---
name: research-persist
description: Set up or repair only the minimal persistent file and runner structure that lets planning, implementation, and optimization survive context resets or interrupted sessions. Use when the user wants Ralph-like persistence, resumable execution, state files, progress logs, or a durable research runner. Triggers on: persistent loop, resume optimization, watchdog, keep running after context reset, stateful research runner, long-running research bot.
argument-hint: [long-running task or loop objective]
disable-model-invocation: true
user-invocable: true
---

# Persistent Research Runtime

Establish or repair the durable runtime for: $ARGUMENTS

Read `${CLAUDE_SKILL_DIR}/references/state-pattern.md` before changing the runtime structure.

## Objective

Make the project restart-safe. This skill exists to ensure that the planning, implementation, and optimization artifacts are all sufficient for a fresh session to continue.

## Required Runtime Files

Maintain only:

- `runtime/RESEARCH_STATE.json`
- `runtime/MANIFEST.md`

## Responsibilities

1. Check whether `research/`, `research/implementation/`, and `optimization/` have the required artifacts.
2. Fill gaps with minimal templates instead of rebuilding everything.
3. Write `runtime/MANIFEST.md` as an index of the current source-of-truth files.
4. Update `runtime/RESEARCH_STATE.json` with a short summary of the active phase, current goal, current status, next step, recommended next skill, and key files.
5. When optimization starts a materially new run, preserve the runtime index so the archive and the new run are both recoverable.

## Canonical Runtime State

`runtime/RESEARCH_STATE.json` should point to:

- active phase,
- current goal,
- current status,
- next step,
- recommended next skill,
- key files for the next agent to read,
- updated timestamp.

## Recovery Procedure

A fresh session should be able to:

1. read `runtime/RESEARCH_STATE.json`,
2. open the listed canonical artifacts,
3. continue from there without re-planning the whole project.

## Guardrails

- Do not invent duplicate source-of-truth files.
- Prefer repairing missing state over introducing a new framework.
- Keep the manifest current whenever the canonical files change.
