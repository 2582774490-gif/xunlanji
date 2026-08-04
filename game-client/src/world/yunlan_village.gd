extends Node2D

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_ESCAPE or event.keycode == KEY_H):
		get_tree().change_scene_to_file("res://scenes/yunlan_south_gate.tscn")
