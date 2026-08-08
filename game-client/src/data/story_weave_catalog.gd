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
		"resonance": {"region": "starter_village", "sector": "mist_stream_banks", "position": Vector2(3860, 820), "story_trace": "water", "name": "潮痕浮灯", "prompt": "静观雾溪石岸的潮痕浮灯", "description": "浅潮没有推着浮灯向下，反而将它缓缓送回山脚。你第一次确认，这不是寻常的水雾异动。"},
		"border_resonance": {"region": "mist_border", "sector": "fog_channel", "position": Vector2(3340, 780), "story_trace": "water", "name": "回潮石环", "prompt": "比对雾渠石环内外的回潮刻度", "description": "石环内的水位比渠外晚退半刻。你听见的不是一条水道在回声，而像两片水域隔着旧界彼此应答。", "branch_id": "tide_listener_border_ring", "branch_title": "回潮石环录"},
		"ridge_resonance": {"region": "ancient_ridge", "sector": "ashen_basins", "position": Vector2(3140, 4220), "story_trace": "water", "name": "蒸潮石洼", "prompt": "比对灰烬盆地石洼里的蒸潮水线", "description": "地火余烬蒸出的水汽没有散入天际，而在石洼中倒流成极浅的潮线。你终于明白，岚潮能借的不止江河，也包括一座山脉呼出的水。", "branch_id": "tide_listener_ridge_tidepool", "branch_title": "蒸潮石洼录"},
		"leads": ["沿雾溪、水府或归墟雾港观察潮线变化。", "向水系散修、船工或丹师交换有关潮息的见闻。"],
	},
	"herb_reader": {
		"name": "识草者", "label": "草木先知",
		"summary": "你先从灵植药性和生长带的反常变化里读到岚潮。",
		"roots": ["木灵根"], "physiques": ["青木灵胎"],
		"signals": ["草", "药", "丹", "木", "湿地", "灵植"],
		"resonance": {"region": "starter_village", "sector": "cloudfoot_wood", "position": Vector2(5580, 2360), "story_trace": "water", "name": "逆时草结", "prompt": "查看疏林中的逆时草结", "description": "同一株灵草的晨露与暮露同时凝在叶脉上。药性尚未变质，却先替这片山林记下了岚潮。"},
		"border_resonance": {"region": "mist_border", "sector": "herb_wetland", "position": Vector2(7240, 2300), "story_trace": "water", "name": "并生药脉", "prompt": "查看同根异时开花的并生药脉", "description": "一段根须同时抽出早春与深秋的叶芽，药性并未相冲。你意识到岚潮先改变的是生长的时序，而非草木本身。", "branch_id": "herb_reader_border_veins", "branch_title": "并生药脉笺"},
		"ridge_resonance": {"region": "ancient_ridge", "sector": "ashen_basins", "position": Vector2(1560, 4740), "story_trace": "relic", "name": "灰芽药囊", "prompt": "检视灰烬中未焦的药芽", "description": "药芽生在冷灰里，叶脉却保留着湿地灵植的药性。它不是耐火异种，而像被岚潮从另一段生长时序借来的余枝。", "branch_id": "herb_reader_ridge_ashbud", "branch_title": "灰芽药囊笺"},
		"leads": ["在雾溪浅岸、湿地与山麓记录灵植的生长差异。", "与药师、丹修或采药散修交换药性与产地线索。"],
	},
	"forge_watcher": {
		"name": "观炉者", "label": "地脉先鸣",
		"summary": "矿脉、地火与器纹的细微失衡，先在你的感知中形成疑问。",
		"roots": ["金灵根", "火灵根", "土灵根"], "physiques": ["玄岳骨", "赤阳髓"],
		"signals": ["矿", "炉", "火", "石", "印", "器", "阵"],
		"resonance": {"region": "starter_village", "sector": "stonebud_highland", "position": Vector2(2140, 3820), "story_trace": "relic", "name": "反纹石芽", "prompt": "辨认石芽上的反向器纹", "description": "石芽缝里的古旧纹路正逆向生长，像有什么东西从地脉深处倒着寻找出口。"},
		"border_resonance": {"region": "mist_border", "sector": "ore_flats", "position": Vector2(5060, 2200), "story_trace": "relic", "name": "余温器砂", "prompt": "以灵识探查矿滩器砂残留的火候", "description": "冷矿砂里残留的不是地火余温，而是一种早已熄灭的炼器火候。它与石芽反纹同属一套被截断的旧制。", "branch_id": "forge_watcher_border_sand", "branch_title": "余温器砂谱"},
		"ridge_resonance": {"region": "ancient_ridge", "sector": "earthfire_ravine", "position": Vector2(4160, 1180), "story_trace": "relic", "name": "倒炼器槽", "prompt": "感知地火裂谷中的倒炼器槽", "description": "槽壁留下的火候是从成器倒推回矿料的。它说明古脊岭的地火并非失控，而是在重复一座旧界锻台被中止的最后一步。", "branch_id": "forge_watcher_ridge_crucible", "branch_title": "倒炼器槽谱"},
		"leads": ["在矿滩、石窟或地火裂谷观察地脉留下的旧纹。", "从炼器师、阵师或地火附近的散修口中收集相互矛盾的解释。"],
	},
	"storm_walker": {
		"name": "逐风者", "label": "风雷先觉",
		"summary": "风向、雷期与崖道上短暂的身法残痕，成为你最早的世界线索。",
		"roots": ["风灵根", "雷灵根", "冰灵根"], "physiques": ["听雷窍"],
		"signals": ["风", "雷", "崖", "断", "符", "隙"],
		"resonance": {"region": "starter_village", "sector": "lan_echo_hills", "position": Vector2(6760, 4060), "story_trace": "relic", "name": "回风残铃", "prompt": "倾听丘陵缺口中的回风残铃", "description": "没有风的时候，残铃却在崖隙中响了一次。它响起的方向与所有商路的风向都相反。"},
		"border_resonance": {"region": "mist_border", "sector": "mist_highlands", "position": Vector2(4140, 3800), "story_trace": "relic", "name": "逆风符阶", "prompt": "沿逆风符阶辨认被抹去的行迹", "description": "石阶上没有脚印，风却始终从上方往下压。你沿着符阶看见一段有人故意避开的旧界折线。", "branch_id": "storm_walker_border_steps", "branch_title": "逆风符阶记"},
		"ridge_resonance": {"region": "ancient_ridge", "sector": "windbreak_ridge", "position": Vector2(10840, 2340), "story_trace": "road", "name": "裂风退路", "prompt": "在断风山脊辨认被风墙掩去的退路", "description": "风墙不是天然屏障，它在每次回卷时露出同一段撤离线。你看见旧界边缘曾被人用来送走整支队伍，却没有一人被留在碑文里。", "branch_id": "storm_walker_ridge_retreat", "branch_title": "裂风退路记"},
		"leads": ["在高地、断崖和商道口留意天气窗口与不合常理的风痕。", "向符修、巡路者或御风散修询问他们避开的地段。"],
	},
	"mirror_keeper": {
		"name": "照见者", "label": "心识先应",
		"summary": "你先从幻雾、器灵与人心的反常反应中察觉旧界正在松动。",
		"roots": [], "physiques": ["镜心魂", "御灵纹"],
		"signals": ["镜", "魂", "妖", "傀", "灵", "古"],
		"resonance": {"region": "starter_village", "sector": "old_caravan_road", "position": Vector2(9660, 1700), "story_trace": "road", "name": "无主影契", "prompt": "查看旧商道旁的无主影契", "description": "破损的影契没有署名，却映出一支从未经过此地的商队。它留下的脚印正朝着被遗忘的旧界边缘延伸。"},
		"border_resonance": {"region": "mist_border", "sector": "outer_shoals", "position": Vector2(10780, 2000), "story_trace": "road", "name": "潮镜残影", "prompt": "凝视潮镜中不属于此岸的行人", "description": "浅潮映出的行人并没有影子，却在朝外海滩脊行走。你无法断定那是幻象，还是旧界有人正从另一侧看向此地。", "branch_id": "mirror_keeper_border_reflection", "branch_title": "潮镜对岸影"},
		"ridge_resonance": {"region": "ancient_ridge", "sector": "broken_plateau", "position": Vector2(4720, 3080), "story_trace": "relic", "name": "断碑双影", "prompt": "从断碑背面比对两道不合日照的影子", "description": "碑前只有你一人的影子，碑后却有第二道影子替你翻读残文。它没有劝你深入，也没有阻你离开，只把一个旧界名字留在风化的石粉里。", "branch_id": "mirror_keeper_ridge_shadow", "branch_title": "断碑双影录"},
		"leads": ["在遗府、雾林与有器灵传闻的地点比对幻象留下的细节。", "与御灵者、音修、散修或宗门弟子交谈，判断谁在借岚潮行事。"],
	},
}


## A player may interpret the shared mystery differently after seeing enough
## evidence. This is narrative posture only: not a class, faction lock, build,
## reward track, or mandatory task branch.
const STANCES := {
	"mender": {
		"name": "守界", "summary": "你认为岚潮正在侵蚀旧界，应先保护人间聚落与地脉。",
		"leads": ["留意边关巡修、护脉散修与受雾潮影响的村落。", "可向宗门询问封阵、护脉与撤离传闻；不要求加入任何宗门。"],
	},
	"seeker": {
		"name": "溯源", "summary": "你认为岚潮是一次罕见的开门，应先寻找旧界与异象的源头。",
		"leads": ["留意失踪商路、潮港航图与遗迹中的旧界坐标。", "可与行商、阵师、散修交换线索；不要求完成任何副本。"],
	},
	"witness": {
		"name": "观变", "summary": "你暂不替任何势力下结论，先记录岚潮如何改变资源、妖兽与人心。",
		"leads": ["留意灵植、妖兽领地和各地物价在雾潮后的变化。", "可通过采集、交易、游历簿与 NPC 关系自行比对；不要求站队。"],
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


static func stance_by_id(stance_id: String) -> Dictionary:
	var stance: Dictionary = STANCES.get(stance_id, {})
	var result := stance.duplicate(true)
	result["id"] = stance_id if STANCES.has(stance_id) else ""
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
