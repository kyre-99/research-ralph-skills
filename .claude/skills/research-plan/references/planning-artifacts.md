# Planning Artifact Protocol

Planning is durable only if a later session can reconstruct intent from a very small set of files alone.

## File Roles

### `research/brief.md`

Current source of truth for the research direction.

Keep it stable and concise. When the direction changes, rewrite this file and log the change in `plan-progress.md`.

### `research/plan.md`

Operational plan derived from the brief.

Recommended sections:

- Objective
- Research thesis
- Milestones
- Validation plan
- Risks
- Non-goals
- Next action

### `research/plan-state.json`

Machine-readable snapshot for automation and routing.

Recommended statuses:

- `draft`
- `approved`
- `blocked`
- `superseded`

### `research/plan-progress.md`

Append-only planning diary.

Each entry should include:

- timestamp,
- what changed,
- why it changed,
- unresolved questions,
- next action.
