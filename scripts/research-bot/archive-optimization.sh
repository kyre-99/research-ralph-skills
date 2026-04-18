#!/bin/bash
#
# Archive the current optimization run before starting a materially new one.
# Usage: ./scripts/research-bot/archive-optimization.sh [reason-or-slug]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCHIVE_ROOT="$ROOT_DIR/archive/optimization"
TIMESTAMP="$(date '+%Y-%m-%d-%H%M%S')"
RAW_REASON="${1:-optimization-reset}"
SLUG="$(printf '%s' "$RAW_REASON" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/-\{2,\}/-/g' | sed 's/^-//' | sed 's/-$//')"

if [ -z "$SLUG" ]; then
  SLUG="optimization-reset"
fi

TARGET="$ARCHIVE_ROOT/$TIMESTAMP-$SLUG"

mkdir -p "$TARGET/research" "$TARGET/optimization" "$TARGET/runtime"

copy_if_exists() {
  local path="$1"
  local destination="$2"
  if [ -e "$path" ]; then
    cp -R "$path" "$destination"
  fi
}

copy_if_exists "$ROOT_DIR/research/plan.md" "$TARGET/research/"
copy_if_exists "$ROOT_DIR/research/plan-history.md" "$TARGET/research/"
copy_if_exists "$ROOT_DIR/research/implementation" "$TARGET/research/"
copy_if_exists "$ROOT_DIR/optimization/prd.json" "$TARGET/optimization/"
copy_if_exists "$ROOT_DIR/optimization/progress.md" "$TARGET/optimization/"
copy_if_exists "$ROOT_DIR/optimization/CLAUDE.md" "$TARGET/optimization/"
copy_if_exists "$ROOT_DIR/runtime/RESEARCH_STATE.json" "$TARGET/runtime/"
copy_if_exists "$ROOT_DIR/runtime/MANIFEST.md" "$TARGET/runtime/"

cat > "$TARGET/summary.md" <<EOF
# Optimization Archive Summary

- Created at: $(date '+%Y-%m-%d %H:%M:%S')
- Reason: $RAW_REASON
- Source root: $ROOT_DIR
- Archive kind: optimization

This archive preserves the previous optimization run before a materially new optimization direction replaced it.
EOF

echo "Archived optimization run to $TARGET"
