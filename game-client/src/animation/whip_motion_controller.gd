class_name WhipMotionController
extends WeaponMotionController

## A whip snaps ahead, then recoils. Its quick forward reach and recoil are
## distinct from the staff's revolving guard and the spear's straight thrust.

@export var snap_duration := 0.21
@export var snap_lunge_pixels := 11.0

var _snap_time_left := 0.0
var _snap_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(20.0, -20.0)
	move_lag_pixels = 8.0
	follow_speed = 16.0
	swing_angle = deg_to_rad(84.0)
	swing_duration = snap_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_snap_time_left = snap_duration
	_snap_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _snap_time_left <= 0.0:
		return
	_snap_time_left = maxf(0.0, _snap_time_left - delta)
	var progress := 1.0 - _snap_time_left / snap_duration
	# Forward on the crack, then a small recoil during the return half.
	var reach := sin(progress * PI) * snap_lunge_pixels
	position += _snap_direction * reach

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
