class_name TowerMotionController
extends WeaponMotionController

## The miniature pagoda rises in measured layers. A command carries it forward
## slightly while the tower settles as if a heavy ward is being projected.

@export var ward_duration := 0.34

var _ward_time_left := 0.0

func _ready() -> void:
	hand_offset = Vector2(35.0, -61.0)
	move_lag_pixels = 4.5
	follow_speed = 11.0
	swing_angle = deg_to_rad(7.0)
	swing_duration = ward_duration
	super._ready()

func trigger_attack(direction: String) -> void:
	super.trigger_attack(direction)
	_ward_time_left = ward_duration

func _process(delta: float) -> void:
	super._process(delta)
	if _ward_time_left <= 0.0:
		return
	_ward_time_left = maxf(0.0, _ward_time_left - delta)
	var progress := 1.0 - _ward_time_left / ward_duration
	position += Vector2(sin(progress * PI) * 10.0, -sin(progress * PI) * 6.0)
	rotation += sin(progress * PI * 2.0) * deg_to_rad(2.0)
