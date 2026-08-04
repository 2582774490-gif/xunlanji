extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_manual_progression()
	await _check_local_profile_payload()
	await _check_cultivation_affinity()
	await _check_sect_progression()
	await _check_wanted_patrol()
	await _check_weapon_combat_profiles()
	await _check_weapon_render_slot()
	await _check_local_market_loop()
	await _check_random_opportunity()
	await _check_village_routes()
	await _check_water_palace_loop()
	await _check_mist_border_scene()
	await _check_mist_bone_creek()
	await _check_mist_forest_grove()
	await _check_sunken_vessel_manor()
	await _check_mist_tide_stone_grotto()
	await _check_red_maple_ancient_road()
	await _check_world_population_encounter()
	await _check_thunder_listening_cliff()
	await _check_return_abyss_mist_port()
	await _check_abysswatch_terrace()
	await _check_ancient_ridge()
	await _check_earthfire_cave()
	await _check_world_menu_region_resume()
	if failures.is_empty():
		print("RUNTIME_SMOKE_PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)

func _check_manual_progression() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	GameState.player.cultivation = GameState.cultivation_threshold() - 1
	GameState.gain_cultivation(20)
	_expect(GameState.player.minor_stage == 1, "Cultivation should not auto-break through when the pool becomes full.")
	_expect(GameState.can_attempt_breakthrough(), "Full cultivation should enable manual breakthrough.")
	_expect(GameState.try_breakthrough(), "Qi Refining small-stage manual breakthrough should succeed without materials.")
	_expect(GameState.player.minor_stage == 2 and GameState.player.cultivation == 0, "Manual small-stage breakthrough did not advance exactly one stage.")
	GameState.player.minor_stage = 10
	GameState.player.cultivation = GameState.cultivation_threshold()
	_expect(not GameState.try_breakthrough(), "Foundation breakthrough should require its dedicated materials.")
	GameState.player.inventory.append("雾林妖丹")
	GameState.player.inventory.append("雾潮晶簇")
	GameState.player.inventory.append("雾潮晶簇")
	GameState.player.inventory.append("雾潮晶簇")
	_expect(not GameState.craft_foundation_pill(), "Foundation pill should require one preparation item from the ninth-layer route or trade.")
	GameState.player.inventory.append("临渊露")
	_expect(GameState.craft_foundation_pill(), "Foundation pill should be craftable from its forest and border materials.")
	_expect(GameState.player.inventory.has("筑基丹"), "Foundation-pill craft did not add the item to inventory.")
	_expect(GameState.try_breakthrough(), "Foundation breakthrough should succeed after materials are prepared.")
	_expect(GameState.player.realm_index == 1 and GameState.player.minor_stage == 1, "Foundation breakthrough did not move to the first Foundation stage.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_local_profile_payload() -> void:
	var player_before: Dictionary = GameState.player.duplicate(true)
	var listings_before: Array = GameState.local_market_listings.duplicate(true)
	var region_before: String = GameState.current_region_id
	var dungeon_before: String = GameState.selected_dungeon_id
	GameState.player.gold = 177
	GameState.player.inventory.append("存档烟测材料")
	GameState.current_region_id = "return_abyss_mist_port"
	GameState.selected_dungeon_id = "abysswatch_terrace"
	var payload := GameState.export_local_profile()
	GameState.player.gold = 1
	GameState.player.inventory.clear()
	GameState.current_region_id = "starter_village"
	_expect(GameState.apply_local_profile(payload), "Local profile payload should restore valid saved state.")
	_expect(GameState.player.gold == 177 and GameState.player.inventory.has("存档烟测材料"), "Local profile payload did not restore player inventory and currency.")
	_expect(GameState.current_region_id == "return_abyss_mist_port" and GameState.selected_dungeon_id == "abysswatch_terrace", "Local profile payload did not restore world resume state.")
	GameState.player = player_before
	GameState.local_market_listings = listings_before
	GameState.current_region_id = region_before
	GameState.selected_dungeon_id = dungeon_before

func _check_sect_progression() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.sect_id = ""
	GameState.player.sect_rank = 0
	GameState.player.sect_contribution = 0
	GameState.player.sect_wanted_by = []
	GameState.player.inventory.append("宗门测试贡品")
	_expect(GameState.join_sect("mist_sword"), "Player should freely join an available sect.")
	_expect(GameState.sect_rank_name() == "外门弟子", "Sect join should begin at outer disciple rank.")
	_expect(GameState.contribute_item_to_sect("宗门测试贡品"), "Sect contribution should accept a carried material.")
	_expect(int(GameState.player.sect_contribution) >= 6 and not GameState.player.inventory.has("宗门测试贡品"), "Sect contribution did not consume the offered material and award contribution.")
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 6
	GameState.player.sect_contribution = 80
	_expect(GameState.try_promote_sect_rank(), "Outer disciple with sufficient realm and contribution should promote.")
	_expect(GameState.sect_rank_name() == "内门弟子", "Sect promotion did not reach inner disciple rank.")
	_expect(GameState.leave_sect(), "Player should be able to freely leave a sect.")
	_expect(GameState.is_wanted_by_sect("mist_sword"), "Leaving Mist Sword at inner rank should preserve a sect wanted record.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_cultivation_affinity() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.spirit_root = "火灵根"
	GameState.player.physique = "赤阳髓"
	GameState.player.cultivation_path = "赤焰炼息法"
	GameState.player.learned_techniques = ["赤焰炼息法"]
	_expect(GameState.cultivation_efficiency_multiplier() >= 1.16, "Matching spirit root and physique should improve cultivation efficiency.")
	GameState.choose_cultivation_path("三折剑经")
	_expect(GameState.player.learned_techniques.has("三折剑经") and GameState.player.cultivation_path == "三折剑经", "Player should be able to learn and switch to another cultivation path.")
	_expect(GameState.cultivation_efficiency_multiplier() >= 1.0, "Mismatched paths must remain playable rather than being blocked.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_wanted_patrol() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.sect_wanted_by = ["mist_sword"]
	var border := preload("res://scenes/mist_tide_border.tscn").instantiate()
	add_child(border)
	await get_tree().process_frame
	var patrol: Area2D = border.regional_population.interaction_for_profile_id("mist_sword_patrol")
	_expect(patrol != null, "Mist Sword wanted status did not place a patrol at its border jurisdiction.")
	if patrol != null:
		border.regional_population.resolve(patrol)
		_expect(border.world_encounter.is_in_encounter(), "Wanted patrol did not start an overworld encounter when confronted.")
	border.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()
	GameState.profile_changed.emit()

func _check_weapon_combat_profiles() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	_expect(GameCatalog.WEAPON_COMBAT_PROFILES.size() == GameCatalog.WEAPON_FAMILIES.size(), "Every launch weapon family needs a combat profile.")
	GameState.player.inventory = ["青篁练气剑", "开山练气斧", "回云练气伞"]
	GameState.equip_weapon("青篁练气剑")
	var sword_combat := CombatState.new()
	sword_combat.begin("测试", "木桩")
	sword_combat.normal_attack()
	var sword_damage := 100 - sword_combat.enemy_hp
	GameState.equip_weapon("开山练气斧")
	var axe_combat := CombatState.new()
	axe_combat.begin("测试", "木桩")
	axe_combat.normal_attack()
	var axe_damage := 100 - axe_combat.enemy_hp
	_expect(axe_damage > sword_damage, "Heavy axe profile should deal more opening damage than sword profile.")
	GameState.equip_weapon("回云练气伞")
	var umbrella_combat := CombatState.new()
	umbrella_combat.begin("测试", "木桩")
	umbrella_combat.normal_attack()
	_expect(umbrella_combat.player_hp > axe_combat.player_hp, "Defensive umbrella profile should reduce counter damage.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_weapon_render_slot() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.inventory.append("青篁练气剑")
	GameState.equip_weapon("青篁练气剑")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.has_node("WeaponPivot/WeaponSprite"), "Equipped Qinghuang Sword did not create an independent player weapon render slot.")
	var weapon_sprite: Sprite2D = port.player.get_node("WeaponPivot/WeaponSprite")
	_expect(weapon_sprite.texture != null, "Equipped Qinghuang Sword render slot has no sword texture.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_local_market_loop() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	var listings_before: Array = GameState.local_market_listings.duplicate(true)
	GameState.player.inventory = ["烟测交易材"]
	GameState.player.gold = 100
	_expect(GameState.list_item_for_market("烟测交易材", 20), "Local market should accept an owned item within its protected price range.")
	_expect(not GameState.player.inventory.has("烟测交易材") and GameState.player.gold == 99, "Market listing should remove the item and charge its minimum fee.")
	var listing_index := GameState.local_market_listings.size() - 1
	_expect(GameState.buy_market_listing(listing_index), "Local market should complete a listed-item purchase.")
	_expect(GameState.player.inventory.has("烟测交易材") and GameState.player.gold == 79, "Market purchase should deliver the item and charge the listing price.")
	_expect(GameState.list_item_for_market("烟测交易材", 20), "Local market should allow a purchased item to be listed again.")
	var cancel_index := GameState.local_market_listings.size() - 1
	_expect(GameState.cancel_market_listing(cancel_index), "Local market should allow the seller to withdraw their own listing.")
	_expect(GameState.player.inventory.has("烟测交易材") and GameState.player.gold == 78, "Listing cancellation should return the item but retain the listing fee.")
	GameState.player = profile_before
	GameState.local_market_listings = listings_before
	GameState.profile_changed.emit()

func _check_random_opportunity() -> void:
	var log_before: int = GameState.player.opportunity_log.size()
	var south_gate := preload("res://scenes/yunlan_south_gate.tscn").instantiate()
	add_child(south_gate)
	await get_tree().process_frame
	_expect(south_gate.chosen_opportunity.size() > 0, "South Gate did not select a random opportunity.")
	south_gate.active_interaction = south_gate.opportunity_interaction
	south_gate._activate_interaction()
	_expect(south_gate.opportunity_collected, "Opportunity interaction did not collect the world object.")
	_expect(GameState.player.opportunity_log.size() == log_before + 1, "Opportunity collection did not write a log record.")
	south_gate.queue_free()
	await get_tree().process_frame

func _check_village_routes() -> void:
	var village := preload("res://scenes/yunlan_village.tscn").instantiate()
	add_child(village)
	await get_tree().process_frame
	_expect(village.sect_envoy != null, "Village is missing the physical sect envoy route.")
	village._set_context("sect", "test")
	_expect(village.active_interaction_id == "sect", "Village sect route did not use the shared contextual interaction path.")
	village.queue_free()
	await get_tree().process_frame

func _check_water_palace_loop() -> void:
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	var palace := preload("res://scenes/mist_stream_water_palace.tscn").instantiate()
	add_child(palace)
	await get_tree().process_frame
	palace.near_boss = true
	var health_before: int = palace.boss_health
	palace._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(palace.boss_health < health_before, "Ningxi Sword Art did not damage the Water Palace boss.")
	palace._defeat_boss()
	await get_tree().process_frame
	_expect(palace.defeated and not palace.boss.visible, "Boss clear did not close the encounter.")
	_expect(palace.clear_panel.visible, "Boss clear did not show a settlement panel.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Boss clear did not grant one initial-equipment drop.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Boss clear did not record the dungeon run.")
	_expect(GameState.is_region_unlocked("mist_border"), "Water Palace clear did not unlock Mist Tide Border.")
	palace.queue_free()
	await get_tree().process_frame

func _check_mist_border_scene() -> void:
	var inventory_before: int = GameState.player.inventory.size()
	var border := preload("res://scenes/mist_tide_border.tscn").instantiate()
	add_child(border)
	await get_tree().process_frame
	_expect(GameState.current_region_id == "mist_border", "Mist Tide Border scene did not set the active region.")
	_expect(border.player.map_bounds.size.x >= 3000.0, "Mist Tide Border did not create a larger regional movement space.")
	_expect(border.return_interaction != null, "Mist Tide Border is missing the return route interaction.")
	_expect(border.scout_interaction != null, "Mist Tide Border is missing its first border-scout NPC route.")
	_expect(border.creek_gate_interaction != null, "Mist Tide Border is missing the Qi Refining third-layer creek entrance.")
	_expect(border.vessel_gate_interaction != null, "Mist Tide Border is missing the Qi Refining fourth-layer vessel entrance.")
	_expect(border.grotto_gate_interaction != null, "Mist Tide Border is missing the Qi Refining fifth-layer grotto entrance.")
	_expect(border.red_maple_gate_interaction != null, "Mist Tide Border is missing the Qi Refining sixth-layer Red Maple Road entrance.")
	_expect(border.thunder_cliff_gate_interaction != null, "Mist Tide Border is missing the Qi Refining seventh-layer Thunder Listening Cliff entrance.")
	_expect(border.mist_port_gate_interaction != null, "Mist Tide Border is missing the Qi Refining eighth-layer Return Abyss Mist Port entrance.")
	_expect(border.abysswatch_gate_interaction != null, "Mist Tide Border is missing the Qi Refining ninth-layer Abysswatch Terrace entrance.")
	_expect(border.ancient_ridge_gate_interaction != null, "Mist Tide Border is missing the Yuan Infant Ancient Ridge entrance.")
	_expect(border.player.map_bounds.size.x >= 11000.0, "Mist Tide Border still behaves like a single small background instead of a large region.")
	_expect(border.chunk_streamer.loaded_chunk_count() >= 1, "Mist Tide Border did not load its nearby high-detail terrain chunk.")
	var border_player_start: Vector2 = border.player.position
	border.player.position = Vector2(11200, 7200)
	await get_tree().process_frame
	_expect(not border.get_node("Terrain").visible, "The terrain chunk streamer did not unload far-away high-detail art.")
	border.player.position = border_player_start
	await get_tree().process_frame
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	_expect(not border.can_enter_mist_forest(), "Mist Forest should remain locked for first-layer Qi Refining.")
	GameState.player.minor_stage = 2
	_expect(border.can_enter_mist_forest(), "Mist Forest should open at second-layer Qi Refining.")
	_expect(not border.can_enter_mist_bone_creek(), "Mist Bone Creek should wait until third-layer Qi Refining.")
	GameState.player.minor_stage = 3
	_expect(border.can_enter_mist_bone_creek(), "Mist Bone Creek should open at third-layer Qi Refining.")
	_expect(not border.can_enter_sunken_vessel(), "Sunken Vessel Manor should wait until fourth-layer Qi Refining.")
	GameState.player.minor_stage = 4
	_expect(border.can_enter_sunken_vessel(), "Sunken Vessel Manor should open at fourth-layer Qi Refining.")
	_expect(not border.can_enter_mist_tide_grotto(), "Mist Tide Stone Grotto should wait until fifth-layer Qi Refining.")
	GameState.player.minor_stage = 5
	_expect(border.can_enter_mist_tide_grotto(), "Mist Tide Stone Grotto should open at fifth-layer Qi Refining.")
	_expect(not border.can_enter_red_maple_road(), "Red Maple Road should wait until sixth-layer Qi Refining.")
	GameState.player.minor_stage = 6
	_expect(border.can_enter_red_maple_road(), "Red Maple Road should open at sixth-layer Qi Refining.")
	_expect(not border.can_enter_thunder_cliff(), "Thunder Listening Cliff should wait until seventh-layer Qi Refining.")
	GameState.player.minor_stage = 7
	_expect(border.can_enter_thunder_cliff(), "Thunder Listening Cliff should open at seventh-layer Qi Refining.")
	_expect(not border.can_enter_mist_port(), "Return Abyss Mist Port should wait until eighth-layer Qi Refining.")
	GameState.player.minor_stage = 8
	_expect(border.can_enter_mist_port(), "Return Abyss Mist Port should open at eighth-layer Qi Refining.")
	_expect(not border.can_enter_abysswatch_terrace(), "Abysswatch Terrace should wait until ninth-layer Qi Refining.")
	GameState.player.minor_stage = 9
	_expect(border.can_enter_abysswatch_terrace(), "Abysswatch Terrace should open at ninth-layer Qi Refining.")
	GameState.player.realm_index = 2
	_expect(not border.can_enter_ancient_ridge(), "Ancient Ridge should remain closed below Yuan Infant.")
	GameState.player.realm_index = 3
	_expect(border.can_enter_ancient_ridge(), "Ancient Ridge should open at Yuan Infant.")
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before
	border.active_interaction = border.scout_interaction
	border._activate_contextual()
	_expect(border.scout_dialogue_stage == 1, "Border scout dialogue did not advance.")
	border.active_interaction = border.crystal_interaction
	border._activate_contextual()
	_expect(border.crystal_collected and not border.get_node("MistTideCrystal").visible, "Border crystal gathering did not remove the resource node.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Border crystal gathering did not add its material to inventory.")
	border.queue_free()
	await get_tree().process_frame

func _check_mist_bone_creek() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 3
	var creek := preload("res://scenes/mist_bone_creek.tscn").instantiate()
	add_child(creek)
	await get_tree().process_frame
	_expect(creek.player.map_bounds.size.x >= 2900.0, "Mist Bone Creek did not create an independent wide exploration space.")
	_expect(creek.chosen_opportunity.size() > 0, "Mist Bone Creek did not select a free-exploration opportunity.")
	creek.active_interaction = creek.opportunity_interaction
	creek._activate_contextual()
	_expect(creek.opportunity_collected, "Mist Bone Creek opportunity did not collect through the shared interaction path.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Mist Bone Creek opportunity did not grant its configured exploration item.")
	_expect(GameState.player.opportunity_log.size() == log_before + 1, "Mist Bone Creek opportunity did not record a world discovery.")
	creek.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_mist_forest_grove() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 2
	var forest := preload("res://scenes/mist_forest_grove.tscn").instantiate()
	add_child(forest)
	await get_tree().process_frame
	_expect(forest.boss_health == 160, "Mist Forest should use its independent higher-health boss configuration.")
	forest.near_boss = true
	forest._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(forest.boss_health < 160, "Mist Forest Ningxi cast did not damage the forest boss.")
	forest._defeat_boss()
	await get_tree().process_frame
	_expect(forest.clear_panel.visible, "Mist Forest clear did not show the settlement panel.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Mist Forest clear did not record a separate dungeon run.")
	_expect(GameState.player.inventory.has("雾林妖丹") and GameState.player.inventory.size() >= inventory_before + 2, "Mist Forest clear should grant an always-available foundation-pill core plus one random reward.")
	forest.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_sunken_vessel_manor() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var runs_before: int = GameState.player.dungeon_runs.size()
	var inventory_before: int = GameState.player.inventory.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 4
	var manor := preload("res://scenes/sunken_vessel_manor.tscn").instantiate()
	add_child(manor)
	await get_tree().process_frame
	_expect(manor.boss_health == 220, "Sunken Vessel Manor should use its independent fourth-layer boss configuration.")
	manor.near_boss = true
	manor._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(manor.boss_health < 220, "Sunken Vessel Ningxi cast did not damage its boss.")
	manor._defeat_boss()
	await get_tree().process_frame
	_expect(manor.clear_panel.visible, "Sunken Vessel clear did not show the settlement panel.")
	_expect(GameState.player.inventory.has("沉舟航图残页") and GameState.player.inventory.size() >= inventory_before + 2, "Sunken Vessel clear did not grant a random drop plus the navigation clue.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Sunken Vessel clear did not record its separate dungeon run.")
	manor.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_mist_tide_stone_grotto() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 5
	var grotto := preload("res://scenes/mist_tide_stone_grotto.tscn").instantiate()
	add_child(grotto)
	await get_tree().process_frame
	_expect(grotto.player.map_bounds.size.x >= 2900.0, "Mist Tide Stone Grotto did not create a broad independent cave map.")
	_expect(grotto.chosen_tide_event.size() > 0, "Mist Tide Stone Grotto did not select a tide event.")
	grotto.active_interaction = grotto.mineral_interaction
	grotto._activate_contextual()
	grotto.active_interaction = grotto.tide_interaction
	grotto._activate_contextual()
	grotto.active_interaction = grotto.tunnel_interaction
	grotto._activate_contextual()
	_expect(grotto.mineral_collected and grotto.tide_resolved and grotto.tunnel_searched, "Mist Tide Stone Grotto did not resolve all independent routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 3, "Mist Tide Stone Grotto should grant one result from each optional route.")
	_expect(GameState.player.opportunity_log.size() == log_before + 3, "Mist Tide Stone Grotto did not record all three open-world discoveries.")
	grotto.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_red_maple_ancient_road() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	var gold_before: int = GameState.player.gold
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 6
	GameState.player.gold = max(18, gold_before)
	var road := preload("res://scenes/red_maple_ancient_road.tscn").instantiate()
	add_child(road)
	await get_tree().process_frame
	_expect(road.player.map_bounds.size.x >= 11000.0, "Red Maple Road did not reserve a large regional exploration space.")
	_expect(road.route_event.size() > 0, "Red Maple Road did not choose a road event.")
	_expect(road.regional_population != null, "Red Maple Road is missing its ecological dynamic-population director.")
	_expect(road.chunk_streamer.loaded_chunk_count() >= 1, "Red Maple Road did not load its nearby western terrain chunk.")
	var road_player_start: Vector2 = road.player.position
	road.player.position = Vector2(11200, 7200)
	await get_tree().process_frame
	_expect(not road.get_node("Terrain").visible, "Red Maple Road did not unload far western terrain art.")
	road.player.position = road_player_start
	await get_tree().process_frame
	road.active_interaction = road.ledger_interaction
	road._activate_contextual()
	road.active_interaction = road.escort_interaction
	road._activate_contextual()
	road.active_interaction = road.event_interaction
	road._activate_contextual()
	_expect(road.escort_resolved and road.event_resolved, "Red Maple Road did not resolve its independent optional routes.")
	_expect(GameState.player.inventory.size() >= inventory_before + 3, "Red Maple Road should grant a trade item plus two optional-route results.")
	_expect(GameState.player.opportunity_log.size() == log_before + 2, "Red Maple Road did not record both free-exploration discoveries.")
	road.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before
	GameState.player.gold = gold_before

func _check_world_population_encounter() -> void:
	var inventory_before: int = GameState.player.inventory.size()
	var road := preload("res://scenes/red_maple_ancient_road.tscn").instantiate()
	add_child(road)
	await get_tree().process_frame
	var population := preload("res://src/world/regional_population_director.gd").new()
	var encounter := preload("res://src/world/world_encounter_controller.gd").new()
	var target_label := Label.new()
	var player_label := Label.new()
	road.add_child(population)
	road.add_child(encounter)
	road.add_child(target_label)
	road.add_child(player_label)
	population.populate(7, [{
		"id": "smoke_test_beast", "region": "test", "kind": "beast", "name": "烟测灵獭",
		"prompt": "接近烟测灵獭", "chance": 1.0, "anchors": [road.player.position + Vector2(54, 0)],
		"health": 10, "damage": 1, "reward": "烟测灵皮", "cultivation": 0,
	}])
	encounter.configure(road.player, population, road.status, target_label, player_label)
	await get_tree().process_frame
	var enemy_root: Node2D = population.get_child(0)
	var enemy_interaction: Area2D = enemy_root.get_node("Interaction")
	population.resolve(enemy_interaction)
	_expect(encounter.is_in_encounter(), "A hostile ecological population entry did not begin an overworld encounter.")
	road.player.position = enemy_root.global_position
	encounter._on_player_attack_impact("south")
	_expect(not encounter.is_in_encounter() and not enemy_root.visible, "Overworld basic attack did not defeat the low-health hostile entry.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Overworld hostile defeat did not award its ecological material.")
	road.queue_free()
	await get_tree().process_frame

func _check_thunder_listening_cliff() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 7
	var cliff := preload("res://scenes/thunder_listening_cliff.tscn").instantiate()
	add_child(cliff)
	await get_tree().process_frame
	_expect(cliff.player.map_bounds.size.x >= 11000.0, "Thunder Listening Cliff did not reserve a large weather-exploration region.")
	_expect(cliff.thunder_window.size() > 0, "Thunder Listening Cliff did not choose a weather opportunity.")
	_expect(cliff.chunk_streamer.loaded_chunk_count() >= 1, "Thunder Listening Cliff did not load its nearby terrain chunk.")
	cliff.active_interaction = cliff.pavilion_interaction
	cliff._activate_contextual()
	cliff.active_interaction = cliff.thunder_interaction
	cliff._activate_contextual()
	_expect(cliff.pavilion_visited and cliff.thunder_resolved, "Thunder Listening Cliff did not resolve its shelter and thunder-window routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Thunder Listening Cliff should grant its weather-material outcome.")
	_expect(GameState.player.opportunity_log.size() == log_before + 2, "Thunder Listening Cliff did not record both free-exploration discoveries.")
	cliff.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_return_abyss_mist_port() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 8
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.map_bounds.size.x >= 11000.0, "Return Abyss Mist Port did not reserve a large port exploration region.")
	_expect(port.port_event.size() > 0, "Return Abyss Mist Port did not choose a free-exploration port event.")
	_expect(port.chunk_streamer.loaded_chunk_count() >= 1, "Return Abyss Mist Port did not load its nearby authored quay terrain.")
	_expect(port.get_node("OuterHarborChunk").visible, "Return Abyss Mist Port did not load its connected outer-harbor terrain chunk.")
	_expect(port.auction_interaction != null, "Return Abyss Mist Port is missing its physical auction-hall entry.")
	port.active_interaction = port.ledger_interaction
	port._activate_contextual()
	port.active_interaction = port.wreck_interaction
	port._activate_contextual()
	port.active_interaction = port.sea_cave_interaction
	port._activate_contextual()
	_expect(port.ledger_read and port.wreck_resolved and port.sea_cave_searched, "Return Abyss Mist Port did not resolve its independent rumour, wreck and sea-cave routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 2, "Return Abyss Mist Port should grant both selected optional resource materials.")
	_expect(GameState.player.opportunity_log.size() == log_before + 3, "Return Abyss Mist Port did not record all three optional discoveries.")
	port.player.position = Vector2(6600, 700)
	await get_tree().process_frame
	_expect(not port.get_node("Terrain").visible and port.get_node("OuterHarborChunk").visible, "Return Abyss Mist Port did not hand off from its first quay chunk to the connected outer-harbor chunk.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_abysswatch_terrace() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 9
	var terrace := preload("res://scenes/abysswatch_terrace.tscn").instantiate()
	add_child(terrace)
	await get_tree().process_frame
	_expect(terrace.player.map_bounds.size.x >= 11000.0, "Abysswatch Terrace did not reserve a large ninth-layer region.")
	_expect(terrace.terrace_sign.size() > 0, "Abysswatch Terrace did not choose a preparation opportunity.")
	_expect(terrace.chunk_streamer.loaded_chunk_count() >= 1, "Abysswatch Terrace did not load its authored terrace chunk.")
	terrace.active_interaction = terrace.observation_interaction
	terrace._activate_contextual()
	terrace.active_interaction = terrace.sign_interaction
	terrace._activate_contextual()
	_expect(terrace.observation_complete and terrace.sign_resolved, "Abysswatch Terrace did not resolve its independent preparation routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Abysswatch Terrace should grant its selected preparation material.")
	_expect(GameState.player.opportunity_log.size() == log_before + 2, "Abysswatch Terrace did not record its two optional discoveries.")
	terrace.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_ancient_ridge() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var log_before: int = GameState.player.opportunity_log.size()
	GameState.player.realm_index = 3
	GameState.player.minor_stage = 1
	var ridge := preload("res://scenes/ancient_ridge.tscn").instantiate()
	add_child(ridge)
	await get_tree().process_frame
	_expect(ridge.player.map_bounds.size.x >= 11000.0, "Ancient Ridge did not reserve a large third-region world space.")
	_expect(ridge.ridge_event.size() > 0, "Ancient Ridge did not choose a terrain-based opportunity.")
	_expect(ridge.chunk_streamer.loaded_chunk_count() >= 1, "Ancient Ridge did not load its nearby authored earthfire terrain chunk.")
	_expect(ridge.earthfire_cave_interaction != null, "Ancient Ridge is missing its physical Earthfire Cave fixed-dungeon entrance.")
	_expect(ridge.battlefield_memorial_interaction != null, "Ancient Ridge is missing its fixed Ancient Battlefield memorial route.")
	ridge.active_interaction = ridge.relic_interaction
	ridge._activate_contextual()
	ridge.active_interaction = ridge.event_interaction
	ridge._activate_contextual()
	ridge._discover_earthfire_cave()
	ridge.active_interaction = ridge.battlefield_memorial_interaction
	ridge._activate_contextual()
	_expect(ridge.relic_examined and ridge.event_resolved and ridge.earthfire_cave_discovered and ridge.battlefield_memorial_examined, "Ancient Ridge did not resolve its ruin, random-opportunity, fixed-dungeon and fixed-relic routes.")
	_expect(GameState.player.inventory.size() == inventory_before + 2, "Ancient Ridge should grant one random and one fixed-relic material.")
	_expect(GameState.player.opportunity_log.size() == log_before + 4, "Ancient Ridge did not record its two discoveries, fixed dungeon entrance and fixed relic.")
	ridge.player.position = Vector2(9800, 700)
	await get_tree().process_frame
	_expect(not ridge.get_node("Terrain").visible and not ridge.get_node("BattlefieldPassChunk").visible and ridge.get_node("AncientBattlefieldChunk").visible, "Ancient Ridge did not stream into its third connected ancient-battlefield chunk.")
	ridge.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_earthfire_cave() -> void:
	var realm_before: int = GameState.player.realm_index
	var stage_before: int = GameState.player.minor_stage
	var inventory_before: int = GameState.player.inventory.size()
	var runs_before: int = GameState.player.dungeon_runs.size()
	GameState.player.realm_index = 3
	GameState.player.minor_stage = 1
	var cave := preload("res://scenes/earthfire_cave.tscn").instantiate()
	add_child(cave)
	await get_tree().process_frame
	_expect(cave.boss_health == 260, "Earthfire Cave did not configure the Earthfire Spirit Beast as its fixed boss.")
	_expect(cave.get_node("Boss/Sprite").texture != null, "Earthfire Cave did not render a dedicated boss asset.")
	cave.near_boss = true
	cave._cast_ningxi_sword_art()
	await get_tree().create_timer(0.35).timeout
	_expect(cave.boss_health < 260, "Earthfire Cave skill cast did not damage its boss.")
	cave._defeat_boss()
	await get_tree().process_frame
	_expect(cave.clear_panel.visible, "Earthfire Cave clear did not show a settlement panel.")
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Earthfire Cave clear did not grant one fixed-dungeon reward.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Earthfire Cave clear did not record a dungeon run.")
	cave.queue_free()
	await get_tree().process_frame
	GameState.player.realm_index = realm_before
	GameState.player.minor_stage = stage_before

func _check_world_menu_region_resume() -> void:
	var region_before: String = GameState.current_region_id
	var main_script := preload("res://src/ui/main.gd")
	var main := main_script.new()
	add_child(main)
	await get_tree().process_frame
	GameState.current_region_id = "return_abyss_mist_port"
	_expect(main._playable_scene_for_current_region() == "res://scenes/return_abyss_mist_port.tscn", "World menu did not resume Return Abyss Mist Port.")
	GameState.current_region_id = "thunder_listening_cliff"
	_expect(main._playable_scene_for_current_region() == "res://scenes/thunder_listening_cliff.tscn", "World menu did not resume Thunder Listening Cliff.")
	GameState.current_region_id = "abysswatch_terrace"
	_expect(main._playable_scene_for_current_region() == "res://scenes/abysswatch_terrace.tscn", "World menu did not resume Abysswatch Terrace.")
	GameState.current_region_id = "ancient_ridge"
	_expect(main._playable_scene_for_current_region() == "res://scenes/ancient_ridge.tscn", "World menu did not resume Ancient Ridge.")
	GameState.current_region_id = region_before
	main.queue_free()
	await get_tree().process_frame

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
