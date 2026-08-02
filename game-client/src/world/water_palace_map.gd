class_name WaterPalaceMap
extends Node2D

const SIZE := Vector2(2560.0, 1536.0)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("102d3d"))
	for x in range(0, 2560, 192):
		for y in range(0, 1536, 192):
			draw_circle(Vector2(x + 92, y + 92), 64.0, Color("17495c"))
	var path := PackedVector2Array([Vector2(100, 1160), Vector2(720, 1050), Vector2(1260, 780), Vector2(1900, 760), Vector2(2360, 760)])
	draw_polyline(path, Color("2f2635"), 192.0, true)
	draw_polyline(path, Color("7294a0"), 150.0, true)
	for position in [Vector2(920, 950), Vector2(1450, 780), Vector2(1980, 760)]:
		draw_rect(Rect2(position - Vector2(108, 70), Vector2(216, 140)), Color("304258"))
		draw_colored_polygon(PackedVector2Array([position + Vector2(-132, -68), position + Vector2(0, -150), position + Vector2(132, -68)]), Color("536177"))
		draw_circle(position + Vector2(0, 22), 10, Color("75dce0"))
	draw_circle(Vector2(2180, 755), 250, Color("1d6d83"))
	draw_arc(Vector2(2180, 755), 250, 0, TAU, 64, Color("84e3e1"), 5.0, true)
