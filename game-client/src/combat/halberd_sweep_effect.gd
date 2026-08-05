class_name HalberdSweepEffect
extends Node2D

## A large hooked crescent for the halberd. The two rings and trailing hook
## communicate a polearm sweep instead of a thrown sword wave.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.26
var _radius := 94.0
var _thickness := 8.0

func launch(origin: Vector2, direction: Vector2, radius := 94.0, thickness := 8.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_radius = radius
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
	var facing_angle := _direction.angle()
	var sweep := 0.44 + progress * 1.02
	var radius := _radius * (0.66 + progress * 0.42)
	var start_angle := facing_angle - sweep * 0.72
	var end_angle := facing_angle + sweep
	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 34, Color(0.34, 0.85, 0.82, 0.96), _thickness, true)
	draw_arc(Vector2.ZERO, radius - _thickness * 0.74, start_angle + 0.08, end_angle - 0.10, 32, Color(0.92, 1.0, 0.86, 0.88), maxf(1.8, _thickness * 0.30), true)
	var hook_tip := Vector2(cos(end_angle), sin(end_angle)) * radius
	var hook_inner := Vector2(cos(end_angle - 0.20), sin(end_angle - 0.20)) * (radius - _thickness * 2.0)
	draw_line(hook_inner, hook_tip, Color(0.94, 0.77, 0.38, 0.92), maxf(2.0, _thickness * 0.42), true)
	draw_circle(hook_tip, maxf(2.6, _thickness * 0.38), Color(0.96, 0.91, 0.58, 0.86))
