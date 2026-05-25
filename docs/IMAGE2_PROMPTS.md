# image2 素材提示词

这些提示词用于 Codex 内置 image/image2 流程。生成后的素材放入 `assets/generated/`，确认可用后再移动到正式素材目录。

角色、怪物、道具和 UI 小件可以先要求“真实透明背景 PNG”，但当前 Codex 内置 image 结果不保证真的带 alpha。如果生成结果出现假棋盘格、浅色底、白色 halo、灰色 fringe 或边缘脏点，正式接入时改用单个主体 + 统一纯色 chroma-key 背景，再用 `tools/extract_image_assets.py` 转真透明，并跑 `tools/qa_asset_edges.py` 检查白边和 chroma 残留。

## 统一风格

```text
Cozy 16-bit pixel art for a vertical mobile idle RPG, inspired by warm farming RPG UI but fully original. Crisp square pixel edges, no blur, no anti-aliasing, no painterly texture, no vector look, no 3D. Deep navy night, lavender purple shadows, cream moonlight, soft pink highlights, warm peach accents, orange primary action color, moss green and earthy brown. Cute but natural, readable at small mobile size, handcrafted pixel UI, black hard pixel borders, no rounded modern UI, no text, no labels, no logos, no watermark.
```

## Background: Moon Camp

<!-- background-prompt-start -->
Create a vertical mobile game background for an original cozy pixel idle RPG called Moon Forest Camp.

Use this style: Cozy 16-bit pixel art for a vertical mobile idle RPG, inspired by warm farming RPG UI but fully original. Crisp square pixel edges, no blur, no anti-aliasing, no painterly texture, no vector look, no 3D. Deep navy night, lavender purple shadows, cream moonlight, soft pink highlights, warm peach accents, orange primary action color, moss green and earthy brown. Cute but natural, readable at small mobile size, handcrafted pixel UI, black hard pixel borders, no rounded modern UI, no text, no labels, no logos, no watermark.

Composition:
- portrait mobile game background, 390:844 safe layout feeling
- moonlit forest camp at night
- top area has low-contrast deep navy sky and distant pink-lavender treetops for HUD readability
- middle has a clean open clearing for one hero and one small monster
- bottom can show warm camp details near edges but must stay calm behind a UI panel
- include tiny mushrooms, grass tufts, small fence pieces, lantern glow, square pixel stars
- leave center readable and not cluttered
- no characters, no UI panels, no text

Negative prompt: blurry, smooth gradients, anti-aliased edges, photorealistic, semi-realistic painting, watercolor, anime mascot, chibi toy, 3D render, vector icon, sticker style, thick cartoon outline, readable text, labels, logo, watermark, busy full scene.
<!-- background-prompt-end -->

## Sprite Sheet: First Creatures

<!-- creature-prompt-start -->
Create a clean sprite sheet of isolated game creatures as a true transparent-background PNG. If transparent output is not supported, use a perfectly flat solid #00ff00 chroma-key background for background removal.

If using chroma-key, do not use #00ff00 anywhere in the sprites. The background must be one uniform color with no shadows, gradients, texture, floor, reflection, or lighting variation.

Use this style: Cozy 16-bit pixel art for a vertical mobile idle RPG, inspired by warm farming RPG UI but fully original. Crisp square pixel edges, no blur, no anti-aliasing, no painterly texture, no vector look, no 3D. Deep navy night, lavender purple shadows, cream moonlight, soft pink highlights, warm peach accents, orange primary action color, moss green and earthy brown. Cute but natural, readable at small mobile size, black hard pixel outline, no white halo, no grey fringe, no sticker border, no text, no labels, no logos, no watermark.

Sprites needed, arranged in a neat grid with generous #00ff00 padding:
1. small moon camp hero, simple adventurer, navy cloak, warm cream scarf, tiny sword, 3/4 top-down idle pose
2. moss slime, round but natural, moss green, tiny cream eyes, idle pose
3. night mushroom monster, pink-brown cap, small feet, gentle but enemy-like
4. root sprout monster, earthy brown root body, lavender shadow
5. coin pile icon, warm gold pixels
6. material shard icon, cream and lavender moonstone

Each character sprite should feel around 64x64 to 96x96. Icons around 32x32 to 48x48. Keep every sprite separated for cropping.

Negative prompt: blurry, smooth gradients, anti-aliased edges, photorealistic, semi-realistic painting, watercolor, anime mascot, chibi toy, oversized glossy eyes, plush toy, sticker style, thick cartoon outline, messy background, floor, UI, text, labels, watermark, logo.
<!-- creature-prompt-end -->

## UI Kit

<!-- ui-prompt-start -->
Create an original pixel UI kit sheet for a vertical mobile idle RPG.

Use this style: Cozy 16-bit pixel art, crisp square pixel edges, no blur, no anti-aliasing, deep navy night, lavender purple shadows, cream moonlight, soft pink highlights, warm peach accents, orange primary action color, black hard pixel borders. It should feel like a warm handcrafted farming RPG UI, but fully original and not copied from any existing game.

Include separate UI components on a transparent or plain dark background:
- top HUD panel frame
- bottom dialog/status panel frame
- orange primary button, empty with no text
- muted blue-purple secondary button, empty with no text
- health bar frame and fill
- experience bar frame and orange-pink fill
- four small square tab icons: adventure, upgrade, bag, quest, no letters
- coin icon
- material shard icon
- tiny notification badge

No readable text, no letters, no numbers, no logos, no watermark. Keep components separated with padding for cropping.
<!-- ui-prompt-end -->

## Companion Sprites

Generate companion sprites with Codex built-in image/image2, not `codex-image` CLI. Prefer one isolated subject per image with a perfectly flat chroma-key background, then convert accepted sprites into `assets/generated/companions/`. Avoid broad sheets unless a later batching pass is intentionally designed and QA'd.

Current companion roster:

| ID | Display name | Real animal |
| --- | --- | --- |
| `nico` | nico | 北美赤狐 |
| `xiaomi` | 小咪猫 | 奶牛猫 |
| `little_xiaomi` | 小小咪猫 | 狸花猫 |
| `zizi` | 姊姊 | 纯白蜜袋鼯 |
| `meimei` | 妹妹 | 普通杂色蜜袋鼯 |
| `tutu` | 图图 | 棕色兔子 |
| `dudu` | 嘟嘟 | 棕色兔子 |

Prompt constraints:

```text
Single isolated companion sprite for a cozy 16-bit pixel idle RPG, small full-body animal companion, 3/4 top-down game sprite view, warm handcrafted pixel art, crisp dark outline, deep navy lavender cream moonlight soft pink warm peach moss green earthy brown palette, readable at 48px tall on mobile. Centered single subject with generous padding, no text, no UI, no sticker border, no fake checkerboard, no shadow baked into background, no anime mascot, no vector, no 3D, no watercolor, no photorealism. Background must be one perfectly flat chroma-key color, either #00FF00 or #FF00FF, chosen so it does not conflict with the subject.
```

Accepted companion assets must be true transparent PNGs after processing. Do not replace missing companion art with programmatic pixel blocks; if generation is blocked, keep the sprite absent until image/image2 output is available.

## Item And Equipment Icons

All item, material, equipment, reward, collectible, and partner entries need a corresponding asset. Prefer one isolated subject per generated image; if the tool returns a white or fake-transparent background, process it with `tools/extract_image_assets.py`, then run `tools/qa_asset_edges.py`.

```text
Create exactly one game item icon as a true RGBA transparent-background PNG. Single centered isolated object only, full object visible, generous transparent padding, no crop, no background, no checkerboard, no white canvas, no floor, no shadow outside the object, no text, no letters, no watermark. Style: cozy 16-bit pixel art for a vertical mobile idle RPG, crisp square pixel edges, dark pixel outline, deep navy shadow pixels, lavender and cream moonlight highlights, warm peach accents, readable at 48px on mobile. Negative: fake transparency checkerboard, white noise, white halo, grey fringe, cut off edges, multiple objects, sticker, vector, 3D, watercolor, photorealism, smooth anti-aliased illustration.
```

## Attack Slash Effect

Create a single isolated attack VFX sprite for the hero sword attack. Use chroma-key if alpha is unreliable.

```text
One isolated attack VFX sprite for a vertical mobile idle RPG, original moonlight sword slash effect, complete wide diagonal crescent arc sweeping lower-left to upper-right, cream moonlight main arc, lavender secondary sparks, warm peach-gold impact pixels, readable at small mobile size, centered with generous padding. Background must be one perfectly flat #00FF00 chroma-key color for transparency conversion. No character, no monster, no UI, no text, no letters, no fake checkerboard, no sticker border, no watermark, no cropped edges.
```
