extends Node2D

const WORLD_SIZE := Vector2(4096.0, 2304.0)
## This compact compatibility/demo map is not the shipped large-region entry.
## It must never revive the former mandatory beginner chain.
const LEGACY_TUTORIAL_GATE_ENABLED := false
const Catalog = preload("res://src/data/game_catalog.gd")
const WorldMarkerScript = preload("res://src/world/world_marker.gd")

@onready var map_canvas: Node2D = $MapCanvas
@onready var yunlan_art: Sprite2D = $YunlanVillageBaseArt
@onready var player: CharacterBody2D = $Player
@onready var interactables: Node2D = $Interactables
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var region_label: Label = $HUD/RegionLabel

var active_marker
var collected_markers: Dictionary = {}
var tutorial_stage := 0

func _ready() -> void:
	map_canvas.configure(GameState.current_region_id)
	yunlan_art.visible = GameState.current_region_id == "starter_village"
	player.map_bounds = Rect2(Vector2(64, 64), WORLD_SIZE - Vector2(128, 128))
	player.position = _spawn_position()
	region_label.text = _region_title()
	status.text = "第一章·雾潮初起：前往云岚村，向引路人沈衍问询。"
	prompt.text = ""
	_build_markers()
	status.text = "云岚旧图演示：资源、人物、秘境与关隘可按自己的顺序接触；它不会要求先完成某条新手任务。"

func _build_markers() -> void:
	for data in _region_markers():
		var marker = WorldMarkerScript.new()
		interactables.add_child(marker)
		marker.setup(data)
		marker.body_entered.connect(func(body: Node2D): _on_marker_entered(marker, body))
		marker.body_exited.connect(func(body: Node2D): _on_marker_exited(marker, body))

func _region_markers() -> Array[Dictionary]:
	match GameState.current_region_id:
		"mist_border":
			return [
				{"id": "mist_ore", "title": "雾铁矿脉", "kind": "resource", "position": Vector2(1450, 980)},
				{"id": "border_scout", "title": "边境斥候", "kind": "npc", "position": Vector2(2380, 1050)},
				{"id": "return_village", "title": "关隘：云岚村", "kind": "gate", "payload": "starter_village", "position": Vector2(310, 1710)},
				{"id": "ridge_gate", "title": "关隘：古脊岭", "kind": "gate", "payload": "ancient_ridge", "position": Vector2(3820, 590)},
			]
		"ancient_ridge":
			return [
				{"id": "ancient_relic", "title": "古脊遗物", "kind": "resource", "position": Vector2(1630, 700)},
				{"id": "ruin_keeper", "title": "遗迹守望者", "kind": "npc", "position": Vector2(2580, 1120)},
				{"id": "return_border", "title": "关隘：雾隐边境", "kind": "gate", "payload": "mist_border", "position": Vector2(310, 1710)},
			]
		_:
			return [
				{"id": "mist_herb", "title": "雾溪灵草", "kind": "resource", "position": Vector2(1450, 1380)},
				{"id": "village_guide", "title": "引路人·沈衍", "kind": "npc", "position": Vector2(1080, 1220)},
				{"id": "water_palace", "title": "雾溪水府", "kind": "dungeon", "payload": "mist_stream_palace", "position": Vector2(3560, 560)},
				{"id": "border_gate", "title": "关隘：雾隐边境", "kind": "gate", "payload": "mist_border", "position": Vector2(3820, 1860)},
			]

func _on_marker_entered(marker, body: Node2D) -> void:
	if body != player or collected_markers.has(marker.marker_id):
		return
	active_marker = marker
	prompt.text = "[E] " + _interaction_text(marker)

func _on_marker_exited(marker, body: Node2D) -> void:
	if body == player and active_marker == marker:
		active_marker = null
		prompt.text = ""

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_marker()
	elif event.keycode == KEY_H or event.keycode == KEY_ESCAPE:
		_return_to_framework()

func _activate_marker() -> void:
	if active_marker == null:
		return
	match active_marker.kind:
		"resource":
			collected_markers[active_marker.marker_id] = true
			active_marker.visible = false
			GameState.add_item(active_marker.title)
			GameState.gain_cultivation(5)
			if active_marker.marker_id == "mist_herb" and tutorial_stage >= 1:
				tutorial_stage = 2
				status.text = "你采得雾溪灵草。沈衍感知到其中的潮息：可前往雾溪水府一探。"
			else:
				status.text = "获得%s。资源、修行与大世界探索已开始联动。" % active_marker.title
			prompt.text = ""
			active_marker = null
		"npc":
			_play_npc_story(active_marker.marker_id)
		"gate":
			GameState.current_region_id = active_marker.payload
			get_tree().reload_current_scene()
		"dungeon":
			if LEGACY_TUTORIAL_GATE_ENABLED and active_marker.marker_id == "water_palace" and tutorial_stage < 2:
				status.text = "水府潮息暂未认可你。先向沈衍问询，再采集一株雾溪灵草。"
				return
			if not GameState.try_begin_fixed_dungeon(str(active_marker.payload)):
				status.text = GameState.fixed_dungeon_entry_block_text()
				return
			GameState.selected_dungeon_id = active_marker.payload
			get_tree().change_scene_to_file("res://scenes/mist_stream_water_palace.tscn")

func _interaction_text(marker) -> String:
	match marker.kind:
		"resource": return "Gather " + marker.title
		"npc": return "Talk to " + marker.title
		"gate": return "Travel through " + marker.title
		"dungeon": return "Enter " + marker.title
	return "Interact"

func _play_npc_story(marker_id: String) -> void:
	if marker_id != "village_guide":
		status.text = "道路仍然敞开。你选择追寻什么，大世界便会留下什么回应。"
		return
	var first_meeting := GameState.meet_npc("沈衍")
	var personal_reflection := GameState.npc_personal_reflection("沈衍")
	var lived_contexts := GameState.record_npc_lived_contexts("沈衍")
	status.text = "沈衍：岚息会在山风、水汽、地脉与人间活动相交的地方留下痕迹。旧图里的水府只是可自行进入的地点之一，不会替你规定先后。"
	if not personal_reflection.is_empty():
		status.text += "\n【你的见闻】%s" % str(personal_reflection.get("description", ""))
	if not lived_contexts.is_empty():
		status.text += "\n【实际游历】%s" % str(lived_contexts.back().get("description", ""))
	if first_meeting:
		status.text += "\n（沈衍已记入游历簿；这不是接取任务。）"
	return
	if tutorial_stage == 0:
		tutorial_stage = 1
		status.text = "沈衍：云岚近来雾潮渐起。你不必急着追逐唯一的命数；先认清自身灵根，再去村中药圃采一株雾溪灵草。"
	elif tutorial_stage == 1:
		status.text = "沈衍：药圃就在村中主路旁。带着灵草里的潮息，去雾溪水府的入口试一试。"
	else:
		status.text = "沈衍：灵草已回应你。雾溪水府便是你的第一场试炼；活着归来后，你可自由选择修行的道路。"

func _spawn_position() -> Vector2:
	return Vector2(360, 1710) if GameState.current_region_id != "starter_village" else Vector2(400, 1700)

func _region_title() -> String:
	for region in Catalog.REGIONS:
		if region.id == GameState.current_region_id:
			return "%s  |  开放世界原型" % region.name
	return "云岚村  |  开放世界原型"

func _return_to_framework() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
