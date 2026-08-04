extends SceneTree

func _init() -> void:
	var log_before: int = GameState.player.opportunity_log.size()
	var inventory_before: int = GameState.player.inventory.size()
	var south_gate := preload("res://scenes/yunlan_south_gate.tscn").instantiate()
	root.add_child(south_gate)
	await process_frame
	assert(south_gate.chosen_opportunity.size() > 0, "South Gate should select one opportunity when it loads.")
	assert(south_gate.opportunity_name.text == str(south_gate.chosen_opportunity.title), "World label should follow selected opportunity.")
	south_gate.active_interaction = south_gate.opportunity_interaction
	south_gate._activate_interaction()
	assert(south_gate.opportunity_collected, "Contextual interaction should collect the selected opportunity.")
	assert(not south_gate.get_node("MistStreamOpportunity").visible, "Collected opportunity should leave the scene.")
	assert(GameState.player.inventory.size() == inventory_before + 1, "Every opportunity should provide its configured item.")
	assert(GameState.player.opportunity_log.size() == log_before + 1, "Every opportunity should create one opportunity-log record.")
	quit()
