class_name TidewardWatchstone
extends Node2D

## A fixed highland landmark, deliberately kept separate from the random
## ecology system.  Its layered geometry gives the wide map a readable
## three-dimensional landmark without turning the whole ridge into a camp.

var _wind_phase := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	_wind_phase = fmod(_wind_phase + delta * 1.15, TAU)
	queue_redraw()

func _draw() -> void:
	# Ground shadow and stepped basalt foundation.
	draw_ellipse(Vector2(0, 4), Vector2(104, 22), Color(0.02, 0.05, 0.06, 0.48))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-92, 0), Vector2(-46, -32), Vector2(58, -28), Vector2(102, 4),
		Vector2(48, 30), Vector2(-54, 28),
	]), Color("25464a"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-68, -2), Vector2(-34, -24), Vector2(44, -22), Vector2(72, 2),
		Vector2(36, 18), Vector2(-40, 17),
	]), Color("3f6d6a"))
	# A weathered observation stele with a lighter face and deep side plane.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -20), Vector2(-20, -170), Vector2(12, -208), Vector2(52, -168),
		Vector2(46, -22), Vector2(6, -3),
	]), Color("18343a"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -20), Vector2(-20, -170), Vector2(12, -208), Vector2(22, -164),
		Vector2(16, -26), Vector2(6, -3),
	]), Color("69968d"))
	draw_line(Vector2(-12, -144), Vector2(7, -159), Color("b3e1ce"), 3.0)
	draw_line(Vector2(-7, -106), Vector2(12, -120), Color("9bcbc0"), 3.0)
	draw_line(Vector2(-3, -67), Vector2(14, -80), Color("9bcbc0"), 3.0)
	# The silk marker moves independently above the stone, making the landmark
	# feel spatially alive when the player passes it in eight directions.
	var drift := sin(_wind_phase) * 11.0
	draw_polyline(PackedVector2Array([
		Vector2(17, -174), Vector2(66, -165 + drift * 0.18),
		Vector2(92, -140 + drift), Vector2(122, -150 + drift * 0.65),
	]), Color("9ddfd1"), 7.0, true)
	draw_polyline(PackedVector2Array([
		Vector2(17, -174), Vector2(66, -165 + drift * 0.18),
		Vector2(92, -140 + drift), Vector2(122, -150 + drift * 0.65),
	]), Color("d5fff0"), 2.0, true)
	draw_circle(Vector2(11, -182), 7.0, Color("d5fff0"))

func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
