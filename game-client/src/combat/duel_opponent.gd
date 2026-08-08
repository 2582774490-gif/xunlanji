class_name DuelOpponent
extends CharacterBody2D

## Local 1v1 sparring opponent. It can run as an AI for solo testing or as a
## second keyboard-controlled fighter. Real online PVP still replaces this
## local input with a remote, server-authoritative player state.

signal attack_landed(damage: int)
signal defeated()

const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_idle_8dir_v01_alpha.png")
const WALK_KEY_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_keypose_8dir_v01_alpha.png")
const ATTACK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_attack_south_6f_v01_alpha.png")

@export var move_speed := 185.0
@export var max_hp := 100
@export var base_damage := 9
@export var map_bounds := Rect2(180.0, 220.0, 2700.0, 1500.0)
@export var local_controlled := true

@onready var body: FrameAnimationController = $Body

var hp := 100
var target: CharacterBody2D
var _attack_cooldown := 0.0
var _attacking := false
var _hit_flash_time := 0.0
var _guard_time_left := 0.0
var _dash_cooldown := 0.0


func _ready() -> void:
	hp = max_hp
	body.configure_from_grid(IDLE_SHEET, 4, 2, {
		"idle_south": {"frames": [0], "fps": 1.0, "loop": true},
		"idle_south_west": {"frames": [1], "fps": 1.0, "loop": true},
		"idle_west": {"frames": [2], "fps": 1.0, "loop": true},
		"idle_north_west": {"frames": [3], "fps": 1.0, "loop": true},
		"idle_north": {"frames": [4], "fps": 1.0, "loop": true},
		"idle_north_east": {"frames": [5], "fps": 1.0, "loop": true},
		"idle_east": {"frames": [6], "fps": 1.0, "loop": true},
		"idle_south_east": {"frames": [7], "fps": 1.0, "loop": true},
	})
	for direction_index in FrameAnimationController.DIRECTIONS.size():
		var direction: String = FrameAnimationController.DIRECTIONS[direction_index]
		body.append_mixed_grid_clip("walk_%s" % direction, [
			{"sheet": IDLE_SHEET, "columns": 4, "rows": 2, "frame": direction_index},
			{"sheet": WALK_KEY_SHEET, "columns": 4, "rows": 2, "frame": direction_index},
		], 7.0, true)
	body.append_grid_clips(ATTACK_SOUTH_SHEET, 6, 1, {
		"attack_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 13.0, "loop": false},
	})
	body.play_action("idle", "north")


func configure(next_target: CharacterBody2D) -> void:
	target = next_target


func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	var reduced_amount: int = maxi(amount, 0)
	if _guard_time_left > 0.0:
		reduced_amount = ceili(float(reduced_amount) * 0.45)
		_guard_time_left = 0.0
	hp = maxi(0, hp - reduced_amount)
	_hit_flash_time = 0.16
	if hp <= 0:
		velocity = Vector2.ZERO
		defeated.emit()


func _physics_process(delta: float) -> void:
	_hit_flash_time = maxf(0.0, _hit_flash_time - delta)
	modulate = Color(1.0, 0.64, 0.64) if _hit_flash_time > 0.0 else Color.WHITE
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_guard_time_left = maxf(0.0, _guard_time_left - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	if hp <= 0 or target == null:
		return
	if local_controlled:
		_process_local_controls(delta)
		return
	var offset := target.global_position - global_position
	var direction := offset.normalized() if offset.length_squared() > 0.001 else Vector2.DOWN
	var facing := body.direction_from_vector(direction)
	if offset.length() > 158.0:
		velocity = direction * move_speed
		move_and_slide()
		position = position.clamp(map_bounds.position, map_bounds.end)
		if not _attacking:
			body.play_action("walk", facing)
		return
	velocity = Vector2.ZERO
	if not _attacking:
		body.play_action("idle", facing)
	if _attack_cooldown <= 0.0 and not _attacking:
		_perform_attack(facing)


func _process_local_controls(delta: float) -> void:
	var movement := Vector2(
		float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
		float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
	)
	move_from_local_input(movement, delta)
	if Input.is_key_pressed(KEY_F):
		trigger_local_attack()
	if Input.is_key_pressed(KEY_G):
		trigger_local_dash()
	if Input.is_key_pressed(KEY_R):
		trigger_local_guard()


func move_from_local_input(movement: Vector2, delta: float) -> void:
	if hp <= 0:
		return
	var direction := movement.normalized() if movement.length_squared() > 0.001 else Vector2.ZERO
	velocity = direction * move_speed
	move_and_slide()
	position = position.clamp(map_bounds.position, map_bounds.end)
	if direction.length_squared() > 0.001 and not _attacking:
		body.play_action("walk", body.direction_from_vector(direction))
	elif not _attacking:
		body.play_action("idle", body.current_direction)
	# The parameter deliberately keeps this method deterministic for local
	# input tests and for a later remote-input adapter.
	if delta <= 0.0:
		velocity = Vector2.ZERO


func trigger_local_attack() -> void:
	if hp <= 0 or _attack_cooldown > 0.0 or _attacking:
		return
	var offset := target.global_position - global_position if target != null else Vector2.DOWN
	_perform_attack(body.direction_from_vector(offset))


func trigger_local_dash() -> void:
	if hp <= 0 or _dash_cooldown > 0.0:
		return
	var escape := (global_position - target.global_position).normalized() if target != null else Vector2.DOWN
	if escape.length_squared() < 0.001:
		escape = Vector2.DOWN
	position = (position + escape * 145.0).clamp(map_bounds.position, map_bounds.end)
	_dash_cooldown = 2.8


func trigger_local_guard() -> void:
	if hp <= 0 or _guard_time_left > 0.0:
		return
	_guard_time_left = 2.5


func local_guard_active() -> bool:
	return _guard_time_left > 0.0


func _perform_attack(facing: String) -> void:
	_attacking = true
	_attack_cooldown = 0.95
	if facing == "south":
		body.trigger_attack()
	await get_tree().create_timer(0.23).timeout
	if hp > 0 and target != null and global_position.distance_to(target.global_position) <= 188.0:
		attack_landed.emit(base_damage)
	_attacking = false
