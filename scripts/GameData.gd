class_name GameData
extends RefCounted

const ENEMIES := [
	{
		"name": "苔影史莱姆",
		"hp": 28,
		"xp": 8,
		"gold": 7,
		"drop": "苔影露珠",
		"color": "#78a66a",
		"sprite": "enemy_moss_slime",
	},
	{
		"name": "夜巡蘑菇",
		"hp": 38,
		"xp": 11,
		"gold": 10,
		"drop": "月光孢子",
		"color": "#c68a7a",
		"sprite": "enemy_mushroom",
	},
	{
		"name": "树根小怪",
		"hp": 52,
		"xp": 15,
		"gold": 14,
		"drop": "暖木碎片",
		"color": "#9b6b42",
		"sprite": "enemy_root_sprout",
	},
]

const BATTLE_AREAS := [
	{
		"id": "camp_clearing",
		"name": "营地外围",
		"short": "营地",
		"unlock_stage": 1,
		"enemy_index": 0,
		"drop": "苔影露珠",
		"map_x": 0.08,
		"map_y": 0.64,
	},
	{
		"id": "moss_pond",
		"name": "苔影水洼",
		"short": "水洼",
		"unlock_stage": 3,
		"enemy_index": 0,
		"drop": "苔影露珠",
		"map_x": 0.30,
		"map_y": 0.58,
	},
	{
		"id": "mushroom_grove",
		"name": "夜菇林",
		"short": "夜菇",
		"unlock_stage": 4,
		"enemy_index": 1,
		"drop": "月光孢子",
		"map_x": 0.50,
		"map_y": 0.52,
	},
	{
		"id": "warm_root_hollow",
		"name": "暖根洞",
		"short": "暖根",
		"unlock_stage": 7,
		"enemy_index": 2,
		"drop": "暖木碎片",
		"map_x": 0.70,
		"map_y": 0.58,
	},
	{
		"id": "moon_spring_gate",
		"name": "月泉门",
		"short": "月泉",
		"unlock_stage": 10,
		"enemy_index": 1,
		"drop": "月泉钥匙",
		"map_x": 0.91,
		"map_y": 0.60,
	},
	{
		"id": "moonroot_corridor",
		"name": "月根回廊",
		"short": "月根",
		"unlock_stage": 21,
		"enemy_index": 2,
		"drop": "月露结晶",
		"map_x": 0.84,
		"map_y": 0.42,
	},
	{
		"id": "quiet_moon_ridge",
		"name": "静月坡",
		"short": "静月",
		"unlock_stage": 24,
		"enemy_index": 1,
		"drop": "静月花瓣",
		"map_x": 0.92,
		"map_y": 0.30,
	},
]

const LOOT_DESCRIPTIONS := {
	"苔影露珠": "湿润的绿色露珠，可用来给营地草药盆充能。",
	"月光孢子": "带一点粉紫月光的孢子，适合做夜间药剂。",
	"暖木碎片": "从树根小怪身上掉下来的温热木片，可修补营地设施。",
	"小鱼干": "小咪很在意但假装不在意的伙伴零食。",
	"月露结晶": "像月光凝成的小石头，后续可用于稀有强化。",
	"月泉钥匙": "可以打开月泉试炼入口的旧钥匙，是挑战月泉试炼的门票。",
	"苔月露核": "苔月巨史莱姆体内凝出来的小核心，带着一点月泉的亮光。",
	"第二月泪": "第二口月泉守卫掉落的弯月泪晶，里面有更深处森林的回声。",
	"静月花瓣": "静月坡上落下的淡紫花瓣，边缘像一小片弯月。",
}

const LOOT_USES := {
	"苔影露珠": "武器强化材料；后续也适合做草药盆配方。",
	"月光孢子": "武器强化材料；后续可扩展为夜间药剂素材。",
	"暖木碎片": "武器强化材料；也适合作为营地修补材料。",
	"小鱼干": "用于喂养出战伙伴，提高伙伴等级和额外金币。",
	"月露结晶": "后续稀有装备、Boss 试炼和图鉴解锁材料。",
	"月泉钥匙": "用于进入月泉试炼；试炼通关后可带回月露结晶和营地材料。",
	"苔月露核": "第 10 区小 Boss 的专属掉落，后续可用于武器觉醒和 Boss 图鉴。",
	"第二月泪": "第 20 区 Boss 的专属掉落，用于第一章后段的武器和护符月泉觉醒。",
	"静月花瓣": "第 24 区后的新循环材料，用于静月坡巡礼和更高阶月泉觉醒。",
}

const LOOT_SPRITES := {
	"苔影露珠": "item_moss_dew",
	"月光孢子": "item_moon_spore",
	"暖木碎片": "item_warm_wood",
	"小鱼干": "item_dried_fish",
	"月露结晶": "item_moon_crystal",
	"月泉钥匙": "item_moon_key",
	"苔月露核": "item_moss_moon_core",
	"第二月泪": "item_second_moon_tear",
	"静月花瓣": "item_quiet_moon_petal",
	"营地材料": "item_camp_materials",
	"金币": "icon_coins_large",
	"第一章徽章": "item_chapter1_crest",
}

const PERSONAL_EVENT_LOGS := [
	"小咪把掉落金币扒拉到你脚边。",
	"小咪检查了一下背包，确认亮晶晶都还在。",
	"营地火堆噼啪响了一下，看起来更像家了。",
	"有只飞蛾撞上灯笼，但它假装没事。",
	"背包里多了一张便签：记得保存。",
	"树根小怪倒下前表示今天也很累。",
	"小咪认真盯着草丛，好像那里藏着什么。",
	"月光落在口袋边上，亮了一小下。",
	"营地风铃轻轻响了一声，巡逻继续。",
	"小咪把爪子收好，假装刚才什么都没扒拉。",
]

const COMPANIONS := {
	"nico": {
		"name": "nico",
		"species": "北美赤狐",
		"role": "狐火伙伴",
		"effect_name": "狐火领路",
		"unlock": "推进到第 6 区或累计签到 2 次",
		"active_name": "狐火领路",
		"support_name": "狐尾标记",
		"active_description": "上阵时，提高攻击伤害。",
		"support_description": "未上阵时，提供少量攻击伤害。",
		"sprite": "companion_nico",
		"description": "北美赤狐，脚步很轻，会把小怪往更好打的位置引。",
	},
	"xiaomi": {
		"name": "小咪猫",
		"species": "奶牛猫",
		"role": "主线伙伴",
		"effect_name": "亮晶晶扒拉",
		"unlock": "默认解锁",
		"active_name": "亮晶晶扒拉",
		"support_name": "亮晶晶提醒",
		"active_description": "上阵时，击败小怪后额外扒拉金币并推进羁绊。",
		"support_description": "未上阵时，仍会提醒你别漏掉金币。",
		"sprite": "companion_xiaomi",
		"description": "所有亮晶晶的东西，最后都会被小咪认真扒拉一下。",
	},
	"little_xiaomi": {
		"name": "小小咪猫",
		"species": "狸花猫",
		"role": "追击伙伴",
		"effect_name": "狸花追击",
		"unlock": "推进到第 4 区或喂养伙伴 1 次",
		"active_name": "狸花追击",
		"support_name": "草丛盯梢",
		"active_description": "上阵时，手动和自动攻击都会获得额外伤害。",
		"support_description": "未上阵时，提供少量额外伤害。",
		"sprite": "companion_little_xiaomi",
		"description": "狸花猫，盯着草丛的时候特别认真，像是在等一个偷袭机会。",
	},
	"zizi": {
		"name": "姊姊",
		"species": "纯白蜜袋鼯",
		"role": "巡逻伙伴",
		"effect_name": "夜巡滑翔",
		"unlock": "推进到第 5 区或累计签到 2 次",
		"active_name": "夜巡滑翔",
		"support_name": "帐篷上方巡逻",
		"active_description": "上阵时，提高巡逻和离线金币收益。",
		"support_description": "未上阵时，提供少量巡逻和离线金币。",
		"sprite": "companion_zizi",
		"description": "白色小巡逻员，总能从营地上方滑过去看一眼。",
	},
	"meimei": {
		"name": "妹妹",
		"species": "杂色蜜袋鼯",
		"role": "寻物伙伴",
		"effect_name": "藏货雷达",
		"unlock": "推进到第 10 区或喂养伙伴 1 次",
		"active_name": "藏货雷达",
		"support_name": "小材料嗅觉",
		"active_description": "上阵时，提高怪物掉落率，并偶尔多带回一份专属掉落。",
		"support_description": "未上阵时，略微提高怪物掉落率。",
		"sprite": "companion_meimei",
		"description": "看起来慢吞吞，其实很会发现小怪藏起来的材料。",
	},
	"tutu": {
		"name": "图图",
		"species": "棕色兔子",
		"role": "营地伙伴",
		"effect_name": "木材搬运",
		"unlock": "营地 1 级",
		"active_name": "木材搬运",
		"support_name": "小木堆整理",
		"active_description": "上阵时，击败小怪有机会额外带回营地材料。",
		"support_description": "未上阵时，任务奖励会获得少量营地材料。",
		"sprite": "companion_tutu",
		"description": "棕色兔子，总能从草丛里拖回一截看起来很有用的木头。",
	},
	"dudu": {
		"name": "嘟嘟",
		"species": "棕色兔子",
		"role": "任务伙伴",
		"effect_name": "奖励藏兜",
		"unlock": "累计签到 3 次或营地 2 级",
		"active_name": "奖励藏兜",
		"support_name": "备用口袋",
		"active_description": "上阵时，任务领奖获得额外金币和材料。",
		"support_description": "未上阵时，任务领奖获得少量额外金币。",
		"sprite": "companion_dudu",
		"description": "棕色兔子，看起来无辜，其实很会把奖励藏进兜里。",
	},
}

const COMPANION_ORDER := ["nico", "xiaomi", "little_xiaomi", "zizi", "meimei", "tutu", "dudu"]

const PRIVATE_COLLECTIBLES := {
	"laifu_relic_bell": {
		"name": "来福圣遗物铃铛",
		"type": "圣遗物",
		"unlock": "小咪羁绊 1 级",
		"effect": "小咪每次扒拉金币 +1G",
		"short_effect": "小咪金币 +1",
		"sprite": "collectible_laifu_bell",
		"description": "听见铃声，就说明亮晶晶要被小咪认真收好了。",
	},
	"nico_drinker": {
		"name": "nico 爱喝的小猫饮水机",
		"type": "营地摆件",
		"unlock": "营地 1 级",
		"effect": "巡逻和离线金币 +1G/分钟",
		"short_effect": "巡逻/离线 +1",
		"sprite": "collectible_nico_drinker",
		"description": "一直咕噜咕噜的小饮水机，放在营地里会让人觉得很安心。",
	},
}

const WEAPON_NAMES := [
	"旧木剑",
	"月露短剑",
	"孢子弯刀",
	"暖木长剑",
	"月森守护刃",
]

const WEAPON_SPRITES := [
	"weapon_wood_sword",
	"weapon_moon_dagger",
	"weapon_spore_saber",
	"weapon_warmwood_longsword",
	"weapon_moon_guardian_blade",
]

const TALISMAN_NAMES := [
	"旧铜护符",
	"苔光护符",
	"月孢护符",
	"暖木护符",
	"月森护符",
]

const TALISMAN_SPRITES := [
	"talisman_old_copper",
	"talisman_mosslight",
	"talisman_moonspore",
	"talisman_warmwood",
	"talisman_moonforest",
]

const EQUIPMENT_SETS := [
	{
		"name": "旧营地套",
		"short_effect": "未形成套装加成",
		"effect": "旧木剑和旧铜护符只是基础装备，暂时没有 2 件套效果。",
		"description": "最早的营地装备，能用，但还谈不上真正的套装。",
	},
	{
		"name": "苔光套",
		"short_effect": "任务金币 +12%",
		"effect": "2 件套：任务领奖金币 +12%。",
		"description": "苔光贴在剑柄和护符上，提醒小咪不要漏掉领奖。",
	},
	{
		"name": "月孢套",
		"short_effect": "怪物掉落率 +7%",
		"effect": "2 件套：怪物掉落率 +7%。",
		"description": "月光孢子会轻轻发亮，适合寻找小怪藏起来的材料。",
	},
	{
		"name": "暖木套",
		"short_effect": "副本金材 +12%",
		"effect": "2 件套：副本金币和营地材料 +12%。",
		"description": "暖木纹路让每日小探险更稳定，带回来的东西也更扎实。",
	},
	{
		"name": "月森守护套",
		"short_effect": "攻击 +10，任务/副本 +18%",
		"effect": "2 件套：攻击 +10；任务金币和副本金材 +18%。",
		"description": "月森外围的阶段性毕业装备，适合准备挑战更大的敌人。",
	},
]

const EQUIPMENT_AWAKEN_MAX_RANK := 3

const DAILY_REWARDS := [
	{
		"title": "第 1 天",
		"description": "小咪今天先扒拉到一点启动资金。",
		"gold": 80,
		"materials": 0,
		"items": {},
	},
	{
		"title": "第 2 天",
		"description": "营地旁边多了一小堆木头。",
		"gold": 0,
		"materials": 4,
		"items": {},
	},
	{
		"title": "第 3 天",
		"description": "不知道谁把零食藏在背包底下。",
		"gold": 0,
		"materials": 0,
		"items": {"小鱼干": 2},
	},
	{
		"title": "第 4 天",
		"description": "今天适合出门多转一圈。",
		"gold": 120,
		"materials": 0,
		"items": {"苔影露珠": 2},
	},
	{
		"title": "第 5 天",
		"description": "月光落在口袋里，变成了一颗小石头。",
		"gold": 0,
		"materials": 0,
		"items": {"月露结晶": 1},
	},
	{
		"title": "第 6 天",
		"description": "营地库存被认真整理了一遍。",
		"gold": 0,
		"materials": 8,
		"items": {"月光孢子": 2},
	},
	{
		"title": "第 7 天",
		"description": "小咪看起来有点想挑战大的。",
		"gold": 220,
		"materials": 0,
		"items": {"小鱼干": 4, "月泉钥匙": 1},
	},
]

const DAILY_TASKS := [
	{
		"id": "defeat_8",
		"title": "清理小怪",
		"description": "今天清理 8 只月森外围小怪，让营地周围安静一点。",
		"progress_key": "defeats",
		"target": 8,
		"reward": {"gold": 90, "materials": 1, "items": {}},
	},
	{
		"id": "claim_quest",
		"title": "领取区域奖励",
		"description": "完成一次区域任务领奖，把小咪扒拉出来的东西收好。",
		"progress_key": "quest_rewards",
		"target": 1,
		"reward": {"gold": 60, "materials": 2, "items": {}},
	},
	{
		"id": "upgrade_once",
		"title": "补强一次",
		"description": "完成一次训练、营地升级、武器强化或护符强化。",
		"progress_key": "upgrades",
		"target": 1,
		"reward": {"gold": 0, "materials": 2, "items": {"苔影露珠": 1}},
	},
	{
		"id": "clear_dungeon",
		"title": "每日小探险",
		"description": "通关任意一个每日副本，带回一份定向材料。",
		"progress_key": "dungeons",
		"target": 1,
		"reward": {"gold": 80, "materials": 0, "items": {"月光孢子": 1}},
	},
]

const CHAPTER_GOALS := {
	"chapter_1_moon_camp": {
		"name": "第一章 · 月森营地",
		"type": "章节结算",
		"sprite": "item_chapter1_crest",
		"description": "第二口月泉安静下来，营地的第一章告一段落。新的月根路线已经在森林深处亮起。",
		"goals": [
			{"id": "stage_20", "label": "推进到第 20 区"},
			{"id": "second_moon_clear", "label": "击败第二月泉守望者"},
			{"id": "moon_awakening", "label": "完成任意 1 次月泉觉醒"},
		],
		"reward": {
			"gold": 1600,
			"materials": 36,
			"items": {"月露结晶": 3, "第二月泪": 1},
			"equipment": {"weapon_4": 1, "talisman_4": 1},
		},
		"claim_feedback": "月根路线已经接上，静月坡开始掉落新的花瓣材料。",
	},
	"chapter_1_quiet_moon_epilogue": {
		"name": "第一章 · 静月尾声",
		"type": "章节尾声",
		"sprite": "item_quiet_moon_petal",
		"description": "静月坡的花瓣被收进营地手册，第一章真正进入尾声。月森深处还有路，但营地已经不再只是临时落脚点。",
		"goals": [
			{"id": "chapter_1_claimed", "label": "领取第一章结算"},
			{"id": "stage_24", "label": "推进到第 24 区静月坡"},
			{"id": "quiet_moon_patrol_clear", "label": "完成 1 次静月坡巡礼"},
			{"id": "moon_awakening_2", "label": "完成任意 1 条月泉觉醒 Lv.2"},
		],
		"reward": {
			"gold": 2400,
			"materials": 48,
			"items": {"静月花瓣": 4, "月露结晶": 4, "第二月泪": 1},
			"equipment": {"weapon_4": 1, "talisman_4": 1},
		},
		"claim_feedback": "静月尾声已点亮，后续可以继续扩展第二章入口或更深的月森路线。",
	},
}

const CHAPTER_GOAL_ORDER := ["chapter_1_moon_camp", "chapter_1_quiet_moon_epilogue"]

const DUNGEONS := {
	"gold_cave": {
		"name": "亮晶晶洞穴",
		"type": "金币副本",
		"unlock_stage": 1,
		"unlock_camp": 0,
		"daily_attempts": 2,
		"base_power": 18,
		"power_per_stage": 2,
		"sprite": "icon_coins_large",
		"description": "小咪闻到亮晶晶的味道。每天可以进去扒拉几次集中金币。",
		"reward": {"gold": 120, "materials": 0, "items": {}, "equipment": {"weapon_1": 1}},
		"reward_gold_per_stage": 12,
		"reward_materials_per_stage": 0,
	},
	"moon_mine": {
		"name": "月露矿道",
		"type": "材料副本",
		"unlock_stage": 3,
		"unlock_camp": 1,
		"daily_attempts": 2,
		"base_power": 30,
		"power_per_stage": 3,
		"sprite": "item_camp_materials",
		"description": "营地后面的浅矿道。适合每天捡一点修补营地用的材料。",
		"reward": {"gold": 30, "materials": 8, "items": {}, "equipment": {"talisman_1": 1}},
		"reward_gold_per_stage": 4,
		"reward_materials_per_stage": 1,
	},
	"spore_nest": {
		"name": "孢子巢穴",
		"type": "专属材料副本",
		"unlock_stage": 5,
		"unlock_camp": 1,
		"daily_attempts": 1,
		"base_power": 42,
		"power_per_stage": 4,
		"sprite": "item_moon_spore",
		"description": "夜巡蘑菇的小仓库。能定向拿到武器强化需要的怪物材料。",
		"reward": {"gold": 55, "materials": 2, "items": {"月光孢子": 3, "苔影露珠": 2}, "equipment": {"weapon_2": 1, "talisman_2": 1}},
		"reward_gold_per_stage": 6,
		"reward_materials_per_stage": 0,
	},
	"moon_spring_trial": {
		"name": "月泉试炼",
		"type": "钥匙试炼",
		"unlock_stage": 10,
		"unlock_camp": 2,
		"daily_attempts": 1,
		"base_power": 72,
		"power_per_stage": 5,
		"requires_item": "月泉钥匙",
		"requires_item_amount": 1,
		"boss_id": "moss_moon_slime",
		"sprite": "item_moon_key",
		"description": "营地北侧的月泉入口。需要月泉钥匙开启，适合每天打一场小试炼。",
		"reward": {"gold": 180, "materials": 6, "items": {"月露结晶": 1, "苔月露核": 1}, "equipment": {"weapon_3": 1, "talisman_3": 1}},
		"reward_gold_per_stage": 10,
		"reward_materials_per_stage": 1,
	},
	"moon_guard_outpost": {
		"name": "月森前哨",
		"type": "装备前哨",
		"unlock_stage": 14,
		"unlock_camp": 2,
		"daily_attempts": 1,
		"base_power": 96,
		"power_per_stage": 5,
		"sprite": "weapon_moon_guardian_blade",
		"description": "第 10 区之后的稳定目标。守在月森更深处的小前哨，会掉落阶段毕业装备件。",
		"reward": {"gold": 110, "materials": 4, "items": {"暖木碎片": 4, "月露结晶": 1}, "equipment": {"weapon_4": 1, "talisman_4": 1}},
		"reward_gold_per_stage": 8,
		"reward_materials_per_stage": 1,
	},
	"second_moon_spring_preview": {
		"name": "第二口月泉",
		"type": "第 20 区 Boss 试炼",
		"unlock_stage": 20,
		"unlock_camp": 3,
		"daily_attempts": 1,
		"base_power": 150,
		"power_per_stage": 6,
		"requires_item": "月露结晶",
		"requires_item_amount": 2,
		"boss_id": "second_moon_warden",
		"sprite": "boss_second_moon_warden",
		"description": "第 20 区的第二口月泉已经醒来。投入月露结晶后，森林根须会聚成月泉守望者。",
		"reward": {"gold": 260, "materials": 8, "items": {"月露结晶": 2, "第二月泪": 1}, "equipment": {"weapon_4": 1, "talisman_4": 1}},
		"reward_gold_per_stage": 10,
		"reward_materials_per_stage": 1,
	},
	"quiet_moon_ridge_patrol": {
		"name": "静月坡巡礼",
		"type": "后段材料副本",
		"unlock_stage": 24,
		"unlock_camp": 3,
		"daily_attempts": 1,
		"base_power": 188,
		"power_per_stage": 7,
		"requires_item": "静月花瓣",
		"requires_item_amount": 3,
		"sprite": "item_quiet_moon_petal",
		"description": "第二月泉平息后的第一段后续巡礼。小咪会沿着静月坡把花瓣、月露结晶和遗落装备一起带回来。",
		"reward": {"gold": 340, "materials": 10, "items": {"静月花瓣": 4, "月露结晶": 3, "第二月泪": 1}, "equipment": {"weapon_4": 1, "talisman_4": 1}},
		"reward_gold_per_stage": 12,
		"reward_materials_per_stage": 1,
	},
}

const DUNGEON_ORDER := ["gold_cave", "moon_mine", "spore_nest", "moon_spring_trial", "moon_guard_outpost", "second_moon_spring_preview", "quiet_moon_ridge_patrol"]

const BOSSES := {
	"moss_moon_slime": {
		"name": "苔月巨史莱姆",
		"type": "第 10 区小 Boss",
		"hp": 520,
		"xp": 90,
		"sprite": "boss_moss_moon_slime",
		"drop": "苔月露核",
		"description": "月泉边沉睡很久的大史莱姆，背上长着苔藓和小叶子，身体里有一枚亮着的月牙。",
		"hint": "血量比普通小怪厚很多，但没有复杂招式。打不过就先训练、强化武器和换上攻击伙伴。",
		"time_limit": 95,
		"fail_reward": {"gold": 40, "materials": 2, "items": {"月光孢子": 1}},
		"draw_height": 118,
		"draw_y_offset": -88,
	},
	"second_moon_warden": {
		"name": "第二月泉守望者",
		"type": "第 20 区 Boss",
		"hp": 1180,
		"xp": 180,
		"sprite": "boss_second_moon_warden",
		"drop": "第二月泪",
		"attack_fx": "fx_moon_spring_slash",
		"description": "第二口月泉旁的根须守卫，胸口嵌着弯月晶核，动作很慢，但每一次挥击都带着月泉的回声。",
		"hint": "这是第一章后段目标。建议先穿戴月森守护套，补训练和攻击伙伴，再消耗月露结晶挑战。",
		"time_limit": 130,
		"fail_reward": {"gold": 90, "materials": 4, "items": {"月露结晶": 1}},
		"draw_height": 142,
		"draw_y_offset": 42,
	},
}

const ALBUM_ENTRIES := [
	{
		"id": "camp_arrival",
		"title": "月森营地第一夜",
		"type": "回忆",
		"unlock": "进入游戏",
		"description": "营火重新点亮，自动冒险从这里开始。",
	},
	{
		"id": "first_drop",
		"title": "第一份怪物掉落",
		"type": "图鉴",
		"unlock": "背包里拥有任意掉落物",
		"description": "小怪掉下来的东西终于不只是数字，而是真的进了背包。",
	},
	{
		"id": "camp_rank_1",
		"title": "营地有点像家了",
		"type": "营地",
		"unlock": "营地 1 级",
		"description": "修过一次之后，火堆旁边看起来安心了一点。",
	},
	{
		"id": "weapon_rank_1",
		"title": "第一把强化武器",
		"type": "装备",
		"unlock": "武器 1 级",
		"description": "剑刃亮了一点，打小怪的时候终于有了仪式感。",
	},
	{
		"id": "xiaomi_bond_1",
		"title": "小咪认真点头",
		"type": "伙伴",
		"unlock": "小咪羁绊 1 级",
		"description": "小咪好像认可了这个营地，也更会扒拉金币了。",
	},
	{
		"id": "daily_3",
		"title": "三天都来看了",
		"type": "签到",
		"unlock": "累计签到 3 次",
		"description": "月森营地已经开始像一个每天会回来看看地方。",
	},
	{
		"id": "snack_feed",
		"title": "小鱼干外交",
		"type": "伙伴",
		"unlock": "喂养伙伴 1 次",
		"description": "小鱼干消失得很快，但小咪假装这件事和它无关。",
	},
	{
		"id": "stage_10",
		"title": "走到第十区",
		"type": "区域",
		"unlock": "推进到第 10 区",
		"description": "营地外围已经熟悉了，森林深处开始露出轮廓。",
	},
	{
		"id": "laifu_bell",
		"title": "来福铃铛响了一下",
		"type": "私人收藏",
		"unlock": "来福圣遗物铃铛生效",
		"description": "听见铃声，就说明亮晶晶被认真收好了。",
	},
	{
		"id": "nico_drinker",
		"title": "咕噜咕噜的饮水机",
		"type": "私人收藏",
		"unlock": "nico 爱喝的小猫饮水机生效",
		"description": "放在营地里之后，巡逻收益也变得稳定了一点。",
	},
	{
		"id": "first_dungeon_clear",
		"title": "第一次副本小探险",
		"type": "副本",
		"unlock": "完成任意副本 1 次",
		"description": "这不是远行，只是每天从营地旁边多带回一点好东西。",
	},
	{
		"id": "spore_nest_clear",
		"title": "翻过蘑菇的小仓库",
		"type": "副本",
		"unlock": "完成孢子巢穴 1 次",
		"description": "小怪也有库存，而且库存确实能用来强化武器。",
	},
	{
		"id": "moss_moon_boss_clear",
		"title": "月泉边的大咕噜",
		"type": "Boss",
		"unlock": "击败苔月巨史莱姆 1 次",
		"description": "它倒下的时候，月泉像被轻轻搅了一下。",
	},
	{
		"id": "stage_20_preview",
		"title": "第二口月泉的回声",
		"type": "区域",
		"unlock": "推进到第 20 区",
		"description": "森林深处传来第二口月泉的回声，守望者已经醒来。",
	},
	{
		"id": "second_moon_boss_clear",
		"title": "第二月泉守望者倒下",
		"type": "Boss",
		"unlock": "击败第二月泉守望者 1 次",
		"description": "第二口月泉安静下来，弯月泪晶落进了背包。",
	},
	{
		"id": "first_moon_awakening",
		"title": "第一道月泉觉醒",
		"type": "装备",
		"unlock": "完成任意 1 次装备月泉觉醒",
		"description": "第二月泪不再只是收藏品，它开始改变武器和护符的月光回路。",
	},
	{
		"id": "chapter_1_clear",
		"title": "第一章收束",
		"type": "章节",
		"unlock": "完成第一章 · 月森营地结算目标",
		"description": "第二口月泉安静下来，营地终于有了进入下一段森林的理由。",
	},
	{
		"id": "quiet_moon_ridge",
		"title": "静月坡的第一片花瓣",
		"type": "区域",
		"unlock": "推进到第 24 区",
		"description": "静月坡的花瓣不像普通材料，更像森林留下的路标。",
	},
	{
		"id": "quiet_moon_patrol_clear",
		"title": "静月坡巡礼完成",
		"type": "副本",
		"unlock": "完成静月坡巡礼 1 次",
		"description": "第二月泉之后的第一段日常目标被接上，营地开始稳定收集静月花瓣。",
	},
	{
		"id": "chapter_1_epilogue",
		"title": "静月尾声",
		"type": "章节",
		"unlock": "完成第一章 · 静月尾声",
		"description": "第一章不只是打倒 Boss，还包括把后续路线真正接回营地。",
	},
]

const PLAYER_TITLES := [
	{
		"id": "camp_adventurer",
		"name": "月森营地冒险者",
		"type": "默认称号",
		"unlock": "默认解锁",
		"description": "从第一夜开始就在月森营地自动冒险的人。",
		"sprite": "icon_notification",
	},
	{
		"id": "cat_chosen",
		"name": "被猫选中的人",
		"type": "伙伴称号",
		"unlock": "小咪羁绊 1 级",
		"description": "小咪认真点头之后，营地就默认你是自己人了。",
		"sprite": "companion_xiaomi",
	},
	{
		"id": "set_apprentice",
		"name": "苔光套见习生",
		"type": "装备称号",
		"unlock": "激活任意 2 件套",
		"description": "终于知道武器和护符要配套穿的人。",
		"sprite": "weapon_moon_dagger",
	},
	{
		"id": "dungeon_scout",
		"name": "副本小探险家",
		"type": "副本称号",
		"unlock": "完成任意副本 1 次",
		"description": "不是远行，也能从营地边上带回好东西。",
		"sprite": "item_moon_key",
	},
	{
		"id": "stage_10_witness",
		"name": "第十区见证者",
		"type": "区域称号",
		"unlock": "推进到第 10 区",
		"description": "走到营地外围更深处，森林开始露出轮廓。",
		"sprite": "item_moon_crystal",
	},
	{
		"id": "daily_keeper",
		"name": "三天都来看了",
		"type": "日常称号",
		"unlock": "累计签到 3 次",
		"description": "月森营地已经变成每天会顺手打开的小地方。",
		"sprite": "item_dried_fish",
	},
	{
		"id": "moss_moon_clearer",
		"name": "月泉咕噜克星",
		"type": "Boss 称号",
		"unlock": "击败苔月巨史莱姆 1 次",
		"description": "第一个真正的大目标已经被你和小咪打倒。",
		"sprite": "item_moss_moon_core",
	},
	{
		"id": "stage_20_pathfinder",
		"name": "第二月泉探路者",
		"type": "区域称号",
		"unlock": "推进到第 20 区",
		"description": "已经走到第一章后段，第二口月泉的守望者就在前面。",
		"sprite": "item_moon_crystal",
	},
	{
		"id": "second_moon_clearer",
		"name": "第二月泉破阵者",
		"type": "Boss 称号",
		"unlock": "击败第二月泉守望者 1 次",
		"description": "击败第 20 区 Boss 后获得的称号，代表第一章后段已经被打开。",
		"sprite": "item_second_moon_tear",
	},
	{
		"id": "moon_awakener",
		"name": "月泪觉醒者",
		"type": "装备称号",
		"unlock": "完成任意 1 次装备月泉觉醒",
		"description": "把第二月泪真正用进装备回路的人，第一章后段成长从这里开始。",
		"sprite": "item_second_moon_tear",
	},
	{
		"id": "chapter_1_keeper",
		"name": "月森第一章守夜人",
		"type": "章节称号",
		"unlock": "完成第一章 · 月森营地结算目标",
		"description": "守住营地、打通第二口月泉，并准备继续往森林深处走的人。",
		"sprite": "item_chapter1_crest",
	},
	{
		"id": "quiet_moon_keeper",
		"name": "静月尾声记录者",
		"type": "章节称号",
		"unlock": "完成第一章 · 静月尾声",
		"description": "不是只打过 Boss，而是把静月坡的后续巡礼也记录进营地的人。",
		"sprite": "item_quiet_moon_petal",
	},
]

static func enemy_for_stage(stage: int) -> Dictionary:
	var base: Dictionary = ENEMIES[(stage - 1) % ENEMIES.size()].duplicate(true)
	var cycle: int = int((stage - 1) / ENEMIES.size())
	var scale: float = 1.0 + float(cycle) * 0.35 + float(stage - 1) * 0.08
	base["hp"] = int(round(float(base["hp"]) * scale))
	base["xp"] = int(round(float(base["xp"]) * (1.0 + float(stage - 1) * 0.12)))
	base["gold"] = int(round(float(base["gold"]) * (1.0 + float(stage - 1) * 0.10)))
	return base

static func enemy_for_area(area_id: String, stage: int) -> Dictionary:
	var area := battle_area(area_id)
	if area.is_empty():
		return enemy_for_stage(stage)
	var enemy_index := clampi(int(area.get("enemy_index", 0)), 0, ENEMIES.size() - 1)
	var effective_stage := maxi(stage, int(area.get("unlock_stage", 1)))
	var base: Dictionary = ENEMIES[enemy_index].duplicate(true)
	var cycle: int = int((effective_stage - 1) / maxi(1, ENEMIES.size()))
	var scale: float = 1.0 + float(cycle) * 0.35 + float(effective_stage - 1) * 0.08
	base["hp"] = int(round(float(base["hp"]) * scale))
	base["xp"] = int(round(float(base["xp"]) * (1.0 + float(effective_stage - 1) * 0.12)))
	base["gold"] = int(round(float(base["gold"]) * (1.0 + float(effective_stage - 1) * 0.10)))
	base["drop"] = str(area.get("drop", base.get("drop", "苔影露珠")))
	base["area_id"] = area_id
	base["area_name"] = str(area.get("name", "营地外围"))
	return base

static func battle_area(area_id: String) -> Dictionary:
	for area in BATTLE_AREAS:
		if str(area.get("id", "")) == area_id:
			return Dictionary(area).duplicate(true)
	return {}

static func battle_area_exists(area_id: String) -> bool:
	return not battle_area(area_id).is_empty()

static func battle_areas() -> Array[Dictionary]:
	var areas: Array[Dictionary] = []
	for area in BATTLE_AREAS:
		areas.append(Dictionary(area).duplicate(true))
	return areas

static func default_battle_area_id() -> String:
	return str(BATTLE_AREAS[0].get("id", "camp_clearing"))

static func xp_to_next(level: int) -> int:
	return int(24 + pow(float(level), 1.5) * 16.0)

static func hero_damage(level: int, training_rank: int, weapon_rank: int = 0) -> int:
	return 4 + level * 2 + training_rank * 3 + weapon_rank * 4

static func attack_interval(training_rank: int) -> float:
	return maxf(0.85, 1.55 - float(training_rank) * 0.04)

static func training_cost(training_rank: int) -> int:
	return 35 + training_rank * 24 + training_rank * training_rank * 4

static func camp_upgrade_cost(camp_rank: int) -> int:
	return 3 + camp_rank * 2

static func weapon_name(weapon_rank: int) -> String:
	if weapon_rank < WEAPON_NAMES.size():
		return WEAPON_NAMES[weapon_rank]
	return "%s +%d" % [WEAPON_NAMES[WEAPON_NAMES.size() - 1], weapon_rank - WEAPON_NAMES.size() + 1]

static func weapon_sprite(weapon_rank: int) -> String:
	if weapon_rank < WEAPON_SPRITES.size():
		return WEAPON_SPRITES[weapon_rank]
	return WEAPON_SPRITES[WEAPON_SPRITES.size() - 1]

static func weapon_upgrade_cost(weapon_rank: int) -> Dictionary:
	var items := ["苔影露珠", "月光孢子", "暖木碎片"]
	return {
		"gold": 50 + weapon_rank * 42,
		"item": items[weapon_rank % items.size()],
		"amount": 2 + weapon_rank,
	}

static func equipment_awaken_max_rank() -> int:
	return EQUIPMENT_AWAKEN_MAX_RANK

static func weapon_awaken_cost(awaken_rank: int) -> Dictionary:
	return {
		"gold": 420 + awaken_rank * 180,
		"tear": 1 + awaken_rank,
		"crystal": 2 + awaken_rank,
		"petal": 0 if awaken_rank <= 0 else 1 + awaken_rank * 2,
	}

static func talisman_awaken_cost(awaken_rank: int) -> Dictionary:
	return {
		"gold": 360 + awaken_rank * 160,
		"tear": 1 + awaken_rank,
		"materials": 12 + awaken_rank * 6,
		"petal": 0 if awaken_rank <= 0 else 1 + awaken_rank * 2,
	}

static func weapon_awaken_attack_bonus(awaken_rank: int) -> int:
	return clampi(awaken_rank, 0, EQUIPMENT_AWAKEN_MAX_RANK) * 6

static func talisman_awaken_patrol_bonus(awaken_rank: int) -> int:
	return clampi(awaken_rank, 0, EQUIPMENT_AWAKEN_MAX_RANK) * 2

static func talisman_awaken_quest_bonus(awaken_rank: int) -> int:
	return clampi(awaken_rank, 0, EQUIPMENT_AWAKEN_MAX_RANK) * 8

static func awaken_name(slot: String) -> String:
	return "月泉护符回响" if slot == "talisman" else "月泉刃痕"

static func talisman_name(talisman_rank: int) -> String:
	if talisman_rank < TALISMAN_NAMES.size():
		return TALISMAN_NAMES[talisman_rank]
	return "%s +%d" % [TALISMAN_NAMES[TALISMAN_NAMES.size() - 1], talisman_rank - TALISMAN_NAMES.size() + 1]

static func talisman_sprite(talisman_rank: int) -> String:
	if talisman_rank < TALISMAN_SPRITES.size():
		return TALISMAN_SPRITES[talisman_rank]
	return TALISMAN_SPRITES[TALISMAN_SPRITES.size() - 1]

static func talisman_upgrade_cost(talisman_rank: int) -> Dictionary:
	return {
		"gold": 70 + talisman_rank * 48,
		"materials": 4 + talisman_rank * 2,
	}

static func equipment_set_rank(weapon_rank: int, talisman_rank: int) -> int:
	return clampi(mini(weapon_rank, talisman_rank), 0, EQUIPMENT_SETS.size() - 1)

static func equipment_set(set_rank: int) -> Dictionary:
	var safe_rank := clampi(set_rank, 0, EQUIPMENT_SETS.size() - 1)
	return Dictionary(EQUIPMENT_SETS[safe_rank]).duplicate(true)

static func equipment_set_name(set_rank: int) -> String:
	return str(equipment_set(set_rank).get("name", "旧营地套"))

static func equipment_set_effect(set_rank: int) -> String:
	return str(equipment_set(set_rank).get("effect", "未形成套装加成。"))

static func equipment_set_short_effect(set_rank: int) -> String:
	return str(equipment_set(set_rank).get("short_effect", "未形成套装加成"))

static func equipment_set_description(set_rank: int) -> String:
	return str(equipment_set(set_rank).get("description", "同时穿戴相近阶位的武器和护符可以激活 2 件套。"))

static func quest_reward_for_milestone(milestone: int) -> Dictionary:
	return {
		"gold": 18 + milestone * 6,
		"materials": 2 if milestone % 3 == 0 else 1,
	}

static func offline_gold_per_minute(level: int, stage: int, training_rank: int) -> int:
	return maxi(4, level * 2 + stage + training_rank)

static func loot_description(item_name: String) -> String:
	return str(LOOT_DESCRIPTIONS.get(item_name, "来自森林的小材料，后续可用于制作和强化。"))

static func loot_use(item_name: String) -> String:
	return str(LOOT_USES.get(item_name, "用于后续制作、强化或任务提交。"))

static func loot_sprite(item_name: String) -> String:
	return str(LOOT_SPRITES.get(item_name, "item_camp_materials"))

static func weapon_description(weapon_rank: int) -> String:
	var name := weapon_name(weapon_rank)
	if weapon_rank <= 0:
		return "%s是营地最早的武器，伤害不高，但足够用来清理月森外围的小怪。" % name
	return "%s经过月森材料强化，剑刃更亮，适合推进更深的区域。" % name

static func weapon_effect(weapon_rank: int) -> String:
	return "当前武器提供 +%d 攻击力。" % (weapon_rank * 4)

static func weapon_decompose_reward(weapon_rank: int) -> Dictionary:
	var rank := maxi(1, weapon_rank)
	var spent := weapon_upgrade_cost(rank - 1)
	var spent_amount := int(spent["amount"])
	return {
		"gold": maxi(12, int(float(spent["gold"]) * 0.35)),
		"item": str(spent["item"]),
		"amount": maxi(1, int(float(spent_amount + 1) * 0.5)),
	}

static func talisman_description(talisman_rank: int) -> String:
	var name := talisman_name(talisman_rank)
	if talisman_rank <= 0:
		return "%s是旧铜做的小护符，先当作基础装备佩戴。" % name
	return "%s吸收了营地材料，能让巡逻、任务和离线收益更稳定。" % name

static func talisman_effect(talisman_rank: int) -> String:
	return "当前护符提供 +%d 巡逻/任务收益等级。" % talisman_rank

static func talisman_decompose_reward(talisman_rank: int) -> Dictionary:
	var rank := maxi(1, talisman_rank)
	var spent := talisman_upgrade_cost(rank - 1)
	return {
		"gold": maxi(16, int(float(spent["gold"]) * 0.35)),
		"materials": maxi(1, int(float(int(spent["materials"]) + 1) * 0.5)),
	}

static func equipment_id(slot: String, rank: int) -> String:
	return "%s_%d" % [slot, clampi(rank, 0, EQUIPMENT_SETS.size() - 1)]

static func equipment_slot(equipment_id: String) -> String:
	return equipment_id.get_slice("_", 0)

static func equipment_rank(equipment_id: String) -> int:
	return clampi(int(equipment_id.get_slice("_", 1)), 0, EQUIPMENT_SETS.size() - 1)

static func equipment_name(equipment_id: String) -> String:
	var slot := equipment_slot(equipment_id)
	var rank := equipment_rank(equipment_id)
	if slot == "talisman":
		return talisman_name(rank)
	return weapon_name(rank)

static func equipment_type_name(equipment_id: String) -> String:
	return "护符" if equipment_slot(equipment_id) == "talisman" else "武器"

static func equipment_sprite(equipment_id: String) -> String:
	var slot := equipment_slot(equipment_id)
	var rank := equipment_rank(equipment_id)
	if slot == "talisman":
		return talisman_sprite(rank)
	return weapon_sprite(rank)

static func equipment_description(equipment_id: String) -> String:
	var slot := equipment_slot(equipment_id)
	var rank := equipment_rank(equipment_id)
	if slot == "talisman":
		return talisman_description(rank)
	return weapon_description(rank)

static func equipment_effect(equipment_id: String) -> String:
	var slot := equipment_slot(equipment_id)
	var rank := equipment_rank(equipment_id)
	if slot == "talisman":
		return talisman_effect(rank)
	return weapon_effect(rank)

static func equipment_decompose_reward(equipment_id: String) -> Dictionary:
	var slot := equipment_slot(equipment_id)
	var rank := equipment_rank(equipment_id)
	if slot == "talisman":
		return talisman_decompose_reward(maxi(1, rank))
	return weapon_decompose_reward(maxi(1, rank))

static func personal_event_log() -> String:
	if PERSONAL_EVENT_LOGS.is_empty():
		return ""
	return str(PERSONAL_EVENT_LOGS[randi() % PERSONAL_EVENT_LOGS.size()])

static func companion(companion_id: String) -> Dictionary:
	return Dictionary(COMPANIONS.get(companion_id, COMPANIONS["xiaomi"])).duplicate(true)

static func companion_ids() -> Array[String]:
	var ids: Array[String] = []
	for item_id in COMPANION_ORDER:
		ids.append(str(item_id))
	return ids

static func companion_gold_bonus(companion_level: int, companion_bond: int, stage: int) -> int:
	return maxi(1, companion_level + int(companion_bond / 2) + int(stage / 8))

static func companion_bond_needed(companion_bond: int) -> int:
	return 6 + companion_bond * 2

static func companion_feed_cost(companion_level: int) -> int:
	return 1 + int(maxi(0, companion_level - 1) / 2)

static func daily_reward(day_index: int) -> Dictionary:
	var safe_index := posmod(day_index, DAILY_REWARDS.size())
	return Dictionary(DAILY_REWARDS[safe_index]).duplicate(true)

static func daily_reward_count() -> int:
	return DAILY_REWARDS.size()

static func daily_task(task_id: String) -> Dictionary:
	for task in DAILY_TASKS:
		if str(task.get("id", "")) == task_id:
			return Dictionary(task).duplicate(true)
	return {}

static func daily_task_ids() -> Array[String]:
	var ids: Array[String] = []
	for task in DAILY_TASKS:
		ids.append(str(task.get("id", "")))
	return ids

static func daily_tasks() -> Array[Dictionary]:
	var tasks: Array[Dictionary] = []
	for task in DAILY_TASKS:
		tasks.append(Dictionary(task).duplicate(true))
	return tasks

static func chapter_goal(goal_id: String) -> Dictionary:
	return Dictionary(CHAPTER_GOALS.get(goal_id, {})).duplicate(true)

static func chapter_goal_ids() -> Array[String]:
	var ids: Array[String] = []
	for goal_id in CHAPTER_GOAL_ORDER:
		ids.append(str(goal_id))
	return ids

static func dungeon(dungeon_id: String) -> Dictionary:
	return Dictionary(DUNGEONS.get(dungeon_id, {})).duplicate(true)

static func dungeon_ids() -> Array[String]:
	var ids: Array[String] = []
	for dungeon_id in DUNGEON_ORDER:
		ids.append(str(dungeon_id))
	return ids

static func dungeon_power_required(dungeon_id: String, stage: int) -> int:
	var data := dungeon(dungeon_id)
	return int(data.get("base_power", 20)) + maxi(0, stage - 1) * int(data.get("power_per_stage", 2))

static func dungeon_reward(dungeon_id: String, stage: int, talisman_rank: int = 0) -> Dictionary:
	var data := dungeon(dungeon_id)
	var reward := Dictionary(data.get("reward", {})).duplicate(true)
	reward["gold"] = int(reward.get("gold", 0)) + maxi(0, stage - 1) * int(data.get("reward_gold_per_stage", 0)) + talisman_rank * 5
	reward["materials"] = int(reward.get("materials", 0)) + int(maxi(0, stage - 1) / 2) * int(data.get("reward_materials_per_stage", 0))
	var reward_items = reward.get("items", {})
	if typeof(reward_items) != TYPE_DICTIONARY:
		reward["items"] = {}
	return reward

static func boss(boss_id: String) -> Dictionary:
	return Dictionary(BOSSES.get(boss_id, {})).duplicate(true)

static func album_entry(entry_id: String) -> Dictionary:
	for entry in ALBUM_ENTRIES:
		if str(entry.get("id", "")) == entry_id:
			return Dictionary(entry).duplicate(true)
	return {}

static func album_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in ALBUM_ENTRIES:
		entries.append(Dictionary(entry).duplicate(true))
	return entries

static func player_title(title_id: String) -> Dictionary:
	for title in PLAYER_TITLES:
		if str(title.get("id", "")) == title_id:
			return Dictionary(title).duplicate(true)
	return Dictionary(PLAYER_TITLES[0]).duplicate(true)

static func player_title_ids() -> Array[String]:
	var ids: Array[String] = []
	for title in PLAYER_TITLES:
		ids.append(str(title.get("id", "")))
	return ids

static func player_title_name(title_id: String) -> String:
	return str(player_title(title_id).get("name", "月森营地冒险者"))

static func private_collectible(item_id: String) -> Dictionary:
	return Dictionary(PRIVATE_COLLECTIBLES.get(item_id, {})).duplicate(true)

static func private_collectible_ids() -> Array[String]:
	var ids: Array[String] = []
	for item_id in PRIVATE_COLLECTIBLES.keys():
		ids.append(str(item_id))
	ids.sort()
	return ids
