extends Node2D

const DUNGEON_ID := "mist_stream_palace"

@onready var player: CharacterBody2D = $Player
@onready var herb: Area2D = $Interactables/SpiritHerb
@onready var portal: Area2D = $Interactables/MistStreamPalaceEntrance
@onready var status: Label = $HUD/Panel/Status
@onready var prompt: Label = $HUD/Prompt

var active_interaction := ""
var herb_collected := false

func _ready() -> void:
	herb.body_entered.connect(_on_herb_entered)
	herb.body_exited.connect(_on_herb_exited)
	portal.body_entered.connect(_on_portal_entered)
	portal.body_exited.connect(_on_portal_exited)
	status.text = "Test asset loaded: player template, idle directions, and a six-frame south walk loop."
	prompt.text = ""

func _on_herb_entered(body: Node2D) -> void:
	if body == player:
		_set_interaction("herb")

func _on_herb_exited(body: Node2D) -> void:
	if body == player:
		_clear_interaction("herb")

func _on_portal_entered(body: Node2D) -> void:
	if body == player:
		_set_interaction("portal")

func _on_portal_exited(body: Node2D) -> void:
	if body == player:
		_clear_interaction("portal")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_interaction()
	elif event.keycode == KEY_J:
		status.text = "Combat input received. Weapon attack art is not assigned until its weapon card is approved."
	elif event.keycode == KEY_H or event.keycode == KEY_ESCAPE:
		_return_to_framework()

func _set_interaction(interaction_id: String) -> void:
	if interaction_id == "herb" and herb_collected:
		return
	active_interaction = interaction_id
	prompt.text = "[E] Gather Mist-Stream Herb" if interaction_id == "herb" else "[E] Enter Mist-Stream Water Palace"

func _clear_interaction(interaction_id: String) -> void:
	if active_interaction != interaction_id:
		return
	active_interaction = ""
	prompt.text = ""

func _activate_interaction() -> void:
	if active_interaction == "herb" and not herb_collected:
		herb_collected = true
		herb.visible = false
		GameState.add_item("Mist-Stream Herb")
		GameState.gain_cultivation(5)
		status.text = "Gathered Mist-Stream Herb. Item and cultivation test succeeded."
		prompt.text = ""
		return
	if active_interaction == "portal":
		GameState.selected_dungeon_id = DUNGEON_ID
		GameState.enter_screen(GameState.Screen.DUNGEON)
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _return_to_framework() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
