extends Node2D

const DEFAULT_CHICKEN_SCENE: PackedScene = preload("res://scenes/actors/enemies/Chicken.tscn")

@export var enemy_scene: PackedScene = DEFAULT_CHICKEN_SCENE
@export var max_alive_enemies: int = 3
@export var spawn_interval_min: float = 2.0
@export var spawn_interval_max: float = 5.0
@export var spawn_offset: Vector2 = Vector2(0, -16)

@export var patrol_left: float = -120.0
@export var patrol_right: float = 120.0
@export var spawn_spread: float = 40.0

@export var nest_max_hp: int = 3
@export var reward_scene: PackedScene
@export var reward_spawn_offset: Vector2 = Vector2(0, -20)

var alive_enemies: Array[Node] = []
var current_hp: int = 0
var destroyed: bool = false

@onready var spawn_timer: Timer = $SpawnTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var visual: CanvasItem = $Visual if has_node("Visual") else null

func _ready() -> void:
	randomize()
	add_to_group("destructible_nest")

	current_hp = nest_max_hp

	if spawn_timer != null and not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	if hurtbox != null and not hurtbox.area_entered.is_connected(_on_hurtbox_area_entered):
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	_reset_spawn_timer()

func _on_spawn_timer_timeout() -> void:
	if destroyed:
		return

	_cleanup_dead_enemies()

	if enemy_scene == null:
		_reset_spawn_timer()
		return

	if alive_enemies.size() < max_alive_enemies:
		var enemy: Node = enemy_scene.instantiate()
		get_parent().add_child(enemy)

		var slot_index: int = alive_enemies.size()
		var spawn_x: float = (float(slot_index) - 1.0) * spawn_spread

		if slot_index <= 0:
			spawn_x = -spawn_spread
		elif slot_index == 1:
			spawn_x = 0.0
		elif slot_index == 2:
			spawn_x = spawn_spread

		if enemy is Node2D:
			(enemy as Node2D).global_position = global_position + spawn_offset + Vector2(spawn_x, 0)

		if "min_x" in enemy:
			enemy.min_x = global_position.x + patrol_left

		if "max_x" in enemy:
			enemy.max_x = global_position.x + patrol_right

		alive_enemies.append(enemy)
		enemy.tree_exited.connect(_on_enemy_removed.bind(enemy))

	_reset_spawn_timer()

func _on_enemy_removed(enemy: Node) -> void:
	alive_enemies.erase(enemy)

func _cleanup_dead_enemies() -> void:
	alive_enemies = alive_enemies.filter(func(e): return is_instance_valid(e))

func _reset_spawn_timer() -> void:
	if destroyed:
		return

	if spawn_timer == null:
		return

	var next_time: float = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.start(next_time)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if destroyed:
		return

	if area == null:
		return

	if not area.is_in_group("projectile"):
		return

	var damage: int = 1
	if area.has_method("get_hit_power"):
		damage = area.get_hit_power()

	take_damage(damage)
	area.queue_free()

func take_damage(amount: int = 1) -> void:
	if destroyed:
		return

	current_hp -= amount

	if current_hp <= 0:
		destroy_nest()

func destroy_nest() -> void:
	if destroyed:
		return

	destroyed = true

	if spawn_timer != null:
		spawn_timer.stop()

	if hurtbox_shape != null:
		hurtbox_shape.set_deferred("disabled", true)

	if visual != null:
		visual.visible = false

	_drop_reward_if_any()
	queue_free()

func _drop_reward_if_any() -> void:
	if reward_scene == null:
		return

	var reward := reward_scene.instantiate()
	get_parent().add_child(reward)

	if reward is Node2D:
		(reward as Node2D).global_position = global_position + reward_spawn_offset
