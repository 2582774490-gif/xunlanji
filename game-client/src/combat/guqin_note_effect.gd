class_name GuqinNoteEffect
extends Node2D

## Three expanding musical note-rings. They have no blade tip or physical
## projectile body and read as a sound-based guqin attack.

var _direction := Vector2.RIGHT
var _elapsed := 0.0
var _duration := 0.32
var _reach := 180.0
var _thickness := 5.0

func launch(origin: Vector2, direction: Vector2, reach := 180.0, thickness := 5.0) -> void:
	global_position = origin
	_direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	_reach = reach
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
	var side := Vector2(-_direction.y, _direction.x)
	for index in 3:
		var ring_progress := clampf(progress * 1.55 - float(index) * 0.22, 0.0, 1.0)
		if ring_progress <= 0.0:
			continue
		var center := _direction * _reach * (0.18 + ring_progress * 0.74) + side * (float(index) - 1.0) * 16.0
		var radius := 12.0 + ring_progress * 28.0
		draw_arc(center, radius, 0.0, TAU, 22, Color(0.58, 0.70, 1.0, 0.88), maxf(1.5, _thickness - index), true)
		draw_circle(center, maxf(2.0, _thickness * 0.38), Color(0.86, 0.92, 1.0, 0.78))
