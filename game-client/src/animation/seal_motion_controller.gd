class_name SealMotionController
extends WeaponMotionController

## The heavy ritual seal hangs above the hand. On command it rises slightly
## before a decisive downward stamp, never using a sword-like side swing.

@export var stamp_duration := 0.30

var _stamp_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(27.0, -62.0)
	move_lag_pixels = 4.0
	follow_speed = 12.0
	swing_angle = deg_to_rad(8.0)
	swing_duration = stamp_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_stamp_time_left = stamp_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _stamp_time_left <= 0.0:
		return
	_stamp_time_left = maxf(0.0, _stamp_time_left - delta)
	var progress := 1.0 - _stamp_time_left / stamp_duration
	position += Vector2(sin(progress * PI) * 4.0, -sin(progress * PI) * 12.0 + progress * 10.0)
