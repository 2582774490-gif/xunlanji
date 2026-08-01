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
		"id": "mist_border", "name": "宗门边境与雾原", "realm": "筑基 / 结丹", "unlocked": false,
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
	"mist_forest": {"name": "雾林妖径", "realm": "筑基", "enemy": "雾林妖将", "reward": "灵木心"},
	"sunken_boat": {"name": "沉舷遗府", "realm": "结丹", "enemy": "沉舷残灵", "reward": "古舟残片"},
	"sealed_grotto": {"name": "封印石窟", "realm": "结丹", "enemy": "封印守兽", "reward": "镇石碎片"},
	"border_realm": {"name": "边境秘境", "realm": "结丹", "enemy": "越界修士", "reward": "雾原令"},
	"earth_fire": {"name": "地火窟", "realm": "元婴", "enemy": "地火灵兽", "reward": "赤焰精金"},
	"ancient_battlefield": {"name": "古战场", "realm": "元婴", "enemy": "战场残魂", "reward": "古战印"},
	"sky_rift": {"name": "天隙台", "realm": "化神", "enemy": "裂隙守望者", "reward": "天隙晶"},
	"demon_ruins": {"name": "镇妖遗迹", "realm": "化神", "enemy": "镇妖古灵", "reward": "镇妖符骨"},
	"deity_trial": {"name": "化神试炼", "realm": "化神圆满", "enemy": "试炼化身", "reward": "化神印记"},
}

const WEAPON_FAMILIES := [
	{"name": "剑", "branches": "飞剑、重剑、阵剑", "starter": "练气木剑"},
	{"name": "刀", "branches": "长刀、双刃、灵刃", "starter": "练气短刀"},
	{"name": "枪", "branches": "长枪、战戟、御枪", "starter": "练气长枪"},
	{"name": "扇", "branches": "羽扇、铁扇、风阵扇", "starter": "练气羽扇"},
	{"name": "琴", "branches": "音律、惑心、镇魂", "starter": "练气古琴"},
	{"name": "符", "branches": "雷符、阵符、御符", "starter": "练气符笔"},
	{"name": "傀儡", "branches": "机关、灵兽、阵傀", "starter": "练气机偶"},
	{"name": "鼎", "branches": "丹鼎、器鼎、镇岳鼎", "starter": "练气小鼎"},
]

const SECTS := [
	{"id": "mist_sword", "name": "雾隐剑宗", "trait": "重视守序、剑阵与护山", "rule": "擅离驻守任务将扣除功勋；背叛山门可能触发限时通缉。"},
	{"id": "cloud_market", "name": "云市会", "trait": "重视商路、鉴宝与契约", "rule": "恶意毁约将失去交易权限，并可能被悬赏追讨。"},
	{"id": "wild_herb", "name": "百草谷", "trait": "重视丹药、采集与救治", "rule": "私占宗门药圃会降低声望；可用贡献修复关系。"},
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
