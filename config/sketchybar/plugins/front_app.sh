#!/bin/bash
source "$(dirname "$0")/env.sh"
source "$HOME/.config/sketchybar/icon_map.sh"

app="${INFO:-}"
if [[ -z "$app" ]]; then
  app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true)"
fi

__icon_map "$app"
sketchybar --set "$NAME" icon="$icon_result" label="$app"
