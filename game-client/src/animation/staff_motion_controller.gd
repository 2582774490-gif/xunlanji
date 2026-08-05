class_name StaffMotionController
extends WeaponMotionController

## The staff remains light and mobile. It rotates in a quick figure-eight
## rather than thrusting like a spear or committing to a heavy cleave.

@export var whirl_duration := 0.24
@export var whirl_offset_pixels := 7.0

var _whirl_time_left := 0.0
var _whirl_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(20.0, -21.0)
	move_lag_pixels = 4.0
	follow_speed = 18.0
	swing_angle = deg_to_rad(118.0)
	swing_duration = whirl_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_whirl_time_left = whirl_duration
	_whirl_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _whirl_time_left <= 0.0:
		return
	_whirl_time_left = maxf(0.0, _whirl_time_left - delta)
	var progress := 1.0 - _whirl_time_left / whirl_duration
	var side := Vector2(-_whirl_direction.y, _whirl_direction.x)
	position += side * sin(progress * TAU) * whirl_offset_pixels

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
