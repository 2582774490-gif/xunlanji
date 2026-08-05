class_name SunkenVesselManor
extends "res://src/world/mist_forest_grove.gd"

const SUNKEN_VESSEL_DROPS := [
	{"item": "古舷木芯", "stones": 34, "cultivation": 40},
	{"item": "沉舟阵枢", "stones": 38, "cultivation": 36},
	{"item": "雾港引潮盘", "stones": 30, "cultivation": 46},
]

func _ready() -> void:
	super._ready()
	GameState.current_region_id = "mist_border"
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(250, 1250)
	boss.position = Vector2(1900, 410)
	boss_health = 220
	boss_attack_cooldown = 1.95
	$HUD/Title.text = "沉舷遗府  |  炼气四层副本"
	status.text = "沉舷遗府：古舟残灵·鸣濯守着沉没航图。炼气四层可以自行尝试；此地不是主线任务，战或退都由你决定。"
	_refresh_boss_hp()

func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -100) + facing * 58.0, facing)
	await get_tree().create_timer(0.24).timeout
	if defeated or not boss_engaged or not _boss_can_reach_player() or boss_health <= 0:
		return
	var raw_damage := 17
	var damage := GameState.pve_damage_after_equipment(raw_damage, "water")
	var mitigation_notes: Array[String] = []
	var water_reduction := GameState.artifact_damage_reduction("water")
	if water_reduction > 0.0:
		mitigation_notes.append("%s凝出水幕，抵去%d%%水系伤害。" % [str(GameState.player.get("equipped_artifact", "法宝")), roundi(water_reduction * 100.0)])
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		mitigation_notes.append("岚息护体偏开了锚影锁潮的大半冲击。")
	player_health = max(0, player_health - damage)
	status.text = "沉舷残灵·鸣濯挥出锚影锁潮，造成 %d 点伤害。%s" % [damage, " ".join(mitigation_notes)]
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你从沉舟甲板撤离：死亡不掉落，正在返回雾潮边境。"
		await get_tree().create_timer(1.2).timeout
		_return_to_village()

func _on_player_attack(_direction: String) -> void:
	if not _can_hit_boss_with_basic() or boss_health <= 0:
		return
	_play_basic_weapon_effect()
	hit_spark.play_burst(boss.position + Vector2(0, -104), Vector2.UP)
	var damage := GameState.weapon_basic_damage(11)
	boss_health = max(0, boss_health - damage)
	status.text = "沉舷残灵·鸣濯受击，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()

func _defeat_boss() -> void:
	if defeated:
		return
	defeated = true
	boss.visible = false
	boss.set_deferred("monitoring", false)
	last_drop = SUNKEN_VESSEL_DROPS.pick_random().duplicate()
	GameState.add_item(str(last_drop.item))
	GameState.add_item("沉舟航图残页")
	GameState.add_spirit_stones(int(last_drop.stones))
	GameState.gain_cultivation(int(last_drop.cultivation))
	GameState.record_dungeon_run({
		"dungeon_id": "sunken_boat",
		"boss": "沉舷残灵·鸣濯",
		"drop": last_drop.item,
		"spirit_stones": last_drop.stones,
		"cultivation": last_drop.cultivation,
	})
	status.text = "沉舷遗府已探索：获得随机舟材与航图残页，可从结算面板返回雾潮边境。"
	prompt.text = ""
	clear_summary.text = "沉舷残灵·鸣濯收回锚影。\n\n获得：%s、沉舟航图残页\n灵石 +%d　修为 +%d\n\n航图残页会成为后续归墟雾港与交易线索的一部分。" % [str(last_drop.item), int(last_drop.stones), int(last_drop.cultivation)]
	clear_panel.visible = true

func _return_to_village() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")

func _refresh_boss_hp() -> void:
	boss_hp.text = "沉舷残灵·鸣濯  |  气血 %d / 220" % boss_health
