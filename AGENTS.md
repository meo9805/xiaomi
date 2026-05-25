# Project Rules: 星露谷

This project is a solo-friendly 2D pixel idle RPG experiment for iOS mobile.

## Product Direction

- Default target: iOS portrait mobile, 2D, cozy pixel art, idle RPG.
- Visual reference: warm, readable, handcrafted pixel UI in the spirit of Stardew Valley; do not copy Stardew Valley assets, names, UI, or copyrighted content.
- Gameplay scope should stay small: auto battle, experience growth, drops, upgrades, quests, offline rewards, simple inventory/status panels.
- Avoid full farming simulation, complex NPC relationship systems, large open-world exploration, multiplayer, or MMO-style scope unless explicitly requested later.

## Technical Direction

- Preferred engine: Godot 4, unless a future decision explicitly switches engines.
- Treat GDevelop as the faster no-code fallback if the project needs a clickable prototype with minimal programming.
- Use engine-native UI and scene systems before inventing custom frameworks.
- For iOS export discussions, remember that macOS and Xcode are part of the real release path.

## Asset Direction

- Prefer legal, trackable assets: generated assets, CC0 packs, or clearly licensed packs.
- Keep an asset source log before using third-party art in a shippable build.
- AI-generated assets should be isolated, cropped, transparent PNGs where possible, with consistent pixel scale and palette.
- Do not mix many unrelated pixel styles in the same screen without a deliberate normalization pass.
- Current user preference for all project art is Codex built-in `image` / `image2` generation. Do not use the `codex-image` CLI for this project unless the user explicitly asks for it again. Do not hand-draw programmatic placeholder sprites as final game assets.
- Treat the current visual target as one coherent set: cozy 16-bit pixel RPG, deep navy night, lavender shadows, cream moonlight, soft pink highlights, warm peach/orange accents, moss green and earthy brown. Avoid anime mascot, toy/chibi, sticker, vector, 3D, watercolor, photoreal, and smooth anti-aliased looks.
- For sprites, request one isolated subject per asset or a clean grid sheet with generous padding. Prefer true transparent PNG. If the image tool gives fake checkerboard transparency, pure white halos, grey fringe, or dirty cutout edges, do not accept it as final.
- For generated sprite sheets, run `tools/extract_asset_sheet.py` and then `tools/qa_asset_edges.py` before wiring assets into scenes. If QA flags pale edge residue, tune the cleanup script or regenerate with a stricter transparent/chroma-key prompt.
- Every current or future item, material, equipment piece, reward, collectible, and partner must have a corresponding accepted image asset before it is treated as a finished feature. Detail popups must show that asset alongside the name, type, description, effects, and available actions.
- For companion sprites, generate transparent PNGs through Codex built-in image/image2 output, then crop/import/QA them before wiring them into scenes. Do not replace them with code-drawn pixel blocks.
- Inspect sprites on a dark navy background and in an actual 390x844 Godot screenshot before calling the asset usable. Small mobile readability matters more than large preview detail.
- Keep generated characters, monsters, props, UI frames, icons, and fonts in the same palette and apparent pixel density. If a new asset looks sharper, blurrier, glossier, or more outlined than the rest, regenerate or normalize it before use.
- Record every accepted generated asset in `docs/ASSET_SOURCES.md`, including default generator path, project path, processing script, and any cleanup caveat.

## Collaboration Defaults

- The user is still exploring the game shape. Start with small playable loops and visible UI tests, not broad architecture.
- When implementing, keep story/data/config separated from gameplay logic.
- Use Chinese for planning notes and user-facing explanations.
- Before large changes, briefly state what will be created or modified.
- Verify real rendered/mobile-like behavior when practical, not only source files.
