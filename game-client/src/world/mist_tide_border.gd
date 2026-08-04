class_name MistTideBorder
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $RuinedCheckpoint/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D

func _ready() -> void:
	GameState.current_region_id = "mist_border"
	player.map_bounds = Rect2(80, 80, 3184, 1722)
	player.position = Vector2(520, 1570)
	status.text = "雾潮边境：这是第二个大区的首个空间切片。地表、残关与雾木均为独立层；后续会在此扩展筑基区域、副本与宗门争端。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_village()

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E / 交互] " + str(interaction.prompt_text)
	touch_controls.set_interaction_available(true)

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction != interaction:
		return
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_village()

func _return_to_village() -> void:
	GameState.current_region_id = "starter_village"
	get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
