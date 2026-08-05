class_name BellSonicSealEffect
extends Node2D

## The bell sends square-edged sealing ripples forward. It is deliberately
## different from the guqin's soft circular notes and the xiao's spiral stream.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.34
var _reach := 170.0
var _radius := 18.0

func launch(origin: Vector2, direction: Vector2, reach := 170.0, radius := 18.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_reach = reach
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
	var side := Vector2(-_direction.y, _direction.x)
	for index in 3:
		var trail := float(index) * 0.14
		var local_progress := clampf((progress - trail) / (1.0 - trail), 0.0, 1.0)
		if local_progress <= 0.0:
			continue
		var center := _direction * (_reach * local_progress)
		var scale := _radius * (0.70 + local_progress * 0.82) * (1.0 - float(index) * 0.11)
		var points := PackedVector2Array([
			center + _direction * scale,
			center + (_direction + side).normalized() * scale,
			center + side * scale,
			center + (-_direction + side).normalized() * scale,
			center - _direction * scale,
			center + (-_direction - side).normalized() * scale,
			center - side * scale,
			center + (_direction - side).normalized() * scale,
			center + _direction * scale,
		])
		draw_polyline(points, Color(0.68, 0.88, 1.0, 0.92 - float(index) * 0.16), 2.6, true)
		draw_circle(center, maxf(2.0, scale * 0.11), Color(0.96, 0.84, 0.42, 0.72))
