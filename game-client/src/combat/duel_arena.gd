class_name DuelArena
extends Node2D

## A real local 1v1 control loop for the first playable prototype.  It proves
## movement, attack timing, weapon defense and resolution in the same 2D world
## presentation. It intentionally does not claim networked multiplayer.

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

@onready var player: SpatialTestPlayer = $Player
@onready var opponent: DuelOpponent = $Opponent
@onready var player_hp_label: Label = $HUD/PlayerHP
@onready var opponent_hp_label: Label = $HUD/OpponentHP
@onready var skill_label: Label = $HUD/Skills
@onready var status: Label = $HUD/StatusPanel/Status
@onready var touch_controls: Node = $HUD/TouchControls

var player_hp := 100
var finished := false
var player_mana := 0.0
var player_max_mana := 0.0
var ningxi_cooldown := 0.0
var cloud_step_cooldown := 0.0
var guard_cooldown := 0.0
var nourish_cooldown := 0.0
var guard_time_left := 0.0


func _ready() -> void:
	player.map_bounds = Rect2(180.0, 220.0, 2700.0, 1500.0)
	player.position = Vector2(1130, 1260)
	opponent.position = Vector2(1880, 980)
	opponent.map_bounds = player.map_bounds
	opponent.configure(player)
	player.attack_impact.connect(_on_player_attack_impact)
	opponent.attack_landed.connect(_on_opponent_attack)
	opponent.defeated.connect(_on_opponent_defeated)
	touch_controls.action_requested.connect(_on_touch_action_requested)
	player_max_mana = float(GameState.derived_stats()["灵力"])
	player_mana = player_max_mana
	status.text = "本地论剑原型：左侧摇杆/方向键移动；右侧五技能或 J、1–5 手操出招；Q 可无冷却切换已制作专属素材的武器。胜负只在本地结算；联网房间与服务端权威尚未接入。"
	_refresh_hud()


func _process(delta: float) -> void:
	ningxi_cooldown = maxf(0.0, ningxi_cooldown - delta)
	cloud_step_cooldown = maxf(0.0, cloud_step_cooldown - delta)
	guard_cooldown = maxf(0.0, guard_cooldown - delta)
	nourish_cooldown = maxf(0.0, nourish_cooldown - delta)
	guard_time_left = maxf(0.0, guard_time_left - delta)
	player_mana = minf(player_max_mana, player_mana + delta * 2.0)
	_refresh_hud()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_H:
		_return_to_menu()
		return
	if event.keycode >= KEY_1 and event.keycode <= KEY_5:
		_use_action(["attack", "ningxi", "cloud_step", "guard", "nourish"][event.keycode - KEY_1])
		get_viewport().set_input_as_handled()


func _on_touch_action_requested(action_id: String) -> void:
	_use_action(action_id)


func _use_action(action_id: String) -> void:
	if finished:
		return
	match action_id:
		"attack": player.trigger_basic_attack()
		"ningxi": _cast_ningxi_sword_art()
		"cloud_step": _cast_cloud_step()
		"guard": _cast_lan_breath_guard()
		"nourish": _cast_spirit_nourish()


func _on_player_attack_impact(_direction: String) -> void:
	if finished:
		return
	var attack_range := float(_skill(0).get("range", 178.0))
	if player.global_position.distance_to(opponent.global_position) > attack_range:
		status.text = "%s未及对手：贴近后再出招。" % str(_skill(0)["name"])
		return
	var damage := maxi(8, GameState.weapon_basic_damage(5))
	if SKILL_CATALOG.is_talisman_brush_skill_set(GameState.player.equipped_weapon):
		_spawn_brush_talisman(player.global_position + Vector2(0, -46), opponent.global_position + Vector2(0, -56))
	elif SKILL_CATALOG.is_spear_skill_set(GameState.player.equipped_weapon):
		_spawn_spear_thrust(player.global_position + Vector2(0, -42), opponent.global_position + Vector2(0, -54), 5.0)
	elif SKILL_CATALOG.is_bow_skill_set(GameState.player.equipped_weapon):
		_spawn_wind_arrow(player.global_position + Vector2(0, -52), opponent.global_position + Vector2(0, -56))
	elif SKILL_CATALOG.is_dao_skill_set(GameState.player.equipped_weapon):
		_spawn_dao_crescent(player.global_position + Vector2(0, -48), (opponent.global_position - player.global_position).normalized(), 72.0, 7.0)
	elif SKILL_CATALOG.is_halberd_skill_set(GameState.player.equipped_weapon):
		_spawn_halberd_sweep(player.global_position + Vector2(0, -48), (opponent.global_position - player.global_position).normalized(), 96.0, 8.0)
	elif SKILL_CATALOG.is_axe_skill_set(GameState.player.equipped_weapon):
		_spawn_axe_ground_cleave(player.global_position + (opponent.global_position - player.global_position).normalized() * 20.0 + Vector2(0, -38), (opponent.global_position - player.global_position).normalized(), 70.0, 9.0)
	elif SKILL_CATALOG.is_hammer_skill_set(GameState.player.equipped_weapon):
		_spawn_hammer_shockwave(player.global_position + (opponent.global_position - player.global_position).normalized() * 22.0 + Vector2(0, -34), 60.0, 8.0)
	elif SKILL_CATALOG.is_staff_skill_set(GameState.player.equipped_weapon):
		_spawn_staff_whirl(player.global_position + Vector2(0, -44), (opponent.global_position - player.global_position).normalized(), 80.0, 6.0)
	elif SKILL_CATALOG.is_whip_skill_set(GameState.player.equipped_weapon):
		_spawn_whip_lash(player.global_position + Vector2(0, -44), (opponent.global_position - player.global_position).normalized(), 132.0, 5.0)
	elif SKILL_CATALOG.is_crossbow_skill_set(GameState.player.equipped_weapon):
		_spawn_crossbow_bolt(player.global_position + Vector2(0, -50), opponent.global_position + Vector2(0, -56))
	opponent.take_damage(damage)
	status.text = "%s 命中试剑使，造成 %d 点伤害。" % [GameState.player.equipped_weapon, damage]
	_refresh_hud()


func _on_opponent_attack(raw_damage: int) -> void:
	if finished:
		return
	var profile := GameCatalog.weapon_profile_for_item(GameState.player.equipped_weapon)
	var damage := maxi(2, raw_damage - int(profile.get("counter_reduction", 0)))
	var was_guarding := guard_time_left > 0.0
	if was_guarding:
		damage = ceili(float(damage) * 0.45)
		guard_time_left = 0.0
		status.text = "岚息护体抵去了大半反击。"
	player_hp = maxi(0, player_hp - damage)
	if not was_guarding:
		status.text = "试剑使反击命中：%d 点伤害。" % damage
	if player_hp <= 0:
		_finish(false)
	_refresh_hud()


func _on_opponent_defeated() -> void:
	_finish(true)


func _finish(player_won: bool) -> void:
	if finished:
		return
	finished = true
	if player_won:
		GameState.record_opportunity({"region": "yunlan_trial_pavilion", "name": "山门论剑胜利", "kind": "local_pvp_prototype"})
		status.text = "本地论剑胜利。此处不掉落装备、不改变PVP排名；正式PVP结算必须由服务器完成。按 Esc 返回。"
	else:
		status.text = "本地论剑落败。死亡不掉落；按 Esc 返回。"
	_refresh_hud()


func _refresh_hud() -> void:
	player_hp_label.text = "你 · %s　HP %d / 100" % [GameState.player.equipped_weapon, player_hp]
	opponent_hp_label.text = "山门试剑使　HP %d / %d" % [opponent.hp, opponent.max_hp]
	var skills := _skills()
	skill_label.text = "灵力 %.0f / %.0f　%s%s　%s%s　%s%s　%s%s" % [
		player_mana, player_max_mana,
		str(skills[1].name), _cooldown_text(ningxi_cooldown),
		str(skills[2].name), _cooldown_text(cloud_step_cooldown),
		str(skills[3].name), _cooldown_text(guard_cooldown),
		str(skills[4].name), _cooldown_text(nourish_cooldown),
	]


func _cast_ningxi_sword_art() -> void:
	var primary := _skill(1)
	if player.global_position.distance_to(opponent.global_position) > float(primary.get("range", 300.0)):
		status.text = "%s需要在有效距离内锁定对手。" % str(primary["name"])
		return
	if not _try_use_skill(1, ningxi_cooldown):
		return
	ningxi_cooldown = float(primary["cooldown"])
	var facing := (opponent.global_position - player.global_position).normalized()
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
	if umbrella:
		_spawn_umbrella_ward(player.global_position + Vector2(0, -54), facing)
		guard_time_left = maxf(guard_time_left, float(primary.get("guard_seconds", 0.0)))
	elif brush:
		_spawn_brush_talisman(player.global_position + Vector2(0, -54), opponent.global_position + Vector2(0, -56))
	elif spear:
		_spawn_spear_thrust(player.global_position + Vector2(0, -50), opponent.global_position + Vector2(0, -54), 8.0)
	elif bow:
		_spawn_wind_arrow(player.global_position + Vector2(0, -54), opponent.global_position + Vector2(0, -56), 0.34)
	elif dao:
		_spawn_dao_crescent(player.global_position + Vector2(0, -50), facing, 118.0, 11.0)
	elif halberd:
		_spawn_halberd_sweep(player.global_position + Vector2(0, -50), facing, 142.0, 12.0)
	elif axe:
		_spawn_axe_ground_cleave(player.global_position + facing * 30.0 + Vector2(0, -40), facing, 112.0, 13.0)
	elif hammer:
		_spawn_hammer_shockwave(player.global_position + facing * 26.0 + Vector2(0, -36), 104.0, 13.0)
	elif staff:
		_spawn_staff_whirl(player.global_position + Vector2(0, -46), facing, 112.0, 9.0)
	elif whip:
		_spawn_whip_lash(player.global_position + Vector2(0, -46), facing, 170.0, 8.0)
	elif crossbow:
		_spawn_crossbow_bolt(player.global_position + Vector2(0, -52), opponent.global_position + Vector2(0, -56), 0.18)
		_spawn_crossbow_bolt(player.global_position + Vector2(0, -52), opponent.global_position + Vector2(0, -82), 0.23)
		_spawn_crossbow_bolt(player.global_position + Vector2(0, -52), opponent.global_position + Vector2(0, -30), 0.28)
	else:
		_spawn_skill_ripple(player.global_position + Vector2(0, -56), Color(0.46, 0.92, 1.0), 34.0, facing)
	await get_tree().create_timer(0.22).timeout
	if finished or opponent.hp <= 0 or player.global_position.distance_to(opponent.global_position) > float(primary.get("range", 300.0)) + 30.0:
		return
	var damage := GameState.weapon_skill_damage(int(primary.get("damage_base", 20)), float(primary.get("attack_ratio", 0.5)), player_max_mana, float(primary.get("mana_ratio", 30.0)))
	opponent.take_damage(damage)
	status.text = "%s命中试剑使，造成 %d 点灵力伤害。%s" % [str(primary["name"]), damage, "伞阵留下一层短暂护持。" if umbrella else ""]
	_refresh_hud()


func _cast_cloud_step() -> void:
	if not _try_use_skill(2, cloud_step_cooldown):
		return
	cloud_step_cooldown = float(_skill(2)["cooldown"])
	var escape := (player.global_position - opponent.global_position).normalized()
	if escape.length_squared() < 0.001:
		escape = Vector2.DOWN
	player.perform_dash(escape, 176.0)
	_spawn_skill_ripple(player.global_position + Vector2(0, -58), Color(0.70, 0.92, 1.0), 24.0, escape)
	status.text = "云步踏岚而行，迅速拉开距离。"
	_refresh_hud()


func _cast_lan_breath_guard() -> void:
	if not _try_use_skill(3, guard_cooldown):
		return
	guard_cooldown = float(_skill(3)["cooldown"])
	guard_time_left = 4.0
	_spawn_skill_ripple(player.global_position + Vector2(0, -52), Color(0.50, 1.0, 0.82), 46.0, Vector2.UP)
	status.text = "岚息护体展开：下一次受击将大幅减伤。"
	_refresh_hud()


func _cast_spirit_nourish() -> void:
	if not _try_use_skill(4, nourish_cooldown):
		return
	nourish_cooldown = float(_skill(4)["cooldown"])
	player_mana = minf(player_max_mana, player_mana + 46.0)
	_spawn_skill_ripple(player.global_position + Vector2(0, -54), Color(0.82, 0.88, 1.0), 30.0, Vector2.UP)
	status.text = "润灵诀回转经脉，恢复部分灵力。"
	_refresh_hud()


func _try_use_skill(index: int, cooldown: float) -> bool:
	var skill := _skill(index)
	if cooldown > 0.0:
		status.text = "%s 还需冷却 %.1f 秒。" % [skill["name"], cooldown]
		return false
	var cost := float(skill["spirit_cost"])
	if player_mana < cost:
		status.text = "灵力不足，无法施放 %s。" % skill["name"]
		return false
	player_mana -= cost
	return true


func _skill(index: int) -> Dictionary:
	return _skills()[index]

func _skills() -> Array[Dictionary]:
	return SKILL_CATALOG.skills_for_weapon(GameState.player.equipped_weapon)


func _cooldown_text(cooldown: float) -> String:
	return " (%.1fs)" % cooldown if cooldown > 0.0 else ""


func _spawn_skill_ripple(origin: Vector2, tint: Color, radius: float, direction: Vector2) -> void:
	# A procedural ring is intentionally generic: it communicates casting now
	# without borrowing a sword VFX for every weapon family.
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

func _spawn_umbrella_ward(origin: Vector2, direction: Vector2) -> void:
	# This is a defensive canopy, not recolored sword VFX: two offset arcs imply
	# the opened umbrella surface while the actual umbrella sprite rotates with it.
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


func _return_to_menu() -> void:
	GameState.enter_screen(GameState.Screen.PVP)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
