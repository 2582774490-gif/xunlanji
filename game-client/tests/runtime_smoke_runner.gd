extends Node

var failures: Array[String] = []

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_manual_progression()
	await _check_local_profile_payload()
	await _check_optional_world_guidance()
	await _check_cultivation_affinity()
	await _check_fair_attribute_and_technique_growth()
	await _check_alchemy_and_medicine_rules()
	await _check_equipment_upgrade_rules()
	await _check_sect_progression()
	await _check_wanted_patrol()
	await _check_weapon_combat_profiles()
	await _check_weapon_render_slot()
	await _check_umbrella_render_slot()
	await _check_runtime_weapon_quick_switch()
	await _check_artifact_render_slot()
	await _check_mist_tide_pearl_render_slot()
	await _check_mist_tide_pearl_combat_rules()
	await _check_earthseal_render_and_combat_rules()
	await _check_local_market_loop()
	await _check_random_opportunity()
	await _check_world_menu_does_not_fabricate_opportunity_rewards()
	await _check_village_routes()
	await _check_water_palace_loop()
	await _check_umbrella_weapon_skill_sets()
	await _check_mist_border_scene()
	await _check_mist_bone_creek()
	await _check_mist_forest_grove()
	await _check_sunken_vessel_manor()
	await _check_mist_tide_stone_grotto()
	await _check_red_maple_ancient_road()
	await _check_world_population_encounter()
	await _check_world_population_resource()
	await _check_dedicated_ecology_visual()
	await _check_local_duel_arena()
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

func _check_optional_world_guidance() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.world_guidance = {"steps": [], "skipped": false}
	_expect(not GameState.is_world_guidance_complete(), "Fresh world orientation should be optional but initially incomplete.")
	_expect(GameState.complete_world_guidance_step("lan_breath"), "South Gate guidance should persist the Lan-breath introduction.")
	_expect(GameState.complete_world_guidance_step("resource_ecology"), "Resource guidance should persist after a first gather.")
	_expect(GameState.complete_world_guidance_step("path_choice"), "Sect-path guidance should persist after speaking to the envoy.")
	_expect(GameState.is_world_guidance_complete(), "All three orientation notes should complete without a forced quest chain.")
	var exported: Dictionary = GameState.export_local_profile()
	_expect((exported.player.get("world_guidance", {}) as Dictionary).get("steps", []).size() == 3, "World orientation progress did not enter the local save payload.")
	GameState.player.world_guidance = {"steps": [], "skipped": false}
	_expect(GameState.skip_world_guidance(), "Players should be able to skip the optional world orientation.")
	_expect(GameState.is_world_guidance_complete() and GameState.player.realm_index == int(profile_before.realm_index), "Skipping orientation must not grant realm progress or block world access.")
	GameState.player = profile_before
	GameState.profile_changed.emit()

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
	var manual_art: Dictionary = GameCatalog.technique_art_profile_for_name("云岚吐纳诀")
	_expect(not manual_art.is_empty() and ResourceLoader.exists(str(manual_art.card_asset)), "Yunlan Breathing Manual must point to its own approved codex art asset.")
	_expect(GameCatalog.technique_art_profile_for_name("三折剑经").is_empty(), "Unapproved technique art must not silently reuse the Yunlan manual cover.")
	GameState.player = profile_before
	GameState.profile_changed.emit()


func _check_fair_attribute_and_technique_growth() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.attributes = {"体魄": 5, "灵识": 5, "身法": 5, "根骨": 5}
	GameState.player.unspent_points = 4
	GameState.player.attribute_points_earned = 4
	GameState.player.learned_techniques = ["云岚吐纳诀"]
	GameState.player.cultivation_path = "云岚吐纳诀"
	GameState.player.technique_insight = {"云岚吐纳诀": {"progress": 0, "awards_claimed": 0}}
	_expect(GameState.attribute_point_budget() == 4 and GameState.attribute_points_spent() == 0, "Every new character should begin with the same four-point allocation pool.")
	_expect(GameState.allocate_attribute("身法"), "A starting free point should be allocatable to body movement.")
	var speed_after_first_point := GameState.world_move_speed()
	GameState.player.attributes["身法"] = 9
	GameState.player.attribute_points_earned = 8
	_expect(GameState.world_move_speed() > speed_after_first_point, "Body-movement allocation should raise actual overworld movement speed.")
	GameState.player.attributes = {"体魄": 5, "灵识": 5, "身法": 5, "根骨": 5}
	GameState.player.attribute_points_earned = 4
	GameState.player.unspent_points = 4
	var awards_before: int = GameState.gain_technique_insight(59)
	_expect(awards_before == 0 and int(GameState.player.unspent_points) == 4, "Technique insight should not award a point before its first slow-growth threshold.")
	var awards_at_threshold: int = GameState.gain_technique_insight(1)
	_expect(awards_at_threshold == 1 and GameState.attribute_point_budget() == 5 and int(GameState.player.unspent_points) == 5, "Technique insight should award one point exactly at the first threshold.")
	GameState.choose_cultivation_path("三折剑经")
	_expect(GameState.attribute_point_budget() == 5, "Learning or switching a technique must not directly mint attribute points.")
	GameState.player = profile_before
	GameState.profile_changed.emit()


func _check_alchemy_and_medicine_rules() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	var listings_before: Array = GameState.local_market_listings.duplicate(true)
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	GameState.player.cultivation = 0
	GameState.player.cultivation_path = "云岚吐纳诀"
	GameState.player.spirit_root = "水灵根"
	GameState.player.physique = "岚息体"
	GameState.player.inventory = ["雾溪灵草", "雾溪药"]
	GameState.player.medicine_tolerance = {"day": "", "burden": 0}
	GameState.player.alchemy_history = []
	var ordinary_rate := GameState.alchemy_success_rate("ningxi")
	GameState.player.cultivation_path = "百草调息录"
	GameState.player.spirit_root = "木灵根"
	GameState.player.physique = "青木灵胎"
	_expect(GameState.alchemy_success_rate("ningxi") > ordinary_rate, "Dan cultivation, matching roots and physique should improve alchemy success rate.")
	_expect(GameState.craft_alchemy_recipe("ningxi", 0.0), "A valid recipe should craft when its controlled roll is within the success rate.")
	_expect(GameState.player.inventory.has("凝息丹") and not GameState.player.inventory.has("雾溪灵草"), "Successful alchemy should consume materials and produce the named pill.")
	GameState.player.cultivation_path = "云岚吐纳诀"
	GameState.player.spirit_root = "水灵根"
	GameState.player.physique = "岚息体"
	_expect(GameState.use_pill("凝息丹"), "A low-realm player should be able to use an effective crafted pill within daily burden.")
	_expect(GameState.medicine_burden() == 5 and GameState.player.cultivation > 0, "Pill use should add its own medicine burden and cultivation effect.")
	GameState.player.inventory.append("凝息丹")
	_expect(GameState.use_pill("凝息丹"), "A second early pill should still fit the initial daily burden budget.")
	GameState.player.inventory.append("凝息丹")
	_expect(not GameState.use_pill("凝息丹") and GameState.player.inventory.has("凝息丹"), "A pill that exceeds daily burden should be rejected without consumption.")
	GameState.player.realm_index = 1
	GameState.player.minor_stage = 1
	GameState.player.medicine_tolerance = {"day": "", "burden": 0}
	_expect(not GameState.use_pill("凝息丹") and GameState.player.inventory.has("凝息丹"), "High-realm players should not consume ineffective low-realm pills.")
	GameState.player.gold = 100
	_expect(GameState.list_item_for_market("凝息丹", 31), "Crafted pills should remain freely tradeable through the market boundary.")
	GameState.player = profile_before
	GameState.local_market_listings = listings_before
	GameState.profile_changed.emit()


func _check_equipment_upgrade_rules() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	var listings_before: Array = GameState.local_market_listings.duplicate(true)
	GameState.player.realm_index = 0
	GameState.player.minor_stage = 1
	GameState.player.inventory = ["练气木剑", "青篁练气剑", "雾潮晶簇", "雾潮晶簇", "雾潮晶簇", "雾潮晶簇", "雾潮晶簇", "雾潮晶簇", "流火矿", "流火矿"]
	GameState.player.equipped_weapon = "练气木剑"
	GameState.player.equipped_artifact = "纳灵玉佩"
	GameState.player.equipment_upgrades = {}
	var base_combat := CombatState.new()
	base_combat.begin("测试", "木桩")
	base_combat.normal_attack()
	var base_damage := 100 - base_combat.enemy_hp
	_expect(GameState.upgrade_equipment("青篁练气剑"), "Qi Refining equipment should upgrade when its first material requirement is present.")
	_expect(GameState.equipment_upgrade_level("青篁练气剑") == 1 and GameState.equipment_power_bonus("青篁练气剑") == 2, "Equipment upgrade did not record its first power level.")
	GameState.equip_weapon("青篁练气剑")
	var upgraded_combat := CombatState.new()
	upgraded_combat.begin("测试", "木桩")
	upgraded_combat.normal_attack()
	_expect(100 - upgraded_combat.enemy_hp > base_damage, "Equipment upgrades should affect combat damage rather than only inventory text.")
	_expect(GameState.upgrade_equipment("青篁练气剑"), "Qi Refining should be able to complete the second mundane upgrade tier with crystal materials.")
	_expect(not GameState.upgrade_equipment("青篁练气剑"), "The first spirit-quality upgrade must be Foundation-gated and must not consume materials at Qi Refining.")
	GameState.equip_weapon("练气木剑")
	GameState.player.gold = 100
	_expect(GameState.list_item_for_market("青篁练气剑", 20), "An unequipped upgraded weapon should be tradeable.")
	_expect(GameState.equipment_upgrade_level("青篁练气剑") == 0, "Listing an upgraded item should move its upgrade state out of the seller profile.")
	var listing_index := GameState.local_market_listings.size() - 1
	_expect(GameState.buy_market_listing(listing_index), "A listed upgraded weapon should remain purchasable.")
	_expect(GameState.equipment_upgrade_level("青篁练气剑") == 2, "Buying an upgraded weapon should restore its transferred upgrade state.")
	GameState.player = profile_before
	GameState.local_market_listings = listings_before
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
	GameState.player.equipment_upgrades = {}
	GameState.equip_weapon("青篁练气剑")
	var sword_combat := CombatState.new()
	sword_combat.begin("测试", "木桩")
	sword_combat.normal_attack()
	var sword_damage := 100 - sword_combat.enemy_hp
	_expect(sword_damage == GameState.weapon_basic_damage(8), "Menu combat must use the same weapon basic-damage rule as playable scenes.")
	var sword_skill_damage := GameState.weapon_skill_damage(20, 0.5, 100.0, 30.0)
	GameState.equip_weapon("开山练气斧")
	var axe_combat := CombatState.new()
	axe_combat.begin("测试", "木桩")
	axe_combat.normal_attack()
	var axe_damage := 100 - axe_combat.enemy_hp
	_expect(axe_damage > sword_damage, "Heavy axe profile should deal more opening damage than sword profile.")
	_expect(GameState.weapon_skill_damage(20, 0.5, 100.0, 30.0) < sword_skill_damage, "Weapon skill damage should use its own skill bonus rather than the generic basic-attack bonus.")
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

func _check_umbrella_render_slot() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	if not GameState.player.inventory.has("回云练气伞"):
		GameState.player.inventory.append("回云练气伞")
	GameState.equip_weapon("回云练气伞")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.has_node("WeaponPivot/WeaponSprite"), "Equipped Huiyun Umbrella did not create an independent player weapon render slot.")
	_expect(port.player.weapon_motion is UmbrellaMotionController, "Huiyun Umbrella did not use its dedicated defensive motion controller.")
	var umbrella_sprite: Sprite2D = port.player.get_node("WeaponPivot/WeaponSprite")
	_expect(umbrella_sprite.texture != null, "Equipped Huiyun Umbrella render slot has no umbrella texture.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_runtime_weapon_quick_switch() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.inventory = ["青篁练气剑", "回云练气伞"]
	GameState.equip_weapon("青篁练气剑")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.weapon_motion is WeaponMotionController and not (port.player.weapon_motion is UmbrellaMotionController), "Quick-switch setup did not render the sword motion layer.")
	_expect(GameState.equip_next_runtime_weapon(), "Runtime weapon switch should succeed when two approved weapon assets are carried.")
	await get_tree().process_frame
	_expect(GameState.player.equipped_weapon == "回云练气伞", "Runtime weapon switch did not select the next carried weapon.")
	_expect(port.player.weapon_motion is UmbrellaMotionController, "Runtime weapon switch did not replace the sword motion layer with the umbrella controller.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()

func _check_artifact_render_slot() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	if not GameState.player.inventory.has("纳灵玉佩"):
		GameState.player.inventory.append("纳灵玉佩")
	GameState.equip_artifact("纳灵玉佩")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.has_node("ArtifactPivot/ArtifactSprite"), "Equipped Naling Jade Pendant did not create an independent player artifact render slot.")
	var artifact_sprite: Sprite2D = port.player.get_node("ArtifactPivot/ArtifactSprite")
	_expect(artifact_sprite.texture != null, "Equipped Naling Jade Pendant render slot has no pendant texture.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()


func _check_mist_tide_pearl_render_slot() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	if not GameState.player.inventory.has("雾潮练气珠"):
		GameState.player.inventory.append("雾潮练气珠")
	GameState.equip_artifact("雾潮练气珠")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	_expect(port.player.has_node("ArtifactPivot/ArtifactSprite"), "Mist-Tide Qi Pearl did not create its own runtime artifact layer.")
	var artifact_sprite: Sprite2D = port.player.get_node("ArtifactPivot/ArtifactSprite")
	_expect(artifact_sprite.texture != null, "Mist-Tide Qi Pearl runtime layer has no approved dedicated texture.")
	port.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()


func _check_mist_tide_pearl_combat_rules() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	GameState.player.equipped_artifact = "雾潮练气珠"
	_expect(is_equal_approx(GameState.artifact_damage_reduction("water"), 0.35), "Mist-Tide Qi Pearl should reduce only declared water damage by 35%.")
	_expect(is_zero_approx(GameState.artifact_damage_reduction("fire")), "Mist-Tide Qi Pearl must not reduce non-water damage.")
	_expect(is_zero_approx(GameState.artifact_mana_regen_bonus()), "Mist-Tide Qi Pearl should not inherit the Jade Pendant mana regeneration.")
	GameState.player.equipped_artifact = "纳灵玉佩"
	_expect(GameState.artifact_mana_regen_bonus() > 0.0, "Naling Jade Pendant should retain its own mana-regeneration effect.")
	_expect(is_zero_approx(GameState.artifact_damage_reduction("water")), "Naling Jade Pendant should not gain the Pearl water-defense effect.")
	GameState.player = profile_before
	GameState.profile_changed.emit()


func _check_earthseal_render_and_combat_rules() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	if not GameState.player.inventory.has("玄土练气印"):
		GameState.player.inventory.append("玄土练气印")
	GameState.equip_artifact("玄土练气印")
	var port := preload("res://scenes/return_abyss_mist_port.tscn").instantiate()
	add_child(port)
	await get_tree().process_frame
	var artifact_sprite: Sprite2D = port.player.get_node("ArtifactPivot/ArtifactSprite")
	_expect(artifact_sprite.texture != null, "Earthseal Qi Stamp runtime layer has no approved dedicated texture.")
	port.queue_free()
	await get_tree().process_frame
	_expect(is_equal_approx(GameState.artifact_damage_reduction("earth"), 0.32), "Earthseal Qi Stamp should reduce only declared earth damage by 32%.")
	_expect(is_zero_approx(GameState.artifact_damage_reduction("water")), "Earthseal Qi Stamp must not reduce water damage.")
	var cave := preload("res://scenes/earthfire_cave.tscn").instantiate()
	add_child(cave)
	await get_tree().process_frame
	cave.near_boss = true
	cave.player_health = 100
	cave.guard_time_left = 0.0
	cave._perform_boss_water_blade()
	await get_tree().create_timer(0.30).timeout
	_expect(cave.player_health == 86, "Earthfire Cave did not apply the Earthseal Qi Stamp only to its earth-impact attack.")
	cave.queue_free()
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


func _check_world_menu_does_not_fabricate_opportunity_rewards() -> void:
	var inventory_before: Array = GameState.player.inventory.duplicate(true)
	var cultivation_before: int = GameState.player.cultivation
	var log_before: int = GameState.player.opportunity_log.size()
	var region_before: String = GameState.current_region_id
	GameState.current_region_id = "mist_border"
	var menu := preload("res://scenes/main.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu._explore()
	_expect(GameState.player.inventory == inventory_before and GameState.player.cultivation == cultivation_before, "World-menu exploration must not mint rewards without a physical regional interaction.")
	_expect(GameState.player.opportunity_log.size() == log_before, "World-menu exploration must not log a fabricated opportunity.")
	menu.queue_free()
	await get_tree().process_frame
	GameState.current_region_id = region_before

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
	var had_pearl := GameState.player.inventory.has("雾潮练气珠")
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
	var expected_item_count := 1 if had_pearl else 2
	_expect(GameState.player.inventory.size() == inventory_before + expected_item_count, "Boss clear did not grant the random initial-equipment drop and the first-clear Pearl reward.")
	_expect(GameState.player.inventory.has("雾潮练气珠"), "First Water Palace clear did not grant the Mist-Tide Qi Pearl.")
	_expect(GameState.player.dungeon_runs.size() == runs_before + 1, "Boss clear did not record the dungeon run.")
	_expect(GameState.is_region_unlocked("mist_border"), "Water Palace clear did not unlock Mist Tide Border.")
	palace.queue_free()
	await get_tree().process_frame

func _check_umbrella_weapon_skill_sets() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	if not GameState.player.inventory.has("回云练气伞"):
		GameState.player.inventory.append("回云练气伞")
	GameState.equip_weapon("回云练气伞")
	var palace := preload("res://scenes/mist_stream_water_palace.tscn").instantiate()
	add_child(palace)
	await get_tree().process_frame
	_expect(str(palace._skill(1).get("id", "")) == "huiyun_umbrella_array", "Dungeon skill bar did not replace sword art with Huiyun Umbrella Array.")
	palace.near_boss = true
	var boss_hp_before: int = palace.boss_health
	palace._cast_ningxi_sword_art()
	await get_tree().create_timer(0.28).timeout
	_expect(palace.boss_health < boss_hp_before and palace.guard_time_left > 0.0, "Umbrella Array should damage at close range and leave a brief defensive ward in dungeons.")
	palace.queue_free()
	await get_tree().process_frame
	var arena := preload("res://scenes/duel_arena.tscn").instantiate()
	add_child(arena)
	await get_tree().process_frame
	_expect(str(arena._skill(1).get("id", "")) == "huiyun_umbrella_array", "Local duel skill HUD did not replace sword art with Huiyun Umbrella Array.")
	arena.player.position = arena.opponent.position + Vector2(100.0, 0.0)
	var opponent_hp_before: int = arena.opponent.hp
	arena._cast_ningxi_sword_art()
	await get_tree().create_timer(0.26).timeout
	_expect(arena.opponent.hp < opponent_hp_before and arena.guard_time_left > 0.0, "Umbrella Array should have distinct local-duel damage and ward behavior.")
	arena.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.profile_changed.emit()

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
	_expect(border.has_node("HUD/WorldMinimap"), "Mist Tide Border is missing its regional orientation map.")
	_expect(border.has_node("EnvironmentDepthLayer"), "Mist Tide Border is missing its layered environment depth plane.")
	var border_depth: RegionalEnvironmentDepthLayer = border.get_node("EnvironmentDepthLayer")
	_expect(border_depth.y_sort_enabled and border_depth.prop_count >= 18 and border_depth.foreground_prop_count >= 4, "Mist Tide Border depth layer did not create enough terrain-bound foreground and midground props.")
	var border_minimap: WorldMinimap = border.get_node("HUD/WorldMinimap")
	_expect(border_minimap.world_bounds.size.x >= 11000.0 and border_minimap.landmarks.size() >= 6, "Mist Tide Border minimap does not represent the large region and its fixed landmarks.")
	_expect(RegionalSectorCatalog.sector_at("mist_border", Vector2(6980, 1370)).get("id", "") == "herb_wetland", "Mist Tide Border did not classify its herb ecology inside the wetland sector.")
	_expect(border.chunk_streamer.loaded_chunk_count() >= 1, "Mist Tide Border did not load its nearby high-detail terrain chunk.")
	_expect(border.has_node("HerbWetlandChunk"), "Mist Tide Border is missing the continuous herb wetland terrain chunk.")
	var ecology_profiles: Array[Dictionary] = border._population_profiles()
	_expect(ecology_profiles.any(func(profile: Dictionary): return str(profile.get("id", "")) == "wetland_mist_herb"), "Mist Tide Border is missing its wetland-bound herb ecology profile.")
	var otter_interaction: Area2D = border.regional_population.interaction_for_profile_id("fog_channel_beast")
	if otter_interaction != null:
		var otter_visual: Sprite2D = otter_interaction.get_parent().get_node("Visual")
		_expect(otter_visual.texture.resource_path.ends_with("mist_channel_otter_spirit_v01_alpha.png"), "Fog-channel otter should use its dedicated runtime art rather than a borrowed boss sprite.")
	var border_player_start: Vector2 = border.player.position
	border.player.position = Vector2(11200, 7200)
	await get_tree().process_frame
	_expect(border_minimap.player_map_position().x > 200.0 and border_minimap.player_map_position().y > 130.0, "Mist Tide Border minimap did not follow the player across the full regional bounds.")
	_expect(not border.get_node("Terrain").visible, "The terrain chunk streamer did not unload far-away high-detail art.")
	_expect(not border.get_node("HerbWetlandChunk").visible, "The terrain chunk streamer did not unload distant wetland art.")
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

func _check_world_population_resource() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	var inventory_before: int = GameState.player.inventory.size()
	var cultivation_before: int = GameState.player.cultivation
	var population := preload("res://src/world/regional_population_director.gd").new()
	add_child(population)
	population.populate(11, [{
		"id": "smoke_test_wetland_herb", "region": "test", "kind": "resource", "name": "烟测湿地灵草",
		"prompt": "采集烟测湿地灵草", "chance": 1.0, "anchors": [Vector2(120, 120)],
		"reward": "烟测雾泽灵草", "cultivation": 2,
	}])
	await get_tree().process_frame
	var herb_root: Node2D = population.get_child(0)
	var herb_interaction: Area2D = herb_root.get_node("Interaction")
	population.resolve(herb_interaction)
	_expect(GameState.player.inventory.size() == inventory_before + 1, "Ecological resource interaction did not grant its bound material.")
	_expect(GameState.player.cultivation >= cultivation_before + 2, "Ecological resource interaction did not grant its cultivation value.")
	_expect(not GameState.is_ecology_profile_available("test", "smoke_test_wetland_herb"), "Collected ecological resources should not return immediately after leaving the scene.")
	population.queue_free()
	await get_tree().process_frame
	var reload_population := preload("res://src/world/regional_population_director.gd").new()
	add_child(reload_population)
	reload_population.populate(11, [{
		"id": "smoke_test_wetland_herb", "region": "test", "kind": "resource", "name": "烟测湿地灵草",
		"prompt": "采集烟测湿地灵草", "chance": 1.0, "anchors": [Vector2(120, 120)],
		"reward": "烟测雾泽灵草", "cultivation": 2,
	}])
	_expect(reload_population.active_count() == 0, "Reloading a region should respect an active resource cooldown instead of instantly farming it again.")
	reload_population.queue_free()
	GameState.player = profile_before
	GameState.profile_changed.emit()
	var social_population := preload("res://src/world/regional_population_director.gd").new()
	add_child(social_population)
	social_population.populate(12, [{
		"id": "smoke_test_road_rogue", "region": "test", "kind": "rogue", "name": "烟测路旁散修",
		"prompt": "询问路旁散修", "chance": 1.0, "anchors": [Vector2(180, 120)],
	}])
	var rogue_interaction: Area2D = social_population.get_child(0).get_node("Interaction")
	social_population.resolve(rogue_interaction)
	_expect(rogue_interaction.get_parent().visible and social_population.active_count() == 1, "Social NPCs should remain present after conversation instead of behaving like one-shot loot nodes.")
	social_population.queue_free()
	await get_tree().process_frame

func _check_dedicated_ecology_visual() -> void:
	var population := preload("res://src/world/regional_population_director.gd").new()
	add_child(population)
	population.populate(19, [{
		"id": "fog_channel_beast", "region": "art_smoke", "kind": "beast", "name": "雾渠獭妖",
		"prompt": "观察雾渠獭妖", "chance": 1.0, "anchors": [Vector2(120, 120)],
		"health": 10, "damage": 1, "reward": "雾獭灵皮", "cultivation": 0,
	}])
	var otter_visual: Sprite2D = population.get_child(0).get_node("Visual")
	_expect(otter_visual.texture.resource_path.ends_with("mist_channel_otter_spirit_v01_alpha.png"), "Fog-channel otter should retain its dedicated runtime art instead of a borrowed boss sprite.")
	population.queue_free()
	await get_tree().process_frame

func _check_local_duel_arena() -> void:
	var profile_before: Dictionary = GameState.player.duplicate(true)
	var log_before: Array = GameState.player.opportunity_log.duplicate(true)
	if not GameState.player.inventory.has("青篁练气剑"):
		GameState.player.inventory.append("青篁练气剑")
	GameState.equip_weapon("青篁练气剑")
	var arena := preload("res://scenes/duel_arena.tscn").instantiate()
	add_child(arena)
	await get_tree().process_frame
	_expect(arena.player != null and arena.opponent != null, "Local duel arena did not create both duel participants.")
	_expect(arena.get_node("Terrain").texture != null, "Local duel arena has no authored arena terrain.")
	arena.player.position = arena.opponent.position + Vector2(110.0, 0.0)
	arena.player.trigger_basic_attack()
	await get_tree().create_timer(0.20).timeout
	_expect(arena.opponent.hp < arena.opponent.max_hp, "Manual player attack did not damage the nearby local-duel opponent.")
	var hp_before_ningxi: int = arena.opponent.hp
	arena._cast_ningxi_sword_art()
	await get_tree().create_timer(0.26).timeout
	_expect(arena.opponent.hp < hp_before_ningxi and arena.ningxi_cooldown > 0.0, "Local-duel Ningxi skill did not deal damage and start its cooldown.")
	var position_before_step := arena.player.position
	arena._cast_cloud_step()
	_expect(arena.player.position.distance_to(position_before_step) > 20.0 and arena.cloud_step_cooldown > 0.0, "Local-duel Cloud Step did not move the player and start its cooldown.")
	arena._cast_lan_breath_guard()
	var hp_before_guard: int = arena.player_hp
	arena._on_opponent_attack(12)
	_expect(hp_before_guard - arena.player_hp <= 6, "Local-duel guard did not reduce the next opponent attack.")
	arena.player_mana = 0.0
	arena._on_touch_action_requested("nourish")
	_expect(arena.player_mana > 0.0 and arena.nourish_cooldown > 0.0, "Local-duel touch skill path did not restore spirit power and start Nourish cooldown.")
	arena._on_opponent_attack(12)
	_expect(arena.player_hp < 100, "Local-duel opponent attack did not damage the player.")
	arena.opponent.take_damage(999)
	_expect(arena.finished, "Local duel arena did not resolve when one participant reached zero HP.")
	arena.queue_free()
	await get_tree().process_frame
	GameState.player = profile_before
	GameState.player.opportunity_log = log_before
	GameState.profile_changed.emit()

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
	_expect(ridge.has_node("HUD/WorldMinimap"), "Ancient Ridge is missing its regional orientation map.")
	_expect(ridge.has_node("EnvironmentDepthLayer"), "Ancient Ridge is missing its layered environment depth plane.")
	var ridge_depth: RegionalEnvironmentDepthLayer = ridge.get_node("EnvironmentDepthLayer")
	_expect(ridge_depth.y_sort_enabled and ridge_depth.prop_count >= 16 and ridge_depth.foreground_prop_count >= 5, "Ancient Ridge depth layer did not create terrain-bound 2D depth props.")
	var ridge_minimap: WorldMinimap = ridge.get_node("HUD/WorldMinimap")
	_expect(ridge_minimap.world_bounds.size.x >= 11000.0 and ridge_minimap.landmarks.size() >= 4, "Ancient Ridge minimap does not represent its large terrain and fixed routes.")
	_expect(RegionalSectorCatalog.sector_at("ancient_ridge", Vector2(5750, 430)).get("id", "") == "earthfire_ravine", "Ancient Ridge did not classify Earthfire Cave inside its ravine sector.")
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
	var had_earthseal := GameState.player.inventory.has("玄土练气印")
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
	var expected_item_count := 1 if had_earthseal else 2
	_expect(GameState.player.inventory.size() == inventory_before + expected_item_count, "Earthfire Cave clear did not grant its fixed-dungeon reward and first-clear Earthseal reward.")
	_expect(GameState.player.inventory.has("玄土练气印"), "First Earthfire Cave clear did not grant the Earthseal Qi Stamp.")
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
