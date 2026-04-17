#!/bin/bash
#
# Install the repo skills into Claude Code's global skills directory.
# Usage:
#   ./scripts/research-bot/install-skills.sh
#   ./scripts/research-bot/install-skills.sh /custom/skills/dir

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_DIR="$ROOT_DIR/.claude/skills"
TARGET_DIR="${1:-${HOME}/.claude/skills}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Missing source skills directory: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"

for skill_dir in "$SOURCE_DIR"/*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  target_path="$TARGET_DIR/$skill_name"

  rm -rf "$target_path"
  cp -R "$skill_dir" "$target_path"
  echo "Installed skill: $skill_name -> $target_path"
done

echo ""
echo "Done."
echo "Global skills installed to: $TARGET_DIR"
