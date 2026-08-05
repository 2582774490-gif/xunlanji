class_name BowMotionController
extends WeaponMotionController

## The bow remains upright at the draw hand and tightens briefly before an
## arrow releases.  Its motion is deliberately different from a sword swing
## or a long-spear thrust.

@export var draw_duration := 0.22

var _draw_time_left := 0.0
var _facing := "south"

func _ready() -> void:
	hand_offset = Vector2(20.0, -30.0)
	move_lag_pixels = 3.0
	follow_speed = 18.0
	super._ready()

func update_from_movement(movement: Vector2, direction: String) -> void:
	if not direction.is_empty():
		_facing = direction
	var normalized := movement.normalized() if movement.length_squared() > 0.001 else Vector2.ZERO
	_target_position = _hand_offset_for(_facing) - normalized * move_lag_pixels
	_target_rotation = _rest_rotation_for(_facing)

func trigger_attack(direction: String) -> void:
	_facing = direction
	_draw_time_left = draw_duration

func _process(delta: float) -> void:
	position = position.lerp(_target_position, minf(delta * follow_speed, 1.0))
	_draw_time_left = maxf(0.0, _draw_time_left - delta)
	var draw_progress := _draw_time_left / draw_duration if draw_duration > 0.0 else 0.0
	rotation = lerp_angle(rotation, _target_rotation, minf(delta * follow_speed, 1.0))
	scale = Vector2(1.0 - draw_progress * 0.06, 1.0 + draw_progress * 0.035)

func _rest_rotation_for(direction: String) -> float:
	if direction.begins_with("north"):
		return deg_to_rad(-18.0)
	if direction.ends_with("west") or direction == "west":
		return deg_to_rad(166.0)
	if direction.ends_with("east") or direction == "east":
		return deg_to_rad(12.0)
	return deg_to_rad(4.0)
