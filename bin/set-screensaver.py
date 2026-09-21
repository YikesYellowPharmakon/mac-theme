#!/usr/bin/env python3
"""Point Sequoia idle/lock screensaver at MacThemeRain.saver."""

from __future__ import annotations

import os
import plistlib
import subprocess
from pathlib import Path
from urllib.parse import quote

STORE = Path.home() / "Library/Application Support/com.apple.wallpaper/Store/Index.plist"
SAVER = Path.home() / "Library/Screen Savers/MacThemeRain.saver"
PROVIDER = "com.apple.wallpaper.choice.screen-saver"


def saver_url() -> str:
    return "file://" + quote(str(SAVER), safe="/:")


def configuration() -> bytes:
    return plistlib.dumps({"module": {"relative": saver_url()}}, fmt=plistlib.FMT_BINARY)


def patch_idle(obj, in_idle: bool = False) -> None:
    if isinstance(obj, dict):
        next_idle = in_idle or "Idle" in obj
        if in_idle and "Provider" in obj and "Choices" not in obj:
            obj["Provider"] = PROVIDER
            obj["Files"] = []
            obj["Configuration"] = configuration()
        for key, value in obj.items():
            child_idle = in_idle
            if key == "Idle":
                child_idle = True
            elif key == "Desktop":
                child_idle = False
            patch_idle(value, child_idle)
    elif isinstance(obj, list):
        for item in obj:
            patch_idle(item, in_idle)


def main() -> int:
    if not SAVER.exists():
        print("screensaver missing:", SAVER)
        return 1
    if STORE.exists():
        data = plistlib.loads(STORE.read_bytes())
        patch_idle(data)
        STORE.write_bytes(plistlib.dumps(data, fmt=plistlib.FMT_BINARY))
        subprocess.run(["killall", "WallpaperAgent"], check=False)
    subprocess.run(
        [
            "osascript",
            "-e",
            'tell application "System Events" to set current screen saver to screen saver "MacThemeRain"',
        ],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        [
            "osascript",
            "-e",
            'tell application "System Events" to tell screen saver preferences to set delay interval to 120',
        ],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        ["defaults", "-currentHost", "write", "com.apple.screensaver", "idleTime", "-int", "120"],
        check=False,
    )
    subprocess.run(
        ["defaults", "write", "com.apple.screensaver", "askForPassword", "-int", "1"],
        check=False,
    )
    subprocess.run(
        ["defaults", "write", "com.apple.screensaver", "askForPasswordDelay", "-int", "0"],
        check=False,
    )
    print("screensaver -> MacThemeRain (idle 120s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
