extends Node2D

@export var horizontal_follow_margin: float = 64.0
@export var vertical_follow_margin: float = 120.0
@export var vertical_switch_deadzone: float = 0.0
@export var entry_camera_y_offset: float = 16.0
@export var vertical_slide_speed: float = 720.0

@onready var player = $Player
@onready var camera: Camera2D = $Camera2D
@onready var player_start: Marker2D = $PlayerStart
@onready var chambers: Node2D = $Chambers

var active_room: Node2D = null
var vertical_snap_to_bottom: bool = false

func _ready() -> void:
	if camera != null:
		camera.make_current()

	if player != null and player_start != null:
		player.global_position = player_start.global_position

	active_room = chambers.get_node_or_null("gray_box_tall") as Node2D
	_snap_camera_to_active_room()

func _process(delta: float) -> void:
	_update_camera_follow(delta)

func show_door_prompt(_text: String) -> void:
	return

func hide_door_prompt() -> void:
	return

func use_chamber_door(spawn_marker: Marker2D, _camera_marker: Marker2D, target_room_name: String = "") -> void:
	if player != null and spawn_marker != null:
		player.global_position = spawn_marker.global_position

	if target_room_name != "":
		var destination_room := chambers.get_node_or_null(target_room_name) as Node2D
		if destination_room != null:
			active_room = destination_room

	_snap_camera_to_active_room()

func _snap_camera_to_active_room() -> void:
	if camera == null or active_room == null:
		return

	var room_rect := _get_active_room_rect()
	if room_rect.size == Vector2.ZERO:
		return

	var target_marker := active_room.get_node_or_null("CameraTarget") as Marker2D
	var snap_position := room_rect.get_center()

	if target_marker != null:
		snap_position = target_marker.global_position

	snap_position.y += entry_camera_y_offset
	camera.global_position = _clamp_camera_to_room(snap_position, room_rect)

	var clamped_center := _clamp_camera_to_room(room_rect.get_center(), room_rect).y
	vertical_snap_to_bottom = camera.global_position.y > clamped_center

func _update_camera_follow(delta: float) -> void:
	if player == null or camera == null or active_room == null:
		return

	var room_rect := _get_active_room_rect()
	if room_rect.size == Vector2.ZERO:
		return

	var next_position := camera.global_position
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

	var left_limit := camera.global_position.x - horizontal_follow_margin
	var right_limit := camera.global_position.x + horizontal_follow_margin

	if player.global_position.x < left_limit:
		next_position.x = player.global_position.x + horizontal_follow_margin
	elif player.global_position.x > right_limit:
		next_position.x = player.global_position.x - horizontal_follow_margin

	var room_mid_y := room_rect.position.y + (room_rect.size.y * 0.5)
	var switch_down_trigger := room_mid_y + vertical_switch_deadzone
	var switch_up_trigger := room_mid_y - vertical_switch_deadzone

	if not vertical_snap_to_bottom:
		if player.global_position.y > switch_down_trigger:
			vertical_snap_to_bottom = true
	else:
		if player.global_position.y < switch_up_trigger:
			vertical_snap_to_bottom = false

	var snap_offset := 6.0
	var target_y := (max_y if vertical_snap_to_bottom else min_y) + snap_offset
	next_position.y = move_toward(camera.global_position.y, target_y, vertical_slide_speed * delta)

	camera.global_position = Vector2(
		clamp(next_position.x, min_x, max_x),
		clamp(next_position.y, min_y, max_y)
	)

func _clamp_camera_to_room(target_position: Vector2, room_rect: Rect2) -> Vector2:
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

	return Vector2(
		clamp(target_position.x, min_x, max_x),
		clamp(target_position.y, min_y, max_y)
	)

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
