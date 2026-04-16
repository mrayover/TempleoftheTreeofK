extends Area2D

var magnet_range := 48.0
var magnet_speed := 220.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist < magnet_range:
		global_position = global_position.move_toward(
			player.global_position,
			magnet_speed * delta
		)

func _on_body_entered(body: Node) -> void:
	_try_apply_to_node(body)

func _on_area_entered(area: Area2D) -> void:
	if area == null:
		return

	_try_apply_to_node(area)

	var area_parent := area.get_parent()
	if area_parent != null:
		_try_apply_to_node(area_parent)

func _try_apply_to_node(node: Node) -> void:
	if node == null:
		return

	if node.is_in_group("player") and node.has_method("apply_powerup"):
		node.apply_powerup()
		queue_free()
		return

	if node.is_in_group("enemy") and node.has_method("apply_powerup"):
		node.apply_powerup()
		queue_free()
		return
