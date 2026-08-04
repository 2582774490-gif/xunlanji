class_name CombatState
extends RefCounted

var player_hp := 100
var enemy_hp := 100
var enemy_name := "水府守卫"
var mode := "副本"
var skill_cooldowns := [0.0, 0.0, 0.0, 0.0, 0.0]
var skill_names := ["踏风", "护体", "引岚", "破势", "微尘"]
var battle_log := "战斗准备完成：J 普攻，数字 1–5 释放技能。"

func begin(next_mode: String, next_enemy_name: String) -> void:
	mode = next_mode
	enemy_name = next_enemy_name
	player_hp = 100
	enemy_hp = 100
	skill_cooldowns = [0.0, 0.0, 0.0, 0.0, 0.0]
	battle_log = "%s开始：对手为%s。" % [mode, enemy_name]

func tick(delta: float) -> void:
	for index in skill_cooldowns.size():
		skill_cooldowns[index] = maxf(0.0, skill_cooldowns[index] - delta)

func normal_attack() -> void:
	if enemy_hp <= 0:
		battle_log = "本场已结束，请返回选择下一场挑战。"
		return
	var profile := _weapon_profile()
	var damage := _player_attack_damage(8 + int(profile.bonus))
	enemy_hp = maxi(0, enemy_hp - damage)
	_counter_attack(maxi(0, 3 - int(profile.counter_reduction)))
	battle_log = "%s·%s 普攻命中，造成 %d 点伤害。%s" % [GameState.player.equipped_weapon, profile.trait, damage, _result_suffix()]

func use_skill(index: int) -> void:
	if index < 0 or index >= skill_cooldowns.size() or enemy_hp <= 0:
		return
	if skill_cooldowns[index] > 0.0:
		battle_log = "%s 冷却中：%.1f 秒" % [skill_names[index], skill_cooldowns[index]]
		return
	var profile := _weapon_profile()
	var damage := _player_attack_damage(12 + index * 4 + int(profile.bonus) + int(profile.skill_bonus))
	enemy_hp = maxi(0, enemy_hp - damage)
	skill_cooldowns[index] = maxf(1.0, 3.0 + index + float(profile.cooldown_delta))
	_counter_attack(maxi(0, 2 + index - int(profile.counter_reduction)))
	battle_log = "%s·%s 施放成功，造成 %d 点伤害。%s" % [GameState.player.equipped_weapon, skill_names[index], damage, _result_suffix()]

func _counter_attack(damage: int) -> void:
	if enemy_hp > 0:
		player_hp = maxi(0, player_hp - damage)

func _player_attack_damage(base_damage: int) -> int:
	var stats: Dictionary = GameState.derived_stats()
	return base_damage + int(int(stats["攻击"]) / 3.0)

func _weapon_profile() -> Dictionary:
	var catalog := preload("res://src/data/game_catalog.gd")
	return catalog.weapon_profile_for_item(GameState.player.equipped_weapon)

func _result_suffix() -> String:
	if enemy_hp <= 0:
		return "对手已败。"
	if player_hp <= 0:
		return "你暂时落败；死亡不掉落。"
	return ""
