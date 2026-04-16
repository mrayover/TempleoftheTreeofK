extends Node2D

const TITLE_SCREEN_PATH := "res://scenes/ui/title_screen.tscn"
const AFTER_ACTION_SCREEN_PATH := "res://scenes/ui/after_action_screen.tscn"

@onready var room_camera: Camera2D = $RoomCamera
@onready var cam_center: Marker2D = $Cam_Center
@onready var cam_corridor_1: Marker2D = $Cam_Corridor1
@onready var cam_right: Marker2D = $Cam_Right
@onready var cam_up: Marker2D = $Cam_Up
@onready var cam_corridor_2: Marker2D = $Cam_Corridor2
@onready var cam_corridor_3: Marker2D = $Cam_Corridor3
@onready var cam_ChampionChamber: Marker2D = $Cam_ChampionChamber
@onready var countdown_layer: CanvasLayer = $CountdownLayer
@onready var champion_entry_spawn: Marker2D = $Spawn_PlayerChampionEntry
@onready var stage_return_spawn: Marker2D = $Spawn_PlayerStageReturn
@onready var champion_entry_spawn_2: Marker2D = $Spawn_PlayerChampionEntry2
@onready var countdown_label: Label = $CountdownLayer/CountdownLabel
@onready var restart_layer: CanvasLayer = $RestartLayer
@onready var restart_button: Button = $RestartLayer/RestartButton
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var door_prompt_layer: CanvasLayer = $DoorPromptLayer
@onready var door_prompt_box: PanelContainer = $DoorPromptLayer/PromptBox
@onready var door_prompt_label: Label = $DoorPromptLayer/PromptBox/StatusLabel
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var fade_rect: ColorRect = $TransitionLayer/FadeRect
@onready var champion_arena_gate_collision: CollisionShape2D = $ChampionArenaGate/CollisionShape2D

var champion_cleared: bool = false
var champion_spawned: bool = false
var is_transitioning: bool = false
var champion_fight_active: bool = false
var is_champion_intro_running: bool = false
var waiting_for_stage_exit: bool = false
var after_action_report_open: bool = false
var active_champion: Node = null

@export var champion_intro_black_hold: float = 0.20
@export var champion_intro_reveal_hold: float = 1.25
var current_stage: int = 1
var current_room: String = "center"
var visited_rooms := {
	"center": false,
	"corridor_1": false,
	"right": false,
	"up": false,
	"corridor_2": false,
	"corridor_3": false,
	"champion": false
}

@onready var champion_spawn_point = $Spawn_Champion
@onready var champion_scene = preload("res://scenes/actors/enemies/champion.tscn")

func _ready() -> void:
	room_camera.global_position = cam_center.global_position

	var player: Node = get_tree().get_first_node_in_group("player")
	if player != null:
		player.player_died.connect(_on_player_died)

	countdown_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	transition_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	door_prompt_box.visible = false
	_set_fade_alpha(0.0)

	restart_layer.visible = false
	restart_button.visible = true
	restart_button.disabled = false
	restart_button.pressed.connect(_on_restart_pressed)

	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.restart_requested.connect(_on_pause_restart_requested)
	pause_menu.quit_to_main_menu_requested.connect(_on_pause_quit_to_main_menu_requested)

	current_stage = 1
	RunState.current_stage = 1
	RunState.champion_cleared = false
	RunState.clear_champion_keys()

	_set_current_room("center")
	_sync_pause_menu()

	call_deferred("_run_start_countdown")

func has_champion_key() -> bool:
	return RunState.has_champion_key()

func has_guardian_fragment() -> bool:
	return RunState.guardian_fragment_collected

func can_use_champion_gate() -> bool:
	return has_champion_key()

func use_chamber_door(spawn_marker: Marker2D, camera_marker: Marker2D, room_name: String) -> void:
	if spawn_marker == null:
		return
	if camera_marker == null:
		return

	await _transition_player_to_spawn(spawn_marker, camera_marker, room_name)

func use_champion_stage_door(spawn_marker: Marker2D, camera_marker: Marker2D, room_name: String) -> void:
	if spawn_marker == null:
		return
	if camera_marker == null:
		return

	await _transition_player_to_spawn(spawn_marker, camera_marker, room_name)

	if champion_spawned:
		return

	await _start_champion_intro()

func show_door_prompt(prompt_text: String) -> void:
	door_prompt_label.text = prompt_text
	door_prompt_box.visible = true

func hide_door_prompt() -> void:
	door_prompt_box.visible = false

func _lock_champion_chamber() -> void:
	champion_fight_active = true
	if champion_arena_gate_collision != null:
		champion_arena_gate_collision.set_deferred("disabled", false)

func _unlock_champion_chamber() -> void:
	champion_fight_active = false
	if champion_arena_gate_collision != null:
		champion_arena_gate_collision.set_deferred("disabled", true)

func _set_fade_alpha(alpha: float) -> void:
	var color := fade_rect.color
	color.a = alpha
	fade_rect.color = color

func _transition_player_to_spawn(spawn_marker: Marker2D, camera_marker: Marker2D, room_name: String) -> void:
	if is_transitioning:
		return

	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		return
	if spawn_marker == null:
		return
	if camera_marker == null:
		return

	is_transitioning = true
	hide_door_prompt()

	var tween_out := create_tween()
	tween_out.tween_method(_set_fade_alpha, fade_rect.color.a, 1.0, 0.15)
	await tween_out.finished

	player.global_position = spawn_marker.global_position
	player.velocity = Vector2.ZERO

	room_camera.global_position = camera_marker.global_position
	_set_current_room(room_name)

	var tween_in := create_tween()
	tween_in.tween_method(_set_fade_alpha, fade_rect.color.a, 0.0, 0.15)
	await tween_in.finished

	is_transitioning = false

func _set_player_input_enabled(enabled: bool) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("set_input_enabled"):
		player.set_input_enabled(enabled)

func _start_champion_intro() -> void:
	if is_champion_intro_running or champion_spawned:
		return

	is_champion_intro_running = true
	hide_door_prompt()
	_set_player_input_enabled(false)

	var tween_out := create_tween()
	tween_out.tween_method(_set_fade_alpha, fade_rect.color.a, 1.0, 0.15)
	await tween_out.finished

	_lock_champion_chamber()
	champion_spawned = true
	_spawn_champion()

	if active_champion != null and active_champion.has_method("set_encounter_active"):
		active_champion.set_encounter_active(false)

	await get_tree().create_timer(champion_intro_black_hold).timeout

	var tween_in := create_tween()
	tween_in.tween_method(_set_fade_alpha, fade_rect.color.a, 0.0, 0.20)
	await tween_in.finished

	await get_tree().create_timer(champion_intro_reveal_hold).timeout

	if active_champion != null and active_champion.has_method("set_encounter_active"):
		active_champion.set_encounter_active(true)

	_set_player_input_enabled(true)
	is_champion_intro_running = false

func collect_champion_key_half(key_half_id: String) -> void:
	RunState.set_champion_key_half(key_half_id, true)
	_sync_pause_menu()

func collect_guardian_fragment() -> void:
	RunState.guardian_fragment_collected = true
	_sync_pause_menu()

func _set_current_room(room_name: String) -> void:
	if not visited_rooms.has(room_name):
		return

	current_room = room_name
	visited_rooms[room_name] = true
	_sync_pause_menu()

func _sync_pause_menu() -> void:
	if pause_menu == null:
		return

	pause_menu.set_stage(current_stage)
	pause_menu.set_archetype_name(_get_current_archetype_name())
	pause_menu.set_champion_key_collected(has_champion_key())
	pause_menu.set_guardian_fragment_collected(RunState.guardian_fragment_collected)
	pause_menu.set_visited_rooms(visited_rooms)
	pause_menu.set_current_room(current_room)

func _get_current_archetype_name() -> String:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return "Unknown"

	if player.can_shield:
		return "Heart"
	if player.can_hover:
		return "Crow"
	if player.can_dash:
		return "Snake"

	return "Sunburst"

func _toggle_pause_menu() -> void:
	if restart_layer.visible:
		return

	if pause_menu.visible:
		pause_menu.close_menu()
		get_tree().paused = false
	else:
		_sync_pause_menu()
		pause_menu.open_menu()
		get_tree().paused = true

func _on_pause_resume_requested() -> void:
	pause_menu.close_menu()
	get_tree().paused = false

func _on_pause_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_quit_to_main_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCREEN_PATH)

func _on_trigger_spawn_champion_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if champion_spawned or is_champion_intro_running:
		return

	champion_spawned = true
	_lock_champion_chamber()
	call_deferred("_spawn_champion")

func _spawn_champion() -> void:
	var champion = champion_scene.instantiate()
	champion.global_position = champion_spawn_point.global_position

	active_champion = champion

	if champion.has_signal("champion_defeated"):
		champion.champion_defeated.connect(_on_champion_defeated)

	add_child(champion)

func _on_champion_defeated() -> void:
	champion_fight_active = false

	if active_champion != null:
		if active_champion.has_method("set_encounter_active"):
			active_champion.set_encounter_active(false)

	var player := get_tree().get_first_node_in_group("player")
	RunState.sync_player_powers_from(player)

	champion_cleared = true
	collect_guardian_fragment()

	RunState.clear_champion_keys()
	_sync_pause_menu()

	_unlock_champion_chamber()

	waiting_for_stage_exit = true
	after_action_report_open = false
	show_door_prompt("Press E to Exit Stage")

func _show_after_action_report() -> void:
	if after_action_report_open:
		return

	var after_action_scene := preload(AFTER_ACTION_SCREEN_PATH)
	var after_action := after_action_scene.instantiate()

	if after_action.has_signal("continue_to_stage_2_requested"):
		after_action.continue_to_stage_2_requested.connect(_on_after_action_continue_to_stage_2_requested)

	add_child(after_action)

	after_action_report_open = true
	waiting_for_stage_exit = false
	hide_door_prompt()
	get_tree().paused = true

func _on_after_action_continue_to_stage_2_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level/stage_2_stub.tscn")

func _on_after_action_exit_stage_requested() -> void:
	get_tree().change_scene_to_file("res://scenes/level/stage_2_stub.tscn")

func _on_player_died() -> void:
	_unlock_champion_chamber()

	restart_layer.visible = true
	restart_button.visible = true
	restart_button.disabled = false
	restart_button.grab_focus()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _run_start_countdown() -> void:
	await get_tree().process_frame

	get_tree().paused = true
	countdown_label.visible = true

	countdown_label.text = "3"
	await get_tree().create_timer(1.0, true).timeout

	countdown_label.text = "2"
	await get_tree().create_timer(1.0, true).timeout

	countdown_label.text = "1"
	await get_tree().create_timer(1.0, true).timeout

	get_tree().paused = false
	countdown_label.text = "GO!"

	await get_tree().create_timer(0.5).timeout
	countdown_label.visible = false

func _on_trigger_center_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_center.global_position
		_set_current_room("center")

func _on_trigger_corridor_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_corridor_1.global_position
		_set_current_room("corridor_1")

func _on_trigger_right_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_right.global_position
		_set_current_room("right")

func _on_trigger_up_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_up.global_position
		_set_current_room("up")

func _on_trigger_corridor_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_corridor_2.global_position
		_set_current_room("corridor_2")

func _on_trigger_corridor_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_corridor_3.global_position
		_set_current_room("corridor_3")

func _on_trigger_champion_chamber_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		room_camera.global_position = cam_ChampionChamber.global_position
		_set_current_room("champion")

func _physics_process(_delta: float) -> void:
	_update_vertical_camera_failsafe()

func _update_vertical_camera_failsafe() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var vertical_midpoint: float = (cam_center.global_position.y + cam_up.global_position.y) * 0.5

	if room_camera.global_position == cam_up.global_position and player.global_position.y > vertical_midpoint:
		room_camera.global_position = cam_center.global_position
	elif room_camera.global_position == cam_center.global_position and player.global_position.y < vertical_midpoint:
		room_camera.global_position = cam_up.global_position

func _unhandled_input(event: InputEvent) -> void:
	if waiting_for_stage_exit:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
			_show_after_action_report()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_toggle_pause_menu()
		return

	if event.is_action_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
