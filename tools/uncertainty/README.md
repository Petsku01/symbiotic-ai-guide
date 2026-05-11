# Uncertainty Toolkit

Minimal scripts to operationalize decision-grade uncertainty with both full scoring and quick MVE mode.

## Scripts

- `score-task.js`
  Compute risk score in either:
  - **full mode** from 5 signals (`evidence`, `consistency`, `policy`, `tool_integrity`, `severity`)
  - **MVE mode** (`--mve` / `--quick`) from minimal inputs: `task`, `confidence` (0-100), `impact` (`low|med|high`)

- `decide-action.js`
  Choose `AUTO_ACT`, `AUTO_ACT_WITH_CAUTION`, or `ESCALATE` using deterministic thresholds. Accepts output from either full or MVE scoring. Includes `decisionReason`.

- `log-result.js`
  Append task outcomes to JSONL. Adds calibration fields while preserving backward compatibility:
  `predictedRisk`, `scoreBand`, `actualOutcome`, `mode`.

- `review-week.js`
  Summarize weekly metrics and calibration by `scoreBand` with:
  `count`, `meanPredictedRisk`, `observedFailureRate`, `gap`.
  Warns on low sample (`n < 5`) and prints a simple threshold adjustment hint.

## Quick examples

```bash
# 1) Score a task (full mode)
node tools/uncertainty/score-task.js '{"signals":{"evidence":0.2,"consistency":0.1,"policy":0.5,"tool_integrity":0.2,"severity":0.8}}'

# 1b) Score a task (MVE/quick mode)
node tools/uncertainty/score-task.js --mve '{"task":"Send customer update","confidence":72,"impact":"med"}'

# 2) Decide action from either scorer output
node tools/uncertainty/decide-action.js '{"mode":"mve","risk":0.34,"severity":0.55,"scoreBand":"low"}'

# 3) Log outcome (calibration-friendly)
node tools/uncertainty/log-result.js '{"task_id":"PILOT-001","mode":"mve","predictedRisk":0.34,"scoreBand":"low","severity":0.55,"action":"AUTO_ACT","actualOutcome":"success"}'

# 4) Weekly review + calibration
node tools/uncertainty/review-week.js
```

## Notes
- Keep thresholds conservative for high-severity workflows.
- Treat this as a pilot baseline, then tune from observed outcomes.
- No external dependencies are required.
