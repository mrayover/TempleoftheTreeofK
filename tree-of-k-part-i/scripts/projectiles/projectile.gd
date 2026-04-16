extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 1.5

var direction: Vector2 = Vector2.RIGHT
var hit_power: int = 1
var shooter: Node = null

func _ready() -> void:
	add_to_group("projectile")
	body_entered.connect(_on_body_entered)
	_apply_size_from_hit_power()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_hit_power(value: int) -> void:
	hit_power = max(1, value)
	_apply_size_from_hit_power()

func get_hit_power() -> int:
	return hit_power

func set_shooter(value: Node) -> void:
	shooter = value

func _apply_size_from_hit_power() -> void:
	if has_node("Visual"):
		var scale_mult: float = 1.0 + (float(hit_power - 1) * 0.35)
		$Visual.scale = Vector2.ONE * scale_mult

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("solid"):
		queue_free()
