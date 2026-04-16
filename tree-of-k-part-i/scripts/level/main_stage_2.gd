extends Node2D

@onready var player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var player_start: Marker2D = $PlayerStart
@onready var chambers: Node2D = $Chambers
@onready var corridors: Node2D = $Corridors

var active_room: Node2D = null

func _ready() -> void:
	if player != null and player_start != null:
		player.global_position = player_start.global_position

	active_room = chambers.get_node_or_null("chamber_1") as Node2D
	_snap_camera_to_active_room()

func _process(_delta: float) -> void:
	_update_camera_follow()

func show_door_prompt(_text: String) -> void:
	return

func hide_door_prompt() -> void:
	return

func use_chamber_door(spawn_marker: Marker2D, _camera_marker: Marker2D, target_room_name: String = "") -> void:
	if player != null and spawn_marker != null:
		player.global_position = spawn_marker.global_position

	if target_room_name != "":
		var destination_room := _get_room_node_by_name(target_room_name)
		if destination_room != null:
			active_room = destination_room

	_snap_camera_to_active_room()

func _get_room_node_by_name(room_name: String) -> Node2D:
	var chamber_room := chambers.get_node_or_null(room_name) as Node2D
	if chamber_room != null:
		return chamber_room

	var corridor_room := corridors.get_node_or_null(room_name) as Node2D
	if corridor_room != null:
		return corridor_room

	return null

func _snap_camera_to_active_room() -> void:
	_update_camera_follow()

func _update_camera_follow() -> void:
	if player == null or camera == null or active_room == null:
		return

	var room_rect := _get_active_room_rect()
	if room_rect.size == Vector2.ZERO:
		return

	var half_view := get_viewport_rect().size * 0.5

	var min_x := room_rect.position.x + half_view.x
	var max_x := room_rect.end.x - half_view.x
	if min_x > max_x:
		var center_x := room_rect.position.x + (room_rect.size.x * 0.5)
		min_x = center_x
		max_x = center_x

	var min_y := room_rect.position.y + half_view.y
	var max_y := room_rect.end.y - half_view.y
	if min_y > max_y:
		var center_y := room_rect.position.y + (room_rect.size.y * 0.5)
		min_y = center_y
		max_y = center_y

	camera.global_position = Vector2(
		clamp(player.global_position.x, min_x, max_x),
		clamp(player.global_position.y, min_y, max_y)
	)

func can_use_champion_gate() -> bool:
	return RunState.has_champion_key()

func use_champion_stage_door(target_scene_path: String) -> void:
	if not can_use_champion_gate():
		print("Champion gate locked. Need 2 keys.")
		return

	get_tree().change_scene_to_file(target_scene_path)

func collect_champion_key_half(key_id: String) -> void:
	var total := 0

	if RunState.champion_key_half_a_collected:
		total += 1
	if RunState.champion_key_half_b_collected:
		total += 1

	print("Champion key collected:", key_id, " Total:", total)

func _get_active_room_rect() -> Rect2:
	if active_room == null:
		return Rect2()

	var top_left := active_room.get_node_or_null("LayoutGuide/LeftTopEdge") as Marker2D
	var bottom_right := active_room.get_node_or_null("LayoutGuide/RightFloorEdge") as Marker2D

	if top_left == null or bottom_right == null:
		return Rect2()

	return Rect2(
		top_left.global_position,
		bottom_right.global_position - top_left.global_position
	)