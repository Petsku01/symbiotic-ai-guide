# Uncertainty Toolkit (v1)

Minimal scripts to operationalize decision-grade uncertainty.

## Scripts

- `score-task.js`  
  Compute risk score from 5 signals (evidence, consistency, policy, tool_integrity, severity).

- `decide-action.js`  
  Choose `AUTO_ACT`, `AUTO_ACT_WITH_CAUTION`, or `ESCALATE` from risk + severity gates.

- `log-result.js`  
  Append task outcomes to JSONL.

- `review-week.js`  
  Summarize weekly metrics and calibration buckets from JSONL.

## Quick example

```bash
# 1) Score a task
node tools/uncertainty/score-task.js '{"signals":{"evidence":0.2,"consistency":0.1,"policy":0.5,"tool_integrity":0.2,"severity":0.8}}'

# 2) Decide action (paste risk from step 1)
node tools/uncertainty/decide-action.js '{"risk":0.34,"severity":0.8,"tLow":0.35,"tHigh":0.60}'

# 3) Log outcome
node tools/uncertainty/log-result.js '{"task_id":"PILOT-001","risk":0.34,"severity":0.8,"action":"ESCALATE","outcome":"escalated_human_confirmed","error_severity":"correct"}'

# 4) Weekly review
node tools/uncertainty/review-week.js
```

## Notes
- Keep thresholds conservative for high-severity workflows.
- Treat this as a pilot baseline, then tune from observed outcomes.
