class_name WorldTestPlayer
extends CharacterBody2D

const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/player_male_template/processed_alpha/player_male_template_idle_8dir_v01.png")
const WALK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/player_male_template/processed_alpha/player_male_template_walk_south_6f_v01.png")

@export var move_speed := 255.0
@export var map_bounds := Rect2(70.0, 105.0, 1140.0, 550.0)

@onready var animator: FrameAnimationController = $Animation
@onready var weapon_motion: WeaponMotionController = get_node_or_null("WeaponPivot")

func _ready() -> void:
	animator.configure_from_grid(IDLE_SHEET, 4, 2, {
		"idle_south": {"frames": [0], "fps": 1.0, "loop": true},
		"idle_south_west": {"frames": [1], "fps": 1.0, "loop": true},
		"idle_west": {"frames": [2], "fps": 1.0, "loop": true},
		"idle_north_west": {"frames": [3], "fps": 1.0, "loop": true},
		"idle_north": {"frames": [4], "fps": 1.0, "loop": true},
		"idle_north_east": {"frames": [5], "fps": 1.0, "loop": true},
		"idle_east": {"frames": [6], "fps": 1.0, "loop": true},
		"idle_south_east": {"frames": [7], "fps": 1.0, "loop": true},
	})
	animator.append_grid_clips(WALK_SOUTH_SHEET, 3, 2, {
		"walk_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 9.0, "loop": true},
	})
	animator.play_action("idle", "south")

func _physics_process(_delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = movement * move_speed
	move_and_slide()
	position = position.clamp(map_bounds.position, map_bounds.end)
	_update_visual_animation(movement)

func _update_visual_animation(movement: Vector2) -> void:
	if weapon_motion:
		weapon_motion.update_from_movement(movement, animator.direction_from_vector(movement))
	if movement.length_squared() <= 0.001:
		animator.play_action("idle", animator.current_direction)
		return
	var direction := animator.direction_from_vector(movement)
	if direction == "south":
		animator.play_action("walk", "south")
	else:
		# Other directions remain honest idle references until their walk cycles exist.
		animator.play_action("idle", direction)
