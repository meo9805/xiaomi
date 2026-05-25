# 放置数值参考

目标：数值要支撑“每天打开都有事做、离线也有成长、升级不乱膨胀”。先用简单模型做稳，再逐步加装备、套装、Boss 和区域。

## 参考对象

### 成熟商业游戏

- Melvor Idle
  - 参考点：RPG 技能互相依赖、资源管理、装备、长期精通目标。
  - 可借鉴：技能/装备/资源之间互相喂养，而不是只有攻击力一条线。
  - 不照搬：20 多个技能的复杂度，新手会太重。
  - 来源：https://store.steampowered.com/app/1267910/Melvor_Idle/
- Cookie Clicker
  - 参考点：经典 incremental 曲线，大量升级和成就形成长期目标。
  - 可借鉴：升级成本与产出同时膨胀，玩家不断追下一个可见目标。
  - 不照搬：无限大数字和纯点击核心，我们要保留 RPG 战斗感。
  - 来源：https://store.steampowered.com/app/1454400/Cookie_Clicker/
- AFK Arena
  - 参考点：离线奖励、长期英雄/装备成长、活动和阶段目标。
  - 可借鉴：玩家不在线也能收获，回归时有明确领奖反馈。
  - 不照搬：重抽卡、重付费、英雄池堆量。
  - 来源：https://www.pocketgamer.com/afk-arena/surpasses-100m-players/
- AFK Journey
  - 参考点：移动端放置 RPG，离线奖励、阵容/战斗、叙事包装和季度内容。
  - 可借鉴：放置收益结合可视化冒险，玩家回来后能继续推进。
  - 不照搬：开放世界、复杂阵容和大体量剧情。
  - 来源：https://www.pocketgamer.com/afk-journey/out-now/

### 开源或可研究项目

- Antimatter Dimensions
  - 参考点：多层 prestige、乘法增长、明确的阶段性重置。
  - 可借鉴：后期可做“月森祝福/转生”类系统，但 MVP 阶段先不做。
  - 来源：https://github.com/IvarK/IvarK.github.io
- Evolve
  - 参考点：从小资源开始，逐步解锁新层级和新系统。
  - 可借鉴：区域/营地/装备逐步开放，不一次性把所有按钮丢给玩家。
  - 来源：https://github.com/pmotschmann/Evolve
- Space Company
  - 参考点：资源链、扩张目标、阶段性科技。
  - 可借鉴：材料用途要逐步扩展，让旧材料不会马上失效。
  - 来源：https://github.com/sparticle999/SpaceCompany

## 我们的数值原则

1. 时间感先定，再填公式。
   - 前 5 分钟：每 20 到 60 秒有一次明显变化。
   - 第 1 小时：每 3 到 8 分钟能买一次小升级。
   - 第 1 天：每 20 到 60 分钟有一次阶段目标。
   - 中后期：允许 2 到 12 小时的离线目标，但不能一上来就等。
2. 每个资源都要有用途。
   - 金币：训练、武器、护符、基础升级。
   - 通用材料：营地、护符、设施。
   - 专属掉落：武器、套装、Boss 门票。
   - 经验：等级和基础战力。
3. 每条成长线要有边界。
   - 等级：基础成长。
   - 训练：前期快速变强。
   - 武器：主要伤害线。
   - 护符：收益和掉落线。
   - 营地：离线和长期效率线。
4. 不让单一系统压过全部。
   - 武器不应该同时提高伤害、掉落、金币、经验。
   - 护符不应该比武器更直接影响战斗。
   - 营地适合提供后台收益，不适合成为唯一最优解。
5. 玩家要能理解为什么卡住。
   - 缺金币、缺材料、缺专属掉落、打不过 Boss，要在 UI 上说清楚。
   - 不要只让按钮变灰。

## 基础公式草案

这些不是最终值，是后续调数值的起点。

### 怪物

```text
monster_hp(stage) = base_hp[type] * (1.10 ^ stage) * zone_multiplier
monster_gold(stage) = base_gold[type] * (1.08 ^ stage)
monster_xp(stage) = base_xp[type] * (1.07 ^ stage)
```

- 普通区域：每 4 只怪推进 1 区。
- 每 10 区一个小 Boss。
- Boss HP 约等于同区普通怪的 4 到 8 倍。
- Boss 掉落 1 个关键材料，作为装备/区域门槛。

### 玩家伤害

```text
damage = base_level_damage + training_bonus + weapon_bonus + set_bonus
base_level_damage = 4 + level * 2
training_bonus = training_rank * 3
weapon_bonus = weapon_rank * 4 到 8
```

- 早期 TTK：普通怪 8 到 20 秒。
- 中期 TTK：普通怪 20 到 45 秒。
- Boss TTK：1 到 4 分钟，打不过时引导回去升级。

### 升级成本

```text
training_cost = 35 * (1.16 ^ training_rank)
weapon_cost_gold = 50 * (1.22 ^ weapon_rank)
weapon_cost_material = 2 + weapon_rank
talisman_cost_gold = 70 * (1.20 ^ talisman_rank)
talisman_cost_material = 4 + talisman_rank * 2
camp_cost_material = 3 + camp_rank * 2
```

- 训练成本增长较慢，保证前期爽感。
- 武器成本增长较快，作为主要长期追求。
- 护符成本介于两者之间，偏收益线。
- 营地主要吃通用材料，避免和武器完全抢同一资源。

### 离线收益

```text
offline_gold_per_minute = level * 2 + stage + training_rank + camp_rank + talisman_rank
offline_cap = min(real_offline_minutes, 360)
```

- MVP 先限制最多 6 小时离线收益。
- 后续营地可解锁更高上限，例如 8 小时、12 小时。
- 离线收益不要超过在线推进收益太多，否则玩家只需要关游戏。

### 副本

```text
dungeon_power_required = zone_power * dungeon_multiplier
dungeon_reward = base_reward[type] * (1.12 ^ dungeon_level) * clear_rating_bonus
daily_attempts = 1 到 3
```

- 副本承担定向资源产出：金币、通用材料、专属材料、Boss 突破材料。
- 副本奖励要比同时间普通挂机更集中，但次数有限。
- 早期副本 30 到 90 秒完成一次；中期 2 到 4 分钟完成一次。
- 失败不扣次数；打不过时明确提示需要武器、等级、护符或伙伴加成。
- 副本不应该成为必须整点上线的压力来源。

### 宠物/战友

```text
companion_bonus = base_bonus + companion_level * bonus_per_level + bond_rank * bond_bonus
companion_attack_interval = 8 到 20 秒
companion_upgrade_cost = snack_base * (1.18 ^ companion_level)
```

- 宠物偏放置收益，例如离线金币、掉落率、每日副本奖励。
- 战友偏战斗收益，例如固定协助攻击、Boss 伤害、破甲。
- 每次只允许 1 个主出战伙伴，避免加成叠太多导致数值失控。
- 伙伴加成前期控制在 3% 到 15%，中期再逐步扩大。
- 伙伴材料优先来自签到、每日任务、副本和 Boss，不做重抽卡。

### 每日签到与活跃

```text
sign_in_day = (claimed_days % 7) + 1
daily_activity_points = task_count_completed * 20
daily_reward_value = player_daily_income * 0.05 到 0.20
```

- 签到奖励服务于留存，但不能比正常游玩收益高太多。
- 7 天循环即可，先不做月卡、通行证、赛季。
- 断签不惩罚，只继续当前 7 天循环。
- 每日任务数量控制在 3 到 5 个，移动端打开 3 到 8 分钟能完成主要奖励。
- 每日奖励优先给伙伴零食、副本次数、Boss 门票和少量稀有材料。

## 调参检查表

每次改数值前后都要看：

- 当前阶段普通怪平均击杀时间。
- 升级一次训练需要几只怪。
- 升级一次武器需要几只怪和多少专属掉落。
- 领取一次任务奖励能推进多少升级进度。
- 离线 30 分钟、2 小时、6 小时分别能买什么。
- Boss 打不过时，玩家能否明确知道要升级哪条线。
- 每日签到和每日任务给的奖励，是否超过同等时间正常战斗收益太多。
- 副本每日次数是否足够形成目标，但不会逼玩家频繁上线。
- 伙伴加成是否只是辅助，而不是超过武器和等级成为唯一答案。

## 后续工具目标

- 做一个 `tools/simulate_balance.py`。
  - 输入：等级、区域、训练、武器、护符、营地。
  - 输出：DPS、怪物 TTK、每分钟金币/经验、下一次升级所需时间。
- 做一个 `data/balance.json`。
  - 把敌人、升级、掉落、区域数据从 `GameData.gd` 拆出来。
  - 后续可以像表格一样调，不必每次改脚本。
