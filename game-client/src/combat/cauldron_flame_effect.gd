class_name CauldronFlameEffect
extends Node2D

## A thick tongue of alchemical furnace fire. Its segmented droplets and warm
## core differentiate it from wind, water, weapon arcs, and generic fireballs.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.30
var _reach := 160.0
var _width := 16.0

func pour(origin: Vector2, direction: Vector2, reach := 160.0, width := 16.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_reach = reach
	_width = width
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
	for index in 6:
		var t := clampf(progress * 1.42 - float(index) * 0.12, 0.0, 1.0)
		if t <= 0.0:
			continue
		var center := _direction * (_reach * t) + side * sin(float(index) * 2.1 + progress * 7.0) * (_width * 0.32)
		var radius := _width * (0.38 + (1.0 - t) * 0.44)
		draw_circle(center, radius, Color(1.0, 0.38 + t * 0.22, 0.08, 0.86))
		draw_circle(center - _direction * 2.0, radius * 0.52, Color(1.0, 0.90, 0.44, 0.92))
	draw_arc(Vector2.ZERO, _width * 0.86, -PI * 0.45, PI * 0.45, 12, Color(0.40, 1.0, 0.82, 0.78), 2.0, true)
