class_name WorldEncounterController
extends Node

## Lightweight overworld encounter loop.  It uses the same player attack
## signal as dungeons, but keeps enemies tied to regional population sites.
const MELEE_RANGE := 205.0
const ENEMY_ATTACK_RANGE := 650.0
const SKILL_CATALOG = preload("res://src/data/skill_catalog.gd")
const TalismanProjectileScript = preload("res://src/combat/talisman_projectile.gd")
const SpearThrustEffectScript = preload("res://src/combat/spear_thrust_effect.gd")
const WindArrowProjectileScript = preload("res://src/combat/wind_arrow_projectile.gd")
const DaoCrescentSlashScript = preload("res://src/combat/dao_crescent_slash.gd")
const HalberdSweepEffectScript = preload("res://src/combat/halberd_sweep_effect.gd")
const AxeGroundCleaveEffectScript = preload("res://src/combat/axe_ground_cleave_effect.gd")
const HammerShockwaveEffectScript = preload("res://src/combat/hammer_shockwave_effect.gd")
const StaffWhirlEffectScript = preload("res://src/combat/staff_whirl_effect.gd")
const WhipLashEffectScript = preload("res://src/combat/whip_lash_effect.gd")
const CrossbowBoltProjectileScript = preload("res://src/combat/crossbow_bolt_projectile.gd")
const FanGustEffectScript = preload("res://src/combat/fan_gust_effect.gd")
const GuqinNoteEffectScript = preload("res://src/combat/guqin_note_effect.gd")
const XiaoSoundstreamEffectScript = preload("res://src/combat/xiao_soundstream_effect.gd")
const BellSonicSealEffectScript = preload("res://src/combat/bell_sonic_seal_effect.gd")
const ArrayLatticeEffectScript = preload("res://src/combat/array_lattice_effect.gd")
const EightfoldArrayWardScript = preload("res://src/combat/eightfold_array_ward.gd")

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
	var array_ward := _show_eightfold_array_ward("neutral")
	_player_health = max(0, _player_health - damage)
	_refresh_player_label()
	_status.text = "%s 逼近发动袭击，造成 %d 点伤害。%s可继续手操反击或先拉开距离。" % [_target_name, damage, "八角阵纹卸去部分冲击；" if array_ward else ""]
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
	elif SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon):
		attack_range = float(SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)[0].get("range", MELEE_RANGE))
	if _player.global_position.distance_to(enemy_position) > attack_range:
		_status.text = "攻击落空：%s 不在近战范围内。" % _target_name
		return
	var damage := GameState.weapon_basic_damage(9)
	if SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon):
		_spawn_brush_talisman(_player.global_position + Vector2(0, -46), enemy_position + Vector2(0, -52))
	elif SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon):
		_spawn_spear_thrust(_player.global_position + Vector2(0, -42), enemy_position + Vector2(0, -52), 5.0)
	elif SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon):
		_spawn_wind_arrow(_player.global_position + Vector2(0, -52), enemy_position + Vector2(0, -52))
	elif SKILL_CATALOG.is_dao_skill_set(GameState.player.equipped_weapon):
		_spawn_dao_crescent(_player.global_position + Vector2(0, -48), (enemy_position - _player.global_position).normalized(), 72.0, 7.0)
	elif SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon):
		_spawn_halberd_sweep(_player.global_position + Vector2(0, -48), (enemy_position - _player.global_position).normalized(), 96.0, 8.0)
	elif SKILL_CATALOG.is_axe_skill_set(GameState.player.equipped_weapon):
		_spawn_axe_ground_cleave(_player.global_position + (enemy_position - _player.global_position).normalized() * 20.0 + Vector2(0, -38), (enemy_position - _player.global_position).normalized(), 70.0, 9.0)
	elif SKILL_CATALOG.is_hammer_skill_set(GameState.player.equipped_weapon):
		_spawn_hammer_shockwave(_player.global_position + (enemy_position - _player.global_position).normalized() * 22.0 + Vector2(0, -34), 60.0, 8.0)
	elif SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon):
		_spawn_staff_whirl(_player.global_position + Vector2(0, -44), (enemy_position - _player.global_position).normalized(), 80.0, 6.0)
	elif SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon):
		_spawn_whip_lash(_player.global_position + Vector2(0, -44), (enemy_position - _player.global_position).normalized(), 132.0, 5.0)
	elif SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon):
		_spawn_crossbow_bolt(_player.global_position + Vector2(0, -50), enemy_position + Vector2(0, -52))
	elif SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon):
		_spawn_fan_gust(_player.global_position + Vector2(0, -46), (enemy_position - _player.global_position).normalized(), 142.0, 5.0)
	elif SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon):
		_spawn_guqin_note(_player.global_position + Vector2(0, -56), (enemy_position - _player.global_position).normalized(), 180.0, 5.0)
	elif SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon):
		_spawn_xiao_soundstream(_player.global_position + Vector2(0, -54), (enemy_position - _player.global_position).normalized(), 205.0, 5.0)
	elif SKILL_CATALOG.is_bell_skill_set(GameState.player.equipped_weapon):
		_spawn_bell_sonic_seal(_player.global_position + Vector2(0, -54), (enemy_position - _player.global_position).normalized(), 170.0, 18.0)
	elif SKILL_CATALOG.is_array_disk_skill_set(GameState.player.equipped_weapon):
		_spawn_array_lattice(_player.global_position + (enemy_position - _player.global_position).normalized() * 145.0 + Vector2(0, -40), 42.0)
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

func _spawn_wind_arrow(origin: Vector2, target: Vector2, travel_time := 0.30) -> void:
	var arrow: WindArrowProjectile = WindArrowProjectileScript.new()
	add_child(arrow)
	arrow.launch(origin, target, Color(0.70, 0.94, 1.0), travel_time)

func _spawn_dao_crescent(origin: Vector2, direction: Vector2, radius := 72.0, thickness := 7.0) -> void:
	var slash: DaoCrescentSlash = DaoCrescentSlashScript.new()
	add_child(slash)
	slash.launch(origin, direction, radius, thickness)

func _spawn_halberd_sweep(origin: Vector2, direction: Vector2, radius := 96.0, thickness := 8.0) -> void:
	var sweep: HalberdSweepEffect = HalberdSweepEffectScript.new()
	sweep.name = "HalberdSweepEffect"
	add_child(sweep)
	sweep.launch(origin, direction, radius, thickness)

func _spawn_axe_ground_cleave(origin: Vector2, direction: Vector2, radius := 70.0, width := 9.0) -> void:
	var cleave: AxeGroundCleaveEffect = AxeGroundCleaveEffectScript.new()
	cleave.name = "AxeGroundCleaveEffect"
	add_child(cleave)
	cleave.launch(origin, direction, radius, width)

func _spawn_hammer_shockwave(origin: Vector2, radius := 60.0, thickness := 8.0) -> void:
	var shockwave: HammerShockwaveEffect = HammerShockwaveEffectScript.new()
	shockwave.name = "HammerShockwaveEffect"
	add_child(shockwave)
	shockwave.launch(origin, radius, thickness)

func _spawn_staff_whirl(origin: Vector2, direction: Vector2, radius := 80.0, thickness := 6.0) -> void:
	var whirl: StaffWhirlEffect = StaffWhirlEffectScript.new()
	whirl.name = "StaffWhirlEffect"
	add_child(whirl)
	whirl.launch(origin, direction, radius, thickness)

func _spawn_whip_lash(origin: Vector2, direction: Vector2, reach := 132.0, width := 5.0) -> void:
	var lash: WhipLashEffect = WhipLashEffectScript.new()
	lash.name = "WhipLashEffect"
	add_child(lash)
	lash.launch(origin, direction, reach, width)

func _spawn_crossbow_bolt(origin: Vector2, target: Vector2, travel_time := 0.22) -> void:
	var bolt: CrossbowBoltProjectile = CrossbowBoltProjectileScript.new()
	bolt.name = "CrossbowBoltProjectile"
	add_child(bolt)
	bolt.launch(origin, target, travel_time)

func _spawn_fan_gust(origin: Vector2, direction: Vector2, reach := 142.0, width := 5.0) -> void:
	var gust: FanGustEffect = FanGustEffectScript.new()
	gust.name = "FanGustEffect"
	add_child(gust)
	gust.launch(origin, direction, reach, width)

func _spawn_guqin_note(origin: Vector2, direction: Vector2, reach := 180.0, thickness := 5.0) -> void:
	var note: GuqinNoteEffect = GuqinNoteEffectScript.new()
	note.name = "GuqinNoteEffect"
	add_child(note)
	note.launch(origin, direction, reach, thickness)

func _spawn_xiao_soundstream(origin: Vector2, direction: Vector2, reach := 205.0, width := 5.0) -> void:
	var stream: XiaoSoundstreamEffect = XiaoSoundstreamEffectScript.new()
	stream.name = "XiaoSoundstreamEffect"
	add_child(stream)
	stream.launch(origin, direction, reach, width)

func _spawn_bell_sonic_seal(origin: Vector2, direction: Vector2, reach := 170.0, radius := 18.0) -> void:
	var seal: BellSonicSealEffect = BellSonicSealEffectScript.new()
	seal.name = "BellSonicSealEffect"
	add_child(seal)
	seal.launch(origin, direction, reach, radius)

func _spawn_array_lattice(origin: Vector2, radius := 52.0) -> void:
	var lattice: ArrayLatticeEffect = ArrayLatticeEffectScript.new()
	lattice.name = "ArrayLatticeEffect"
	add_child(lattice)
	lattice.deploy(origin, radius)

func _show_eightfold_array_ward(element: String) -> bool:
	if str(GameState.player.get("equipped_artifact", "")) != "八角练气阵盘":
		return false
	if GameState.artifact_damage_reduction(element) <= 0.0:
		return false
	var ward: EightfoldArrayWard = EightfoldArrayWardScript.new()
	ward.name = "EightfoldArrayWard"
	add_child(ward)
	ward.trigger(_player.global_position + Vector2(0, -52))
	return true
