class_name PuppetMotionController
extends WeaponMotionController

## A puppet is a companion unit, not something held by the hand. It hovers at
## the flank and bobs with the player, then leans forward when commanded.

@export var command_duration := 0.26

var _command_time_left := 0.0
var _elapsed := 0.0

func _ready() -> void:
	hand_offset = Vector2(48.0, -50.0)
	move_lag_pixels = 5.0
	follow_speed = 11.0
	swing_angle = deg_to_rad(10.0)
	swing_duration = command_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_command_time_left = command_duration

func _process(delta: float) -> void:
	_elapsed += delta
	super._process(delta)
	position += Vector2(0.0, sin(_elapsed * 3.4) * 0.7)
	if _command_time_left <= 0.0:
		return
	_command_time_left = maxf(0.0, _command_time_left - delta)
	var progress := 1.0 - _command_time_left / command_duration
	position += Vector2(sin(progress * PI) * 12.0, -sin(progress * PI) * 4.0)
