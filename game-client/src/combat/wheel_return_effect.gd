class_name WheelReturnEffect
extends Node2D

## A wind wheel goes out on a shallow curve and returns on the opposite curve.
## The doubled trail makes its return route readable in 2D combat, unlike a
## one-way arrow, bolt, or pearl projectile.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _duration := 0.42
var _radius := 17.0

func launch(origin: Vector2, target: Vector2, radius := 17.0, duration := 0.42) -> void:
	_origin = origin
	_target = target
	_radius = radius
	_duration = duration
	global_position = origin
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var direction := (_target - _origin).normalized()
	var side := Vector2(-direction.y, direction.x)
	var travel := progress * 2.0 if progress <= 0.5 else (1.0 - progress) * 2.0
	var return_phase := progress > 0.5
	var bend := sin(travel * PI) * (25.0 if not return_phase else -25.0)
	global_position = _origin.lerp(_target, travel) + side * bend
	rotation += delta * (18.0 if not return_phase else -18.0)
	modulate.a = 1.0 if progress < 0.9 else (1.0 - progress) / 0.1
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var direction := (_target - _origin).normalized()
	var tail := -direction * _radius * 3.0
	draw_arc(Vector2.ZERO, _radius, rotation, rotation + PI * 1.35, 16, Color(0.54, 1.0, 0.96, 0.96), 3.0, true)
	draw_arc(Vector2.ZERO, _radius, rotation + PI, rotation + PI * 2.35, 16, Color(0.20, 0.68, 0.96, 0.88), 3.0, true)
	draw_arc(Vector2.ZERO, _radius * 0.56, rotation + 0.3, rotation + 0.3 + TAU, 16, Color(0.86, 1.0, 0.90, 0.72), 1.6, true)
	draw_line(tail, -direction * _radius * 0.6, Color(0.30, 0.92, 0.92, 0.46), 2.4, true)
