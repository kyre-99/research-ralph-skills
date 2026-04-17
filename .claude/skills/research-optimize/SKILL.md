---
name: research-optimize
description: Prepare and maintain a persistent Ralph-like optimization run for research code using prd.json, progress.md, and CLAUDE.md. Use when the user wants repeated implement-evaluate-improve cycles with a clear optimization target and resumable state. Triggers on: optimize this experiment, improve metric X, automatic tuning, autoresearch style optimization, keep improving until target, prepare an optimization loop, set up optimization run.
argument-hint: [objective, target metric, and stopping rule]
disable-model-invocation: true
user-invocable: true
---

# Research Optimization Run Setup

Prepare the research optimization run for: $ARGUMENTS

Read `${CLAUDE_SKILL_DIR}/references/optimization-loop.md` before updating optimization artifacts.

## Goal

This skill should behave like the setup phase of a research-oriented Ralph loop with the smallest useful artifact set:

- one machine-readable task decomposition file,
- one append-only progress log,
- one single-iteration runner prompt,
- resumable execution across sessions.

## Primary Responsibility

This skill prepares the optimization run. It does not execute the full optimization loop itself.

Its job is to:

- define or refresh the optimization objective,
- define or refresh the optimization task decomposition,
- define or refresh the single-iteration Claude prompt,
- decide whether the current run should continue or be archived and replaced,
- leave the project ready for `./scripts/research-bot/optimize.sh`.

Unless the user explicitly asks for a one-off optimization pass in the current session, do not execute queued optimization work directly in this skill.

## Source Material

When generating or refreshing `optimization/prd.json`, derive it from:

- `research/plan.md`
- `research/implementation/tasks.json`
- `research/implementation/progress.md` when useful
- the latest `optimization/progress.md` if this is a continuing run

Use the plan for intent and constraints, and use the implementation files for what is already runnable.

## Required Artifacts

Maintain these files under `optimization/`:

- `prd.json`
- `progress.md`
- `CLAUDE.md`

Use these templates when initializing:

- `${CLAUDE_SKILL_DIR}/assets/optimizer-claude.template.md`

## Initialization

Before the loop starts, ensure `prd.json` defines:

- the optimization objective,
- the primary metric,
- the stop condition,
- the current baseline,
- a list of bounded tasks,
- acceptance criteria for each task,
- priority and completion status for each task.

If any item is missing, infer a reasonable default and write it explicitly.
If the optimization objective changes materially from the current run, archive the current run before replacing the optimization files. Use `./scripts/research-bot/archive-run.sh <slug>` for this instead of silently overwriting the current state.
Always initialize or refresh `optimization/CLAUDE.md` so it matches the current `prd.json` and `progress.md` before handing control to `./scripts/research-bot/optimize.sh`.

## Setup Protocol

Each invocation of this skill should do exactly this:

1. Read `research/plan.md` and implementation artifacts if they exist.
2. Read `optimization/prd.json` and `optimization/progress.md` if they exist.
3. Decide whether this is:
   - a refinement of the current optimization run, or
   - a materially new optimization run.
4. If it is a materially new run:
   - archive the current run with `./scripts/research-bot/archive-run.sh <slug>`,
   - then rewrite `prd.json`, `progress.md`, and `CLAUDE.md`.
5. If it is a refinement of the current run:
   - update `prd.json`, `progress.md`, and `CLAUDE.md` in place.
6. Leave the repository ready for `./scripts/research-bot/optimize.sh`.

## Direction Iteration

This skill owns iterative optimization direction changes and run preparation.

- Small refinements should stay in the current run and be recorded in `prd.json` and `progress.md`.
- Material objective changes should start by archiving the current run, then rewriting `prd.json`, `progress.md`, and `CLAUDE.md`.
- Treat "new optimization direction" as part of the optimization loop, not as a reason to go back to `/research-plan`.

## prd.json Discipline

`prd.json` must track at least:

```json
{
  "objective": "",
  "primary_metric": "",
  "stop_condition": "",
  "baseline": {
    "metric": null,
    "run_id": ""
  },
  "tasks": [
    {
      "id": "OPT-001",
      "title": "",
      "type": "experiment",
      "description": "",
      "acceptanceCriteria": [],
      "priority": 1,
      "status": "pending",
      "notes": ""
    }
  ]
}
```

Task design rules:

- Every task must be small enough to complete in one iteration.
- Every task must have verifiable acceptance criteria.
- A failed experiment can still complete a task if it produces a decision-worthy result.
- Prefer instrumentation and analysis tasks before large implementation changes.

## Task Decomposition Rules

Follow a Ralph-like decomposition style:

1. Split large optimization goals into single-iteration tasks.
2. Order tasks by dependency and information gain.
3. Prefer observability and evaluation tasks before architectural changes.
4. Encode completion using task status in `prd.json`, not only prose in `progress.md`.

Good tasks:

- add one missing metric
- compare one hyperparameter change against the current baseline
- add one bounded implementation change and run one evaluation
- analyze one failure mode and record the decision

Bad tasks:

- improve the whole model
- redesign the entire training loop
- optimize everything related to reasoning

Rule of thumb: if one task cannot be described in 2-3 sentences with explicit acceptance criteria, split it.

## Progress Entry Format

Every append to `progress.md` should include:

- timestamp,
- round number,
- hypothesis,
- exact change,
- evaluation command,
- metric result,
- keep/reject decision,
- next action.

When this skill is preparing a new run, the entry may also include:

- why the run was reset,
- archive path, if any,
- what changed in the objective.

## Recovery Rules

On re-entry:

1. Read `optimization/prd.json`.
2. Read the latest section of `optimization/progress.md`.
3. If session context is thin, trust the files rather than conversational memory.
4. Resume from the highest-priority incomplete task and the recorded learnings rather than re-deriving the whole search.

## Runner Integration

Keep `optimization/CLAUDE.md` aligned with the current `prd.json` and `progress.md` so an external runner can invoke repeated optimization rounds.

If the project needs a shell loop, use the template in `${CLAUDE_SKILL_DIR}/assets/optimizer-claude.template.md` together with `scripts/research-bot/optimize.sh`.

`optimization/CLAUDE.md` should be a single-iteration instruction file for a fresh Claude invocation, similar to Ralph's `CLAUDE.md`.

## Guardrails

- Never run an unbounded loop.
- Never overwrite the known-best result without recording it first.
- Stop when gains are noise-level, outside constraints, or clearly misaligned with the user's objective.
- Prefer small, testable changes over large speculative rewrites.
- Archive the previous run before starting a new objective that is not comparable to the current one.
- When archiving is needed, explicitly run `./scripts/research-bot/archive-run.sh <slug>` before resetting optimization state.
- Do not silently perform the full optimization loop in the current skill invocation when the user's intent is to prepare a reusable Ralph-like run.
