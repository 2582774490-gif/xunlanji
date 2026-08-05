class_name SkillCatalog
extends RefCounted

## Combat scenes read this catalog rather than hard-coding labels, costs and
## cooldowns into the UI.  Only weapons with actual runtime assets receive a
## distinct live moveset; unfinished families stay asset-pending.
const SHARED_MOVEMENT_AND_CULTIVATION_SKILLS := [
	{
		"id": "cloud_step",
		"name": "云步",
		"key": "L",
		"spirit_cost": 10,
		"cooldown": 3.0,
		"description": "短距踏岚位移，用于脱离水刃。",
	},
	{
		"id": "lan_breath_guard",
		"name": "岚息护体",
		"key": "I",
		"spirit_cost": 14,
		"cooldown": 7.0,
		"description": "短时护体，减轻下一次伤害。",
	},
	{
		"id": "spirit_nourish",
		"name": "润灵诀",
		"key": "O",
		"spirit_cost": 0,
		"cooldown": 8.0,
		"description": "调息回灵，立即恢复部分灵力。",
	},
]

const QINGHUANG_SWORD_SKILLS := [
	{"id": "qinghuang_sword_strike", "name": "青篁剑击", "key": "J", "spirit_cost": 0, "cooldown": 0.43, "description": "以青篁剑近身斩击。"},
	{"id": "ningxi_sword_art", "name": "凝息剑诀", "key": "K", "spirit_cost": 18, "cooldown": 4.0, "range": 300.0, "damage_base": 20, "attack_ratio": 0.5, "mana_ratio": 30.0, "visual": "sword_wave", "description": "凝岚成刃，斩出一记中距离剑诀。"},
]

const HUIYUN_UMBRELLA_SKILLS := [
	{"id": "huiyun_umbrella_strike", "name": "回云伞击", "key": "J", "spirit_cost": 0, "cooldown": 0.55, "description": "以伞缘横扫并借势卸力。"},
	{"id": "huiyun_umbrella_array", "name": "回云伞阵", "key": "K", "spirit_cost": 16, "cooldown": 4.6, "range": 250.0, "damage_base": 15, "attack_ratio": 0.34, "mana_ratio": 36.0, "guard_seconds": 1.8, "visual": "umbrella_ward", "description": "撑开灵伞形成回云伞阵，近距震退并短暂护身。"},
]

const VERMILION_TALISMAN_BRUSH_SKILLS := [
	{"id": "vermilion_brush_flick", "name": "朱砂符点", "key": "J", "spirit_cost": 0, "cooldown": 0.48, "range": 275.0, "description": "以符笔掷出朱砂灵符，保持中距离牵制。"},
	{"id": "vermilion_binding_talisman", "name": "缚灵朱符", "key": "K", "spirit_cost": 20, "cooldown": 4.3, "range": 360.0, "damage_base": 18, "attack_ratio": 0.44, "mana_ratio": 28.0, "visual": "talisman_burst", "description": "朱砂成符，射出一记中距离缚灵符。"},
]

const LIUYUN_SPEAR_SKILLS := [
	{"id": "liuyun_spear_thrust", "name": "流云枪刺", "key": "J", "spirit_cost": 0, "cooldown": 0.50, "range": 245.0, "description": "长兵前刺，保持比剑更远的安全距离。"},
	{"id": "liuyun_spear_drive", "name": "破雾枪势", "key": "K", "spirit_cost": 17, "cooldown": 4.1, "range": 335.0, "damage_base": 21, "attack_ratio": 0.48, "mana_ratio": 25.0, "visual": "spear_thrust", "description": "凝聚枪势直刺前方，对中距离目标施加贯穿冲击。"},
]

const ZHUFENG_BOW_SKILLS := [
	{"id": "zhufeng_arrow", "name": "逐风箭", "key": "J", "spirit_cost": 0, "cooldown": 0.60, "range": 470.0, "description": "放出灵箭，在远处牵制已经警觉的敌人。"},
	{"id": "zhufeng_piercing_arrow", "name": "逐风贯矢", "key": "K", "spirit_cost": 19, "cooldown": 4.5, "range": 620.0, "damage_base": 19, "attack_ratio": 0.42, "mana_ratio": 30.0, "visual": "wind_arrow", "description": "凝风为矢，射出一支更远的贯穿灵箭。"},
]

const DUANWU_DAO_SKILLS := [
	{"id": "duanwu_dao_cut", "name": "断雾刀斩", "key": "J", "spirit_cost": 0, "cooldown": 0.58, "range": 220.0, "description": "以厚背弧刃近身横斩，伤害高于轻剑但必须贴近目标。"},
	{"id": "duanwu_cleaving_mist", "name": "断雾横斩", "key": "K", "spirit_cost": 24, "cooldown": 4.7, "range": 235.0, "damage_base": 26, "attack_ratio": 0.56, "mana_ratio": 24.0, "visual": "dao_crescent", "description": "蓄入岚息后斩出一轮宽刀弧，只有近身时才能完整命中。"},
]

const XUANYUE_HALBERD_SKILLS := [
	{"id": "xuanyue_hook_cut", "name": "玄月钩斩", "key": "J", "spirit_cost": 0, "cooldown": 0.62, "range": 268.0, "description": "以月刃勾住中距离目标后横拖，兼顾守距与压迫。"},
	{"id": "xuanyue_moon_sweep", "name": "玄月横扫", "key": "K", "spirit_cost": 21, "cooldown": 4.5, "range": 292.0, "damage_base": 24, "attack_ratio": 0.52, "mana_ratio": 26.0, "visual": "halberd_sweep", "description": "岚息贯入戟杆，挥出一轮带钩的半圆戟势，克制试图贴近的敌手。"},
]

const KAISHAN_AXE_SKILLS := [
	{"id": "kaishan_axe_chop", "name": "开山斧劈", "key": "J", "spirit_cost": 0, "cooldown": 0.72, "range": 202.0, "description": "双手蓄力后沉斧重劈，范围短但单次压制力极强。"},
	{"id": "kaishan_earthsplitter", "name": "裂地开山", "key": "K", "spirit_cost": 25, "cooldown": 5.1, "range": 224.0, "damage_base": 29, "attack_ratio": 0.58, "mana_ratio": 22.0, "visual": "axe_ground_cleave", "description": "以斧刃震裂地面，近处目标承受一次厚重的裂地冲击。"},
]

const STARTER_TEST_SKILLS := QINGHUANG_SWORD_SKILLS + SHARED_MOVEMENT_AND_CULTIVATION_SKILLS

static func skills_for_weapon(item_name: String) -> Array[Dictionary]:
	var weapon_skills: Array[Dictionary] = QINGHUANG_SWORD_SKILLS
	if item_name == "回云练气伞":
		weapon_skills = HUIYUN_UMBRELLA_SKILLS
	elif item_name == "朱砂练气符笔":
		weapon_skills = VERMILION_TALISMAN_BRUSH_SKILLS
	elif item_name == "流云练气枪":
		weapon_skills = LIUYUN_SPEAR_SKILLS
	elif item_name == "逐风练气弓":
		weapon_skills = ZHUFENG_BOW_SKILLS
	elif item_name == "断雾练气刀":
		weapon_skills = DUANWU_DAO_SKILLS
	elif item_name == "玄月练气戟":
		weapon_skills = XUANYUE_HALBERD_SKILLS
	elif item_name == "开山练气斧":
		weapon_skills = KAISHAN_AXE_SKILLS
	var result: Array[Dictionary] = []
	for skill in weapon_skills:
		result.append(skill.duplicate(true))
	for skill in SHARED_MOVEMENT_AND_CULTIVATION_SKILLS:
		result.append(skill.duplicate(true))
	return result

static func is_umbrella_skill_set(item_name: String) -> bool:
	return item_name == "回云练气伞"

static func is_talisman_brush_skill_set(item_name: String) -> bool:
	return item_name == "朱砂练气符笔"

static func is_spear_skill_set(item_name: String) -> bool:
	return item_name == "流云练气枪"

static func is_bow_skill_set(item_name: String) -> bool:
	return item_name == "逐风练气弓"

static func is_dao_skill_set(item_name: String) -> bool:
	return item_name == "断雾练气刀"

static func is_halberd_skill_set(item_name: String) -> bool:
	return item_name == "玄月练气戟"

static func is_axe_skill_set(item_name: String) -> bool:
	return item_name == "开山练气斧"
