class_name XiaoSoundstreamEffect
extends Node2D

## A single narrow helical soundstream. This is directional and fluid, unlike
## the guqin's expanding rings or a physical arrow.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.30
var _reach := 205.0
var _width := 5.0

func launch(origin: Vector2, direction: Vector2, reach := 205.0, width := 5.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_reach = reach
	_width = width
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = maxf(0.0, 1.0 - _elapsed / _duration)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var side := Vector2(-_direction.y, _direction.x)
	var points := PackedVector2Array()
	for index in 18:
		var t := float(index) / 17.0
		var wave := sin((t * 2.0 + progress * 1.2) * TAU) * (1.0 - t * 0.48) * 20.0
		points.append(_direction * _reach * (0.08 + t * 0.92) + side * wave)
	draw_polyline(points, Color(0.42, 0.96, 0.72, 0.90), _width, true)
	draw_polyline(points, Color(0.88, 1.0, 0.82, 0.82), maxf(1.5, _width * 0.30), true)
	draw_circle(points[points.size() - 1], maxf(2.2, _width * 0.46), Color(0.82, 1.0, 0.74, 0.90))
