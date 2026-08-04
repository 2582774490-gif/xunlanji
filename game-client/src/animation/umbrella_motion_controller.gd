class_name UmbrellaMotionController
extends WeaponMotionController

## An open umbrella is not held like a sword.  It stays above the shoulder,
## turns into a short guard on attack, and has its own defensive rhythm.

@export var guard_duration := 0.28

var _guard_time_left := 0.0
var _facing := "south"


func _ready() -> void:
	position = Vector2(0.0, -58.0)
	_target_position = position


func update_from_movement(movement: Vector2, direction: String) -> void:
	if not direction.is_empty():
		_facing = direction
	var moving := movement.length_squared() > 0.001
	var lateral := -10.0 if _facing.ends_with("west") or _facing == "west" else 10.0
	_target_position = Vector2(lateral, -60.0) - movement.normalized() * (3.0 if moving else 0.0)
	_target_rotation = _rest_rotation_for(_facing)


func trigger_attack(direction: String) -> void:
	_facing = direction
	_guard_time_left = guard_duration


func _process(delta: float) -> void:
	position = position.lerp(_target_position, minf(delta * follow_speed, 1.0))
	_guard_time_left = maxf(0.0, _guard_time_left - delta)
	var guard_progress := _guard_time_left / guard_duration if guard_duration > 0.0 else 0.0
	var facing_sign := -1.0 if _facing.ends_with("west") or _facing == "west" else 1.0
	rotation = lerp_angle(rotation, _target_rotation + guard_progress * 0.16 * facing_sign, minf(delta * follow_speed, 1.0))
	scale = Vector2.ONE * (1.0 + sin(guard_progress * PI) * 0.10)


func _rest_rotation_for(direction: String) -> float:
	if direction.begins_with("north"):
		return deg_to_rad(-7.0)
	if direction.ends_with("west") or direction == "west":
		return deg_to_rad(-18.0)
	if direction.ends_with("east") or direction == "east":
		return deg_to_rad(18.0)
	return deg_to_rad(5.0)
