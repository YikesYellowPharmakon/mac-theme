#!/usr/bin/env bash
# Pull official Omarchy colors.toml files into themes/.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

BASE="https://raw.githubusercontent.com/omacom/omarchy/quattro/themes"
THEMES=(
  catppuccin
  catppuccin-latte
  ethereal
  everforest
  flexoki-light
  gruvbox
  hackerman
  kanagawa
  last-horizon
  lumon
  lupine
  matte-black
  miasma
  nord
  osaka-jade
  retro-82
  ristretto
  rose-pine
  solitude
  tokyo-night
  vantablack
  white
)

for name in "${THEMES[@]}"; do
  dest="$THEMES_DIR/$name/colors.toml"
  mkdir -p "$(dirname "$dest")"
  if curl -fsSL "$BASE/$name/colors.toml" -o "$dest.tmp"; then
    mv "$dest.tmp" "$dest"
    echo "synced $name"
  else
    rm -f "$dest.tmp"
    if [[ -f "$dest" ]]; then
      echo "keep local $name"
    else
      echo "failed $name" >&2
    fi
  fi
done
