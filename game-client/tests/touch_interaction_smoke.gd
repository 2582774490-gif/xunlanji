extends SceneTree

## Confirms exploration maps expose the contextual mobile interaction action
## separately from the Water Palace's combat buttons.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var south_gate = preload("res://scenes/yunlan_south_gate.tscn").instantiate()
	root.add_child(south_gate)
	await process_frame
	var controls: Control = south_gate.get_node("HUD/TouchControls")
	controls.size = Vector2(1280, 720)
	var received_action := ""
	controls.action_requested.connect(func(action_id: String): received_action = action_id)
	controls.call("set_interaction_available", true)
	controls.call("_handle_touch", 4, Vector2(1180, 602), true)
	if received_action != "interact":
		push_error("Exploration interaction button did not emit the interact action.")
		quit(1)
		return
	quit(0)
