class_name FrameAnimationController
extends AnimatedSprite2D

## Runtime controller for top-down 2D character sprite sheets.
## Art is supplied as separate action sheets. This controller turns a grid and
## a small manifest into named AnimatedSprite2D clips at runtime.

signal action_started(clip_name: String)
signal action_finished(clip_name: String)

const DIRECTIONS := [
	"south",
	"south_west",
	"west",
	"north_west",
	"north",
	"north_east",
	"east",
	"south_east",
]

@export var idle_action := "idle"

var current_action := "idle"
var current_direction := "south"
var _return_to_idle_after_clip := false


func _ready() -> void:
	animation_finished.connect(_on_animation_finished)


func configure_from_grid(sheet: Texture2D, columns: int, rows: int, clips: Dictionary) -> void:
	sprite_frames = SpriteFrames.new()
	append_grid_clips(sheet, columns, rows, clips)


func append_grid_clips(sheet: Texture2D, columns: int, rows: int, clips: Dictionary) -> void:
	if sheet == null or columns <= 0 or rows <= 0:
		push_warning("FrameAnimationController needs a valid texture grid.")
		return
	if sprite_frames == null:
		sprite_frames = SpriteFrames.new()
	var grid_size := Vector2i(columns, rows)
	var texture_size := sheet.get_size()
	var cell_size := Vector2(texture_size.x / columns, texture_size.y / rows)
	for clip_name_variant in clips:
		var clip_name := str(clip_name_variant)
		var definition: Dictionary = clips[clip_name_variant]
		if sprite_frames.has_animation(clip_name):
			sprite_frames.remove_animation(clip_name)
		sprite_frames.add_animation(clip_name)
		sprite_frames.set_animation_speed(clip_name, float(definition.get("fps", 8.0)))
		sprite_frames.set_animation_loop(clip_name, bool(definition.get("loop", true)))
		for frame_index_variant in definition.get("frames", []):
			var frame_index := int(frame_index_variant)
			if frame_index < 0 or frame_index >= grid_size.x * grid_size.y:
				push_warning("Frame %d is outside the supplied sprite grid." % frame_index)
				continue
			var cell := Vector2i(frame_index % grid_size.x, frame_index / grid_size.x)
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = sheet
			atlas_texture.region = Rect2(Vector2(cell) * cell_size, cell_size)
			sprite_frames.add_frame(clip_name, atlas_texture)


func play_action(action_name: String, direction := current_direction, return_to_idle := false) -> bool:
	if sprite_frames == null:
		return false
	current_action = action_name
	current_direction = _normalize_direction(direction)
	var clip_name := _resolve_clip(action_name, current_direction)
	if clip_name.is_empty():
		push_warning("No animation clip for %s / %s." % [action_name, current_direction])
		return false
	_return_to_idle_after_clip = return_to_idle
	if animation == clip_name and is_playing():
		return true
	animation = clip_name
	play()
	action_started.emit(clip_name)
	return true


func update_motion(movement: Vector2) -> void:
	if movement.length_squared() <= 0.001:
		play_action(idle_action, current_direction)
		return
	current_direction = direction_from_vector(movement)
	play_action("walk", current_direction)


func trigger_attack() -> bool:
	return play_action("attack", current_direction, true)


func trigger_hit() -> bool:
	return play_action("hit", current_direction, true)


func direction_from_vector(vector: Vector2) -> String:
	if vector.length_squared() <= 0.001:
		return current_direction
	var angle := vector.angle()
	var octant := int(round(angle / (TAU / 8.0)))
	var mapping := {
		0: "east",
		1: "south_east",
		2: "south",
		3: "south_west",
		4: "west",
		-3: "north_west",
		-2: "north",
		-1: "north_east",
	}
	return mapping.get(octant, "south")


func _resolve_clip(action_name: String, direction: String) -> String:
	var exact_clip := "%s_%s" % [action_name, direction]
	if sprite_frames.has_animation(exact_clip):
		return exact_clip
	var fallback_clip := "%s_south" % action_name
	if sprite_frames.has_animation(fallback_clip):
		return fallback_clip
	if sprite_frames.has_animation(action_name):
		return action_name
	return ""


func _normalize_direction(direction: String) -> String:
	return direction if DIRECTIONS.has(direction) else "south"


func _on_animation_finished() -> void:
	var finished_clip := str(animation)
	action_finished.emit(finished_clip)
	if _return_to_idle_after_clip:
		_return_to_idle_after_clip = false
		play_action(idle_action, current_direction)
