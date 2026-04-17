# Optimization Loop Protocol

The optimization loop should be durable, inspectable, and resumable with as few files as possible.

## Core Files

### `optimization/OBJECTIVE.md`

Human-readable contract for the loop.

Recommended sections:

- Objective
- Primary metric
- Target
- Baseline
- Constraints
- Allowed modifications
- Stop conditions

### `optimization/QUEUE.md`

Prioritized experiment/change backlog.

Recommended sections:

- Active
- Pending
- Accepted
- Rejected
- Blocked

### `optimization/STATE.json`

Latest machine-readable snapshot.

### `optimization/PROGRESS.md`

Append-only narrative and evidence log.

## Ralph-Like Design Rules

- One iteration should focus on one bounded improvement attempt.
- Memory should live in files, not only in the chat.
- A fresh session should be able to continue from `STATE.json` plus the latest section of `PROGRESS.md`.
- Preserve accepted and rejected ideas to avoid repeated work.
- Keep the runner prompt aligned with the latest objective and queue.
- When the objective is replaced rather than refined, archive the current run before resetting optimization files.

## Objective Change Rule

Optimization owns the iterative search direction.

- If the user is still improving the same broad research task, stay inside the optimization loop.
- If the user introduces a materially new optimization target or non-comparable metric, archive the current run and start a new optimization run.
- Use planning again only when the research problem itself has changed so much that the existing brief and implementation are no longer the right base.
