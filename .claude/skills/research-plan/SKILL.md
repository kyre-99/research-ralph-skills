---
name: research-plan
description: Discuss a research problem with the user, clarify the scope, and persist the outcome as a durable research plan plus a planning history log. Use when the user wants to shape an idea, refine a research question, compare directions, define milestones, or produce a reusable plan for implementation and optimization. Triggers on: research plan, refine this idea, discuss a paper idea, build a research plan, turn this into a project plan, define the research scope.
argument-hint: [research topic or problem]
user-invocable: true
---

# Research Planning

Plan the research direction for: $ARGUMENTS

Read `${CLAUDE_SKILL_DIR}/references/planning-artifacts.md` before updating the planning files.

Start every invocation by reading:

1. `runtime/RESEARCH_STATE.json` if it exists
2. `research/plan.md` if it exists
3. `research/plan-history.md` if it exists

## Purpose

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.
This skill is not a one-off brainstorm. It creates the smallest planning artifact set that the next session can read directly without repeating the same discussion.

## Required Artifacts

Maintain only these files under `research/`:

- `research/plan.md` — current plan and handoff document
- `research/plan-history.md` — append-only history of planning revisions

## Workflow

1. Read any existing planning artifacts first.
2. Compare the current user request against the existing plan:
   - If aligned, refine the existing plan.
   - If materially different, update the plan and record the scope change in `plan-history.md`.
3. Ask only the minimum clarifying questions needed to remove dangerous ambiguity.
4. Write or update:
   - the objective,
   - the problem definition,
   - the thesis,
   - milestones,
   - baseline definition,
   - evaluation plan,
   - risks,
   - non-goals,
   - implementation handoff,
   - optimization handoff.
5. Append a planning entry to `research/plan-history.md`.
6. Update `runtime/RESEARCH_STATE.json` if it exists with a short summary of the current goal, status, next step, and key files.

## Output Contract

### `research/plan.md`

Must contain:

- objective,
- problem definition,
- thesis,
- milestones,
- baseline definition,
- evaluation plan,
- risks,
- non-goals,
- implementation handoff,
- optimization handoff.

### `research/plan-history.md`

Each append should include:

- timestamp,
- what changed,
- why it changed,
- previous assumptions,
- new assumptions,
- next action.

## Planning Rules

- Prefer a compact, testable thesis over a broad wishlist.
- Make hypotheses falsifiable.
- Include default metrics if the user did not specify any.
- Treat literature validation as a follow-up task unless it is the immediate focus.
- The plan should be ready for `/research-implement` and `/research-optimize` without re-planning from scratch.
- Use `Implementation Handoff` and `Optimization Handoff` to make downstream consumption explicit.
- Keep `runtime/RESEARCH_STATE.json` lightweight. It should orient the next agent quickly, not duplicate the full plan.

## Boundaries

- Do not start coding in this skill.
- Do not launch experiments in this skill.
- Do not leave planning results only in the conversation; persist them to files.
