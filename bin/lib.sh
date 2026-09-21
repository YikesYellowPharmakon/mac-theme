#!/usr/bin/env bash
# Shared paths for mac-theme scripts.

# AeroSpace exec-and-forget uses a tiny PATH. Keep Homebrew/system Python visible.
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ROOT="${ROOT:-$(cd "$_LIB_DIR/.." && pwd)}"
export ROOT
export THEMES_DIR="$ROOT/themes"
export STATE_DIR="$ROOT/state"
export CURRENT_LINK="$STATE_DIR/current"
export CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export LOCAL_BIN="$HOME/.local/bin"
export DEFAULT_THEME="tokyo-night"

mkdir -p "$STATE_DIR"

list_themes() {
  find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

current_theme_name() {
  if [[ -L "$CURRENT_LINK" || -d "$CURRENT_LINK" ]]; then
    basename "$(readlink "$CURRENT_LINK" 2>/dev/null || echo "$CURRENT_LINK")"
  elif [[ -f "$STATE_DIR/theme.name" ]]; then
    cat "$STATE_DIR/theme.name"
  else
    echo "$DEFAULT_THEME"
  fi
}

notify() {
  /usr/bin/osascript >/dev/null 2>&1 -e "display notification \"$1\" with title \"mac-theme\"" || true
}

log_hotkey() {
  printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" >> "$STATE_DIR/hotkey.log"
}
