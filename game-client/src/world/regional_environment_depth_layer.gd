class_name RegionalEnvironmentDepthLayer
extends Node2D

## Places environment elements at their feet position in the same Y-sort plane
## as the player. Walking north of a tree or rock puts the player behind it;
## walking south brings the player in front, instead of treating a map as one poster.

const MIST_PINES: Texture2D = preload("res://assets/art/maps/mist_tide_border/props/processed_alpha/mist_tide_border_mist_pines_v01_alpha.png")
const JADE_PINE: Texture2D = preload("res://assets/art/maps/yunlan_south_gate/props/processed_alpha/yunlan_south_gate_jade_pine_v01_alpha.png")

@export var region_style := "mist_border"

var prop_count := 0
var foreground_prop_count := 0


func _ready() -> void:
	y_sort_enabled = true
	match region_style:
		"yunlan_outskirts":
			_build_yunlan_outskirts_depth()
		"mist_border":
			_build_mist_border_depth()
		"ancient_ridge":
			_build_ancient_ridge_depth()


func _build_yunlan_outskirts_depth() -> void:
	# 林木只压在山径、溪岸与丘陵转折处，给大世界留下可望见的空地。
	var placements: Array[Dictionary] = [
		{"at": Vector2(980, 1050), "scale": 0.36, "flip": false},
		{"at": Vector2(2880, 1120), "scale": 0.42, "flip": true},
		{"at": Vector2(4700, 1780), "scale": 0.46, "flip": false},
		{"at": Vector2(5600, 2400), "scale": 0.54, "flip": true},
		{"at": Vector2(6800, 2060), "scale": 0.40, "flip": false},
		{"at": Vector2(7960, 2620), "scale": 0.48, "flip": true},
		{"at": Vector2(9700, 2160), "scale": 0.42, "flip": false},
		{"at": Vector2(11140, 2620), "scale": 0.50, "flip": true},
		{"at": Vector2(1280, 3600), "scale": 0.50, "flip": false},
		{"at": Vector2(3120, 4140), "scale": 0.56, "flip": true},
		{"at": Vector2(5900, 4560), "scale": 0.48, "flip": false},
		{"at": Vector2(8740, 4920), "scale": 0.58, "flip": true},
		{"at": Vector2(10800, 4480), "scale": 0.52, "flip": false},
	]
	for index in placements.size():
		var placement := placements[index]
		_add_jade_pine(placement.at, float(placement.scale), bool(placement.flip), index % 4 == 0)
	for point in [Vector2(3640, 720), Vector2(6120, 2200), Vector2(7420, 3720), Vector2(10040, 3660)]:
		_add_mist_bank(point)


func _add_jade_pine(foot_position: Vector2, scale_amount: float, flipped: bool, foreground: bool) -> void:
	var root := Node2D.new()
	root.name = "DepthJadePine_%02d" % prop_count
	root.position = foot_position
	root.y_sort_enabled = true
	add_child(root)
	var sprite := Sprite2D.new()
	sprite.texture = JADE_PINE
	sprite.centered = false
	sprite.offset = Vector2(-627.0, -1254.0)
	sprite.scale = Vector2.ONE * scale_amount
	sprite.flip_h = flipped
	sprite.modulate = Color(0.82, 0.96, 0.80) if foreground else Color(0.63, 0.82, 0.68)
	root.add_child(sprite)
	_add_foot_shadow(root, 62.0 * scale_amount)
	prop_count += 1
	if foreground:
		foreground_prop_count += 1


func _build_mist_border_depth() -> void:
	# Pines are concentrated along forest, highland and wetland edges. They do
	# not form a uniform carpet across the entire 12 km map or block the roads.
	var placements: Array[Dictionary] = [
		{"at": Vector2(2470, 1240), "scale": 0.42, "flip": false},
		{"at": Vector2(2860, 1660), "scale": 0.54, "flip": true},
		{"at": Vector2(3260, 1110), "scale": 0.38, "flip": false},
		{"at": Vector2(3730, 2450), "scale": 0.47, "flip": true},
		{"at": Vector2(5320, 3120), "scale": 0.56, "flip": false},
		{"at": Vector2(5810, 3760), "scale": 0.43, "flip": true},
		{"at": Vector2(6320, 2920), "scale": 0.42, "flip": false},
		{"at": Vector2(6940, 2080), "scale": 0.36, "flip": true},
		{"at": Vector2(8300, 2740), "scale": 0.46, "flip": false},
		{"at": Vector2(9060, 3250), "scale": 0.52, "flip": true},
		{"at": Vector2(10360, 3520), "scale": 0.48, "flip": false},
		{"at": Vector2(11240, 2960), "scale": 0.40, "flip": true},
		{"at": Vector2(1520, 4180), "scale": 0.50, "flip": true},
		{"at": Vector2(4280, 5260), "scale": 0.56, "flip": false},
		{"at": Vector2(7480, 4640), "scale": 0.52, "flip": false},
		{"at": Vector2(10180, 4920), "scale": 0.58, "flip": true},
	]
	for index in placements.size():
		var placement := placements[index]
		_add_pine(placement.at, float(placement.scale), bool(placement.flip), index % 3 == 0)
	# Sparse mist banks are visual occluders only; they never add hidden collision.
	for point in [Vector2(3140, 1840), Vector2(6630, 2440), Vector2(8850, 3660), Vector2(10680, 4210)]:
		_add_mist_bank(point)


func _build_ancient_ridge_depth() -> void:
	# The ridge uses stone spires and broken standards, never a borrowed forest
	# asset. Clear approaches remain around the fixed cave and main road.
	var spires: Array[Dictionary] = [
		{"at": Vector2(1880, 2640), "size": 0.9, "kind": "ash"},
		{"at": Vector2(2670, 1860), "size": 1.15, "kind": "fire"},
		{"at": Vector2(3900, 2100), "size": 0.85, "kind": "fire"},
		{"at": Vector2(4780, 2740), "size": 1.20, "kind": "ash"},
		{"at": Vector2(5860, 2460), "size": 1.05, "kind": "battle"},
		{"at": Vector2(6650, 2220), "size": 0.98, "kind": "battle"},
		{"at": Vector2(7420, 1820), "size": 1.22, "kind": "battle"},
		{"at": Vector2(8220, 2440), "size": 0.92, "kind": "battle"},
		{"at": Vector2(9160, 2100), "size": 1.12, "kind": "battle"},
		{"at": Vector2(10280, 2800), "size": 1.28, "kind": "stone"},
		{"at": Vector2(11180, 2480), "size": 1.02, "kind": "stone"},
		{"at": Vector2(1160, 4420), "size": 1.18, "kind": "ash"},
		{"at": Vector2(3560, 4960), "size": 1.30, "kind": "ash"},
		{"at": Vector2(6180, 4100), "size": 1.15, "kind": "stone"},
		{"at": Vector2(7860, 5160), "size": 1.34, "kind": "stone"},
		{"at": Vector2(10320, 4700), "size": 1.24, "kind": "stone"},
	]
	for index in spires.size():
		var spire := spires[index]
		_add_stone_spire(spire.at, float(spire.size), str(spire.kind), index % 3 == 1)


func _add_pine(foot_position: Vector2, scale_amount: float, flipped: bool, foreground: bool) -> void:
	var root := Node2D.new()
	root.name = "DepthPine_%02d" % prop_count
	root.position = foot_position
	root.y_sort_enabled = true
	add_child(root)
	var sprite := Sprite2D.new()
	sprite.texture = MIST_PINES
	sprite.centered = false
	sprite.offset = Vector2(-627.0, -1254.0)
	sprite.scale = Vector2.ONE * scale_amount
	sprite.flip_h = flipped
	sprite.modulate = Color(0.76, 0.92, 0.90) if foreground else Color(0.62, 0.79, 0.77)
	root.add_child(sprite)
	_add_foot_shadow(root, 58.0 * scale_amount)
	prop_count += 1
	if foreground:
		foreground_prop_count += 1


func _add_mist_bank(foot_position: Vector2) -> void:
	var root := Node2D.new()
	root.name = "ForegroundMist_%02d" % prop_count
	root.position = foot_position
	root.y_sort_enabled = true
	add_child(root)
	var bank := Polygon2D.new()
	bank.polygon = PackedVector2Array([
		Vector2(-170, -66), Vector2(-86, -132), Vector2(12, -112), Vector2(92, -146),
		Vector2(184, -54), Vector2(124, -16), Vector2(-88, -20),
	])
	bank.color = Color(0.55, 0.84, 0.82, 0.22)
	root.add_child(bank)
	prop_count += 1
	foreground_prop_count += 1


func _add_stone_spire(foot_position: Vector2, size_amount: float, kind: String, foreground: bool) -> void:
	var root := Node2D.new()
	root.name = "DepthSpire_%02d" % prop_count
	root.position = foot_position
	root.y_sort_enabled = true
	add_child(root)
	var colors := _spire_colors(kind)
	var shadow := Polygon2D.new()
	shadow.polygon = _scaled_points([Vector2(-62, -4), Vector2(-14, -22), Vector2(98, -2), Vector2(26, 13)], size_amount)
	shadow.color = Color(0.03, 0.025, 0.025, 0.48)
	root.add_child(shadow)
	var rock := Polygon2D.new()
	rock.polygon = _scaled_points([
		Vector2(-52, -8), Vector2(-42, -118), Vector2(-10, -204), Vector2(24, -136),
		Vector2(54, -82), Vector2(44, -8),
	], size_amount)
	rock.color = colors.base
	root.add_child(rock)
	var edge := Polygon2D.new()
	edge.polygon = _scaled_points([
		Vector2(-42, -118), Vector2(-10, -204), Vector2(3, -128), Vector2(-14, -42),
	], size_amount)
	edge.color = colors.rim
	root.add_child(edge)
	if foreground:
		var banner := Polygon2D.new()
		banner.polygon = _scaled_points([
			Vector2(3, -128), Vector2(58, -110), Vector2(12, -82), Vector2(2, -74),
		], size_amount)
		banner.color = colors.banner
		root.add_child(banner)
	prop_count += 1
	if foreground:
		foreground_prop_count += 1


func _add_foot_shadow(root: Node2D, radius: float) -> void:
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(-radius, -4), Vector2(0, -radius * 0.32), Vector2(radius, -4), Vector2(0, radius * 0.22),
	])
	shadow.color = Color(0.02, 0.05, 0.06, 0.42)
	root.add_child(shadow)


func _scaled_points(points: Array[Vector2], amount: float) -> PackedVector2Array:
	var scaled := PackedVector2Array()
	for point in points:
		scaled.append(point * amount)
	return scaled


func _spire_colors(kind: String) -> Dictionary:
	match kind:
		"fire":
			return {"base": Color(0.32, 0.18, 0.15), "rim": Color(0.76, 0.32, 0.16), "banner": Color(0.91, 0.46, 0.17)}
		"battle":
			return {"base": Color(0.27, 0.23, 0.24), "rim": Color(0.57, 0.48, 0.39), "banner": Color(0.56, 0.23, 0.20)}
		"ash":
			return {"base": Color(0.23, 0.22, 0.22), "rim": Color(0.48, 0.44, 0.41), "banner": Color(0.63, 0.41, 0.22)}
		_:
			return {"base": Color(0.25, 0.28, 0.30), "rim": Color(0.52, 0.58, 0.60), "banner": Color(0.48, 0.57, 0.64)}
