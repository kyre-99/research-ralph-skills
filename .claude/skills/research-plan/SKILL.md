---
name: research-plan
description: Discuss a research problem with the user, clarify the scope, and persist the outcome as reusable planning artifacts for later implementation and optimization. Use when the user wants to shape an idea, refine a research question, compare directions, define milestones, or produce a durable research brief. Triggers on: research plan, refine this idea, discuss a paper idea, build a research brief, turn this into a project plan, define the research scope.
argument-hint: [research topic or problem]
user-invocable: true
---

# Research Planning

Plan the research direction for: $ARGUMENTS

Read `${CLAUDE_SKILL_DIR}/references/planning-artifacts.md` before updating the planning files.

## Purpose

This skill is not a one-off brainstorm. It creates the smallest planning artifact set that the next session can read directly without repeating the same discussion.

## Required Artifacts

Maintain only these files under `research/`:

- `research/brief.md` — current high-level brief
- `research/plan.md` — actionable milestone plan
- `research/plan-state.json` — machine-readable planning state
- `research/plan-progress.md` — append-only planning log

Use `${CLAUDE_SKILL_DIR}/assets/plan-state.template.json` when initializing `research/plan-state.json`.

## Workflow

1. Read any existing planning artifacts first.
2. Compare the current user request against the existing brief:
   - If aligned, refine the existing files.
   - If materially different, update the brief and record the scope change in `plan-progress.md`.
3. Ask only the minimum clarifying questions needed to remove dangerous ambiguity.
4. Write or update:
   - the problem definition,
   - the main hypotheses,
   - scope boundaries,
   - milestones,
   - evaluation criteria,
   - the recommended next step.
5. Append a planning entry to `research/plan-progress.md`.

## Output Contract

### `research/brief.md`

Must contain:

- title,
- objective,
- problem context,
- assumptions,
- hypotheses,
- constraints,
- success criteria.

### `research/plan.md`

Must contain:

- milestone list,
- expected deliverables per milestone,
- validation plan,
- major risks and mitigations,
- explicit non-goals,
- exact next action.

### `research/plan-state.json`

Must track at least:

```json
{
  "topic": "",
  "status": "draft",
  "current_phase": "planning",
  "recommended_next_skill": "research-implement",
  "primary_metric": "",
  "artifacts": {
    "brief": "research/brief.md",
    "plan": "research/plan.md",
    "progress": "research/plan-progress.md"
  },
  "updated_at": ""
}
```

## Planning Rules

- Prefer a compact, testable thesis over a broad wishlist.
- Make hypotheses falsifiable.
- Include default metrics if the user did not specify any.
- Treat literature validation as a follow-up task unless it is the immediate focus.
- The plan should be ready for `/research-implement` without re-planning from scratch.

## Boundaries

- Do not start coding in this skill.
- Do not launch experiments in this skill.
- Do not leave planning results only in the conversation; persist them to files.
