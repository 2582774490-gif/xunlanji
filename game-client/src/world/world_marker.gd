class_name WorldMarker
extends Area2D

var marker_id := ""
var title := ""
var kind := ""
var payload := ""

func setup(data: Dictionary) -> void:
	marker_id = data.id
	title = data.title
	kind = data.kind
	payload = data.get("payload", "")
	position = data.position
	var marker := Polygon2D.new()
	marker.polygon = PackedVector2Array([Vector2(0, -24), Vector2(20, 0), Vector2(0, 24), Vector2(-20, 0)])
	marker.color = _marker_color()
	add_child(marker)
	var label := Label.new()
	label.text = title
	label.position = Vector2(-88, 28)
	label.size = Vector2(176, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("fff0b0"))
	add_child(label)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 68.0
	collision.shape = shape
	add_child(collision)

func _marker_color() -> Color:
	match kind:
		"dungeon": return Color("59c9ee")
		"gate": return Color("f0ba65")
		"npc": return Color("ce91ee")
		_: return Color("75e798")
