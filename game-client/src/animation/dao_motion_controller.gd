class_name DaoMotionController
extends WeaponMotionController

## The saber uses a heavier, wider cut than the sword's quick wrist swing.
## Its curve briefly pulls through the target side before returning to guard.

@export var cut_duration := 0.23
@export var cut_lunge_pixels := 8.0

var _cut_time_left := 0.0
var _cut_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(20.0, -20.0)
	move_lag_pixels = 6.0
	follow_speed = 14.0
	swing_angle = deg_to_rad(66.0)
	swing_duration = cut_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_cut_time_left = cut_duration
	_cut_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _cut_time_left <= 0.0:
		return
	_cut_time_left = maxf(0.0, _cut_time_left - delta)
	var progress := 1.0 - _cut_time_left / cut_duration
	position += _cut_direction * sin(progress * PI) * cut_lunge_pixels

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
