# 素材来源记录

## 已引入

- Fusion Pixel Font
  - 来源：`/Users/meo/Desktop/momo 历险记/public/fonts/fusion-pixel/`
  - 原项目来源：https://github.com/TakWolf/fusion-pixel-font
  - 许可证：SIL Open Font License 1.1
  - 本项目路径：`assets/fonts/fusion-pixel/`
  - 用途：中文/英文像素字体。
  - 说明：Godot 不加载 Web 用 `.woff2`，本项目另下载同版本 `2026.05.07` 的 `.otf` 包供 Godot 使用。

## 当前策略

- 主要游戏素材优先由 Codex 内置 `image` / `image2` 生成，确保统一风格。
- 不再通过 `codex-image` CLI 生成本项目素材，除非用户之后明确恢复这条流程。
- 伙伴、角色、道具和 UI 正式素材不得用程序化大像素占位替代；缺素材时先保留路径，等 image/image2 输出后接入。
- 当前和后续所有道具、材料、装备、奖励、收藏和伙伴都必须有对应图片素材；详情弹窗必须展示图片、描述和可用操作。
- 开源素材只接受成套素材包，不使用缺东少西的零散素材作为主视觉。
- 每个正式采用的素材都要记录来源、许可、用途和路径。

## 已生成素材

- Moon Forest Camp first asset sheet
  - 来源：Codex 内置 image 生成，按项目提示词生成。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e49cc-6b8e-7ba0-bf35-6c37b797a704/ig_01676ac8efad0421016a0ff0ebc1808196a865b19df4aa5d45.png`
  - 项目路径：`assets/generated/moon-camp-asset-sheet.png`
  - 透明化版本：`assets/generated/moon-camp-asset-sheet-alpha.png`
  - 裁切目录：`assets/generated/crops/`
  - 处理脚本：`tools/extract_asset_sheet.py`
  - 用途：首批主角、怪物、金币、材料、UI kit 候选素材。
  - 备注：首批图不是原生透明 PNG，而是假棋盘格背景，并带过浅色边缘残留；当前已用脚本转透明并去除浅色 fringe，后续新素材优先直接要求真实透明背景，失败时再用纯色底转透明。`hero_attack.png` 已扩大裁切框，避免攻击剑光被截断。
  - QA：`tools/qa_asset_edges.py` 用于检查透明边缘白点/浅色残留和纯绿/品红 chroma 残留，接入前必须通过。攻击动作包含奶白色剑光，脚本对 `hero_attack.png` 使用单独阈值，仍需配合深色背景和 390x844 截图人工检查。

- Moon Forest Camp vertical background
  - 来源：Codex 内置 image 生成，按项目提示词生成。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e49cc-6b8e-7ba0-bf35-6c37b797a704/ig_03678dada5cff386016a0ff9f788808191af55c5fdd59317be.png`
  - 项目路径：`assets/generated/moon-camp-background.png`
  - 用途：当前主界面竖屏森林营地背景。

- Current item / equipment / collectible icon set
  - 来源：Codex 内置 image 生成；当前正式版本优先采用单物品纯色 chroma-key 原图，已通过 `tools/extract_image_assets.py` 转成真透明、保留主体、清理边缘并做游戏尺寸归一。旧 sheet fallback 只在没有单物品源时使用，不再覆盖已接入的新图。
  - 项目路径：`assets/generated/items/`
  - 清单：金币、营地材料、苔影露珠、月光孢子、暖木碎片、小鱼干、月露结晶、月泉钥匙、苔月露核、5 把武器、5 个护符、来福圣遗物铃铛、nico 爱喝的小猫饮水机。
  - QA：`tools/qa_asset_edges.py` 已通过；详情弹窗截图已确认掉落物、武器、护符、收藏和签到奖励会显示图片。

- Moss-Moon boss and drop
  - 来源：Codex 内置 image 生成，单主体假棋盘格背景原图，再转真透明。
  - Boss 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_094a9594b175c3ff016a140e39144c81949f9d128cf8aa62e4.png`
  - Boss 项目路径：`assets/generated/bosses/boss_moss_moon_slime.png`
  - 掉落原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_094a9594b175c3ff016a140fe652bc81948d742dd21a52bd42.png`
  - 掉落项目路径：`assets/generated/items/item_moss_moon_core.png`
  - 处理脚本：`tools/process_single_generated_sprite.py`
  - 用途：第 10 区月泉试炼 Boss“苔月巨史莱姆”和专属掉落“苔月露核”。
  - QA：`tools/qa_asset_edges.py` 已通过；已在深海军蓝背景预览和 390x844 Godot 截图中检查移动端可读性。

- Companion sprite set
  - 来源：Codex 内置 image 生成，每个伙伴单独生成纯色 chroma-key 原图，再由 `tools/extract_image_assets.py` 转成真透明 PNG。
  - 输出目录：`assets/generated/companions/`
  - 清单：
    - `companion_nico.png`：nico，北美赤狐。
    - `companion_xiaomi_cat.png`：小咪猫，奶牛猫。
    - `companion_little_xiaomi_cat.png`：小小咪猫，狸花猫。
    - `companion_zizi.png`：姊姊，纯白蜜袋鼯。
    - `companion_meimei.png`：妹妹，普通杂色蜜袋鼯。
    - `companion_tutu.png`：图图，棕色兔子。
    - `companion_dudu.png`：嘟嘟，棕色兔子。
  - QA：`tools/qa_asset_edges.py` 已通过；伙伴详情 smoke 已覆盖所有 7 个伙伴图片。

- Attack slash VFX
  - 来源：Codex 内置 image 生成单张剑光特效，纯绿色 chroma-key 原图转真透明 PNG。
  - 项目路径：`assets/generated/vfx/fx_attack_slash.png`
  - 用途：手动攻击时绘制完整剑光贴图，替代原先临时线条为主的效果；绘制区域已扩大，避免剑光视觉上被裁掉。
  - QA：`tools/qa_asset_edges.py` 已通过；Godot smoke 覆盖特效贴图加载和扩大后的攻击闪光区域。

- Linear battle area map
  - 来源：Codex 内置 image 生成，横向 16-bit 月森线性地图，无文字、无角色，用作战斗页挂机区域选择底图。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0fc95e61857e708b016a141d1b24288190a2576f2999c9cba8.png`
  - 项目路径：`assets/generated/ui/battle_area_map.png`
  - 用途：战斗页怪物血条下方的线性挂机地图，叠加 5 个代码绘制的区域节点和当前掉落提示。
  - QA：已在 Godot 390x844 战斗截图中检查移动端可读性；该图不是透明抠图，不进入透明边缘 QA。

- Second Moon Spring boss set
  - 来源：Codex 内置 image 生成，原图为 3 个单体素材的横向表；生成器未输出真 alpha，因此只保留原图，项目内用专用脚本转成真透明 PNG。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0a13abd370e71d77016a15017a40248196bc04b9d12334a861.png`
  - 项目路径：`assets/generated/bosses/boss_second_moon_warden.png`、`assets/generated/items/item_second_moon_tear.png`、`assets/generated/vfx/fx_moon_spring_slash.png`
  - 处理脚本：`tools/process_second_moon_assets.py`
  - 用途：第 20 区 Boss“第二月泉守望者”、专属掉落“第二月泪”和 Boss 月泉剑光特效。
  - QA：`tools/qa_asset_edges.py` 已通过；脚本会移除白底、清理淡色边缘，并把靠透明边缘的纯白高光压到项目调色板的奶油月光/淡紫色。Boss 外沿月晶属于有意高光，使用单独 QA 阈值并已做深海军蓝背景预览。

- Chapter 1 completion crest
  - 来源：Codex 内置 image/image2 生成，单主体章节徽章图标；生成器输出为白底图，因此保留原图并转真透明。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0296eb97826c2188016a1512a560f081958517266e0c5a0b80.png`
  - 项目路径：`assets/generated/items/item_chapter1_crest.png`
  - 处理脚本：`tools/process_chapter_assets.py`
  - 用途：第一章 · 月森营地章节结算目标、章节称号和章节奖励详情弹窗。
  - QA：`tools/qa_asset_edges.py` 已通过；已在 390x844 章节详情弹窗中检查移动端可读性。

- Moonlit UI kit
  - 来源：Codex 内置 image/image2 生成，单张 UI 套件图，使用绿色色键背景后本地清理。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0696072409e942de016a151c08c0e08195ad7c2927928a8d3d.png`
  - 项目路径：`assets/generated/ui/ui_modal_panel.png`、`assets/generated/ui/ui_hud_panel.png`、`assets/generated/ui/ui_button_primary.png`、`assets/generated/ui/ui_button_secondary.png`、`assets/generated/ui/ui_tab_selected.png`、`assets/generated/ui/ui_tab_idle.png`、`assets/generated/ui/ui_progress_xp.png`、`assets/generated/ui/ui_progress_hp.png`、`assets/generated/ui/ui_section_card.png`
  - 处理脚本：`tools/process_ui_kit.py`
  - 用途：顶部/底部 HUD 面板、详情弹窗框、内容分区卡、主按钮/次按钮、页签和进度条底框。
  - QA：`tools/qa_asset_edges.py` 已纳入 `assets/generated/ui`；绿色色键残留和白边均为 0，并已做 390x844 截图验收。

- Quiet Moon Petal
  - 来源：Codex 内置 image/image2 生成，单主体后段材料图标；生成器使用绿色色键背景，项目内转真透明。
  - 原始默认保存位置：`/Users/meo/.codex/generated_images/019e5cb2-e00f-7311-bfbb-448041d4346b/ig_0696072409e942de016a152370dec081958f50ac59e7363a4c.png`
  - 项目路径：`assets/generated/items/item_quiet_moon_petal.png`
  - 处理脚本：`tools/process_quiet_moon_assets.py`
  - 用途：第 24 区“静月坡”挂机掉落、静月坡巡礼门票/奖励、月泉觉醒 Lv.2+ 消耗、第一章静月尾声章节目标。
  - QA：`tools/qa_asset_edges.py` 已通过；图标在深色背景下预览无明显绿色残留。
