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
const PuppetDashEffectScript = preload("res://src/combat/puppet_dash_effect.gd")
const CauldronFlameEffectScript = preload("res://src/combat/cauldron_flame_effect.gd")
const PearlTideProjectileScript = preload("res://src/combat/pearl_tide_projectile.gd")
const SealSlamEffectScript = preload("res://src/combat/seal_slam_effect.gd")
const MirrorRayEffectScript = preload("res://src/combat/mirror_ray_effect.gd")
const TowerWardImpactEffectScript = preload("res://src/combat/tower_ward_impact_effect.gd")
const WheelReturnEffectScript = preload("res://src/combat/wheel_return_effect.gd")
const EightfoldArrayWardScript = preload("res://src/combat/eightfold_array_ward.gd")

signal combat_state_changed(state: Dictionary)

var _player: CharacterBody2D
var _population: Node
var _status: Label
var _target_label: Label
var _player_label: Label
var _touch_controls: Node
var _active_interaction: Area2D
var _target_name := ""
var _target_health := 0
var _target_max_health := 0
var _target_damage := 0
var _player_health := 0
var _player_max_health := 0
var _attack_cooldown := 0.0
var _player_mana := 0.0
var _player_max_mana := 0.0
var _primary_cooldown := 0.0
var _cloud_step_cooldown := 0.0
var _guard_cooldown := 0.0
var _nourish_cooldown := 0.0
var _guard_time_left := 0.0

func configure(player: CharacterBody2D, population: Node, status: Label, target_label: Label, player_label: Label) -> void:
	_player = player
	_population = population
	_status = status
	_target_label = target_label
	_player_label = player_label
	_player_max_health = int(GameState.derived_stats()["气血"])
	_player_health = _player_max_health
	_player_max_mana = float(GameState.derived_stats()["灵力"])
	_player_mana = _player_max_mana
	_touch_controls = get_parent().get_node_or_null("HUD/TouchControls")
	_player.attack_impact.connect(_on_player_attack_impact)
	_population.hostile_encounter_requested.connect(_begin_encounter)
	_target_label.visible = false
	_refresh_player_label()
	_publish_combat_state()

func is_in_encounter() -> bool:
	return _active_interaction != null

func _process(delta: float) -> void:
	_primary_cooldown = maxf(0.0, _primary_cooldown - delta)
	_cloud_step_cooldown = maxf(0.0, _cloud_step_cooldown - delta)
	_guard_cooldown = maxf(0.0, _guard_cooldown - delta)
	_nourish_cooldown = maxf(0.0, _nourish_cooldown - delta)
	_guard_time_left = maxf(0.0, _guard_time_left - delta)
	_player_mana = minf(_player_max_mana, _player_mana + delta * (2.0 + GameState.artifact_mana_regen_bonus()))
	_refresh_player_label()
	_publish_combat_state()
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
	var was_guarding := _guard_time_left > 0.0
	if was_guarding:
		damage = ceili(float(damage) * 0.45)
		_guard_time_left = 0.0
	var array_ward := _show_eightfold_array_ward("neutral")
	_player_health = max(0, _player_health - damage)
	_refresh_player_label()
	_status.text = "%s 逼近发动袭击，造成 %d 点伤害。%s%s" % [_target_name, damage, "岚息护体抵去大半冲击；" if was_guarding else "", "八角阵纹继续卸去部分冲击。" if array_ward else "可继续手操反击或先拉开距离。"]
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


func use_action(action_id: String) -> void:
	match action_id:
		"attack": _player.trigger_basic_attack()
		"ningxi": _cast_weapon_primary()
		"cloud_step": _cast_cloud_step()
		"guard": _cast_lan_breath_guard()
		"nourish": _cast_spirit_nourish()


func _cast_weapon_primary() -> void:
	if _active_interaction == null or not is_instance_valid(_active_interaction):
		_status.text = "%s需要先锁定野外敌对目标。" % str(_skill(1).get("name", "武器主技"))
		return
	var primary := _skill(1)
	var enemy_position: Vector2 = (_active_interaction.get_parent() as Node2D).global_position
	if _player.global_position.distance_to(enemy_position) > float(primary.get("range", MELEE_RANGE)):
		_status.text = "%s超出%s的有效距离。" % [_target_name, str(primary.get("name", "武器主技"))]
		return
	if not _try_use_skill(1, _primary_cooldown):
		return
	_primary_cooldown = float(primary.get("cooldown", 4.0))
	var facing := (enemy_position - _player.global_position).normalized()
	_spawn_skill_ripple(_player.global_position + Vector2(0, -52), Color(0.48, 0.92, 1.0), 38.0, facing)
	if SKILL_CATALOG.is_umbrella_skill_set(GameState.player.equipped_weapon):
		_guard_time_left = maxf(_guard_time_left, float(primary.get("guard_seconds", 1.8)))
	var damage := GameState.weapon_skill_damage(
		int(primary.get("damage_base", 20)), float(primary.get("attack_ratio", 0.5)),
		_player_max_mana, float(primary.get("mana_ratio", 30.0))
	)
	_damage_target(damage, "%s命中%s，造成 %d 点灵力伤害。" % [str(primary.get("name", "武器主技")), _target_name, damage])


func _cast_cloud_step() -> void:
	if not _try_use_skill(2, _cloud_step_cooldown):
		return
	_cloud_step_cooldown = float(_skill(2).get("cooldown", 3.0))
	var direction := _player.velocity.normalized()
	if _active_interaction != null and is_instance_valid(_active_interaction):
		var enemy_position: Vector2 = (_active_interaction.get_parent() as Node2D).global_position
		direction = (_player.global_position - enemy_position).normalized()
	if direction.length_squared() < 0.001:
		direction = Vector2.DOWN
	_player.perform_dash(direction, 176.0)
	_spawn_skill_ripple(_player.global_position + Vector2(0, -52), Color(0.70, 0.92, 1.0), 24.0, direction)
	_status.text = "云步踏岚而行，迅速拉开了距离。"


func _cast_lan_breath_guard() -> void:
	if not _try_use_skill(3, _guard_cooldown):
		return
	_guard_cooldown = float(_skill(3).get("cooldown", 7.0))
	_guard_time_left = 4.0
	_spawn_skill_ripple(_player.global_position + Vector2(0, -52), Color(0.50, 1.0, 0.82), 46.0, Vector2.UP)
	_status.text = "岚息护体展开：下一次野外受击将大幅减伤。"


func _cast_spirit_nourish() -> void:
	if not _try_use_skill(4, _nourish_cooldown):
		return
	_nourish_cooldown = float(_skill(4).get("cooldown", 8.0))
	_player_mana = minf(_player_max_mana, _player_mana + 46.0)
	_spawn_skill_ripple(_player.global_position + Vector2(0, -52), Color(0.82, 0.88, 1.0), 30.0, Vector2.UP)
	_status.text = "润灵诀回转经脉，恢复部分灵力。"


func _try_use_skill(index: int, cooldown: float) -> bool:
	var skill := _skill(index)
	if cooldown > 0.0:
		_status.text = "%s还需冷却 %.1f 秒。" % [str(skill.get("name", "技能")), cooldown]
		return false
	var cost := float(skill.get("spirit_cost", 0))
	if _player_mana < cost:
		_status.text = "灵力不足，无法施放%s。" % str(skill.get("name", "技能"))
		return false
	_player_mana -= cost
	_publish_combat_state()
	return true


func _skill(index: int) -> Dictionary:
	return SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)[index]

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
	elif SKILL_CATALOG.is_puppet_skill_set(GameState.player.equipped_weapon):
		_spawn_puppet_dash(_player.global_position + Vector2(38, -54), enemy_position + Vector2(0, -52), 0.044)
	elif SKILL_CATALOG.is_cauldron_skill_set(GameState.player.equipped_weapon):
		_spawn_cauldron_flame(_player.global_position + Vector2(30, -58), (enemy_position - _player.global_position).normalized(), 160.0, 14.0)
	elif SKILL_CATALOG.is_pearl_skill_set(GameState.player.equipped_weapon):
		_spawn_pearl_tide(_player.global_position + Vector2(30, -56), enemy_position + Vector2(0, -52), 12.0, 0.30)
	elif SKILL_CATALOG.is_seal_skill_set(GameState.player.equipped_weapon):
		_spawn_seal_slam(_player.global_position + (enemy_position - _player.global_position).normalized() * 146.0 + Vector2(0, -38), 40.0)
	elif SKILL_CATALOG.is_mirror_skill_set(GameState.player.equipped_weapon):
		_spawn_mirror_ray(_player.global_position + Vector2(28, -56), (enemy_position - _player.global_position).normalized(), 190.0, 4.0)
	elif SKILL_CATALOG.is_tower_skill_set(GameState.player.equipped_weapon):
		_spawn_tower_ward_impact(_player.global_position + (enemy_position - _player.global_position).normalized() * 150.0 + Vector2(0, -42), 42.0)
	elif SKILL_CATALOG.is_wheel_skill_set(GameState.player.equipped_weapon):
		_spawn_wheel_return(_player.global_position + Vector2(28, -54), enemy_position + Vector2(0, -52), 13.0, 0.38)
	_target_health = max(0, _target_health - damage)
	_refresh_target_label()
	_status.text = "%s 受击，造成 %d 点伤害。" % [_target_name, damage]
	if _target_health == 0:
		_population.defeat_hostile(_active_interaction)
		_end_encounter("")


func _damage_target(damage: int, summary: String) -> void:
	if _active_interaction == null or not is_instance_valid(_active_interaction):
		return
	_target_health = max(0, _target_health - damage)
	_refresh_target_label()
	_status.text = summary
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
	_player_label.text = "野外气血 %d / %d　灵力 %d / %d" % [_player_health, _player_max_health, int(_player_mana), int(_player_max_mana)]


func _publish_combat_state() -> void:
	var state := {
		"mana": _player_mana,
		"cooldowns": {
			"ningxi": _primary_cooldown,
			"cloud_step": _cloud_step_cooldown,
			"guard": _guard_cooldown,
			"nourish": _nourish_cooldown,
		},
		"costs": {
			"ningxi": float(_skill(1).get("spirit_cost", 0)),
			"cloud_step": float(_skill(2).get("spirit_cost", 0)),
			"guard": float(_skill(3).get("spirit_cost", 0)),
			"nourish": float(_skill(4).get("spirit_cost", 0)),
		},
	}
	combat_state_changed.emit(state)
	if _touch_controls != null and _touch_controls.has_method("set_combat_state"):
		_touch_controls.set_combat_state(state)


func _spawn_skill_ripple(origin: Vector2, tint: Color, radius: float, direction: Vector2) -> void:
	# A common cast ring communicates the shared cultivation skills without
	# pretending every weapon family uses the same projectile art.
	var ring := Line2D.new()
	ring.width = 4.0
	ring.default_color = tint
	ring.z_index = 18
	var points := PackedVector2Array()
	for index in 17:
		var angle := TAU * float(index) / 16.0
		points.append(Vector2(cos(angle), sin(angle) * 0.56) * radius)
	ring.points = points
	ring.position = origin + direction.normalized() * 18.0
	add_child(ring)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(2.1, 2.1), 0.34)
	tween.tween_property(ring, "modulate:a", 0.0, 0.34)
	tween.chain().tween_callback(ring.queue_free)

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

func _spawn_puppet_dash(origin: Vector2, target: Vector2, size := 0.052) -> void:
	var puppet: PuppetDashEffect = PuppetDashEffectScript.new()
	puppet.name = "PuppetDashEffect"
	add_child(puppet)
	puppet.launch(origin, target, size)

func _spawn_cauldron_flame(origin: Vector2, direction: Vector2, reach := 160.0, width := 16.0) -> void:
	var flame: CauldronFlameEffect = CauldronFlameEffectScript.new()
	flame.name = "CauldronFlameEffect"
	add_child(flame)
	flame.pour(origin, direction, reach, width)

func _spawn_pearl_tide(origin: Vector2, target: Vector2, radius := 13.0, duration := 0.30) -> void:
	var pearl: PearlTideProjectile = PearlTideProjectileScript.new()
	pearl.name = "PearlTideProjectile"
	add_child(pearl)
	pearl.launch(origin, target, radius, duration)

func _spawn_seal_slam(origin: Vector2, size := 44.0) -> void:
	var seal: SealSlamEffect = SealSlamEffectScript.new()
	seal.name = "SealSlamEffect"
	add_child(seal)
	seal.slam(origin, size)

func _spawn_mirror_ray(origin: Vector2, direction: Vector2, reach := 180.0, thickness := 4.0) -> void:
	var ray: MirrorRayEffect = MirrorRayEffectScript.new()
	ray.name = "MirrorRayEffect"
	add_child(ray)
	ray.reflect(origin, direction, reach, thickness)

func _spawn_tower_ward_impact(origin: Vector2, radius := 48.0) -> void:
	var impact: TowerWardImpactEffect = TowerWardImpactEffectScript.new()
	impact.name = "TowerWardImpactEffect"
	add_child(impact)
	impact.invoke(origin, radius)

func _spawn_wheel_return(origin: Vector2, target: Vector2, radius := 17.0, duration := 0.42) -> void:
	var wheel: WheelReturnEffect = WheelReturnEffectScript.new()
	wheel.name = "WheelReturnEffect"
	add_child(wheel)
	wheel.launch(origin, target, radius, duration)

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
