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

function bandFromRisk(risk) {
  if (risk >= 0.6) return 'high';
  if (risk >= 0.35) return 'mid';
  return 'low';
}

function normalizeInput(input) {
  const risk = clamp01(input.risk);
  const severity = clamp01(input.severity ?? (input.signals && input.signals.severity));
  const scoreBand = input.scoreBand || bandFromRisk(risk);

  return {
    ...input,
    risk,
    severity,
    scoreBand,
    tLow: clamp01(input.tLow ?? 0.35),
    tHigh: clamp01(input.tHigh ?? 0.6),
    highSeverityEscalate: clamp01(input.highSeverityEscalate ?? 0.8),
  };
}

function decide(raw) {
  const ctx = normalizeInput(raw);
  const { risk, severity, tLow, tHigh, highSeverityEscalate } = ctx;

  let action = 'AUTO_ACT';
  let decisionReason = `risk ${risk.toFixed(2)} < low threshold ${tLow.toFixed(2)}`;
  let reason = 'risk_low';

  if (severity >= highSeverityEscalate && risk >= tLow) {
    action = 'ESCALATE';
    reason = 'high_severity_gate';
    decisionReason = `severity ${severity.toFixed(2)} >= ${highSeverityEscalate.toFixed(2)} and risk ${risk.toFixed(2)} >= ${tLow.toFixed(2)}`;
  } else if (risk >= tHigh) {
    action = 'ESCALATE';
    reason = 'risk_high';
    decisionReason = `risk ${risk.toFixed(2)} >= high threshold ${tHigh.toFixed(2)}`;
  } else if (risk >= tLow) {
    action = 'AUTO_ACT_WITH_CAUTION';
    reason = 'risk_medium';
    decisionReason = `risk ${risk.toFixed(2)} in caution range [${tLow.toFixed(2)}, ${tHigh.toFixed(2)})`;
  }

  return {
    action,
    reason,
    decisionReason,
    risk,
    severity,
    scoreBand: ctx.scoreBand,
    mode: ctx.mode || 'full',
    thresholds: { tLow, tHigh, highSeverityEscalate },
  };
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
