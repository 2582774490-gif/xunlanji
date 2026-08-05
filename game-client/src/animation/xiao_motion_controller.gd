class_name XiaoMotionController
extends WeaponMotionController

## The xiao drifts like a breath-held instrument and leans forward only while
## releasing a note. This avoids all polearm and staff strike motion.

@export var breath_duration := 0.22

var _breath_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(18.0, -29.0)
	move_lag_pixels = 3.0
	follow_speed = 17.0
	swing_angle = deg_to_rad(16.0)
	swing_duration = breath_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_breath_time_left = breath_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _breath_time_left <= 0.0:
		return
	_breath_time_left = maxf(0.0, _breath_time_left - delta)
	var progress := 1.0 - _breath_time_left / breath_duration
	position += Vector2(0.0, -sin(progress * PI) * 5.0)
