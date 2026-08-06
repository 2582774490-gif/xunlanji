class_name SpatialTestPlayer
extends CharacterBody2D

## First spatial-avatar test for Yunlan South Gate.  The body is an 8-way
## atlas, while this root node is the single "feet" point used by Godot's
## Y-sort, collision and future weapon/costume child slots.
const IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_idle_8dir_v01_alpha.png")
const WALK_KEY_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_keypose_8dir_v01_alpha.png")
const WALK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_south_6f_v01_alpha.png")
const WALK_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_east_6f_v01_alpha.png")
const WALK_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_west_6f_v01_alpha.png")
const WALK_NORTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_north_6f_v01_alpha.png")
const WALK_NORTH_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_north_east_6f_v01_alpha.png")
const WALK_NORTH_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_north_west_6f_v01_alpha.png")
const WALK_SOUTH_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_south_east_6f_v01_alpha.png")
const WALK_SOUTH_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_walk_south_west_6f_v01_alpha.png")
const ATTACK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_attack_south_6f_v01_alpha.png")
const FEMALE_IDLE_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_idle_8dir_v01_alpha.png")
const FEMALE_WALK_KEY_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_keypose_8dir_v01_alpha.png")
const FEMALE_WALK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_south_6f_v01_alpha.png")
const FEMALE_WALK_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_east_6f_v01_alpha.png")
const FEMALE_WALK_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_west_6f_v01_alpha.png")
const FEMALE_WALK_NORTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_north_6f_v01_alpha.png")
const FEMALE_WALK_NORTH_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_north_east_6f_v01_alpha.png")
const FEMALE_WALK_NORTH_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_north_west_6f_v01_alpha.png")
const FEMALE_WALK_SOUTH_EAST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_south_east_6f_v01_alpha.png")
const FEMALE_WALK_SOUTH_WEST_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_walk_south_west_6f_v01_alpha.png")
const FEMALE_ATTACK_SOUTH_SHEET: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_attack_south_6f_v01_alpha.png")
const WeaponMotionScript = preload("res://src/animation/weapon_motion_controller.gd")
const UmbrellaMotionScript = preload("res://src/animation/umbrella_motion_controller.gd")
const SpearMotionScript = preload("res://src/animation/spear_motion_controller.gd")
const BowMotionScript = preload("res://src/animation/bow_motion_controller.gd")
const DaoMotionScript = preload("res://src/animation/dao_motion_controller.gd")
const HalberdMotionScript = preload("res://src/animation/halberd_motion_controller.gd")
const AxeMotionScript = preload("res://src/animation/axe_motion_controller.gd")
const HammerMotionScript = preload("res://src/animation/hammer_motion_controller.gd")
const StaffMotionScript = preload("res://src/animation/staff_motion_controller.gd")
const WhipMotionScript = preload("res://src/animation/whip_motion_controller.gd")
const CrossbowMotionScript = preload("res://src/animation/crossbow_motion_controller.gd")
const FanMotionScript = preload("res://src/animation/fan_motion_controller.gd")
const GuqinMotionScript = preload("res://src/animation/guqin_motion_controller.gd")
const XiaoMotionScript = preload("res://src/animation/xiao_motion_controller.gd")
const BellMotionScript = preload("res://src/animation/bell_motion_controller.gd")
const ArrayDiskMotionScript = preload("res://src/animation/array_disk_motion_controller.gd")
const PuppetMotionScript = preload("res://src/animation/puppet_motion_controller.gd")
const CauldronMotionScript = preload("res://src/animation/cauldron_motion_controller.gd")
const PearlMotionScript = preload("res://src/animation/pearl_motion_controller.gd")
const SealMotionScript = preload("res://src/animation/seal_motion_controller.gd")
const MirrorMotionScript = preload("res://src/animation/mirror_motion_controller.gd")
const TowerMotionScript = preload("res://src/animation/tower_motion_controller.gd")
const WheelMotionScript = preload("res://src/animation/wheel_motion_controller.gd")
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
var _rendered_footwear_name := ""

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
	# Both launch templates have real eastward, westward and northward six-frame
	# cycles. Both launch templates also have native north-east and north-west
	# cycles. Both launch templates also have native south-east and south-west
	# cycles. Every launch movement direction now uses a full approved frame sheet.
	var east_walk_sheet := FEMALE_WALK_EAST_SHEET if GameState.player.gender == "女" else WALK_EAST_SHEET
	body.append_grid_clips(east_walk_sheet, 6, 1, {
		"walk_east": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var west_walk_sheet := FEMALE_WALK_WEST_SHEET if GameState.player.gender == "女" else WALK_WEST_SHEET
	body.append_grid_clips(west_walk_sheet, 6, 1, {
		"walk_west": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var north_walk_sheet := FEMALE_WALK_NORTH_SHEET if GameState.player.gender == "女" else WALK_NORTH_SHEET
	body.append_grid_clips(north_walk_sheet, 6, 1, {
		"walk_north": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var north_east_walk_sheet := FEMALE_WALK_NORTH_EAST_SHEET if GameState.player.gender == "女" else WALK_NORTH_EAST_SHEET
	body.append_grid_clips(north_east_walk_sheet, 6, 1, {
		"walk_north_east": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var north_west_walk_sheet := FEMALE_WALK_NORTH_WEST_SHEET if GameState.player.gender == "女" else WALK_NORTH_WEST_SHEET
	body.append_grid_clips(north_west_walk_sheet, 6, 1, {
		"walk_north_west": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var south_east_walk_sheet := FEMALE_WALK_SOUTH_EAST_SHEET if GameState.player.gender == "女" else WALK_SOUTH_EAST_SHEET
	body.append_grid_clips(south_east_walk_sheet, 6, 1, {
		"walk_south_east": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
	})
	var south_west_walk_sheet := FEMALE_WALK_SOUTH_WEST_SHEET if GameState.player.gender == "女" else WALK_SOUTH_WEST_SHEET
	body.append_grid_clips(south_west_walk_sheet, 6, 1, {
		"walk_south_west": {"frames": [0, 1, 2, 3, 4, 5], "fps": 10.0, "loop": true},
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
	var desired_footwear := str(GameState.player.get("equipped_footwear", ""))
	if desired_footwear != _rendered_footwear_name:
		_remove_runtime_layer("FootwearPivot")
		_rendered_footwear_name = desired_footwear
		_configure_equipped_footwear_visual()

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
	var asset_path := str(runtime_profile.get("asset", ""))
	var weapon_texture := load(asset_path) as Texture2D
	if motion.is_empty() or weapon_texture == null:
		return
	var pivot: WeaponMotionController = WeaponMotionScript.new()
	if motion == "defense_umbrella":
		pivot = UmbrellaMotionScript.new()
	elif motion == "long_spear":
		pivot = SpearMotionScript.new()
	elif motion == "wind_bow":
		pivot = BowMotionScript.new()
	elif motion == "mist_dao":
		pivot = DaoMotionScript.new()
	elif motion == "moon_halberd":
		pivot = HalberdMotionScript.new()
	elif motion == "mountain_axe":
		pivot = AxeMotionScript.new()
	elif motion == "mountain_hammer":
		pivot = HammerMotionScript.new()
	elif motion == "bamboo_staff":
		pivot = StaffMotionScript.new()
	elif motion == "shadow_whip":
		pivot = WhipMotionScript.new()
	elif motion == "jique_crossbow":
		pivot = CrossbowMotionScript.new()
	elif motion == "flowing_fan":
		pivot = FanMotionScript.new()
	elif motion == "qingshang_guqin":
		pivot = GuqinMotionScript.new()
	elif motion == "bihuang_xiao":
		pivot = XiaoMotionScript.new()
	elif motion == "xuanshuang_bell":
		pivot = BellMotionScript.new()
	elif motion == "eightfold_array_disk":
		pivot = ArrayDiskMotionScript.new()
	elif motion == "moxu_puppet":
		pivot = PuppetMotionScript.new()
	elif motion == "qinglu_cauldron":
		pivot = CauldronMotionScript.new()
	elif motion == "canglan_pearl":
		pivot = PearlMotionScript.new()
	elif motion == "zhenyue_seal":
		pivot = SealMotionScript.new()
	elif motion == "hanzhao_mirror":
		pivot = MirrorMotionScript.new()
	elif motion == "futu_tower":
		pivot = TowerMotionScript.new()
	elif motion == "zhulan_wheel":
		pivot = WheelMotionScript.new()
	pivot.name = "WeaponPivot"
	pivot.z_index = 2 if motion == "defense_umbrella" else 3
	add_child(pivot)
	weapon_motion = pivot
	var sprite := Sprite2D.new()
	sprite.name = "WeaponSprite"
	sprite.texture = weapon_texture
	if motion == "defense_umbrella":
		sprite.scale = Vector2(0.092, 0.092)
	elif motion == "rune_brush":
		# The brush has its own off-hand layer and swing timing; it is not a
		# recoloured sword sprite.  The lower bristle points at the casting hand.
		sprite.scale = Vector2(0.105, 0.105)
		sprite.position = Vector2(38, -44)
		sprite.rotation = deg_to_rad(-28.0)
	elif motion == "long_spear":
		# The source weapon's lower-left butt is pinned near the hand; this keeps
		# the full shaft readable during movement and during the thrust controller.
		sprite.scale = Vector2(0.075, 0.075)
		sprite.position = Vector2(37, -43)
		sprite.rotation = deg_to_rad(-45.0)
	elif motion == "wind_bow":
		sprite.scale = Vector2(0.084, 0.084)
		sprite.position = Vector2(20, -54)
	elif motion == "mist_dao":
		# The hilt lives in the lower-left of its single-item source image, so it
		# is pinned near the hand while the long curved blade remains readable.
		sprite.scale = Vector2(0.065, 0.065)
		sprite.position = Vector2(44, -45)
	elif motion == "moon_halberd":
		# The butt is lower-left and the hook opens at the upper-right; anchoring
		# this long diagonal source at the grip keeps the full silhouette legible.
		sprite.scale = Vector2(0.060, 0.060)
		sprite.position = Vector2(42, -46)
		sprite.rotation = deg_to_rad(-12.0)
	elif motion == "mountain_axe":
		# The heavy axe head stays just above the hand while the lower butt anchors
		# the diagonal source, leaving room for the deliberate downward cleave.
		sprite.scale = Vector2(0.068, 0.068)
		sprite.position = Vector2(39, -45)
		sprite.rotation = deg_to_rad(-10.0)
	elif motion == "mountain_hammer":
		# The compact hammer head is held closer to the shoulder; its controller
		# creates the overhead drop without borrowing the axe's long cleave pose.
		sprite.scale = Vector2(0.066, 0.066)
		sprite.position = Vector2(37, -42)
		sprite.rotation = deg_to_rad(-16.0)
	elif motion == "bamboo_staff":
		# A staff reads as a long diagonal line; keep its middle grip close to the
		# hand so the dedicated quick-whirl controller can spin it around the body.
		sprite.scale = Vector2(0.058, 0.058)
		sprite.position = Vector2(39, -43)
		sprite.rotation = deg_to_rad(-12.0)
	elif motion == "shadow_whip":
		# The handle sits at the lower-left of the source while the flexible body
		# rises outward; pin that handle near the hand for the snap-and-recoil pose.
		sprite.scale = Vector2(0.063, 0.063)
		sprite.position = Vector2(37, -43)
		sprite.rotation = deg_to_rad(-8.0)
	elif motion == "jique_crossbow":
		# The rear grip is lower-left while the bolt rack points right; this keeps
		# the dedicated recoil controller aligned with the firing direction.
		sprite.scale = Vector2(0.072, 0.072)
		sprite.position = Vector2(35, -45)
		sprite.rotation = deg_to_rad(-5.0)
	elif motion == "flowing_fan":
		# The jade pivot anchors this wide fan close to the casting hand; its own
		# flick controller keeps the cloth spread readable without sword rotation.
		sprite.scale = Vector2(0.060, 0.060)
		sprite.position = Vector2(37, -46)
		sprite.rotation = deg_to_rad(-18.0)
	elif motion == "qingshang_guqin":
		# The full instrument rests just in front of the torso, far enough from
		# the feet to remain legible while its dedicated pluck controller floats.
		sprite.scale = Vector2(0.064, 0.064)
		sprite.position = Vector2(32, -57)
		sprite.rotation = deg_to_rad(-6.0)
	elif motion == "bihuang_xiao":
		# The lower end anchors close to the hands so the xiao can hover upright
		# through its dedicated breath-release movement rather than polearm motion.
		sprite.scale = Vector2(0.060, 0.060)
		sprite.position = Vector2(38, -52)
		sprite.rotation = deg_to_rad(-14.0)
	elif motion == "xuanshuang_bell":
		# This large source is pinned at the handle; its controller adds a small
		# hanging sway so it reads as a hand bell rather than a static accessory.
		sprite.scale = Vector2(0.050, 0.050)
		sprite.position = Vector2(38, -52)
		sprite.rotation = deg_to_rad(-12.0)
	elif motion == "eightfold_array_disk":
		# Keep the face visible at a small scale so the player can identify the
		# array before it is deployed in front of the casting hand.
		sprite.scale = Vector2(0.055, 0.055)
		sprite.position = Vector2(35, -52)
		sprite.rotation = deg_to_rad(-8.0)
	elif motion == "moxu_puppet":
		# The puppet lives by the player flank as an autonomous companion rather
		# than in the hand position used by ordinary weapons.
		sprite.scale = Vector2(0.061, 0.061)
		sprite.position = Vector2(0, 0)
		sprite.rotation = 0.0
	elif motion == "qinglu_cauldron":
		# The compact furnace hovers near the shoulder, keeping its lid and flame
		# silhouette clear before the controller tips it forward to cast.
		sprite.scale = Vector2(0.055, 0.055)
		sprite.position = Vector2(0, 0)
		sprite.rotation = deg_to_rad(-3.0)
	elif motion == "canglan_pearl":
		# The pearl stays slightly ahead of the shoulder to read as a hovering
		# focus; its own controller supplies the orbit and command movement.
		sprite.scale = Vector2(0.054, 0.054)
		sprite.position = Vector2(0, 0)
		sprite.rotation = 0.0
	elif motion == "zhenyue_seal":
		# Keep the underside of the seal visible just above the hand; its own
		# controller provides the heavy rise-and-stamp rhythm.
		sprite.scale = Vector2(0.050, 0.050)
		sprite.position = Vector2(0, 0)
		sprite.rotation = deg_to_rad(-5.0)
	elif motion == "hanzhao_mirror":
		# The mirror floats upright in front of the shoulder, keeping the cold
		# reflective face visible while its controller turns it to cast.
		sprite.scale = Vector2(0.053, 0.053)
		sprite.position = Vector2(0, 0)
		sprite.rotation = deg_to_rad(-4.0)
	elif motion == "futu_tower":
		# A miniature tower floats above the shoulder; scale keeps its tiers legible
		# without covering the player or behaving like an environmental building.
		sprite.scale = Vector2(0.046, 0.046)
		sprite.position = Vector2(0, 0)
		sprite.rotation = 0.0
	elif motion == "zhulan_wheel":
		# The ring is centered on its pivot so its constant spin reads clearly.
		sprite.scale = Vector2(0.060, 0.060)
		sprite.position = Vector2.ZERO
		sprite.rotation = 0.0
	else:
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

func _configure_equipped_footwear_visual() -> void:
	# Footwear is a lower-body layer. It may coexist with bracers and a body
	# piece instead of being forced through the temporary armor slot.
	var footwear_profile := GameCatalog.footwear_profile_for_item(str(GameState.player.get("equipped_footwear", "")))
	var asset_path := str(footwear_profile.get("runtime_asset", ""))
	if asset_path.is_empty():
		return
	var footwear_texture := load(asset_path) as Texture2D
	if footwear_texture == null:
		return
	var pivot := Node2D.new()
	pivot.name = "FootwearPivot"
	pivot.z_index = 4
	add_child(pivot)
	var sprite := Sprite2D.new()
	sprite.name = "FootwearSprite"
	sprite.texture = footwear_texture
	var render_scale := float(footwear_profile.get("render_scale", 0.035))
	sprite.scale = Vector2(render_scale, render_scale)
	sprite.position = Vector2(0, -20)
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
	return minf(395.0, GameState.world_move_speed() + GameState.footwear_move_speed_bonus())


func _emit_attack_impact(direction: String) -> void:
	# The sword strike lands near the animated follow-through, so damage feels
	# connected to the visible body and weapon motion instead of to the keypress.
	await get_tree().create_timer(0.16).timeout
	attack_impact.emit(direction)
