#!/usr/bin/env python3
"""v3-red-test.py — punatesti restore-checkille (ei tuotantokosketusta).

Sama pääjakaja kuten V2-punatesti: monkeypatch OFFSITE_KEY, OFFSITE_WORK_ROOT.
Testit: (1) avain puuttuu → CRIT + rc=1, (2) kohdekansio puuttuu → CRIT + rc=1,
(3) audit-only ei dekryptaa (keinotekoinen: audit-only + uudessa tilapäishakiossa).
"""
import importlib.util
import io
import contextlib
import sys
from pathlib import Path

PLUGIN = Path.home() / ".hermes/plugins/kuu-memory-operator"
spec = importlib.util.spec_from_file_location("v3", PLUGIN / "restore_check.py")
v3 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v3)

fail = 0
def case(name: str, patch_key: str, bad_value, expect_contains: str):
    global fail
    saved = getattr(v3, patch_key)
    setattr(v3, patch_key, bad_value)
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = v3.cmd_restore_check(type("A", (), {"audit_only": True, "stamp": None, "keep": False})())
    setattr(v3, patch_key, saved)
    ok = rc == 1 and expect_contains in buf.getvalue()
    print(f"{name}: rc={rc} -> {'PASS' if ok else 'FAIL'}  ({buf.getvalue().strip()[:100]})")
    if not ok:
        fail += 1

case("1 avain puuttuu", "OFFSITE_KEY", Path("/nonexistent/no-key"), "CRIT")
case("2 work-juuri puuttuu", "OFFSITE_WORK_ROOT", Path("/nonexistent/kuu"), "CRIT")

# Case 3: audit-only ei kirjoita temp-kansioon (ei dekryptaa) — varmista:
buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    rc = v3.cmd_restore_check(type("A", (), {"audit_only": True, "stamp": None, "keep": False})())
import glob
temps_before = glob.glob("/scratch/tmp/kuu-restore-check-*")
if rc == 0 and not temps_before:
    print(f"3 audit-only ei temp-kansiota: PASS")
else:
    print(f"3 audit-only ei temp-kansiota: FAIL (rc={rc}, temps: {temps_before})")
    fail += 1

print("\nTULOS:", "RED-TEST OK (3/3)" if fail == 0 else f"RED-TEST FAIL ({fail})")
sys.exit(1 if fail else 0)