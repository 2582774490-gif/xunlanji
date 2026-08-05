class_name SealSlamEffect
extends Node2D

## A square mountain seal impresses itself into the ground. This strong stamp
## shape differentiates it from circular wards and the array disk lattice.

var _elapsed := 0.0
var _duration := 0.34
var _size := 44.0

func slam(origin: Vector2, size := 44.0) -> void:
	global_position = origin
	_size = size
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = maxf(0.0, 1.0 - _elapsed / _duration)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var impact := clampf(progress * 2.4, 0.0, 1.0)
	var size := _size * (0.25 + impact * 0.75)
	var rect := Rect2(Vector2(-size, -size * 0.58), Vector2(size * 2.0, size * 1.16))
	draw_rect(rect, Color(0.20, 0.74, 0.36, 0.20), true)
	draw_rect(rect, Color(0.70, 1.0, 0.46, 0.94), false, 3.4)
	draw_line(Vector2(-size * 0.70, size * 0.34), Vector2(0.0, -size * 0.35), Color(0.92, 0.82, 0.34, 0.86), 2.8)
	draw_line(Vector2(0.0, -size * 0.35), Vector2(size * 0.70, size * 0.34), Color(0.92, 0.82, 0.34, 0.86), 2.8)
	if progress < 0.48:
		var drop_height := (0.48 - progress) / 0.48 * size * 1.8
		draw_rect(Rect2(Vector2(-size * 0.40, -drop_height - size * 0.22), Vector2(size * 0.80, size * 0.44)), Color(0.96, 0.82, 0.30, 0.72), false, 2.5)
