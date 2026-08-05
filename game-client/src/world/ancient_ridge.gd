class_name AncientRidge
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")

const RIDGE_EVENTS := [
	{"name": "地火余温", "item": "赤焰精金", "cultivation": 22, "description": "地火裂缝退去后，岩层露出可炼器的精金。"},
	{"name": "残阵兵魄", "item": "古战印", "cultivation": 19, "description": "古战场残阵还保留着一段行军与布阵之法。"},
	{"name": "断岭风痕", "item": "破风石片", "cultivation": 20, "description": "峡谷长风在断崖刻下遁空前的身法痕迹。"},
]

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $TerraceExit/Interaction
@onready var relic_interaction: Area2D = $ObservationPlinth/Interaction
@onready var event_interaction: Area2D = $AbyssSign/Interaction
@onready var earthfire_cave_interaction: Area2D = $EarthfireCave/Interaction
@onready var battlefield_memorial_interaction: Area2D = $BattlefieldMemorial/Interaction
@onready var regional_population = $RegionalPopulation
@onready var world_encounter = $WorldCombat
@onready var chunk_streamer = $ChunkStreamer
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var ridge_event: Dictionary = {}
var relic_examined := false
var event_resolved := false
var earthfire_cave_discovered := false
var battlefield_memorial_examined := false
var current_sector_id := ""

func _ready() -> void:
	GameState.current_region_id = "ancient_ridge"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(460, 1660)
	_setup_environment_depth()
	_setup_world_minimap()
	chunk_streamer.configure(player, [
		{"id": "ancient_ridge_earthfire", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
		{"id": "ancient_ridge_battlefield_pass", "node": $BattlefieldPassChunk, "bounds": Rect2(3072, 0, 3072, 2048)},
		{"id": "ancient_ridge_battlefield", "node": $AncientBattlefieldChunk, "bounds": Rect2(6144, 0, 3072, 2048)},
	])
	ridge_event = RIDGE_EVENTS.pick_random().duplicate()
	$AbyssSign/Name.text = str(ridge_event.name)
	$TerraceExit/Name.text = "古脊关道 · 返回雾潮边境"
	$ObservationPlinth/Name.text = "古战遗址 · 高阶探索"
	$HUD/Title.text = "古脊岭 · 元婴以上山脉探索"
	status.text = "古脊岭是首发第三大区的起始地火裂谷。高阶资源、遗迹与势力冲突会在同一张大地图继续向山脉深处延展。"
	for interaction in [return_interaction, relic_interaction, event_interaction, earthfire_cave_interaction, battlefield_memorial_interaction]:
		interaction.focused.connect(_focus_interaction)
		interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)


func _setup_world_minimap() -> void:
	var minimap: WorldMinimap = WorldMinimapScript.new()
	minimap.name = "WorldMinimap"
	$HUD.add_child(minimap)
	minimap.configure_region(player, player.map_bounds, "古脊岭", [
		{"position": Vector2(460, 1660), "kind": "gate"},
		{"position": Vector2(5750, 430), "kind": "dungeon"},
		{"position": Vector2(7320, 350), "kind": "relic"},
		{"position": Vector2(7480, 960), "kind": "relic"},
	], [
		PackedVector2Array([Vector2(460, 1660), Vector2(2600, 1220), Vector2(5750, 430)]),
		PackedVector2Array([Vector2(5750, 430), Vector2(6800, 620), Vector2(7320, 350), Vector2(7840, 920)]),
	])


func _setup_environment_depth() -> void:
	var depth_layer: RegionalEnvironmentDepthLayer = RegionalEnvironmentDepthLayerScript.new()
	depth_layer.name = "EnvironmentDepthLayer"
	depth_layer.region_style = "ancient_ridge"
	add_child(depth_layer)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_border()


func _process(_delta: float) -> void:
	_update_sector_presence()


func _update_sector_presence() -> void:
	var sector := RegionalSectorCatalogScript.sector_at("ancient_ridge", player.position)
	var sector_id := str(sector.get("id", ""))
	if sector_id.is_empty() or sector_id == current_sector_id:
		return
	current_sector_id = sector_id
	if active_interaction == null:
		status.text = "进入%s：%s" % [str(sector.get("name", "古脊岭")), str(sector.get("description", ""))]

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E / 互动] " + str(interaction.prompt_text)
	touch_controls.set_interaction_available(true)

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction == interaction:
		_close_interaction()

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()
	elif action_id == "attack":
		player.trigger_basic_attack()

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_border()
	elif active_interaction == earthfire_cave_interaction:
		_enter_earthfire_cave()
	elif active_interaction == battlefield_memorial_interaction and not battlefield_memorial_examined:
		_examine_battlefield_memorial()
	elif active_interaction == relic_interaction and not relic_examined:
		_examine_relic()
	elif active_interaction == event_interaction and not event_resolved:
		_resolve_event()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func _examine_relic() -> void:
	relic_examined = true
	GameState.record_opportunity({"region": "ancient_ridge", "name": "古脊战场遗址", "kind": "high_realm_lore"})
	status.text = "遗址残碑记载着高阶修士争夺山脉地火的旧事。这是自由探索线索，不是必须接取的任务。"
	_close_interaction()

func _resolve_event() -> void:
	event_resolved = true
	$AbyssSign.visible = false
	event_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(ridge_event.item))
	GameState.gain_cultivation(int(ridge_event.cultivation))
	GameState.record_opportunity({"region": "ancient_ridge", "name": ridge_event.name, "item": ridge_event.item, "cultivation": ridge_event.cultivation})
	status.text = "你捕捉到%s，获得%s。%s 修为 +%d。" % [ridge_event.name, ridge_event.item, ridge_event.description, ridge_event.cultivation]
	_close_interaction()

func _enter_earthfire_cave() -> void:
	GameState.selected_dungeon_id = "earth_fire"
	_discover_earthfire_cave()
	get_tree().change_scene_to_file("res://scenes/earthfire_cave.tscn")

func _discover_earthfire_cave() -> void:
	if not earthfire_cave_discovered:
		earthfire_cave_discovered = true
		GameState.record_opportunity({"region": "ancient_ridge", "name": "地火洞", "kind": "fixed_dungeon_entrance"})
		status.text = "地火洞已被记录为固定副本入口，正在进入地火灵兽的洞外战场。"
	else:
		status.text = "地火洞仍在前方。它是古脊岭内的固定副本入口，不会因随机机缘刷新而消失。"
	_close_interaction()

func _examine_battlefield_memorial() -> void:
	battlefield_memorial_examined = true
	GameState.add_item("残阵军策")
	GameState.gain_cultivation(26)
	GameState.record_opportunity({"region": "ancient_ridge", "name": "古战纪念台", "item": "残阵军策", "kind": "fixed_relic", "cultivation": 26})
	status.text = "纪念台碑文记录了古脊战场的阵势更迭。获得残阵军策，修为 +26；这是固定遗迹，不会随着随机生态消失。"
	_close_interaction()

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 114513

func _population_profiles() -> Array[Dictionary]:
	return [
		{"id": "earthfire_hound", "region": "ancient_ridge", "kind": "beast", "name": "地火岩獒", "prompt": "观察地火岩獒的裂谷领地", "chance": 0.60, "anchors": [Vector2(2480, 780), Vector2(2680, 890)], "health": 175, "damage": 22, "reward": "地火兽核", "cultivation": 24, "tint": Color(1.0, 0.65, 0.42), "label_color": Color(1.0, 0.75, 0.48)},
		{"id": "battlefield_remnant", "region": "ancient_ridge", "kind": "beast", "name": "战场残魂", "prompt": "感知古战场残魂的游荡范围", "chance": 0.46, "anchors": [Vector2(7400, 1080), Vector2(7840, 900)], "health": 190, "damage": 24, "reward": "残魂兵符", "cultivation": 25, "tint": Color(0.84, 0.63, 0.48), "label_color": Color(1.0, 0.78, 0.58)},
		{"id": "relic_seeker", "region": "ancient_ridge", "kind": "rogue", "name": "守碑散修", "prompt": "询问守碑散修的古战场判断", "chance": 0.36, "anchors": [Vector2(7200, 700), Vector2(7520, 770)], "tint": Color(0.76, 0.72, 0.90), "label_color": Color(0.84, 0.80, 1.0)},
	]

func _on_population_resolved(summary: String) -> void:
	status.text = summary

func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_border() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
