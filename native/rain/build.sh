#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/native/rain"
OUT="$ROOT/build/rain"
SAVER_DST="$HOME/Library/Screen Savers/MacThemeRain.saver"
SDK="$(xcrun --show-sdk-path)"

mkdir -p "$OUT" "$ROOT/bin"

clang -fobjc-arc -O2 -isysroot "$SDK" \
  -framework Cocoa -framework CoreGraphics -framework CoreText \
  -o "$ROOT/bin/mac-theme-rain" \
  "$SRC/RainView.m" "$SRC/desktop_main.m"

mkdir -p "$OUT/MacThemeRain.saver/Contents/MacOS" "$OUT/MacThemeRain.saver/Contents/Resources"

clang -bundle -fobjc-arc -O2 -isysroot "$SDK" \
  -framework Cocoa -framework CoreGraphics -framework CoreText -framework ScreenSaver \
  -o "$OUT/MacThemeRain.saver/Contents/MacOS/MacThemeRain" \
  "$SRC/RainView.m" "$SRC/MacThemeRainView.m"

cp "$SRC/Info-saver.plist" "$OUT/MacThemeRain.saver/Contents/Info.plist"
mkdir -p "$HOME/Library/Screen Savers"
rm -rf "$SAVER_DST"
cp -R "$OUT/MacThemeRain.saver" "$SAVER_DST"
echo "built $ROOT/bin/mac-theme-rain"
echo "installed $SAVER_DST"
