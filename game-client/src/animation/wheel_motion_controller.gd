class_name WheelMotionController
extends WeaponMotionController

## The wheel hovers beside the caster and spins up before it is thrown.  The
## held sprite never pretends to be a sword; the actual ranged return is drawn
## by WheelReturnEffect in combat scenes.

@export var throw_duration := 0.28

var _throw_time_left := 0.0
var _elapsed := 0.0

func _ready() -> void:
	hand_offset = Vector2(35.0, -48.0)
	move_lag_pixels = 1.8
	follow_speed = 17.0
	swing_angle = deg_to_rad(18.0)
	swing_duration = throw_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_throw_time_left = throw_duration

func _process(delta: float) -> void:
	_elapsed += delta
	super._process(delta)
	rotation += delta * 2.6
	if _throw_time_left <= 0.0:
		return
	_throw_time_left = maxf(0.0, _throw_time_left - delta)
	var progress := 1.0 - _throw_time_left / throw_duration
	position += Vector2(sin(progress * PI) * 14.0, -sin(progress * PI) * 4.0)
