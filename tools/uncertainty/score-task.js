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

function clamp100(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(100, x));
}

function scoreBandFromRisk(risk) {
  if (risk >= 0.6) return 'high';
  if (risk >= 0.35) return 'mid';
  return 'low';
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
  const roundedRisk = Number(risk.toFixed(4));
  return {
    mode: 'full',
    signals: s,
    weights: w,
    risk: roundedRisk,
    scoreBand: scoreBandFromRisk(roundedRisk),
    severity: s.severity,
  };
}

function parseFlags(argv) {
  const args = argv.slice(2);
  const flags = { mve: false, inputArg: null };
  for (const arg of args) {
    if (arg === '--mve' || arg === '--quick') {
      flags.mve = true;
    } else if (!flags.inputArg) {
      flags.inputArg = arg;
    }
  }
  return flags;
}

function impactToSeverity(impact) {
  const norm = String(impact || '').trim().toLowerCase();
  if (norm === 'low') return 0.25;
  if (norm === 'med' || norm === 'medium') return 0.55;
  if (norm === 'high') return 0.85;
  throw new Error('MVE mode requires impact: low|med|high');
}

function computeMve(input) {
  const task = input.task || input.taskLabel || input.label;
  const confidence = clamp100(input.confidence);
  const severity = impactToSeverity(input.impact);

  if (!task || typeof task !== 'string') {
    throw new Error('MVE mode requires task label via task, taskLabel, or label');
  }
  if (!Number.isFinite(Number(input.confidence))) {
    throw new Error('MVE mode requires numeric confidence in range 0-100');
  }

  const uncertainty = 1 - confidence / 100;
  const risk = clamp01((uncertainty * 0.75) + (severity * 0.25));
  const roundedRisk = Number(risk.toFixed(4));

  return {
    mode: 'mve',
    task,
    confidence,
    impact: String(input.impact).toLowerCase() === 'medium' ? 'med' : String(input.impact).toLowerCase(),
    severity,
    risk: roundedRisk,
    scoreBand: scoreBandFromRisk(roundedRisk),
  };
}

function main() {
  try {
    const { mve, inputArg } = parseFlags(process.argv);
    const input = loadInput(inputArg);

    const forceMve = mve || String(input.mode || '').toLowerCase() === 'mve';
    const result = forceMve
      ? computeMve(input)
      : computeRisk(input.signals || input, input.weights || {});

    console.log(JSON.stringify(result, null, 2));
  } catch (err) {
    console.error(`Error: ${err.message}`);
    console.error('Usage (full): node tools/uncertainty/score-task.js <json-file-or-json-string>');
    console.error('Usage (mve): node tools/uncertainty/score-task.js --mve "{\"task\":\"...\",\"confidence\":72,\"impact\":\"med\"}"');
    process.exit(1);
  }
}

main();
