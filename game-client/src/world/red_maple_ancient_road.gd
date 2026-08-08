class_name RedMapleAncientRoad
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $RoadExit/Interaction
@onready var merchant_interaction: Area2D = $MerchantLuoQing/Interaction
@onready var ledger_interaction: Area2D = $CaravanLedger/Interaction
@onready var escort_interaction: Area2D = $EscortBeacon/Interaction
@onready var event_interaction: Area2D = $RoadEvent/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls
@onready var regional_population = $RegionalPopulation
@onready var world_encounter = $WorldCombat
@onready var chunk_streamer = $ChunkStreamer

var active_interaction: Area2D
var event_resolved := false
var escort_resolved := false
var route_event: Dictionary = {}

const ROAD_EVENTS := [
	{"name": "枫影石函", "item": "枫影石函", "cultivation": 12, "description": "石函里残留着一段未知修士的行路感悟。"},
	{"name": "断桥灵风", "item": "风痕符材", "cultivation": 10, "description": "断桥上掠过的灵风能被符修、风修或商人收集。"},
	{"name": "古道药篓", "item": "赤枫药材", "cultivation": 8, "description": "遗落药篓尚有可用灵材，适合炼丹或交易。"},
]

func _ready() -> void:
	GameState.current_region_id = "red_maple_ancient_road"
	# Red Maple Road is a long trade corridor. Its first painted chunk is only
	# the western entrance; the playable regional space continues eastward.
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(1490, 1710)
	chunk_streamer.configure(player, [
		{"id": "red_maple_western_road", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
		{"id": "red_maple_broken_bridge", "node": $BrokenBridgeEmberRidgeChunk, "bounds": Rect2(3072, 0, 3072, 2048)},
	])
	route_event = ROAD_EVENTS.pick_random().duplicate()
	$RoadEvent/Name.text = str(route_event.name)
	status.text = "赤枫古道（炼气六层）：商路、岔道与偶遇互相独立。你可交易、帮商队护路、寻找机缘，或只当作通往远方的道路。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	merchant_interaction.focused.connect(_focus_interaction)
	merchant_interaction.unfocused.connect(_unfocus_interaction)
	ledger_interaction.focused.connect(_focus_interaction)
	ledger_interaction.unfocused.connect(_unfocus_interaction)
	escort_interaction.focused.connect(_focus_interaction)
	escort_interaction.unfocused.connect(_unfocus_interaction)
	event_interaction.focused.connect(_focus_interaction)
	event_interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)

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
	else:
		world_encounter.use_action(action_id)

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_border()
	elif active_interaction == merchant_interaction:
		_talk_to_merchant()
	elif active_interaction == ledger_interaction:
		_buy_caravan_goods()
	elif active_interaction == escort_interaction and not escort_resolved:
		_support_caravan()
	elif active_interaction == event_interaction and not event_resolved:
		_resolve_road_event()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 9317

func _population_profiles() -> Array[Dictionary]:
	# The road is not populated uniformly. Traders stay at the route fork,
	# bandits prefer the narrow eastern cut, and fire-aligned beasts gather only
	# around the dry ridge and old kiln remains.
	return [
		{
			"id": "caravan_scout", "region": "red_maple_ancient_road", "kind": "merchant", "name": "商队斥候",
			"prompt": "询问商队斥候的前路", "chance": 0.70,
			"anchors": [Vector2(1740, 790), Vector2(1840, 880), Vector2(1950, 740)],
			"story_trace": "road", "story_note": "商队斥候标出的安全岔路每逢雾潮都会偏移半里，像有一条看不见的旧道正在重叠。",
			"tint": Color(1.0, 0.78, 0.56), "label_color": Color(1.0, 0.82, 0.58),
		},
		{
			"id": "maple_cut_bandits", "region": "red_maple_ancient_road", "kind": "bandit", "name": "赤枫盗修",
			"prompt": "查看断桥伏击留下的痕迹", "chance": 0.58,
			"anchors": [Vector2(2810, 1380), Vector2(3000, 1460), Vector2(3150, 1360)],
			"health": 74, "damage": 9, "reward": "盗修符囊", "cultivation": 7,
			"story_trace": "road", "story_note": "盗修符囊里夹着一张过时的通关符，盖印来自早已废弃的边境关署。",
			"tint": Color(0.79, 0.55, 0.64), "label_color": Color(1.0, 0.65, 0.69),
		},
		{
			"id": "kiln_fire_beast", "region": "red_maple_ancient_road", "kind": "beast", "name": "火鬃岩獾",
			"prompt": "观察火鬃岩獾的领地", "chance": 0.62,
			"anchors": [Vector2(4500, 2730), Vector2(4680, 2840), Vector2(4800, 2640)],
			"health": 82, "damage": 10, "reward": "火鬃硬毛", "cultivation": 8,
			"story_trace": "relic", "story_note": "旧窑裂缝渗出的地火纹路与古脊岭断碑上的阵线方向一致。",
			"tint": Color(1.0, 0.54, 0.30), "label_color": Color(1.0, 0.68, 0.38),
		},
	]

func _on_population_resolved(summary: String) -> void:
	status.text = summary

func _talk_to_merchant() -> void:
	var first_meeting := GameState.meet_npc("洛清")
	var personal_reflection := GameState.npc_personal_reflection("洛清")
	status.text = "行商·洛晴：古道上的交易、护路和岔路都由修士自行选择。门派会给建议，散修也能凭资源与信誉走出自己的路。"

	if not personal_reflection.is_empty():
		status.text += "\n【你的见闻】%s" % str(personal_reflection.get("description", ""))
	if first_meeting:
		status.text += "\n（洛清已记入万物图鉴与游历簿；护送商队只是可错过的个人选择。）"

func _buy_caravan_goods() -> void:
	if GameState.player.gold < 18:
		status.text = "行囊金钱不足。商队不绑定买卖，玩家可采集、交易或以后再来。"
		return
	GameState.player.gold -= 18
	GameState.add_item("流火矿")
	status.text = "从商队购得流火矿（18 金钱）。它可用于炼器分支，也可自由交易。"

func _support_caravan() -> void:
	escort_resolved = true
	$EscortBeacon.visible = false
	escort_interaction.set_deferred("monitoring", false)
	GameState.add_item("商路凭信")
	GameState.gain_cultivation(15)
	GameState.record_opportunity({"region": "red_maple_ancient_road", "name": "自愿护路", "item": "商路凭信", "cultivation": 15})
	status.text = "你选择协助商队穿过岔口，获得商路凭信与修为。这是可选路线，不参与也不会失去其他内容。"
	_close_interaction()

func _resolve_road_event() -> void:
	event_resolved = true
	$RoadEvent.visible = false
	event_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(route_event.item))
	GameState.gain_cultivation(int(route_event.cultivation))
	GameState.record_opportunity({
		"region": "red_maple_ancient_road",
		"name": route_event.name,
		"item": route_event.item,
		"cultivation": route_event.cultivation,
	})
	status.text = "你发现%s：%s 获得 %s，修为 +%d。" % [route_event.name, route_event.description, route_event.item, route_event.cultivation]
	_close_interaction()

func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_border() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
