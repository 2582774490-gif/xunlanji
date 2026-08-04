class_name SpatialTestPlayer
extends CharacterBody2D

## First spatial-avatar test for Yunlan South Gate.  The body is an 8-way
## atlas, while this root node is the single "feet" point used by Godot's
## Y-sort, collision and future weapon/costume child slots.
const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_idle_8dir_v01_alpha.png")
const WALK_KEY_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_keypose_8dir_v01_alpha.png")
const WALK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_south_6f_v01_alpha.png")
const ATTACK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_attack_south_6f_v01_alpha.png")
const FEMALE_IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_idle_8dir_v01_alpha.png")
const FEMALE_WALK_KEY_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_keypose_8dir_v01_alpha.png")
const FEMALE_WALK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_south_6f_v01_alpha.png")
const FEMALE_ATTACK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_attack_south_6f_v01_alpha.png")

signal attack_started(direction: String)
signal attack_impact(direction: String)

@export var move_speed := 250.0
@export var map_bounds := Rect2(48.0, 48.0, 1576.0, 844.0)

@onready var body: FrameAnimationController = $Body
@onready var weapon_motion: WeaponMotionController = get_node_or_null("WeaponPivot")

var _moving := false
var _elapsed := 0.0
var _attack_visual_time_left := 0.0
var _attack_lock_time_left := 0.0

func _ready() -> void:
	var idle_sheet := FEMALE_IDLE_SHEET if GameState.player.gender == "女" else IDLE_SHEET
	var walk_sheet := FEMALE_WALK_KEY_SHEET if GameState.player.gender == "女" else WALK_KEY_SHEET
	var south_walk_sheet := FEMALE_WALK_SOUTH_SHEET if GameState.player.gender == "女" else WALK_SOUTH_SHEET
	var south_attack_sheet := FEMALE_ATTACK_SOUTH_SHEET if GameState.player.gender == "女" else ATTACK_SOUTH_SHEET
	body.configure_from_grid(idle_sheet, 4, 2, {
		"idle_south": {"frames": [0], "fps": 1.0, "loop": true},
		"idle_south_west": {"frames": [1], "fps": 1.0, "loop": true},
		"idle_west": {"frames": [2], "fps": 1.0, "loop": true},
		"idle_north_west": {"frames": [3], "fps": 1.0, "loop": true},
		"idle_north": {"frames": [4], "fps": 1.0, "loop": true},
		"idle_north_east": {"frames": [5], "fps": 1.0, "loop": true},
		"idle_east": {"frames": [6], "fps": 1.0, "loop": true},
		"idle_south_east": {"frames": [7], "fps": 1.0, "loop": true},
	})
	for direction_index in FrameAnimationController.DIRECTIONS.size():
		var direction: String = FrameAnimationController.DIRECTIONS[direction_index]
		body.append_mixed_grid_clip("walk_%s" % direction, [
			{"sheet": idle_sheet, "columns": 4, "rows": 2, "frame": direction_index},
			{"sheet": walk_sheet, "columns": 4, "rows": 2, "frame": direction_index},
		], 8.0, true)
	# The back-facing route has a real six-frame cycle. The other seven routes
	# keep their own directional key art while their full sheets are produced.
	body.append_grid_clips(south_walk_sheet, 6, 1, {
		"walk_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	body.append_grid_clips(south_attack_sheet, 6, 1, {
		"attack_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 14.0, "loop": false},
	})
	body.play_action("idle", "south")

func _physics_process(delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = movement * move_speed
	move_and_slide()
	position = position.clamp(map_bounds.position, map_bounds.end)
	_moving = movement.length_squared() > 0.001
	if weapon_motion:
		weapon_motion.update_from_movement(movement, body.direction_from_vector(movement))
	if body.current_action == "attack" and body.is_playing():
		pass
	elif _moving:
		body.play_action("walk", body.direction_from_vector(movement))
	else:
		body.play_action("idle", body.current_direction)
	_elapsed += delta
	_attack_visual_time_left = maxf(0.0, _attack_visual_time_left - delta)
	_attack_lock_time_left = maxf(0.0, _attack_lock_time_left - delta)
	var walk_bob := sin(_elapsed * (18.0 if _moving else 2.0)) * (1.4 if _moving else 0.35)
	var attack_progress := 1.0 - _attack_visual_time_left / 0.16 if _attack_visual_time_left > 0.0 else 0.0
	var attack_lunge := sin(attack_progress * PI) * 4.0
	body.position = Vector2(0.0, -60.0 + walk_bob - attack_lunge)
	var attack_scale := sin(attack_progress * PI) if _attack_visual_time_left > 0.0 else 0.0
	body.scale = Vector2(0.30 * (1.0 + attack_scale * 0.04), 0.30 * (1.0 - attack_scale * 0.03))


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or event.keycode != KEY_J:
		return
	trigger_basic_attack()
	get_viewport().set_input_as_handled()


func trigger_basic_attack() -> void:
	if _attack_lock_time_left > 0.0:
		return
	if weapon_motion:
		weapon_motion.trigger_attack(body.current_direction)
	if body.current_direction == "south":
		body.trigger_attack()
	_attack_visual_time_left = 0.16
	_attack_lock_time_left = 0.43
	attack_started.emit(body.current_direction)
	_emit_attack_impact(body.current_direction)


func perform_dash(facing: Vector2, distance := 116.0) -> void:
	var direction := facing.normalized() if facing.length_squared() > 0.001 else Vector2.DOWN
	position = (position + direction * distance).clamp(map_bounds.position, map_bounds.end)
	velocity = direction * move_speed


func _emit_attack_impact(direction: String) -> void:
	# The sword strike lands near the animated follow-through, so damage feels
	# connected to the visible body and weapon motion instead of to the keypress.
	await get_tree().create_timer(0.16).timeout
	attack_impact.emit(direction)
