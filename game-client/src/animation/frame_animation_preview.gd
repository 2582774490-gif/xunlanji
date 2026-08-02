extends Node2D

const DIRECTION_REFERENCE_PATH := "res://assets/art/characters/player_male_template/processed_alpha/player_male_template_idle_8dir_v01.png"
const WALK_SOUTH_PATH := "res://assets/art/characters/player_male_template/processed_alpha/player_male_template_walk_south_6f_v01.png"

@onready var avatar: FrameAnimationController = $Avatar
@onready var status: Label = $CanvasLayer/Status


func _ready() -> void:
	var texture := load(DIRECTION_REFERENCE_PATH) as Texture2D
	if texture == null:
		status.text = "Missing processed direction sheet. Run the alpha processing step first."
		return
	var clips := {
		"idle_south": {"frames": [0], "fps": 1.0, "loop": true},
		"idle_south_west": {"frames": [1], "fps": 1.0, "loop": true},
		"idle_west": {"frames": [2], "fps": 1.0, "loop": true},
		"idle_north_west": {"frames": [3], "fps": 1.0, "loop": true},
		"idle_north": {"frames": [4], "fps": 1.0, "loop": true},
		"idle_north_east": {"frames": [5], "fps": 1.0, "loop": true},
		"idle_east": {"frames": [6], "fps": 1.0, "loop": true},
		"idle_south_east": {"frames": [7], "fps": 1.0, "loop": true},
	}
	avatar.configure_from_grid(texture, 4, 2, clips)
	var walk_texture := load(WALK_SOUTH_PATH) as Texture2D
	if walk_texture != null:
		avatar.append_grid_clips(
			walk_texture,
			3,
			2,
			{"walk_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 9.0, "loop": true}},
		)
	avatar.play_action("idle", "south")
	status.text = "Down arrow: six-frame south walk test. Other arrows: eight-direction idle verification."


func _process(_delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if movement.length_squared() > 0.001:
		var direction := avatar.direction_from_vector(movement)
		if direction == "south":
			avatar.play_action("walk", direction)
		else:
			avatar.play_action("idle", direction)
