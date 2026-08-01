class_name WorldCatalog
extends RefCounted

const REALM_ORDER := ["炼气", "筑基", "结丹", "元婴", "化神"]

const REGIONS := [
	{
		"id": "starter_village",
		"name": "新手村与近郊",
		"realm": "炼气",
		"fixed_dungeons": ["教学洞府", "废弃矿脉", "雾溪水府"],
		"purpose": "角色创建、基础宗门接引、首次随机机缘",
	},
	{
		"id": "mist_border",
		"name": "宗门边境与雾原",
		"realm": "筑基 / 结丹",
		"fixed_dungeons": ["雾林妖巢", "沉舟遗府", "封印石窟", "边境秘境"],
		"purpose": "宗门晋升、公开资源竞争与中阶副本",
	},
	{
		"id": "ancient_ridge",
		"name": "险地山脉与古遗址",
		"realm": "元婴 / 化神圆满",
		"fixed_dungeons": ["地火宫", "古战场", "天裂台", "镇妖遗迹", "化神试炼"],
		"purpose": "高阶法宝、势力冲突与终局挑战",
	},
]
