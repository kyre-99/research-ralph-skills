# Persistent Runtime Pattern

Persistence should work across planning, implementation, and optimization with as few top-level files as possible.

## Runtime Layer

The `runtime/` directory is the top-level recovery surface.

### `runtime/RESEARCH_STATE.json`

Machine-readable context entrypoint for the next fresh session.

Recommended structure:

```json
{
  "active_phase": "planning",
  "current_goal": "",
  "current_status": "planning not started",
  "next_step": "run /research-plan with a concrete research topic",
  "recommended_next_skill": "research-plan",
  "key_files": [
    "research/plan.md",
    "research/plan-history.md"
  ],
  "updated_at": ""
}
```

### `runtime/MANIFEST.md`

Human-readable file index of the canonical artifacts and their purpose.

## Design Rules

- Planning, implementation, and optimization keep their own local files.
- `runtime/` gives the next agent a short orientation layer rather than duplicating the full artifacts.
- Recovery starts from `runtime/`, then drills into the phase-specific files.
- Keep source-of-truth files singular and explicit.
- When a new run replaces the current one, archive the previous `research/`, `optimization/`, and `runtime/` directories under `archive/`.
