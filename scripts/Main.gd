extends Control

const SAVE_PATH := "user://idle_rpg_save.json"
const VIEWPORT_SIZE := Vector2(390, 844)
const PIXEL_FONT_PATH := "res://assets/fonts/fusion-pixel/fusion-pixel-12px-proportional-zh_hans.otf"
const DATA := preload("res://scripts/GameData.gd")
const GAME_TITLE := "小咪变成人啦！大冒险"
const ATTACK_SLASH_DURATION := 0.34
const FLOATING_DAMAGE_DURATION := 0.55
const DETAIL_TITLE_CHARS_PER_LINE := 28
const DETAIL_SUBTITLE_CHARS_PER_LINE := 30
const CONTENT_TEXT_CHARS_PER_LINE := 31

var level := 1
var xp := 0
var gold := 0
var materials := 0
var stage := 1
var defeated := 0
var claimed_quests := 0
var training_rank := 0
var camp_rank := 0
var weapon_rank := 0
var talisman_rank := 0
var weapon_awaken_rank := 0
var talisman_awaken_rank := 0
var equipped_weapon_rank := 0
var equipped_talisman_rank := 0
var companion_id := "xiaomi"
var companion_level := 1
var companion_bond := 0
var companion_bond_progress := 0
var companion_feed_count := 0
var companion_states: Dictionary = {}
var loaded_companion_states := false
var daily_claimed_date := ""
var daily_cycle_day := 0
var daily_claim_count := 0
var daily_task_date := ""
var daily_task_progress: Dictionary = {}
var daily_task_claimed: Dictionary = {}
var chapter_claimed: Dictionary = {}
var dungeon_attempts_date := ""
var dungeon_attempts: Dictionary = {}
var dungeon_clears: Dictionary = {}
var inventory: Dictionary = {}
var equipment_inventory: Dictionary = {}
var loaded_equipment_inventory := false
var equipped_title_id := "camp_adventurer"
var boss_active := false
var active_boss_id := ""
var active_boss_dungeon_id := ""
var active_boss_saved_hp := 0
var active_boss_timer := 0.0
var active_boss_duration := 0.0
var boss_intro_timer := 0.0
var boss_resonance_timer := 0.0

var enemy: Dictionary = {}
var enemy_hp := 1
var enemy_max_hp := 1

var auto_attack_clock := 0.0
var passive_income_clock := 0.0
var attack_pose_timer := 0.0
var hit_flash_timer := 0.0
var slash_timer := 0.0
var floating_damage_timer := 0.0
var dungeon_feedback_timer := 0.0
var dungeon_feedback_duration := 0.0
var dungeon_feedback_title := ""
var dungeon_feedback_body := ""
var dungeon_feedback_color := Color("#ffd4a3")
var last_damage := 0
var visual_time := 0.0
var selected_tab := "battle"
var selected_area_id := "camp_clearing"
var hovered_area_id := ""
var inventory_section := "equipment"
var companion_section := "companions"
var content_dirty := true
var last_rendered_tab := ""
var pending_offline_message := ""
var sprite_textures: Dictionary = {}
var background_texture: Texture2D
var reward_popups: Array[Dictionary] = []
var save_enabled := true
var dungeon_run_anim_timer := 0.0
var dungeon_run_anim_duration := 0.0
var dungeon_run_anim_title := ""
var dungeon_run_anim_success := true

var enemy_name_label: Label
var enemy_hp_bar: ProgressBar
var xp_bar: ProgressBar
var hero_label: Label
var gold_value_label: Label
var material_value_label: Label
var training_value_label: Label
var camp_value_label: Label
var weapon_value_label: Label
var stage_value_label: Label
var scene_spacer: Control
var secondary_nav_row: HBoxContainer
var secondary_nav_signature := ""
var content_scroll: ScrollContainer
var content_stack: VBoxContainer
var log_label: Label
var attack_button: Button
var quest_claim_button: Button
var upgrade_button: Button
var camp_button: Button
var weapon_button: Button
var talisman_button: Button
var save_button: Button
var action_row: HBoxContainer
var upgrade_row: HBoxContainer
var tab_buttons: Dictionary = {}
var tab_button_labels: Dictionary = {}
var recent_logs: Array[String] = []
var detail_overlay: ColorRect
var detail_title_label: Label
var detail_type_label: Label
var detail_image_rect: TextureRect
var detail_body_scroll: ScrollContainer
var detail_description_label: Label
var detail_effect_label: Label
var detail_extra_container: VBoxContainer
var detail_primary_button: Button
var detail_secondary_button: Button
var detail_close_button: Button
var active_detail: Dictionary = {}

func _ready() -> void:
	randomize()
	DisplayServer.window_set_title(GAME_TITLE)
	_apply_debug_args()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_load_sprite_textures()
	_load_game()
	selected_tab = _normalize_tab(selected_tab)
	_ensure_companion_states()
	if not _is_companion_unlocked(companion_id):
		companion_id = "xiaomi"
	_sanitize_selected_area()
	_ensure_equipment_inventory()
	if boss_active:
		_restore_boss_enemy()
	else:
		_spawn_enemy()
	_apply_project_theme()
	_build_ui()
	if pending_offline_message != "":
		_add_log(pending_offline_message)
	else:
		_add_log("营火重新点亮，冒险自动开始。")
	_add_log("小咪检查了一下背包，确认亮晶晶都还在。")
	_update_ui()

func _apply_debug_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	for arg in args:
		var text := str(arg)
		if text.begins_with("--debug-tab="):
			selected_tab = _normalize_tab(text.get_slice("=", 1))

func _process(delta: float) -> void:
	visual_time += delta
	auto_attack_clock += delta
	passive_income_clock += delta
	attack_pose_timer = maxf(0.0, attack_pose_timer - delta)
	hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
	slash_timer = maxf(0.0, slash_timer - delta)
	floating_damage_timer = maxf(0.0, floating_damage_timer - delta)
	dungeon_feedback_timer = maxf(0.0, dungeon_feedback_timer - delta)
	dungeon_run_anim_timer = maxf(0.0, dungeon_run_anim_timer - delta)
	boss_intro_timer = maxf(0.0, boss_intro_timer - delta)
	boss_resonance_timer = maxf(0.0, boss_resonance_timer - delta)
	for i in range(reward_popups.size() - 1, -1, -1):
		var popup := reward_popups[i]
		popup["age"] = float(popup["age"]) + delta
		if float(popup["age"]) >= float(popup["duration"]):
			reward_popups.remove_at(i)
		else:
			reward_popups[i] = popup

	if auto_attack_clock >= DATA.attack_interval(training_rank):
		auto_attack_clock = 0.0
		_deal_damage(false)

	if passive_income_clock >= 8.0:
		passive_income_clock = 0.0
		var patrol_gold := maxi(1, int(stage * 0.5) + camp_rank + talisman_rank + DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank) + _camp_patrol_bonus() + _companion_patrol_bonus())
		gold += patrol_gold
		_push_reward_popup("+%dG 巡逻" % patrol_gold, Vector2(size.x * 0.50, size.y * 0.42), Color("#ffd4a3"))
		_update_ui()
		_save_game(false)

	if boss_active:
		active_boss_timer = maxf(0.0, active_boss_timer - delta)
		if active_boss_timer <= 0.0:
			_fail_boss_encounter()
			return

	_update_battle_hover()
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if selected_tab != "battle" or detail_overlay == null or detail_overlay.visible:
		return
	var click_pos := Vector2.INF
	var pressed := false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		pressed = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
		click_pos = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		pressed = touch_event.pressed
		click_pos = touch_event.position
	if not pressed:
		return
	if _battle_companion_rect().has_point(click_pos):
		_open_detail(_companion_selector_detail())
		accept_event()
		return
	var area_id := _battle_area_at_position(click_pos)
	if area_id != "":
		_select_battle_area(area_id)
		accept_event()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game(false)

func _draw() -> void:
	var w := size.x
	var h := size.y
	var scene_h := h * 0.58

	if background_texture != null:
		_draw_background_cover(background_texture, Rect2(0, 0, w, h))
		draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.05, 0.12, 0.22))
	else:
		draw_rect(Rect2(0, 0, w, h), Color("#0d1328"))
		draw_rect(Rect2(0, 0, w, scene_h), Color("#101935"))
		draw_rect(Rect2(0, scene_h * 0.62, w, scene_h * 0.38), Color("#223a2a"))
		draw_rect(Rect2(0, scene_h * 0.78, w, scene_h * 0.22), Color("#3f4d2f"))
		_draw_moon(Vector2(w - 74, 74), 8)
		_draw_stars(w, scene_h)
		_draw_tree_line(w, scene_h)

	var hero_pos := Vector2(w * 0.34, scene_h - 86)
	var enemy_pos := Vector2(w * 0.66, scene_h - 80)
	_draw_active_companion(_battle_companion_bottom_center())
	_draw_hero(hero_pos)
	_draw_boss_presence(enemy_pos)
	_draw_enemy(enemy_pos)
	_draw_attack_flash(hero_pos + Vector2(54, -6), enemy_pos + Vector2(0, -20))
	_draw_enemy_status_overlay()
	_draw_dungeon_run_animation()
	_draw_reward_popups()
	_draw_dungeon_feedback()

func _build_ui() -> void:
	var safe := MarginContainer.new()
	safe.name = "SafeArea"
	safe.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 14)
	safe.add_theme_constant_override("margin_top", 18)
	safe.add_theme_constant_override("margin_right", 14)
	safe.add_theme_constant_override("margin_bottom", 16)
	add_child(safe)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	safe.add_child(layout)

	var top_bar := PanelContainer.new()
	top_bar.add_theme_stylebox_override("panel", _ui_style_box("ui_hud_panel", "#1a1a2e", "#000000", 3, 28))
	layout.add_child(top_bar)

	var top_margin := MarginContainer.new()
	top_margin.add_theme_constant_override("margin_left", 10)
	top_margin.add_theme_constant_override("margin_top", 7)
	top_margin.add_theme_constant_override("margin_right", 10)
	top_margin.add_theme_constant_override("margin_bottom", 7)
	top_bar.add_child(top_margin)

	var top_stack := VBoxContainer.new()
	top_stack.add_theme_constant_override("separation", 4)
	top_margin.add_child(top_stack)

	hero_label = _label("", 15, Color("#e8dff5"))
	top_stack.add_child(hero_label)

	var resource_row := HBoxContainer.new()
	resource_row.add_theme_constant_override("separation", 6)
	top_stack.add_child(resource_row)

	gold_value_label = _stat_chip(resource_row, "icon_coins", "G")
	material_value_label = _stat_chip(resource_row, "icon_moon_shard", "材")
	training_value_label = _text_stat_chip(resource_row, "训")
	camp_value_label = _text_stat_chip(resource_row, "营")
	weapon_value_label = _text_stat_chip(resource_row, "武")
	stage_value_label = _text_stat_chip(resource_row, "区")

	xp_bar = _progress("#16213e", "#ff8c42")
	top_stack.add_child(xp_bar)

	scene_spacer = Control.new()
	scene_spacer.custom_minimum_size = Vector2(0, 332)
	scene_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scene_spacer)

	var bottom_panel := PanelContainer.new()
	bottom_panel.add_theme_stylebox_override("panel", _ui_style_box("ui_hud_panel", "#1a1a2e", "#000000", 3, 28))
	layout.add_child(bottom_panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 12)
	panel_margin.add_theme_constant_override("margin_top", 10)
	panel_margin.add_theme_constant_override("margin_right", 12)
	panel_margin.add_theme_constant_override("margin_bottom", 10)
	bottom_panel.add_child(panel_margin)

	var panel_stack := VBoxContainer.new()
	panel_stack.add_theme_constant_override("separation", 8)
	panel_margin.add_child(panel_stack)

	enemy_name_label = _label("", 16, Color("#fef9ef"))
	panel_stack.add_child(enemy_name_label)

	enemy_hp_bar = _progress("#2a2a4e", "#ffb5c0")
	panel_stack.add_child(enemy_hp_bar)

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 4)
	panel_stack.add_child(tab_row)

	for tab in [
		["battle", "战斗", "tab_adventure"],
		["growth", "战力", "tab_upgrade"],
		["inventory", "背包", "tab_bag"],
		["dungeon", "副本", "tab_quest"],
		["companion", "伙伴", "icon_notification"],
	]:
		var button := Button.new()
		button.text = ""
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 31)
		button.pressed.connect(_set_tab.bind(tab[0]))
		tab_button_labels[tab[0]] = _button_icon_label(button, tab[2], tab[1], 12)
		tab_buttons[tab[0]] = button
		tab_row.add_child(button)

	secondary_nav_row = HBoxContainer.new()
	secondary_nav_row.add_theme_constant_override("separation", 5)
	secondary_nav_row.visible = false
	panel_stack.add_child(secondary_nav_row)

	content_scroll = ScrollContainer.new()
	content_scroll.custom_minimum_size = Vector2(0, 116)
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_stack.add_child(content_scroll)

	content_stack = VBoxContainer.new()
	content_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_stack.add_theme_constant_override("separation", 5)
	content_scroll.add_child(content_stack)

	action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(action_row)

	attack_button = Button.new()
	attack_button.text = "手动攻击"
	attack_button.focus_mode = Control.FOCUS_NONE
	attack_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attack_button.pressed.connect(_manual_attack)
	action_row.add_child(attack_button)

	quest_claim_button = Button.new()
	quest_claim_button.focus_mode = Control.FOCUS_NONE
	quest_claim_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quest_claim_button.pressed.connect(_claim_quest_reward)
	action_row.add_child(quest_claim_button)

	save_button = Button.new()
	save_button.text = "保存"
	save_button.focus_mode = Control.FOCUS_NONE
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.pressed.connect(_save_game.bind(true))
	action_row.add_child(save_button)

	upgrade_row = HBoxContainer.new()
	upgrade_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(upgrade_row)

	upgrade_button = Button.new()
	upgrade_button.focus_mode = Control.FOCUS_NONE
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.pressed.connect(_buy_training)
	upgrade_row.add_child(upgrade_button)

	camp_button = Button.new()
	camp_button.focus_mode = Control.FOCUS_NONE
	camp_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camp_button.pressed.connect(_upgrade_camp)
	upgrade_row.add_child(camp_button)

	weapon_button = Button.new()
	weapon_button.focus_mode = Control.FOCUS_NONE
	weapon_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weapon_button.pressed.connect(_upgrade_weapon)
	upgrade_row.add_child(weapon_button)

	talisman_button = Button.new()
	talisman_button.focus_mode = Control.FOCUS_NONE
	talisman_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	talisman_button.pressed.connect(_upgrade_talisman)
	upgrade_row.add_child(talisman_button)

	log_label = _label("", 12, Color("#b4a5d5"))
	log_label.custom_minimum_size = Vector2(0, 58)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel_stack.add_child(log_label)

	_apply_button_styles()
	_build_detail_overlay()

func _apply_project_theme() -> void:
	var pixel_font := load(PIXEL_FONT_PATH)
	if pixel_font is Font:
		var project_theme := Theme.new()
		project_theme.default_font = pixel_font
		project_theme.default_font_size = 13
		theme = project_theme

func _load_sprite_textures() -> void:
	var paths := {
		"background": "res://assets/generated/moon-camp-background.png",
		"hero_idle": "res://assets/generated/crops/hero_idle.png",
		"hero_attack": "res://assets/generated/crops/hero_attack.png",
		"enemy_moss_slime": "res://assets/generated/crops/enemy_moss_slime.png",
		"enemy_mushroom": "res://assets/generated/crops/enemy_mushroom.png",
		"enemy_root_sprout": "res://assets/generated/crops/enemy_root_sprout.png",
		"icon_coins": "res://assets/generated/crops/icon_coins.png",
		"icon_moon_shard": "res://assets/generated/crops/icon_moon_shard.png",
		"tab_adventure": "res://assets/generated/crops/tab_adventure.png",
		"tab_upgrade": "res://assets/generated/crops/tab_upgrade.png",
		"tab_bag": "res://assets/generated/crops/tab_bag.png",
		"tab_quest": "res://assets/generated/crops/tab_quest.png",
		"icon_notification": "res://assets/generated/crops/icon_notification.png",
		"fx_attack_slash": "res://assets/generated/vfx/fx_attack_slash.png",
		"companion_nico": "res://assets/generated/companions/companion_nico.png",
		"companion_xiaomi": "res://assets/generated/companions/companion_xiaomi_cat.png",
		"companion_little_xiaomi": "res://assets/generated/companions/companion_little_xiaomi_cat.png",
		"companion_zizi": "res://assets/generated/companions/companion_zizi.png",
		"companion_meimei": "res://assets/generated/companions/companion_meimei.png",
		"companion_tutu": "res://assets/generated/companions/companion_tutu.png",
		"companion_dudu": "res://assets/generated/companions/companion_dudu.png",
		"item_moss_dew": "res://assets/generated/items/item_moss_dew.png",
		"item_moon_spore": "res://assets/generated/items/item_moon_spore.png",
		"item_warm_wood": "res://assets/generated/items/item_warm_wood.png",
		"item_dried_fish": "res://assets/generated/items/item_dried_fish.png",
			"item_moon_crystal": "res://assets/generated/items/item_moon_crystal.png",
			"item_moon_key": "res://assets/generated/items/item_moon_key.png",
			"item_moss_moon_core": "res://assets/generated/items/item_moss_moon_core.png",
			"item_second_moon_tear": "res://assets/generated/items/item_second_moon_tear.png",
			"item_quiet_moon_petal": "res://assets/generated/items/item_quiet_moon_petal.png",
			"item_camp_materials": "res://assets/generated/items/item_camp_materials.png",
			"item_chapter1_crest": "res://assets/generated/items/item_chapter1_crest.png",
		"icon_coins_large": "res://assets/generated/items/icon_coins_large.png",
		"weapon_wood_sword": "res://assets/generated/items/weapon_wood_sword.png",
		"weapon_moon_dagger": "res://assets/generated/items/weapon_moon_dagger.png",
		"weapon_spore_saber": "res://assets/generated/items/weapon_spore_saber.png",
		"weapon_warmwood_longsword": "res://assets/generated/items/weapon_warmwood_longsword.png",
		"weapon_moon_guardian_blade": "res://assets/generated/items/weapon_moon_guardian_blade.png",
		"talisman_old_copper": "res://assets/generated/items/talisman_old_copper.png",
		"talisman_mosslight": "res://assets/generated/items/talisman_mosslight.png",
		"talisman_moonspore": "res://assets/generated/items/talisman_moonspore.png",
		"talisman_warmwood": "res://assets/generated/items/talisman_warmwood.png",
		"talisman_moonforest": "res://assets/generated/items/talisman_moonforest.png",
		"collectible_laifu_bell": "res://assets/generated/items/collectible_laifu_bell.png",
			"collectible_nico_drinker": "res://assets/generated/items/collectible_nico_drinker.png",
			"boss_moss_moon_slime": "res://assets/generated/bosses/boss_moss_moon_slime.png",
			"boss_second_moon_warden": "res://assets/generated/bosses/boss_second_moon_warden.png",
			"fx_moon_spring_slash": "res://assets/generated/vfx/fx_moon_spring_slash.png",
			"battle_area_map": "res://assets/generated/ui/battle_area_map.png",
			"ui_modal_panel": "res://assets/generated/ui/ui_modal_panel.png",
			"ui_hud_panel": "res://assets/generated/ui/ui_hud_panel.png",
			"ui_button_primary": "res://assets/generated/ui/ui_button_primary.png",
			"ui_button_secondary": "res://assets/generated/ui/ui_button_secondary.png",
			"ui_tab_selected": "res://assets/generated/ui/ui_tab_selected.png",
			"ui_tab_idle": "res://assets/generated/ui/ui_tab_idle.png",
			"ui_progress_xp": "res://assets/generated/ui/ui_progress_xp.png",
			"ui_progress_hp": "res://assets/generated/ui/ui_progress_hp.png",
			"ui_section_card": "res://assets/generated/ui/ui_section_card.png",
		}
	for key in paths.keys():
		var texture := _load_texture_from_path(paths[key])
		if texture != null:
			if key == "background":
				background_texture = texture
			else:
				sprite_textures[key] = texture

func _load_texture_from_path(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", load(PIXEL_FONT_PATH))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _estimated_line_count(text: String, chars_per_line: int, max_lines: int) -> int:
	if text.strip_edges() == "":
		return 1
	var total := 0
	for raw_line in text.split("\n", false):
		var line := str(raw_line)
		total += maxi(1, int(ceil(float(line.length()) / float(chars_per_line))))
	if max_lines > 0:
		return clampi(total, 1, max_lines)
	return maxi(1, total)

func _limit_label_lines(label: Label, max_lines: int, wrap: bool = true, line_height: int = 16) -> void:
	label.clip_text = false
	if max_lines > 0:
		label.max_lines_visible = max_lines
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label.custom_minimum_size = Vector2(0, line_height * max_lines + 2)

func _content_text_height(text: String, font_size: int = 13) -> int:
	var lines := _estimated_line_count(text, CONTENT_TEXT_CHARS_PER_LINE, 8)
	return 16 + lines * (font_size + 5)

func _detail_row_height(title: String, subtitle: String) -> int:
	var title_lines := _estimated_line_count(title, DETAIL_TITLE_CHARS_PER_LINE, 2)
	var subtitle_lines := 0 if subtitle == "" else _estimated_line_count(subtitle, DETAIL_SUBTITLE_CHARS_PER_LINE, 4)
	return 22 + title_lines * 17 + subtitle_lines * 16

func _stat_chip(parent: HBoxContainer, texture_key: String, fallback: String) -> Label:
	var chip := HBoxContainer.new()
	chip.add_theme_constant_override("separation", 2)
	parent.add_child(chip)

	var texture: Texture2D = sprite_textures.get(texture_key)
	if texture != null:
		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = Vector2(20, 20)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(icon)
	else:
		var fallback_label := _label(fallback, 12, Color("#ffd4a3"))
		fallback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(fallback_label)

	var value_label := _label("0", 13, Color("#ffd4a3"))
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(value_label)
	return value_label

func _text_stat_chip(parent: HBoxContainer, prefix: String) -> Label:
	var chip := HBoxContainer.new()
	chip.add_theme_constant_override("separation", 2)
	parent.add_child(chip)

	var prefix_label := _label(prefix, 12, Color("#b4a5d5"))
	prefix_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(prefix_label)

	var value_label := _label("0", 13, Color("#ffd4a3"))
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(value_label)
	return value_label

func _button_icon_label(button: Button, texture_key: String, text: String, font_size: int) -> Label:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 3)
	margin.add_theme_constant_override("margin_bottom", 3)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 2)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var texture: Texture2D = sprite_textures.get(texture_key)
	if texture != null:
		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = Vector2(15, 15)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)

	var text_label := _label(text, font_size, Color("#fef9ef"))
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_label)
	return text_label

func _build_detail_overlay() -> void:
	detail_overlay = ColorRect.new()
	detail_overlay.name = "DetailOverlay"
	detail_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_overlay.color = Color(0.02, 0.02, 0.05, 0.64)
	detail_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	detail_overlay.visible = false
	add_child(detail_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(338, 0)
	panel.add_theme_stylebox_override("panel", _ui_style_box("ui_modal_panel", "#1a1a2e", "#000000", 3, 38))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	margin.add_child(stack)

	detail_title_label = _label("", 16, Color("#fef9ef"))
	detail_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(detail_title_label)

	detail_type_label = _label("", 12, Color("#ffd4a3"))
	detail_type_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(detail_type_label)

	detail_image_rect = TextureRect.new()
	detail_image_rect.custom_minimum_size = Vector2(0, 104)
	detail_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	detail_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(detail_image_rect)

	detail_body_scroll = ScrollContainer.new()
	detail_body_scroll.custom_minimum_size = Vector2(0, 230)
	detail_body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(detail_body_scroll)

	var detail_body_stack := VBoxContainer.new()
	detail_body_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_body_stack.add_theme_constant_override("separation", 7)
	detail_body_scroll.add_child(detail_body_stack)

	detail_description_label = _label("", 13, Color("#e8dff5"))
	detail_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_body_stack.add_child(detail_description_label)

	detail_effect_label = _label("", 12, Color("#b4a5d5"))
	detail_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_effect_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_body_stack.add_child(detail_effect_label)

	detail_extra_container = VBoxContainer.new()
	detail_extra_container.add_theme_constant_override("separation", 6)
	detail_extra_container.visible = false
	detail_body_stack.add_child(detail_extra_container)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	stack.add_child(action_row)

	detail_primary_button = Button.new()
	detail_primary_button.focus_mode = Control.FOCUS_NONE
	detail_primary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_primary_button.pressed.connect(_on_detail_primary)
	action_row.add_child(detail_primary_button)
	_apply_single_button_style(detail_primary_button)

	detail_secondary_button = Button.new()
	detail_secondary_button.focus_mode = Control.FOCUS_NONE
	detail_secondary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_secondary_button.pressed.connect(_on_detail_secondary)
	action_row.add_child(detail_secondary_button)
	_apply_single_button_style(detail_secondary_button)

	detail_close_button = Button.new()
	detail_close_button.text = "关闭"
	detail_close_button.focus_mode = Control.FOCUS_NONE
	detail_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_close_button.pressed.connect(_hide_detail_overlay)
	action_row.add_child(detail_close_button)
	_apply_single_button_style(detail_close_button)

func _clear_content_rows() -> void:
	if content_stack == null:
		return
	for child in content_stack.get_children():
		content_stack.remove_child(child)
		child.queue_free()

func _add_content_text(text: String, font_size: int = 13, color: Color = Color("#e8dff5")) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, _content_text_height(text, font_size))
	panel.add_theme_stylebox_override("panel", _ui_style_box("ui_section_card", "#20203a", "#4b405f", 2, 18))
	content_stack.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 5)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var label := _label(text, font_size, color)
	_limit_label_lines(label, _estimated_line_count(text, CONTENT_TEXT_CHARS_PER_LINE, 8), true, font_size + 5)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(label)

func _add_detail_row(title: String, subtitle: String, detail: Dictionary, status: String = "") -> void:
	var title_text := title if status == "" else "%s  %s" % [title, status]
	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, _detail_row_height(title_text, subtitle))
	button.clip_contents = true
	button.pressed.connect(_open_detail.bind(detail))
	content_stack.add_child(button)
	_apply_single_button_style(button)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)

	var title_label := _label(title_text, 13, Color("#fef9ef"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_limit_label_lines(title_label, _estimated_line_count(title_text, DETAIL_TITLE_CHARS_PER_LINE, 2), true, 17)
	stack.add_child(title_label)

	if subtitle != "":
		var subtitle_label := _label(subtitle, 11, Color("#b4a5d5"))
		subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_limit_label_lines(subtitle_label, _estimated_line_count(subtitle, DETAIL_SUBTITLE_CHARS_PER_LINE, 4), true, 15)
		stack.add_child(subtitle_label)

func _add_equipment_set_gallery_rows() -> void:
	_add_content_text("套装图鉴：同阶武器和护符都穿戴后点亮词条。", 12, Color("#ffd4a3"))
	for set_rank in range(1, _max_equipment_set_rank() + 1):
		_add_equipment_set_gallery_row(set_rank)

func _add_equipment_set_gallery_row(set_rank: int) -> void:
	var detail := _equipment_set_detail(set_rank)
	var active := bool(detail.get("unlocked", false))
	var ready := bool(detail.get("ready", false))
	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 88)
	button.clip_contents = true
	button.pressed.connect(_open_detail.bind(detail))
	content_stack.add_child(button)
	_apply_single_button_style(button)
	if active:
		button.add_theme_stylebox_override("normal", _style_box("#3a2f30", "#ffd4a3", 3))
	elif ready:
		button.add_theme_stylebox_override("normal", _style_box("#222e38", "#8ccf9f", 2))
	else:
		button.add_theme_stylebox_override("normal", _style_box("#1b1b31", "#4b405f", 2))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.add_theme_constant_override("separation", 2)
	text_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_stack)

	var title_label := _label("套装图鉴 · %s" % DATA.equipment_set_name(set_rank), 12, Color("#fef9ef"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_limit_label_lines(title_label, _estimated_line_count(title_label.text, 24, 2), true, 16)
	text_stack.add_child(title_label)

	var effect_label := _label(DATA.equipment_set_short_effect(set_rank), 11, Color("#b4a5d5"))
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_limit_label_lines(effect_label, _estimated_line_count(effect_label.text, 24, 2), true, 15)
	text_stack.add_child(effect_label)

	var status_color := Color("#ffd4a3") if active else Color("#8ccf9f") if ready else Color("#b4a5d5")
	var status_label := _label(_equipment_set_gallery_status(set_rank), 11, status_color)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_limit_label_lines(status_label, _estimated_line_count(status_label.text, 26, 3), true, 14)
	text_stack.add_child(status_label)

	var slot_row := HBoxContainer.new()
	slot_row.custom_minimum_size = Vector2(116, 0)
	slot_row.add_theme_constant_override("separation", 5)
	slot_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(slot_row)
	_add_set_piece_slot(slot_row, _equipment_set_piece_data(set_rank, "weapon"), Vector2(54, 62), 28)
	_add_set_piece_slot(slot_row, _equipment_set_piece_data(set_rank, "talisman"), Vector2(54, 62), 28)

func _add_set_piece_slot(parent: Control, piece: Dictionary, min_size: Vector2, icon_height: int, expand: bool = false) -> PanelContainer:
	var owned := bool(piece.get("owned", false))
	var equipped := bool(piece.get("equipped", false))
	var border := "#ffd4a3" if equipped else "#8ccf9f" if owned else "#4b405f"
	var bg := "#332b35" if equipped else "#202b36" if owned else "#151528"
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style_box(bg, border, 2))
	if expand:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 1)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)

	var texture: Texture2D = sprite_textures.get(str(piece.get("sprite", "")))
	var image_rect := TextureRect.new()
	image_rect.texture = texture
	image_rect.custom_minimum_size = Vector2(0, icon_height)
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	image_rect.modulate = Color(1, 1, 1, 1.0 if owned else 0.34)
	image_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(image_rect)

	var slot_label := _label(str(piece.get("slot", "")), 9, Color("#fef9ef") if owned else Color("#817296"))
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(slot_label)

	var state_label := _label(str(piece.get("state", "")), 10, Color(border))
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(state_label)
	return panel

func _open_detail(detail: Dictionary) -> void:
	active_detail = detail.duplicate(true)
	detail_title_label.text = str(active_detail.get("title", "详情"))
	detail_type_label.text = str(active_detail.get("type", ""))
	var description_text := str(active_detail.get("description", ""))
	var effect_text := str(active_detail.get("effect", ""))
	detail_description_label.text = description_text
	detail_description_label.visible = description_text != ""
	detail_effect_label.text = effect_text
	detail_effect_label.visible = effect_text != ""
	_set_detail_image(str(active_detail.get("sprite", "")))
	_configure_detail_extra()
	_configure_detail_actions()
	if detail_body_scroll != null:
		detail_body_scroll.scroll_vertical = 0
	detail_overlay.visible = true

func _set_detail_image(sprite_key: String) -> void:
	if detail_image_rect == null:
		return
	var texture: Texture2D = sprite_textures.get(sprite_key)
	detail_image_rect.texture = texture
	detail_image_rect.visible = texture != null

func _clear_detail_extra() -> void:
	if detail_extra_container == null:
		return
	for child in detail_extra_container.get_children():
		detail_extra_container.remove_child(child)
		child.queue_free()
	detail_extra_container.visible = false

func _configure_detail_extra() -> void:
	_clear_detail_extra()
	var kind := str(active_detail.get("kind", ""))
	if active_detail.has("sections"):
		_add_detail_sections(active_detail.get("sections", []))
	if kind == "companion_selector":
		_add_companion_selector_buttons()
		return
	if kind == "chapter_goal":
		return
	if kind != "equipment_set":
		if detail_extra_container != null and detail_extra_container.get_child_count() > 0:
			detail_extra_container.visible = true
		return
	var set_rank := int(active_detail.get("rank", 1))
	var title_label := _label("套装部件", 12, Color("#ffd4a3"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_extra_container.add_child(title_label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_extra_container.add_child(row)
	_add_set_piece_slot(row, _equipment_set_piece_data(set_rank, "weapon"), Vector2(0, 82), 42, true)
	_add_set_piece_slot(row, _equipment_set_piece_data(set_rank, "talisman"), Vector2(0, 82), 42, true)
	detail_extra_container.visible = true

func _add_detail_sections(sections: Array) -> void:
	for section in sections:
		if typeof(section) != TYPE_DICTIONARY:
			continue
		var section_dict: Dictionary = Dictionary(section)
		var title := str(section_dict.get("title", "信息"))
		var body := str(section_dict.get("body", ""))
		if body == "":
			continue
		var color := Color(str(section_dict.get("color", "#ffd4a3")))
		_add_detail_section_text(title, body, color)
	if detail_extra_container != null and detail_extra_container.get_child_count() > 0:
		detail_extra_container.visible = true

func _add_detail_section_text(title: String, body: String, title_color: Color = Color("#ffd4a3")) -> void:
	var title_label := _label(title, 12, title_color)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_extra_container.add_child(title_label)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _ui_style_box("ui_section_card", "#17172b", "#4b405f", 2, 18))
	detail_extra_container.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var body_label := _label(body, 11, Color("#d8ccec"))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_label.custom_minimum_size = Vector2(0, _content_text_height(body, 11) - 8)
	body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(body_label)

func _add_chapter_goal_extra() -> void:
	var goal_id := str(active_detail.get("id", ""))
	var data := DATA.chapter_goal(goal_id)
	if data.is_empty():
		return
	var step_lines: Array[String] = []
	var goals: Array = data.get("goals", [])
	for goal in goals:
		var goal_dict: Dictionary = Dictionary(goal)
		var step_id := str(goal_dict.get("id", ""))
		var prefix := "已完成" if _is_chapter_goal_step_complete(step_id) else "未完成"
		step_lines.append("%s · %s" % [prefix, str(goal_dict.get("label", step_id))])
	if not step_lines.is_empty():
		_add_detail_section_text("进度", "\n".join(step_lines))
	var reward: Dictionary = Dictionary(data.get("reward", {})).duplicate(true)
	_add_detail_section_text("结算奖励", _format_reward(reward).replace(" + ", "\n"), Color("#8ccf9f"))
	var status := "已领取" if _is_chapter_goal_claimed(goal_id) else "可领取" if _is_chapter_goal_complete(goal_id) else "继续推进"
	_add_detail_section_text("状态", status, Color("#b4a5d5"))
	detail_extra_container.visible = true

func _add_companion_selector_buttons() -> void:
	var title_label := _label("选择 1 个上阵伙伴", 12, Color("#ffd4a3"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_extra_container.add_child(title_label)
	for item_id in DATA.companion_ids():
		var companion := DATA.companion(item_id)
		var unlocked := _is_companion_unlocked(item_id)
		var status := "已上阵" if item_id == companion_id else "可上阵" if unlocked else "未解锁"
		var button := Button.new()
		button.text = "%s · %s" % [str(companion.get("name", item_id)), status]
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = not unlocked or item_id == companion_id
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 34)
		button.pressed.connect(_select_companion_from_selector.bind(item_id))
		detail_extra_container.add_child(button)
		_apply_single_button_style(button)
	detail_extra_container.visible = true

func _configure_detail_actions() -> void:
	var kind := str(active_detail.get("kind", ""))
	detail_primary_button.visible = false
	detail_secondary_button.visible = false
	detail_primary_button.disabled = false
	detail_secondary_button.disabled = false
	match kind:
		"weapon":
			var weapon_detail_rank := int(active_detail.get("rank", 0))
			var weapon_count := _equipment_count("weapon", weapon_detail_rank)
			detail_primary_button.visible = true
			detail_primary_button.text = "已穿戴" if weapon_detail_rank == equipped_weapon_rank else "穿戴"
			detail_primary_button.disabled = weapon_detail_rank == equipped_weapon_rank or weapon_count <= 0
			detail_secondary_button.visible = true
			detail_secondary_button.text = "分解"
			detail_secondary_button.disabled = weapon_detail_rank <= 0 or weapon_count <= (1 if weapon_detail_rank == equipped_weapon_rank else 0)
		"talisman":
			var talisman_detail_rank := int(active_detail.get("rank", 0))
			var talisman_count := _equipment_count("talisman", talisman_detail_rank)
			detail_primary_button.visible = true
			detail_primary_button.text = "已穿戴" if talisman_detail_rank == equipped_talisman_rank else "穿戴"
			detail_primary_button.disabled = talisman_detail_rank == equipped_talisman_rank or talisman_count <= 0
			detail_secondary_button.visible = true
			detail_secondary_button.text = "分解"
			detail_secondary_button.disabled = talisman_detail_rank <= 0 or talisman_count <= (1 if talisman_detail_rank == equipped_talisman_rank else 0)
		"companion":
			var item_id := str(active_detail.get("id", ""))
			detail_primary_button.visible = true
			detail_primary_button.text = "已上阵" if item_id == companion_id else "上阵"
			detail_primary_button.disabled = item_id == companion_id or not _is_companion_unlocked(item_id)
			detail_secondary_button.visible = true
			detail_secondary_button.text = "喂小鱼干"
			detail_secondary_button.disabled = not _is_companion_unlocked(item_id) or not _can_feed_companion(item_id)
		"collectible":
			detail_primary_button.visible = true
			detail_primary_button.text = "已生效" if bool(active_detail.get("unlocked", false)) else "未解锁"
			detail_primary_button.disabled = true
		"daily":
			detail_primary_button.visible = true
			detail_primary_button.text = "已领取" if not _can_claim_daily() else "领取"
			detail_primary_button.disabled = not _can_claim_daily()
		"daily_task":
			var task_id := str(active_detail.get("id", ""))
			var complete := _is_daily_task_complete(task_id)
			var claimed := _is_daily_task_claimed(task_id)
			detail_primary_button.visible = true
			detail_primary_button.text = "已领取" if claimed else "领取" if complete else "未完成"
			detail_primary_button.disabled = claimed or not complete
		"chapter_goal":
			var goal_id := str(active_detail.get("id", ""))
			var chapter_complete := _is_chapter_goal_complete(goal_id)
			var chapter_claimed_ready := _is_chapter_goal_claimed(goal_id)
			detail_primary_button.visible = true
			detail_primary_button.text = "已领取" if chapter_claimed_ready else "领取" if chapter_complete else "未完成"
			detail_primary_button.disabled = chapter_claimed_ready or not chapter_complete
		"dungeon":
			var dungeon_id := str(active_detail.get("id", ""))
			detail_primary_button.visible = true
			if _is_dungeon_preview(dungeon_id):
				detail_primary_button.text = "预告"
				detail_primary_button.disabled = true
				return
			var dungeon_unlocked := _is_dungeon_unlocked(dungeon_id)
			var dungeon_attempts_ready := _dungeon_attempts_left(dungeon_id) > 0
			var dungeon_cost_ready := _has_dungeon_entry_cost(dungeon_id)
			var dungeon_boss_active := _is_boss_dungeon_active(dungeon_id)
			detail_primary_button.text = "回战斗" if dungeon_boss_active else "挑战" if dungeon_cost_ready else "缺门票"
			detail_primary_button.disabled = not dungeon_boss_active and (not dungeon_unlocked or not dungeon_attempts_ready or not dungeon_cost_ready)
		"equipment_set":
			detail_primary_button.visible = true
			detail_primary_button.text = "已激活" if bool(active_detail.get("unlocked", false)) else "可激活" if bool(active_detail.get("ready", false)) else "缺少部件"
			detail_primary_button.disabled = true
		"weapon_awaken":
			detail_primary_button.visible = true
			detail_primary_button.text = "已满级" if _is_weapon_awaken_maxed() else "觉醒" if _can_awaken_weapon() else "材料不足"
			detail_primary_button.disabled = _is_weapon_awaken_maxed() or not _can_awaken_weapon()
		"talisman_awaken":
			detail_primary_button.visible = true
			detail_primary_button.text = "已满级" if _is_talisman_awaken_maxed() else "觉醒" if _can_awaken_talisman() else "材料不足"
			detail_primary_button.disabled = _is_talisman_awaken_maxed() or not _can_awaken_talisman()
		"loot":
			var loot_name := str(active_detail.get("id", active_detail.get("title", "")))
			if loot_name == "第二月泪":
				detail_primary_button.visible = true
				detail_primary_button.text = "去觉醒"
				detail_primary_button.disabled = not _is_awaken_unlocked()
		"title":
			var title_id := str(active_detail.get("id", "camp_adventurer"))
			var unlocked := _is_title_unlocked(title_id)
			detail_primary_button.visible = true
			detail_primary_button.text = "使用中" if title_id == equipped_title_id else "使用" if unlocked else "未解锁"
			detail_primary_button.disabled = title_id == equipped_title_id or not unlocked
		"album":
			detail_primary_button.visible = true
			detail_primary_button.text = "已收集" if bool(active_detail.get("unlocked", false)) else "未解锁"
			detail_primary_button.disabled = true
		"boss":
			detail_primary_button.visible = true
			detail_primary_button.text = "战斗中" if boss_active else "已击败"
			detail_primary_button.disabled = true
		"companion_selector":
			detail_primary_button.visible = true
			detail_primary_button.text = "去伙伴页"
			detail_primary_button.disabled = false

func _hide_detail_overlay() -> void:
	active_detail.clear()
	_clear_detail_extra()
	if detail_overlay != null:
		detail_overlay.visible = false

func _progress(bg: String, fill: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 16)
	bar.show_percentage = false
	var texture_key := "ui_progress_hp" if fill == "#ffb5c0" else "ui_progress_xp"
	bar.add_theme_stylebox_override("background", _ui_style_box(texture_key, bg, "#100f1e", 1, 10))
	bar.add_theme_stylebox_override("fill", _style_box(fill, fill, 0))
	return bar

func _ui_style_box(texture_key: String, fallback_bg: String, fallback_border: String, border_width: int, texture_margin: int) -> StyleBox:
	var texture: Texture2D = sprite_textures.get(texture_key)
	if texture == null:
		return _style_box(fallback_bg, fallback_border, border_width)
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = texture_margin
	style.texture_margin_top = texture_margin
	style.texture_margin_right = texture_margin
	style.texture_margin_bottom = texture_margin
	return style

func _style_box(bg: String, border: String, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(border)
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	return style

func _apply_button_styles() -> void:
	for button in _all_buttons():
		_apply_single_button_style(button)
	_update_tab_styles()

func _apply_single_button_style(button: Button) -> void:
	if button == null:
		return
	var normal := _ui_style_box("ui_button_secondary", "#2a2a4e", "#000000", 3, 18)
	var pressed := _ui_style_box("ui_button_primary", "#ff8c42", "#000000", 3, 18)
	var hover := _ui_style_box("ui_button_primary", "#b4a5d5", "#000000", 3, 18)
	var disabled := _style_box("#2a2338", "#0a0812", 3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_font_override("font", load(PIXEL_FONT_PATH))
	button.add_theme_color_override("font_color", Color("#fef9ef"))
	button.add_theme_color_override("font_pressed_color", Color("#1a1a2e"))
	button.add_theme_color_override("font_hover_color", Color("#1a1a2e"))
	button.add_theme_color_override("font_disabled_color", Color("#817296"))
	button.add_theme_font_size_override("font_size", 13)

func _all_buttons() -> Array[Button]:
	var buttons: Array[Button] = [attack_button, quest_claim_button, save_button, upgrade_button, camp_button, weapon_button, talisman_button]
	for button in tab_buttons.values():
		buttons.append(button)
	return buttons

func _update_tab_styles() -> void:
	for tab in tab_buttons.keys():
		var button: Button = tab_buttons[tab]
		if tab == selected_tab:
			button.add_theme_stylebox_override("normal", _ui_style_box("ui_tab_selected", "#ff8c42", "#000000", 3, 18))
			button.add_theme_color_override("font_color", Color("#1a1a2e"))
			var selected_label: Label = tab_button_labels.get(tab)
			if selected_label != null:
				selected_label.add_theme_color_override("font_color", Color("#1a1a2e"))
		else:
			button.add_theme_stylebox_override("normal", _ui_style_box("ui_tab_idle", "#2a2a4e", "#000000", 3, 18))
			button.add_theme_color_override("font_color", Color("#fef9ef"))
			var normal_label: Label = tab_button_labels.get(tab)
			if normal_label != null:
				normal_label.add_theme_color_override("font_color", Color("#fef9ef"))

func _normalize_tab(tab: String) -> String:
	match tab:
		"adventure":
			return "battle"
		"upgrade":
			return "growth"
		"quest":
			return "dungeon"
		"battle", "growth", "inventory", "dungeon", "companion":
			return tab
		_:
			return "battle"

func _set_tab(tab: String) -> void:
	selected_tab = _normalize_tab(tab)
	_update_tab_styles()
	_request_content_refresh()
	_update_ui()

func _set_inventory_section(section: String) -> void:
	if section not in ["equipment", "items", "collectibles"]:
		section = "equipment"
	if inventory_section == section:
		return
	inventory_section = section
	_request_content_refresh()
	_update_ui()

func _set_companion_section(section: String) -> void:
	if section not in ["companions", "titles", "album"]:
		section = "companions"
	if companion_section == section:
		return
	companion_section = section
	_request_content_refresh()
	_update_ui()

func _request_content_refresh() -> void:
	content_dirty = true

func _configure_secondary_nav() -> void:
	if secondary_nav_row == null:
		return
	var items: Array = []
	var active_key := ""
	var signature := selected_tab
	if selected_tab == "inventory":
		items = [
			["equipment", "装备"],
			["items", "道具"],
			["collectibles", "收藏"],
		]
		active_key = inventory_section
		signature = "inventory:%s" % inventory_section
	elif selected_tab == "companion":
		items = [
			["companions", "伙伴"],
			["titles", "称号"],
			["album", "相册"],
		]
		active_key = companion_section
		signature = "companion:%s" % companion_section
	else:
		secondary_nav_row.visible = false
		secondary_nav_signature = ""
		return
	if signature == secondary_nav_signature:
		secondary_nav_row.visible = true
		return
	for child in secondary_nav_row.get_children():
		secondary_nav_row.remove_child(child)
		child.queue_free()
	for item in items:
		var key := str(item[0])
		var label := str(item[1])
		var button := Button.new()
		button.text = label
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 29)
		if selected_tab == "inventory":
			button.pressed.connect(_set_inventory_section.bind(key))
		else:
			button.pressed.connect(_set_companion_section.bind(key))
		secondary_nav_row.add_child(button)
		_apply_single_button_style(button)
		if key == active_key:
			button.add_theme_stylebox_override("normal", _ui_style_box("ui_tab_selected", "#ff8c42", "#000000", 3, 18))
			button.add_theme_color_override("font_color", Color("#1a1a2e"))
	secondary_nav_row.visible = true
	secondary_nav_signature = signature

func _render_tab_content() -> void:
	_clear_content_rows()
	match selected_tab:
		"battle":
			if boss_active:
				_add_content_text("Boss 战斗中：当前伤害 %d，倒计时结束会判定试炼失败。" % _hero_damage_value(), 12, Color("#ffd4a3"))
			else:
				_add_content_text("自动挂机：当前伤害 %d。区域掉落在血条下方显示，伙伴上阵会影响战斗和收益。" % _hero_damage_value(), 12, Color("#e8dff5"))
		"growth":
			_add_content_text("战力养成：训练、营地、武器和护符都会影响主线推进。")
			_add_equipment_rows()
			_add_awaken_rows()
			if _is_weapon_unlocked():
				_add_content_text("下次武器强化：%s\n%s" % [_format_weapon_cost(), _weapon_upgrade_preview_text()], 12, Color("#ffd4a3"))
			else:
				_add_content_text("再击败 %d 只小怪解锁武器强化。" % maxi(0, 12 - defeated), 12, Color("#ffd4a3"))
			var talisman_next := "营地 1 级或击败 8 只小怪后解锁"
			if _is_talisman_unlocked():
				talisman_next = "%s\n%s" % [_format_talisman_cost(), _talisman_upgrade_preview_text()]
			_add_content_text("下次护符强化：%s" % talisman_next, 12, Color("#ffd4a3"))
		"inventory":
			match inventory_section:
				"equipment":
					_add_content_text("装备页：查看穿戴、套装图鉴和部位强化。穿戴中的 1 件不会被分解。", 12, Color("#ffd4a3"))
					_add_equipment_set_gallery_rows()
					_add_owned_equipment_rows()
				"items":
					_add_content_text("道具页：材料、门票和 Boss 掉落都在这里，点开可以看图片和用途。", 12, Color("#ffd4a3"))
					_add_detail_row("材料 · 营地材料 x%d" % materials, "用来升级营地和基础设施。", _generic_material_detail())
					var keys := inventory.keys()
					keys.sort()
					if keys.is_empty() and materials <= 0:
						_add_content_text("背包暂无掉落物。击败小怪或挑战副本后会获得道具。", 12, Color("#b4a5d5"))
					for key in keys:
						var item_name := str(key)
						_add_detail_row("道具 · %s x%d" % [item_name, int(inventory[key])], DATA.loot_description(item_name), _loot_detail(item_name, int(inventory[key])))
				"collectibles":
					_add_content_text("收藏页：私人收藏和纪念物会在满足条件后点亮，并提供常驻效果。", 12, Color("#ffd4a3"))
					_add_collectible_rows()
		"dungeon":
			var dungeon_claimable := _claimable_quests()
			var equipment_line := "武器部位强化：Lv.%d。" % weapon_rank if _is_weapon_unlocked() else "长期目标：击败 12 只小怪解锁第一件装备。总击败：%d / 12。" % defeated
			var reward_line := "可领取任务奖励：%d 个。" % dungeon_claimable if dungeon_claimable > 0 else "清理满 4 只小怪后可领取奖励。"
			_add_content_text("副本与日常：区域任务 %d/4 · %s %s" % [defeated % 4, reward_line, equipment_line], 12)
			_add_chapter_goal_rows()
			_add_daily_task_rows()
			_add_dungeon_rows()
			_add_daily_row()
			_add_detail_row("区域任务奖励", _quest_reward_subtitle(dungeon_claimable), _quest_reward_detail(dungeon_claimable), "[可领取]" if dungeon_claimable > 0 else "[进行中]")
			_add_album_progress_row()
		"companion":
			match companion_section:
				"companions":
					_add_content_text(_companion_progress_text(companion_id), 12, Color("#ffd4a3"))
					_add_companion_rows()
				"titles":
					_add_title_rows()
				"album":
					_add_album_rows()
					_add_album_progress_row()

func _add_equipment_rows(include_set_summary: bool = true) -> void:
	var set_rank := _equipment_set_rank()
	if include_set_summary:
		var set_status := "[2件]" if set_rank > 0 else "[未激活]"
		_add_detail_row("当前套装 · %s" % DATA.equipment_set_name(set_rank), _equipment_set_row_subtitle(), _equipment_set_detail(set_rank if set_rank > 0 else 1), set_status)
	var weapon_status := "[已穿戴]"
	_add_detail_row("武器 · %s Lv.%d x%d" % [DATA.weapon_name(equipped_weapon_rank), equipped_weapon_rank, _equipment_count("weapon", equipped_weapon_rank)], _weapon_row_subtitle(equipped_weapon_rank), _weapon_detail(equipped_weapon_rank), weapon_status)
	var talisman_status := "[已穿戴]"
	_add_detail_row("护符 · %s Lv.%d x%d" % [DATA.talisman_name(equipped_talisman_rank), equipped_talisman_rank, _equipment_count("talisman", equipped_talisman_rank)], _talisman_row_subtitle(equipped_talisman_rank), _talisman_detail(equipped_talisman_rank), talisman_status)

func _add_awaken_rows() -> void:
	if not _is_awaken_unlocked():
		if stage >= 18:
			_add_content_text("月泉觉醒：第 20 区 Boss 掉落第二月泪后开放，用来强化武器和护符部位。", 12, Color("#b4a5d5"))
		return
	_add_content_text("月泉觉醒：消耗第二月泪，让第 20 区后的成长从装备部位继续延伸。", 12, Color("#ffd4a3"))
	_add_detail_row(
		"觉醒 · %s Lv.%d" % [DATA.awaken_name("weapon"), weapon_awaken_rank],
		_weapon_awaken_row_subtitle(),
		_weapon_awaken_detail(),
		"[已满]" if _is_weapon_awaken_maxed() else "[可觉醒]" if _can_awaken_weapon() else "[缺材料]"
	)
	_add_detail_row(
		"觉醒 · %s Lv.%d" % [DATA.awaken_name("talisman"), talisman_awaken_rank],
		_talisman_awaken_row_subtitle(),
		_talisman_awaken_detail(),
		"[已满]" if _is_talisman_awaken_maxed() else "[可觉醒]" if _can_awaken_talisman() else "[缺材料]"
	)

func _add_owned_equipment_rows() -> void:
	_ensure_equipment_inventory()
	var ids := _owned_equipment_ids()
	if ids.is_empty():
		_add_content_text("还没有副本装备。先挑战亮晶晶洞穴或月露矿道。", 12, Color("#b4a5d5"))
		return
	for equipment_id in ids:
		var slot := DATA.equipment_slot(equipment_id)
		var rank := DATA.equipment_rank(equipment_id)
		var count := int(equipment_inventory.get(equipment_id, 0))
		var equipped := equipment_id == _equipped_equipment_id(slot)
		var status := "[已穿戴]" if equipped else "[可穿戴]"
		var title := "%s · %s Lv.%d x%d" % [DATA.equipment_type_name(equipment_id), DATA.equipment_name(equipment_id), rank, count]
		var subtitle := "%s · %s" % [DATA.equipment_effect(equipment_id), "多余件可分解" if count > (1 if equipped else 0) and rank > 0 else "至少保留穿戴件" if equipped else "可用于套装搭配"]
		var detail := _talisman_detail(rank) if slot == "talisman" else _weapon_detail(rank)
		_add_detail_row(title, subtitle, detail, status)

func _equipment_set_row_subtitle() -> String:
	var set_rank := _equipment_set_rank()
	if set_rank <= 0:
		return "同时穿戴武器 Lv.1 + 护符 Lv.1 激活第一条 2 件套词条。"
	return "%s · %s" % [DATA.equipment_set_short_effect(set_rank), _equipment_set_next_text()]

func _weapon_row_subtitle(rank: int) -> String:
	if rank == weapon_rank:
		return "%s · %s" % [DATA.weapon_effect(rank), _weapon_upgrade_preview_text()]
	return DATA.weapon_effect(rank)

func _talisman_row_subtitle(rank: int) -> String:
	if rank == talisman_rank:
		return "%s · %s" % [DATA.talisman_effect(rank), _talisman_upgrade_preview_text()]
	return DATA.talisman_effect(rank)

func _add_companion_rows() -> void:
	for item_id in DATA.companion_ids():
		var companion := DATA.companion(item_id)
		var unlocked := _is_companion_unlocked(item_id)
		var status := "[已上阵]" if item_id == companion_id else "[辅助]" if unlocked else "[未解锁]"
		var title := "伙伴 · %s Lv.%d" % [str(companion.get("name", item_id)), _companion_level(item_id)]
		var subtitle := _companion_row_subtitle(item_id, unlocked)
		_add_detail_row(title, subtitle, _companion_detail(item_id), status)

func _add_title_rows() -> void:
	_sanitize_equipped_title()
	_add_content_text("当前称号：%s。称号只改变顶部身份展示，不提供数值加成。" % DATA.player_title_name(equipped_title_id), 12, Color("#ffd4a3"))
	for title_id in DATA.player_title_ids():
		var title := DATA.player_title(title_id)
		var unlocked := _is_title_unlocked(title_id)
		var status := "[使用中]" if title_id == equipped_title_id else "[已解锁]" if unlocked else "[未解锁]"
		var subtitle := str(title.get("description", "")) if unlocked else "解锁条件：%s" % str(title.get("unlock", "待发现"))
		_add_detail_row("称号 · %s" % str(title.get("name", title_id)), subtitle, _title_detail(title_id), status)

func _companion_row_subtitle(item_id: String, unlocked: bool) -> String:
	var companion := DATA.companion(item_id)
	if not unlocked:
		return "解锁条件：%s" % str(companion.get("unlock", "待发现"))
	if item_id == companion_id:
		return "上阵：%s" % _companion_active_text(item_id)
	return "辅助：%s" % _companion_support_text(item_id)

func _companion_active_text(item_id: String) -> String:
	match item_id:
		"nico":
			return "攻击伤害 +%d" % _nico_active_damage_bonus()
		"xiaomi":
			return "击败后额外扒拉 +%dG" % _xiaomi_active_gold_bonus()
		"little_xiaomi":
			return "攻击伤害 +%d" % _little_xiaomi_active_damage_bonus()
		"zizi":
			return "巡逻和离线金币 +%dG" % _zizi_active_patrol_bonus()
		"meimei":
			return "怪物掉落率 +25%，掉落时可能多带回 1 个材料"
		"tutu":
			return "击败小怪时有机会额外带回 1 个营地材料"
		"dudu":
			return "任务领奖额外 +%dG +1材" % _dudu_active_quest_gold_bonus()
		_:
			return "上阵时提供小额收益"

func _companion_support_text(item_id: String) -> String:
	match item_id:
		"nico":
			return "攻击伤害 +%d" % _nico_support_damage_bonus()
		"xiaomi":
			return "击败后提醒亮晶晶，额外 +%dG" % _xiaomi_support_gold_bonus()
		"little_xiaomi":
			return "攻击伤害 +%d" % _little_xiaomi_support_damage_bonus()
		"zizi":
			return "巡逻和离线金币 +%dG" % _zizi_support_patrol_bonus()
		"meimei":
			return "怪物掉落率 +5%"
		"tutu":
			return "任务领奖额外 +1材"
		"dudu":
			return "任务领奖额外 +%dG" % _dudu_support_quest_gold_bonus()
		_:
			return "未上阵时提供辅助收益"

func _add_collectible_rows() -> void:
	for item_id in DATA.private_collectible_ids():
		var item := DATA.private_collectible(item_id)
		var unlocked := _has_private_collectible(item_id)
		var status := "[已生效]" if unlocked else "[未解锁]"
		var subtitle := str(item.get("short_effect", item.get("effect", "")))
		_add_detail_row("收藏 · %s" % str(item.get("name", item_id)), subtitle, _collectible_detail(item_id, unlocked), status)

func _add_daily_row() -> void:
	var reward := DATA.daily_reward(daily_cycle_day)
	var status := "[可领取]" if _can_claim_daily() else "[已领取]"
	var subtitle := "%s · %s" % [_format_reward(reward), str(reward.get("description", ""))]
	_add_detail_row("签到 · %s" % str(reward.get("title", "今日奖励")), subtitle, _daily_detail(), status)

func _add_dungeon_rows() -> void:
	_reset_dungeon_attempts_if_needed()
	for dungeon_id in DATA.dungeon_ids():
		var data := DATA.dungeon(dungeon_id)
		var unlocked := _is_dungeon_unlocked(dungeon_id)
		var preview := _is_dungeon_preview(dungeon_id)
		var attempts_left := _dungeon_attempts_left(dungeon_id)
		var has_entry_cost := _has_dungeon_entry_cost(dungeon_id)
		var status := "[预告]" if preview and unlocked else "[战斗中]" if _is_boss_dungeon_active(dungeon_id) else "[可挑战]" if unlocked and attempts_left > 0 and has_entry_cost else "[缺钥匙]" if unlocked and attempts_left > 0 else "[次数用完]" if unlocked else "[未解锁]"
		var subtitle := ""
		if _is_boss_dungeon_active(dungeon_id):
			subtitle = "Boss 已出现 · 回到战斗页击败 %s · HP %d/%d" % [str(enemy.get("name", "Boss")), enemy_hp, enemy_max_hp]
		elif preview and unlocked:
			subtitle = "第 20 区目标预告 · 推荐战力 %d · 正式 Boss 素材接入后开放。" % _dungeon_power_required(dungeon_id)
		elif unlocked:
			var cost_text := _dungeon_entry_cost_text(dungeon_id)
			subtitle = "剩余 %d/%d · 推荐战力 %d · %s · %s" % [
				attempts_left,
				_dungeon_daily_attempts(dungeon_id),
				_dungeon_power_required(dungeon_id),
				cost_text,
				_format_reward(_dungeon_reward_preview(dungeon_id)),
			]
		else:
			subtitle = "解锁条件：%s" % _dungeon_unlock_text(dungeon_id)
		_add_detail_row("副本 · %s" % str(data.get("name", dungeon_id)), subtitle, _dungeon_detail(dungeon_id), status)

func _add_chapter_goal_rows() -> void:
	for goal_id in DATA.chapter_goal_ids():
		var data := DATA.chapter_goal(goal_id)
		if data.is_empty():
			continue
		var complete_count := _chapter_goal_complete_count(goal_id)
		var total_count := _chapter_goal_total_count(goal_id)
		var claimed := _is_chapter_goal_claimed(goal_id)
		var complete := _is_chapter_goal_complete(goal_id)
		var status := "[已领取]" if claimed else "[可领取]" if complete else "[章节目标]"
		var reward: Dictionary = Dictionary(data.get("reward", {})).duplicate(true)
		var subtitle := "进度 %d/%d · 奖励 %s" % [complete_count, total_count, _format_reward(reward)]
		_add_detail_row("章节 · %s" % str(data.get("name", goal_id)), subtitle, _chapter_goal_detail(goal_id), status)

func _add_daily_task_rows() -> void:
	_reset_daily_tasks_if_needed()
	var complete_count := _daily_task_complete_count()
	var total := DATA.daily_task_ids().size()
	_add_content_text("每日小目标：%d/%d。完成短任务可领取额外奖励，明天刷新。" % [complete_count, total], 12, Color("#ffd4a3"))
	for task_id in DATA.daily_task_ids():
		var task := DATA.daily_task(task_id)
		var progress := _daily_task_progress_value(task_id)
		var target := maxi(1, int(task.get("target", 1)))
		var reward: Dictionary = Dictionary(task.get("reward", {})).duplicate(true)
		var status := "[已领取]" if _is_daily_task_claimed(task_id) else "[可领取]" if _is_daily_task_complete(task_id) else "[进行中]"
		var subtitle := "进度 %d/%d · 奖励 %s" % [mini(progress, target), target, _format_reward(reward)]
		_add_detail_row("每日 · %s" % str(task.get("title", task_id)), subtitle, _daily_task_detail(task_id), status)

func _quest_reward_subtitle(claimable_count: int) -> String:
	if claimable_count > 0:
		return "可领取 %d 次 · 金币、营地材料；护符和套装会提高奖励。" % claimable_count
	return "清理满 4 只小怪后可领取金币和营地材料。"

func _quest_reward_detail(claimable_count: int) -> Dictionary:
	return {
		"kind": "quest",
		"title": "区域清理奖励",
		"type": "任务 / 主线循环",
		"sprite": "icon_coins_large",
		"description": "每清理 4 只小怪可以领取一次。奖励会随着里程碑提高。",
		"effect": "",
		"sections": [
			{"title": "当前可领", "body": "%d 个" % claimable_count},
			{"title": "收益加成", "body": "护符 +%dG/次\n月泉觉醒 +%dG/次\n套装金币倍率 x%.2f" % [
				talisman_rank * 3,
				DATA.talisman_awaken_quest_bonus(talisman_awaken_rank),
				_equipment_set_quest_gold_multiplier(),
			], "color": "#8ccf9f"},
		],
	}

func _add_album_progress_row() -> void:
	var unlocked := _album_unlocked_count()
	var total := DATA.album_entries().size()
	_add_detail_row("相册 · 月森回忆 %d/%d" % [unlocked, total], "伙伴页可以查看每一条回忆和解锁条件。", {
		"kind": "album",
		"unlocked": true,
		"title": "月森相册",
		"type": "图鉴 / 回忆",
		"description": "记录已经发生过的小目标、私人收藏和营地回忆。",
		"effect": "",
		"sections": [
			{"title": "收集进度", "body": "%d/%d" % [unlocked, total]},
			{"title": "继续点亮", "body": "签到、升级营地、强化装备、喂小鱼干。", "color": "#b4a5d5"},
		],
	}, "[进度]")

func _add_album_rows() -> void:
	var entries := DATA.album_entries()
	var unlocked_count := _album_unlocked_count()
	_add_content_text("月森相册：%d/%d。点开条目可以看描述和解锁条件。" % [unlocked_count, entries.size()], 12, Color("#ffd4a3"))
	for entry in entries:
		var entry_id := str(entry.get("id", ""))
		var unlocked := _is_album_unlocked(entry_id)
		var status := "[已收集]" if unlocked else "[未解锁]"
		var subtitle := str(entry.get("description", "")) if unlocked else "解锁条件：%s" % str(entry.get("unlock", "待发现"))
		_add_detail_row("相册 · %s" % str(entry.get("title", entry_id)), subtitle, _album_detail(entry_id), status)

func _weapon_detail(rank: int) -> Dictionary:
	var reward := DATA.weapon_decompose_reward(maxi(1, rank))
	var count := _equipment_count("weapon", rank)
	var decompose_text := "持有：%d。多余件可分解返还：%dG + %s x%d；穿戴中的 1 件必须保留。" % [count, int(reward["gold"]), str(reward["item"]), int(reward["amount"])] if rank > 0 else "持有：%d。初始武器不能分解。" % count
	var upgrade_text := _weapon_upgrade_preview_text() if rank == weapon_rank else "旧阶装备可重新穿戴，用来配合护符激活低阶套装。"
	return {
		"kind": "weapon",
		"rank": rank,
		"title": "%s Lv.%d" % [DATA.weapon_name(rank), rank],
		"type": "武器 / 部位强化",
		"sprite": DATA.weapon_sprite(rank),
		"description": DATA.weapon_description(rank),
		"effect": "",
		"sections": [
			{"title": "当前效果", "body": DATA.weapon_effect(rank)},
			{"title": "强化", "body": "强化绑定在武器部位，不会把旧武器变成另一把。\n%s" % upgrade_text, "color": "#8ccf9f"},
			{"title": "套装", "body": _equipment_set_requirement_text(rank), "color": "#ffd4a3"},
			{"title": "分解", "body": decompose_text, "color": "#b4a5d5"},
		],
	}

func _talisman_detail(rank: int) -> Dictionary:
	var reward := DATA.talisman_decompose_reward(maxi(1, rank))
	var count := _equipment_count("talisman", rank)
	var decompose_text := "持有：%d。多余件可分解返还：%dG + %d材；穿戴中的 1 件必须保留。" % [count, int(reward["gold"]), int(reward["materials"])] if rank > 0 else "持有：%d。初始护符不能分解。" % count
	var upgrade_text := _talisman_upgrade_preview_text() if rank == talisman_rank else "旧阶护符可重新穿戴，用来配合武器激活低阶套装。"
	return {
		"kind": "talisman",
		"rank": rank,
		"title": "%s Lv.%d" % [DATA.talisman_name(rank), rank],
		"type": "护符 / 部位强化",
		"sprite": DATA.talisman_sprite(rank),
		"description": DATA.talisman_description(rank),
		"effect": "",
		"sections": [
			{"title": "当前效果", "body": DATA.talisman_effect(rank)},
			{"title": "强化", "body": "强化绑定在护符部位，不会把旧护符变成另一件。\n%s" % upgrade_text, "color": "#8ccf9f"},
			{"title": "套装", "body": _equipment_set_requirement_text(rank), "color": "#ffd4a3"},
			{"title": "分解", "body": decompose_text, "color": "#b4a5d5"},
		],
	}

func _equipment_set_detail(set_rank: int = -1) -> Dictionary:
	var target_rank := _equipment_set_rank() if set_rank < 0 else clampi(set_rank, 1, _max_equipment_set_rank())
	var active := _equipment_set_rank() >= target_rank
	var ready := _equipment_count("weapon", target_rank) > 0 and _equipment_count("talisman", target_rank) > 0
	var next_text := _equipment_set_next_text() if active else _equipment_set_activation_text(target_rank)
	return {
		"kind": "equipment_set",
		"rank": target_rank,
		"unlocked": active,
		"ready": ready,
		"title": DATA.equipment_set_name(target_rank),
		"type": "套装图鉴 / 2 件套词条",
		"sprite": DATA.weapon_sprite(target_rank),
		"description": DATA.equipment_set_description(target_rank),
		"effect": "",
		"sections": [
			{"title": "套装词条", "body": DATA.equipment_set_effect(target_rank)},
			{"title": "激活进度", "body": "%s\n%s" % [next_text, _equipment_set_piece_status_line(target_rank)], "color": "#8ccf9f"},
			{"title": "当前穿戴", "body": "武器 Lv.%d\n护符 Lv.%d" % [equipped_weapon_rank, equipped_talisman_rank], "color": "#b4a5d5"},
		],
	}

func _weapon_awaken_detail() -> Dictionary:
	return {
		"kind": "weapon_awaken",
		"title": DATA.awaken_name("weapon"),
		"type": "月泉觉醒 / 武器部位",
		"sprite": "item_second_moon_tear",
		"description": "把第二月泪嵌进武器部位的月光回路。它不会替换当前穿戴的武器，只提升武器部位的后段成长。",
		"effect": "",
		"sections": [
			{"title": "当前加成", "body": "Lv.%d\n攻击 +%d" % [weapon_awaken_rank, DATA.weapon_awaken_attack_bonus(weapon_awaken_rank)]},
			{"title": "下次消耗", "body": _format_weapon_awaken_cost().replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "觉醒上限", "body": "Lv.%d" % DATA.equipment_awaken_max_rank(), "color": "#b4a5d5"},
		],
	}

func _talisman_awaken_detail() -> Dictionary:
	return {
		"kind": "talisman_awaken",
		"title": DATA.awaken_name("talisman"),
		"type": "月泉觉醒 / 护符部位",
		"sprite": "item_second_moon_tear",
		"description": "把第二月泪调进护符回响。它不会替换当前穿戴的护符，只提升巡逻、任务和离线收益。",
		"effect": "",
		"sections": [
			{"title": "当前加成", "body": "Lv.%d\n巡逻/离线 +%dG\n任务领奖 +%dG/次" % [
				talisman_awaken_rank,
				DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank),
				DATA.talisman_awaken_quest_bonus(talisman_awaken_rank),
			]},
			{"title": "下次消耗", "body": _format_talisman_awaken_cost().replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "觉醒上限", "body": "Lv.%d" % DATA.equipment_awaken_max_rank(), "color": "#b4a5d5"},
		],
	}

func _loot_detail(item_name: String, count: int) -> Dictionary:
	return {
		"kind": "loot",
		"id": item_name,
		"title": item_name,
		"type": "道具 / 掉落物",
		"sprite": DATA.loot_sprite(item_name),
		"description": DATA.loot_description(item_name),
		"effect": "",
		"sections": [
			{"title": "持有", "body": "x%d" % count},
			{"title": "用途", "body": DATA.loot_use(item_name), "color": "#8ccf9f"},
		],
	}

func _generic_material_detail() -> Dictionary:
	return {
		"kind": "material",
		"title": "营地材料",
		"type": "通用材料",
		"sprite": DATA.loot_sprite("营地材料"),
		"description": "修补营地、升级设施用的基础材料。",
		"effect": "",
		"sections": [
			{"title": "持有", "body": "x%d" % materials},
			{"title": "当前消耗", "body": "营地升级需要 %d材" % DATA.camp_upgrade_cost(camp_rank), "color": "#8ccf9f"},
		],
	}

func _companion_detail(item_id: String) -> Dictionary:
	var companion := DATA.companion(item_id)
	var unlocked := _is_companion_unlocked(item_id)
	var needed := DATA.companion_bond_needed(_companion_bond(item_id))
	var feed_cost := DATA.companion_feed_cost(_companion_level(item_id))
	var state_text := "当前上阵。" if item_id == companion_id else "未上阵，正在提供辅助能力。" if unlocked else "未解锁，暂不提供能力。"
	return {
		"kind": "companion",
		"id": item_id,
		"title": str(companion.get("name", "小咪")),
		"type": str(companion.get("role", "伙伴")),
		"sprite": str(companion.get("sprite", "")),
		"description": str(companion.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "状态", "body": state_text},
			{"title": "能力", "body": "上阵：%s\n辅助：%s" % [_companion_active_text(item_id), _companion_support_text(item_id)], "color": "#8ccf9f"},
			{"title": "羁绊与喂养", "body": "羁绊 %d（%d/%d）\n喂养需要小鱼干 x%d\n当前持有 x%d" % [
				_companion_bond(item_id),
				_companion_bond_progress(item_id),
				needed,
				feed_cost,
				int(inventory.get("小鱼干", 0)),
			], "color": "#b4a5d5"},
		],
	}

func _collectible_detail(item_id: String, unlocked: bool) -> Dictionary:
	var item := DATA.private_collectible(item_id)
	var unlock_text := "已解锁并生效。" if unlocked else "解锁条件：%s。" % str(item.get("unlock", "待发现"))
	return {
		"kind": "collectible",
		"id": item_id,
		"unlocked": unlocked,
		"title": str(item.get("name", item_id)),
		"type": str(item.get("type", "收藏")),
		"sprite": str(item.get("sprite", "")),
		"description": str(item.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "效果", "body": str(item.get("effect", "")), "color": "#8ccf9f"},
			{"title": "状态", "body": unlock_text, "color": "#b4a5d5"},
		],
	}

func _title_detail(title_id: String) -> Dictionary:
	var title := DATA.player_title(title_id)
	var unlocked := _is_title_unlocked(title_id)
	var status := "使用中。" if title_id == equipped_title_id else "已解锁，可切换。" if unlocked else "未解锁。"
	return {
		"kind": "title",
		"id": title_id,
		"unlocked": unlocked,
		"title": str(title.get("name", title_id)),
		"type": str(title.get("type", "称号")),
		"sprite": str(title.get("sprite", "icon_notification")),
		"description": str(title.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "解锁条件", "body": str(title.get("unlock", "待发现"))},
			{"title": "状态", "body": status, "color": "#8ccf9f"},
			{"title": "说明", "body": "称号只改变顶部身份展示，不提供数值加成。", "color": "#b4a5d5"},
		],
	}

func _daily_detail() -> Dictionary:
	var reward := DATA.daily_reward(daily_cycle_day)
	var status := "今日可领取。" if _can_claim_daily() else "今日已领取，明天再来。"
	return {
		"kind": "daily",
		"title": str(reward.get("title", "今日签到")),
		"type": "每日签到",
		"sprite": _reward_sprite_key(reward),
		"description": str(reward.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "奖励", "body": _format_reward(reward).replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "状态", "body": status},
			{"title": "累计签到", "body": "%d 次" % daily_claim_count, "color": "#b4a5d5"},
		],
	}

func _daily_task_detail(task_id: String) -> Dictionary:
	_reset_daily_tasks_if_needed()
	var task := DATA.daily_task(task_id)
	var reward: Dictionary = Dictionary(task.get("reward", {})).duplicate(true)
	var progress := _daily_task_progress_value(task_id)
	var target := maxi(1, int(task.get("target", 1)))
	var status := "已领取。" if _is_daily_task_claimed(task_id) else "可领取。" if _is_daily_task_complete(task_id) else "进行中。"
	return {
		"kind": "daily_task",
		"id": task_id,
		"title": str(task.get("title", "每日小目标")),
		"type": "每日任务",
		"sprite": _reward_sprite_key(reward),
		"description": str(task.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "进度", "body": "%d/%d" % [mini(progress, target), target]},
			{"title": "奖励", "body": _format_reward(reward).replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "状态", "body": status, "color": "#b4a5d5"},
		],
	}

func _chapter_goal_detail(goal_id: String) -> Dictionary:
	var data := DATA.chapter_goal(goal_id)
	if data.is_empty():
		return {
			"kind": "chapter_goal",
			"title": "章节目标",
			"type": "章节结算",
			"description": "这个章节目标还没有开放。",
			"effect": "",
		}
	var step_lines: Array[String] = []
	var goals: Array = data.get("goals", [])
	for goal in goals:
		var goal_dict: Dictionary = Dictionary(goal)
		var step_id := str(goal_dict.get("id", ""))
		var prefix := "已完成" if _is_chapter_goal_step_complete(step_id) else "未完成"
		step_lines.append("%s · %s" % [prefix, str(goal_dict.get("label", step_id))])
	var reward: Dictionary = Dictionary(data.get("reward", {})).duplicate(true)
	var status := "已领取" if _is_chapter_goal_claimed(goal_id) else "可领取" if _is_chapter_goal_complete(goal_id) else "继续推进"
	return {
		"kind": "chapter_goal",
		"id": goal_id,
		"title": str(data.get("name", goal_id)),
		"type": str(data.get("type", "章节结算")),
		"sprite": str(data.get("sprite", "item_second_moon_tear")),
		"description": str(data.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "进度", "body": "\n".join(step_lines)},
			{"title": "结算奖励", "body": _format_reward(reward).replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "状态", "body": status, "color": "#b4a5d5"},
		],
	}

func _boss_detail(boss_id: String) -> Dictionary:
	var boss := DATA.boss(boss_id)
	if boss.is_empty():
		return {
			"kind": "boss",
			"title": "未知 Boss",
			"type": "Boss",
			"description": "这个 Boss 还没有开放。",
			"effect": "",
		}
	var reward := _dungeon_reward_preview(active_boss_dungeon_id) if active_boss_dungeon_id != "" else {}
	var fail_reward: Dictionary = Dictionary(boss.get("fail_reward", {})).duplicate(true)
	return {
		"kind": "boss",
		"id": boss_id,
		"title": str(boss.get("name", boss_id)),
		"type": str(boss.get("type", "Boss")),
		"sprite": str(boss.get("sprite", "")),
		"description": str(boss.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "战斗", "body": "HP %d/%d\n剩余 %s" % [enemy_hp, enemy_max_hp, _format_time_seconds(active_boss_timer)]},
			{"title": "提示", "body": str(boss.get("hint", "打不过就先补强。")), "color": "#ffd4a3"},
			{"title": "击败奖励", "body": _format_reward(reward).replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "失败安慰", "body": _format_reward(fail_reward).replace(" + ", "\n"), "color": "#b4a5d5"},
		],
	}

func _dungeon_detail(dungeon_id: String) -> Dictionary:
	_reset_dungeon_attempts_if_needed()
	var data := DATA.dungeon(dungeon_id)
	var unlocked := _is_dungeon_unlocked(dungeon_id)
	var attempts_left := _dungeon_attempts_left(dungeon_id)
	var needed := _dungeon_power_required(dungeon_id)
	var reward := _dungeon_reward_preview(dungeon_id)
	var cost_ready := _has_dungeon_entry_cost(dungeon_id)
	var preview := _is_dungeon_preview(dungeon_id)
	var status := "预告：正式 Boss 素材和动作还未接入，暂不开放挑战。" if preview and unlocked else "Boss 已出现，回到战斗页继续。" if _is_boss_dungeon_active(dungeon_id) else "可挑战。" if unlocked and attempts_left > 0 and cost_ready else "缺少门票：%s。" % _dungeon_entry_cost_text(dungeon_id) if unlocked and attempts_left > 0 else "今日次数已用完。" if unlocked else "未解锁：%s。" % _dungeon_unlock_text(dungeon_id)
	var power_line := "当前战力 %d / 推荐 %d。" % [_hero_power(), needed]
	if unlocked and _hero_power() < needed:
		power_line += " 建议先训练、强化武器或换上攻击伙伴。"
	if preview:
		power_line = "第 20 区目标战力参考：%d。当前战力 %d。" % [needed, _hero_power()]
	return {
		"kind": "dungeon",
		"id": dungeon_id,
		"unlocked": unlocked,
		"title": str(data.get("name", dungeon_id)),
		"type": str(data.get("type", "每日副本")),
		"sprite": str(data.get("sprite", "item_moon_key")),
		"description": str(data.get("description", "")),
		"effect": "",
		"sections": [
			{"title": "奖励", "body": _format_reward(reward).replace(" + ", "\n"), "color": "#8ccf9f"},
			{"title": "次数与门票", "body": "次数 %d/%d\n%s" % [attempts_left, _dungeon_daily_attempts(dungeon_id), _dungeon_entry_cost_text(dungeon_id)]},
			{"title": "战力", "body": "%s\n套装副本倍率 x%.2f" % [power_line, _equipment_set_dungeon_multiplier()], "color": "#ffd4a3"},
			{"title": "状态", "body": status, "color": "#b4a5d5"},
		],
	}

func _reward_sprite_key(reward: Dictionary) -> String:
	var reward_equipment = reward.get("equipment", {})
	if typeof(reward_equipment) == TYPE_DICTIONARY:
		var equipment_keys := Dictionary(reward_equipment).keys()
		equipment_keys.sort()
		if not equipment_keys.is_empty():
			return DATA.equipment_sprite(str(equipment_keys[0]))
	var reward_items = reward.get("items", {})
	if typeof(reward_items) == TYPE_DICTIONARY:
		var keys := Dictionary(reward_items).keys()
		keys.sort()
		if not keys.is_empty():
			return DATA.loot_sprite(str(keys[0]))
	if int(reward.get("materials", 0)) > 0:
		return DATA.loot_sprite("营地材料")
	if int(reward.get("gold", 0)) > 0:
		return DATA.loot_sprite("金币")
	return ""

func _album_detail(entry_id: String) -> Dictionary:
	var entry := DATA.album_entry(entry_id)
	var unlocked := _is_album_unlocked(entry_id)
	var description := str(entry.get("description", ""))
	if not unlocked:
		description = "这个回忆还没有点亮。继续推进对应目标后会自动收集。"
	return {
		"kind": "album",
		"id": entry_id,
		"unlocked": unlocked,
		"title": str(entry.get("title", entry_id)),
		"type": str(entry.get("type", "相册")),
		"description": description,
		"effect": "",
		"sections": [
			{"title": "解锁条件", "body": str(entry.get("unlock", "待发现"))},
			{"title": "状态", "body": "已收集" if unlocked else "未解锁", "color": "#8ccf9f" if unlocked else "#b4a5d5"},
		],
	}

func _manual_attack() -> void:
	_deal_damage(true)

func _on_detail_primary() -> void:
	var kind := str(active_detail.get("kind", ""))
	match kind:
		"weapon":
			var equip_weapon_rank := int(active_detail.get("rank", 0))
			if _equipment_count("weapon", equip_weapon_rank) > 0:
				equipped_weapon_rank = equip_weapon_rank
				_add_log("已穿戴%s Lv.%d。" % [DATA.weapon_name(equip_weapon_rank), equip_weapon_rank])
		"talisman":
			var equip_talisman_rank := int(active_detail.get("rank", 0))
			if _equipment_count("talisman", equip_talisman_rank) > 0:
				equipped_talisman_rank = equip_talisman_rank
				_add_log("已穿戴%s Lv.%d。" % [DATA.talisman_name(equip_talisman_rank), equip_talisman_rank])
		"companion":
			var item_id := str(active_detail.get("id", companion_id))
			if _is_companion_unlocked(item_id):
				companion_id = item_id
				var companion := DATA.companion(companion_id)
				_add_log("%s 已上阵，其余伙伴提供辅助能力。" % str(companion.get("name", "伙伴")))
		"daily":
			_claim_daily_reward()
		"daily_task":
			_claim_daily_task(str(active_detail.get("id", "")))
		"chapter_goal":
			_claim_chapter_goal(str(active_detail.get("id", "")))
		"dungeon":
			_run_dungeon(str(active_detail.get("id", "")))
		"weapon_awaken":
			_awaken_weapon()
		"talisman_awaken":
			_awaken_talisman()
		"loot":
			if str(active_detail.get("id", active_detail.get("title", ""))) == "第二月泪":
				selected_tab = "growth"
		"title":
			var title_id := str(active_detail.get("id", "camp_adventurer"))
			if _is_title_unlocked(title_id):
				equipped_title_id = title_id
				_add_log("称号已切换为：%s。" % DATA.player_title_name(equipped_title_id))
		"companion_selector":
			selected_tab = "companion"
			companion_section = "companions"
	_hide_detail_overlay()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _on_detail_secondary() -> void:
	var kind := str(active_detail.get("kind", ""))
	match kind:
		"weapon":
			_decompose_weapon_detail()
		"talisman":
			_decompose_talisman_detail()
		"companion":
			_feed_companion(str(active_detail.get("id", companion_id)))

func _select_companion_from_selector(item_id: String) -> void:
	if not _is_companion_unlocked(item_id):
		_add_log("这个伙伴还没有解锁。")
		return
	companion_id = item_id
	var companion := DATA.companion(companion_id)
	_add_log("%s 已上阵，其余伙伴提供辅助能力。" % str(companion.get("name", "伙伴")))
	_hide_detail_overlay()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _decompose_weapon_detail() -> void:
	var rank := int(active_detail.get("rank", 0))
	var equipment_id := _equipment_key("weapon", rank)
	var count := int(equipment_inventory.get(equipment_id, 0))
	var reserved := 1 if rank == equipped_weapon_rank else 0
	if rank <= 0:
		_add_log("初始武器不能分解。")
		return
	if count <= reserved:
		_add_log("穿戴中的武器至少保留 1 件，没有多余件可分解。")
		return
	var old_name := DATA.weapon_name(rank)
	var reward := DATA.equipment_decompose_reward(equipment_id)
	gold += int(reward["gold"])
	_add_item(str(reward["item"]), int(reward["amount"]))
	_remove_equipment(equipment_id, 1)
	_push_reward_popup("+%dG +%s x%d" % [int(reward["gold"]), str(reward["item"]), int(reward["amount"])], Vector2(size.x * 0.50, size.y * 0.55), Color("#ffd4a3"))
	_add_log("分解%s，返还 %dG 和 %s x%d。" % [old_name, int(reward["gold"]), str(reward["item"]), int(reward["amount"])])
	_hide_detail_overlay()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _decompose_talisman_detail() -> void:
	var rank := int(active_detail.get("rank", 0))
	var equipment_id := _equipment_key("talisman", rank)
	var count := int(equipment_inventory.get(equipment_id, 0))
	var reserved := 1 if rank == equipped_talisman_rank else 0
	if rank <= 0:
		_add_log("初始护符不能分解。")
		return
	if count <= reserved:
		_add_log("穿戴中的护符至少保留 1 件，没有多余件可分解。")
		return
	var old_name := DATA.talisman_name(rank)
	var reward := DATA.equipment_decompose_reward(equipment_id)
	gold += int(reward["gold"])
	materials += int(reward["materials"])
	_remove_equipment(equipment_id, 1)
	_push_reward_popup("+%dG +%d材" % [int(reward["gold"]), int(reward["materials"])], Vector2(size.x * 0.50, size.y * 0.55), Color("#b4a5d5"))
	_add_log("分解%s，返还 %dG 和 %d 个材料。" % [old_name, int(reward["gold"]), int(reward["materials"])])
	_hide_detail_overlay()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _awaken_weapon() -> void:
	if not _is_awaken_unlocked():
		_add_log("击败第二月泉守望者后才会开放月泉觉醒。")
		return
	if _is_weapon_awaken_maxed():
		_add_log("武器月泉觉醒已经满级。")
		return
	if not _can_awaken_weapon():
		_add_log("材料还不够，武器觉醒需要%s。" % _format_weapon_awaken_cost())
		return
	var cost := DATA.weapon_awaken_cost(weapon_awaken_rank)
	gold -= int(cost["gold"])
	_remove_item("第二月泪", int(cost["tear"]))
	_remove_item("月露结晶", int(cost["crystal"]))
	if int(cost.get("petal", 0)) > 0:
		_remove_item("静月花瓣", int(cost["petal"]))
	weapon_awaken_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_push_reward_popup("武器觉醒 +1", Vector2(size.x * 0.50, size.y * 0.55), Color("#ffd4a3"), 1.35)
	_add_log("武器部位完成月泉觉醒 Lv.%d，攻击额外提高。" % weapon_awaken_rank)
	_request_content_refresh()

func _awaken_talisman() -> void:
	if not _is_awaken_unlocked():
		_add_log("击败第二月泉守望者后才会开放月泉觉醒。")
		return
	if _is_talisman_awaken_maxed():
		_add_log("护符月泉觉醒已经满级。")
		return
	if not _can_awaken_talisman():
		_add_log("材料还不够，护符觉醒需要%s。" % _format_talisman_awaken_cost())
		return
	var cost := DATA.talisman_awaken_cost(talisman_awaken_rank)
	gold -= int(cost["gold"])
	materials -= int(cost["materials"])
	_remove_item("第二月泪", int(cost["tear"]))
	if int(cost.get("petal", 0)) > 0:
		_remove_item("静月花瓣", int(cost["petal"]))
	talisman_awaken_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_push_reward_popup("护符觉醒 +1", Vector2(size.x * 0.50, size.y * 0.55), Color("#b4a5d5"), 1.35)
	_add_log("护符部位完成月泉觉醒 Lv.%d，巡逻和任务收益提高。" % talisman_awaken_rank)
	_request_content_refresh()

func _claim_daily_reward() -> void:
	if not _can_claim_daily():
		_add_log("今天的签到奖励已经领取过了。")
		return
	var reward := DATA.daily_reward(daily_cycle_day)
	_apply_reward(reward)
	daily_claimed_date = _today_key()
	daily_claim_count += 1
	daily_cycle_day = (daily_cycle_day + 1) % DATA.daily_reward_count()
	_push_reward_popup(_format_reward(reward), Vector2(size.x * 0.50, size.y * 0.54), Color("#ffd4a3"))
	_add_log("签到成功，获得%s。" % _format_reward(reward))
	_request_content_refresh()

func _claim_daily_task(task_id: String) -> void:
	_reset_daily_tasks_if_needed()
	if _is_daily_task_claimed(task_id):
		_add_log("这个每日小目标今天已经领过了。")
		return
	if not _is_daily_task_complete(task_id):
		_add_log("每日小目标还没完成。")
		return
	var task := DATA.daily_task(task_id)
	if task.is_empty():
		_add_log("这个每日小目标还没开放。")
		return
	var reward: Dictionary = Dictionary(task.get("reward", {})).duplicate(true)
	_apply_reward(reward)
	daily_task_claimed[task_id] = true
	_push_reward_popup(_format_reward(reward), Vector2(size.x * 0.50, size.y * 0.50), Color("#ffd4a3"), 1.45)
	_add_log("完成每日小目标：%s，获得%s。" % [str(task.get("title", task_id)), _format_reward(reward)])
	_request_content_refresh()

func _claim_chapter_goal(goal_id: String) -> void:
	if _is_chapter_goal_claimed(goal_id):
		_add_log("这个章节结算奖励已经领取过了。")
		return
	if not _is_chapter_goal_complete(goal_id):
		_add_log("章节目标还没有完成。")
		return
	var data := DATA.chapter_goal(goal_id)
	if data.is_empty():
		_add_log("这个章节目标还没开放。")
		return
	var reward: Dictionary = Dictionary(data.get("reward", {})).duplicate(true)
	_apply_reward(reward)
	chapter_claimed[goal_id] = true
	var feedback_body := str(data.get("claim_feedback", "获得 %s，第二月泉后的路线已接上。" % _format_reward(reward)))
	_push_reward_popup("章节完成", Vector2(size.x * 0.50, size.y * 0.46), Color("#ffd4a3"), 1.70)
	_push_dungeon_feedback("章节完成 · %s" % str(data.get("name", goal_id)), "%s 获得 %s。" % [feedback_body, _format_reward(reward)], Color("#ffd4a3"), 2.55)
	_add_log("完成%s，获得%s。" % [str(data.get("name", goal_id)), _format_reward(reward)])
	_request_content_refresh()

func _run_dungeon(dungeon_id: String) -> void:
	_reset_dungeon_attempts_if_needed()
	var data := DATA.dungeon(dungeon_id)
	var dungeon_name := str(data.get("name", "副本"))
	if data.is_empty():
		_add_log("这个副本还没开放。")
		_push_dungeon_feedback("副本未开放", "月森地图还在扩建。", Color("#b4a5d5"))
		return
	if _is_boss_dungeon_active(dungeon_id):
		selected_tab = "battle"
		_push_dungeon_feedback("Boss 战进行中", "回到战斗页击败 %s。" % str(enemy.get("name", "Boss")), Color("#ffd4a3"), 1.80)
		_add_log("%s还在战斗中，先把 Boss 打倒。" % dungeon_name)
		return
	if boss_active:
		_add_log("当前已有 Boss 战进行中，先击败 %s。" % str(enemy.get("name", "Boss")))
		_push_dungeon_feedback("Boss 战进行中", "当前只能同时挑战 1 个 Boss。", Color("#b4a5d5"), 1.80)
		return
	if not _is_dungeon_unlocked(dungeon_id):
		var unlock_text := _dungeon_unlock_text(dungeon_id)
		_add_log("%s还没解锁：%s。" % [dungeon_name, unlock_text])
		_push_dungeon_feedback("未解锁 · %s" % dungeon_name, unlock_text, Color("#b4a5d5"))
		return
	if _is_dungeon_preview(dungeon_id):
		_add_log("%s只是预告：正式 Boss 素材和动作还没接入，暂不开放挑战。" % dungeon_name)
		_push_dungeon_feedback("预告 · %s" % dungeon_name, "第 20 区 Boss 会单独生成 image/image2 素材后开放。", Color("#ffd4a3"), 2.20)
		_request_content_refresh()
		return
	if _dungeon_attempts_left(dungeon_id) <= 0:
		_add_log("%s今天的次数已经用完。" % dungeon_name)
		_push_dungeon_feedback("次数用完 · %s" % dungeon_name, "明天再来，或者先推进主线。", Color("#b4a5d5"))
		return
	if not _has_dungeon_entry_cost(dungeon_id):
		var cost_text := _dungeon_entry_cost_text(dungeon_id)
		_add_log("%s缺少门票：%s。" % [dungeon_name, cost_text])
		_push_dungeon_feedback("缺少门票 · %s" % dungeon_name, cost_text, Color("#b4a5d5"), 2.15)
		return
	var needed := _dungeon_power_required(dungeon_id)
	var current_power := _hero_power()
	if current_power < needed:
		_add_log("%s打不过：当前战力 %d / 推荐 %d。先训练、强化武器或换上攻击伙伴。" % [
			dungeon_name,
			current_power,
			needed,
		])
		_push_dungeon_feedback("挑战失败 · %s" % dungeon_name, "战力 %d / %d，先去战力页补强。" % [current_power, needed], Color("#b4a5d5"), 2.15)
		_push_reward_popup("战力不足", Vector2(size.x * 0.50, size.y * 0.52), Color("#b4a5d5"), 1.60)
		_start_dungeon_run_animation(dungeon_name, false)
		return

	var boss_id := str(data.get("boss_id", ""))
	if boss_id != "" and DATA.boss(boss_id).is_empty():
		_add_log("%s的 Boss 还没准备好。" % dungeon_name)
		_push_dungeon_feedback("Boss 未开放", "素材或数据还未接入。", Color("#b4a5d5"), 1.80)
		return
	_push_reward_popup("进入 · %s" % dungeon_name, Vector2(size.x * 0.45, size.y * 0.40), Color("#e8dff5"), 1.35)
	_start_dungeon_run_animation(dungeon_name, true)
	_consume_dungeon_entry_cost(dungeon_id)
	if boss_id != "":
		_start_boss_encounter(dungeon_id, boss_id)
		return
	dungeon_attempts[dungeon_id] = _dungeon_attempts_used(dungeon_id) + 1
	dungeon_clears[dungeon_id] = int(dungeon_clears.get(dungeon_id, 0)) + 1
	var reward := _dungeon_reward_preview(dungeon_id)
	_apply_reward(reward)
	attack_pose_timer = 0.32
	hit_flash_timer = 0.22
	slash_timer = ATTACK_SLASH_DURATION
	floating_damage_timer = FLOATING_DAMAGE_DURATION
	last_damage = needed
	_push_dungeon_feedback("通关 · %s" % dungeon_name, "获得 %s，剩余 %d 次。" % [_format_reward(reward), _dungeon_attempts_left(dungeon_id)], Color("#ffd4a3"), 2.15)
	_push_reward_popup(_format_reward(reward), Vector2(size.x * 0.50, size.y * 0.48), Color("#ffd4a3"), 1.75)
	_add_daily_task_progress("dungeons", 1)
	_add_log("挑战%s成功，获得%s。今日剩余 %d 次。" % [
		dungeon_name,
		_format_reward(reward),
		_dungeon_attempts_left(dungeon_id),
	])
	_maybe_add_personal_event_log(0.24)
	_request_content_refresh()

func _start_boss_encounter(dungeon_id: String, boss_id: String) -> void:
	var boss := DATA.boss(boss_id)
	if boss.is_empty():
		return
	boss_active = true
	active_boss_id = boss_id
	active_boss_dungeon_id = dungeon_id
	enemy = boss.duplicate(true)
	enemy_max_hp = _boss_hp_value(boss_id)
	enemy["hp"] = enemy_max_hp
	enemy_hp = enemy_max_hp
	active_boss_saved_hp = enemy_hp
	active_boss_duration = _boss_time_limit(boss_id)
	active_boss_timer = active_boss_duration
	boss_intro_timer = 1.20
	boss_resonance_timer = 0.0
	dungeon_attempts[dungeon_id] = _dungeon_attempts_used(dungeon_id) + 1
	selected_tab = "battle"
	attack_pose_timer = 0.18
	hit_flash_timer = 0.18
	var entry_body := "第二口月泉开始共鸣，击败后结算第二月泪和装备奖励。" if boss_id == "second_moon_warden" else "月泉试炼已开启，击败后结算奖励。"
	var entry_popup := "月泉共鸣" if boss_id == "second_moon_warden" else "Boss 出现"
	_push_dungeon_feedback("Boss 出现 · %s" % str(boss.get("name", boss_id)), entry_body, Color("#ffd4a3"), 2.55)
	_push_reward_popup(entry_popup, Vector2(size.x * 0.52, size.y * 0.42), Color("#ffd4a3"), 1.70)
	_add_log("Boss 试炼开启：%s 出现。门票已消耗，击败后领取奖励。" % str(boss.get("name", boss_id)))
	_request_content_refresh()

func _restore_boss_enemy() -> void:
	var boss := DATA.boss(active_boss_id)
	if boss.is_empty():
		boss_active = false
		active_boss_id = ""
		active_boss_dungeon_id = ""
		active_boss_saved_hp = 0
		active_boss_timer = 0.0
		active_boss_duration = 0.0
		boss_intro_timer = 0.0
		boss_resonance_timer = 0.0
		_spawn_enemy()
		return
	enemy = boss.duplicate(true)
	enemy_max_hp = _boss_hp_value(active_boss_id)
	enemy["hp"] = enemy_max_hp
	enemy_hp = clampi(active_boss_saved_hp if active_boss_saved_hp > 0 else enemy_max_hp, 1, enemy_max_hp)
	active_boss_duration = active_boss_duration if active_boss_duration > 0.0 else _boss_time_limit(active_boss_id)
	active_boss_timer = clampf(active_boss_timer if active_boss_timer > 0.0 else active_boss_duration, 1.0, active_boss_duration)
	if active_boss_id == "second_moon_warden" and _boss_hp_ratio() <= 0.35:
		enemy["resonance_started"] = true

func _defeat_boss() -> void:
	var boss_id := active_boss_id
	var dungeon_id := active_boss_dungeon_id
	var boss := DATA.boss(boss_id)
	var boss_name := str(boss.get("name", "Boss"))
	var reward := _dungeon_reward_preview(dungeon_id)
	xp += int(boss.get("xp", 0))
	while xp >= DATA.xp_to_next(level):
		xp -= DATA.xp_to_next(level)
		level += 1
		_push_reward_popup("Lv.%d" % level, Vector2(size.x * 0.42, size.y * 0.38), Color("#ffd4a3"))
	_apply_reward(reward)
	dungeon_clears[dungeon_id] = int(dungeon_clears.get(dungeon_id, 0)) + 1
	_add_daily_task_progress("dungeons", 1)
	var clear_title := "第二月泉平息" if boss_id == "second_moon_warden" else "击破 · %s" % boss_name
	var clear_body := "第二月泪落入背包，获得 %s。" % _format_reward(reward) if boss_id == "second_moon_warden" else "获得 %s。" % _format_reward(reward)
	boss_active = false
	active_boss_id = ""
	active_boss_dungeon_id = ""
	active_boss_saved_hp = 0
	active_boss_timer = 0.0
	active_boss_duration = 0.0
	boss_intro_timer = 0.0
	boss_resonance_timer = 0.0
	_push_dungeon_feedback(clear_title, clear_body, Color("#ffd4a3"), 2.70)
	_push_reward_popup(_format_reward(reward), Vector2(size.x * 0.50, size.y * 0.45), Color("#ffd4a3"), 1.90)
	_add_log("击败%s，获得%s和 %d 经验。" % [boss_name, _format_reward(reward), int(boss.get("xp", 0))])
	_maybe_add_personal_event_log(0.35)
	_spawn_enemy()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _fail_boss_encounter() -> void:
	if not boss_active:
		return
	var boss_id := active_boss_id
	var boss := DATA.boss(boss_id)
	var boss_name := str(boss.get("name", "Boss"))
	var fail_reward: Dictionary = Dictionary(boss.get("fail_reward", {})).duplicate(true)
	_apply_reward(fail_reward)
	var fail_title := "月泉压制失败" if boss_id == "second_moon_warden" else "试炼失败 · %s" % boss_name
	var fail_body := "第二月泉重新合拢，获得安慰奖励 %s；先补训练、装备或攻击伙伴。" % _format_reward(fail_reward) if boss_id == "second_moon_warden" else "获得安慰奖励 %s；先补训练、武器或攻击伙伴。" % _format_reward(fail_reward)
	boss_active = false
	active_boss_id = ""
	active_boss_dungeon_id = ""
	active_boss_saved_hp = 0
	active_boss_timer = 0.0
	active_boss_duration = 0.0
	boss_intro_timer = 0.0
	boss_resonance_timer = 0.0
	_push_dungeon_feedback(fail_title, fail_body, Color("#b4a5d5"), 2.85)
	_push_reward_popup("试炼失败", Vector2(size.x * 0.50, size.y * 0.42), Color("#b4a5d5"), 1.60)
	_add_log("%s撑过了倒计时，月泉试炼失败。获得安慰奖励%s，建议先补训练、武器或攻击伙伴。" % [boss_name, _format_reward(fail_reward)])
	_spawn_enemy()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _dungeon_reward_preview(dungeon_id: String) -> Dictionary:
	var reward := DATA.dungeon_reward(dungeon_id, stage, talisman_rank)
	return _apply_gold_material_multiplier(reward, _equipment_set_dungeon_multiplier())

func _feed_companion(item_id: String) -> void:
	if not _is_companion_unlocked(item_id):
		_add_log("这个伙伴还没有解锁。")
		return
	if not _can_feed_companion(item_id):
		_add_log("小鱼干不够，喂养需要 %d 个。" % DATA.companion_feed_cost(_companion_level(item_id)))
		return
	var cost := DATA.companion_feed_cost(_companion_level(item_id))
	inventory["小鱼干"] = int(inventory.get("小鱼干", 0)) - cost
	if int(inventory["小鱼干"]) <= 0:
		inventory.erase("小鱼干")
	_set_companion_state_value(item_id, "level", _companion_level(item_id) + 1)
	_set_companion_state_value(item_id, "feed_count", _companion_feed_count(item_id) + 1)
	_set_companion_state_value(item_id, "bond_progress", _companion_bond_progress(item_id) + 1)
	var companion := DATA.companion(item_id)
	_sync_legacy_companion_fields()
	_push_reward_popup("%s Lv.%d" % [str(companion.get("name", "伙伴")), _companion_level(item_id)], Vector2(size.x * 0.50, size.y * 0.54), Color("#ffd4a3"))
	_add_log("喂了 %d 个小鱼干，%s 升到 Lv.%d。" % [cost, str(companion.get("name", "伙伴")), _companion_level(item_id)])
	_hide_detail_overlay()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _buy_training() -> void:
	var cost: int = DATA.training_cost(training_rank)
	if gold < cost:
		_add_log("金币还不够，训练需要 %d 金币。" % cost)
		return
	gold -= cost
	training_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_add_log("训练提升到 %d，自动攻击更快也更疼了。" % training_rank)
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _upgrade_camp() -> void:
	var cost: int = DATA.camp_upgrade_cost(camp_rank)
	if materials < cost:
		_add_log("材料还不够，营地升级需要 %d 个材料。" % cost)
		return
	materials -= cost
	camp_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_add_log("营地升到 %d 级，离线收益和巡逻收益提高。" % camp_rank)
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _upgrade_weapon() -> void:
	if not _is_weapon_unlocked():
		_add_log("再击败 %d 只小怪就能解锁装备。" % maxi(0, 12 - defeated))
		return

	var cost := DATA.weapon_upgrade_cost(weapon_rank)
	var cost_gold := int(cost["gold"])
	var item_name := str(cost["item"])
	var amount := int(cost["amount"])
	if gold < cost_gold:
		_add_log("金币还不够，强化武器需要 %d 金币。" % cost_gold)
		return
	if not _has_item(item_name, amount):
		_add_log("材料还不够，强化武器需要 %s x%d。" % [item_name, amount])
		return

	gold -= cost_gold
	inventory[item_name] = int(inventory.get(item_name, 0)) - amount
	if int(inventory[item_name]) <= 0:
		inventory.erase(item_name)
	weapon_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_push_reward_popup("武器 +1", Vector2(size.x * 0.50, size.y * 0.55), Color("#ffd4a3"))
	_add_log("武器部位强化到 Lv.%d，当前穿戴不会被替换，攻击力提高。" % weapon_rank)
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _upgrade_talisman() -> void:
	if not _is_talisman_unlocked():
		_add_log("营地 1 级或击败 8 只小怪后解锁护符。")
		return

	var cost := DATA.talisman_upgrade_cost(talisman_rank)
	var cost_gold := int(cost["gold"])
	var cost_materials := int(cost["materials"])
	if gold < cost_gold:
		_add_log("金币还不够，强化护符需要 %d 金币。" % cost_gold)
		return
	if materials < cost_materials:
		_add_log("材料还不够，强化护符需要 %d 个材料。" % cost_materials)
		return

	gold -= cost_gold
	materials -= cost_materials
	talisman_rank += 1
	_add_daily_task_progress("upgrades", 1)
	_push_reward_popup("护符 +1", Vector2(size.x * 0.50, size.y * 0.55), Color("#b4a5d5"))
	_add_log("护符部位强化到 Lv.%d，当前护符不会被替换，巡逻和任务收益提高。" % talisman_rank)
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _claim_quest_reward() -> void:
	var claimable := _claimable_quests()
	if claimable <= 0:
		_add_log("当前没有可领取的任务奖励。")
		return

	var gained_gold := 0
	var gained_materials := 0
	for i in range(claimable):
		var milestone := claimed_quests + 1
		var reward := DATA.quest_reward_for_milestone(milestone)
		var quest_gold := int(reward["gold"]) + talisman_rank * 3 + DATA.talisman_awaken_quest_bonus(talisman_awaken_rank) + _companion_quest_gold_bonus()
		gained_gold += int(round(float(quest_gold) * _equipment_set_quest_gold_multiplier()))
		gained_materials += int(reward["materials"]) + _companion_quest_material_bonus()
		claimed_quests += 1

	gold += gained_gold
	materials += gained_materials
	_add_daily_task_progress("quest_rewards", claimable)
	_push_reward_popup("+%dG +%d材" % [gained_gold, gained_materials], Vector2(size.x * 0.50, size.y * 0.56), Color("#ffd4a3"))
	_add_log("领取 %d 个任务奖励，获得 %d 金币和 %d 材料。" % [claimable, gained_gold, gained_materials])
	_maybe_add_personal_event_log(0.35)
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _deal_damage(manual: bool) -> void:
	var base_damage := _hero_damage_value()
	var damage: int = base_damage if not manual else maxi(1, int(round(float(base_damage) * 0.65)))
	var hp_before := enemy_hp
	enemy_hp = maxi(0, enemy_hp - damage)
	if boss_active:
		active_boss_saved_hp = enemy_hp
	last_damage = damage
	attack_pose_timer = 0.32
	hit_flash_timer = 0.22
	slash_timer = ATTACK_SLASH_DURATION
	floating_damage_timer = FLOATING_DAMAGE_DURATION
	if manual:
		_add_log("你补了一击，造成 %d 点伤害。" % damage)
	if boss_active:
		_maybe_trigger_boss_resonance(hp_before)

	if enemy_hp <= 0:
		if boss_active:
			_defeat_boss()
		else:
			_defeat_enemy()
	else:
		_update_ui()

func _defeat_enemy() -> void:
	var gained_gold: int = enemy["gold"]
	var gained_xp: int = enemy["xp"]
	gold += gained_gold
	xp += gained_xp
	defeated += 1
	_add_daily_task_progress("defeats", 1)
	_apply_companion_defeat_reward()

	var drop_chance := clampf(0.65 + _companion_drop_chance_bonus() + _equipment_set_drop_bonus(), 0.0, 0.95)
	if randf() < drop_chance:
		materials += 1
		var drop_name := str(enemy["drop"])
		var drop_amount := 1
		if companion_id == "meimei" and _is_companion_unlocked("meimei") and randf() < 0.28:
			drop_amount += 1
			materials += 1
		if companion_id == "tutu" and _is_companion_unlocked("tutu") and randf() < 0.30:
			materials += 1
			_push_reward_popup("+1材 图图", Vector2(size.x * 0.45, size.y * 0.47), Color("#ffd4a3"))
		_add_item(drop_name, drop_amount)
		_push_reward_popup("+%d %s" % [drop_amount, drop_name], Vector2(size.x * 0.62, size.y * 0.45), Color("#e8dff5"))
		_add_log("击败 %s，获得 %d 金币、%d 经验和 %d 个%s。" % [enemy["name"], gained_gold, gained_xp, drop_amount, drop_name])
	else:
		_push_reward_popup("+%dG +%dXP" % [gained_gold, gained_xp], Vector2(size.x * 0.62, size.y * 0.45), Color("#ffd4a3"))
		_add_log("击败 %s，获得 %d 金币和 %d 经验。" % [enemy["name"], gained_gold, gained_xp])

	while xp >= DATA.xp_to_next(level):
		xp -= DATA.xp_to_next(level)
		level += 1
		_add_log("升级到 Lv.%d，森林更安全了一点。" % level)

	if defeated % 4 == 0:
		stage += 1
		_add_log("推进到第 %d 区，怪物变强，奖励也变多。" % stage)

	_maybe_add_personal_event_log(0.28)
	_spawn_enemy()
	_request_content_refresh()
	_update_ui()
	_save_game(false)

func _spawn_enemy() -> void:
	_sanitize_selected_area()
	enemy = DATA.enemy_for_area(selected_area_id, stage)
	enemy_max_hp = int(enemy["hp"])
	enemy_hp = enemy_max_hp

func _add_item(item_name: String, amount: int) -> void:
	inventory[item_name] = int(inventory.get(item_name, 0)) + amount
	_request_content_refresh()

func _has_item(item_name: String, amount: int) -> bool:
	return int(inventory.get(item_name, 0)) >= amount

func _remove_item(item_name: String, amount: int) -> void:
	inventory[item_name] = int(inventory.get(item_name, 0)) - amount
	if int(inventory[item_name]) <= 0:
		inventory.erase(item_name)
	_request_content_refresh()

func _equipment_key(slot: String, rank: int) -> String:
	return DATA.equipment_id(slot, rank)

func _equipment_count(slot: String, rank: int) -> int:
	return int(equipment_inventory.get(_equipment_key(slot, rank), 0))

func _add_equipment(equipment_id: String, amount: int = 1) -> void:
	if equipment_id == "":
		return
	equipment_inventory[equipment_id] = int(equipment_inventory.get(equipment_id, 0)) + amount
	_request_content_refresh()

func _remove_equipment(equipment_id: String, amount: int = 1) -> void:
	equipment_inventory[equipment_id] = int(equipment_inventory.get(equipment_id, 0)) - amount
	if int(equipment_inventory[equipment_id]) <= 0:
		equipment_inventory.erase(equipment_id)
	_request_content_refresh()

func _ensure_equipment_inventory() -> void:
	if equipment_inventory.is_empty() and not loaded_equipment_inventory:
		for rank in range(0, weapon_rank + 1):
			equipment_inventory[_equipment_key("weapon", rank)] = maxi(1, int(equipment_inventory.get(_equipment_key("weapon", rank), 0)))
		for rank in range(0, talisman_rank + 1):
			equipment_inventory[_equipment_key("talisman", rank)] = maxi(1, int(equipment_inventory.get(_equipment_key("talisman", rank), 0)))
	equipment_inventory[_equipment_key("weapon", equipped_weapon_rank)] = maxi(1, int(equipment_inventory.get(_equipment_key("weapon", equipped_weapon_rank), 0)))
	equipment_inventory[_equipment_key("talisman", equipped_talisman_rank)] = maxi(1, int(equipment_inventory.get(_equipment_key("talisman", equipped_talisman_rank), 0)))

func _owned_equipment_ids(slot_filter: String = "") -> Array[String]:
	_ensure_equipment_inventory()
	var ids: Array[String] = []
	for key in equipment_inventory.keys():
		var equipment_id := str(key)
		if int(equipment_inventory[equipment_id]) <= 0:
			continue
		if slot_filter != "" and DATA.equipment_slot(equipment_id) != slot_filter:
			continue
		ids.append(equipment_id)
	ids.sort_custom(func(a: String, b: String) -> bool:
		var slot_a := DATA.equipment_slot(a)
		var slot_b := DATA.equipment_slot(b)
		if slot_a != slot_b:
			return slot_a > slot_b
		return DATA.equipment_rank(a) > DATA.equipment_rank(b)
	)
	return ids

func _equipped_equipment_id(slot: String) -> String:
	return _equipment_key(slot, equipped_talisman_rank if slot == "talisman" else equipped_weapon_rank)

func _is_weapon_unlocked() -> bool:
	return defeated >= 12 or weapon_rank > 0

func _is_talisman_unlocked() -> bool:
	return camp_rank >= 1 or defeated >= 8 or talisman_rank > 0

func _claimable_quests() -> int:
	return maxi(0, int(defeated / 4) - claimed_quests)

func _ensure_companion_states() -> void:
	for item_id in DATA.companion_ids():
		var state = companion_states.get(item_id, {})
		if typeof(state) != TYPE_DICTIONARY:
			state = {}
		var state_dict := Dictionary(state)
		state_dict["level"] = maxi(1, int(state_dict.get("level", 1)))
		state_dict["bond"] = maxi(0, int(state_dict.get("bond", 0)))
		state_dict["bond_progress"] = maxi(0, int(state_dict.get("bond_progress", 0)))
		state_dict["feed_count"] = maxi(0, int(state_dict.get("feed_count", 0)))
		companion_states[item_id] = state_dict
	if not companion_states.has("xiaomi"):
		companion_states["xiaomi"] = {}
	var xiaomi_state := Dictionary(companion_states["xiaomi"])
	if not loaded_companion_states:
		xiaomi_state["level"] = maxi(int(xiaomi_state.get("level", 1)), companion_level)
		xiaomi_state["bond"] = maxi(int(xiaomi_state.get("bond", 0)), companion_bond)
		xiaomi_state["bond_progress"] = maxi(int(xiaomi_state.get("bond_progress", 0)), companion_bond_progress)
		xiaomi_state["feed_count"] = maxi(int(xiaomi_state.get("feed_count", 0)), companion_feed_count)
	companion_states["xiaomi"] = xiaomi_state
	_sync_legacy_companion_fields()
	loaded_companion_states = true

func _companion_state(item_id: String) -> Dictionary:
	_ensure_companion_state(item_id)
	return Dictionary(companion_states.get(item_id, {}))

func _ensure_companion_state(item_id: String) -> void:
	if companion_states.has(item_id) and typeof(companion_states[item_id]) == TYPE_DICTIONARY:
		return
	companion_states[item_id] = {
		"level": 1,
		"bond": 0,
		"bond_progress": 0,
		"feed_count": 0,
	}

func _set_companion_state_value(item_id: String, key: String, value: int) -> void:
	_ensure_companion_state(item_id)
	var state := Dictionary(companion_states[item_id])
	state[key] = maxi(0, value)
	if key == "level":
		state[key] = maxi(1, value)
	companion_states[item_id] = state

func _companion_level(item_id: String) -> int:
	var state := _companion_state(item_id)
	var value := maxi(1, int(state.get("level", 1)))
	if item_id == "xiaomi" and not loaded_companion_states:
		value = maxi(value, companion_level)
	return value

func _companion_bond(item_id: String) -> int:
	var state := _companion_state(item_id)
	var value := maxi(0, int(state.get("bond", 0)))
	if item_id == "xiaomi" and not loaded_companion_states:
		value = maxi(value, companion_bond)
	return value

func _companion_bond_progress(item_id: String) -> int:
	var state := _companion_state(item_id)
	var value := maxi(0, int(state.get("bond_progress", 0)))
	if item_id == "xiaomi" and not loaded_companion_states:
		value = maxi(value, companion_bond_progress)
	return value

func _companion_feed_count(item_id: String) -> int:
	var state := _companion_state(item_id)
	var value := maxi(0, int(state.get("feed_count", 0)))
	if item_id == "xiaomi" and not loaded_companion_states:
		value = maxi(value, companion_feed_count)
	return value

func _total_companion_feed_count() -> int:
	var total := 0
	for item_id in DATA.companion_ids():
		total += _companion_feed_count(item_id)
	return total

func _sync_legacy_companion_fields() -> void:
	companion_level = _companion_level("xiaomi")
	companion_bond = _companion_bond("xiaomi")
	companion_bond_progress = _companion_bond_progress("xiaomi")
	companion_feed_count = _total_companion_feed_count()

func _is_companion_unlocked(item_id: String) -> bool:
	match item_id:
		"xiaomi":
			return true
		"nico":
			return stage >= 6 or daily_claim_count >= 2
		"little_xiaomi":
			return stage >= 4 or _total_companion_feed_count() >= 1
		"zizi":
			return stage >= 5 or daily_claim_count >= 2
		"meimei":
			return stage >= 10 or _total_companion_feed_count() >= 1
		"tutu":
			return camp_rank >= 1
		"dudu":
			return camp_rank >= 2 or daily_claim_count >= 3
		_:
			return false

func _today_key() -> String:
	var date := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(date["year"]), int(date["month"]), int(date["day"])]

func _can_claim_daily() -> bool:
	return daily_claimed_date != _today_key()

func _reset_daily_tasks_if_needed() -> void:
	var today := _today_key()
	if daily_task_date == today:
		return
	daily_task_date = today
	daily_task_progress.clear()
	daily_task_claimed.clear()

func _add_daily_task_progress(progress_key: String, amount: int = 1) -> void:
	_reset_daily_tasks_if_needed()
	daily_task_progress[progress_key] = maxi(0, int(daily_task_progress.get(progress_key, 0)) + amount)

func _daily_task_progress_value(task_id: String) -> int:
	_reset_daily_tasks_if_needed()
	var task := DATA.daily_task(task_id)
	var progress_key := str(task.get("progress_key", ""))
	return maxi(0, int(daily_task_progress.get(progress_key, 0)))

func _is_daily_task_complete(task_id: String) -> bool:
	var task := DATA.daily_task(task_id)
	if task.is_empty():
		return false
	return _daily_task_progress_value(task_id) >= maxi(1, int(task.get("target", 1)))

func _is_daily_task_claimed(task_id: String) -> bool:
	_reset_daily_tasks_if_needed()
	return bool(daily_task_claimed.get(task_id, false))

func _daily_task_complete_count() -> int:
	var count := 0
	for task_id in DATA.daily_task_ids():
		if _is_daily_task_complete(task_id):
			count += 1
	return count

func _chapter_goal_total_count(goal_id: String) -> int:
	var data := DATA.chapter_goal(goal_id)
	var goals: Array = data.get("goals", [])
	return goals.size()

func _chapter_goal_complete_count(goal_id: String) -> int:
	var data := DATA.chapter_goal(goal_id)
	var goals: Array = data.get("goals", [])
	var count := 0
	for goal in goals:
		var goal_dict: Dictionary = Dictionary(goal)
		if _is_chapter_goal_step_complete(str(goal_dict.get("id", ""))):
			count += 1
	return count

func _is_chapter_goal_step_complete(step_id: String) -> bool:
	match step_id:
		"stage_20":
			return stage >= 20
		"second_moon_clear":
			return int(dungeon_clears.get("second_moon_spring_preview", 0)) >= 1
		"moon_awakening":
			return weapon_awaken_rank > 0 or talisman_awaken_rank > 0
		"chapter_1_claimed":
			return _is_chapter_goal_claimed("chapter_1_moon_camp")
		"stage_24":
			return stage >= 24
		"quiet_moon_patrol_clear":
			return int(dungeon_clears.get("quiet_moon_ridge_patrol", 0)) >= 1
		"moon_awakening_2":
			return weapon_awaken_rank >= 2 or talisman_awaken_rank >= 2
		_:
			return false

func _is_chapter_goal_complete(goal_id: String) -> bool:
	if _is_chapter_goal_claimed(goal_id):
		return true
	var total := _chapter_goal_total_count(goal_id)
	return total > 0 and _chapter_goal_complete_count(goal_id) >= total

func _is_chapter_goal_claimed(goal_id: String) -> bool:
	return bool(chapter_claimed.get(goal_id, false))

func _reset_dungeon_attempts_if_needed() -> void:
	var today := _today_key()
	if dungeon_attempts_date == today:
		return
	dungeon_attempts_date = today
	dungeon_attempts.clear()

func _dungeon_daily_attempts(dungeon_id: String) -> int:
	var data := DATA.dungeon(dungeon_id)
	return maxi(0, int(data.get("daily_attempts", 0)))

func _dungeon_attempts_used(dungeon_id: String) -> int:
	_reset_dungeon_attempts_if_needed()
	return maxi(0, int(dungeon_attempts.get(dungeon_id, 0)))

func _dungeon_attempts_left(dungeon_id: String) -> int:
	return maxi(0, _dungeon_daily_attempts(dungeon_id) - _dungeon_attempts_used(dungeon_id))

func _is_dungeon_preview(dungeon_id: String) -> bool:
	var data := DATA.dungeon(dungeon_id)
	return bool(data.get("preview_only", false))

func _is_boss_dungeon_active(dungeon_id: String) -> bool:
	return boss_active and active_boss_dungeon_id == dungeon_id

func _boss_hp_ratio() -> float:
	return clampf(float(enemy_hp) / float(maxi(1, enemy_max_hp)), 0.0, 1.0)

func _is_second_moon_boss_active() -> bool:
	return boss_active and active_boss_id == "second_moon_warden"

func _maybe_trigger_boss_resonance(hp_before: int) -> void:
	if not _is_second_moon_boss_active():
		return
	if enemy_hp <= 0:
		return
	var before_ratio := clampf(float(hp_before) / float(maxi(1, enemy_max_hp)), 0.0, 1.0)
	if before_ratio <= 0.35 or _boss_hp_ratio() > 0.35:
		return
	enemy["resonance_started"] = true
	boss_resonance_timer = 1.45
	hit_flash_timer = maxf(hit_flash_timer, 0.32)
	slash_timer = maxf(slash_timer, ATTACK_SLASH_DURATION)
	active_boss_timer = minf(active_boss_duration, active_boss_timer + 8.0)
	_push_reward_popup("月泉共鸣", Vector2(size.x * 0.54, size.y * 0.37), Color("#ffd4a3"), 1.55)
	_add_log("第二月泉守望者进入月泉共鸣，倒计时短暂回稳，但已经露出核心。")

func _boss_hp_value(boss_id: String) -> int:
	var boss := DATA.boss(boss_id)
	var base_hp := int(boss.get("hp", 300))
	return maxi(base_hp, int(round(float(base_hp) * (1.0 + maxf(0.0, float(stage - 10)) * 0.08))))

func _boss_time_limit(boss_id: String) -> float:
	var boss := DATA.boss(boss_id)
	return maxf(20.0, float(boss.get("time_limit", 90)))

func _format_time_seconds(seconds: float) -> String:
	var total := maxi(0, int(ceil(seconds)))
	return "%02d:%02d" % [int(total / 60), total % 60]

func _dungeon_required_item(dungeon_id: String) -> String:
	var data := DATA.dungeon(dungeon_id)
	return str(data.get("requires_item", ""))

func _dungeon_required_item_amount(dungeon_id: String) -> int:
	var data := DATA.dungeon(dungeon_id)
	return maxi(0, int(data.get("requires_item_amount", 0)))

func _has_dungeon_entry_cost(dungeon_id: String) -> bool:
	var required_item := _dungeon_required_item(dungeon_id)
	var required_amount := _dungeon_required_item_amount(dungeon_id)
	if required_item.is_empty() or required_amount <= 0:
		return true
	return _has_item(required_item, required_amount)

func _consume_dungeon_entry_cost(dungeon_id: String) -> void:
	var required_item := _dungeon_required_item(dungeon_id)
	var required_amount := _dungeon_required_item_amount(dungeon_id)
	if required_item.is_empty() or required_amount <= 0:
		return
	_remove_item(required_item, required_amount)

func _dungeon_entry_cost_text(dungeon_id: String) -> String:
	var required_item := _dungeon_required_item(dungeon_id)
	var required_amount := _dungeon_required_item_amount(dungeon_id)
	if required_item.is_empty() or required_amount <= 0:
		return "无门票消耗"
	return "%s x%d（持有 x%d）" % [required_item, required_amount, int(inventory.get(required_item, 0))]

func _total_dungeon_clears() -> int:
	var total := 0
	for dungeon_id in dungeon_clears.keys():
		total += maxi(0, int(dungeon_clears[dungeon_id]))
	return total

func _dungeon_power_required(dungeon_id: String) -> int:
	return DATA.dungeon_power_required(dungeon_id, stage)

func _hero_power() -> int:
	return _hero_damage_value() * 2 + level + talisman_rank * 3 + talisman_awaken_rank * 8

func _is_dungeon_unlocked(dungeon_id: String) -> bool:
	var data := DATA.dungeon(dungeon_id)
	if data.is_empty():
		return false
	var required_stage := int(data.get("unlock_stage", 1))
	var required_camp := int(data.get("unlock_camp", 0))
	return stage >= required_stage and camp_rank >= required_camp

func _dungeon_unlock_text(dungeon_id: String) -> String:
	var data := DATA.dungeon(dungeon_id)
	if data.is_empty():
		return "待发现"
	var parts: Array[String] = []
	var required_stage := int(data.get("unlock_stage", 1))
	var required_camp := int(data.get("unlock_camp", 0))
	if required_stage > 1:
		parts.append("推进到第 %d 区" % required_stage)
	if required_camp > 0:
		parts.append("营地 %d 级" % required_camp)
	if parts.is_empty():
		return "默认开放"
	return "，".join(parts)

func _can_feed_companion(item_id: String) -> bool:
	return _has_item("小鱼干", DATA.companion_feed_cost(_companion_level(item_id)))

func _apply_reward(reward: Dictionary) -> void:
	gold += int(reward.get("gold", 0))
	materials += int(reward.get("materials", 0))
	var reward_items = reward.get("items", {})
	if typeof(reward_items) == TYPE_DICTIONARY:
		for item_name in Dictionary(reward_items).keys():
			_add_item(str(item_name), int(reward_items[item_name]))
	var reward_equipment = reward.get("equipment", {})
	if typeof(reward_equipment) == TYPE_DICTIONARY:
		for equipment_id in Dictionary(reward_equipment).keys():
			_add_equipment(str(equipment_id), int(reward_equipment[equipment_id]))

func _format_reward(reward: Dictionary) -> String:
	var parts: Array[String] = []
	var reward_gold := int(reward.get("gold", 0))
	var reward_materials := int(reward.get("materials", 0))
	if reward_gold > 0:
		parts.append("%dG" % reward_gold)
	if reward_materials > 0:
		parts.append("%d材" % reward_materials)
	var reward_items = reward.get("items", {})
	if typeof(reward_items) == TYPE_DICTIONARY:
		var keys := Dictionary(reward_items).keys()
		keys.sort()
		for item_name in keys:
			parts.append("%s x%d" % [str(item_name), int(reward_items[item_name])])
	var reward_equipment = reward.get("equipment", {})
	if typeof(reward_equipment) == TYPE_DICTIONARY:
		var equipment_keys := Dictionary(reward_equipment).keys()
		equipment_keys.sort()
		for equipment_id in equipment_keys:
			parts.append("%s x%d" % [DATA.equipment_name(str(equipment_id)), int(reward_equipment[equipment_id])])
	if parts.is_empty():
		return "一点营地好运"
	return " + ".join(parts)

func _apply_gold_material_multiplier(reward: Dictionary, multiplier: float) -> Dictionary:
	var adjusted := reward.duplicate(true)
	if multiplier <= 1.0:
		return adjusted
	for key in ["gold", "materials"]:
		var value := int(adjusted.get(key, 0))
		if value > 0:
			adjusted[key] = maxi(value, int(round(float(value) * multiplier)))
	return adjusted

func _max_equipment_set_rank() -> int:
	return DATA.EQUIPMENT_SETS.size() - 1

func _equipment_set_piece_data(set_rank: int, piece_kind: String) -> Dictionary:
	var is_weapon := piece_kind == "weapon"
	var equipped_rank := equipped_weapon_rank if is_weapon else equipped_talisman_rank
	var owned := _equipment_count("weapon" if is_weapon else "talisman", set_rank) > 0
	var equipped := equipped_rank >= set_rank
	var state := "已穿戴" if equipped_rank == set_rank else "已满足" if equipped_rank > set_rank else "已拥有" if owned else "缺少"
	return {
		"slot": "武器" if is_weapon else "护符",
		"name": DATA.weapon_name(set_rank) if is_weapon else DATA.talisman_name(set_rank),
		"sprite": DATA.weapon_sprite(set_rank) if is_weapon else DATA.talisman_sprite(set_rank),
		"owned": owned,
		"equipped": equipped,
		"state": state,
	}

func _equipment_set_gallery_status(set_rank: int) -> String:
	if _equipment_set_rank() >= set_rank:
		return "已激活 · %s" % DATA.equipment_set_short_effect(set_rank)
	var blockers := _equipment_set_piece_blockers(set_rank)
	var missing: Array = blockers["missing"]
	var unworn: Array = blockers["unworn"]
	if not missing.is_empty():
		return "缺少：%s" % "、".join(missing)
	if not unworn.is_empty():
		return "可激活：穿戴%s" % "、".join(unworn)
	return "可激活：穿戴同阶部件"

func _equipment_set_activation_text(set_rank: int) -> String:
	var blockers := _equipment_set_piece_blockers(set_rank)
	var missing: Array = blockers["missing"]
	var unworn: Array = blockers["unworn"]
	if missing.is_empty() and unworn.is_empty():
		return "已集齐，穿戴同阶武器和护符即可点亮。"
	var parts: Array[String] = []
	if not missing.is_empty():
		parts.append("缺少%s" % "、".join(missing))
	if not unworn.is_empty():
		parts.append("%s未穿戴" % "、".join(unworn))
	return "尚未激活：%s。" % "；".join(parts)

func _equipment_set_piece_status_line(set_rank: int) -> String:
	var weapon_piece := _equipment_set_piece_data(set_rank, "weapon")
	var talisman_piece := _equipment_set_piece_data(set_rank, "talisman")
	return "%s Lv.%d %s；%s Lv.%d %s" % [
		str(weapon_piece["slot"]),
		set_rank,
		str(weapon_piece["state"]),
		str(talisman_piece["slot"]),
		set_rank,
		str(talisman_piece["state"]),
	]

func _equipment_set_piece_blockers(set_rank: int) -> Dictionary:
	var missing: Array[String] = []
	var unworn: Array[String] = []
	if _equipment_count("weapon", set_rank) <= 0:
		missing.append("武器 Lv.%d" % set_rank)
	elif equipped_weapon_rank < set_rank:
		unworn.append("武器 Lv.%d" % set_rank)
	if _equipment_count("talisman", set_rank) <= 0:
		missing.append("护符 Lv.%d" % set_rank)
	elif equipped_talisman_rank < set_rank:
		unworn.append("护符 Lv.%d" % set_rank)
	return {
		"missing": missing,
		"unworn": unworn,
	}

func _equipment_set_rank() -> int:
	return DATA.equipment_set_rank(equipped_weapon_rank, equipped_talisman_rank)

func _equipment_set_attack_bonus() -> int:
	return 10 if _equipment_set_rank() >= 4 else 0

func _equipment_set_drop_bonus() -> float:
	return 0.07 if _equipment_set_rank() >= 2 else 0.0

func _equipment_set_quest_gold_multiplier() -> float:
	if _equipment_set_rank() >= 4:
		return 1.18
	if _equipment_set_rank() >= 1:
		return 1.12
	return 1.0

func _equipment_set_dungeon_multiplier() -> float:
	if _equipment_set_rank() >= 4:
		return 1.18
	if _equipment_set_rank() >= 3:
		return 1.12
	return 1.0

func _equipment_set_next_text() -> String:
	var set_rank := _equipment_set_rank()
	if set_rank >= 4:
		return "当前已是最高套装词条。"
	var next_rank := set_rank + 1
	return "下一阶：%s，需要同时穿戴武器 Lv.%d + 护符 Lv.%d。" % [
		DATA.equipment_set_name(next_rank),
		next_rank,
		next_rank,
	]

func _equipment_set_requirement_text(rank: int) -> String:
	if rank <= 0:
		return "强化武器和护符到 Lv.1 后，可以激活第一条 2 件套词条。"
	return "搭配另一件 Lv.%d+ 装备，可激活%s：%s" % [
		rank,
		DATA.equipment_set_name(rank),
		DATA.equipment_set_short_effect(rank),
	]

func _hero_damage_value() -> int:
	return DATA.hero_damage(level, training_rank, weapon_rank) + _companion_damage_bonus() + _equipment_set_attack_bonus() + DATA.weapon_awaken_attack_bonus(weapon_awaken_rank)

func _companion_gold_bonus() -> int:
	return _xiaomi_active_gold_bonus() if companion_id == "xiaomi" else _xiaomi_support_gold_bonus() if _is_companion_unlocked("xiaomi") else 0

func _companion_damage_bonus() -> int:
	var bonus := 0
	if companion_id == "nico" and _is_companion_unlocked("nico"):
		bonus += _nico_active_damage_bonus()
	elif _is_companion_unlocked("nico"):
		bonus += _nico_support_damage_bonus()
	if companion_id == "little_xiaomi" and _is_companion_unlocked("little_xiaomi"):
		bonus += _little_xiaomi_active_damage_bonus()
	elif _is_companion_unlocked("little_xiaomi"):
		bonus += _little_xiaomi_support_damage_bonus()
	return bonus

func _nico_active_damage_bonus() -> int:
	return 3 + _companion_level("nico")

func _nico_support_damage_bonus() -> int:
	if not _is_companion_unlocked("nico"):
		return 0
	return 1 + int(_companion_level("nico") / 3)

func _little_xiaomi_active_damage_bonus() -> int:
	return 2 + int(_companion_level("little_xiaomi") / 2)

func _little_xiaomi_support_damage_bonus() -> int:
	if not _is_companion_unlocked("little_xiaomi"):
		return 0
	return 1

func _xiaomi_active_gold_bonus() -> int:
	var bonus: int = DATA.companion_gold_bonus(_companion_level("xiaomi"), _companion_bond("xiaomi"), stage)
	if _has_private_collectible("laifu_relic_bell"):
		bonus += 1
	return bonus

func _xiaomi_support_gold_bonus() -> int:
	if not _is_companion_unlocked("xiaomi"):
		return 0
	var bonus := 1 + int(_companion_bond("xiaomi") / 3)
	if _has_private_collectible("laifu_relic_bell"):
		bonus += 1
	return bonus

func _zizi_active_patrol_bonus() -> int:
	return maxi(2, _companion_level("zizi") + int(stage / 8))

func _zizi_support_patrol_bonus() -> int:
	if not _is_companion_unlocked("zizi"):
		return 0
	return 1 + int(_companion_level("zizi") / 4)

func _companion_patrol_bonus() -> int:
	var bonus := 0
	if companion_id == "zizi" and _is_companion_unlocked("zizi"):
		bonus += _zizi_active_patrol_bonus()
	elif _is_companion_unlocked("zizi"):
		bonus += _zizi_support_patrol_bonus()
	return bonus

func _dudu_active_quest_gold_bonus() -> int:
	return 18 + _companion_level("dudu") * 4

func _dudu_support_quest_gold_bonus() -> int:
	if not _is_companion_unlocked("dudu"):
		return 0
	return 6 + _companion_level("dudu")

func _companion_quest_gold_bonus() -> int:
	if companion_id == "dudu" and _is_companion_unlocked("dudu"):
		return _dudu_active_quest_gold_bonus()
	if _is_companion_unlocked("dudu"):
		return _dudu_support_quest_gold_bonus()
	return 0

func _companion_quest_material_bonus() -> int:
	var bonus := 0
	if companion_id == "dudu" and _is_companion_unlocked("dudu"):
		bonus += 1
	if companion_id != "tutu" and _is_companion_unlocked("tutu"):
		bonus += 1
	return bonus

func _companion_drop_chance_bonus() -> float:
	var bonus := 0.0
	if companion_id == "meimei" and _is_companion_unlocked("meimei"):
		bonus += 0.25
	elif _is_companion_unlocked("meimei"):
		bonus += 0.05
	return bonus

func _camp_patrol_bonus() -> int:
	return 1 if _has_private_collectible("nico_drinker") else 0

func _apply_companion_defeat_reward() -> int:
	var gained_gold := 0
	var active_companion := DATA.companion(companion_id)
	var active_name := str(active_companion.get("name", "伙伴"))
	match companion_id:
		"nico":
			gained_gold += maxi(1, int(_nico_active_damage_bonus() / 2))
		"xiaomi":
			gained_gold += _xiaomi_active_gold_bonus()
		"little_xiaomi":
			if randf() < 0.25:
				var chip_damage := _little_xiaomi_active_damage_bonus()
				enemy_hp = maxi(0, enemy_hp - chip_damage)
				_push_reward_popup("追击 -%d" % chip_damage, Vector2(size.x * 0.45, size.y * 0.43), Color("#ffd4a3"))
		"zizi":
			gained_gold += maxi(1, int(_zizi_active_patrol_bonus() / 2))
		"meimei":
			if randf() < 0.24:
				var drop_name := str(enemy.get("drop", "苔影露珠"))
				_add_item(drop_name, 1)
				materials += 1
				_push_reward_popup("+1 %s" % drop_name, Vector2(size.x * 0.45, size.y * 0.45), Color("#e8dff5"))
		"tutu":
			if randf() < 0.28:
				materials += 1
				_push_reward_popup("+1材 图图", Vector2(size.x * 0.45, size.y * 0.45), Color("#ffd4a3"))
		"dudu":
			gained_gold += maxi(1, int(_dudu_active_quest_gold_bonus() / 4))
		_:
			pass
	if companion_id != "xiaomi" and _is_companion_unlocked("xiaomi"):
		gained_gold += _xiaomi_support_gold_bonus()
	if gained_gold > 0:
		gold += gained_gold
		_push_reward_popup("+%dG %s" % [gained_gold, active_name], Vector2(size.x * 0.43, size.y * 0.45), Color("#ffd4a3"))
	_advance_companion_bond(companion_id)
	if randf() < 0.22:
		_add_log("%s 发动上阵能力：%s。" % [active_name, _companion_active_text(companion_id)])
	return gained_gold

func _advance_companion_bond(item_id: String) -> void:
	if not _is_companion_unlocked(item_id):
		return
	var progress := _companion_bond_progress(item_id) + 1
	var bond := _companion_bond(item_id)
	var needed := DATA.companion_bond_needed(bond)
	if progress >= needed:
		progress = 0
		bond += 1
		var companion := DATA.companion(item_id)
		_add_log("%s 羁绊提升到 %d。" % [str(companion.get("name", "伙伴")), bond])
	_set_companion_state_value(item_id, "bond", bond)
	_set_companion_state_value(item_id, "bond_progress", progress)
	_sync_legacy_companion_fields()

func _format_weapon_cost() -> String:
	var cost := DATA.weapon_upgrade_cost(weapon_rank)
	return "%dG + %s x%d" % [int(cost["gold"]), str(cost["item"]), int(cost["amount"])]

func _format_talisman_cost() -> String:
	var cost := DATA.talisman_upgrade_cost(talisman_rank)
	return "%dG + %d材" % [int(cost["gold"]), int(cost["materials"])]

func _format_weapon_awaken_cost() -> String:
	if _is_weapon_awaken_maxed():
		return "已满级"
	var cost := DATA.weapon_awaken_cost(weapon_awaken_rank)
	var parts: Array[String] = [
		"%dG" % int(cost["gold"]),
		"第二月泪 x%d" % int(cost["tear"]),
		"月露结晶 x%d" % int(cost["crystal"]),
	]
	if int(cost.get("petal", 0)) > 0:
		parts.append("静月花瓣 x%d" % int(cost["petal"]))
	return " + ".join(parts)

func _format_talisman_awaken_cost() -> String:
	if _is_talisman_awaken_maxed():
		return "已满级"
	var cost := DATA.talisman_awaken_cost(talisman_awaken_rank)
	var parts: Array[String] = [
		"%dG" % int(cost["gold"]),
		"第二月泪 x%d" % int(cost["tear"]),
		"%d材" % int(cost["materials"]),
	]
	if int(cost.get("petal", 0)) > 0:
		parts.append("静月花瓣 x%d" % int(cost["petal"]))
	return " + ".join(parts)

func _weapon_awaken_row_subtitle() -> String:
	if not _is_awaken_unlocked():
		return "击败第二月泉守望者后开放。"
	if _is_weapon_awaken_maxed():
		return "攻击 +%d · 已达到当前觉醒上限。" % DATA.weapon_awaken_attack_bonus(weapon_awaken_rank)
	return "攻击 +%d -> +%d · %s · %s" % [
		DATA.weapon_awaken_attack_bonus(weapon_awaken_rank),
		DATA.weapon_awaken_attack_bonus(weapon_awaken_rank + 1),
		_format_weapon_awaken_cost(),
		_weapon_awaken_gap_text(),
	]

func _talisman_awaken_row_subtitle() -> String:
	if not _is_awaken_unlocked():
		return "击败第二月泉守望者后开放。"
	if _is_talisman_awaken_maxed():
		return "巡逻/离线 +%dG，任务 +%dG/次 · 已达到当前觉醒上限。" % [
			DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank),
			DATA.talisman_awaken_quest_bonus(talisman_awaken_rank),
		]
	return "巡逻/离线 +%dG -> +%dG，任务 +%dG/次 -> +%dG/次 · %s · %s" % [
		DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank),
		DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank + 1),
		DATA.talisman_awaken_quest_bonus(talisman_awaken_rank),
		DATA.talisman_awaken_quest_bonus(talisman_awaken_rank + 1),
		_format_talisman_awaken_cost(),
		_talisman_awaken_gap_text(),
	]

func _weapon_awaken_gap_text() -> String:
	if _is_weapon_awaken_maxed():
		return "已满级。"
	var cost := DATA.weapon_awaken_cost(weapon_awaken_rank)
	var missing: Array[String] = []
	if gold < int(cost["gold"]):
		missing.append("%dG" % (int(cost["gold"]) - gold))
	if int(inventory.get("第二月泪", 0)) < int(cost["tear"]):
		missing.append("第二月泪 x%d" % (int(cost["tear"]) - int(inventory.get("第二月泪", 0))))
	if int(inventory.get("月露结晶", 0)) < int(cost["crystal"]):
		missing.append("月露结晶 x%d" % (int(cost["crystal"]) - int(inventory.get("月露结晶", 0))))
	if int(cost.get("petal", 0)) > 0 and int(inventory.get("静月花瓣", 0)) < int(cost["petal"]):
		missing.append("静月花瓣 x%d" % (int(cost["petal"]) - int(inventory.get("静月花瓣", 0))))
	if missing.is_empty():
		return "材料已齐，可觉醒。"
	return "还差%s。" % "、".join(missing)

func _talisman_awaken_gap_text() -> String:
	if _is_talisman_awaken_maxed():
		return "已满级。"
	var cost := DATA.talisman_awaken_cost(talisman_awaken_rank)
	var missing: Array[String] = []
	if gold < int(cost["gold"]):
		missing.append("%dG" % (int(cost["gold"]) - gold))
	if int(inventory.get("第二月泪", 0)) < int(cost["tear"]):
		missing.append("第二月泪 x%d" % (int(cost["tear"]) - int(inventory.get("第二月泪", 0))))
	if materials < int(cost["materials"]):
		missing.append("%d材" % (int(cost["materials"]) - materials))
	if int(cost.get("petal", 0)) > 0 and int(inventory.get("静月花瓣", 0)) < int(cost["petal"]):
		missing.append("静月花瓣 x%d" % (int(cost["petal"]) - int(inventory.get("静月花瓣", 0))))
	if missing.is_empty():
		return "材料已齐，可觉醒。"
	return "还差%s。" % "、".join(missing)

func _weapon_upgrade_preview_text() -> String:
	if not _is_weapon_unlocked():
		return "解锁条件：击败 12 只小怪。"
	var next_rank := weapon_rank + 1
	return "武器部位 Lv.%d -> Lv.%d，攻击 +%d。当前穿戴不自动变成新武器，%s" % [
		weapon_rank,
		next_rank,
		DATA.hero_damage(level, training_rank, next_rank) - DATA.hero_damage(level, training_rank, weapon_rank),
		_weapon_upgrade_gap_text(),
	]

func _weapon_upgrade_gap_text() -> String:
	var cost := DATA.weapon_upgrade_cost(weapon_rank)
	var missing: Array[String] = []
	var cost_gold := int(cost["gold"])
	var item_name := str(cost["item"])
	var amount := int(cost["amount"])
	if gold < cost_gold:
		missing.append("%dG" % (cost_gold - gold))
	var owned := int(inventory.get(item_name, 0))
	if owned < amount:
		missing.append("%s x%d" % [item_name, amount - owned])
	if missing.is_empty():
		return "材料已齐，可强化。"
	return "还差%s。" % "、".join(missing)

func _talisman_upgrade_preview_text() -> String:
	if not _is_talisman_unlocked():
		return "解锁条件：营地 1 级或击败 8 只小怪。"
	var next_rank := talisman_rank + 1
	return "护符部位 Lv.%d -> Lv.%d，巡逻/任务 +1。当前穿戴不自动变成新护符，%s" % [
		talisman_rank,
		next_rank,
		_talisman_upgrade_gap_text(),
	]

func _talisman_upgrade_gap_text() -> String:
	var cost := DATA.talisman_upgrade_cost(talisman_rank)
	var missing: Array[String] = []
	var cost_gold := int(cost["gold"])
	var cost_materials := int(cost["materials"])
	if gold < cost_gold:
		missing.append("%dG" % (cost_gold - gold))
	if materials < cost_materials:
		missing.append("%d材" % (cost_materials - materials))
	if missing.is_empty():
		return "材料已齐，可强化。"
	return "还差%s。" % "、".join(missing)

func _equipment_summary() -> String:
	return "穿戴：%s Lv.%d / %s Lv.%d\n部位强化：武器 Lv.%d / 护符 Lv.%d\n月泉觉醒：武器 Lv.%d / 护符 Lv.%d\n套装：%s（%s）" % [
		DATA.weapon_name(equipped_weapon_rank),
		equipped_weapon_rank,
		DATA.talisman_name(equipped_talisman_rank),
		equipped_talisman_rank,
		weapon_rank,
		talisman_rank,
		weapon_awaken_rank,
		talisman_awaken_rank,
		DATA.equipment_set_name(_equipment_set_rank()),
		DATA.equipment_set_short_effect(_equipment_set_rank()),
	]

func _inventory_summary() -> String:
	var lines: Array[String] = [_equipment_summary()]
	if materials > 0:
		lines.append("营地材料 x%d - 用来升级营地和基础设施。" % materials)
	if inventory.is_empty() and lines.size() == 1:
		lines.append("背包暂无掉落物。击败小怪后会掉落材料。")
	else:
		var keys := inventory.keys()
		keys.sort()
		for key in keys:
			lines.append("%s x%d - %s" % [key, int(inventory[key]), DATA.loot_description(str(key))])
	lines.append(_private_collection_summary())
	return "\n".join(lines)

func _companion_summary() -> String:
	var companion := DATA.companion(companion_id)
	var needed := DATA.companion_bond_needed(_companion_bond(companion_id))
	return "%s Lv.%d  羁绊 %d（%d/%d）\n上阵：%s\n辅助伙伴也会提供小额能力。\n%s\n%s" % [
		str(companion.get("name", "小咪")),
		_companion_level(companion_id),
		_companion_bond(companion_id),
		_companion_bond_progress(companion_id),
		needed,
		_companion_active_text(companion_id),
		str(companion.get("description", "")),
		_private_collection_summary(),
	]

func _companion_progress_text(item_id: String) -> String:
	var companion := DATA.companion(item_id)
	var needed := DATA.companion_bond_needed(_companion_bond(item_id))
	return "当前上阵：%s。羁绊进度：%d/%d。只能上阵 1 个伙伴，其他已解锁伙伴提供辅助能力。" % [
		str(companion.get("name", "伙伴")),
		_companion_bond_progress(item_id),
		needed,
	]

func _private_collection_summary() -> String:
	var lines: Array[String] = ["私人收藏："]
	for item_id in DATA.private_collectible_ids():
		var item := DATA.private_collectible(item_id)
		var status := "已生效" if _has_private_collectible(item_id) else "未解锁"
		var unlock := "" if _has_private_collectible(item_id) else "需%s，" % str(item.get("unlock", ""))
		lines.append("%s [%s] %s%s" % [
			str(item.get("name", item_id)),
			status,
			unlock,
			str(item.get("short_effect", item.get("effect", ""))),
		])
	return "\n".join(lines)

func _sanitize_equipped_title() -> void:
	if not _is_title_unlocked(equipped_title_id):
		equipped_title_id = "camp_adventurer"

func _is_title_unlocked(title_id: String) -> bool:
	match title_id:
		"camp_adventurer":
			return true
		"cat_chosen":
			return _companion_bond("xiaomi") >= 1
		"set_apprentice":
			return _equipment_set_rank() >= 1
		"dungeon_scout":
			return _total_dungeon_clears() >= 1
		"stage_10_witness":
			return stage >= 10
		"daily_keeper":
			return daily_claim_count >= 3
		"moss_moon_clearer":
			return int(dungeon_clears.get("moon_spring_trial", 0)) >= 1
		"stage_20_pathfinder":
			return stage >= 20
		"second_moon_clearer":
			return int(dungeon_clears.get("second_moon_spring_preview", 0)) >= 1
		"moon_awakener":
			return weapon_awaken_rank > 0 or talisman_awaken_rank > 0
		"chapter_1_keeper":
			return _is_chapter_goal_complete("chapter_1_moon_camp")
		"quiet_moon_keeper":
			return _is_chapter_goal_complete("chapter_1_quiet_moon_epilogue")
		_:
			return false

func _title_unlocked_count() -> int:
	var count := 0
	for title_id in DATA.player_title_ids():
		if _is_title_unlocked(title_id):
			count += 1
	return count

func _has_private_collectible(item_id: String) -> bool:
	match item_id:
		"laifu_relic_bell":
			return _companion_bond("xiaomi") >= 1
		"nico_drinker":
			return camp_rank >= 1
		_:
			return false

func _is_album_unlocked(entry_id: String) -> bool:
	match entry_id:
		"camp_arrival":
			return true
		"first_drop":
			return not inventory.is_empty() or materials > 0
		"camp_rank_1":
			return camp_rank >= 1
		"weapon_rank_1":
			return weapon_rank >= 1
		"xiaomi_bond_1":
			return _companion_bond("xiaomi") >= 1
		"daily_3":
			return daily_claim_count >= 3
		"snack_feed":
			return _total_companion_feed_count() >= 1
		"stage_10":
			return stage >= 10
		"laifu_bell":
			return _has_private_collectible("laifu_relic_bell")
		"nico_drinker":
			return _has_private_collectible("nico_drinker")
		"first_dungeon_clear":
			return _total_dungeon_clears() >= 1
		"spore_nest_clear":
			return int(dungeon_clears.get("spore_nest", 0)) >= 1
		"moss_moon_boss_clear":
			return int(dungeon_clears.get("moon_spring_trial", 0)) >= 1
		"stage_20_preview":
			return stage >= 20
		"second_moon_boss_clear":
			return int(dungeon_clears.get("second_moon_spring_preview", 0)) >= 1
		"first_moon_awakening":
			return weapon_awaken_rank > 0 or talisman_awaken_rank > 0
		"chapter_1_clear":
			return _is_chapter_goal_complete("chapter_1_moon_camp")
		"quiet_moon_ridge":
			return stage >= 24
		"quiet_moon_patrol_clear":
			return int(dungeon_clears.get("quiet_moon_ridge_patrol", 0)) >= 1
		"chapter_1_epilogue":
			return _is_chapter_goal_complete("chapter_1_quiet_moon_epilogue")
		_:
			return false

func _album_unlocked_count() -> int:
	var count := 0
	for entry in DATA.album_entries():
		if _is_album_unlocked(str(entry.get("id", ""))):
			count += 1
	return count

func _is_reading_tab() -> bool:
	return selected_tab != "battle"

func _tab_scroll_height() -> int:
	match selected_tab:
		"battle":
			return 52
		"growth":
			return 330
		"dungeon":
			return 360
		"inventory", "companion":
			return 410
		_:
			return 300

func _tab_scene_spacer_height() -> int:
	match selected_tab:
		"battle":
			return 360
		"growth":
			return 132
		"dungeon":
			return 118
		"inventory", "companion":
			return 96
		_:
			return 140

func _configure_layout_for_tab() -> void:
	var show_dungeon_claim := selected_tab == "dungeon" and _claimable_quests() > 0
	_configure_secondary_nav()
	if scene_spacer != null:
		scene_spacer.custom_minimum_size = Vector2(0, _tab_scene_spacer_height())
	if content_scroll != null:
		content_scroll.custom_minimum_size = Vector2(0, _tab_scroll_height())
	if enemy_name_label != null:
		enemy_name_label.visible = false
	if enemy_hp_bar != null:
		enemy_hp_bar.visible = false
	if action_row != null:
		action_row.visible = selected_tab == "battle" or show_dungeon_claim
	if upgrade_row != null:
		upgrade_row.visible = selected_tab == "growth"
	if attack_button != null:
		attack_button.visible = selected_tab == "battle"
	if quest_claim_button != null:
		quest_claim_button.visible = selected_tab == "battle" or show_dungeon_claim
	if save_button != null:
		save_button.visible = selected_tab == "battle"
	if log_label != null:
		log_label.custom_minimum_size = Vector2(0, 58 if selected_tab == "battle" else 24)
		log_label.visible = selected_tab in ["battle", "growth", "dungeon"]

func _sync_log_label() -> void:
	if log_label == null:
		return
	if selected_tab == "battle":
		log_label.text = "\n".join(recent_logs)
	elif recent_logs.is_empty():
		log_label.text = ""
	else:
		log_label.text = recent_logs[0]

func _update_ui() -> void:
	if enemy_name_label == null:
		return

	_configure_layout_for_tab()
	_sanitize_equipped_title()

	hero_label.text = "Lv.%d  %s" % [level, DATA.player_title_name(equipped_title_id)]
	gold_value_label.text = str(gold)
	material_value_label.text = str(materials)
	training_value_label.text = str(training_rank)
	camp_value_label.text = str(camp_rank)
	weapon_value_label.text = str(weapon_rank)
	stage_value_label.text = str(stage)

	xp_bar.max_value = DATA.xp_to_next(level)
	xp_bar.value = xp

	enemy_name_label.text = "%s   HP %d / %d" % [enemy["name"], enemy_hp, enemy_max_hp]
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp

	var cost: int = DATA.training_cost(training_rank)
	upgrade_button.text = "训练 %dG" % cost
	upgrade_button.disabled = gold < cost
	var camp_cost: int = DATA.camp_upgrade_cost(camp_rank)
	camp_button.text = "营地 %d材" % camp_cost
	camp_button.disabled = materials < camp_cost
	weapon_button.text = "武器锁定" if not _is_weapon_unlocked() else "武器强化"
	weapon_button.disabled = not _can_upgrade_weapon()
	talisman_button.text = "护符锁定" if not _is_talisman_unlocked() else "护符强化"
	talisman_button.disabled = not _can_upgrade_talisman()
	var claimable_quests := _claimable_quests()
	quest_claim_button.text = "领奖 x%d" % claimable_quests if claimable_quests > 0 else "领奖"
	quest_claim_button.disabled = claimable_quests <= 0

	if content_dirty or last_rendered_tab != selected_tab:
		_render_tab_content()
		last_rendered_tab = selected_tab
		content_dirty = false

	_sync_log_label()

func _add_log(message: String) -> void:
	recent_logs.push_front(message)
	while recent_logs.size() > 4:
		recent_logs.pop_back()
	_sync_log_label()

func _maybe_add_personal_event_log(chance: float) -> void:
	if randf() > chance:
		return
	var message := DATA.personal_event_log()
	if message != "":
		_add_log(message)

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return

	level = int(data.get("level", level))
	xp = int(data.get("xp", xp))
	gold = int(data.get("gold", gold))
	materials = int(data.get("materials", materials))
	stage = int(data.get("stage", stage))
	defeated = int(data.get("defeated", defeated))
	claimed_quests = int(data.get("claimed_quests", claimed_quests))
	training_rank = int(data.get("training_rank", training_rank))
	camp_rank = int(data.get("camp_rank", camp_rank))
	weapon_rank = int(data.get("weapon_rank", weapon_rank))
	talisman_rank = int(data.get("talisman_rank", talisman_rank))
	weapon_awaken_rank = clampi(int(data.get("weapon_awaken_rank", weapon_awaken_rank)), 0, DATA.equipment_awaken_max_rank())
	talisman_awaken_rank = clampi(int(data.get("talisman_awaken_rank", talisman_awaken_rank)), 0, DATA.equipment_awaken_max_rank())
	equipped_weapon_rank = clampi(int(data.get("equipped_weapon_rank", weapon_rank)), 0, weapon_rank)
	equipped_talisman_rank = clampi(int(data.get("equipped_talisman_rank", talisman_rank)), 0, talisman_rank)
	companion_id = str(data.get("companion_id", companion_id))
	companion_level = int(data.get("companion_level", companion_level))
	companion_bond = int(data.get("companion_bond", companion_bond))
	companion_bond_progress = int(data.get("companion_bond_progress", companion_bond_progress))
	companion_feed_count = int(data.get("companion_feed_count", companion_feed_count))
	var saved_companion_states = data.get("companion_states", {})
	if typeof(saved_companion_states) == TYPE_DICTIONARY:
		companion_states = Dictionary(saved_companion_states).duplicate(true)
		loaded_companion_states = not companion_states.is_empty()
	_ensure_companion_states()
	equipped_title_id = str(data.get("equipped_title_id", equipped_title_id))
	_sanitize_equipped_title()
	selected_area_id = str(data.get("selected_area_id", selected_area_id))
	inventory_section = str(data.get("inventory_section", inventory_section))
	companion_section = str(data.get("companion_section", companion_section))
	if inventory_section not in ["equipment", "items", "collectibles"]:
		inventory_section = "equipment"
	if companion_section not in ["companions", "titles", "album"]:
		companion_section = "companions"
	daily_claimed_date = str(data.get("daily_claimed_date", daily_claimed_date))
	daily_cycle_day = int(data.get("daily_cycle_day", daily_cycle_day)) % DATA.daily_reward_count()
	daily_claim_count = int(data.get("daily_claim_count", daily_claim_count))
	daily_task_date = str(data.get("daily_task_date", daily_task_date))
	var saved_daily_task_progress = data.get("daily_task_progress", {})
	if typeof(saved_daily_task_progress) == TYPE_DICTIONARY:
		daily_task_progress = Dictionary(saved_daily_task_progress).duplicate(true)
	var saved_daily_task_claimed = data.get("daily_task_claimed", {})
	if typeof(saved_daily_task_claimed) == TYPE_DICTIONARY:
		daily_task_claimed = Dictionary(saved_daily_task_claimed).duplicate(true)
	var saved_chapter_claimed = data.get("chapter_claimed", {})
	if typeof(saved_chapter_claimed) == TYPE_DICTIONARY:
		chapter_claimed = Dictionary(saved_chapter_claimed).duplicate(true)
	_reset_daily_tasks_if_needed()
	dungeon_attempts_date = str(data.get("dungeon_attempts_date", dungeon_attempts_date))
	var saved_dungeon_attempts = data.get("dungeon_attempts", {})
	if typeof(saved_dungeon_attempts) == TYPE_DICTIONARY:
		dungeon_attempts = Dictionary(saved_dungeon_attempts).duplicate(true)
	var saved_dungeon_clears = data.get("dungeon_clears", {})
	if typeof(saved_dungeon_clears) == TYPE_DICTIONARY:
		dungeon_clears = Dictionary(saved_dungeon_clears).duplicate(true)
	_reset_dungeon_attempts_if_needed()
	var saved_inventory = data.get("inventory", {})
	if typeof(saved_inventory) == TYPE_DICTIONARY:
		inventory = saved_inventory.duplicate(true)
	var saved_equipment_inventory = data.get("equipment_inventory", {})
	if typeof(saved_equipment_inventory) == TYPE_DICTIONARY:
		equipment_inventory = Dictionary(saved_equipment_inventory).duplicate(true)
		loaded_equipment_inventory = not equipment_inventory.is_empty()
	_ensure_equipment_inventory()
	boss_active = bool(data.get("boss_active", boss_active))
	active_boss_id = str(data.get("active_boss_id", active_boss_id))
	active_boss_dungeon_id = str(data.get("active_boss_dungeon_id", active_boss_dungeon_id))
	active_boss_saved_hp = int(data.get("active_boss_hp", active_boss_saved_hp))
	active_boss_timer = float(data.get("active_boss_timer", active_boss_timer))
	active_boss_duration = float(data.get("active_boss_duration", active_boss_duration))
	if boss_active and (active_boss_id == "" or active_boss_dungeon_id == "" or DATA.boss(active_boss_id).is_empty()):
		boss_active = false
		active_boss_id = ""
		active_boss_dungeon_id = ""
		active_boss_saved_hp = 0
		active_boss_timer = 0.0
		active_boss_duration = 0.0

	var last_seen := int(data.get("last_seen", 0))
	var now := int(Time.get_unix_time_from_system())
	if last_seen > 0 and now > last_seen:
		var elapsed_seconds := now - last_seen
		if boss_active:
			active_boss_timer = maxf(0.0, active_boss_timer - float(elapsed_seconds))
			if active_boss_timer <= 0.0:
				var boss := DATA.boss(active_boss_id)
				var boss_name := str(boss.get("name", "Boss"))
				var fail_reward: Dictionary = Dictionary(boss.get("fail_reward", {})).duplicate(true)
				_apply_reward(fail_reward)
				boss_active = false
				active_boss_id = ""
				active_boss_dungeon_id = ""
				active_boss_saved_hp = 0
				active_boss_timer = 0.0
				active_boss_duration = 0.0
				pending_offline_message = "离线期间%s撑过倒计时，试炼失败；获得安慰奖励%s。" % [boss_name, _format_reward(fail_reward)]
		var offline_minutes := mini(360, int(elapsed_seconds / 60))
		if offline_minutes > 0:
			var income: int = offline_minutes * (DATA.offline_gold_per_minute(level, stage, training_rank) + camp_rank + talisman_rank + DATA.talisman_awaken_patrol_bonus(talisman_awaken_rank) + _camp_patrol_bonus() + _companion_patrol_bonus())
			gold += income
			var income_message := "离线 %d 分钟，营地收获 %d 金币。" % [offline_minutes, income]
			pending_offline_message = "%s\n%s" % [pending_offline_message, income_message] if pending_offline_message != "" else income_message

func _save_game(show_log: bool) -> void:
	if not save_enabled:
		if show_log:
			_add_log("测试模式未写入存档。")
		return
	_ensure_companion_states()
	_ensure_equipment_inventory()
	_reset_daily_tasks_if_needed()
	_reset_dungeon_attempts_if_needed()

	var payload := {
		"level": level,
		"xp": xp,
		"gold": gold,
		"materials": materials,
		"stage": stage,
		"defeated": defeated,
		"claimed_quests": claimed_quests,
		"training_rank": training_rank,
		"camp_rank": camp_rank,
		"weapon_rank": weapon_rank,
		"talisman_rank": talisman_rank,
		"weapon_awaken_rank": weapon_awaken_rank,
		"talisman_awaken_rank": talisman_awaken_rank,
		"equipped_weapon_rank": equipped_weapon_rank,
		"equipped_talisman_rank": equipped_talisman_rank,
		"companion_id": companion_id,
		"companion_level": companion_level,
		"companion_bond": companion_bond,
		"companion_bond_progress": companion_bond_progress,
		"companion_feed_count": companion_feed_count,
		"companion_states": companion_states,
		"equipped_title_id": equipped_title_id,
		"selected_area_id": selected_area_id,
		"inventory_section": inventory_section,
		"companion_section": companion_section,
		"daily_claimed_date": daily_claimed_date,
		"daily_cycle_day": daily_cycle_day,
		"daily_claim_count": daily_claim_count,
		"daily_task_date": daily_task_date,
		"daily_task_progress": daily_task_progress,
		"daily_task_claimed": daily_task_claimed,
		"chapter_claimed": chapter_claimed,
		"dungeon_attempts_date": dungeon_attempts_date,
		"dungeon_attempts": dungeon_attempts,
		"dungeon_clears": dungeon_clears,
		"inventory": inventory,
		"equipment_inventory": equipment_inventory,
		"boss_active": boss_active,
		"active_boss_id": active_boss_id,
		"active_boss_dungeon_id": active_boss_dungeon_id,
		"active_boss_hp": enemy_hp if boss_active else 0,
		"active_boss_timer": active_boss_timer if boss_active else 0.0,
		"active_boss_duration": active_boss_duration if boss_active else 0.0,
		"last_seen": int(Time.get_unix_time_from_system()),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_add_log("保存失败：无法写入本地存档。")
		return
	file.store_string(JSON.stringify(payload))
	if show_log:
		_add_log("已保存。")

func _draw_moon(center: Vector2, pixel: int) -> void:
	var cream := Color("#f8e4b5")
	var pink := Color("#f3b4b8")
	var lavender := Color("#b7a1d4")
	for y in range(-3, 4):
		for x in range(-3, 4):
			if Vector2(x, y).length() <= 3.2:
				var color := cream
				if (x == 1 and y == -1) or (x == -2 and y == 1):
					color = pink
				elif x == 2 and y == 1:
					color = lavender
				draw_rect(Rect2(center + Vector2(x * pixel, y * pixel), Vector2(pixel, pixel)), color)

func _draw_stars(w: float, scene_h: float) -> void:
	var star_color := Color("#f7d7ae")
	for i in range(9):
		var x := 22 + i * 39
		var y := 38 + int(i * 23) % int(scene_h * 0.35)
		draw_rect(Rect2(x, y, 3, 3), star_color)

func _draw_tree_line(w: float, scene_h: float) -> void:
	for i in range(-1, 10):
		var x := float(i * 46 + 12)
		var base_y := scene_h * 0.74 + float((i % 3) * 8)
		draw_rect(Rect2(x + 14, base_y - 20, 10, 34), Color("#5d3e2e"))
		draw_rect(Rect2(x, base_y - 50, 38, 20), Color("#2e5b43"))
		draw_rect(Rect2(x + 6, base_y - 66, 26, 18), Color("#47704a"))
		draw_rect(Rect2(x + 10, base_y - 76, 18, 14), Color("#6d8555"))

func _battle_scene_height() -> float:
	return size.y * 0.58

func _battle_hero_pos() -> Vector2:
	return Vector2(size.x * 0.34, _battle_scene_height() - 86)

func _battle_companion_bottom_center() -> Vector2:
	return _battle_hero_pos() + Vector2(-96, 62)

func _battle_companion_rect() -> Rect2:
	var center := _battle_companion_bottom_center()
	return Rect2(center + Vector2(-28, -52), Vector2(56, 62))

func _battle_status_rect() -> Rect2:
	var overlay_height := 58.0 if boss_active else 44.0
	return Rect2(Vector2(24, 104), Vector2(size.x - 48, overlay_height))

func _battle_map_rect(status_rect: Rect2 = Rect2()) -> Rect2:
	var base := status_rect if status_rect.size.x > 0.0 else _battle_status_rect()
	return Rect2(Vector2(base.position.x, base.position.y + base.size.y + 6.0), Vector2(base.size.x, 92.0))

func _current_battle_area() -> Dictionary:
	_sanitize_selected_area()
	return DATA.battle_area(selected_area_id)

func _sanitize_selected_area() -> void:
	if not DATA.battle_area_exists(selected_area_id) or not _is_battle_area_unlocked(selected_area_id):
		selected_area_id = DATA.default_battle_area_id()

func _is_battle_area_unlocked(area_id: String) -> bool:
	var area := DATA.battle_area(area_id)
	if area.is_empty():
		return false
	return stage >= int(area.get("unlock_stage", 1))

func _battle_area_node_pos(area: Dictionary, map_rect: Rect2) -> Vector2:
	var map_x := clampf(float(area.get("map_x", 0.5)), 0.08, 0.92)
	var map_y := clampf(float(area.get("map_y", 0.62)), 0.28, 0.82)
	return map_rect.position + Vector2(map_rect.size.x * map_x, map_rect.size.y * map_y)

func _battle_area_at_position(pos: Vector2) -> String:
	if boss_active:
		return ""
	var map_rect := _battle_map_rect()
	if not map_rect.grow(10.0).has_point(pos):
		return ""
	for area in DATA.battle_areas():
		var area_id := str(area.get("id", ""))
		var node_pos := _battle_area_node_pos(area, map_rect)
		if pos.distance_to(node_pos) <= 18.0:
			return area_id
	return ""

func _update_battle_hover() -> void:
	var next_hover := ""
	if selected_tab == "battle" and detail_overlay != null and not detail_overlay.visible:
		next_hover = _battle_area_at_position(get_local_mouse_position())
	if next_hover != hovered_area_id:
		hovered_area_id = next_hover
		queue_redraw()

func _select_battle_area(area_id: String) -> void:
	if not DATA.battle_area_exists(area_id):
		return
	var area := DATA.battle_area(area_id)
	if not _is_battle_area_unlocked(area_id):
		_add_log("%s还没开放：需要推进到第 %d 区。" % [str(area.get("name", "区域")), int(area.get("unlock_stage", 1))])
		return
	selected_area_id = area_id
	_spawn_enemy()
	_request_content_refresh()
	_add_log("开始在%s挂机，主要掉落%s。" % [str(area.get("name", "区域")), str(area.get("drop", "材料"))])
	_update_ui()
	_save_game(false)

func _companion_selector_detail() -> Dictionary:
	var companion := DATA.companion(companion_id)
	return {
		"kind": "companion_selector",
		"title": "更换上阵伙伴",
		"type": "伙伴 / 上阵选择",
		"sprite": str(companion.get("sprite", "")),
		"description": "当前上阵：%s。只能上阵 1 个伙伴，其余已解锁伙伴提供辅助能力。" % str(companion.get("name", "伙伴")),
		"effect": "当前上阵能力：%s\n当前辅助收益仍会结算已解锁伙伴的辅助能力。" % _companion_active_text(companion_id),
	}

func _draw_hero(pos: Vector2) -> void:
	var texture_key := "hero_attack" if attack_pose_timer > 0.0 else "hero_idle"
	var texture: Texture2D = sprite_textures.get(texture_key)
	if texture != null:
		var texture_bob := int(sin(visual_time * 5.0) * 2.0)
		var x_offset := 10.0 if attack_pose_timer > 0.0 else 0.0
		_draw_sprite_bottom_center(texture, pos + Vector2(x_offset, 54 + texture_bob), 90.0)
		return

	var bob := int(sin(visual_time * 5.0) * 2.0)
	pos.y += bob
	draw_rect(Rect2(pos.x - 12, pos.y - 22, 24, 20), Color("#f2cfa3"))
	draw_rect(Rect2(pos.x - 16, pos.y - 4, 32, 30), Color("#506b9d"))
	draw_rect(Rect2(pos.x - 20, pos.y + 20, 14, 16), Color("#2d2440"))
	draw_rect(Rect2(pos.x + 6, pos.y + 20, 14, 16), Color("#2d2440"))
	draw_rect(Rect2(pos.x - 7, pos.y - 12, 4, 4), Color("#17152a"))
	draw_rect(Rect2(pos.x + 5, pos.y - 12, 4, 4), Color("#17152a"))
	draw_rect(Rect2(pos.x + 16, pos.y + 1, 18, 6), Color("#f1d6a0"))

func _draw_active_companion(pos: Vector2) -> void:
	if companion_id == "" or not _is_companion_unlocked(companion_id):
		return
	var companion := DATA.companion(companion_id)
	var bob := int(sin(visual_time * 4.2 + 0.8) * 2.0)
	pos.y += bob
	var texture_key := str(companion.get("sprite", ""))
	var texture: Texture2D = sprite_textures.get(texture_key)
	if texture == null:
		return
	var shadow := Color(0.05, 0.04, 0.10, 0.38)
	draw_rect(Rect2(pos.x - 14, pos.y + 16, 28, 5), shadow)
	_draw_sprite_bottom_center(texture, pos + Vector2(0, 18), 38.0, Color.WHITE, true)
	var click_rect := _battle_companion_rect()
	if selected_tab == "battle" and click_rect.has_point(get_local_mouse_position()):
		var companion_hover_fill := Color("#ffd4a3")
		companion_hover_fill.a = 0.16
		var companion_hover_border := Color("#ffd4a3")
		companion_hover_border.a = 0.74
		draw_rect(click_rect, companion_hover_fill)
		draw_rect(click_rect, companion_hover_border, false, 2.0)

func _draw_boss_presence(pos: Vector2) -> void:
	if not _is_second_moon_boss_active():
		return
	var center := pos + Vector2(0, -18)
	var intro_alpha := clampf(boss_intro_timer / 1.20, 0.0, 1.0)
	var resonance_alpha := clampf(boss_resonance_timer / 1.45, 0.0, 1.0)
	var low_hp_alpha := 0.34 if bool(enemy.get("resonance_started", false)) else 0.0
	var pulse := 0.5 + 0.5 * sin(visual_time * 7.0)
	var base_alpha := maxf(maxf(intro_alpha * 0.62, resonance_alpha * 0.82), low_hp_alpha * (0.72 + pulse * 0.28))
	if base_alpha <= 0.0:
		return
	var moon := Color(0.96, 0.82, 1.0, base_alpha)
	var cream := Color(1.0, 0.90, 0.62, base_alpha * 0.62)
	var shadow := Color(0.28, 0.18, 0.44, base_alpha * 0.32)
	draw_arc(center, 58.0 + pulse * 6.0, deg_to_rad(18.0), deg_to_rad(342.0), 28, shadow, 5.0)
	draw_arc(center, 47.0 + pulse * 4.0, deg_to_rad(210.0), deg_to_rad(510.0), 26, moon, 3.0)
	draw_arc(center + Vector2(0, 3), 34.0 + pulse * 3.0, deg_to_rad(34.0), deg_to_rad(286.0), 24, cream, 2.0)
	for i in range(6):
		var angle := visual_time * 1.7 + float(i) * TAU / 6.0
		var radius := 42.0 + 8.0 * sin(visual_time * 2.6 + float(i))
		var spark_pos := center + Vector2(cos(angle), sin(angle)) * radius
		_draw_pixel_spark(spark_pos, Color(1.0, 0.86, 0.64, base_alpha), 3.0)

func _draw_enemy(pos: Vector2) -> void:
	var sprite_key := str(enemy.get("sprite", "enemy_moss_slime"))
	var texture: Texture2D = sprite_textures.get(sprite_key)
	if texture != null:
		var texture_bob := int(sin(visual_time * 3.6 + 1.4) * 3.0)
		var hit_offset := 3.0 if hit_flash_timer > 0.0 else 0.0
		var modulate := Color(1.0, 0.82, 0.82, 1.0) if hit_flash_timer > 0.0 else Color.WHITE
		if _is_second_moon_boss_active() and bool(enemy.get("resonance_started", false)):
			modulate = Color(1.08, 0.94, 1.14, 1.0) if hit_flash_timer <= 0.0 else Color(1.18, 0.82, 1.02, 1.0)
		var target_height := float(enemy.get("draw_height", 76.0))
		var y_offset := float(enemy.get("draw_y_offset", 50.0))
		_draw_sprite_bottom_center(texture, pos + Vector2(hit_offset, y_offset + texture_bob), target_height, modulate)
		return

	var bob := int(sin(visual_time * 3.6 + 1.4) * 3.0)
	pos.y += bob
	var body_color := Color(str(enemy.get("color", "#78a66a")))
	draw_rect(Rect2(pos.x - 23, pos.y - 10, 46, 30), body_color)
	draw_rect(Rect2(pos.x - 15, pos.y - 24, 30, 18), body_color.lightened(0.12))
	draw_rect(Rect2(pos.x - 10, pos.y - 12, 5, 5), Color("#17152a"))
	draw_rect(Rect2(pos.x + 7, pos.y - 12, 5, 5), Color("#17152a"))
	draw_rect(Rect2(pos.x - 16, pos.y + 18, 14, 8), body_color.darkened(0.18))
	draw_rect(Rect2(pos.x + 4, pos.y + 18, 18, 8), body_color.darkened(0.18))

func _draw_enemy_status_overlay() -> void:
	if selected_tab != "battle" or enemy.is_empty():
		return
	var overlay_rect := _battle_status_rect()
	var hp_ratio := clampf(float(enemy_hp) / float(maxi(1, enemy_max_hp)), 0.0, 1.0)
	draw_rect(overlay_rect, Color(0.08, 0.08, 0.16, 0.86))
	draw_rect(overlay_rect, Color("#05040c"), false, 3.0)
	var font := get_theme_default_font()
	var title := "%s   HP %d / %d" % [str(enemy.get("name", "小怪")), enemy_hp, enemy_max_hp]
	if boss_active:
		title = "%s   HP %d / %d   %s" % [str(enemy.get("name", "Boss")), enemy_hp, enemy_max_hp, _format_time_seconds(active_boss_timer)]
		if _is_second_moon_boss_active() and bool(enemy.get("resonance_started", false)):
			title = "%s   共鸣   HP %d / %d   %s" % [str(enemy.get("name", "Boss")), enemy_hp, enemy_max_hp, _format_time_seconds(active_boss_timer)]
	draw_string(font, overlay_rect.position + Vector2(10, 18), title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("#fef9ef"))
	var bar_rect := Rect2(overlay_rect.position + Vector2(10, 27), Vector2(overlay_rect.size.x - 20, 9))
	draw_rect(bar_rect, Color("#2a2a4e"))
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * hp_ratio, bar_rect.size.y)), Color("#ffb5c0"))
	draw_rect(bar_rect, Color("#100f1e"), false, 1.0)
	if boss_active:
		var time_ratio := clampf(active_boss_timer / maxf(1.0, active_boss_duration), 0.0, 1.0)
		var time_bar_rect := Rect2(overlay_rect.position + Vector2(10, 42), Vector2(overlay_rect.size.x - 20, 7))
		draw_rect(time_bar_rect, Color("#302442"))
		draw_rect(Rect2(time_bar_rect.position, Vector2(time_bar_rect.size.x * time_ratio, time_bar_rect.size.y)), Color("#ffd4a3"))
		draw_rect(time_bar_rect, Color("#100f1e"), false, 1.0)
	if not boss_active:
		_draw_battle_area_map(overlay_rect)

func _draw_battle_area_map(status_rect: Rect2) -> void:
	var map_rect := _battle_map_rect(status_rect)
	var texture: Texture2D = sprite_textures.get("battle_area_map")
	if texture != null:
		_draw_texture_rect_pixel(texture, map_rect, Color(1, 1, 1, 0.92))
	else:
		var fallback_map_color := Color("#11172d")
		fallback_map_color.a = 0.92
		draw_rect(map_rect, fallback_map_color)
	draw_rect(map_rect, Color(0.03, 0.03, 0.08, 0.18))
	draw_rect(map_rect, Color("#05040c"), false, 3.0)
	var current_area := _current_battle_area()
	var current_name := str(current_area.get("name", "月森营地"))
	var current_drop := str(enemy.get("drop", current_area.get("drop", "材料")))
	var font := get_theme_default_font()
	draw_string(font, map_rect.position + Vector2(9, 14), "挂机：%s" % current_name, HORIZONTAL_ALIGNMENT_LEFT, map_rect.size.x - 18.0, 10, Color("#fef9ef"))
	draw_string(font, map_rect.position + Vector2(9, 28), "掉落：%s" % current_drop, HORIZONTAL_ALIGNMENT_LEFT, map_rect.size.x - 18.0, 10, Color("#ffd4a3"))
	var previous_pos := Vector2.INF
	for area in DATA.battle_areas():
		var node_pos := _battle_area_node_pos(area, map_rect)
		if previous_pos != Vector2.INF:
			draw_line(previous_pos, node_pos, Color(1.0, 0.84, 0.58, 0.38), 2.0)
		previous_pos = node_pos
	for area in DATA.battle_areas():
		var area_id := str(area.get("id", ""))
		var node_pos := _battle_area_node_pos(area, map_rect)
		var unlocked := _is_battle_area_unlocked(area_id)
		var selected := area_id == selected_area_id
		var hovered := area_id == hovered_area_id
		var node_color := Color("#ffd4a3") if selected else Color("#8ccf9f") if unlocked else Color("#5b536e")
		var bg_color := Color("#251b2d") if selected else Color("#16213e") if unlocked else Color("#11111f")
		var half := 5.0 if not selected else 6.0
		draw_rect(Rect2(node_pos - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), bg_color)
		draw_rect(Rect2(node_pos - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), node_color, false, 2.0 if selected or hovered else 1.0)
		if hovered and unlocked:
			draw_rect(Rect2(node_pos - Vector2(10, 10), Vector2(20, 20)), Color(1.0, 0.82, 0.46, 0.20))
		var label_color := Color("#fef9ef") if selected else Color("#d8ccec") if unlocked else Color("#817296")
		draw_string(font, node_pos + Vector2(-25, 18), str(area.get("short", area.get("name", ""))), HORIZONTAL_ALIGNMENT_CENTER, 50.0, 9, label_color)

func _draw_texture_rect_pixel(texture: Texture2D, rect: Rect2, modulate: Color = Color.WHITE, flip_x: bool = false) -> void:
	if flip_x:
		draw_set_transform(rect.position + Vector2(rect.size.x, 0), 0.0, Vector2(-1, 1))
		draw_texture_rect(texture, Rect2(Vector2.ZERO, rect.size), false, modulate)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(texture, rect, false, modulate)

func _draw_sprite_bottom_center(texture: Texture2D, bottom_center: Vector2, target_height: float, modulate: Color = Color.WHITE, flip_x: bool = false) -> void:
	var source_size := texture.get_size()
	if source_size.y <= 0.0:
		return
	var scale := target_height / source_size.y
	var target_size := source_size * scale
	var rect := Rect2(
		bottom_center.x - target_size.x * 0.5,
		bottom_center.y - target_size.y,
		target_size.x,
		target_size.y
	)
	_draw_texture_rect_pixel(texture, rect, modulate, flip_x)

func _quadratic_bezier_point(start: Vector2, control: Vector2, end: Vector2, t: float) -> Vector2:
	var inv := 1.0 - t
	return start * inv * inv + control * 2.0 * inv * t + end * t * t

func _quadratic_bezier_points(start: Vector2, control: Vector2, end: Vector2, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		points.append(_quadratic_bezier_point(start, control, end, t))
	return points

func _draw_pixel_spark(center: Vector2, color: Color, size: float) -> void:
	var core := Vector2(size, size)
	draw_rect(Rect2(center - core * 0.5, core), color)
	var arm := maxf(2.0, size - 1.0)
	draw_rect(Rect2(center + Vector2(-arm * 1.5, -1.0), Vector2(arm * 3.0, 2.0)), color)
	draw_rect(Rect2(center + Vector2(-1.0, -arm * 1.5), Vector2(2.0, arm * 3.0)), color)

func _attack_flash_rect(center: Vector2, hero_tip: Vector2 = Vector2.INF) -> Rect2:
	var slash_size := Vector2(214, 136)
	if hero_tip == Vector2.INF:
		return Rect2(center - slash_size * 0.5, slash_size)
	var mid := hero_tip.lerp(center, 0.62)
	return Rect2(mid - slash_size * 0.5, slash_size)

func _draw_attack_flash(hero_tip: Vector2, center: Vector2) -> void:
	if slash_timer > 0.0:
		var t := clampf(1.0 - slash_timer / ATTACK_SLASH_DURATION, 0.0, 1.0)
		var alpha := clampf(slash_timer / ATTACK_SLASH_DURATION, 0.0, 1.0)
		var sword_start := hero_tip + Vector2(0, 30)
		var impact := center + Vector2(-4, 8)
		var curve_control := (sword_start + impact) * 0.5 + Vector2(8, -42 + 8 * t)
		var slash_key := str(enemy.get("attack_fx", "fx_attack_slash"))
		var slash_texture: Texture2D = sprite_textures.get(slash_key)
		if slash_texture != null:
			var slash_rect := _attack_flash_rect(impact, sword_start)
			var slash_alpha := alpha * 0.68
			if slash_key == "fx_moon_spring_slash":
				var moon_slash_size := Vector2(276, 182)
				var moon_mid := sword_start.lerp(impact, 0.58)
				slash_rect = Rect2(moon_mid - moon_slash_size * 0.5, moon_slash_size)
				slash_alpha = alpha * 0.78
			_draw_texture_rect_pixel(slash_texture, slash_rect, Color(1.0, 1.0, 1.0, slash_alpha), true)
		var leading_end := sword_start.lerp(impact, 0.82 + 0.12 * t)
		var main_curve := _quadratic_bezier_points(sword_start, curve_control, leading_end, 20)
		var lower_curve := _quadratic_bezier_points(
			sword_start + Vector2(-8, 12),
			curve_control + Vector2(-12, 20),
			impact + Vector2(-12, 18),
			16
		)

		draw_polyline(main_curve, Color(1.0, 0.78, 0.38, alpha * 0.12), 16.0)
		draw_polyline(main_curve, Color(1.0, 0.93, 0.66, alpha * 0.52), 7.0)
		draw_polyline(main_curve, Color(1.0, 0.98, 0.82, alpha * 0.82), 3.0)
		draw_polyline(lower_curve, Color(0.82, 0.65, 1.0, alpha * 0.36), 4.0)
		draw_polyline(lower_curve, Color(1.0, 0.92, 0.72, alpha * 0.34), 2.0)

		draw_arc(impact, 26.0, deg_to_rad(146.0 - 8.0 * t), deg_to_rad(326.0 - 8.0 * t), 18, Color(1.0, 0.91, 0.64, alpha * 0.56), 3.0)
		draw_arc(impact + Vector2(2, 3), 15.0, deg_to_rad(186.0), deg_to_rad(306.0), 14, Color(0.88, 0.70, 1.0, alpha * 0.42), 2.0)
		draw_line(sword_start.lerp(impact, 0.72), impact + Vector2(18, -8), Color(1.0, 0.96, 0.78, alpha * 0.54), 2.0)

		for spark_t in [0.22, 0.48, 0.72]:
			var spark_pos := _quadratic_bezier_point(sword_start, curve_control, impact, clampf(float(spark_t) + t * 0.04, 0.0, 1.0))
			_draw_pixel_spark(spark_pos, Color(1.0, 0.92, 0.66, alpha * 0.66), 3.0)
		_draw_pixel_spark(impact + Vector2(18, -14), Color(0.95, 0.76, 1.0, alpha * 0.72), 4.0)
	if floating_damage_timer > 0.0:
		var rise := (FLOATING_DAMAGE_DURATION - floating_damage_timer) * 28.0
		draw_string(get_theme_default_font(), center + Vector2(-10, -46 - rise), "-%d" % last_damage, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("#ffd4a3"))

func _draw_background_cover(texture: Texture2D, target: Rect2) -> void:
	var source_size := texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return
	var target_ratio := target.size.x / target.size.y
	var source_ratio := source_size.x / source_size.y
	var source_rect := Rect2(Vector2.ZERO, source_size)
	if source_ratio > target_ratio:
		var crop_width := source_size.y * target_ratio
		source_rect.position.x = (source_size.x - crop_width) * 0.5
		source_rect.size.x = crop_width
	else:
		var crop_height := source_size.x / target_ratio
		source_rect.position.y = (source_size.y - crop_height) * 0.5
		source_rect.size.y = crop_height
	draw_texture_rect_region(texture, target, source_rect)

func _can_upgrade_weapon() -> bool:
	if not _is_weapon_unlocked():
		return false
	var cost := DATA.weapon_upgrade_cost(weapon_rank)
	return gold >= int(cost["gold"]) and _has_item(str(cost["item"]), int(cost["amount"]))

func _can_upgrade_talisman() -> bool:
	if not _is_talisman_unlocked():
		return false
	var cost := DATA.talisman_upgrade_cost(talisman_rank)
	return gold >= int(cost["gold"]) and materials >= int(cost["materials"])

func _is_awaken_unlocked() -> bool:
	return weapon_awaken_rank > 0 or talisman_awaken_rank > 0 or stage >= 20 or int(dungeon_clears.get("second_moon_spring_preview", 0)) > 0 or _has_item("第二月泪", 1)

func _is_weapon_awaken_maxed() -> bool:
	return weapon_awaken_rank >= DATA.equipment_awaken_max_rank()

func _is_talisman_awaken_maxed() -> bool:
	return talisman_awaken_rank >= DATA.equipment_awaken_max_rank()

func _can_awaken_weapon() -> bool:
	if not _is_awaken_unlocked() or _is_weapon_awaken_maxed():
		return false
	var cost := DATA.weapon_awaken_cost(weapon_awaken_rank)
	return gold >= int(cost["gold"]) and _has_item("第二月泪", int(cost["tear"])) and _has_item("月露结晶", int(cost["crystal"])) and _has_item("静月花瓣", int(cost.get("petal", 0)))

func _can_awaken_talisman() -> bool:
	if not _is_awaken_unlocked() or _is_talisman_awaken_maxed():
		return false
	var cost := DATA.talisman_awaken_cost(talisman_awaken_rank)
	return gold >= int(cost["gold"]) and materials >= int(cost["materials"]) and _has_item("第二月泪", int(cost["tear"])) and _has_item("静月花瓣", int(cost.get("petal", 0)))

func _push_dungeon_feedback(title: String, body: String, color: Color, duration: float = 1.75) -> void:
	dungeon_feedback_title = title
	dungeon_feedback_body = body
	dungeon_feedback_color = color
	dungeon_feedback_duration = duration
	dungeon_feedback_timer = duration

func _start_dungeon_run_animation(title: String, success: bool) -> void:
	dungeon_run_anim_title = title
	dungeon_run_anim_success = success
	dungeon_run_anim_duration = 1.15
	dungeon_run_anim_timer = dungeon_run_anim_duration

func _push_reward_popup(text: String, position: Vector2, color: Color, duration: float = 1.05) -> void:
	reward_popups.append({
		"text": text,
		"pos": position,
		"age": 0.0,
		"duration": duration,
		"color": color,
	})
	while reward_popups.size() > 6:
		reward_popups.pop_front()

func _draw_dungeon_feedback() -> void:
	if dungeon_feedback_timer <= 0.0 or dungeon_feedback_duration <= 0.0:
		return
	if boss_active and selected_tab == "battle":
		return
	var t := clampf(1.0 - dungeon_feedback_timer / dungeon_feedback_duration, 0.0, 1.0)
	var alpha := 1.0
	if t > 0.72:
		alpha = clampf((1.0 - t) / 0.28, 0.0, 1.0)
	var panel_w := minf(size.x - 42.0, 330.0)
	var panel_h := 54.0
	var rect := Rect2(Vector2((size.x - panel_w) * 0.5, size.y * 0.31), Vector2(panel_w, panel_h))
	draw_rect(rect, Color(0.09, 0.09, 0.18, 0.88 * alpha))
	draw_rect(rect, Color(0.0, 0.0, 0.0, alpha), false, 3.0)
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(4, panel_h - 8)), Color(dungeon_feedback_color.r, dungeon_feedback_color.g, dungeon_feedback_color.b, alpha))
	var font := get_theme_default_font()
	draw_string(font, rect.position + Vector2(16, 22), dungeon_feedback_title, HORIZONTAL_ALIGNMENT_LEFT, panel_w - 28.0, 14, Color(1.0, 0.96, 0.88, alpha))
	draw_string(font, rect.position + Vector2(16, 42), dungeon_feedback_body, HORIZONTAL_ALIGNMENT_LEFT, panel_w - 28.0, 11, Color(0.82, 0.75, 0.92, alpha))

func _draw_dungeon_run_animation() -> void:
	if dungeon_run_anim_timer <= 0.0 or dungeon_run_anim_duration <= 0.0:
		return
	var t := clampf(1.0 - dungeon_run_anim_timer / dungeon_run_anim_duration, 0.0, 1.0)
	var alpha := 1.0
	if t > 0.78:
		alpha = clampf((1.0 - t) / 0.22, 0.0, 1.0)
	var panel_w := minf(size.x - 58.0, 300.0)
	var rect := Rect2(Vector2((size.x - panel_w) * 0.5, size.y * 0.24), Vector2(panel_w, 46))
	draw_rect(rect, Color(0.07, 0.07, 0.15, 0.84 * alpha))
	var border_color := Color("#05040c")
	border_color.a = alpha
	draw_rect(rect, border_color, false, 3.0)
	var line_y := rect.position.y + 30.0
	draw_line(rect.position + Vector2(18, 30), rect.position + Vector2(panel_w - 18, 30), Color(0.72, 0.63, 0.84, 0.48 * alpha), 2.0)
	var runner_x := rect.position.x + 22.0 + (panel_w - 44.0) * t
	var runner_color := Color("#ffd4a3") if dungeon_run_anim_success else Color("#b4a5d5")
	runner_color.a = alpha
	_draw_pixel_spark(Vector2(runner_x, line_y - 1.0), runner_color, 5.0)
	for i in range(3):
		var trail_t := clampf(t - float(i + 1) * 0.12, 0.0, 1.0)
		var trail_x := rect.position.x + 22.0 + (panel_w - 44.0) * trail_t
		var trail_color := Color(1.0, 0.86, 0.60, alpha * (0.38 - float(i) * 0.08))
		draw_rect(Rect2(Vector2(trail_x - 2.0, line_y + 6.0 + float(i % 2)), Vector2(4, 4)), trail_color)
	draw_string(get_theme_default_font(), rect.position + Vector2(14, 17), "副本挑战 · %s" % dungeon_run_anim_title, HORIZONTAL_ALIGNMENT_LEFT, panel_w - 28.0, 12, Color(1.0, 0.96, 0.88, alpha))

func _draw_reward_popups() -> void:
	for popup in reward_popups:
		var age := float(popup["age"])
		var duration := float(popup["duration"])
		var t := clampf(age / duration, 0.0, 1.0)
		var pos: Vector2 = popup["pos"]
		var color: Color = popup["color"]
		color.a = 1.0 - t
		var rise := 34.0 * t
		draw_string(
			get_theme_default_font(),
			pos + Vector2(-38, -rise),
			str(popup["text"]),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			13,
			color
		)
