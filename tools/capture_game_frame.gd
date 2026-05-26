extends SceneTree

const MAIN_SCENE := preload("res://scenes/Main.tscn")

var output_path := "/tmp/xiaomi-game-frame.png"
var capture_tab := "inventory"
var capture_detail := ""
var capture_dungeon_run := ""
var capture_boss := ""
var capture_attack := false
var capture_stage := -1
var capture_camp_rank := -1
var capture_boss_hp_ratio := -1.0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_parse_args()
	root.size = Vector2i(390, 844)

	var main := MAIN_SCENE.instantiate()
	main.save_enabled = false
	root.add_child(main)
	await process_frame

	_prepare_state(main)
	main.size = Vector2(390, 844)
	if capture_tab != "":
		main._set_tab(capture_tab)
	if capture_boss != "":
		main.boss_active = true
		main.active_boss_id = capture_boss
		main.active_boss_dungeon_id = "second_moon_spring_preview" if capture_boss == "second_moon_warden" else "moon_spring_trial"
		main.active_boss_timer = 118.0 if capture_boss == "second_moon_warden" else 80.0
		main.active_boss_duration = 130.0 if capture_boss == "second_moon_warden" else 95.0
		main._restore_boss_enemy()
		if capture_boss_hp_ratio >= 0.0:
			main.enemy_hp = maxi(1, int(float(main.enemy_max_hp) * clampf(capture_boss_hp_ratio, 0.0, 1.0)))
			main.active_boss_saved_hp = main.enemy_hp
			if capture_boss == "second_moon_warden" and capture_boss_hp_ratio <= 0.35:
				main.enemy["resonance_started"] = true
				main.boss_resonance_timer = 1.10
	if capture_attack:
		main._deal_damage(true)
		main.attack_pose_timer = 0.32
		main.slash_timer = 0.34
		main.hit_flash_timer = 0.22
		main.floating_damage_timer = 0.55
	if capture_dungeon_run != "":
		main._run_dungeon(capture_dungeon_run)
	if capture_detail != "":
		_open_requested_detail(main)

	await process_frame
	await process_frame

	var image := root.get_texture().get_image()
	var err := image.save_png(output_path)
	if err == OK:
		print("CAPTURED: %s" % output_path)
		quit(0)
	else:
		push_error("CAPTURE FAILED: %s" % output_path)
		quit(1)

func _parse_args() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	for arg in args:
		var text := str(arg)
		if text.begins_with("--capture-output="):
			output_path = text.get_slice("=", 1)
		elif text.begins_with("--capture-tab="):
			capture_tab = text.get_slice("=", 1)
		elif text.begins_with("--capture-detail="):
			capture_detail = text.get_slice("=", 1)
		elif text.begins_with("--capture-dungeon-run="):
			capture_dungeon_run = text.get_slice("=", 1)
		elif text.begins_with("--capture-boss="):
			capture_boss = text.get_slice("=", 1)
		elif text.begins_with("--capture-stage="):
			capture_stage = int(text.get_slice("=", 1))
		elif text.begins_with("--capture-camp-rank="):
			capture_camp_rank = int(text.get_slice("=", 1))
		elif text.begins_with("--capture-boss-hp-ratio="):
			capture_boss_hp_ratio = float(text.get_slice("=", 1))
		elif text == "--capture-attack":
			capture_attack = true

func _prepare_state(main: Control) -> void:
	main.level = 24
	main.gold = 7301
	main.materials = 90
	main.training_rank = 12
	main.camp_rank = 2
	main.weapon_rank = 4
	main.talisman_rank = 2
	main.equipped_weapon_rank = 4
	main.equipped_talisman_rank = 2
	main.equipment_inventory = {
		"weapon_0": 1,
		"weapon_1": 2,
		"weapon_2": 1,
		"weapon_3": 1,
		"weapon_4": 1,
		"talisman_0": 1,
		"talisman_1": 2,
		"talisman_2": 1,
	}
	main.loaded_equipment_inventory = true
	main.companion_id = "meimei"
	main._set_companion_state_value("xiaomi", "level", 3)
	main._set_companion_state_value("xiaomi", "bond", 1)
	main._set_companion_state_value("xiaomi", "feed_count", 1)
	main._set_companion_state_value("zizi", "level", 2)
	main._set_companion_state_value("meimei", "level", 2)
	main._sync_legacy_companion_fields()
	main.daily_claimed_date = ""
	main.daily_cycle_day = 2
	main.daily_claim_count = 2
	main.defeated = 37
	main.stage = 10
	if capture_stage > 0:
		main.stage = capture_stage
	if capture_camp_rank >= 0:
		main.camp_rank = capture_camp_rank
	if main.stage >= 20:
		main.level = 34
		main.gold = 1260
		main.materials = 42
		main.training_rank = 22
		main.camp_rank = maxi(main.camp_rank, 3)
		main.weapon_rank = 4
		main.talisman_rank = 4
		main.equipped_weapon_rank = 4
		main.equipped_talisman_rank = 4
		main.equipment_inventory["talisman_4"] = 1
		main.dungeon_clears["second_moon_spring_preview"] = 1
		main.weapon_awaken_rank = 1
	if main.stage >= 24:
		main.chapter_claimed["chapter_1_moon_camp"] = true
		main.dungeon_clears["quiet_moon_ridge_patrol"] = 1
		main.weapon_awaken_rank = 2
	main.selected_area_id = "mushroom_grove"
	if main.stage >= 24:
		main.selected_area_id = "quiet_moon_ridge"
	main.inventory_section = "equipment"
	main.companion_section = "companions"
	main.inventory = {
		"苔影露珠": 28,
		"月光孢子": 31,
		"暖木碎片": 31,
		"小鱼干": 4,
		"月露结晶": 3,
		"月泉钥匙": 1,
	}
	if main.stage >= 20:
		main.inventory["月露结晶"] = 4
		main.inventory["第二月泪"] = 2
	if main.stage >= 24:
		main.inventory["静月花瓣"] = 6
	main.enemy = main.DATA.enemy_for_area(main.selected_area_id, main.stage)
	main.enemy_max_hp = int(main.enemy["hp"])
	main.enemy_hp = int(main.enemy_max_hp * 0.54)
	main._update_ui()

func _open_requested_detail(main: Control) -> void:
	match capture_detail:
		"weapon":
			main._open_detail(main._weapon_detail(main.weapon_rank))
		"talisman":
			main._open_detail(main._talisman_detail(main.talisman_rank))
		"loot":
			main._open_detail(main._loot_detail("苔影露珠", int(main.inventory.get("苔影露珠", 0))))
		"second_moon_tear":
			main._open_detail(main._loot_detail("第二月泪", int(main.inventory.get("第二月泪", 0))))
		"quiet_moon_petal":
			main._open_detail(main._loot_detail("静月花瓣", int(main.inventory.get("静月花瓣", 0))))
		"weapon_awaken":
			main._open_detail(main._weapon_awaken_detail())
		"talisman_awaken":
			main._open_detail(main._talisman_awaken_detail())
		"chapter_goal":
			main._open_detail(main._chapter_goal_detail("chapter_1_moon_camp"))
		"chapter_epilogue":
			main._open_detail(main._chapter_goal_detail("chapter_1_quiet_moon_epilogue"))
		"companion":
			main._open_detail(main._companion_detail(main.companion_id))
		"daily":
			main._open_detail(main._daily_detail())
		"dungeon":
			main._open_detail(main._dungeon_detail("gold_cave"))
		"moon_trial":
			main._open_detail(main._dungeon_detail("moon_spring_trial"))
		"second_moon":
			main._open_detail(main._dungeon_detail("second_moon_spring_preview"))
		"quiet_moon":
			main._open_detail(main._dungeon_detail("quiet_moon_ridge_patrol"))
		"second_boss":
			main.boss_active = true
			main.active_boss_id = "second_moon_warden"
			main.active_boss_dungeon_id = "second_moon_spring_preview"
			main.active_boss_timer = 118.0
			main.active_boss_duration = 130.0
			main._restore_boss_enemy()
			main._open_detail(main._boss_detail("second_moon_warden"))
		"boss":
			main.boss_active = true
			main.active_boss_id = "moss_moon_slime"
			main.active_boss_dungeon_id = "moon_spring_trial"
			main._restore_boss_enemy()
			main._open_detail(main._boss_detail("moss_moon_slime"))
		"equipment_set":
			main._open_detail(main._equipment_set_detail(2))
		"album":
			main._open_detail(main._album_detail("snack_feed"))
		"collectible":
			main._open_detail(main._collectible_detail("laifu_relic_bell", main._has_private_collectible("laifu_relic_bell")))
