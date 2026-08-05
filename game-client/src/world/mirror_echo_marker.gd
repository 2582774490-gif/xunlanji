class_name MirrorEchoMarker
extends Node2D

## A local illusion marker shown only after Zhaoying Qi Mirror reveals it.
## It makes the artifact's exploration role visible without scattering the
## same random encounter uniformly across unrelated maps.

var _elapsed := 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 0.5 + sin(_elapsed * 2.4) * 0.5
	var outer_radius := 40.0 + pulse * 7.0
	draw_arc(Vector2.ZERO, outer_radius, 0.0, TAU, 40, Color(0.58, 0.86, 0.98, 0.42 + pulse * 0.20), 2.0, true)
	draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 32, Color(0.83, 0.96, 1.0, 0.50), 1.4, true)
	for index in 4:
		var angle := float(index) * TAU / 4.0 + _elapsed * 0.22
		var direction := Vector2(cos(angle), sin(angle) * 0.52)
		draw_line(direction * 13.0, direction * 31.0, Color(0.70, 0.92, 1.0, 0.36 + pulse * 0.18), 1.4)
	draw_circle(Vector2.ZERO, 7.0 + pulse * 3.0, Color(0.76, 0.94, 1.0, 0.42))
