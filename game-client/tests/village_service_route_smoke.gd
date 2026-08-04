extends SceneTree

func _init() -> void:
	var village := preload("res://scenes/yunlan_village.tscn").instantiate()
	root.add_child(village)
	await process_frame
	assert(village.sect_envoy != null, "Village should contain an independently interactive sect envoy.")
	village._set_context("sect", "test sect route")
	assert(village.active_interaction_id == "sect", "Sect envoy proximity should use the shared contextual route.")
	village._activate_contextual()
	assert(GameState.current_screen == GameState.Screen.SECT, "Sect envoy interaction should enter the existing sect screen.")
	quit()
