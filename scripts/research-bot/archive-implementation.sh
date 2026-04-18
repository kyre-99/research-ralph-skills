#!/bin/bash
#
# Archive the current implementation run before starting a materially new one.
# Usage: ./scripts/research-bot/archive-implementation.sh [reason-or-slug]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCHIVE_ROOT="$ROOT_DIR/archive/implementation"
TIMESTAMP="$(date '+%Y-%m-%d-%H%M%S')"
RAW_REASON="${1:-implementation-reset}"
SLUG="$(printf '%s' "$RAW_REASON" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/-\{2,\}/-/g' | sed 's/^-//' | sed 's/-$//')"

if [ -z "$SLUG" ]; then
  SLUG="implementation-reset"
fi

TARGET="$ARCHIVE_ROOT/$TIMESTAMP-$SLUG"

mkdir -p "$TARGET/research" "$TARGET/runtime"

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
copy_if_exists "$ROOT_DIR/runtime/RESEARCH_STATE.json" "$TARGET/runtime/"
copy_if_exists "$ROOT_DIR/runtime/MANIFEST.md" "$TARGET/runtime/"

cat > "$TARGET/summary.md" <<EOF
# Implementation Archive Summary

- Created at: $(date '+%Y-%m-%d %H:%M:%S')
- Reason: $RAW_REASON
- Source root: $ROOT_DIR
- Archive kind: implementation

This archive preserves the previous implementation run before a materially new implementation direction replaced it.
EOF

echo "Archived implementation run to $TARGET"

