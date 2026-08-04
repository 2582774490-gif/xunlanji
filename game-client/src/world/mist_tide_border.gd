class_name MistTideBorder
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $RuinedCheckpoint/Interaction
@onready var scout_interaction: Area2D = $BorderScoutLiuShuo/Interaction
@onready var crystal_interaction: Area2D = $MistTideCrystal/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var scout_dialogue_stage := 0
var crystal_collected := false

func _ready() -> void:
	GameState.current_region_id = "mist_border"
	player.map_bounds = Rect2(80, 80, 3184, 1722)
	player.position = Vector2(520, 1570)
	status.text = "雾潮边境：这是第二个大区的首个空间切片。地表、残关与雾木均为独立层；边境探子可提供筑基区域的线索。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	scout_interaction.focused.connect(_focus_interaction)
	scout_interaction.unfocused.connect(_unfocus_interaction)
	crystal_interaction.focused.connect(_focus_interaction)
	crystal_interaction.unfocused.connect(_unfocus_interaction)
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
	elif active_interaction == scout_interaction:
		_talk_to_scout()
	elif active_interaction == crystal_interaction and not crystal_collected:
		_collect_crystal()

func _talk_to_scout() -> void:
	if scout_dialogue_stage == 0:
		scout_dialogue_stage = 1
		status.text = "边境探子·柳朔：雾潮会随着时辰退涨。若想深入北面的雾林，至少要先稳住筑基根基；盲目闯入只会被雾路带偏。"
		prompt.text = "[E] 再问柳朔"
	else:
		status.text = "柳朔：晶簇是雾潮留下的稳定锚点。采集能带来材料与修为，但真正的秘境入口会在筑基后才对你显现。"

func _collect_crystal() -> void:
	crystal_collected = true
	$MistTideCrystal.visible = false
	crystal_interaction.set_deferred("monitoring", false)
	GameState.add_item("雾潮晶簇")
	GameState.gain_cultivation(8)
	status.text = "获得雾潮晶簇：这是边境生态资源，可用于后续炼器、阵法和筑基区域的雾潮探索。修为 +8。"
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_village() -> void:
	GameState.current_region_id = "starter_village"
	get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
