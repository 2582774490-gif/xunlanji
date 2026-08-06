extends Node2D

const FrameController = preload("res://src/animation/frame_animation_controller.gd")

@onready var avatar: FrameAnimationController = $Avatar
@onready var status: Label = $CanvasLayer/Status


func _ready() -> void:
	var costume: Dictionary = GameCatalog.costume_profile_for_id("liulan_wayfarer")
	var sword: Dictionary = GameCatalog.weapon_runtime_profile_for_item("青篁练气剑")
	var south_idle: Texture2D = load(str(costume.get("idle_south_asset", ""))) as Texture2D
	if south_idle == null:
		status.text = "缺少流岚游衣南向待机资源。"
		return
	avatar.configure_from_grid(south_idle, 1, 1, {"idle_south": {"frames": [0], "fps": 1.0, "loop": true}})
	_append_idle_directions(costume)
	_append_walk_directions(costume)
	_append_qinghuang_attack(sword)
	avatar.play_action("idle", "south")
	status.text = "方向键：切换八方向行走；松开后停在对应待机。J：播放青篁练气剑南向六帧普攻。此场景仅用于资源验收。"


func _process(_delta: float) -> void:
	var movement: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if movement.length_squared() > 0.001:
		avatar.play_action("walk", avatar.direction_from_vector(movement))
	elif avatar.current_action == "walk":
		avatar.play_action("idle", avatar.current_direction)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode != KEY_J:
		return
	avatar.play_action("attack", "south", true)
	get_viewport().set_input_as_handled()


func _append_idle_directions(costume: Dictionary) -> void:
	var directions: Array[String] = ["south_west", "west", "north_west", "north", "north_east", "east", "south_east"]
	for direction: String in directions:
		var texture: Texture2D = load(str(costume.get("idle_%s_asset" % direction, ""))) as Texture2D
		if texture != null:
			avatar.append_grid_clips(texture, 1, 1, {"idle_%s" % direction: {"frames": [0], "fps": 1.0, "loop": true}})


func _append_walk_directions(costume: Dictionary) -> void:
	var directions: Array[String] = ["south", "south_west", "west", "north_west", "north", "north_east", "east", "south_east"]
	for direction: String in directions:
		var paths: Array = costume.get("walk_%s_frames" % direction, [])
		var frame_sources: Array = _frame_sources_from_paths(paths)
		if frame_sources.size() == 6:
			avatar.append_mixed_grid_clip("walk_%s" % direction, frame_sources, 9.0, true)


func _append_qinghuang_attack(sword: Dictionary) -> void:
	var paths: Array = sword.get("attack_frames", [])
	var frame_sources: Array = _frame_sources_from_paths(paths)
	if frame_sources.size() == 6:
		avatar.append_mixed_grid_clip("attack_south", frame_sources, 14.0, false)


func _frame_sources_from_paths(paths: Array) -> Array:
	var sources: Array = []
	for path_variant: Variant in paths:
		var texture: Texture2D = load(str(path_variant)) as Texture2D
		if texture != null:
			sources.append({"sheet": texture, "columns": 1, "rows": 1, "frame": 0})
	return sources
