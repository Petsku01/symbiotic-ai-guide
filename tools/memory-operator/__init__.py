"""kuu-memory-operator — memory subsystem OPERATOR plugin.

Operator tooling: inventory (manifest), health, drift diff. NOTHING here owns a
memory path: HOT (memories/MEMORY.md) stays Hermes-native, WARM stays the cortext
MemoryProvider, compression stays jev (ContextEngine). This plugin never writes
memory, never auto-promotes shadows, never touches production without --apply
(flag declared in v2; v1 is read-only).

Layer map (what this inventories):
  hot     memories/MEMORY.md (capacity, entry/separator sanity — read-only)
  warm    cortext_memory.db (size, mtime, canary query via cortext_cli probe)
  cold    memories/memory-archive/*.md + quarantine.jsonl + evictions.jsonl
  cron    cron/jobs.json (id, name, schedule, enabled) — source of truth
  units   systemd --user units (hermes/jev/strata/orca)
  scripts scripts/*.py count + muisti/cortext subset
"""
from __future__ import annotations

import argparse
import json
import sqlite3
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Callable

import importlib.util as _ilu

_HERE = Path(__file__).resolve().parent

def _load_v2_module():
    p = _HERE / "backup_graph.py"
    if not p.exists():
        return None
    spec = _ilu.spec_from_file_location("kuu_memory_operator_v2", p)
    mod = _ilu.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

V2 = _load_v2_module()

def _load_v3_module():
    p = _HERE / "restore_check.py"
    if not p.exists():
        return None
    spec = _ilu.spec_from_file_location("kuu_memory_operator_v3", p)
    mod = _ilu.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

V3 = _load_v3_module()

HERMES = Path.home() / ".hermes"
MANIFEST_FILE = HERMES / "plugins" / "kuu-memory-operator" / "manifest.json"

# --- collectors ------------------------------------------------------------


def _collect_cron() -> dict[str, Any]:
    """cron/jobs.json is the scheduler's own source of truth."""
    p = HERMES / "cron" / "jobs.json"
    out: dict[str, Any] = {"source": str(p), "jobs": [], "count": 0, "enabled": 0, "disabled": 0}
    try:
        data = json.loads(p.read_text())
        jobs = data if isinstance(data, list) else data.get("jobs") or []
        for j in jobs:
            st = j.get("status") or ("enabled" if j.get("enabled") is not False else "disabled")
            out["jobs"].append({"id": j.get("id"), "name": j.get("name"),
                                "schedule": j.get("schedule") or j.get("interval"), "status": st})
        out["count"] = len(out["jobs"])
        out["enabled"] = sum(1 for j in out["jobs"] if j["status"] != "disabled")
        out["disabled"] = out["count"] - out["enabled"]
    except Exception as e:
        out["error"] = str(e)[:120]
    return out


def _collect_units() -> dict[str, Any]:
    wanted = ("hermes-gateway.service", "hermes-jev-local-primary.service",
              "hermes-jev-local-primary.socket", "hermes-jev-reranker.service",
              "strata.service", "orca.service")
    res: dict[str, Any] = {"wanted": list(wanted), "units": {}}
    for u in wanted:
        r = subprocess.run(["systemctl", "--user", "is-active", u],
                           capture_output=True, text=True, timeout=20)
        res["units"][u] = (r.stdout or "").strip() or "unknown"
    return res


def _collect_hot() -> dict[str, Any]:
    p = HERMES / "memories" / "MEMORY.md"
    d: dict[str, Any] = {"path": str(p)}
    try:
        t = p.read_text()
        lines = t.splitlines()
        d.update(chars=len(t), lines=len(lines), entries=len(lines) - lines.count("§"),
                 separators=lines.count("§"),
                 pct=round(100 * len(t) / 10000, 1),
                 orphan_pairs=None)
        seps = [i for i, l in enumerate(lines) if l.strip() == "§"]
        d["orphan_pairs"] = sum(1 for a, b in zip(seps, seps[1:]) if b - a == 1)
    except Exception as e:
        d["error"] = str(e)[:120]
    return d


def _collect_warm() -> dict[str, Any]:
    p = HERMES / "cortext_memory.db"
    d: dict[str, Any] = {"path": str(p)}
    try:
        st = p.stat()
        d.update(size_mb=round(st.st_size / 1e6, 1),
                 mtime=time.strftime("%F %T", time.localtime(st.st_mtime)))
    except Exception as e:
        d["error"] = str(e)[:120]
    return d


def _collect_cold() -> dict[str, Any]:
    mem = HERMES / "memories"
    d: dict[str, Any] = {}
    arch = mem / "memory-archive"
    d["archive_files"] = sorted(f.name for f in arch.glob("*.md")) if arch.exists() else []
    for name in ("quarantine.jsonl", "evictions.jsonl"):
        p = mem / name
        d[name] = {"exists": p.exists(),
                   "lines": sum(1 for _ in p.open(errors="replace")) if p.exists() else 0}
    return d


def _collect_scripts() -> dict[str, Any]:
    s = HERMES / "scripts"
    pys = sorted(s.glob("*.py"))
    return {"total_py": len(pys),
            "memory_cortext": len([p for p in pys if p.name.startswith(("memory", "cortext"))])}


COLLECTORS: dict[str, Callable[[], dict[str, Any]]] = {
    "hot": _collect_hot, "warm": _collect_warm, "cold": _collect_cold,
    "cron": _collect_cron, "units": _collect_units, "scripts": _collect_scripts,
    "backup": lambda: (V2._collect_backup() if V2 else {"error": "v2-moduuli puuttuu"}),
}


def build_manifest() -> dict[str, Any]:
    m: dict[str, Any] = {"schema": "kuu-memory-operator/manifest@1", "generated_at":
                         time.strftime("%F %T"), "layers": {k: f() for k, f in COLLECTORS.items()}}
    try:
        MANIFEST_FILE.write_text(json.dumps(m, ensure_ascii=False, indent=2))
    except Exception as e:
        m["_manifest_write_error"] = str(e)[:120]
    return m


def load_saved_manifest() -> dict[str, Any] | None:
    try:
        return json.loads(MANIFEST_FILE.read_text())
    except Exception:
        return None


# --- commands ---------------------------------------------------------------


def _fmt(m: dict[str, Any]) -> str:
    L = m["layers"]
    hot, warm, cron, units, cold, scr = L["hot"], L["warm"], L["cron"], L["units"], L["cold"], L["scripts"]
    lines = [
        f"MANIFEST (saved {m['generated_at']}):",
        f"  hot:    {hot.get('chars')} chars / {hot.get('pct')} % | entries {hot.get('entries')} | § {hot.get('separators')} | §-pairs {hot.get('orphan_pairs')}",
        f"  warm:   {warm.get('size_mb')} MB, mtime {warm.get('mtime')}",
        f"  cold:   archive {len(cold['archive_files'])} file: {', '.join(cold['archive_files']) or '-'} | quarantine {cold['quarantine.jsonl']['lines']} | evictions {cold['evictions.jsonl']['lines']}",
        f"  cron:   {cron.get('count')} jobs ({cron.get('enabled')} enabled / {cron.get('disabled')} disabled)",
        f"  units:  {'; '.join(f'{u.split(chr(46))[0].replace(chr(45), chr(45))}={v}' for u, v in units['units'].items())}",
        f"  scripts:{scr.get('total_py')} py total ({scr.get('memory_cortext')} muisti/cortext)",
    ]
    return "\n".join(lines)


def cmd_manifest(args: argparse.Namespace) -> int:
    m = build_manifest()
    print(_fmt(m))
    if not m.get("_manifest_write_error"):
        print(f"  saved -> {MANIFEST_FILE}")
    return 0


def _healthy(hot: dict, warm: dict, cron: dict, units: dict) -> tuple[bool, list[str]]:
    prob: list[str] = []
    if hot.get("orphan_pairs", 0):
        prob.append(f"HOT: {hot['orphan_pairs']} §-paria (erottimen jäännös)")
    if hot.get("pct", 0) >= 95:
        prob.append(f"HOT: {hot['pct']} % CRIT-katto") 
    elif hot.get("pct", 0) >= 85:
        prob.append(f"HOT: {hot['pct']} % soft-gate")
    if warm.get("size_mb", 0) > 500:
        prob.append(f"WARM: {warm['size_mb']} MB — kasvuseurantahälytys")
    if units["units"].get("hermes-gateway.service") not in ("active",):
        prob.append("UNIT: hermes-gateway ei active")
    jev = units["units"].get("hermes-jev-local-primary.socket")
    if jev not in ("active", "inactive"):  # inactive ok on-demand mallissa
        prob.append(f"UNIT: jev-socket {jev}")
    return bool(prob), prob


def cmd_health(args: argparse.Namespace) -> int:
    m = build_manifest()
    L = m["layers"]
    # FIX 15.10 (Solin inventointi P0): virhe-injektiot NÄKYVÄT statuksessa —
    # bad laskettiin aiemmin ennen errors/prob-lisäyksiä → rc=0 viallisen datan kanssa
    bad, prob = _healthy(L["hot"], L["warm"], L["cron"], L["units"])
    errors = [f"{k}: {L[k].get('error')}" for k in L if isinstance(L[k], dict) and L[k].get("error")]
    if L["cron"].get("count", 0) == 0 and not L["cron"].get("error"):
        prob.append("CRON: 0 jobia — jobs.json-luku epäonnistui hiljaa?")
    if errors:
        prob.extend(f"COLLECT {e}" for e in errors)
    # FIX 15.10: USER.md- ja MISTAKES-kattotarkistus + moniriviblock-havainto
    mem = HERMES / "memories"
    try:
        u_chars = len((mem / "USER.md").read_text())
        if u_chars >= 3000 * 0.9:
            prob.append(f"USER: {round(100 * u_chars / 3000)} % — katko lähestyy")
        if u_chars >= 3000:
            bad = True
    except Exception as e:
        prob.append(f"USER-lukuvirhe: {str(e)[:60]}")
        bad = True
    try:
        mst = (HERMES / "MISTAKES.md").read_text()
        n_entries = len([l for l in mst.splitlines() if l.startswith("### ")])
        if n_entries >= 15:
            prob.append(f"MISTAKES: {n_entries}/15 katto TÄYNNÄ — uutta entryta ei voi kirjata")
    except Exception as e:
        prob.append(f"MISTAKES-lukuvirhe: {str(e)[:60]}")
    monirivi = (L["hot"].get("separators", 0) + 1) - L["hot"].get("entries", 0)
    if monirivi > 1:
        prob.append(f"HOT-RAKENNE: {monirivi - 1} monirivistä lohkoa — 'entry=1 rivi' ei "
                    f"toteudu (Solin inventointi); kanoninen parseri tarvitaan")
    bad = bad or bool(errors)
    print("HEALTH:", "PROBLEM" if bad or prob else "OK")
    for p in prob:
        print("  !", p)
    if not prob:
        print("  (ei havaintoja — kaikki kerrosrajit vihreällä)")
    return 1 if bad or errors else 0


def cmd_diff(args: argparse.Namespace) -> int:
    saved = load_saved_manifest()
    if not saved:
        print("Ei tallennettua manifestia — aja: hermes kuu-memory manifest")
        return 2
    now = build_manifest()

    def flat(m: dict) -> dict:
        L = m["layers"]
        f = {"hot.chars": L["hot"].get("chars"), "hot.entries": L["hot"].get("entries"),
             "hot.sep_pairs": L["hot"].get("orphan_pairs"), "hot.pct": L["hot"].get("pct"),
             "warm.size_mb": L["warm"].get("size_mb"),
             "cold.archive": len(L["cold"]["archive_files"]),
             "cold.quarantine": L["cold"]["quarantine.jsonl"]["lines"],
             "cold.evictions": L["cold"]["evictions.jsonl"]["lines"],
             "cron.count": L["cron"].get("count"), "cron.enabled": L["cron"].get("enabled"),
             "scripts.total_py": L["scripts"].get("total_py"),
             "scripts.memory_cortext": L["scripts"].get("memory_cortext")}
        b = L.get("backup") or {}
        f["backup.key_exists"] = b.get("offsite_key_exists")
        f["backup.snapshots"] = b.get("snapshots_count")
        f["backup.snapshot_latest"] = b.get("snapshots_latest")
        for u, v in L["units"]["units"].items():
            f[f"unit.{u}"] = v
        return f

    a, b = flat(saved), flat(now)
    drift = {k: (a.get(k), b.get(k)) for k in b if a.get(k) != b.get(k)}
    if not drift:
        print("DIFF: identtinen viimeiseen manifestiin")
        return 0
    print(f"DIFF ({len(drift)} muutosta vs {saved['generated_at']}):")
    for k, (x, y) in sorted(drift.items()):
        print(f"  {k}: {x} -> {y}")
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    m = build_manifest()
    L = m["layers"]
    ok = True
    if L["cron"].get("count", 0) < 5:
        print("  FAIL cron count implausibly small:", L["cron"])
        ok = False
    units_ok = L["units"]["units"].get("hermes-gateway.service") == "active"
    if not units_ok:
        ok = False
    if L["hot"].get("chars", 0) < 1000:
        ok = False
        print("  FAIL hot too small:", L["hot"].get("chars"))
    if L["warm"].get("size_mb", 0) < 10:
        ok = False
        print("  FAIL warm db implausibly small")
    print("VERIFY:", "OK — manifest-realismi läpi (cron/luku/unit/hot/warm)" if ok else "FAIL")
    return 0 if ok else 1


def register_cli(sub: argparse.ArgumentParser) -> None:
    s = sub.add_subparsers(dest="cmd", required=True)
    s.add_parser("manifest", help="inventoi kerrospuu ja tallentaa manifest.json").set_defaults(
        func=cmd_manifest)
    s.add_parser("health", help="kerrosrajat + unit-tilat, exit1 jos ongelma").set_defaults(
        func=cmd_health)
    s.add_parser("diff", help="muutokset vs. tallennettu manifesti").set_defaults(func=cmd_diff)
    s.add_parser("verify", help="manifest-realismi (cron>5, gateway active, hot>1k)").set_defaults(
        func=cmd_verify)
    # V2
    if V2 is not None:
        # rekisteröidään audit suoraan pääparseriin V2-moduulin audit_entry-funktiolla
        ap = s.add_parser("audit", help="backup-riippuvuusgraafi: GAP/WARN/OK + restore-readiness")
        ap.add_argument("--shadow-write", action="store_true",
                        help="kirjaa raportin last-audit.json (plugin-kansioon)")
        ap.set_defaults(func=V2.audit_entry)
    # V3
    if V3 is not None:
        r3 = s.add_parser("restore-check",
                          help="palautuskokeilu temp-hakemistoon (ei tuotantoon)")
        r3.add_argument("--stamp", help="snapshot-stamp; oletus uusin work-kansio")
        r3.add_argument("--keep", action="store_true", help="jätä temp-kansio")
        r3.add_argument("--audit-only", action="store_true",
                        help="vain avain+lähde tarkistus, ei palautusta")
        r3.set_defaults(func=V3.cmd_restore_check)


def cmd_root(args: argparse.Namespace) -> int:
    return args.func(args)


def register(ctx) -> None:
    ctx.register_cli_command(
        name="kuu-memory", help="Kuu memory operator (manifest, health, diff, verify, audit)",
        setup_fn=register_cli, handler_fn=cmd_root,
        description="Memory operator: inventory manifest, health (USER/MISTAKES caps, hot-structure), drift diff, backup-riippuvuusgraafi audit.")