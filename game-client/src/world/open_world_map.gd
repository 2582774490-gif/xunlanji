class_name OpenWorldMap
extends Node2D

const WORLD_SIZE := Vector2(4096.0, 2304.0)

var region_id := "starter_village"

func configure(value: String) -> void:
	region_id = value
	queue_redraw()

func _draw() -> void:
	var palette := _palette()
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), palette["ground"])
	_draw_grid(palette["grid"])
	_draw_landmarks(palette)
	_draw_roads(palette["road"], palette["road_edge"])
	_draw_water(palette["water"], palette["water_line"])
	_draw_buildings(palette["roof"], palette["wall"], palette["lantern"])

func _palette() -> Dictionary:
	match region_id:
		"mist_border":
			return {"ground": Color("163f45"), "grid": Color("25585b"), "road": Color("6d7d6b"), "road_edge": Color("314e4d"), "water": Color("2a6971"), "water_line": Color("8bc7c5"), "roof": Color("2e344d"), "wall": Color("65736f"), "lantern": Color("e5bd6c")}
		"ancient_ridge":
			return {"ground": Color("40363a"), "grid": Color("59494a"), "road": Color("8b7155"), "road_edge": Color("4f403b"), "water": Color("4f6b78"), "water_line": Color("a7c0c5"), "roof": Color("5d3e36"), "wall": Color("8b7662"), "lantern": Color("f0a953")}
		_:
			return {"ground": Color("31534b"), "grid": Color("466b5e"), "road": Color("937a54"), "road_edge": Color("65563f"), "water": Color("2e7590"), "water_line": Color("86c6d1"), "roof": Color("6e4440"), "wall": Color("9a8766"), "lantern": Color("f4c66d")}

func _draw_grid(color: Color) -> void:
	for x in range(0, int(WORLD_SIZE.x) + 1, 256):
		draw_line(Vector2(x, 0), Vector2(x, WORLD_SIZE.y), color, 1.0)
	for y in range(0, int(WORLD_SIZE.y) + 1, 256):
		draw_line(Vector2(0, y), Vector2(WORLD_SIZE.x, y), color, 1.0)

func _draw_landmarks(palette: Dictionary) -> void:
	var mountain_color: Color = palette["grid"].darkened(0.14)
	for i in 16:
		var x := float((i * 293) % 4000 + 40)
		var y := float((i * 521) % 2100 + 80)
		var mountain := PackedVector2Array([Vector2(x - 110, y + 90), Vector2(x, y - 130), Vector2(x + 120, y + 90)])
		draw_colored_polygon(mountain, mountain_color)

func _draw_roads(road: Color, edge: Color) -> void:
	var points := PackedVector2Array([Vector2(240, 1700), Vector2(900, 1430), Vector2(1580, 1510), Vector2(2330, 1180), Vector2(3020, 920), Vector2(3830, 590)])
	draw_polyline(points, edge, 122.0, true)
	draw_polyline(points, road, 92.0, true)
	var branch := PackedVector2Array([Vector2(1580, 1510), Vector2(1700, 870), Vector2(2500, 560), Vector2(3430, 420)])
	draw_polyline(branch, edge, 92.0, true)
	draw_polyline(branch, road, 64.0, true)

func _draw_water(water: Color, line_color: Color) -> void:
	if region_id == "ancient_ridge":
		return
	var river := PackedVector2Array([Vector2(0, 330), Vector2(680, 510), Vector2(1310, 420), Vector2(1970, 610), Vector2(2660, 420), Vector2(3380, 600), Vector2(4096, 460), Vector2(4096, 0), Vector2(0, 0)])
	draw_colored_polygon(river, water)
	for x in range(80, 4050, 220):
		draw_line(Vector2(x, 245 + (x % 180)), Vector2(x + 110, 245 + (x % 180)), line_color, 3.0)

func _draw_buildings(roof: Color, wall: Color, lantern: Color) -> void:
	var buildings := [Vector2(800, 1220), Vector2(1080, 1280), Vector2(1260, 1120), Vector2(1760, 1440), Vector2(1960, 1220), Vector2(2320, 940), Vector2(2850, 860)]
	for position in buildings:
		var body := Rect2(position - Vector2(62, 36), Vector2(124, 72))
		draw_rect(body, wall)
		var roof_shape := PackedVector2Array([position + Vector2(-78, -34), position + Vector2(0, -92), position + Vector2(78, -34)])
		draw_colored_polygon(roof_shape, roof)
		draw_circle(position + Vector2(0, 42), 5.0, lantern)
