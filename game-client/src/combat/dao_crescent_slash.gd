class_name DaoCrescentSlash
extends Node2D

## A broad compressed saber crescent. Its visible arc and short radius make
## it distinct from the sword wave, spear line and bow projectile.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.22
var _radius := 72.0
var _thickness := 7.0

func launch(origin: Vector2, direction: Vector2, radius := 72.0, thickness := 7.0) -> void:
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
	var sweep := 0.32 + progress * 0.82
	var radius := _radius * (0.74 + progress * 0.32)
	var tint := Color(0.44, 0.80, 0.94, 0.95)
	draw_arc(Vector2.ZERO, radius, facing_angle - sweep, facing_angle + sweep, 28, tint, _thickness, true)
	draw_arc(Vector2.ZERO, radius - _thickness * 0.58, facing_angle - sweep * 0.90, facing_angle + sweep * 0.90, 26, Color(0.90, 0.98, 1.0, 0.88), maxf(1.6, _thickness * 0.30), true)
	var tip := Vector2(cos(facing_angle + sweep), sin(facing_angle + sweep)) * radius
	draw_circle(tip, maxf(2.4, _thickness * 0.35), Color(0.82, 0.96, 1.0, 0.80))
