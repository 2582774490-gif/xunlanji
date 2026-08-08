class_name RemoteAvatarLayer
extends Node2D

## A lightweight world representation for connected players.  It intentionally
## uses the already-approved 2D avatar sheet, while combat/loot remains local
## until server authority exists.

const MALE_IDLE: Texture2D = preload("res://assets/art/characters/yunlan_spatial_male/processed_alpha/yunlan_spatial_male_idle_8dir_v01_alpha.png")
const FEMALE_IDLE: Texture2D = preload("res://assets/art/characters/yunlan_spatial_female/processed_alpha/yunlan_spatial_female_idle_8dir_v01_alpha.png")

var region_id := ""
var _avatars: Dictionary = {}


func configure(next_region_id: String) -> void:
	region_id = next_region_id
	OnlineSession.roster_changed.connect(_sync_roster)
	OnlineSession.remote_position_changed.connect(_sync_position)
	_sync_roster(OnlineSession.remote_players())


func _exit_tree() -> void:
	if OnlineSession.roster_changed.is_connected(_sync_roster):
		OnlineSession.roster_changed.disconnect(_sync_roster)
	if OnlineSession.remote_position_changed.is_connected(_sync_position):
		OnlineSession.remote_position_changed.disconnect(_sync_position)


func _sync_roster(players: Array[Dictionary]) -> void:
	var visible_ids: Dictionary = {}
	for profile in players:
		var id := str(profile.get("id", ""))
		if id.is_empty() or str(profile.get("region", "")) != region_id:
			continue
		visible_ids[id] = true
		_update_avatar(id, profile)
	for id in _avatars.keys():
		if not visible_ids.has(id):
			var stale: Node2D = _avatars[id]
			stale.queue_free()
			_avatars.erase(id)


func _sync_position(peer_id: String, profile: Dictionary) -> void:
	if str(profile.get("region", "")) != region_id:
		if _avatars.has(peer_id):
			var stale: Node2D = _avatars[peer_id]
			stale.queue_free()
			_avatars.erase(peer_id)
		return
	_update_avatar(peer_id, profile)


func _update_avatar(peer_id: String, profile: Dictionary) -> void:
	var avatar: Node2D
	if _avatars.has(peer_id):
		avatar = _avatars[peer_id]
	else:
		avatar = _create_avatar(peer_id, str(profile.get("gender", "male")))
		_avatars[peer_id] = avatar
		add_child(avatar)
	var target := Vector2(float(profile.get("x", 0.0)), float(profile.get("y", 0.0)))
	avatar.position = avatar.position.lerp(target, 0.72) if avatar.position.length_squared() > 1.0 else target
	var sprite: Sprite2D = avatar.get_node("Body")
	_set_direction(sprite, str(profile.get("direction", "south")))
	var name_label: Label = avatar.get_node("Name")
	name_label.text = str(profile.get("name", "云岚修士"))


func _create_avatar(peer_id: String, gender: String) -> Node2D:
	var avatar := Node2D.new()
	avatar.name = "Remote_%s" % peer_id.left(8)
	avatar.y_sort_enabled = true
	var shadow := Polygon2D.new()
	shadow.name = "Shadow"
	shadow.polygon = PackedVector2Array([Vector2(-22, 0), Vector2(0, -7), Vector2(25, 0), Vector2(6, 7), Vector2(-16, 6)])
	shadow.color = Color(0.02, 0.05, 0.07, 0.48)
	avatar.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.name = "Body"
	sprite.texture = FEMALE_IDLE if gender == "female" else MALE_IDLE
	sprite.region_enabled = true
	_set_direction(sprite, "south")
	sprite.position = Vector2(0, -60)
	sprite.scale = Vector2(0.30, 0.30)
	avatar.add_child(sprite)
	var name_label := Label.new()
	name_label.name = "Name"
	name_label.position = Vector2(-80, -126)
	name_label.size = Vector2(160, 24)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.52))
	name_label.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.08))
	name_label.add_theme_constant_override("outline_size", 5)
	avatar.add_child(name_label)
	return avatar


func _set_direction(sprite: Sprite2D, direction: String) -> void:
	var texture_size := sprite.texture.get_size()
	var cell_size := Vector2(texture_size.x / 4.0, texture_size.y / 2.0)
	var index: int = int({"south": 0, "west": 2, "north": 4, "east": 6}.get(direction, 0))
	sprite.region_rect = Rect2(Vector2(float(index % 4) * cell_size.x, float(index / 4) * cell_size.y), cell_size)
