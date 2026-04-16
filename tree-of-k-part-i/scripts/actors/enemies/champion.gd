extends Chicken

signal champion_defeated

enum ChampionAnim {
	IDLE,
	WALK,
	ATTACK,
	DEATH,
	DASH
}

const CHAMPION_ATTACK_DURATION: float = 0.375
const CHAMPION_DEATH_DURATION: float = 0.083

@export var champion_speed: float = 130.0
@export var champion_max_hp: int = 30
@export var champion_attack_trigger_distance: float = 340.0
@export var champion_vertical_tolerance: float = 72.0

@export var champion_dash_speed: float = 420.0
@export var champion_dash_duration: float = 0.45
@export var champion_dash_cooldown: float = 0.25

@export var champion_attack_hitbox_delay: float = 0.10
@export var champion_attack_hitbox_duration: float = 0.12

@export var champion_idle_chance: float = 0.18
@export var champion_walk_phase_min: float = 0.9
@export var champion_walk_phase_max: float = 1.8
@export var champion_idle_phase_min: float = 0.15
@export var champion_idle_phase_max: float = 0.45

@export var champion_contact_damage_width: float = 54.0
@export var champion_contact_damage_height: float = 56.0
@export var champion_attack_hitbox_width: float = 72.0
@export var champion_attack_hitbox_height: float = 42.0
@export var champion_attack_hitbox_offset_x: float = 42.0
@export var champion_attack_hitbox_offset_y: float = 14.0

var attack_scan_timer: float = 0.0
var attack_hitbox_timer: float = 0.0
var attack_phase_timer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var queued_dash_direction: int = -1
var attack_started_hitbox: bool = false
var encounter_active: bool = true

func _ready() -> void:
	speed = champion_speed
	max_hp = champion_max_hp
	idle_chance = champion_idle_chance
	walk_phase_min = champion_walk_phase_min
	walk_phase_max = champion_walk_phase_max
	idle_phase_min = champion_idle_phase_min
	idle_phase_max = champion_idle_phase_max
	peck_trigger_distance = champion_attack_trigger_distance
	peck_vertical_tolerance = champion_vertical_tolerance
	peck_cooldown = 0.0

	super._ready()

	anim_state = ChampionAnim.WALK
	_set_peck_box_active(false)
	_resize_champion_hitboxes()
	attack_scan_timer = _get_scan_interval()

func die() -> void:
	if dead or dying:
		return

	champion_defeated.emit()
	super.die()

func set_encounter_active(enabled: bool) -> void:
	encounter_active = enabled

	if not encounter_active:
		velocity = Vector2.ZERO
		patrol_idle = true
		attack_started_hitbox = false
		dash_timer = 0.0
		_set_peck_box_active(false)
		_set_anim_state(ChampionAnim.IDLE)
		return

	attack_scan_timer = _get_scan_interval()
	_begin_walk_phase()

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

	if not encounter_active:
		velocity = Vector2.ZERO
		_set_peck_box_active(false)
		_update_animation(delta)
		_update_peck_effect(delta)
		return

	if dash_strike_attack_lock_timer > 0.0:
		dash_strike_attack_lock_timer = max(dash_strike_attack_lock_timer - delta, 0.0)

	if dash_strike_invulnerability_timer > 0.0:
		dash_strike_invulnerability_timer = max(dash_strike_invulnerability_timer - delta, 0.0)

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

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)

	if not is_on_floor():
		velocity.y += gravity * delta

	match anim_state:
		ChampionAnim.ATTACK:
			_process_attack_state(delta)
		ChampionAnim.DASH:
			_process_dash_state(delta)
		_:
			_process_patrol_state(delta)

	move_and_slide()
	_apply_contact_damage()
	_apply_body_collision_damage()
	_update_animation(delta)
	_update_peck_effect(delta)

func _process_patrol_state(delta: float) -> void:
	attack_scan_timer -= delta

	if attack_scan_timer <= 0.0:
		if _try_begin_attack_sequence():
			return
		attack_scan_timer = _get_scan_interval()

	if patrol_idle:
		velocity.x = 0.0
		behavior_timer -= delta
		if behavior_timer <= 0.0:
			_begin_walk_phase()
		return

	velocity.x = direction * speed
	behavior_timer -= delta

	var turned_this_frame: bool = false

	if global_position.x <= min_x:
		global_position.x = min_x + 2.0
		direction = 1
		velocity.x = direction * speed
		_update_facing()
		turned_this_frame = true
	elif global_position.x >= max_x:
		global_position.x = max_x - 2.0
		direction = -1
		velocity.x = direction * speed
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
				velocity.x = direction * speed
				_update_facing()
				break

	if behavior_timer <= 0.0:
		if rng.randf() <= idle_chance:
			_begin_idle_phase()
		else:
			_begin_walk_phase()

func _process_attack_state(delta: float) -> void:
	velocity.x = 0.0
	attack_phase_timer -= delta

	if not attack_started_hitbox:
		attack_hitbox_timer -= delta
		if attack_hitbox_timer <= 0.0:
			attack_started_hitbox = true
			attack_hitbox_timer = champion_attack_hitbox_duration
			_set_peck_box_active(true)
	else:
		attack_hitbox_timer -= delta
		if attack_hitbox_timer <= 0.0:
			_set_peck_box_active(false)

	if attack_phase_timer <= 0.0:
		_begin_dash_phase()

func _process_dash_state(delta: float) -> void:
	dash_timer -= delta
	velocity.x = float(direction) * champion_dash_speed

	if dash_timer <= 0.0:
		velocity.x = 0.0
		dash_cooldown_timer = champion_dash_cooldown
		attack_scan_timer = _get_scan_interval()
		_begin_walk_phase()

func _try_begin_attack_sequence() -> bool:
	if dash_cooldown_timer > 0.0:
		return false

	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null or not (player is Node2D):
		return false

	var player_node: Node2D = player as Node2D
	var offset: Vector2 = player_node.global_position - global_position

	if abs(offset.y) > champion_vertical_tolerance:
		return false

	if abs(offset.x) > champion_attack_trigger_distance:
		return false

	var desired_direction: int = direction
	if offset.x != 0.0:
		desired_direction = 1 if offset.x > 0.0 else -1

	direction = desired_direction
	queued_dash_direction = desired_direction
	_update_facing()
	_begin_attack_phase()
	return true

func _begin_walk_phase() -> void:
	patrol_idle = false
	behavior_timer = rng.randf_range(champion_walk_phase_min, champion_walk_phase_max)
	velocity.x = 0.0
	_set_peck_box_active(false)
	_set_anim_state(ChampionAnim.WALK)

func _begin_idle_phase() -> void:
	patrol_idle = true
	behavior_timer = rng.randf_range(champion_idle_phase_min, champion_idle_phase_max)
	velocity.x = 0.0
	_set_peck_box_active(false)
	_set_anim_state(ChampionAnim.IDLE)

func _begin_attack_phase() -> void:
	patrol_idle = false
	velocity.x = 0.0
	attack_started_hitbox = false
	attack_hitbox_timer = champion_attack_hitbox_delay
	attack_phase_timer = CHAMPION_ATTACK_DURATION
	_set_peck_box_active(false)
	_set_anim_state(ChampionAnim.ATTACK)

func _begin_dash_phase() -> void:
	direction = queued_dash_direction
	_update_facing()
	dash_timer = champion_dash_duration
	_set_peck_box_active(false)
	_set_anim_state(ChampionAnim.DASH)

func _get_scan_interval() -> float:
	if current_hp <= 5:
		return 0.08
	if current_hp <= 10:
		return 1.0
	if current_hp <= 20:
		return rng.randf_range(1.0, 2.0)
	return rng.randf_range(1.0, 3.0)

func _resize_champion_hitboxes() -> void:
	if damage_shape != null:
		var body_rect: RectangleShape2D = damage_shape.shape as RectangleShape2D
		if body_rect != null:
			body_rect.size = Vector2(champion_contact_damage_width, champion_contact_damage_height)
			damage_shape.position = Vector2(0.0, 16.0)

	if peck_shape != null:
		var attack_rect: RectangleShape2D = peck_shape.shape as RectangleShape2D
		if attack_rect != null:
			attack_rect.size = Vector2(champion_attack_hitbox_width, champion_attack_hitbox_height)
			_update_peck_box_position()

func _update_animation(_delta: float) -> void:
	return

func _apply_current_frame() -> void:
	if visual == null:
		return
	visual.frame = 0

func _get_animation_duration(state: int) -> float:
	match state:
		ChampionAnim.ATTACK:
			return CHAMPION_ATTACK_DURATION
		ChampionAnim.DEATH:
			return CHAMPION_DEATH_DURATION
		ChampionAnim.DASH:
			return champion_dash_duration
		_:
			return 0.0

func _update_peck_box_position() -> void:
	if peck_shape == null:
		return

	peck_shape.position = Vector2(champion_attack_hitbox_offset_x * direction, champion_attack_hitbox_offset_y)

func _set_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return

	anim_state = new_state
	anim_timer = 0.0
	anim_frame_index = 0
	_apply_current_frame()

func _should_start_peck() -> bool:
	return false
