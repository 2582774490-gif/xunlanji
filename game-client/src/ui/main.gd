extends Control

const WorldCatalogData = preload("res://src/data/world_catalog.gd")

var mode_label: Label
var region_label: Label
var detail_label: Label

func _ready() -> void:
	GameState.mode_changed.connect(_refresh)
	_build_interface()
	_refresh(GameState.current_mode)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b1620"))
	draw_circle(Vector2(size.x * 0.78, size.y * 0.24), 125.0, Color("385c79"))
	draw_circle(Vector2(size.x * 0.80, size.y * 0.22), 112.0, Color("d9e7df"))
	draw_line(Vector2(0, size.y * 0.72), Vector2(size.x, size.y * 0.58), Color("31565b"), 96.0)

func _build_interface() -> void:
	var title := Label.new()
	title.text = "寻岚记 · 首发玩法原型"
	title.position = Vector2(56, 38)
	title.add_theme_font_size_override("font_size", 38)
	title.modulate = Color("e6dbc4")
	add_child(title)

	mode_label = Label.new()
	mode_label.position = Vector2(60, 110)
	mode_label.add_theme_font_size_override("font_size", 26)
	mode_label.modulate = Color("9ed7d0")
	add_child(mode_label)

	region_label = Label.new()
	region_label.position = Vector2(60, 164)
	region_label.add_theme_font_size_override("font_size", 22)
	region_label.modulate = Color("ffffff")
	add_child(region_label)

	detail_label = Label.new()
	detail_label.position = Vector2(60, 210)
	detail_label.size = Vector2(670, 180)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 18)
	detail_label.modulate = Color("c6d2cf")
	add_child(detail_label)

	_add_button("大世界探索", Vector2(60, 430), _enter_overworld)
	_add_button("进入固定副本", Vector2(285, 430), _enter_dungeon)
	_add_button("进入 1v1 论剑", Vector2(510, 430), _enter_pvp)

	var control_hint := Label.new()
	control_hint.text = "目标操作：左侧虚拟摇杆｜右侧普攻｜五技能槽（当前为系统骨架）"
	control_hint.position = Vector2(60, 640)
	control_hint.add_theme_font_size_override("font_size", 17)
	control_hint.modulate = Color("91a5a2")
	add_child(control_hint)

func _add_button(text: String, position_value: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = position_value
	button.size = Vector2(190, 56)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	add_child(button)

func _refresh(_next_mode: GameState.Mode) -> void:
	queue_redraw()
	var region: Dictionary = WorldCatalogData.REGIONS[0]
	mode_label.text = "当前模式：%s" % GameState.mode_name()
	region_label.text = "首发区域：%s（%s）" % [region.name, region.realm]
	detail_label.text = "%s\n固定副本：%s\n\n三大区数据、境界路线、区域短加载与 10 人同区限制已进入项目数据骨架。" % [region.purpose, "、".join(region.fixed_dungeons)]

func _enter_overworld() -> void:
	GameState.transition_to(GameState.Mode.OVERWORLD)

func _enter_dungeon() -> void:
	GameState.transition_to(GameState.Mode.DUNGEON)

func _enter_pvp() -> void:
	GameState.transition_to(GameState.Mode.PVP)
