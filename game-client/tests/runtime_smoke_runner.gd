extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_manual_progression()
	await _check_random_opportunity()
	await _check_village_routes()
	await _check_water_palace_loop()
	await _check_mist_border_scene()
	await _check_mist_bone_creek()
	await _check_mist_forest_grove()
	await _check_sunken_vessel_manor()
	await _check_mist_tide_stone_grotto()
	await _check_red_maple_ancient_road()
	await _check_world_population_encounter()
	await _check_thunder_listening_cliff()
	if failures.is_empty():
		print("RUNTIME_SMOKE_PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check_manual_progression() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	GameState.player.cultivation = GameState.cultivation_threshold() - 1
	GameState.gain_cultivation(20)
	_expect(GameState.player.minor_stage == 1, "Cultivation should not auto-break through when the pool becomes full.")
	_expect(GameState.can_attempt_breakthrough(), "Full cultivation should enable manual breakthrough.")
	_expect(GameState.try_breakthrough(), "Qi Refining small-stage manual breakthrough should succeed without materials.")
	_expect(GameState.player.minor_stage == 2 and GameState.player.cultivation == 0, "Manual small-stage breakthrough did not advance exactly one stage.")
	GameState.player.minor_stage = 10
	GameState.player.cultivation = GameState.cultivation_threshold()
	_expect(not GameState.try_breakthrough(), "Foundation breakthrough should require its dedicated materials.")
	GameState.player.inventory.append("雾林妖丹")
	GameState.player.inventory.append("雾潮晶簇")
	GameState.player.inventory.append("雾潮晶簇")
	GameState.player.inventory.append("雾潮晶簇")
	_expect(GameState.craft_foundation_pill(), "Foundation pill should be craftable from its forest and border materials.")
	_expect(GameState.player.inventory.has("筑基丹"), "Foundation-pill craft did not add the item to inventory.")
	_expect(GameState.try_breakthrough(), "Foundation breakthrough should succeed after materials are prepared.")
	_expect(GameState.player.realm_index == 1 and GameState.player.minor_stage == 1, "Foundation breakthrough did not move to the first Foundation stage.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_random_opportunity() -> void:
	var log_before: int = GameState.player.opportunity_log.size()
	var south_gate := preload("res://scenes/yunlan_south_gate.tscn").instantiate()
	add_child(south_gate)
	await get_tree().process_frame
	_expect(south_gate.chosen_opportunity.size() > 0, "South Gate did not select a random opportunity.")
	south_gate.active_interaction = south_gate.opportunity_interaction
	south_gate._activate_interaction()
	_expect(south_gate.opportunity_collected, "Opportunity interaction did not collect the world object.")
	_expect(GameState.player.opportunity_log.size() == log_before + 1, "Opportunity collection did not write a log record.")
	south_gate.queue_free()
	await get_tree().process_frame

func _check_village_routes() -> void:
	var village := preload("res://scenes/yunlan_village.tscn").instantiate()
	add_child(village)
	await get_tree().process_frame
	_expect(village.sect_envoy != null, "Village is missing the physical sect envoy route.")
	village._set_context("sect", "test")
	_expect(village.active_interaction_id == "sect", "Village sect route did not use the shared contextual interaction path.")
	village.queue_free()
	await get_tree().process_frame

func _check_water_palace_loop() -> void:
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	var palace := preload("res://scenes/mist_stream_water_palace.tscn").instantiate()
	add_child(palace)
	await get_tree().process_frame
	palace.near_boss = true
	var health_before: int = palace.boss_health
	palace._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(palace.boss_health < health_before, "Ningxi Sword Art did not damage the Water Palace boss.")
	palace._defeat_boss()
	await get_tree().process_frame
	_expect(palace.defeated and not palace.boss.visible, "Boss clear did not close the encounter.")
	_expect(palace.clear_panel.visible, "Boss clear did not show a settlement panel.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Boss clear did not grant one initial-equipment drop.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Boss clear did not record the dungeon run.")
	_expect(GameState.is_region_unlocked("mist_border"), "Water Palace clear did not unlock Mist Tide Border.")
	palace.queue_free()
	await get_tree().process_frame

func _check_mist_border_scene() -> void:
	var inventory_before: int = GameState.player.inventory.size()
	var border := preload("res://scenes/mist_tide_border.tscn").instantiate()
	add_child(border)
	await get_tree().process_frame
	_expect(GameState.current_region_id == "mist_border", "Mist Tide Border scene did not set the active region.")
	_expect(border.player.map_bounds.size.x >= 3000.0, "Mist Tide Border did not create a larger regional movement space.")
	_expect(border.return_interaction != null, "Mist Tide Border is missing the return route interaction.")
	_expect(border.scout_interaction != null, "Mist Tide Border is missing its first border-scout NPC route.")
	_expect(border.creek_gate_interaction != null, "Mist Tide Border is missing the Qi Refining third-layer creek entrance.")
	_expect(border.vessel_gate_interaction != null, "Mist Tide Border is missing the Qi Refining fourth-layer vessel entrance.")
	_expect(border.grotto_gate_interaction != null, "Mist Tide Border is missing the Qi Refining fifth-layer grotto entrance.")
	_expect(border.red_maple_gate_interaction != null, "Mist Tide Border is missing the Qi Refining sixth-layer Red Maple Road entrance.")
	_expect(border.thunder_cliff_gate_interaction != null, "Mist Tide Border is missing the Qi Refining seventh-layer Thunder Listening Cliff entrance.")
	_expect(border.player.map_bounds.size.x >= 11000.0, "Mist Tide Border still behaves like a single small background instead of a large region.")
	_expect(border.chunk_streamer.loaded_chunk_count() >= 1, "Mist Tide Border did not load its nearby high-detail terrain chunk.")
	var border_player_start: Vector2 = border.player.position
	border.player.position = Vector2(11200, 7200)
	await get_tree().process_frame
	_expect(not border.get_node("Terrain").visible, "The terrain chunk streamer did not unload far-away high-detail art.")
	border.player.position = border_player_start
	await get_tree().process_frame
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	_expect(not border.can_enter_mist_forest(), "Mist Forest should remain locked for first-layer Qi Refining.")
	GameState.player.minor_stage = 2
	_expect(border.can_enter_mist_forest(), "Mist Forest should open at second-layer Qi Refining.")
	_expect(not border.can_enter_mist_bone_creek(), "Mist Bone Creek should wait until third-layer Qi Refining.")
	GameState.player.minor_stage = 3
	_expect(border.can_enter_mist_bone_creek(), "Mist Bone Creek should open at third-layer Qi Refining.")
	_expect(not border.can_enter_sunken_vessel(), "Sunken Vessel Manor should wait until fourth-layer Qi Refining.")
	GameState.player.minor_stage = 4
	_expect(border.can_enter_sunken_vessel(), "Sunken Vessel Manor should open at fourth-layer Qi Refining.")
	_expect(not border.can_enter_mist_tide_grotto(), "Mist Tide Stone Grotto should wait until fifth-layer Qi Refining.")
	GameState.player.minor_stage = 5
	_expect(border.can_enter_mist_tide_grotto(), "Mist Tide Stone Grotto should open at fifth-layer Qi Refining.")
	_expect(not border.can_enter_red_maple_road(), "Red Maple Road should wait until sixth-layer Qi Refining.")
	GameState.player.minor_stage = 6
	_expect(border.can_enter_red_maple_road(), "Red Maple Road should open at sixth-layer Qi Refining.")
	_expect(not border.can_enter_thunder_cliff(), "Thunder Listening Cliff should wait until seventh-layer Qi Refining.")
	GameState.player.minor_stage = 7
	_expect(border.can_enter_thunder_cliff(), "Thunder Listening Cliff should open at seventh-layer Qi Refining.")
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before
	border.active_interaction = border.scout_interaction
	border._activate_contextual()
	_expect(border.scout_dialogue_stage == 1, "Border scout dialogue did not advance.")
	border.active_interaction = border.crystal_interaction
	border._activate_contextual()
	_expect(border.crystal_collected and not border.get_node("MistTideCrystal").visible, "Border crystal gathering did not remove the resource node.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Border crystal gathering did not add its material to inventory.")
	border.queue_free()
	await get_tree().process_frame

func _check_mist_bone_creek() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 3
	var creek := preload("res://scenes/mist_bone_creek.tscn").instantiate()
	add_child(creek)
	await get_tree().process_frame
	_expect(creek.player.map_bounds.size.x >= 2900.0, "Mist Bone Creek did not create an independent wide exploration space.")
	_expect(creek.chosen_opportunity.size() > 0, "Mist Bone Creek did not select a free-exploration opportunity.")
	creek.active_interaction = creek.opportunity_interaction
	creek._activate_contextual()
	_expect(creek.opportunity_collected, "Mist Bone Creek opportunity did not collect through the shared interaction path.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Mist Bone Creek opportunity did not grant its configured exploration item.")
	_expect(GameState.player.opportunity_log.size() == log_before + 1, "Mist Bone Creek opportunity did not record a world discovery.")
	creek.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_mist_forest_grove() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 2
	var forest := preload("res://scenes/mist_forest_grove.tscn").instantiate()
	add_child(forest)
	await get_tree().process_frame
	_expect(forest.boss_health == 160, "Mist Forest should use its independent higher-health boss configuration.")
	forest.near_boss = true
	forest._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(forest.boss_health < 160, "Mist Forest Ningxi cast did not damage the forest boss.")
	forest._defeat_boss()
	await get_tree().process_frame
	_expect(forest.clear_panel.visible, "Mist Forest clear did not show the settlement panel.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Mist Forest clear did not record a separate dungeon run.")
	_expect(GameState.player.inventory.has("雾林妖丹") and GameState.player.inventory.size() >= inventory_before + 2, "Mist Forest clear should grant an always-available foundation-pill core plus one random reward.")
	forest.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_sunken_vessel_manor() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 4
	var manor := preload("res://scenes/sunken_vessel_manor.tscn").instantiate()
	add_child(manor)
	await get_tree().process_frame
	_expect(manor.boss_health == 220, "Sunken Vessel Manor should use its independent fourth-layer boss configuration.")
	manor.near_boss = true
	manor._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(manor.boss_health < 220, "Sunken Vessel Ningxi cast did not damage its boss.")
	manor._defeat_boss()
	await get_tree().process_frame
	_expect(manor.clear_panel.visible, "Sunken Vessel clear did not show the settlement panel.")
	_expect(GameState.player.inventory.has("沉舟航图残页") and GameState.player.inventory.size() >= inventory_before + 2, "Sunken Vessel clear did not grant a random drop plus the navigation clue.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Sunken Vessel clear did not record its separate dungeon run.")
	manor.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_mist_tide_stone_grotto() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 5
	var grotto := preload("res://scenes/mist_tide_stone_grotto.tscn").instantiate()
	add_child(grotto)
	await get_tree().process_frame
	_expect(grotto.player.map_bounds.size.x >= 2900.0, "Mist Tide Stone Grotto did not create a broad independent cave map.")
	_expect(grotto.chosen_tide_event.size() > 0, "Mist Tide Stone Grotto did not select a tide event.")
	grotto.active_interaction = grotto.mineral_interaction
	grotto._activate_contextual()
	grotto.active_interaction = grotto.tide_interaction
	grotto._activate_contextual()
	grotto.active_interaction = grotto.tunnel_interaction
	grotto._activate_contextual()
	_expect(grotto.mineral_collected and grotto.tide_resolved and grotto.tunnel_searched, "Mist Tide Stone Grotto did not resolve all independent routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 3, "Mist Tide Stone Grotto should grant one result from each optional route.")
	_expect(GameState.player.opportunity_log.size() == log_before + 3, "Mist Tide Stone Grotto did not record all three open-world discoveries.")
	grotto.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_red_maple_ancient_road() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	var gold_before: int = GameState.player.gold
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 6
	GameState.player.gold = max(18, gold_before)
	var road := preload("res://scenes/red_maple_ancient_road.tscn").instantiate()
	add_child(road)
	await get_tree().process_frame
	_expect(road.player.map_bounds.size.x >= 11000.0, "Red Maple Road did not reserve a large regional exploration space.")
	_expect(road.route_event.size() > 0, "Red Maple Road did not choose a road event.")
	_expect(road.regional_population != null, "Red Maple Road is missing its ecological dynamic-population director.")
	_expect(road.chunk_streamer.loaded_chunk_count() >= 1, "Red Maple Road did not load its nearby western terrain chunk.")
	var road_player_start: Vector2 = road.player.position
	road.player.position = Vector2(11200, 7200)
	await get_tree().process_frame
	_expect(not road.get_node("Terrain").visible, "Red Maple Road did not unload far western terrain art.")
	road.player.position = road_player_start
	await get_tree().process_frame
	road.active_interaction = road.ledger_interaction
	road._activate_contextual()
	road.active_interaction = road.escort_interaction
	road._activate_contextual()
	road.active_interaction = road.event_interaction
	road._activate_contextual()
	_expect(road.escort_resolved and road.event_resolved, "Red Maple Road did not resolve its independent optional routes.")
	_expect(GameState.player.inventory.size() >= inventory_before + 3, "Red Maple Road should grant a trade item plus two optional-route results.")
	_expect(GameState.player.opportunity_log.size() == log_before + 2, "Red Maple Road did not record both free-exploration discoveries.")
	road.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before
	GameState.player.gold = gold_before

func _check_world_population_encounter() -> void:
	var inventory_before: int = GameState.player.inventory.size()
	var road := preload("res://scenes/red_maple_ancient_road.tscn").instantiate()
	add_child(road)
	await get_tree().process_frame
	var population := preload("res://src/world/regional_population_director.gd").new()
	var encounter := preload("res://src/world/world_encounter_controller.gd").new()
	var target_label := Label.new()
	var player_label := Label.new()
	road.add_child(population)
	road.add_child(encounter)
	road.add_child(target_label)
	road.add_child(player_label)
	population.populate(7, [{
		"id": "smoke_test_beast", "region": "test", "kind": "beast", "name": "烟测灵獭",
		"prompt": "接近烟测灵獭", "chance": 1.0, "anchors": [road.player.position + Vector2(54, 0)],
		"health": 10, "damage": 1, "reward": "烟测灵皮", "cultivation": 0,
	}])
	encounter.configure(road.player, population, road.status, target_label, player_label)
	await get_tree().process_frame
	var enemy_root: Node2D = population.get_child(0)
	var enemy_interaction: Area2D = enemy_root.get_node("Interaction")
	population.resolve(enemy_interaction)
	_expect(encounter.is_in_encounter(), "A hostile ecological population entry did not begin an overworld encounter.")
	road.player.position = enemy_root.global_position
	encounter._on_player_attack_impact("south")
	_expect(not encounter.is_in_encounter() and not enemy_root.visible, "Overworld basic attack did not defeat the low-health hostile entry.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Overworld hostile defeat did not award its ecological material.")
	road.queue_free()
	await get_tree().process_frame

func _check_thunder_listening_cliff() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 7
	var cliff := preload("res://scenes/thunder_listening_cliff.tscn").instantiate()
	add_child(cliff)
	await get_tree().process_frame
	_expect(cliff.player.map_bounds.size.x >= 11000.0, "Thunder Listening Cliff did not reserve a large weather-exploration region.")
	_expect(cliff.thunder_window.size() > 0, "Thunder Listening Cliff did not choose a weather opportunity.")
	_expect(cliff.chunk_streamer.loaded_chunk_count() >= 1, "Thunder Listening Cliff did not load its nearby terrain chunk.")
	cliff.active_interaction = cliff.pavilion_interaction
	cliff._activate_contextual()
	cliff.active_interaction = cliff.thunder_interaction
	cliff._activate_contextual()
	_expect(cliff.pavilion_visited and cliff.thunder_resolved, "Thunder Listening Cliff did not resolve its shelter and thunder-window routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Thunder Listening Cliff should grant its weather-material outcome.")
	_expect(GameState.player.opportunity_log.size() == log_before + 2, "Thunder Listening Cliff did not record both free-exploration discoveries.")
	cliff.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
