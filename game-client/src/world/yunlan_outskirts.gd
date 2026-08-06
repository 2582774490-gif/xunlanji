class_name YunlanOutskirts
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")
const RemoteAvatarLayerScript = preload("res://src/world/remote_avatar_layer.gd")

const CHANCE_TRACES := [
	{
		"id": "mist_stream_cache", "name": "雾溪石函", "prompt": "探查雾溪石岸上的旧函", "sector": "mist_stream_banks",
		"position": Vector2(3500, 780), "item": "雾溪旧函", "cultivation": 4,
		"description": "石函被浅水冲开一角，留下前人辨药时记录的水痕。",
	},
	{
		"id": "stonewind_trace", "name": "风蚀残页", "prompt": "感悟背风岩台上的风痕", "sector": "stonebud_highland",
		"position": Vector2(2520, 3600), "item": "风蚀残页", "cultivation": 4,
		"description": "风从岩缝折返，卷出一段并不完整的游身法门。",
	},
	{
		"id": "oldroad_ledger", "name": "旧道货札", "prompt": "翻看旧商道旁遗下的货札", "sector": "old_caravan_road",
		"position": Vector2(9200, 1500), "item": "旧道货札", "cultivation": 2,
		"description": "被雨水浸软的货札记着山货、药材与一段绕开劫修的旧路。",
	},
]

# A terrain chance trace is a discovery in a particular place, rather than a
# disposable scene prop. Resolving one suppresses only that exact trace for a
# while; another compatible terrain sector may still offer a different chance.
const CHANCE_TRACE_RESPAWN_SECONDS := 1800

const FIELD_CLUES := {
	"stream_stair_cairn": {
		"name": "雾溪引水堆石", "sector": "cloudfoot_wood",
		"text": "石堆下压着褪色的采药签：\"顺着湿石阶入林，浅潮尽头便是雾溪水府。炼气一层后，水门才会回应。\"",
	},
	"caravan_milestone": {
		"name": "旧商道里程碑", "sector": "old_caravan_road",
		"text": "断碑仍能辨出商队旧记：\"雾潮关受水脉牵引；先探明水府，再过旧关。雨后不走偏坡，劫修常伏在车辙外。\"",
	},
	"wind_etched_marker": {
		"name": "背风崖风蚀石", "sector": "stonebud_highland",
		"text": "风蚀刻痕并不指向任务，只留下观地之法：背风石芽可采石蕊；循山脊望东，能见岚息回响石。",
	},
}

const OPENING_PAGES := [
	{
		"title": "云岚外野 · 初见",
		"body": "云岚村外，山风贴着雾溪而过。\n\n此世所谓“岚”，并非单一灵气：它是山势、水汽、地脉与生灵吐纳交汇后，能被修士感知、引导与炼化的余息。",
	},
	{
		"title": "修行不只有一条路",
		"body": "你可以先沿溪采药，也可以试不同武器、入宗门、做散修、炼丹、交易，或只是向远处走。\n\n灵根、体质和功法会改变适配与效率，却不会封死任何修行路径。",
	},
	{
		"title": "踏入外野",
		"body": "方向键或左摇杆行走；靠近地标按 E 或“交”互动。右侧五个技能分别对应普攻、武器主技、云步、护体与润灵。\n\n雾溪水府在云麓疏林深处，炼气一层可入；但它不是你的任务终点。去哪里，由你自己决定。",
	},
]

@onready var player: CharacterBody2D = $Player
@onready var village_gate: Area2D = $YunlanVillageGate/Interaction
@onready var mist_border_gate: Area2D = $MistBorderPass/Interaction
@onready var water_palace_gate: Area2D = $MistStreamWaterPalaceGate/Interaction
@onready var echo_stone: Area2D = $LanEchoStone/Interaction
@onready var chance_trace: Area2D = $YunlanChanceTrace/Interaction
@onready var stream_stair_cairn: Area2D = $FieldClues/StreamStairCairn/Interaction
@onready var caravan_milestone: Area2D = $FieldClues/CaravanMilestone/Interaction
@onready var wind_etched_marker: Area2D = $FieldClues/WindEtchedMarker/Interaction
@onready var regional_population = $RegionalPopulation
@onready var chunk_streamer = $ChunkStreamer
@onready var world_encounter = $WorldCombat
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls
@onready var opening_overlay: Control = $HUD/OpeningLore
@onready var opening_title: Label = $HUD/OpeningLore/Card/Title
@onready var opening_body: Label = $HUD/OpeningLore/Card/Body
@onready var opening_progress: Label = $HUD/OpeningLore/Card/Progress
@onready var opening_continue: Button = $HUD/OpeningLore/Card/Continue

var active_interaction: Area2D
var echo_stone_observed := false
var chance_trace_resolved := false
var chosen_chance_trace: Dictionary = {}
var current_sector_id := ""
var opening_active := false
var opening_page_index := 0


func _ready() -> void:
	GameState.current_region_id = "starter_village"
	player.map_bounds = Rect2(80, 80, 11840, 7840)
	player.position = GameState.region_position_or("starter_village", Vector2(860, 1680), player.map_bounds)
	_setup_environment_depth()
	_setup_world_minimap()
	chunk_streamer.configure(player, [
		{"id": "south_gate_fields", "node": $SouthGateChunk, "bounds": Rect2(0, 0, 3072, 2048)},
	])
	status.text = "云岚外野：云岚村只是第一处聚落。沿灵田、雾溪、云麓疏林与旧商道自由探索；资源和人物只会出现在合适地形。"
	_setup_chance_trace()
	var interactions: Array[Area2D] = [village_gate, mist_border_gate, water_palace_gate, echo_stone, stream_stair_cairn, caravan_milestone, wind_etched_marker]
	if not chosen_chance_trace.is_empty():
		interactions.append(chance_trace)
	for interaction in interactions:
		interaction.focused.connect(_focus_interaction)
		interaction.unfocused.connect(_unfocus_interaction)
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	_setup_online_presence()
	_setup_opening_lore()


func _setup_chance_trace() -> void:
	var available_traces: Array[Dictionary] = []
	for trace_data in CHANCE_TRACES:
		var trace: Dictionary = trace_data
		var cooldown_id := "chance_trace_%s" % str(trace.get("id", ""))
		if GameState.is_ecology_profile_available("starter_village", cooldown_id):
			available_traces.append(trace)
	if available_traces.is_empty():
		chosen_chance_trace = {}
		$YunlanChanceTrace.hide()
		chance_trace.set_deferred("monitoring", false)
		return
	chosen_chance_trace = available_traces.pick_random().duplicate()
	$YunlanChanceTrace.show()
	chance_trace.set_deferred("monitoring", true)
	$YunlanChanceTrace.position = chosen_chance_trace.position
	$YunlanChanceTrace/Name.text = str(chosen_chance_trace.name)
	chance_trace.prompt_text = str(chosen_chance_trace.prompt)


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
		{"position": Vector2(4740, 1710), "kind": "clue"},
		{"position": Vector2(7720, 1500), "kind": "relic"},
		{"position": Vector2(2800, 3360), "kind": "clue"},
		{"position": Vector2(9060, 1560), "kind": "clue"},
		{"position": Vector2(11000, 1650), "kind": "gate"},
	], [
		PackedVector2Array([Vector2(760, 1440), Vector2(2780, 1660), Vector2(5140, 1770), Vector2(7720, 1500), Vector2(11000, 1650)]),
		PackedVector2Array([Vector2(2780, 1660), Vector2(2420, 2960), Vector2(3180, 3600)]),
		PackedVector2Array([Vector2(5140, 1770), Vector2(6760, 3600), Vector2(8720, 4560)]),
	])


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if opening_active:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E or event.keycode == KEY_ESCAPE:
			_advance_opening_lore()
			get_viewport().set_input_as_handled()
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


func _exit_tree() -> void:
	if player != null:
		GameState.remember_region_position("starter_village", player.position)
	OnlineSession.detach_world(self)


func _setup_online_presence() -> void:
	var layer: RemoteAvatarLayer = RemoteAvatarLayerScript.new()
	layer.name = "RemoteAvatarLayer"
	add_child(layer)
	layer.configure("starter_village")
	OnlineSession.attach_world("starter_village", player, self)


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
	elif active_interaction == water_palace_gate:
		_enter_mist_stream_water_palace()
	elif active_interaction == echo_stone and not echo_stone_observed:
		_observe_lan_echo()
	elif active_interaction == chance_trace and not chance_trace_resolved:
		_resolve_chance_trace()
	elif active_interaction == stream_stair_cairn:
		_read_field_clue("stream_stair_cairn")
	elif active_interaction == caravan_milestone:
		_read_field_clue("caravan_milestone")
	elif active_interaction == wind_etched_marker:
		_read_field_clue("wind_etched_marker")
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()


func _enter_mist_border() -> void:
	if not GameState.is_region_unlocked("mist_border"):
		status.text = "旧商道尽头的雾潮仍不稳定。炼气一层后可在云岚村进入雾溪水府试探；完成一次水府探索后，边境旧关才会常年开放。"
		return
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")


func _enter_mist_stream_water_palace() -> void:
	# The first fixed dungeon begins at Qi Refining first layer. It is a place
	# inside the large starting region, not a menu reward or an imposed quest.
	if GameState.player.realm_index == 0 and GameState.player.minor_stage < 1:
		status.text = "雾溪水府的浅潮尚未回应。先稳定到炼气一层，再从石阶进入。"
		return
	if not GameState.try_begin_fixed_dungeon("mist_stream_palace"):
		status.text = GameState.fixed_dungeon_entry_block_text()
		return
	GameState.selected_dungeon_id = "mist_stream_palace"
	get_tree().change_scene_to_file("res://scenes/mist_stream_water_palace.tscn")


func _observe_lan_echo() -> void:
	echo_stone_observed = true
	echo_stone.set_deferred("monitoring", false)
	GameState.add_item("岚息石屑")
	GameState.gain_cultivation(3)
	GameState.record_opportunity({"region": "starter_village", "name": "岚息回响石", "kind": "highland_landmark", "item": "岚息石屑"})
	status.text = "风从石缝掠过，留下短促的岚息回响。你获得岚息石屑，修为 +3。它是丘陵里一处固定远望点，不会被复制成遍地奖励。"
	_close_interaction()


func _resolve_chance_trace() -> void:
	chance_trace_resolved = true
	chance_trace.set_deferred("monitoring", false)
	GameState.mark_ecology_profile_resolved(
		"starter_village",
		"chance_trace_%s" % str(chosen_chance_trace.get("id", "")),
		CHANCE_TRACE_RESPAWN_SECONDS
	)
	GameState.add_item(str(chosen_chance_trace.item))
	GameState.gain_cultivation(int(chosen_chance_trace.cultivation))
	GameState.record_opportunity({
		"region": "starter_village", "name": str(chosen_chance_trace.name), "kind": "terrain_chance_trace",
		"item": str(chosen_chance_trace.item),
	})
	status.text = "%s。获得 %s，修为 +%d。此类机缘每次只选一处合理地貌，不会被均匀铺满。" % [
		str(chosen_chance_trace.description), str(chosen_chance_trace.item), int(chosen_chance_trace.cultivation),
	]
	$YunlanChanceTrace.visible = false
	_close_interaction()


func _setup_opening_lore() -> void:
	opening_continue.pressed.connect(_advance_opening_lore)
	if GameState.has_seen_opening_lore():
		opening_overlay.hide()
		return
	opening_active = true
	opening_overlay.show()
	player.set_physics_process(false)
	player.set_process_unhandled_key_input(false)
	_render_opening_page()


func _advance_opening_lore() -> void:
	if not opening_active:
		return
	opening_page_index += 1
	if opening_page_index < OPENING_PAGES.size():
		_render_opening_page()
		return
	opening_active = false
	opening_overlay.hide()
	player.set_physics_process(true)
	player.set_process_unhandled_key_input(true)
	GameState.complete_opening_lore()
	status.text = "你踏出云岚村南门。外野没有强制任务线：沿路、溪、林与高地探索，观察地貌与修行机会。"


func _render_opening_page() -> void:
	var page: Dictionary = OPENING_PAGES[opening_page_index]
	opening_title.text = str(page.title)
	opening_body.text = str(page.body)
	opening_progress.text = "%d / %d" % [opening_page_index + 1, OPENING_PAGES.size()]
	opening_continue.text = "踏入外野" if opening_page_index == OPENING_PAGES.size() - 1 else "继续"


func _read_field_clue(clue_id: String) -> void:
	var clue: Dictionary = FIELD_CLUES.get(clue_id, {})
	if clue.is_empty():
		return
	var first_read := GameState.record_field_clue(clue_id)
	if first_read:
		GameState.record_opportunity({
			"region": "starter_village", "name": str(clue.name), "kind": "field_clue",
		})
		status.text = "%s\n（已记入见闻；这不是任务，也不发放数值奖励。）" % str(clue.text)
	else:
		status.text = "%s\n（你已读过这处地貌线索。）" % str(clue.text)
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
