class_name ArrayLatticeEffect
extends Node2D

## A ground-deployed octagonal lattice. The weapon version forms ahead of the
## caster to pressure a lane; it deliberately differs from the defensive
## artifact ward that only flashes around the player after a hit.

var _elapsed := 0.0
var _duration := 0.42
var _radius := 52.0

func deploy(origin: Vector2, radius := 52.0) -> void:
	global_position = origin
	_radius = radius
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = maxf(0.0, 1.0 - _elapsed / _duration)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var radius := _radius * (0.22 + minf(progress * 2.0, 1.0) * 0.78)
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for index in 9:
		var angle := TAU * float(index) / 8.0 + PI * 0.125
		outer.append(Vector2(cos(angle), sin(angle) * 0.58) * radius)
		inner.append(Vector2(cos(angle), sin(angle) * 0.58) * radius * 0.58)
	draw_colored_polygon(outer, Color(0.10, 0.68, 0.70, 0.13))
	draw_polyline(outer, Color(0.42, 1.0, 0.92, 0.95), 3.2, true)
	draw_polyline(inner, Color(0.90, 1.0, 0.78, 0.88), 2.0, true)
	for index in 4:
		var angle := TAU * float(index) / 4.0 + PI * 0.125
		var point := Vector2(cos(angle), sin(angle) * 0.58) * radius
		draw_line(-point, point, Color(0.44, 0.92, 1.0, 0.58), 1.6)
	draw_circle(Vector2.ZERO, maxf(4.0, radius * 0.12), Color(0.98, 0.80, 0.36, 0.82))
