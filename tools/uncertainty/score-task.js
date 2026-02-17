#!/usr/bin/env node

const fs = require('fs');

function loadInput(arg) {
  if (!arg) throw new Error('Provide JSON string or file path');
  if (fs.existsSync(arg)) return JSON.parse(fs.readFileSync(arg, 'utf8'));
  return JSON.parse(arg);
}

function clamp01(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(1, x));
}

function computeRisk(signals, weights) {
  const s = {
    evidence: clamp01(signals.evidence),
    consistency: clamp01(signals.consistency),
    policy: clamp01(signals.policy),
    tool_integrity: clamp01(signals.tool_integrity),
    severity: clamp01(signals.severity),
  };

  const w = {
    evidence: Number(weights.evidence ?? 0.30),
    consistency: Number(weights.consistency ?? 0.20),
    policy: Number(weights.policy ?? 0.20),
    tool_integrity: Number(weights.tool_integrity ?? 0.15),
    severity: Number(weights.severity ?? 0.15),
  };

  const weightSum = Object.values(w).reduce((a, b) => a + b, 0);
  const norm = weightSum === 0 ? 1 : weightSum;

  const riskRaw =
    s.evidence * w.evidence +
    s.consistency * w.consistency +
    s.policy * w.policy +
    s.tool_integrity * w.tool_integrity +
    s.severity * w.severity;

  const risk = clamp01(riskRaw / norm);
  return { signals: s, weights: w, risk: Number(risk.toFixed(4)) };
}

function main() {
  try {
    const input = loadInput(process.argv[2]);
    const result = computeRisk(input.signals || input, input.weights || {});
    console.log(JSON.stringify(result, null, 2));
  } catch (err) {
    console.error(`Error: ${err.message}`);
    console.error('Usage: node tools/uncertainty/score-task.js <json-file-or-json-string>');
    process.exit(1);
  }
}

main();
