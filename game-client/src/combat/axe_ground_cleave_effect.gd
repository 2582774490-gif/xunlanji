class_name AxeGroundCleaveEffect
extends Node2D

## A heavy impact visual: a compact wedge strikes first, then two short earth
## cracks travel away. It is deliberately not an arc, projectile or thrust.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.30
var _radius := 72.0
var _width := 9.0

func launch(origin: Vector2, direction: Vector2, radius := 72.0, width := 9.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_radius = radius
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
	var impact_distance := _radius * (0.28 + progress * 0.22)
	var impact := _direction * impact_distance
	var wedge := PackedVector2Array([
		impact + _direction * 19.0,
		impact + side * _width,
		impact - _direction * 12.0,
		impact - side * _width,
	])
	draw_colored_polygon(wedge, Color(0.96, 0.66, 0.28, 0.86))
	draw_polyline(PackedVector2Array([Vector2.ZERO, impact - side * 4.0, impact + _direction * 15.0]), Color(1.0, 0.90, 0.55, 0.94), maxf(2.0, _width * 0.30), true)
	var crack_extent := _radius * (0.34 + progress * 0.66)
	for sign in [-1.0, 1.0]:
		var bend: Vector2 = side * sign * _width * 1.7
		var crack := PackedVector2Array([impact - _direction * 5.0, impact + _direction * crack_extent * 0.48 + bend, impact + _direction * crack_extent + bend * 0.55])
		draw_polyline(crack, Color(0.64, 0.32, 0.12, 0.90), maxf(2.0, _width * 0.26), true)
