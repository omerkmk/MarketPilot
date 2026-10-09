#!/bin/bash
# Stop: .swift değişikliği notu varsa build alır; kırıksa hataları Claude'a döner (exit 2).

marker="$CLAUDE_PROJECT_DIR/.claude/hooks/.swift-changed"

if [[ ! -f "$marker" ]]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR" || exit 0

output=$(xcodebuild -project MarketPilot.xcodeproj -scheme MarketPilot -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5,arch=arm64' build 2>&1)
status=$?

if [[ $status -eq 0 ]]; then
  rm -f "$marker"
  exit 0
fi

errors=$(echo "$output" | grep "error:")

if [[ -n "$errors" ]]; then
  echo "$errors" >&2
else
  echo "$output" | tail -n 20 >&2
fi
exit 2
