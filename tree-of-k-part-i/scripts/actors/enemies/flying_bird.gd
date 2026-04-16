extends CharacterBody2D

@export var speed: float = 80.0
@export var min_x: float = -99999.0
@export var max_x: float = 99999.0
@export var max_hp: int = 2
@export var dash_strike_stun_time: float = 0.18
@export var dash_strike_attack_lock_time: float = 0.28
@export var dash_strike_invulnerability_time: float = 0.18

@onready var visual: Sprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var direction: int = -1
var current_hp: int = 2
var bonus_hp: int = 0
var bonus_hp_label: Label = null
var dead: bool = false
var dash_strike_stun_timer: float = 0.0
var dash_strike_attack_lock_timer: float = 0.0
var dash_strike_invulnerability_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	current_hp = max_hp
	bonus_hp = 0
	hurtbox.area_entered.connect(_on_hit)

	if visual != null:
		visual.visible = true

	_setup_bonus_hp_label()
	_update_bonus_hp_label()
	_update_facing()

func _physics_process(delta: float) -> void:
	if dead:
		return

	if dash_strike_attack_lock_timer > 0.0:
		dash_strike_attack_lock_timer -= delta
		if dash_strike_attack_lock_timer < 0.0:
			dash_strike_attack_lock_timer = 0.0

	if dash_strike_invulnerability_timer > 0.0:
		dash_strike_invulnerability_timer -= delta
		if dash_strike_invulnerability_timer < 0.0:
			dash_strike_invulnerability_timer = 0.0

	if dash_strike_stun_timer > 0.0:
		dash_strike_stun_timer -= delta
		move_and_slide()

		if dash_strike_stun_timer <= 0.0:
			dash_strike_stun_timer = 0.0
			velocity = Vector2.ZERO

		return

	velocity = Vector2(direction * speed, 0.0)
	move_and_slide()

	if global_position.x <= min_x:
		direction = 1
		_update_facing()
	elif global_position.x >= max_x:
		direction = -1
		_update_facing()

	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Node = collision.get_collider() as Node
		var normal: Vector2 = collision.get_normal()

		if collider == null:
			continue

		if collider.is_in_group("solid") and abs(normal.x) > 0.9:
			direction *= -1
			_update_facing()
			break

func _update_facing() -> void:
	if visual == null:
		return

	visual.flip_h = direction > 0

func _setup_bonus_hp_label() -> void:
	bonus_hp_label = Label.new()
	bonus_hp_label.text = "1"
	bonus_hp_label.visible = false
	bonus_hp_label.position = Vector2(-4, -28)
	add_child(bonus_hp_label)

func _update_bonus_hp_label() -> void:
	if bonus_hp_label == null:
		return

	bonus_hp_label.text = str(bonus_hp)
	bonus_hp_label.visible = bonus_hp > 0

func can_damage_player() -> bool:
	return not dead and dash_strike_stun_timer <= 0.0 and dash_strike_attack_lock_timer <= 0.0

func apply_dash_strike(dash_dir: int, damage: int, knockback_x: float, knockback_y: float) -> void:
	if dead:
		return

	if dash_strike_invulnerability_timer > 0.0:
		return

	take_projectile_damage(damage)

	if dead:
		return

	dash_strike_invulnerability_timer = dash_strike_invulnerability_time
	dash_strike_stun_timer = dash_strike_stun_time
	dash_strike_attack_lock_timer = dash_strike_attack_lock_time

	if dash_dir != 0:
		direction = 1 if dash_dir > 0 else -1
		_update_facing()

	velocity.x = float(dash_dir) * knockback_x
	velocity.y = knockback_y * 0.35

func take_projectile_damage(amount: int) -> void:
	if dead:
		return

	var damage_left: int = amount

	if bonus_hp > 0 and damage_left > 0:
		bonus_hp = 0
		damage_left -= 1
		_update_bonus_hp_label()

	if damage_left > 0:
		current_hp -= damage_left

	if current_hp <= 0:
		die()

func die() -> void:
	if dead:
		return

	dead = true
	velocity = Vector2.ZERO

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	if has_node("Hurtbox/CollisionShape2D"):
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

	queue_free()

func apply_powerup() -> void:
	if dead:
		return

	if current_hp < max_hp:
		current_hp += 1
	else:
		bonus_hp = 1

	_update_bonus_hp_label()

func _on_hit(area: Area2D) -> void:
	if dead:
		return

	if not area.is_in_group("projectile"):
		return

	var damage: int = 1

	if area.has_method("get_hit_power"):
		damage = area.get_hit_power()

	var projectile_shooter = area.get("shooter")
	if projectile_shooter != null and projectile_shooter.has_method("add_special_tick"):
		projectile_shooter.add_special_tick()

	take_projectile_damage(damage)
	area.queue_free()
