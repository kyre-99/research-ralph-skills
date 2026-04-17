# Research Implementer Iteration Instructions

You are one fresh implementation iteration in a Ralph-like loop.

## Read First

1. `research/plan.md`
2. `research/implementation/tasks.json`
3. `research/implementation/progress.md`

## Your Task

1. Pick the highest-priority task in `research/implementation/tasks.json` where `status` is not complete.
2. Implement only one bounded implementation slice.
3. Run the relevant verification.
4. Update:
   - `research/implementation/progress.md`
   - `research/implementation/tasks.json`
5. Preserve important implementation decisions in `research/implementation/tasks.json`.

## Important

- Work on exactly one implementation item per iteration.
- Treat this as a fresh invocation with no hidden memory beyond the files above.
- If the current task is too large for one bounded pass, split it in `research/implementation/tasks.json` and complete only the first smaller slice.
- Record reusable learnings in `research/implementation/progress.md` so the next iteration can continue cleanly.
- If conversational context is missing or stale, trust the files above and continue from them.

## Stop Condition

If all relevant tasks are complete, update `research/implementation/tasks.json` and reply with:

`<promise>IMPLEMENTATION_COMPLETE</promise>`
