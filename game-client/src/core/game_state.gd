extends Node

signal mode_changed(next_mode: Mode)

enum Mode {
	OVERWORLD,
	DUNGEON,
	PVP,
}

var current_mode: Mode = Mode.OVERWORLD
var current_region_id := "starter_village"

func transition_to(next_mode: Mode) -> void:
	if current_mode == next_mode:
		return
	current_mode = next_mode
	mode_changed.emit(current_mode)

func mode_name() -> String:
	match current_mode:
		Mode.OVERWORLD:
			return "大世界探索"
		Mode.DUNGEON:
			return "横版副本"
		Mode.PVP:
			return "1v1 论剑"
	return "未知模式"
