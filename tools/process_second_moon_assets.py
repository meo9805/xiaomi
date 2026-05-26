#!/usr/bin/env python3
"""Extract the second moon boss sheet into transparent game assets."""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = Path(
    "/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/"
    "ig_0a13abd370e71d77016a15017a40248196bc04b9d12334a861.png"
)

ASSETS = {
    "boss_second_moon_warden": {
        "box": (20, 26, 760, 704),
        "out": ROOT / "assets/generated/bosses/boss_second_moon_warden.png",
        "max_size": 360,
        "padding": 30,
        "min_component_area": 16,
    },
    "item_second_moon_tear": {
        "box": (845, 170, 1295, 590),
        "out": ROOT / "assets/generated/items/item_second_moon_tear.png",
        "max_size": 220,
        "padding": 28,
        "min_component_area": 12,
    },
    "fx_moon_spring_slash": {
        "box": (1290, 20, 2160, 704),
        "out": ROOT / "assets/generated/vfx/fx_moon_spring_slash.png",
        "max_size": 460,
        "padding": 34,
        "min_component_area": 6,
    },
}


def is_border_background(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    spread = max(r, g, b) - min(r, g, b)
    average = (r + g + b) / 3
    return average >= 238 and spread <= 30


def remove_border_background(image: Image.Image) -> Image.Image:
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
        if not is_border_background(pixels[x, y]):
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    return rgba


def touches_transparency(pixels: Image.PixelAccess, width: int, height: int, x: int, y: int) -> bool:
    for nx in range(x - 1, x + 2):
        for ny in range(y - 1, y + 2):
            if nx == x and ny == y:
                continue
            if nx < 0 or ny < 0 or nx >= width or ny >= height:
                return True
            if pixels[nx, ny][3] == 0:
                return True
    return False


def remove_pale_edge_residue(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    for pass_index in range(4):
        pixels = rgba.load()
        width, height = rgba.size
        to_clear: list[tuple[int, int]] = []
        average_limit = 238 - pass_index * 6
        spread_limit = 30 - pass_index * 4
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a == 0:
                    continue
                average = (r + g + b) / 3
                spread = max(r, g, b) - min(r, g, b)
                if average >= average_limit and spread <= spread_limit and touches_transparency(pixels, width, height, x, y):
                    to_clear.append((x, y))
        if not to_clear:
            break
        for x, y in to_clear:
            pixels[x, y] = (255, 255, 255, 0)
    return rgba


def tint_pale_edge_highlights(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    moon_cream = (248, 226, 190)
    lavender_cream = (226, 210, 246)
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            average = (r + g + b) / 3
            spread = max(r, g, b) - min(r, g, b)
            if average < 218 or spread >= 28:
                continue
            if not touches_transparency(pixels, width, height, x, y):
                continue
            tint = lavender_cream if b >= r and b >= g else moon_cream
            pixels[x, y] = (tint[0], tint[1], tint[2], a)
    return rgba


def component_bounds(points: list[tuple[int, int]]) -> tuple[int, int, int, int]:
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


def remove_tiny_components(image: Image.Image, min_area: int) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    seen: set[tuple[int, int]] = set()
    components: list[list[tuple[int, int]]] = []

    for y in range(height):
        for x in range(width):
            if (x, y) in seen or pixels[x, y][3] == 0:
                continue
            queue: deque[tuple[int, int]] = deque([(x, y)])
            points: list[tuple[int, int]] = []
            seen.add((x, y))
            while queue:
                cx, cy = queue.popleft()
                points.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if nx < 0 or ny < 0 or nx >= width or ny >= height or (nx, ny) in seen:
                        continue
                    seen.add((nx, ny))
                    if pixels[nx, ny][3] > 0:
                        queue.append((nx, ny))
            components.append(points)

    for points in components:
        if len(points) >= min_area:
            continue
        for x, y in points:
            pixels[x, y] = (255, 255, 255, 0)

    return rgba


def crop_alpha(image: Image.Image, padding: int) -> Image.Image:
    rgba = image.convert("RGBA")
    bbox = rgba.getchannel("A").getbbox()
    if bbox is None:
        return rgba
    left, top, right, bottom = bbox
    box = (
        max(0, left - padding),
        max(0, top - padding),
        min(rgba.width, right + padding),
        min(rgba.height, bottom + padding),
    )
    return rgba.crop(box)


def normalize(image: Image.Image, max_size: int) -> Image.Image:
    rgba = image.convert("RGBA")
    if rgba.width <= max_size and rgba.height <= max_size:
        return rgba
    scale = min(max_size / rgba.width, max_size / rgba.height)
    size = (max(1, int(rgba.width * scale)), max(1, int(rgba.height * scale)))
    return rgba.resize(size, Image.Resampling.NEAREST)


def process_asset(source: Image.Image, config: dict[str, object]) -> dict[str, object]:
    image = source.crop(config["box"])  # type: ignore[arg-type]
    image = remove_border_background(image)
    image = remove_pale_edge_residue(image)
    image = remove_tiny_components(image, int(config["min_component_area"]))
    image = tint_pale_edge_highlights(image)
    image = crop_alpha(image, int(config["padding"]))
    image = normalize(image, int(config["max_size"]))

    out_path = Path(config["out"])
    out_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(out_path)
    return {
        "path": str(out_path.relative_to(ROOT)),
        "size": list(image.size),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path, nargs="?", default=DEFAULT_SOURCE)
    args = parser.parse_args()

    source = Image.open(args.source)
    manifest = {
        "source": str(args.source),
        "assets": {},
    }
    for name, config in ASSETS.items():
        manifest["assets"][name] = process_asset(source, config)
        print(f"saved {manifest['assets'][name]['path']} size={manifest['assets'][name]['size']}")

    manifest_path = ROOT / "assets/generated/second-moon-assets-manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
