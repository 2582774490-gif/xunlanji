class_name GuqinMotionController
extends WeaponMotionController

## A guqin floats steadily and shifts only on a short string-pluck impulse.
## Its restrained movement avoids pretending an instrument is a melee weapon.

@export var pluck_duration := 0.18

var _pluck_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(18.0, -32.0)
	move_lag_pixels = 2.0
	follow_speed = 15.0
	swing_angle = deg_to_rad(10.0)
	swing_duration = pluck_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_pluck_time_left = pluck_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _pluck_time_left <= 0.0:
		return
	_pluck_time_left = maxf(0.0, _pluck_time_left - delta)
	var progress := 1.0 - _pluck_time_left / pluck_duration
	position.y -= sin(progress * PI) * 4.0
