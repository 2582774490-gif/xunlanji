class_name MistTideStoneGrotto
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var return_interaction: Area2D = $GrottoExit/Interaction
@onready var mineral_interaction: Area2D = $MineralShelf/Interaction
@onready var tide_interaction: Area2D = $TidePool/Interaction
@onready var tunnel_interaction: Area2D = $CollapsedTunnel/Interaction
@onready var mirror_echo: Node2D = $MirrorEcho
@onready var mirror_interaction: Area2D = $MirrorEcho/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction: Area2D
var mineral_collected := false
var tide_resolved := false
var tunnel_searched := false
var mirror_echo_revealed := false
var mirror_echo_resolved := false
var chosen_tide_event: Dictionary = {}

const TIDE_EVENTS := [
	{"name": "灵潮回涌", "item": "潮息感悟", "cultivation": 16, "stones": 0, "description": "灵潮短暂回涌，适合不同功法自行体悟。"},
	{"name": "幽鳞药泉", "item": "幽鳞药", "cultivation": 8, "stones": 4, "description": "药泉在石缝中出现，丹修可自行研究它的药性。"},
	{"name": "回声石室", "item": "回声阵片", "cultivation": 10, "stones": 8, "description": "石室回声带来阵法残响，阵修、符修和散修都可利用。"},
]

func _ready() -> void:
	GameState.current_region_id = "mist_tide_stone_grotto"
	player.map_bounds = Rect2(70, 70, 2930, 1905)
	player.position = Vector2(1510, 1700)
	chosen_tide_event = TIDE_EVENTS.pick_random().duplicate()
	$TidePool/Name.text = str(chosen_tide_event.name)
	status.text = "雾潮石窟（炼气五层）：左侧矿台、中部灵潮与右侧塌方洞各自独立。没有任务顺序，你可只取一处资源，也可全部探索。"
	return_interaction.focused.connect(_focus_interaction)
	return_interaction.unfocused.connect(_unfocus_interaction)
	mineral_interaction.focused.connect(_focus_interaction)
	mineral_interaction.unfocused.connect(_unfocus_interaction)
	tide_interaction.focused.connect(_focus_interaction)
	tide_interaction.unfocused.connect(_unfocus_interaction)
	tunnel_interaction.focused.connect(_focus_interaction)
	tunnel_interaction.unfocused.connect(_unfocus_interaction)
	mirror_interaction.focused.connect(_focus_interaction)
	mirror_interaction.unfocused.connect(_unfocus_interaction)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	if str(GameState.player.get("equipped_artifact", "")) == "照影练气镜":
		_reveal_mirror_echo()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_E:
		_activate_contextual()
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_border()

func _focus_interaction(interaction: Area2D) -> void:
	active_interaction = interaction
	prompt.text = "[E / 交互] " + str(interaction.prompt_text)
	touch_controls.set_interaction_available(true)

func _unfocus_interaction(interaction: Area2D) -> void:
	if active_interaction != interaction:
		return
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()

func _activate_contextual() -> void:
	if active_interaction == return_interaction:
		_return_to_border()
	elif active_interaction == mineral_interaction and not mineral_collected:
		_collect_mineral_shelf()
	elif active_interaction == tide_interaction and not tide_resolved:
		_resolve_tide_event()
	elif active_interaction == tunnel_interaction and not tunnel_searched:
		_search_collapsed_tunnel()
	elif active_interaction == mirror_interaction and mirror_echo_revealed and not mirror_echo_resolved:
		_resolve_mirror_echo()

func _collect_mineral_shelf() -> void:
	mineral_collected = true
	$MineralShelf.visible = false
	mineral_interaction.set_deferred("monitoring", false)
	GameState.add_item("雾潮矿芯")
	GameState.gain_cultivation(7)
	GameState.record_opportunity({"region": "mist_tide_stone_grotto", "name": "矿台采集", "item": "雾潮矿芯", "cultivation": 7})
	status.text = "获得雾潮矿芯。它可服务于炼器、法宝胚子或自由交易；修为 +7。"
	_close_interaction()

func _resolve_tide_event() -> void:
	tide_resolved = true
	$TidePool.visible = false
	tide_interaction.set_deferred("monitoring", false)
	GameState.add_item(str(chosen_tide_event.item))
	GameState.add_spirit_stones(int(chosen_tide_event.stones))
	GameState.gain_cultivation(int(chosen_tide_event.cultivation))
	GameState.record_opportunity({
		"region": "mist_tide_stone_grotto",
		"name": chosen_tide_event.name,
		"item": chosen_tide_event.item,
		"cultivation": chosen_tide_event.cultivation,
	})
	status.text = "遭遇%s：%s 获得 %s，修为 +%d。" % [chosen_tide_event.name, chosen_tide_event.description, chosen_tide_event.item, chosen_tide_event.cultivation]
	_close_interaction()

func _search_collapsed_tunnel() -> void:
	tunnel_searched = true
	$CollapsedTunnel.visible = false
	tunnel_interaction.set_deferred("monitoring", false)
	GameState.add_item("塌方残匣")
	var first_array: bool = not GameState.player.inventory.has("八角练气阵盘")
	if first_array:
		GameState.add_item("八角练气阵盘")
	GameState.add_spirit_stones(12)
	GameState.gain_cultivation(9)
	GameState.record_opportunity({"region": "mist_tide_stone_grotto", "name": "塌方洞探查", "item": "八角练气阵盘" if first_array else "塌方残匣", "cultivation": 9})
	var artifact_note := "另获八角练气阵盘（首个石窟阵修法宝）。" if first_array else "阵盘已被你收录，此次只保留残匣线索。"
	status.text = "塌方洞中找到残匣：%s 修为 +9。" % artifact_note
	_close_interaction()

func _reveal_mirror_echo() -> void:
	if mirror_echo_revealed:
		return
	mirror_echo_revealed = true
	mirror_echo.visible = true
	mirror_interaction.monitoring = true
	status.text = "照影练气镜映出石窟深处的一道镜影裂隙。它只是可选机缘，不妨碍其余三处探索。"


func _resolve_mirror_echo() -> void:
	mirror_echo_resolved = true
	mirror_echo.visible = false
	mirror_interaction.set_deferred("monitoring", false)
	GameState.add_item("镜影碎晶")
	GameState.add_spirit_stones(16)
	GameState.gain_cultivation(12)
	GameState.record_opportunity({
		"region": "mist_tide_stone_grotto",
		"name": "镜影裂隙",
		"item": "镜影碎晶",
		"cultivation": 12,
	})
	status.text = "照影镜破开了薄雾：获得镜影碎晶、灵石 +16，修为 +12。"
	_close_interaction()


func _close_interaction() -> void:
	active_interaction = null
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _return_to_border() -> void:
	GameState.current_region_id = "mist_border"
	get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
