#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path("/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0296eb97826c2188016a1512a560f081958517266e0c5a0b80.png")
OUT = ROOT / "assets/generated/items/item_chapter1_crest.png"


def is_background(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return True
    # Keep cream highlights on the crest; only remove border-connected white canvas.
    return r >= 238 and g >= 238 and b >= 235 and max(r, g, b) - min(r, g, b) <= 12


def flood_canvas_alpha(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()
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
        if not is_background(pixels[x, y]):
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.append((x + 1, y))
        queue.append((x - 1, y))
        queue.append((x, y + 1))
        queue.append((x, y - 1))

    return rgba


def crop_and_pad(img: Image.Image, canvas_size: int = 192, pad: int = 18) -> Image.Image:
    bbox = img.getbbox()
    if bbox is None:
        return Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    cropped = img.crop(bbox)
    max_side = max(cropped.size)
    scale = float(canvas_size - pad * 2) / float(max_side)
    new_size = (max(1, round(cropped.size[0] * scale)), max(1, round(cropped.size[1] * scale)))
    cropped = cropped.resize(new_size, Image.Resampling.NEAREST)
    out = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    out.alpha_composite(cropped, ((canvas_size - new_size[0]) // 2, (canvas_size - new_size[1]) // 2))
    return out


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"missing generated source: {SOURCE}")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    cleaned = flood_canvas_alpha(Image.open(SOURCE))
    crop_and_pad(cleaned).save(OUT)
    print(f"WROTE {OUT}")


if __name__ == "__main__":
    main()
