class_name MistTideBorder
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")
const RemoteAvatarLayerScript = preload("res://src/world/remote_avatar_layer.gd")
const WorldInteractionScript = preload("res://src/world/world_interaction.gd")
const PersonalOpportunityDirectorScript = preload("res://src/world/personal_opportunity_director.gd")

const PERSONAL_OPPORTUNITY_PROFILES: Array[Dictionary] = [
	{
		"id": "checkpoint_refuge_charm", "sector": "old_checkpoint", "name": "避潮护符", "prompt": "查看残关石阶下遗落的避潮护符", "chance": 0.80,
		"anchors": [Vector2(1320, 1420), Vector2(1880, 1180)], "reward": "避潮符纸", "cultivation": 3, "story_trace": "road",
		"description": "护符背面写着一串避潮车队的临时人名。有人在雾潮里先救走了陌生人，留下的不是功勋，只是一条仍能走通的路。",
		"story_branch": "opportunity_checkpoint_refuge_charm", "story_branch_title": "残关避潮符", "tint": Color(0.94, 0.84, 0.56),
	},
	{
		"id": "fog_channel_scale", "sector": "fog_channel", "name": "回水鳞片", "prompt": "拾取石岸夹缝中逆潮漂来的鳞片", "chance": 0.76,
		"anchors": [Vector2(2260, 860), Vector2(3420, 580)], "reward": "回水鳞片", "cultivation": 4, "story_trace": "water",
		"description": "鳞片的纹路朝向与水流相反，边缘还带着另一片水域的盐霜。雾渠只是两边潮息偶尔重叠的窄口。",
		"story_branch": "opportunity_fog_channel_scale", "story_branch_title": "回水鳞片录", "tint": Color(0.48, 0.92, 0.96),
	},
	{
		"id": "ore_flat_survey_pin", "sector": "ore_flats", "name": "断纹测钉", "prompt": "拔出矿滩上标记旧纹走向的测钉", "chance": 0.72,
		"anchors": [Vector2(3980, 2140), Vector2(5480, 1860)], "reward": "断纹测钉", "cultivation": 4, "story_trace": "relic",
		"description": "测钉沿着退潮矿线排开，却指向不存在的地层。有人曾在这里认真测量旧界，而不是传言中的宝藏。",
		"story_branch": "opportunity_ore_flat_survey_pin", "story_branch_title": "断纹测钉", "tint": Color(0.86, 0.70, 1.0),
	},
	{
		"id": "wetland_medicine_sachet", "sector": "herb_wetland", "name": "同枝药囊", "prompt": "辨认湿地石滩上晾晒的同枝药囊", "chance": 0.70,
		"anchors": [Vector2(6760, 2180), Vector2(8260, 1680)], "reward": "雾泽灵草", "cultivation": 3, "story_trace": "water",
		"description": "药囊里的两味药草来自同一枝根，却有相反的成熟时序。它们不是珍稀掉落，只是一片湿地正在缓慢改变的证据。",
		"story_branch": "opportunity_wetland_medicine_sachet", "story_branch_title": "同枝药囊", "tint": Color(0.70, 1.0, 0.72),
	},
]

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
@onready var tideward_watchstone_interaction: Area2D = $TidewardWatchstone/Interaction
@onready var regional_population = $RegionalPopulation
@onready var chunk_streamer = $ChunkStreamer
@onready var world_encounter = $WorldCombat
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var scout_dialogue_stage := 0
var crystal_collected := false
var tideward_watchstone_observed := false
var current_sector_id := ""
var personal_resonance: Area2D
var personal_resonance_profile: Dictionary = {}
var personal_opportunities: Variant = null

func _ready() -> void:
	GameState.current_region_id = "mist_border"
	# The painted border image is one authored chunk inside a much larger
	# continuous region. Future chunks attach to the same 12 km x 8 km space.
	player.map_bounds = Rect2(80, 80, 11840, 7840)
	player.position = GameState.region_position_or("mist_border", Vector2(520, 1570), player.map_bounds)
	_setup_environment_depth()
	_setup_world_minimap()
	chunk_streamer.configure(player, [
		{"id": "border_checkpoint", "node": $Terrain, "bounds": Rect2(0, 0, 3072, 2048)},
		{"id": "waterway_ore_flats", "node": $WaterwayOreFlatsChunk, "bounds": Rect2(3072, 0, 3072, 2048)},
		{"id": "herb_wetland", "node": $HerbWetlandChunk, "bounds": Rect2(6144, 0, 3072, 2048)},
		{"id": "south_highlands", "node": $SouthHighlandsChunk, "bounds": Rect2(0, 2048, 3072, 2048)},
		{"id": "tideward_hills", "node": $TidewardHillsChunk, "bounds": Rect2(6144, 4096, 3072, 2048)},
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
	tideward_watchstone_interaction.focused.connect(_focus_interaction)
	tideward_watchstone_interaction.unfocused.connect(_unfocus_interaction)
	_setup_personal_story_resonance()
	_setup_personal_opportunities()
	regional_population.focused.connect(_focus_interaction)
	regional_population.unfocused.connect(_unfocus_interaction)
	regional_population.population_resolved.connect(_on_population_resolved)
	regional_population.populate(_population_seed(), _population_profiles())
	world_encounter.configure(player, regional_population, status, $HUD/EncounterTarget, $HUD/EncounterPlayer)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	_setup_online_presence()


func _setup_world_minimap() -> void:
	var minimap: WorldMinimap = WorldMinimapScript.new()
	minimap.name = "WorldMinimap"
	$HUD.add_child(minimap)
	minimap.configure_region(player, player.map_bounds, "雾潮边境", [
		{"position": Vector2(760, 1100), "kind": "gate"},
		{"position": Vector2(3100, 1300), "kind": "dungeon"},
		{"position": Vector2(4760, 1300), "kind": "water"},
		{"position": Vector2(5280, 720), "kind": "water"},
		{"position": Vector2(2900, 2050), "kind": "dungeon"},
		{"position": Vector2(6980, 1370), "kind": "resource"},
		{"position": Vector2(5880, 2800), "kind": "gate"},
		{"position": Vector2(3980, 3800), "kind": "dungeon"},
		{"position": Vector2(7900, 5100), "kind": "relic"},
		{"position": Vector2(9000, 3900), "kind": "gate"},
		{"position": Vector2(10450, 1600), "kind": "water"},
		{"position": Vector2(11000, 5350), "kind": "gate"},
	], [
		PackedVector2Array([Vector2(520, 1570), Vector2(1380, 1040), Vector2(3100, 1300), Vector2(4760, 1300), Vector2(5280, 720)]),
		PackedVector2Array([Vector2(3100, 1300), Vector2(2900, 2050), Vector2(5880, 2800), Vector2(3980, 3800)]),
		PackedVector2Array([Vector2(5880, 2800), Vector2(7900, 5100), Vector2(9000, 3900), Vector2(10450, 1600), Vector2(11000, 5350)]),
	])


func _setup_environment_depth() -> void:
	var depth_layer: RegionalEnvironmentDepthLayer = RegionalEnvironmentDepthLayerScript.new()
	depth_layer.name = "EnvironmentDepthLayer"
	depth_layer.region_style = "mist_border"
	add_child(depth_layer)

func _setup_personal_opportunities() -> void:
	personal_opportunities = PersonalOpportunityDirectorScript.new()
	personal_opportunities.name = "PersonalOpportunities"
	add_child(personal_opportunities)
	personal_opportunities.focused.connect(_focus_interaction)
	personal_opportunities.unfocused.connect(_unfocus_interaction)
	personal_opportunities.resolved.connect(_on_personal_opportunity_resolved)
	personal_opportunities.populate("mist_border", PERSONAL_OPPORTUNITY_PROFILES)


func _on_personal_opportunity_resolved(summary: String) -> void:
	status.text = summary


func _setup_personal_story_resonance() -> void:
	# This second observation is authored, not randomly distributed. It appears
	# only after the player found their own first resonance in Yunlan, then
	# continues that perspective in a different but fitting regional ecology.
	var story_state := GameState.personal_story_state()
	if not (story_state.get("personal_marks", []) as Array).has("origin_resonance"):
		return
	if (story_state.get("personal_marks", []) as Array).has("border_resonance"):
		return
	var origin := GameState.personal_story_profile()
	var resonance: Variant = origin.get("border_resonance", {})
	if not resonance is Dictionary or str(resonance.get("region", "")) != "mist_border":
		return
	personal_resonance_profile = (resonance as Dictionary).duplicate(true)
	var position: Vector2 = personal_resonance_profile.get("position", Vector2.ZERO)
	var expected_sector := str(personal_resonance_profile.get("sector", ""))
	var actual_sector := RegionalSectorCatalogScript.sector_at("mist_border", position)
	if position == Vector2.ZERO or str(actual_sector.get("id", "")) != expected_sector:
		push_warning("Mist Border personal resonance had no valid sector anchor.")
		personal_resonance_profile.clear()
		return
	var root := Node2D.new()
	root.name = "PersonalStoryResonance"
	root.position = position
	root.y_sort_enabled = true
	add_child(root)
	var colors := _personal_resonance_colors(str(origin.get("id", "")))
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-74, 0), Vector2(-28, -13), Vector2(64, -4), Vector2(40, 16), Vector2(-50, 14)])
	shadow.color = Color(0.02, 0.05, 0.08, 0.52)
	root.add_child(shadow)
	var outer_halo := Polygon2D.new()
	outer_halo.polygon = PackedVector2Array([Vector2(0, -182), Vector2(72, -104), Vector2(62, -36), Vector2(0, 12), Vector2(-62, -36), Vector2(-72, -104)])
	outer_halo.color = colors[0]
	root.add_child(outer_halo)
	var inner_shard := Polygon2D.new()
	inner_shard.polygon = PackedVector2Array([Vector2(-20, -18), Vector2(-12, -130), Vector2(0, -204), Vector2(20, -130), Vector2(26, -18), Vector2(0, 6)])
	inner_shard.color = colors[1]
	root.add_child(inner_shard)
	var crest := Polygon2D.new()
	crest.polygon = PackedVector2Array([Vector2(-48, -80), Vector2(0, -126), Vector2(48, -80), Vector2(0, -60)])
	crest.color = colors[2]
	root.add_child(crest)
	var name_label := Label.new()
	name_label.position = Vector2(-170, -256)
	name_label.size = Vector2(340, 32)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", colors[1])
	name_label.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.09))
	name_label.add_theme_constant_override("outline_size", 6)
	name_label.text = str(personal_resonance_profile.get("name", "岚潮续响"))
	root.add_child(name_label)
	personal_resonance = Area2D.new()
	personal_resonance.name = "Interaction"
	personal_resonance.set_script(WorldInteractionScript)
	personal_resonance.interaction_id = "mist_border_personal_story_resonance"
	personal_resonance.prompt_text = str(personal_resonance_profile.get("prompt", "静观岚潮续响"))
	root.add_child(personal_resonance)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 102.0
	collision.shape = shape
	collision.position = Vector2(0, -88)
	personal_resonance.add_child(collision)
	personal_resonance.focused.connect(_focus_interaction)
	personal_resonance.unfocused.connect(_unfocus_interaction)


func _personal_resonance_colors(origin_id: String) -> Array[Color]:
	match origin_id:
		"tide_listener":
			return [Color(0.20, 0.78, 0.96, 0.34), Color(0.70, 0.96, 1.0), Color(0.40, 0.70, 1.0, 0.86)]
		"herb_reader":
			return [Color(0.38, 0.92, 0.54, 0.34), Color(0.78, 1.0, 0.68), Color(0.32, 0.76, 0.44, 0.86)]
		"forge_watcher":
			return [Color(1.0, 0.48, 0.18, 0.32), Color(1.0, 0.84, 0.52), Color(0.92, 0.42, 0.20, 0.88)]
		"storm_walker":
			return [Color(0.70, 0.64, 1.0, 0.32), Color(0.90, 0.90, 1.0), Color(0.54, 0.48, 0.96, 0.88)]
		_:
			return [Color(0.94, 0.70, 1.0, 0.30), Color(1.0, 0.86, 1.0), Color(0.84, 0.50, 0.92, 0.88)]


func _resolve_personal_story_resonance() -> void:
	if personal_resonance == null or personal_resonance_profile.is_empty():
		return
	var trace := str(personal_resonance_profile.get("story_trace", ""))
	var name := str(personal_resonance_profile.get("name", "岚潮续响"))
	var description := str(personal_resonance_profile.get("description", ""))
	GameState.record_opportunity({
		"region": "mist_border", "name": name, "kind": "personal_border_resonance", "story_trace": trace,
	})
	GameState.record_personal_story_branch(
		str(personal_resonance_profile.get("branch_id", "mist_border_resonance")),
		str(personal_resonance_profile.get("branch_title", name)),
		description
	)
	var story: Dictionary = GameState.player.story_weave
	var marks: Array = story.get("personal_marks", [])
	if not marks.has("border_resonance"):
		marks.append("border_resonance")
	story.personal_marks = marks
	GameState.player.story_weave = story
	GameState.profile_changed.emit()
	status.text = "%s\n（这段续响来自你的命途起点；它记录你的理解，不要求你追随某个势力或完成固定任务。）" % description
	personal_resonance.set_deferred("monitoring", false)
	personal_resonance.get_parent().visible = false
	_close_interaction()


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
		_return_to_village()


func _process(_delta: float) -> void:
	_update_sector_presence()


func _exit_tree() -> void:
	if player != null:
		GameState.remember_region_position("mist_border", player.position)
	OnlineSession.detach_world(self)


func _setup_online_presence() -> void:
	var layer: RemoteAvatarLayer = RemoteAvatarLayerScript.new()
	layer.name = "RemoteAvatarLayer"
	add_child(layer)
	layer.configure("mist_border")
	OnlineSession.attach_world("mist_border", player, self)


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
	else:
		world_encounter.use_action(action_id)

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
	elif active_interaction == tideward_watchstone_interaction and not tideward_watchstone_observed:
		_observe_tideward_watchstone()
	elif active_interaction == personal_resonance:
		_resolve_personal_story_resonance()
	elif personal_opportunities != null and personal_opportunities.owns(active_interaction):
		personal_opportunities.resolve(active_interaction)
		_close_interaction()
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
			"story_trace": "water", "story_note": "雾渠的水痕在石岸形成反向潮线，像有另一片水域正隔着雾潮回应。",
			"tint": Color(0.72, 0.95, 0.86), "label_color": Color(0.74, 1.0, 0.89),
		},
		{
			"id": "mist_ore_rogue", "region": "mist_border", "kind": "rogue", "name": "采雾散修",
			"prompt": "向采雾散修打听矿脉", "chance": 0.48,
			"anchors": [Vector2(3860, 1190), Vector2(4060, 1260), Vector2(4280, 1160)],
			"story_trace": "relic", "story_note": "矿滩碎石上的旧器纹并非天然裂纹，采雾散修也无法说清它们的来处。",
			"tint": Color(0.78, 0.83, 0.94), "label_color": Color(0.81, 0.87, 1.0),
		},
		{
			"id": "checkpoint_watcher", "region": "mist_border", "kind": "rogue", "name": "边关巡修",
			"prompt": "询问边关巡修的雾潮消息", "chance": 0.35,
			"anchors": [Vector2(760, 980), Vector2(880, 1060)],
			"story_trace": "road", "story_note": "边关巡修提到，最近有未入关的车辙在旧商道尽头凭空消失。",
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
		# Personal main-line witnesses stay bound to their believable local ecology.
		# They are not quest dispensers: meeting one only records a lived piece of
		# evidence for the player's current interpretation of the shared mystery.
		{
			"id": "mist_border_refuge_patrol", "region": "mist_border", "kind": "rogue", "name": "避潮护路修",
			"prompt": "询问护路修关于旧关外避潮车队的去向", "chance": 0.62,
			"anchors": [Vector2(1140, 880), Vector2(1480, 1050), Vector2(1720, 940)],
			"story_stance": "mender", "story_trace": "road",
			"story_note": "旧关外的避潮车队没有失踪；护路修沿着被雾潮改写的旧驿线，把迷路的凡人和药农送回了安全地带。",
			"story_branch": "mender_border_refuge_route", "story_branch_title": "旧关避潮簿",
			"story_branch_description": "你在旧关外留下了避潮车队的路线：守界并非封闭道路，而是让仍在路上的人能平安回家。",
			"tint": Color(0.78, 0.87, 0.96), "label_color": Color(0.84, 0.92, 1.0),
		},
		{
			"id": "mist_border_ore_surveyor", "region": "mist_border", "kind": "rogue", "name": "量纹寻矿师",
			"prompt": "比对寻矿师拓下的倒纹与旧器碎片", "chance": 0.50,
			"anchors": [Vector2(4520, 1300), Vector2(4860, 1540), Vector2(5140, 1180)],
			"story_stance": "seeker", "story_trace": "relic",
			"story_note": "矿滩的倒纹与旧器底部的坐标并不指向宝藏，而指向一条被岚潮暂时显出的旧界测线。",
			"story_branch": "seeker_border_ore_survey", "story_branch_title": "倒纹测线图",
			"story_branch_description": "你把矿滩倒纹与残器坐标并列记录：旧界并非传说，它曾以可测量的方式经过这里。",
			"tint": Color(0.86, 0.80, 0.96), "label_color": Color(0.92, 0.86, 1.0),
		},
		{
			"id": "mist_border_wetland_scribe", "region": "mist_border", "kind": "rogue", "name": "湿泽记潮人",
			"prompt": "翻看记潮人记录的药性、水位与兽迹", "chance": 0.46,
			"anchors": [Vector2(7420, 920), Vector2(7780, 1080), Vector2(8120, 1220)],
			"story_stance": "witness", "story_trace": "water",
			"story_note": "同一场雾潮令药草提前开花、浅泽水位倒涨，也把惧水的兽迹推向高处；变化正在同时改写生计与生灵。",
			"story_branch": "witness_border_wetland_log", "story_branch_title": "湿泽七潮录",
			"story_branch_description": "你补全了湿泽的一段连续记录：先看清改变了谁、如何改变，才谈得上要不要干预。",
			"tint": Color(0.75, 0.95, 0.86), "label_color": Color(0.82, 1.0, 0.91),
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
	var first_meeting := GameState.meet_npc("柳朔")
	var personal_reflection := GameState.npc_personal_reflection("柳朔")
	if scout_dialogue_stage == 0:
		scout_dialogue_stage = 1
		status.text = "边境探子·柳朔：雾潮会随着时辰退涨。北面的雾林从炼气二层起便可试探，但仍需稳住根基；盲目闯入只会被雾路带偏。" + ("\n（柳朔已记入万物图鉴与游历簿；这不是接取任务。）" if first_meeting else "")
		prompt.text = "[E] 再问柳朔"
		if not personal_reflection.is_empty():
			status.text += "\n【你的见闻】%s" % str(personal_reflection.get("description", ""))
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


func _observe_tideward_watchstone() -> void:
	tideward_watchstone_observed = true
	$TidewardWatchstone/Interaction.set_deferred("monitoring", false)
	GameState.add_item("潮痕石片")
	GameState.gain_cultivation(6)
	GameState.record_opportunity({
		"region": "mist_border", "name": "断潮观石", "kind": "highland_landmark", "item": "潮痕石片",
	})
	status.text = "断潮观石残留着观海修士的潮汐刻度。你取下可用于炼器辨潮的潮痕石片，修为 +6。这里不会刷成营地：丘陵只留下这一处可辨认的远望地标。"
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _try_enter_mist_forest() -> void:
	if not can_enter_mist_forest():
		status.text = "雾林结界只回应炼气二层以上的修士。你可继续水府试炼、采集与修炼来稳固根基。"
		return
	if not GameState.try_begin_fixed_dungeon("mist_forest"):
		status.text = GameState.fixed_dungeon_entry_block_text()
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
	if not GameState.try_begin_fixed_dungeon("sunken_boat"):
		status.text = GameState.fixed_dungeon_entry_block_text()
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
	GameState.unlock_region("ancient_ridge")
	GameState.selected_dungeon_id = "ancient_battlefield"
	get_tree().change_scene_to_file("res://scenes/ancient_ridge.tscn")

func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_village() -> void:
	GameState.current_region_id = "starter_village"
	get_tree().change_scene_to_file("res://scenes/yunlan_outskirts.tscn")
