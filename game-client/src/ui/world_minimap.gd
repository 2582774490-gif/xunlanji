class_name WorldMinimap
extends Control

## A regional orientation map, not a fast-travel menu.  It compresses the
## current 12 km x 8 km region into a readable reference while the player
## still has to travel through the continuous world themselves.

const PANEL_SIZE := Vector2(256.0, 176.0)
const MAP_RECT := Rect2(14.0, 36.0, 228.0, 118.0)

var player: Node2D
var world_bounds := Rect2(0.0, 0.0, 1.0, 1.0)
var landmarks: Array[Dictionary] = []
var roads: Array[PackedVector2Array] = []
var region_title := ""
var _title_label: Label
var _scale_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 1.0
	anchor_right = 1.0
	offset_left = -270.0
	offset_top = 14.0
	offset_right = -14.0
	offset_bottom = 190.0
	custom_minimum_size = PANEL_SIZE
	_title_label = Label.new()
	_title_label.position = Vector2(14.0, 8.0)
	_title_label.size = Vector2(226.0, 22.0)
	_title_label.add_theme_font_size_override("font_size", 15)
	_title_label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0))
	add_child(_title_label)
	_scale_label = Label.new()
	_scale_label.position = Vector2(14.0, 154.0)
	_scale_label.size = Vector2(228.0, 18.0)
	_scale_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_scale_label.add_theme_font_size_override("font_size", 11)
	_scale_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.82))
	add_child(_scale_label)
	_refresh_labels()


func configure_region(
		player_node: Node2D,
		bounds: Rect2,
		title: String,
		known_landmarks: Array[Dictionary],
		regional_roads: Array[PackedVector2Array] = []
	) -> void:
	player = player_node
	world_bounds = bounds
	region_title = title
	landmarks = known_landmarks.duplicate(true)
	roads = regional_roads.duplicate(true)
	_refresh_labels()
	queue_redraw()


func player_map_position() -> Vector2:
	if player == null:
		return Vector2.ZERO
	return _map_point(player.global_position)


func _process(_delta: float) -> void:
	queue_redraw()


func _refresh_labels() -> void:
	if _title_label == null:
		return
	_title_label.text = region_title if not region_title.is_empty() else "区域舆图"
	var width_km := world_bounds.size.x / 1000.0
	var height_km := world_bounds.size.y / 1000.0
	_scale_label.text = "%.1f × %.1f km  ·  仅作方位" % [width_km, height_km]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), Color(0.025, 0.07, 0.10, 0.89), true)
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), Color(0.38, 0.67, 0.74, 0.76), false, 1.0)
	draw_rect(MAP_RECT, Color(0.08, 0.18, 0.20, 0.94), true)
	draw_rect(MAP_RECT, Color(0.34, 0.61, 0.64, 0.54), false, 1.0)
	_draw_grid()
	for road in roads:
		_draw_road(road)
	for landmark in landmarks:
		_draw_landmark(landmark)
	if player != null:
		_draw_player_marker(player_map_position())


func _draw_grid() -> void:
	for column in range(1, 4):
		var x := MAP_RECT.position.x + MAP_RECT.size.x * float(column) / 4.0
		draw_line(Vector2(x, MAP_RECT.position.y), Vector2(x, MAP_RECT.end.y), Color(0.27, 0.46, 0.48, 0.24), 1.0)
	for row in range(1, 3):
		var y := MAP_RECT.position.y + MAP_RECT.size.y * float(row) / 3.0
		draw_line(Vector2(MAP_RECT.position.x, y), Vector2(MAP_RECT.end.x, y), Color(0.27, 0.46, 0.48, 0.24), 1.0)


func _draw_road(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	var mapped := PackedVector2Array()
	for point in points:
		mapped.append(_map_point(point))
	draw_polyline(mapped, Color(0.67, 0.63, 0.42, 0.76), 1.7, true)


func _draw_landmark(landmark: Dictionary) -> void:
	var point: Vector2 = landmark.get("position", Vector2.ZERO)
	var kind := str(landmark.get("kind", "landmark"))
	var color := _landmark_color(kind)
	var mapped := _map_point(point)
	draw_circle(mapped, 3.1, Color(0.01, 0.04, 0.05, 0.9))
	draw_circle(mapped, 2.0, color)


func _draw_player_marker(point: Vector2) -> void:
	var direction := Vector2.UP
	if player is CharacterBody2D and (player as CharacterBody2D).velocity.length_squared() > 1.0:
		direction = (player as CharacterBody2D).velocity.normalized()
	var side := direction.orthogonal() * 3.5
	var tip := point + direction * 5.5
	var tail := point - direction * 3.5
	draw_colored_polygon(PackedVector2Array([tip, tail + side, tail - side]), Color(1.0, 0.89, 0.38))
	draw_arc(point, 6.0, 0.0, TAU, 16, Color(1.0, 0.93, 0.58, 0.62), 1.0, true)


func _map_point(world_point: Vector2) -> Vector2:
	var safe_size := Vector2(maxf(world_bounds.size.x, 1.0), maxf(world_bounds.size.y, 1.0))
	var normalized := (world_point - world_bounds.position) / safe_size
	normalized = normalized.clamp(Vector2.ZERO, Vector2.ONE)
	return MAP_RECT.position + normalized * MAP_RECT.size


func _landmark_color(kind: String) -> Color:
	match kind:
		"gate":
			return Color(0.58, 0.79, 1.0)
		"dungeon":
			return Color(1.0, 0.55, 0.37)
		"resource":
			return Color(0.49, 0.93, 0.61)
		"relic":
			return Color(0.86, 0.65, 1.0)
		"water":
			return Color(0.39, 0.87, 0.94)
		_:
			return Color(0.78, 0.82, 0.72)
