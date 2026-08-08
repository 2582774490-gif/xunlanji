class_name AncientRidge
extends Node2D

const WorldMinimapScript = preload("res://src/ui/world_minimap.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const RegionalEnvironmentDepthLayerScript = preload("res://src/world/regional_environment_depth_layer.gd")
const RemoteAvatarLayerScript = preload("res://src/world/remote_avatar_layer.gd")
const PersonalOpportunityDirectorScript = preload("res://src/world/personal_opportunity_director.gd")
const WorldInteractionScript = preload("res://src/world/world_interaction.gd")

const RIDGE_EVENTS := [
	{"name": "地火余温", "item": "赤焰精金", "cultivation": 22, "description": "地火裂缝退去后，岩层露出可炼器的精金。"},
	{"name": "残阵兵魄", "item": "古战印", "cultivation": 19, "description": "古战场残阵还保留着一段行军与布阵之法。"},
	{"name": "断岭风痕", "item": "破风石片", "cultivation": 20, "description": "峡谷长风在断崖刻下遁空前的身法痕迹。"},
]

const PERSONAL_OPPORTUNITY_PROFILES: Array[Dictionary] = [
	{
		"id": "earthfire_cooling_ore", "sector": "earthfire_ravine", "name": "熄火矿心", "prompt": "探查裂谷边尚未散尽热息的矿心", "chance": 0.74,
		"anchors": [Vector2(3060, 1580), Vector2(4780, 1280)], "reward": "赤焰精金", "cultivation": 12, "story_trace": "relic", "realm_index": 3,
		"description": "地火退去后露出的矿心已经冷却，却仍保留着旧日锻台的器纹。它不是首领掉落，只是山脉慢慢冷却时给行者的一次偶遇。",
		"story_branch": "opportunity_earthfire_cooling_ore", "story_branch_title": "熄火矿心", "tint": Color(1.0, 0.54, 0.30),
	},
	{
		"id": "battlefield_broken_banner", "sector": "ancient_battlefield", "name": "残阵旌影", "prompt": "辨认石海间未散的残阵旌影", "chance": 0.70,
		"anchors": [Vector2(8360, 1560), Vector2(9480, 2040)], "reward": "残魂兵符", "cultivation": 13, "story_trace": "relic", "realm_index": 3,
		"description": "断旗投下的影子比旗身多出一列。你从残阵里看见的不是必经战斗，而是一段曾被人为删去的退军路线。",
		"story_branch": "opportunity_battlefield_broken_banner", "story_branch_title": "残阵旌影", "tint": Color(0.92, 0.66, 0.48),
	},
	{
		"id": "windbreak_ancient_map", "sector": "windbreak_ridge", "name": "断风旧图", "prompt": "展开岩缝中未被风蚀尽的旧图", "chance": 0.62,
		"anchors": [Vector2(10380, 1520), Vector2(11400, 2680)], "reward": "破风石片", "cultivation": 11, "story_trace": "road", "realm_index": 3,
		"description": "旧图没有标出宝地，只标记了三段被风墙遮住的撤离线。越接近高阶区域，越能看出旧界曾怎样影响普通修士的生死。",
		"story_branch": "opportunity_windbreak_ancient_map", "story_branch_title": "断风旧图", "tint": Color(0.70, 0.78, 1.0),
	},
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
var personal_opportunities: Variant = null
var personal_resonance: Area2D
var personal_resonance_profile: Dictionary = {}

func _ready() -> void:
	GameState.current_region_id = "ancient_ridge"
	player.map_bounds = Rect2(70, 70, 11860, 7860)
	player.position = GameState.region_position_or("ancient_ridge", Vector2(460, 1660), player.map_bounds)
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


func _setup_personal_opportunities() -> void:
	personal_opportunities = PersonalOpportunityDirectorScript.new()
	personal_opportunities.name = "PersonalOpportunities"
	add_child(personal_opportunities)
	personal_opportunities.focused.connect(_focus_interaction)
	personal_opportunities.unfocused.connect(_unfocus_interaction)
	personal_opportunities.resolved.connect(_on_personal_opportunity_resolved)
	personal_opportunities.populate("ancient_ridge", PERSONAL_OPPORTUNITY_PROFILES)


func _setup_personal_story_resonance() -> void:
	# The third individual observation keeps the launch story from ending at a
	# single beginner-area clue. It appears only after the same character has
	# physically found both earlier resonances in compatible regional terrain.
	var story_state := GameState.personal_story_state()
	if not (story_state.get("personal_marks", []) as Array).has("border_resonance"):
		return
	if (story_state.get("personal_marks", []) as Array).has("ridge_resonance"):
		return
	var origin := GameState.personal_story_profile()
	var resonance: Variant = origin.get("ridge_resonance", {})
	if not resonance is Dictionary or str(resonance.get("region", "")) != "ancient_ridge":
		return
	personal_resonance_profile = (resonance as Dictionary).duplicate(true)
	var position: Vector2 = personal_resonance_profile.get("position", Vector2.ZERO)
	var expected_sector := str(personal_resonance_profile.get("sector", ""))
	var actual_sector := RegionalSectorCatalogScript.sector_at("ancient_ridge", position)
	if position == Vector2.ZERO or str(actual_sector.get("id", "")) != expected_sector:
		push_warning("Ancient Ridge personal resonance had no valid sector anchor.")
		personal_resonance_profile.clear()
		return
	var root := Node2D.new()
	root.name = "PersonalStoryRidgeResonance"
	root.position = position
	root.y_sort_enabled = true
	add_child(root)
	var colors := _personal_resonance_colors(str(origin.get("id", "")))
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-78, 0), Vector2(-36, -16), Vector2(66, -4), Vector2(44, 18), Vector2(-52, 16)])
	shadow.color = Color(0.02, 0.03, 0.05, 0.58)
	root.add_child(shadow)
	var outer_halo := Polygon2D.new()
	outer_halo.polygon = PackedVector2Array([Vector2(0, -190), Vector2(84, -120), Vector2(58, -36), Vector2(0, 16), Vector2(-58, -36), Vector2(-84, -120)])
	outer_halo.color = colors[0]
	root.add_child(outer_halo)
	var inner_shard := Polygon2D.new()
	inner_shard.polygon = PackedVector2Array([Vector2(-22, -18), Vector2(-15, -134), Vector2(0, -214), Vector2(22, -134), Vector2(28, -18), Vector2(0, 8)])
	inner_shard.color = colors[1]
	root.add_child(inner_shard)
	var crest := Polygon2D.new()
	crest.polygon = PackedVector2Array([Vector2(-52, -84), Vector2(0, -138), Vector2(52, -84), Vector2(0, -60)])
	crest.color = colors[2]
	root.add_child(crest)
	var name_label := Label.new()
	name_label.position = Vector2(-176, -264)
	name_label.size = Vector2(352, 32)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", colors[1])
	name_label.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.06))
	name_label.add_theme_constant_override("outline_size", 6)
	name_label.text = str(personal_resonance_profile.get("name", "古脊续响"))
	root.add_child(name_label)
	personal_resonance = Area2D.new()
	personal_resonance.name = "Interaction"
	personal_resonance.set_script(WorldInteractionScript)
	personal_resonance.interaction_id = "ancient_ridge_personal_story_resonance"
	personal_resonance.prompt_text = str(personal_resonance_profile.get("prompt", "静观古脊续响"))
	root.add_child(personal_resonance)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 102.0
	collision.shape = shape
	collision.position = Vector2(0, -92)
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
	var name := str(personal_resonance_profile.get("name", "古脊续响"))
	var description := str(personal_resonance_profile.get("description", ""))
	GameState.record_opportunity({"region": "ancient_ridge", "name": name, "kind": "personal_ridge_resonance", "story_trace": trace})
	GameState.record_personal_story_branch(str(personal_resonance_profile.get("branch_id", "ancient_ridge_resonance")), str(personal_resonance_profile.get("branch_title", name)), description)
	var story: Dictionary = GameState.player.story_weave
	var marks: Array = story.get("personal_marks", [])
	if not marks.has("ridge_resonance"):
		marks.append("ridge_resonance")
	story.personal_marks = marks
	GameState.player.story_weave = story
	GameState.profile_changed.emit()
	status.text = "%s\n（古脊岭的续响延续你的个人命途；它保留一段见闻，不要求进入副本、加入势力或接受任务。）" % description
	personal_resonance.set_deferred("monitoring", false)
	personal_resonance.get_parent().visible = false
	_close_interaction()


func _on_personal_opportunity_resolved(summary: String) -> void:
	status.text = summary

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_border()


func _process(_delta: float) -> void:
	_update_sector_presence()


func _exit_tree() -> void:
	if player != null:
		GameState.remember_region_position("ancient_ridge", player.position)
	OnlineSession.detach_world(self)


func _setup_online_presence() -> void:
	var layer: RemoteAvatarLayer = RemoteAvatarLayerScript.new()
	layer.name = "RemoteAvatarLayer"
	add_child(layer)
	layer.configure("ancient_ridge")
	OnlineSession.attach_world("ancient_ridge", player, self)


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
	elif active_interaction == personal_resonance:
		_resolve_personal_story_resonance()
	elif personal_opportunities != null and personal_opportunities.owns(active_interaction):
		personal_opportunities.resolve(active_interaction)
		_close_interaction()
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
	if not GameState.try_begin_fixed_dungeon("earth_fire"):
		status.text = GameState.fixed_dungeon_entry_block_text()
		return
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
		{"id": "battlefield_remnant", "region": "ancient_ridge", "kind": "beast", "name": "战场残魂", "prompt": "感知古战场残魂的游荡范围", "chance": 0.46, "anchors": [Vector2(7400, 1080), Vector2(7840, 900)], "health": 190, "damage": 24, "reward": "残魂兵符", "cultivation": 25, "story_trace": "relic", "story_note": "残魂兵符的缺口与古战场外侧的断碑刻痕出自同一套失传阵制。", "tint": Color(0.84, 0.63, 0.48), "label_color": Color(1.0, 0.78, 0.58)},
		{"id": "relic_seeker", "region": "ancient_ridge", "kind": "rogue", "name": "守碑散修", "prompt": "询问守碑散修的古战场判断", "chance": 0.36, "anchors": [Vector2(7200, 700), Vector2(7520, 770)], "story_trace": "relic", "story_note": "守碑散修认为碑文并非在记录战事，而是在封存一段仍会回应岚潮的旧界坐标。", "tint": Color(0.76, 0.72, 0.90), "label_color": Color(0.84, 0.80, 1.0)},
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
