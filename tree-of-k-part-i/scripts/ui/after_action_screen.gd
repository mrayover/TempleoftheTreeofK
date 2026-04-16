extends CanvasLayer

signal continue_to_stage_2_requested

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_tree().paused = false
		continue_to_stage_2_requested.emit()
		queue_free()