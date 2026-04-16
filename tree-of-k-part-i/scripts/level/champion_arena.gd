extends Node2D

@onready var player = $Player
@onready var player_start: Marker2D = $PlayerStart
@onready var champion = $Champion
@onready var exit_label: Label = $Label

var can_exit: bool = false
var completion_applied: bool = false


func _ready() -> void:
	if player != null and player_start != null:
		player.global_position = player_start.global_position

	if exit_label != null:
		exit_label.visible = false

	if champion != null and not champion.champion_defeated.is_connected(_on_champion_defeated):
		champion.champion_defeated.connect(_on_champion_defeated)


func _process(_delta: float) -> void:
	if not can_exit:
		return

	if Input.is_action_just_pressed("interact"):
		if completion_applied:
			return

		completion_applied = true

		if RunState.current_stage == 1:
			RunState.mark_stage_1_cleared()
			call_deferred("_go_to_stage_2")
		else:
			RunState.advance_after_champion_clear()
			call_deferred("_return_to_antechamber")


func _on_champion_defeated() -> void:
	can_exit = true

	if exit_label != null:
		exit_label.visible = true


func _go_to_stage_2() -> void:
	get_tree().change_scene_to_file("res://scenes/level/main_stage_2.tscn")


func _return_to_antechamber() -> void:
	get_tree().change_scene_to_file("res://scenes/level/antechamber.tscn")