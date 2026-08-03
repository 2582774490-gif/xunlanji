class_name YunlanSouthGate
extends Node2D

@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var guide_interaction: Area2D = $GuideShen/Interaction
@onready var herb_interaction: Area2D = $MistHerb/Interaction

var active_interaction: Area2D
var guide_dialogue_stage := 0
var herb_collected := false

func _ready() -> void:
	status.text = "云岚村南门 · 空间场景重建：角色以脚底参与前后遮挡；门楼两侧有实体碰撞，中间可以通行。"
	guide_interaction.focused.connect(_focus_interaction)
	guide_interaction.unfocused.connect(_unfocus_interaction)
	herb_interaction.focused.connect(_focus_interaction)
	herb_interaction.unfocused.connect(_unfocus_interaction)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif event.keycode == KEY_E:
		_activate_interaction()

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E] " + str(interaction.get("prompt_text"))

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction != interaction:
		return
	active_interaction = null
	prompt.text = ""

func _activate_interaction() -> void:
	if active_interaction == null:
		return
	if str(active_interaction.get("interaction_id")) == "guide_shen":
		if guide_dialogue_stage == 0:
			guide_dialogue_stage = 1
			status.text = "沈衍：南门之外，雾潮近来常有异动。先沿溪路找一株雾溪灵草；你不必急于选定唯一的道途。"
			prompt.text = "[E] 再问沈衍"
		else:
			status.text = "沈衍：往南门东侧的溪路走。资源与机缘都在世界里，不在一张固定的任务清单里。"
	elif str(active_interaction.get("interaction_id")) == "mist_herb" and not herb_collected:
		herb_collected = true
		$MistHerb.visible = false
		GameState.add_item("雾溪灵草")
		GameState.gain_cultivation(5)
		status.text = "获得雾溪灵草：这是第一个可采集资源点。未来资源会在不同区域按生态、境界、天气与随机机缘刷新。"
		active_interaction = null
		prompt.text = ""
