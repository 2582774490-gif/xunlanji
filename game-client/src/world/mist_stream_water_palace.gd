extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var boss: Area2D = $Boss
@onready var boss_hp: Label = $HUD/BossPanel/BossHP
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt

var boss_health := 100
var near_boss := false
var player_health := 100
var boss_attack_cooldown := 2.4
var defeated := false

func _ready() -> void:
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(240, 1250)
	player_health = int(GameState.derived_stats()["气血"])
	player.attack_started.connect(_on_player_attack)
	boss.body_entered.connect(func(body: Node2D): near_boss = body == player; _refresh_prompt())
	boss.body_exited.connect(func(body: Node2D): if body == player: near_boss = false; _refresh_prompt())
	status.text = "雾溪水府：深入内池，击败水妖首领潮妃·兰纱。"
	_refresh_boss_hp()
	_refresh_player_hp()

func _process(delta: float) -> void:
	if defeated or not near_boss or boss_health <= 0:
		return
	boss_attack_cooldown -= delta
	if boss_attack_cooldown > 0.0:
		return
	boss_attack_cooldown = 2.4
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
	var damage := 8 + int(int(GameState.derived_stats()["攻击"]) / 3.0)
	boss_health = max(0, boss_health - damage)
	status.text = "潮妃·兰纱受击，造成 %d 点伤害。属性分配已影响本次攻击。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		boss.visible = false
		GameState.add_item("水府初阶法器匣")
		GameState.gain_cultivation(20)
		status.text = "水府试炼完成：获得水府初阶法器匣与 20 修为。"
		prompt.text = ""

func _refresh_boss_hp() -> void:
	boss_hp.text = "潮妃 · 兰纱  |  气血 %d / 100" % boss_health

func _refresh_player_hp() -> void:
	player_hp_label.text = "气血 %d / %d" % [player_health, int(GameState.derived_stats()["气血"])]

func _refresh_prompt() -> void:
	prompt.text = "[J] 攻击水妖首领" if near_boss and boss_health > 0 else ""

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_H or event.keycode == KEY_ESCAPE):
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
