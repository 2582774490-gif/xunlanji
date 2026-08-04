class_name LargeRegionBackdrop
extends Node2D

## A large region is assembled from many art chunks.  This node is the
## low-detail terrain base between those chunks, so the playable world is not
## limited to the size of a single painted background image.
@export var region_size := Vector2(12000.0, 8000.0)
@export var region_style := "mist_border"

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var palette := _palette()
	draw_rect(Rect2(Vector2.ZERO, region_size), palette.ground)
	_draw_rivers(palette)
	_draw_long_roads(palette)
	_draw_landform_clusters(palette)
	_draw_chunk_blending(palette)
	_draw_far_landmarks(palette)

func _palette() -> Dictionary:
	match region_style:
		"thunder_cliff":
			return {
				"ground": Color("192331"), "water": Color("1c405a"),
				"road_edge": Color("111827"), "road": Color("5f6c76"),
				"mountain": Color("111c2d"), "mist": Color("46586d"),
				"landmark": Color("7e8cff"),
			}
		"red_maple":
			return {
				"ground": Color("3d241f"), "water": Color("254753"),
				"road_edge": Color("2b1717"), "road": Color("a86f42"),
				"mountain": Color("291d25"), "mist": Color("6f483e"),
				"landmark": Color("f4a24b"),
			}
		_:
			return {
				"ground": Color("173c3c"), "water": Color("245e67"),
				"road_edge": Color("143034"), "road": Color("6b806d"),
				"mountain": Color("123035"), "mist": Color("3f7773"),
				"landmark": Color("7acfc3"),
			}

func _draw_rivers(palette: Dictionary) -> void:
	var river := PackedVector2Array([
		Vector2(-80, 740), Vector2(1500, 940), Vector2(2900, 730), Vector2(4350, 1090),
		Vector2(6080, 780), Vector2(7720, 1180), Vector2(9400, 860), Vector2(12080, 1120),
		Vector2(12080, 0), Vector2(-80, 0),
	])
	draw_colored_polygon(river, palette.water)
	for x in range(120, int(region_size.x), 360):
		var y := 360.0 + float((x * 37) % 620)
		draw_line(Vector2(x, y), Vector2(x + 150, y + 12), palette.mist.lightened(0.18), 3.0)

func _draw_long_roads(palette: Dictionary) -> void:
	var main_road := PackedVector2Array([
		Vector2(300, 1600), Vector2(1520, 1480), Vector2(2780, 1690), Vector2(4220, 1410),
		Vector2(5580, 1880), Vector2(7050, 1540), Vector2(8510, 1900), Vector2(10100, 1510), Vector2(11700, 1720),
	])
	draw_polyline(main_road, palette.road_edge, 132.0, true)
	draw_polyline(main_road, palette.road, 94.0, true)
	var north_branch := PackedVector2Array([
		Vector2(4220, 1410), Vector2(4680, 2790), Vector2(5900, 3360), Vector2(7150, 3100), Vector2(8450, 3850),
	])
	draw_polyline(north_branch, palette.road_edge, 96.0, true)
	draw_polyline(north_branch, palette.road, 62.0, true)
	var south_branch := PackedVector2Array([
		Vector2(7050, 1540), Vector2(7600, 2910), Vector2(9000, 3650), Vector2(10900, 3520),
	])
	draw_polyline(south_branch, palette.road_edge, 96.0, true)
	draw_polyline(south_branch, palette.road, 62.0, true)

func _draw_landform_clusters(palette: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 912023 if region_style == "mist_border" else 618603
	for i in 96:
		var x := rng.randf_range(120.0, region_size.x - 120.0)
		var y := rng.randf_range(560.0, region_size.y - 160.0)
		# Keep the central road network readable.  Dense terrain gathers at its
		# edges instead of being evenly scattered over every tile.
		if y < 2250.0 and rng.randf() < 0.55:
			y += 2100.0
		var radius := rng.randf_range(80.0, 250.0)
		var hill := PackedVector2Array([
			Vector2(x - radius, y + radius * 0.55), Vector2(x - radius * 0.35, y - radius),
			Vector2(x + radius * 0.22, y - radius * 0.48), Vector2(x + radius, y + radius * 0.55),
		])
		draw_colored_polygon(hill, palette.mountain.lightened(rng.randf_range(0.0, 0.16)))
		if i % 3 == 0:
			draw_circle(Vector2(x, y - radius * 0.22), radius * 0.44, palette.mist.darkened(0.18))

func _draw_chunk_blending(palette: Dictionary) -> void:
	# Fine painted backgrounds are placed on top as chunk art.  These soft
	# boundaries make room for many future authored chunks without a hard edge.
	for x in range(0, int(region_size.x), 3072):
		for y in range(0, int(region_size.y), 2048):
			draw_rect(Rect2(x + 32, y + 32, 3008, 1984), palette.mist.darkened(0.42), false, 2.0)

func _draw_far_landmarks(palette: Dictionary) -> void:
	for point in [Vector2(4090, 1420), Vector2(5910, 3350), Vector2(8410, 3850), Vector2(10880, 3510)]:
		draw_circle(point, 44.0, palette.landmark.darkened(0.45))
		draw_circle(point, 19.0, palette.landmark)
