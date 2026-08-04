class_name SpriteSheetBurst
extends Sprite2D

## A small reusable one-shot effect player for AI-authored VFX atlases.
## The atlas stays independent from characters, weapons and enemies: callers
## provide the start point and direction, then this component handles frames,
## travel, scale and fade without baking any of them into the art.

@export var columns := 1
@export var rows := 1
@export var frame_count := 1
@export var animation_fps := 14.0
@export var motion_distance := 0.0
@export var start_scale := Vector2.ONE
@export var end_scale := Vector2.ONE

var _active := false
var _elapsed := 0.0
var _origin := Vector2.ZERO
var _facing := Vector2.RIGHT


func _ready() -> void:
	region_enabled = true
	visible = false
	_set_frame(0)


func play_burst(origin: Vector2, facing := Vector2.RIGHT) -> void:
	if texture == null or frame_count <= 0:
		return
	_origin = origin
	_facing = facing.normalized() if facing.length_squared() > 0.001 else Vector2.RIGHT
	position = _origin
	rotation = _facing.angle()
	_elapsed = 0.0
	modulate = Color.WHITE
	scale = start_scale
	_set_frame(0)
	visible = true
	_active = true


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	var duration := float(frame_count) / animation_fps
	var progress := clampf(_elapsed / duration, 0.0, 1.0)
	var frame := mini(int(_elapsed * animation_fps), frame_count - 1)
	_set_frame(frame)
	position = _origin + _facing * motion_distance * progress
	scale = start_scale.lerp(end_scale, progress)
	modulate.a = 1.0 - progress
	if progress >= 1.0:
		_active = false
		visible = false


func _set_frame(frame: int) -> void:
	if texture == null or columns <= 0 or rows <= 0:
		return
	var cell_size := Vector2(texture.get_size().x / columns, texture.get_size().y / rows)
	var cell := Vector2i(frame % columns, frame / columns)
	region_rect = Rect2(Vector2(cell) * cell_size, cell_size)
