#!/bin/bash
source "$(dirname "$0")/env.sh"
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null || true
ACCENT="${ACCENT:-0xff3cbf5c}"
MUTED="${MUTED:-0xff678d6a}"
percent="$(pmset -g batt | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"
charging="$(pmset -g batt | grep -c 'AC Power' || true)"
if [[ "${charging}" -gt 0 ]]; then
  icon=""
elif [[ "${percent:-0}" -gt 70 ]]; then
  icon=""
elif [[ "${percent:-0}" -gt 30 ]]; then
  icon=""
else
  icon=""
fi
color="$MUTED"
if [[ "${percent:-100}" -le 20 && "${charging}" -eq 0 ]]; then
  color="$ACCENT"
fi
sketchybar --set "$NAME" icon="$icon" icon.color="$color" label="${percent}%"
