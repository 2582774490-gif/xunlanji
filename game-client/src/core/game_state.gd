extends Node

signal screen_changed(next_screen: Screen)
signal profile_changed()
signal notice_changed(text: String)

enum Screen {
	CHARACTER_SELECT,
	HOME,
	OVERWORLD,
	DUNGEON,
	REALM,
	INVENTORY,
	SECT,
	MARKET,
	ALCHEMY,
	PVP,
	CODEX,
	SETTINGS,
}

var current_screen: Screen = Screen.CHARACTER_SELECT
var current_region_id := "starter_village"
var selected_dungeon_id := "mist_stream_palace"
var last_notice := "欢迎来到《寻岚记》首发框架演示。"
const MARKET_FEE_RATE := 0.05
const MARKET_MIN_PRICE := 1
const MARKET_MAX_PRICE := 99999
const MARKET_REFERENCE_MIN_MULTIPLIER := 0.35
const MARKET_REFERENCE_MAX_MULTIPLIER := 3.0
# Reference prices protect the launch economy from accidental or abusive
# outliers. They are deliberately broad, not a forced fixed price. Unlisted
# discoveries remain tradeable under the global range until enough trade data
# exists to give them a reliable reference.
const MARKET_REFERENCE_PRICES := {
	"雾溪药": 14,
	"雾潮晶簇": 32,
	"雾潮矿芯": 32,
	"雾林妖丹": 36,
	"雷纹符材": 45,
	"临渊露": 45,
	"御崖石屑": 45,
	"护脉阵片": 52,
	"凝气符": 18,
	"雾溪草": 12,
	"练气木剑": 24,
	"练气羽扇": 45,
	"青篁练气剑": 52,
	"纳灵玉佩": 60,
	"潮息玉佩": 86,
	"凝息丹": 42,
	"养元丹": 68,
	"归元丹": 96,
	"筑基丹": 360,
	"雾纹护臂": 72,
	"水府灵靴": 64,
	"雾林轻甲": 128,
	"沉雾舟纹袍": 180,
}
const FOUNDATION_PREPARATION_ITEMS := ["临渊露", "御崖石屑", "护脉阵片"]
const WORLD_GUIDANCE_STEPS := ["lan_breath", "resource_ecology", "path_choice"]
const ECOLOGY_RESPAWN_SECONDS := {"resource": 420, "beast": 540, "bandit": 600}
const INITIAL_ATTRIBUTE_POINTS := 4
const BASE_ATTRIBUTE_TOTAL := 20
const TECHNIQUE_INSIGHT_THRESHOLDS := [60, 180, 360]
const EQUIPMENT_MAX_UPGRADE := 10
const LOCAL_SAVE_PATH := "user://xunlanji_local_profile.json"
const LOCAL_SAVE_VERSION := 1
# 首发商业化只出售外观与便利，不出售属性、战斗伤害、PVP 数值或交易税优惠。
# 本地原型可模拟权益，用于验证规则；正式激活必须由支付与账号服务端签发。
const BASE_DAILY_FIXED_DUNGEON_ATTEMPTS := 3
const MONTHLY_CARD_SMALL_PRICE_CNY := 30
const MONTHLY_CARD_LARGE_PRICE_CNY := 98
const MONTHLY_CARD_DURATION_DAYS := 30
const MONTHLY_CARD_BENEFITS := {
	"none": {"label": "无月卡", "extra_attempts": 0, "common_bonus_chance": 0.0, "convenience_cooldown_multiplier": 1.0},
	"small": {"label": "小月卡", "extra_attempts": 1, "common_bonus_chance": 0.02, "convenience_cooldown_multiplier": 0.90},
	"large": {"label": "大月卡", "extra_attempts": 2, "common_bonus_chance": 0.04, "convenience_cooldown_multiplier": 0.80},
}
var local_market_listings: Array[Dictionary] = [
	{"id": "npc_mist_stream_medicine", "name": "雾溪药", "type": "药材", "price": 14, "seller": "陆青禾"},
	{"id": "npc_ore", "name": "雾潮矿芯", "type": "材料", "price": 32, "seller": "温行客"},
	{"id": "npc_talisman", "name": "雷纹符材", "type": "符材", "price": 45, "seller": "候雷符修"},
	{"id": "npc_tide_pendant", "name": "潮息玉佩", "type": "法宝", "price": 86, "seller": "温行客"},
]
var player := {
	"gender": "男",
	"face": 1,
	"hair": 1,
	"spirit_root": "水灵根",
	"physique": "岚息体",
	"cultivation_path": "云岚吐纳诀",
	"learned_techniques": ["云岚吐纳诀"],
	"realm_index": 0,
	"minor_stage": 1,
	"cultivation": 0,
	"meditation_sessions": 3,
	"meditation_day": "",
	"medicine_tolerance": {"day": "", "burden": 0},
	"alchemy_history": [],
	"unspent_points": INITIAL_ATTRIBUTE_POINTS,
	"attribute_points_earned": INITIAL_ATTRIBUTE_POINTS,
	"attributes": {"体魄": 5, "灵识": 5, "身法": 5, "根骨": 5},
	"technique_insight": {"云岚吐纳诀": {"progress": 0, "awards_claimed": 0}},
	"spirit_stones": 120,
	"gold": 80,
	"sect_id": "",
	"sect_rank": 0,
	"sect_contribution": 0,
	"sect_wanted_by": [],
	"npc_relations": {},
	"npc_met": [],
	"npc_trade_records": [],
	"world_guidance": {"steps": [], "skipped": false},
	"opening_lore_seen": false,
	"field_clues": [],
	"ecology_cooldowns": {},
	"world_positions": {},
	"equipped_weapon": "练气木剑",
	"equipped_artifact": "纳灵玉佩",
	"equipped_armor": "",
	"equipped_footwear": "",
	"equipment_upgrades": {},
	"weapon_trial_claimed": false,
	"inventory": ["练气木剑", "凝气符", "雾溪草", "纳灵玉佩"],
	"codex": ["云岚村", "雾溪水府"],
	"opportunity_log": [],
	"dungeon_runs": [],
	"fixed_dungeon_attempts": {"day": "", "used": 0},
	"monthly_card": {"tier": "none", "expires_at": 0},
	"unlocked_regions": ["starter_village"],
}

func enter_screen(next_screen: Screen) -> void:
	current_screen = next_screen
	screen_changed.emit(current_screen)

func export_local_profile() -> Dictionary:
	# This payload is deliberately local-only.  Currency, listings and player
	# state become server-authoritative after account/multiplayer services exist.
	return {
		"version": LOCAL_SAVE_VERSION,
		"player": player.duplicate(true),
		"market_listings": local_market_listings.duplicate(true),
		"current_region_id": current_region_id,
		"selected_dungeon_id": selected_dungeon_id,
	}

func apply_local_profile(payload: Dictionary) -> bool:
	if int(payload.get("version", 0)) != LOCAL_SAVE_VERSION:
		return false
	var stored_player: Variant = payload.get("player", {})
	if not stored_player is Dictionary:
		return false
	if not stored_player.has("inventory") or not stored_player.has("attributes"):
		return false
	player = stored_player.duplicate(true)
	_normalize_player_schema()
	current_region_id = str(payload.get("current_region_id", "starter_village"))
	selected_dungeon_id = str(payload.get("selected_dungeon_id", "mist_stream_palace"))
	local_market_listings.clear()
	var stored_listings: Variant = payload.get("market_listings", [])
	if stored_listings is Array:
		for entry in stored_listings:
			if entry is Dictionary:
				local_market_listings.append(entry.duplicate(true))
	profile_changed.emit()
	return true

func save_local_profile() -> bool:
	var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		notify("本地存档写入失败。")
		return false
	file.store_string(JSON.stringify(export_local_profile()))
	file.close()
	notify("本地进度已保存。此存档仅在当前设备有效；尚未接入账号云端。")
	return true

func load_local_profile() -> bool:
	if not FileAccess.file_exists(LOCAL_SAVE_PATH):
		notify("当前设备没有可读取的本地存档。")
		return false
	var file := FileAccess.open(LOCAL_SAVE_PATH, FileAccess.READ)
	if file == null:
		notify("本地存档读取失败。")
		return false
	var decoder := JSON.new()
	var parse_result := decoder.parse(file.get_as_text())
	file.close()
	if parse_result != OK or not decoder.data is Dictionary or not apply_local_profile(decoder.data):
		notify("本地存档格式无效或版本不兼容。")
		return false
	notify("已恢复本地进度。账号云端与多人数据仍需服务器接入。")
	return true

func market_fee(price: int) -> int:
	return max(1, ceili(float(price) * MARKET_FEE_RATE))


func market_price_protection(item_name: String) -> Dictionary:
	var reference := int(MARKET_REFERENCE_PRICES.get(item_name, 0))
	if reference <= 0:
		return {
			"protected": false,
			"reference": 0,
			"minimum": MARKET_MIN_PRICE,
			"maximum": MARKET_MAX_PRICE,
		}
	return {
		"protected": true,
		"reference": reference,
		"minimum": maxi(MARKET_MIN_PRICE, ceili(float(reference) * MARKET_REFERENCE_MIN_MULTIPLIER)),
		"maximum": mini(MARKET_MAX_PRICE, floori(float(reference) * MARKET_REFERENCE_MAX_MULTIPLIER)),
	}


func market_suggested_price(item_name: String) -> int:
	var protection := market_price_protection(item_name)
	return int(protection.reference) if bool(protection.protected) else 20


func market_price_protection_text(item_name: String) -> String:
	var protection := market_price_protection(item_name)
	if not bool(protection.protected):
		return "新发现物品：暂按全局范围 %d～%d 金寄售；积累交易数据后再设参考价。" % [int(protection.minimum), int(protection.maximum)]
	return "参考价 %d 金，保护寄售区间 %d～%d 金。" % [int(protection.reference), int(protection.minimum), int(protection.maximum)]


func is_market_price_allowed(item_name: String, price: int) -> bool:
	var protection := market_price_protection(item_name)
	return price >= int(protection.minimum) and price <= int(protection.maximum)


func market_purchase_price(index: int) -> int:
	if index < 0 or index >= local_market_listings.size():
		return 0
	var listing: Dictionary = local_market_listings[index]
	var price := int(listing.get("price", 0))
	var seller := str(listing.get("seller", ""))
	if seller.is_empty() or seller == "本地修士":
		return price
	return maxi(1, ceili(float(price) * (1.0 - npc_market_discount(seller))))

func list_item_for_market(item_name: String, price: int) -> bool:
	if not is_market_price_allowed(item_name, price):
		notify("上架价格超出保护范围：%s" % market_price_protection_text(item_name))
		return false
	if not player.inventory.has(item_name):
		notify("行囊中没有可上架的 %s。" % item_name)
		return false
	if item_name == str(player.get("equipped_weapon", "")) or item_name == str(player.get("equipped_artifact", "")) or item_name == str(player.get("equipped_armor", "")) or item_name == str(player.get("equipped_footwear", "")):
		notify("已装备的武器、法宝、护具或足部装备不能直接上架，请先更换装备。")
		return false
	var fee := market_fee(price)
	if player.gold < fee:
		notify("上架手续费不足：需要 %d 金钱。" % fee)
		return false
	player.inventory.erase(item_name)
	player.gold -= fee
	var listing := {"id": "player_%d" % Time.get_ticks_msec(), "name": item_name, "type": "玩家寄售", "price": price, "seller": "本地修士"}
	if is_upgradeable_equipment(item_name):
		var states: Dictionary = player.get("equipment_upgrades", {})
		if states.has(item_name):
			listing["equipment_state"] = (states[item_name] as Dictionary).duplicate(true)
			states.erase(item_name)
			player.equipment_upgrades = states
	local_market_listings.append(listing)
	notify("已上架 %s，标价 %d，手续费 %d。真实玩家交易将改由服务器结算。" % [item_name, price, fee])
	profile_changed.emit()
	return true

func buy_market_listing(index: int) -> bool:
	if index < 0 or index >= local_market_listings.size():
		return false
	var listing: Dictionary = local_market_listings[index]
	var price := market_purchase_price(index)
	if player.gold < price:
		notify("金钱不足。")
		return false
	player.gold -= price
	add_item(str(listing.name))
	if listing.get("equipment_state", null) is Dictionary:
		var states: Dictionary = player.get("equipment_upgrades", {})
		states[str(listing.name)] = (listing.equipment_state as Dictionary).duplicate(true)
		player.equipment_upgrades = states
	local_market_listings.remove_at(index)
	_record_npc_trade(str(listing.get("seller", "")), str(listing.get("id", "")))
	notify("成交：获得 %s，支付 %d 金钱。" % [listing.name, price])
	profile_changed.emit()
	return true

func cancel_market_listing(index: int) -> bool:
	if index < 0 or index >= local_market_listings.size():
		return false
	var listing: Dictionary = local_market_listings[index]
	if str(listing.seller) != "本地修士":
		notify("只能撤回自己上架的物品。")
		return false
	local_market_listings.remove_at(index)
	add_item(str(listing.name))
	if listing.get("equipment_state", null) is Dictionary:
		var states: Dictionary = player.get("equipment_upgrades", {})
		states[str(listing.name)] = (listing.equipment_state as Dictionary).duplicate(true)
		player.equipment_upgrades = states
	notify("已撤回 %s；已收取的上架手续费不返还。" % listing.name)
	profile_changed.emit()
	return true

func update_character(gender: String, face: int, hair: int) -> void:
	player.gender = gender
	player.face = face
	player.hair = hair
	profile_changed.emit()

func update_innate(spirit_root: String, physique: String) -> void:
	player.spirit_root = spirit_root
	player.physique = physique
	profile_changed.emit()

func choose_cultivation_path(path_name: String) -> void:
	_normalize_player_schema()
	if not player.get("learned_techniques", []).has(path_name):
		var learned: Array = player.get("learned_techniques", [])
		learned.append(path_name)
		player.learned_techniques = learned
		_ensure_technique_insight_entry(path_name)
	player.cultivation_path = path_name
	notify("已切换主修功法：%s。功法可随时转换，灵根与体质只影响效率。" % path_name)
	profile_changed.emit()


func discover_technique(path_name: String, source: String) -> bool:
	_normalize_player_schema()
	var catalog := preload("res://src/data/game_catalog.gd")
	if not catalog.TECHNIQUE_AFFINITIES.has(path_name):
		notify("这段感悟尚未对应可修行的功法。")
		return false
	var learned: Array = player.get("learned_techniques", [])
	var discovered := not learned.has(path_name)
	if discovered:
		learned.append(path_name)
		player.learned_techniques = learned
		_ensure_technique_insight_entry(path_name)
	var codex_entries: Array = player.get("codex", [])
	if not codex_entries.has(path_name):
		codex_entries.append(path_name)
		player.codex = codex_entries
	if discovered:
		notify("从%s领悟《%s》；已登记，可在修炼界面自由切换主修。" % [source, path_name])
	else:
		notify("%s与你已知的《%s》相互印证，留下新的探索记录。" % [source, path_name])
	profile_changed.emit()
	return discovered

func realm_name() -> String:
	var catalog := preload("res://src/data/game_catalog.gd")
	var realm: Dictionary = catalog.REALMS[player.realm_index]
	if player.realm_index == 0:
		return "%s%d层" % [realm.name, player.minor_stage]
	return "%s·%s" % [realm.name, realm.minor_stages[player.minor_stage - 1]]

func cultivation_threshold() -> int:
	# 每一层的修为池独立结算，避免通过一次副本直接连跳多个小境界。
	return 100 + player.realm_index * 45 + player.minor_stage * 12

func is_realm_cap() -> bool:
	var catalog := preload("res://src/data/game_catalog.gd")
	return player.realm_index >= catalog.REALMS.size() - 1 and player.minor_stage >= catalog.REALMS[player.realm_index].minor_stages.size()

func can_attempt_breakthrough() -> bool:
	return not is_realm_cap() and player.cultivation >= cultivation_threshold()

func breakthrough_requirements() -> Array:
	var catalog := preload("res://src/data/game_catalog.gd")
	var stage_count: int = catalog.REALMS[player.realm_index].minor_stages.size()
	if player.minor_stage < stage_count:
		return []
	match player.realm_index:
		0:
			# 晶簇已在筑基丹丹方中消耗；冲关本身只检验成丹。
			return [{"item": "筑基丹", "count": 1}]
		1:
			return [{"item": "结丹灵材", "count": 1}, {"item": "雾木灵芯", "count": 3}]
		2:
			return [{"item": "元婴灵材", "count": 1}, {"item": "古战残魂", "count": 3}]
		3:
			return [{"item": "化神灵材", "count": 1}, {"item": "天隙晶", "count": 3}]
	return []

func breakthrough_requirement_text() -> String:
	if is_realm_cap():
		return "已抵达首发境界上限：化神圆满。"
	var requirements := breakthrough_requirements()
	if requirements.is_empty():
		return "小境界冲关：修为圆满后可主动冲关。"
	var labels: Array[String] = []
	for requirement in requirements:
		labels.append("%s × %d" % [requirement.item, requirement.count])
	return "大境界冲关材料：%s" % "、".join(labels)

func _has_requirements(requirements: Array) -> bool:
	for requirement in requirements:
		var owned := 0
		for item_name in player.inventory:
			if item_name == requirement.item:
				owned += 1
		if owned < int(requirement.count):
			return false
	return true

func gain_cultivation(amount: int) -> String:
	if is_realm_cap():
		notify("修为感悟已积淀，但首发境界上限为化神圆满。")
		return last_notice
	var threshold := cultivation_threshold()
	var adjusted_amount := maxi(1, floori(float(max(amount, 0)) * cultivation_efficiency_multiplier())) if amount > 0 else 0
	var before: int = player.cultivation
	player.cultivation = min(player.cultivation + adjusted_amount, threshold)
	var gained: int = player.cultivation - before
	var result := "修为 +%d（%d / %d）" % [gained, player.cultivation, threshold]
	if can_attempt_breakthrough():
		result = "修为已圆满（%d / %d），请主动冲关。" % [player.cultivation, threshold]
	notify(result)
	profile_changed.emit()
	return result

func try_breakthrough() -> bool:
	if not can_attempt_breakthrough():
		notify("修为尚未圆满，不能贸然冲关。")
		return false
	var catalog := preload("res://src/data/game_catalog.gd")
	var requirements := breakthrough_requirements()
	if not requirements.is_empty() and not _has_requirements(requirements):
		notify("冲击大境界材料不足：%s" % breakthrough_requirement_text())
		return false
	for requirement in requirements:
		for index in int(requirement.count):
			player.inventory.erase(requirement.item)
	var previous_name := realm_name()
	var stage_count: int = catalog.REALMS[player.realm_index].minor_stages.size()
	if player.minor_stage < stage_count:
		player.minor_stage += 1
		_grant_attribute_points(1)
	else:
		player.realm_index += 1
		player.minor_stage = 1
		_grant_attribute_points(3)
	player.cultivation = 0
	notify("冲关成功：%s → %s" % [previous_name, realm_name()])
	profile_changed.emit()
	return true

func _refresh_meditation_day() -> void:
	var today := Time.get_date_string_from_system()
	if player.meditation_day != today:
		player.meditation_day = today
		player.meditation_sessions = 3


func _refresh_medicine_day() -> void:
	var today := Time.get_date_string_from_system()
	var tolerance: Dictionary = player.get("medicine_tolerance", {})
	if str(tolerance.get("day", "")) != today:
		tolerance.day = today
		tolerance.burden = 0
	player.medicine_tolerance = tolerance

func meditation_sessions_left() -> int:
	_refresh_meditation_day()
	return int(player.meditation_sessions)

func meditate() -> bool:
	_refresh_meditation_day()
	if player.meditation_sessions <= 0:
		notify("今日静坐次数已用尽；可通过探索、副本、炼丹继续积累修为。")
		return false
	player.meditation_sessions -= 1
	gain_cultivation(8)
	var insight_awards := gain_technique_insight(4)
	if insight_awards > 0:
		notify("功法悟性突破：%s 获得 %d 点属性点。" % [str(player.cultivation_path), insight_awards])
	else:
		notify("静坐完成：%s 的功法悟性缓慢增长。" % str(player.cultivation_path))
	profile_changed.emit()
	return true

func allocate_attribute(attribute_name: String) -> bool:
	_normalize_player_schema()
	if int(player.unspent_points) <= 0 or not player.attributes.has(attribute_name):
		return false
	player.attributes[attribute_name] += 1
	_refresh_attribute_budget()
	notify("%s +1，剩余属性点 %d" % [attribute_name, player.unspent_points])
	profile_changed.emit()
	return true


func attribute_points_spent() -> int:
	_normalize_player_schema()
	var total := 0
	for value in (player.attributes as Dictionary).values():
		total += int(value)
	return max(0, total - BASE_ATTRIBUTE_TOTAL)


func attribute_point_budget() -> int:
	_normalize_player_schema()
	return int(player.attribute_points_earned)


func attribute_point_summary() -> String:
	_normalize_player_schema()
	return "公平点池 %d｜已投入 %d｜可分配 %d" % [attribute_point_budget(), attribute_points_spent(), int(player.unspent_points)]


func technique_insight_progress(path_name: String = "") -> Dictionary:
	_normalize_player_schema()
	var technique := path_name if not path_name.is_empty() else str(player.cultivation_path)
	return _ensure_technique_insight_entry(technique).duplicate(true)


func technique_insight_text() -> String:
	var insight := technique_insight_progress()
	var awards := int(insight.awards_claimed)
	if awards >= TECHNIQUE_INSIGHT_THRESHOLDS.size():
		return "%s：悟性已完成首轮参悟（%d / %d 属性奖励）。" % [str(player.cultivation_path), awards, TECHNIQUE_INSIGHT_THRESHOLDS.size()]
	return "%s：悟性 %d / %d；达到后获得 1 点属性。" % [str(player.cultivation_path), int(insight.progress), int(TECHNIQUE_INSIGHT_THRESHOLDS[awards])]


func gain_technique_insight(amount: int) -> int:
	_normalize_player_schema()
	if amount <= 0:
		return 0
	var technique := str(player.cultivation_path)
	var insight := _ensure_technique_insight_entry(technique)
	var awards_before := int(insight.awards_claimed)
	insight.progress = min(int(insight.progress) + amount, int(TECHNIQUE_INSIGHT_THRESHOLDS.back()))
	while int(insight.awards_claimed) < TECHNIQUE_INSIGHT_THRESHOLDS.size() and int(insight.progress) >= int(TECHNIQUE_INSIGHT_THRESHOLDS[int(insight.awards_claimed)]):
		insight.awards_claimed = int(insight.awards_claimed) + 1
	var all_insight: Dictionary = player.technique_insight
	all_insight[technique] = insight
	player.technique_insight = all_insight
	var awarded := int(insight.awards_claimed) - awards_before
	if awarded > 0:
		_grant_attribute_points(awarded)
	return awarded


func world_move_speed() -> float:
	# Base 5 body-movement yields the original 250 px/s prototype pace. Every
	# point adds a modest 2.34 px/s, so mobility is meaningful but never lets one
	# build erase the scale of a 12 km region.
	return clampf(160.0 + float(derived_stats()["移速"]) * 0.78, 220.0, 380.0)

func derived_stats() -> Dictionary:
	var a: Dictionary = player.attributes
	var physique := str(player.get("physique", ""))
	var vitality_bonus := 12 if physique == "玄岳髓" else 0
	var mana_bonus := 12 if physique == "流泉脉" else 0
	var attack_bonus := 2 if physique == "赤阳髓" else 0
	return {
		"气血": 100 + int(a["体魄"]) * 15 + int(a["根骨"]) * 5 + vitality_bonus,
		"灵力": 60 + int(a["灵识"]) * 12 + int(a["根骨"]) * 6 + mana_bonus,
		"攻击": 8 + int(a["体魄"]) * 2 + int(a["灵识"]) + attack_bonus,
		"移速": 100 + int(a["身法"]) * 3,
		"修行效率": roundi(cultivation_efficiency_multiplier() * 100.0),
	}

func cultivation_affinity() -> Dictionary:
	var catalog := preload("res://src/data/game_catalog.gd")
	return catalog.technique_affinity_for(str(player.get("cultivation_path", "")))

func cultivation_efficiency_multiplier() -> float:
	var affinity := cultivation_affinity()
	var multiplier := 1.0
	if str(player.get("spirit_root", "")) == str(affinity.get("root", "")):
		multiplier += 0.10
	if str(player.get("physique", "")) == str(affinity.get("physique", "")):
		multiplier += 0.06
	return multiplier

func cultivation_efficiency_text() -> String:
	var affinity := cultivation_affinity()
	return "%s｜适配灵根：%s｜适配体质：%s｜当前效率 %d%%" % [str(affinity.label), str(affinity.root), str(affinity.physique), roundi(cultivation_efficiency_multiplier() * 100.0)]

func add_item(item_name: String) -> void:
	player.inventory.append(item_name)
	if not player.codex.has(item_name):
		player.codex.append(item_name)
	profile_changed.emit()

func claim_starter_weapon_trials(item_names: Array[String]) -> Array[String]:
	# This one-off village rack is a launch-prototype testing route.  It grants
	# only real runtime weapons, once per local profile, so it cannot become an
	# infinite market mint once normal drops and crafting are expanded.
	_normalize_player_schema()
	var granted: Array[String] = []
	if bool(player.get("weapon_trial_claimed", false)):
		notify("云岚试兵架已记录你的试用资格；试用灵器不可重复领取。")
		return granted
	for item_name in item_names:
		if not player.inventory.has(item_name):
			player.inventory.append(item_name)
			granted.append(item_name)
		if not player.codex.has(item_name):
			player.codex.append(item_name)
	player.weapon_trial_claimed = true
	if str(player.get("equipped_weapon", "")) == "练气木剑" and not granted.is_empty():
		player.equipped_weapon = granted[0]
	player.opportunity_log.append({"region": "starter_village", "name": "云岚试兵", "kind": "starter_weapon_trial", "items": granted.duplicate()})
	profile_changed.emit()
	notify("云岚试兵架交付了 %d 件首发试用灵器。按 Q 可无冷却切换已完成的武器。" % granted.size())
	return granted

func add_spirit_stones(amount: int) -> void:
	player.spirit_stones += max(amount, 0)
	profile_changed.emit()

func record_opportunity(entry: Dictionary) -> void:
	player.opportunity_log.append(entry)
	profile_changed.emit()


func meet_npc(npc_name: String) -> bool:
	if npc_name.is_empty():
		return false
	_normalize_player_schema()
	var met: Array = player.npc_met
	if met.has(npc_name):
		return false
	met.append(npc_name)
	player.npc_met = met
	change_npc_rapport(npc_name, 3, "初识")
	return true


func npc_rapport(npc_name: String) -> int:
	_normalize_player_schema()
	return clampi(int((player.npc_relations as Dictionary).get(npc_name, 0)), -100, 100)


func npc_relationship_title(npc_name: String) -> String:
	var rapport := npc_rapport(npc_name)
	if rapport >= 45:
		return "信任"
	if rapport >= 20:
		return "熟识"
	if rapport <= -30:
		return "冷淡"
	return "初识"


func change_npc_rapport(npc_name: String, amount: int, _source := "") -> bool:
	if npc_name.is_empty() or amount == 0:
		return false
	_normalize_player_schema()
	var relations: Dictionary = player.npc_relations
	relations[npc_name] = clampi(int(relations.get(npc_name, 0)) + amount, -100, 100)
	player.npc_relations = relations
	profile_changed.emit()
	return true


func npc_market_discount(npc_name: String) -> float:
	var rapport := npc_rapport(npc_name)
	return 0.10 if rapport >= 45 else (0.05 if rapport >= 20 else 0.0)


func _record_npc_trade(npc_name: String, listing_id: String) -> void:
	if npc_name.is_empty() or npc_name == "本地修士" or listing_id.is_empty():
		return
	_normalize_player_schema()
	var records: Array = player.npc_trade_records
	var key := "%s::%s" % [npc_name, listing_id]
	if records.has(key):
		return
	records.append(key)
	player.npc_trade_records = records
	change_npc_rapport(npc_name, 1, "首笔交易")


func complete_opening_lore() -> bool:
	_normalize_player_schema()
	if bool(player.opening_lore_seen):
		return false
	player.opening_lore_seen = true
	profile_changed.emit()
	return true


func has_seen_opening_lore() -> bool:
	_normalize_player_schema()
	return bool(player.opening_lore_seen)


func record_field_clue(clue_id: String) -> bool:
	if clue_id.is_empty():
		return false
	_normalize_player_schema()
	var clues: Array = player.field_clues
	if clues.has(clue_id):
		return false
	clues.append(clue_id)
	player.field_clues = clues
	profile_changed.emit()
	return true


func has_field_clue(clue_id: String) -> bool:
	_normalize_player_schema()
	return (player.field_clues as Array).has(clue_id)


func remember_region_position(region_id: String, position: Vector2) -> void:
	if region_id.is_empty():
		return
	_normalize_player_schema()
	var positions: Dictionary = player.world_positions
	positions[region_id] = {"x": position.x, "y": position.y}
	player.world_positions = positions


func region_position_or(region_id: String, fallback: Vector2, bounds: Rect2) -> Vector2:
	_normalize_player_schema()
	var positions: Dictionary = player.world_positions
	var raw: Variant = positions.get(region_id, {})
	if not raw is Dictionary:
		return fallback
	var stored: Dictionary = raw
	var candidate := Vector2(float(stored.get("x", fallback.x)), float(stored.get("y", fallback.y)))
	var safe_min := bounds.position + Vector2(12.0, 12.0)
	var safe_max := bounds.end - Vector2(12.0, 12.0)
	if candidate.x < safe_min.x or candidate.y < safe_min.y or candidate.x > safe_max.x or candidate.y > safe_max.y:
		return fallback
	return candidate

func record_dungeon_run(entry: Dictionary) -> void:
	player.dungeon_runs.append(entry)
	if not str(player.get("sect_id", "")).is_empty():
		add_sect_contribution(12, "完成宗门认可的副本探索")
	profile_changed.emit()


func _calendar_day(now_unix: int = -1) -> String:
	var date: Dictionary
	if now_unix < 0:
		date = Time.get_datetime_dict_from_system()
	else:
		date = Time.get_datetime_dict_from_unix_time(now_unix)
	return "%04d-%02d-%02d" % [int(date.year), int(date.month), int(date.day)]


func _refresh_fixed_dungeon_attempt_day(now_unix: int = -1) -> void:
	_normalize_player_schema()
	var attempts: Dictionary = player.fixed_dungeon_attempts
	var today := _calendar_day(now_unix)
	if str(attempts.get("day", "")) != today:
		attempts = {"day": today, "used": 0}
		player.fixed_dungeon_attempts = attempts


func monthly_card_tier(now_unix: int = -1) -> String:
	_normalize_player_schema()
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	var card: Dictionary = player.monthly_card
	var tier := str(card.get("tier", "none"))
	if not MONTHLY_CARD_BENEFITS.has(tier) or tier == "none" or int(card.get("expires_at", 0)) <= now:
		return "none"
	return tier


func monthly_card_benefits(now_unix: int = -1) -> Dictionary:
	return (MONTHLY_CARD_BENEFITS.get(monthly_card_tier(now_unix), MONTHLY_CARD_BENEFITS.none) as Dictionary).duplicate(true)


func monthly_card_status_text(now_unix: int = -1) -> String:
	var tier := monthly_card_tier(now_unix)
	if tier == "none":
		return "当前无月卡｜固定副本每日 %d 次｜PVP、交易税与战斗数值对所有玩家一致。" % BASE_DAILY_FIXED_DUNGEON_ATTEMPTS
	var card: Dictionary = player.monthly_card
	var benefits := monthly_card_benefits(now_unix)
	var price := MONTHLY_CARD_SMALL_PRICE_CNY if tier == "small" else MONTHLY_CARD_LARGE_PRICE_CNY
	return "%s ¥%d/月，至 %s｜固定副本每日 %d 次｜常规材料额外产出 %.0f%%｜便利物品冷却 -%d%%。" % [str(benefits.label), price, _calendar_day(int(card.expires_at)), daily_fixed_dungeon_limit(now_unix), float(benefits.common_bonus_chance) * 100.0, roundi((1.0 - float(benefits.convenience_cooldown_multiplier)) * 100.0)]


func daily_fixed_dungeon_limit(now_unix: int = -1) -> int:
	return BASE_DAILY_FIXED_DUNGEON_ATTEMPTS + int(monthly_card_benefits(now_unix).get("extra_attempts", 0))


func fixed_dungeon_attempts_used(now_unix: int = -1) -> int:
	_refresh_fixed_dungeon_attempt_day(now_unix)
	return int((player.fixed_dungeon_attempts as Dictionary).get("used", 0))


func fixed_dungeon_attempts_remaining(now_unix: int = -1) -> int:
	return max(0, daily_fixed_dungeon_limit(now_unix) - fixed_dungeon_attempts_used(now_unix))


func can_enter_fixed_dungeon(_dungeon_id: String, now_unix: int = -1) -> bool:
	return fixed_dungeon_attempts_remaining(now_unix) > 0


func fixed_dungeon_entry_block_text(now_unix: int = -1) -> String:
	return "今日固定副本次数已用尽（%d/%d）。次日重置；月卡只增加次数，不改变战斗、PVP、交易税或稀有首领掉落。" % [fixed_dungeon_attempts_used(now_unix), daily_fixed_dungeon_limit(now_unix)]


func try_begin_fixed_dungeon(dungeon_id: String, now_unix: int = -1) -> bool:
	if dungeon_id.is_empty() or not can_enter_fixed_dungeon(dungeon_id, now_unix):
		notify(fixed_dungeon_entry_block_text(now_unix))
		return false
	_refresh_fixed_dungeon_attempt_day(now_unix)
	var attempts: Dictionary = player.fixed_dungeon_attempts
	attempts.used = int(attempts.get("used", 0)) + 1
	player.fixed_dungeon_attempts = attempts
	profile_changed.emit()
	return true


func convenience_cooldown_multiplier(category: String, now_unix: int = -1) -> float:
	# 仅回城符、探索罗盘和纯展示类便利可受益；技能、修炼、炼丹、采集生态、市场和 PVP 永远不受影响。
	if not category in ["return_talisman", "exploration_compass", "cosmetic_preview"]:
		return 1.0
	return float(monthly_card_benefits(now_unix).get("convenience_cooldown_multiplier", 1.0))


func convenience_cooldown_seconds(base_seconds: float, category: String, now_unix: int = -1) -> float:
	return maxf(0.0, base_seconds * convenience_cooldown_multiplier(category, now_unix))


func try_award_monthly_card_common_material(dungeon_id: String, common_materials: Array[String], roll: float = -1.0) -> String:
	# 只可额外产出明确传入的常规材料；首领装备、功法、法宝、丹药和稀有掉落绝不进入此池。
	if dungeon_id.is_empty() or common_materials.is_empty():
		return ""
	var chance := float(monthly_card_benefits().get("common_bonus_chance", 0.0))
	var resolved_roll := randf() if roll < 0.0 else roll
	if chance <= 0.0 or resolved_roll >= chance:
		return ""
	var reward := common_materials.pick_random()
	add_item(reward)
	return reward


func set_local_monthly_card_test_entitlement(tier: String, now_unix: int = -1) -> bool:
	# Local-only verification hook. It neither charges money nor represents a purchase.
	if not MONTHLY_CARD_BENEFITS.has(tier):
		return false
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	player.monthly_card = {"tier": tier, "expires_at": now + MONTHLY_CARD_DURATION_DAYS * 24 * 60 * 60 if tier != "none" else 0}
	profile_changed.emit()
	return true

func is_region_unlocked(region_id: String) -> bool:
	return player.unlocked_regions.has(region_id)

func unlock_region(region_id: String) -> bool:
	if is_region_unlocked(region_id):
		return false
	player.unlocked_regions.append(region_id)
	notify("新区域已开启：雾潮边境")
	profile_changed.emit()
	return true

func consume_items(items: Array[String]) -> bool:
	for item_name in items:
		if not player.inventory.has(item_name):
			return false
	for item_name in items:
		player.inventory.erase(item_name)
	profile_changed.emit()
	return true


func medicine_burden_capacity() -> int:
	_refresh_medicine_day()
	var capacity := 10 + int(player.minor_stage) * 2 + int(player.realm_index) * 8
	if str(player.get("physique", "")) == "青木灵胎":
		capacity += 3
	return capacity


func medicine_burden() -> int:
	_refresh_medicine_day()
	return int((player.medicine_tolerance as Dictionary).get("burden", 0))


func medicine_burden_text() -> String:
	return "今日药负 %d / %d" % [medicine_burden(), medicine_burden_capacity()]


func alchemy_success_rate(recipe_id: String) -> float:
	var catalog := preload("res://src/data/game_catalog.gd")
	var recipe: Dictionary = catalog.ALCHEMY_RECIPES.get(recipe_id, {})
	if recipe.is_empty():
		return 0.0
	var rate := float(recipe.get("base_success", 0.0))
	var technique := str(player.get("cultivation_path", ""))
	if technique == "百草调息篇":
		rate += 0.18
	elif technique == "炉火化元法":
		rate += 0.12
	if str(player.get("spirit_root", "")) == "火灵根" or str(player.get("spirit_root", "")) == "木灵根":
		rate += 0.05
	if str(player.get("physique", "")) == "青木灵胎":
		rate += 0.08
	if npc_rapport("白蘅") >= 20:
		rate += 0.03
	return clampf(rate, 0.45, 0.95)


func craft_alchemy_recipe(recipe_id: String, forced_roll := -1.0) -> bool:
	var catalog := preload("res://src/data/game_catalog.gd")
	var recipe: Dictionary = catalog.ALCHEMY_RECIPES.get(recipe_id, {})
	if recipe.is_empty():
		return false
	var materials: Array = recipe.get("materials", [])
	if not consume_items(materials):
		notify("炼制%s的材料不足。" % str(recipe.get("name", "丹药")))
		return false
	var roll := randf() if forced_roll < 0.0 else clampf(forced_roll, 0.0, 1.0)
	var success_rate := alchemy_success_rate(recipe_id)
	var history: Array = player.get("alchemy_history", [])
	if roll <= success_rate:
		var output := str(recipe.output)
		add_item(output)
		history.append({"recipe": recipe_id, "success": true, "rate": success_rate})
		player.alchemy_history = history
		notify("炼制成功：%s 入囊。%s" % [output, medicine_burden_text()])
		profile_changed.emit()
		return true
	add_item("药渣")
	history.append({"recipe": recipe_id, "success": false, "rate": success_rate})
	player.alchemy_history = history
	notify("炼制失手：得到药渣。丹修功法、灵根与体质会提高成丹率。")
	profile_changed.emit()
	return false


func use_pill(item_name: String) -> bool:
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.PILL_PROFILES.get(item_name, {})
	if profile.is_empty() or not player.inventory.has(item_name):
		return false
	var max_realm := int(profile.max_realm)
	var max_stage := int(profile.max_stage)
	if player.realm_index > max_realm or (player.realm_index == max_realm and player.minor_stage > max_stage):
		notify("当前境界已超过%s的有效药性范围；低阶丹药不会提供提升。" % item_name)
		return false
	_refresh_medicine_day()
	var burden_cost := int(profile.burden)
	if medicine_burden() + burden_cost > medicine_burden_capacity():
		notify("药性承受已接近上限（%s），今日不宜继续服用%s。" % [medicine_burden_text(), item_name])
		return false
	player.inventory.erase(item_name)
	var effect := int(profile.cultivation)
	if str(player.get("physique", "")) == "青木灵胎":
		effect = ceili(effect * 1.10)
	var tolerance: Dictionary = player.medicine_tolerance
	tolerance.burden = medicine_burden() + burden_cost
	player.medicine_tolerance = tolerance
	gain_cultivation(effect)
	notify("服用%s：修为 +%d，%s。" % [item_name, effect, medicine_burden_text()])
	profile_changed.emit()
	return true

func use_cultivation_item(item_name: String, cultivation_amount: int, max_realm_index: int, max_minor_stage: int) -> bool:
	var catalog := preload("res://src/data/game_catalog.gd")
	if catalog.PILL_PROFILES.has(item_name):
		return use_pill(item_name)
	if not player.inventory.has(item_name):
		notify("行囊中没有%s。" % item_name)
		return false
	if player.realm_index > max_realm_index or (player.realm_index == max_realm_index and player.minor_stage > max_minor_stage):
		notify("当前境界已超过%s的有效药性范围。" % item_name)
		return false
	player.inventory.erase(item_name)
	gain_cultivation(cultivation_amount)
	return true

func craft_foundation_pill() -> bool:
	if player.realm_index > 0:
		notify("筑基丹应在炼气圆满前准备；筑基后不可重复炼制此丹。")
		return false
	if not consume_items(["雾林妖丹", "雾潮晶簇", "雾潮晶簇", "雾潮晶簇"]):
		notify("筑基丹材料不足：需要雾林妖丹 × 1 与雾潮晶簇 × 3。")
		return false
	var preparation_item := _first_foundation_preparation_item()
	if preparation_item.is_empty():
		# Restore the base materials when the optional-route preparation item is
		# absent, so a failed crafting attempt never consumes anything.
		add_item("雾林妖丹")
		add_item("雾潮晶簇")
		add_item("雾潮晶簇")
		add_item("雾潮晶簇")
		notify("筑基丹还需一份临渊准备材料：临渊露、御崖石屑或护脉阵片。可自行探索或通过交易取得。")
		return false
	player.inventory.erase(preparation_item)
	add_item("筑基丹")
	notify("炼制成功：以%s调和药性，筑基丹已入囊。待炼气圆满、修为积满后，可在修炼界面自行冲击筑基。" % preparation_item)
	return true

func _first_foundation_preparation_item() -> String:
	for item_name in FOUNDATION_PREPARATION_ITEMS:
		if player.inventory.has(item_name):
			return item_name
	return ""

func equip_weapon(item_name: String) -> void:
	if not player.inventory.has(item_name):
		notify("行囊中没有%s，不能装备。" % item_name)
		return
	player.equipped_weapon = item_name
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.weapon_profile_for_item(item_name)
	notify("已装备：%s｜战斗倾向：%s。专属动作与特效仍按武器卡逐把制作。" % [item_name, profile.trait])
	profile_changed.emit()

func equip_next_runtime_weapon() -> bool:
	# The quick switch only cycles weapons that have an approved runtime profile.
	# Other launch families stay in the bag until their own art and controller
	# exist, instead of receiving a misleading sword or umbrella substitution.
	var catalog := preload("res://src/data/game_catalog.gd")
	var available: Array[String] = []
	for item_name in player.inventory:
		if not catalog.weapon_runtime_profile_for_item(str(item_name)).is_empty() and not available.has(str(item_name)):
			available.append(str(item_name))
	if available.size() < 2:
		notify("可即时切换的专属武器不足两把；未制作运行时素材的器型不会被替代显示。")
		return false
	var current_index := available.find(str(player.equipped_weapon))
	var next_index := (current_index + 1) % available.size() if current_index >= 0 else 0
	equip_weapon(available[next_index])
	notify("无冷却切换：%s。" % available[next_index])
	return true

func equip_artifact(item_name: String) -> void:
	if not player.inventory.has(item_name):
		notify("行囊中没有 %s，不能装备。" % item_name)
		return
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.artifact_profile_for_item(item_name)
	if profile.is_empty():
		notify("%s 尚未建立法宝卡与运行时素材，暂不能装备。" % item_name)
		return
	player.equipped_artifact = item_name
	notify("已装备法宝：%s｜%s" % [item_name, str(profile.trait)])
	profile_changed.emit()


func equip_armor(item_name: String) -> void:
	if not player.inventory.has(item_name):
		notify("行囊中没有 %s，不能装备。" % item_name)
		return
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.armor_profile_for_item(item_name)
	if profile.is_empty():
		notify("%s 尚未建立护具卡，暂不能装备。" % item_name)
		return
	player.equipped_armor = item_name
	notify("已装备护具：%s｜%s" % [item_name, str(profile.trait)])
	profile_changed.emit()


func equip_footwear(item_name: String) -> void:
	if not player.inventory.has(item_name):
		notify("行囊中没有%s，不能装备。" % item_name)
		return
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.footwear_profile_for_item(item_name)
	if profile.is_empty():
		notify("%s 尚未建立足部装备卡，暂不能装备。" % item_name)
		return
	player.equipped_footwear = item_name
	notify("已装备足部装备：%s｜%s" % [item_name, str(profile.trait)])
	profile_changed.emit()


func is_upgradeable_equipment(item_name: String) -> bool:
	var catalog := preload("res://src/data/game_catalog.gd")
	for family in catalog.WEAPON_FAMILIES:
		if item_name == str(family.starter):
			return true
	return not catalog.artifact_profile_for_item(item_name).is_empty() or not catalog.armor_profile_for_item(item_name).is_empty() or not catalog.footwear_profile_for_item(item_name).is_empty()


func equipment_upgrade_level(item_name: String) -> int:
	_normalize_player_schema()
	var states: Dictionary = player.equipment_upgrades
	var state: Dictionary = states.get(item_name, {})
	return clampi(int(state.get("level", 0)), 0, EQUIPMENT_MAX_UPGRADE)


func equipment_quality(item_name: String) -> String:
	var level := equipment_upgrade_level(item_name)
	if level >= 9:
		return "地品"
	if level >= 6:
		return "玄品"
	if level >= 3:
		return "灵品"
	return "凡品"


func equipment_power_bonus(item_name: String) -> int:
	return equipment_upgrade_level(item_name) * 2


func equipped_artifact_profile() -> Dictionary:
	var catalog := preload("res://src/data/game_catalog.gd")
	return catalog.artifact_profile_for_item(str(player.get("equipped_artifact", "")))


func equipped_armor_profile() -> Dictionary:
	var catalog := preload("res://src/data/game_catalog.gd")
	return catalog.armor_profile_for_item(str(player.get("equipped_armor", "")))


func artifact_mana_regen_bonus() -> float:
	return maxf(0.0, float(equipped_artifact_profile().get("mana_regen_bonus", 0.0)))


func equipped_footwear_profile() -> Dictionary:
	var catalog := preload("res://src/data/game_catalog.gd")
	return catalog.footwear_profile_for_item(str(player.get("equipped_footwear", "")))


func footwear_move_speed_bonus() -> float:
	return clampf(float(equipped_footwear_profile().get("move_speed_bonus", 0.0)), 0.0, 24.0)


func artifact_damage_reduction(element: String) -> float:
	var field := "%s_damage_reduction" % element.strip_edges().to_lower()
	return clampf(float(equipped_artifact_profile().get(field, 0.0)), 0.0, 0.75)


func elemental_damage_after_artifact(raw_damage: int, element: String) -> int:
	var reduction := artifact_damage_reduction(element)
	return maxi(1, ceili(float(raw_damage) * (1.0 - reduction)))


func armor_pve_damage_reduction() -> float:
	var armor_name := str(player.get("equipped_armor", ""))
	var base_reduction := float(equipped_armor_profile().get("pve_damage_reduction", 0.0))
	var upgrade_bonus := float(equipment_upgrade_level(armor_name)) * 0.006
	return clampf(base_reduction + upgrade_bonus, 0.0, 0.25)


func armor_elemental_damage_reduction(element: String) -> float:
	var profile := equipped_armor_profile()
	return clampf(float(profile.get("%s_damage_reduction" % element, 0.0)), 0.0, 0.25)


func pve_damage_after_equipment(raw_damage: int, element: String) -> int:
	var after_artifact := elemental_damage_after_artifact(raw_damage, element)
	var armor_reduction := armor_pve_damage_reduction() + armor_elemental_damage_reduction(element)
	return maxi(1, ceili(float(after_artifact) * (1.0 - clampf(armor_reduction, 0.0, 0.35))))


func weapon_basic_damage(base_damage: int) -> int:
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.weapon_profile_for_item(str(player.get("equipped_weapon", "")))
	var stats := derived_stats()
	return base_damage + int(int(stats["攻击"]) / 3.0) + int(profile.get("bonus", 0)) + equipment_power_bonus(str(player.get("equipped_weapon", "")))


func weapon_skill_damage(base_damage: int, attack_ratio: float, spirit_value: float, mana_ratio: float) -> int:
	var catalog := preload("res://src/data/game_catalog.gd")
	var profile: Dictionary = catalog.weapon_profile_for_item(str(player.get("equipped_weapon", "")))
	var stats := derived_stats()
	var safe_mana_ratio := maxf(1.0, mana_ratio)
	return base_damage + int(float(stats["攻击"]) * attack_ratio) + int(spirit_value / safe_mana_ratio) + int(profile.get("skill_bonus", 0)) + equipment_power_bonus(str(player.get("equipped_weapon", "")))


func equipment_upgrade_requirement(item_name: String) -> Dictionary:
	if not is_upgradeable_equipment(item_name):
		return {}
	var next_level := equipment_upgrade_level(item_name) + 1
	if next_level > EQUIPMENT_MAX_UPGRADE:
		return {}
	var material := "雾潮晶簇" if next_level <= 2 else ("流火矿" if next_level <= 5 else ("古战残魂" if next_level <= 8 else "天隙晶"))
	var count := next_level if next_level <= 2 else maxi(2, next_level - 2)
	var realm_required := 0 if next_level <= 2 else (1 if next_level <= 5 else (2 if next_level <= 8 else 3))
	return {"next_level": next_level, "material": material, "count": count, "realm_index": realm_required}


func equipment_upgrade_text(item_name: String) -> String:
	var requirement := equipment_upgrade_requirement(item_name)
	if requirement.is_empty():
		return "%s +%d｜%s（已达当前强化上限）" % [item_name, equipment_upgrade_level(item_name), equipment_quality(item_name)]
	return "%s +%d｜%s｜下次需 %s × %d｜境界 %s" % [item_name, equipment_upgrade_level(item_name), equipment_quality(item_name), str(requirement.material), int(requirement.count), _realm_name_for_index(int(requirement.realm_index))]


func upgrade_equipment(item_name: String) -> bool:
	if not is_upgradeable_equipment(item_name) or not player.inventory.has(item_name):
		return false
	var requirement := equipment_upgrade_requirement(item_name)
	if requirement.is_empty():
		notify("%s 已达首发强化上限。" % item_name)
		return false
	if int(player.realm_index) < int(requirement.realm_index):
		notify("强化%s需要至少%s，不能提前用材料跳过境界。" % [item_name, _realm_name_for_index(int(requirement.realm_index))])
		return false
	var materials: Array[String] = []
	for _index in int(requirement.count):
		materials.append(str(requirement.material))
	if not consume_items(materials):
		notify("强化材料不足：需要%s × %d。" % [str(requirement.material), int(requirement.count)])
		return false
	var states: Dictionary = player.equipment_upgrades
	states[item_name] = {"level": int(requirement.next_level)}
	player.equipment_upgrades = states
	notify("强化成功：%s +%d，品级进度为%s。" % [item_name, int(requirement.next_level), equipment_quality(item_name)])
	profile_changed.emit()
	return true


func _realm_name_for_index(realm_index: int) -> String:
	var catalog := preload("res://src/data/game_catalog.gd")
	var bounded := clampi(realm_index, 0, catalog.REALMS.size() - 1)
	return str(catalog.REALMS[bounded].name)

func join_sect(sect_id: String) -> bool:
	if not str(player.get("sect_id", "")).is_empty():
		notify("请先退出当前宗门，再自由选择新的去处。")
		return false
	var sect := _sect_by_id(sect_id)
	if sect.is_empty():
		notify("目标宗门不存在。")
		return false
	player.sect_id = sect_id
	player.sect_rank = 0
	player.sect_contribution = 0
	notify("已加入%s，身份从外门弟子开始。" % str(sect.name))
	profile_changed.emit()
	return true

func leave_sect() -> bool:
	var sect := current_sect()
	if sect.is_empty():
		notify("当前是散修，无需退出宗门。")
		return false
	var rank := int(player.get("sect_rank", 0))
	var wanted_rank := int(sect.get("exit_wanted_rank", 99))
	if rank >= wanted_rank:
		var wanted_by: Array = player.get("sect_wanted_by", [])
		if not wanted_by.has(str(sect.id)):
			wanted_by.append(str(sect.id))
		player.sect_wanted_by = wanted_by
	player.sect_id = ""
	player.sect_rank = 0
	player.sect_contribution = 0
	notify("已退出%s。%s" % [str(sect.name), str(sect.exit_penalty)])
	profile_changed.emit()
	return true

func current_sect() -> Dictionary:
	return _sect_by_id(str(player.get("sect_id", "")))

func sect_rank_name() -> String:
	if str(player.get("sect_id", "")).is_empty():
		return "散修"
	var catalog := preload("res://src/data/game_catalog.gd")
	var rank_index := clampi(int(player.get("sect_rank", 0)), 0, catalog.SECT_RANKS.size() - 1)
	return str(catalog.SECT_RANKS[rank_index].name)

func sect_promotion_requirement() -> Dictionary:
	if str(player.get("sect_id", "")).is_empty():
		return {}
	var catalog := preload("res://src/data/game_catalog.gd")
	var next_rank := int(player.get("sect_rank", 0)) + 1
	if next_rank >= catalog.SECT_RANKS.size():
		return {}
	return catalog.SECT_RANKS[next_rank]

func try_promote_sect_rank() -> bool:
	var requirement := sect_promotion_requirement()
	if requirement.is_empty():
		notify("当前没有可申请的下一宗门身份。")
		return false
	if int(player.get("sect_contribution", 0)) < int(requirement.contribution):
		notify("贡献不足：晋升%s需要贡献 %d。" % [str(requirement.name), int(requirement.contribution)])
		return false
	if not _meets_realm_requirement(requirement):
		notify("境界不足：晋升%s需要%s。" % [str(requirement.name), _realm_requirement_text(requirement)])
		return false
	player.sect_rank = int(player.get("sect_rank", 0)) + 1
	var sect := current_sect()
	if int(player.sect_rank) >= 1 and not sect.is_empty():
		discover_technique(str(sect.get("technique", "")), "%s内门传功" % str(sect.name))
	notify("身份晋升：%s。" % sect_rank_name())
	profile_changed.emit()
	return true

func contribute_item_to_sect(item_name: String) -> bool:
	if str(player.get("sect_id", "")).is_empty():
		notify("散修可自由持有资源；加入宗门后才能进献。")
		return false
	if item_name == str(player.get("equipped_weapon", "")) or item_name == str(player.get("equipped_artifact", "")) or item_name == str(player.get("equipped_armor", "")) or item_name == str(player.get("equipped_footwear", "")) or not player.inventory.has(item_name):
		notify("该物品不能作为当前宗门进献。")
		return false
	player.inventory.erase(item_name)
	var values := {"雾溪草": 10, "雾潮晶簇": 18, "赤焰精金": 32, "古战印": 24, "地火兽核": 20}
	var gained := int(values.get(item_name, 6))
	add_sect_contribution(gained, "进献%s" % item_name)
	return true

func add_sect_contribution(amount: int, source: String) -> void:
	if str(player.get("sect_id", "")).is_empty() or amount <= 0:
		return
	player.sect_contribution = int(player.get("sect_contribution", 0)) + amount
	notify("%s：宗门贡献 +%d（当前 %d）。" % [source, amount, int(player.sect_contribution)])
	profile_changed.emit()

func is_wanted_by_sect(sect_id: String) -> bool:
	var wanted_by: Array = player.get("sect_wanted_by", [])
	return wanted_by.has(sect_id)

func _sect_by_id(sect_id: String) -> Dictionary:
	if sect_id.is_empty():
		return {}
	var catalog := preload("res://src/data/game_catalog.gd")
	for sect in catalog.SECTS:
		if str(sect.id) == sect_id:
			return sect
	return {}

func _meets_realm_requirement(requirement: Dictionary) -> bool:
	var realm_requirement := int(requirement.realm_index)
	var stage_requirement := int(requirement.minor_stage)
	return player.realm_index > realm_requirement or (player.realm_index == realm_requirement and player.minor_stage >= stage_requirement)

func _realm_requirement_text(requirement: Dictionary) -> String:
	var catalog := preload("res://src/data/game_catalog.gd")
	var realm: Dictionary = catalog.REALMS[int(requirement.realm_index)]
	if int(requirement.realm_index) == 0:
		return "%s%d层" % [str(realm.name), int(requirement.minor_stage)]
	return "%s·%s" % [str(realm.name), str(realm.minor_stages[int(requirement.minor_stage) - 1])]

func _normalize_player_schema() -> void:
	if not player.has("attributes") or not player.attributes is Dictionary:
		player.attributes = {"体魄": 5, "灵识": 5, "身法": 5, "根骨": 5}
	else:
		var attributes: Dictionary = player.attributes
		for attribute_name in ["体魄", "灵识", "身法", "根骨"]:
			if not attributes.has(attribute_name):
				attributes[attribute_name] = 5
			else:
				attributes[attribute_name] = max(0, int(attributes[attribute_name]))
		player.attributes = attributes
	if not player.has("attribute_points_earned"):
		player.attribute_points_earned = max(INITIAL_ATTRIBUTE_POINTS, _attribute_points_spent_raw() + max(0, int(player.get("unspent_points", 0))))
	else:
		player.attribute_points_earned = max(INITIAL_ATTRIBUTE_POINTS, int(player.attribute_points_earned), _attribute_points_spent_raw())
	_refresh_attribute_budget()
	if not player.has("sect_rank"):
		player.sect_rank = 0
	if not player.has("sect_contribution"):
		player.sect_contribution = 0
	if not player.has("sect_wanted_by"):
		player.sect_wanted_by = []
	if not player.has("npc_relations") or not player.npc_relations is Dictionary:
		player.npc_relations = {}
	if not player.has("npc_met") or not player.npc_met is Array:
		player.npc_met = []
	if not player.has("npc_trade_records") or not player.npc_trade_records is Array:
		player.npc_trade_records = []
	if not player.has("learned_techniques"):
		player.learned_techniques = [str(player.get("cultivation_path", "云岚吐纳诀"))]
	if not player.has("technique_insight") or not player.technique_insight is Dictionary:
		player.technique_insight = {}
	for technique_name in player.learned_techniques:
		_ensure_technique_insight_entry(str(technique_name))
	if not player.has("medicine_tolerance") or not player.medicine_tolerance is Dictionary:
		player.medicine_tolerance = {"day": "", "burden": 0}
	else:
		var tolerance: Dictionary = player.medicine_tolerance
		tolerance.day = str(tolerance.get("day", ""))
		tolerance.burden = max(0, int(tolerance.get("burden", 0)))
		player.medicine_tolerance = tolerance
	if not player.has("alchemy_history") or not player.alchemy_history is Array:
		player.alchemy_history = []
	if not player.has("equipment_upgrades") or not player.equipment_upgrades is Dictionary:
		player.equipment_upgrades = {}
	else:
		var equipment_states: Dictionary = player.equipment_upgrades
		for item_name in equipment_states.keys():
			var raw_state: Variant = equipment_states[item_name]
			if raw_state is Dictionary:
				equipment_states[item_name] = {"level": clampi(int(raw_state.get("level", 0)), 0, EQUIPMENT_MAX_UPGRADE)}
			else:
				equipment_states.erase(item_name)
		player.equipment_upgrades = equipment_states
	if not player.has("weapon_trial_claimed"):
		player.weapon_trial_claimed = false
	else:
		player.weapon_trial_claimed = bool(player.weapon_trial_claimed)
	if not player.has("equipped_armor"):
		player.equipped_armor = ""
	else:
		player.equipped_armor = str(player.equipped_armor)
	if not player.has("equipped_footwear"):
		player.equipped_footwear = ""
	else:
		player.equipped_footwear = str(player.equipped_footwear)
	if not player.has("world_guidance") or not player.world_guidance is Dictionary:
		player.world_guidance = {"steps": [], "skipped": false}
	else:
		var guidance: Dictionary = player.world_guidance
		if not guidance.get("steps", []) is Array:
			guidance.steps = []
		if not guidance.has("skipped"):
			guidance.skipped = false
		player.world_guidance = guidance
	if not player.has("field_clues") or not player.field_clues is Array:
		player.field_clues = []
	if not player.has("opening_lore_seen"):
		player.opening_lore_seen = false
	else:
		player.opening_lore_seen = bool(player.opening_lore_seen)
	if not player.has("ecology_cooldowns") or not player.ecology_cooldowns is Dictionary:
		player.ecology_cooldowns = {}
	if not player.has("world_positions") or not player.world_positions is Dictionary:
		player.world_positions = {}
	if not player.has("fixed_dungeon_attempts") or not player.fixed_dungeon_attempts is Dictionary:
		player.fixed_dungeon_attempts = {"day": "", "used": 0}
	else:
		var fixed_attempts: Dictionary = player.fixed_dungeon_attempts
		fixed_attempts.day = str(fixed_attempts.get("day", ""))
		fixed_attempts.used = max(0, int(fixed_attempts.get("used", 0)))
		player.fixed_dungeon_attempts = fixed_attempts
	if not player.has("monthly_card") or not player.monthly_card is Dictionary:
		player.monthly_card = {"tier": "none", "expires_at": 0}
	else:
		var monthly_card: Dictionary = player.monthly_card
		var card_tier := str(monthly_card.get("tier", "none"))
		monthly_card.tier = card_tier if MONTHLY_CARD_BENEFITS.has(card_tier) else "none"
		monthly_card.expires_at = max(0, int(monthly_card.get("expires_at", 0)))
		player.monthly_card = monthly_card


func _attribute_points_spent_raw() -> int:
	var total := 0
	var attributes: Dictionary = player.get("attributes", {})
	for value in attributes.values():
		total += int(value)
	return max(0, total - BASE_ATTRIBUTE_TOTAL)


func _refresh_attribute_budget() -> void:
	var spent := _attribute_points_spent_raw()
	var earned: int = maxi(INITIAL_ATTRIBUTE_POINTS, maxi(int(player.get("attribute_points_earned", INITIAL_ATTRIBUTE_POINTS)), spent))
	player.attribute_points_earned = earned
	player.unspent_points = max(0, earned - spent)


func _grant_attribute_points(amount: int) -> void:
	if amount <= 0:
		return
	_normalize_player_schema()
	player.attribute_points_earned = int(player.attribute_points_earned) + amount
	_refresh_attribute_budget()


func _ensure_technique_insight_entry(technique_name: String) -> Dictionary:
	var all_insight: Dictionary = player.get("technique_insight", {})
	var entry: Variant = all_insight.get(technique_name, {})
	if not entry is Dictionary:
		entry = {}
	var insight: Dictionary = entry
	insight.progress = clampi(int(insight.get("progress", 0)), 0, int(TECHNIQUE_INSIGHT_THRESHOLDS.back()))
	insight.awards_claimed = clampi(int(insight.get("awards_claimed", 0)), 0, TECHNIQUE_INSIGHT_THRESHOLDS.size())
	all_insight[technique_name] = insight
	player.technique_insight = all_insight
	return insight

func is_ecology_profile_available(region_id: String, profile_id: String, now_unix: int = -1) -> bool:
	_normalize_player_schema()
	var key := "%s::%s" % [region_id, profile_id]
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	var available_at := int(player.ecology_cooldowns.get(key, 0))
	return available_at <= now

func mark_ecology_profile_resolved(region_id: String, profile_id: String, respawn_seconds: int, now_unix: int = -1) -> void:
	if region_id.is_empty() or profile_id.is_empty() or respawn_seconds <= 0:
		return
	_normalize_player_schema()
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	var cooldowns: Dictionary = player.ecology_cooldowns
	cooldowns["%s::%s" % [region_id, profile_id]] = now + respawn_seconds
	player.ecology_cooldowns = cooldowns
	profile_changed.emit()

func ecology_respawn_seconds(profile: Dictionary) -> int:
	if profile.has("respawn_seconds"):
		return max(0, int(profile.respawn_seconds))
	return int(ECOLOGY_RESPAWN_SECONDS.get(str(profile.get("kind", "")), 0))

func complete_world_guidance_step(step_id: String) -> bool:
	if not WORLD_GUIDANCE_STEPS.has(step_id):
		return false
	_normalize_player_schema()
	var guidance: Dictionary = player.world_guidance
	var steps: Array = guidance.steps
	if steps.has(step_id):
		return false
	steps.append(step_id)
	guidance.steps = steps
	player.world_guidance = guidance
	profile_changed.emit()
	return true

func has_world_guidance_step(step_id: String) -> bool:
	_normalize_player_schema()
	return (player.world_guidance.get("steps", []) as Array).has(step_id)

func is_world_guidance_complete() -> bool:
	_normalize_player_schema()
	if bool(player.world_guidance.get("skipped", false)):
		return true
	var steps: Array = player.world_guidance.get("steps", [])
	for step_id in WORLD_GUIDANCE_STEPS:
		if not steps.has(step_id):
			return false
	return true

func skip_world_guidance() -> bool:
	_normalize_player_schema()
	if is_world_guidance_complete():
		return false
	var guidance: Dictionary = player.world_guidance
	guidance.skipped = true
	player.world_guidance = guidance
	notify("已跳过世界引导。所有地图、修行与宗门选择仍可自由探索。")
	profile_changed.emit()
	return true

func world_guidance_text() -> String:
	_normalize_player_schema()
	if bool(player.world_guidance.get("skipped", false)):
		return "已跳过；可随时按自己的路径探索。"
	var steps: Array = player.world_guidance.get("steps", [])
	var labels := {"lan_breath": "认识岚息", "resource_ecology": "认识资源", "path_choice": "认识道途"}
	var pending: Array[String] = []
	for step_id in WORLD_GUIDANCE_STEPS:
		if not steps.has(step_id):
			pending.append(str(labels[step_id]))
	return "已完成" if pending.is_empty() else "可选：%s" % "、".join(pending)

func notify(text: String) -> void:
	last_notice = text
	notice_changed.emit(text)
