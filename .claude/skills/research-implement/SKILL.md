---
name: research-implement
description: Implement a persisted research brief in code and maintain a minimal set of durable implementation artifacts for later review and optimization. Use when the user already has a research direction and wants runnable code, experiment scaffolding, baselines, evaluation scripts, or a first executable prototype. Triggers on: implement this research plan, build the experiment, create the baseline, turn the brief into code, scaffold the project for this idea.
argument-hint: [brief, plan, or implementation goal]
user-invocable: true
---

# Research Implementation

Implement the research task for: $ARGUMENTS

Read `research/brief.md`, `research/plan.md`, and any existing implementation artifacts before making changes.

## Required Artifacts

Maintain these files under `research/implementation/`:

- `IMPLEMENTATION.md`
- `IMPLEMENTATION_STATE.json`
- `IMPLEMENTATION_LOG.md`

Use `${CLAUDE_SKILL_DIR}/assets/implementation-state.template.json` when initializing state.

## Workflow

1. Read planning artifacts first and extract the smallest useful implementation slice.
2. Record the intended slice in `IMPLEMENTATION.md`.
3. Implement incrementally:
   - core method,
   - baseline or comparison path,
   - reproducible entrypoint,
   - evaluation hook.
4. Run the lightest meaningful verification.
5. Update implementation state and append a log entry.

## `IMPLEMENTATION.md`

Capture:

- target milestone,
- files or modules expected to change,
- baseline behavior,
- validation command,
- expected output artifacts,
- next action.

## `IMPLEMENTATION_STATE.json`

Track at least:

```json
{
  "status": "in_progress",
  "current_milestone": "",
  "baseline": "",
  "primary_metric": "",
  "last_validation": "",
  "ready_for_optimization": false,
  "updated_at": ""
}
```

## `IMPLEMENTATION_LOG.md`

Append-only log with:

- timestamp,
- change made,
- files touched,
- validation result,
- reusable learnings,
- next action.

## Rules

- Prefer simple, inspectable baselines before complexity.
- Make seeds, hyperparameters, and paths configurable.
- Save outputs in machine-readable formats when possible.
- If validation cannot run, state exactly why in `IMPLEMENTATION_LOG.md`.
- Mark `ready_for_optimization` true only when there is a runnable baseline and a measurable metric.

## Boundaries

- Do not claim gains that are not measured.
- Do not erase prior implementation history.
- Hand off to `/research-optimize` only after the implementation artifacts are current.
