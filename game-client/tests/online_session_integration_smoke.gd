extends Node2D

func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	OnlineSession.disconnect_room(false)
	if not OnlineSession.connect_local_room():
		push_error("ONLINE_SESSION_SMOKE_FAIL: local connection did not start")
		get_tree().quit(1)
		return
	var deadline := Time.get_ticks_msec() + 4000
	while Time.get_ticks_msec() < deadline and not OnlineSession.is_room_connected():
		await get_tree().process_frame
	if not OnlineSession.is_room_connected():
		push_error("ONLINE_SESSION_SMOKE_FAIL: local room handshake timed out (%s)" % OnlineSession.state_text())
		get_tree().quit(1)
		return
	var player := CharacterBody2D.new()
	player.position = Vector2(640, 420)
	add_child(player)
	OnlineSession.attach_world("starter_village", player, self)
	await get_tree().create_timer(0.22).timeout
	OnlineSession.detach_world(self)
	OnlineSession.disconnect_room(false)
	print("ONLINE_SESSION_SMOKE_PASS")
	get_tree().quit(0)
