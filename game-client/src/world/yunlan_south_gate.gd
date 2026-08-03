class_name YunlanSouthGate
extends Node2D

@onready var status: Label = $HUD/StatusPanel/Status

func _ready() -> void:
	status.text = "云岚村南门 · 空间场景重建：角色以脚底参与前后遮挡；门楼两侧有实体碰撞，中间可以通行。"

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
