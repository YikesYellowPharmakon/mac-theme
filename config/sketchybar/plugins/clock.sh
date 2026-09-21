#!/bin/bash
source "$(dirname "$0")/env.sh"
sketchybar --set "$NAME" icon="" label="$(date '+%a %H:%M')"
