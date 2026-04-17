# Planning Artifact Protocol

Planning is durable only if a later session can reconstruct intent from a very small set of files alone.

## File Roles

### `research/plan.md`

Current source of truth for the research direction and downstream handoff.

Recommended sections:

- Objective
- Problem Definition
- Thesis
- Milestones
- Baseline
- Validation plan
- Risks
- Non-goals
- Implementation Handoff
- Optimization Handoff

### `research/plan-history.md`

Append-only planning diary.

Each entry should include:

- timestamp,
- what changed,
- why it changed,
- previous assumptions,
- new assumptions,
- next action.
