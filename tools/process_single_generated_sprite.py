#!/usr/bin/env python3
"""Clean one generated sprite into a transparent PNG asset."""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image


def is_light_background(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    spread = max(r, g, b) - min(r, g, b)
    average = (r + g + b) / 3
    return average >= 226 and spread <= 36


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
        if not is_light_background(pixels[x, y]):
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return rgba


def remove_pale_edge_residue(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    for pass_index in range(4):
        pixels = rgba.load()
        width, height = rgba.size
        to_clear: list[tuple[int, int]] = []
        threshold = 232 - pass_index * 6
        spread_limit = 38 - pass_index * 5
        for y in range(height):
            for x in range(width):
                r, g, b, a = pixels[x, y]
                if a == 0:
                    continue
                average = (r + g + b) / 3
                spread = max(r, g, b) - min(r, g, b)
                if average >= threshold and spread <= spread_limit and touches_transparency(pixels, width, height, x, y):
                    to_clear.append((x, y))
        if not to_clear:
            break
        for x, y in to_clear:
            pixels[x, y] = (255, 255, 255, 0)
    return rgba


def component_bounds(points: list[tuple[int, int]]) -> tuple[int, int, int, int]:
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


def keep_primary_cluster(image: Image.Image, margin: int) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    seen: set[tuple[int, int]] = set()
    components: list[dict[str, object]] = []

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
            components.append({"area": len(points), "bounds": component_bounds(points), "points": points})

    if not components:
        return rgba

    largest = max(components, key=lambda component: int(component["area"]))
    left, top, right, bottom = largest["bounds"]  # type: ignore[misc]
    keep_bounds = (
        max(0, int(left) - margin),
        max(0, int(top) - margin),
        min(width, int(right) + margin),
        min(height, int(bottom) + margin),
    )
    largest_area = int(largest["area"])
    kept: set[tuple[int, int]] = set()
    for component in components:
        area = int(component["area"])
        bounds = component["bounds"]  # type: ignore[assignment]
        intersects = bounds[0] < keep_bounds[2] and bounds[2] > keep_bounds[0] and bounds[1] < keep_bounds[3] and bounds[3] > keep_bounds[1]  # type: ignore[index]
        if intersects and area >= max(12, int(largest_area * 0.003)):
            kept.update(component["points"])  # type: ignore[arg-type]

    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 0 and (x, y) not in kept:
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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--padding", type=int, default=28)
    parser.add_argument("--margin", type=int, default=180)
    parser.add_argument("--max-size", type=int, default=320)
    args = parser.parse_args()

    image = Image.open(args.source)
    image = remove_border_background(image)
    image = keep_primary_cluster(image, args.margin)
    image = remove_pale_edge_residue(image)
    image = crop_alpha(image, args.padding)
    image = normalize(image, args.max_size)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output)
    print(f"saved {args.output} size={image.size}")


if __name__ == "__main__":
    main()
