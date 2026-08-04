class_name SkillCatalog
extends RefCounted

## Launch-test skill data.  Combat scenes read this catalog rather than
## hard-coding labels, costs and cooldowns into the UI, so sect and weapon
## branches can later replace or extend each slot without replacing the HUD.
const STARTER_TEST_SKILLS := [
	{
		"id": "qinglan_sword",
		"name": "青岚剑",
		"key": "J",
		"spirit_cost": 0,
		"cooldown": 0.43,
		"description": "基础剑击，消耗最低。",
	},
	{
		"id": "ningxi_sword_art",
		"name": "凝息剑诀",
		"key": "K",
		"spirit_cost": 18,
		"cooldown": 4.0,
		"description": "凝灵成诀，造成较高灵力伤害。",
	},
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
