extends SceneTree

const MAIN_SCENE := preload("res://scenes/Main.tscn")

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	main.save_enabled = false
	root.add_child(main)
	await process_frame

	_assert(main.sprite_textures.has("ui_modal_panel") and main.sprite_textures.has("ui_button_primary"), "generated UI kit textures are loaded")
	_assert(main.attack_button.get_theme_stylebox("normal") is StyleBoxTexture, "action buttons use generated UI texture styles")
	_assert(main.xp_bar.get_theme_stylebox("background") is StyleBoxTexture, "progress bars use generated UI texture frames")

	main.inventory.clear()
	main.materials = 0
	main.companion_id = "xiaomi"
	main._set_companion_state_value("xiaomi", "level", 1)
	main._set_companion_state_value("xiaomi", "bond", 0)
	main._set_companion_state_value("xiaomi", "bond_progress", 0)
	main._sync_legacy_companion_fields()
	main.camp_rank = 0
	main.enemy = {
		"name": "测试小怪",
		"hp": 1,
		"xp": 0,
		"gold": 0,
		"drop": "苔影露珠",
		"sprite": "enemy_moss_slime",
	}
	main.enemy_hp = 1
	main.enemy_max_hp = 1
	main._add_item("苔影露珠", 1)
	_assert(int(main.inventory.get("苔影露珠", 0)) == 1, "drop item is added to inventory")
	_assert(main._inventory_summary().contains("苔影露珠 x1"), "inventory tab can render drop count")
	main.inventory_section = "equipment"
	main._set_tab("inventory")
	await process_frame
	_assert(main.content_stack.get_child_count() >= 8, "inventory tab renders equipment set guide and clickable rows")
	_assert(main.secondary_nav_row.visible and main.secondary_nav_row.get_child_count() == 3, "inventory tab shows frozen secondary category buttons")
	_assert(main.content_scroll.custom_minimum_size.y >= 400.0, "inventory tab expands scroll reading area")
	_assert(not main.action_row.visible and not main.upgrade_row.visible, "inventory tab hides global action rows")
	_assert(main._detail_row_height("护符 · 苔光护符 Lv.1  [已穿戴]", "当前护符提供 +1 巡逻/任务收益等级。 · 旧铜护符 -> 苔光护符，巡逻/任务 +1。材料已齐，可强化。") > 43, "long detail rows grow instead of leaking text")
	_assert(main._content_text_height("下次武器强化：92G + 月光孢子 x3\n月露短剑 -> 孢子弯刀，攻击 +4。材料已齐，可强化。", 12) > 42, "long content notes reserve wrapped text height")
	main._open_detail(main._loot_detail("苔影露珠", 1))
	_assert(main.detail_overlay.visible, "item detail popup opens")
	_assert(main.detail_description_label.text.contains("湿润"), "item detail popup shows item description")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "item detail popup shows item artwork")
	main._hide_detail_overlay()
	main.inventory.clear()
	_assert(main._inventory_summary().contains("私人收藏"), "empty inventory still renders private collection")
	main._add_item("苔影露珠", 1)
	main._maybe_add_personal_event_log(1.0)
	_assert(main.recent_logs.size() > 0, "personal event log can be added")
	_assert(main.recent_logs.size() <= 4, "log list keeps mobile height bounded")
	_assert(main._companion_summary().contains("小咪"), "companion tab renders Xiaomi")
	_assert(main._private_collection_summary().contains("来福圣遗物铃铛"), "private collection renders Laifu bell")
	_assert(main._private_collection_summary().contains("nico 爱喝的小猫饮水机"), "private collection renders Nico drinker")

	main.daily_claimed_date = ""
	main.daily_cycle_day = 2
	main.daily_claim_count = 0
	main.defeated = 0
	main.claimed_quests = 0
	main.inventory.clear()
	main._set_tab("dungeon")
	await process_frame
	_assert(main.content_stack.get_child_count() >= 3, "dungeon tab renders daily sign-in row")
	_assert(not main.action_row.visible and not main.attack_button.visible, "dungeon tab hides global battle actions when no reward is claimable")
	main._open_detail(main._daily_detail())
	_assert(main.detail_overlay.visible, "daily detail popup opens")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "daily detail popup shows reward artwork")
	_assert(main.detail_primary_button.text == "领取", "daily detail allows claiming when available")
	main._on_detail_primary()
	_assert(main.daily_claim_count == 1, "daily claim increments count")
	_assert(main.daily_cycle_day == 3, "daily claim advances cycle")
	_assert(main._has_item("小鱼干", 2), "daily claim grants snack item")
	var gold_after_daily: int = main.gold
	main._claim_daily_reward()
	_assert(main.gold == gold_after_daily, "daily claim cannot be repeated on same date")
	main.daily_task_date = main._today_key()
	main.daily_task_progress.clear()
	main.daily_task_claimed.clear()
	main._add_daily_task_progress("defeats", 8)
	main._open_detail(main._daily_task_detail("defeat_8"))
	_assert(main.detail_overlay.visible, "daily task detail popup opens")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "daily task detail shows reward artwork")
	_assert(main.detail_primary_button.text == "领取", "completed daily task allows claiming")
	var gold_before_daily_task: int = main.gold
	main._on_detail_primary()
	_assert(main._is_daily_task_claimed("defeat_8"), "daily task claim is recorded")
	_assert(main.gold > gold_before_daily_task and main.materials > 0, "daily task grants reward")

	main.stage = 5
	main.camp_rank = 1
	main.level = 8
	main.training_rank = 2
	main.equipped_weapon_rank = 1
	main.equipment_inventory = {"weapon_0": 1, "talisman_0": 1}
	main.loaded_equipment_inventory = true
	main.gold = 0
	main.materials = 0
	main.inventory.clear()
	main.dungeon_attempts_date = ""
	main.dungeon_attempts.clear()
	main.dungeon_clears.clear()
	main._set_tab("quest")
	await process_frame
	_assert(main.selected_tab == "dungeon", "legacy quest tab maps to dungeon")
	_assert(main.content_stack.get_child_count() >= 6, "dungeon tab renders daily and dungeon rows")
	var dungeon_tab_text := _node_text(main.content_stack)
	_assert(dungeon_tab_text.contains("亮晶晶洞穴"), "dungeon tab renders unlocked gold dungeon row")
	_assert(dungeon_tab_text.contains("孢子巢穴"), "dungeon tab renders unlocked spore dungeon row")
	_assert(dungeon_tab_text.contains("月泉试炼"), "dungeon tab renders locked moon spring trial row")
	_assert(dungeon_tab_text.contains("月森前哨"), "dungeon tab renders stage 14 outpost row")
	_assert(dungeon_tab_text.contains("第二口月泉"), "dungeon tab renders stage 20 boss preview row")
	main._open_detail(main._dungeon_detail("gold_cave"))
	_assert(main.detail_overlay.visible, "dungeon detail popup opens")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "dungeon detail popup shows reward artwork")
	_assert(main.detail_primary_button.text == "挑战", "dungeon detail allows challenge")
	main._on_detail_primary()
	_assert(int(main.dungeon_attempts.get("gold_cave", 0)) == 1, "successful dungeon challenge spends one attempt")
	_assert(main.gold > 0, "gold dungeon grants gold")
	_assert(int(main.equipment_inventory.get("weapon_1", 0)) >= 1, "gold dungeon grants an equipment drop")
	_assert(main._daily_task_progress_value("clear_dungeon") >= 1, "successful dungeon challenge advances daily task")
	_assert(main.dungeon_feedback_title.contains("通关"), "successful dungeon challenge shows feedback banner")
	_assert(main.dungeon_feedback_timer > 0.0, "dungeon feedback banner stays visible briefly")
	_assert(main._is_album_unlocked("first_dungeon_clear"), "first dungeon clear unlocks album entry")
	main.level = 1
	main.training_rank = 0
	main.equipped_weapon_rank = 0
	main.gold = 0
	var spore_attempts_before: int = int(main.dungeon_attempts.get("spore_nest", 0))
	main._run_dungeon("spore_nest")
	_assert(int(main.dungeon_attempts.get("spore_nest", 0)) == spore_attempts_before, "failed dungeon challenge does not spend attempt")
	_assert(not main.inventory.has("月光孢子"), "failed dungeon challenge grants no items")
	_assert(main.dungeon_feedback_title.contains("挑战失败"), "failed dungeon challenge shows failure banner")
	main.level = 14
	main.training_rank = 4
	main.equipped_weapon_rank = 3
	main._run_dungeon("spore_nest")
	_assert(int(main.dungeon_attempts.get("spore_nest", 0)) == 1, "spore dungeon success spends attempt")
	_assert(main._has_item("月光孢子", 3), "spore dungeon grants targeted material")
	_assert(main._is_album_unlocked("spore_nest_clear"), "spore dungeon unlocks album entry")
	main.stage = 14
	main.camp_rank = 2
	main.level = 18
	main.training_rank = 10
	main.weapon_rank = 4
	main.talisman_rank = 4
	main.equipped_weapon_rank = 3
	main.equipped_talisman_rank = 2
	main._run_dungeon("moon_guard_outpost")
	_assert(int(main.dungeon_attempts.get("moon_guard_outpost", 0)) == 1, "stage 14 outpost success spends attempt")
	_assert(int(main.equipment_inventory.get("weapon_4", 0)) >= 1 and int(main.equipment_inventory.get("talisman_4", 0)) >= 1, "stage 14 outpost grants final-set equipment drops")
	main.stage = 20
	main.camp_rank = 3
	main.level = 34
	main.training_rank = 22
	main.weapon_rank = 4
	main.talisman_rank = 4
	main.equipped_weapon_rank = 4
	main.equipped_talisman_rank = 4
	main._add_item("月露结晶", 3)
	var second_moon_attempts_before: int = int(main.dungeon_attempts.get("second_moon_spring_preview", 0))
	main._open_detail(main._dungeon_detail("second_moon_spring_preview"))
	_assert(main.detail_primary_button.text == "挑战" and not main.detail_primary_button.disabled, "stage 20 second moon detail allows challenge")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "stage 20 second moon detail shows generated boss artwork")
	_assert(_node_text(main.detail_extra_container).contains("第二月泪"), "stage 20 second moon detail shows unique boss drop in sections")
	main._hide_detail_overlay()
	main._run_dungeon("second_moon_spring_preview")
	_assert(int(main.dungeon_attempts.get("second_moon_spring_preview", 0)) == second_moon_attempts_before + 1, "stage 20 second moon challenge spends one attempt")
	_assert(main.boss_active and main.active_boss_id == "second_moon_warden", "stage 20 second moon starts generated boss encounter")
	_assert(main.boss_intro_timer > 0.0, "stage 20 second moon starts boss intro feedback")
	_assert(main.dungeon_feedback_body.contains("第二口月泉"), "stage 20 second moon entry uses dedicated boss feedback")
	_assert(str(main.enemy.get("sprite", "")) == "boss_second_moon_warden", "stage 20 second moon uses generated boss sprite")
	_assert(str(main.enemy.get("attack_fx", "")) == "fx_moon_spring_slash", "stage 20 second moon uses generated attack VFX")
	_assert(main._has_item("月露结晶", 1) and not main._has_item("第二月泪", 1), "stage 20 second moon consumes entry crystals before boss reward")
	main._open_detail(main._boss_detail("second_moon_warden"))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "second moon boss detail popup shows artwork")
	main._hide_detail_overlay()
	main.enemy_hp = int(float(main.enemy_max_hp) * 0.40)
	main.active_boss_saved_hp = main.enemy_hp
	main._deal_damage(false)
	_assert(main.boss_active and bool(main.enemy.get("resonance_started", false)), "second moon boss enters resonance phase at low HP")
	_assert(main.boss_resonance_timer > 0.0, "second moon boss resonance feedback is visible briefly")
	main.enemy_hp = 1
	main.active_boss_saved_hp = 1
	main._deal_damage(false)
	_assert(not main.boss_active, "defeating second moon boss exits encounter")
	_assert(main._has_item("第二月泪", 1), "second moon boss defeat grants unique tear drop")
	_assert(int(main.dungeon_clears.get("second_moon_spring_preview", 0)) == 1, "second moon boss defeat records dungeon clear")
	_assert(main.dungeon_feedback_title.contains("第二月泉"), "second moon boss victory uses dedicated feedback")
	_assert(main._is_album_unlocked("stage_20_preview"), "stage 20 milestone unlocks album entry")
	_assert(main._is_album_unlocked("second_moon_boss_clear"), "second moon boss defeat unlocks album entry")
	_assert(main._is_title_unlocked("stage_20_pathfinder"), "stage 20 milestone unlocks pathfinder title")
	_assert(main._is_title_unlocked("second_moon_clearer"), "second moon boss defeat unlocks boss title")
	main._open_detail(main._loot_detail("第二月泪", int(main.inventory.get("第二月泪", 0))))
	_assert(main.detail_primary_button.visible and main.detail_primary_button.text == "去觉醒", "second moon tear detail links to awakening")
	main._on_detail_primary()
	_assert(main.selected_tab == "growth", "second moon tear detail opens growth tab")
	main.gold = 420
	main.inventory["第二月泪"] = 1
	main.inventory["月露结晶"] = 2
	var damage_before_awaken: int = main._hero_damage_value()
	main._open_detail(main._weapon_awaken_detail())
	_assert(main.detail_primary_button.text == "觉醒", "weapon awakening detail allows upgrade when materials are ready")
	main._on_detail_primary()
	_assert(main.weapon_awaken_rank == 1, "weapon awakening consumes tear and increments rank")
	_assert(main._hero_damage_value() > damage_before_awaken, "weapon awakening increases hero damage")
	_assert(not main.inventory.has("第二月泪"), "weapon awakening consumes second moon tear")
	_assert(main._is_album_unlocked("first_moon_awakening"), "first awakening unlocks album entry")
	_assert(main._is_title_unlocked("moon_awakener"), "first awakening unlocks title")
	main.gold = 360
	main.materials = 12
	main.inventory["第二月泪"] = 1
	var quest_gold_before_awaken: int = main.gold
	main._open_detail(main._talisman_awaken_detail())
	_assert(main.detail_primary_button.text == "觉醒", "talisman awakening detail allows upgrade when materials are ready")
	main._on_detail_primary()
	_assert(main.talisman_awaken_rank == 1, "talisman awakening consumes tear and increments rank")
	main.defeated = 4
	main.claimed_quests = 0
	main.gold = 0
	main._claim_quest_reward()
	_assert(main.gold > quest_gold_before_awaken / 20, "talisman awakening contributes quest reward gold")
	main._open_detail(main._chapter_goal_detail("chapter_1_moon_camp"))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "chapter goal detail shows reward artwork")
	_assert(str(main.active_detail.get("sprite", "")) == "item_chapter1_crest", "chapter goal uses generated chapter crest artwork")
	_assert(main.detail_description_label.text.contains("第一章告一段落"), "chapter goal main description is player-facing")
	_assert(not main.detail_description_label.text.contains("完成：") and not main.detail_description_label.text.contains("奖励："), "chapter goal main description does not mix system progress")
	_assert(main.detail_extra_container.visible and main.detail_extra_container.get_child_count() >= 6, "chapter goal detail separates progress reward and status sections")
	_assert(main.detail_primary_button.text == "领取", "completed chapter goal can be claimed")
	var chapter_gold_before: int = main.gold
	main._on_detail_primary()
	_assert(bool(main.chapter_claimed.get("chapter_1_moon_camp", false)), "chapter goal claim is recorded")
	_assert(main.gold > chapter_gold_before and main.materials > 0, "chapter goal grants settlement reward")
	_assert(main._has_item("第二月泪", 1), "chapter goal grants an extra second moon tear")
	_assert(main._is_album_unlocked("chapter_1_clear"), "chapter goal unlocks chapter album entry")
	_assert(main._is_title_unlocked("chapter_1_keeper"), "chapter goal unlocks chapter title")
	main.stage = 24
	main.camp_rank = 3
	main.level = 34
	main.training_rank = 22
	main.weapon_rank = 4
	main.talisman_rank = 4
	main.equipped_weapon_rank = 4
	main.equipped_talisman_rank = 4
	main.gold = 1200
	main.materials = 36
	main.inventory["第二月泪"] = 2
	main.inventory["月露结晶"] = 4
	main.inventory["静月花瓣"] = 3
	main._select_battle_area("quiet_moon_ridge")
	_assert(main.selected_area_id == "quiet_moon_ridge", "stage 24 quiet moon ridge can be selected")
	_assert(str(main.enemy.get("drop", "")) == "静月花瓣", "quiet moon ridge drops new quiet moon petal material")
	main.weapon_awaken_rank = 1
	main._open_detail(main._weapon_awaken_detail())
	_assert(_node_text(main.detail_extra_container).contains("静月花瓣"), "weapon awakening rank 2 asks for quiet moon petals")
	main._on_detail_primary()
	_assert(main.weapon_awaken_rank == 2, "weapon awakening can progress to rank 2 with quiet moon petals")
	_assert(not main.inventory.has("静月花瓣"), "weapon awakening rank 2 consumes quiet moon petals")
	main.inventory["静月花瓣"] = 3
	main._open_detail(main._dungeon_detail("quiet_moon_ridge_patrol"))
	_assert(main.detail_primary_button.text == "挑战", "quiet moon ridge patrol detail allows challenge")
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "quiet moon ridge patrol detail uses generated petal artwork")
	_assert(_node_text(main.detail_extra_container).contains("静月花瓣"), "quiet moon ridge patrol detail shows petal ticket and reward")
	var quiet_attempts_before: int = int(main.dungeon_attempts.get("quiet_moon_ridge_patrol", 0))
	main._on_detail_primary()
	_assert(int(main.dungeon_attempts.get("quiet_moon_ridge_patrol", 0)) == quiet_attempts_before + 1, "quiet moon ridge patrol spends one attempt")
	_assert(int(main.dungeon_clears.get("quiet_moon_ridge_patrol", 0)) == 1, "quiet moon ridge patrol records clear")
	_assert(main._has_item("静月花瓣", 4) and main._has_item("第二月泪", 1), "quiet moon ridge patrol grants post chapter materials")
	_assert(main._is_album_unlocked("quiet_moon_ridge"), "stage 24 unlocks quiet moon album entry")
	_assert(main._is_album_unlocked("quiet_moon_patrol_clear"), "quiet moon patrol clear unlocks album entry")
	main._open_detail(main._chapter_goal_detail("chapter_1_quiet_moon_epilogue"))
	_assert(main.detail_primary_button.text == "领取", "quiet moon epilogue chapter goal can be claimed")
	var epilogue_gold_before: int = main.gold
	main._on_detail_primary()
	_assert(bool(main.chapter_claimed.get("chapter_1_quiet_moon_epilogue", false)), "quiet moon epilogue claim is recorded")
	_assert(main.gold > epilogue_gold_before and main._has_item("静月花瓣", 1), "quiet moon epilogue grants chapter reward")
	_assert(main._is_album_unlocked("chapter_1_epilogue"), "quiet moon epilogue unlocks album entry")
	_assert(main._is_title_unlocked("quiet_moon_keeper"), "quiet moon epilogue unlocks title")
	main.weapon_awaken_rank = 0
	main.talisman_awaken_rank = 0
	main.stage = 10
	main.camp_rank = 2
	main.level = 24
	main.training_rank = 12
	main.equipped_weapon_rank = 4
	main.equipped_talisman_rank = 2
	main.inventory.erase("月泉钥匙")
	main.inventory.erase("月露结晶")
	var trial_attempts_before: int = int(main.dungeon_attempts.get("moon_spring_trial", 0))
	main._open_detail(main._dungeon_detail("moon_spring_trial"))
	_assert(main.detail_primary_button.text == "缺门票", "moon spring trial detail blocks challenge without ticket")
	_assert(_node_text(main.detail_extra_container).contains("门票"), "moon spring trial detail shows entry ticket section")
	main._hide_detail_overlay()
	main._run_dungeon("moon_spring_trial")
	_assert(int(main.dungeon_attempts.get("moon_spring_trial", 0)) == trial_attempts_before, "moon spring trial without key spends no attempt")
	_assert(not main.inventory.has("月露结晶"), "moon spring trial without key grants no crystal")
	_assert(main.dungeon_feedback_title.contains("缺少门票"), "moon spring trial without key shows ticket feedback")
	main._add_item("月泉钥匙", 1)
	main._open_detail(main._dungeon_detail("moon_spring_trial"))
	_assert(main.detail_primary_button.text == "挑战", "moon spring trial detail allows challenge with key")
	main._on_detail_primary()
	_assert(int(main.dungeon_attempts.get("moon_spring_trial", 0)) == trial_attempts_before + 1, "moon spring trial with key spends one attempt")
	_assert(not main.inventory.has("月泉钥匙"), "moon spring trial consumes one moon key")
	_assert(main.boss_active and main.active_boss_id == "moss_moon_slime", "moon spring trial starts boss encounter")
	_assert(str(main.enemy.get("sprite", "")) == "boss_moss_moon_slime", "boss encounter uses generated boss sprite")
	_assert(not main.inventory.has("月露结晶"), "moon spring trial waits for boss defeat before granting crystal")
	var boss_timer_before: float = main.active_boss_timer
	main._process(0.25)
	_assert(main.boss_active and main.active_boss_timer < boss_timer_before, "boss encounter countdown decreases during battle")
	main._open_detail(main._boss_detail("moss_moon_slime"))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "boss detail popup shows boss artwork")
	_assert(_node_text(main.detail_extra_container).contains("击败奖励"), "boss detail shows defeat reward section")
	_assert(_node_text(main.detail_extra_container).contains("失败安慰"), "boss detail shows failure consolation reward section")
	main._hide_detail_overlay()
	main.enemy_hp = 1
	main.active_boss_saved_hp = 1
	main._deal_damage(false)
	_assert(not main.boss_active, "defeating boss exits boss encounter")
	_assert(main._has_item("月露结晶", 1), "moon spring boss defeat grants moon crystal")
	_assert(main._has_item("苔月露核", 1), "moon spring boss defeat grants unique boss drop")
	_assert(int(main.dungeon_clears.get("moon_spring_trial", 0)) == 1, "moon spring boss defeat records dungeon clear")
	_assert(main._is_album_unlocked("moss_moon_boss_clear"), "moon spring boss defeat unlocks album entry")
	_assert(main._is_title_unlocked("moss_moon_clearer"), "moon spring boss defeat unlocks boss title")
	var materials_before_boss_fail: int = main.materials
	main._start_boss_encounter("moon_spring_trial", "moss_moon_slime")
	main.active_boss_timer = 0.05
	main._process(0.10)
	_assert(not main.boss_active, "boss countdown expiry exits boss encounter")
	_assert(main.materials > materials_before_boss_fail, "boss countdown failure grants consolation reward")
	_assert(main.dungeon_feedback_title.contains("试炼失败"), "boss countdown failure shows failure feedback")

	main.inventory["小鱼干"] = 2
	main._set_companion_state_value("xiaomi", "level", 1)
	main._set_companion_state_value("xiaomi", "feed_count", 0)
	main._sync_legacy_companion_fields()
	main._open_detail(main._companion_detail("xiaomi"))
	main._on_detail_secondary()
	_assert(main._companion_level("xiaomi") == 2, "companion detail can feed snack and level up")
	_assert(main._companion_feed_count("xiaomi") == 1, "feeding companion increments feed count")
	_assert(main._is_album_unlocked("snack_feed"), "feeding unlocks snack album entry")
	_assert(main._album_unlocked_count() > 0, "album progress can count unlocked entries")
	main.stage = 10
	main._set_tab("companion")
	await process_frame
	_assert(main.content_scroll.custom_minimum_size.y >= 400.0, "companion tab expands scroll reading area")
	_assert(main.secondary_nav_row.visible and main.secondary_nav_row.get_child_count() == 3, "companion tab shows frozen companion/title/album buttons")
	for companion_id in main.DATA.companion_ids():
		main._open_detail(main._companion_detail(companion_id))
		_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "companion detail popup shows artwork for %s" % companion_id)
		main._hide_detail_overlay()
	_assert(main._is_companion_unlocked("zizi"), "Zizi unlocks after stage or sign-in progress")
	_assert(main._is_companion_unlocked("meimei"), "Meimei unlocks after stage or feeding")
	main._open_detail(main._companion_detail("meimei"))
	main._on_detail_primary()
	_assert(main.companion_id == "meimei", "companion detail can set one active companion")
	_assert(main._companion_drop_chance_bonus() > 0.2, "active Meimei grants larger drop chance bonus")
	_assert(main._companion_gold_bonus() > 0, "inactive Xiaomi support still grants gold bonus")

	main.gold = 0
	var companion_bonus: int = main._apply_companion_defeat_reward()
	_assert(companion_bonus > 0, "companion grants defeat gold bonus")
	_assert(main.gold == companion_bonus, "companion bonus is added to gold")
	_assert(main._companion_bond_progress(main.companion_id) > 0, "active companion defeat reward advances bond progress")
	main._set_companion_state_value("xiaomi", "bond", 1)
	main._sync_legacy_companion_fields()
	_assert(main._has_private_collectible("laifu_relic_bell"), "Laifu bell unlocks at Xiaomi bond 1")
	_assert(main._companion_gold_bonus() > companion_bonus, "Laifu bell increases companion gold bonus")
	_assert(main._is_title_unlocked("cat_chosen"), "Xiaomi bond unlocks cat chosen title")
	main._open_detail(main._title_detail("cat_chosen"))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "title detail popup shows title artwork")
	_assert(main.detail_primary_button.text == "使用", "unlocked title can be equipped")
	main._on_detail_primary()
	_assert(main.equipped_title_id == "cat_chosen", "title detail can equip title")
	_assert(main.hero_label.text.contains("被猫选中的人"), "equipped title appears in top hero label")
	main._open_detail(main._companion_selector_detail())
	_assert(main.detail_overlay.visible, "battle companion selector popup opens")
	_assert(main.detail_extra_container.visible and main.detail_extra_container.get_child_count() >= 4, "companion selector lists switch options")
	main._select_companion_from_selector("nico")
	_assert(main.companion_id == "nico", "companion selector can switch active companion")

	main.gold = 0
	main._deal_damage(true)
	_assert(main.attack_pose_timer > 0.0, "manual attack starts attack pose")
	_assert(main.slash_timer > 0.0, "manual attack starts slash effect")
	_assert(main.sprite_textures.has("fx_attack_slash"), "manual attack uses generated slash artwork")
	_assert(main.floating_damage_timer > 0.0, "manual attack starts damage number")
	var flash_rect: Rect2 = main._attack_flash_rect(Vector2(258, 350), Vector2(187, 398))
	_assert(flash_rect.size.x <= 230.0 and flash_rect.size.y <= 150.0, "attack flash stays compact around the hit area")
	_assert(flash_rect.has_point(Vector2(231, 368)), "attack flash remains anchored between hero sword and enemy")

	main.materials = 3
	main.camp_rank = 0
	main._upgrade_camp()
	_assert(main.camp_rank == 1, "camp upgrade increments camp rank")
	_assert(main.materials == 0, "camp upgrade spends materials")
	_assert(main._has_private_collectible("nico_drinker"), "Nico drinker unlocks at camp rank 1")
	_assert(main._camp_patrol_bonus() == 1, "Nico drinker adds patrol bonus")

	main.defeated = 4
	main.claimed_quests = 0
	main.weapon_rank = 1
	main.talisman_rank = 1
	main.equipped_weapon_rank = 1
	main.equipped_talisman_rank = 1
	main.equipment_inventory = {"weapon_1": 1, "talisman_1": 1}
	main.loaded_equipment_inventory = true
	main.gold = 0
	main.materials = 0
	main._claim_quest_reward()
	_assert(main.claimed_quests == 1, "quest reward marks milestone claimed")
	_assert(main.gold == 30, "quest reward applies equipment set gold multiplier")
	_assert(main.materials > 0, "quest reward grants materials")
	main._open_detail(main._equipment_set_detail())
	_assert(main.detail_overlay.visible, "equipment set detail popup opens")
	_assert(_node_text(main.detail_extra_container).contains("金币"), "equipment set detail shows set affix in sections")
	_assert(main.detail_extra_container.visible and main.detail_extra_container.get_child_count() >= 2, "equipment set detail shows piece image guide")
	main._hide_detail_overlay()
	main.weapon_rank = 2
	main.talisman_rank = 1
	main.equipped_weapon_rank = 2
	main.equipped_talisman_rank = 1
	main.equipment_inventory = {"weapon_2": 1, "talisman_1": 1}
	main._open_detail(main._equipment_set_detail(2))
	_assert(_node_text(main.detail_extra_container).contains("缺少护符 Lv.2"), "equipment set detail names the missing piece")
	_assert(main.detail_extra_container.visible, "missing set still shows visual piece slots")
	main._hide_detail_overlay()

	main.camp_rank = 1
	main.talisman_rank = 0
	main.equipped_talisman_rank = 0
	main.gold = 70
	main.materials = 4
	main._upgrade_talisman()
	_assert(main.talisman_rank == 1, "talisman upgrade increments talisman rank")
	_assert(main.equipped_talisman_rank == 0, "talisman strengthen does not replace the worn talisman")
	_assert(main.gold == 0, "talisman upgrade spends gold")
	_assert(main.materials == 0, "talisman upgrade spends materials")
	main.talisman_rank = 2
	main.equipped_talisman_rank = 0
	main.equipment_inventory = {"talisman_0": 1, "talisman_1": 1, "talisman_2": 1, "weapon_0": 1}
	main._open_detail(main._talisman_detail(1))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "talisman detail popup shows equipment artwork")
	_assert(_node_text(main.detail_extra_container).contains("强化"), "talisman detail shows strengthen section")
	main._on_detail_primary()
	_assert(main.equipped_talisman_rank == 1, "talisman detail can equip owned rank")
	main.talisman_rank = 2
	main.equipped_talisman_rank = 1
	main.gold = 0
	main.materials = 0
	main._open_detail(main._talisman_detail(2))
	main._on_detail_secondary()
	_assert(main.talisman_rank == 2 and not main.equipment_inventory.has("talisman_2"), "talisman detail can decompose extra equipment without lowering slot strengthen")
	_assert(main.gold > 0 and main.materials > 0, "talisman decompose returns resources")

	main.defeated = 12
	main.weapon_rank = 0
	main.equipped_weapon_rank = 0
	main.gold = 50
	main.inventory["苔影露珠"] = 2
	main._upgrade_weapon()
	_assert(main.weapon_rank == 1, "weapon upgrade increments weapon rank")
	_assert(main.equipped_weapon_rank == 0, "weapon strengthen does not replace the worn weapon")
	_assert(main.gold == 0, "weapon upgrade spends gold")
	_assert(not main.inventory.has("苔影露珠"), "weapon upgrade spends required item")
	_assert(main._hero_damage_value() > main.DATA.hero_damage(main.level, main.training_rank, 0), "weapon slot strengthen increases damage")
	main.weapon_rank = 2
	main.equipped_weapon_rank = 0
	main.equipment_inventory = {"weapon_0": 1, "weapon_1": 1, "weapon_2": 1, "talisman_0": 1}
	main._open_detail(main._weapon_detail(1))
	_assert(main.detail_image_rect.visible and main.detail_image_rect.texture != null, "weapon detail popup shows equipment artwork")
	_assert(_node_text(main.detail_extra_container).contains("强化"), "weapon detail shows strengthen section")
	main._on_detail_primary()
	_assert(main.equipped_weapon_rank == 1, "weapon detail can equip owned rank")
	main._set_tab("growth")
	await process_frame
	_assert(main.upgrade_row.visible and not main.action_row.visible, "growth tab uses training and upgrade action row")
	_assert(main.content_scroll.custom_minimum_size.y >= 300.0, "growth tab gives upgrades a larger scroll area")
	main._set_tab("battle")
	await process_frame
	_assert(main.action_row.visible and main.attack_button.visible and main.quest_claim_button.visible, "battle tab keeps attack and reward actions")
	_assert(main.content_scroll.custom_minimum_size.y <= 140.0, "battle tab keeps scene-focused compact scroll area")
	_assert(not main.enemy_name_label.visible and not main.enemy_hp_bar.visible, "battle enemy HP is moved out of the bottom panel")
	_assert(main.scene_spacer.custom_minimum_size.y >= 360.0, "battle tab reserves more visible scene space")
	_assert(main.sprite_textures.has("battle_area_map"), "battle tab loads generated linear map artwork")
	main.stage = 10
	main._select_battle_area("mushroom_grove")
	_assert(main.selected_area_id == "mushroom_grove", "battle map can select idle area")
	_assert(str(main.enemy.get("drop", "")) == "月光孢子", "selected idle area changes current drop")
	main.stage = 21
	main._select_battle_area("moonroot_corridor")
	_assert(main.selected_area_id == "moonroot_corridor", "post-second-moon idle area can be selected")
	_assert(str(main.enemy.get("drop", "")) == "月露结晶", "post-second-moon idle area feeds moon crystal loop")
	main.stage = 1
	main.selected_area_id = "camp_clearing"
	main._select_battle_area("moon_spring_gate")
	_assert(main.selected_area_id == "camp_clearing", "locked idle area falls back to unlocked default")
	main._set_tab("inventory")
	await process_frame
	main.content_dirty = false
	main.enemy_hp = 9999
	main.enemy_max_hp = 9999
	main._deal_damage(false)
	_assert(not main.content_dirty, "non-lethal attack does not force inventory hover rows to rebuild")
	main.talisman_rank = 2
	main.equipped_talisman_rank = 2
	main.equipped_weapon_rank = 2
	_assert(main._equipment_set_drop_bonus() > 0.0, "moon spore set grants drop chance bonus")
	var dungeon_reward: Dictionary = main._dungeon_reward_preview("moon_mine")
	_assert(int(dungeon_reward.get("materials", 0)) >= 8, "equipment set can preview dungeon reward")
	main.weapon_rank = 2
	main.equipped_weapon_rank = 1
	main.gold = 0
	main.inventory.clear()
	main._open_detail(main._weapon_detail(2))
	main._on_detail_secondary()
	_assert(main.weapon_rank == 2 and not main.equipment_inventory.has("weapon_2"), "weapon detail can decompose extra equipment without lowering slot strengthen")
	_assert(main.gold > 0 and main.inventory.size() > 0, "weapon decompose returns gold and item")

	if failures.is_empty():
		print("SMOKE PASS: inventory details/categories, daily sign-in, daily tasks, chapter settlement/quiet moon epilogue, dungeons/equipment drops/stage 14 outpost/stage 20 second moon boss/stage 24 quiet moon patrol, second moon tear and quiet moon petal awakening, post-second-moon battle area, moon spring tickets, boss encounter/countdown/failure/reward, dungeon feedback/animation, companion active/support/selector, title equip, album progress, battle map area selection, attack feedback, quest reward, and equipment strengthen/equip/decompose")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append("SMOKE FAIL: " + message)

func _node_text(node: Node) -> String:
	var parts: Array[String] = []
	if node is Label:
		parts.append((node as Label).text)
	elif node is Button:
		parts.append((node as Button).text)
	for child in node.get_children():
		parts.append(_node_text(child))
	return "\n".join(parts)
