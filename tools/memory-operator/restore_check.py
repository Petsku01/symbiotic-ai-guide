"""kuu-memory-operator V3 — restore-inventaario (read-only tuotantoon!):

restore_check = todista että offsite-snapshot palautuu MEKANIIKALTAAN
pohjatiedostoiksi (osion yhdistys → openssl → zstd) JA että mekanismi
tuottaa odotetut artefaktit. EI asenna mitään tuotantoon, EI kirjoita
~/.hermeseen — kaikki temp-hakemistoon.

Ketjun vauriot (offsite work-kansioissa):
  - 4.10 ajo: timeout (600 s) — parts 7-? kesken? audit todistaa
  - 11.10 ajo: push-fail — mutta osat TÄYDELLISET (push-puoli vain)
Testikohde: 11.10 work-kansio (30 f, RESTORE.sh mukana — push-fail ei
vaurioittanut palautusketjun osia; todistettava).
"""
from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

Here = Path(__file__).resolve().parent
HERMES = Path.home() / ".hermes"
OFFSITE_KEY = HERMES / "backup-keys" / "backup.passphrase"
OFFSITE_WORK_ROOT = Path("/scratch/tmp")

# tuotantopolut: EI KOSKETETA — listaan vain inventaariota varten
# nimi-mapping: snapshotissa X.zst → palautus tuottaa plainin eri nimellä
# (files.tar.zst → files.tar; koska zstd-tiedoston sisältö on tar-arkisto)
PRODUCTION_ARTIFACTS = (
    # (snapshot-nimi, palautunut nimi tai None jos sama)
    ("state.db.bak", None),
    ("cortext_memory.db.bak", None),
    ("files.tar.zst", "files.tar"),
)
# offsite-ajojen RESTORE.sh tavanomaiset osat (RESTORE.sh itse tulostaa)


def _sha256(path: Path, limit_bytes: int = 5_000_000) -> str:
    """Pienelle tiedostolle full-SHA, isoille head-SHA (5 MB) + koko."""
    h = hashlib.sha256()
    size = path.stat().st_size
    with open(path, "rb") as f:
        if size <= limit_bytes:
            h.update(f.read())
        else:
            h.update(f.read(limit_bytes))
    return f"{h.hexdigest()[:16]}@{size}"


def _pick_source(stamp: str | None) -> Path:
    """snapshot-work-kansio: aina uusin tai pyydetty."""
    if stamp:
        p = OFFSITE_WORK_ROOT / f"kuu-offsite-{stamp}"
        if p.exists():
            return p
        raise FileNotFoundError(f"pyydetty work-kansio puuttuu: {p}")
    wks = sorted(OFFSITE_WORK_ROOT.glob("kuu-offsite-*"), key=lambda p: p.name)
    if not wks:
        raise FileNotFoundError(f"yhtään offsite-work-kansiota ei löydy {OFFSITE_WORK_ROOT}:sta")
    return wks[-1]


def _safe_temp() -> Path:
    """temp-työkansio /scratchissa (ei tuotantopolkuja; EI koskaan HERMES)"""
    t = Path(tempfile.mkdtemp(prefix="kuu-restore-check-", dir="/scratch/tmp"))
    return t


def _combine_parts(work_src: Path, tmp: Path) -> list[Path]:
    """RESTORE.sh step 1: palautusmateriaalin kokoonpano.
    KÄSITTELEE MOLEMMAT: (a) ositettut .enc.part-* → yhdistetty .enc;
    (b) ei-ositettut .enc → kopioituu sellaisenaan (RESTORE.sh: 'ei-ositettuihin
    ei saa koskea' = ei cat-komennolla, mutta dekryptattavaksi sekin kulkee)."""
    out: list[Path] = []
    # (a) ositettut
    stems = {p.name.rsplit(".part-", 1)[0] for p in work_src.glob("*.enc.part-*")}
    for stem in sorted(stems):
        parts = sorted(work_src.glob(f"{stem}.part-*"))
        target = tmp / stem
        with open(target, "wb") as w:
            for p in parts:
                with open(p, "rb") as r:
                    while True:
                        chunk = r.read(8 * 1024 * 1024)
                        if not chunk:
                            break
                        w.write(chunk)
        out.append(target)
    # (b) ei-ositetut .enc (kopio dekryptausvaiheen nimeä varten)
    for enc in work_src.glob("*.enc"):
        target = tmp / enc.name
        if not target.exists():
            shutil.copy2(enc, target)
            out.append(target)
    return out


def _decrypt(combined: list[Path], tmp: Path) -> list[Path]:
    """RESTORE.sh step 2+3: openssl -> zstd-decode. Nimilogiikka eksplisiittinen:
    X.enc -> X.zst (openssl) -> X (zstd). X = enc-nimi ilman lopputainta."""
    out: list[Path] = []
    for enc in combined:
        stem = enc.name[:-len(".enc")]  # files.tar.zst / state.db.bak.zst
        zst_file = tmp / f"{stem}.out.zst"  # openssl-output (ei nimeä enc-rajapinnalle)
        r = subprocess.run(
            ["openssl", "enc", "-d", "-aes-256-cbc", "-pbkdf2", "-iter", "600000",
             "-in", str(enc), "-out", str(zst_file), "-pass", f"file:{OFFSITE_KEY}"],
            capture_output=True, text=True, timeout=600)
        if r.returncode != 0:
            raise RuntimeError(f"openssl decrypt fail {enc.name}: {(r.stderr or '')[:120]}")
        # zstd-dekoodaus: stem.out.zst -> plain-nimi
        # stem = X.zst → plain = X (esim. state.db.bak.zst -> state.db.bak)
        plain_stem = stem[:-4] if stem.endswith(".zst") else stem
        plain = tmp / plain_stem
        r2 = subprocess.run(["zstd", "-d", "-q", "-f", str(zst_file), "-o", str(plain)],
                           capture_output=True, text=True, timeout=900)
        if r2.returncode != 0:
            raise RuntimeError(f"zstd decode fail {zst_file.name}: {(r2.stderr or '')[:120]}")
        out.append(plain)
    return out


def _verify_inventory(decrypted: list[Path]) -> list[dict]:
    """inventaario: mitkä kolme tuotantoartefaktia palautui + mitkä puuttuvat."""
    rows = []
    names = {p.name for p in decrypted}
    for artifact, restored_name in PRODUCTION_ARTIFACTS:
        target = restored_name or artifact
        if target in names:
            p = next(x for x in decrypted if x.name == target)
            rows.append({"artifact": artifact, "state": "RESTORED",
                         "sha16_size": _sha256(p)})
        else:
            rows.append({"artifact": artifact, "state": "MISSING_FROM_SNAPSHOT"})
    return rows


def cmd_restore_check(args: argparse.Namespace) -> int:
    t0 = time.time()
    rows: list[tuple[str, str]] = []
    try:
        src = _pick_source(args.stamp)
        rows.append(("OK", f"lähde: {src.name} ({len(list(src.iterdir()))} f)"))
    except FileNotFoundError as e:
        print(f"RESTORE-CHECK CRIT: {e}")
        return 1
    if not OFFSITE_KEY.exists():
        print("RESTORE-CHECK CRIT: avain puuttuu:", OFFSITE_KEY)
        return 1
    rows.append(("OK", "avain läsnä"))
    tmp = _safe_temp()
    try:
        if args.audit_only:
            print("RESTORE-CHECK (audit-only; ei palautusta)")
            for tag, msg in rows:
                print(f"  [{tag}] {msg}")
            return 0
        combined = _combine_parts(src, tmp)
        rows.append(("OK", f"osiat yhdistetty: {len(combined)} stemmaa "
                     f"({total_size(combined)/1e9:.2f} GB)"))
        decrypted = _decrypt(combined, tmp)
        rows.append(("OK", f"purettu: {len(decrypted)} artefaktia "
                     f"({total_size(decrypted)/1e9:.2f} GB)"))
        inv = _verify_inventory(decrypted)
        crit = [r for r in inv if r["state"] == "MISSING_FROM_SNAPSHOT"]
        for r in inv:
            tag = "OK" if r["state"] == "RESTORED" else "CRIT"
            rows.append((tag, f"inventaario {r['artifact']}: {r['state']} "
                         f"{r.get('sha16_size', '')}"))
        dur = time.time() - t0
        n_crit = len(crit)
        print(f"RESTORE-CHECK: {n_crit} CRIT / ok-rivit {len(rows)-n_crit} "
              f"({dur:.1f}s)")
        for tag, msg in rows:
            print(f"  [{tag}] {msg}")
        return 1 if crit else 0
    finally:
        if not args.keep:
            shutil.rmtree(tmp, ignore_errors=True)
        else:
            print(f"  temp jätetty: {tmp}")


def total_size(paths: list[Path]) -> int:
    return sum(p.stat().st_size for p in paths)


def register_v3(sub: argparse.ArgumentParser) -> None:
    p = sub.add_parser("restore-check",
                       help="palautuskokeilu snapshotista: osit+decrypt+inventaario (temp)")
    p.add_argument("--stamp", help="snapshot-stamp (esim. 2026-10-11_0400); oletus uusin")
    p.add_argument("--keep", action="store_true", help="jätä temp-kansio debuggaus")
    p.add_argument("--audit-only", action="store_true",
                   help="vain avain+lähde tarkistus, EI palautusta")
    p.set_defaults(func=lambda a: cmd_restore_check(a))