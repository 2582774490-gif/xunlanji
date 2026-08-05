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
const QINGHUANG_SWORD_TEXTURE: Texture2D = preload("res://assets/art/weapons/qinghuang_qi_sword/processed_alpha/qinghuang_qi_sword_v01_alpha.png")
const HUIYUN_UMBRELLA_TEXTURE: Texture2D = preload("res://assets/art/weapons/huiyun_qi_umbrella/processed_alpha/huiyun_qi_umbrella_v01_alpha.png")
const WeaponMotionScript = preload("res://src/animation/weapon_motion_controller.gd")
const UmbrellaMotionScript = preload("res://src/animation/umbrella_motion_controller.gd")
const ArtifactMotionScript = preload("res://src/animation/artifact_motion_controller.gd")

signal attack_started(direction: String)
signal attack_impact(direction: String)

@export var move_speed := 250.0
@export var map_bounds := Rect2(48.0, 48.0, 1576.0, 844.0)

@onready var body: FrameAnimationController = $Body
@onready var weapon_motion: WeaponMotionController = get_node_or_null("WeaponPivot")
@onready var artifact_motion: ArtifactMotionController = get_node_or_null("ArtifactPivot")

var _moving := false
var _elapsed := 0.0
var _attack_visual_time_left := 0.0
var _attack_lock_time_left := 0.0
var _rendered_weapon_name := ""
var _rendered_artifact_name := ""
var _rendered_armor_name := ""

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
	GameState.profile_changed.connect(_sync_equipment_layers)
	_sync_equipment_layers()

func _exit_tree() -> void:
	if GameState.profile_changed.is_connected(_sync_equipment_layers):
		GameState.profile_changed.disconnect(_sync_equipment_layers)

func _sync_equipment_layers() -> void:
	var desired_weapon := str(GameState.player.get("equipped_weapon", ""))
	if desired_weapon != _rendered_weapon_name:
		_remove_runtime_layer("WeaponPivot")
		weapon_motion = null
		_rendered_weapon_name = desired_weapon
		_configure_equipped_weapon_visual()
	var desired_artifact := str(GameState.player.get("equipped_artifact", ""))
	if desired_artifact != _rendered_artifact_name:
		_remove_runtime_layer("ArtifactPivot")
		artifact_motion = null
		_rendered_artifact_name = desired_artifact
		_configure_equipped_artifact_visual()
	var desired_armor := str(GameState.player.get("equipped_armor", ""))
	if desired_armor != _rendered_armor_name:
		_remove_runtime_layer("ArmorPivot")
		_rendered_armor_name = desired_armor
		_configure_equipped_armor_visual()

func _remove_runtime_layer(node_name: String) -> void:
	var layer := get_node_or_null(NodePath(node_name))
	if layer == null:
		return
	remove_child(layer)
	layer.queue_free()

func _configure_equipped_weapon_visual() -> void:
	# Each equipped weapon is a runtime child of the player, never part of the
	# terrain art.  Its presentation profile decides which motion controller it
	# owns; unfinished families intentionally stay asset-pending.
	var runtime_profile := GameCatalog.weapon_runtime_profile_for_item(GameState.player.equipped_weapon)
	var motion := str(runtime_profile.get("motion", ""))
	if motion.is_empty():
		return
	var pivot: WeaponMotionController = UmbrellaMotionScript.new() if motion == "defense_umbrella" else WeaponMotionScript.new()
	pivot.name = "WeaponPivot"
	pivot.z_index = 2 if motion == "defense_umbrella" else 3
	add_child(pivot)
	weapon_motion = pivot
	var sprite := Sprite2D.new()
	sprite.name = "WeaponSprite"
	if motion == "defense_umbrella":
		sprite.texture = HUIYUN_UMBRELLA_TEXTURE
		sprite.scale = Vector2(0.092, 0.092)
	else:
		sprite.texture = QINGHUANG_SWORD_TEXTURE
		sprite.scale = Vector2(0.13, 0.13)
		# The source image holds the hilt in its lower-left quadrant. This pins
		# that hilt near the moving hand pivot instead of rotating around center.
		sprite.position = Vector2(50, -50)
	pivot.add_child(sprite)

func _configure_equipped_artifact_visual() -> void:
	# An artifact is its own child layer and can be removed or swapped without
	# altering the body/weapon layers. Every item must name its own approved
	# runtime asset; an unknown artifact is never substituted with another one.
	var artifact_profile := GameCatalog.artifact_profile_for_item(GameState.player.equipped_artifact)
	var asset_path := str(artifact_profile.get("runtime_asset", ""))
	if asset_path.is_empty():
		return
	var artifact_texture := load(asset_path) as Texture2D
	if artifact_texture == null:
		return
	var pivot: ArtifactMotionController = ArtifactMotionScript.new()
	pivot.name = "ArtifactPivot"
	pivot.z_index = 2
	add_child(pivot)
	artifact_motion = pivot
	var sprite := Sprite2D.new()
	sprite.name = "ArtifactSprite"
	sprite.texture = artifact_texture
	var render_scale := float(artifact_profile.get("render_scale", 0.075))
	sprite.scale = Vector2(render_scale, render_scale)
	pivot.add_child(sprite)


func _configure_equipped_armor_visual() -> void:
	# Lightweight armor cards can attach as their own layer while full costume
	# sheets are still produced. They never alter the body atlas or weapon slot.
	var armor_profile := GameCatalog.armor_profile_for_item(str(GameState.player.get("equipped_armor", "")))
	var asset_path := str(armor_profile.get("runtime_asset", ""))
	if asset_path.is_empty():
		return
	var armor_texture := load(asset_path) as Texture2D
	if armor_texture == null:
		return
	var pivot := Node2D.new()
	pivot.name = "ArmorPivot"
	pivot.z_index = 4
	add_child(pivot)
	var sprite := Sprite2D.new()
	sprite.name = "ArmorSprite"
	sprite.texture = armor_texture
	var render_scale := float(armor_profile.get("render_scale", 0.045))
	sprite.scale = Vector2(render_scale, render_scale)
	sprite.position = Vector2(0, -62)
	pivot.add_child(sprite)

func _physics_process(delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = movement * effective_move_speed()
	move_and_slide()
	position = position.clamp(map_bounds.position, map_bounds.end)
	_moving = movement.length_squared() > 0.001
	if weapon_motion:
		weapon_motion.update_from_movement(movement, body.direction_from_vector(movement))
	if artifact_motion:
		artifact_motion.update_from_movement(movement, body.direction_from_vector(movement))
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
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_Q:
		GameState.equip_next_runtime_weapon()
		get_viewport().set_input_as_handled()
		return
	if event.keycode != KEY_J:
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
	velocity = direction * effective_move_speed()


func effective_move_speed() -> float:
	return GameState.world_move_speed()


func _emit_attack_impact(direction: String) -> void:
	# The sword strike lands near the animated follow-through, so damage feels
	# connected to the visible body and weapon motion instead of to the keypress.
	await get_tree().create_timer(0.16).timeout
	attack_impact.emit(direction)
