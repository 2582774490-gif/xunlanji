extends Node2D

const SKILL_CATALOG = preload("res://src/data/skill_catalog.gd")

@onready var player: CharacterBody2D = $Player
@onready var boss: Area2D = $Boss
@onready var boss_hp: Label = $HUD/BossPanel/BossHP
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var player_mana_label: Label = $HUD/PlayerMana
@onready var status: Label = $HUD/StatusPanel/Status
@onready var prompt: Label = $HUD/Prompt
@onready var slash_trail: Node = $CombatEffects/SlashTrail
@onready var hit_spark: Node = $CombatEffects/HitSpark
@onready var ningxi_cast: Node = $CombatEffects/NingxiCast
@onready var demon_water_blade: Node = $CombatEffects/DemonWaterBlade
@onready var touch_controls: Node = $HUD/TouchControls
@onready var skill_labels: Array[Label] = [
	$HUD/SkillBar/Basic/Label,
	$HUD/SkillBar/Ningxi/Label,
	$HUD/SkillBar/CloudStep/Label,
	$HUD/SkillBar/Guard/Label,
	$HUD/SkillBar/Nourish/Label,
]

var boss_health := 100
var near_boss := false
var player_health := 100
var player_mana := 0.0
var player_max_mana := 0.0
var ningxi_cooldown := 0.0
var cloud_step_cooldown := 0.0
var guard_cooldown := 0.0
var nourish_cooldown := 0.0
var guard_time_left := 0.0
var boss_attack_cooldown := 2.4
var defeated := false

func _ready() -> void:
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(240, 1250)
	player_health = int(GameState.derived_stats()["气血"])
	player_max_mana = float(GameState.derived_stats()["灵力"])
	player_mana = player_max_mana
	player.attack_started.connect(_on_player_attack_started)
	player.attack_impact.connect(_on_player_attack)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	boss.body_entered.connect(func(body: Node2D): near_boss = body == player; _refresh_prompt())
	boss.body_exited.connect(func(body: Node2D): if body == player: near_boss = false; _refresh_prompt())
	status.text = "雾溪水府：深入内池，击败水妖首领潮妃·兰纱。"
	_refresh_boss_hp()
	_refresh_player_hp()
	_refresh_player_mana()
	_refresh_skill_bar()

func _process(delta: float) -> void:
	ningxi_cooldown = maxf(0.0, ningxi_cooldown - delta)
	cloud_step_cooldown = maxf(0.0, cloud_step_cooldown - delta)
	guard_cooldown = maxf(0.0, guard_cooldown - delta)
	nourish_cooldown = maxf(0.0, nourish_cooldown - delta)
	guard_time_left = maxf(0.0, guard_time_left - delta)
	player_mana = minf(player_max_mana, player_mana + delta * 2.0)
	_refresh_player_mana()
	_refresh_skill_bar()
	if defeated or not near_boss or boss_health <= 0:
		return
	boss_attack_cooldown -= delta
	if boss_attack_cooldown > 0.0:
		return
	boss_attack_cooldown = 2.4
	_perform_boss_water_blade()


func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -86) + facing * 44.0, facing)
	await get_tree().create_timer(0.22).timeout
	if defeated or not near_boss or boss_health <= 0:
		return
	var damage := 9
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		status.text = "岚息护体抵去了大半水刃。"
	player_health = max(0, player_health - damage)
	status.text = "潮妃·兰纱掀起水刃，造成 %d 点伤害。" % damage
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在水府中力竭而退：死亡不掉落，正在返回云岚村。"
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")

func _on_player_attack(_direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	hit_spark.play_burst(boss.position + Vector2(0, -90), Vector2.UP)
	var damage := 8 + int(int(GameState.derived_stats()["攻击"]) / 3.0)
	boss_health = max(0, boss_health - damage)
	status.text = "潮妃·兰纱受击，造成 %d 点伤害。属性分配已影响本次攻击。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()


func _on_player_attack_started(direction: String) -> void:
	if not near_boss or boss_health <= 0:
		return
	var facing := _direction_vector(direction)
	slash_trail.play_burst(player.position + facing * 46.0 + Vector2(0, -34), facing)


func _cast_ningxi_sword_art() -> void:
	if not near_boss or boss_health <= 0:
		status.text = "凝息剑诀需要锁定近处目标。"
		return
	if ningxi_cooldown > 0.0:
		status.text = "凝息剑诀还需冷却 %.1f 秒。" % ningxi_cooldown
		return
	if player_mana < 18.0:
		status.text = "灵力不足，无法施放凝息剑诀。"
		return
	var facing := (boss.position - player.position).normalized()
	player_mana -= 18.0
	ningxi_cooldown = 4.0
	_refresh_player_mana()
	ningxi_cast.play_burst(player.position + Vector2(0, -62), facing)
	status.text = "凝息剑诀结印中……灵力 -18。"
	await get_tree().create_timer(0.24).timeout
	if defeated or not near_boss or boss_health <= 0:
		return
	var stats: Dictionary = GameState.derived_stats()
	var damage := 20 + int(int(stats["攻击"]) / 2.0) + int(int(stats["灵力"]) / 30.0)
	boss_health = max(0, boss_health - damage)
	hit_spark.play_burst(boss.position + Vector2(0, -90), Vector2.UP)
	status.text = "凝息剑诀命中潮妃·兰纱，造成 %d 点伤害。" % damage
	_refresh_boss_hp()
	if boss_health == 0:
		_defeat_boss()


func _cast_cloud_step() -> void:
	if not _try_use_skill(2, cloud_step_cooldown):
		return
	cloud_step_cooldown = float(_skill(2)["cooldown"])
	var escape := (player.position - boss.position).normalized() if near_boss else Vector2.DOWN
	player.call("perform_dash", escape)
	ningxi_cast.play_burst(player.position + Vector2(0, -62), escape)
	status.text = "云步踏岚而行，迅速拉开了距离。"


func _cast_lan_breath_guard() -> void:
	if not _try_use_skill(3, guard_cooldown):
		return
	guard_cooldown = float(_skill(3)["cooldown"])
	guard_time_left = 4.0
	ningxi_cast.play_burst(player.position + Vector2(0, -62), Vector2.UP)
	status.text = "岚息护体已展开：下一次受击将大幅减伤。"


func _cast_spirit_nourish() -> void:
	if not _try_use_skill(4, nourish_cooldown):
		return
	nourish_cooldown = float(_skill(4)["cooldown"])
	player_mana = minf(player_max_mana, player_mana + 46.0)
	ningxi_cast.play_burst(player.position + Vector2(0, -62), Vector2.UP)
	_refresh_player_mana()
	status.text = "润灵诀回转经脉，恢复了灵力。"


func _on_touch_action_requested(action_id: String) -> void:
	match action_id:
		"attack": player.call("trigger_basic_attack")
		"ningxi": _cast_ningxi_sword_art()
		"cloud_step": _cast_cloud_step()
		"guard": _cast_lan_breath_guard()
		"nourish": _cast_spirit_nourish()


func _try_use_skill(index: int, cooldown: float) -> bool:
	var skill := _skill(index)
	if cooldown > 0.0:
		status.text = "%s还需冷却 %.1f 秒。" % [skill["name"], cooldown]
		return false
	var cost := float(skill["spirit_cost"])
	if player_mana < cost:
		status.text = "灵力不足，无法施放%s。" % skill["name"]
		return false
	player_mana -= cost
	_refresh_player_mana()
	return true


func _skill(index: int) -> Dictionary:
	return SKILL_CATALOG.STARTER_TEST_SKILLS[index]


func _defeat_boss() -> void:
	boss.visible = false
	GameState.add_item("水府初阶法器匣")
	GameState.gain_cultivation(20)
	status.text = "水府试炼完成：获得水府初阶法器匣与 20 修为。"
	prompt.text = ""


func _direction_vector(direction: String) -> Vector2:
	match direction:
		"south": return Vector2.DOWN
		"south_west": return Vector2(-1, 1).normalized()
		"west": return Vector2.LEFT
		"north_west": return Vector2(-1, -1).normalized()
		"north": return Vector2.UP
		"north_east": return Vector2(1, -1).normalized()
		"east": return Vector2.RIGHT
		"south_east": return Vector2(1, 1).normalized()
	return Vector2.DOWN

func _refresh_boss_hp() -> void:
	boss_hp.text = "潮妃 · 兰纱  |  气血 %d / 100" % boss_health

func _refresh_player_hp() -> void:
	player_hp_label.text = "气血 %d / %d" % [player_health, int(GameState.derived_stats()["气血"])]


func _refresh_player_mana() -> void:
	player_mana_label.text = "灵力 %d / %d" % [int(player_mana), int(player_max_mana)]


func _refresh_skill_bar() -> void:
	var cooldowns := [0.0, ningxi_cooldown, cloud_step_cooldown, guard_cooldown, nourish_cooldown]
	for index in skill_labels.size():
		var skill := _skill(index)
		var state := "可用" if cooldowns[index] <= 0.0 else "%.1fs" % cooldowns[index]
		if index == 0:
			state = "普攻"
		skill_labels[index].text = "[%s] %s\n%s" % [skill["key"], skill["name"], state]
		skill_labels[index].modulate = Color(0.52, 0.63, 0.67, 1) if cooldowns[index] > 0.0 else Color.WHITE

func _refresh_prompt() -> void:
	prompt.text = "[J] 普攻  [K] 凝息剑诀" if near_boss and boss_health > 0 else ""

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_K:
		_cast_ningxi_sword_art()
		get_viewport().set_input_as_handled()
		return
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_L:
		_cast_cloud_step()
		get_viewport().set_input_as_handled()
		return
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_I:
		_cast_lan_breath_guard()
		get_viewport().set_input_as_handled()
		return
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_O:
		_cast_spirit_nourish()
		get_viewport().set_input_as_handled()
		return
	if event.is_pressed() and not event.is_echo() and (event.keycode == KEY_H or event.keycode == KEY_ESCAPE):
		GameState.enter_screen(GameState.Screen.OVERWORLD)
		get_tree().change_scene_to_file("res://scenes/yunlan_village.tscn")
