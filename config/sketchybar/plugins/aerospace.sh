#!/bin/bash
source "$(dirname "$0")/env.sh"
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null || true
ACCENT="${ACCENT:-0xff3cbf5c}"
MUTED="${MUTED:-0xff678d6a}"
SELECT="${SELECT:-0xff23482a}"

if [[ "${SENDER:-}" == "aerospace_workspace_change" && -n "${FOCUSED_WORKSPACE:-}" ]]; then
  focused="$FOCUSED_WORKSPACE"
else
  focused="$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null || echo 1)"
fi

for i in 1 2 3 4 5 6 7 8 9; do
  if [[ "$focused" == "$i" ]]; then
    sketchybar --set space."$i" icon.color="$ACCENT" background.drawing=on background.color="$SELECT"
  else
    sketchybar --set space."$i" icon.color="$MUTED" background.drawing=off
  fi
done
