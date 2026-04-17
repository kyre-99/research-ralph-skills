---
name: research-optimize
description: Run a persistent objective-driven optimization loop for research code using a minimal set of goals, state, and progress files. Use when the user wants Ralph-like repeated implement-evaluate-improve cycles with a clear optimization target and resumable state. Triggers on: optimize this experiment, improve metric X, automatic tuning, autoresearch style optimization, keep improving until target, run an optimization loop.
argument-hint: [objective, target metric, and stopping rule]
disable-model-invocation: true
user-invocable: true
---

# Research Optimization Loop

Optimize the research system for: $ARGUMENTS

Read `${CLAUDE_SKILL_DIR}/references/optimization-loop.md` before updating optimization artifacts.

## Goal

This skill should behave like a research-oriented Ralph loop with the smallest useful artifact set:

- one durable objective,
- one machine-readable state file,
- one append-only progress log,
- resumable execution across sessions.

## Required Artifacts

Maintain these files under `optimization/`:

- `OBJECTIVE.md`
- `QUEUE.md`
- `STATE.json`
- `PROGRESS.md`
- `CLAUDE.md`

Use these templates when initializing:

- `${CLAUDE_SKILL_DIR}/assets/optimization-state.template.json`
- `${CLAUDE_SKILL_DIR}/assets/objective.template.md`
- `${CLAUDE_SKILL_DIR}/assets/optimizer-claude.template.md`

## Initialization

Before the loop starts, ensure `OBJECTIVE.md` defines:

- what is being optimized,
- the primary metric,
- the target or stopping rule,
- the baseline result,
- hard constraints,
- allowed search space.

If any item is missing, infer a reasonable default and write it explicitly.
If the optimization objective changes materially from the current run, archive the current run before replacing the optimization files. Use `./scripts/research-bot/archive-run.sh <slug>` for this instead of silently overwriting the current state.
Always initialize or refresh `optimization/CLAUDE.md` so it matches the current objective, queue, and state before handing control to `./scripts/research-bot/optimize.sh`.

## Loop Protocol

Each iteration should do exactly this:

1. Read `optimization/STATE.json`, `optimization/QUEUE.md`, and `optimization/PROGRESS.md`.
2. Pick the highest-value pending change from `QUEUE.md`.
3. Implement only that change set.
4. Run the relevant evaluation.
5. Append a structured entry to `PROGRESS.md`.
6. Update `STATE.json`.
7. Decide whether to continue, pause, or stop.

## Direction Iteration

This skill owns iterative optimization direction changes.

- Small refinements should stay in the current run and be recorded in `QUEUE.md` and `PROGRESS.md`.
- Material objective changes should start by archiving the current run, then rewriting `OBJECTIVE.md`, `QUEUE.md`, `STATE.json`, and `CLAUDE.md`.
- Treat "new optimization direction" as part of the optimization loop, not as a reason to go back to `/research-plan`.

## Queue Discipline

`QUEUE.md` should separate:

- pending ideas,
- active experiment,
- accepted improvements,
- rejected ideas,
- blocked items.

Do not lose rejected ideas; keep them with a short reason.

## State Discipline

`STATE.json` must track at least:

```json
{
  "status": "in_progress",
  "round": 0,
  "objective": "",
  "primary_metric": "",
  "baseline_metric": null,
  "best_metric": null,
  "best_run_id": "",
  "active_task": "",
  "stop_reason": "",
  "updated_at": ""
}
```

## Progress Entry Format

Every append to `PROGRESS.md` should include:

- timestamp,
- round number,
- hypothesis,
- exact change,
- evaluation command,
- metric result,
- keep/reject decision,
- next action.

## Recovery Rules

On re-entry:

1. Read `optimization/STATE.json`.
2. Read the latest section of `optimization/PROGRESS.md`.
3. Resume from the recorded active task and next action rather than re-deriving the whole search.

## Runner Integration

Keep `optimization/CLAUDE.md` aligned with the current objective and queue so an external runner can invoke repeated optimization rounds.

If the project needs a shell loop, use the template in `${CLAUDE_SKILL_DIR}/assets/optimizer-claude.template.md` together with `scripts/research-bot/optimize.sh`.

## Guardrails

- Never run an unbounded loop.
- Never overwrite the known-best result without recording it first.
- Stop when gains are noise-level, outside constraints, or clearly misaligned with the user's objective.
- Prefer small, testable changes over large speculative rewrites.
- Archive the previous run before starting a new objective that is not comparable to the current one.
- When archiving is needed, explicitly run `./scripts/research-bot/archive-run.sh <slug>` before resetting optimization state.
