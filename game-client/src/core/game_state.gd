extends Node

signal screen_changed(next_screen: Screen)
signal character_changed()

enum Screen {
	CHARACTER_SELECT,
	OVERWORLD,
	DUNGEON,
	PVP,
}

var current_screen: Screen = Screen.CHARACTER_SELECT
var current_region_id := "starter_village"
var character := {
	"gender": "男",
	"face": 1,
	"hair": 1,
	"realm": "炼气一层",
}

func enter_screen(next_screen: Screen) -> void:
	current_screen = next_screen
	screen_changed.emit(current_screen)

func update_character(gender: String, face: int, hair: int) -> void:
	character.gender = gender
	character.face = face
	character.hair = hair
	character_changed.emit()

func screen_name() -> String:
	match current_screen:
		Screen.CHARACTER_SELECT:
			return "角色创建"
		Screen.OVERWORLD:
			return "大世界探索"
		Screen.DUNGEON:
			return "横版副本"
		Screen.PVP:
			return "1v1 论剑"
	return "未知界面"
