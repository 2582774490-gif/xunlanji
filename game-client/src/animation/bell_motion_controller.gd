class_name BellMotionController
extends WeaponMotionController

## A ritual bell should hang and answer movement with a small pendulum sway.
## Attacks add a crisp sideways ring instead of borrowing an instrument pluck
## or a sword swing.

@export var ring_duration := 0.26

var _ring_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(20.0, -31.0)
	move_lag_pixels = 4.0
	follow_speed = 15.0
	swing_angle = deg_to_rad(22.0)
	swing_duration = ring_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_ring_time_left = ring_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _ring_time_left <= 0.0:
		return
	_ring_time_left = maxf(0.0, _ring_time_left - delta)
	var progress := 1.0 - _ring_time_left / ring_duration
	rotation += sin(progress * TAU * 1.4) * deg_to_rad(5.0)
