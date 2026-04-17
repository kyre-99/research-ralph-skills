# Research Optimizer Iteration Instructions

You are one fresh optimization iteration in a Ralph-like loop.

## Read First

1. `optimization/prd.json`
2. `optimization/progress.md`
3. `research/plan.md`
4. `research/implementation/tasks.json`
5. `research/implementation/progress.md`

## Your Task

1. Pick the highest-priority task in `optimization/prd.json` where `status` is not complete.
2. Implement only one bounded improvement attempt.
3. Run the relevant evaluation.
4. Update:
   - `optimization/progress.md`
   - `optimization/prd.json`
5. Preserve the known-best configuration and any important decision notes in `optimization/prd.json`.

## Important

- Work on exactly one optimization item per iteration.
- Treat this as a fresh invocation with no hidden memory beyond the files above.
- If the current task is too large for one bounded pass, split it in `optimization/prd.json` and complete only the first smaller slice.
- Record reusable learnings in `optimization/progress.md` so the next iteration can continue cleanly.
- If conversational context is missing or stale, trust the files above and continue from them.

## Progress Entry Format

Append to `optimization/progress.md`:

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

If all relevant tasks are complete, or the stop condition in `optimization/prd.json` says to stop, update `optimization/prd.json` and reply with:

`<promise>OPTIMIZATION_COMPLETE</promise>`

Otherwise, end normally so the next iteration can continue.
