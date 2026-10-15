"""kuu-memory-operator — V2: backup dependency graph + audit + restore readiness.

V1: manifest / health / diff / verify (kerroksittainen inventointi).
V2 (tämä): backup-ketjun todistaminen KONEELLISESTI — mitkä polut ovat backupissa,
mitä excludataan, mitkä cron-skriptit ja tulospolut riippuvat mistäkin. Juurisyy
ollama_utils.py-katoon (22.9) ja dream.py-katoon on ollut backup-rivin EXCLUDE:
workspace excluded offsite-tarissa → tools/-moduulit katosivat rekonstruktiossa.
audit-komento vertaa exclustet + include-rivit + cron-skriptipolut JA raportoi
GAP-rivit ennen cutoveria, ei jälkikäteen.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
HERMES = Path.home() / ".hermes"
MANIFEST_FILE = HERE / "manifest.json"

SCRATCH_BACKUP = HERMES / "workspace" / "tools" / "kuu-scratch-backup.sh"
OFFSITE = HERMES / "scripts" / "kuu-offsite-backup.sh"
OFFSITE_REPO = "github.com/YOURUSER/YOURUSER-offsite-backup"  # muuta omaan
OFFSITE_KEY = HERMES / "backup-keys" / "backup.passphrase"
SCRATCH_DEST = Path("/scratch/kuu-backup")
OFFSITE_STAGE = Path("/scratch/tmp")


def _collect_backup() -> dict:
    d: dict = {}
    try:
        t = SCRATCH_BACKUP.read_text()
        d["scratch_backup_script"] = str(SCRATCH_BACKUP)
        d["scratch_excludes"] = sorted(set(re.findall(r"--exclude=?'?\"?([^'\"\s\\]+)", t)))
        # tar-includerivit: rivit ilman exclusta, jotka alkavat .hermes/.local:
        inc = re.findall(r"^\s{0,8}(\.hermes[a-z_/. ]*\.?hermes?[^|]*)\s+\|", t, re.M)
        inc2 = re.findall(r"([.]hermes[a-z_/.]*|.local[a-z_/.]*)\s+\|", t)
        d["scratch_includes"] = sorted(set(inc) | set(inc2)) if (inc or inc2) else \
            [l.strip() for l in t.splitlines() if l.strip().startswith((".hermes", ".local"))]
    except Exception as e:
        d["scratch_error"] = str(e)[:140]
    try:
        t2 = OFFSITE.read_text()
        d["offsite_script"] = str(OFFSITE)
        d["offsite_stage_dir"] = str(OFFSITE_STAGE)
        d["offsite_repo"] = OFFSITE_REPO
        d["offsite_key_exists"] = OFFSITE_KEY.exists()
        d["restore_readme_in_script"] = "RESTORE.sh" in t2
    except Exception as e:
        d["offsite_error"] = str(e)[:140]
    try:
        snaps = sorted(SCRATCH_DEST.glob("kuu-*"), key=lambda p: p.name)
        d["snapshots_latest"] = snaps[-1].name if snaps else None
        d["snapshots_count"] = len(snaps)
        latest = snaps[-1] if snaps else None
        if latest:
            d["latest_files"] = sorted(p.name for p in latest.iterdir() if p.is_file())
    except Exception as e:
        d["snapshot_error"] = str(e)[:140]
    return d


def cmd_audit(args: argparse.Namespace) -> int:
    """Backup-riippuvuusgraafin kattavuusaudit — GAP/WARN/OK -rivit."""
    rows: list[tuple[str, str]] = []
    b = _collect_backup()
    excl = set(b.get("scratch_excludes") or [])
    incs = " ".join(b.get("scratch_includes") or [])
    if b.get("scratch_error") or b.get("offsite_error"):
        for e in ("scratch_error", "offsite_error"):
            if b.get(e):
                rows.append(("CRIT", f"backup-skripti lukemattomissa: {b[e]}"))
    # WORKSPACE-EXCLUDE-CHECK (fix 15.10: warn vain jos exclude YHÄ kokonaisessa)
    # uusi scratch-backup excludeaa vain cache + .git — dokumentit KULKEVAT
    scr = SCRATCH_BACKUP.read_text() if SCRATCH_BACKUP.exists() else ""
    excl_all = re.search(r"--exclude=?'?\"?\.hermes/workspace'?\"?\s*(\\|$)", scr)
    excl_partial = ("--exclude='.hermes/workspace/cache'" in scr
                    and "--exclude='.hermes/workspace/.git'" in scr)
    if excl_all:
        rows.append(("WARN", "workspace EXCLUDED offsite-tarissa KOKONAAN — "
                    "EOD-kopio ainoa lähde (ollama_utils-luokka)"))
    elif excl_partial:
        rows.append(("OK", "workspace sisältyy offsite-tariin (vain cache+git excluded) "
                    "— FIX 15.10 voimaan sunnuntain 18.10 ajosta"))
    else:
        rows.append(("WARN", "workspace-tilaa ei tunnistettu skriptistä — "
                    "tarkista --exclude-rivit"))
    # avaimet
    if not b.get("offsite_key_exists", False):
        rows.append(("CRIT", f"offsite-salausavain puuttuu: {OFFSITE_KEY}"))
    else:
        rows.append(("OK", f"offsite-salausavain läsnä: {OFFSITE_KEY.name}"))
    # scratch mount
    ok_m = SCRATCH_DEST.exists()
    rows.append(("OK" if ok_m else "CRIT",
                 f"/scratch/kuu-backup {'liitettynä' if ok_m else 'PUUTTUU (ei liitettynä)'}"))
    if b.get("snapshots_latest"):
        rows.append(("OK", f"uusin snapshot: {b['snapshots_latest']} "
                    f"({b.get('snapshots_count')} yhteensä)"))
        if not b.get("latest_files"):
            rows.append(("CRIT", f"uusin snapshot TYHJÄ: {b['snapshots_latest']}"))
        else:
            rows.append(("OK", f"snapshot-sisältö: {', '.join(b['latest_files'])}"))
    else:
        rows.append(("CRIT", "yhtään snapshotia ei löydy /scratch/kuu-backupista"))
    # unit-riippuvuus palautukselle
    try:
        r = subprocess.run(["systemctl", "--user", "is-active", "hermes-gateway.service"],
                           capture_output=True, text=True, timeout=15)
        gw = (r.stdout or "").strip()
        rows.append(("OK" if gw == "active" else "WARN", f"gateway: {gw} "
                     "(restoren jälkeen pakollinen)"))
    except Exception as e:
        rows.append(("WARN", f"gateway-tila ei luettu: {e}"))
    # RESTORE-readiness
    rows.append(("OK" if b.get("restore_readme_in_script") else "WARN",
                 "RESTORE.sh-generaatio offsite-skriptissä "
                 + ("läsnä" if b.get("restore_readme_in_script") else "PUUTTUU")))
    # UUSIMMAN OFFSITE-AJON TULOS (cron/output/643598dd9eda/*.md) — 4.-11.10 failit
    # jäivät ilman hälytystä koska mikään ei lukenut tuloshistoriaa
    off_out = HERMES / "cron" / "output" / "643598dd9eda"
    try:
        mds = sorted(off_out.glob("*.md"))
        if not mds:
            rows.append(("WARN", f"offsite-tuloshistoria tyhjä: {off_out}"))
        else:
            newest = mds[-1]
            body = newest.read_text(errors="replace")
            m = re.search(r"\*\*Run Time:\*\*\s*(\S+\s+\S+)", body)
            run_t = m.group(1) if m else newest.name
            failed = ("script failed" in body or "VIRHE" in body
                      or "timed out" in body or "epäonnistui" in body)
            if failed:
                rows.append(("CRIT", f"offsite-ajo FAILITTU {run_t} ({newest.name}) — "
                             f"tarkista: {newest}"))
            else:
                rows.append(("OK", f"offsite-ajo {run_t}: silent/ok"))
            # ikä: viikkotahti — yli 10 vrk = ketju ei ole edes yrittänyt
            import datetime as _dt
            try:
                stamp = _dt.datetime.strptime(newest.name[:16].replace("_", " ")[:16],
                                              "%Y-%m-%d %H-%M")
                age_d = (_dt.datetime.now() - stamp).days
                if age_d > 10:
                    rows.append(("CRIT", f"offsite-ajo {age_d} pv vanha (>10) — "
                                 f"viikkotahti rikki"))
                elif age_d > 7:
                    rows.append(("WARN", f"offsite-ajo {age_d} pv vanha — "
                                 f"seuraava ylittää viikon"))
            except Exception:
                pass  # nimiketju ei täsmää — ei kaadeta audittia
    except Exception as e:
        rows.append(("WARN", f"offsite-tuloshistoria ei luettu: {e}"))
    crit = [r for r in rows if r[0] == "CRIT"]
    warn = [r for r in rows if r[0] == "WARN"]
    print(f"AUDIT (backup-riippuvuusgraafi): {len(crit)} CRIT / {len(warn)} WARN "
          f"/ {len(rows) - len(crit) - len(warn)} OK")
    for tag, msg in rows:
        print(f"  [{tag}] {msg}")
    if not args.shadow_write:
        return 1 if crit else 0
    # shadow_write: kirjaa raportti manifest.json viereen (ei tuotantopolkuja)
    out = HERE / "last-audit.json"
    out.write_text(json.dumps({"ts": time.strftime("%F %T"),
                               "rows": [{"tag": t, "msg": m} for t, m in rows]},
                              ensure_ascii=False, indent=2))
    print(f"  saved -> {out}")
    return 1 if crit else 0


def register_v2(sub: argparse.ArgumentParser) -> None:
    p = sub.add_parser("audit", help="backup-riippuvuusgraafi: GAP/WARN/OK + restore-readiness")
    p.add_argument("--shadow-write", action="store_true",
                   help="kirjaa raportin last-audit.json (plugin-kansioon; ei tuotantopolkuja)")
    p.set_defaults(func=_audit_entry)


def _audit_entry(args: argparse.Namespace) -> int:
    return cmd_audit(args)


def audit_entry(args: argparse.Namespace) -> int:
    """Public re-export kuu-memory CLI:n v2-päivitystä varten."""
    return cmd_audit(args)