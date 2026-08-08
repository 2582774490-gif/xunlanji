class_name OnlineDuelArena
extends Node2D

## Two-player online sparring vertical slice. The client only submits input;
## position bounds, attack range, cooldown, HP and victory are broadcast from
## the room server. Gear stats are intentionally not trusted in this mode.

const MALE_IDLE: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_idle_8dir_v01_alpha.png")
const FEMALE_IDLE: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_idle_8dir_v01_alpha.png")

@onready var player: SpatialTestPlayer = $Player
@onready var opponent: Node2D = $Opponent
@onready var opponent_sprite: Sprite2D = $Opponent/Body
@onready var opponent_name: Label = $Opponent/Name
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var opponent_hp_label: Label = $HUD/OpponentHP
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var duel_id := ""
var remote_peer_id := ""
var send_elapsed := 0.0
var finished := false
var latest_state: Dictionary = {}


func _ready() -> void:
	var duel := OnlineSession.active_duel_for_local()
	if duel.is_empty():
		_return_to_menu("未找到可进入的联机论剑会话。")
		return
	duel_id = str(duel.get("id", ""))
	remote_peer_id = str(duel.get("targetId", "")) if str(duel.get("challengerId", "")) == OnlineSession.local_peer_id() else str(duel.get("challengerId", ""))
	player.map_bounds = Rect2(180.0, 220.0, 2700.0, 1500.0)
	player.attack_impact.connect(_on_player_attack_impact)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	OnlineSession.duel_state_changed.connect(_on_duel_state_changed)
	_configure_remote_avatar()
	status.text = "联机论剑：移动、攻击距离、冷却、血量与胜负由本机房间服务端裁定。J 或右侧普攻出剑；2–5 为服务器裁定的论剑技。Esc 返回论剑台。"
	var cached := OnlineSession.duel_state(duel_id)
	if not cached.is_empty():
		_apply_state(cached)
	else:
		OnlineSession.send_duel_move(duel_id, player.position, "south")


func _exit_tree() -> void:
	if OnlineSession.duel_state_changed.is_connected(_on_duel_state_changed):
		OnlineSession.duel_state_changed.disconnect(_on_duel_state_changed)


func _process(delta: float) -> void:
	if duel_id.is_empty() or finished:
		return
	send_elapsed += delta
	if send_elapsed >= 0.10:
		send_elapsed = 0.0
		OnlineSession.send_duel_move(duel_id, player.position, player.body.current_direction)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_menu("")
		get_viewport().set_input_as_handled()
		return
	if event.keycode >= KEY_2 and event.keycode <= KEY_5:
		_request_skill()
		get_viewport().set_input_as_handled()


func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "attack":
		player.trigger_basic_attack()
	else:
		_request_skill()


func _on_player_attack_impact(_direction: String) -> void:
	if finished or not OnlineSession.send_duel_action(duel_id, "basic"):
		return
	status.text = "你已出剑，等待服务端核验距离与收势。"


func _request_skill() -> void:
	if finished or not OnlineSession.send_duel_action(duel_id, "skill"):
		return
	status.text = "你施展论剑技，等待服务端核验距离与冷却。"


func _on_duel_state_changed(next_state: Dictionary) -> void:
	if str(next_state.get("id", "")) != duel_id:
		return
	_apply_state(next_state)


func _apply_state(next_state: Dictionary) -> void:
	latest_state = next_state.duplicate(true)
	var fighters: Variant = latest_state.get("fighters", {})
	if not fighters is Dictionary:
		return
	var local: Variant = fighters.get(OnlineSession.local_peer_id(), {})
	var remote: Variant = fighters.get(remote_peer_id, {})
	if local is Dictionary:
		player.position = Vector2(float(local.get("x", player.position.x)), float(local.get("y", player.position.y)))
		player_hp_label.text = "你 · 公平论剑法 HP %d / 100" % int(local.get("hp", 0))
	if remote is Dictionary:
		var target := Vector2(float(remote.get("x", opponent.position.x)), float(remote.get("y", opponent.position.y)))
		opponent.position = opponent.position.lerp(target, 0.72) if opponent.position.length_squared() > 1.0 else target
		opponent_hp_label.text = "%s　HP %d / 100" % [opponent_name.text, int(remote.get("hp", 0))]
		_set_remote_direction(str(remote.get("direction", "south")))
	if str(latest_state.get("status", "")) == "finished":
		finished = true
		var won := str(latest_state.get("winnerId", "")) == OnlineSession.local_peer_id()
		status.text = "服务端结算：%s。论剑不掉落物品，不改变装备与交易数据；按 Esc 返回。" % ("你胜出" if won else "你落败")


func _configure_remote_avatar() -> void:
	var remote_profile: Dictionary = {}
	for profile in OnlineSession.remote_players():
		if str(profile.get("id", "")) == remote_peer_id:
			remote_profile = profile
			break
	opponent_sprite.texture = FEMALE_IDLE if str(remote_profile.get("gender", "male")) == "female" else MALE_IDLE
	opponent_name.text = str(remote_profile.get("name", "远游修士"))
	_set_remote_direction("south")


func _set_remote_direction(direction: String) -> void:
	var texture_size := opponent_sprite.texture.get_size()
	var cell_size := Vector2(texture_size.x / 4.0, texture_size.y / 2.0)
	var index: int = int({"south": 0, "south_west": 1, "west": 2, "north_west": 3, "north": 4, "north_east": 5, "east": 6, "south_east": 7}.get(direction, 0))
	opponent_sprite.region_rect = Rect2(Vector2(float(index % 4) * cell_size.x, float(index / 4) * cell_size.y), cell_size)


func _return_to_menu(notice: String) -> void:
	if not notice.is_empty():
		GameState.notify(notice)
	GameState.enter_screen(GameState.Screen.PVP)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
