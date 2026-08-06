class_name MistTideBorder
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $RuinedCheckpoint/Interaction
@onready var scout_interaction: Area2D = $BorderScoutLiuShuo/Interaction
@onready var crystal_interaction: Area2D = $MistTideCrystal/Interaction
@onready var forest_gate_interaction: Area2D = $MistForestGate/Interaction
@onready var creek_gate_interaction: Area2D = $MistBoneCreekGate/Interaction
@onready var vessel_gate_interaction: Area2D = $SunkenVesselGate/Interaction
@onready var grotto_gate_interaction: Area2D = $MistTideGrottoGate/Interaction
@onready var red_maple_gate_interaction: Area2D = $RedMapleRoadGate/Interaction
@onready var thunder_cliff_gate_interaction: Area2D = $ThunderCliffGate/Interaction
@onready var mist_port_gate_interaction: Area2D = $MistPortGate/Interaction
@onready var abysswatch_gate_interaction: Area2D = $AbysswatchGate/Interaction
@onready var ancient_ridge_gate_interaction: Area2D = $AncientRidgeGate/Interaction
@onready var regional_population = $RegionalPopulation
@onready var chunk_streamer = $ChunkStreamer
@onready var world_encounter = $WorldCombat
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var scout_dialogue_stage := 0
var crystal_collected := false
var current_sector_id := ""

func _ready() -> void:
	GameState.current_region_id = "mist_border"
	# The painted border image is one authored chunk inside a much larger
	# continuous region. Future chunks attach to the same 12 km x 8 km space.
	player.map_bounds = Rect2(80, 80, 11840, 7840)
	player.position = Vector2(520, 1570)
	_setup_environment_depth()
	_setup_world_minimap()
	chunk_streamer.configure(player, [
		{"id": "border_checkpoint", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
		{"id": "waterway_ore_flats", "node": $WaterwayOreFlatsChunk, "bounds": Rect2(3072, 0, 3072, 2048)},
		{"id": "herb_wetland", "node": $HerbWetlandChunk, "bounds": Rect2(6144, 0, 3072, 2048)},
		{"id": "south_highlands", "node": $SouthHighlandsChunk, "bounds": Rect2(0, 2048, 3072, 2048)},
	])
	status.text = "雾潮边境：这是第二个大区的首个空间切片。地表、残关与雾木均为独立层；边境探子可提供筑基区域的线索。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	scout_interaction.focused.connect(_focus_interaction)
	scout_interaction.unfocused.connect(_unfocus_interaction)
	crystal_interaction.focused.connect(_focus_interaction)
	crystal_interaction.unfocused.connect(_unfocus_interaction)
	forest_gate_interaction.focused.connect(_focus_interaction)
	forest_gate_interaction.unfocused.connect(_unfocus_interaction)
	creek_gate_interaction.focused.connect(_focus_interaction)
	creek_gate_interaction.unfocused.connect(_unfocus_interaction)
	vessel_gate_interaction.focused.connect(_focus_interaction)
	vessel_gate_interaction.unfocused.connect(_unfocus_interaction)
	grotto_gate_interaction.focused.connect(_focus_interaction)
	grotto_gate_interaction.unfocused.connect(_unfocus_interaction)
	red_maple_gate_interaction.focused.connect(_focus_interaction)
	red_maple_gate_interaction.unfocused.connect(_unfocus_interaction)
	thunder_cliff_gate_interaction.focused.connect(_focus_interaction)
	thunder_cliff_gate_interaction.unfocused.connect(_unfocus_interaction)
	mist_port_gate_interaction.focused.connect(_focus_interaction)
	mist_port_gate_interaction.unfocused.connect(_unfocus_interaction)
	abysswatch_gate_interaction.focused.connect(_focus_interaction)
	abysswatch_gate_interaction.unfocused.connect(_unfocus_interaction)
	ancient_ridge_gate_interaction.focused.connect(_focus_interaction)
	ancient_ridge_gate_interaction.unfocused.connect(_unfocus_interaction)
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
	minimap.configure_region(player, player.map_bounds, "雾潮边境", [
		{"position": Vector2(760, 1100), "kind": "gate"},
		{"position": Vector2(1600, 460), "kind": "dungeon"},
		{"position": Vector2(2260, 560), "kind": "water"},
		{"position": Vector2(2860, 650), "kind": "gate"},
		{"position": Vector2(6980, 1370), "kind": "resource"},
		{"position": Vector2(2640, 1370), "kind": "gate"},
		{"position": Vector2(2940, 900), "kind": "gate"},
	], [
		PackedVector2Array([Vector2(520, 1570), Vector2(1380, 1040), Vector2(2260, 560), Vector2(2860, 650)]),
		PackedVector2Array([Vector2(760, 1100), Vector2(1600, 840), Vector2(2640, 1370), Vector2(2940, 900)]),
		PackedVector2Array([Vector2(2940, 900), Vector2(5000, 1060), Vector2(6980, 1370), Vector2(8170, 760)]),
	])


func _setup_environment_depth() -> void:
	var depth_layer: RegionalEnvironmentDepthLayer = RegionalEnvironmentDepthLayerScript.new()
	depth_layer.name = "EnvironmentDepthLayer"
	depth_layer.region_style = "mist_border"
	add_child(depth_layer)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_village()


func _process(_delta: float) -> void:
	_update_sector_presence()


func _update_sector_presence() -> void:
	var sector := RegionalSectorCatalogScript.sector_at("mist_border", player.position)
	var sector_id := str(sector.get("id", ""))
	if sector_id.is_empty() or sector_id == current_sector_id:
		return
	current_sector_id = sector_id
	# A sector notice explains the terrain's role but never turns it into a
	# quest marker or claims that every part of the sector contains an encounter.
	if active_interaction == null:
		status.text = "进入%s：%s" % [str(sector.get("name", "雾潮边境")), str(sector.get("description", ""))]

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
	elif action_id == "attack":
		player.trigger_basic_attack()

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_village()
	elif active_interaction == scout_interaction:
		_talk_to_scout()
	elif active_interaction == crystal_interaction and not crystal_collected:
		_collect_crystal()
	elif active_interaction == forest_gate_interaction:
		_try_enter_mist_forest()
	elif active_interaction == creek_gate_interaction:
		_try_enter_mist_bone_creek()
	elif active_interaction == vessel_gate_interaction:
		_try_enter_sunken_vessel()
	elif active_interaction == grotto_gate_interaction:
		_try_enter_mist_tide_grotto()
	elif active_interaction == red_maple_gate_interaction:
		_try_enter_red_maple_road()
	elif active_interaction == thunder_cliff_gate_interaction:
		_try_enter_thunder_cliff()
	elif active_interaction == mist_port_gate_interaction:
		_try_enter_mist_port()
	elif active_interaction == abysswatch_gate_interaction:
		_try_enter_abysswatch_terrace()
	elif active_interaction == ancient_ridge_gate_interaction:
		_try_enter_ancient_ridge()
	elif regional_population.owns(active_interaction):
		regional_population.resolve(active_interaction)
		_close_interaction()

func can_enter_mist_forest() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 2

func can_enter_mist_bone_creek() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 3

func can_enter_sunken_vessel() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 4

func can_enter_mist_tide_grotto() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 5

func can_enter_red_maple_road() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 6

func can_enter_thunder_cliff() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 7

func can_enter_mist_port() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 8

func can_enter_abysswatch_terrace() -> bool:
	return GameState.player.realm_index >= 1 or GameState.player.minor_stage >= 9

func can_enter_ancient_ridge() -> bool:
	return GameState.player.realm_index >= 3

func _population_seed() -> int:
	return int(Time.get_unix_time_from_system() / 180.0) + 6421

func _population_profiles() -> Array[Dictionary]:
	# These are ecological clusters, not a map-wide even distribution:
	# waterline beasts gather at the fog channel, scouts near the checkpoint,
	# and rogue cultivators only appear by resource-bearing side paths.
	var profiles: Array[Dictionary] = [
		{
			"id": "fog_channel_beast", "region": "mist_border", "kind": "beast", "name": "雾渠獭妖",
			"prompt": "观察雾渠獭妖的活动范围", "chance": 0.72,
			"anchors": [Vector2(2500, 560), Vector2(2700, 640), Vector2(2860, 470)],
			"health": 66, "damage": 7, "reward": "雾獭灵皮", "cultivation": 5,
			"tint": Color(0.72, 0.95, 0.86), "label_color": Color(0.74, 1.0, 0.89),
		},
		{
			"id": "mist_ore_rogue", "region": "mist_border", "kind": "rogue", "name": "采雾散修",
			"prompt": "向采雾散修打听矿脉", "chance": 0.48,
			"anchors": [Vector2(3860, 1190), Vector2(4060, 1260), Vector2(4280, 1160)],
			"tint": Color(0.78, 0.83, 0.94), "label_color": Color(0.81, 0.87, 1.0),
		},
		{
			"id": "checkpoint_watcher", "region": "mist_border", "kind": "rogue", "name": "边关巡修",
			"prompt": "询问边关巡修的雾潮消息", "chance": 0.35,
			"anchors": [Vector2(760, 980), Vector2(880, 1060)],
			"tint": Color(0.92, 0.86, 0.68), "label_color": Color(1.0, 0.9, 0.66),
		},
		# The wetland is intentionally quiet: herbs sit only on shallow-water
		# stone banks, while the herbalist stays beside the drying rack.
		{
			"id": "wetland_mist_herb", "region": "mist_border", "kind": "resource", "name": "雾泽灵草丛",
			"prompt": "在石滩与浅水交界采集雾泽灵草", "chance": 0.66,
			"anchors": [Vector2(6980, 1370), Vector2(7380, 1510), Vector2(7740, 1290)],
			"reward": "雾泽灵草", "cultivation": 3,
			"tint": Color(0.76, 1.0, 0.86), "label_color": Color(0.78, 1.0, 0.90),
		},
		{
			"id": "wetland_herbalist", "region": "mist_border", "kind": "rogue", "name": "晾药散修",
			"prompt": "向晾药散修询问湿地药性", "chance": 0.42,
			"anchors": [Vector2(7900, 700), Vector2(8170, 760)],
			"tint": Color(0.76, 0.90, 0.74), "label_color": Color(0.82, 0.96, 0.78),
		},
		# The southern highlands intentionally receive a single low-frequency
		# mineral-herb niche. It grows only where fogged rock shelves meet the
		# mountain path, leaving most of the new plateau quiet for exploration.
		{
			"id": "highland_mist_stonebud", "region": "mist_border", "kind": "resource", "name": "雾岭石芽",
			"prompt": "采集岩台雾气滋养的雾岭石芽", "chance": 0.32,
			"anchors": [Vector2(1360, 3180), Vector2(2120, 3440), Vector2(2660, 3620)],
			"reward": "雾岭石芽", "cultivation": 4,
			"tint": Color(0.80, 0.94, 0.84), "label_color": Color(0.84, 1.0, 0.88),
		},
	]
	# A sect wanted record is not a map-wide monster switch.  The patrol only
	# takes the checkpoint and gate-road anchors that belong to its jurisdiction.
	if GameState.is_wanted_by_sect("mist_sword"):
		profiles.append({
			"id": "mist_sword_patrol", "region": "mist_border", "kind": "bandit", "name": "雾隐剑宗巡守",
			"prompt": "雾隐剑宗巡守正在查验离宗记录", "chance": 1.0,
			"anchors": [Vector2(760, 980), Vector2(880, 1060), Vector2(1120, 920)],
			"health": 102, "damage": 13, "reward": "巡守令牌", "cultivation": 8,
			"tint": Color(0.72, 0.80, 0.96), "label_color": Color(0.80, 0.88, 1.0),
		})
	return profiles

func _on_population_resolved(summary: String) -> void:
	status.text = summary

func _talk_to_scout() -> void:
	if scout_dialogue_stage == 0:
		scout_dialogue_stage = 1
		status.text = "边境探子·柳朔：雾潮会随着时辰退涨。北面的雾林从炼气二层起便可试探，但仍需稳住根基；盲目闯入只会被雾路带偏。"
		prompt.text = "[E] 再问柳朔"
	else:
		status.text = "柳朔：晶簇是雾潮留下的稳定锚点。炼气二层可先进入雾林妖径；筑基后，边境深处还会显现更危险的秘境。"

func _collect_crystal() -> void:
	crystal_collected = true
	$MistTideCrystal.visible = false
	crystal_interaction.set_deferred("monitoring", false)
	GameState.add_item("雾潮晶簇")
	GameState.gain_cultivation(8)
	status.text = "获得雾潮晶簇：这是边境生态资源，可用于后续炼器、阵法和筑基区域的雾潮探索。修为 +8。"
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _try_enter_mist_forest() -> void:
	if not can_enter_mist_forest():
		status.text = "雾林结界只回应炼气二层以上的修士。你可继续水府试炼、采集与修炼来稳固根基。"
		return
	GameState.selected_dungeon_id = "mist_forest"
	get_tree().change_scene_to_file("res://scenes/mist_forest_grove.tscn")

func _try_enter_mist_bone_creek() -> void:
	if not can_enter_mist_bone_creek():
		status.text = "雾骨溪的灵潮在炼气三层后才会稳定。无需接取任务，你可继续探索、采集、交易或修炼后自行前往。"
		return
	get_tree().change_scene_to_file("res://scenes/mist_bone_creek.tscn")

func _try_enter_sunken_vessel() -> void:
	if not can_enter_sunken_vessel():
		status.text = "沉舷遗府的潮门要到炼气四层才会完整显现。你可自由选择继续探索雾骨溪、挑战雾林、交易材料或修炼后再来。"
		return
	GameState.selected_dungeon_id = "sunken_boat"
	get_tree().change_scene_to_file("res://scenes/sunken_vessel_manor.tscn")

func _try_enter_mist_tide_grotto() -> void:
	if not can_enter_mist_tide_grotto():
		status.text = "雾潮石窟的三条支路要到炼气五层才会稳定。它没有任务门槛；你可用任意修行、交易或探索方式准备后再来。"
		return
	GameState.selected_dungeon_id = "sealed_grotto"
	get_tree().change_scene_to_file("res://scenes/mist_tide_stone_grotto.tscn")

func _try_enter_red_maple_road() -> void:
	if not can_enter_red_maple_road():
		status.text = "赤枫古道在炼气六层后才适合穿行。它不是任务门槛；修炼、采集、交易或探索都能帮助你抵达此处。"
		return
	GameState.selected_dungeon_id = "border_realm"
	get_tree().change_scene_to_file("res://scenes/red_maple_ancient_road.tscn")

func _try_enter_thunder_cliff() -> void:
	if not can_enter_thunder_cliff():
		status.text = "听雷断崖的雷云要到炼气七层后才相对稳定。它没有任务顺序；可先通过任意修行、探索或交易路线准备。"
		return
	GameState.selected_dungeon_id = "thunder_cliff"
	get_tree().change_scene_to_file("res://scenes/thunder_listening_cliff.tscn")

func _try_enter_mist_port() -> void:
	if not can_enter_mist_port():
		status.text = "归墟雾港外海的潮路到炼气八层后才稳定。它不是任务门槛；可循修炼、探索、交易或宗门路线慢慢准备。"
		return
	GameState.selected_dungeon_id = "return_abyss_mist_port"
	get_tree().change_scene_to_file("res://scenes/return_abyss_mist_port.tscn")

func _try_enter_abysswatch_terrace() -> void:
	if not can_enter_abysswatch_terrace():
		status.text = "临渊台的崖风要到炼气九层后才适合观想。它不是任务门槛；可用任意自由路线准备后再来。"
		return
	GameState.selected_dungeon_id = "abysswatch_terrace"
	get_tree().change_scene_to_file("res://scenes/abysswatch_terrace.tscn")

func _try_enter_ancient_ridge() -> void:
	if not can_enter_ancient_ridge():
		status.text = "古脊岭的地火与遗址会压制元婴以下修士。它不是任务门槛；到元婴后可从边境关道自由进入。"
		return
	GameState.selected_dungeon_id = "ancient_battlefield"
	get_tree().change_scene_to_file("res://scenes/ancient_ridge.tscn")

func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_village() -> void:
	GameState.current_region_id = "starter_village"
	get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
