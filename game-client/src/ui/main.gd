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
	OnlineSession.connection_state_changed.connect(func(_state):
		if GameState.current_screen == GameState.Screen.OVERWORLD:
			_render()
	)
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
	_text("已装备：%s｜法宝：%s｜护具：%s" % [GameState.player.equipped_weapon, GameState.player.equipped_artifact, GameState.player.get("equipped_armor", "未装备") if not str(GameState.player.get("equipped_armor", "")).is_empty() else "未装备"])
	_line()
	_text("核心循环：探索区域 → 获得资源/机缘 → 修炼与装备成长 → 宗门/交易/PVP → 解锁更高区域。")
	_buttons([["进入开放世界", func(): GameState.enter_screen(GameState.Screen.OVERWORLD), 220], ["吐纳修炼", func(): GameState.enter_screen(GameState.Screen.REALM), 180], ["查看行囊", func(): GameState.enter_screen(GameState.Screen.INVENTORY), 180]])
	_buttons([["宗门身份", func(): GameState.enter_screen(GameState.Screen.SECT), 180], ["自由市集", func(): GameState.enter_screen(GameState.Screen.MARKET), 180], ["1v1 论剑", func(): GameState.enter_screen(GameState.Screen.PVP), 180], ["设置", func(): GameState.enter_screen(GameState.Screen.SETTINGS), 120]])

func _show_overworld() -> void:
	_heading("开放世界 · 三大区")
	# 这些条目是玩家可自行发现的世界线索，不会生成强制任务链。
	_text("探索原则：%s" % Catalog.WORLD_EXPLORATION_POLICY.main_thread, 16, Color("a7d5ca"))
	_text("门派与修行指引：%s" % Catalog.WORLD_EXPLORATION_POLICY.guidance, 16, Color("a7d5ca"))
	_text("世界引导：%s" % GameState.world_guidance_text(), 16, Color("f2d79c"))
	if not GameState.is_world_guidance_complete():
		_text("提示：南门沈衍、溪路灵草与村中宗门接引使会依次说明基础规则；也可直接跳过，不会封锁任何自由内容。", 15, Color("a7d5ca"))
		_buttons([["跳过世界引导", func(): GameState.skip_world_guidance(), 190]])
	if GameState.player.realm_index == 0:
		_text("炼气阶段的可发现内容（传闻与自然入口，不是强制任务顺序）：", 18, Color("f2d79c"))
		for content in Catalog.QI_REFINING_CONTENT:
			var known: bool = GameState.player.minor_stage >= int(content.layer)
			var tint: Color = Color.WHITE if known else Color("82908c")
			var state := "当前可尝试" if known else "尚可从传闻、宗门或探索中得知"
			_text("炼气%d · %s｜%s｜%s｜%s" % [int(content.layer), content.name, content.kind, state, content.reward], 15, tint)
	_text("当前区域：%s。大区以短暂切换连接；正式联网目标为单区最多 10 名玩家。" % _current_region().name)
	_text("十人同区原型：%s。仅同步在线名册与位置；背包、交易结算与战斗仍不会交给客户端联网伪造。" % OnlineSession.state_text(), 15, Color("a7d5ca"))
	_buttons([["连接本机十人房", _connect_local_ten_player_room, 200, OnlineSession.is_room_connected()], ["断开十人房", _disconnect_ten_player_room, 160, not OnlineSession.is_room_connected()]])
	var thresholds := [0, 1, 3]
	for region_index in Catalog.REGIONS.size():
		var region: Dictionary = Catalog.REGIONS[region_index]
		var available: bool = bool(region.unlocked) or GameState.player.realm_index >= thresholds[region_index]
		_text("【%s】适配：%s｜%s" % [region.name, region.realm, region.description], 17, Color.WHITE if available else Color("82908c"))
		_buttons([["前往 %s" % region.name, func(): _select_region(region), 245, not available]])
	_line()
	var region: Dictionary = _current_region()
	_text("固定副本：%s" % _dungeon_names(region.dungeons), 18, Color("f2d79c"))
	_text("副本只能从大地图的真实入口进入；此页不提供绕过地图的直接传送。", 15, Color("a7d5ca"))
	_buttons([["进入可运行大地图", _open_playable_world, 240]])
	_buttons([["查看区域探索要点", _explore, 220], ["返回洞府", func(): GameState.enter_screen(GameState.Screen.HOME), 160]])

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
	var threshold := GameState.cultivation_threshold()
	_text("当前境界：%s｜修为：%d / %d" % [GameState.realm_name(), GameState.player.cultivation, threshold], 22, Color("f2d79c"))
	_text(GameState.breakthrough_requirement_text(), 17, Color("a7d5ca"))
	_buttons([["主动冲关", func(): GameState.try_breakthrough(), 180, not GameState.can_attempt_breakthrough()]])
	var attributes: Dictionary = GameState.player.attributes
	var stats: Dictionary = GameState.derived_stats()
	_text(GameState.attribute_point_summary() + "｜所有角色创角点池相同；身法会影响大世界移动。", 16, Color("a7d5ca"))
	_text("可分配属性点：%d｜体魄 %d · 灵识 %d · 身法 %d · 根骨 %d" % [GameState.player.unspent_points, attributes["体魄"], attributes["灵识"], attributes["身法"], attributes["根骨"]], 18, Color("a7d5ca"))
	_text("派生：气血 %d · 灵力 %d · 攻击 %d · 移速 %d · 修行效率 %d%%" % [stats["气血"], stats["灵力"], stats["攻击"], stats["移速"], stats["修行效率"]], 16)
	_buttons([["体魄 +1", func(): _allocate_attribute("体魄"), 120], ["灵识 +1", func(): _allocate_attribute("灵识"), 120], ["身法 +1", func(): _allocate_attribute("身法"), 120], ["根骨 +1", func(): _allocate_attribute("根骨"), 120]])
	_text("炼气使用一至九层与圆满；筑基、结丹、元婴、化神使用初期至后期圆满；首发上限为化神圆满。")
	for realm_index in Catalog.REALMS.size():
		var realm: Dictionary = Catalog.REALMS[realm_index]
		var status := "已到达" if realm_index < GameState.player.realm_index else ("当前" if realm_index == GameState.player.realm_index else "未解锁")
		_text("%s · %s · %s" % [realm.name, "、".join(realm.minor_stages), status], 16, Color.WHITE if realm_index <= GameState.player.realm_index else Color("82908c"))
	_line()
	_text("功法派系：已学功法可自由切换。所有线路都能玩；适配灵根与体质只提供温和的修行效率加成，不封死其他玩法。", 17, Color("f2d79c"))
	_text(GameState.cultivation_efficiency_text(), 16, Color("a7d5ca"))
	_text(GameState.technique_insight_text(), 16, Color("a7d5ca"))
	for school in Catalog.CULTIVATION_SCHOOLS:
		_text("【%s】%s" % [school.faction, "、".join(school.techniques)], 16)
		for technique_name in school.techniques:
			_buttons([["切换主修 %s" % technique_name, func(): GameState.choose_cultivation_path(technique_name), 270]])
	_buttons([["每日静坐（剩余 %d / 3，+8 修为）" % GameState.meditation_sessions_left(), GameState.meditate, 280, GameState.meditation_sessions_left() <= 0], ["服用灵泉露（+15 修为）", _use_dew, 240]])

func _allocate_attribute(attribute_name: String) -> void:
	if not GameState.allocate_attribute(attribute_name):
		GameState.notify("没有剩余属性点可分配。")
	_render()

func _show_inventory() -> void:
	_heading("行囊 · 装备与法宝")
	var armor_name := str(GameState.player.get("equipped_armor", ""))
	_text("已装备武器：%s｜已装备法宝：%s｜已装备护具：%s" % [GameState.player.equipped_weapon, GameState.player.equipped_artifact, armor_name if not armor_name.is_empty() else "未装备"], 20, Color("f2d79c"))
	_text("当前物品：%s" % "、".join(GameState.player.inventory))
	_line()
	var card_names := {}
	for item_value in GameState.player.inventory:
		var item_name := str(item_value)
		if card_names.has(item_name):
			continue
		card_names[item_name] = true
		var artifact_profile := Catalog.artifact_profile_for_item(item_name)
		if not artifact_profile.is_empty():
			_add_inventory_equipment_card(item_name, artifact_profile, "法宝", item_name == str(GameState.player.get("equipped_artifact", "")))
			continue
		var armor_profile := Catalog.armor_profile_for_item(item_name)
		if not armor_profile.is_empty():
			_add_inventory_equipment_card(item_name, armor_profile, "护具", item_name == str(GameState.player.get("equipped_armor", "")))
			continue
		var footwear_profile := Catalog.footwear_profile_for_item(item_name)
		if not footwear_profile.is_empty():
			_add_inventory_equipment_card(item_name, footwear_profile, "足部护具", item_name == str(GameState.player.get("equipped_footwear", "")))
	_text("首发正式基础器型：每种大类先做一把正式武器，再逐步补大分支、小分支、品级、武器卡、动作和特效。")
	for family in Catalog.WEAPON_FAMILIES:
		var profile: Dictionary = Catalog.weapon_profile_for_item(str(family.starter))
		_text("%s｜%s｜基础器：%s｜派系：%s｜战斗倾向：%s" % [family.name, family.branches, family.starter, family.school, profile.trait], 16)
	_buttons([["录入全部基础器型（本地演示）", _claim_weapon_samples, 300]])
	var equips: Array = []
	for item_name in GameState.player.inventory:
		if "练气" in item_name:
			equips.append(["装备 %s" % item_name, func(): GameState.equip_weapon(item_name), 180])
	if not equips.is_empty(): _buttons(equips)
	var artifact_equips: Array = []
	for item_name in GameState.player.inventory:
		if not Catalog.artifact_profile_for_item(item_name).is_empty():
			artifact_equips.append(["装备法宝 %s" % item_name, func(): GameState.equip_artifact(item_name), 220])
	if not artifact_equips.is_empty(): _buttons(artifact_equips)
	var armor_equips: Array = []
	for item_name in GameState.player.inventory:
		if not Catalog.armor_profile_for_item(item_name).is_empty():
			armor_equips.append(["装备护具 %s" % item_name, func(): GameState.equip_armor(item_name), 220])
	if not armor_equips.is_empty(): _buttons(armor_equips)
	var footwear_equips: Array = []
	for item_name in GameState.player.inventory:
		if not Catalog.footwear_profile_for_item(item_name).is_empty():
			footwear_equips.append(["装备足部 %s" % item_name, func(): GameState.equip_footwear(item_name), 220])
	if not footwear_equips.is_empty(): _buttons(footwear_equips)
	_text("装备强化：同类基础器型可用材料升级，升级属性可随交易一并转移；强化受境界限制。", 16, Color("a7d5ca"))
	_text("村北工坊的祝铁山负责说明强化材料与境界门槛；当前原型可直接在行囊中委托强化。", 16, Color("a7d5ca"))
	var upgrade_buttons: Array = []
	for item_name in GameState.player.inventory:
		if GameState.is_upgradeable_equipment(str(item_name)):
			_text(GameState.equipment_upgrade_text(str(item_name)), 15)
			upgrade_buttons.append(["强化 %s" % str(item_name), func(): GameState.upgrade_equipment(str(item_name)), 210])
	if not upgrade_buttons.is_empty(): _buttons(upgrade_buttons)
	if GameState.player.inventory.has("凝息丹"):
		_buttons([["服用凝息丹（+15 修为）", _use_condensing_pill, 230]])

func _add_inventory_equipment_card(item_name: String, profile: Dictionary, category: String, equipped: bool) -> void:
	var runtime_asset := str(profile.get("runtime_asset", ""))
	if runtime_asset.is_empty() or not ResourceLoader.exists(runtime_asset):
		return
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 128)
	card.add_theme_constant_override("separation", 16)
	content.add_child(card)
	var prop_image := TextureRect.new()
	prop_image.texture = load(runtime_asset) as Texture2D
	prop_image.custom_minimum_size = Vector2(112, 118)
	prop_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	prop_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(prop_image)
	var details := Label.new()
	var equipped_line := "已装备" if equipped else "行囊中"
	details.text = "《%s》｜%s｜%s｜%s\n%s\n%s" % [item_name, category, str(profile.get("quality", "凡品")), equipped_line, str(profile.get("trait", "已登记运行时规则。")), GameState.equipment_upgrade_text(item_name)]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 16)
	card.add_child(details)


func _show_sect() -> void:
	_heading("宗门与身份")
	if GameState.player.sect_id == "":
		_text("当前为散修。可自由加入宗门；初始身份为外门弟子。副本结算与资源进献可获得贡献，达到境界与贡献要求后可申请晋升。")
		for sect in Catalog.SECTS:
			var wanted_note := "｜你正被该宗门通缉" if GameState.is_wanted_by_sect(str(sect.id)) else ""
			_text("【%s】%s｜门规：%s%s" % [sect.name, sect.trait, sect.rule, wanted_note])
			if not str(sect.get("liaison", "")).is_empty():
				_text(str(sect.liaison), 16, Color("a7d5ca"))
			_buttons([["加入 %s" % sect.name, func(): GameState.join_sect(sect.id), 230]])
	else:
		var sect: Dictionary = _find_sect(GameState.player.sect_id)
		_text("当前宗门：%s｜身份：%s｜贡献：%d" % [sect.name, GameState.sect_rank_name(), int(GameState.player.sect_contribution)], 21, Color("f2d79c"))
		_text("%s\n门规：%s" % [sect.trait, sect.rule])
		_text("内门传功：%s。达到内门会登记该功法，但不会强制切换主修。" % str(sect.technique), 16, Color("a7d5ca"))
		if not str(sect.get("liaison", "")).is_empty():
			_text(str(sect.liaison), 16, Color("a7d5ca"))
		var promotion := GameState.sect_promotion_requirement()
		if not promotion.is_empty():
			_text("下一身份：%s｜需要贡献 %d、%s" % [promotion.name, int(promotion.contribution), GameState._realm_requirement_text(promotion)], 16, Color("a7d5ca"))
			_buttons([["申请身份晋升", GameState.try_promote_sect_rank, 220]])
		var contribution_items: Array[String] = []
		for item_name in GameState.player.inventory:
			if item_name != GameState.player.equipped_weapon and not contribution_items.has(item_name):
				contribution_items.append(item_name)
			if contribution_items.size() >= 3:
				break
		for item_name in contribution_items:
			_buttons([["进献 %s" % item_name, func(): GameState.contribute_item_to_sect(item_name), 210]])
		_text("离宗后仍可选择其他道路；部分门规会保留追查或通缉记录。真实多人追捕、赎罪和关系修复将由服务器权威结算。", 15, Color("a7d5ca"))
		_buttons([["退出宗门", GameState.leave_sect, 220]])

func _show_market() -> void:
	_heading("云市 · 自由交易与拍卖行")
	_text("洛清负责云岚村市集的上架、手续费与价格保护；温行客在雾溪渡口解释鉴别标记，并提供归墟雾港拍卖行消息。", 16, Color("a7d5ca"))
	_text("当前金钱：%d｜手续费：5%%（最低 1 金）。当前为本地模拟；真实玩家交易将由服务器校验所有权、上架、成交和反作弊。" % GameState.player.gold, 17, Color("f2d79c"))
	for index in GameState.local_market_listings.size():
		var listing: Dictionary = GameState.local_market_listings[index]
		var purchase_price := GameState.market_purchase_price(index)
		var price_text := "价格 %d 金" % purchase_price
		if purchase_price != int(listing.price):
			price_text += "（关系优惠，标价 %d）" % int(listing.price)
		_text("%s｜%s｜%s" % [listing.name, listing.type, price_text], 18)
		_buttons([["购买", func(): _buy_market_listing(index), 130, GameState.player.gold < purchase_price]])
		if str(listing.seller) == "本地修士":
			_buttons([["撤回上架", func(): _cancel_market_listing(index), 130]])
	_buttons([["上架行囊首件物品（20 金）", _list_first_inventory_item, 280]])

func _show_alchemy() -> void:
	_heading("云岚村 · 炼丹工坊")
	_add_alchemy_pill_card("凝息丹")
	_add_alchemy_pill_card("养元丹")
	_add_alchemy_pill_card("归元丹")
	_text("所有修士都能炼丹；丹修将拥有更高成丹率与更深药性控制。高阶修士服用低阶丹药不会获得有效提升。", 17, Color("f2d79c"))
	_text("初阶配方：雾溪灵草 × 1 + 雾溪药 × 1 → 凝息丹（炼气一至三层有效，使用后 +15 修为）")
	_text("筑基丹方：雾林妖丹 × 1 + 雾潮晶簇 × 3 + 临渊准备材料 × 1（临渊露 / 御崖石屑 / 护脉阵片任选）→ 筑基丹", 18, Color("f2d79c"))
	_buttons([["炼制凝息丹", _craft_condensing_pill, 210], ["炼制筑基丹", _craft_foundation_pill, 210], ["返回行囊", func(): GameState.enter_screen(GameState.Screen.INVENTORY), 160]])
	_buttons([["炼制养元丹", func(): _craft_alchemy_recipe("yangyuan"), 210], ["炼制归元丹", func(): _craft_alchemy_recipe("guiyuan"), 210]])
	_text("普通丹药有成丹率与每日药负；低阶丹药可交易，但高境界服用无效。当前：" + GameState.medicine_burden_text(), 16, Color("a7d5ca"))

func _add_alchemy_pill_card(pill_name: String) -> void:
	var pill_art := Catalog.pill_art_profile_for_item(pill_name)
	if pill_art.is_empty():
		return
	var pill_card := HBoxContainer.new()
	pill_card.custom_minimum_size = Vector2(0, 104)
	pill_card.add_theme_constant_override("separation", 14)
	content.add_child(pill_card)
	var pill_texture := TextureRect.new()
	pill_texture.texture = load(str(pill_art.card_asset)) as Texture2D
	pill_texture.custom_minimum_size = Vector2(96, 96)
	pill_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pill_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pill_card.add_child(pill_texture)
	var pill_details := Label.new()
	pill_details.text = "《%s》\n%s" % [pill_name, str(pill_art.caption)]
	pill_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pill_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill_details.add_theme_font_size_override("font_size", 16)
	pill_card.add_child(pill_details)


func _craft_condensing_pill() -> void:
	GameState.craft_alchemy_recipe("ningxi")
	_render()


func _craft_alchemy_recipe(recipe_id: String) -> void:
	GameState.craft_alchemy_recipe(recipe_id)
	_render()

func _craft_foundation_pill() -> void:
	GameState.craft_foundation_pill()
	_render()

func _show_pvp() -> void:
	_heading("1v1 论剑台")
	if combat.mode != "论剑" or combat.enemy_name != "山门试剑使": combat.begin("论剑", "山门试剑使")
	_text("首发 PVP 最多支持两人。当前为本地对战演示，不代表已经完成实时联网。", 18, Color("f2d79c"))
	_text("玩家 HP：%d / 100｜对手 HP：%d / 100" % [combat.player_hp, combat.enemy_hp], 22, Color.WHITE)
	_text(combat.battle_log)
	_buttons(_combat_entries(true))
	_buttons([["进入可操作论剑场", _open_duel_arena, 220]])
	_text("联网清单：房间匹配、同步、断线处理、服务器权威结算、战绩与反作弊。", 15, Color("a7d5ca"))

func _show_codex() -> void:
	_heading("万物图鉴")
	_text("已发现：%s" % "、".join(GameState.player.codex), 18, Color("f2d79c"))
	_text("首批 NPC：")
	for npc in Catalog.NPCS:
		var npc_name := str(npc.name)
		var npc_profile := Catalog.npc_card_profile_for_name(npc_name)
		if npc_profile.is_empty():
			_text("%s · %s · %s" % [npc.name, npc.role, npc.place], 17)
		else:
			_add_npc_codex_card(npc, npc_profile)
	_line()
	_text("图鉴分类接口：人物、宗门、妖怪、法宝、灵植、资源、地点、副本、功法、事件。")
	_line()
	_heading("功法图鉴")
	var current_technique := str(GameState.player.cultivation_path)
	var art_profile := Catalog.technique_art_profile_for_name(current_technique)
	if art_profile.is_empty():
		_text("当前主修《%s》已记录规则与悟性进度；独立秘卷图尚未验收，因此不复用其他功法图。" % current_technique, 16, Color("a7d5ca"))
	else:
		_add_technique_codex_card(current_technique, art_profile, true)
	var illustrated_names: Array[String] = []
	for technique_name in Catalog.TECHNIQUE_ART_PROFILES:
		var name := str(technique_name)
		illustrated_names.append(name)
		if name != current_technique:
			_add_technique_codex_card(name, Catalog.technique_art_profile_for_name(name))
	_line()
	_heading("完整修行路线")
	for school in Catalog.CULTIVATION_SCHOOLS:
		_text("【%s】" % str(school.faction), 18, Color("f2d79c"))
		for technique_name in school.techniques:
			var name := str(technique_name)
			var affinity := Catalog.technique_affinity_for(name)
			var art_state := "独立秘卷已验收" if illustrated_names.has(name) else "已设定，待单独出图"
			_text("· 《%s》｜%s｜适配 %s / %s｜%s" % [name, str(affinity.label), str(affinity.root), str(affinity.physique), art_state], 16, Color("a7d5ca"))
	_line()
	_heading("炼气丹药图鉴")
	for pill_name in Catalog.PILL_PROFILES:
		var name := str(pill_name)
		var pill_profile := Catalog.pill_art_profile_for_item(name)
		if pill_profile.is_empty():
			var profile: Dictionary = Catalog.PILL_PROFILES.get(name, {})
			_text("《%s》｜%s｜修为 +%d｜药负 +%d｜已设定，待单独出图" % [name, str(profile.get("kind", "丹药")), int(profile.get("cultivation", 0)), int(profile.get("burden", 0))], 16, Color("a7d5ca"))
		else:
			_add_alchemy_pill_card(name)
	_line()
	_heading("法宝与护具图鉴")
	for item_name in Catalog.ARTIFACT_PROFILES:
		_add_equipment_codex_card(str(item_name), Catalog.artifact_profile_for_item(str(item_name)), "法宝")
	_add_equipment_codex_card("照影练气镜", Catalog.artifact_profile_for_item("照影练气镜"), "鉴别法宝")
	for item_name in Catalog.ARMOR_PROFILES:
		_add_equipment_codex_card(str(item_name), Catalog.armor_profile_for_item(str(item_name)), "护具")
	for item_name in Catalog.FOOTWEAR_PROFILES:
		_add_equipment_codex_card(str(item_name), Catalog.footwear_profile_for_item(str(item_name)), "足部护具")
	_line()
	_heading("首发基础器型（均已有独立动作与运行时素材）")
	_text("、".join(Catalog.WEAPON_RUNTIME_PROFILES.keys()), 16, Color("a7d5ca"))


func _add_npc_codex_card(npc: Dictionary, profile: Dictionary) -> void:
	var runtime_asset := str(profile.get("card_asset", ""))
	if runtime_asset.is_empty() or not ResourceLoader.exists(runtime_asset):
		_text("%s · %s · %s" % [npc.name, npc.role, npc.place], 17)
		return
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 182)
	card.add_theme_constant_override("separation", 18)
	content.add_child(card)
	var portrait := TextureRect.new()
	portrait.texture = load(runtime_asset) as Texture2D
	portrait.custom_minimum_size = Vector2(128, 172)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(portrait)
	var details := Label.new()
	var rapport := GameState.npc_rapport(str(npc.name))
	details.text = "《%s》｜%s\n所在地：%s｜势力：%s\n关系：%s（好感 %d）\n交易：%s\n线索：%s" % [str(npc.name), str(npc.role), str(npc.place), str(profile.get("faction", "无")), GameState.npc_relationship_title(str(npc.name)), rapport, str(profile.get("service", "暂无")), str(profile.get("lead", "暂无"))]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 16)
	card.add_child(details)


func _add_technique_codex_card(technique_name: String, art_profile: Dictionary, show_insight := false) -> void:
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 152)
	card.add_theme_constant_override("separation", 18)
	content.add_child(card)
	var manual := TextureRect.new()
	manual.texture = load(str(art_profile.card_asset)) as Texture2D
	manual.custom_minimum_size = Vector2(134, 142)
	manual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	manual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(manual)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(details)
	var title := Label.new()
	title.text = "《%s》" % technique_name
	title.add_theme_font_size_override("font_size", 22)
	title.modulate = Color("f2d79c")
	details.add_child(title)
	var affinity := Catalog.technique_affinity_for(technique_name)
	var description := Label.new()
	var insight_line := GameState.technique_insight_text() if show_insight else "已登记独立秘卷美术，规则可供自由修行切换。"
	description.text = "%s\n%s\n%s" % [str(art_profile.caption), "适配：%s / %s" % [str(affinity.root), str(affinity.physique)], insight_line]
	description.add_theme_font_size_override("font_size", 16)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(0, 108)
	details.add_child(description)


func _add_equipment_codex_card(item_name: String, profile: Dictionary, category: String) -> void:
	var runtime_asset := str(profile.get("runtime_asset", ""))
	if runtime_asset.is_empty() or not ResourceLoader.exists(runtime_asset):
		_text("《%s》｜%s｜尚待独立美术验收。" % [item_name, category], 16, Color("a7d5ca"))
		return
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 112)
	card.add_theme_constant_override("separation", 14)
	content.add_child(card)
	var prop_image := TextureRect.new()
	prop_image.texture = load(runtime_asset) as Texture2D
	prop_image.custom_minimum_size = Vector2(98, 102)
	prop_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	prop_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(prop_image)
	var details := Label.new()
	details.text = "《%s》｜%s｜%s\n%s" % [item_name, category, str(profile.get("quality", "凡品")), str(profile.get("trait", "已登记运行时规则。"))]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 16)
	card.add_child(details)

func _show_settings() -> void:
	_heading("设置与开发状态")
	_text("引擎：Godot 4.7｜目标：微信小游戏优先｜当前：Windows 本地原型。")
	_text("已具备：首发内容数据、完整模块入口、本地修炼/机缘/副本/交易/PVP 演示、本地存档、首批立绘。")
	_text("后续尚需：微信导出验证、服务器、账号、真实多人同步、完整动作帧、数值平衡、音频与云端存档。")
	_buttons([["保存本地进度", _save_local_profile, 190], ["读取本地进度", _load_local_profile, 190]])
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
	# The menu must resume the player's actual region.  Always reopening the
	# starter gate made the large-world regions feel like disconnected demos.
	get_tree().change_scene_to_file(_playable_scene_for_current_region())

func _playable_scene_for_current_region() -> String:
	var scene_by_region := {
		"starter_village": "res://scenes/yunlan_outskirts.tscn",
		"mist_border": "res://scenes/mist_tide_border.tscn",
		"red_maple_ancient_road": "res://scenes/red_maple_ancient_road.tscn",
		"thunder_listening_cliff": "res://scenes/thunder_listening_cliff.tscn",
		"return_abyss_mist_port": "res://scenes/return_abyss_mist_port.tscn",
		"abysswatch_terrace": "res://scenes/abysswatch_terrace.tscn",
		"ancient_ridge": "res://scenes/ancient_ridge.tscn",
	}
	return scene_by_region.get(GameState.current_region_id, "res://scenes/yunlan_outskirts.tscn")

func _explore() -> void:
	# Menu actions cannot mint cultivation or materials. Real opportunities are
	# only resolved at physical regional anchors in the playable world.
	var region := _current_region()
	var hint_by_region := {
		"starter_village": "从云岚外野的灵田、雾溪和云麓疏林探索；雾溪水府位于疏林石阶，村庄只是服务聚落。",
		"mist_border": "进入雾潮边境后，沿雾渠、矿滩和药湿地观察；不同地貌只会出现相应生态。",
		"red_maple_ancient_road": "赤枫古道的机缘应在商路、断桥与火窑遗址附近寻找。",
		"thunder_listening_cliff": "听雷崖的线索集中在崖缘、雷纹石与避风平台，不会平铺在全区。",
		"return_abyss_mist_port": "归墟雾港以潮汐、港道和海穴决定探索内容。",
		"abysswatch_terrace": "临渊台的资源与感悟位于崖道、观想台和阵法残迹周边。",
		"ancient_ridge": "古脊岭的地火、战场残魂与石海遗迹各有地貌边界；请在大地图实地探索。",
	}
	GameState.notify("%s｜%s" % [str(region.name), str(hint_by_region.get(region.id, "请进入可运行大地图寻找可解释的机缘。"))])
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
	GameState.use_cultivation_item("灵泉露", 15, 0, 9)

func _use_condensing_pill() -> void:
	GameState.use_cultivation_item("凝息丹", 15, 0, 3)

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

func _buy_market_listing(index: int) -> void:
	GameState.buy_market_listing(index)


func _connect_local_ten_player_room() -> void:
	OnlineSession.connect_local_room()
	GameState.notify("正在连接本机十人房；请先在项目 server 文件夹执行 npm start。")
	call_deferred("_render")


func _disconnect_ten_player_room() -> void:
	OnlineSession.disconnect_room()
	GameState.notify("已断开本机十人房。")
	call_deferred("_render")
	_render()

func _list_first_inventory_item() -> void:
	if GameState.player.inventory.is_empty():
		GameState.notify("行囊为空，无法上架。")
		return
	GameState.list_item_for_market(str(GameState.player.inventory[0]), 20)
	_render()

func _cancel_market_listing(index: int) -> void:
	GameState.cancel_market_listing(index)
	_render()

func _save_local_profile() -> void:
	GameState.save_local_profile()
	_render()

func _load_local_profile() -> void:
	GameState.load_local_profile()
	_render()

func _open_duel_arena() -> void:
	# This launches the playable local prototype.  It is intentionally separate
	# from the menu combat simulation and makes no claim of online synchrony.
	get_tree().change_scene_to_file("res://scenes/duel_arena.tscn")

func _restart_pvp() -> void:
	combat.begin("论剑", "山门试剑使")
	GameState.notify("已开始本地 1v1 演示。")
	_render()

func _update_notice(text: String) -> void:
	if notice_label: notice_label.text = "提示：%s" % text
