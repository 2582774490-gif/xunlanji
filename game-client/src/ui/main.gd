extends Control

const Catalog = preload("res://src/data/game_catalog.gd")
const CombatStateData = preload("res://src/combat/combat_state.gd")

var combat := CombatStateData.new()
var selected_gender := "男"
var selected_face := 1
var selected_hair := 1
var selected_root_index := 2
var selected_physique_index := 0
var content: VBoxContainer
var notice_label: Label

func _ready() -> void:
	GameState.screen_changed.connect(func(_screen): _render())
	GameState.profile_changed.connect(_render)
	GameState.notice_changed.connect(_update_notice)
	_render()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or GameState.current_screen != GameState.Screen.DUNGEON:
		return
	if event.keycode == KEY_J:
		combat.normal_attack()
		_render()
	if event.keycode >= KEY_1 and event.keycode <= KEY_5:
		combat.use_skill(event.keycode - KEY_1)
		_render()

func _process(delta: float) -> void:
	if GameState.current_screen == GameState.Screen.DUNGEON or GameState.current_screen == GameState.Screen.PVP:
		combat.tick(delta)

func _render() -> void:
	for child in get_children():
		child.queue_free()
	var background := ColorRect.new()
	background.color = Color("101a27")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var frame := Panel.new()
	frame.position = Vector2(25, 18)
	frame.size = Vector2(1230, 684)
	add_child(frame)
	var title := Label.new()
	title.text = "寻岚记"
	title.position = Vector2(54, 34)
	title.add_theme_font_size_override("font_size", 34)
	title.modulate = Color("f2d79c")
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = _subtitle()
	subtitle.position = Vector2(58, 78)
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.modulate = Color("a7d5ca")
	add_child(subtitle)
	if GameState.current_screen != GameState.Screen.CHARACTER_SELECT:
		_add_navigation()
	content = VBoxContainer.new()
	content.position = Vector2(58, 138)
	content.size = Vector2(1120, 490)
	content.add_theme_constant_override("separation", 10)
	add_child(content)
	notice_label = Label.new()
	notice_label.text = "提示：%s" % GameState.last_notice
	notice_label.position = Vector2(58, 652)
	notice_label.size = Vector2(1130, 30)
	notice_label.add_theme_font_size_override("font_size", 15)
	notice_label.modulate = Color("b8c9c4")
	add_child(notice_label)
	match GameState.current_screen:
		GameState.Screen.CHARACTER_SELECT: _show_character_select()
		GameState.Screen.HOME: _show_home()
		GameState.Screen.OVERWORLD: _show_overworld()
		GameState.Screen.DUNGEON: _show_dungeon()
		GameState.Screen.REALM: _show_realm()
		GameState.Screen.INVENTORY: _show_inventory()
		GameState.Screen.SECT: _show_sect()
		GameState.Screen.MARKET: _show_market()
		GameState.Screen.ALCHEMY: _show_alchemy()
		GameState.Screen.PVP: _show_pvp()
		GameState.Screen.CODEX: _show_codex()
		GameState.Screen.SETTINGS: _show_settings()

func _subtitle() -> String:
	var labels := {
		GameState.Screen.CHARACTER_SELECT: "首发角色模板 · 原创国漫修仙视觉方向",
		GameState.Screen.HOME: "修行、探索、宗门与人世，都从此处展开",
		GameState.Screen.OVERWORLD: "三大区开放世界 · 固定副本与可解释随机机缘",
		GameState.Screen.DUNGEON: "统一 2D 斜俯视场景战斗 · 当前为本地基础动作逻辑",
		GameState.Screen.REALM: "炼气至化神圆满 · 多重小境界成长",
		GameState.Screen.INVENTORY: "武器、材料、法宝与时装的统一入口",
		GameState.Screen.SECT: "自由加入与退出 · 门规、贡献、身份与后果",
		GameState.Screen.MARKET: "自由交易与拍卖行接口 · 当前为本地演示",
		GameState.Screen.ALCHEMY: "丹药由材料、境界与药性共同限制；所有玩家可炼，丹修更擅长",
		GameState.Screen.PVP: "1v1 论剑 · 后续接入房间与服务器权威同步",
		GameState.Screen.CODEX: "人物、宗门、地区、副本、法宝的收藏与知识库",
		GameState.Screen.SETTINGS: "原型设置与联网状态说明",
	}
	return labels.get(GameState.current_screen, "")

func _add_navigation() -> void:
	var row := HBoxContainer.new()
	row.position = Vector2(430, 37)
	row.size = Vector2(780, 45)
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	for entry in [["洞府", GameState.Screen.HOME], ["世界", GameState.Screen.OVERWORLD], ["修炼", GameState.Screen.REALM], ["行囊", GameState.Screen.INVENTORY], ["炼丹", GameState.Screen.ALCHEMY], ["宗门", GameState.Screen.SECT], ["市集", GameState.Screen.MARKET], ["论剑", GameState.Screen.PVP], ["图鉴", GameState.Screen.CODEX]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(83, 40)
		button.pressed.connect(func(): GameState.enter_screen(entry[1]))
		row.add_child(button)

func _heading(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", 27)
	label.modulate = Color.WHITE
	content.add_child(label)

func _text(value: String, size := 17, tint := Color("c8d5d1")) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.modulate = tint
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size = Vector2(1100, 0)
	content.add_child(label)

func _buttons(entries: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	content.add_child(row)
	for entry in entries:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(entry[2] if entry.size() > 2 else 180, 46)
		button.disabled = entry.size() > 3 and entry[3]
		button.pressed.connect(entry[1])
		row.add_child(button)

func _line() -> void:
	content.add_child(HSeparator.new())

func _show_character_select() -> void:
	var portrait := TextureRect.new()
	portrait.texture = _load_portrait(selected_gender)
	portrait.position = Vector2(70, 145)
	portrait.size = Vector2(390, 450)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(portrait)
	content.position = Vector2(560, 170)
	content.size = Vector2(570, 420)
	_heading("创建你的修士")
	_text("首发仅开放男女角色模板、脸型模板与发型模板；体型捏脸将在后续版本评估。")
	_text("当前选择：%s · 脸型 %d · 发型 %d" % [selected_gender, selected_face, selected_hair], 20, Color("f2d79c"))
	_buttons([["男模板", func(): _set_gender("男"), 140], ["女模板", func(): _set_gender("女"), 140]])
	_buttons([["切换脸型", _cycle_face, 180], ["切换发型", _cycle_hair, 180]])
	_text("灵根：%s｜体质：%s" % [Catalog.SPIRIT_ROOTS[selected_root_index].name, Catalog.PHYSIQUES[selected_physique_index].name], 17, Color("a7d5ca"))
	_buttons([["切换灵根", _cycle_root, 180], ["切换体质", _cycle_physique, 180]])
	_line()
	_text("人物资产统一为：立绘用于详情与剧情；2D 斜俯视角色用于大世界、副本与 PVP。", 16)
	_buttons([["踏入云岚村", _confirm_character, 250]])

func _show_home() -> void:
	_heading("修士洞府")
	_text("%s · %s · 灵石 %d · 金钱 %d" % [GameState.player.gender, GameState.realm_name(), GameState.player.spirit_stones, GameState.player.gold], 21, Color("f2d79c"))
	_text("灵根：%s｜体质：%s｜主修：%s" % [GameState.player.spirit_root, GameState.player.physique, GameState.player.cultivation_path])
	_text("已装备：%s｜法宝：%s" % [GameState.player.equipped_weapon, GameState.player.equipped_artifact])
	_line()
	_text("核心循环：探索区域 → 获得资源/机缘 → 修炼与装备成长 → 宗门/交易/PVP → 解锁更高区域。")
	_buttons([["进入开放世界", func(): GameState.enter_screen(GameState.Screen.OVERWORLD), 220], ["吐纳修炼", func(): GameState.enter_screen(GameState.Screen.REALM), 180], ["查看行囊", func(): GameState.enter_screen(GameState.Screen.INVENTORY), 180]])
	_buttons([["宗门身份", func(): GameState.enter_screen(GameState.Screen.SECT), 180], ["自由市集", func(): GameState.enter_screen(GameState.Screen.MARKET), 180], ["1v1 论剑", func(): GameState.enter_screen(GameState.Screen.PVP), 180], ["设置", func(): GameState.enter_screen(GameState.Screen.SETTINGS), 120]])

func _show_overworld() -> void:
	_heading("开放世界 · 三大区")
	_text("当前区域：%s。大区以短暂切换连接；正式联网目标为单区最多 10 名玩家。" % _current_region().name)
	var thresholds := [0, 1, 3]
	for region_index in Catalog.REGIONS.size():
		var region: Dictionary = Catalog.REGIONS[region_index]
		var available: bool = bool(region.unlocked) or GameState.player.realm_index >= thresholds[region_index]
		_text("【%s】适配：%s｜%s" % [region.name, region.realm, region.description], 17, Color.WHITE if available else Color("82908c"))
		_buttons([["前往 %s" % region.name, func(): _select_region(region), 245, not available]])
	_line()
	var region: Dictionary = _current_region()
	_text("固定副本：%s" % _dungeon_names(region.dungeons), 18, Color("f2d79c"))
	var dungeon_buttons: Array = []
	for dungeon_id in region.dungeons:
		dungeon_buttons.append([Catalog.DUNGEONS[dungeon_id].name, func(): _enter_dungeon(dungeon_id), 180])
	_buttons(dungeon_buttons)
	_buttons([["进入可运行大地图", _open_playable_world, 240]])
	_buttons([["探索随机机缘", _explore, 220], ["返回洞府", func(): GameState.enter_screen(GameState.Screen.HOME), 160]])

func _show_dungeon() -> void:
	var dungeon: Dictionary = Catalog.DUNGEONS[GameState.selected_dungeon_id]
	_heading("%s · 2D 场景副本" % dungeon.name)
	_text("目标：击败%s｜适配：%s｜首通演示奖励：%s" % [dungeon.enemy, dungeon.realm, dungeon.reward], 19, Color("f2d79c"))
	_text("玩家 HP：%d / 100｜对手 HP：%d / 100" % [combat.player_hp, combat.enemy_hp], 22, Color.WHITE)
	_text(combat.battle_log)
	_text("当前使用无武器基础战斗逻辑；每把武器需在武器卡确认后单独制作动作与特效。", 15, Color("a7d5ca"))
	_buttons(_combat_entries())
	_buttons([["领取副本演示奖励", _claim_reward, 220, combat.enemy_hp > 0], ["退出副本", func(): GameState.enter_screen(GameState.Screen.OVERWORLD), 160]])

func _show_realm() -> void:
	_heading("修炼体系")
	_text("当前境界：%s｜修为：%d" % [GameState.realm_name(), GameState.player.cultivation], 22, Color("f2d79c"))
	_text("炼气使用一至九层与圆满；筑基、结丹、元婴、化神使用初期至后期圆满；首发上限为化神圆满。")
	for realm_index in Catalog.REALMS.size():
		var realm: Dictionary = Catalog.REALMS[realm_index]
		var status := "已到达" if realm_index < GameState.player.realm_index else ("当前" if realm_index == GameState.player.realm_index else "未解锁")
		_text("%s · %s · %s" % [realm.name, "、".join(realm.minor_stages), status], 16, Color.WHITE if realm_index <= GameState.player.realm_index else Color("82908c"))
	_line()
	_text("功法派系：可选择一部主修功法；不同灵根和体质将影响后续的实际数值与技能树。", 17, Color("f2d79c"))
	for school in Catalog.CULTIVATION_SCHOOLS:
		_text("【%s】%s" % [school.faction, "、".join(school.techniques)], 16)
		_buttons([["主修 %s" % school.techniques[0], func(): GameState.choose_cultivation_path(school.techniques[0]), 250]])
	_buttons([["静坐吐纳（+25 修为）", func(): GameState.gain_cultivation(25), 240], ["服用灵泉露（+40 修为）", _use_dew, 240]])

func _show_inventory() -> void:
	_heading("行囊 · 装备与法宝")
	_text("已装备武器：%s｜已装备法宝：%s" % [GameState.player.equipped_weapon, GameState.player.equipped_artifact], 20, Color("f2d79c"))
	_text("当前物品：%s" % "、".join(GameState.player.inventory))
	_line()
	_text("首发正式基础器型：每种大类先做一把正式武器，再逐步补大分支、小分支、品级、武器卡、动作和特效。")
	for family in Catalog.WEAPON_FAMILIES:
		_text("%s｜%s｜基础器：%s｜派系：%s" % [family.name, family.branches, family.starter, family.school], 16)
	_buttons([["录入全部基础器型（本地演示）", _claim_weapon_samples, 300]])
	var equips: Array = []
	for item_name in GameState.player.inventory:
		if "练气" in item_name:
			equips.append(["装备 %s" % item_name, func(): GameState.equip_weapon(item_name), 180])
	if not equips.is_empty(): _buttons(equips)

func _show_sect() -> void:
	_heading("宗门与身份")
	if GameState.player.sect_id == "":
		_text("当前为散修。可自由加入宗门；初始身份为外门弟子，后续通过贡献与实力晋升。")
		for sect in Catalog.SECTS:
			_text("【%s】%s｜门规：%s" % [sect.name, sect.trait, sect.rule])
			_buttons([["加入 %s" % sect.name, func(): GameState.join_sect(sect.id), 230]])
	else:
		var sect: Dictionary = _find_sect(GameState.player.sect_id)
		_text("当前宗门：%s｜身份：外门弟子（本地演示）" % sect.name, 21, Color("f2d79c"))
		_text("%s\n门规：%s" % [sect.trait, sect.rule])
		_text("正式版将由服务器结算升迁、任职、通缉、赎罪和关系修复。", 15, Color("a7d5ca"))
		_buttons([["退出宗门（演示）", GameState.leave_sect, 220]])

func _show_market() -> void:
	_heading("云市 · 自由交易与拍卖行")
	_text("当前金钱：%d。正式版将由服务器校验所有权、上架、成交、税率与反作弊；本页仅演示客户端交互。" % GameState.player.gold, 17, Color("f2d79c"))
	for listing in Catalog.MARKET_LISTINGS:
		_text("%s｜%s｜价格 %d 金" % [listing.name, listing.type, listing.price], 18)
		_buttons([["购买", func(): _buy(listing), 130, GameState.player.gold < listing.price]])
	_buttons([["发布自己的物品（接口）", func(): GameState.notify("已记录上架意图，正式版将打开定价和服务器校验。"), 280]])

func _show_alchemy() -> void:
	_heading("云岚村 · 炼丹工坊")
	_text("所有修士都能炼丹；丹修将拥有更高成丹率与更深药性控制。高阶修士服用低阶丹药不会获得有效提升。", 17, Color("f2d79c"))
	_text("初阶配方：雾溪灵草 × 1 + 雾溪药 × 1 → 凝息丹（炼气一至三层有效，+25 修为）")
	_buttons([["炼制凝息丹", _craft_condensing_pill, 210], ["返回行囊", func(): GameState.enter_screen(GameState.Screen.INVENTORY), 160]])

func _craft_condensing_pill() -> void:
	if GameState.player.realm_index > 0 or GameState.player.minor_stage > 3:
		GameState.notify("当前境界已超过凝息丹的有效药性范围。")
		return
	if not GameState.consume_items(["雾溪灵草", "雾溪药"]):
		GameState.notify("材料不足：需要雾溪灵草与雾溪药各一份。")
		return
	GameState.add_item("凝息丹")
	GameState.gain_cultivation(25)
	GameState.notify("炼制成功：凝息丹入囊，药性已转化为修为。")
	_render()

func _show_pvp() -> void:
	_heading("1v1 论剑台")
	if combat.mode != "论剑" or combat.enemy_name != "山门试剑使": combat.begin("论剑", "山门试剑使")
	_text("首发 PVP 最多支持两人。当前为本地对战演示，不代表已经完成实时联网。", 18, Color("f2d79c"))
	_text("玩家 HP：%d / 100｜对手 HP：%d / 100" % [combat.player_hp, combat.enemy_hp], 22, Color.WHITE)
	_text(combat.battle_log)
	_buttons(_combat_entries(true))
	_text("联网清单：房间匹配、同步、断线处理、服务器权威结算、战绩与反作弊。", 15, Color("a7d5ca"))

func _show_codex() -> void:
	_heading("万物图鉴")
	_text("已发现：%s" % "、".join(GameState.player.codex), 18, Color("f2d79c"))
	_text("首批 NPC：")
	for npc in Catalog.NPCS:
		_text("%s · %s · %s" % [npc.name, npc.role, npc.place], 17)
	_line()
	_text("图鉴分类接口：人物、宗门、妖怪、法宝、灵植、资源、地点、副本、功法、事件。")

func _show_settings() -> void:
	_heading("设置与开发状态")
	_text("引擎：Godot 4.7｜目标：微信小游戏优先｜当前：Windows 本地原型。")
	_text("已具备：首发内容数据、完整模块入口、本地修炼/机缘/副本/交易/PVP 演示、首批立绘。")
	_text("后续尚需：微信导出验证、服务器、账号、真实多人同步、去背切图和完整动作帧、数值平衡、音频、存档与测试。")
	_buttons([["返回洞府", func(): GameState.enter_screen(GameState.Screen.HOME), 160], ["重新创建角色", func(): GameState.enter_screen(GameState.Screen.CHARACTER_SELECT), 180]])

func _combat_entries(include_reset := false) -> Array:
	var entries: Array = [["J 普攻", func(): _attack(), 120]]
	if include_reset: entries.push_front(["重新开始", func(): _restart_pvp(), 150])
	for skill_index in 5:
		entries.append(["%d · %s" % [skill_index + 1, combat.skill_names[skill_index]], func(): _skill(skill_index), 145])
	return entries

func _set_gender(value: String) -> void:
	selected_gender = value
	_render()

func _cycle_face() -> void:
	selected_face = selected_face % 3 + 1
	_render()

func _cycle_hair() -> void:
	selected_hair = selected_hair % 3 + 1
	_render()

func _cycle_root() -> void:
	selected_root_index = (selected_root_index + 1) % Catalog.SPIRIT_ROOTS.size()
	_render()

func _cycle_physique() -> void:
	selected_physique_index = (selected_physique_index + 1) % Catalog.PHYSIQUES.size()
	_render()

func _confirm_character() -> void:
	GameState.update_character(selected_gender, selected_face, selected_hair)
	GameState.update_innate(Catalog.SPIRIT_ROOTS[selected_root_index].name, Catalog.PHYSIQUES[selected_physique_index].name)
	GameState.notify("角色创建完成，云岚村的雾潮正等待你的第一次探索。")
	GameState.enter_screen(GameState.Screen.HOME)

func _load_portrait(gender: String) -> Texture2D:
	var path := "res://assets/art/prototype_batch_01/male_anchor_portrait_v01.png" if gender == "男" else "res://assets/art/prototype_batch_01/female_anchor_portrait_v01.png"
	return load(path) as Texture2D

func _current_region() -> Dictionary:
	for region in Catalog.REGIONS:
		if region.id == GameState.current_region_id: return region
	return Catalog.REGIONS[0]

func _select_region(region: Dictionary) -> void:
	GameState.current_region_id = region.id
	GameState.notify("已切换至%s。" % region.name)
	_render()

func _dungeon_names(ids: Array) -> String:
	var names: Array[String] = []
	for dungeon_id in ids: names.append(Catalog.DUNGEONS[dungeon_id].name)
	return "、".join(names)

func _enter_dungeon(dungeon_id: String) -> void:
	GameState.selected_dungeon_id = dungeon_id
	combat.begin("副本", Catalog.DUNGEONS[dungeon_id].enemy)
	GameState.enter_screen(GameState.Screen.DUNGEON)

func _open_playable_world() -> void:
	get_tree().change_scene_to_file("res://scenes/yunlan_south_gate.tscn")

func _explore() -> void:
	var opportunity: Dictionary = Catalog.OPPORTUNITIES.pick_random()
	GameState.add_item(opportunity.item)
	GameState.gain_cultivation(opportunity.cultivation)
	GameState.notify("机缘【%s】：%s 获得 %s。" % [opportunity.title, opportunity.text, opportunity.item])
	_render()

func _attack() -> void:
	combat.normal_attack()
	_render()

func _skill(index: int) -> void:
	combat.use_skill(index)
	_render()

func _claim_reward() -> void:
	var dungeon: Dictionary = Catalog.DUNGEONS[GameState.selected_dungeon_id]
	GameState.add_item(dungeon.reward)
	GameState.player.spirit_stones += 12
	GameState.gain_cultivation(20)
	GameState.notify("副本结算：获得 %s、12 灵石与修为。" % dungeon.reward)

func _use_dew() -> void:
	if GameState.player.inventory.has("灵泉露"):
		GameState.player.inventory.erase("灵泉露")
		GameState.gain_cultivation(40)
	else:
		GameState.notify("行囊中没有灵泉露，可在探索机缘中获得。")

func _claim_weapon_samples() -> void:
	for family in Catalog.WEAPON_FAMILIES:
		if not GameState.player.inventory.has(family.starter): GameState.add_item(family.starter)
	GameState.notify("已录入全部首发基础器型；每把武器仍需建立武器卡后制作专属动作与特效。")

func _find_sect(id: String) -> Dictionary:
	for sect in Catalog.SECTS:
		if sect.id == id: return sect
	return Catalog.SECTS[0]

func _buy(listing: Dictionary) -> void:
	if GameState.player.gold < listing.price:
		GameState.notify("金钱不足。")
		return
	GameState.player.gold -= listing.price
	GameState.add_item(listing.name)
	GameState.notify("已完成本地演示购买：%s。" % listing.name)

func _restart_pvp() -> void:
	combat.begin("论剑", "山门试剑使")
	GameState.notify("已开始本地 1v1 演示。")
	_render()

func _update_notice(text: String) -> void:
	if notice_label: notice_label.text = "提示：%s" % text
