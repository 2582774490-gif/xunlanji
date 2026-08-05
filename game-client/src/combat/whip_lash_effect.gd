class_name WhipLashEffect
extends Node2D

## Curved segmented trail for a whip crack. It deliberately ends in a bright
## tip instead of resembling a sword wave or a straight projectile.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.20
var _reach := 132.0
var _width := 5.0

func launch(origin: Vector2, direction: Vector2, reach := 132.0, width := 5.0) -> void:
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
	var length := _reach * (0.35 + progress * 0.65)
	var points := PackedVector2Array()
	for index in 13:
		var t := float(index) / 12.0
		var wave := sin((t * 1.45 + progress * 0.85) * PI) * (1.0 - t) * _reach * 0.22
		points.append(_direction * length * t + side * wave)
	draw_polyline(points, Color(0.30, 0.82, 0.96, 0.94), _width, true)
	draw_polyline(points, Color(0.86, 0.98, 1.0, 0.84), maxf(1.5, _width * 0.30), true)
	var tip := points[points.size() - 1]
	draw_circle(tip, maxf(2.5, _width * 0.52), Color(0.80, 1.0, 0.96, 0.90))
