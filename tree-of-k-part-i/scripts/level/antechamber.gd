extends Node2D

@onready var player = $Player
@onready var player_start: Marker2D = $PlayerStart
@onready var corridor_spawn: Marker2D = $CorridorSpawn
@onready var camera: Camera2D = $Camera2D
@onready var camera_top_left: Marker2D = $CameraBounds/LeftTopEdge
@onready var camera_bottom_right: Marker2D = $CameraBounds/RightBottomEdge

var current_door: Area2D = null


func _ready() -> void:
	if player != null and player_start != null:
		player.global_position = player_start.global_position

	_update_camera_follow()


func _process(_delta: float) -> void:
	_update_camera_follow()

	if current_door == null:
		return

	if Input.is_action_just_pressed("interact"):
		if current_door.name == "ChamberDoor":
			player.global_position = corridor_spawn.global_position
		elif current_door.name == "StageDoor":
			RunState.reset_for_new_run()
			get_tree().change_scene_to_file("res://scenes/level/main_stage_1.tscn")


func _update_camera_follow() -> void:
	if player == null or camera == null:
		return

	if camera_top_left == null or camera_bottom_right == null:
		return

	var room_rect := Rect2(
		camera_top_left.global_position,
		camera_bottom_right.global_position - camera_top_left.global_position
	)

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


func _on_chamber_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_door = $ChamberDoor


func _on_chamber_door_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and current_door == $ChamberDoor:
		current_door = null


func _on_stage_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_door = $StageDoor


func _on_stage_door_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and current_door == $StageDoor:
		current_door = null