class_name RegionChunkStreamer
extends Node

## Loads only nearby high-detail terrain art. Gameplay entities remain in the
## region, so moving across a chunk boundary never resets exploration state.
@export var load_radius := 2900.0
@export var unload_radius := 3500.0

var _player: Node2D
var _chunks: Array = []

func configure(player: Node2D, chunks: Array) -> void:
	_player = player
	_chunks = chunks
	_refresh(true)

func _process(_delta: float) -> void:
	_refresh(false)

func loaded_chunk_count() -> int:
	var count := 0
	for chunk in _chunks:
		var node: CanvasItem = chunk.node
		if node.visible:
			count += 1
	return count

func _refresh(force: bool) -> void:
	if _player == null:
		return
	for chunk in _chunks:
		var node: CanvasItem = chunk.node
		var bounds: Rect2 = chunk.bounds
		var distance := _distance_to_rect(_player.position, bounds)
		var should_load := distance <= load_radius
		var should_unload := distance > unload_radius
		if force or should_load:
			node.visible = true
		elif should_unload:
			node.visible = false

func _distance_to_rect(point: Vector2, rect: Rect2) -> float:
	var nearest := point.clamp(rect.position, rect.end)
	return point.distance_to(nearest)
