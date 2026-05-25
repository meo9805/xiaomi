#!/usr/bin/env python3
"""Check generated transparent sprites for pale edge residue."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ASSET_DIRS = [
    ROOT / "assets/generated/crops",
    ROOT / "assets/generated/companions",
    ROOT / "assets/generated/items",
    ROOT / "assets/generated/bosses",
    ROOT / "assets/generated/vfx",
]
MAX_SUSPICIOUS_WHITE_EDGE_PIXELS = 50
MAX_SUSPICIOUS_CHROMA_EDGE_PIXELS = 12
ASSET_EDGE_LIMITS = {
    # The attack sprite has a cream moonlit sword arc that legitimately touches
    # transparency; keep it checked, but allow more bright edge pixels.
    "hero_attack.png": 80,
}


def is_chroma_residue(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return False
    if g >= 170 and r <= 90 and b <= 90:
        return True
    return r >= 170 and b >= 170 and g <= 90


def suspicious_white_edge_pixels(path: Path) -> int:
    image = Image.open(path).convert("RGBA")
    pixels = image.load()
    width, height = image.size
    count = 0

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if r <= 210 or g <= 210 or b <= 210:
                continue
            if max(r, g, b) - min(r, g, b) >= 25:
                continue
            if touches_transparency(pixels, width, height, x, y):
                count += 1

    return count


def suspicious_chroma_edge_pixels(path: Path) -> int:
    image = Image.open(path).convert("RGBA")
    pixels = image.load()
    width, height = image.size
    count = 0

    for y in range(height):
        for x in range(width):
            if not is_chroma_residue(pixels[x, y]):
                continue
            if touches_transparency(pixels, width, height, x, y):
                count += 1

    return count


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


def main() -> None:
    failures: list[str] = []
    paths: list[Path] = []
    for asset_dir in ASSET_DIRS:
        if asset_dir.exists():
            paths.extend(sorted(asset_dir.glob("*.png")))

    for path in paths:
        count = suspicious_white_edge_pixels(path)
        chroma_count = suspicious_chroma_edge_pixels(path)
        print(f"{path.relative_to(ROOT)}: suspicious_white_edge={count} suspicious_chroma_edge={chroma_count}")
        limit = ASSET_EDGE_LIMITS.get(path.name, MAX_SUSPICIOUS_WHITE_EDGE_PIXELS)
        if count > limit:
            failures.append(f"{path.name}: white {count}")
        if chroma_count > MAX_SUSPICIOUS_CHROMA_EDGE_PIXELS:
            failures.append(f"{path.name}: chroma {chroma_count}")

    if failures:
        joined = ", ".join(failures)
        raise SystemExit(f"Asset edge QA failed: {joined}")


if __name__ == "__main__":
    main()
