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
	palace.call("_cast_ningxi_sword_art")
	await create_timer(0.35).timeout
	if palace.boss_health >= start_health or palace.player_mana >= start_mana:
		push_error("Ningxi Sword Art did not spend mana and damage the boss.")
		quit(1)
		return

	var start_position: Vector2 = palace.player.position
	palace.call("_cast_cloud_step")
	if palace.player.position == start_position:
		push_error("Cloud Step did not move the player.")
		quit(1)
		return

	palace.call("_cast_lan_breath_guard")
	if palace.guard_time_left <= 0.0:
		push_error("Lan Breath Guard did not enable protection.")
		quit(1)
		return

	palace.player_mana = 0.0
	palace.call("_cast_spirit_nourish")
	if palace.player_mana <= 0.0:
		push_error("Spirit Nourish did not restore mana.")
		quit(1)
		return

	quit(0)
