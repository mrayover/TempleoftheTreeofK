extends CanvasLayer

signal resume_requested
signal restart_requested
signal quit_to_main_menu_requested

const ROOM_UNVISITED := Color(0.15, 0.15, 0.18, 0.9)
const ROOM_VISITED := Color(0.75, 0.78, 0.85, 0.9)
const ROOM_CURRENT := Color(0.75, 0.18, 0.18, 1.0)

const KEY_EMPTY := Color(0.08, 0.08, 0.08, 0.95)
const KEY_FILLED := Color(0.95, 0.95, 0.35, 1.0)

@onready var pause_label: Label = $PauseLabel
@onready var stage_label: Label = $StageLabel
@onready var resume_button: Button = $ResumeButton
@onready var restart_run_button: Button = $RestartRunButton
@onready var quit_to_main_menu_button: Button = $QuitToMainMenuButton
@onready var archetype_title: Label = $ArchetypeTitle
@onready var archetype_name: Label = $ArchetypeName
@onready var champion_key_label: Label = $ChampionKeyLabel
@onready var champion_key_box: ColorRect = $ChampionKeyBox
@onready var guardian_fragments_label: Label = $GuardianFragmentsLabel
@onready var guardian_fragments_placeholder: ColorRect = $GuardianFragmentsPlaceholder

@onready var room_center_box: ColorRect = $MapContainer/RoomCenterBox
@onready var room_up_box: ColorRect = $MapContainer/RoomUpBox
@onready var room_right_box: ColorRect = $MapContainer/RoomRightBox
@onready var room_champion_box: ColorRect = $MapContainer/RoomChampionBox

var current_stage: int = 1
var current_archetype_name: String = "Snake"
var champion_key_collected: bool = false
var guardian_fragment_collected: bool = false
var current_room: String = "center"

var visited_rooms := {
	"center": false,
	"up": false,
	"right": false,
	"champion": false
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	resume_button.pressed.connect(_on_resume_pressed)
	restart_run_button.pressed.connect(_on_restart_run_pressed)
	quit_to_main_menu_button.pressed.connect(_on_quit_to_main_menu_pressed)

	_refresh_all()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		resume_requested.emit()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	visible = true
	resume_button.grab_focus()
	_refresh_all()

func close_menu() -> void:
	visible = false

func set_stage(stage_number: int) -> void:
	current_stage = stage_number
	_refresh_stage()

func set_archetype_name(archetype_text: String) -> void:
	current_archetype_name = archetype_text
	_refresh_archetype()

func set_champion_key_collected(collected: bool) -> void:
	champion_key_collected = collected
	_refresh_champion_key()

func set_guardian_fragment_collected(collected: bool) -> void:
	guardian_fragment_collected = collected
	_refresh_guardian_fragment()

func set_current_room(room_name: String) -> void:
	if not visited_rooms.has(room_name):
		return

	current_room = room_name
	visited_rooms[room_name] = true
	_refresh_map()

func set_visited_rooms(new_visited_rooms: Dictionary) -> void:
	for key in visited_rooms.keys():
		if new_visited_rooms.has(key):
			visited_rooms[key] = bool(new_visited_rooms[key])

	_refresh_map()

func _refresh_all() -> void:
	_refresh_stage()
	_refresh_archetype()
	_refresh_champion_key()
	_refresh_guardian_fragment()
	_refresh_map()

func _refresh_stage() -> void:
	stage_label.text = "Stage %d" % current_stage

func _refresh_archetype() -> void:
	archetype_name.text = current_archetype_name

func _refresh_champion_key() -> void:
	champion_key_box.color = KEY_FILLED if champion_key_collected else KEY_EMPTY

func _refresh_guardian_fragment() -> void:
	guardian_fragments_placeholder.color = KEY_FILLED if guardian_fragment_collected else KEY_EMPTY

func _refresh_map() -> void:
	_set_room_box_state(room_center_box, "center")
	_set_room_box_state(room_up_box, "up")
	_set_room_box_state(room_right_box, "right")
	_set_room_box_state(room_champion_box, "champion")

func _set_room_box_state(box: ColorRect, room_name: String) -> void:
	if current_room == room_name:
		box.color = ROOM_CURRENT
	elif visited_rooms.get(room_name, false):
		box.color = ROOM_VISITED
	else:
		box.color = ROOM_UNVISITED

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_restart_run_pressed() -> void:
	restart_requested.emit()

func _on_quit_to_main_menu_pressed() -> void:
	quit_to_main_menu_requested.emit()
