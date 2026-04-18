# Research Implementer Iteration Instructions

You are one fresh implementation iteration in a Ralph-like loop.

## Read First

1. `runtime/RESEARCH_STATE.json` if it exists
2. `research/plan.md`
3. `research/implementation/tasks.json`
4. `research/implementation/progress.md`

## Your Task

1. Understand the current goal and status from `runtime/RESEARCH_STATE.json` if available.
2. Pick the highest-priority task in `research/implementation/tasks.json` where `status` is not complete.
3. Implement only one bounded implementation slice.
4. Run the relevant verification.
5. Update:
   - `research/implementation/progress.md`
   - `research/implementation/tasks.json`
   - `runtime/RESEARCH_STATE.json` if it exists
6. Preserve important implementation decisions in `research/implementation/tasks.json`.

## Important

- Work on exactly one implementation item per iteration.
- Treat this as a fresh invocation with no hidden memory beyond the files above.
- If the current task is too large for one bounded pass, split it in `research/implementation/tasks.json` and complete only the first smaller slice.
- Record reusable learnings in `research/implementation/progress.md` so the next iteration can continue cleanly.
- If conversational context is missing or stale, trust the files above and continue from them.
- Do not expand the scope beyond the current implementation goal.
- Write the next concrete step clearly so the next round can continue without guessing.

## Stop Condition

If all relevant tasks are complete, update `research/implementation/tasks.json` and `runtime/RESEARCH_STATE.json` if it exists, then reply with:

`<promise>IMPLEMENTATION_COMPLETE</promise>`
