class_name SpearMotionController
extends WeaponMotionController

## Long weapons carry their mass differently from swords: the shaft rests
## farther from the body and the attack resolves as a forward thrust instead
## of a broad wrist swing.

@export var thrust_distance := 18.0
@export var thrust_duration := 0.19

var _thrust_time_left := 0.0
var _thrust_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(24.0, -22.0)
	move_lag_pixels = 5.0
	swing_angle = deg_to_rad(10.0)
	swing_duration = thrust_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_thrust_time_left = thrust_duration
	_thrust_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _thrust_time_left <= 0.0:
		return
	_thrust_time_left = maxf(0.0, _thrust_time_left - delta)
	var progress := 1.0 - _thrust_time_left / thrust_duration
	position += _thrust_direction * sin(progress * PI) * thrust_distance

func _direction_vector(direction: String) -> Vector2:
	match direction:
		"north": return Vector2.UP
		"north_east": return Vector2(1, -1).normalized()
		"east": return Vector2.RIGHT
		"south_east": return Vector2(1, 1).normalized()
		"south": return Vector2.DOWN
		"south_west": return Vector2(-1, 1).normalized()
		"west": return Vector2.LEFT
		"north_west": return Vector2(-1, -1).normalized()
	return Vector2.RIGHT
