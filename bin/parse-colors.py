#!/usr/bin/env python3
"""Parse a theme colors.toml into shell assignments or JSON."""

from __future__ import annotations

import json
import re
import shlex
import sys
from pathlib import Path

PAIR = re.compile(
    r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(.*?)"\s*$'
)


def parse(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = PAIR.match(stripped)
        if match:
            data[match.group(1)] = match.group(2)
    return data


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.strip().lstrip("#")
    if len(value) != 6:
        raise ValueError(value)
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def argb(hex_color: str, alpha: str = "ff") -> str:
    return f"0x{alpha}{hex_color.lstrip('#').lower()}"


def nearest_apple_accent(hex_color: str) -> int:
    r, g, b = hex_to_rgb(hex_color)
    presets = {
        -1: (152, 152, 157),
        0: (255, 59, 48),
        1: (255, 149, 0),
        2: (255, 204, 0),
        3: (52, 199, 76),
        4: (0, 122, 255),
        5: (175, 82, 222),
        6: (255, 45, 85),
    }
    return min(
        presets,
        key=lambda key: (r - presets[key][0]) ** 2
        + (g - presets[key][1]) ** 2
        + (b - presets[key][2]) ** 2,
    )


def highlight_string(hex_color: str) -> str:
    r, g, b = hex_to_rgb(hex_color)
    return f"{r / 255:.6f} {g / 255:.6f} {b / 255:.6f} Other"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: parse-colors.py <colors.toml> [json|export]", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    fmt = sys.argv[2] if len(sys.argv) > 2 else "export"
    colors = parse(path)
    if "accent" not in colors or "background" not in colors:
        print("colors.toml missing accent/background", file=sys.stderr)
        return 1
    colors.setdefault("foreground", "#c0caf5")
    colors.setdefault("muted", colors.get("dark_foreground", "#555555"))
    colors.setdefault("selection", colors.get("lighter_background", colors["background"]))
    colors.setdefault("bright_foreground", colors["foreground"])
    colors.setdefault("cursor", colors.get("bright_foreground", colors["foreground"]))
    colors.setdefault("mode", "dark")
    extra = {
        "apple_accent": str(nearest_apple_accent(colors["accent"])),
        "apple_highlight": highlight_string(colors["accent"]),
        "bar_bg": argb(colors["background"], "c8"),
        "bar_border": argb(colors.get("lighter_background", colors["background"]), "66"),
        "acc_argb": argb(colors["accent"]),
        "fg_argb": argb(colors["foreground"]),
        "muted_argb": argb(colors["muted"]),
        "sel_argb": argb(colors["selection"]),
        "bg_argb": argb(colors["background"]),
        "inactive_border": argb(colors.get("lighter_background", colors["muted"]), "66"),
    }
    if fmt == "json":
        print(json.dumps({**colors, **extra}))
        return 0
    for key, value in {**colors, **extra}.items():
        print(f"{key}={shlex.quote(str(value))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
