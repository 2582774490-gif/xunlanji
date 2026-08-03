class_name WeaponMotionController
extends Node2D

## Keeps a weapon layer visually attached to a moving 2D character without
## making it feel welded to the body. The actual weapon texture is supplied
## later by its weapon card; this component only owns the shared motion logic.

@export var hand_offset := Vector2(20.0, -18.0)
@export var move_lag_pixels := 7.0
@export var follow_speed := 16.0
@export var swing_angle := deg_to_rad(28.0)
@export var swing_duration := 0.16

var _target_position := Vector2.ZERO
var _target_rotation := 0.0
var _attack_time_left := 0.0
var _attack_sign := 1.0


func _ready() -> void:
	position = hand_offset
	_target_position = hand_offset


func update_from_movement(movement: Vector2, direction: String) -> void:
	var normalized := movement.normalized() if movement.length_squared() > 0.001 else Vector2.ZERO
	# The weapon trails slightly against travel, then catches up. This is kept
	# deliberately small so it supports hand-authored frames instead of hiding
	# weak animation with excessive procedural motion.
	_target_position = _hand_offset_for(direction) - normalized * move_lag_pixels
	_target_rotation = _rest_rotation_for(direction)


func trigger_attack(direction: String) -> void:
	_attack_sign = -1.0 if direction.ends_with("west") else 1.0
	_attack_time_left = swing_duration


func _process(delta: float) -> void:
	position = position.lerp(_target_position, minf(delta * follow_speed, 1.0))
	var desired_rotation := _target_rotation
	if _attack_time_left > 0.0:
		_attack_time_left = maxf(0.0, _attack_time_left - delta)
		var progress := 1.0 - _attack_time_left / swing_duration
		desired_rotation += sin(progress * PI) * swing_angle * _attack_sign
	rotation = lerp_angle(rotation, desired_rotation, minf(delta * follow_speed, 1.0))


func _rest_rotation_for(direction: String) -> float:
	if direction.begins_with("north"):
		return deg_to_rad(-16.0)
	if direction.begins_with("south"):
		return deg_to_rad(18.0)
	if direction.ends_with("west") or direction == "west":
		return deg_to_rad(168.0)
	return deg_to_rad(-12.0)


func _hand_offset_for(direction: String) -> Vector2:
	match direction:
		"south": return Vector2(18.0, -8.0)
		"south_east": return Vector2(24.0, -15.0)
		"east": return Vector2(27.0, -20.0)
		"north_east": return Vector2(17.0, -28.0)
		"north": return Vector2(-4.0, -30.0)
		"north_west": return Vector2(-19.0, -26.0)
		"west": return Vector2(-25.0, -18.0)
		"south_west": return Vector2(-19.0, -10.0)
	return hand_offset
