class_name MistForestGrove
extends "res://src/world/mist_stream_water_palace.gd"

const MIST_FOREST_DROPS := [
	{"item": "雾木灵芯", "stones": 22, "cultivation": 38},
	{"item": "妖将护符", "stones": 28, "cultivation": 32},
	{"item": "炼气雾纹佩", "stones": 18, "cultivation": 44},
	{"item": "雾林轻甲", "stones": 26, "cultivation": 36},
]

func _ready() -> void:
	super._ready()
	GameState.current_region_id = "mist_border"
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(260, 1240)
	boss.position = Vector2(1910, 420)
	boss_health = 160
	boss_attack_cooldown = 2.0
	$HUD/Title.text = "雾林妖径  |  炼气二层副本"
	status.text = "雾林妖径：击退雾林妖将 · 玄枝。炼气二层即可尝试，但妖将的雾刃伤害更高。"
	_refresh_boss_hp()

func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -92) + facing * 46.0, facing)
	await get_tree().create_timer(0.22).timeout
	if defeated or not boss_engaged or not _boss_can_reach_player() or boss_health <= 0:
		return
	var damage := GameState.pve_damage_after_equipment(14, "neutral")
	var array_ward := _show_eightfold_array_ward("neutral")
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		status.text = "岚息护体挡下了大半雾刃。"
	player_health = max(0, player_health - damage)
	status.text = "雾林妖将 · 玄枝挥出雾刃，造成 %d 点伤害。%s" % [damage, "八角阵纹展开，卸去部分冲击。" if array_ward else ""]
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在雾林中力竭而退：死亡不掉落，正在返回雾潮边境。"
		await get_tree().create_timer(1.2).timeout
		_return_to_village()

func _on_player_attack(_direction: String) -> void:
	if not _can_hit_boss_with_basic() or boss_health <= 0:
		return
	_play_basic_weapon_effect()
	hit_spark.play_burst(boss.position + Vector2(0, -96), Vector2.UP)
	var damage := GameState.weapon_basic_damage(10)
	boss_health = max(0, boss_health - damage)
	status.text = "雾林妖将 · 玄枝受击，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()

func _cast_ningxi_sword_art() -> void:
	_cast_dungeon_weapon_primary(24, "玄枝", Vector2(0, -96))

func _defeat_boss() -> void:
	if defeated:
		return
	defeated = true
	boss.visible = false
	boss.set_deferred("monitoring", false)
	last_drop = MIST_FOREST_DROPS.pick_random().duplicate()
	GameState.add_item(str(last_drop.item))
	# 妖丹是筑基丹的稳定核心，随机装备/材料掉落仍保留其探索感。
	GameState.add_item("雾林妖丹")
	GameState.add_spirit_stones(int(last_drop.stones))
	GameState.gain_cultivation(int(last_drop.cultivation))
	var monthly_card_bonus := GameState.try_award_monthly_card_common_material("mist_forest", ["雾木灵芯"])
	GameState.record_dungeon_run({
		"dungeon_id": "mist_forest",
		"boss": "雾林妖将·玄枝",
		"drop": last_drop.item,
		"monthly_card_common_bonus": monthly_card_bonus,
		"spirit_stones": last_drop.stones,
		"cultivation": last_drop.cultivation,
	})
	status.text = "雾林试炼完成：已获得随机掉落与雾林妖丹，可从结算面板返回雾潮边境。"
	prompt.text = ""
	var monthly_bonus_text := "、%s（月卡常规材料）" % monthly_card_bonus if not monthly_card_bonus.is_empty() else ""
	clear_summary.text = "雾林妖将 · 玄枝散入林雾。\n\n获得：%s、雾林妖丹%s\n灵石 +%d　修为 +%d\n\n妖丹可作为筑基丹丹方的核心；本次战利品已进入行囊。" % [str(last_drop.item), monthly_bonus_text, int(last_drop.stones), int(last_drop.cultivation)]
	clear_panel.visible = true

func _return_to_village() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")

func _refresh_boss_hp() -> void:
	boss_hp.text = "雾林妖将 · 玄枝  |  气血 %d / 160" % boss_health
