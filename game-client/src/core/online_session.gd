extends Node

## Development transport for the ten-player room prototype.  It deliberately
## carries presence only: inventory, combat resolution and currency remain
## local until their server-authoritative services are implemented.

signal connection_state_changed(state_text: String)
signal roster_changed(remote_players: Array[Dictionary])
signal remote_position_changed(peer_id: String, player: Dictionary)

const LOCAL_URL := "ws://127.0.0.1:8080"
const DEFAULT_ROOM := "launch-1"
const SEND_INTERVAL := 0.10

var _socket := WebSocketPeer.new()
var _url := ""
var _room_id := DEFAULT_ROOM
var _state_text := "未连接"
var _hello_sent := false
var _peer_id := ""
var _remote_players: Dictionary = {}
var _world_root: Node2D
var _local_player: CharacterBody2D
var _region_id := ""
var _send_elapsed := 0.0


func state_text() -> String:
	return _state_text


func is_room_connected() -> bool:
	return _socket.get_ready_state() == WebSocketPeer.STATE_OPEN and not _peer_id.is_empty()


func remote_players() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for player in _remote_players.values():
		if player is Dictionary:
			result.append((player as Dictionary).duplicate(true))
	return result


func connect_local_room() -> bool:
	return connect_to_room(LOCAL_URL, DEFAULT_ROOM)


func connect_to_room(url: String, room_id: String) -> bool:
	disconnect_room(false)
	_url = url.strip_edges()
	_room_id = room_id.strip_edges() if not room_id.strip_edges().is_empty() else DEFAULT_ROOM
	if _url.is_empty():
		_set_state("未配置联机地址")
		return false
	_socket = WebSocketPeer.new()
	var result := _socket.connect_to_url(_url)
	if result != OK:
		_set_state("连接失败（错误 %d）" % result)
		return false
	_set_state("正在连接十人房…")
	return true


func disconnect_room(show_notice := true) -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_socket.close()
	_socket = WebSocketPeer.new()
	_hello_sent = false
	_peer_id = ""
	_remote_players.clear()
	_emit_roster()
	if show_notice:
		_set_state("未连接")


func attach_world(region_id: String, player: CharacterBody2D, world_root: Node2D) -> void:
	_region_id = region_id
	_local_player = player
	_world_root = world_root
	_send_elapsed = SEND_INTERVAL


func detach_world(world_root: Node2D) -> void:
	if _world_root == world_root:
		_world_root = null
		_local_player = null
		_region_id = ""


func _process(delta: float) -> void:
	_socket.poll()
	var ready_state := _socket.get_ready_state()
	if ready_state == WebSocketPeer.STATE_OPEN:
		if not _hello_sent:
			_send_hello()
		_read_packets()
		_send_elapsed += delta
		if _local_player != null and _send_elapsed >= SEND_INTERVAL:
			_send_elapsed = 0.0
			_send_local_position()
	elif ready_state == WebSocketPeer.STATE_CLOSED and not _url.is_empty() and _state_text.begins_with("正在"):
		_set_state("十人房未启动或连接已断开")


func _send_hello() -> void:
	_hello_sent = true
	_send({
		"type": "hello", "room": _room_id, "name": _local_display_name(),
		"gender": "female" if GameState.player.gender == "女" else "male",
		"region": _region_id if not _region_id.is_empty() else GameState.current_region_id,
	})


func _send_local_position() -> void:
	if not is_room_connected() or _local_player == null:
		return
	var direction := "south"
	if _local_player.velocity.length_squared() > 1.0:
		direction = _direction_name(_local_player.velocity)
	_send({
		"type": "position", "region": _region_id, "x": _local_player.position.x,
		"y": _local_player.position.y, "direction": direction,
	})


func _read_packets() -> void:
	while _socket.get_available_packet_count() > 0:
		var decoded: Variant = JSON.parse_string(_socket.get_packet().get_string_from_utf8())
		if decoded is Dictionary:
			_handle_message(decoded as Dictionary)


func _handle_message(message: Dictionary) -> void:
	match str(message.get("type", "")):
		"welcome":
			_peer_id = str(message.get("peerId", ""))
			_set_state("十人房已连接（%s）" % str(message.get("room", DEFAULT_ROOM)))
		"roster":
			_remote_players.clear()
			var raw_players: Variant = message.get("players", [])
			if raw_players is Array:
				for raw_player in raw_players:
					if raw_player is Dictionary:
						var player: Dictionary = raw_player
						var id := str(player.get("id", ""))
						if not id.is_empty() and id != _peer_id:
							_remote_players[id] = player.duplicate(true)
			_emit_roster()
		"position":
			var player: Variant = message.get("player", {})
			if player is Dictionary:
				var profile: Dictionary = player
				var id := str(profile.get("id", ""))
				if not id.is_empty() and id != _peer_id:
					_remote_players[id] = profile.duplicate(true)
					remote_position_changed.emit(id, profile.duplicate(true))
		"error":
			_set_state("十人房：%s" % ("人数已满" if str(message.get("code", "")) == "room_full" else "通信错误"))


func _emit_roster() -> void:
	roster_changed.emit(remote_players())


func _send(message: Dictionary) -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_socket.send_text(JSON.stringify(message))


func _set_state(next_state: String) -> void:
	if _state_text == next_state:
		return
	_state_text = next_state
	connection_state_changed.emit(_state_text)


func _local_display_name() -> String:
	return "云岚%s修" % ("女" if GameState.player.gender == "女" else "散")


func _direction_name(velocity: Vector2) -> String:
	if absf(velocity.x) > absf(velocity.y):
		return "east" if velocity.x > 0.0 else "west"
	return "south" if velocity.y > 0.0 else "north"
