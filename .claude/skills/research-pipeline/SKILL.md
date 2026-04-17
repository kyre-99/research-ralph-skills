---
name: research-pipeline
description: Orchestrate the persisted research workflow by reading and updating the project's planning, implementation, optimization, and runtime artifacts. Use when the user wants the whole research bot workflow to continue from the current state instead of starting each stage from scratch. Triggers on: full research pipeline, continue the research bot, run the whole workflow, resume the workflow, orchestrate research skills.
argument-hint: [research goal]
disable-model-invocation: true
user-invocable: true
---

# Research Pipeline

Coordinate the research workflow for: $ARGUMENTS

## Read Order

Always start with:

1. `runtime/RESEARCH_STATE.json` if it exists
2. the canonical phase files listed in the runtime state

If the session is fresh and context is thin, do not infer the current state from memory. Reconstruct it from the files above first.

If `runtime/` does not exist yet, initialize via `/research-persist`.

## Stage Logic

- If planning artifacts are missing or stale, run `/research-plan`.
- If the plan is ready but implementation is not runnable, run `/research-implement`.
- If implementation is runnable and a metric/objective exists, run `/research-optimize`.
- If any stage lacks durable artifacts, repair with `/research-persist`.

## Pipeline Contract

At each handoff, update:

- the current phase's source-of-truth artifacts,
- `runtime/RESEARCH_STATE.json`.

## Guardrails

- Treat files as the memory surface, not the conversation.
- Do not skip state updates between stages.
- Prefer resuming the current stage over reopening the whole pipeline.
