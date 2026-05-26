#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path("/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0696072409e942de016a151c08c0e08195ad7c2927928a8d3d.png")
OUT_DIR = ROOT / "assets/generated/ui"
PANEL_FILL = (21, 21, 40, 255)

COMPONENTS = [
    ("ui_modal_panel.png", (17, 318, 287, 880)),
    ("ui_hud_panel.png", (299, 555, 562, 880)),
    ("ui_button_primary.png", (580, 701, 836, 875)),
    ("ui_button_secondary.png", (306, 1039, 558, 1209)),
    ("ui_tab_selected.png", (580, 1039, 835, 1209)),
    ("ui_section_card.png", (626, 1334, 817, 1501)),
    ("ui_tab_idle.png", (23, 1354, 275, 1498)),
    ("ui_progress_xp.png", (304, 1427, 601, 1484)),
    ("ui_progress_hp.png", (304, 1644, 601, 1700)),
]


def is_key(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return False
    return g >= 88 and g - max(r, b) >= 30


def crop_component(source: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    crop = source.crop(box).convert("RGBA")
    width, height = crop.size
    pixels = crop.load()
    seen: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= width or y >= height or (x, y) in seen:
            continue
        seen.add((x, y))
        if not is_key(pixels[x, y]):
            continue
        pixels[x, y] = (0, 0, 0, 0)
        queue.append((x + 1, y))
        queue.append((x - 1, y))
        queue.append((x, y + 1))
        queue.append((x, y - 1))

    for y in range(height):
        for x in range(width):
            if is_key(pixels[x, y]):
                pixels[x, y] = PANEL_FILL

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if g > r + 8 and g > b + 8:
                pixels[x, y] = (0, 0, 0, 0) if touches_alpha(pixels, width, height, x, y) else PANEL_FILL

    return crop


def touches_alpha(
    pixels: Image.PixelAccess,
    width: int,
    height: int,
    x: int,
    y: int,
) -> bool:
    for ny in range(max(0, y - 1), min(height, y + 2)):
        for nx in range(max(0, x - 1), min(width, x + 2)):
            if nx == x and ny == y:
                continue
            if pixels[nx, ny][3] == 0:
                return True
    return False


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"missing generated source: {SOURCE}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE).convert("RGBA")
    for filename, box in COMPONENTS:
        out = OUT_DIR / filename
        crop_component(source, box).save(out)
        print(f"WROTE {out}")


if __name__ == "__main__":
    main()
