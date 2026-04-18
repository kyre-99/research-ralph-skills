#!/bin/bash
#
# Minimal Ralph-like implementation runner for repeated Claude Code iterations.
# Usage: ./scripts/research-bot/implement.sh [max_iterations]

set -e

MAX_ITERATIONS="${1:-10}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPT_FILE="$ROOT_DIR/research/implementation/CLAUDE.md"
TASKS_FILE="$ROOT_DIR/research/implementation/tasks.json"
PROGRESS_FILE="$ROOT_DIR/research/implementation/progress.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Missing $PROMPT_FILE"
  echo "Initialize implementation artifacts with the research-implement skill first."
  exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
  echo "Missing $TASKS_FILE"
  echo "Initialize implementation artifacts with the research-implement skill first."
  exit 1
fi

mkdir -p "$ROOT_DIR/research/implementation"

if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Implementation Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

echo "Starting research implementation loop for $MAX_ITERATIONS iterations"
echo "Runner role: this script owns the multi-round loop."
echo "Authoring role: /research-implement should prepare artifacts and recommend this command instead of running the loop itself."

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo ""
  echo "==============================================================="
  echo "  Implementation Iteration $i of $MAX_ITERATIONS"
  echo "==============================================================="

  OUTPUT=$(
    (
      cd "$ROOT_DIR"
      {
        echo "Implementation workspace context:"
        echo "- Project root: $ROOT_DIR"
        echo "- Instruction file: $PROMPT_FILE"
        echo "- Task file: $TASKS_FILE"
        echo "- Progress file: $PROGRESS_FILE"
        echo ""
        echo "Before starting implementation work:"
        echo "1. Read the instruction file, task file, and progress file at the exact paths above."
        echo "2. Use the project root above as the working directory."
        echo "3. Follow the instruction file below as the primary implementation guide."
        echo ""
        echo "----- BEGIN CLAUDE.md -----"
        cat "$PROMPT_FILE"
        echo ""
        echo "----- END CLAUDE.md -----"
      } | claude --dangerously-skip-permissions --print
    ) 2>&1 | tee /dev/stderr
  ) || true

  if echo "$OUTPUT" | grep -q "<promise>IMPLEMENTATION_COMPLETE</promise>"; then
    echo ""
    echo "Implementation objective reached."
    exit 0
  fi

  STATUS=$(python3 - <<'PY' "$TASKS_FILE"
import json, sys
path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    tasks = data.get("tasks", [])
    incomplete = [t for t in tasks if str(t.get("status", "")).lower() not in {"complete", "completed", "done", "passed"}]
    print("completed" if not incomplete else "in_progress")
except Exception:
    print("")
PY
)
  if [ "$STATUS" = "completed" ]; then
    echo ""
    echo "Implementation loop stopped because all implementation tasks are complete."
    exit 0
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)."
echo "Check $PROGRESS_FILE for details."
echo "If more rounds are needed, rerun: ./scripts/research-bot/implement.sh $MAX_ITERATIONS"
exit 1
