# Optimization Loop Protocol

The optimization loop should be durable, inspectable, and resumable with as few files as possible.

## Core Files

### `optimization/prd.json`

Machine-readable optimization contract and task backlog.

Recommended top-level fields:

- `objective`
- `primary_metric`
- `stop_condition`
- `baseline`
- `tasks`

Each task should contain:

- `id`
- `title`
- `type`
- `description`
- `acceptanceCriteria`
- `priority`
- `status`
- `notes`

Recommended task types:

- `instrumentation`
- `experiment`
- `implementation`
- `analysis`
- `decision`

### `optimization/progress.md`

Append-only narrative and evidence log.

## Ralph-Like Design Rules

- One iteration should focus on one bounded improvement attempt.
- Memory should live in files, not only in the chat.
- A fresh session should be able to continue from `prd.json` plus the latest section of `progress.md`.
- Preserve accepted and rejected ideas as task notes instead of losing them.
- Keep the runner prompt aligned with the latest task decomposition.
- When the objective is replaced rather than refined, archive the current run before resetting optimization files.
- Separate run preparation from run execution: the skill prepares files, the shell runner executes repeated fresh iterations.
- Derive the task list from the research plan and current runnable implementation, then shrink it into single-iteration tasks.

## Objective Change Rule

Optimization owns the iterative search direction.

- If the user is still improving the same broad research task, stay inside the optimization loop.
- If the user introduces a materially new optimization target or non-comparable metric, archive the current run and start a new optimization run.
- Use planning again only when the research problem itself has changed so much that the existing brief and implementation are no longer the right base.
