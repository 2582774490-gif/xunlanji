class_name WorldTestPlayer
extends CharacterBody2D

signal attack_started(direction: String)

const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/player_male_template/processed_alpha/player_male_yunlan_body_idle_8dir_v01_alpha.png")

@export var move_speed := 255.0
@export var map_bounds := Rect2(64.0, 64.0, 3968.0, 2176.0)

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
	animator.play_action("idle", "south")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or event.keycode != KEY_J:
		return
	if weapon_motion:
		weapon_motion.trigger_attack(animator.current_direction)
		attack_started.emit(animator.current_direction)
	get_viewport().set_input_as_handled()

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
	# The complete walk package will replace this eight-direction idle pose.
	# Keeping one identity on screen is preferable to mixing a different test character's frames.
	animator.play_action("idle", direction)
