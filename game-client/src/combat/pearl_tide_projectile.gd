class_name PearlTideProjectile
extends Node2D

## A watery spirit pearl travels on a curved tide line. Its concentric shell
## and tail make it distinct from arrows, bolts, talismans, and the xiao stream.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _duration := 0.30
var _radius := 13.0

func launch(origin: Vector2, target: Vector2, radius := 13.0, duration := 0.30) -> void:
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
	global_position = _origin.lerp(_target, progress) + side * sin(progress * PI) * 20.0
	modulate.a = 1.0 if progress < 0.86 else (1.0 - progress) / 0.14
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var direction := (_target - _origin).normalized()
	var tail := -direction * (_radius * 2.6)
	draw_circle(tail, _radius * 0.62, Color(0.22, 0.78, 1.0, 0.30))
	draw_circle(tail * 0.48, _radius * 0.82, Color(0.18, 0.72, 1.0, 0.46))
	draw_circle(Vector2.ZERO, _radius, Color(0.16, 0.72, 0.96, 0.92))
	draw_circle(Vector2(-_radius * 0.20, -_radius * 0.24), _radius * 0.42, Color(0.82, 1.0, 1.0, 0.94))
	draw_arc(Vector2.ZERO, _radius * 1.32, progress * TAU, progress * TAU + PI * 1.4, 12, Color(0.64, 1.0, 0.98, 0.88), 2.0, true)
