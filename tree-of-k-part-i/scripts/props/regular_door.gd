extends Node2D

@export var target_spawn_path: NodePath
@export var target_camera_path: NodePath
@export var target_room_name: String = ""
@export var prompt_text: String = "Enter (E)"

@onready var interact_area: Area2D = $Area2D

var player_in_range: bool = false

func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range:
		return

	if not Input.is_action_just_pressed("interact"):
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	var spawn_marker := scene_root.get_node_or_null(target_spawn_path) as Marker2D
	var camera_marker := scene_root.get_node_or_null(target_camera_path) as Marker2D

	if spawn_marker == null:
		return
	if camera_marker == null:
		return

	if scene_root.has_method("hide_door_prompt"):
		scene_root.hide_door_prompt()

	player_in_range = false

	if scene_root.has_method("use_chamber_door"):
		scene_root.use_chamber_door(spawn_marker, camera_marker, target_room_name)
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	player_in_range = true

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("show_door_prompt"):
		scene_root.show_door_prompt(prompt_text)

func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	player_in_range = false

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("hide_door_prompt"):
		scene_root.hide_door_prompt()