class_name FanMotionController
extends WeaponMotionController

## A folding fan opens through a quick wrist flick and settles into a soft
## breeze-follow. It has no blade-like commitment and remains light in motion.

@export var flick_duration := 0.20

var _flick_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(18.0, -24.0)
	move_lag_pixels = 5.0
	follow_speed = 19.0
	swing_angle = deg_to_rad(54.0)
	swing_duration = flick_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_flick_time_left = flick_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _flick_time_left <= 0.0:
		return
	_flick_time_left = maxf(0.0, _flick_time_left - delta)
	var progress := 1.0 - _flick_time_left / flick_duration
	scale = Vector2(1.0 + sin(progress * PI) * 0.05, 1.0 + sin(progress * PI) * 0.05)
	if _flick_time_left <= 0.0:
		scale = Vector2.ONE
