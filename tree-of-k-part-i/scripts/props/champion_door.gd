extends Node2D

enum DoorType {
	CHAMBER,
	CHAMPION_GATE,
	CHAMPION_STAGE
}

@export var door_type: DoorType = DoorType.CHAMBER
@export var target_spawn_path: NodePath
@export var target_camera_path: NodePath
@export var target_room_name: String = ""
@export var target_scene_path: String = ""
@export var locked_prompt: String = "Both Champion Key Halves Required"
@export var unlocked_prompt: String = "Enter (E)"

@onready var interact_area: Area2D = $Area2D

var player_in_range: bool = false

func _ready() -> void:
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

func _unhandled_input(_event: InputEvent) -> void:
	if not player_in_range:
		return

	if not Input.is_action_just_pressed("interact"):
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	if not _can_use_door(scene_root):
		return

	if scene_root.has_method("hide_door_prompt"):
		scene_root.hide_door_prompt()

	player_in_range = false

	match door_type:
		DoorType.CHAMBER:
			var spawn_marker := scene_root.get_node_or_null(target_spawn_path) as Marker2D
			var camera_marker := scene_root.get_node_or_null(target_camera_path) as Marker2D

			if spawn_marker == null or camera_marker == null:
				return

			if scene_root.has_method("use_chamber_door"):
				scene_root.use_chamber_door(spawn_marker, camera_marker, target_room_name)
				get_viewport().set_input_as_handled()

		DoorType.CHAMPION_GATE, DoorType.CHAMPION_STAGE:
			if scene_root.has_method("use_champion_stage_door"):
				var viewport := get_viewport()
				if viewport != null:
					viewport.set_input_as_handled()

				scene_root.use_champion_stage_door(target_scene_path)

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	player_in_range = true
	_refresh_prompt()

func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	player_in_range = false

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("hide_door_prompt"):
		scene_root.hide_door_prompt()

func _refresh_prompt() -> void:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	if not scene_root.has_method("show_door_prompt"):
		return

	if (door_type == DoorType.CHAMPION_GATE or door_type == DoorType.CHAMPION_STAGE) and not _can_use_door(scene_root):
		scene_root.show_door_prompt(locked_prompt)
	else:
		scene_root.show_door_prompt(unlocked_prompt)

func _can_use_door(scene_root: Node) -> bool:
	if door_type == DoorType.CHAMBER:
		return true

	return scene_root.has_method("can_use_champion_gate") and scene_root.can_use_champion_gate()
