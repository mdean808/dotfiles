#!/usr/bin/env python3
import colorsys
import re
import shutil
import subprocess
import sys
from pathlib import Path

THEME = "Papirus-Dark"
PLACES = Path("/usr/share/icons/Papirus/48x48/places")
STATE = Path.home() / ".cache/matugen/papirus-folder-color"


def hsv(value):
    value = value.lstrip("#")
    return colorsys.rgb_to_hsv(*(int(value[i : i + 2], 16) / 255 for i in (0, 2, 4)))


def folder_colors():
    colors = {}
    for svg in PLACES.glob("folder-*.svg"):
        name = svg.stem.removeprefix("folder-")
        if "-" in name or not (PLACES / f"folder-{name}-documents.svg").exists():
            continue
        match = re.search(r"#[0-9a-fA-F]{6}", svg.read_text())
        if match:
            colors[name] = hsv(match.group(0))
    return colors


def distance(a, b):
    hue = min(abs(a[0] - b[0]), 1 - abs(a[0] - b[0]))
    return (hue * 2) ** 2 * min(a[1], b[1]) + (a[1] - b[1]) ** 2 + ((a[2] - b[2]) / 2) ** 2


def main():
    if not shutil.which("papirus-folders"):
        return
    target = hsv(sys.argv[1])
    colors = folder_colors()
    color = min(colors, key=lambda name: distance(target, colors[name]))
    if STATE.exists() and STATE.read_text() == color:
        return
    result = subprocess.run(
        ["sudo", "-n", "papirus-folders", "-C", color, "--theme", THEME],
        capture_output=True,
    )
    if result.returncode == 0:
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(color)


if __name__ == "__main__":
    main()
