extends Node2D

const WORLD_SIZE := Vector2(4096.0, 2304.0)
const Catalog = preload("res://src/data/game_catalog.gd")
const WorldMarkerScript = preload("res://src/world/world_marker.gd")

@onready var map_canvas: Node2D = $MapCanvas
@onready var player: CharacterBody2D = $Player
@onready var interactables: Node2D = $Interactables
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var region_label: Label = $HUD/RegionLabel

var active_marker
var collected_markers: Dictionary = {}

func _ready() -> void:
	map_canvas.configure(GameState.current_region_id)
	player.map_bounds = Rect2(Vector2(64, 64), WORLD_SIZE - Vector2(128, 128))
	player.position = _spawn_position()
	region_label.text = _region_title()
	status.text = "Explore the full region. Follow roads, find resources and NPCs, then enter the Water Palace."
	prompt.text = ""
	_build_markers()

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
				{"id": "mist_ore", "title": "Mist Iron Vein", "kind": "resource", "position": Vector2(1450, 980)},
				{"id": "border_scout", "title": "Border Scout", "kind": "npc", "position": Vector2(2380, 1050)},
				{"id": "return_village", "title": "Gate: Yunlan Village", "kind": "gate", "payload": "starter_village", "position": Vector2(310, 1710)},
				{"id": "ridge_gate", "title": "Gate: Ancient Ridge", "kind": "gate", "payload": "ancient_ridge", "position": Vector2(3820, 590)},
			]
		"ancient_ridge":
			return [
				{"id": "ancient_relic", "title": "Ancient Relic", "kind": "resource", "position": Vector2(1630, 700)},
				{"id": "ruin_keeper", "title": "Ruin Keeper", "kind": "npc", "position": Vector2(2580, 1120)},
				{"id": "return_border", "title": "Gate: Mist Border", "kind": "gate", "payload": "mist_border", "position": Vector2(310, 1710)},
			]
		_:
			return [
				{"id": "mist_herb", "title": "Mist-Stream Herb", "kind": "resource", "position": Vector2(1450, 1380)},
				{"id": "village_guide", "title": "Sect Guide Shen Yan", "kind": "npc", "position": Vector2(1080, 1220)},
				{"id": "water_palace", "title": "Mist-Stream Water Palace", "kind": "dungeon", "payload": "mist_stream_palace", "position": Vector2(3560, 560)},
				{"id": "border_gate", "title": "Gate: Mist Border", "kind": "gate", "payload": "mist_border", "position": Vector2(3820, 1860)},
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
			status.text = "Collected %s. Resources and cultivation are now linked to the world map." % active_marker.title
			prompt.text = ""
			active_marker = null
		"npc":
			status.text = "%s: The roads and gates are open. Your choices decide which opportunities you pursue." % active_marker.title
		"gate":
			GameState.current_region_id = active_marker.payload
			get_tree().reload_current_scene()
		"dungeon":
			GameState.selected_dungeon_id = active_marker.payload
			get_tree().change_scene_to_file("res://scenes/mist_stream_water_palace.tscn")

func _interaction_text(marker) -> String:
	match marker.kind:
		"resource": return "Gather " + marker.title
		"npc": return "Talk to " + marker.title
		"gate": return "Travel through " + marker.title
		"dungeon": return "Enter " + marker.title
	return "Interact"

func _spawn_position() -> Vector2:
	return Vector2(360, 1710) if GameState.current_region_id != "starter_village" else Vector2(400, 1700)

func _region_title() -> String:
	for region in Catalog.REGIONS:
		if region.id == GameState.current_region_id:
			return "%s  |  large-world prototype" % region.name
	return "Yunlan Village  |  large-world prototype"

func _return_to_framework() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
