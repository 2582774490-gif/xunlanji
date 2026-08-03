extends Area2D

## Scene-local interaction trigger.  Visuals stay on their owning prop/NPC
## node; this node only owns the reachable area and interaction metadata.
@export var interaction_id := ""
@export var prompt_text := ""

signal focused(interaction: Area2D)
signal unfocused(interaction: Area2D)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_actor"):
		focused.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player_actor"):
		unfocused.emit(self)
