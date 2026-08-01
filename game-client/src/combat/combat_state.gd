class_name CombatState
extends RefCounted

var player_hp := 100
var enemy_hp := 100
var skill_cooldowns := [0.0, 0.0, 0.0, 0.0, 0.0]
var skill_names := ["踏风", "护体", "引岚", "破势", "御器"]
var battle_log := "副本已就绪：J 普攻，数字 1–5 施放技能。"

func reset() -> void:
	player_hp = 100
	enemy_hp = 100
	skill_cooldowns = [0.0, 0.0, 0.0, 0.0, 0.0]
	battle_log = "雾溪水府开启：击败水府守卫。"

func tick(delta: float) -> void:
	for index in skill_cooldowns.size():
		skill_cooldowns[index] = maxf(0.0, skill_cooldowns[index] - delta)

func normal_attack() -> void:
	if enemy_hp <= 0:
		battle_log = "守卫已被击败，等待下一场挑战。"
		return
	enemy_hp = maxi(0, enemy_hp - 8)
	battle_log = "普攻命中，守卫受到 8 点伤害。"

func use_skill(index: int) -> void:
	if index < 0 or index >= skill_cooldowns.size():
		return
	if skill_cooldowns[index] > 0.0:
		battle_log = "%s 冷却中：%.1f 秒" % [skill_names[index], skill_cooldowns[index]]
		return
	if enemy_hp <= 0:
		battle_log = "守卫已被击败，技能不再消耗。"
		return
	var damage := 12 + index * 4
	enemy_hp = maxi(0, enemy_hp - damage)
	skill_cooldowns[index] = 3.0 + index
	battle_log = "%s 施放成功，造成 %d 点伤害。" % [skill_names[index], damage]
