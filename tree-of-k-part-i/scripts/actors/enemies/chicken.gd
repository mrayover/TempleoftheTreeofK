class_name Chicken
extends CharacterBody2D

var speed: float = 60.0
var direction: int = -1
var gravity: float = 900.0
var peck_effect_timer: float = 0.0
var peck_effect_frame: int = 0
const PECK_EFFECT_FRAME_SIZE := Vector2i(20, 12)
const PECK_EFFECT_FRAMES := 5
const PECK_EFFECT_FPS := 16.0
const PECK_EFFECT_FRAME_TIME := 0.03
var min_x: float = -99999.0
var max_x: float = 99999.0

@export var idle_fps: float = 6.0
@export var walk_fps: float = 10.0
@export var peck_fps: float = 12.0
@export var death_fps: float = 14.0
@export var walk_phase_min: float = 2.2
@export var walk_phase_max: float = 4.6
@export var idle_phase_min: float = 0.2
@export var idle_phase_max: float = 0.5
@export var idle_chance: float = 0.3
@export var peck_trigger_distance: float = 50.0
@export var peck_vertical_tolerance: float = 25.0
@export var peck_cooldown: float = 1.2

@onready var peck_box: Area2D = $PeckBox if has_node("PeckBox") else null
@onready var peck_shape: CollisionShape2D = $PeckBox/CollisionShape2D if has_node("PeckBox/CollisionShape2D") else null
@onready var visual: Sprite2D = $Visual
@onready var edge_check: RayCast2D = $EdgeCheck
@onready var hurtbox: Area2D = $Hurtbox
@onready var peck_effect: Sprite2D = $PeckEffect if has_node("PeckEffect") else null

# Assumes your working scene has DamageBox.
# If not, leave these helpers alone for now.
@onready var damage_box: Area2D = $DamageBox if has_node("DamageBox") else null
@onready var damage_shape: CollisionShape2D = $DamageBox/CollisionShape2D if has_node("DamageBox/CollisionShape2D") else null

@export var max_hp: int = 3
@export var dash_strike_stun_time: float = 0.22
@export var dash_strike_attack_lock_time: float = 0.35
@export var dash_strike_invulnerability_time: float = 0.18

var dead: bool = false
var dying: bool = false
var death_timer: float = 0.0
var current_hp: int = 3
var bonus_hp: int = 0
var bonus_hp_label: Label = null
var dash_strike_stun_timer: float = 0.0
var dash_strike_attack_lock_timer: float = 0.0
var dash_strike_invulnerability_timer: float = 0.0

enum ChickenAnim {
	IDLE,
	WALK,
	PECK,
	DEATH
}

var anim_state: int = ChickenAnim.WALK
var anim_timer: float = 0.0
var anim_frame_index: int = 0
var patrol_idle: bool = false
var behavior_timer: float = 0.0
var peck_timer: float = 0.0
var peck_cooldown_timer: float = 0.0
var rng := RandomNumberGenerator.new()

var peck_turn_locked: bool = false
var pre_peck_direction: int = -1

const IDLE_DURATION := 0.35
const WALK_DURATION := 0.35
const PECK_DURATION := 0.22
const DEATH_DURATION := 0.40

func die() -> void:
	if dead or dying:
		return

	dead = true
	dying = true
	velocity = Vector2.ZERO

	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

	if has_node("StompBox/CollisionShape2D"):
		$StompBox/CollisionShape2D.set_deferred("disabled", true)

	if has_node("DamageBox/CollisionShape2D"):
		$DamageBox/CollisionShape2D.set_deferred("disabled", true)

	if has_node("PeckBox/CollisionShape2D"):
		$PeckBox/CollisionShape2D.set_deferred("disabled", true)

	_set_anim_state(ChickenAnim.DEATH)
	death_timer = _get_animation_duration(ChickenAnim.DEATH)

func stomp() -> void:
	die()

func _ready() -> void:
	add_to_group("enemy")
	current_hp = max_hp
	bonus_hp = 0
	rng.randomize()
	hurtbox.area_entered.connect(_on_hit)

	if damage_box != null:
		damage_box.monitoring = true
		damage_box.monitorable = true

	if peck_box != null:
		peck_box.monitoring = true
		peck_box.monitorable = true

	_set_peck_box_active(false)

	if peck_effect != null:
		peck_effect.visible = false

	_setup_bonus_hp_label()
	_update_bonus_hp_label()
	_update_facing()
	_begin_walk_phase()

func _is_ladder_collider(node: Node) -> bool:
	var current: Node = node

	while current != null:
		if current.is_in_group("ladder"):
			return true
		current = current.get_parent()

	return false
func _physics_process(delta: float) -> void:
	if dying:
		_update_animation(delta)
		_update_peck_effect(delta)
		death_timer -= delta
		if death_timer <= 0.0:
			queue_free()
		return

	if dead:
		return

	if peck_cooldown_timer > 0.0:
		peck_cooldown_timer -= delta
		if peck_cooldown_timer < 0.0:
			peck_cooldown_timer = 0.0

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

		if not is_on_floor():
			velocity.y += gravity * delta

		velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
		move_and_slide()

		if dash_strike_stun_timer <= 0.0:
			dash_strike_stun_timer = 0.0
			velocity = Vector2.ZERO
			_begin_walk_phase()

		_update_animation(delta)
		_update_peck_effect(delta)
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if anim_state == ChickenAnim.PECK:
		velocity.x = 0.0
		peck_timer -= delta

		if peck_timer <= 0.0:
			_stop_peck_effect()

			if peck_turn_locked:
				direction = pre_peck_direction
				peck_turn_locked = false
				_update_facing()

			_begin_idle_phase()

	elif _should_start_peck():
		_begin_peck_phase()
		velocity.x = 0.0

	elif patrol_idle:
		velocity.x = 0.0
		behavior_timer -= delta

		if behavior_timer <= 0.0:
			_begin_walk_phase()

	else:
		velocity.x = direction * speed
		behavior_timer -= delta

	move_and_slide()
	_apply_contact_damage()
	_apply_body_collision_damage()

	var turned_this_frame: bool = false

	if anim_state != ChickenAnim.PECK and not patrol_idle:
		if global_position.x <= min_x:
			direction = 1
			_update_facing()
			turned_this_frame = true

		elif global_position.x >= max_x:
			direction = -1
			_update_facing()
			turned_this_frame = true

		if not turned_this_frame:
			for i in range(get_slide_collision_count()):
				var collision: KinematicCollision2D = get_slide_collision(i)
				var collider: Node = collision.get_collider() as Node
				var normal: Vector2 = collision.get_normal()

				if collider == null:
					continue

				if _is_ladder_collider(collider):
					continue

				if collider.is_in_group("solid") and abs(normal.x) > 0.9:
					direction *= -1
					_update_facing()
					turned_this_frame = true
					break

		if behavior_timer <= 0.0:
			if rng.randf() <= idle_chance:
				_begin_idle_phase()
			else:
				_begin_walk_phase()

	_update_animation(delta)
	_update_peck_effect(delta)

func _update_state() -> void:
	if dying:
		_set_anim_state(ChickenAnim.DEATH)
	elif anim_state == ChickenAnim.PECK:
		_set_anim_state(ChickenAnim.PECK)
	elif patrol_idle:
		_set_anim_state(ChickenAnim.IDLE)
	else:
		_set_anim_state(ChickenAnim.WALK)

func _set_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return

	anim_state = new_state
	anim_timer = 0.0
	anim_frame_index = 0
	_apply_current_frame()

	# Prep hook for future peck hitbox extension
	_set_peck_hitbox_extended(anim_state == ChickenAnim.PECK)

func _update_animation(delta: float) -> void:
	_apply_current_frame()

func _apply_current_frame() -> void:
	if visual == null:
		return

	visual.frame = 0



func _get_current_fps() -> float:
	match anim_state:
		ChickenAnim.IDLE:
			return idle_fps
		ChickenAnim.WALK:
			return walk_fps
		ChickenAnim.PECK:
			return peck_fps
		ChickenAnim.DEATH:
			return death_fps
	return walk_fps

func _get_animation_duration(state: int) -> float:
	match state:
		ChickenAnim.IDLE:
			return IDLE_DURATION
		ChickenAnim.WALK:
			return WALK_DURATION
		ChickenAnim.PECK:
			return PECK_DURATION
		ChickenAnim.DEATH:
			return DEATH_DURATION
		_:
			return 0.0

func _begin_walk_phase() -> void:
	patrol_idle = false
	behavior_timer = rng.randf_range(walk_phase_min, walk_phase_max)
	_set_peck_box_active(false)
	_set_anim_state(ChickenAnim.WALK)

func _begin_idle_phase() -> void:
	patrol_idle = true
	behavior_timer = rng.randf_range(idle_phase_min, idle_phase_max)
	velocity.x = 0.0
	_set_peck_box_active(false)
	_set_anim_state(ChickenAnim.IDLE)

func _begin_peck_phase() -> void:
	patrol_idle = false
	peck_timer = _get_animation_duration(ChickenAnim.PECK)
	peck_cooldown_timer = peck_cooldown
	velocity.x = 0.0
	_set_peck_box_active(true)
	_set_anim_state(ChickenAnim.PECK)
	_start_peck_effect()
func _start_peck_effect() -> void:
	if peck_effect != null:
		peck_effect.visible = false

func _stop_peck_effect() -> void:
	if peck_effect != null:
		peck_effect.visible = false

func _update_peck_effect(delta: float) -> void:
	return

func _update_peck_effect_frame() -> void:
	if peck_effect == null:
		return

	peck_effect.frame = (PECK_EFFECT_FRAMES - 1) - peck_effect_frame

func _update_peck_effect_position() -> void:
	if peck_effect == null:
		return

	peck_effect.flip_h = direction > 0
	peck_effect.position = Vector2(22 * direction, 5)

func _on_peck_box_body_entered(body: Node) -> void:
	if dead or dying:
		return

	if not can_damage_player():
		return

	if body == null:
		return

	if body.has_method("take_damage"):
		body.take_damage(global_position.x)

func _try_face_player_for_peck() -> bool:
	if dead or dying:
		return false

	if dash_strike_stun_timer > 0.0:
		return false

	if dash_strike_attack_lock_timer > 0.0:
		return false

	if peck_cooldown_timer > 0.0:
		return false

	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return false

	if not (player is Node2D):
		return false

	var player_node: Node2D = player as Node2D
	var offset: Vector2 = player_node.global_position - global_position

	if abs(offset.y) > peck_vertical_tolerance:
		return false

	if abs(offset.x) > peck_trigger_distance:
		return false

	if offset.x == 0.0:
		return true

	var desired_direction: int = int(sign(offset.x))
	if desired_direction == 0:
		return true

	if desired_direction != direction:
		pre_peck_direction = direction
		direction = desired_direction
		peck_turn_locked = true
		_update_facing()

	return true

func _should_start_peck() -> bool:
	return _try_face_player_for_peck()

func _set_peck_box_active(is_active: bool) -> void:
	if peck_shape == null:
		return

	peck_shape.disabled = not is_active
	_update_peck_box_position()

func _update_peck_box_position() -> void:
	if peck_shape == null:
		return

	peck_shape.position = Vector2(18 * direction, 10)

func _set_peck_hitbox_extended(is_extended: bool) -> void:
	if damage_shape == null:
		return

	var rect: RectangleShape2D = damage_shape.shape as RectangleShape2D
	if rect == null:
		return

	if is_extended:
		rect.size = Vector2(44, 26)
		damage_shape.position = Vector2(10 * direction, 16)
	else:
		rect.size = Vector2(34, 26)
		damage_shape.position = Vector2(0, 16)

func _update_facing() -> void:
	visual.flip_h = direction > 0
	edge_check.position.x = abs(edge_check.position.x) * direction
	_update_peck_box_position()
	_update_peck_effect_position()

	# Keep any future peck-hitbox offset facing the right way
	if anim_state == ChickenAnim.PECK:
		_set_peck_hitbox_extended(true)

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
	return not dead and not dying and dash_strike_stun_timer <= 0.0 and dash_strike_attack_lock_timer <= 0.0

func apply_dash_strike(dash_dir: int, damage: int, knockback_x: float, knockback_y: float) -> void:
	if dead or dying:
		return

	if dash_strike_invulnerability_timer > 0.0:
		return

	_stop_peck_effect()
	peck_turn_locked = false
	_set_peck_box_active(false)

	take_projectile_damage(damage)

	if dead or dying:
		return

	dash_strike_invulnerability_timer = dash_strike_invulnerability_time
	dash_strike_stun_timer = dash_strike_stun_time
	dash_strike_attack_lock_timer = dash_strike_attack_lock_time
	peck_cooldown_timer = max(peck_cooldown_timer, dash_strike_attack_lock_time)
	patrol_idle = false
	_set_anim_state(ChickenAnim.WALK)

	if dash_dir != 0:
		direction = 1 if dash_dir > 0 else -1
		_update_facing()
		velocity.x = float(dash_dir) * knockback_x
	else:
		velocity.x = 0.0

	velocity.y = knockback_y

func take_projectile_damage(amount: int) -> void:
	if dead or dying:
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

func apply_powerup() -> void:
	if dead or dying:
		return

	if current_hp < max_hp:
		current_hp += 1
	else:
		bonus_hp = 1

	_update_bonus_hp_label()

func _on_hit(area: Area2D) -> void:
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

func _on_stomp_box_body_entered(body: Node) -> void:
	if dead:
		return

	if body == null:
		return

	if body is CharacterBody2D and body.has_method("bounce_from_stomp"):
		if body.velocity.y > 0:
			body.bounce_from_stomp()
			stomp()

func _apply_contact_damage() -> void:
	if dead or dying:
		return

	if not can_damage_player():
		return

	if damage_box == null:
		return

	var overlapping_bodies: Array[Node2D] = damage_box.get_overlapping_bodies()

	for body in overlapping_bodies:
		if body == null:
			continue

		if body.has_method("take_damage"):
			body.take_damage(global_position.x)

func _apply_body_collision_damage() -> void:
	if dead or dying:
		return

	if not can_damage_player():
		return

	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision == null:
			continue

		var collider: Node = collision.get_collider() as Node
		if collider == null:
			continue

		if collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(global_position.x)

func _on_damage_box_body_entered(body: Node) -> void:
	if dead or dying:
		return

	if not can_damage_player():
		return

	if body == null:
		return

	if body.has_method("take_damage"):
		body.take_damage(global_position.x)
