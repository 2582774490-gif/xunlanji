extends Control

const WorldCatalogData = preload("res://src/data/world_catalog.gd")
const CombatStateData = preload("res://src/combat/combat_state.gd")

var selected_gender := "男"
var selected_face := 1
var selected_hair := 1
var player_position := Vector2(420, 420)
var combat := CombatStateData.new()
var status_label: Label
var detail_label: Label

func _ready() -> void:
	GameState.screen_changed.connect(_render_screen)
	set_process(true)
	_render_screen(GameState.current_screen)

func _process(delta: float) -> void:
	if GameState.current_screen == GameState.Screen.OVERWORLD:
		var move_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if move_direction.length() > 0.0:
			player_position += move_direction * 260.0 * delta
			player_position.x = clampf(player_position.x, 80.0, 1160.0)
			player_position.y = clampf(player_position.y, 210.0, 610.0)
			queue_redraw()
	elif GameState.current_screen == GameState.Screen.DUNGEON:
		combat.tick(delta)
		queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if GameState.current_screen == GameState.Screen.DUNGEON:
		if event.keycode == KEY_J:
			combat.normal_attack()
			_refresh_combat_text()
			return
		if event.keycode >= KEY_1 and event.keycode <= KEY_5:
			combat.use_skill(event.keycode - KEY_1)
			_refresh_combat_text()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("09151d"))
	match GameState.current_screen:
		GameState.Screen.CHARACTER_SELECT:
			_draw_character_select_background()
		GameState.Screen.OVERWORLD:
			_draw_overworld()
		GameState.Screen.DUNGEON:
			_draw_dungeon()
		GameState.Screen.PVP:
			_draw_pvp()

func _clear_ui() -> void:
	for child in get_children():
		child.queue_free()
	status_label = null
	detail_label = null

func _render_screen(_next_screen: GameState.Screen) -> void:
	_clear_ui()
	queue_redraw()
	match GameState.current_screen:
		GameState.Screen.CHARACTER_SELECT:
			_show_character_select()
		GameState.Screen.OVERWORLD:
			_show_overworld()
		GameState.Screen.DUNGEON:
			_show_dungeon()
		GameState.Screen.PVP:
			_show_pvp()

func _add_label(text_value: String, position_value: Vector2, font_size: int = 20, color: Color = Color.WHITE, width: float = 0.0) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	if width > 0.0:
		label.size = Vector2(width, 0.0)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	return label

func _add_button(text_value: String, position_value: Vector2, callback: Callable, button_size := Vector2(190, 54)) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = button_size
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	add_child(button)
	return button

func _add_header(subtitle: String) -> void:
	_add_label("寻岚记", Vector2(54, 34), 40, Color("efe1bf"))
	_add_label(subtitle, Vector2(57, 90), 20, Color("8ec8bd"))

func _show_character_select() -> void:
	_add_header("首发角色模板 · 先选择性别、脸型与发型")
	_add_label("角色创建", Vector2(720, 188), 30, Color("ffffff"))
	_add_label("性别", Vector2(720, 250), 18, Color("bdc9c6"))
	_add_button("男", Vector2(720, 282), func(): _set_gender("男"), Vector2(120, 48))
	_add_button("女", Vector2(850, 282), func(): _set_gender("女"), Vector2(120, 48))
	_add_label("脸型模板：%d" % selected_face, Vector2(720, 350), 18, Color("bdc9c6"))
	_add_button("切换脸型", Vector2(720, 382), _cycle_face, Vector2(250, 48))
	_add_label("发型模板：%d" % selected_hair, Vector2(720, 448), 18, Color("bdc9c6"))
	_add_button("切换发型", Vector2(720, 480), _cycle_hair, Vector2(250, 48))
	_add_button("踏入云岚村", Vector2(720, 568), _confirm_character, Vector2(250, 60))
	status_label = _add_label("当前选择：%s · 脸型 %d · 发型 %d" % [selected_gender, selected_face, selected_hair], Vector2(720, 650), 17, Color("a2bab4"))

func _show_overworld() -> void:
	var region: Dictionary = WorldCatalogData.REGIONS[0]
	_add_header("云岚村与近郊 · 方向键模拟左侧虚拟摇杆")
	_add_label("%s｜%s" % [GameState.character.gender, GameState.character.realm], Vector2(54, 134), 19, Color("d8e5df"))
	_add_label("当前区域：%s" % region.name, Vector2(54, 170), 22, Color("ffffff"))
	detail_label = _add_label("固定副本：%s\n随机机缘：在野外移动时将触发（下一轮接入）。" % "、".join(region.fixed_dungeons), Vector2(54, 210), 18, Color("bdcfca"), 430)
	_add_button("进入雾溪水府", Vector2(54, 530), _enter_dungeon, Vector2(210, 56))
	_add_button("前往 1v1 论剑台", Vector2(280, 530), _enter_pvp, Vector2(220, 56))
	_add_button("返回角色选择", Vector2(54, 600), _back_to_create, Vector2(210, 48))
	_add_label("宗门边境与雾原、险地山脉与古遗址将在境界达到后解锁。", Vector2(54, 670), 16, Color("92a9a3"))

func _show_dungeon() -> void:
	combat.reset()
	_add_header("雾溪水府 · 横版即时战斗原型")
	status_label = _add_label("玩家 HP：100    守卫 HP：100", Vector2(54, 145), 22, Color("ffffff"))
	detail_label = _add_label(combat.battle_log, Vector2(54, 190), 18, Color("b8c9c4"), 650)
	_add_button("J 普攻", Vector2(46, 584), _normal_attack, Vector2(130, 52))
	for index in 5:
		var skill_button := _add_button("%d·%s" % [index + 1, combat.skill_names[index]], Vector2(190 + index * 170, 584), func(): _use_skill(index), Vector2(155, 52))
		skill_button.tooltip_text = "数字 %d 也可施放" % (index + 1)
	_add_button("退出副本", Vector2(1000, 62), _leave_dungeon, Vector2(180, 48))

func _show_pvp() -> void:
	_add_header("1v1 论剑台 · 联机接口占位")
	_add_label("首发目标：同区最多 10 人；PVP 当前仅开放两人对战。", Vector2(80, 200), 26, Color("ffffff"))
	_add_label("下一轮：接入房间匹配、服务器权威结算与双方战斗同步。", Vector2(80, 250), 19, Color("bdcfca"))
	_add_button("返回云岚村", Vector2(80, 520), _leave_pvp, Vector2(220, 56))

func _set_gender(value: String) -> void:
	selected_gender = value
	status_label.text = "当前选择：%s · 脸型 %d · 发型 %d" % [selected_gender, selected_face, selected_hair]

func _cycle_face() -> void:
	selected_face = selected_face % 3 + 1
	_render_screen(GameState.current_screen)

func _cycle_hair() -> void:
	selected_hair = selected_hair % 3 + 1
	_render_screen(GameState.current_screen)

func _confirm_character() -> void:
	GameState.update_character(selected_gender, selected_face, selected_hair)
	GameState.enter_screen(GameState.Screen.OVERWORLD)

func _back_to_create() -> void:
	GameState.enter_screen(GameState.Screen.CHARACTER_SELECT)

func _enter_dungeon() -> void:
	GameState.enter_screen(GameState.Screen.DUNGEON)

func _leave_dungeon() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)

func _enter_pvp() -> void:
	GameState.enter_screen(GameState.Screen.PVP)

func _leave_pvp() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)

func _normal_attack() -> void:
	combat.normal_attack()
	_refresh_combat_text()

func _use_skill(index: int) -> void:
	combat.use_skill(index)
	_refresh_combat_text()

func _refresh_combat_text() -> void:
	if status_label:
		status_label.text = "玩家 HP：%d    守卫 HP：%d" % [combat.player_hp, combat.enemy_hp]
	if detail_label:
		detail_label.text = combat.battle_log

func _draw_character_select_background() -> void:
	draw_circle(Vector2(340, 330), 170.0, Color("29485a"))
	draw_circle(Vector2(340, 300), 108.0, Color("d9d4c4"))
	draw_rect(Rect2(250, 410, 180, 190), Color("2b6672"))
	draw_line(Vector2(120, 630), Vector2(590, 630), Color("6e9f98"), 4.0)

func _draw_overworld() -> void:
	draw_rect(Rect2(0, 150, size.x, size.y - 150), Color("1f4d4a"))
	draw_circle(Vector2(190, 300), 125.0, Color("356953"))
	draw_circle(Vector2(980, 360), 175.0, Color("315f4f"))
	draw_rect(Rect2(560, 360, 220, 150), Color("8a694a"))
	draw_rect(Rect2(580, 325, 180, 55), Color("c2b180"))
	draw_circle(player_position, 26.0, Color("ecdfbd"))
	draw_circle(player_position + Vector2(0, -34), 18.0, Color("161f29"))
	draw_string(ThemeDB.fallback_font, player_position + Vector2(-32, 62), "道友", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _draw_dungeon() -> void:
	draw_rect(Rect2(0, 150, size.x, size.y - 150), Color("152938"))
	draw_rect(Rect2(0, 510, size.x, 210), Color("294451"))
	draw_rect(Rect2(340, 405, 250, 30), Color("476a70"))
	draw_circle(Vector2(300, 460), 42.0, Color("dce6dd"))
	draw_circle(Vector2(890, 458), 50.0, Color("a04e53"))
	draw_rect(Rect2(770, 355, 250, 16), Color("43252a"))
	draw_rect(Rect2(770, 355, 2.5 * combat.enemy_hp, 16), Color("d76566"))
	draw_string(ThemeDB.fallback_font, Vector2(770, 335), "水府守卫", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

func _draw_pvp() -> void:
	draw_rect(Rect2(0, 150, size.x, size.y - 150), Color("30233c"))
	draw_circle(Vector2(310, 430), 68.0, Color("b7d8d4"))
	draw_circle(Vector2(970, 430), 68.0, Color("d58e91"))
	draw_line(Vector2(120, 560), Vector2(1160, 560), Color("d9c28f"), 8.0)
