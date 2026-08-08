extends Control

const Catalog = preload("res://src/data/game_catalog.gd")
const CombatStateData = preload("res://src/combat/combat_state.gd")
const StoryWeave = preload("res://src/data/story_weave_catalog.gd")
const OPENING_ORIGIN_IDS: Array[String] = ["tide_listener", "herb_reader", "forge_watcher", "storm_walker", "mirror_keeper"]

var combat := CombatStateData.new()
var selected_gender := "男"
var selected_face := 1
var selected_hair := 1
var selected_root_index := 2
var selected_physique_index := 0
var selected_origin_index := 0
var content: VBoxContainer
var notice_label: Label
var _trade_drafts: Dictionary = {}

func _ready() -> void:
	GameState.screen_changed.connect(func(_screen): _render())
	GameState.profile_changed.connect(_render)
	GameState.notice_changed.connect(_update_notice)
	OnlineSession.connection_state_changed.connect(func(_state):
		if GameState.current_screen == GameState.Screen.OVERWORLD or GameState.current_screen == GameState.Screen.PVP:
			_render()
	)
	OnlineSession.duel_sessions_changed.connect(func(_sessions):
		if GameState.current_screen == GameState.Screen.PVP:
			_render()
	)
	OnlineSession.trade_state_changed.connect(func(_trade):
		if GameState.current_screen == GameState.Screen.MARKET:
			_render()
	)
	OnlineSession.trade_ledger_changed.connect(func(_ledger):
		if GameState.current_screen == GameState.Screen.MARKET:
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
		GameState.Screen.JOURNAL: _show_journal()
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
		GameState.Screen.PVP: "1v1 论剑 · 本机十人房已验证服务器权威同步",
		GameState.Screen.CODEX: "人物、宗门、地区、副本、法宝的收藏与知识库",
		GameState.Screen.JOURNAL: "只记录实际发生的采集、遭遇与发现，不生成任务式伪记录",
		GameState.Screen.SETTINGS: "原型设置与联网状态说明",
	}
	return labels.get(GameState.current_screen, "")

func _add_navigation() -> void:
	var row := HBoxContainer.new()
	row.position = Vector2(430, 37)
	row.size = Vector2(780, 45)
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	for entry in [["洞府", GameState.Screen.HOME], ["世界", GameState.Screen.OVERWORLD], ["修炼", GameState.Screen.REALM], ["行囊", GameState.Screen.INVENTORY], ["炼丹", GameState.Screen.ALCHEMY], ["宗门", GameState.Screen.SECT], ["市集", GameState.Screen.MARKET], ["论剑", GameState.Screen.PVP], ["图鉴", GameState.Screen.CODEX], ["游历", GameState.Screen.JOURNAL]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(74, 40)
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
	var opening_origin := StoryWeave.origin_by_id(OPENING_ORIGIN_IDS[selected_origin_index])
	_text("命途起点：%s｜%s" % [str(opening_origin.get("name", "听潮者")), str(opening_origin.get("summary", ""))], 16, Color("f2d79c"))
	_text("命途只决定你最先容易注意到哪类岚潮线索；不改变灵根、属性、功法、装备或可加入的宗门。", 15, Color("a7d5ca"))
	_buttons([["切换命途起点", _cycle_opening_origin, 200]])
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
	_text("十人同区原型：%s。位置同步、固定数值论剑与双人托管交换均有服务端验证；账号、云端背包与生产级经济仍未接入。" % OnlineSession.state_text(), 15, Color("a7d5ca"))
	_buttons([["连接本机十人房", _connect_local_ten_player_room, 200, OnlineSession.is_room_connected()], ["断开十人房", _disconnect_ten_player_room, 160, not OnlineSession.is_room_connected()]])
	if GameState.player.inventory.has(GameState.EXPLORATION_COMPASS_ITEM):
		var compass_remaining := GameState.convenience_cooldown_remaining(GameState.EXPLORATION_COMPASS_ITEM)
		var compass_text := "探路罗盘可辨识当前区域已有的地形线索；不生成资源、不加修为、不影响战斗。"
		if compass_remaining > 0.0:
			compass_text += " 冷却剩余 %.0f 秒。" % ceilf(compass_remaining)
		_text(compass_text, 16, Color("a7d5ca"))
		_buttons([["使用探路罗盘", _use_exploration_compass, 190, compass_remaining > 0.0]])
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
	_buttons([["进入可运行大地图", _open_playable_world, 240], ["验收时装动作", _open_costume_animation_preview, 200]])
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
	_heading("衣柜 · 不参与任何数值结算")
	var equipped_costume_id := str(GameState.player.get("equipped_costume", ""))
	_text("当前外观：%s。时装不改变角色属性、武器技能、PVP、掉落、交易或副本次数。" % (str(GameState.equipped_costume_profile().get("name", "默认行装"))), 16, Color("f2d79c"))
	var costume_buttons: Array = [["卸下时装", func(): GameState.equip_costume(""), 160, equipped_costume_id.is_empty()]]
	for costume_value in (GameState.player.get("owned_costumes", []) as Array):
		var costume_id := str(costume_value)
		var costume_profile := Catalog.costume_profile_for_id(costume_id)
		if costume_profile.is_empty() or str(costume_profile.get("gender", "")) != str(GameState.player.get("gender", "")):
			continue
		_add_inventory_costume_card(costume_id, costume_profile, costume_id == equipped_costume_id)
		costume_buttons.append(["试穿 %s" % str(costume_profile.name), func(): GameState.equip_costume(costume_id), 200, costume_id == equipped_costume_id])
	_buttons(costume_buttons)
	_text("流岚游衣已接入男体大世界角色层；绛云霓裳仍在补齐八方向动作与武器遮挡。未达动作验收线的时装不会把静态立绘硬贴到地图人物上。", 15, Color("a7d5ca"))
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
			continue
		var weapon_card_profile := Catalog.weapon_card_profile_for_item(item_name)
		if not weapon_card_profile.is_empty():
			_add_inventory_equipment_card(item_name, weapon_card_profile, "武器", item_name == str(GameState.player.get("equipped_weapon", "")))
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


func _add_inventory_costume_card(costume_id: String, profile: Dictionary, equipped: bool) -> void:
	var concept_asset := str(profile.get("concept_asset", ""))
	if concept_asset.is_empty() or not ResourceLoader.exists(concept_asset):
		return
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 205)
	card.add_theme_constant_override("separation", 16)
	content.add_child(card)
	var preview := TextureRect.new()
	preview.texture = load(concept_asset) as Texture2D
	preview.custom_minimum_size = Vector2(124, 190)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(preview)
	var details := Label.new()
	var state := "已试穿" if equipped else "衣柜中"
	details.text = "【%s】｜%s｜%s\n%s\n%s\n%s" % [str(profile.name), str(profile.get("rarity", "外观")), state, str(profile.description), GameState.costume_runtime_status_text(costume_id), str(profile.get("animation_requirement", ""))]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 16)
	card.add_child(details)


func _show_sect() -> void:
	_heading("宗门与身份")
	_text("百草谷传功：雾泽药庐执事·白蘅负责内门传功登记《百草调息篇》；登记不会强制切换玩家主修。", 16, Color("a7d5ca"))
	var met_ning_yuan: bool = GameState.player.npc_met.has("宁远")
	var ning_reflection := GameState.npc_personal_reflection("宁远")
	if met_ning_yuan and not ning_reflection.is_empty():
		_text("接引台见闻：%s" % str(ning_reflection.get("description", "")), 16, Color("f2d79c"))
	var ning_contexts: Array[String] = []
	for record in GameState.personal_story_thread_records():
		if str(record.get("id", "")).begins_with("npc_context_宁远_"):
			ning_contexts.append(str(record.get("description", "")))
	if not ning_contexts.is_empty():
		_text("接引台印证：%s" % "\n".join(ning_contexts), 15, Color("c8d5d1"))
	_text("这些是你亲自结识与选择后留下的解释；加入、离开或无视宗门，都不会使主线失败。", 15, Color("a7d5ca"))
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
		_line()
		_text("山门当期事务（完全自愿，不是主线任务）：", 18, Color("f2d79c"))
		_text("这些事务反映宗门正在关心的商路、边关或药性。你可以忽略、改走其他修行路径，或在合适区域带着材料回来结报。", 15, Color("a7d5ca"))
		for service in GameState.current_sect_services():
			var readiness := "可结报" if bool(service.get("available", false)) else "轮休 %.0f 秒" % ceilf(GameState.sect_service_remaining(str(service.id)))
			var location := "已在对应区域" if bool(service.get("in_region", false)) else "需前往%s" % str(service.get("region_name", "指定区域"))
			_text("【%s】%s｜需 %s｜贡献 +%d｜%s｜%s" % [str(service.get("name", "宗门事务")), str(service.get("brief", "")), str(service.get("item", "材料")), int(service.get("contribution", 0)), location, readiness], 15)
			_buttons([["结报 %s" % str(service.get("name", "事务")), func(): GameState.complete_sect_service(str(service.id)), 240]])
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
		_text("%s｜%s｜%s｜%s" % [listing.name, listing.type, price_text, GameState.market_price_protection_text(str(listing.name))], 18)
		_buttons([["购买", func(): _buy_market_listing(index), 130, GameState.player.gold < purchase_price]])
		if str(listing.seller) == "本地修士":
			_buttons([["撤回上架", func(): _cancel_market_listing(index), 130]])
	if not GameState.player.inventory.is_empty():
		var first_item := str(GameState.player.inventory[0])
		_text("行囊首件：%s｜%s" % [first_item, GameState.market_price_protection_text(first_item)], 16, Color("a7d5ca"))
		_buttons([["按参考价上架行囊首件（%d 金）" % GameState.market_suggested_price(first_item), _list_first_inventory_item, 300]])

	_show_online_trade_session()


func _show_online_trade_session() -> void:
	_heading("十人房 · 双人托管交换（开发期）")
	if not OnlineSession.is_room_connected():
		_text("连接本机十人房后，可向同房修士发起双人交换。当前云市购买仍是本地模拟；该交换由房间服务端暂存报价、双方锁定并原子结算。", 15, Color("a7d5ca"))
		return
	_text("会话账本：%d 金｜本次连接时登记的背包会由服务端校验。没有账号、云存档与正式经济服务前，它只用于本机开发验证。" % int(OnlineSession.trade_ledger().get("gold", GameState.player.gold)), 15, Color("f2d79c"))
	for peer in OnlineSession.remote_players():
		var peer_id := str(peer.get("id", ""))
		var peer_name := str(peer.get("name", "远游修士"))
		_buttons([["向 %s 发起交换" % peer_name, func(): _request_online_trade(peer_id), 210, OnlineSession.local_player_has_trade()]])
	for trade in OnlineSession.trade_states():
		var requester := str(trade.get("requesterId", ""))
		var target := str(trade.get("targetId", ""))
		var trade_id := str(trade.get("id", ""))
		if requester != OnlineSession.local_peer_id() and target != OnlineSession.local_peer_id():
			continue
		var state := str(trade.get("status", ""))
		_text("交换会话 %s｜%s" % [trade_id.right(12), _online_trade_state_label(state)], 15, Color("a7d5ca"))
		if target == OnlineSession.local_peer_id() and state == "pending":
			_buttons([["接受交换", func(): _respond_online_trade(trade_id, true), 140], ["拒绝", func(): _respond_online_trade(trade_id, false), 120]])
		if state == "active":
			var offers: Dictionary = trade.get("offers", {})
			var mine: Dictionary = offers.get(OnlineSession.local_peer_id(), {})
			var other_id := target if requester == OnlineSession.local_peer_id() else requester
			var theirs: Dictionary = offers.get(other_id, {})
			_text("你的报价：%s｜对方报价：%s" % [_online_trade_offer_text(mine), _online_trade_offer_text(theirs)], 15, Color("c8d5d1"))
			_buttons([["以首件非装备物品报价", func(): _offer_first_online_trade_item(trade_id), 220, bool(mine.get("locked", false))], ["锁定我的报价", func(): _lock_online_trade(trade_id), 170, bool(mine.get("locked", false))], ["取消交换", func(): _cancel_online_trade(trade_id), 150]])


			var draft := _trade_draft_for(trade_id)
			_text("拟议报价（可组合物品与灵石，提交前不会改变服务端报价）：%s" % _online_trade_offer_text({"items": draft.get("items", {}), "gold": draft.get("gold", 0), "locked": false}), 15, Color("a7d5ca"))
			for item_name in _online_trade_selectable_items():
				_buttons([["加入 %s ×1" % item_name, func(): _add_online_trade_draft_item(trade_id, item_name), 250, bool(mine.get("locked", false))]])
			_buttons([["拟议灵石 +1", func(): _add_online_trade_draft_gold(trade_id, 1), 150, bool(mine.get("locked", false))], ["拟议灵石 +5", func(): _add_online_trade_draft_gold(trade_id, 5), 150, bool(mine.get("locked", false))], ["清空拟议报价", func(): _clear_online_trade_draft(trade_id), 160, bool(mine.get("locked", false))]])
			_buttons([["提交拟议报价", func(): _submit_online_trade_draft(trade_id), 180, bool(mine.get("locked", false))]])


func _online_trade_offer_text(offer: Dictionary) -> String:
	var item_parts: Array[String] = []
	var raw_items: Variant = offer.get("items", {})
	if raw_items is Dictionary:
		for raw_name in (raw_items as Dictionary).keys():
			item_parts.append("%s×%d" % [str(raw_name), int((raw_items as Dictionary).get(raw_name, 0))])
	var parts: Array[String] = item_parts
	if int(offer.get("gold", 0)) > 0:
		parts.append("%d 金" % int(offer.get("gold", 0)))
	if parts.is_empty():
		parts.append("空报价")
	if bool(offer.get("locked", false)):
		parts.append("已锁定")
	return "、".join(parts)


func _online_trade_state_label(state: String) -> String:
	match state:
		"pending": return "等待回应"
		"active": return "正在报价"
		"completed": return "已完成"
		"declined": return "已拒绝"
		"cancelled": return "已取消"
		_: return state


func _request_online_trade(peer_id: String) -> void:
	if not OnlineSession.request_trade(peer_id):
		GameState.notify("无法发起交换：请确认双方已连接且没有其他活跃交换。")
	_render()


func _respond_online_trade(trade_id: String, accept: bool) -> void:
	OnlineSession.respond_to_trade(trade_id, accept)
	_render()


func _offer_first_online_trade_item(trade_id: String) -> void:
	var chosen := ""
	for raw_item in GameState.player.inventory:
		var item_name := str(raw_item)
		if item_name != GameState.player.equipped_weapon and item_name != GameState.player.equipped_artifact and item_name != GameState.player.equipped_armor:
			chosen = item_name
			break
	if chosen.is_empty():
		GameState.notify("当前没有可用于交换的非装备物品。")
		return
	OnlineSession.offer_trade(trade_id, {chosen: 1}, 0)
	_render()


func _lock_online_trade(trade_id: String) -> void:
	OnlineSession.lock_trade(trade_id)
	_render()


func _cancel_online_trade(trade_id: String) -> void:
	OnlineSession.cancel_trade(trade_id)
	_render()


func _trade_draft_for(trade_id: String) -> Dictionary:
	var existing: Variant = _trade_drafts.get(trade_id, {})
	if existing is Dictionary:
		var draft: Dictionary = existing
		if draft.has("items") and draft.get("items") is Dictionary:
			return draft.duplicate(true)
	return {"items": {}, "gold": 0}


func _store_trade_draft(trade_id: String, draft: Dictionary) -> void:
	_trade_drafts[trade_id] = draft.duplicate(true)


func _online_trade_selectable_items() -> Array[String]:
	var result: Array[String] = []
	for raw_item in GameState.player.inventory:
		var item_name := str(raw_item)
		if item_name.is_empty() or item_name == GameState.player.equipped_weapon or item_name == GameState.player.equipped_artifact or item_name == GameState.player.equipped_armor or result.has(item_name):
			continue
		result.append(item_name)
	return result


func _add_online_trade_draft_item(trade_id: String, item_name: String) -> void:
	var draft := _trade_draft_for(trade_id)
	var items: Dictionary = draft.get("items", {})
	items[item_name] = int(items.get(item_name, 0)) + 1
	draft.items = items
	_store_trade_draft(trade_id, draft)
	_render()


func _add_online_trade_draft_gold(trade_id: String, amount: int) -> void:
	var draft := _trade_draft_for(trade_id)
	draft.gold = min(int(GameState.player.gold), max(0, int(draft.get("gold", 0)) + amount))
	_store_trade_draft(trade_id, draft)
	_render()


func _clear_online_trade_draft(trade_id: String) -> void:
	_trade_drafts.erase(trade_id)
	_render()


func _submit_online_trade_draft(trade_id: String) -> void:
	var draft := _trade_draft_for(trade_id)
	OnlineSession.offer_trade(trade_id, draft.get("items", {}), int(draft.get("gold", 0)))
	_render()


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
	_text("首发 PVP 最多支持两人。本地论剑保留完整武器动作测试；本机十人房已接入服务器裁定的公平联机论剑原型。", 18, Color("f2d79c"))
	if OnlineSession.is_room_connected():
		_text("十人房论剑会话：服务器只允许一名挑战者与一名被挑战者进入同一会话；位置、攻击距离、冷却、血量与胜负均由服务端裁定。", 16, Color("a7d5ca"))
		for peer in OnlineSession.remote_players():
			var peer_id := str(peer.get("id", ""))
			var peer_name := str(peer.get("name", "远游修士"))
			_buttons([["挑战 %s" % peer_name, func(): _request_online_duel(peer_id), 190, OnlineSession.local_player_has_duel()]])
		for duel in OnlineSession.duel_sessions():
			var challenger := str(duel.get("challengerId", ""))
			var target := str(duel.get("targetId", ""))
			var state := "等待回应" if str(duel.get("status", "")) == "pending" else ("可进入联机论剑" if str(duel.get("status", "")) == "active" else "论剑已结束")
			_text("论剑会话 %s：%s ↔ %s｜%s" % [str(duel.get("id", "")).right(12), challenger.left(8), target.left(8), state], 15, Color("a7d5ca"))
			if target == OnlineSession.local_peer_id() and str(duel.get("status", "")) == "pending":
				_buttons([["接受挑战", func(): _respond_online_duel(str(duel.get("id", "")), true), 140], ["拒绝", func(): _respond_online_duel(str(duel.get("id", "")), false), 120]])
			if str(duel.get("status", "")) == "active" and (challenger == OnlineSession.local_peer_id() or target == OnlineSession.local_peer_id()):
				_buttons([["进入联机论剑场", _open_online_duel_arena, 210]])
	else:
		_text("连接本机十人房后，可验证服务器管理的双人挑战、移动、攻击距离、冷却、血量与胜负。", 16, Color("a7d5ca"))
	_text("玩家 HP：%d / 100｜对手 HP：%d / 100" % [combat.player_hp, combat.enemy_hp], 22, Color.WHITE)
	_text(combat.battle_log)
	_buttons(_combat_entries(true))
	_buttons([["进入可操作论剑场", _open_duel_arena, 220]])
	_text("已完成：本机十人房、双人挑战、服务端位置/距离/冷却/HP/胜负裁定。待完善：匹配、断线重连、账号鉴权、战绩排行、装备与功法快照、反作弊与生产部署。", 15, Color("a7d5ca"))

func _show_journal() -> void:
	_heading("游历簿")
	_text("只保留角色真实获得、观察或击退的世界记录；不会因为点击菜单、查看地图或接近一个区域而凭空产生奖励。为保持本地存档轻量，最多保留最近 %d 条。" % GameState.MAX_OPPORTUNITY_LOG_ENTRIES, 16, Color("a7d5ca"))
	_line()
	var story_profile := GameState.personal_story_profile()
	var story_stage := GameState.personal_story_stage()
	_heading("岚潮线索 · %s" % str(story_stage.get("name", "岚潮初闻")))
	_text(str(story_stage.get("summary", "")), 17, Color("f2d79c"))
	_text("你的命途起点：%s｜%s" % [str(story_profile.get("label", "尚待真实发现")), str(story_profile.get("summary", ""))], 16, Color("a7d5ca"))
	var marks: Array = GameState.personal_story_mark_labels()
	_text("已由真实游历印证的世界痕迹：%s。它们只更新叙事认知，不提供数值奖励或强制目标。" % ("、".join(marks) if not marks.is_empty() else "尚未形成"), 15, Color("a7d5ca"))
	if str(story_stage.get("id", "")) == "old_boundary":
		var stance := GameState.personal_story_stance()
		if stance.is_empty():
			_text("旧界回声已足以让你作出暂时判断。选择只改变线索角度，不锁宗门、不送数值、不影响任何玩法，也可稍后改写。", 15, Color("f2d79c"))
			_buttons([["守界：先护地脉与人间", func(): _choose_personal_story_stance("mender"), 240], ["溯源：先追旧界来处", func(): _choose_personal_story_stance("seeker"), 240], ["观变：先记录世界变化", func(): _choose_personal_story_stance("witness"), 240]])
		else:
			_text("你当前的判断：%s｜%s" % [str(stance.get("name", "观变")), str(stance.get("summary", ""))], 16, Color("f2d79c"))
			_buttons([["改为守界", func(): _choose_personal_story_stance("mender"), 150], ["改为溯源", func(): _choose_personal_story_stance("seeker"), 150], ["改为观变", func(): _choose_personal_story_stance("witness"), 150]])
	var branch_records := GameState.personal_story_branch_records()
	if not branch_records.is_empty():
		_text("你的个人回响（保留已亲历的见闻；改变判断不会抹去它们）：", 16, Color("f2d79c"))
		for record in branch_records:
			_text("· %s｜%s" % [str(record.get("title", "个人回响")), str(record.get("description", ""))], 15, Color("c8d5d1"))
	var thread_records := GameState.personal_story_thread_records()
	if not thread_records.is_empty():
		_text("你亲自织入的世界支线（不构成任务清单）：", 16, Color("f2d79c"))
		for record in thread_records:
			_text("· 【%s】%s｜%s" % [_story_thread_name(str(record.get("thread", ""))), str(record.get("title", "世界经历")), str(record.get("description", ""))], 15, Color("c8d5d1"))
	if GameState.is_personal_story_paused():
		_text("线索提示已暂缓；你仍会正常探索并留下游历记录。", 15, Color("82908c"))
	else:
		for lead in GameState.personal_story_leads():
			_text("· %s" % lead, 15, Color("c8d5d1"))
	_buttons([["恢复线索提示" if GameState.is_personal_story_paused() else "暂缓线索提示", _toggle_personal_story_pause, 190]])
	_text("可交错探索的支线网：", 16, Color("f2d79c"))
	for thread in GameState.personal_story_side_threads():
		_text("【%s】%s｜%s" % [str(thread.get("name", "支线")), str(thread.get("source", "")), str(thread.get("description", ""))], 15, Color("a7d5ca"))
	_line()
	var entries := GameState.recent_opportunities(18)
	if entries.is_empty():
		_text("尚未留下游历记录。走入大世界、采集灵材、完成副本或发现地标后，这里才会出现内容。", 18, Color("f2d79c"))
		return
	for entry in entries:
		var place := _journal_region_name(str(entry.get("region", "")))
		var label := _journal_kind_name(str(entry.get("kind", "exploration")))
		var title := str(entry.get("name", entry.get("title", "未命名发现")))
		var timestamp := str(entry.get("recorded_at", "早期存档"))
		var description := str(entry.get("description", ""))
		var observation_text := "\n见闻：%s" % description if not description.is_empty() else ""
		_text("【%s】%s · %s\n%s%s%s" % [label, title, place, _journal_reward_text(entry), observation_text, "\n记录：%s" % timestamp], 17, Color("f2d79c"))
		_line()


func _toggle_personal_story_pause() -> void:
	GameState.toggle_personal_story_pause()
	_render()


func _choose_personal_story_stance(stance_id: String) -> void:
	GameState.choose_personal_story_stance(stance_id)
	_render()

func _journal_region_name(region_id: String) -> String:
	for region in Catalog.REGIONS:
		if str(region.get("id", "")) == region_id:
			return str(region.get("name", region_id))
	if Catalog.DUNGEONS.has(region_id):
		return str((Catalog.DUNGEONS[region_id] as Dictionary).get("name", region_id))
	return region_id if not region_id.is_empty() else "未知地点"

func _journal_kind_name(kind: String) -> String:
	var labels := {
		"resource": "采集", "hostile_defeated": "遭遇", "starter_weapon_trial": "试兵",
		"fixed_dungeon_entrance": "入口", "fixed_relic": "遗迹", "high_realm_lore": "见闻",
		"port_rumor": "传闻", "foundation_preparation": "观想", "story_observation": "岚潮见闻", "personal_opportunity": "偶遇机缘", "exploration": "探索",
	}
	return str(labels.get(kind, "机缘"))


func _story_thread_name(thread_id: String) -> String:
	var labels := {"market": "行商之网", "craft": "丹火器纹", "companions": "人间回音", "sect": "山门立场"}
	return str(labels.get(thread_id, "自由游历"))

func _journal_reward_text(entry: Dictionary) -> String:
	var rewards: Array[String] = []
	var item_name := str(entry.get("item", ""))
	if not item_name.is_empty():
		rewards.append(item_name)
	var items: Variant = entry.get("items", [])
	if items is Array:
		for item in items:
			if not rewards.has(str(item)):
				rewards.append(str(item))
	var cultivation := int(entry.get("cultivation", 0))
	var stones := int(entry.get("stones", 0))
	var text := "获得：%s" % ("、".join(rewards) if not rewards.is_empty() else "无实物奖励")
	if cultivation > 0:
		text += "｜修为 +%d" % cultivation
	if stones > 0:
		text += "｜灵石 +%d" % stones
	return text

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
	_heading("区域生态图鉴")
	_text("生态卡记录的是“会在哪里、为什么会在那里、能如何互动”，并不代表所有对象同时出现。每次进入区域只从合理生态位选择少量实体。", 16, Color("a7d5ca"))
	for profile_id in Catalog.ECOLOGY_CARD_ORDER:
		var ecology_profile := Catalog.ecology_card_profile_for_id(str(profile_id))
		if not ecology_profile.is_empty():
			_add_ecology_codex_card(ecology_profile)
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
	_heading("首发基础器型 · 武器卡")
	_text("每个大类的首把正式武器均有独立运行时图标、动作控制器和技能组；未复用其他器型的外观或攻击规则。", 16, Color("a7d5ca"))
	for family in Catalog.WEAPON_FAMILIES:
		var starter_name := str(family.starter)
		var weapon_card_profile := Catalog.weapon_card_profile_for_item(starter_name)
		_add_equipment_codex_card(starter_name, weapon_card_profile, "%s · %s" % [str(family.name), str(family.school)])


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
	var npc_name := str(npc.name)
	var rapport := GameState.npc_rapport(npc_name)
	var has_met: bool = GameState.player.npc_met.has(npc_name)
	var personal_reflection := GameState.npc_personal_reflection(npc_name)
	var relationship_label := GameState.npc_relationship_title(npc_name) if has_met else "未相识"
	details.text = "《%s》｜%s\n所在地：%s｜势力：%s\n关系：%s（好感 %d）\n交易：%s\n线索：%s" % [str(npc.name), str(npc.role), str(npc.place), str(profile.get("faction", "无")), relationship_label, rapport, str(profile.get("service", "暂无")), str(profile.get("lead", "暂无"))]
	if has_met and not personal_reflection.is_empty():
		details.text += "\n你的见闻：%s" % str(personal_reflection.get("description", ""))
	elif not has_met and not personal_reflection.is_empty():
		details.text += "\n你的见闻：尚待亲自结识；图鉴不会替你预先写下这段经历。"
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 16)
	card.add_child(details)


func _add_ecology_codex_card(profile: Dictionary) -> void:
	var runtime_asset := str(profile.get("card_asset", ""))
	if runtime_asset.is_empty() or not ResourceLoader.exists(runtime_asset):
		_text("《%s》｜%s｜%s" % [str(profile.get("name", "未知生态")), str(profile.get("category", "生态")), str(profile.get("region", "未知区域"))], 16, Color("a7d5ca"))
		return
	var card := HBoxContainer.new()
	card.custom_minimum_size = Vector2(0, 148)
	card.add_theme_constant_override("separation", 16)
	content.add_child(card)
	var portrait := TextureRect.new()
	portrait.texture = load(runtime_asset) as Texture2D
	portrait.custom_minimum_size = Vector2(116, 138)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(portrait)
	var details := Label.new()
	details.text = "《%s》｜%s\n区域：%s\n栖息/出现：%s\n交互：%s\n产出：%s" % [str(profile.get("name", "未知生态")), str(profile.get("category", "生态")), str(profile.get("region", "未知区域")), str(profile.get("appearance", "暂无")), str(profile.get("interaction", "暂无")), str(profile.get("reward", "暂无"))]
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_font_size_override("font_size", 15)
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
	_text("后续尚需：微信导出验证、账号与云端存档、生产级多人区域同步、完整动作帧、数值平衡、音频与正式交易服务。")
	_heading("首发月卡边界（本地规则验证）")
	_text(GameState.monthly_card_status_text(), 17, Color("f2d79c"))
	_text("今日固定副本剩余 %d / %d 次。免费玩家每日 3 次；小月卡 ¥30/月为 4 次，大月卡 ¥98/月为 5 次。" % [GameState.fixed_dungeon_attempts_remaining(), GameState.daily_fixed_dungeon_limit()])
	_text("仅可额外获得极少量常规材料，并缩短回城符、探索罗盘等便利物品冷却。不会改变攻击、防御、技能冷却、修炼、炼丹、资源刷新、PVP、市场价格保护或 5%% 交易手续费。", 16, Color("c7d8d2"))
	_text("下列按钮只用于 Windows 本地原型验证，既不会扣款，也不代表已接入支付。正式上线需由微信支付与账号服务器签发权益。", 15, Color("a5b4bf"))
	_buttons([["本地模拟小月卡", func(): _set_local_monthly_card_test("small"), 180], ["本地模拟大月卡", func(): _set_local_monthly_card_test("large"), 180], ["关闭本地测试权益", func(): _set_local_monthly_card_test("none"), 190]])
	_buttons([["保存本地进度", _save_local_profile, 190], ["读取本地进度", _load_local_profile, 190]])
	_buttons([["返回洞府", func(): GameState.enter_screen(GameState.Screen.HOME), 160], ["重新创建角色", func(): GameState.enter_screen(GameState.Screen.CHARACTER_SELECT), 180]])


func _set_local_monthly_card_test(tier: String) -> void:
	if not GameState.set_local_monthly_card_test_entitlement(tier):
		return
	GameState.notify("已切换本地测试权益：%s。未发生支付；PVP、交易税和战斗数值不受影响。" % str(GameState.monthly_card_benefits().label))
	_render()

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

func _cycle_opening_origin() -> void:
	selected_origin_index = (selected_origin_index + 1) % OPENING_ORIGIN_IDS.size()
	_render()

func _confirm_character() -> void:
	if not GameState.choose_personal_story_origin(OPENING_ORIGIN_IDS[selected_origin_index]):
		return
	GameState.update_character(selected_gender, selected_face, selected_hair)
	GameState.update_innate(Catalog.SPIRIT_ROOTS[selected_root_index].name, Catalog.PHYSIQUES[selected_physique_index].name)
	GameState.notify("角色创建完成。你的命途起点只会影响最先遇见的岚潮线索，云岚村正等待你的第一次探索。")
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


func _open_costume_animation_preview() -> void:
	get_tree().change_scene_to_file("res://scenes/costume_animation_preview.tscn")

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


func _use_exploration_compass() -> void:
	var result := GameState.use_exploration_compass(str(_current_region().id))
	if not bool(result.get("ok", false)):
		GameState.notify(str(result.get("message", "探路罗盘暂时无法辨向。")))
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
	var item_name := str(GameState.player.inventory[0])
	GameState.list_item_for_market(item_name, GameState.market_suggested_price(item_name))
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


func _open_online_duel_arena() -> void:
	if OnlineSession.active_duel_for_local().is_empty():
		GameState.notify("当前没有可进入的联机论剑会话。")
		_render()
		return
	get_tree().change_scene_to_file("res://scenes/online_duel_arena.tscn")

func _restart_pvp() -> void:
	combat.begin("论剑", "山门试剑使")
	GameState.notify("已开始本地 1v1 演示。")
	_render()


func _request_online_duel(peer_id: String) -> void:
	if not OnlineSession.request_duel(peer_id):
		GameState.notify("当前无法发起论剑挑战。")
	_render()


func _respond_online_duel(duel_id: String, accept: bool) -> void:
	if not OnlineSession.respond_to_duel(duel_id, accept):
		GameState.notify("该论剑挑战已失效。")
	_render()

func _update_notice(text: String) -> void:
	if notice_label: notice_label.text = "提示：%s" % text
