class_name PearlMotionController
extends WeaponMotionController

## The spirit pearl floats on a close orbit rather than sitting in the hand.
## Commands draw it forward briefly, then it settles back into its water-rune
## orbit around the caster.

@export var command_duration := 0.24

var _command_time_left := 0.0
var _elapsed := 0.0

func _ready() -> void:
	hand_offset = Vector2(32.0, -48.0)
	move_lag_pixels = 2.0
	follow_speed = 16.0
	swing_angle = deg_to_rad(14.0)
	swing_duration = command_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_command_time_left = command_duration

func _process(delta: float) -> void:
	_elapsed += delta
	super._process(delta)
	var orbit := Vector2(cos(_elapsed * 2.8) * 2.8, sin(_elapsed * 3.8) * 2.0)
	position += orbit * delta * 2.4
	rotation += delta * 0.75
	if _command_time_left <= 0.0:
		return
	_command_time_left = maxf(0.0, _command_time_left - delta)
	var progress := 1.0 - _command_time_left / command_duration
	position += Vector2(sin(progress * PI) * 12.0, -sin(progress * PI) * 4.0)
