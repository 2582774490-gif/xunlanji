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
var local_market_listings: Array[Dictionary] = [
	{"id": "npc_ore", "name": "雾潮矿芯", "type": "材料", "price": 32, "seller": "雾港行商"},
	{"id": "npc_talisman", "name": "雷纹符材", "type": "符材", "price": 45, "seller": "候雷符修"},
]
var player := {
	"gender": "男",
	"face": 1,
	"hair": 1,
	"spirit_root": "水灵根",
	"physique": "岚息体",
	"cultivation_path": "云岚吐纳诀",
	"realm_index": 0,
	"minor_stage": 1,
	"cultivation": 0,
	"meditation_sessions": 3,
	"meditation_day": "",
	"unspent_points": 4,
	"attributes": {"体魄": 5, "灵识": 5, "身法": 5, "根骨": 5},
	"spirit_stones": 120,
	"gold": 80,
	"sect_id": "",
	"equipped_weapon": "练气木剑",
	"equipped_artifact": "纳灵玉佩",
	"inventory": ["练气木剑", "凝气符", "雾溪草", "纳灵玉佩"],
	"codex": ["云岚村", "雾溪水府"],
	"opportunity_log": [],
	"dungeon_runs": [],
	"unlocked_regions": ["starter_village"],
}

func enter_screen(next_screen: Screen) -> void:
	current_screen = next_screen
	screen_changed.emit(current_screen)

func market_fee(price: int) -> int:
	return max(1, ceili(float(price) * MARKET_FEE_RATE))

func list_item_for_market(item_name: String, price: int) -> bool:
	if price < MARKET_MIN_PRICE or price > MARKET_MAX_PRICE:
		notify("上架价格超出雾港保护范围。")
		return false
	if not player.inventory.has(item_name):
		notify("行囊中没有可上架的 %s。" % item_name)
		return false
	var fee := market_fee(price)
	if player.gold < fee:
		notify("上架手续费不足：需要 %d 金钱。" % fee)
		return false
	player.inventory.erase(item_name)
	player.gold -= fee
	local_market_listings.append({"id": "player_%d" % Time.get_ticks_msec(), "name": item_name, "type": "玩家寄售", "price": price, "seller": "本地修士"})
	notify("已上架 %s，标价 %d，手续费 %d。真实玩家交易将改由服务器结算。" % [item_name, price, fee])
	profile_changed.emit()
	return true

func buy_market_listing(index: int) -> bool:
	if index < 0 or index >= local_market_listings.size():
		return false
	var listing: Dictionary = local_market_listings[index]
	var price := int(listing.price)
	if player.gold < price:
		notify("金钱不足。")
		return false
	player.gold -= price
	add_item(str(listing.name))
	local_market_listings.remove_at(index)
	notify("成交：获得 %s，支付 %d 金钱。" % [listing.name, price])
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
	player.cultivation_path = path_name
	notify("已选定主修功法：%s" % path_name)
	profile_changed.emit()

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
	var before: int = player.cultivation
	player.cultivation = min(player.cultivation + max(amount, 0), threshold)
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
		player.unspent_points += 1
	else:
		player.realm_index += 1
		player.minor_stage = 1
		player.unspent_points += 3
	player.cultivation = 0
	notify("冲关成功：%s → %s" % [previous_name, realm_name()])
	profile_changed.emit()
	return true

func _refresh_meditation_day() -> void:
	var today := Time.get_date_string_from_system()
	if player.meditation_day != today:
		player.meditation_day = today
		player.meditation_sessions = 3

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
	return true

func allocate_attribute(attribute_name: String) -> bool:
	if player.unspent_points <= 0 or not player.attributes.has(attribute_name):
		return false
	player.unspent_points -= 1
	player.attributes[attribute_name] += 1
	notify("%s +1，剩余属性点 %d" % [attribute_name, player.unspent_points])
	profile_changed.emit()
	return true

func derived_stats() -> Dictionary:
	var a: Dictionary = player.attributes
	return {
		"气血": 100 + int(a["体魄"]) * 15 + int(a["根骨"]) * 5,
		"灵力": 60 + int(a["灵识"]) * 12 + int(a["根骨"]) * 6,
		"攻击": 8 + int(a["体魄"]) * 2 + int(a["灵识"]),
		"移速": 100 + int(a["身法"]) * 3,
	}

func add_item(item_name: String) -> void:
	player.inventory.append(item_name)
	if not player.codex.has(item_name):
		player.codex.append(item_name)
	profile_changed.emit()

func add_spirit_stones(amount: int) -> void:
	player.spirit_stones += max(amount, 0)
	profile_changed.emit()

func record_opportunity(entry: Dictionary) -> void:
	player.opportunity_log.append(entry)
	profile_changed.emit()

func record_dungeon_run(entry: Dictionary) -> void:
	player.dungeon_runs.append(entry)
	profile_changed.emit()

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

func use_cultivation_item(item_name: String, cultivation_amount: int, max_realm_index: int, max_minor_stage: int) -> bool:
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
	add_item("筑基丹")
	notify("炼制成功：筑基丹已入囊。待炼气圆满、修为积满后，可在修炼界面冲击筑基。")
	return true

func equip_weapon(item_name: String) -> void:
	player.equipped_weapon = item_name
	notify("已装备：%s（仅外观/类型占位，不绑定特效）" % item_name)
	profile_changed.emit()

func join_sect(sect_id: String) -> void:
	player.sect_id = sect_id
	notify("已加入宗门。身份从外门弟子开始。")
	profile_changed.emit()

func leave_sect() -> void:
	player.sect_id = ""
	notify("已退出宗门。正式版将按门规判定是否进入通缉状态。")
	profile_changed.emit()

func notify(text: String) -> void:
	last_notice = text
	notice_changed.emit(text)
