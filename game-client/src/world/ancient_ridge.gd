class_name AncientRidge
extends Node2D

const RIDGE_EVENTS := [
	{"name": "地火余温", "item": "赤焰精金", "cultivation": 22, "description": "地火裂缝退去后，岩层露出可炼器的精金。"},
	{"name": "残阵兵魄", "item": "古战印", "cultivation": 19, "description": "古战场残阵还保留着一段行军与布阵之法。"},
	{"name": "断岭风痕", "item": "破风石片", "cultivation": 20, "description": "峡谷长风在断崖刻下遁空前的身法痕迹。"},
]

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $TerraceExit/Interaction
@onready var relic_interaction: Area2D = $ObservationPlinth/Interaction
@onready var event_interaction: Area2D = $AbyssSign/Interaction
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

func _ready() -> void:
	GameState.current_region_id = "ancient_ridge"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(460, 1660)
	chunk_streamer.configure(player, [{"id": "ancient_ridge_earthfire", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)}])
	ridge_event = RIDGE_EVENTS.pick_random().duplicate()
	$AbyssSign/Name.text = str(ridge_event.name)
	$TerraceExit/Name.text = "古脊关道 · 返回雾潮边境"
	$ObservationPlinth/Name.text = "古战遗址 · 高阶探索"
	$HUD/Title.text = "古脊岭 · 元婴以上山脉探索"
	status.text = "古脊岭是首发第三大区的起始地火裂谷。高阶资源、遗迹与势力冲突会在同一张大地图继续向山脉深处延展。"
	for interaction in [return_interaction, relic_interaction, event_interaction]:
		interaction.focused.connect(_focus_interaction)
		interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
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

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 114513

func _population_profiles() -> Array[Dictionary]:
	return [
		{"id": "earthfire_hound", "region": "ancient_ridge", "kind": "beast", "name": "地火岩獒", "prompt": "观察地火岩獒的裂谷领地", "chance": 0.60, "anchors": [Vector2(2480, 780), Vector2(2680, 890)], "health": 175, "damage": 22, "reward": "地火兽核", "cultivation": 24, "tint": Color(1.0, 0.65, 0.42), "label_color": Color(1.0, 0.75, 0.48)},
		{"id": "relic_seeker", "region": "ancient_ridge", "kind": "rogue", "name": "寻古散修", "prompt": "询问寻古散修的遗址判断", "chance": 0.36, "anchors": [Vector2(1300, 790), Vector2(1440, 870)], "tint": Color(0.76, 0.72, 0.90), "label_color": Color(0.84, 0.80, 1.0)},
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
