class_name MirrorRayEffect
extends Node2D

## A cold mirror ray travels as two angular segments. The sharp reflected kink
## establishes a mirror identity rather than another elemental projectile.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.26
var _reach := 180.0
var _thickness := 4.0

func reflect(origin: Vector2, direction: Vector2, reach := 180.0, thickness := 4.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_reach = reach
	_thickness = thickness
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
	var bend := _direction * (_reach * 0.48) + side * _reach * 0.18
	var end := _direction * _reach - side * _reach * 0.11
	var path := PackedVector2Array([Vector2.ZERO, bend, end])
	draw_polyline(path, Color(0.38, 0.90, 1.0, 0.92), _thickness, true)
	draw_polyline(path, Color(0.92, 1.0, 1.0, 0.86), maxf(1.4, _thickness * 0.34), true)
	draw_circle(bend, _thickness * (1.5 + sin(progress * PI) * 0.5), Color(0.70, 0.94, 1.0, 0.78))
	draw_arc(end, _thickness * 3.0, -PI * 0.65, PI * 0.65, 10, Color(0.84, 0.96, 1.0, 0.80), 2.0, true)
