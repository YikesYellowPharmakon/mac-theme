#!/usr/bin/env python3
"""Generate a grainy theme wallpaper, or Matrix rain for into-the-matrix."""

from __future__ import annotations

import importlib.util
import random
import subprocess
import sys
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "parse_colors", Path(__file__).resolve().parent / "parse-colors.py"
)
_mod = importlib.util.module_from_spec(_spec)
assert _spec.loader
_spec.loader.exec_module(_mod)
hex_to_rgb = _mod.hex_to_rgb
parse = _mod.parse


def clamp(value: int) -> int:
    return 0 if value < 0 else 255 if value > 255 else value


def mix(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3))  # type: ignore[return-value]


def write_ppm(path: Path, width: int, height: int, pixels: bytearray) -> None:
    path.write_bytes(f"P6\n{width} {height}\n255\n".encode() + pixels)


def generate(colors: dict[str, str], dest: Path, kind: str, width: int = 2560, height: int = 1600) -> None:
    bg = hex_to_rgb(colors["background"])
    accent = hex_to_rgb(colors["accent"])
    fg = hex_to_rgb(colors.get("bright_foreground", colors["foreground"]))
    lift = hex_to_rgb(colors.get("lighter_background", colors["background"]))
    rng = random.Random(sum(bg) * 97 + sum(accent) * 13)
    pixels = bytearray(width * height * 3)

    if kind == "rain":
        column_w = 7
        for x in range(width):
            col = x // column_w
            seed = random.Random(col * 7919 + 13)
            if seed.random() < 0.18:
                color = mix(bg, lift, 0.12)
                grain = seed.randint(-6, 6)
                for y in range(height):
                    idx = (y * width + x) * 3
                    pixels[idx] = clamp(color[0] + grain)
                    pixels[idx + 1] = clamp(color[1] + grain)
                    pixels[idx + 2] = clamp(color[2] + grain // 2)
                continue
            head = seed.randrange(0, height)
            length = seed.randint(int(height * 0.18), int(height * 0.72))
            for y in range(height):
                dist = (head - y) % height
                if dist > length:
                    color = mix(bg, lift, 0.15)
                elif dist < 3:
                    color = fg
                else:
                    t = 1 - dist / length
                    color = mix(bg, accent, 0.18 + t * 0.82)
                grain = seed.randint(-8, 8)
                idx = (y * width + x) * 3
                pixels[idx] = clamp(color[0] + grain)
                pixels[idx + 1] = clamp(color[1] + grain)
                pixels[idx + 2] = clamp(color[2] + grain // 2)
    else:
        for y in range(height):
            vy = y / (height - 1)
            for x in range(width):
                vx = x / (width - 1)
                vignette = (vx - 0.5) ** 2 + (vy - 0.5) ** 2
                t = 0.35 * (1 - vy) + 0.12 * vx
                color = mix(bg, lift, t)
                color = mix(color, accent, 0.04 + 0.10 * (1 - min(1.0, vignette * 2.4)))
                grain = rng.randint(-10, 10)
                idx = (y * width + x) * 3
                pixels[idx] = clamp(color[0] + grain)
                pixels[idx + 1] = clamp(color[1] + grain)
                pixels[idx + 2] = clamp(color[2] + grain)

    tmp = dest.with_suffix(".ppm")
    write_ppm(tmp, width, height, pixels)
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["sips", "-s", "format", "jpeg", "-s", "formatOptions", "80", str(tmp), "--out", str(dest)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    tmp.unlink(missing_ok=True)


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: gen-wallpaper.py <colors.toml> <out.jpg> [rain|grain]", file=sys.stderr)
        return 2
    colors = parse(Path(sys.argv[1]))
    dest = Path(sys.argv[2])
    kind = sys.argv[3] if len(sys.argv) > 3 else "grain"
    generate(colors, dest, kind)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
