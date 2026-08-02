extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var boss: Area2D = $Boss
@onready var boss_hp: Label = $HUD/BossPanel/BossHP
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt

var boss_health := 100
var near_boss := false

func _ready() -> void:
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(260, 1160)
	player.attack_started.connect(_on_player_attack)
	boss.body_entered.connect(func(body: Node2D): near_boss = body == player; _refresh_prompt())
	boss.body_exited.connect(func(body: Node2D): if body == player: near_boss = false; _refresh_prompt())
	status.text = "Mist-Stream Water Palace: reach the inner pool and test the boss encounter loop."
	_refresh_boss_hp()

func _on_player_attack(_direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	boss_health = max(0, boss_health - 12)
	status.text = "Qiao Tide Demoness Lansa is struck. The combat hook is now connected to the same player controller."
	_refresh_boss_hp()
	if boss_health == 0:
		boss.visible = false
		GameState.add_item("Water Palace Initiate Token")
		GameState.gain_cultivation(20)
		status.text = "Encounter cleared. Received initial equipment token and cultivation reward."
		prompt.text = ""

func _refresh_boss_hp() -> void:
	boss_hp.text = "Qiao Tide Demoness Lansa  |  HP %d / 100" % boss_health

func _refresh_prompt() -> void:
	prompt.text = "[J] Attack the Water Demon" if near_boss and boss_health > 0 else ""

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_H or event.keycode == KEY_ESCAPE):
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/playable_world.tscn")
