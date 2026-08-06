extends Node2D

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
const BossIdleSheet: Texture2D = preload("res://assets/art/characters/boss_xiaochao_lansha/processed_alpha/boss_xiaochao_lansha_idle_south_6f_v01_alpha.png")
const BOSS_RETALIATION_RANGE := 650.0
const BOSS_ECHO_NAME := "潇潮岚鲨 · 映潮分身"

@onready var player: CharacterBody2D = $Player
@onready var boss: Area2D = $Boss
@onready var boss_sprite: FrameAnimationController = $Boss/Sprite
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
@onready var clear_panel: Control = $HUD/ClearPanel
@onready var clear_summary: Label = $HUD/ClearPanel/Summary
@onready var clear_return: Button = $HUD/ClearPanel/ReturnButton
@onready var skill_labels: Array[Label] = [
	$HUD/SkillBar/Basic/Label,
	$HUD/SkillBar/Ningxi/Label,
	$HUD/SkillBar/CloudStep/Label,
	$HUD/SkillBar/Guard/Label,
	$HUD/SkillBar/Nourish/Label,
]

var boss_health := 100
var near_boss := false
var boss_engaged := false
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
var last_drop: Dictionary = {}
var boss_phase := 1
var boss_attack_count := 0

const WATER_PALACE_DROPS := [
	{"item": "雾纹护腕", "stones": 10, "cultivation": 20},
	{"item": "潮息玉佩", "stones": 14, "cultivation": 18},
	{"item": "水府灵靴", "stones": 8, "cultivation": 24},
]

func _ready() -> void:
	boss_sprite.configure_from_grid(BossIdleSheet, 6, 1, {
		"idle_south": {"frames": [0, 1, 2, 3, 4, 5], "fps": 3.2, "loop": true},
	})
	boss_sprite.play_action("idle", "south")
	player.map_bounds = Rect2(64, 64, 2432, 1408)
	player.position = Vector2(240, 1250)
	player_health = int(GameState.derived_stats()["气血"])
	player_max_mana = float(GameState.derived_stats()["灵力"])
	player_mana = player_max_mana
	player.attack_started.connect(_on_player_attack_started)
	player.attack_impact.connect(_on_player_attack)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	clear_panel.visible = false
	clear_return.pressed.connect(_return_to_village)
	boss.body_entered.connect(func(body: Node2D): near_boss = body == player; _refresh_prompt())
	boss.body_exited.connect(func(body: Node2D): if body == player: near_boss = false; _refresh_prompt())
	status.text = "雾溪水府：深入内池，击败%s。她是归墟雾港稀有水妖在上游留下的映潮分身。" % BOSS_ECHO_NAME
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
	player_mana = minf(player_max_mana, player_mana + delta * (2.0 + GameState.artifact_mana_regen_bonus()))
	_refresh_player_mana()
	_refresh_skill_bar()
	if defeated or not boss_engaged or not _boss_can_reach_player() or boss_health <= 0:
		return
	boss_attack_cooldown -= delta
	if boss_attack_cooldown > 0.0:
		return
	boss_attack_cooldown = 1.8 if boss_phase >= 2 else 2.4
	boss_attack_count += 1
	if boss_phase >= 2 and boss_attack_count % 2 == 0:
		_perform_boss_tide_fan()
	else:
		_perform_boss_water_blade()


func _perform_boss_water_blade() -> void:
	var facing := (player.position - boss.position).normalized()
	demon_water_blade.play_burst(boss.position + Vector2(0, -86) + facing * 44.0, facing)
	await get_tree().create_timer(0.22).timeout
	if defeated or not boss_engaged or not _boss_can_reach_player() or boss_health <= 0:
		return
	var raw_damage := 9
	var damage := GameState.pve_damage_after_equipment(raw_damage, "water")
	var mitigation_notes: Array[String] = []
	var water_reduction := GameState.artifact_damage_reduction("water")
	if water_reduction > 0.0:
		mitigation_notes.append("%s凝出水幕，抵去%d%%水系伤害。" % [str(GameState.player.get("equipped_artifact", "法宝")), roundi(water_reduction * 100.0)])
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		mitigation_notes.append("岚息护体抵去了大半水刃。")
	player_health = max(0, player_health - damage)
	status.text = "%s掀起水刃，造成 %d 点伤害。%s" % [BOSS_ECHO_NAME, damage, " ".join(mitigation_notes)]
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在水府中力竭而退：死亡不掉落，正在返回云岚村。"
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://scenes/yunlan_outskirts.tscn")

func _on_player_attack(_direction: String) -> void:
	if not _can_hit_boss_with_basic() or boss_health <= 0:
		return
	boss_engaged = true
	_play_basic_weapon_effect()
	hit_spark.play_burst(boss.position + Vector2(0, -90), Vector2.UP)
	var damage := GameState.weapon_basic_damage(8)
	boss_health = max(0, boss_health - damage)
	status.text = "%s受击，造成 %d 点伤害。属性分配已影响本次攻击。" % [BOSS_ECHO_NAME, damage]
	_refresh_boss_hp()
	_check_boss_phase()
	if boss_health == 0:
		_defeat_boss()


func _perform_boss_tide_fan() -> void:
	# Phase two deliberately shows three clear lanes rather than speeding up a
	# single invisible hit.  The player can read the fan and dash out of the
	# centre lane, which fits the manual-action combat direction.
	var facing := (player.position - boss.position).normalized()
	for angle_offset in [-0.42, 0.0, 0.42]:
		var lane := facing.rotated(angle_offset)
		_spawn_boss_water_blade(boss.position + Vector2(0, -86) + lane * 42.0, lane, 72.0, 0.28)
	status.text = "%s以岚潮展开三道水刃；离开扇面即可避开。" % BOSS_ECHO_NAME
	await get_tree().create_timer(0.29).timeout
	if defeated or not boss_engaged or not _boss_can_reach_player() or boss_health <= 0:
		return
	var to_player := (player.position - boss.position).normalized()
	if facing.dot(to_player) < 0.84:
		return
	var damage := GameState.pve_damage_after_equipment(7, "water")
	if guard_time_left > 0.0:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
	player_health = max(0, player_health - damage)
	status.text = "%s的岚潮扇面命中，造成 %d 点伤害。" % [BOSS_ECHO_NAME, damage]
	_refresh_player_hp()
	if player_health == 0:
		defeated = true
		status.text = "你在水府中力竭而退：死亡不掉落，正在返回云岚村。"
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://scenes/yunlan_outskirts.tscn")


func _spawn_boss_water_blade(origin: Vector2, facing: Vector2, distance := 56.0, lifetime := 0.25) -> void:
	var blade := SpriteSheetBurst.new()
	blade.texture = demon_water_blade.texture
	blade.columns = 4
	blade.frame_count = 4
	blade.animation_fps = 16.0
	blade.motion_distance = distance
	blade.start_scale = Vector2(0.22, 0.22)
	blade.end_scale = Vector2(0.34, 0.34)
	$CombatEffects.add_child(blade)
	blade.play_burst(origin, facing)
	get_tree().create_timer(lifetime).timeout.connect(blade.queue_free)


func _check_boss_phase() -> void:
	if boss_phase >= 2 or boss_health > 50 or boss_health <= 0:
		return
	boss_phase = 2
	boss_attack_cooldown = minf(boss_attack_cooldown, 0.75)
	status.text = "%s的水袖与鲛鳞共鸣，映潮分身进入第二重“岚潮回环”；她会放出可见的三道水刃。" % BOSS_ECHO_NAME


func _on_player_attack_started(direction: String) -> void:
	if boss_health <= 0:
		return
	var facing := _direction_vector(direction)
	if SKILL_CATALOG.is_umbrella_skill_set(GameState.player.equipped_weapon):
		_spawn_umbrella_ward(player.position + facing * 34.0 + Vector2(0, -34), facing)
	elif SKILL_CATALOG.is_dao_skill_set(GameState.player.equipped_weapon):
		_spawn_dao_crescent(player.position + Vector2(0, -48), facing, 72.0, 7.0)
	elif SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon):
		_spawn_halberd_sweep(player.position + Vector2(0, -48), facing, 96.0, 8.0)
	elif SKILL_CATALOG.is_axe_skill_set(GameState.player.equipped_weapon):
		_spawn_axe_ground_cleave(player.position + facing * 20.0 + Vector2(0, -38), facing, 70.0, 9.0)
	elif SKILL_CATALOG.is_hammer_skill_set(GameState.player.equipped_weapon):
		_spawn_hammer_shockwave(player.position + facing * 22.0 + Vector2(0, -34), 60.0, 8.0)
	elif SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon):
		_spawn_staff_whirl(player.position + Vector2(0, -44), facing, 80.0, 6.0)
	elif SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon):
		_spawn_whip_lash(player.position + Vector2(0, -44), facing, 132.0, 5.0)
	elif SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon):
		_spawn_crossbow_bolt(player.position + Vector2(0, -50), boss.position + Vector2(0, -86))
	elif SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon):
		_spawn_fan_gust(player.position + Vector2(0, -46), facing, 142.0, 5.0)
	elif SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon):
		_spawn_guqin_note(player.position + Vector2(0, -56), facing, 180.0, 5.0)
	elif SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon):
		_spawn_xiao_soundstream(player.position + Vector2(0, -54), facing, 205.0, 5.0)
	elif SKILL_CATALOG.is_bell_skill_set(GameState.player.equipped_weapon):
		_spawn_bell_sonic_seal(player.position + Vector2(0, -54), facing, 170.0, 18.0)
	elif SKILL_CATALOG.is_array_disk_skill_set(GameState.player.equipped_weapon):
		_spawn_array_lattice(player.position + facing * 145.0 + Vector2(0, -40), 42.0)
	elif SKILL_CATALOG.is_puppet_skill_set(GameState.player.equipped_weapon):
		_spawn_puppet_dash(player.position + Vector2(38, -54), boss.position + Vector2(0, -70), 0.044)
	elif SKILL_CATALOG.is_cauldron_skill_set(GameState.player.equipped_weapon):
		_spawn_cauldron_flame(player.position + Vector2(30, -58), facing, 160.0, 14.0)
	elif SKILL_CATALOG.is_pearl_skill_set(GameState.player.equipped_weapon):
		_spawn_pearl_tide(player.position + Vector2(30, -56), boss.position + Vector2(0, -72), 12.0, 0.30)
	elif SKILL_CATALOG.is_seal_skill_set(GameState.player.equipped_weapon):
		_spawn_seal_slam(player.position + facing * 146.0 + Vector2(0, -38), 40.0)
	elif SKILL_CATALOG.is_mirror_skill_set(GameState.player.equipped_weapon):
		_spawn_mirror_ray(player.position + Vector2(28, -56), facing, 190.0, 4.0)
	elif SKILL_CATALOG.is_tower_skill_set(GameState.player.equipped_weapon):
		_spawn_tower_ward_impact(player.position + facing * 150.0 + Vector2(0, -42), 42.0)
	elif SKILL_CATALOG.is_wheel_skill_set(GameState.player.equipped_weapon):
		_spawn_wheel_return(player.position + Vector2(28, -54), boss.position + Vector2(0, -72), 13.0, 0.38)
	elif not SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon) and not SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon) and not SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon):
		slash_trail.play_burst(player.position + facing * 46.0 + Vector2(0, -34), facing)


func _cast_ningxi_sword_art() -> void:
	_cast_dungeon_weapon_primary(20, BOSS_ECHO_NAME, Vector2(0, -90))

func _cast_dungeon_weapon_primary(base_damage: int, target_name: String, hit_offset: Vector2) -> void:
	var primary := _skill(1)
	if boss_health <= 0 or player.position.distance_to(boss.position) > float(primary.get("range", 205.0)):
		status.text = "%s需要锁定近处目标。" % str(primary["name"])
		return
	if ningxi_cooldown > 0.0:
		status.text = "%s还需冷却 %.1f 秒。" % [str(primary["name"]), ningxi_cooldown]
		return
	if player_mana < float(primary["spirit_cost"]):
		status.text = "灵力不足，无法施放%s。" % str(primary["name"])
		return
	var facing := (boss.position - player.position).normalized()
	var umbrella := SKILL_CATALOG.is_umbrella_skill_set(GameState.player.equipped_weapon)
	var brush := SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon)
	var spear := SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon)
	var bow := SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon)
	var dao := SKILL_CATALOG.is_dao_skill_set(GameState.player.equipped_weapon)
	var halberd := SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon)
	var axe := SKILL_CATALOG.is_axe_skill_set(GameState.player.equipped_weapon)
	var hammer := SKILL_CATALOG.is_hammer_skill_set(GameState.player.equipped_weapon)
	var staff := SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon)
	var whip := SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon)
	var crossbow := SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon)
	var fan := SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon)
	var guqin := SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon)
	var xiao := SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon)
	var bell := SKILL_CATALOG.is_bell_skill_set(GameState.player.equipped_weapon)
	var array_disk := SKILL_CATALOG.is_array_disk_skill_set(GameState.player.equipped_weapon)
	var puppet := SKILL_CATALOG.is_puppet_skill_set(GameState.player.equipped_weapon)
	var cauldron := SKILL_CATALOG.is_cauldron_skill_set(GameState.player.equipped_weapon)
	var pearl := SKILL_CATALOG.is_pearl_skill_set(GameState.player.equipped_weapon)
	var seal := SKILL_CATALOG.is_seal_skill_set(GameState.player.equipped_weapon)
	var mirror := SKILL_CATALOG.is_mirror_skill_set(GameState.player.equipped_weapon)
	var tower := SKILL_CATALOG.is_tower_skill_set(GameState.player.equipped_weapon)
	var wheel := SKILL_CATALOG.is_wheel_skill_set(GameState.player.equipped_weapon)
	boss_engaged = true
	player_mana -= float(primary["spirit_cost"])
	ningxi_cooldown = float(primary["cooldown"])
	_refresh_player_mana()
	if umbrella:
		_spawn_umbrella_ward(player.position + Vector2(0, -58), facing)
		guard_time_left = maxf(guard_time_left, float(primary.get("guard_seconds", 0.0)))
	elif brush:
		_spawn_brush_talisman(player.position + Vector2(0, -56), boss.position + hit_offset)
	elif spear:
		_spawn_spear_thrust(player.position + Vector2(0, -48), boss.position + hit_offset, 8.0)
	elif bow:
		_spawn_wind_arrow(player.position + Vector2(0, -52), boss.position + hit_offset, 0.34)
	elif dao:
		_spawn_dao_crescent(player.position + Vector2(0, -50), facing, 118.0, 11.0)
	elif halberd:
		_spawn_halberd_sweep(player.position + Vector2(0, -50), facing, 142.0, 12.0)
	elif axe:
		_spawn_axe_ground_cleave(player.position + facing * 30.0 + Vector2(0, -40), facing, 112.0, 13.0)
	elif hammer:
		_spawn_hammer_shockwave(player.position + facing * 26.0 + Vector2(0, -36), 104.0, 13.0)
	elif staff:
		_spawn_staff_whirl(player.position + Vector2(0, -46), facing, 112.0, 9.0)
	elif whip:
		_spawn_whip_lash(player.position + Vector2(0, -46), facing, 170.0, 8.0)
	elif crossbow:
		_spawn_crossbow_bolt(player.position + Vector2(0, -52), boss.position + hit_offset, 0.18)
		_spawn_crossbow_bolt(player.position + Vector2(0, -52), boss.position + hit_offset + Vector2(0, -28), 0.23)
		_spawn_crossbow_bolt(player.position + Vector2(0, -52), boss.position + hit_offset + Vector2(0, 28), 0.28)
	elif fan:
		_spawn_fan_gust(player.position + Vector2(0, -48), facing, 190.0, 8.0)
	elif guqin:
		_spawn_guqin_note(player.position + Vector2(0, -58), facing, 235.0, 8.0)
	elif xiao:
		_spawn_xiao_soundstream(player.position + Vector2(0, -56), facing, 260.0, 8.0)
	elif bell:
		_spawn_bell_sonic_seal(player.position + Vector2(0, -56), facing, 236.0, 28.0)
	elif array_disk:
		_spawn_array_lattice(player.position + facing * 205.0 + Vector2(0, -44), 70.0)
	elif puppet:
		_spawn_puppet_dash(player.position + Vector2(38, -56), boss.position + hit_offset, 0.062)
	elif cauldron:
		_spawn_cauldron_flame(player.position + Vector2(30, -60), facing, 232.0, 24.0)
	elif pearl:
		_spawn_pearl_tide(player.position + Vector2(30, -58), boss.position + hit_offset, 16.0, 0.24)
	elif seal:
		_spawn_seal_slam(player.position + facing * 210.0 + Vector2(0, -40), 68.0)
	elif mirror:
		_spawn_mirror_ray(player.position + Vector2(28, -58), facing, 260.0, 7.0)
	elif tower:
		_spawn_tower_ward_impact(player.position + facing * 218.0 + Vector2(0, -44), 74.0)
	elif wheel:
		_spawn_wheel_return(player.position + Vector2(28, -56), boss.position + hit_offset, 18.0, 0.52)
	else:
		ningxi_cast.play_burst(player.position + Vector2(0, -62), facing)
	status.text = "%s结印中……灵力 -%d。" % [str(primary["name"]), int(primary["spirit_cost"])]
	await get_tree().create_timer(0.24).timeout
	if defeated or boss_health <= 0 or player.position.distance_to(boss.position) > float(primary.get("range", 205.0)) + 30.0:
		return
	var tuned_base := int(primary.get("damage_base", 20)) + (base_damage - 20)
	var damage := GameState.weapon_skill_damage(tuned_base, float(primary.get("attack_ratio", 0.5)), player_max_mana, float(primary.get("mana_ratio", 30.0)))
	boss_health = max(0, boss_health - damage)
	hit_spark.play_burst(boss.position + hit_offset, Vector2.UP)
	status.text = "%s命中%s，造成 %d 点伤害。%s" % [str(primary["name"]), target_name, damage, "伞阵保留了一层短暂护持。" if umbrella else ""]
	_refresh_boss_hp()
	_check_boss_phase()
	if boss_health == 0:
		_defeat_boss()

func _can_hit_boss_with_basic() -> bool:
	if near_boss:
		return true
	var ranged_weapon := SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_bell_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_array_disk_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_puppet_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_cauldron_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_pearl_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_seal_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_mirror_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_tower_skill_set(GameState.player.equipped_weapon) or SKILL_CATALOG.is_wheel_skill_set(GameState.player.equipped_weapon)
	if not ranged_weapon:
		return false
	return player.position.distance_to(boss.position) <= float(_skill(0).get("range", 205.0))

func _play_basic_weapon_effect() -> void:
	if SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon):
		_spawn_brush_talisman(player.position + Vector2(0, -46), boss.position + Vector2(0, -90))
	elif SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon):
		_spawn_spear_thrust(player.position + Vector2(0, -42), boss.position + Vector2(0, -88), 5.0)
	elif SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon):
		_spawn_wind_arrow(player.position + Vector2(0, -52), boss.position + Vector2(0, -88))
	elif SKILL_CATALOG.is_dao_skill_set(GameState.player.equipped_weapon):
		_spawn_dao_crescent(player.position + Vector2(0, -48), (boss.position - player.position).normalized(), 72.0, 7.0)
	elif SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon):
		_spawn_halberd_sweep(player.position + Vector2(0, -48), (boss.position - player.position).normalized(), 96.0, 8.0)
	elif SKILL_CATALOG.is_axe_skill_set(GameState.player.equipped_weapon):
		_spawn_axe_ground_cleave(player.position + (boss.position - player.position).normalized() * 20.0 + Vector2(0, -38), (boss.position - player.position).normalized(), 70.0, 9.0)
	elif SKILL_CATALOG.is_hammer_skill_set(GameState.player.equipped_weapon):
		_spawn_hammer_shockwave(player.position + (boss.position - player.position).normalized() * 22.0 + Vector2(0, -34), 60.0, 8.0)
	elif SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon):
		_spawn_staff_whirl(player.position + Vector2(0, -44), (boss.position - player.position).normalized(), 80.0, 6.0)
	elif SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon):
		_spawn_whip_lash(player.position + Vector2(0, -44), (boss.position - player.position).normalized(), 132.0, 5.0)
	elif SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon):
		_spawn_crossbow_bolt(player.position + Vector2(0, -50), boss.position + Vector2(0, -86))
	elif SKILL_CATALOG.is_fan_skill_set(GameState.player.equipped_weapon):
		_spawn_fan_gust(player.position + Vector2(0, -46), (boss.position - player.position).normalized(), 142.0, 5.0)
	elif SKILL_CATALOG.is_guqin_skill_set(GameState.player.equipped_weapon):
		_spawn_guqin_note(player.position + Vector2(0, -56), (boss.position - player.position).normalized(), 180.0, 5.0)
	elif SKILL_CATALOG.is_xiao_skill_set(GameState.player.equipped_weapon):
		_spawn_xiao_soundstream(player.position + Vector2(0, -54), (boss.position - player.position).normalized(), 205.0, 5.0)
	elif SKILL_CATALOG.is_bell_skill_set(GameState.player.equipped_weapon):
		_spawn_bell_sonic_seal(player.position + Vector2(0, -54), (boss.position - player.position).normalized(), 170.0, 18.0)
	elif SKILL_CATALOG.is_array_disk_skill_set(GameState.player.equipped_weapon):
		_spawn_array_lattice(player.position + (boss.position - player.position).normalized() * 145.0 + Vector2(0, -40), 42.0)
	elif SKILL_CATALOG.is_puppet_skill_set(GameState.player.equipped_weapon):
		_spawn_puppet_dash(player.position + Vector2(38, -54), boss.position + Vector2(0, -70), 0.044)
	elif SKILL_CATALOG.is_cauldron_skill_set(GameState.player.equipped_weapon):
		_spawn_cauldron_flame(player.position + Vector2(30, -58), (boss.position - player.position).normalized(), 160.0, 14.0)
	elif SKILL_CATALOG.is_pearl_skill_set(GameState.player.equipped_weapon):
		_spawn_pearl_tide(player.position + Vector2(30, -56), boss.position + Vector2(0, -72), 12.0, 0.30)
	elif SKILL_CATALOG.is_seal_skill_set(GameState.player.equipped_weapon):
		_spawn_seal_slam(player.position + (boss.position - player.position).normalized() * 146.0 + Vector2(0, -38), 40.0)
	elif SKILL_CATALOG.is_mirror_skill_set(GameState.player.equipped_weapon):
		_spawn_mirror_ray(player.position + Vector2(28, -56), (boss.position - player.position).normalized(), 190.0, 4.0)
	elif SKILL_CATALOG.is_tower_skill_set(GameState.player.equipped_weapon):
		_spawn_tower_ward_impact(player.position + (boss.position - player.position).normalized() * 150.0 + Vector2(0, -42), 42.0)
	elif SKILL_CATALOG.is_wheel_skill_set(GameState.player.equipped_weapon):
		_spawn_wheel_return(player.position + Vector2(28, -54), boss.position + Vector2(0, -72), 13.0, 0.38)

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
	ward.trigger(player.position + Vector2(0, -52))
	return true

func _boss_can_reach_player() -> bool:
	return player.position.distance_to(boss.position) <= BOSS_RETALIATION_RANGE


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
	return SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)[index]


func _defeat_boss() -> void:
	if defeated:
		return
	defeated = true
	boss.visible = false
	boss.set_deferred("monitoring", false)
	var first_clear_pearl: bool = not GameState.player.inventory.has("雾潮练气珠")
	last_drop = WATER_PALACE_DROPS.pick_random().duplicate()
	GameState.add_item(str(last_drop.item))
	GameState.add_item("岚鲨鳞片")
	if first_clear_pearl:
		GameState.add_item("雾潮练气珠")
	GameState.add_spirit_stones(int(last_drop.stones))
	GameState.gain_cultivation(int(last_drop.cultivation))
	var monthly_card_bonus := GameState.try_award_monthly_card_common_material("mist_stream_palace", ["雾溪药", "凝气符"])
	GameState.record_dungeon_run({
		"dungeon_id": "mist_stream_palace",
		"boss": BOSS_ECHO_NAME,
		"drop": last_drop.item,
		"material": "岚鲨鳞片",
		"monthly_card_common_bonus": monthly_card_bonus,
		"spirit_stones": last_drop.stones,
		"cultivation": last_drop.cultivation,
	})
	GameState.unlock_region("mist_border")
	status.text = "水府试炼完成：已获得掉落，可从结算面板返回云岚村。"
	prompt.text = ""
	var pearl_reward := "、雾潮练气珠（首通御水法宝）" if first_clear_pearl else ""
	var monthly_bonus_text := "\n月卡常规材料额外产出：%s" % monthly_card_bonus if not monthly_card_bonus.is_empty() else ""
	clear_summary.text = "%s已退入水雾。\n\n获得：%s、岚鲨鳞片%s\n灵石 +%d　修为 +%d%s\n\n首件装备来自水府试炼随机掉落；岚鲨鳞片可用于后续护具与水系炼器。" % [BOSS_ECHO_NAME, str(last_drop.item), pearl_reward, int(last_drop.stones), int(last_drop.cultivation), monthly_bonus_text]
	clear_panel.visible = true

func _return_to_village() -> void:
	GameState.enter_screen(GameState.Screen.OVERWORLD)
	get_tree().change_scene_to_file("res://scenes/yunlan_outskirts.tscn")


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

func _spawn_umbrella_ward(origin: Vector2, direction: Vector2) -> void:
	for index in 2:
		var arc := Line2D.new()
		arc.width = 5.0 - index
		arc.default_color = Color(0.62, 0.84, 1.0, 0.92 - index * 0.22)
		arc.z_index = 18
		var points := PackedVector2Array()
		for point_index in 13:
			var angle := lerpf(-2.52, -0.62, float(point_index) / 12.0)
			points.append(Vector2(cos(angle) * (62.0 + index * 13.0), sin(angle) * 30.0))
		arc.points = points
		arc.position = origin + direction * 16.0
		arc.rotation = direction.angle() + PI * 0.5
		add_child(arc)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(arc, "scale", Vector2(1.45, 1.45), 0.34)
		tween.tween_property(arc, "modulate:a", 0.0, 0.34)
		tween.chain().tween_callback(arc.queue_free)

func _refresh_boss_hp() -> void:
	var phase_name := "第一重 · 潮刃" if boss_phase == 1 else "第二重 · 岚潮回环"
	boss_hp.text = "%s｜%s｜气血 %d / 100" % [BOSS_ECHO_NAME, phase_name, boss_health]

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
	prompt.text = "[J] %s  [K] %s" % [str(_skill(0)["name"]), str(_skill(1)["name"])] if near_boss and boss_health > 0 else ""

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
		get_tree().change_scene_to_file("res://scenes/yunlan_outskirts.tscn")
