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

const HANYUE_HAMMER_SKILLS := [
	{"id": "hanyue_hammer_smash", "name": "撼岳锤击", "key": "J", "spirit_cost": 0, "cooldown": 0.78, "range": 196.0, "description": "沉锤砸落，攻击节奏最慢，但可在近身形成强烈震荡。"},
	{"id": "hanyue_mountain_shock", "name": "撼岳震环", "key": "K", "spirit_cost": 27, "cooldown": 5.4, "range": 218.0, "damage_base": 30, "attack_ratio": 0.55, "mana_ratio": 24.0, "visual": "hammer_shockwave", "description": "以岚息压入锤面，砸出一圈短距离震环，适合打断贴身围攻。"},
]

const QINGZHU_STAFF_SKILLS := [
	{"id": "qingzhu_staff_sweep", "name": "青竹横扫", "key": "J", "spirit_cost": 0, "cooldown": 0.44, "range": 230.0, "description": "借竹棍回转横扫，出手迅捷，适合持续保持近中距离。"},
	{"id": "qingzhu_whirl_guard", "name": "青竹回风", "key": "K", "spirit_cost": 18, "cooldown": 3.9, "range": 252.0, "damage_base": 20, "attack_ratio": 0.47, "mana_ratio": 28.0, "visual": "staff_whirl", "description": "旋棍引风，连续扫开身前近处目标，攻势轻快而非重击。"},
]

const SUIYING_WHIP_SKILLS := [
	{"id": "suiying_whip_crack", "name": "碎影鞭梢", "key": "J", "spirit_cost": 0, "cooldown": 0.54, "range": 318.0, "description": "挥出弯曲鞭梢，在中距离点出一记迅疾的牵制。"},
	{"id": "suiying_bindback", "name": "碎影回缚", "key": "K", "spirit_cost": 20, "cooldown": 4.4, "range": 348.0, "damage_base": 19, "attack_ratio": 0.46, "mana_ratio": 29.0, "visual": "whip_lash", "description": "岚息沿鞭节疾走，鞭梢弯折回抽，适合压制试图拉开距离的敌手。"},
]

const JIQUE_CROSSBOW_SKILLS := [
	{"id": "jique_bolt", "name": "机阙灵矢", "key": "J", "spirit_cost": 0, "cooldown": 0.48, "range": 410.0, "description": "机关匣弹出短灵矢，射程不及长弓但起射更快。"},
	{"id": "jique_threebolt", "name": "机阙三连", "key": "K", "spirit_cost": 21, "cooldown": 4.2, "range": 480.0, "damage_base": 21, "attack_ratio": 0.45, "mana_ratio": 28.0, "visual": "crossbow_bolt", "description": "拨动机关匣，连续送出三枚练气短矢，强调短促爆发而非弓术蓄势。"},
]

const LIUFENG_FAN_SKILLS := [
	{"id": "liufeng_fan_flick", "name": "流风扇击", "key": "J", "spirit_cost": 0, "cooldown": 0.50, "range": 275.0, "description": "扇面一振，送出短距离风息，攻守节奏轻巧。"},
	{"id": "liufeng_wind_return", "name": "流风回旋", "key": "K", "spirit_cost": 19, "cooldown": 4.1, "range": 310.0, "damage_base": 18, "attack_ratio": 0.44, "mana_ratio": 31.0, "visual": "fan_gust", "description": "以折扇引动岚息，三道回旋风流扫过前方，不以硬碰硬取胜。"},
]

const QINGSHANG_GUQIN_SKILLS := [
	{"id": "qingshang_note", "name": "清商弦音", "key": "J", "spirit_cost": 0, "cooldown": 0.56, "range": 335.0, "description": "拨出一道清音，音波在中距离扩散，不依赖兵刃接触。"},
	{"id": "qingshang_resonance", "name": "清商回鸣", "key": "K", "spirit_cost": 22, "cooldown": 4.7, "range": 382.0, "damage_base": 19, "attack_ratio": 0.43, "mana_ratio": 34.0, "visual": "guqin_note", "description": "连拨三弦，令三圈音波依次前推，以节奏压制远处目标。"},
]

const BIHUANG_XIAO_SKILLS := [
	{"id": "bihuang_breath_note", "name": "碧篁清音", "key": "J", "spirit_cost": 0, "cooldown": 0.52, "range": 360.0, "description": "一息入箫，放出细长音流，在远处牵制目标。"},
	{"id": "bihuang_winding_tone", "name": "碧篁绕音", "key": "K", "spirit_cost": 20, "cooldown": 4.3, "range": 410.0, "damage_base": 18, "attack_ratio": 0.42, "mana_ratio": 33.0, "visual": "xiao_soundstream", "description": "箫音沿岚息回旋向前，形成更长的螺旋音流，擅长远距骚扰。"},
]

const XUANSHUANG_BELL_SKILLS := [
	{"id": "xuanshuang_bell_chime", "name": "玄霜铃音", "key": "J", "spirit_cost": 0, "cooldown": 0.62, "range": 285.0, "description": "轻振摄魂铃，放出一枚八角音印，扰乱中距离目标的步调。"},
	{"id": "xuanshuang_seal_wave", "name": "玄霜镇音", "key": "K", "spirit_cost": 23, "cooldown": 4.9, "range": 338.0, "damage_base": 20, "attack_ratio": 0.40, "mana_ratio": 38.0, "visual": "bell_sonic_seal", "description": "三声镇铃化作层叠八角音印，向前推进，适合稳住近中距离的战局。"},
]

const EIGHTFOLD_ARRAY_DISK_SKILLS := [
	{"id": "eightfold_array_cast", "name": "八方落阵", "key": "J", "spirit_cost": 0, "cooldown": 0.68, "range": 255.0, "description": "将引岚阵盘抛至前方，展开一座短暂的八方阵纹，压迫中距离区域。"},
	{"id": "eightfold_array_lock", "name": "八方锁岚", "key": "K", "spirit_cost": 24, "cooldown": 5.0, "range": 308.0, "damage_base": 21, "attack_ratio": 0.41, "mana_ratio": 37.0, "visual": "array_lattice", "description": "阵盘旋转展开，八条岚纹在落点交错锁合，适合限制前方区域而非贴身斩击。"},
]

const MOXU_PUPPET_SKILLS := [
	{"id": "moxu_puppet_command", "name": "墨枢点杀", "key": "J", "spirit_cost": 0, "cooldown": 0.60, "range": 330.0, "description": "以灵线催动墨枢傀儡突进一击，保留施术者与目标的安全距离。"},
	{"id": "moxu_puppet_chain", "name": "墨枢连机", "key": "K", "spirit_cost": 25, "cooldown": 5.1, "range": 390.0, "damage_base": 22, "attack_ratio": 0.44, "mana_ratio": 35.0, "visual": "puppet_dash", "description": "傀儡由灵线牵引作一次更远的连机突进，擅长打断中距离目标的节奏。"},
]

const QINGLU_CAULDRON_SKILLS := [
	{"id": "qinglu_fire_pour", "name": "青炉丹火", "key": "J", "spirit_cost": 0, "cooldown": 0.66, "range": 250.0, "description": "青炉倾出一缕丹火，稳定灼烧中距离前方目标。"},
	{"id": "qinglu_furnace_echo", "name": "炉火回震", "key": "K", "spirit_cost": 26, "cooldown": 5.2, "range": 300.0, "damage_base": 23, "attack_ratio": 0.43, "mana_ratio": 36.0, "visual": "cauldron_flame", "description": "以岚息催旺炉心，连续喷出更长的丹火余焰，适合封锁正面近中距离。"},
]

const CANGLAN_PEARL_SKILLS := [
	{"id": "canglan_pearl_shot", "name": "沧澜珠击", "key": "J", "spirit_cost": 0, "cooldown": 0.54, "range": 350.0, "description": "引动沧澜灵珠沿水岚曲线射出，适合稳定牵制远处目标。"},
	{"id": "canglan_tide_return", "name": "沧澜回潮", "key": "K", "spirit_cost": 22, "cooldown": 4.6, "range": 425.0, "damage_base": 20, "attack_ratio": 0.40, "mana_ratio": 38.0, "visual": "pearl_tide", "description": "灵珠裹挟回潮水岚飞得更远，在命中处泛起一圈珠潮，不以直线箭矢取胜。"},
]

const ZHENYUE_SEAL_SKILLS := [
	{"id": "zhenyue_seal_stamp", "name": "镇岳落印", "key": "J", "spirit_cost": 0, "cooldown": 0.70, "range": 245.0, "description": "悬印在前方落下，形成一记方正山纹冲击，擅长稳定压迫近中距离。"},
	{"id": "zhenyue_binding_mountain", "name": "镇岳缚灵", "key": "K", "spirit_cost": 25, "cooldown": 5.0, "range": 300.0, "damage_base": 24, "attack_ratio": 0.45, "mana_ratio": 34.0, "visual": "seal_slam", "description": "法印引来更重的岳纹落下，在较远位置形成更大的镇压印痕。"},
]

const HANZHAO_MIRROR_SKILLS := [
	{"id": "hanzhao_mirror_ray", "name": "寒照破妄", "key": "J", "spirit_cost": 0, "cooldown": 0.56, "range": 330.0, "description": "灵镜偏转，放出一束折向的寒照光线，以两段光路远击目标。"},
	{"id": "hanzhao_reflection", "name": "寒照回映", "key": "K", "spirit_cost": 23, "cooldown": 4.8, "range": 400.0, "damage_base": 20, "attack_ratio": 0.41, "mana_ratio": 37.0, "visual": "mirror_ray", "description": "镜面凝出更长的破妄光束，在折返点形成一次更强的回映冲击。"},
]

const FUTU_TOWER_SKILLS := [
	{"id": "futu_tower_press", "name": "浮屠镇妖", "key": "J", "spirit_cost": 0, "cooldown": 0.72, "range": 255.0, "description": "令浮屠塔在前方显出一层塔纹，稳住近中距离的妖煞与敌手。"},
	{"id": "futu_tower_layers", "name": "浮屠三镇", "key": "K", "spirit_cost": 26, "cooldown": 5.3, "range": 312.0, "damage_base": 24, "attack_ratio": 0.44, "mana_ratio": 35.0, "visual": "tower_ward_impact", "description": "三层镇妖塔纹依次投落，在前方形成连续震荡，适合压制一处战场。"},
]

const ZHULAN_WHEEL_SKILLS := [
	{"id": "zhulan_wheel_throw", "name": "逐岚回轮", "key": "J", "spirit_cost": 0, "cooldown": 0.58, "range": 405.0, "description": "掷出逐岚练气轮，轮刃沿风线回旋后折返，适合在远处保持游走节奏。"},
	{"id": "zhulan_riftsplit_return", "name": "裂空回轮", "key": "K", "spirit_cost": 22, "cooldown": 4.5, "range": 475.0, "damage_base": 21, "attack_ratio": 0.45, "mana_ratio": 32.0, "visual": "wheel_return", "description": "以风岚催动轮刃远掷，去程与回程划出相反弧线；核心不在直线射击，而在可读的回旋压制。"},
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
	elif item_name == "撼岳练气锤":
		weapon_skills = HANYUE_HAMMER_SKILLS
	elif item_name == "青竹练气棍":
		weapon_skills = QINGZHU_STAFF_SKILLS
	elif item_name == "碎影练气鞭":
		weapon_skills = SUIYING_WHIP_SKILLS
	elif item_name == "机阙练气弩":
		weapon_skills = JIQUE_CROSSBOW_SKILLS
	elif item_name == "流风练气扇":
		weapon_skills = LIUFENG_FAN_SKILLS
	elif item_name == "清商练气琴":
		weapon_skills = QINGSHANG_GUQIN_SKILLS
	elif item_name == "碧篁练气箫":
		weapon_skills = BIHUANG_XIAO_SKILLS
	elif item_name == "玄霜摄魂铃":
		weapon_skills = XUANSHUANG_BELL_SKILLS
	elif item_name == "八方引岚阵盘":
		weapon_skills = EIGHTFOLD_ARRAY_DISK_SKILLS
	elif item_name == "墨枢练气傀儡":
		weapon_skills = MOXU_PUPPET_SKILLS
	elif item_name == "青炉练气鼎":
		weapon_skills = QINGLU_CAULDRON_SKILLS
	elif item_name == "沧澜引灵珠":
		weapon_skills = CANGLAN_PEARL_SKILLS
	elif item_name == "镇岳缚灵印":
		weapon_skills = ZHENYUE_SEAL_SKILLS
	elif item_name == "寒照破妄镜":
		weapon_skills = HANZHAO_MIRROR_SKILLS
	elif item_name == "浮屠镇妖塔":
		weapon_skills = FUTU_TOWER_SKILLS
	elif item_name == "逐岚练气轮":
		weapon_skills = ZHULAN_WHEEL_SKILLS
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

static func is_hammer_skill_set(item_name: String) -> bool:
	return item_name == "撼岳练气锤"

static func is_staff_skill_set(item_name: String) -> bool:
	return item_name == "青竹练气棍"

static func is_whip_skill_set(item_name: String) -> bool:
	return item_name == "碎影练气鞭"

static func is_crossbow_skill_set(item_name: String) -> bool:
	return item_name == "机阙练气弩"

static func is_fan_skill_set(item_name: String) -> bool:
	return item_name == "流风练气扇"

static func is_guqin_skill_set(item_name: String) -> bool:
	return item_name == "清商练气琴"

static func is_xiao_skill_set(item_name: String) -> bool:
	return item_name == "碧篁练气箫"

static func is_bell_skill_set(item_name: String) -> bool:
	return item_name == "玄霜摄魂铃"

static func is_array_disk_skill_set(item_name: String) -> bool:
	return item_name == "八方引岚阵盘"

static func is_puppet_skill_set(item_name: String) -> bool:
	return item_name == "墨枢练气傀儡"

static func is_cauldron_skill_set(item_name: String) -> bool:
	return item_name == "青炉练气鼎"

static func is_pearl_skill_set(item_name: String) -> bool:
	return item_name == "沧澜引灵珠"

static func is_seal_skill_set(item_name: String) -> bool:
	return item_name == "镇岳缚灵印"

static func is_mirror_skill_set(item_name: String) -> bool:
	return item_name == "寒照破妄镜"

static func is_tower_skill_set(item_name: String) -> bool:
	return item_name == "浮屠镇妖塔"

static func is_wheel_skill_set(item_name: String) -> bool:
	return item_name == "逐岚练气轮"
