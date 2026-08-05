class_name WorldEncounterController
extends Node

## Lightweight overworld encounter loop.  It uses the same player attack
## signal as dungeons, but keeps enemies tied to regional population sites.
const MELEE_RANGE := 205.0
const ENEMY_ATTACK_RANGE := 225.0
const SKILL_CATALOG = preload("res://src/data/skill_catalog.gd")
const TalismanProjectileScript = preload("res://src/combat/talisman_projectile.gd")
const SpearThrustEffectScript = preload("res://src/combat/spear_thrust_effect.gd")

var _player: CharacterBody2D
var _population: Node
var _status: Label
var _target_label: Label
var _player_label: Label
var _active_interaction: Area2D
var _target_name := ""
var _target_health := 0
var _target_max_health := 0
var _target_damage := 0
var _player_health := 0
var _player_max_health := 0
var _attack_cooldown := 0.0

func configure(player: CharacterBody2D, population: Node, status: Label, target_label: Label, player_label: Label) -> void:
	_player = player
	_population = population
	_status = status
	_target_label = target_label
	_player_label = player_label
	_player_max_health = int(GameState.derived_stats()["气血"])
	_player_health = _player_max_health
	_player.attack_impact.connect(_on_player_attack_impact)
	_population.hostile_encounter_requested.connect(_begin_encounter)
	_target_label.visible = false
	_refresh_player_label()

func is_in_encounter() -> bool:
	return _active_interaction != null

func _process(delta: float) -> void:
	if _active_interaction == null or not is_instance_valid(_active_interaction):
		return
	var enemy_position: Vector2 = (_active_interaction.get_parent() as Node2D).global_position
	if _player.global_position.distance_to(enemy_position) > ENEMY_ATTACK_RANGE:
		_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
		return
	_attack_cooldown -= delta
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 2.2
	var damage := GameState.pve_damage_after_equipment(_target_damage, "neutral")
	_player_health = max(0, _player_health - damage)
	_refresh_player_label()
	_status.text = "%s 逼近发动袭击，造成 %d 点伤害。可继续手操反击或先拉开距离。" % [_target_name, damage]
	if _player_health == 0:
		_player_health = _player_max_health
		_player.position -= (enemy_position - _player.position).normalized() * 190.0
		_end_encounter("你在野外力竭而退：死亡不掉落，已撤出 %s 的领地。" % _target_name)

func _begin_encounter(interaction: Area2D) -> void:
	if _active_interaction != null:
		return
	var profile: Dictionary = _population.profile_for(interaction)
	_active_interaction = interaction
	_target_name = str(profile.get("name", "野外敌对者"))
	_target_max_health = int(profile.get("health", 58))
	_target_health = _target_max_health
	_target_damage = int(profile.get("damage", 8))
	_attack_cooldown = 0.8
	_target_label.visible = true
	_refresh_target_label()
	_status.text = "遭遇 %s。靠近后按 J 或右侧“攻”进行手操普攻；也可直接离开领地。" % _target_name

func _on_player_attack_impact(_direction: String) -> void:
	if _active_interaction == null or not is_instance_valid(_active_interaction):
		return
	var enemy_position: Vector2 = (_active_interaction.get_parent() as Node2D).global_position
	var attack_range := MELEE_RANGE
	if SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon):
		attack_range = float(SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)[0].get("range", MELEE_RANGE))
	elif SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon):
		attack_range = float(SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)[0].get("range", MELEE_RANGE))
	if _player.global_position.distance_to(enemy_position) > attack_range:
		_status.text = "攻击落空：%s 不在近战范围内。" % _target_name
		return
	var damage := GameState.weapon_basic_damage(9)
	if SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon):
		_spawn_brush_talisman(_player.global_position + Vector2(0, -46), enemy_position + Vector2(0, -52))
	elif SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon):
		_spawn_spear_thrust(_player.global_position + Vector2(0, -42), enemy_position + Vector2(0, -52), 5.0)
	_target_health = max(0, _target_health - damage)
	_refresh_target_label()
	_status.text = "%s 受击，造成 %d 点伤害。" % [_target_name, damage]
	if _target_health == 0:
		_population.defeat_hostile(_active_interaction)
		_end_encounter("")

func _end_encounter(message: String) -> void:
	_active_interaction = null
	_target_label.visible = false
	if not message.is_empty():
		_status.text = message

func _refresh_target_label() -> void:
	_target_label.text = "%s  |  气血 %d / %d" % [_target_name, _target_health, _target_max_health]

func _refresh_player_label() -> void:
	_player_label.text = "野外气血 %d / %d" % [_player_health, _player_max_health]

func _spawn_brush_talisman(origin: Vector2, target: Vector2) -> void:
	var talisman: TalismanProjectile = TalismanProjectileScript.new()
	add_child(talisman)
	talisman.launch(origin, target)

func _spawn_spear_thrust(origin: Vector2, target: Vector2, width := 5.0) -> void:
	var thrust: SpearThrustEffect = SpearThrustEffectScript.new()
	add_child(thrust)
	thrust.launch(origin, target, width)
