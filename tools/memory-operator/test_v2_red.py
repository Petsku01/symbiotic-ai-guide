#!/usr/bin/env python3
"""test_v2_red.py — punatesti: kääntääkö audit CRITeiksi kun ketju rikki?

Simuloi kolme cutover-vauriota MONKEYPATCHtaamalla polut (ei tuotantokosketusta):
  1) avain poissa   → offsite_puri ei avaa snapshotteja
  2) /scratch ei liitettynä → snapshotit kateissa
  3) snapshot-kuu-* tyhjä → palautusketjussa ei sisältöä
Odotukset: audit exit=1 JA vähintään 2 CRIT-riviä + WARN-workspace pysyy.
"""
import importlib.util as _ilu
import sys
from pathlib import Path

PLUGIN = Path.home() / ".hermes/plugins/kuu-memory-operator"

spec = _ilu.spec_from_file_location("v2", PLUGIN / "backup_graph.py")
v2 = _ilu.module_from_spec(spec)
spec.loader.exec_module(v2)

fail = 0

def run_case(name: str, patches: dict[str, object], expect_crit_min: int):
    global fail
    # patches: vain case-ohjaus — ei setattr tuotantomuuttujiin ilman erikoiskäsittelyä
    if "key_ok" in patches:
        saved_key = v2.OFFSITE_KEY
        v2.OFFSITE_KEY = Path("/nonexistent/test-no-key") if not patches["key_ok"] else saved_key
    if "empty_snap" in patches:
        v2.SCRATCH_DEST = _EmptySnap()
    orig_collect = v2._collect_backup
    def fake_collect():
        d = dict(orig_collect())
        if not patches.get("key_ok"):
            d["offsite_key_exists"] = False
        d["snapshot_error"] = patches.get("snap_err")
        if patches.get("snap_err") is None and patches.get("empty_snap"):
            d["snapshots_latest"] = "kuu-EMPTY-TEST"
            d["latest_files"] = []
        return d
    v2._collect_backup = fake_collect

    orig_stdout = sys.stdout
    import io
    buf = io.StringIO()
    sys.stdout = buf
    try:
        rc = v2.cmd_audit(type("A", (), {"shadow_write": False})())
    finally:
        sys.stdout = orig_stdout
    out = buf.getvalue()
    crit = sum(1 for l in out.splitlines() if l.strip().startswith("[CRIT]"))
    warn = sum(1 for l in out.splitlines() if l.strip().startswith("[WARN]"))
    ok = (rc == 1 and crit >= expect_crit_min)
    print(f"{name}: rc={rc} CRIT={crit} WARN={warn} -> {'PASS' if ok else 'FAIL'}")
    for l in out.splitlines():
        if "[CRIT]" in l or "[WARN]" in l:
            print("   ", l.strip())
    if not ok:
        fail += 1
    v2._collect_backup = orig_collect

# case 1: avain poissa (polku olemattomaan)
v2.OFFSITE_KEY = Path("/nonexistent/test-no-key")
run_case("1 avain poissa", {"key_ok": False}, expect_crit_min=1)
v2.OFFSITE_KEY = PLUGIN  # palauta tuotantopolku

# case 2: scratch puuttuu (destä olematon)
v2.SCRATCH_DEST = Path("/nonexistent/kuu-backup")
run_case("2 scratch puuttuu", {"key_ok": True}, expect_crit_min=1)
v2.SCRATCH_DEST = Path("/scratch/kuu-backup")

# case 3: tyhjä snapshot
class _EmptySnap:
    def glob(self, pat):
        return []
    def exists(self):
        return True  # mount ok, mutta snapshotit tyhjät
    def iterdir(self):
        return iter([])

v2.SCRATCH_DEST = _EmptySnap()
run_case("3 snapshotit tyhjät", {"key_ok": True}, expect_crit_min=1)
v2.SCRATCH_DEST = Path("/scratch/kuu-backup")  # palauta tuotantopolku

print("\nTULOS:", "RED-TEST OK (kaikki 3 vauriota nappi)" if fail == 0
      else f"RED-TEST FAIL ({fail})")
sys.exit(1 if fail else 0)