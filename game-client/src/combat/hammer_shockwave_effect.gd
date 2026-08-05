class_name HammerShockwaveEffect
extends Node2D

## A localized circular hammer impact. It travels as a shallow ground ring,
## making the crowd-control beat clear without copying the axe's split cracks.

var _elapsed := 0.0
var _duration := 0.28
var _radius := 62.0
var _thickness := 8.0

func launch(origin: Vector2, radius := 62.0, thickness := 8.0) -> void:
	global_position = origin
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
	var radius := _radius * (0.16 + progress * 0.84)
	var ring_width := _thickness * (1.0 - progress * 0.35)
	draw_circle(Vector2.ZERO, maxf(5.0, radius * 0.18), Color(0.96, 0.68, 0.27, 0.34 * (1.0 - progress)))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0.88, 0.54, 0.20, 0.94), ring_width, true)
	draw_arc(Vector2.ZERO, radius - ring_width * 0.70, 0.0, TAU, 32, Color(1.0, 0.90, 0.56, 0.86), maxf(1.6, ring_width * 0.26), true)
	for index in 6:
		var angle := float(index) * TAU / 6.0 + progress * 0.18
		var point := Vector2(cos(angle), sin(angle)) * radius
		draw_circle(point, maxf(1.6, ring_width * 0.22), Color(0.98, 0.72, 0.34, 0.82))
