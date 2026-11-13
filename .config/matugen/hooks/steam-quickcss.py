#!/usr/bin/env python3
import colorsys
import json
import re
import sys
from pathlib import Path

STEAMUI = Path.home() / ".local/share/Steam/steamui"
QUICK_CSS = Path.home() / ".config/millennium/quick.css"

COLOR_PROPS = re.compile(
    r"^(--[\w-]+|color|fill|stroke|caret-color|outline(-color)?|"
    r"background(-color|-image)?|border(-(top|right|bottom|left))?(-color)?)$"
)
HEX = r"#[0-9a-fA-F]{3,8}\b"
RGB = r"rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*[\d.]+\s*)?\)"
COLOR = re.compile(f"{HEX}|{RGB}")
SKIP_AT_RULES = ("@keyframes", "@-webkit-keyframes", "@font-face", "@page")

NEUTRAL_TIERS = [
    (0.10, "surface_container_lowest"),
    (0.14, "surface"),
    (0.19, "surface_container"),
    (0.25, "surface_container_high"),
    (0.40, "surface_container_highest"),
    (0.60, "outline"),
    (0.80, "on_surface_variant"),
    (1.01, "on_surface"),
]


def parse_color(text):
    if text.startswith("#"):
        h = text[1:]
        if len(h) in (3, 4):
            h = "".join(c * 2 for c in h)
        if len(h) not in (6, 8):
            return None
        r, g, b = (int(h[i : i + 2], 16) for i in (0, 2, 4))
        a = int(h[6:8], 16) / 255 if len(h) == 8 else None
        return r, g, b, a
    parts = [p.strip() for p in text[text.index("(") + 1 : -1].split(",")]
    r, g, b = (int(p) for p in parts[:3])
    a = float(parts[3]) if len(parts) == 4 else None
    return r, g, b, a


def role_for(r, g, b):
    hue, lightness, _ = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    chroma = (max(r, g, b) - min(r, g, b)) / 255
    bluish = 190 <= hue * 360 <= 230
    if chroma >= 0.24:
        return "primary" if bluish and lightness > 0.3 else None
    if chroma >= 0.08 and not bluish:
        return None
    return next(role for limit, role in NEUTRAL_TIERS if lightness < limit)


def recolor(prop, value, palette):
    changed = False
    accent = "primary_container" if prop.startswith("background") else "primary"

    def swap(match):
        nonlocal changed
        parsed = parse_color(match.group(0))
        if parsed is None:
            return match.group(0)
        r, g, b, a = parsed
        if a == 0:
            return match.group(0)
        role = role_for(r, g, b)
        if role is None:
            return match.group(0)
        if role == "primary":
            role = accent
        changed = True
        nr, ng, nb = palette[role]
        return f"rgb({nr}, {ng}, {nb})" if a is None else f"rgba({nr}, {ng}, {nb}, {a:g})"

    return COLOR.sub(swap, value), changed


def split_blocks(css):
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    stack, start, i = [], 0, 0
    while i < len(css):
        c = css[i]
        if c == "\\":
            i += 2
            continue
        if c in "\"'":
            end = css.find(c, i + 1)
            i = len(css) if end == -1 else end + 1
            continue
        if c == "{":
            stack.append(css[start:i].strip())
            start = i + 1
        elif c == "}":
            if stack:
                yield list(stack), css[start:i]
                stack.pop()
            start = i + 1
        elif c == ";" and (not stack or stack[-1].startswith("@")):
            start = i + 1
        i += 1


def build(palette):
    rules = []
    seen = set()
    for path in sorted(STEAMUI.rglob("*.css")):
        for preludes, body in split_blocks(path.read_text(errors="ignore")):
            if any(p.startswith(SKIP_AT_RULES) for p in preludes):
                continue
            selector, *wrappers = reversed(preludes)
            if selector.startswith("@"):
                continue
            decls = []
            for decl in body.split(";"):
                prop, sep, value = decl.partition(":")
                prop = prop.strip()
                if not sep or not COLOR_PROPS.match(prop) or "url(" in value:
                    continue
                value = value.replace("!important", "").strip()
                new, changed = recolor(prop, value, palette)
                if changed:
                    decls.append(f"{prop}:{new}!important")
            if not decls:
                continue
            rule = f"{selector}{{{';'.join(decls)}}}"
            for wrapper in wrappers:
                rule = f"{wrapper}{{{rule}}}"
            if rule not in seen:
                seen.add(rule)
                rules.append(rule)
    return "\n".join(rules) + "\n"


def main():
    colors = json.loads(Path(sys.argv[1]).read_text())
    palette = {
        name: tuple(int(value[i : i + 2], 16) for i in (1, 3, 5))
        for name, value in colors.items()
    }
    if not STEAMUI.is_dir():
        return
    QUICK_CSS.parent.mkdir(parents=True, exist_ok=True)
    QUICK_CSS.write_text(build(palette))


if __name__ == "__main__":
    main()
