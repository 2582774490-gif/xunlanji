class_name EarthfireCave
extends "res://src/world/mist_forest_grove.gd"

const EARTHFIRE_DROPS := [
	{"item": "赤焰精金", "stones": 36, "cultivation": 48},
	{"item": "地火兽核", "stones": 42, "cultivation": 40},
	{"item": "熔脉护符", "stones": 30, "cultivation": 54},
]

func _ready() -> void:
	super._ready()
	GameState.current_region_id = "ancient_ridge"
	GameState.selected_dungeon_id = "earth_fire"
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(260, 1240)
	boss.position = Vector2(1900, 450)
	boss_health = 260
	boss_attack_cooldown = 1.9
	$HUD/Title.text = "地火洞 · 元婴固定副本"
	status.text = "地火洞：从古脊山道进入的固定副本。击退地火灵兽·炽甲，即可取得炼器与元婴期所需的火脉材料。"
	_refresh_boss_hp()

func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -100) + facing * 46.0, facing)
	await get_tree().create_timer(0.22).timeout
	if defeated or not near_boss or boss_health <= 0:
		return
	var raw_damage := 20
	var damage := GameState.elemental_damage_after_artifact(raw_damage, "earth")
	var mitigation_notes: Array[String] = []
	var earth_reduction := GameState.artifact_damage_reduction("earth")
	if earth_reduction > 0.0:
		mitigation_notes.append("%s镇住岩势，抵去%d%%土岩伤害。" % [str(GameState.player.get("equipped_artifact", "法宝")), roundi(earth_reduction * 100.0)])
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		mitigation_notes.append("岚息护体挡下了大半地火爪焰。")
	player_health = max(0, player_health - damage)
	status.text = "地火灵兽·炽甲拍出地火爪焰，造成 %d 点伤害。%s" % [damage, " ".join(mitigation_notes)]
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在地火洞中暂时力竭：死亡不掉落，正在返回古脊岭。"
		await get_tree().create_timer(1.2).timeout
		_return_to_village()

func _on_player_attack(_direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	hit_spark.play_burst(boss.position + Vector2(0, -108), Vector2.UP)
	var damage := GameState.weapon_basic_damage(16)
	boss_health = max(0, boss_health - damage)
	status.text = "地火灵兽·炽甲受击，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()

func _cast_ningxi_sword_art() -> void:
	_cast_dungeon_weapon_primary(34, "炽甲", Vector2(0, -108))

func _defeat_boss() -> void:
	if defeated:
		return
	defeated = true
	boss.visible = false
	boss.set_deferred("monitoring", false)
	var first_clear_seal := not GameState.player.inventory.has("玄土练气印")
	last_drop = EARTHFIRE_DROPS.pick_random().duplicate()
	GameState.add_item(str(last_drop.item))
	if first_clear_seal:
		GameState.add_item("玄土练气印")
	GameState.add_spirit_stones(int(last_drop.stones))
	GameState.gain_cultivation(int(last_drop.cultivation))
	GameState.record_dungeon_run({
		"dungeon_id": "earth_fire",
		"boss": "地火灵兽·炽甲",
		"drop": last_drop.item,
		"spirit_stones": last_drop.stones,
		"cultivation": last_drop.cultivation,
	})
	status.text = "地火洞试炼完成：奖励已进入行囊，可从结算面板返回古脊岭。"
	prompt.text = ""
	var seal_reward := "、玄土练气印（首通护身法宝）" if first_clear_seal else ""
	clear_summary.text = "地火灵兽·炽甲沉入熄火的岩池。\n\n获得：%s%s\n灵石 +%d　修为 +%d\n\n地火洞保留为固定副本；后续会增加洞内深层、火脉锻台与掉落分支。" % [str(last_drop.item), seal_reward, int(last_drop.stones), int(last_drop.cultivation)]
	clear_panel.visible = true

func _return_to_village() -> void:
	GameState.current_region_id = "ancient_ridge"
	get_tree().change_scene_to_file("res://scenes/ancient_ridge.tscn")

func _refresh_boss_hp() -> void:
	boss_hp.text = "地火灵兽 · 炽甲  |  气血 %d / 260" % boss_health
