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
	"border_realm": {"name": "边境秘境", "realm": "结丹", "enemy": "越界修士", "reward": "雾原令"},
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
	{"name": "枪", "branches": "长枪、短枪、御枪", "starter": "云纹练气枪", "school": "兵修"},
	{"name": "戟", "branches": "长戟、钩戟、月戟", "starter": "沉岳练气戟", "school": "体修"},
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

const SECTS := [
	{"id": "mist_sword", "name": "雾隐剑宗", "trait": "重视守序、剑阵与护山", "rule": "擅离驻守任务将扣除功勋；背叛山门可能触发限时通缉。", "technique": "三折剑经"},
	{"id": "cloud_market", "name": "云市会", "trait": "重视商路、鉴宝与契约", "rule": "恶意毁约将失去交易权限，并可能被悬赏追讨。", "technique": "镜心守识篇"},
	{"id": "wild_herb", "name": "百草谷", "trait": "重视丹药、采集与救治", "rule": "私占宗门药圃会降低声望；可用贡献修复关系。", "technique": "百草调息录"},
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
