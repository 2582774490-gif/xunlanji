class_name HalberdMotionController
extends WeaponMotionController

## A halberd is held at distance, then pulled through a wide hooking sweep.
## It deliberately does not reuse the straight thrust of a spear or the short
## blade cut of a saber.

@export var hook_duration := 0.28
@export var hook_pull_pixels := 10.0

var _hook_time_left := 0.0
var _hook_direction := Vector2.RIGHT

func _ready() -> void:
	hand_offset = Vector2(18.0, -23.0)
	move_lag_pixels = 8.0
	follow_speed = 12.0
	swing_angle = deg_to_rad(88.0)
	swing_duration = hook_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_hook_time_left = hook_duration
	_hook_direction = _direction_vector(direction)

func _process(delta: float) -> void:
	super._process(delta)
	if _hook_time_left <= 0.0:
		return
	_hook_time_left = maxf(0.0, _hook_time_left - delta)
	var progress := 1.0 - _hook_time_left / hook_duration
	# First open the distance, then draw the hook back toward the wielder.
	position += _hook_direction * sin(progress * PI) * hook_pull_pixels

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
