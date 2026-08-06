class_name ReturnAbyssMistPort
extends Node2D

const PORT_EVENTS := [
	{"name": "潮签落在旧栈桥", "item": "归墟潮砂", "cultivation": 12, "description": "退潮后显出的潮签记录着一段可售卖的航线。"},
	{"name": "失期货箱", "item": "雾港封蜡", "cultivation": 10, "description": "一只未署名的货箱被海潮推上石阶，里面只有通行封蜡。"},
	{"name": "残舟引路", "item": "沉舟航标片", "cultivation": 14, "description": "沉船残骸间的灵光映出一条临时航道，可通向未来遗迹。"},
]

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $PortExit/Interaction
@onready var auction_interaction: Area2D = $AuctionHall/Interaction
@onready var ledger_interaction: Area2D = $TideLedger/Interaction
@onready var wreck_interaction: Area2D = $WreckedPier/Interaction
@onready var sea_cave_interaction: Area2D = $SeaCaveApproach/Interaction
@onready var regional_population = $RegionalPopulation
@onready var world_encounter = $WorldCombat
@onready var chunk_streamer = $ChunkStreamer
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var port_event: Dictionary = {}
var ledger_read := false
var wreck_resolved := false
var sea_cave_searched := false

func _ready() -> void:
	GameState.current_region_id = "return_abyss_mist_port"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = Vector2(560, 1640)
	chunk_streamer.configure(player, [
		{"id": "mist_port_quays", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
		{"id": "mist_port_outer_harbor", "node": $OuterHarborChunk, "bounds": Rect2(3072, 0, 3072, 2048)},
	])
	port_event = PORT_EVENTS.pick_random().duplicate()
	$WreckedPier/Name.text = str(port_event.name)
	status.text = "归墟雾港（炼气八层）：这是大区的第一处港口切片。交易、人流、浅滩水妖与残舟遗物各有自己的活动位置；港外仍可继续扩展。"
	for interaction in [return_interaction, auction_interaction, ledger_interaction, wreck_interaction, sea_cave_interaction]:
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
	prompt.text = "[E / 互动] " + str(interaction.prompt_text)
	touch_controls.set_interaction_available(true)

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction == interaction:
		_close_interaction()

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()
	else:
		world_encounter.use_action(action_id)

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_border()
	elif active_interaction == auction_interaction:
		_open_market()
	elif active_interaction == ledger_interaction and not ledger_read:
		_read_tide_ledger()
	elif active_interaction == wreck_interaction and not wreck_resolved:
		_resolve_wreck()
	elif active_interaction == sea_cave_interaction and not sea_cave_searched:
		_search_sea_cave()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func _open_market() -> void:
	# This hands off to the existing local marketplace.  Real listings, bidding,
	# ten-player room synchronisation and cross-player settlement remain server work.
	GameState.enter_screen(GameState.Screen.MARKET)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _read_tide_ledger() -> void:
	ledger_read = true
	GameState.record_opportunity({"region": "return_abyss_mist_port", "name": "潮路公告板", "kind": "port_rumor"})
	status.text = "潮路公告板记下了临时船期与遗迹流言。它是自由探索提示，不会替你领取任务；不同宗门、散修与商会可据此走向不同海路。"
	_close_interaction()

func _resolve_wreck() -> void:
	wreck_resolved = true
	$WreckedPier.visible = false
	wreck_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(port_event.item))
	GameState.gain_cultivation(int(port_event.cultivation))
	GameState.record_opportunity({"region": "return_abyss_mist_port", "name": port_event.name, "item": port_event.item, "cultivation": port_event.cultivation})
	status.text = "你在%s中找到%s。%s 修为 +%d。" % [port_event.name, port_event.item, port_event.description, port_event.cultivation]
	_close_interaction()

func _search_sea_cave() -> void:
	sea_cave_searched = true
	$SeaCaveApproach.visible = false
	sea_cave_interaction.set_deferred("monitoring", false)
	GameState.add_item("潮洞灵藻")
	GameState.gain_cultivation(16)
	GameState.record_opportunity({"region": "return_abyss_mist_port", "name": "海蚀洞潮池", "item": "潮洞灵藻", "cultivation": 16})
	status.text = "你在海蚀洞外的潮池采到潮洞灵藻。这里暂时是可选采集点；未来会向更深处的外海遗迹副本延展。修为 +16。"
	_close_interaction()

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 88018

func _population_profiles() -> Array[Dictionary]:
	# Population is tied to port functions: commerce at the moorings, rumours by
	# notices, and water beasts only around the unsafe wrecked shallows.
	return [
		{
			"id": "port_merchant", "region": "return_abyss_mist_port", "kind": "merchant", "name": "泊位行商",
			"prompt": "向泊位行商打听最近货路", "chance": 0.70,
			"anchors": [Vector2(1280, 1040), Vector2(1430, 1120), Vector2(1550, 980)],
			"tint": Color(0.86, 0.78, 0.59), "label_color": Color(1.0, 0.86, 0.58),
		},
		{
			"id": "tide_chart_rogue", "region": "return_abyss_mist_port", "kind": "rogue", "name": "测潮散修",
			"prompt": "询问测潮散修的外海流向", "chance": 0.46,
			"anchors": [Vector2(820, 760), Vector2(940, 830)],
			"tint": Color(0.60, 0.85, 0.91), "label_color": Color(0.67, 0.94, 1.0),
		},
		{
			"id": "wreck_shallows_beast", "region": "return_abyss_mist_port", "kind": "beast", "name": "潇潮岚鲨",
			"prompt": "观察潇潮岚鲨的沉桩浅滩领地", "chance": 0.20,
			"anchors": [Vector2(2380, 900), Vector2(2550, 1020), Vector2(2710, 820)],
			"health": 132, "damage": 16, "reward": "岚鲨鳞片", "cultivation": 16,
			"tint": Color(0.55, 0.88, 0.86), "label_color": Color(0.65, 1.0, 0.91),
		},
		{
			"id": "shipyard_rogue", "region": "return_abyss_mist_port", "kind": "rogue", "name": "修舟散修",
			"prompt": "询问修舟散修的外海传闻", "chance": 0.38,
			"anchors": [Vector2(3540, 900), Vector2(3710, 1020)],
			"tint": Color(0.82, 0.70, 0.55), "label_color": Color(0.98, 0.82, 0.60),
		},
		{
			"id": "sea_cave_beast", "region": "return_abyss_mist_port", "kind": "beast", "name": "潮穴鳞獭",
			"prompt": "观察潮穴鳞獭的洞口领地", "chance": 0.52,
			"anchors": [Vector2(4750, 980), Vector2(4920, 1100), Vector2(5100, 920)],
			"health": 116, "damage": 14, "reward": "潮穴鳞皮", "cultivation": 14,
			"tint": Color(0.60, 0.82, 0.90), "label_color": Color(0.70, 0.91, 1.0),
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
