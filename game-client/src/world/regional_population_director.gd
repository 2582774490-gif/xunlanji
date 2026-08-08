class_name RegionalPopulationDirector
extends Node2D

## Dynamic population uses ecological clusters, not a uniform random grid.
## A region provides only locations that make sense for its roads, water,
## ruins and resource sites.  Each visit then chooses a small subset of them.
const WorldInteractionScript = preload("res://src/world/world_interaction.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")
const SCOUT_TEXTURE: Texture2D = preload("res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png")
const MERCHANT_TEXTURE: Texture2D = preload("res://assets/art/npcs/marketkeeper_luo/processed_alpha/marketkeeper_luo_idle_v01_alpha.png")
const GUIDE_TEXTURE: Texture2D = preload("res://assets/art/npcs/guide_shen/processed_alpha/guide_shen_idle_south_v01_alpha.png")
const BEAST_TEXTURE: Texture2D = preload("res://assets/art/characters/boss_mist_forest_general/processed_alpha/boss_mist_forest_general_v01_alpha.png")
const MIST_CHANNEL_OTTER_TEXTURE: Texture2D = preload("res://assets/art/characters/mist_channel_otter_spirit/processed_alpha/mist_channel_otter_spirit_v01_alpha.png")
const HERB_TEXTURE: Texture2D = preload("res://assets/art/resources/mist_stream_spirit_herb/processed_alpha/mist_stream_spirit_herb_v01_alpha.png")
const CRYSTAL_TEXTURE: Texture2D = preload("res://assets/art/resources/mist_tide_crystal_cluster/processed_alpha/mist_tide_crystal_cluster_v01_alpha.png")
const EARTHFIRE_TEXTURE: Texture2D = preload("res://assets/art/characters/earthfire_spirit_beast/processed_alpha/earthfire_spirit_beast_v01_alpha.png")
const WRAITH_TEXTURE: Texture2D = preload("res://assets/art/characters/boss_sunken_vessel_wraith/processed_alpha/boss_sunken_vessel_wraith_v01_alpha.png")
const XIAOCHAO_TEXTURE: Texture2D = preload("res://assets/art/characters/boss_xiaochao_lansha/slices/boss_xiaochao_lansha_front_v01.png")

signal focused(interaction: Area2D)
signal unfocused(interaction: Area2D)
signal population_resolved(summary: String)
signal hostile_encounter_requested(interaction: Area2D)

var _entries: Dictionary = {}
var _resolved: Dictionary = {}

func populate(seed_value: int, profiles: Array[Dictionary]) -> void:
	_clear_population()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for profile in profiles:
		if not _profile_matches_personal_story(profile):
			continue
		if not GameState.is_ecology_profile_available(str(profile.get("region", "")), str(profile.get("id", ""))):
			continue
		if rng.randf() > float(profile.get("chance", 1.0)):
			continue
		var anchors := _eligible_anchors(profile)
		if anchors.is_empty():
			continue
		var anchor: Vector2 = anchors[rng.randi_range(0, anchors.size() - 1)]
		_create_population_node(profile, anchor)


## Some witnesses only approach a cultivator after they have formed a view of
## the old boundary, traded, crafted, or lived through a sect relationship.
## These are not quest givers: no map pin, reward, or region lock is attached.
## They make the same landscape answer different characters with different
## plausible people and concerns.
func _profile_matches_personal_story(profile: Dictionary) -> bool:
	var required_stance := str(profile.get("story_stance", ""))
	if not required_stance.is_empty() and required_stance != str(GameState.personal_story_stance().get("id", "")):
		return false
	var required_inquiry := str(profile.get("story_inquiry", ""))
	if not required_inquiry.is_empty():
		var inquiry := GameState.personal_story_inquiry()
		if required_inquiry != str(inquiry.get("id", "")) or int(inquiry.get("evidence_count", 0)) <= 0:
			return false
	var records := GameState.personal_story_thread_records()
	var required_record_ids: Array = profile.get("story_requires_any_thread", [])
	if not required_record_ids.is_empty():
		var found_record := false
		for record in records:
			if required_record_ids.has(str(record.get("id", ""))):
				found_record = true
				break
		if not found_record:
			return false
	var required_category := str(profile.get("story_requires_thread_category", ""))
	if not required_category.is_empty():
		var found_category := false
		for record in records:
			if str(record.get("thread", "")) == required_category:
				found_category = true
				break
		if not found_category:
			return false
	return true


func _eligible_anchors(profile: Dictionary) -> Array:
	var anchors: Array = profile.get("anchors", [])
	var sector_id := str(profile.get("sector", _sector_for_profile(str(profile.get("id", "")))))
	if sector_id.is_empty():
		return anchors
	var region_style := str(profile.get("region", ""))
	var eligible: Array = []
	for anchor_variant in anchors:
		if not anchor_variant is Vector2:
			continue
		var anchor: Vector2 = anchor_variant
		var sector := RegionalSectorCatalogScript.sector_at(region_style, anchor)
		if str(sector.get("id", "")) == sector_id:
			eligible.append(anchor)
	return eligible


func _sector_for_profile(profile_id: String) -> String:
	# Launch ecology is intentionally clustered.  Keep this mapping central so a
	# profile cannot silently drift into a visually convenient but illogical zone.
	match profile_id:
		"fog_channel_beast": return "fog_channel"
		"mist_ore_rogue": return "ore_flats"
		"checkpoint_watcher", "mist_sword_patrol", "mist_border_refuge_patrol": return "old_checkpoint"
		"mist_border_ore_surveyor": return "ore_flats"
		"mist_border_wetland_scribe": return "herb_wetland"
		"wetland_mist_herb", "wetland_herbalist": return "herb_wetland"
		"highland_mist_stonebud": return "mist_highlands"
		"yunlan_market_price_reader": return "old_caravan_road"
		"mist_border_temper_surveyor": return "ore_flats"
		"earthfire_hound": return "earthfire_ravine"
		"battlefield_remnant", "relic_seeker": return "ancient_battlefield"
		"ridge_gate_relay_warden": return "ridge_gate"
		"ridge_fragment_cartographer": return "broken_plateau"
		"ridge_ash_ledger_keeper": return "ashen_basins"
		"ridge_pass_wayfarer": return "battlefield_pass"
		"port_merchant", "tide_chart_rogue": return "tide_ledger_quay"
		"port_harbor_listener": return "tide_ledger_quay"
		"wreck_shallows_beast": return "wrecked_shallows"
		"shipyard_rogue": return "shipyard_lane"
		"sea_cave_beast": return "sea_cave_approach"
		"thunder_crag_beast": return "lightning_crags"
		"storm_talisman_rogue": return "storm_shelter_road"
		"terrace_wind_eagle": return "windward_cliffs"
		"terrace_observer": return "observation_path"
		_: return ""

func owns(interaction: Area2D) -> bool:
	return _entries.has(interaction)

func resolve(interaction: Area2D) -> void:
	if not _entries.has(interaction) or _resolved.has(interaction):
		return
	var profile: Dictionary = _entries[interaction]
	var kind := str(profile.get("kind", "wanderer"))
	var name := str(profile.get("name", "陌生修士"))
	if kind == "bandit" or kind == "beast":
		hostile_encounter_requested.emit(interaction)
		return
	var summary := ""
	match kind:
		"resource":
			_resolved[interaction] = true
			var reward := str(profile.get("reward", "野生灵材"))
			GameState.add_item(reward)
			GameState.gain_cultivation(int(profile.get("cultivation", 0)))
			_apply_ecology_cooldown(profile)
			interaction.set_deferred("monitoring", false)
			interaction.get_parent().visible = false
			summary = "在%s采得%s。此处位于对应生态带，下一次刷新仍只会回到湿地、矿脉或山涧等合适地点。" % [name, reward]
		"merchant":
			summary = "%s 分享了一段商路传闻：附近的资源与路口会随时令和人流改变。" % name
		"rogue":
			summary = "%s 留下一句关于地势与机缘的提醒。散修路线不受宗门任务约束。" % name
		"bandit":
			summary = "你发现 %s 的伏击痕迹。暂时可绕行；动态战斗接入后，这里会形成遭遇战。" % name
		"beast":
			summary = "%s 在自己的生态领地活动。暂时可观察或绕开；动态战斗接入后将按领地触发。" % name
		_:
			summary = "%s 的出现为这片区域增加了一条可自由追踪的线索。" % name
	if kind == "resource":
		GameState.record_opportunity({"region": str(profile.get("region", "")), "name": name, "kind": kind, "cultivation": 0})
	else:
		summary += _observe_profile_story(profile)
	population_resolved.emit(summary)

func profile_for(interaction: Area2D) -> Dictionary:
	return _entries.get(interaction, {})

func defeat_hostile(interaction: Area2D) -> void:
	if not _entries.has(interaction) or _resolved.has(interaction):
		return
	_resolved[interaction] = true
	var profile: Dictionary = _entries[interaction]
	var name := str(profile.get("name", "游荡妖物"))
	var reward := str(profile.get("reward", "异兽残材"))
	interaction.set_deferred("monitoring", false)
	interaction.get_parent().visible = false
	_apply_ecology_cooldown(profile)
	GameState.add_item(reward)
	GameState.gain_cultivation(int(profile.get("cultivation", 4)))
	GameState.record_opportunity({"region": str(profile.get("region", "")), "name": name, "kind": "hostile_defeated", "item": reward})
	population_resolved.emit("击退 %s，获得 %s。这里的生态位会在后续时段重新出现。%s" % [name, reward, _observe_profile_story(profile)])

func active_count() -> int:
	return _entries.size()

func interaction_for_profile_id(profile_id: String) -> Area2D:
	for interaction in _entries:
		var profile: Dictionary = _entries[interaction]
		if str(profile.get("id", "")) == profile_id:
			return interaction
	return null


func _observe_profile_story(profile: Dictionary) -> String:
	var trace := str(profile.get("story_trace", ""))
	if not ["water", "road", "relic"].has(trace):
		return ""
	var source_id := "population_%s" % str(profile.get("id", ""))
	var name := str(profile.get("name", "无名线索"))
	var note := str(profile.get("story_note", "你把这段见闻记入游历簿。"))
	var stance_note := str(profile.get("story_stance_note", ""))
	if not stance_note.is_empty():
		note += " " + stance_note
	var observed := GameState.observe_story_source(source_id, {
		"region": str(profile.get("region", "")), "name": name,
		"kind": "story_observation", "story_trace": trace, "description": note,
	})
	var branch_id := str(profile.get("story_branch", ""))
	var branch_recorded := false
	if not branch_id.is_empty():
		branch_recorded = GameState.record_personal_story_branch(branch_id, str(profile.get("story_branch_title", name)), str(profile.get("story_branch_description", note)))
	if not observed and not branch_recorded:
		return ""
	return " 你将这段见闻记为%s。" % note

func _clear_population() -> void:
	for interaction in _entries.keys():
		if is_instance_valid(interaction):
			var root: Node = interaction.get_parent()
			if is_instance_valid(root):
				root.queue_free()
	_entries.clear()
	_resolved.clear()

func _apply_ecology_cooldown(profile: Dictionary) -> void:
	var seconds := GameState.ecology_respawn_seconds(profile)
	if seconds <= 0:
		return
	GameState.mark_ecology_profile_resolved(str(profile.get("region", "")), str(profile.get("id", "")), seconds)

func _create_population_node(profile: Dictionary, anchor: Vector2) -> void:
	var root := Node2D.new()
	root.name = "Dynamic_%s" % str(profile.get("id", "population"))
	root.position = anchor
	root.y_sort_enabled = true
	add_child(root)
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-32, -4), Vector2(0, -13), Vector2(32, -4), Vector2(0, 7)])
	shadow.color = Color(0.02, 0.04, 0.05, 0.48)
	root.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name = "Visual"
	sprite.texture = _texture_for(profile)
	sprite.centered = false
	var texture_size := sprite.texture.get_size()
	sprite.offset = Vector2(-texture_size.x * 0.5, -texture_size.y * 0.75)
	sprite.scale = Vector2(0.135, 0.135)
	sprite.modulate = Color(profile.get("tint", Color.WHITE))
	root.add_child(sprite)
	var label := Label.new()
	label.position = Vector2(-115, -166)
	label.size = Vector2(230, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(profile.get("label_color", Color(0.95, 0.88, 0.70))))
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.08))
	label.add_theme_constant_override("outline_size", 5)
	label.text = str(profile.get("name", "游历者"))
	root.add_child(label)
	var interaction := Area2D.new()
	interaction.name = "Interaction"
	interaction.set_script(WorldInteractionScript)
	interaction.interaction_id = str(profile.get("id", "dynamic_population"))
	interaction.prompt_text = str(profile.get("prompt", "观察此处动静"))
	root.add_child(interaction)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 84.0
	collision.shape = shape
	collision.position = Vector2(0, -72)
	interaction.add_child(collision)
	interaction.focused.connect(func(area: Area2D): focused.emit(area))
	interaction.unfocused.connect(func(area: Area2D): unfocused.emit(area))
	_entries[interaction] = profile

func _texture_for(profile: Dictionary) -> Texture2D:
	# Runtime art follows an ecological identity.  A water妖, mineral bud or
	# earthfire beast therefore no longer borrows a generic monster image just
	# because it is convenient to spawn.  The Codex cards use the same profile.
	match str(profile.get("id", "")):
		"fog_channel_beast", "sea_cave_beast": return MIST_CHANNEL_OTTER_TEXTURE
		"wetland_mist_herb": return HERB_TEXTURE
		"highland_mist_stonebud": return CRYSTAL_TEXTURE
		"earthfire_hound", "thunder_crag_beast": return EARTHFIRE_TEXTURE
		"battlefield_remnant": return WRAITH_TEXTURE
		"wreck_shallows_beast": return XIAOCHAO_TEXTURE
	var kind := str(profile.get("kind", "wanderer"))
	match kind:
		"resource": return HERB_TEXTURE
		"merchant": return MERCHANT_TEXTURE
		"rogue": return SCOUT_TEXTURE
		"bandit": return GUIDE_TEXTURE
		"beast": return BEAST_TEXTURE
		_: return SCOUT_TEXTURE
