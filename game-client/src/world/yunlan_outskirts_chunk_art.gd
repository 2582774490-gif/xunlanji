class_name YunlanOutskirtsChunkArt
extends Node2D

## Runtime-authored detail planes for Yunlan's large exploration region.
##
## Each plane represents a different terrain logic rather than a repeated
## decoration pattern. They deliberately sit above the broad procedural
## backdrop and below Y-sorted actors/foreground props. Final Image 2 terrain
## chunks can replace a plane one-for-one without changing the world layout or
## its stream boundaries.

@export var chunk_kind := "mist_stream_banks"
@export var chunk_size := Vector2(3072.0, 2048.0)
@export var palette_variant := 0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	match chunk_kind:
		"mist_stream_banks":
			_draw_mist_stream_banks()
		"cloudfoot_wood":
			_draw_cloudfoot_wood()
		"stonebud_highland":
			_draw_stonebud_highland()
		"old_caravan_road":
			_draw_old_caravan_road()
		"lan_echo_hills":
			_draw_lan_echo_hills()
		_:
			draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.14, 0.22, 0.19, 0.08), true)


func _draw_mist_stream_banks() -> void:
	# Braided shallow water and reed beds: herbs and water spirits make sense
	# here, whereas road bandits do not.
	draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.24, 0.46, 0.37, 0.10), true)
	for lane in range(3):
		var y := 360.0 + float(lane) * 510.0
		var points := PackedVector2Array()
		for point_index in range(10):
			var x := float(point_index) * 360.0 - 80.0
			points.append(Vector2(x, y + sin((x + float(lane) * 210.0) / 430.0) * 120.0))
		draw_polyline(points, Color(0.30, 0.76, 0.78, 0.52), 108.0, true)
		draw_polyline(points, Color(0.71, 0.95, 0.89, 0.52), 21.0, true)
	for bed in range(18):
		var x := 90.0 + float((bed * 173) % 2810)
		var y := 150.0 + float((bed * 307) % 1700)
		_draw_reed_bed(Vector2(x, y), 0.72 + float(bed % 4) * 0.10)
	for stone in range(16):
		var x := 130.0 + float((stone * 401) % 2760)
		var y := 180.0 + float((stone * 229) % 1640)
		draw_circle(Vector2(x, y), 16.0 + float(stone % 3) * 7.0, Color(0.29, 0.42, 0.39, 0.74))


func _draw_cloudfoot_wood() -> void:
	# A sparse, walkable forest: visible routes and clearings are preserved for
	# the water-palace approach instead of turning the entire chunk into a wall.
	draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.12, 0.31, 0.24, 0.16), true)
	var trail := PackedVector2Array([
		Vector2(-60, 1430), Vector2(540, 1270), Vector2(1160, 1410),
		Vector2(1770, 1080), Vector2(2390, 1130), Vector2(3130, 780),
	])
	draw_polyline(trail, Color(0.53, 0.45, 0.29, 0.72), 172.0, true)
	draw_polyline(trail, Color(0.77, 0.70, 0.47, 0.42), 26.0, true)
	for tree in range(28):
		var column := tree % 7
		var row := tree / 7
		var x := 160.0 + float(column) * 430.0 + float((row * 119) % 170)
		var y := 140.0 + float(row) * 430.0 + float((column * 97) % 140)
		if abs(y - (1330.0 - x * 0.16)) > 190.0:
			_draw_cloudfoot_tree(Vector2(x, y), 0.78 + float(tree % 3) * 0.13)
	for mist in range(7):
		var mist_position := Vector2(280.0 + float(mist) * 410.0, 260.0 + float((mist * 271) % 1220))
		draw_circle(mist_position, 118.0, Color(0.72, 0.94, 0.90, 0.10))
		draw_circle(mist_position + Vector2(98, 14), 92.0, Color(0.72, 0.94, 0.90, 0.08))


func _draw_stonebud_highland() -> void:
	# Terraces and windbreak crags give the highland a distinct silhouette and
	# leave exposed observation routes for wind clues and stone-bud gathering.
	draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.35, 0.31, 0.24, 0.15), true)
	for terrace in range(6):
		var y := 250.0 + float(terrace) * 315.0
		var terrace_line := PackedVector2Array([
			Vector2(-20, y + 90), Vector2(520, y - 30), Vector2(1110, y + 44),
			Vector2(1680, y - 46), Vector2(2300, y + 34), Vector2(3150, y - 24),
		])
		draw_polyline(terrace_line, Color(0.39, 0.34, 0.28, 0.68), 78.0, true)
		draw_polyline(terrace_line, Color(0.64, 0.57, 0.42, 0.52), 12.0, true)
	for crag in range(15):
		var x := 120.0 + float((crag * 317) % 2740)
		var y := 170.0 + float((crag * 443) % 1560)
		_draw_crag(Vector2(x, y), 0.72 + float(crag % 4) * 0.08)
	for bud in range(9):
		var x := 220.0 + float((bud * 631) % 2560)
		var y := 240.0 + float((bud * 279) % 1500)
		draw_circle(Vector2(x, y), 14.0, Color(0.61, 0.82, 0.50, 0.76))
		draw_circle(Vector2(x + 13, y - 16), 10.0, Color(0.76, 0.93, 0.56, 0.64))


func _draw_old_caravan_road() -> void:
	# The broad road supports caravans, travelling NPCs and ambush events, while
	# scrub outside the route keeps encounters geographically credible.
	draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.39, 0.31, 0.20, 0.13), true)
	var road := PackedVector2Array([
		Vector2(-100, 1040), Vector2(520, 1010), Vector2(1140, 1140),
		Vector2(1740, 980), Vector2(2360, 1110), Vector2(3170, 920),
	])
	draw_polyline(road, Color(0.36, 0.28, 0.18, 0.78), 270.0, true)
	draw_polyline(road, Color(0.67, 0.53, 0.31, 0.74), 138.0, true)
	draw_polyline(road, Color(0.87, 0.75, 0.48, 0.34), 15.0, true)
	for post in range(6):
		var x := 230.0 + float(post) * 480.0
		var y := 820.0 + sin(x / 420.0) * 82.0
		draw_line(Vector2(x, y), Vector2(x, y - 70.0), Color(0.24, 0.16, 0.10, 0.92), 13.0, true)
		draw_circle(Vector2(x, y - 74.0), 13.0, Color(0.72, 0.61, 0.35, 0.78))
	for scrub in range(22):
		var x := 90.0 + float((scrub * 281) % 2820)
		var y := 120.0 + float((scrub * 479) % 1740)
		if abs(y - (1040.0 + sin(x / 420.0) * 80.0)) > 230.0:
			draw_circle(Vector2(x, y), 28.0 + float(scrub % 4) * 8.0, Color(0.22, 0.39, 0.24, 0.62))


func _draw_lan_echo_hills() -> void:
	# Wind-cut hill folds point players toward the distant echo stone without
	# forcing a quest line; it is a navigable landscape, not a corridor.
	draw_rect(Rect2(Vector2.ZERO, chunk_size), Color(0.19, 0.28, 0.28, 0.14), true)
	for fold in range(7):
		var base_y := 180.0 + float(fold) * 280.0
		var fold_line := PackedVector2Array()
		for point_index in range(9):
			var x := float(point_index) * 410.0 - 70.0
			fold_line.append(Vector2(x, base_y + sin((x + float(fold) * 180.0) / 360.0) * 74.0))
		draw_polyline(fold_line, Color(0.23, 0.34, 0.34, 0.64), 66.0, true)
		draw_polyline(fold_line, Color(0.47, 0.66, 0.59, 0.35), 10.0, true)
	for pine in range(17):
		var x := 120.0 + float((pine * 373) % 2760)
		var y := 140.0 + float((pine * 257) % 1700)
		_draw_cloudfoot_tree(Vector2(x, y), 0.58 + float(pine % 3) * 0.09)


func _draw_reed_bed(position: Vector2, scale_factor: float) -> void:
	for blade in range(5):
		var offset := float(blade - 2) * 9.0
		draw_line(position + Vector2(offset, 14.0), position + Vector2(offset * 1.6, -48.0 * scale_factor), Color(0.25, 0.49, 0.28, 0.82), 5.0, true)
		draw_circle(position + Vector2(offset * 1.6, -52.0 * scale_factor), 4.0, Color(0.67, 0.81, 0.40, 0.76))


func _draw_cloudfoot_tree(position: Vector2, scale_factor: float) -> void:
	var trunk_height := 96.0 * scale_factor
	draw_line(position, position + Vector2(0, -trunk_height), Color(0.19, 0.18, 0.12, 0.86), 18.0 * scale_factor, true)
	draw_circle(position + Vector2(-26.0 * scale_factor, -trunk_height), 48.0 * scale_factor, Color(0.12, 0.31, 0.20, 0.83))
	draw_circle(position + Vector2(24.0 * scale_factor, -trunk_height - 18.0 * scale_factor), 54.0 * scale_factor, Color(0.16, 0.40, 0.25, 0.78))
	draw_circle(position + Vector2(0, -trunk_height - 48.0 * scale_factor), 43.0 * scale_factor, Color(0.23, 0.50, 0.30, 0.74))


func _draw_crag(position: Vector2, scale_factor: float) -> void:
	var width := 72.0 * scale_factor
	var height := 148.0 * scale_factor
	var polygon := PackedVector2Array([
		position + Vector2(-width, 12.0), position + Vector2(-width * 0.48, -height * 0.54),
		position + Vector2(width * 0.10, -height), position + Vector2(width, -height * 0.32),
		position + Vector2(width * 0.64, 14.0),
	])
	draw_colored_polygon(polygon, Color(0.33, 0.31, 0.27, 0.86))
	draw_line(position + Vector2(-width * 0.42, -height * 0.48), position + Vector2(width * 0.35, -height * 0.22), Color(0.63, 0.55, 0.40, 0.54), 7.0, true)
