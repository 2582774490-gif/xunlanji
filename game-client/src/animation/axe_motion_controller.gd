class_name AxeMotionController
extends WeaponMotionController

## The axe is intentionally slower than saber and halberd routes. It rises
## into a brief backswing, then commits to a heavy downward chop.

@export var cleave_duration := 0.34
@export var cleave_lunge_pixels := 13.0

var _cleave_time_left := 0.0
var _cleave_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(19.0, -23.0)
	move_lag_pixels = 10.0
	follow_speed = 10.0
	swing_angle = deg_to_rad(104.0)
	swing_duration = cleave_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_cleave_time_left = cleave_duration
	_cleave_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _cleave_time_left <= 0.0:
		return
	_cleave_time_left = maxf(0.0, _cleave_time_left - delta)
	var progress := 1.0 - _cleave_time_left / cleave_duration
	# A delayed lunge keeps the high-mass chop readable rather than floaty.
	position += _cleave_direction * pow(sin(progress * PI), 1.35) * cleave_lunge_pixels

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
