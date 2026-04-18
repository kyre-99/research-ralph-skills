---
name: research-implement
description: Implement a persisted research plan in code and maintain a Ralph-like task list plus progress log for implementation. Use when the user already has a research direction and wants runnable code, experiment scaffolding, baselines, evaluation scripts, or a first executable prototype. Triggers on: implement this research plan, build the experiment, create the baseline, turn the plan into code, scaffold the project for this idea.
argument-hint: [brief, plan, or implementation goal]
allowed-tools: Bash(*) Read Write Edit Grep Glob Skill
disable-model-invocation: true
user-invocable: true
---

# Research Implementation

Implement the research task for: $ARGUMENTS

Read `research/plan.md` and any existing implementation artifacts before making changes.

Start every invocation by reading in this order:

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
- refresh `runtime/RESEARCH_STATE.json` with a short summary of the current implementation context,
- leave the repository ready for `./scripts/research-bot/implement.sh`.

Unless the user explicitly asks for a one-off implementation pass in the current session, do not execute queued implementation work directly in this skill.

This skill is also responsible for deciding whether the current implementation run should continue in place or be archived and replaced.

## Default Behavior

By default, stop after preparing or refreshing:

- `research/implementation/tasks.json`
- `research/implementation/progress.md`
- `runtime/RESEARCH_STATE.json`

Then recommend the shell runner:

```bash
./scripts/research-bot/implement.sh 10
```

Do not start implementing queued tasks in this skill unless the user explicitly asks for an immediate one-off implementation pass.

## Setup Protocol

1. Read `runtime/RESEARCH_STATE.json` if it exists.
2. Read `research/plan.md`.
3. Read `research/implementation/tasks.json` and `research/implementation/progress.md` if they exist.
4. Decide whether this is:
   - a refinement of the current implementation run, or
   - a materially new implementation run.
5. If it is a materially new implementation run:
   - archive the current implementation state with `./scripts/research-bot/archive-implementation.sh "<reason>"`,
   - then rewrite `research/implementation/tasks.json` and `research/implementation/progress.md`.
6. If it is a refinement of the current implementation run:
   - update `research/implementation/tasks.json` and `research/implementation/progress.md` in place.
7. Update `runtime/RESEARCH_STATE.json` with:
   - `active_phase`
   - `current_goal`
   - `current_status`
   - `next_step`
   - `recommended_next_skill`
   - `key_files`
   - `updated_at`
8. Leave the repository ready for `./scripts/research-bot/implement.sh`.
9. End by explicitly recommending `./scripts/research-bot/implement.sh <N>` as the next step.

Archive only when the current request materially changes the implementation run, such as:

- the implementation objective has clearly changed,
- the task structure needs a large reset rather than incremental edits,
- the previous implementation route is being abandoned,
- continuing in the same files would blur two different implementation runs.

Do not archive for small refinements such as:

- adding one or two tasks,
- adjusting priorities,
- clarifying acceptance criteria,
- updating progress for continued work on the same run.

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

This file is a stable single-iteration protocol for a fresh Claude invocation.

It should explain:

- where to read context from,
- what kind of bounded work to do,
- what files must be updated,
- what stop condition to use.

Do not rewrite this file for normal run preparation. Treat it as fixed runner guidance unless you are intentionally changing the workflow protocol itself.

## Rules

- Prefer simple, inspectable baselines before complexity.
- Make seeds, hyperparameters, and paths configurable.
- Save outputs in machine-readable formats when possible.
- If validation cannot run, state exactly why in `progress.md`.
- When the baseline becomes runnable, mark the relevant task complete and record the validation result in both `tasks.json` notes and `progress.md`.
- If session context is thin, trust the files rather than conversational memory.
- Keep `runtime/RESEARCH_STATE.json` brief and operational. It is a context entrypoint, not a second task database.

## Boundaries

- Do not claim gains that are not measured.
- Do not erase prior implementation history.
- Hand off to `/research-optimize` only after `tasks.json` reflects the current implementation status.
- Do not silently run the full implementation loop in the current skill invocation when the user's intent is to prepare a reusable Ralph-like run.
- Prefer the shell runner over ad-hoc in-session implementation once the task list has been prepared.
- When archiving is needed, explicitly run `./scripts/research-bot/archive-implementation.sh "<reason>"` before resetting the implementation files.
