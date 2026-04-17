#!/bin/bash
#
# Minimal Ralph-like optimization runner for repeated Claude Code iterations.
# Usage: ./scripts/research-bot/optimize.sh [max_iterations]

set -e

MAX_ITERATIONS="${1:-10}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPT_FILE="$ROOT_DIR/optimization/CLAUDE.md"
STATE_FILE="$ROOT_DIR/optimization/STATE.json"
PROGRESS_FILE="$ROOT_DIR/optimization/PROGRESS.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "Missing $PROMPT_FILE"
  echo "Initialize optimization artifacts with the research-optimize skill first."
  exit 1
fi

mkdir -p "$ROOT_DIR/optimization"

if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Optimization Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

echo "Starting research optimization loop for $MAX_ITERATIONS iterations"

for i in $(seq 1 "$MAX_ITERATIONS"); do
  echo ""
  echo "==============================================================="
  echo "  Optimization Iteration $i of $MAX_ITERATIONS"
  echo "==============================================================="

  OUTPUT=$(claude --dangerously-skip-permissions --print < "$PROMPT_FILE" 2>&1 | tee /dev/stderr) || true

  if echo "$OUTPUT" | grep -q "<promise>OPTIMIZATION_COMPLETE</promise>"; then
    echo ""
    echo "Optimization objective reached."
    exit 0
  fi

  if [ -f "$STATE_FILE" ]; then
    STATUS=$(python3 - <<'PY' "$STATE_FILE"
import json, sys
path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(data.get("status", ""))
except Exception:
    print("")
PY
)
    if [ "$STATUS" = "completed" ] || [ "$STATUS" = "stopped" ]; then
      echo ""
      echo "Optimization loop stopped according to optimization/STATE.json."
      exit 0
    fi
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Reached max iterations ($MAX_ITERATIONS)."
echo "Check $PROGRESS_FILE for details."
exit 1
