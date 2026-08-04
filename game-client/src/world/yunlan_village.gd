extends Node2D

@onready var merchant: Area2D = $MarketkeeperLuo/Interaction
@onready var prompt: Label = $HUD/Prompt
var active_merchant := false

func _ready() -> void:
	merchant.focused.connect(func(_interaction): active_merchant = true; prompt.text = "[E] 与云市掌柜 · 洛晴交易")
	merchant.unfocused.connect(func(_interaction): active_merchant = false; prompt.text = "")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_ESCAPE or event.keycode == KEY_H):
		get_tree().change_scene_to_file("res://scenes/yunlan_south_gate.tscn")
	elif event.is_pressed() and not event.is_echo() and event.keycode == KEY_E and active_merchant:
		GameState.enter_screen(GameState.Screen.MARKET)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
