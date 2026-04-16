extends Area2D

@export var pair_index: int = 0
@export var key_half_id: String = "A"

@onready var visual: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if _should_remove_for_current_run():
		queue_free()
		return

	if visual != null:
		visual.play("Idle")

func _should_remove_for_current_run() -> bool:
	if pair_index != RunState.get_active_key_pair_index():
		return true

	match key_half_id:
		"A":
			return RunState.champion_key_half_a_collected
		"B":
			return RunState.champion_key_half_b_collected

	return false

func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	if not body.is_in_group("player"):
		return

	RunState.set_champion_key_half(key_half_id, true)

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("collect_champion_key_half"):
		scene_root.collect_champion_key_half(key_half_id)

	queue_free()
