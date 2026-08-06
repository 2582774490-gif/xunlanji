class_name LargeRegionBackdrop
extends Node2D

const RegionalSectorCatalogScript = preload("res://src/world/regional_sector_catalog.gd")

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
	_draw_sector_washes(palette)
	_draw_rivers(palette)
	_draw_long_roads(palette)
	_draw_landform_clusters(palette)
	_draw_chunk_blending(palette)
	_draw_far_landmarks(palette)

func _palette() -> Dictionary:
	match region_style:
		"yunlan_outskirts":
			return {
				"ground": Color("284535"), "water": Color("377784"),
				"road_edge": Color("273129"), "road": Color("a58a5d"),
				"mountain": Color("1c392e"), "mist": Color("6aa59a"),
				"landmark": Color("d6c172"),
			}
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
		"mist_port":
			return {
				"ground": Color("173f4a"), "water": Color("236f78"),
				"road_edge": Color("163039"), "road": Color("789092"),
				"mountain": Color("17333b"), "mist": Color("4c8583"),
				"landmark": Color("e2b46c"),
			}
		"ancient_ridge":
			return {
				"ground": Color("3b302d"), "water": Color("4a5964"),
				"road_edge": Color("241d20"), "road": Color("967a56"),
				"mountain": Color("2c2223"), "mist": Color("68534c"),
				"landmark": Color("f28f4b"),
			}
		_:
			return {
				"ground": Color("173c3c"), "water": Color("245e67"),
				"road_edge": Color("143034"), "road": Color("6b806d"),
				"mountain": Color("123035"), "mist": Color("3f7773"),
				"landmark": Color("7acfc3"),
			}

func _draw_rivers(palette: Dictionary) -> void:
	if region_style == "yunlan_outskirts":
		var mist_stream := PackedVector2Array([
			Vector2(-80, 480), Vector2(1320, 700), Vector2(2620, 540), Vector2(3780, 880),
			Vector2(4980, 720), Vector2(6420, 1080), Vector2(7860, 860), Vector2(9300, 1180),
			Vector2(12080, 1020), Vector2(12080, 0), Vector2(-80, 0),
		])
		draw_colored_polygon(mist_stream, palette.water)
		for x in range(160, int(region_size.x), 420):
			var y := 360.0 + float((x * 23) % 580)
			draw_line(Vector2(x, y), Vector2(x + 126, y + 16), palette.mist.lightened(0.2), 3.0)
		return
	if region_style == "ancient_ridge":
		# Ancient Ridge has no coast-like river.  Its visible flow is the unstable
		# earthfire vein that originates in the ravine, then fades into ash basins.
		var earthfire := PackedVector2Array([
			Vector2(2440, 640), Vector2(3320, 890), Vector2(4120, 720), Vector2(5060, 1080),
			Vector2(5840, 1640), Vector2(6760, 1870),
		])
		draw_polyline(earthfire, palette.mountain.darkened(0.5), 76.0, true)
		draw_polyline(earthfire, palette.landmark.darkened(0.32), 32.0, true)
		for point in earthfire:
			draw_circle(point, 34.0, palette.landmark.darkened(0.45))
			draw_circle(point, 14.0, palette.landmark)
		return
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
	if region_style == "yunlan_outskirts":
		var south_gate_road := PackedVector2Array([
			Vector2(360, 1700), Vector2(1440, 1530), Vector2(2600, 1740), Vector2(3840, 1460),
			Vector2(5140, 1770), Vector2(6460, 1500), Vector2(7860, 1710), Vector2(9320, 1460), Vector2(11700, 1680),
		])
		_draw_road_pair(south_gate_road, palette, 138.0, 96.0)
		var highland_path := PackedVector2Array([
			Vector2(2600, 1740), Vector2(2320, 2840), Vector2(3180, 3600), Vector2(4100, 4260),
		])
		_draw_road_pair(highland_path, palette, 92.0, 58.0)
		var cloudfoot_path := PackedVector2Array([
			Vector2(5140, 1770), Vector2(5480, 2820), Vector2(6760, 3600), Vector2(8300, 4050),
		])
		_draw_road_pair(cloudfoot_path, palette, 92.0, 58.0)
		return
	if region_style == "ancient_ridge":
		var ridge_road := PackedVector2Array([
			Vector2(300, 1660), Vector2(1420, 1490), Vector2(2360, 1320), Vector2(3480, 1430),
			Vector2(4680, 1280), Vector2(5860, 1620), Vector2(7080, 1490), Vector2(8460, 1730),
			Vector2(10480, 1430), Vector2(11700, 1620),
		])
		_draw_road_pair(ridge_road, palette, 126.0, 84.0)
		var fire_branch := PackedVector2Array([
			Vector2(2360, 1320), Vector2(3060, 980), Vector2(4320, 820), Vector2(5750, 430),
		])
		_draw_road_pair(fire_branch, palette, 90.0, 56.0)
		var battlefield_branch := PackedVector2Array([
			Vector2(7080, 1490), Vector2(7320, 850), Vector2(7320, 350), Vector2(8400, 640),
		])
		_draw_road_pair(battlefield_branch, palette, 90.0, 56.0)
		return
	var main_road := PackedVector2Array([
		Vector2(300, 1600), Vector2(1520, 1480), Vector2(2780, 1690), Vector2(4220, 1410),
		Vector2(5580, 1880), Vector2(7050, 1540), Vector2(8510, 1900), Vector2(10100, 1510), Vector2(11700, 1720),
	])
	_draw_road_pair(main_road, palette, 132.0, 94.0)
	var north_branch := PackedVector2Array([
		Vector2(4220, 1410), Vector2(4680, 2790), Vector2(5900, 3360), Vector2(7150, 3100), Vector2(8450, 3850),
	])
	_draw_road_pair(north_branch, palette, 96.0, 62.0)
	var south_branch := PackedVector2Array([
		Vector2(7050, 1540), Vector2(7600, 2910), Vector2(9000, 3650), Vector2(10900, 3520),
	])
	_draw_road_pair(south_branch, palette, 96.0, 62.0)

func _draw_road_pair(points: PackedVector2Array, palette: Dictionary, edge_width: float, road_width: float) -> void:
	draw_polyline(points, palette.road_edge, edge_width, true)
	draw_polyline(points, palette.road, road_width, true)

func _draw_landform_clusters(palette: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 912023 if region_style == "mist_border" else 618603
	for i in 150:
		var x := rng.randf_range(120.0, region_size.x - 120.0)
		var y := rng.randf_range(560.0, region_size.y - 160.0)
		var sector := RegionalSectorCatalogScript.sector_at(region_style, Vector2(x, y))
		var terrain_kind := str(sector.get("terrain", "highland"))
		# Geographic bands control density.  Roads, stable checkpoints and broad
		# resources stay readable; highlands and old battlefields carry the dense
		# silhouette, rather than using an even scatter across the whole map.
		if rng.randf() > _landform_density(terrain_kind):
			continue
		var radius := rng.randf_range(80.0, 250.0)
		var hill := PackedVector2Array([
			Vector2(x - radius, y + radius * 0.55), Vector2(x - radius * 0.35, y - radius),
			Vector2(x + radius * 0.22, y - radius * 0.48), Vector2(x + radius, y + radius * 0.55),
		])
		draw_colored_polygon(hill, palette.mountain.lightened(rng.randf_range(0.0, 0.16)))
		if i % 3 == 0 and terrain_kind != "settled":
			draw_circle(Vector2(x, y - radius * 0.22), radius * 0.44, palette.mist.darkened(0.18))

func _draw_sector_washes(palette: Dictionary) -> void:
	for sector in RegionalSectorCatalogScript.sectors_for(region_style):
		var bounds: Rect2 = sector.get("bounds", Rect2())
		var fill := _sector_color(str(sector.get("terrain", "highland")), palette)
		fill.a = 0.42
		draw_rect(bounds, fill, true)
		var rim := fill.lightened(0.14)
		rim.a = 0.32
		draw_rect(bounds.grow(-16.0), rim, false, 2.0)

func _landform_density(terrain_kind: String) -> float:
	match terrain_kind:
		"settled": return 0.15
		"water": return 0.22
		"resource": return 0.28
		"forest", "marsh": return 0.48
		"fire", "battlefield", "relic": return 0.58
		_: return 0.72

func _sector_color(terrain_kind: String, palette: Dictionary) -> Color:
	match terrain_kind:
		"settled": return palette.road.darkened(0.28)
		"water": return palette.water.lightened(0.12)
		"resource": return palette.mist.lightened(0.08)
		"forest": return palette.mountain.lightened(0.10)
		"marsh": return palette.mist.darkened(0.08)
		"fire": return palette.landmark.darkened(0.46)
		"battlefield": return palette.mountain.lightened(0.06)
		"relic": return palette.road.darkened(0.18)
		_: return palette.mountain.lightened(0.08)

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
