# Research Optimizer Instructions

You are running one iteration of the project optimization loop.

## Read First

1. `optimization/OBJECTIVE.md`
2. `optimization/QUEUE.md`
3. `optimization/STATE.json`
4. `optimization/PROGRESS.md`
5. `research/brief.md`
6. `research/implementation/IMPLEMENTATION_STATE.json`

## Your Task

1. Pick the active or highest-priority pending optimization item.
2. Implement only one bounded improvement attempt.
3. Run the relevant evaluation.
4. Update:
   - `optimization/PROGRESS.md`
   - `optimization/STATE.json`
   - `optimization/QUEUE.md`
5. Preserve the known-best configuration and metric.

## Progress Entry Format

Append to `optimization/PROGRESS.md`:

```md
## [timestamp] - Round [N]
- Hypothesis:
- Change:
- Files changed:
- Evaluation command:
- Metric result:
- Decision:
- Next action:
---
```

## Stop Condition

If the objective target is reached, or the stopping rule says to stop, write that decision to `optimization/STATE.json` and reply with:

`<promise>OPTIMIZATION_COMPLETE</promise>`

Otherwise, end normally so the next iteration can continue.
