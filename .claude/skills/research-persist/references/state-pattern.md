# Persistent Runtime Pattern

Persistence should work across planning, implementation, and optimization with as few top-level files as possible.

## Runtime Layer

The `runtime/` directory is the top-level recovery surface.

### `runtime/RESEARCH_STATE.json`

Machine-readable index of the whole project state.

Recommended structure:

```json
{
  "active_phase": "planning",
  "recommended_next_skill": "research-plan",
  "canonical_files": {
    "plan": "research/plan.md",
    "plan_history": "research/plan-history.md",
    "implementation_tasks": "research/implementation/tasks.json",
    "optimization_prd": "optimization/prd.json"
  },
  "updated_at": ""
}
```

### `runtime/MANIFEST.md`

Human-readable file index of the canonical artifacts and their purpose.

## Design Rules

- Planning, implementation, and optimization keep their own local files.
- `runtime/` only indexes those files.
- Recovery starts from `runtime/`, then drills into the phase-specific files.
- Keep source-of-truth files singular and explicit.
- When a new run replaces the current one, archive the previous `research/`, `optimization/`, and `runtime/` directories under `archive/`.
