class_name YunlanOutskirts
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")

@onready var player: CharacterBody2D = $Player
@onready var village_gate: Area2D = $YunlanVillageGate/Interaction
@onready var mist_border_gate: Area2D = $MistBorderPass/Interaction
@onready var echo_stone: Area2D = $LanEchoStone/Interaction
@onready var regional_population = $RegionalPopulation
@onready var chunk_streamer = $ChunkStreamer
@onready var world_encounter = $WorldCombat
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var echo_stone_observed := false
var current_sector_id := ""


func _ready() -> void:
	GameState.current_region_id = "starter_village"
	player.map_bounds = Rect2(80, 80, 11840, 7840)
	player.position = Vector2(860, 1680)
	_setup_environment_depth()
	_setup_world_minimap()
	chunk_streamer.configure(player, [
		{"id": "south_gate_fields", "node": $SouthGateChunk, "bounds": Rect2(0, 0, 3072, 2048)},
	])
	status.text = "云岚外野：云岚村只是第一处聚落。沿灵田、雾溪、云麓疏林与旧商道自由探索；资源和人物只会出现在合适地形。"
	for interaction in [village_gate, mist_border_gate, echo_stone]:
		interaction.focused.connect(_focus_interaction)
		interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)


func _setup_environment_depth() -> void:
	var depth_layer: RegionalEnvironmentDepthLayer = RegionalEnvironmentDepthLayerScript.new()
	depth_layer.name = "EnvironmentDepthLayer"
	depth_layer.region_style = "yunlan_outskirts"
	add_child(depth_layer)


func _setup_world_minimap() -> void:
	var minimap: WorldMinimap = WorldMinimapScript.new()
	minimap.name = "WorldMinimap"
	$HUD.add_child(minimap)
	minimap.configure_region(player, player.map_bounds, "云岚外野", [
		{"position": Vector2(760, 1440), "kind": "gate"},
		{"position": Vector2(3520, 720), "kind": "resource"},
		{"position": Vector2(5840, 1700), "kind": "dungeon"},
		{"position": Vector2(7720, 1500), "kind": "relic"},
		{"position": Vector2(11000, 1650), "kind": "gate"},
	], [
		PackedVector2Array([Vector2(760, 1440), Vector2(2780, 1660), Vector2(5140, 1770), Vector2(7720, 1500), Vector2(11000, 1650)]),
		PackedVector2Array([Vector2(2780, 1660), Vector2(2420, 2960), Vector2(3180, 3600)]),
		PackedVector2Array([Vector2(5140, 1770), Vector2(6760, 3600), Vector2(8720, 4560)]),
	])


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode >= KEY_1 and event.keycode <= KEY_5:
		world_encounter.use_action(["attack", "ningxi", "cloud_step", "guard", "nourish"][event.keycode - KEY_1])
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _process(_delta: float) -> void:
	var sector := RegionalSectorCatalogScript.sector_at("yunlan_outskirts", player.position)
	var sector_id := str(sector.get("id", ""))
	if sector_id.is_empty() or sector_id == current_sector_id:
		return
	current_sector_id = sector_id
	if active_interaction == null:
		status.text = "进入%s：%s" % [str(sector.get("name", "云岚外野")), str(sector.get("description", ""))]


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
	else:
		world_encounter.use_action(action_id)


func _activate_contextual() -> void:
	if active_interaction == village_gate:
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
	elif active_interaction == mist_border_gate:
		_enter_mist_border()
	elif active_interaction == echo_stone and not echo_stone_observed:
		_observe_lan_echo()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()


func _enter_mist_border() -> void:
	if not GameState.is_region_unlocked("mist_border"):
		status.text = "旧商道尽头的雾潮仍不稳定。炼气一层后可在云岚村进入雾溪水府试探；完成一次水府探索后，边境旧关才会常年开放。"
		return
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")


func _observe_lan_echo() -> void:
	echo_stone_observed = true
	echo_stone.set_deferred("monitoring", false)
	GameState.add_item("岚息石屑")
	GameState.gain_cultivation(3)
	GameState.record_opportunity({"region": "starter_village", "name": "岚息回响石", "kind": "highland_landmark", "item": "岚息石屑"})
	status.text = "风从石缝掠过，留下短促的岚息回响。你获得岚息石屑，修为 +3。它是丘陵里一处固定远望点，不会被复制成遍地奖励。"
	_close_interaction()


func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 1327


func _population_profiles() -> Array[Dictionary]:
	return [
		{
			"id": "yunlan_bank_herb", "region": "yunlan_outskirts", "sector": "mist_stream_banks", "kind": "resource", "name": "雾溪灵草丛",
			"prompt": "在雾溪石岸采集低阶灵草", "chance": 0.72,
			"anchors": [Vector2(3140, 620), Vector2(3560, 770), Vector2(4020, 660)],
			"reward": "雾溪灵草", "cultivation": 2, "tint": Color(0.82, 1.0, 0.76), "label_color": Color(0.86, 1.0, 0.78),
		},
		{
			"id": "yunlan_cloudfoot_rogue", "region": "yunlan_outskirts", "sector": "cloudfoot_wood", "kind": "rogue", "name": "采药散修",
			"prompt": "向采药散修询问云麓疏林", "chance": 0.46,
			"anchors": [Vector2(5320, 1680), Vector2(5900, 2050), Vector2(6460, 1760)],
			"tint": Color(0.82, 0.92, 0.72), "label_color": Color(0.90, 0.98, 0.74),
		},
		{
			"id": "yunlan_oldroad_bandit", "region": "yunlan_outskirts", "sector": "old_caravan_road", "kind": "bandit", "name": "旧道劫修",
			"prompt": "旧商道旁有劫修拦路", "chance": 0.36,
			"anchors": [Vector2(8760, 1540), Vector2(9440, 1660), Vector2(10120, 1480)],
			"health": 48, "damage": 5, "reward": "旧道行囊", "cultivation": 3, "tint": Color(0.88, 0.70, 0.66), "label_color": Color(1.0, 0.76, 0.68),
		},
		{
			"id": "yunlan_stonebud", "region": "yunlan_outskirts", "sector": "stonebud_highland", "kind": "resource", "name": "背风石芽",
			"prompt": "在背风岩隙采集石芽", "chance": 0.34,
			"anchors": [Vector2(1280, 3520), Vector2(2140, 3880), Vector2(3160, 3520)],
			"reward": "云岚石芽", "cultivation": 2, "tint": Color(0.82, 0.94, 0.86), "label_color": Color(0.88, 1.0, 0.90),
		},
	]


func _on_population_resolved(summary: String) -> void:
	status.text = summary


func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)
