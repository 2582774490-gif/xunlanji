class_name ArtifactMotionController
extends Node2D

## Runtime controller for a protective artifact.  An artifact remains a child
## of the player so it can be swapped independently from the body, costume and
## weapon layers.  The small orbit/bob gives it life without pretending a
## single image is a complete character animation.

@export var orbit_radius := Vector2(30.0, 13.0)
@export var orbit_speed := 1.45
@export var hover_height := 5.0
@export var follow_speed := 7.5

var _elapsed := 0.0
var _direction := "south"
var _moving := false


func update_from_movement(movement: Vector2, direction: String) -> void:
	_moving = movement.length_squared() > 0.001
	if not direction.is_empty():
		_direction = direction


func _process(delta: float) -> void:
	_elapsed += delta
	var facing_sign := -1.0 if _direction.ends_with("west") or _direction == "west" else 1.0
	var pace := 1.5 if _moving else 1.0
	var angle := _elapsed * orbit_speed * pace
	var orbit := Vector2(cos(angle) * orbit_radius.x, sin(angle * 1.8) * orbit_radius.y)
	var anchor := Vector2(30.0 * facing_sign, -47.0)
	var target := anchor + orbit + Vector2(0.0, sin(angle * 2.4) * hover_height)
	position = position.lerp(target, minf(delta * follow_speed, 1.0))
	rotation = sin(angle * 1.3) * 0.08 * facing_sign
