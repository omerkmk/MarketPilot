#!/bin/bash
# PostToolUse (Edit|Write): .swift dosyası değiştiyse not bırakır. Build almaz.

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

if [[ "$file_path" != *.swift ]]; then
  exit 0
fi

touch "$CLAUDE_PROJECT_DIR/.claude/hooks/.swift-changed"
exit 0
