class_name PuppetDashEffect
extends Node2D

## A small summoned puppet rushes from its owner to the target, strikes, then
## fades. This uses the actual puppet asset rather than a generic projectile.

const PUPPET_TEXTURE := preload("res://assets/art/weapons/moxu_qi_puppet/processed_alpha/moxu_qi_puppet_v01_alpha.png")

var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _elapsed := 0.0
var _duration := 0.28
var _size := 0.052
var _sprite: Sprite2D

func launch(origin: Vector2, target: Vector2, size := 0.052) -> void:
	_origin = origin
	_target = target
	_size = size
	global_position = origin
	_sprite = Sprite2D.new()
	_sprite.texture = PUPPET_TEXTURE
	_sprite.scale = Vector2(_size, _size)
	_sprite.position = Vector2(0.0, -28.0)
	_sprite.z_index = 5
	add_child(_sprite)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var lunge := sin(progress * PI) * 14.0
	global_position = _origin.lerp(_target, progress) + Vector2(0.0, -lunge)
	if _sprite != null:
		_sprite.rotation = sin(progress * PI) * deg_to_rad(9.0)
		_sprite.modulate.a = 1.0 if progress < 0.78 else (1.0 - progress) / 0.22
	queue_redraw()
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var radius := 11.0 + progress * 12.0
	draw_arc(Vector2(0.0, -22.0), radius, deg_to_rad(-150.0), deg_to_rad(35.0), 12, Color(0.40, 1.0, 0.82, 0.82), 2.8, true)
	if progress > 0.74:
		draw_circle(Vector2(0.0, -22.0), 18.0, Color(0.88, 0.76, 0.30, (progress - 0.74) / 0.26))
