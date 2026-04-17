#!/bin/bash
#
# Install the repo skills and helper scripts into a target project.
# Usage:
#   ./scripts/research-bot/install-skills.sh
#   ./scripts/research-bot/install-skills.sh /path/to/target-project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_DIR="$ROOT_DIR/.claude/skills"
SOURCE_SCRIPT_DIR="$ROOT_DIR/scripts/research-bot"
TARGET_PROJECT_DIR="${1:-$(pwd)}"
TARGET_DIR="$TARGET_PROJECT_DIR/.claude/skills"
TARGET_SCRIPT_DIR="$TARGET_PROJECT_DIR/scripts/research-bot"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Missing source skills directory: $SOURCE_DIR"
  exit 1
fi

if [ ! -d "$SOURCE_SCRIPT_DIR" ]; then
  echo "Missing source script directory: $SOURCE_SCRIPT_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_SCRIPT_DIR"

for skill_dir in "$SOURCE_DIR"/*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  target_path="$TARGET_DIR/$skill_name"

  rm -rf "$target_path"
  cp -R "$skill_dir" "$target_path"
  echo "Installed skill: $skill_name -> $target_path"
done

for script_file in "$SOURCE_SCRIPT_DIR"/*.sh; do
  [ -f "$script_file" ] || continue
  script_name="$(basename "$script_file")"
  target_script="$TARGET_SCRIPT_DIR/$script_name"
  cp "$script_file" "$target_script"
  chmod +x "$target_script"
  echo "Installed script: $script_name -> $target_script"
done

echo ""
echo "Done."
echo "Project skills installed to: $TARGET_DIR"
echo "Helper scripts installed to: $TARGET_SCRIPT_DIR"
