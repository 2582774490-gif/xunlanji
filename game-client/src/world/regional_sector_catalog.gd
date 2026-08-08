class_name RegionalSectorCatalog
extends RefCounted

## Regional sectors define *where* a kind of content belongs.  They are broad
## geographic bands inside one continuous map, never a list of tiny rooms or
## an instruction to fill every square with encounters.

static func sectors_for(region_style: String) -> Array[Dictionary]:
	match region_style:
		"yunlan_outskirts":
			return _yunlan_outskirts_sectors()
		"return_abyss_mist_port":
			return _return_abyss_mist_port_sectors()
		"thunder_listening_cliff":
			return _thunder_listening_cliff_sectors()
		"abysswatch_terrace":
			return _abysswatch_terrace_sectors()
		"ancient_ridge":
			return _ancient_ridge_sectors()
		"mist_border":
			return _mist_border_sectors()
		_:
			return []


static func _yunlan_outskirts_sectors() -> Array[Dictionary]:
	# 云岚外野是新手聚落外真正可延展的第一大区；村庄本身只是
	# 其中一个稳定聚落，不应被误当成整张新手地图。
	return [
		{
			"id": "south_gate_fields", "name": "南门灵田", "bounds": Rect2(80, 760, 2640, 1960),
			"description": "云岚村南门外的灵田、晒药坪与商路驿站。人流集中在道路和田埂，野兽不会闯进村口。", "terrain": "settled",
		},
		{
			"id": "mist_stream_banks", "name": "雾溪浅岸", "bounds": Rect2(2360, 120, 2460, 1780),
			"description": "雾溪从云岚山脚流过，低阶灵草只沿着石岸与浅水交界出现。", "terrain": "resource",
		},
		{
			"id": "cloudfoot_wood", "name": "云麓疏林", "bounds": Rect2(4680, 600, 2600, 2660),
			"description": "树冠稀疏、山风稳定的林地。采药人和迷路散修会循山径活动，并不会覆盖整个林区。", "terrain": "forest",
		},
		{
			"id": "stonebud_highland", "name": "石芽高地", "bounds": Rect2(80, 2920, 4240, 4960),
			"description": "云岚山脚抬升成宽阔岩台，只有背风岩隙适合生长石芽，适合练气期慢慢探路。", "terrain": "highland",
		},
		{
			"id": "old_caravan_road", "name": "旧商道", "bounds": Rect2(7040, 1040, 4820, 2240),
			"description": "连接雾潮边境的旧商道，路边偶有行脚人与盗匪踪迹；两者都只会依附道路与驿点。", "terrain": "settled",
		},
		{
			"id": "lan_echo_hills", "name": "岚息丘陵", "bounds": Rect2(4440, 3500, 7480, 4360),
			"description": "雾与山风相交的大片丘陵。此处保留给后续洞府、宗门外驻地与随机机缘，不预先填满怪物。", "terrain": "highland",
		},
	]


static func sector_at(region_style: String, world_position: Vector2) -> Dictionary:
	for sector in sectors_for(region_style):
		var bounds: Rect2 = sector.get("bounds", Rect2())
		if bounds.has_point(world_position):
			return sector
	return {}


static func _mist_border_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "old_checkpoint", "name": "雾潮旧关", "bounds": Rect2(80, 620, 2120, 1600),
			"description": "残关与官道仍有人巡望；适合初入边境的修士辨认道路。", "terrain": "settled",
		},
		{
			"id": "fog_channel", "name": "雾渠水口", "bounds": Rect2(1980, 120, 1600, 940),
			"description": "雾水汇入旧渠，水妖只会在浅滩与石岸间活动。", "terrain": "water",
		},
		{
			"id": "mist_forest_road", "name": "雾林道", "bounds": Rect2(2580, 720, 1840, 1600),
			"description": "进入雾林前的缓坡路段，路旁迷雾会遮住偏离官道的去向。", "terrain": "forest",
		},
		{
			"id": "ore_flats", "name": "雾渠矿滩", "bounds": Rect2(3480, 420, 2240, 2550),
			"description": "退潮后露出的灰白矿滩，偶有采矿散修沿水线停留。", "terrain": "resource",
		},
		{
			"id": "cedar_mire", "name": "沉杉洼地", "bounds": Rect2(5480, 1760, 1720, 2660),
			"description": "断杉与浅泥交错，地势复杂，不适合商旅通行。", "terrain": "marsh",
		},
		{
			"id": "herb_wetland", "name": "雾泽药湿地", "bounds": Rect2(6400, 260, 2140, 2500),
			"description": "灵草只沿石滩和浅水交界生长，湿地深处并非采药区。", "terrain": "resource",
		},
		{
			"id": "windward_marsh", "name": "望潮芦原", "bounds": Rect2(8260, 1120, 1940, 2950),
			"description": "风从北海灌入芦原，偶尔有过路人停靠，却不会形成聚落。", "terrain": "marsh",
		},
		{
			"id": "outer_shoals", "name": "外海滩脊", "bounds": Rect2(9900, 420, 2020, 3220),
			"description": "边境最外侧的潮湿滩脊，远处航标指向尚未开放的海域。", "terrain": "water",
		},
		{
			"id": "mist_highlands", "name": "雾岭高地", "bounds": Rect2(120, 2940, 6080, 4940),
			"description": "远离水线的雾岭高地，山径稀疏，未来可延展为洞府与宗门支线。", "terrain": "highland",
		},
		{
			"id": "tideward_hills", "name": "潮外丘陵", "bounds": Rect2(6200, 3640, 5720, 4240),
			"description": "风蚀丘陵将湿地与外海隔开；这里保留给后续大型秘境与山门扩展。", "terrain": "highland",
		},
	]


static func _return_abyss_mist_port_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "tide_ledger_quay", "name": "潮簿泊位", "bounds": Rect2(480, 540, 1360, 980),
			"description": "有税簿、泊位和往来货单的安全港埠；行商与测潮散修只会在这里交换消息。", "terrain": "settled",
		},
		{
			"id": "wrecked_shallows", "name": "沉桅浅滩", "bounds": Rect2(2180, 500, 980, 1260),
			"description": "残舟压住暗礁后的危险浅滩；水妖只能在礁群、潮沟与破船之间活动。", "terrain": "water",
		},
		{
			"id": "shipyard_lane", "name": "修船栈道", "bounds": Rect2(3260, 520, 940, 1280),
			"description": "风浪较缓的维修船坞与工料栈道；修船散修不会出现在外海浅滩。", "terrain": "settled",
		},
		{
			"id": "sea_cave_approach", "name": "海蚀洞潮口", "bounds": Rect2(4480, 500, 980, 1320),
			"description": "涨潮时被雾水淹没的洞口滩脊，属于潮穴鳞豚的领地而非普通商路。", "terrain": "water",
		},
	]


static func _thunder_listening_cliff_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "storm_shelter_road", "name": "避雷栈道", "bounds": Rect2(760, 460, 920, 1120),
			"description": "通往避雷亭的石栈路，候雷符修会在风势可控的位置停留，不会占满崖顶。", "terrain": "settled",
		},
		{
			"id": "lightning_crags", "name": "引雷危崖", "bounds": Rect2(1880, 380, 980, 1140),
			"description": "雷晶裂缝与断崖组成的高危地带；引雷岩貂只在其巢穴附近出没。", "terrain": "storm",
		},
	]


static func _abysswatch_terrace_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "observation_path", "name": "观渊石径", "bounds": Rect2(940, 440, 720, 1060),
			"description": "通向观想台的避风石径；守台散修在这里交流护脉经验，不会被随机投放到断崖外。", "terrain": "settled",
		},
		{
			"id": "windward_cliffs", "name": "裂风崖缘", "bounds": Rect2(2060, 360, 1040, 1180),
			"description": "受峡风切割的崖缘与岩柱，是裂风岩隼盘旋、筑巢和俯冲的唯一生态带。", "terrain": "highland",
		},
	]


static func _ancient_ridge_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "ridge_gate", "name": "古脊关道", "bounds": Rect2(70, 720, 2300, 1760),
			"description": "入岭关道贴着旧山脊延伸，是商队与散修进入高阶区域的唯一稳妥路线。", "terrain": "settled",
		},
		{
			"id": "earthfire_ravine", "name": "地火裂谷", "bounds": Rect2(2180, 140, 3580, 1960),
			"description": "地火从裂隙涌出，灵兽与矿脉都受其影响；只有固定洞口可进入副本。", "terrain": "fire",
		},
		{
			"id": "broken_plateau", "name": "断碑台地", "bounds": Rect2(3440, 1860, 2380, 2060),
			"description": "风化石碑散落在台地，适合遗迹探索，但不该被普通怪物均匀占满。", "terrain": "relic",
		},
		{
			"id": "battlefield_pass", "name": "古战关隘", "bounds": Rect2(5540, 440, 2080, 2240),
			"description": "山口收束成狭长通道，旧日军阵遗迹与巡行残魂集中于此。", "terrain": "battlefield",
		},
		{
			"id": "ancient_battlefield", "name": "古战场", "bounds": Rect2(7160, 120, 2880, 2580),
			"description": "大规模遗迹带。残魂、寻碑散修和高阶机缘只会以小群落形式出现。", "terrain": "battlefield",
		},
		{
			"id": "windbreak_ridge", "name": "断风山脊", "bounds": Rect2(9580, 760, 2340, 2920),
			"description": "山风割裂岩壁，未经准备的修士不宜深入；为后续高阶内容预留。", "terrain": "highland",
		},
		{
			"id": "ashen_basins", "name": "灰烬盆地", "bounds": Rect2(80, 2920, 5160, 4980),
			"description": "地火余烬在盆地沉积，地貌宽阔但路线曲折，适合未来矿脉与洞府扩展。", "terrain": "fire",
		},
		{
			"id": "stone_sea", "name": "石海荒原", "bounds": Rect2(5100, 3240, 6820, 4660),
			"description": "风化石林连成荒原，远端地貌将通过持续分块加入，而不是缩成一张小图。", "terrain": "highland",
		},
	]
