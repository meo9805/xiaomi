extends SceneTree

const MAIN_SCENE := preload("res://scenes/Main.tscn")

var output_path := "/tmp/xiaomi-game-frame.png"
var capture_tab := "inventory"
var capture_detail := ""
var capture_dungeon_run := ""
var capture_attack := false

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
	main.inventory = {
		"苔影露珠": 28,
		"月光孢子": 31,
		"暖木碎片": 31,
		"小鱼干": 4,
		"月露结晶": 1,
		"月泉钥匙": 1,
	}
	main.enemy = main.DATA.enemy_for_stage(main.stage)
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
		"companion":
			main._open_detail(main._companion_detail(main.companion_id))
		"daily":
			main._open_detail(main._daily_detail())
		"dungeon":
			main._open_detail(main._dungeon_detail("gold_cave"))
		"moon_trial":
			main._open_detail(main._dungeon_detail("moon_spring_trial"))
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
