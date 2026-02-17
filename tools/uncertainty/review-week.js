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

function bucket(risk) {
  const r = Number(risk) || 0;
  if (r >= 0.6) return 'high';
  if (r >= 0.35) return 'mid';
  return 'low';
}

function isError(sev) {
  return ['minor_error', 'major_error', 'critical_error'].includes(sev);
}

function main() {
  const file = path.resolve(process.argv[2] || 'research/uncertainty-abstention/logs/pilot-results.jsonl');
  const rows = parseJsonl(file);
  const total = rows.length;

  const auto = rows.filter(r => (r.action || '').startsWith('AUTO')).length;
  const escalated = rows.filter(r => r.action === 'ESCALATE').length;
  const falseEsc = rows.filter(r => r.action === 'ESCALATE' && r.outcome === 'escalated_human_confirmed').length;

  const major = rows.filter(r => r.error_severity === 'major_error').length;
  const critical = rows.filter(r => r.error_severity === 'critical_error').length;

  const buckets = { low: { n: 0, err: 0 }, mid: { n: 0, err: 0 }, high: { n: 0, err: 0 } };
  for (const r of rows) {
    const b = bucket(r.risk);
    buckets[b].n += 1;
    if (isError(r.error_severity)) buckets[b].err += 1;
  }

  const out = {
    file,
    total,
    action_counts: { auto, escalated },
    escalation_rate: total ? Number((escalated / total).toFixed(4)) : 0,
    false_escalations: falseEsc,
    error_counts: { major, critical },
    calibration_buckets: Object.fromEntries(Object.entries(buckets).map(([k, v]) => [k, {
      count: v.n,
      error_rate: v.n ? Number((v.err / v.n).toFixed(4)) : 0
    }]))
  };

  console.log(JSON.stringify(out, null, 2));
}

try { main(); } catch (err) { console.error(`Error: ${err.message}`); process.exit(1); }
