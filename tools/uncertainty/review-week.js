#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function parseJsonl(file) {
  if (!fs.existsSync(file)) throw new Error(`File not found: ${file}`);
  const lines = fs.readFileSync(file, 'utf8').split('\n').filter(Boolean);
  return lines.map((l, i) => {
    try { return JSON.parse(l); } catch (e) { throw new Error(`Invalid JSONL line ${i + 1}: ${e.message}`); }
  });
}

function clamp01(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(1, x));
}

function scoreBandFromRisk(risk) {
  if (risk >= 0.6) return 'high';
  if (risk >= 0.35) return 'mid';
  return 'low';
}

function normalizeBand(row) {
  return row.scoreBand || scoreBandFromRisk(row.predictedRisk ?? row.risk);
}

function normalizePredictedRisk(row) {
  return clamp01(row.predictedRisk ?? row.risk);
}

function isFailure(row) {
  const actual = String(row.actualOutcome ?? row.outcome ?? '').toLowerCase();
  if (actual === 'failure') return true;
  if (actual === 'success' || actual === 'correct') return false;

  const err = String(row.error_severity ?? row.errorSeverity ?? '').toLowerCase();
  return ['minor_error', 'major_error', 'critical_error', 'failure'].includes(err);
}

function summarizeBand(rows) {
  const n = rows.length;
  const meanPredRisk = n ? rows.reduce((a, r) => a + normalizePredictedRisk(r), 0) / n : 0;
  const failures = rows.filter(isFailure).length;
  const observedFailureRate = n ? failures / n : 0;
  const gap = observedFailureRate - meanPredRisk;
  return {
    count: n,
    meanPredictedRisk: Number(meanPredRisk.toFixed(4)),
    observedFailureRate: Number(observedFailureRate.toFixed(4)),
    gap: Number(gap.toFixed(4)),
  };
}

function thresholdHint(calByBand) {
  const high = calByBand.high;
  const low = calByBand.low;

  if (high && high.count >= 5 && high.gap > 0.1) {
    return 'High band is underpredicting failures; consider lowering tHigh slightly (e.g. -0.05).';
  }
  if (low && low.count >= 5 && low.gap < -0.1) {
    return 'Low band is overpredicting failures; consider raising tLow slightly (e.g. +0.05).';
  }
  return 'Thresholds look roughly aligned; keep current thresholds and gather more data.';
}

function main() {
  const file = path.resolve(process.argv[2] || 'research/uncertainty-abstention/logs/pilot-results.jsonl');
  const rows = parseJsonl(file);
  const total = rows.length;

  const auto = rows.filter(r => String(r.action || '').startsWith('AUTO')).length;
  const escalated = rows.filter(r => r.action === 'ESCALATE').length;

  const byBandRows = { low: [], mid: [], high: [] };
  for (const row of rows) {
    byBandRows[normalizeBand(row)].push(row);
  }

  const calibrationByScoreBand = {
    low: summarizeBand(byBandRows.low),
    mid: summarizeBand(byBandRows.mid),
    high: summarizeBand(byBandRows.high),
  };

  const lowSampleWarnings = Object.entries(calibrationByScoreBand)
    .filter(([, v]) => v.count > 0 && v.count < 5)
    .map(([k, v]) => `Low sample for ${k} band (n=${v.count}); calibration may be noisy.`);

  const out = {
    file,
    total,
    actionCounts: { auto, escalated },
    escalationRate: total ? Number((escalated / total).toFixed(4)) : 0,
    calibrationByScoreBand,
    warnings: lowSampleWarnings,
    thresholdAdjustmentHint: thresholdHint(calibrationByScoreBand),
  };

  // Backward-compat aliases
  out.action_counts = out.actionCounts;
  out.escalation_rate = out.escalationRate;
  out.calibration_buckets = {
    low: {
      count: out.calibrationByScoreBand.low.count,
      error_rate: out.calibrationByScoreBand.low.observedFailureRate,
    },
    mid: {
      count: out.calibrationByScoreBand.mid.count,
      error_rate: out.calibrationByScoreBand.mid.observedFailureRate,
    },
    high: {
      count: out.calibrationByScoreBand.high.count,
      error_rate: out.calibrationByScoreBand.high.observedFailureRate,
    },
  };

  console.log(JSON.stringify(out, null, 2));
}

try { main(); } catch (err) { console.error(`Error: ${err.message}`); process.exit(1); }
