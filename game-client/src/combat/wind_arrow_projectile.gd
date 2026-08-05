class_name WindArrowProjectile
extends Node2D

## A compact, readable physical arrow with a restrained pale-cyan wind wake.
## It avoids using a generic sword wave for the dedicated bow route.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _travel_time := 0.30
var _tint := Color(0.70, 0.94, 1.0)

func launch(origin: Vector2, target: Vector2, tint := Color(0.70, 0.94, 1.0), travel_time := 0.30) -> void:
	_origin = origin
	_target = target
	_tint = tint
	_travel_time = travel_time
	global_position = origin
	rotation = (target - origin).angle()
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _travel_time, 0.0, 1.0)
	global_position = _origin.lerp(_target, progress)
	modulate.a = 1.0 - progress * 0.16
	if progress >= 1.0:
		queue_free()

func _draw() -> void:
	draw_line(Vector2(-24, 0), Vector2(14, 0), Color(0.94, 0.99, 1.0, 0.98), 2.4)
	draw_line(Vector2(-30, -5), Vector2(-18, 0), _tint, 1.6)
	draw_line(Vector2(-30, 5), Vector2(-18, 0), _tint, 1.6)
	var tip := PackedVector2Array([Vector2(20, 0), Vector2(9, -5), Vector2(9, 5)])
	draw_colored_polygon(tip, Color(0.78, 0.94, 1.0, 0.98))
	draw_line(Vector2(-42, 0), Vector2(-16, 0), Color(_tint, 0.30), 5.0)
