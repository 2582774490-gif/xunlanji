class_name SpatialTestPlayer
extends CharacterBody2D

## First spatial-avatar test for Yunlan South Gate.  The body is an 8-way
## atlas, while this root node is the single "feet" point used by Godot's
## Y-sort, collision and future weapon/costume child slots.
const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_idle_8dir_v01_alpha.png")

@export var move_speed := 250.0
@export var map_bounds := Rect2(48.0, 48.0, 1576.0, 844.0)

@onready var body: FrameAnimationController = $Body

var _moving := false
var _elapsed := 0.0

func _ready() -> void:
	body.configure_from_grid(IDLE_SHEET, 4, 2, {
		"idle_south": {"frames": [0], "fps": 1.0, "loop": true},
		"idle_south_west": {"frames": [1], "fps": 1.0, "loop": true},
		"idle_west": {"frames": [2], "fps": 1.0, "loop": true},
		"idle_north_west": {"frames": [3], "fps": 1.0, "loop": true},
		"idle_north": {"frames": [4], "fps": 1.0, "loop": true},
		"idle_north_east": {"frames": [5], "fps": 1.0, "loop": true},
		"idle_east": {"frames": [6], "fps": 1.0, "loop": true},
		"idle_south_east": {"frames": [7], "fps": 1.0, "loop": true},
	})
	body.play_action("idle", "south")

func _physics_process(delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = movement * move_speed
	move_and_slide()
	position = position.clamp(map_bounds.position, map_bounds.end)
	_moving = movement.length_squared() > 0.001
	if _moving:
		body.play_action("idle", body.direction_from_vector(movement))
	_elapsed += delta
	# This is deliberately only a light locomotion lift.  The actual 8-way walk
	# sheets will replace it; no false attack or walk pose is baked into the map.
	body.position.y = -60.0 + (sin(_elapsed * 12.0) * 1.15 if _moving else 0.0)
