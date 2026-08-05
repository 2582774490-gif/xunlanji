class_name TalismanProjectile
extends Node2D

## A short-lived procedural rune projectile for the Zhu Sha Talisman Brush.
## It is deliberately separate from sword trails and umbrella wards, so each
## finished weapon family keeps a readable combat silhouette.

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _travel_time := 0.26
var _tint := Color(1.0, 0.28, 0.16)

func launch(origin: Vector2, target: Vector2, tint := Color(1.0, 0.28, 0.16)) -> void:
	_origin = origin
	_target = target
	_tint = tint
	global_position = origin
	rotation = (target - origin).angle()
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _travel_time, 0.0, 1.0)
	global_position = _origin.lerp(_target, progress)
	scale = Vector2.ONE * (0.78 + progress * 0.28)
	modulate.a = 1.0 - progress * 0.28
	if progress >= 1.0:
		queue_free()

func _draw() -> void:
	var paper := Color(1.0, 0.80, 0.56, 0.94)
	draw_rect(Rect2(-11, -17, 22, 34), paper, true)
	draw_rect(Rect2(-11, -17, 22, 34), _tint, false, 2.0)
	draw_line(Vector2(-5, -8), Vector2(6, -3), _tint, 2.5)
	draw_line(Vector2(5, -3), Vector2(-4, 4), _tint, 2.5)
	draw_line(Vector2(-4, 4), Vector2(5, 10), _tint, 2.5)
	draw_circle(Vector2.ZERO, 22.0, Color(_tint, 0.14))
