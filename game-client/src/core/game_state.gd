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

func gain_cultivation(amount: int) -> String:
	var catalog := preload("res://src/data/game_catalog.gd")
	var threshold: int = 100 + player.realm_index * 45 + player.minor_stage * 12
	player.cultivation += amount
	var result := "修为 +%d" % amount
	if player.cultivation >= threshold:
		player.cultivation = 0
		player.unspent_points += 2
		if player.realm_index == 0 and player.minor_stage < 9:
			player.minor_stage += 1
			result = "突破成功：%s" % realm_name()
		elif player.realm_index < catalog.REALMS.size() - 1:
			player.realm_index += 1
			player.minor_stage = 1
			result = "大境界突破：%s" % realm_name()
		else:
			player.minor_stage = min(player.minor_stage + 1, catalog.REALMS[player.realm_index].minor_stages.size())
			result = "已抵达首发上限：化神圆满"
	notify(result)
	profile_changed.emit()
	return result

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
