extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_random_opportunity()
	await _check_village_routes()
	await _check_water_palace_loop()
	await _check_mist_border_scene()
	await _check_mist_forest_grove()
	if failures.is_empty():
		print("RUNTIME_SMOKE_PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

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
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	_expect(not border.can_enter_mist_forest(), "Mist Forest should remain locked for first-layer Qi Refining.")
	GameState.player.minor_stage = 2
	_expect(border.can_enter_mist_forest(), "Mist Forest should open at second-layer Qi Refining.")
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

func _check_mist_forest_grove() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var runs_before: int = GameState.player.dungeon_runs.size()
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
	forest.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
