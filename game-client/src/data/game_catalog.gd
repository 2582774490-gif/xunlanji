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
		"id": "starter_village", "name": "云岚村与近郊", "realm": "炼气", "unlocked": true,
		"description": "新手村、基础采集、宗门接引与可解释的初始机缘。",
		"dungeons": ["training_cave", "abandoned_mine", "mist_stream_palace"],
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
	"mist_stream_palace": {"name": "雾溪水府", "realm": "炼气", "enemy": "水府守卫", "reward": "纳灵玉佩"},
	"mist_forest": {"name": "雾林妖径", "realm": "炼气二层", "enemy": "雾林妖将", "reward": "灵木心"},
	"sunken_boat": {"name": "沉舷遗府", "realm": "炼气四层", "enemy": "沉舷残灵·鸣濯", "reward": "沉舟航图残页"},
	"sealed_grotto": {"name": "雾潮石窟", "realm": "炼气五层", "enemy": "灵潮异象", "reward": "雾潮矿芯"},
	"border_realm": {"name": "赤枫古道", "realm": "炼气六层", "enemy": "商路异闻", "reward": "流火矿"},
	"thunder_cliff": {"name": "听雷断崖", "realm": "炼气七层", "enemy": "引雷岩貂", "reward": "雷纹符材"},
	"return_abyss_mist_port": {"name": "归墟雾港", "realm": "炼气八层", "enemy": "沉桩水魇", "reward": "归墟潮砂"},
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
	{"name": "刀", "branches": "长刀、双刃、灵刃", "starter": "赤纹练气刀", "school": "兵修"},
	{"name": "枪", "branches": "长枪、短枪、御枪", "starter": "流云练气枪", "school": "兵修"},
	{"name": "戟", "branches": "长戟、钩戟、月戟", "starter": "玄月练气戟", "school": "体修"},
	{"name": "斧", "branches": "战斧、双斧、破阵斧", "starter": "开山练气斧", "school": "体修"},
	{"name": "锤", "branches": "重锤、双锤、雷锤", "starter": "镇石练气锤", "school": "体修"},
	{"name": "棍", "branches": "长棍、短棍、禅杖", "starter": "青铜练气棍", "school": "体修"},
	{"name": "鞭", "branches": "软鞭、骨鞭、雷鞭", "starter": "流火练气鞭", "school": "兵修"},
	{"name": "弓", "branches": "长弓、短弓、灵弓", "starter": "逐风练气弓", "school": "游修"},
	{"name": "弩", "branches": "连弩、重弩、机关弩", "starter": "机括练气弩", "school": "机关"},
	{"name": "扇", "branches": "羽扇、铁扇、风阵扇", "starter": "雾羽练气扇", "school": "风修"},
	{"name": "伞", "branches": "纸伞、骨伞、护阵伞", "starter": "回云练气伞", "school": "防御"},
	{"name": "琴", "branches": "音律、惑心、镇魂", "starter": "清商练气琴", "school": "音律"},
	{"name": "箫", "branches": "御兽、迷阵、清心", "starter": "碧篁练气箫", "school": "音律"},
	{"name": "铃", "branches": "摄魂、警阵、御灵", "starter": "悬月练气铃", "school": "御灵"},
	{"name": "符笔", "branches": "雷符、阵符、御符", "starter": "朱砂练气符笔", "school": "符修"},
	{"name": "阵盘", "branches": "困阵、杀阵、护阵", "starter": "八角练气阵盘", "school": "阵修"},
	{"name": "傀儡", "branches": "机关、灵兽、阵傀", "starter": "木甲练气机偶", "school": "机关"},
	{"name": "鼎", "branches": "丹鼎、器鼎、镇岳鼎", "starter": "青炉练气鼎", "school": "丹器"},
	{"name": "珠", "branches": "御水、护身、聚灵", "starter": "雾潮练气珠", "school": "水修"},
	{"name": "印", "branches": "镇压、封禁、山岳", "starter": "玄土练气印", "school": "土修"},
	{"name": "镜", "branches": "幻术、映照、破妄", "starter": "照影练气镜", "school": "幻修"},
	{"name": "塔", "branches": "镇妖、收纳、护体", "starter": "浮屠练气塔", "school": "器修"},
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

# A combat profile describes balance; a runtime profile describes presentation.
# Keeping these separate prevents a defensive weapon from inheriting sword art
# simply because both happen to be equippable.
const WEAPON_RUNTIME_PROFILES := {
	"青篁练气剑": {"motion": "hand_swing", "asset": "res://assets/art/weapons/qinghuang_qi_sword/processed_alpha/qinghuang_qi_sword_v01_alpha.png"},
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
}

static func weapon_runtime_profile_for_item(item_name: String) -> Dictionary:
	return WEAPON_RUNTIME_PROFILES.get(item_name, {}).duplicate(true)

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
	{"faction": "丹器百工", "techniques": ["百草调息录", "炉火化元法", "器纹初解"]},
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
	"百草调息录": {"root": "木灵根", "physique": "青木灵胎", "label": "丹修调息"},
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
}

static func technique_art_profile_for_name(path_name: String) -> Dictionary:
	return TECHNIQUE_ART_PROFILES.get(path_name, {}).duplicate(true)

const SECTS := [
	{"id": "mist_sword", "name": "雾隐剑宗", "trait": "重视守序、剑阵与护山", "rule": "擅离驻守任务将扣除功勋；内门后叛离山门会触发通缉。", "technique": "三折剑经", "exit_wanted_rank": 1, "exit_penalty": "雾隐剑宗已记录你的离宗，山道与驻地附近可能出现追查。"},
	{"id": "cloud_market", "name": "云市会", "trait": "重视商路、鉴宝与契约", "rule": "恶意毁约将失去交易权限，并可能被悬赏追讨。", "technique": "镜心守识篇", "exit_wanted_rank": 3, "exit_penalty": "云市会冻结了你的会内契约信用；正常离会不构成通缉。"},
	{"id": "wild_herb", "name": "百草谷", "trait": "重视丹药、采集与救治", "rule": "私占宗门药圃会降低声望；可用贡献修复关系。", "technique": "百草调息录", "exit_wanted_rank": 99, "exit_penalty": "百草谷保留了离谷记录，但不会因正常离开而通缉。"},
]

const SECT_RANKS := [
	{"name": "外门弟子", "contribution": 0, "realm_index": 0, "minor_stage": 1},
	{"name": "内门弟子", "contribution": 80, "realm_index": 0, "minor_stage": 6},
	{"name": "执事", "contribution": 320, "realm_index": 1, "minor_stage": 3},
	{"name": "长老", "contribution": 900, "realm_index": 2, "minor_stage": 3},
	{"name": "副宗主", "contribution": 2400, "realm_index": 3, "minor_stage": 3},
]

const NPCS := [
	{"name": "沈砚舟", "role": "宗门接引使", "place": "云岚村"},
	{"name": "陆青禾", "role": "药材商", "place": "云岚村"},
	{"name": "温行客", "role": "行脚鉴宝人", "place": "雾溪渡口"},
	{"name": "祝铁山", "role": "炼器师", "place": "村北工坊"},
]

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
