---
name: research-implement
description: Implement a persisted research plan in code and maintain a Ralph-like task list plus progress log for implementation. Use when the user already has a research direction and wants runnable code, experiment scaffolding, baselines, evaluation scripts, or a first executable prototype. Triggers on: implement this research plan, build the experiment, create the baseline, turn the plan into code, scaffold the project for this idea.
argument-hint: [brief, plan, or implementation goal]
disable-model-invocation: true
user-invocable: true
---

# Research Implementation

Implement the research task for: $ARGUMENTS

Read `research/plan.md` and any existing implementation artifacts before making changes.

If this is a fresh session with little or no context, start by reading in this order:

1. `runtime/RESEARCH_STATE.json` if it exists
2. `research/plan.md`
3. `research/implementation/tasks.json` if it exists
4. `research/implementation/progress.md` if it exists

## Required Artifacts

Maintain these files under `research/implementation/`:

- `tasks.json`
- `progress.md`
- `CLAUDE.md`

## Primary Responsibility

This skill prepares the implementation run. It does not execute the full implementation loop itself.

Its job is to:

- derive implementation tasks from `research/plan.md`,
- refresh `research/implementation/tasks.json`,
- refresh `research/implementation/progress.md` when the plan changes,
- refresh `research/implementation/CLAUDE.md`,
- leave the repository ready for `./scripts/research-bot/implement.sh`.

Unless the user explicitly asks for a one-off implementation pass in the current session, do not execute queued implementation work directly in this skill.

## Default Behavior

By default, stop after preparing or refreshing:

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `research/implementation/CLAUDE.md`

Then recommend the shell runner:

```bash
./scripts/research-bot/implement.sh 10
```

Do not start implementing queued tasks in this skill unless the user explicitly asks for an immediate one-off implementation pass.

## Setup Protocol

1. Read `research/plan.md`.
2. Read `research/implementation/tasks.json` and `research/implementation/progress.md` if they exist.
3. Convert the current implementation handoff into bounded implementation tasks in `research/implementation/tasks.json`.
4. Refresh `research/implementation/CLAUDE.md` so it matches the current task list and progress log.
5. Leave the repository ready for `./scripts/research-bot/implement.sh`.
6. End by explicitly recommending `./scripts/research-bot/implement.sh <N>` as the next step.

## `tasks.json`

It must contain:

- the implementation objective,
- a reference to `research/plan.md`,
- a list of bounded implementation tasks.

Recommended shape:

```json
{
  "objective": "Implement the current research plan",
  "source_plan": "research/plan.md",
  "tasks": [
    {
      "id": "IMP-001",
      "title": "",
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

- Every task must be small enough to complete in one implementation pass.
- Every task must have verifiable acceptance criteria.
- Split large build steps into multiple tasks before starting work.
- Use `status` to encode progress: `pending`, `in_progress`, `complete`, or `blocked`.

## `progress.md`

Append-only log with:

- timestamp,
- task id,
- change made,
- files touched,
- validation result,
- reusable learnings,
- next action.

## `CLAUDE.md`

This file must be a single-iteration instruction file for a fresh Claude invocation, similar to Ralph's `CLAUDE.md`.

## Rules

- Prefer simple, inspectable baselines before complexity.
- Make seeds, hyperparameters, and paths configurable.
- Save outputs in machine-readable formats when possible.
- If validation cannot run, state exactly why in `progress.md`.
- When the baseline becomes runnable, mark the relevant task complete and record the validation result in both `tasks.json` notes and `progress.md`.
- If session context is thin, trust the files rather than conversational memory.

## Boundaries

- Do not claim gains that are not measured.
- Do not erase prior implementation history.
- Hand off to `/research-optimize` only after `tasks.json` reflects the current implementation status.
- Do not silently run the full implementation loop in the current skill invocation when the user's intent is to prepare a reusable Ralph-like run.
- Prefer the shell runner over ad-hoc in-session implementation once the task list has been prepared.
