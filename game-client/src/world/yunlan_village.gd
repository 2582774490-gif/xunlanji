extends Node2D

@onready var merchant: Area2D = $MarketkeeperLuo/Interaction
@onready var alchemy: Area2D = $AlchemyWorkshop/Interaction
@onready var water_palace: Area2D = $WaterPalaceEntrance/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var touch_controls: Node = $HUD/TouchControls
var active_interaction_id := ""

func _ready() -> void:
	merchant.focused.connect(func(_interaction): _set_context("merchant", "与云市掌柜 · 洛晴交易"))
	merchant.unfocused.connect(func(_interaction): _clear_context("merchant"))
	alchemy.focused.connect(func(_interaction): _set_context("alchemy", "进入炼丹工坊"))
	alchemy.unfocused.connect(func(_interaction): _clear_context("alchemy"))
	water_palace.focused.connect(func(_interaction): _set_context("water_palace", "进入雾溪水府（炼气副本）"))
	water_palace.unfocused.connect(func(_interaction): _clear_context("water_palace"))
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_ESCAPE or event.keycode == KEY_H):
		get_tree().change_scene_to_file("res://scenes/yunlan_south_gate.tscn")
	elif event.is_pressed() and not event.is_echo() and event.keycode == KEY_E:
		_activate_contextual()


func _set_context(interaction_id: String, description: String) -> void:
	active_interaction_id = interaction_id
	prompt.text = "[E / 交互] %s" % description
	touch_controls.set_interaction_available(true)


func _clear_context(interaction_id: String) -> void:
	if active_interaction_id != interaction_id:
		return
	active_interaction_id = ""
	prompt.text = ""
	touch_controls.set_interaction_available(false)


func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()


func _activate_contextual() -> void:
	match active_interaction_id:
		"merchant":
			GameState.enter_screen(GameState.Screen.MARKET)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"alchemy":
			GameState.enter_screen(GameState.Screen.ALCHEMY)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"water_palace":
			GameState.selected_dungeon_id = "mist_stream_palace"
			get_tree().change_scene_to_file("res://scenes/mist_stream_water_palace.tscn")
