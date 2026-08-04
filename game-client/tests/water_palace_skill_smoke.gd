extends SceneTree

## Runtime smoke test for the first five-slot dungeon package.  It validates
## the state changes that a startup-only scene check cannot observe.

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var palace = preload("res://scenes/mist_stream_water_palace.tscn").instantiate()
	root.add_child(palace)
	await process_frame
	palace.near_boss = true

	var start_health: int = palace.boss_health
	var start_mana: float = palace.player_mana
	palace.call("_on_touch_action_requested", "ningxi")
	await create_timer(0.35).timeout
	if palace.boss_health >= start_health or palace.player_mana >= start_mana:
		push_error("Ningxi Sword Art did not spend mana and damage the boss.")
		quit(1)
		return

	var start_position: Vector2 = palace.player.position
	palace.call("_on_touch_action_requested", "cloud_step")
	if palace.player.position == start_position:
		push_error("Cloud Step did not move the player.")
		quit(1)
		return

	palace.call("_on_touch_action_requested", "guard")
	if palace.guard_time_left <= 0.0:
		push_error("Lan Breath Guard did not enable protection.")
		quit(1)
		return

	palace.player_mana = 0.0
	palace.call("_on_touch_action_requested", "nourish")
	if palace.player_mana <= 0.0:
		push_error("Spirit Nourish did not restore mana.")
		quit(1)
		return

	var touch_controls: Control = palace.touch_controls
	touch_controls.size = Vector2(1280, 720)
	touch_controls.call("_handle_touch", 7, Vector2(164, 598), true)
	if not Input.is_action_pressed("ui_right"):
		push_error("Virtual joystick did not press the shared right-movement action.")
		quit(1)
		return
	touch_controls.call("_handle_touch", 7, Vector2.ZERO, false)
	if Input.is_action_pressed("ui_right"):
		push_error("Virtual joystick did not release the shared right-movement action.")
		quit(1)
		return

	quit(0)
