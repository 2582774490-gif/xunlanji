class_name GroundShadow
extends Node2D

## A separate ground-contact layer.  Keeping it outside of the character art
## makes equipment, clothing and body sheets replaceable without baking a
## shadow into every asset.
@export var tint := Color(0.025, 0.08, 0.09, 0.42)
@export var radius := Vector2(24.0, 8.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, radius.y / radius.x))
	draw_circle(Vector2.ZERO, radius.x, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
