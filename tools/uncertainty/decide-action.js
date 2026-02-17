#!/usr/bin/env node

function clamp01(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(1, x));
}

function parse(arg) {
  if (!arg) throw new Error('Provide JSON string');
  return JSON.parse(arg);
}

function decide({ risk, severity, tLow = 0.35, tHigh = 0.60, highSeverityEscalate = 0.8 }) {
  const r = clamp01(risk);
  const s = clamp01(severity);

  if (s >= highSeverityEscalate && r >= tLow) {
    return { action: 'ESCALATE', reason: 'high_severity_gate', risk: r, severity: s };
  }
  if (r >= tHigh) return { action: 'ESCALATE', reason: 'risk_high', risk: r, severity: s };
  if (r >= tLow) return { action: 'AUTO_ACT_WITH_CAUTION', reason: 'risk_medium', risk: r, severity: s };
  return { action: 'AUTO_ACT', reason: 'risk_low', risk: r, severity: s };
}

try {
  const input = parse(process.argv[2]);
  const out = decide(input);
  console.log(JSON.stringify(out, null, 2));
} catch (err) {
  console.error(`Error: ${err.message}`);
  console.error('Usage: node tools/uncertainty/decide-action.js "{\"risk\":0.42,\"severity\":0.7}"');
  process.exit(1);
}
