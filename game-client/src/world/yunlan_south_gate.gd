class_name YunlanSouthGate
extends Node2D

@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var guide_interaction: Area2D = $GuideShen/Interaction
@onready var herb_interaction: Area2D = $MistHerb/Interaction
@onready var opportunity_interaction: Area2D = $MistStreamOpportunity/Interaction
@onready var opportunity_name: Label = $MistStreamOpportunity/Name
@onready var player: CharacterBody2D = $Player
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var guide_dialogue_stage := 0
var herb_collected := false
var opportunity_collected := false
var chosen_opportunity: Dictionary = {}

const OPPORTUNITIES := [
	{
		"id": "mist_cache",
		"title": "雾溪遗匣",
		"prompt": "探查雾溪遗匣",
		"item": "遗匣灵石袋",
		"stones": 14,
		"cultivation": 2,
		"story_trace": "water",
		"summary": "石缝中的旧匣仍存一缕灵息。"
	},
	{
		"id": "lan_echo",
		"title": "岚息残痕",
		"prompt": "感悟岚息残痕",
		"item": "岚息残页",
		"stones": 0,
		"cultivation": 9,
		"story_trace": "water",
		"summary": "淡青雾痕随吐纳而散，留下短暂感悟。"
	},
	{
		"id": "dew_bloom",
		"title": "雾灵露华",
		"prompt": "采集雾灵露华",
		"item": "雾灵露",
		"stones": 5,
		"cultivation": 4,
		"story_trace": "water",
		"summary": "夜雾凝成露华，是低境修士也能承受的温和灵材。"
	}
]

func _ready() -> void:
	status.text = "云岚村南门：角色以脚底参与前后遮挡；门楼两侧有实体碰撞，中间可以通行。"
	chosen_opportunity = OPPORTUNITIES.pick_random().duplicate()
	opportunity_name.text = str(chosen_opportunity.title)
	opportunity_interaction.prompt_text = str(chosen_opportunity.prompt)
	guide_interaction.focused.connect(_focus_interaction)
	guide_interaction.unfocused.connect(_unfocus_interaction)
	herb_interaction.focused.connect(_focus_interaction)
	herb_interaction.unfocused.connect(_unfocus_interaction)
	opportunity_interaction.focused.connect(_focus_interaction)
	opportunity_interaction.unfocused.connect(_unfocus_interaction)
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _process(_delta: float) -> void:
	if active_interaction == null and player.position.y < 430.0:
		prompt.text = "[E / 交互] 进入云岚村心"
		touch_controls.set_interaction_available(true)
	elif active_interaction == null:
		prompt.text = ""
		touch_controls.set_interaction_available(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif event.keycode == KEY_E:
		_activate_contextual()

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E / 交互] " + str(interaction.get("prompt_text"))
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
	if active_interaction == null and player.position.y < 430.0:
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
		return
	_activate_interaction()

func _activate_interaction() -> void:
	if active_interaction == null:
		return
	var interaction_id := str(active_interaction.get("interaction_id"))
	if interaction_id == "guide_shen":
		var first_meeting := GameState.meet_npc("沈衍")
		var personal_reflection := GameState.npc_personal_reflection("沈衍")
		if guide_dialogue_stage == 0:
			guide_dialogue_stage = 1
			GameState.complete_world_guidance_step("lan_breath")
			status.text = "沈衍：岚息是山风、水汽与灵机交汇的可感之息。南门之外雾潮有异动；沿溪路找一株雾溪灵草即可。你不必急于选定唯一的道途。"
			prompt.text = "[E] 再问沈衍"
			status.text = "沈衍：岚息是山风、水汽与灵机交汇的可感之息。南门之外的溪路、坡地与雾线都可自行观察；采药、试武、入村、行商或直接远游都不会错过唯一的道路。"
			if not personal_reflection.is_empty():
				status.text += "\n【你的见闻】%s" % str(personal_reflection.get("description", ""))
			if first_meeting:
				status.text += "\n（沈衍已记入万物图鉴与游历簿；这只是一段世界认识，不是必须完成的任务。）"
		else:
			status.text = "沈衍：往南门东侧的溪路走。资源与机缘都在世界里，不在一张固定的任务清单里。"
	elif interaction_id == "mist_herb" and not herb_collected:
		herb_collected = true
		$MistHerb.visible = false
		GameState.add_item("雾溪灵草")
		GameState.gain_cultivation(5)
		GameState.complete_world_guidance_step("resource_ecology")
		GameState.record_opportunity({"region": "starter_village", "name": "雾溪灵草", "kind": "resource", "item": "雾溪灵草", "cultivation": 5, "story_trace": "water"})
		status.text = "获得雾溪灵草：这是第一个可采集资源点。未来资源会在不同区域按生态、境界、天气与随机机缘刷新；不需要接取固定任务才可采集。"
		active_interaction = null
		prompt.text = ""
		touch_controls.set_interaction_available(false)
	elif interaction_id == "mist_stream_opportunity" and not opportunity_collected:
		_collect_random_opportunity()

func _collect_random_opportunity() -> void:
	opportunity_collected = true
	$MistStreamOpportunity.visible = false
	opportunity_interaction.set_deferred("monitoring", false)
	var item_name := str(chosen_opportunity.item)
	var stones := int(chosen_opportunity.stones)
	var cultivation := int(chosen_opportunity.cultivation)
	GameState.add_item(item_name)
	if stones > 0:
		GameState.add_spirit_stones(stones)
	if cultivation > 0:
		GameState.gain_cultivation(cultivation)
	GameState.record_opportunity({
		"id": chosen_opportunity.id,
		"title": chosen_opportunity.title,
		"item": item_name,
		"spirit_stones": stones,
		"cultivation": cultivation,
		"story_trace": str(chosen_opportunity.get("story_trace", "")),
	})
	var rewards := "获得 %s" % item_name
	if stones > 0:
		rewards += "、灵石 +%d" % stones
	if cultivation > 0:
		rewards += "、修为 +%d" % cultivation
	status.text = "%s %s" % [str(chosen_opportunity.summary), rewards]
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)
