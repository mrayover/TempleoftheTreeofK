extends Area2D

@onready var visual: Polygon2D = $Polygon2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	if not body.is_in_group("player"):
		return

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("collect_guardian_fragment"):
		scene_root.collect_guardian_fragment()
		queue_free()