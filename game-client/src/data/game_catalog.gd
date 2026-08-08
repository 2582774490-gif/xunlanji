class_name GameCatalog
extends RefCounted

const REALMS := [
	{"name": "炼气", "minor_stages": ["一层", "二层", "三层", "四层", "五层", "六层", "七层", "八层", "九层", "圆满"]},
	{"name": "筑基", "minor_stages": ["初期", "初期圆满", "中期", "中期圆满", "后期", "后期圆满"]},
	{"name": "结丹", "minor_stages": ["初期", "初期圆满", "中期", "中期圆满", "后期", "后期圆满"]},
	{"name": "元婴", "minor_stages": ["初期", "初期圆满", "中期", "中期圆满", "后期", "后期圆满"]},
	{"name": "化神", "minor_stages": ["初期", "初期圆满", "中期", "中期圆满", "后期", "后期圆满"]},
]

const REGIONS := [
	{
		"id": "starter_village", "name": "云岚外野", "realm": "炼气", "unlocked": true,
		"description": "云岚村服务聚落、雾溪浅岸、云麓疏林与首个实体副本入口。",
		"dungeons": ["mist_stream_palace"],
	},
	{
		"id": "mist_border", "name": "宗门边境与雾原", "realm": "炼气二层 / 筑基", "unlocked": false,
		"description": "宗门争端、雾潮资源与中阶秘境。",
		"dungeons": ["mist_forest", "sunken_boat", "sealed_grotto", "border_realm"],
	},
	{
		"id": "ancient_ridge", "name": "险地山脉与古遗址", "realm": "元婴 / 化神圆满", "unlocked": false,
		"description": "高阶法宝、势力冲突与化神试炼。",
		"dungeons": ["earth_fire", "ancient_battlefield", "sky_rift", "demon_ruins", "deity_trial"],
	},
]

const DUNGEONS := {
	"training_cave": {"name": "引气洞府", "realm": "炼气", "enemy": "洞府灵傀", "reward": "凝气符"},
	"abandoned_mine": {"name": "废弃矿脉", "realm": "炼气", "enemy": "矿脉妖鼠", "reward": "雾溪草"},
	"mist_stream_palace": {"name": "雾溪水府", "realm": "炼气一层", "enemy": "潇潮岚鲨·映潮分身", "reward": "炼气初始护具、岚鲨鳞片与雾潮练气珠"},
	"mist_forest": {"name": "雾林妖径", "realm": "炼气二层", "enemy": "雾林妖将", "reward": "灵木心"},
	"sunken_boat": {"name": "沉舷遗府", "realm": "炼气四层", "enemy": "沉舷残灵·鸣濯", "reward": "沉舟航图残页"},
	"sealed_grotto": {"name": "雾潮石窟", "realm": "炼气五层", "enemy": "灵潮异象", "reward": "雾潮矿芯"},
	"border_realm": {"name": "赤枫古道", "realm": "炼气六层", "enemy": "商路异闻", "reward": "流火矿"},
	"thunder_cliff": {"name": "听雷断崖", "realm": "炼气七层", "enemy": "引雷岩貂", "reward": "雷纹符材"},
	"return_abyss_mist_port": {"name": "归墟雾港", "realm": "炼气八层", "enemy": "潇潮岚鲨（本体）", "reward": "归墟潮砂与稀有水系材料"},
	"abysswatch_terrace": {"name": "临渊台", "realm": "炼气九层", "enemy": "裂风岩隼", "reward": "临渊露"},
	"earth_fire": {"name": "地火窟", "realm": "元婴", "enemy": "地火灵兽", "reward": "赤焰精金"},
	"ancient_battlefield": {"name": "古战场", "realm": "元婴", "enemy": "战场残魂", "reward": "古战印"},
	"sky_rift": {"name": "天隙台", "realm": "化神", "enemy": "裂隙守望者", "reward": "天隙晶"},
	"demon_ruins": {"name": "镇妖遗迹", "realm": "化神", "enemy": "镇妖古灵", "reward": "镇妖符骨"},
	"deity_trial": {"name": "化神试炼", "realm": "化神圆满", "enemy": "试炼化身", "reward": "化神印记"},
}

# 世界内容以传闻、地貌、资源和门派建议引导；它们不是必须按序领取的任务链。
const WORLD_EXPLORATION_POLICY := {
	"main_thread": "微弱主线只解释岚息、旧界裂隙与修行方法；不替代玩家自由探索。",
	"guidance": "门派、功法与灵根只改变推荐方向、线索与效率，不封死其他玩法。",
	"progression": "境界门槛保护区域强度与节奏；同一层可通过副本、采集、机缘、交易或宗门活动成长。",
}

const QI_REFINING_CONTENT := [
	{"layer": 1, "name": "云岚南门与引气洞府", "kind": "引导 / 自由采集", "access": "炼气一层", "lead": "村中长者讲述岚息与基础操作", "reward": "吐纳、灵草与初始武器"},
	{"layer": 2, "name": "雾林妖径", "kind": "固定副本", "access": "炼气二层", "lead": "边境探子柳朔的传闻", "reward": "雾林妖丹、随机装备与雾林材料"},
	{"layer": 3, "name": "雾骨溪", "kind": "开放小地图 / 溪畔机缘", "access": "炼气三层", "lead": "水系功法与游修更容易察觉溪中灵潮", "reward": "雾骨苔、溪心灵晶与随机感悟"},
	{"layer": 4, "name": "沉舟遗府", "kind": "固定副本", "access": "炼气四层", "lead": "云市旧图、器修和阵修可获得不同线索", "reward": "残舟机关材与法宝胚子"},
	{"layer": 5, "name": "雾潮石窟", "kind": "采集区 / 事件洞窟", "access": "炼气五层", "lead": "丹修关注药性，体修可打开塌方支路", "reward": "药材、矿料与异变事件"},
	{"layer": 6, "name": "赤枫古道", "kind": "区域首领 / 护送商路", "access": "炼气六层", "lead": "商会、宗门和散修都能以不同方式参与", "reward": "流火矿、交易线索与武器分支材料"},
	{"layer": 7, "name": "听雷断崖", "kind": "天气机缘 / 试炼", "access": "炼气七层", "lead": "雷灵根和符修更容易识别雷暴窗口", "reward": "雷纹符材、身法残篇"},
	{"layer": 8, "name": "归墟雾港", "kind": "多人资源争夺 / 遗迹", "access": "炼气八层", "lead": "门派声望、拍卖行消息与航线随机出现", "reward": "高阶炼气法宝材料与稀有交易品"},
	{"layer": 9, "name": "临渊台", "kind": "固定试炼 / 突破准备", "access": "炼气九层", "lead": "各派提供不同的筑基建议，但不强制拜入任何宗门", "reward": "筑基丹丹方线索与护脉材料"},
	{"layer": 10, "name": "炼气大圆满", "kind": "自由筹备", "access": "炼气圆满", "lead": "收集丹材、选择冲关时机、交易或自行炼丹", "reward": "筑基资格，不是自动升级"},
]

const WEAPON_FAMILIES := [
	{"name": "剑", "branches": "飞剑、重剑、阵剑", "starter": "青篁练气剑", "school": "剑修"},
	{"name": "刀", "branches": "长刀、双刃、灵刃", "starter": "断雾练气刀", "school": "兵修"},
	{"name": "枪", "branches": "长枪、短枪、御枪", "starter": "流云练气枪", "school": "兵修"},
	{"name": "戟", "branches": "长戟、钩戟、月戟", "starter": "玄月练气戟", "school": "体修"},
	{"name": "斧", "branches": "战斧、双斧、破阵斧", "starter": "开山练气斧", "school": "体修"},
	{"name": "锤", "branches": "重锤、双锤、雷锤", "starter": "撼岳练气锤", "school": "体修"},
	{"name": "棍", "branches": "长棍、短棍、禅杖", "starter": "青竹练气棍", "school": "体修"},
	{"name": "鞭", "branches": "软鞭、骨鞭、雷鞭", "starter": "碎影练气鞭", "school": "兵修"},
	{"name": "弓", "branches": "长弓、短弓、灵弓", "starter": "逐风练气弓", "school": "游修"},
	{"name": "弩", "branches": "连弩、重弩、机关弩", "starter": "机阙练气弩", "school": "机关"},
	{"name": "扇", "branches": "羽扇、铁扇、风阵扇", "starter": "流风练气扇", "school": "风修"},
	{"name": "伞", "branches": "纸伞、骨伞、护阵伞", "starter": "回云练气伞", "school": "防御"},
	{"name": "琴", "branches": "音律、惑心、镇魂", "starter": "清商练气琴", "school": "音律"},
	{"name": "箫", "branches": "御兽、迷阵、清心", "starter": "碧篁练气箫", "school": "音律"},
	{"name": "铃", "branches": "摄魂、警阵、御灵", "starter": "玄霜摄魂铃", "school": "御灵"},
	{"name": "符笔", "branches": "雷符、阵符、御符", "starter": "朱砂练气符笔", "school": "符修"},
	{"name": "阵盘", "branches": "困阵、杀阵、护阵", "starter": "八方引岚阵盘", "school": "阵修"},
	{"name": "傀儡", "branches": "机关、灵兽、阵傀", "starter": "墨枢练气傀儡", "school": "机关"},
	{"name": "鼎", "branches": "丹鼎、器鼎、镇岳鼎", "starter": "青炉练气鼎", "school": "丹器"},
	{"name": "珠", "branches": "御水、护身、聚灵", "starter": "沧澜引灵珠", "school": "水修"},
	{"name": "印", "branches": "镇压、封禁、山岳", "starter": "镇岳缚灵印", "school": "土修"},
	{"name": "镜", "branches": "幻术、映照、破妄", "starter": "寒照破妄镜", "school": "幻修"},
	{"name": "塔", "branches": "镇妖、收纳、护体", "starter": "浮屠镇妖塔", "school": "器修"},
	{"name": "轮", "branches": "风轮、刃轮、御空轮", "starter": "逐岚练气轮", "school": "风修"},
]

# First-launch combat tendencies for every broad weapon family.  These are
# deliberately modest, because detailed movesets, hit effects and weapon-card
# animation will be authored weapon by weapon instead of hidden in huge stats.
const WEAPON_COMBAT_PROFILES := {
	"剑": {"bonus": 2, "counter_reduction": 0, "skill_bonus": 1, "cooldown_delta": -0.2, "trait": "均衡剑势"},
	"刀": {"bonus": 4, "counter_reduction": 0, "skill_bonus": 1, "cooldown_delta": 0.0, "trait": "斩击蓄势"},
	"枪": {"bonus": 3, "counter_reduction": 1, "skill_bonus": 1, "cooldown_delta": 0.0, "trait": "长兵守距"},
	"戟": {"bonus": 4, "counter_reduction": 1, "skill_bonus": 1, "cooldown_delta": 0.1, "trait": "钩斩压制"},
	"斧": {"bonus": 5, "counter_reduction": 0, "skill_bonus": 0, "cooldown_delta": 0.3, "trait": "重劈破势"},
	"锤": {"bonus": 5, "counter_reduction": 1, "skill_bonus": 0, "cooldown_delta": 0.3, "trait": "震击厚重"},
	"棍": {"bonus": 2, "counter_reduction": 2, "skill_bonus": 1, "cooldown_delta": -0.1, "trait": "架势连转"},
	"鞭": {"bonus": 2, "counter_reduction": 0, "skill_bonus": 3, "cooldown_delta": 0.0, "trait": "牵制连击"},
	"弓": {"bonus": 3, "counter_reduction": 2, "skill_bonus": 1, "cooldown_delta": 0.0, "trait": "远射游走"},
	"弩": {"bonus": 5, "counter_reduction": 1, "skill_bonus": 0, "cooldown_delta": 0.4, "trait": "机括爆发"},
	"扇": {"bonus": 1, "counter_reduction": 0, "skill_bonus": 2, "cooldown_delta": -0.4, "trait": "风息回转"},
	"伞": {"bonus": 0, "counter_reduction": 4, "skill_bonus": 1, "cooldown_delta": 0.0, "trait": "护阵卸力"},
	"琴": {"bonus": 1, "counter_reduction": 1, "skill_bonus": 4, "cooldown_delta": 0.0, "trait": "音律共鸣"},
	"箫": {"bonus": 1, "counter_reduction": 1, "skill_bonus": 3, "cooldown_delta": -0.1, "trait": "清心御灵"},
	"铃": {"bonus": 1, "counter_reduction": 2, "skill_bonus": 2, "cooldown_delta": 0.0, "trait": "御灵警阵"},
	"符笔": {"bonus": 2, "counter_reduction": 0, "skill_bonus": 3, "cooldown_delta": -0.1, "trait": "符法连引"},
	"阵盘": {"bonus": 0, "counter_reduction": 3, "skill_bonus": 4, "cooldown_delta": 0.2, "trait": "阵势控场"},
	"傀儡": {"bonus": 3, "counter_reduction": 1, "skill_bonus": 2, "cooldown_delta": 0.1, "trait": "机偶协击"},
	"鼎": {"bonus": 1, "counter_reduction": 2, "skill_bonus": 2, "cooldown_delta": 0.1, "trait": "丹器镇守"},
	"珠": {"bonus": 1, "counter_reduction": 3, "skill_bonus": 2, "cooldown_delta": -0.1, "trait": "御水护身"},
	"印": {"bonus": 4, "counter_reduction": 1, "skill_bonus": 1, "cooldown_delta": 0.1, "trait": "镇压封禁"},
	"镜": {"bonus": 2, "counter_reduction": 2, "skill_bonus": 2, "cooldown_delta": 0.0, "trait": "映照破妄"},
	"塔": {"bonus": 1, "counter_reduction": 4, "skill_bonus": 1, "cooldown_delta": 0.2, "trait": "镇守收纳"},
	"轮": {"bonus": 3, "counter_reduction": 1, "skill_bonus": 2, "cooldown_delta": -0.3, "trait": "御风回旋"},
}

static func weapon_profile_for_item(item_name: String) -> Dictionary:
	for family in WEAPON_FAMILIES:
		if item_name == str(family.starter):
			return WEAPON_COMBAT_PROFILES.get(str(family.name), {}).duplicate(true)
	return {"bonus": 0, "counter_reduction": 0, "skill_bonus": 0, "cooldown_delta": 0.0, "trait": "未定器型"}


static func weapon_family_for_item(item_name: String) -> Dictionary:
	for family in WEAPON_FAMILIES:
		if item_name == str(family.starter):
			return family.duplicate(true)
	return {}

# A combat profile describes balance; a runtime profile describes presentation.
# Keeping these separate prevents a defensive weapon from inheriting sword art
# simply because both happen to be equippable.
const WEAPON_RUNTIME_PROFILES := {
	"青篁练气剑": {
		"motion": "hand_swing",
		"asset": "res://assets/art/weapons/qinghuang_qi_sword/processed_alpha/qinghuang_qi_sword_v01_alpha.png",
		"attack_direction": "south",
		"attack_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f6_alpha.png",
		],
		"effect_policy": "compact_cyan_white_slash_only",
	},
	"回云练气伞": {"motion": "defense_umbrella", "asset": "res://assets/art/weapons/huiyun_qi_umbrella/processed_alpha/huiyun_qi_umbrella_v01_alpha.png"},
	"朱砂练气符笔": {"motion": "rune_brush", "asset": "res://assets/art/weapons/vermilion_qi_talisman_brush/processed_alpha/vermilion_qi_talisman_brush_v01_alpha.png"},
	"流云练气枪": {"motion": "long_spear", "asset": "res://assets/art/weapons/liuyun_qi_spear/processed_alpha/liuyun_qi_spear_v01_alpha.png"},
	"逐风练气弓": {"motion": "wind_bow", "asset": "res://assets/art/weapons/zhufeng_qi_bow/processed_alpha/zhufeng_qi_bow_v01_alpha.png"},
	"断雾练气刀": {"motion": "mist_dao", "asset": "res://assets/art/weapons/duanwu_qi_dao/processed_alpha/duanwu_qi_dao_v01_alpha.png"},
	"玄月练气戟": {"motion": "moon_halberd", "asset": "res://assets/art/weapons/xuanyue_qi_ji/processed_alpha/xuanyue_qi_ji_v01_alpha.png"},
	"开山练气斧": {"motion": "mountain_axe", "asset": "res://assets/art/weapons/kaishan_qi_axe/processed_alpha/kaishan_qi_axe_v01_alpha.png"},
	"撼岳练气锤": {"motion": "mountain_hammer", "asset": "res://assets/art/weapons/hanyue_qi_hammer/processed_alpha/hanyue_qi_hammer_v01_alpha.png"},
	"青竹练气棍": {"motion": "bamboo_staff", "asset": "res://assets/art/weapons/qingzhu_qi_staff/processed_alpha/qingzhu_qi_staff_v01_alpha.png"},
	"碎影练气鞭": {"motion": "shadow_whip", "asset": "res://assets/art/weapons/suiying_qi_whip/processed_alpha/suiying_qi_whip_v01_alpha.png"},
	"机阙练气弩": {"motion": "jique_crossbow", "asset": "res://assets/art/weapons/jique_qi_crossbow/processed_alpha/jique_qi_crossbow_v01_alpha.png"},
	"流风练气扇": {"motion": "flowing_fan", "asset": "res://assets/art/weapons/liufeng_qi_fan/processed_alpha/liufeng_qi_fan_v01_alpha.png"},
	"清商练气琴": {"motion": "qingshang_guqin", "asset": "res://assets/art/weapons/qingshang_qi_guqin/processed_alpha/qingshang_qi_guqin_v01_alpha.png"},
	"碧篁练气箫": {"motion": "bihuang_xiao", "asset": "res://assets/art/weapons/bihuang_qi_xiao/processed_alpha/bihuang_qi_xiao_v01_alpha.png"},
	"玄霜摄魂铃": {"motion": "xuanshuang_bell", "asset": "res://assets/art/weapons/xuanshuang_soul_bell/processed_alpha/xuanshuang_soul_bell_v01_alpha.png"},
	"八方引岚阵盘": {"motion": "eightfold_array_disk", "asset": "res://assets/art/weapons/eightfold_wind_array_disk/processed_alpha/eightfold_wind_array_disk_v01_alpha.png"},
	"墨枢练气傀儡": {"motion": "moxu_puppet", "asset": "res://assets/art/weapons/moxu_qi_puppet/processed_alpha/moxu_qi_puppet_v01_alpha.png"},
	"青炉练气鼎": {"motion": "qinglu_cauldron", "asset": "res://assets/art/weapons/qinglu_qi_cauldron/processed_alpha/qinglu_qi_cauldron_v01_alpha.png"},
	"沧澜引灵珠": {"motion": "canglan_pearl", "asset": "res://assets/art/weapons/canglan_spirit_pearl/processed_alpha/canglan_spirit_pearl_v01_alpha.png"},
	"镇岳缚灵印": {"motion": "zhenyue_seal", "asset": "res://assets/art/weapons/zhenyue_spirit_seal/processed_alpha/zhenyue_spirit_seal_v01_alpha.png"},
	"寒照破妄镜": {"motion": "hanzhao_mirror", "asset": "res://assets/art/weapons/hanzhao_truth_mirror/processed_alpha/hanzhao_truth_mirror_v01_alpha.png"},
	"浮屠镇妖塔": {"motion": "futu_tower", "asset": "res://assets/art/weapons/futu_demon_tower/processed_alpha/futu_demon_tower_v01_alpha.png"},
	"逐岚练气轮": {"motion": "zhulan_wheel", "asset": "res://assets/art/weapons/zhulan_rift_wheel/processed_alpha/zhulan_rift_wheel_v01_alpha.png"},
}

static func weapon_runtime_profile_for_item(item_name: String) -> Dictionary:
	return WEAPON_RUNTIME_PROFILES.get(item_name, {}).duplicate(true)


static func weapon_card_profile_for_item(item_name: String) -> Dictionary:
	var family: Dictionary = weapon_family_for_item(item_name)
	var runtime: Dictionary = weapon_runtime_profile_for_item(item_name)
	if family.is_empty() or runtime.is_empty():
		return {}
	var balance: Dictionary = weapon_profile_for_item(item_name)
	return {
		"runtime_asset": str(runtime.get("asset", "")),
		"quality": "炼气试用器",
		"trait": "%s｜%s｜分支：%s｜动作：%s" % [str(balance.get("trait", "未定器型")), str(family.get("school", "散修")), str(family.get("branches", "待扩展")), str(runtime.get("motion", "待制作"))],
	}

const SPIRIT_ROOTS := [
	{"name": "金灵根", "affinity": "锋锐、破甲、器炼"},
	{"name": "木灵根", "affinity": "生长、疗愈、灵植"},
	{"name": "水灵根", "affinity": "柔化、御水、恢复"},
	{"name": "火灵根", "affinity": "爆发、炼丹、炼器"},
	{"name": "土灵根", "affinity": "防御、镇压、阵基"},
	{"name": "风灵根", "affinity": "位移、连击、御空"},
	{"name": "雷灵根", "affinity": "迅击、破邪、天劫"},
	{"name": "冰灵根", "affinity": "减速、控制、凝形"},
	{"name": "雾灵根", "affinity": "隐匿、感知、岚潮共鸣"},
]

const PHYSIQUES := [
	{"name": "岚息体", "trait": "对区域岚潮更敏锐，提升机缘线索可见性"},
	{"name": "玄岳骨", "trait": "护体与震退更稳，适合重兵与镇压法门"},
	{"name": "流泉脉", "trait": "灵力回复平稳，适合御水与疗愈法门"},
	{"name": "赤阳髓", "trait": "火系功法爆发更高，但修炼消耗更快"},
	{"name": "青木灵胎", "trait": "灵植与丹药效果更佳"},
	{"name": "听雷窍", "trait": "对雷系节奏技和预警事件更敏感"},
	{"name": "镜心魂", "trait": "幻术、心神防御与鉴别能力更强"},
	{"name": "御灵纹", "trait": "灵兽、傀儡与器灵互动更顺畅"},
]

const CULTIVATION_SCHOOLS := [
	{"faction": "五行正修", "techniques": ["金阙破锋诀", "青木回生篇", "玄水引潮经", "赤焰炼息法", "厚土镇元诀"]},
	{"faction": "岚潮一脉", "techniques": ["云岚吐纳诀", "雾行隐踪篇", "听潮观息法"]},
	{"faction": "剑与兵修", "techniques": ["三折剑经", "沉锋养势诀", "百兵淬体法"]},
	{"faction": "符阵机关", "techniques": ["朱砂引灵书", "四隅阵解", "机枢御偶篇"]},
	{"faction": "丹器百工", "techniques": ["百草调息篇", "炉火化元法", "器纹初解"]},
	{"faction": "御兽音律", "techniques": ["灵契共鸣篇", "清商安魂曲", "驭风游身诀"]},
	{"faction": "雷冰异修", "techniques": ["惊雷转息法", "寒照凝形诀", "镜心守识篇"]},
]

# Every line is playable by every spirit root. Matching a root/physique gives
# a modest efficiency bonus rather than closing the other routes.
const TECHNIQUE_AFFINITIES := {
	"金阙破锋诀": {"root": "金灵根", "physique": "玄岳髓", "label": "金系破锋"},
	"青木回生篇": {"root": "木灵根", "physique": "青木灵胎", "label": "木系回生"},
	"玄水引潮经": {"root": "水灵根", "physique": "流泉脉", "label": "水系引潮"},
	"赤焰炼息法": {"root": "火灵根", "physique": "赤阳髓", "label": "火系炼息"},
	"厚土镇元诀": {"root": "土灵根", "physique": "玄岳髓", "label": "土系镇元"},
	"云岚吐纳诀": {"root": "雾灵根", "physique": "岚息体", "label": "岚潮吐纳"},
	"雾行隐踪篇": {"root": "雾灵根", "physique": "岚息体", "label": "雾行身法"},
	"听潮观息法": {"root": "水灵根", "physique": "岚息体", "label": "潮息感知"},
	"三折剑经": {"root": "金灵根", "physique": "玄岳髓", "label": "剑修养势"},
	"沉锋养势诀": {"root": "土灵根", "physique": "玄岳髓", "label": "兵修蓄势"},
	"百兵淬体法": {"root": "金灵根", "physique": "玄岳髓", "label": "百兵淬体"},
	"朱砂引灵书": {"root": "火灵根", "physique": "镜心魂", "label": "符法引灵"},
	"四隅阵解": {"root": "土灵根", "physique": "镜心魂", "label": "阵法推演"},
	"机枢御偶篇": {"root": "金灵根", "physique": "御灵纹", "label": "机关御偶"},
	"百草调息篇": {"root": "木灵根", "physique": "青木灵胎", "label": "丹修调息"},
	"炉火化元法": {"root": "火灵根", "physique": "赤阳髓", "label": "炉火化元"},
	"器纹初解": {"root": "金灵根", "physique": "御灵纹", "label": "器纹炼器"},
	"灵契共鸣篇": {"root": "风灵根", "physique": "御灵纹", "label": "御兽灵契"},
	"清商安魂曲": {"root": "水灵根", "physique": "镜心魂", "label": "音律安魂"},
	"驭风游身诀": {"root": "风灵根", "physique": "御灵纹", "label": "驭风游身"},
	"惊雷转息法": {"root": "雷灵根", "physique": "听雷窍", "label": "雷法转息"},
	"寒照凝形诀": {"root": "冰灵根", "physique": "流泉脉", "label": "冰法凝形"},
	"镜心守识篇": {"root": "冰灵根", "physique": "镜心魂", "label": "心神守识"},
}

static func technique_affinity_for(path_name: String) -> Dictionary:
	return TECHNIQUE_AFFINITIES.get(path_name, {"root": "", "physique": "", "label": "自由修行"}).duplicate(true)


# Technique art is separate from the rules data. A manual image may enter the
# codex only after its own source and alpha asset have been reviewed; no other
# technique is allowed to borrow this cover as a stand-in.
const TECHNIQUE_ART_PROFILES := {
	"云岚吐纳诀": {
		"card_asset": "res://assets/art/techniques/cloud_mist_breathing_manual/processed_alpha/cloud_mist_breathing_manual_v01_alpha.png",
		"caption": "云岚吐纳诀秘卷｜岚潮一脉的基础吐纳法门。",
	},
	"朱砂引灵书": {
		"card_asset": "res://assets/art/techniques/vermilion_spirit_guidance_manual/processed_alpha/vermilion_spirit_guidance_manual_v01_alpha.png",
		"caption": "朱砂引灵书秘卷｜以朱砂、符纸与灵机牵引为根本的符修入门法门。",
	},
	"驭风游身诀": {
		"card_asset": "res://assets/art/techniques/wind_wandering_body_manual/processed_alpha/wind_wandering_body_manual_v01_alpha.png",
		"caption": "驭风游身诀秘卷｜以风息调身、穿行与闪避为核心的游身法门。",
	},
	"三折剑经": {
		"card_asset": "res://assets/art/techniques/threefold_sword_sutra/processed_alpha/threefold_sword_sutra_v01_alpha.png",
		"caption": "三折剑经秘卷｜雾隐剑宗的入门剑修法门，以折势、续势与归势三段养成剑势。",
	},
	"百草调息篇": {
		"card_asset": "res://assets/art/techniques/hundred_herbs_breath_regulation_manual/processed_alpha/hundred_herbs_breath_regulation_manual_v01_alpha.png",
		"caption": "百草调息篇秘卷——以药植吐纳、药性相济与温养经脉为根本的丹修入门法门；提升炼丹稳定性。",
	},
	"炉火化元法": {
		"card_asset": "res://assets/art/techniques/furnace_fire_transforming_origin_manual/processed_alpha/furnace_fire_transforming_origin_manual_v01_alpha.png",
		"caption": "炉火化元法秘卷——以炉温、火候与元息循环调和药材；炼丹稳定性略增，并为炼器路线预留火候理解。",
	},
}

static func technique_art_profile_for_name(path_name: String) -> Dictionary:
	return TECHNIQUE_ART_PROFILES.get(path_name, {}).duplicate(true)

# 时装只描述外观与资源状态，绝不能在这里附带战斗或经济数值。
# 概念图通过审核后，仍需补齐男女同骨架的八方向待机、行走与攻击帧，
# 才能写入 runtime_asset 并进入地图角色层。
const COSTUME_PROFILES := {
	"liulan_wayfarer": {
		"name": "流岚游衣",
		"gender": "男",
		"rarity": "典藏外观",
		"description": "云白、青碧与银纹交叠的游修外袍，短披与束腕让长途探索时仍保有清晰轮廓。",
		"concept_asset": "res://assets/art/costumes/liulan_wayfarer/concept/liulan_wayfarer_concept_v01.png",
		"idle_south_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_v01_alpha.png",
		"idle_south_west_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_west_v01_alpha.png",
		"idle_west_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_west_v01_alpha.png",
		"idle_north_west_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_west_v01_alpha.png",
		"idle_north_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_v01_alpha.png",
		"idle_north_east_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_east_v01_alpha.png",
		"idle_east_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_east_v01_alpha.png",
		"idle_south_east_asset": "res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_east_v01_alpha.png",
		"walk_south_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f6_alpha.png",
		],
		"walk_south_west_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f6_alpha.png",
		],
		"walk_west_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f6_alpha.png",
		],
		"walk_north_west_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f6_alpha.png",
		],
		"walk_north_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f6_alpha.png",
		],
		"walk_north_east_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f6_alpha.png",
		],
		"walk_east_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f6_alpha.png",
		],
		"walk_south_east_frames": [
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f1_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f2_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f3_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f4_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f5_alpha.png",
			"res://assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f6_alpha.png",
		],
		"runtime_state": "ready",
		"animation_requirement": "已接入男体大世界角色层：八方向待机、八方向各六帧行走及青篁练气剑南向攻击均使用本时装的独立透明源图。其余武器攻击方向仍待补齐。",
	},
	"jiangyun_rainbow": {
		"name": "绛云霓裳",
		"gender": "女",
		"rarity": "典藏外观",
		"description": "绛红、黛紫与云白纱袖层叠的游修霓裳，收束腰封与轻甲护腕让飘逸和行动感并存。",
		"concept_asset": "res://assets/art/costumes/jiangyun_rainbow/concept/jiangyun_rainbow_concept_v01.png",
		"idle_south_candidate_asset": "res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_south_v01_alpha.png",
		"idle_south_west_candidate_asset": "res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_south_west_v01_alpha.png",
		"idle_west_candidate_asset": "res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_west_v01_alpha.png",
		"idle_north_candidate_asset": "res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_north_v01_alpha.png",
		"walk_south_candidate_frames": [
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f1_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f2_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f3_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f4_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f5_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f6_alpha.png",
		],
		"walk_south_west_candidate_frames": [
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f1_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f2_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f3_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f4_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f5_alpha.png",
			"res://assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f6_alpha.png",
		],
		"runtime_state": "concept_only",
		"animation_requirement": "已完成女体南、南西、西、北向待机候选，南与南西各六帧行走候选；仍需补齐其余方向行走、八方向待机、独立武器攻击及发梢与广袖遮挡测试。",
	},
}

static func costume_profile_for_id(costume_id: String) -> Dictionary:
	return COSTUME_PROFILES.get(costume_id, {}).duplicate(true)

const SECTS := [
	{"id": "mist_sword", "name": "雾隐剑宗", "trait": "重视守序、剑阵与护山", "rule": "擅离驻守任务将扣除功勋；内门后叛离山门会触发通缉。", "technique": "三折剑经", "exit_wanted_rank": 1, "exit_penalty": "雾隐剑宗已记录你的离宗，山道与驻地附近可能出现追查。"},
	{"id": "cloud_market", "name": "云市会", "trait": "重视商路、鉴宝与契约", "rule": "恶意毁约将失去交易权限，并可能被悬赏追讨。", "technique": "镜心守识篇", "exit_wanted_rank": 3, "exit_penalty": "云市会冻结了你的会内契约信用；正常离会不构成通缉。"},
	{"id": "wild_herb", "name": "百草谷", "trait": "重视丹药、采集与救治", "rule": "私占宗门药圃会降低声望；可用贡献修复关系。", "technique": "百草调息篇", "liaison": "百草谷执事·白蘅驻守雾泽药庐，负责药性记录、药圃规约与内门传功登记。", "exit_wanted_rank": 99, "exit_penalty": "百草谷保留了离谷记录，但不会因正常离开而通缉。"},
]

const SECT_RANKS := [
	{"name": "外门弟子", "contribution": 0, "realm_index": 0, "minor_stage": 1},
	{"name": "内门弟子", "contribution": 80, "realm_index": 0, "minor_stage": 6},
	{"name": "执事", "contribution": 320, "realm_index": 1, "minor_stage": 3},
	{"name": "长老", "contribution": 900, "realm_index": 2, "minor_stage": 3},
	{"name": "副宗主", "contribution": 2400, "realm_index": 3, "minor_stage": 3},
]

# 宗门事务不是强制任务链：它们是山门对真实区域的当期需求。
# 玩家可绕开、换宗或做散修；完成后只留下自己的社会经历和贡献。
const SECT_SERVICES := [
	{"id": "mist_sword_oldroad_patrol", "sect_id": "mist_sword", "name": "旧商道巡守结报", "regions": ["yunlan_outskirts"], "region_name": "云岚外野·旧商道", "item": "雾潮晶簇", "contribution": 18, "cooldown": 3600, "brief": "雾隐剑宗要核验旧商道的雾潮晶簇，以判断巡守阵眼是否还能维持。"},
	{"id": "mist_sword_pass_watch", "sect_id": "mist_sword", "name": "雾关阵眼校验", "regions": ["mist_border"], "region_name": "雾潮边境", "item": "雾潮矿芯", "contribution": 24, "cooldown": 5400, "brief": "边关水雾反常，剑宗向路过的门人征集矿芯校验阵眼。"},
	{"id": "cloud_market_route_ledger", "sect_id": "cloud_market", "name": "旧道货签核验", "regions": ["yunlan_outskirts"], "region_name": "云岚外野·旧商道", "item": "旧道货签", "contribution": 16, "cooldown": 3600, "brief": "云市会不问你从何处来，只需一枚可靠货签来修正商路风险。"},
	{"id": "cloud_market_relic_appraisal", "sect_id": "cloud_market", "name": "古脊遗物鉴别", "regions": ["ancient_ridge"], "region_name": "古脊岭", "item": "古战印", "contribution": 26, "cooldown": 5400, "brief": "古脊岭遗物涌入市面，云市会收取古战印建立公开的鉴别记录。"},
	{"id": "wild_herb_medicine_sample", "sect_id": "wild_herb", "name": "雾溪药性留样", "regions": ["yunlan_outskirts"], "region_name": "云岚外野·雾溪", "item": "雾溪草", "contribution": 14, "cooldown": 3000, "brief": "百草谷收集雨后雾溪草的药性差异；不是上缴药圃，只是补足公共药录。"},
	{"id": "wild_herb_marsh_remedy", "sect_id": "wild_herb", "name": "边泽药包转存", "regions": ["mist_border"], "region_name": "雾潮边境", "item": "雾溪药", "contribution": 20, "cooldown": 4200, "brief": "湿雾季将至，百草谷请门人将可用药材转入边泽药庐。"},
]

const NPCS := [
	{"name": "沈衍", "role": "南门引路人", "place": "云岚村南门"},
	{"name": "陆青禾", "role": "药材商", "place": "云岚村"},
	{"name": "温行客", "role": "行脚鉴宝人", "place": "雾溪渡口"},
	{"name": "祝铁山", "role": "炼器师", "place": "村北工坊"},
	{"name": "白蘅", "role": "百草谷执事", "place": "雾泽药庐"},
	{"name": "宁远", "role": "宗门接引使", "place": "云岚村"},
	{"name": "洛清", "role": "云市掌柜", "place": "云岚村市集"},
	{"name": "柳朔", "role": "边境探子", "place": "雾潮边境·残关"},
]

const NPC_CARD_PROFILES := {
	"陆青禾": {
		"card_asset": "res://assets/art/npcs/lu_qinghe/processed_alpha/lu_qinghe_card_v01_alpha.png",
		"faction": "云岚村 · 药圃行",
		"relationship": "初识 · 可交易",
		"service": "出售雾溪药；它与雾溪灵草共同构成凝息丹的首个可自由取得配方。",
		"lead": "她会留意雨后溪路的药草变化，并可能提供雾泽灵草与百草谷的传闻。",
	},
	"祝铁山": {
		"card_asset": "res://assets/art/npcs/zhu_tieshan/processed_alpha/zhu_tieshan_card_v01_alpha.png",
		"faction": "云岚村 · 村北工坊",
		"relationship": "初识 · 可委托强化",
		"service": "说明首发装备强化所需的雾潮晶簇、流火矿与境界门槛；已强化的装备状态会随交易转移。",
		"lead": "他会收集古战残魂与地火材料，并可引出炼器、武器大分支和地火洞的传闻。",
	},
	"沈衍": {
		"card_asset": "res://assets/art/npcs/shen_yan/processed_alpha/shen_yan_card_v01_alpha.png",
		"lived_contexts": [
			{"id": "south_gate_water_trace", "when_world_mark": "water", "title": "沈衍 · 溪路印证", "description": "你已亲自见过水路留下的岚潮痕迹。沈衍不再把南门异动只当作雾重，而承认旧石阶下的回响或许值得被不同的人分别记下。"},
		],
		"story_reflections": {
			"tide_listener": {"title": "沈衍 · 溪雾之问", "description": "沈衍只说南门雾潮比往年早起。你在他停顿时听见溪水逆着石阶轻响，像山脚下还有一段不属于今日的潮线。"},
			"herb_reader": {"title": "沈衍 · 药性之问", "description": "沈衍提醒雨后灵草药性易变。你却注意到他指的是一片尚未开花的坡地：岚潮最早改变的也许不是灵草，而是它们等待发芽的时序。"},
			"forge_watcher": {"title": "沈衍 · 石阶之问", "description": "沈衍把南门湿滑石阶当作寻常雾重。你摸到阶缝里细微的反向纹路，像一座早已废弃的引灵阵仍在地下缓慢回火。"},
			"storm_walker": {"title": "沈衍 · 风口之问", "description": "沈衍要你留意山风与雾线的变化。你发现南门风总在同一刻折向东侧溪谷，仿佛避开某条没有写入地形图的旧道。"},
			"mirror_keeper": {"title": "沈衍 · 门影之问", "description": "沈衍说门楼的长影只是晨雾折光。你没有争辩，只记下影子偶尔比真实门柱多出半截，且始终朝着村外延伸。"},
		},
		"faction": "云岚村 · 南门引路人",
		"relationship": "初识 · 世界引导",
		"service": "说明岚息、灵根与吐纳的基础关系；与他交谈会记录“认识岚息”，但不会强制接取任务、发放境界经验或限制探索。",
		"lead": "他留意南门外雾潮的涨落，提醒新人从雾溪药草、散修传闻与可见地标开始自行探索；后续可牵出各宗门的入门去向。",
	},
	"温行客": {
		"card_asset": "res://assets/art/npcs/wen_xingke/processed_alpha/wen_xingke_card_v01_alpha.png",
		"faction": "云市会 · 雾溪渡口",
		"relationship": "初识 · 可鉴宝",
		"service": "说明雾港货物、法宝与材料的保护价区间；他的货单提供雾潮矿芯与潮息玉佩，并指向归墟雾港的拍卖行。",
		"lead": "他会根据潮期收集残舟货签与古物传闻；这些线索可引向雾港航路、沉舷遗府和后续玩家交易。",
	},
	"白蘅": {
		"card_asset": "res://assets/art/npcs/bai_heng/processed_alpha/bai_heng_card_v01_alpha.png",
		"faction": "百草谷 · 雾泽药庐",
		"relationship": "初识 · 丹修传功",
		"service": "说明药性承受、灵植分区与百草谷门规；玩家自由加入百草谷并晋升内门后，会登记《百草调息篇》，但不会强制切换主修。",
		"lead": "她会记录雨后灵泉、雾泽灵草与妖丹成熟期，后续可延展为药圃事件、高阶丹方和采集生态线索。",
	},
	"宁远": {
		"card_asset": "res://assets/art/npcs/ning_yuan/processed_alpha/ning_yuan_card_v01_alpha.png",
		"faction": "云岚村 · 宗门接引台",
		"relationship": "初识 · 宗门引导",
		"service": "说明雾隐剑宗、云市会与百草谷的加入方式、贡献晋升与离宗后果；只开启可选的“选择道路”引导，不替玩家指定宗门或功法。",
		"lead": "他保管各宗门的入门帖与门规摘要。商路契约、药圃规约和剑宗驻守都能从此分流为不同的自由探索方向。",
	},
	"洛清": {
		"card_asset": "res://assets/art/npcs/luo_qing/processed_alpha/luo_qing_card_v01_alpha.png",
		"lived_contexts": [
			{"id": "trade_ledger", "when_any_thread": ["market_first_consignment", "market_first_purchase"], "title": "洛清 · 账页印证", "description": "你已经让一件物品真正进入交换。洛清因此愿意给你看一页潮后账簿：价格变化并不证明谁说得对，却能证明岚潮正在改变人们如何生活。"},
		],
		"story_reflections": {
			"tide_listener": {"title": "洛清 · 潮价之问", "description": "洛清只把雨后涨价归为港路受阻。你对照她的货签，却发现同一批盐袋在潮前已先沾上不属于此地的水息。"},
			"herb_reader": {"title": "洛清 · 药箱之问", "description": "洛清留意到商队药箱里的干草总比车轮先返潮。她把这当作仓储损耗；你却怀疑雾潮正沿着商路改写草木的干湿次序。"},
			"forge_watcher": {"title": "洛清 · 货铃之问", "description": "洛清说旧铜货铃近来常在无风时发响，只怕车夫惊马。你听见的节律却和矿脉回鸣相合，像有一道看不见的旧路在试探货队。"},
			"storm_walker": {"title": "洛清 · 车辙之问", "description": "洛清把偏离半里的车辙归为山口乱风。你沿着裂坡看去，发现每次偏移都绕开同一块从未记入商图的灰白界石。"},
			"mirror_keeper": {"title": "洛清 · 空车之问", "description": "洛清不愿把失踪车队说成邪祟，只说账簿里偶尔会多出一趟无人签收的货。你把那页没有影子的车印夹进游历簿，暂不替它命名。"},
		},
		"faction": "云市会 · 云岚村市集",
		"relationship": "初识 · 可交易",
		"service": "负责云岚村市集的本地货单、玩家上架、5% 手续费与价格保护范围；不出售数值特权，也不会收取玩家私有物的绑定限制。",
		"lead": "她会记录商路上的材料波动与远港消息，可把自由交易引向温行客的鉴宝货单、归墟雾港拍卖行和后续契约纠纷。",
	},
	"柳朔": {
		"card_asset": "res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png",
		"lived_contexts": [
			{"id": "mist_crystal", "when_item": "雾潮晶簇", "title": "柳朔 · 晶簇印证", "description": "你带着亲手取得的雾潮晶簇回到残关。柳朔承认晶簇的稳定感不像自然矿物，却仍不同意贸然把它称作灾兆；边地的人先要考虑如何活过下一次潮期。"},
		],
		"story_reflections": {
			"tide_listener": {"title": "柳朔 · 听潮之问", "description": "柳朔听你分辨潮声后，提起残关外有一段水位总比雾期晚退半刻。他把它当作巡路经验；你却听出像有另一片水域隔着旧界回应。"},
			"herb_reader": {"title": "柳朔 · 草木之问", "description": "柳朔说雾林里有些草总在潮退后才开花。他只担心药农误入湿地；你记下的却是生长时序被雾潮轻轻拨乱。"},
			"forge_watcher": {"title": "柳朔 · 矿砂之问", "description": "柳朔把冷矿砂里的余温归为旧炉渣。你在他掌中看见的，却是已经熄灭的火候仍被某种回流留住。"},
			"storm_walker": {"title": "柳朔 · 逆风之问", "description": "柳朔提醒残关风向会把人带离正路。你沿他所指的山口望去，发现逆风并非偶然，而是在刻意遮掩一段旧界折线。"},
			"mirror_keeper": {"title": "柳朔 · 关外之问", "description": "柳朔说自己在潮镜里见过没有影子的行人，只当是边境人疲乏后的幻觉。你没有急着反驳，只把那道朝海岸走去的倒影记进游历簿。"},
		},
		"faction": "雾潮边境 · 巡路散修",
		"relationship": "初识 · 边境传闻",
		"service": "他不派发日常任务；只会把雾林、晶簇与潮期的现场判断告诉实际走到残关的修士。",
		"lead": "柳朔认为雾潮涨退并非单一妖物所为。持有晶簇、走过雾林或见过旧关车辙后，再与他交谈会让边境的风险与人间生计有不同解释。",
	},
}

static func npc_card_profile_for_name(npc_name: String) -> Dictionary:
	return NPC_CARD_PROFILES.get(npc_name, {}).duplicate(true)

## These entries describe *ecological roles*, not a requirement for every
## visit to show every creature.  The regional population director selects a
## sparse, sector-bound subset from its own anchors.  Keeping the card here
## gives a wandering entity a stable identity without turning the open world
## into a uniform spawn table.
const ECOLOGY_CARD_PROFILES := {
	"fog_channel_beast": {
		"name": "雾渠獭妖", "category": "妖兽 · 水道领地", "region": "雾潮边境 · 雾渠水道",
		"card_asset": "res://assets/art/characters/mist_channel_otter_spirit/processed_alpha/mist_channel_otter_spirit_v01_alpha.png",
		"appearance": "只栖在雾渠的浅滩、倒木与鱼群回游处；离开水线后不会继续刷新。",
		"interaction": "可绕行、观察或击退；受惊后会沿水道退去。",
		"reward": "雾獭灵皮，可制作炼气期初始护腕与护具内衬。",
	},
	"mist_ore_rogue": {
		"name": "采雾散修", "category": "散修 · 矿脉支路", "region": "雾潮边境 · 雾潮矿脉",
		"card_asset": "res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png",
		"appearance": "只会在有雾潮晶簇的废矿支路短暂停留，寻找安全矿脉。",
		"interaction": "交换矿脉传闻，不隶属任何宗门，也不强迫接取任务。",
		"reward": "可能提供雾潮晶簇、矿脉方位或低阶炼器线索。",
	},
	"checkpoint_watcher": {
		"name": "边关巡修", "category": "游历修士 · 关隘", "region": "雾潮边境 · 旧关卡",
		"card_asset": "res://assets/art/npcs/guide_shen/processed_alpha/guide_shen_idle_south_v01_alpha.png",
		"appearance": "只在旧关卡、山道岔口和雾潮预警石附近巡望。",
		"interaction": "提供边境风险与固定副本的境界提醒，不会替玩家锁定路线。",
		"reward": "边境传闻、雾林妖径的可选入口线索。",
	},
	"wetland_mist_herb": {
		"name": "雾泽灵草丛", "category": "灵植 · 湿地采集", "region": "雾潮边境 · 雾泽药湿地",
		"card_asset": "res://assets/art/resources/mist_stream_spirit_herb/processed_alpha/mist_stream_spirit_herb_v01_alpha.png",
		"appearance": "只生在浅水与石滩交界，受潮期、采集与刷新冷却共同限制。",
		"interaction": "采集后进入生态冷却，不会被全地图平均补点。",
		"reward": "雾泽灵草，可入凝息丹、归元丹及百草谷药圃委托。",
	},
	"wetland_herbalist": {
		"name": "晾药散修", "category": "散修 · 湿地药性", "region": "雾潮边境 · 雾泽药湿地",
		"card_asset": "res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png",
		"appearance": "只在药架、避雨棚与干燥石台附近整理湿地药材。",
		"interaction": "可询问药性承受、丹修路线与雨后灵草的观察方法。",
		"reward": "药性线索与后续丹方材料提示。",
	},
	"highland_mist_stonebud": {
		"name": "雾岭石芽", "category": "灵材 · 高地矿植", "region": "雾潮边境 · 雾岭高地",
		"card_asset": "res://assets/art/resources/mist_tide_crystal_cluster/processed_alpha/mist_tide_crystal_cluster_v01_alpha.png",
		"appearance": "仅在雾岩台地与山路相接的裂隙生长；高地的大部分区域应保持安静。",
		"interaction": "采集后需等待地气回流，适合作为探索途中偶遇的低频资源。",
		"reward": "雾岭石芽，可供低阶护具、阵盘与炼器支线使用。",
	},
	"earthfire_hound": {
		"name": "地火岩獒", "category": "妖兽 · 地火裂谷", "region": "古脊岭 · 地火裂谷",
		"card_asset": "res://assets/art/characters/earthfire_spirit_beast/processed_alpha/earthfire_spirit_beast_v01_alpha.png",
		"appearance": "守在有热气与矿脉余火的裂谷边缘，不会出现在古战场或商路。",
		"interaction": "可观察其领地，或以相应境界挑战。",
		"reward": "地火兽核，用于炼器、火系法门材料和中期法宝分支。",
	},
	"battlefield_remnant": {
		"name": "战场残魂", "category": "灵体 · 古战场", "region": "古脊岭 · 古战场",
		"card_asset": "res://assets/art/characters/boss_sunken_vessel_wraith/processed_alpha/boss_sunken_vessel_wraith_v01_alpha.png",
		"appearance": "受残阵与兵器意志束缚，只在古战场的残垣、纪念台附近游荡。",
		"interaction": "接触前可先感知阵势；并非任何野外道路都会出现的普通敌人。",
		"reward": "残魂兵符，可延展为阵修、傀儡与古战遗物路线。",
	},
	"relic_seeker": {
		"name": "守碑散修", "category": "散修 · 遗迹观察", "region": "古脊岭 · 古战场",
		"card_asset": "res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png",
		"appearance": "在碑林外围记录阵势，不会深入残魂最密集的区域。",
		"interaction": "交换古战判断与安全路线，不属于强制主线 NPC。",
		"reward": "残阵军策、遗迹机缘与高阶副本前置知识。",
	},
	"port_merchant": {
		"name": "泊位行商", "category": "商人 · 港口泊位", "region": "归墟雾港 · 泊位商路",
		"card_asset": "res://assets/art/npcs/marketkeeper_luo/processed_alpha/marketkeeper_luo_idle_v01_alpha.png",
		"appearance": "随靠港货船与潮期出现，只在码头、泊位和货栈之间活动。",
		"interaction": "提供商路传闻与交易方向；价格保护、手续费仍由市场系统统一约束。",
		"reward": "港口材料、外海副本与拍卖行线索。",
	},
	"tide_chart_rogue": {
		"name": "测潮散修", "category": "散修 · 潮汐观测", "region": "归墟雾港 · 潮位石",
		"card_asset": "res://assets/art/npcs/guide_shen/processed_alpha/guide_shen_idle_south_v01_alpha.png",
		"appearance": "只在潮位石、堤岸和可安全观海的位置测绘水势。",
		"interaction": "可询问外海流向与潮洞可进入时段。",
		"reward": "潮期信息、沉舷遗府与海蚀洞的探索线索。",
	},
	"wreck_shallows_beast": {
		"name": "潇潮岚鲨", "category": "稀有水妖首领 · 沉桩浅滩", "region": "归墟雾港 · 沉桩浅滩",
		"card_asset": "res://assets/art/characters/boss_xiaochao_lansha/slices/boss_xiaochao_lansha_front_v01.png",
		"appearance": "女性拟人水妖，以岚潮凝成鲛尾与水袖；只在沉船木桩、月潮与浅滩灵息交汇时现身。",
		"interaction": "稀有首领，非普通均匀刷新的野怪；可先观察、回避，或在准备后挑战。",
		"reward": "岚鲨鳞片、潮息玉与炼气期初始护具材料；首领掉落遵循次数、生态冷却与战利品保护。",
	},
	"shipyard_rogue": {
		"name": "修舟散修", "category": "散修 · 船坞工棚", "region": "归墟雾港 · 船坞巷",
		"card_asset": "res://assets/art/npcs/marketkeeper_luo/processed_alpha/marketkeeper_luo_idle_v01_alpha.png",
		"appearance": "只在修舟棚、旧桅杆和工具堆旁停留。",
		"interaction": "交换航具、法宝防潮处理与外海航路消息。",
		"reward": "修舟材料与港口生活类机缘。",
	},
	"sea_cave_beast": {
		"name": "潮穴鳞獭", "category": "妖兽 · 海蚀洞口", "region": "归墟雾港 · 海蚀洞外",
		"card_asset": "res://assets/art/characters/mist_channel_otter_spirit/processed_alpha/mist_channel_otter_spirit_v01_alpha.png",
		"appearance": "沿潮穴洞口与退潮水洼觅食，不会进入港口商区。",
		"interaction": "洞口领地敌对，可绕开或以合适境界挑战。",
		"reward": "潮穴鳞皮，用于低阶防潮护具与水系炼器材料。",
	},
	"thunder_crag_beast": {
		"name": "引雷岩貂", "category": "妖兽 · 听雷崖", "region": "古脊岭 · 听雷崖",
		"card_asset": "res://assets/art/characters/earthfire_spirit_beast/processed_alpha/earthfire_spirit_beast_v01_alpha.png",
		"appearance": "只在雷后温热岩缝出没，借残余雷息淬炼皮毛。",
		"interaction": "低频崖缘生态位，遇见与否取决于天气、时段与区域刷新。",
		"reward": "引雷短毛，可用于符修与雷系炼器支线。",
	},
	"storm_talisman_rogue": {
		"name": "候雷符修", "category": "散修 · 风雨避所", "region": "古脊岭 · 风雨避所",
		"card_asset": "res://assets/art/npcs/border_scout_liushuo/processed_alpha/border_scout_liushuo_idle_v01_alpha.png",
		"appearance": "会在暴雨前后停在有屋檐与避雷石的山道，而不是孤立山巅。",
		"interaction": "可交换符箓、天气与雷崖机缘的观察方法。",
		"reward": "雷行符材和听雷崖副本提示。",
	},
	"terrace_wind_eagle": {
		"name": "裂风岩隼", "category": "妖兽 · 临渊崖缘", "region": "临渊观台 · 迎风断崖",
		"card_asset": "res://assets/art/characters/boss_mist_forest_general/processed_alpha/boss_mist_forest_general_v01_alpha.png",
		"appearance": "只盘旋在迎风断崖与高处石巢，避开观台与安全山道。",
		"interaction": "保持距离即可观察；接近石巢才可能触发领地战。",
		"reward": "裂风翎羽，可制身法类符箓、披风与飞行法宝素材。",
	},
	"terrace_observer": {
		"name": "守台散修", "category": "散修 · 观想台", "region": "临渊观台 · 护脉石台",
		"card_asset": "res://assets/art/npcs/guide_shen/processed_alpha/guide_shen_idle_south_v01_alpha.png",
		"appearance": "停留在观想台与护脉石旁，不会把临渊区域填满 NPC。",
		"interaction": "解释冲击筑基前的准备，但不让玩家一次互动跳过长期修行。",
		"reward": "护脉材料、筑基准备与观想地点线索。",
	},
}

const ECOLOGY_CARD_ORDER := [
	"fog_channel_beast", "mist_ore_rogue", "checkpoint_watcher", "wetland_mist_herb", "wetland_herbalist", "highland_mist_stonebud",
	"earthfire_hound", "battlefield_remnant", "relic_seeker", "thunder_crag_beast", "storm_talisman_rogue",
	"port_merchant", "tide_chart_rogue", "wreck_shallows_beast", "shipyard_rogue", "sea_cave_beast",
	"terrace_wind_eagle", "terrace_observer",
]

static func ecology_card_profile_for_id(profile_id: String) -> Dictionary:
	return ECOLOGY_CARD_PROFILES.get(profile_id, {}).duplicate(true)

const OPPORTUNITIES := [
	{"title": "雾潮散开", "text": "山道雾气短暂散去，发现一株雾溪草。", "item": "雾溪草", "cultivation": 8},
	{"title": "旧碑回响", "text": "残碑与当前炼气法门共鸣，获得一段可参悟的行气法。", "item": "残碑拓片", "cultivation": 16},
	{"title": "行商求助", "text": "护送行商避开妖兽，得到少量灵石。", "item": "行商谢礼", "cultivation": 5},
	{"title": "雨后灵泉", "text": "雨后低洼处凝成灵泉，短暂吐纳有所收获。", "item": "灵泉露", "cultivation": 12},
]

const MARKET_LISTINGS := [
	{"name": "凝气符", "type": "材料", "price": 18},
	{"name": "雾溪草", "type": "灵植", "price": 12},
	{"name": "纳灵玉佩", "type": "法宝", "price": 60},
	{"name": "练气羽扇", "type": "武器", "price": 45},
]

# Artifacts have their own runtime slot.  Their later active skills, cooldowns
# and upgrade trees are authored per artifact; this initial profile establishes
# the data boundary so an equipped pendant is never baked into the body art.
const ARTIFACT_PROFILES := {
	"纳灵玉佩": {
		"slot": "护身法宝",
		"quality": "凡品",
		"trait": "缓慢聚拢游离岚息，适合炼气期稳定吐纳。",
		"mana_regen_bonus": 0.45,
		"water_damage_reduction": 0.0,
		"render_scale": 0.075,
		"runtime_asset": "res://assets/art/artifacts/naling_jade_pendant/processed_alpha/naling_jade_pendant_v01_alpha.png",
	},
	"潮息玉佩": {
		"slot": "护身法宝",
		"quality": "凡品",
		"trait": "以潮息温养经脉，灵力恢复略高于纳灵玉佩；不提供元素减伤或PVP数值压制。",
		"mana_regen_bonus": 0.70,
		"water_damage_reduction": 0.0,
		"render_scale": 0.068,
		"runtime_asset": "res://assets/art/artifacts/tide_breath_jade_pendant/processed_alpha/tide_breath_jade_pendant_v01_alpha.png",
	},
	"雾潮练气珠": {
		"slot": "御水法宝",
		"quality": "灵品",
		"trait": "以潮息凝出一层水幕；水系伤害降低 35%，只在水系首领与水域危险中生效。",
		"mana_regen_bonus": 0.0,
		"water_damage_reduction": 0.35,
		"render_scale": 0.112,
		"runtime_asset": "res://assets/art/artifacts/mist_tide_qi_pearl/processed_alpha/mist_tide_qi_pearl_v01_alpha.png",
	},
	"玄土练气印": {
		"slot": "护身法宝",
		"quality": "灵品",
		"trait": "以山纹镇住来势；土岩伤害降低 32%，只在土岩首领与地形危险中生效。",
		"mana_regen_bonus": 0.0,
		"earth_damage_reduction": 0.32,
		"render_scale": 0.118,
		"runtime_asset": "res://assets/art/artifacts/earthseal_qi_stamp/processed_alpha/earthseal_qi_stamp_v01_alpha.png",
	},
	"八角练气阵盘": {
		"slot": "阵势法宝",
		"quality": "灵品",
		"trait": "展开护阵分散常规冲击；中性 PVE 伤害降低 16%，不参与 PVP 减伤。",
		"mana_regen_bonus": 0.0,
		"neutral_damage_reduction": 0.16,
		"render_scale": 0.116,
		"runtime_asset": "res://assets/art/artifacts/eightfold_qi_array/processed_alpha/eightfold_qi_array_v01_alpha.png",
	},
	"妖将护符": {
		"slot": "妖猎护符",
		"quality": "灵品",
		"trait": "以雾兽纹镇定胆气；对妖类首领的 PVE 伤害降低 12%，不参与 PVP 减伤。",
		"mana_regen_bonus": 0.0,
		"demon_damage_reduction": 0.12,
		"render_scale": 0.068,
		"runtime_asset": "res://assets/art/artifacts/mist_general_talisman/processed_alpha/mist_general_talisman_v01_alpha.png",
	},
	"雾港引潮盘": {
		"slot": "航图法宝",
		"quality": "灵品",
		"trait": "以古舵与潮眼校正岚潮航线；水系 PVE 伤害降低 16%，灵力恢复 +0.30，不参与 PVP 减伤。",
		"mana_regen_bonus": 0.30,
		"water_damage_reduction": 0.16,
		"render_scale": 0.096,
		"runtime_asset": "res://assets/art/artifacts/mist_harbor_tide_guide_disk/processed_alpha/mist_harbor_tide_guide_disk_v01_alpha.png",
	},
}

# A reveal artifact does not provide combat reduction. Its exploration route is
# attached per map, beginning with the Mist Tide Stone Grotto.
const ZHAOYING_QI_MIRROR_PROFILE := {
	"slot": "鉴别法宝",
	"quality": "灵品",
	"trait": "映出被幻雾遮掩的局部机缘；当前可在雾潮石窟揭示镜影裂隙。",
	"mana_regen_bonus": 0.0,
	"reveal_radius": 220.0,
	"render_scale": 0.094,
	"runtime_asset": "res://assets/art/artifacts/zhaoying_qi_mirror/processed_alpha/zhaoying_qi_mirror_v01_alpha.png",
}

# Pill data is separate from breakthrough material checks.  Lower-realm pills
# can still be crafted and traded by high-realm players, but their medicinal
# effect does not remain useful after the stated realm range.
const PILL_PROFILES := {
	"灵泉露": {"name": "灵泉露", "cultivation": 15, "burden": 2, "max_realm": 0, "max_stage": 9, "kind": "灵液"},
	"凝息丹": {"name": "凝息丹", "cultivation": 15, "burden": 5, "max_realm": 0, "max_stage": 3, "kind": "炼气丹"},
	"养元丹": {"name": "养元丹", "cultivation": 22, "burden": 7, "max_realm": 0, "max_stage": 6, "kind": "炼气丹"},
	"归元丹": {"name": "归元丹", "cultivation": 30, "burden": 9, "max_realm": 0, "max_stage": 9, "kind": "炼气丹"},
}

# Runtime art is deliberately independent from pill balance data. This lets a
# future pill add a unique card without accidentally inheriting another item.
const PILL_ART_PROFILES := {
	"灵泉露": {
		"card_asset": "res://assets/art/pills/spirit_spring_dew/processed_alpha/spirit_spring_dew_v01_alpha.png",
		"caption": "炼气期可饮用的温和灵液；修为 +15，药负 +2。多见于雨后低洼灵泉与溪谷雾地。",
	},
	"凝息丹": {
		"card_asset": "res://assets/art/pills/condensing_breath_pill/processed_alpha/condensing_breath_pill_v01_alpha.png",
		"caption": "炼气一至三层的温和调息丹；修为 +15，药负 +5。",
	},
	"养元丹": {
		"card_asset": "res://assets/art/pills/nourishing_origin_pill/processed_alpha/nourishing_origin_pill_v01_alpha.png",
		"caption": "炼气中期的养元灵丹；修为 +22，药负 +7。以雾泽灵草、雾林材料与凝气符材炼成。",
	},
	"归元丹": {
		"card_asset": "res://assets/art/pills/returning_origin_pill/processed_alpha/returning_origin_pill_v01_alpha.png",
		"caption": "炼气七至九层的归元灵丹；修为 +30，药负 +9。以妖丹、灵草与临渊露调和而成。",
	},
}

const ALCHEMY_RECIPES := {
	"ningxi": {
		"name": "凝息丹", "output": "凝息丹", "materials": ["雾溪灵草", "雾溪药"],
		"base_success": 0.74, "note": "炼气初期调息丹，药性温和。",
	},
	"yangyuan": {
		"name": "养元丹", "output": "养元丹", "materials": ["雾泽灵草", "雾林材料", "凝气符材"],
		"base_success": 0.68, "note": "炼气中期养元丹，药性比凝息丹更重。",
	},
	"guiyuan": {
		"name": "归元丹", "output": "归元丹", "materials": ["雾林妖丹", "雾泽灵草", "临渊露"],
		"base_success": 0.61, "note": "炼气后期归元丹，需谨慎安排当天药负。",
	},
}

static func artifact_profile_for_item(item_name: String) -> Dictionary:
	if item_name == "照影练气镜":
		return ZHAOYING_QI_MIRROR_PROFILE.duplicate(true)
	return ARTIFACT_PROFILES.get(item_name, {}).duplicate(true)


static func pill_art_profile_for_item(item_name: String) -> Dictionary:
	return PILL_ART_PROFILES.get(item_name, {}).duplicate(true)


# Armor is an independent body slot. Body protection is deliberately mild PVE
# mitigation; artifacts remain elemental/utility choices and PVP does not call
# this protection path.
const ARMOR_PROFILES := {
	"雾纹护腕": {
		"slot": "护腕",
		"quality": "凡品",
		"trait": "以雾纹分散近身冲击，PVE伤害降低 8%；不参与PVP减伤。",
		"pve_damage_reduction": 0.08,
		"render_scale": 0.045,
		"runtime_asset": "res://assets/art/armor/mist_pattern_bracers/processed_alpha/mist_pattern_bracers_v01_alpha.png",
	},
	"雾林轻甲": {
		"slot": "胸甲",
		"quality": "灵品",
		"trait": "雾林行装以层叠织甲与护肩分散雾刃冲击，PVE伤害降低 11%；不参与PVP减伤。",
		"pve_damage_reduction": 0.11,
		"render_scale": 0.055,
		"runtime_asset": "res://assets/art/armor/mist_forest_light_armor/processed_alpha/mist_forest_light_armor_v01_alpha.png",
	},
	"沉雾舟纹袍": {
		"slot": "胸甲",
		"quality": "灵品",
		"trait": "沉舷遗府打捞出的舟纹胸甲；常规 PVE 伤害降低 4%，水系 PVE 伤害额外降低 10%，不参与 PVP 减伤。",
		"pve_damage_reduction": 0.04,
		"water_damage_reduction": 0.10,
		"render_scale": 0.090,
		"runtime_asset": "res://assets/art/armor/sunken_mist_vessel_robe/processed_alpha/sunken_mist_vessel_robe_v01_alpha.png",
	},
}


# Feet are independent from bracers/body armor so the player can eventually
# wear both. The prototype starts with a modest exploration-only speed bonus.
const FOOTWEAR_PROFILES := {
	"水府灵靴": {
		"slot": "足部",
		"quality": "凡品",
		"trait": "水纹护靴，浅水探索时步伐更稳；大世界移动速度 +18。",
		"move_speed_bonus": 18.0,
		"render_scale": 0.035,
		"runtime_asset": "res://assets/art/armor/water_palace_spirit_boots/processed_alpha/water_palace_spirit_boots_v01_alpha.png",
	},
}


static func armor_profile_for_item(item_name: String) -> Dictionary:
	return ARMOR_PROFILES.get(item_name, {}).duplicate(true)


static func footwear_profile_for_item(item_name: String) -> Dictionary:
	return FOOTWEAR_PROFILES.get(item_name, {}).duplicate(true)
