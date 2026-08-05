class_name ThunderListeningCliff
extends Node2D

const THUNDER_WINDOWS := [
	{"name": "初雷照崖", "item": "雷纹符材", "cultivation": 11, "description": "第一道落雷过后，崖壁残留的雷纹最适合符修与雷灵根修士辨认。"},
	{"name": "风隙回响", "item": "御风残页", "cultivation": 13, "description": "断崖风口的回响暗合身法运息，任何流派都可尝试参悟。"},
	{"name": "雨后雷晶", "item": "微雷晶", "cultivation": 9, "description": "暴雨稍歇时，浅层岩缝会析出可交易的微雷晶。"},
]

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $CliffExit/Interaction
@onready var pavilion_interaction: Area2D = $LightningWardPavilion/Interaction
@onready var thunder_interaction: Area2D = $ThunderWindow/Interaction
@onready var regional_population = $RegionalPopulation
@onready var world_encounter = $WorldCombat
@onready var chunk_streamer = $ChunkStreamer
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var thunder_window: Dictionary = {}
var thunder_resolved := false
var pavilion_visited := false

func _ready() -> void:
	GameState.current_region_id = "thunder_listening_cliff"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(460, 1670)
	chunk_streamer.configure(player, [
		{"id": "thunder_cliff_west", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
	])
	thunder_window = THUNDER_WINDOWS.pick_random().duplicate()
	$ThunderWindow/Name.text = str(thunder_window.name)
	status.text = "听雷断崖（炼气七层）：雷暴窗口、避雷古亭与崖上生态彼此独立。可追逐雷机缘，也可只是借古道远行。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	pavilion_interaction.focused.connect(_focus_interaction)
	pavilion_interaction.unfocused.connect(_unfocus_interaction)
	thunder_interaction.focused.connect(_focus_interaction)
	thunder_interaction.unfocused.connect(_unfocus_interaction)
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
	if active_interaction != interaction:
		return
	_close_interaction()

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()
	elif action_id == "attack":
		player.trigger_basic_attack()

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_border()
	elif active_interaction == pavilion_interaction and not pavilion_visited:
		_visit_pavilion()
	elif active_interaction == thunder_interaction and not thunder_resolved:
		_resolve_thunder_window()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func _visit_pavilion() -> void:
	pavilion_visited = true
	GameState.record_opportunity({"region": "thunder_listening_cliff", "name": "避雷古亭", "kind": "shelter"})
	status.text = "避雷古亭的残阵仍在导走部分天雷。它提示你：天气机缘有窗口，不需要接取任务，也不必每次都冒险追逐。"
	_close_interaction()

func _resolve_thunder_window() -> void:
	thunder_resolved = true
	$ThunderWindow.visible = false
	thunder_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(thunder_window.item))
	GameState.gain_cultivation(int(thunder_window.cultivation))
	if str(thunder_window.get("item", "")) == "驭风残页":
		GameState.discover_technique("驭风游身诀", "听雷断崖的风隙回响")
	GameState.record_opportunity({"region": "thunder_listening_cliff", "name": thunder_window.name, "item": thunder_window.item, "cultivation": thunder_window.cultivation})
	status.text = "你抓住 %s：%s 获得 %s，修为 +%d。" % [thunder_window.name, thunder_window.description, thunder_window.item, thunder_window.cultivation]
	_close_interaction()

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 77031

func _population_profiles() -> Array[Dictionary]:
	return [
		{
			"id": "thunder_crag_beast", "region": "thunder_listening_cliff", "kind": "beast", "name": "引雷岩貂",
			"prompt": "观察引雷岩貂的雷晶巢", "chance": 0.64,
			"anchors": [Vector2(2100, 690), Vector2(2250, 760), Vector2(2400, 650)],
			"health": 94, "damage": 11, "reward": "引雷貂尾", "cultivation": 10,
			"tint": Color(0.72, 0.75, 1.0), "label_color": Color(0.78, 0.84, 1.0),
		},
		{
			"id": "storm_talisman_rogue", "region": "thunder_listening_cliff", "kind": "rogue", "name": "候雷符修",
			"prompt": "询问候雷符修的雷暴判断", "chance": 0.42,
			"anchors": [Vector2(1280, 840), Vector2(1410, 770)],
			"tint": Color(0.75, 0.72, 0.96), "label_color": Color(0.83, 0.78, 1.0),
		},
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
