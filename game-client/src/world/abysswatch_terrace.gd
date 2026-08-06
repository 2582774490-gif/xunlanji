class_name AbysswatchTerrace
extends Node2D

const TERRACE_SIGNS := [
	{"name": "临渊静观", "item": "临渊露", "cultivation": 15, "description": "云雾在崖沿凝成露珠，适合筑基前温养气海。"},
	{"name": "风碑回响", "item": "御崖石屑", "cultivation": 13, "description": "旧碑被山风敲响，留下一段可自由参悟的身法节奏。"},
	{"name": "护台残阵", "item": "护脉阵片", "cultivation": 17, "description": "残阵仍守着高台一角，阵纹能用于后续护脉准备。"},
]

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $TerraceExit/Interaction
@onready var observation_interaction: Area2D = $ObservationPlinth/Interaction
@onready var sign_interaction: Area2D = $AbyssSign/Interaction
@onready var regional_population = $RegionalPopulation
@onready var world_encounter = $WorldCombat
@onready var chunk_streamer = $ChunkStreamer
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var terrace_sign: Dictionary = {}
var observation_complete := false
var sign_resolved := false

func _ready() -> void:
	GameState.current_region_id = "abysswatch_terrace"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(460, 1660)
	chunk_streamer.configure(player, [{"id": "abysswatch_west", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)}])
	terrace_sign = TERRACE_SIGNS.pick_random().duplicate()
	$AbyssSign/Name.text = str(terrace_sign.name)
	status.text = "临渊台（炼气九层）：高台、观想位与崖缘机缘彼此独立。它为筑基前准备提供线索，但不会自动替你突破。"
	for interaction in [return_interaction, observation_interaction, sign_interaction]:
		interaction.focused.connect(_focus_interaction)
		interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if event.keycode >= KEY_1 and event.keycode <= KEY_5:
		world_encounter.use_action(["attack", "ningxi", "cloud_step", "guard", "nourish"][event.keycode - KEY_1])
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_E: _activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H: _return_to_border()

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E / 互动] " + str(interaction.prompt_text)
	touch_controls.set_interaction_available(true)

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction == interaction: _close_interaction()

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact": _activate_contextual()
	else: world_encounter.use_action(action_id)

func _activate_contextual() -> void:
	if active_interaction == return_interaction: _return_to_border()
	elif active_interaction == observation_interaction and not observation_complete: _observe_terrace()
	elif active_interaction == sign_interaction and not sign_resolved: _resolve_sign()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func _observe_terrace() -> void:
	observation_complete = true
	GameState.record_opportunity({"region": "abysswatch_terrace", "name": "临渊观想台", "kind": "foundation_preparation"})
	status.text = "观想台只让你梳理冲关前的准备：丹药、护脉材料与时机仍由你自行决定。高阶境界不会被这一次互动自动跳过。"
	_close_interaction()

func _resolve_sign() -> void:
	sign_resolved = true
	$AbyssSign.visible = false
	sign_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(terrace_sign.item))
	GameState.gain_cultivation(int(terrace_sign.cultivation))
	GameState.record_opportunity({"region": "abysswatch_terrace", "name": terrace_sign.name, "item": terrace_sign.item, "cultivation": terrace_sign.cultivation})
	status.text = "你参悟%s，获得%s。%s 修为 +%d。" % [terrace_sign.name, terrace_sign.item, terrace_sign.description, terrace_sign.cultivation]
	_close_interaction()

func _population_seed() -> int: return int(Time.get_unix_time_from_system() / 180.0) + 99119

func _population_profiles() -> Array[Dictionary]:
	return [
		{"id":"terrace_wind_eagle","region":"abysswatch_terrace","kind":"beast","name":"裂风岩隼","prompt":"观察裂风岩隼的崖缘领地","chance":0.58,"anchors":[Vector2(2430,720),Vector2(2630,820)],"health":124,"damage":15,"reward":"裂风翎羽","cultivation":15,"tint":Color(0.72,0.78,0.92),"label_color":Color(0.78,0.86,1.0)},
		{"id":"terrace_observer","region":"abysswatch_terrace","kind":"rogue","name":"守台散修","prompt":"询问守台散修的护脉经验","chance":0.40,"anchors":[Vector2(1280,820),Vector2(1430,750)],"tint":Color(0.88,0.76,0.58),"label_color":Color(1.0,0.86,0.64)},
	]

func _on_population_resolved(summary: String) -> void: status.text = summary
func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)
func _return_to_border() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
