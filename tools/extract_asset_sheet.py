#!/usr/bin/env python3
"""Extract the first generated Moon Forest Camp asset sheet.

The Codex built-in image generator returned a checkerboard-looking background
instead of true alpha. This script removes only border-connected light neutral
checker pixels, then crops the current asset sheet into named PNG files.
Each crop gets a second pass that removes the pale one-pixel fringe left by
fake transparent backgrounds.
"""

from __future__ import annotations

import json
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/generated/moon-camp-asset-sheet.png"
ALPHA_SHEET = ROOT / "assets/generated/moon-camp-asset-sheet-alpha.png"
OUT_DIR = ROOT / "assets/generated/crops"


BOXES = {
    "hero_idle": (48, 82, 250, 372),
    "hero_attack": (250, 70, 570, 392),
    "enemy_moss_slime": (576, 130, 770, 360),
    "enemy_mushroom": (774, 112, 990, 370),
    "enemy_root_sprout": (1030, 90, 1225, 382),
    "icon_coins": (48, 420, 260, 642),
    "icon_moon_shard": (298, 420, 490, 662),
    "ui_button_primary": (510, 450, 855, 620),
    "ui_button_secondary": (875, 450, 1220, 620),
    "ui_bar_health": (58, 670, 600, 780),
    "ui_bar_xp": (640, 670, 1225, 780),
    "tab_adventure": (170, 820, 350, 1010),
    "tab_upgrade": (420, 820, 595, 1010),
    "tab_bag": (665, 820, 845, 1010),
    "tab_quest": (905, 820, 1092, 1010),
    "icon_notification": (165, 1060, 250, 1158),
    "fx_sparkles": (280, 1050, 1135, 1175),
}


def is_checker_pixel(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, _a = pixel
    return r > 218 and g > 218 and b > 218 and max(r, g, b) - min(r, g, b) <= 12


def is_light_residue_pixel(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return False
    spread = max(r, g, b) - min(r, g, b)
    average = (r + g + b) / 3
    return average >= 205 and spread <= 36


def is_neutral_fringe_pixel(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return False
    spread = max(r, g, b) - min(r, g, b)
    average = (r + g + b) / 3
    return average >= 135 and spread <= 50


def touches_transparency(
    pixels: Image.PixelAccess,
    width: int,
    height: int,
    x: int,
    y: int,
) -> bool:
    for nx in range(x - 1, x + 2):
        for ny in range(y - 1, y + 2):
            if nx == x and ny == y:
                continue
            if nx < 0 or ny < 0 or nx >= width or ny >= height:
                return True
            if pixels[nx, ny][3] == 0:
                return True
    return False


def remove_border_checkerboard(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
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
        if (x, y) in seen or x < 0 or y < 0 or x >= width or y >= height:
            continue
        seen.add((x, y))
        if not is_checker_pixel(pixels[x, y]):
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    return rgba


def alpha_bbox(image: Image.Image, padding: int = 6) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return (0, 0, image.width, image.height)
    left, top, right, bottom = bbox
    return (
        max(0, left - padding),
        max(0, top - padding),
        min(image.width, right + padding),
        min(image.height, bottom + padding),
    )


def remove_light_fringe(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    for _pass in range(2):
        pixels = rgba.load()
        width, height = rgba.size
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                if is_light_residue_pixel(pixels[x, y]) and touches_transparency(pixels, width, height, x, y):
                    to_clear.append((x, y))
        if not to_clear:
            break
        for x, y in to_clear:
            pixels[x, y] = (255, 255, 255, 0)
    pixels = rgba.load()
    width, height = rgba.size
    to_clear = []
    for y in range(height):
        for x in range(width):
            if is_neutral_fringe_pixel(pixels[x, y]) and touches_transparency(pixels, width, height, x, y):
                to_clear.append((x, y))
    for x, y in to_clear:
        pixels[x, y] = (255, 255, 255, 0)
    return rgba


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE)
    alpha_sheet = remove_border_checkerboard(source)
    alpha_sheet.save(ALPHA_SHEET)

    manifest = {
        "source": str(SOURCE.relative_to(ROOT)),
        "alpha_sheet": str(ALPHA_SHEET.relative_to(ROOT)),
        "assets": {},
    }

    for name, box in BOXES.items():
        crop = alpha_sheet.crop(box)
        crop = remove_light_fringe(crop)
        crop = crop.crop(alpha_bbox(crop))
        out_path = OUT_DIR / f"{name}.png"
        crop.save(out_path)
        manifest["assets"][name] = {
            "path": str(out_path.relative_to(ROOT)),
            "size": list(crop.size),
        }

    (OUT_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
