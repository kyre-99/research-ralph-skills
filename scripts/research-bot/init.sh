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

write_if_missing "$ROOT_DIR/research/brief.md" "# Research Brief

## Objective
- 

## Problem Context
- 

## Assumptions
- 

## Hypotheses
1. 

## Constraints
- 

## Success Criteria
- "

write_if_missing "$ROOT_DIR/research/plan.md" "# Research Plan

## Thesis
- 

## Milestones
1. 

## Validation Plan
- 

## Risks
- 

## Non-Goals
- 

## Next Action
- "

write_if_missing "$ROOT_DIR/research/plan-progress.md" "# Planning Progress

## $(date '+%Y-%m-%d %H:%M:%S')
- Initialized planning artifacts
- Next action: fill in \`research/brief.md\` and \`research/plan.md\`
"

write_if_missing "$ROOT_DIR/research/plan-state.json" '{
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
}'

write_if_missing "$ROOT_DIR/research/implementation/IMPLEMENTATION.md" "# Implementation

## Target Milestone
- 

## Scope
- 

## Baseline Behavior
- 

## Validation Command
- 

## Expected Output Artifacts
- 

## Next Action
- "

write_if_missing "$ROOT_DIR/research/implementation/IMPLEMENTATION_LOG.md" "# Implementation Log

## $(date '+%Y-%m-%d %H:%M:%S')
- Initialized implementation artifacts
- Next action: define the first implementation slice
"

write_if_missing "$ROOT_DIR/research/implementation/IMPLEMENTATION_STATE.json" '{
  "status": "in_progress",
  "current_milestone": "",
  "baseline": "",
  "primary_metric": "",
  "last_validation": "",
  "ready_for_optimization": false,
  "updated_at": ""
}'

write_if_missing "$ROOT_DIR/optimization/OBJECTIVE.md" "# Optimization Objective

## Objective
- 

## Primary Metric
- Metric:
- Direction: higher-is-better / lower-is-better

## Target
- 

## Baseline
- Result:
- Run id:

## Constraints
- Time budget:
- Compute budget:
- Quality constraints:

## Allowed Search Space
- 

## Stop Conditions
- "

write_if_missing "$ROOT_DIR/optimization/QUEUE.md" "# Optimization Queue

## Active
- 

## Pending
- 

## Accepted
- 

## Rejected
- 

## Blocked
- "

write_if_missing "$ROOT_DIR/optimization/PROGRESS.md" "# Optimization Progress

## $(date '+%Y-%m-%d %H:%M:%S') - Round 0
- Hypothesis: initialization
- Change: created optimization artifacts
- Evaluation command:
- Metric result:
- Decision: ready for first optimization round
- Next action: define the first active optimization item
---"

write_if_missing "$ROOT_DIR/optimization/STATE.json" '{
  "status": "in_progress",
  "round": 0,
  "objective": "",
  "primary_metric": "",
  "baseline_metric": null,
  "best_metric": null,
  "best_run_id": "",
  "active_task": "",
  "stop_reason": "",
  "updated_at": ""
}'

write_if_missing "$ROOT_DIR/optimization/CLAUDE.md" "# Research Optimizer Instructions

You are running one iteration of the project optimization loop.

## Read First

1. \`optimization/OBJECTIVE.md\`
2. \`optimization/QUEUE.md\`
3. \`optimization/STATE.json\`
4. \`optimization/PROGRESS.md\`
5. \`research/brief.md\`
6. \`research/implementation/IMPLEMENTATION_STATE.json\`

## Your Task

1. Pick the active or highest-priority pending optimization item.
2. Implement only one bounded improvement attempt.
3. Run the relevant evaluation.
4. Update:
   - \`optimization/PROGRESS.md\`
   - \`optimization/STATE.json\`
   - \`optimization/QUEUE.md\`
5. Preserve the known-best configuration and metric.

## Stop Condition

If the objective target is reached, or the stopping rule says to stop, write that decision to \`optimization/STATE.json\` and reply with:

\`<promise>OPTIMIZATION_COMPLETE</promise>\`
"

write_if_missing "$ROOT_DIR/runtime/RESEARCH_STATE.json" '{
  "active_phase": "planning",
  "recommended_next_skill": "research-plan",
  "canonical_files": {
    "brief": "research/brief.md",
    "plan": "research/plan.md",
    "plan_state": "research/plan-state.json",
    "implementation_state": "research/implementation/IMPLEMENTATION_STATE.json",
    "optimization_state": "optimization/STATE.json"
  },
  "updated_at": ""
}'

write_if_missing "$ROOT_DIR/runtime/MANIFEST.md" "# Runtime Manifest

- \`research/brief.md\`: current research brief
- \`research/plan.md\`: current research plan
- \`research/plan-state.json\`: planning state
- \`research/implementation/IMPLEMENTATION.md\`: current implementation slice
- \`research/implementation/IMPLEMENTATION_STATE.json\`: implementation state
- \`optimization/OBJECTIVE.md\`: optimization contract
- \`optimization/QUEUE.md\`: optimization backlog
- \`optimization/STATE.json\`: optimization state
"

echo "Research bot artifacts initialized."
echo "Start with research/brief.md and research/plan.md, or invoke the research-plan skill."
