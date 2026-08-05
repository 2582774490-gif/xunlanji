class_name MirrorMotionController
extends WeaponMotionController

## A mirror floats upright and turns its face toward the cast direction. Its
## short tilt on attack is a reflection gesture, not a weapon swing.

@export var reflect_duration := 0.26

var _reflect_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(26.0, -53.0)
	move_lag_pixels = 2.5
	follow_speed = 15.0
	swing_angle = deg_to_rad(13.0)
	swing_duration = reflect_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_reflect_time_left = reflect_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _reflect_time_left <= 0.0:
		return
	_reflect_time_left = maxf(0.0, _reflect_time_left - delta)
	var progress := 1.0 - _reflect_time_left / reflect_duration
	position += Vector2(sin(progress * PI) * 7.0, -sin(progress * PI) * 3.0)
	rotation += sin(progress * PI) * deg_to_rad(5.0)
