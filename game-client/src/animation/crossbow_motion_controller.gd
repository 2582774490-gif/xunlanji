class_name CrossbowMotionController
extends WeaponMotionController

## The crossbow stays level, then gives a compact recoil and reset. It does
## not draw vertically like the bow or drift broadly like a flexible weapon.

@export var recoil_duration := 0.16
@export var recoil_pixels := 8.0

var _recoil_time_left := 0.0
var _recoil_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(22.0, -28.0)
	move_lag_pixels = 3.0
	follow_speed = 20.0
	swing_angle = deg_to_rad(5.0)
	swing_duration = recoil_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_recoil_time_left = recoil_duration
	_recoil_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _recoil_time_left <= 0.0:
		return
	_recoil_time_left = maxf(0.0, _recoil_time_left - delta)
	var progress := 1.0 - _recoil_time_left / recoil_duration
	position -= _recoil_direction * sin(progress * PI) * recoil_pixels

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
