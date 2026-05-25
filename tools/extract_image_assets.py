#!/usr/bin/env python3
"""Extract Codex built-in image sheets into transparent game assets."""

from __future__ import annotations

import json
import shutil
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
GENERATED_DIR = ROOT / "assets/generated"
IMAGE_SOURCE_ROOT = Path(
    "/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/"
)
COMPANION_SOURCE = IMAGE_SOURCE_ROOT / "ig_0957971add0e8f2d016a13b4330e0c81908c5e5d60ab9fd42a.png"
ITEM_SOURCE = Path(
    "/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/"
    "ig_0957971add0e8f2d016a13b4f6b0dc8190b4672e1cd8a2a2fd.png"
)

COMPANION_SHEET = GENERATED_DIR / "image-companion-vfx-sheet.png"
ITEM_SHEET = GENERATED_DIR / "image-item-icon-sheet.png"
COMPANION_DIR = GENERATED_DIR / "companions"
VFX_DIR = GENERATED_DIR / "vfx"
ITEM_DIR = GENERATED_DIR / "items"

SINGLE_ITEM_SOURCES = {
    "item_moss_dew": "ig_0957971add0e8f2d016a13b661128881908139997a0a8fb227.png",
    "item_moon_spore": "ig_0957971add0e8f2d016a13b6d716a48190af27f11ab6eb7e06.png",
    "item_warm_wood": "ig_0957971add0e8f2d016a13b6f498588190a829d0e0aeee4a48.png",
    "item_dried_fish": "ig_0957971add0e8f2d016a13b74a541c8190bb131038b7ca3a23.png",
    "item_moon_crystal": "ig_0957971add0e8f2d016a13b7bf58dc8190a76d025db3f52749.png",
    "item_moon_key": "ig_0957971add0e8f2d016a13b81726d48190b1d5cc58453ff0ff.png",
    "item_camp_materials": "ig_0957971add0e8f2d016a13b86a49c4819093b9e30e18ca9627.png",
    "icon_coins_large": "ig_0957971add0e8f2d016a13b8dd52408190a040f44978bd0e70.png",
    "weapon_wood_sword": "ig_0957971add0e8f2d016a13b92eb83c819083d6cf36e45e02b3.png",
    "weapon_moon_dagger": "ig_0957971add0e8f2d016a13b978ce30819090d0ad6551d63bda.png",
    "weapon_spore_saber": "ig_0957971add0e8f2d016a13b9c3384881908c9bebe5b517b6b1.png",
    "weapon_warmwood_longsword": "ig_0957971add0e8f2d016a13ba14eb4c8190b123cea96c7b7ec8.png",
}

CHROMA_ITEM_SOURCES = {
    "item_moss_dew": {
        "filename": "ig_0957971add0e8f2d016a13c6377674819091be84c68a9644df.png",
        "key": "magenta",
    },
    "item_moon_spore": {
        "filename": "ig_0957971add0e8f2d016a13c87d853881909f754a8d88db4c3b.png",
        "key": "green",
    },
    "item_warm_wood": {
        "filename": "ig_0957971add0e8f2d016a13c8d4e3ac81908ab2e004aa93ab30.png",
        "key": "magenta",
    },
    "item_dried_fish": {
        "filename": "ig_0957971add0e8f2d016a13c94cf1dc819081ce0b51e5ea19ef.png",
        "key": "magenta",
    },
    "item_moon_crystal": {
        "filename": "ig_0957971add0e8f2d016a13c99987008190a286c86879569147.png",
        "key": "green",
    },
    "item_moon_key": {
        "filename": "ig_0957971add0e8f2d016a13ce025adc819094c314dede598410.png",
        "key": "green",
    },
    "icon_coins_large": {
        "filename": "ig_0957971add0e8f2d016a13d2ce44d8819098455cc2ff0e90b5.png",
        "key": "green",
    },
    "item_camp_materials": {
        "filename": "ig_0957971add0e8f2d016a13d32299448190be8b04f76ba3a982.png",
        "key": "magenta",
    },
    "weapon_wood_sword": {
        "filename": "ig_0957971add0e8f2d016a13d42c2bf48190af40eacb313ecc2f.png",
        "key": "magenta",
    },
    "weapon_moon_dagger": {
        "filename": "ig_0957971add0e8f2d016a13d47ac9b481908dbfc830180d6d47.png",
        "key": "green",
    },
    "weapon_spore_saber": {
        "filename": "ig_0957971add0e8f2d016a13d4c59d708190981b7ab5119cde50.png",
        "key": "green",
    },
    "weapon_warmwood_longsword": {
        "filename": "ig_0957971add0e8f2d016a13d51b990c8190abf165ce4053a58f.png",
        "key": "green",
    },
    "weapon_moon_guardian_blade": {
        "filename": "ig_0957971add0e8f2d016a13d576206881908b7f91cccd66a611.png",
        "key": "green",
    },
    "talisman_old_copper": {
        "filename": "ig_0957971add0e8f2d016a13d69b3b188190b2c291a6d18704b9.png",
        "key": "green",
    },
    "talisman_mosslight": {
        "filename": "ig_0957971add0e8f2d016a13d6eae6908190864cdfcb140de973.png",
        "key": "magenta",
    },
    "talisman_moonspore": {
        "filename": "ig_0957971add0e8f2d016a13d73d10148190971dc52f228469fe.png",
        "key": "green",
    },
    "talisman_warmwood": {
        "filename": "ig_0957971add0e8f2d016a13d7a1a9188190bf6a17d68e652738.png",
        "key": "magenta",
    },
    "talisman_moonforest": {
        "filename": "ig_0957971add0e8f2d016a13d80378ac81908179cc87a03c7af8.png",
        "key": "green",
    },
    "collectible_laifu_bell": {
        "filename": "ig_0246d53896ce36b7016a13da73e248819686b44e5f54e9862d.png",
        "key": "magenta",
    },
    "collectible_nico_drinker": {
        "filename": "ig_0246d53896ce36b7016a13d9bab98c8196a7d6cbe92c8b06b4.png",
        "key": "magenta",
    },
}

CHROMA_COMPANION_SOURCES = {
    "companion_nico": {
        "filename": "ig_0246d53896ce36b7016a13dbc8b3808196913c58a2d3dd40c0.png",
        "key": "green",
    },
    "companion_xiaomi_cat": {
        "filename": "ig_0246d53896ce36b7016a13dc0b74608196b286721601da5584.png",
        "key": "magenta",
    },
    "companion_little_xiaomi_cat": {
        "filename": "ig_0246d53896ce36b7016a13dc458b38819692739c9a74ad5470.png",
        "key": "magenta",
    },
    "companion_zizi": {
        "filename": "ig_0246d53896ce36b7016a13dc80640c8196af0967ef79a859b8.png",
        "key": "magenta",
    },
    "companion_meimei": {
        "filename": "ig_0246d53896ce36b7016a13dd181a0081968d33bf6765bd11ca.png",
        "key": "green",
    },
    "companion_tutu": {
        "filename": "ig_0246d53896ce36b7016a13dd58135081968b21f72ec6e4fef6.png",
        "key": "magenta",
    },
    "companion_dudu": {
        "filename": "ig_0246d53896ce36b7016a13dd9907a08196ac8a9c234d75ba5c.png",
        "key": "green",
    },
}

CHROMA_VFX_SOURCES = {
    "fx_attack_slash": {
        "filename": "ig_0246d53896ce36b7016a13def4c0048196849a6faae194d46d.png",
        "key": "green",
    },
}


COMPANION_BOXES = {
    "companion_nico": (20, 95, 250, 395),
    "companion_xiaomi_cat": (300, 110, 570, 395),
    "companion_little_xiaomi_cat": (610, 108, 840, 398),
    "companion_zizi": (900, 130, 1135, 395),
    "companion_meimei": (1180, 130, 1390, 395),
    "companion_tutu": (1445, 90, 1645, 395),
    "companion_dudu": (1660, 88, 1860, 395),
}

VFX_BOXES = {
    "fx_attack_slash_1": (220, 505, 620, 815),
    "fx_attack_slash_2": (815, 420, 1225, 820),
    "fx_attack_slash_3": (1310, 520, 1665, 820),
}

ITEM_BOXES = {
    "item_moss_dew": (80, 80, 270, 295),
    "item_moon_spore": (330, 70, 520, 300),
    "item_warm_wood": (600, 70, 790, 300),
    "item_dried_fish": (810, 85, 1010, 290),
    "item_moon_crystal": (1060, 80, 1235, 295),
    "item_moon_key": (1325, 70, 1500, 300),
    "item_camp_materials": (70, 315, 285, 535),
    "icon_coins_large": (330, 315, 520, 520),
    "weapon_wood_sword": (600, 315, 780, 535),
    "weapon_moon_dagger": (830, 315, 1030, 535),
    "weapon_spore_saber": (1060, 315, 1240, 535),
    "weapon_warmwood_longsword": (1305, 315, 1505, 535),
    "weapon_moon_guardian_blade": (80, 560, 285, 785),
    "talisman_old_copper": (330, 560, 520, 785),
    "talisman_mosslight": (560, 560, 765, 785),
    "talisman_moonspore": (810, 560, 1030, 790),
    "talisman_warmwood": (1060, 560, 1240, 790),
    "talisman_moonforest": (1305, 560, 1510, 790),
    "collectible_laifu_bell": (540, 745, 760, 965),
    "collectible_nico_drinker": (820, 730, 1080, 970),
}

SHEET_ITEM_FALLBACKS = {
    "weapon_moon_guardian_blade": (40, 520, 325, 825),
    "talisman_old_copper": (300, 530, 550, 810),
    "talisman_mosslight": (520, 515, 780, 720),
    "talisman_moonspore": (755, 515, 1015, 720),
    "talisman_warmwood": (1035, 530, 1265, 825),
    "talisman_moonforest": (1245, 515, 1535, 720),
    "collectible_laifu_bell": (500, 710, 790, 990),
    "collectible_nico_drinker": (790, 740, 1115, 1000),
}


def is_checker_pixel(pixel: tuple[int, int, int, int]) -> bool:
    r, g, b, _a = pixel
    return r >= 225 and g >= 225 and b >= 225 and max(r, g, b) - min(r, g, b) <= 4


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


def remove_white_background(image: Image.Image) -> Image.Image:
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
        r, g, b, a = pixels[x, y]
        if a == 0:
            continue
        if r < 236 or g < 236 or b < 236:
            continue
        if max(r, g, b) - min(r, g, b) > 18:
            continue
        pixels[x, y] = (255, 255, 255, 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    return rgba


def remove_chroma_key(image: Image.Image, key: str) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue
            if key == "magenta" and ((r > 190 and b > 170 and g < 110) or (r > 95 and b > 95 and g < 45)):
                pixels[x, y] = (255, 0, 255, 0)
            elif key == "green" and ((g > 190 and r < 130 and b < 130) or (g > 150 and g > r + 45 and g > b + 45)):
                pixels[x, y] = (255, 0, 255, 0)
    return rgba


def touches_transparency(
    pixels: Image.Image.ImagePointHandler,
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


def is_pale_residue(pixel: tuple[int, int, int, int], pass_index: int) -> bool:
    r, g, b, a = pixel
    if a == 0:
        return False
    spread = max(r, g, b) - min(r, g, b)
    average = (r + g + b) / 3
    if pass_index == 0:
        return average >= 235 and spread <= 42
    if pass_index == 1:
        return average >= 225 and spread <= 34
    return average >= 214 and spread <= 24


def remove_pale_edge_residue(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    for pass_index in range(3):
        pixels = rgba.load()
        width, height = rgba.size
        to_clear: list[tuple[int, int]] = []
        for y in range(height):
            for x in range(width):
                if is_pale_residue(pixels[x, y], pass_index) and touches_transparency(pixels, width, height, x, y):
                    to_clear.append((x, y))
        if not to_clear:
            break
        for x, y in to_clear:
            pixels[x, y] = (255, 255, 255, 0)
    return rgba


def alpha_bbox(image: Image.Image, padding: int = 6) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        return (0, 0, image.width, image.height)
    left, top, right, bottom = bbox
    return (
        max(0, left - padding),
        max(0, top - padding),
        min(image.width, right + padding),
        min(image.height, bottom + padding),
    )


def _component_bounds(points: list[tuple[int, int]]) -> tuple[int, int, int, int]:
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return (min(xs), min(ys), max(xs) + 1, max(ys) + 1)


def _intersects(a: tuple[int, int, int, int], b: tuple[int, int, int, int]) -> bool:
    return a[0] < b[2] and a[2] > b[0] and a[1] < b[3] and a[3] > b[1]


def keep_primary_cluster(image: Image.Image, margin: int = 80) -> Image.Image:
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
            components.append({
                "points": points,
                "area": len(points),
                "bounds": _component_bounds(points),
            })

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

    kept: set[tuple[int, int]] = set()
    largest_area = int(largest["area"])
    for component in components:
        area = int(component["area"])
        bounds = component["bounds"]  # type: ignore[assignment]
        if area >= max(12, int(largest_area * 0.004)) and _intersects(bounds, keep_bounds):  # type: ignore[arg-type]
            kept.update(component["points"])  # type: ignore[arg-type]

    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] > 0 and (x, y) not in kept:
                pixels[x, y] = (255, 255, 255, 0)

    return rgba


def trim_crop(sheet: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    crop = sheet.crop(box)
    crop = keep_primary_cluster(crop)
    return crop.crop(alpha_bbox(crop))


def normalize_game_icon(image: Image.Image, max_size: int = 256) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    if width <= max_size and height <= max_size:
        return rgba
    scale = min(max_size / width, max_size / height)
    size = (max(1, int(width * scale)), max(1, int(height * scale)))
    return rgba.resize(size, Image.Resampling.NEAREST)


def extract(sheet: Image.Image, boxes: dict[str, tuple[int, int, int, int]], out_dir: Path) -> dict[str, dict[str, object]]:
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, dict[str, object]] = {}
    for name, box in boxes.items():
        crop = trim_crop(sheet, box)
        out_path = out_dir / f"{name}.png"
        crop.save(out_path)
        manifest[name] = {
            "path": str(out_path.relative_to(ROOT)),
            "size": list(crop.size),
        }
    return manifest


def extract_single_items() -> dict[str, dict[str, object]]:
    ITEM_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, dict[str, object]] = {}
    source_root = IMAGE_SOURCE_ROOT
    for name, filename in SINGLE_ITEM_SOURCES.items():
        source = source_root / filename
        image = remove_white_background(Image.open(source))
        image = remove_pale_edge_residue(image)
        image = keep_primary_cluster(image, margin=180)
        image = image.crop(alpha_bbox(image, padding=26))
        image = normalize_game_icon(image)
        out_path = ITEM_DIR / f"{name}.png"
        image.save(out_path)
        manifest[name] = {
            "source": str(source),
            "path": str(out_path.relative_to(ROOT)),
            "size": list(image.size),
        }
    for name, config in CHROMA_ITEM_SOURCES.items():
        source = source_root / str(config["filename"])
        image = remove_chroma_key(Image.open(source), str(config["key"]))
        image = keep_primary_cluster(image, margin=180)
        image = image.crop(alpha_bbox(image, padding=26))
        image = normalize_game_icon(image)
        out_path = ITEM_DIR / f"{name}.png"
        image.save(out_path)
        manifest[name] = {
            "source": str(source),
            "path": str(out_path.relative_to(ROOT)),
            "size": list(image.size),
        }
    fallback_names = [name for name in SHEET_ITEM_FALLBACKS if name not in manifest]
    if ITEM_SOURCE.exists() and fallback_names:
        sheet = remove_border_checkerboard(Image.open(ITEM_SOURCE))
        for name in fallback_names:
            box = SHEET_ITEM_FALLBACKS[name]
            image = sheet.crop(box)
            image = keep_primary_cluster(image, margin=70)
            image = remove_pale_edge_residue(image)
            image = image.crop(alpha_bbox(image, padding=22))
            image = normalize_game_icon(image)
            out_path = ITEM_DIR / f"{name}.png"
            image.save(out_path)
            manifest[name] = {
                "source": str(ITEM_SOURCE),
                "path": str(out_path.relative_to(ROOT)),
                "size": list(image.size),
            }
    return manifest


def extract_single_companions() -> dict[str, dict[str, object]]:
    COMPANION_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, dict[str, object]] = {}
    source_root = IMAGE_SOURCE_ROOT
    for name, config in CHROMA_COMPANION_SOURCES.items():
        source = source_root / str(config["filename"])
        image = remove_chroma_key(Image.open(source), str(config["key"]))
        image = keep_primary_cluster(image, margin=200)
        image = image.crop(alpha_bbox(image, padding=30))
        image = normalize_game_icon(image, max_size=256)
        out_path = COMPANION_DIR / f"{name}.png"
        image.save(out_path)
        manifest[name] = {
            "source": str(source),
            "path": str(out_path.relative_to(ROOT)),
            "size": list(image.size),
        }
    return manifest


def extract_single_vfx() -> dict[str, dict[str, object]]:
    VFX_DIR.mkdir(parents=True, exist_ok=True)
    manifest: dict[str, dict[str, object]] = {}
    source_root = IMAGE_SOURCE_ROOT
    for name, config in CHROMA_VFX_SOURCES.items():
        source = source_root / str(config["filename"])
        image = remove_chroma_key(Image.open(source), str(config["key"]))
        image = keep_primary_cluster(image, margin=260)
        image = image.crop(alpha_bbox(image, padding=34))
        image = normalize_game_icon(image, max_size=384)
        out_path = VFX_DIR / f"{name}.png"
        image.save(out_path)
        manifest[name] = {
            "source": str(source),
            "path": str(out_path.relative_to(ROOT)),
            "size": list(image.size),
        }
    return manifest


def main() -> None:
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    needs_item_sheet = bool(set(SHEET_ITEM_FALLBACKS.keys()) - set(SINGLE_ITEM_SOURCES.keys()) - set(CHROMA_ITEM_SOURCES.keys()))
    if ITEM_SOURCE.exists() and needs_item_sheet:
        shutil.copy2(ITEM_SOURCE, ITEM_SHEET)

    if ITEM_SOURCE.exists() and needs_item_sheet:
        item_sheet = remove_border_checkerboard(Image.open(ITEM_SHEET))
        item_sheet.save(GENERATED_DIR / "image-item-icon-sheet-alpha.png")

    manifest = {
        "sources": {
            "generated_image_dir": str(IMAGE_SOURCE_ROOT),
            "item_icon_sheet": str(ITEM_SHEET.relative_to(ROOT)) if ITEM_SOURCE.exists() and needs_item_sheet else "",
        },
        "companions": extract_single_companions(),
        "vfx": extract_single_vfx(),
        "items": extract_single_items(),
    }
    (GENERATED_DIR / "image-assets-manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
