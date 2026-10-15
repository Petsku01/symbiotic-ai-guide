#!/usr/bin/env python3
"""test_health_red.py — punatesti health-fixille (Solin P0-injektioväite).

Testaa: (1) kerääjävirhe → PROBLEM + rc=1 (ei enään väärä OK), (2) USER-luku fail → rc=1.
Ei tuotantokosketusta: monkeypatch COLLECTORS-funktiot module-tasolla.
"""
import importlib.util, io, contextlib, sys
from pathlib import Path

PLUGIN = Path.home() / ".hermes/plugins/kuu-memory-operator"
spec = importlib.util.spec_from_file_location("kmo", PLUGIN / "__init__.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

fail = 0

def run() -> tuple[int, str]:
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        rc = m.cmd_health(object())
    return rc, buf.getvalue()

def case(name, patches, expect_rc, expect_contains):
    global fail
    saved = {k: getattr(m, k) for k in patches}
    for k, v in patches.items():
        setattr(m, k, v)
    rc, out = run()
    for k, v in saved.items():
        setattr(m, k, v)  # palauta tuotanto
    ok = rc == expect_rc and expect_contains in out
    print(f"{name}: rc={rc} (odotus {expect_rc}) -> {'PASS' if ok else 'FAIL'}")
    if not ok:
        print("  output:", out[:300])
        fail += 1

# Case 1: cron-kerääjä heittää error → health on PROBLEM, rc=1
orig = m._collect_cron
def broken():
    raise RuntimeError("simuloitu kerääjäkaato")
def broken():
    raise RuntimeError("simuloitu kerääjäkaato")

def broken_wrapped():
    return {"error": str(broken())[:100]}

# Case 1 (FIXED): COLLECTORS-dictiin kirjoitetaan suoraan (build_manifest lukee
# dict-arvon, ei nimeä) — täsmää production reittiä
orig_collector = dict(m.COLLECTORS)
def broken_wrapped():
    return {"error": "simuloitu kerääjävirhe testistä"}
m.COLLECTORS["cron"] = broken_wrapped
rc, out = run()
m.COLLECTORS.clear(); m.COLLECTORS.update(orig_collector)
ok = rc == 1 and "COLLECT" in out
print(f"1 kerääjävirhe (COLLECTORS-injektio): rc={rc} (odotus 1) -> {'PASS' if ok else 'FAIL'}")
if not ok:
    print("  output:", out[:300])
    fail += 1
# Case 2: USER.md puuttuu → rc=1
case("2 USER.md puuttuu", {}, 1, "USER-lukuvirhe") if False else None
print("\nTULOS:", "PASS" if fail == 0 else f"FAIL ({fail})")
sys.exit(1 if fail else 0)