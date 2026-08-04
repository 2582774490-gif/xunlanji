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
	var damage := 20
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		status.text = "岚息护体挡下了大半地火爪焰。"
	player_health = max(0, player_health - damage)
	status.text = "地火灵兽·炽甲拍出地火爪焰，造成 %d 点伤害。" % damage
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
	var damage := 16 + int(int(GameState.derived_stats()["攻击"]) / 3.0)
	boss_health = max(0, boss_health - damage)
	status.text = "地火灵兽·炽甲受击，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()

func _cast_ningxi_sword_art() -> void:
	if not near_boss or boss_health <= 0:
		status.text = "凝息剑诀需要锁定近处的地火灵兽。"
		return
	if ningxi_cooldown > 0.0:
		status.text = "凝息剑诀还需冷却 %.1f 秒。" % ningxi_cooldown
		return
	if player_mana < 18.0:
		status.text = "灵力不足，无法施放凝息剑诀。"
		return
	var facing := (boss.position - player.position).normalized()
	player_mana -= 18.0
	ningxi_cooldown = 4.0
	_refresh_player_mana()
	ningxi_cast.play_burst(player.position + Vector2(0, -62), facing)
	status.text = "凝息剑诀结印中……灵力 -18。"
	await get_tree().create_timer(0.24).timeout
	if defeated or not near_boss or boss_health <= 0:
		return
	var stats: Dictionary = GameState.derived_stats()
	var damage := 34 + int(int(stats["攻击"]) / 2.0) + int(int(stats["灵力"]) / 30.0)
	boss_health = max(0, boss_health - damage)
	hit_spark.play_burst(boss.position + Vector2(0, -108), Vector2.UP)
	status.text = "凝息剑诀命中炽甲，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()

func _defeat_boss() -> void:
	if defeated:
		return
	defeated = true
	boss.visible = false
	boss.set_deferred("monitoring", false)
	last_drop = EARTHFIRE_DROPS.pick_random().duplicate()
	GameState.add_item(str(last_drop.item))
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
	clear_summary.text = "地火灵兽·炽甲沉入熄火的岩池。\n\n获得：%s\n灵石 +%d　修为 +%d\n\n地火洞保留为固定副本；后续会增加洞内深层、火脉锻台与掉落分支。" % [str(last_drop.item), int(last_drop.stones), int(last_drop.cultivation)]
	clear_panel.visible = true

func _return_to_village() -> void:
	GameState.current_region_id = "ancient_ridge"
	get_tree().change_scene_to_file("res://scenes/ancient_ridge.tscn")

func _refresh_boss_hp() -> void:
	boss_hp.text = "地火灵兽 · 炽甲  |  气血 %d / 260" % boss_health
