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
const FOUNDATION_PREPARATION_ITEMS := ["临渊露", "御崖石屑", "护脉阵片"]
const WORLD_GUIDANCE_STEPS := ["lan_breath", "resource_ecology", "path_choice"]
const LOCAL_SAVE_PATH := "user://xunlanji_local_profile.json"
const LOCAL_SAVE_VERSION := 1
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
	"learned_techniques": ["云岚吐纳诀"],
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
	"sect_rank": 0,
	"sect_contribution": 0,
	"sect_wanted_by": [],
	"world_guidance": {"steps": [], "skipped": false},
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

func cancel_market_listing(index: int) -> bool:
	if index < 0 or index >= local_market_listings.size():
		return false
	var listing: Dictionary = local_market_listings[index]
	if str(listing.seller) != "本地修士":
		notify("只能撤回自己上架的物品。")
		return false
	local_market_listings.remove_at(index)
	add_item(str(listing.name))
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
	if not player.get("learned_techniques", []).has(path_name):
		var learned: Array = player.get("learned_techniques", [])
		learned.append(path_name)
		player.learned_techniques = learned
	player.cultivation_path = path_name
	notify("已切换主修功法：%s。功法可随时转换，灵根与体质只影响效率。" % path_name)
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

func add_spirit_stones(amount: int) -> void:
	player.spirit_stones += max(amount, 0)
	profile_changed.emit()

func record_opportunity(entry: Dictionary) -> void:
	player.opportunity_log.append(entry)
	profile_changed.emit()

func record_dungeon_run(entry: Dictionary) -> void:
	player.dungeon_runs.append(entry)
	if not str(player.get("sect_id", "")).is_empty():
		add_sect_contribution(12, "完成宗门认可的副本探索")
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
	notify("身份晋升：%s。" % sect_rank_name())
	profile_changed.emit()
	return true

func contribute_item_to_sect(item_name: String) -> bool:
	if str(player.get("sect_id", "")).is_empty():
		notify("散修可自由持有资源；加入宗门后才能进献。")
		return false
	if item_name == str(player.get("equipped_weapon", "")) or not player.inventory.has(item_name):
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
	if not player.has("sect_rank"):
		player.sect_rank = 0
	if not player.has("sect_contribution"):
		player.sect_contribution = 0
	if not player.has("sect_wanted_by"):
		player.sect_wanted_by = []
	if not player.has("learned_techniques"):
		player.learned_techniques = [str(player.get("cultivation_path", "云岚吐纳诀"))]
	if not player.has("world_guidance") or not player.world_guidance is Dictionary:
		player.world_guidance = {"steps": [], "skipped": false}
	else:
		var guidance: Dictionary = player.world_guidance
		if not guidance.get("steps", []) is Array:
			guidance.steps = []
		if not guidance.has("skipped"):
			guidance.skipped = false
		player.world_guidance = guidance

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
