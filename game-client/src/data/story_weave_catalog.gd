class_name StoryWeaveCatalog
extends RefCounted

## The weak main thread is a shared world event, not a mandatory task list.
## A player's first resonance only changes which clue is easiest to notice;
## every route remains available through exploration, trade, sects, or NPCs.

const WORLD_STAGES := [
	{
		"id": "first_whisper", "name": "岚潮初闻",
		"summary": "云岚一带的岚息开始在不该停留的地方回流。它不是命令你出发的任务，只是一条会在游历中反复出现的世界异象。",
		"need": 0,
	},
	{
		"id": "two_traces", "name": "异地同痕",
		"summary": "来自水路、商路或古遗址的两种痕迹彼此印证：岚潮并非某一处副本的事故，而是跨区域的缓慢变化。",
		"need": 2,
	},
	{
		"id": "old_boundary", "name": "旧界回声",
		"summary": "三类痕迹齐备后，能看出旧界边缘正随岚潮重新显影。宗门、商会、散修与妖族会给出彼此矛盾的解释，玩家自行决定相信、利用、观望或绕开。",
		"need": 3,
	},
]

const ORIGINS := {
	"tide_listener": {
		"name": "听潮者", "label": "潮痕先现",
		"summary": "你更容易从雾溪、水府与潮港察觉异常的岚息回流。",
		"roots": ["水灵根", "雾灵根"], "physiques": ["流泉脉", "岚息体"],
		"signals": ["雾", "溪", "潮", "水府", "港", "海"],
		"leads": ["沿雾溪、水府或归墟雾港观察潮线变化。", "向水系散修、船工或丹师交换有关潮息的见闻。"],
	},
	"herb_reader": {
		"name": "识草者", "label": "草木先知",
		"summary": "你先从灵植药性和生长带的反常变化里读到岚潮。",
		"roots": ["木灵根"], "physiques": ["青木灵胎"],
		"signals": ["草", "药", "丹", "木", "湿地", "灵植"],
		"leads": ["在雾溪浅岸、湿地与山麓记录灵植的生长差异。", "与药师、丹修或采药散修交换药性与产地线索。"],
	},
	"forge_watcher": {
		"name": "观炉者", "label": "地脉先鸣",
		"summary": "矿脉、地火与器纹的细微失衡，先在你的感知中形成疑问。",
		"roots": ["金灵根", "火灵根", "土灵根"], "physiques": ["玄岳骨", "赤阳髓"],
		"signals": ["矿", "炉", "火", "石", "印", "器", "阵"],
		"leads": ["在矿滩、石窟或地火裂谷观察地脉留下的旧纹。", "从炼器师、阵师或地火附近的散修口中收集相互矛盾的解释。"],
	},
	"storm_walker": {
		"name": "逐风者", "label": "风雷先觉",
		"summary": "风向、雷期与崖道上短暂的身法残痕，成为你最早的世界线索。",
		"roots": ["风灵根", "雷灵根", "冰灵根"], "physiques": ["听雷窍"],
		"signals": ["风", "雷", "崖", "断", "符", "隙"],
		"leads": ["在高地、断崖和商道口留意天气窗口与不合常理的风痕。", "向符修、巡路者或御风散修询问他们避开的地段。"],
	},
	"mirror_keeper": {
		"name": "照见者", "label": "心识先应",
		"summary": "你先从幻雾、器灵与人心的反常反应中察觉旧界正在松动。",
		"roots": [], "physiques": ["镜心魂", "御灵纹"],
		"signals": ["镜", "魂", "妖", "傀", "灵", "古"],
		"leads": ["在遗府、雾林与有器灵传闻的地点比对幻象留下的细节。", "与御灵者、音修、散修或宗门弟子交谈，判断谁在借岚潮行事。"],
	},
}


static func origin_for(player: Dictionary) -> Dictionary:
	var root := str(player.get("spirit_root", ""))
	var physique := str(player.get("physique", ""))
	for origin_id in ["tide_listener", "herb_reader", "forge_watcher", "storm_walker", "mirror_keeper"]:
		var origin: Dictionary = ORIGINS[origin_id]
		if (origin.get("roots", []) as Array).has(root) or (origin.get("physiques", []) as Array).has(physique):
			var result := origin.duplicate(true)
			result["id"] = origin_id
			return result
	var fallback: Dictionary = ORIGINS.mirror_keeper.duplicate(true)
	fallback["id"] = "mirror_keeper"
	return fallback


static func origin_by_id(origin_id: String) -> Dictionary:
	var origin: Dictionary = ORIGINS.get(origin_id, ORIGINS.mirror_keeper)
	var result := origin.duplicate(true)
	result["id"] = origin_id if ORIGINS.has(origin_id) else "mirror_keeper"
	return result


static func stage_for_mark_count(mark_count: int) -> Dictionary:
	var result: Dictionary = WORLD_STAGES[0]
	for stage in WORLD_STAGES:
		if mark_count >= int(stage.get("need", 0)):
			result = stage
	return result.duplicate(true)


static func side_threads(player: Dictionary) -> Array[Dictionary]:
	var threads: Array[Dictionary] = [
		{
			"id": "terrain", "name": "地势之书", "source": "溪岸、背风岩隙、旧路和遗迹",
			"description": "从真实地貌寻找资源与随机机缘；不要求接取或清空地图。",
		},
		{
			"id": "market", "name": "行商之网", "source": "云市、拍卖行、商队与航图",
			"description": "通过材料、价格与传闻追踪岚潮带来的供需变化；可交易，也可完全忽略。",
		},
		{
			"id": "companions", "name": "人间回音", "source": "NPC 关系、散修传闻与宗门身份",
			"description": "不同关系和宗门立场提供互相矛盾的解释，不会把玩家固定为某一势力的人。",
		},
	]
	if not str(player.get("sect_id", "")).is_empty():
		threads.append({
			"id": "sect", "name": "山门立场", "source": "宗门贡献、门规与外驻地",
			"description": "你可协助、质疑或离开宗门；离门后的后果属于世界关系，而不是主线失败。",
		})
	return threads

