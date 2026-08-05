class_name TowerWardImpactEffect
extends Node2D

## Three stacked pagoda tiers stamp outward at a target point. It is a tower
## ward impact, distinct from a square seal stamp or flat eightfold array.

var _elapsed := 0.0
var _duration := 0.38
var _radius := 48.0

func invoke(origin: Vector2, radius := 48.0) -> void:
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
	for tier in 3:
		var delay := float(tier) * 0.14
		var local_progress := clampf((progress - delay) / (1.0 - delay), 0.0, 1.0)
		if local_progress <= 0.0:
			continue
		var width := _radius * (0.40 + local_progress * 0.74) * (1.0 - tier * 0.12)
		var y := (1.0 - local_progress) * 18.0 - tier * 10.0
		var roof := PackedVector2Array([
			Vector2(-width, y + 4.0), Vector2(0.0, y - width * 0.38), Vector2(width, y + 4.0)
		])
		draw_polyline(roof, Color(0.94, 0.78, 0.34, 0.90 - tier * 0.12), 3.0, true)
		draw_line(Vector2(-width * 0.66, y + 5.0), Vector2(width * 0.66, y + 5.0), Color(0.54, 1.0, 0.68, 0.82), 2.5)
	draw_circle(Vector2.ZERO, _radius * 0.12 + progress * 4.0, Color(1.0, 0.82, 0.38, 0.82))
