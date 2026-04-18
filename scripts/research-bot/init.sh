#!/bin/bash
#
# Initialize the minimal artifact structure for the research bot.
# Usage: ./scripts/research-bot/init.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

mkdir -p \
  "$ROOT_DIR/research" \
  "$ROOT_DIR/research/implementation" \
  "$ROOT_DIR/optimization" \
  "$ROOT_DIR/runtime"

write_if_missing() {
  local path="$1"
  local content="$2"
  if [ ! -f "$path" ]; then
    printf "%s\n" "$content" > "$path"
  fi
}

write_if_missing "$ROOT_DIR/research/plan.md" "# Research Plan

## Objective
- 

## Problem Definition
- 

## Thesis
- 

## Milestones
1. 

## Baseline
- 

## Validation Plan
- 

## Risks
- 

## Non-Goals
- 

## Implementation Handoff
- 

## Optimization Handoff
- "

write_if_missing "$ROOT_DIR/research/plan-history.md" "# Planning History

## $(date '+%Y-%m-%d %H:%M:%S')
- Initialized planning artifacts
- Previous assumptions:
- New assumptions:
- Next action: fill in \`research/plan.md\`
"

write_if_missing "$ROOT_DIR/research/implementation/tasks.json" '{
  "objective": "Implement the current research plan",
  "source_plan": "research/plan.md",
  "tasks": [
    {
      "id": "IMP-001",
      "title": "",
      "description": "",
      "acceptanceCriteria": [],
      "priority": 1,
      "status": "pending",
      "notes": ""
    }
  ]
}'

write_if_missing "$ROOT_DIR/research/implementation/progress.md" "# Implementation Progress

## $(date '+%Y-%m-%d %H:%M:%S')
- Initialized implementation artifacts
- Next action: define the first implementation task
"

write_if_missing "$ROOT_DIR/research/implementation/CLAUDE.md" "# Research Implementer Iteration Instructions

You are one fresh implementation iteration in a Ralph-like loop.
You are not responsible for starting or orchestrating the outer loop yourself.

## Read First

1. \`runtime/RESEARCH_STATE.json\` if it exists
2. \`research/plan.md\`
3. \`research/implementation/tasks.json\`
4. \`research/implementation/progress.md\`

## Your Task

1. Understand the current goal and status from \`runtime/RESEARCH_STATE.json\` if available.
2. Pick the highest-priority task in \`research/implementation/tasks.json\` where \`status\` is not complete.
3. Implement only one bounded implementation slice.
4. Run the relevant verification.
5. Update:
   - \`research/implementation/progress.md\`
   - \`research/implementation/tasks.json\`
   - \`runtime/RESEARCH_STATE.json\` if it exists
6. Preserve important implementation decisions in \`research/implementation/tasks.json\`.

## Important

- Work on exactly one implementation item per iteration.
- Treat this as a fresh invocation with no hidden memory beyond the files above.
- If the current task is too large for one bounded pass, split it in \`research/implementation/tasks.json\` and complete only the first smaller slice.
- Record reusable learnings in \`research/implementation/progress.md\` so the next iteration can continue cleanly.
- If conversational context is missing or stale, trust the files above and continue from them.
- Do not expand the scope beyond the current implementation goal.
- Write the next concrete step clearly so the next round can continue without guessing.
- Do not bootstrap a multi-round workflow from inside this iteration. The outer loop is run by \`./scripts/research-bot/implement.sh <N>\`.
- Do not rewrite the overall process. Focus on the next bounded implementation slice and the required file updates.

## Stop Condition

If all relevant tasks are complete, update \`research/implementation/tasks.json\` and \`runtime/RESEARCH_STATE.json\` if it exists, then reply with:

\`<promise>IMPLEMENTATION_COMPLETE</promise>\`
"

write_if_missing "$ROOT_DIR/optimization/prd.json" '{
  "objective": "",
  "primary_metric": "",
  "stop_condition": "",
  "baseline": {
    "metric": null,
    "run_id": ""
  },
  "tasks": [
    {
      "id": "OPT-001",
      "title": "",
      "type": "instrumentation",
      "description": "",
      "acceptanceCriteria": [],
      "priority": 1,
      "status": "pending",
      "notes": ""
    }
  ]
}'

write_if_missing "$ROOT_DIR/optimization/progress.md" "# Optimization Progress

## $(date '+%Y-%m-%d %H:%M:%S') - Round 0
- Hypothesis: initialization
- Change: created optimization artifacts
- Evaluation command:
- Metric result:
- Decision: ready for first optimization round
- Next action: define the first active optimization item
---"

write_if_missing "$ROOT_DIR/optimization/CLAUDE.md" "# Research Optimizer Iteration Instructions

You are one fresh optimization iteration in a Ralph-like loop.
You are not responsible for starting or orchestrating the outer loop yourself.

## Read First

1. \`runtime/RESEARCH_STATE.json\` if it exists
2. \`optimization/prd.json\`
3. \`optimization/progress.md\`
4. \`research/plan.md\`
5. \`research/implementation/tasks.json\`
6. \`research/implementation/progress.md\`

## Your Task

1. Understand the current goal and status from \`runtime/RESEARCH_STATE.json\` if available.
2. Pick the highest-priority task in \`optimization/prd.json\` where \`status\` is not complete.
3. Implement only one bounded improvement attempt.
4. Run the relevant evaluation.
5. Update:
   - \`optimization/progress.md\`
   - \`optimization/prd.json\`
   - \`runtime/RESEARCH_STATE.json\` if it exists
6. Preserve the known-best configuration and important decision notes in \`optimization/prd.json\`.

## Important

- Work on exactly one optimization item per iteration.
- Treat this as a fresh invocation with no hidden memory beyond the files above.
- If the current task is too large for one bounded pass, split it in \`optimization/prd.json\` and complete only the first smaller slice.
- Record reusable learnings in \`optimization/progress.md\` so the next iteration can continue cleanly.
- Do not bootstrap a multi-round workflow from inside this iteration. The outer loop is run by \`./scripts/research-bot/optimize.sh <N>\`.
- Do not silently convert this round into a new planning session. Focus on the next bounded optimization slice and the required file updates.
- Do not broaden the objective mid-run.
- Write the next concrete step clearly so the next round can continue without guessing.

## Stop Condition

If all relevant tasks are complete, or the stop condition in \`optimization/prd.json\` says to stop, update \`optimization/prd.json\` and \`runtime/RESEARCH_STATE.json\` if it exists, then reply with:

\`<promise>OPTIMIZATION_COMPLETE</promise>\`
"

write_if_missing "$ROOT_DIR/runtime/RESEARCH_STATE.json" '{
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
}'

write_if_missing "$ROOT_DIR/runtime/MANIFEST.md" "# Runtime Manifest

- \`research/plan.md\`: current research plan
- \`research/plan-history.md\`: planning history
- \`research/implementation/tasks.json\`: implementation task decomposition
- \`research/implementation/progress.md\`: implementation log
- \`research/implementation/CLAUDE.md\`: single-iteration implementation prompt
- \`optimization/prd.json\`: optimization task decomposition and objective
- \`optimization/progress.md\`: optimization log
- \`optimization/CLAUDE.md\`: single-iteration optimization prompt
"

echo "Research bot artifacts initialized."
echo "Start with research/plan.md, or invoke the research-plan skill."
echo "When artifacts are ready, run the shell loop explicitly:"
echo "  ./scripts/research-bot/implement.sh 10"
echo "  ./scripts/research-bot/optimize.sh 10"
