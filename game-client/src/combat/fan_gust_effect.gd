class_name FanGustEffect
extends Node2D

## A soft three-stream gust from the fan. The flow curves around the target
## space and is visually unrelated to an arrow, spear line or blade arc.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.28
var _reach := 154.0
var _width := 5.0

func launch(origin: Vector2, direction: Vector2, reach := 154.0, width := 5.0) -> void:
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
	for band in [-1.0, 0.0, 1.0]:
		var points := PackedVector2Array()
		for index in 10:
			var t := float(index) / 9.0
			var bend := sin((t + progress * 0.55) * PI) * (20.0 + absf(band) * 10.0)
			points.append(_direction * _reach * (0.14 + t * 0.86) + side * (band * 16.0 + bend))
		draw_polyline(points, Color(0.58, 0.94, 0.96, 0.88), maxf(1.6, _width - absf(band) * 1.2), true)
