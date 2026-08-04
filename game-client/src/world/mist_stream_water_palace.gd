extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var boss: Area2D = $Boss
@onready var boss_hp: Label = $HUD/BossPanel/BossHP
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var player_mana_label: Label = $HUD/PlayerMana
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var slash_trail: Node = $CombatEffects/SlashTrail
@onready var hit_spark: Node = $CombatEffects/HitSpark
@onready var ningxi_cast: Node = $CombatEffects/NingxiCast
@onready var demon_water_blade: Node = $CombatEffects/DemonWaterBlade

var boss_health := 100
var near_boss := false
var player_health := 100
var player_mana := 0.0
var player_max_mana := 0.0
var ningxi_cooldown := 0.0
var boss_attack_cooldown := 2.4
var defeated := false

func _ready() -> void:
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(240, 1250)
	player_health = int(GameState.derived_stats()["气血"])
	player_max_mana = float(GameState.derived_stats()["灵力"])
	player_mana = player_max_mana
	player.attack_started.connect(_on_player_attack_started)
	player.attack_impact.connect(_on_player_attack)
	boss.body_entered.connect(func(body: Node2D): near_boss = body == player; _refresh_prompt())
	boss.body_exited.connect(func(body: Node2D): if body == player: near_boss = false; _refresh_prompt())
	status.text = "雾溪水府：深入内池，击败水妖首领潮妃·兰纱。"
	_refresh_boss_hp()
	_refresh_player_hp()
	_refresh_player_mana()

func _process(delta: float) -> void:
	ningxi_cooldown = maxf(0.0, ningxi_cooldown - delta)
	player_mana = minf(player_max_mana, player_mana + delta * 2.0)
	_refresh_player_mana()
	if defeated or not near_boss or boss_health <= 0:
		return
	boss_attack_cooldown -= delta
	if boss_attack_cooldown > 0.0:
		return
	boss_attack_cooldown = 2.4
	_perform_boss_water_blade()


func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -86) + facing * 44.0, facing)
	await get_tree().create_timer(0.22).timeout
	if defeated or not near_boss or boss_health <= 0:
		return
	var damage := 9
	player_health = max(0, player_health - damage)
	status.text = "潮妃·兰纱掀起水刃，造成 %d 点伤害。" % damage
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在水府中力竭而退：死亡不掉落，正在返回云岚村。"
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")

func _on_player_attack(_direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	hit_spark.play_burst(boss.position + Vector2(0, -90), Vector2.UP)
	var damage := 8 + int(int(GameState.derived_stats()["攻击"]) / 3.0)
	boss_health = max(0, boss_health - damage)
	status.text = "潮妃·兰纱受击，造成 %d 点伤害。属性分配已影响本次攻击。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()


func _on_player_attack_started(direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	var facing := _direction_vector(direction)
	slash_trail.play_burst(player.position + facing * 46.0 + Vector2(0, -34), facing)


func _cast_ningxi_sword_art() -> void:
	if not near_boss or boss_health <= 0:
		status.text = "凝息剑诀需要锁定近处目标。"
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
	var damage := 20 + int(int(stats["攻击"]) / 2.0) + int(int(stats["灵力"]) / 30.0)
	boss_health = max(0, boss_health - damage)
	hit_spark.play_burst(boss.position + Vector2(0, -90), Vector2.UP)
	status.text = "凝息剑诀命中潮妃·兰纱，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()


func _defeat_boss() -> void:
	boss.visible = false
	GameState.add_item("水府初阶法器匣")
	GameState.gain_cultivation(20)
	status.text = "水府试炼完成：获得水府初阶法器匣与 20 修为。"
	prompt.text = ""


func _direction_vector(direction: String) -> Vector2:
	match direction:
		"south": return Vector2.DOWN
		"south_west": return Vector2(-1, 1).normalized()
		"west": return Vector2.LEFT
		"north_west": return Vector2(-1, -1).normalized()
		"north": return Vector2.UP
		"north_east": return Vector2(1, -1).normalized()
		"east": return Vector2.RIGHT
		"south_east": return Vector2(1, 1).normalized()
	return Vector2.DOWN

func _refresh_boss_hp() -> void:
	boss_hp.text = "潮妃 · 兰纱  |  气血 %d / 100" % boss_health

func _refresh_player_hp() -> void:
	player_hp_label.text = "气血 %d / %d" % [player_health, int(GameState.derived_stats()["气血"])]


func _refresh_player_mana() -> void:
	var availability := "可用" if ningxi_cooldown <= 0.0 else "%.1fs" % ningxi_cooldown
	player_mana_label.text = "灵力 %d / %d  |  凝息剑诀 %s" % [int(player_mana), int(player_max_mana), availability]

func _refresh_prompt() -> void:
	prompt.text = "[J] 普攻  [K] 凝息剑诀" if near_boss and boss_health > 0 else ""

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_K:
		_cast_ningxi_sword_art()
		get_viewport().set_input_as_handled()
		return
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_H or event.keycode == KEY_ESCAPE):
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
