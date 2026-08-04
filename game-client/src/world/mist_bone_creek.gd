class_name MistBoneCreek
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $CreekwayArch/Interaction
@onready var opportunity_interaction: Area2D = $CreekHeartOpportunity/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var opportunity_collected := false
var chosen_opportunity: Dictionary = {}

const CREEK_OPPORTUNITIES := [
	{"name": "溪心灵晶", "item": "溪心灵晶", "cultivation": 6, "description": "水系功法可借其调息，阵修也能将它作为微型阵眼。"},
	{"name": "骨纹苔", "item": "骨纹苔", "cultivation": 8, "description": "湿润石缝中的灵苔，可作为炼丹与护脉药材。"},
	{"name": "岚息回响", "item": "雾骨溪感悟", "cultivation": 14, "description": "并非任务奖励，只是一段被溪雾放大的个人感悟。"},
]

func _ready() -> void:
	GameState.current_region_id = "mist_bone_creek"
	player.map_bounds = Rect2(80, 80, 2920, 1850)
	player.position = Vector2(1450, 1510)
	chosen_opportunity = CREEK_OPPORTUNITIES.pick_random().duplicate()
	$CreekHeartOpportunity/Name.text = str(chosen_opportunity.name)
	status.text = "雾骨溪（炼气三层）：这是一处自由探索的溪谷。沿水路、石台或雾中空地行动都可能发现不同线索；无强制任务。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	opportunity_interaction.focused.connect(_focus_interaction)
	opportunity_interaction.unfocused.connect(_unfocus_interaction)
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_border()

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
		_return_to_border()
	elif active_interaction == opportunity_interaction and not opportunity_collected:
		_collect_opportunity()

func _collect_opportunity() -> void:
	opportunity_collected = true
	$CreekHeartOpportunity.visible = false
	opportunity_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(chosen_opportunity.item))
	GameState.gain_cultivation(int(chosen_opportunity.cultivation))
	GameState.record_opportunity({
		"region": "mist_bone_creek",
		"name": chosen_opportunity.name,
		"item": chosen_opportunity.item,
		"cultivation": chosen_opportunity.cultivation,
	})
	status.text = "你在溪畔发现了%s：%s 修为 +%d。它属于开放世界机缘，不会要求你继续任何任务。" % [chosen_opportunity.name, chosen_opportunity.description, chosen_opportunity.cultivation]
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_border() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
