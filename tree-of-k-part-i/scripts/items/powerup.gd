extends Area2D

var magnet_range := 48.0
var magnet_speed := 220.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

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
	if body == null:
		return

	if body.is_in_group("player") and body.has_method("apply_powerup"):
		body.apply_powerup()
		queue_free()
		return

	if body.is_in_group("enemy") and body.has_method("apply_powerup"):
		body.apply_powerup()
		queue_free()
		return