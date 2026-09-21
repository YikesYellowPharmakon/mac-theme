#!/bin/bash
source "$(dirname "$0")/env.sh"
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null || true
MUTED="${MUTED:-0xff678d6a}"
vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 0)"
is_muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)"
if [[ "$is_muted" == "true" || "${vol:-0}" -eq 0 ]]; then
  icon=""
else
  icon=""
fi
sketchybar --set "$NAME" icon="$icon" icon.color="$MUTED" label="${vol}%"
