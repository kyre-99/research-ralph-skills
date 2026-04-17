#!/bin/bash
#
# Archive the current research-bot state before starting a materially new run.
# Usage: ./scripts/research-bot/archive-run.sh [slug]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCHIVE_DIR="$ROOT_DIR/archive"
TIMESTAMP="$(date '+%Y-%m-%d-%H%M%S')"
SLUG="${1:-run}"
SLUG="$(printf '%s' "$SLUG" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g' | sed 's/-\{2,\}/-/g' | sed 's/^-//' | sed 's/-$//')"

if [ -z "$SLUG" ]; then
  SLUG="run"
fi

TARGET="$ARCHIVE_DIR/$TIMESTAMP-$SLUG"

mkdir -p "$TARGET"

copy_if_exists() {
  local path="$1"
  if [ -e "$path" ]; then
    cp -R "$path" "$TARGET/"
  fi
}

copy_if_exists "$ROOT_DIR/research"
copy_if_exists "$ROOT_DIR/optimization"
copy_if_exists "$ROOT_DIR/runtime"

cat > "$TARGET/ARCHIVE_NOTE.md" <<EOF
# Archive Note

- Created at: $(date '+%Y-%m-%d %H:%M:%S')
- Slug: $SLUG
- Source root: $ROOT_DIR

This archive contains the previous research-bot state before a materially new run replaced it.
EOF

echo "Archived current run to $TARGET"
