#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const DEFAULT_PATH = path.resolve(process.cwd(), 'research/uncertainty-abstention/logs/pilot-results.jsonl');

function usage() {
  console.error('Usage: node tools/uncertainty/log-result.js <json-string> [jsonl-path]');
  process.exit(1);
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

function normalizeActualOutcome(row) {
  if (row.actualOutcome) return row.actualOutcome;
  if (row.outcome) return row.outcome;
  if (row.error_severity && row.error_severity !== 'correct') return 'failure';
  if (row.errorSeverity && row.errorSeverity !== 'correct') return 'failure';
  return 'unknown';
}

const payload = process.argv[2];
if (!payload) usage();

let obj;
try {
  obj = JSON.parse(payload);
} catch (err) {
  console.error(`Invalid JSON: ${err.message}`);
  process.exit(1);
}

obj.ts = obj.ts || new Date().toISOString();

const risk = clamp01(obj.predictedRisk ?? obj.risk);
obj.predictedRisk = Number(risk.toFixed(4));
obj.risk = obj.risk ?? obj.predictedRisk; // backward compatibility
obj.scoreBand = obj.scoreBand || scoreBandFromRisk(obj.predictedRisk);
obj.actualOutcome = normalizeActualOutcome(obj);
obj.mode = obj.mode || 'full';

const target = process.argv[3] ? path.resolve(process.argv[3]) : DEFAULT_PATH;
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.appendFileSync(target, JSON.stringify(obj) + '\n');
console.log(`Logged to ${target}`);
