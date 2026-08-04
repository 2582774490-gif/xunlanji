class_name DuelArena
extends Node2D

## A real local 1v1 control loop for the first playable prototype.  It proves
## movement, attack timing, weapon defense and resolution in the same 2D world
## presentation. It intentionally does not claim networked multiplayer.

@onready var player: SpatialTestPlayer = $Player
@onready var opponent: DuelOpponent = $Opponent
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var opponent_hp_label: Label = $HUD/OpponentHP
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var player_hp := 100
var finished := false


func _ready() -> void:
	player.map_bounds = Rect2(180.0, 220.0, 2700.0, 1500.0)
	player.position = Vector2(1130, 1260)
	opponent.position = Vector2(1880, 980)
	opponent.map_bounds = player.map_bounds
	opponent.configure(player)
	player.attack_impact.connect(_on_player_attack_impact)
	opponent.attack_landed.connect(_on_opponent_attack)
	opponent.defeated.connect(_on_opponent_defeated)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	status.text = "本地论剑原型：左侧摇杆/方向键移动，右侧攻击键或 J 出招。胜负只在本地结算；联网房间与服务端权威尚未接入。"
	_refresh_hud()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_menu()


func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "attack" and not finished:
		player.trigger_basic_attack()


func _on_player_attack_impact(_direction: String) -> void:
	if finished:
		return
	if player.global_position.distance_to(opponent.global_position) > 178.0:
		status.text = "剑势未及对手：贴近后再出招。"
		return
	var profile := GameCatalog.weapon_profile_for_item(GameState.player.equipped_weapon)
	var damage := maxi(8, int(GameState.derived_stats()["攻击"]) / 3 + int(profile.get("bonus", 0)) + 5)
	opponent.take_damage(damage)
	status.text = "%s 命中试剑使，造成 %d 点伤害。" % [GameState.player.equipped_weapon, damage]
	_refresh_hud()


func _on_opponent_attack(raw_damage: int) -> void:
	if finished:
		return
	var profile := GameCatalog.weapon_profile_for_item(GameState.player.equipped_weapon)
	var damage := maxi(2, raw_damage - int(profile.get("counter_reduction", 0)))
	player_hp = maxi(0, player_hp - damage)
	status.text = "试剑使反击命中：%d 点伤害。" % damage
	if player_hp <= 0:
		_finish(false)
	_refresh_hud()


func _on_opponent_defeated() -> void:
	_finish(true)


func _finish(player_won: bool) -> void:
	if finished:
		return
	finished = true
	if player_won:
		GameState.record_opportunity({"region": "yunlan_trial_pavilion", "name": "山门论剑胜利", "kind": "local_pvp_prototype"})
		status.text = "本地论剑胜利。此处不掉落装备、不改变PVP排名；正式PVP结算必须由服务器完成。按 Esc 返回。"
	else:
		status.text = "本地论剑落败。死亡不掉落；按 Esc 返回。"
	_refresh_hud()


func _refresh_hud() -> void:
	player_hp_label.text = "你 · %s　HP %d / 100" % [GameState.player.equipped_weapon, player_hp]
	opponent_hp_label.text = "山门试剑使　HP %d / %d" % [opponent.hp, opponent.max_hp]


func _return_to_menu() -> void:
	GameState.enter_screen(GameState.Screen.PVP)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
