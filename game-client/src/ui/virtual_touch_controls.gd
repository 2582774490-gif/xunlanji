class_name VirtualTouchControls
extends Control

## Reusable mobile input overlay.  It stays entirely above the world scene and
## translates touch gestures into the same movement/actions used by keyboard
## development controls, so mobile exports do not need a second combat system.

signal action_requested(action_id: String)

@export var combat_enabled := false
@export var overworld_attack_enabled := false
@export var interaction_enabled := true

const JOYSTICK_RADIUS := 78.0
const JOYSTICK_DEAD_ZONE := 0.18
const BUTTON_RADIUS := 38.0
const MOVEMENT_ACTIONS := ["ui_left", "ui_right", "ui_up", "ui_down"]

var _move_touch_id := -999
var _joystick_knob := Vector2.ZERO
var _mouse_dragging := false
var _interaction_available := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _exit_tree() -> void:
	_release_movement()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event.index, event.position, event.pressed)
	elif event is InputEventScreenDrag:
		if event.index == _move_touch_id:
			_update_joystick(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_dragging = event.pressed
		_handle_touch(-1, event.position, event.pressed)
	elif event is InputEventMouseMotion and _mouse_dragging and _move_touch_id == -1:
		_update_joystick(event.position)


func _handle_touch(touch_id: int, touch_position: Vector2, pressed: bool) -> void:
	if pressed:
		if _move_touch_id == -999 and touch_position.distance_to(_joystick_center()) <= JOYSTICK_RADIUS * 1.45:
			_move_touch_id = touch_id
			_update_joystick(touch_position)
			return
		if combat_enabled or overworld_attack_enabled or _interaction_available:
			var action_id := _action_at(touch_position)
			if not action_id.is_empty():
				action_requested.emit(action_id)
		return
	if touch_id == _move_touch_id:
		_move_touch_id = -999
		_release_movement()
		queue_redraw()


func _update_joystick(touch_position: Vector2) -> void:
	var center := _joystick_center()
	var offset := touch_position - center
	var clamped := offset.limit_length(JOYSTICK_RADIUS)
	_joystick_knob = center + clamped
	var normalized := clamped / JOYSTICK_RADIUS
	_release_movement()
	if normalized.length() >= JOYSTICK_DEAD_ZONE:
		if normalized.x < 0.0:
			Input.action_press("ui_left", absf(normalized.x))
		if normalized.x > 0.0:
			Input.action_press("ui_right", absf(normalized.x))
		if normalized.y < 0.0:
			Input.action_press("ui_up", absf(normalized.y))
		if normalized.y > 0.0:
			Input.action_press("ui_down", absf(normalized.y))
	queue_redraw()


func _release_movement() -> void:
	for action_name in MOVEMENT_ACTIONS:
		Input.action_release(action_name)
	_joystick_knob = _joystick_center()


func _joystick_center() -> Vector2:
	return Vector2(112.0, size.y - 122.0)


func _button_data() -> Array[Dictionary]:
	var x := size.x - 100.0
	var y := size.y - 114.0
	var buttons: Array[Dictionary] = []
	if combat_enabled:
		buttons.append_array([
			{"id": "attack", "label": "攻", "position": Vector2(x, y)},
			{"id": "ningxi", "label": "诀", "position": Vector2(x - 88.0, y + 7.0)},
			{"id": "cloud_step", "label": "步", "position": Vector2(x - 34.0, y - 82.0)},
			{"id": "guard", "label": "护", "position": Vector2(x - 120.0, y - 84.0)},
			{"id": "nourish", "label": "灵", "position": Vector2(x - 192.0, y - 18.0)},
		])
	elif overworld_attack_enabled:
		buttons.append({"id": "attack", "label": "攻", "position": Vector2(x, y)})
	if interaction_enabled and _interaction_available:
		buttons.append({"id": "interact", "label": "交", "position": Vector2(x, y - 4.0)})
	return buttons


func set_interaction_available(available: bool) -> void:
	if _interaction_available == available:
		return
	_interaction_available = available
	queue_redraw()


func _action_at(touch_position: Vector2) -> String:
	for button in _button_data():
		if touch_position.distance_to(button["position"]) <= BUTTON_RADIUS:
			return button["id"]
	return ""


func _draw() -> void:
	var center := _joystick_center()
	if _joystick_knob == Vector2.ZERO:
		_joystick_knob = center
	draw_circle(center, JOYSTICK_RADIUS, Color(0.05, 0.18, 0.22, 0.42))
	draw_arc(center, JOYSTICK_RADIUS, 0.0, TAU, 48, Color(0.45, 0.86, 0.88, 0.75), 2.0)
	draw_circle(_joystick_knob, 30.0, Color(0.26, 0.72, 0.75, 0.72))
	var font := ThemeDB.fallback_font
	for button in _button_data():
		var is_attack: bool = str(button["id"]) == "attack"
		var radius := BUTTON_RADIUS + 8.0 if is_attack else BUTTON_RADIUS
		var color := Color(0.08, 0.38, 0.46, 0.88) if is_attack else Color(0.10, 0.23, 0.33, 0.82)
		draw_circle(button["position"], radius, color)
		draw_arc(button["position"], radius, 0.0, TAU, 32, Color(0.66, 0.94, 0.94, 0.82), 2.0)
		draw_string(font, button["position"] + Vector2(-10.0, 8.0), button["label"], HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color(0.9, 1, 1, 1))
