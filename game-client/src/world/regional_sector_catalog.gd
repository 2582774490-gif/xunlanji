class_name RegionalSectorCatalog
extends RefCounted

## Regional sectors define *where* a kind of content belongs.  They are broad
## geographic bands inside one continuous map, never a list of tiny rooms or
## an instruction to fill every square with encounters.

static func sectors_for(region_style: String) -> Array[Dictionary]:
	match region_style:
		"ancient_ridge":
			return _ancient_ridge_sectors()
		"mist_border":
			return _mist_border_sectors()
		_:
			return []


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


static func _ancient_ridge_sectors() -> Array[Dictionary]:
	return [
		{
			"id": "ridge_gate", "name": "古脊关道", "bounds": Rect2(70, 720, 2300, 1760),
			"description": "入岭关道贴着旧山脊延伸，是商队与散修进入高阶区域的唯一稳妥路线。", "terrain": "settled",
		},
		{
			"id": "earthfire_ravine", "name": "地火裂谷", "bounds": Rect2(2180, 140, 3560, 1960),
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
