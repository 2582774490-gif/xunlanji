class_name CauldronMotionController
extends WeaponMotionController

## The cauldron floats at the caster's shoulder and settles with a heavy,
## deliberate sway. A cast tilts it forward to pour a line of furnace fire.

@export var pour_duration := 0.30

var _pour_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(32.0, -53.0)
	move_lag_pixels = 3.5
	follow_speed = 12.0
	swing_angle = deg_to_rad(15.0)
	swing_duration = pour_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_pour_time_left = pour_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _pour_time_left <= 0.0:
		return
	_pour_time_left = maxf(0.0, _pour_time_left - delta)
	var progress := 1.0 - _pour_time_left / pour_duration
	rotation += sin(progress * PI) * deg_to_rad(7.0)
	position += Vector2(sin(progress * PI) * 7.0, -sin(progress * PI) * 4.0)
