class_name ArrayDiskMotionController
extends WeaponMotionController

## The array disk remains flat near the caster and spins forward for a brief
## deployment moment. It is neither a shield block nor a floating artifact.

@export var deploy_duration := 0.30

var _deploy_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(17.0, -34.0)
	move_lag_pixels = 2.5
	follow_speed = 18.0
	swing_angle = deg_to_rad(28.0)
	swing_duration = deploy_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_deploy_time_left = deploy_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _deploy_time_left <= 0.0:
		return
	_deploy_time_left = maxf(0.0, _deploy_time_left - delta)
	var progress := 1.0 - _deploy_time_left / deploy_duration
	rotation += delta * TAU * (2.5 - progress)
	position += Vector2(0.0, -sin(progress * PI) * 5.0)
