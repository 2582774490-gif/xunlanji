class_name StaffWhirlEffect
extends Node2D

## Two offset spinning bands make the staff's rotary guard visible. This is a
## short localized sweep, not a thrown blade or a straight projectile.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.23
var _radius := 80.0
var _thickness := 6.0

func launch(origin: Vector2, direction: Vector2, radius := 80.0, thickness := 6.0) -> void:
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
	var facing := _direction.angle() + progress * TAU * 0.72
	var radius := _radius * (0.72 + progress * 0.26)
	for offset in [-0.56, 0.56]:
		var start := facing + offset - 0.76
		var end := facing + offset + 0.76
		draw_arc(Vector2.ZERO, radius, start, end, 20, Color(0.39, 0.87, 0.58, 0.90), _thickness, true)
		draw_arc(Vector2.ZERO, radius - _thickness * 0.65, start + 0.08, end - 0.08, 18, Color(0.88, 1.0, 0.72, 0.86), maxf(1.4, _thickness * 0.30), true)
	draw_circle(Vector2.ZERO, maxf(3.0, _thickness * 0.62), Color(0.76, 0.98, 0.72, 0.72))
