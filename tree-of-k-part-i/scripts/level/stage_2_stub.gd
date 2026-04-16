extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/player/Player.tscn")

@onready var camera: Camera2D = $Camera2D
@onready var spawn_player: Marker2D = $Spawn_Player
@onready var title_label: Label = $CanvasLayer/TitleLabel

var player_instance: CharacterBody2D = null

func _ready() -> void:
	get_tree().paused = false
	RunState.current_stage = 2

	player_instance = PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child(player_instance)
	player_instance.global_position = spawn_player.global_position
	RunState.apply_player_powers_to(player_instance)

	camera.make_current()
	camera.position = Vector2.ZERO
	camera.global_position = Vector2.ZERO

	title_label.text = "Stage 2 Begin"
	title_label.modulate.a = 1.0

	await get_tree().create_timer(1.0).timeout

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, 1.0)

func _process(_delta: float) -> void:
	pass
