class_name SpearThrustEffect
extends Node2D

## A readable, narrow long-weapon strike.  This is not a sword wave: it keeps
## a straight shaft-like line and a single bright spear tip at the target end.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _duration := 0.20
var _width := 5.0

func launch(origin: Vector2, target: Vector2, width := 5.0) -> void:
	_origin = origin
	_target = target
	_width = width
	global_position = origin
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = maxf(0.0, 1.0 - _elapsed / _duration)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var vector := _target - _origin
	var point := vector * (0.18 + progress * 0.82)
	var direction := vector.normalized()
	var side := Vector2(-direction.y, direction.x)
	draw_line(Vector2.ZERO, point, Color(0.58, 0.92, 1.0, 0.92), _width)
	draw_line(Vector2.ZERO, point, Color(0.96, 0.99, 1.0, 0.96), maxf(1.5, _width * 0.38))
	var tip := PackedVector2Array([point + direction * 15.0, point + side * 7.0, point - direction * 8.0, point - side * 7.0])
	draw_colored_polygon(tip, Color(0.86, 0.98, 1.0, 0.94))
