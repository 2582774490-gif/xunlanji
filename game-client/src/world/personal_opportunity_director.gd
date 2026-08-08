class_name PersonalOpportunityDirector
extends Node2D

## Generates one private, optional opportunity for a character in a regional
## time window. These are client-local discoveries, not shared monster spawns:
## they make two explorers' routes differ without changing shared ecology,
## combat balance, trade prices, or other players' loot.

const WorldInteractionScript = preload("res://src/world/world_interaction.gd")
const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")

signal focused(interaction: Area2D)
signal unfocused(interaction: Area2D)
signal resolved(summary: String)

const WINDOW_SECONDS := 900

var _entries: Dictionary = {}
var _region_id := ""


func populate(region_id: String, profiles: Array[Dictionary], now_unix: int = -1) -> void:
	_clear()
	_region_id = region_id
	if region_id.is_empty() or profiles.is_empty():
		return
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	var candidates: Array[Dictionary] = []
	for raw_profile in profiles:
		var profile := raw_profile.duplicate(true)
		if not _is_profile_eligible(profile, now):
			continue
		candidates.append(profile)
	if candidates.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	var window := int(floor(float(now) / float(WINDOW_SECONDS)))
	rng.seed = int(GameState.personal_opportunity_seed()) ^ region_id.hash() ^ (window * 7919)
	var profile := candidates[rng.randi_range(0, candidates.size() - 1)]
	if rng.randf() > float(profile.get("chance", 0.82)):
		return
	var anchors: Array = _eligible_anchors(profile)
	if anchors.is_empty():
		return
	var position: Vector2 = anchors[rng.randi_range(0, anchors.size() - 1)]
	_create(profile, position)


func owns(interaction: Area2D) -> bool:
	return _entries.has(interaction)


func active_count() -> int:
	# A branching opportunity may expose two nearby handling choices, but it is
	# still one sparse world event rather than two independent map spawns.
	var roots: Dictionary = {}
	for interaction in _entries:
		if is_instance_valid(interaction) and is_instance_valid(interaction.get_parent()):
			roots[interaction.get_parent()] = true
	return roots.size()


func interaction_for_profile_id(profile_id: String) -> Area2D:
	for interaction in _entries:
		var profile: Dictionary = _entries[interaction]
		if str(profile.get("id", "")) == profile_id:
			return interaction
	return null


func interaction_for_response_id(profile_id: String, response_id: String) -> Area2D:
	for interaction in _entries:
		var profile: Dictionary = _entries[interaction]
		if str(profile.get("id", "")) == profile_id and str(profile.get("response_id", "")) == response_id:
			return interaction
	return null


func resolve(interaction: Area2D, now_unix: int = -1) -> void:
	if not _entries.has(interaction):
		return
	var profile: Dictionary = _entries[interaction]
	var root: Node = interaction.get_parent()
	_remove_entries_for_root(root)
	var now := int(Time.get_unix_time_from_system()) if now_unix < 0 else now_unix
	var profile_id := str(profile.get("id", ""))
	GameState.mark_ecology_profile_resolved(_region_id, "personal_opportunity_%s" % profile_id, int(profile.get("respawn_seconds", 3600)), now)
	var response_title := str(profile.get("response_title", ""))
	var reward := str(profile.get("reward", "一段见闻"))
	if bool(profile.get("gives_item", true)) and not reward.is_empty():
		GameState.add_item(reward)
	var cultivation := int(profile.get("cultivation", 0))
	if cultivation > 0:
		GameState.gain_cultivation(cultivation)
	var name := str(profile.get("name", "偶遇机缘"))
	if not response_title.is_empty():
		name += " · " + response_title
	var description := str(profile.get("description", "你在合适的地貌中留下了一段只属于自己的见闻。"))
	GameState.record_opportunity({
		"region": _region_id, "name": name, "kind": "personal_opportunity", "item": reward,
		"cultivation": cultivation, "story_trace": str(profile.get("story_trace", "")), "description": description,
	})
	var branch_id := str(profile.get("story_branch", ""))
	if not branch_id.is_empty():
		GameState.record_personal_story_branch(branch_id, str(profile.get("story_branch_title", name)), str(profile.get("story_branch_description", description)))
	var thread_id := str(profile.get("story_thread", ""))
	if not thread_id.is_empty():
		var response_id := str(profile.get("response_id", "resolve"))
		GameState.record_personal_story_thread(thread_id, "personal_opportunity_%s_%s" % [profile_id, response_id], str(profile.get("story_thread_title", name)), str(profile.get("story_thread_description", description)))
	if is_instance_valid(root):
		root.visible = false
	var choice_note := ""
	if not response_title.is_empty():
		choice_note = "\n（你选择：%s。这只记录你的处理方式；另一条可能性并不会从世界中被判定为错误。）" % response_title
	resolved.emit("%s%s\n（这是随你的游历偶然显现的个人机缘；不会替代固定副本、宗门或其他探索道路。）" % [description, choice_note])


func _is_profile_eligible(profile: Dictionary, now_unix: int) -> bool:
	if int(GameState.player.get("realm_index", 0)) < int(profile.get("realm_index", 0)):
		return false
	if int(GameState.player.get("minor_stage", 1)) < int(profile.get("minor_stage", 1)):
		return false
	return GameState.is_ecology_profile_available(_region_id, "personal_opportunity_%s" % str(profile.get("id", "")), now_unix)


func _eligible_anchors(profile: Dictionary) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var expected_sector := str(profile.get("sector", ""))
	for raw_anchor in profile.get("anchors", []):
		if not raw_anchor is Vector2:
			continue
		var anchor: Vector2 = raw_anchor
		var sector := RegionalSectorCatalogScript.sector_at(_sector_region_id(), anchor)
		if expected_sector.is_empty() or str(sector.get("id", "")) == expected_sector:
			result.append(anchor)
	return result


func _sector_region_id() -> String:
	# Runtime region ids are player/save ids; the first region's geometry is
	# catalogued under its world-map style name.
	return "yunlan_outskirts" if _region_id == "starter_village" else _region_id


func _create(profile: Dictionary, position: Vector2) -> void:
	var root := Node2D.new()
	root.name = "PersonalOpportunity_%s" % str(profile.get("id", "unknown"))
	root.position = position
	root.y_sort_enabled = true
	add_child(root)
	var tint: Color = profile.get("tint", Color(0.76, 0.94, 0.86))
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([Vector2(-52, -2), Vector2(-14, -14), Vector2(58, -3), Vector2(26, 12), Vector2(-34, 12)])
	shadow.color = Color(0.03, 0.06, 0.07, 0.50)
	root.add_child(shadow)
	var halo := Polygon2D.new()
	halo.polygon = PackedVector2Array([Vector2(0, -112), Vector2(42, -62), Vector2(34, -14), Vector2(0, 6), Vector2(-34, -14), Vector2(-42, -62)])
	halo.color = Color(tint.r, tint.g, tint.b, 0.35)
	root.add_child(halo)
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([Vector2(-15, -15), Vector2(-6, -104), Vector2(0, -146), Vector2(14, -96), Vector2(18, -16), Vector2(0, 2)])
	core.color = tint
	root.add_child(core)
	var label := Label.new()
	label.position = Vector2(-150, -194)
	label.size = Vector2(300, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", tint.lightened(0.28))
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.08))
	label.add_theme_constant_override("outline_size", 5)
	label.text = str(profile.get("name", "偶遇机缘"))
	root.add_child(label)
	var choices: Array = profile.get("choices", [])
	if choices.size() >= 2:
		label.text = "%s · 自行取舍" % str(profile.get("name", "偶遇机缘"))
		for index in choices.size():
			if not choices[index] is Dictionary:
				continue
			var choice: Dictionary = choices[index]
			var entry := _profile_with_choice(profile, choice)
			var offset := Vector2(-78.0 if index % 2 == 0 else 78.0, -44.0)
			_create_interaction(root, entry, offset, str(choice.get("title", "处理此事")))
		return
	_create_interaction(root, profile, Vector2.ZERO)


func _profile_with_choice(profile: Dictionary, choice: Dictionary) -> Dictionary:
	var result := profile.duplicate(true)
	result["response_id"] = str(choice.get("id", "choice"))
	result["response_title"] = str(choice.get("title", "处理此事"))
	for key in ["prompt", "reward", "gives_item", "cultivation", "story_trace", "description", "story_branch", "story_branch_title", "story_branch_description", "story_thread", "story_thread_title", "story_thread_description"]:
		if choice.has(key):
			result[key] = choice[key]
	# A choice that explicitly supplies a material is collectible by default,
	# even when its parent event was a lore-only discovery.
	if choice.has("reward") and not choice.has("gives_item"):
		result["gives_item"] = true
	return result


func _create_interaction(root: Node2D, profile: Dictionary, local_position := Vector2.ZERO, choice_label := "") -> void:
	var interaction := Area2D.new()
	interaction.name = "Interaction_%s" % str(profile.get("response_id", "main"))
	interaction.position = local_position
	interaction.set_script(WorldInteractionScript)
	interaction.interaction_id = "personal_opportunity_%s_%s" % [str(profile.get("id", "unknown")), str(profile.get("response_id", "main"))]
	interaction.prompt_text = str(profile.get("prompt", "探查这处个人机缘"))
	root.add_child(interaction)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 58.0 if not choice_label.is_empty() else 82.0
	collision.shape = shape
	collision.position = Vector2(0, -66)
	interaction.add_child(collision)
	if not choice_label.is_empty():
		var label := Label.new()
		label.position = Vector2(-92, -160)
		label.size = Vector2(184, 34)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.70))
		label.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.07))
		label.add_theme_constant_override("outline_size", 5)
		label.text = "[ %s ]" % choice_label
		interaction.add_child(label)
	interaction.focused.connect(func(_ignored: Area2D): focused.emit(interaction))
	interaction.unfocused.connect(func(_ignored: Area2D): unfocused.emit(interaction))
	_entries[interaction] = profile


func _remove_entries_for_root(root: Node) -> void:
	var related: Array[Area2D] = []
	for candidate in _entries:
		if candidate is Area2D and is_instance_valid(candidate) and candidate.get_parent() == root:
			related.append(candidate)
	for candidate in related:
		_entries.erase(candidate)
		candidate.set_deferred("monitoring", false)


func _clear() -> void:
	var roots: Dictionary = {}
	for interaction in _entries:
		if is_instance_valid(interaction) and is_instance_valid(interaction.get_parent()):
			roots[interaction.get_parent()] = true
	for root in roots:
		if is_instance_valid(root):
			root.queue_free()
	_entries.clear()
