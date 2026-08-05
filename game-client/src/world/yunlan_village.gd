extends Node2D

@onready var merchant: Area2D = $MarketkeeperLuo/Interaction
@onready var alchemy: Area2D = $AlchemyWorkshop/Interaction
@onready var sect_envoy: Area2D = $SectEnvoyNingYuan/Interaction
@onready var mist_border: Area2D = $MistBorderPassage/Interaction
@onready var water_palace: Area2D = $WaterPalaceEntrance/Interaction
@onready var weapon_rack: Area2D = $WeaponTrialRack/Interaction
@onready var prompt: Label = $HUD/Prompt
@onready var touch_controls: Node = $HUD/TouchControls

var active_interaction_id := ""
const STARTER_TRIAL_WEAPONS: Array[String] = ["青篁练气剑", "回云练气伞", "朱砂练气符笔", "流云练气枪", "逐风练气弓", "断雾练气刀", "玄月练气戟", "开山练气斧", "撼岳练气锤", "青竹练气棍", "碎影练气鞭", "机阙练气弩", "流风练气扇", "清商练气琴", "碧篁练气箫", "玄霜摄魂铃", "八方引岚阵盘", "墨枢练气傀儡", "青炉练气鼎", "沧澜引灵珠", "镇岳缚灵印"]

func _ready() -> void:
	GameState.current_region_id = "starter_village"
	merchant.focused.connect(func(_interaction): _set_context("merchant", "与云市掌柜·洛清交易"))
	merchant.unfocused.connect(func(_interaction): _clear_context("merchant"))
	alchemy.focused.connect(func(_interaction): _set_context("alchemy", "进入炼丹工坊"))
	alchemy.unfocused.connect(func(_interaction): _clear_context("alchemy"))
	sect_envoy.focused.connect(func(_interaction): _set_context("sect", "与宗门接引使·宁远交谈"))
	sect_envoy.unfocused.connect(func(_interaction): _clear_context("sect"))
	mist_border.focused.connect(func(_interaction): _set_context("mist_border", "前往雾潮边境" if GameState.is_region_unlocked("mist_border") else "雾潮边境尚待水府试炼开启"))
	mist_border.unfocused.connect(func(_interaction): _clear_context("mist_border"))
	water_palace.focused.connect(func(_interaction): _set_context("water_palace", "进入雾溪水府（炼气副本）"))
	water_palace.unfocused.connect(func(_interaction): _clear_context("water_palace"))
	weapon_rack.focused.connect(func(_interaction): _set_context("weapon_rack", "查看云岚试兵架（领取首发试用灵器）"))
	weapon_rack.unfocused.connect(func(_interaction): _clear_context("weapon_rack"))
	touch_controls.action_requested.connect(_on_touch_action_requested)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_ESCAPE or event.keycode == KEY_H):
		get_tree().change_scene_to_file("res://scenes/yunlan_south_gate.tscn")
	elif event.is_pressed() and not event.is_echo() and event.keycode == KEY_E:
		_activate_contextual()

func _set_context(interaction_id: String, description: String) -> void:
	active_interaction_id = interaction_id
	prompt.text = "[E / 交互] %s" % description
	touch_controls.set_interaction_available(true)

func _clear_context(interaction_id: String) -> void:
	if active_interaction_id != interaction_id:
		return
	active_interaction_id = ""
	prompt.text = ""
	touch_controls.set_interaction_available(false)

func _on_touch_action_requested(action_id: String) -> void:
	if action_id == "interact":
		_activate_contextual()

func _activate_contextual() -> void:
	match active_interaction_id:
		"merchant":
			GameState.enter_screen(GameState.Screen.MARKET)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"alchemy":
			GameState.enter_screen(GameState.Screen.ALCHEMY)
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"sect":
			GameState.complete_world_guidance_step("path_choice")
			GameState.enter_screen(GameState.Screen.SECT)
			GameState.notify("宁远：可自由选择宗门，但门规、贡献与离宗后果也会随选择而来。")
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		"mist_border":
			if GameState.is_region_unlocked("mist_border"):
				get_tree().change_scene_to_file("res://scenes/mist_tide_border.tscn")
			else:
				GameState.notify("雾潮边境被水雾封锁。完成雾溪水府试炼后可沿旧道前往。")
		"water_palace":
			GameState.selected_dungeon_id = "mist_stream_palace"
			get_tree().change_scene_to_file("res://scenes/mist_stream_water_palace.tscn")
		"weapon_rack":
			var granted := GameState.claim_starter_weapon_trials(STARTER_TRIAL_WEAPONS)
			if not granted.is_empty():
				prompt.text = "已领取：%s\n按 Q 切换武器；可前往雾溪水府或山门论剑试用。" % "、".join(granted)
			else:
				prompt.text = "试兵资格已记录。按 Q 可切换已完成的专属武器。"
