class_name CrossbowBoltProjectile
extends Node2D

## A fast short bolt with a mechanical cyan afterimage. The shorter body and
## square fletching keep it distinct from the bow's wind arrow.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _travel_time := 0.22

func launch(origin: Vector2, target: Vector2, travel_time := 0.22) -> void:
	_origin = origin
	_target = target
	_travel_time = travel_time
	global_position = origin
	rotation = (target - origin).angle()
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _travel_time, 0.0, 1.0)
	global_position = _origin.lerp(_target, progress)
	modulate.a = 1.0 - progress * 0.12
	if progress >= 1.0:
		queue_free()

func _draw() -> void:
	draw_line(Vector2(-18, 0), Vector2(17, 0), Color(0.62, 0.94, 1.0, 0.98), 3.0)
	draw_line(Vector2(-34, 0), Vector2(-14, 0), Color(0.26, 0.72, 0.95, 0.38), 6.0)
	draw_rect(Rect2(-24, -5, 8, 10), Color(0.35, 0.26, 0.14, 0.96), true)
	var tip := PackedVector2Array([Vector2(23, 0), Vector2(12, -6), Vector2(12, 6)])
	draw_colored_polygon(tip, Color(0.88, 1.0, 1.0, 0.98))
