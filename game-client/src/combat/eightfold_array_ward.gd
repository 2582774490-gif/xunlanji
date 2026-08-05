class_name EightfoldArrayWard
extends Node2D

## A compact defensive formation that appears only when the Eightfold Qi Array
## actually mitigates a neutral PVE impact. It communicates protection without
## reusing water, earth, sword, or umbrella effects.

var _elapsed := 0.0
var _duration := 0.46
var _radius := 50.0

func trigger(origin: Vector2, radius := 50.0) -> void:
	global_position = origin
	_radius = radius
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	modulate.a = maxf(0.0, 1.0 - _elapsed / _duration)
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var radius := _radius * (0.78 + progress * 0.34)
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for index in 9:
		var angle := TAU * float(index) / 8.0 + PI * 0.125
		outer.append(Vector2(cos(angle), sin(angle) * 0.60) * radius)
		inner.append(Vector2(cos(angle), sin(angle) * 0.60) * radius * 0.62)
	draw_polyline(outer, Color(0.50, 0.96, 0.92, 0.95), 3.0, true)
	draw_polyline(inner, Color(0.86, 0.98, 1.0, 0.82), 2.0, true)
	for index in 8:
		var angle := TAU * float(index) / 8.0 + PI * 0.125
		var point := Vector2(cos(angle), sin(angle) * 0.60) * radius
		draw_line(Vector2.ZERO, point, Color(0.36, 0.86, 0.84, 0.40), 1.4)
	draw_circle(Vector2.ZERO, 8.0 + progress * 5.0, Color(0.70, 1.0, 0.94, 0.60))
