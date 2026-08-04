extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_random_opportunity()
	await _check_village_routes()
	await _check_water_palace_loop()
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
	palace.queue_free()
	await get_tree().process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
