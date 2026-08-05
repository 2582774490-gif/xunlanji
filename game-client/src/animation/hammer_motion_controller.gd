class_name HammerMotionController
extends WeaponMotionController

## The hammer has a compact overhead wind-up and a vertical impact rebound.
## Its mass is communicated with a short pause and squash, not a wide axe arc.

@export var impact_duration := 0.31
@export var impact_drop_pixels := 15.0

var _impact_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(18.0, -22.0)
	move_lag_pixels = 11.0
	follow_speed = 9.0
	swing_angle = deg_to_rad(70.0)
	swing_duration = impact_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_impact_time_left = impact_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _impact_time_left <= 0.0:
		return
	_impact_time_left = maxf(0.0, _impact_time_left - delta)
	var progress := 1.0 - _impact_time_left / impact_duration
	# The late drop then rebound makes the impact distinct from a cleaving axe.
	var impact_curve := sin(progress * PI)
	position += Vector2(0.0, impact_curve * impact_drop_pixels)
	scale = Vector2(1.0 + impact_curve * 0.07, 1.0 - impact_curve * 0.05)
	if _impact_time_left <= 0.0:
		scale = Vector2.ONE
