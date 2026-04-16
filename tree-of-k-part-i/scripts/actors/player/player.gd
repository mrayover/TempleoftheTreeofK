extends CharacterBody2D

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var climb_speed: float = 160.0
@export var acceleration: float = 1400.0
@export var deceleration: float = 1800.0
@export var jump_cut_multiplier: float = 0.45
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.35
@export var turn_acceleration: float = 2200.0
@export var air_acceleration: float = 900.0
@export var air_deceleration: float = 500.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12
@export var low_jump_gravity_multiplier: float = 1.8
@export var apex_gravity_multiplier: float = 0.9
@export var max_fall_speed: float = 560.0
@export var corner_correction_enabled: bool = true
@export var corner_correction_pixels: int = 4
@export var controller_aim_deadzone: float = 0.25

@export var grapple_windup_time: float = 0.3
@export var grapple_range: float = 110.0
@export var grapple_pull_speed: float = 700.0
@export var grapple_stop_offset_x: float = 18.0
@export var grapple_stop_offset_y: float = 6.0
@export var grapple_arrival_distance: float = 6.0
@export var grapple_hop_x: float = 12.0
@export var grapple_hop_y: float = -210.0
@export var grapple_hop_time: float = 0.12
@export var grapple_cooldown: float = 0.15
@export var grapple_visual_start_offset_x: float = 8.0
@export var grapple_visual_start_offset_y: float = 18.0
@export var grapple_rope_texture: Texture2D
@export var grapple_head_texture: Texture2D

@export var grapple_attack_range: float = 28.0
@export var grapple_attack_height: float = 10.0
@export var grapple_attack_start_offset_x: float = 8.0
@export var grapple_attack_offset_y: float = 18.0
@export var grapple_attack_extend_speed: float = 520.0
@export var grapple_attack_retract_speed: float = 700.0
@export var grapple_attack_cooldown: float = 0.2
@export var grapple_attack_damage: int = 1
@export var grapple_attack_fallback_knockback_x: float = 0.0
@export var grapple_attack_fallback_knockback_y: float = 0.0
@export var grapple_attack_rope_texture: Texture2D
@export var grapple_attack_head_texture: Texture2D

@export var max_hp: int = 5
@export var max_bonus_hp: int = 3
@export var invulnerability_time: float = 1.0
@export var hitstun_time: float = 0.5
@export var knockback_x: float = 400.0
@export var knockback_y: float = -320.0

@export var burst_shots: int = 5
@export var shot_fire_cooldown: float = 0.0
@export var shot_recharge_delay: float = 0.0
@export var shot_recharge_interval: float = 0.3
@export var charge_first_pip_time: float = 0.4
@export var charge_two_hit_time: float = 2.0
@export var charge_three_hit_time: float = 3.5
@export var special_hit_power: int = 5
@export var shot_spawn_offset_x: float = 12.0
@export var shot_spawn_offset_y: float = 22.0
@export var shot_spawn_forward_distance: float = 10.0

@export var can_dash: bool = true
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.25
@export var dash_strike_damage: int = 2
@export var dash_strike_knockback_x: float = 180.0
@export var dash_strike_knockback_y: float = -140.0

@export var can_shield: bool = false
@export var shield_duration: float = 2.0
@export var shield_cooldown: float = 4.0
@export var shield_break_invulnerability_time: float = 0.75

@export var can_flight: bool = false
@export var flight_duration: float = 2.5
@export var flight_horizontal_speed_scale: float = 0.75
@export var flight_start_velocity: float = -260.0
@export var flight_flap_velocity: float = -220.0
@export var flight_rise_speed: float = -95.0
@export var flight_fall_speed: float = 55.0
@export var flight_vertical_acceleration: float = 700.0
@export var flight_flap_cooldown: float = 0.18

@export var crouch_collision_height: float = 14.0
@export var crouch_sprite_offset_y: float = 7.0
@export var crouch_speed_scale: float = 0.5

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/projectiles/Projectile.tscn")
const PLAYER_CHARGE_HELPER = preload("res://scripts/actors/player/player_charge_helper.gd")
const PLAYER_VISUAL_HELPER = preload("res://scripts/actors/player/player_visual_helper.gd")
const PLAYER_ARCHETYPE_VISUAL_HELPER = preload("res://scripts/actors/player/player_archetype_visual_helper.gd")
const TORCH_TEXTURE: Texture2D = preload("res://Assets/Archetypes/TorchFinalSprite.png")
const SNAKE_TEXTURE: Texture2D = preload("res://Assets/Archetypes/SnakeFinalsprite.png")
const CROW_TEXTURE: Texture2D = preload("res://Assets/Archetypes/CrowFinalSprite.png")
const HEART_TEXTURE: Texture2D = preload("res://Assets/Archetypes/HeartFinalSprite.png")

var ladder_count: int = 0
var is_climbing: bool = false

var current_hp: int = 5
var bonus_hp: int = 0
var current_special: int = 0
var max_special: int = 5
var current_fuel: int = 0
var max_fuel: int = 5
var fuel_per_grapple_hit: int = 1
var fuel_cost_per_torch_shot: int = 1
var champion_keys : int = 0
var facing_dir: int = 1
var invulnerability_timer: float = 0.0
var hitstun_timer: float = 0.0

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: int = 0
var dash_just_started: bool = false

var shield_active: bool = false
var shield_timer: float = 0.0
var shield_cooldown_timer: float = 0.0

var is_crouching: bool = false
var grapple_attack_requested: bool = false

var grapple_attack_button_pressed: bool = false
var grapple_attack_button_held: bool = false
var grapple_attack_button_released: bool = false

var grapple_attack_hold_time: float = 0.0

@export var grapple_attack_hold_threshold: float = 0.2
var is_torch_aiming: bool = false

var is_flying: bool = false
var flight_time_left: float = 0.0
var flight_flap_cooldown_timer: float = 0.0

var spawn_position: Vector2
var input_enabled: bool = true

var current_shots: int = 0
var shot_fire_cooldown_timer: float = 0.0
var shot_recharge_delay_timer: float = 0.0
var shot_recharge_timer: float = 0.0
var is_charging: bool = false
var stored_charge_power: int = 0
var charge_timer: float = 0.0
var shoot_anim_timer: float = 0.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var grapple_cooldown_timer: float = 0.0
var grapple_windup_timer: float = 0.0
var grapple_hop_timer: float = 0.0
var is_grapple_winding_up: bool = false
var is_grapple_pulling: bool = false
var is_grapple_hopping: bool = false
var grapple_face_dir: int = 1
var grapple_target: Node2D = null

# Grapple attack state
var grapple_attack_length: float = 0.0
var grapple_attack_cooldown_timer: float = 0.0
var grapple_attack_rope_visual: Sprite2D = null
var grapple_attack_head_visual: Sprite2D = null
var grapple_rope_visual: Sprite2D = null
var grapple_head_visual: Sprite2D = null

@onready var body_visual: CanvasItem = get_node_or_null("Body") as CanvasItem
@onready var main_collision: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield_area: Area2D = $ShieldArea
@onready var shield_collision: CollisionShape2D = $ShieldArea/CollisionShape2D
@onready var shield_sprite: Sprite2D = $ShieldArea/Sprite2D
@onready var charge_pip_1: ColorRect = $ChargePips/Pip1
@onready var charge_pip_2: ColorRect = $ChargePips/Pip2
@onready var charge_pip_3: ColorRect = $ChargePips/Pip3

var standing_collision_size: Vector2 = Vector2.ZERO
var standing_collision_position: Vector2 = Vector2.ZERO
var crouching_collision_size: Vector2 = Vector2.ZERO
var crouching_collision_position: Vector2 = Vector2.ZERO
var standing_sprite_position: Vector2 = Vector2.ZERO
var crouching_sprite_position: Vector2 = Vector2.ZERO

enum GrappleAttackState {
	READY,
	ATTACK_EXTEND,
	ATTACK_HIT_CONFIRM,
	ATTACK_DROP,
	ATTACK_RESET_RECALL,
	ATTACK_COMBO_2,
	ATTACK_COMBO_3,
	ATTACK_CHARGE,
	ATTACK_HEAVY_RELEASE,
	ATTACK_RECOVERY
}

var grapple_attack_state: int = GrappleAttackState.READY
var grapple_attack_drop_timer: float = 0.0
var grapple_attack_state_timer: float = 0.0
var grapple_attack_combo_window_timer: float = 0.0
var grapple_attack_combo_step_ready: int = 0
var grapple_attack_current_strike: int = 0
var grapple_attack_has_hit_this_strike: bool = false
var grapple_attack_hit_targets: Dictionary = {}

@export var grapple_attack_drop_window: float = 0.18
@export var grapple_attack_hit_confirm_duration: float = 0.08
@export var grapple_attack_combo_window_1_duration: float = 0.18
@export var grapple_attack_combo_window_2_duration: float = 0.18
@export var grapple_attack_first_active_duration: float = 0.12
@export var grapple_attack_combo_2_active_duration: float = 0.12
@export var grapple_attack_combo_3_active_duration: float = 0.12
@export var grapple_attack_heavy_release_active_duration: float = 0.12
@export var grapple_attack_combo_2_arc_height: float = 34.0
@export var grapple_attack_combo_2_arc_width: float = 18.0

@export var grapple_attack_combo_3_forward_distance: float = 30.0
@export var grapple_attack_combo_3_vertical_start: float = 20.0
@export var grapple_attack_combo_3_vertical_end: float = -2.0

func _get_grapple_attack_state_name(state: int) -> String:
	match state:
		GrappleAttackState.READY:
			return "READY"
		GrappleAttackState.ATTACK_EXTEND:
			return "ATTACK_EXTEND"
		GrappleAttackState.ATTACK_HIT_CONFIRM:
			return "ATTACK_HIT_CONFIRM"
		GrappleAttackState.ATTACK_DROP:
			return "ATTACK_DROP"
		GrappleAttackState.ATTACK_RESET_RECALL:
			return "ATTACK_RESET_RECALL"
		GrappleAttackState.ATTACK_COMBO_2:
			return "ATTACK_COMBO_2"
		GrappleAttackState.ATTACK_COMBO_3:
			return "ATTACK_COMBO_3"
		GrappleAttackState.ATTACK_CHARGE:
			return "ATTACK_CHARGE"
		GrappleAttackState.ATTACK_HEAVY_RELEASE:
			return "ATTACK_HEAVY_RELEASE"
		GrappleAttackState.ATTACK_RECOVERY:
			return "ATTACK_RECOVERY"
		_:
			return "UNKNOWN"


func _is_grapple_attack_active() -> bool:
	return grapple_attack_state != GrappleAttackState.READY


func _set_grapple_attack_state(new_state: int) -> void:
	if grapple_attack_state == new_state:
		return

	grapple_attack_state = new_state
	grapple_attack_state_timer = 0.0

	match new_state:
		GrappleAttackState.ATTACK_EXTEND:
			grapple_attack_state_timer = grapple_attack_first_active_duration
		GrappleAttackState.ATTACK_HIT_CONFIRM:
			grapple_attack_state_timer = grapple_attack_hit_confirm_duration
		GrappleAttackState.ATTACK_DROP:
			grapple_attack_drop_timer = grapple_attack_drop_window
		GrappleAttackState.ATTACK_COMBO_2:
			grapple_attack_state_timer = grapple_attack_combo_2_active_duration
		GrappleAttackState.ATTACK_COMBO_3:
			grapple_attack_state_timer = grapple_attack_combo_3_active_duration
		GrappleAttackState.ATTACK_HEAVY_RELEASE:
			grapple_attack_state_timer = grapple_attack_heavy_release_active_duration
		_:
			pass

	print("GrappleAttackState -> ", _get_grapple_attack_state_name(new_state))

func _ready() -> void:
	current_hp = max_hp
	bonus_hp = 0
	current_special = 0
	current_fuel = max_fuel
	current_shots = current_fuel
	flight_time_left = flight_duration
	spawn_position = global_position
	add_to_group("player")

	RunState.apply_player_powers_to(self)

	hp_changed.emit(current_hp + bonus_hp)
	special_changed.emit(current_special)
	fuel_changed.emit(current_fuel)

	if body_visual != null:
		body_visual.visible = false

	if anim != null:
		anim.visible = true
		_apply_archetype_visual()

	_initialize_crouch_state()
	_initialize_grapple_attack_visual()
	_initialize_grapple_traverse_visual()

	if grapple_attack_rope_visual != null:
		grapple_attack_rope_visual.texture = grapple_attack_rope_texture

	if grapple_attack_head_visual != null:
		grapple_attack_head_visual.texture = grapple_attack_head_texture

	if grapple_rope_visual != null:
		grapple_rope_visual.texture = grapple_rope_texture

	if grapple_head_visual != null:
		grapple_head_visual.texture = grapple_head_texture

	_sync_shield_visuals()
	_update_charge_pips()

func _apply_archetype_visual() -> void:
	if anim == null:
		return

	var texture: Texture2D = TORCH_TEXTURE

	match RunState.current_archetype:
		RunState.ARCHETYPE_TORCH:
			texture = TORCH_TEXTURE
		RunState.ARCHETYPE_SNAKE:
			texture = SNAKE_TEXTURE
		RunState.ARCHETYPE_CROW:
			texture = CROW_TEXTURE
		RunState.ARCHETYPE_HEART:
			texture = HEART_TEXTURE

	PLAYER_ARCHETYPE_VISUAL_HELPER.apply_archetype_frames(anim, texture)

func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled

	if input_enabled:
		return

	_cancel_charge_state()
	dash_timer = 0.0
	dash_direction = 0
	dash_just_started = false
	shield_active = false
	shield_timer = 0.0
	shield_cooldown_timer = 0.0
	is_crouching = false
	_apply_crouch_state(false)
	grapple_attack_requested = false
	grapple_attack_length = 0.0
	grapple_attack_cooldown_timer = 0.0
	_set_grapple_attack_state(GrappleAttackState.READY)
	_update_grapple_attack_visual()
	is_flying = false
	flight_flap_cooldown_timer = 0.0
	is_climbing = false
	is_grapple_winding_up = false
	is_grapple_pulling = false
	is_grapple_hopping = false
	grapple_windup_timer = 0.0
	grapple_hop_timer = 0.0
	grapple_target = null
	_update_grapple_traverse_visual()
	velocity = Vector2.ZERO
	_sync_shield_visuals()

func _physics_process(delta: float) -> void:
	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta

	if hitstun_timer > 0.0:
		hitstun_timer -= delta

	if shot_fire_cooldown_timer > 0.0:
		shot_fire_cooldown_timer -= delta
		if shot_fire_cooldown_timer < 0.0:
			shot_fire_cooldown_timer = 0.0

	if shot_recharge_delay_timer > 0.0:
		shot_recharge_delay_timer = 0.0

	if shot_recharge_timer > 0.0:
		shot_recharge_timer = 0.0

	if grapple_cooldown_timer > 0.0:
		grapple_cooldown_timer -= delta
		if grapple_cooldown_timer < 0.0:
			grapple_cooldown_timer = 0.0

	if grapple_attack_cooldown_timer > 0.0:
		grapple_attack_cooldown_timer -= delta
		if grapple_attack_cooldown_timer < 0.0:
			grapple_attack_cooldown_timer = 0.0

	if _is_grapple_attack_active():
		_process_grapple_attack(delta)

	if is_grapple_winding_up:
		_update_grapple_traverse_visual()
		grapple_windup_timer -= delta
		if grapple_windup_timer <= 0.0:
			is_grapple_winding_up = false
			grapple_windup_timer = 0.0
			_try_begin_grapple_pull()

	if dash_timer > 0.0:
		dash_timer -= delta
		if dash_just_started:
			dash_just_started = false
		if dash_timer <= 0.0:
			dash_timer = 0.0
			dash_direction = 0
			dash_just_started = false

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer < 0.0:
			dash_cooldown_timer = 0.0

	if shield_cooldown_timer > 0.0:
		shield_cooldown_timer -= delta
		if shield_cooldown_timer < 0.0:
			shield_cooldown_timer = 0.0

	if shield_active:
		shield_timer -= delta
		if shield_timer <= 0.0:
			_break_shield(false)

	if flight_flap_cooldown_timer > 0.0:
		flight_flap_cooldown_timer -= delta
		if flight_flap_cooldown_timer < 0.0:
			flight_flap_cooldown_timer = 0.0

	if is_flying:
		flight_time_left -= delta
		if flight_time_left <= 0.0:
			flight_time_left = 0.0
			is_flying = false

	if is_on_floor():
		coyote_timer = coyote_time
		is_flying = false
		flight_time_left = flight_duration
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if is_charging:
		charge_timer = 0.0

	if shoot_anim_timer > 0.0:
		shoot_anim_timer -= delta
		if shoot_anim_timer < 0.0:
			shoot_anim_timer = 0.0

	if anim != null:
		if invulnerability_timer > 0.0:
			anim.visible = int(invulnerability_timer * 12.0) % 2 == 0
		else:
			anim.visible = true

	if not input_enabled:
		velocity.x = 0.0

		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0.0

		move_and_slide()
		_update_animation()
		_update_charge_pips()
		return

	if is_grapple_pulling:
		_process_grapple_pull(delta)
		_update_facing()
		_update_animation()
		_update_charge_pips()
		return

	if is_grapple_hopping:
		_update_grapple_traverse_visual()
		grapple_hop_timer -= delta
		if grapple_hop_timer <= 0.0:
			is_grapple_hopping = false
			grapple_hop_timer = 0.0
			_update_grapple_traverse_visual()
		else:
			var hop_progress := 1.0 - (grapple_hop_timer / grapple_hop_time)

			if hop_progress < 0.55:
				velocity.x = 0.0
			else:
				velocity.x = move_toward(velocity.x, grapple_face_dir * grapple_hop_x, air_acceleration * delta)

			move_and_slide()
			_update_facing()
			_update_animation()
			_update_charge_pips()
			return

	var dir: float = 0.0
	if hitstun_timer <= 0.0:
		_handle_dash_input()
		_handle_shield_input()
		_handle_crouch_input()
		_handle_torch_aim_input()
		_handle_grapple_attack_input(delta)
		_handle_torch_fire_input()
		_handle_flight_input()
		_handle_grapple_input()

		if Input.is_action_pressed("move_left"):
			dir -= 1.0
		if Input.is_action_pressed("move_right"):
			dir += 1.0

	if hitstun_timer <= 0.0 and ladder_count > 0 and (Input.is_action_pressed("climb_up") or Input.is_action_pressed("climb_down")):
		if not is_climbing:
			_cancel_charge_state()
			if Input.is_action_pressed("climb_down") and is_on_floor():
				global_position.y += 6.0
		is_climbing = true

	if is_climbing:
		velocity.x = dir * speed * 0.4

		var climb_dir: float = 0.0
		if Input.is_action_pressed("climb_up"):
			climb_dir -= 1.0
		if Input.is_action_pressed("climb_down"):
			climb_dir += 1.0

		velocity.y = climb_dir * climb_speed

		if hitstun_timer <= 0.0 and Input.is_action_just_pressed("jump"):
			is_climbing = false
			velocity.y = jump_velocity

		if ladder_count == 0:
			is_climbing = false
	else:
		if dash_timer > 0.0:
			_cancel_dash_if_input()

		if dash_timer > 0.0:
			velocity.y = 0.0
		elif is_flying:
			var flight_target_y: float = flight_fall_speed
			if Input.is_action_pressed("flight"):
				flight_target_y = flight_rise_speed

			velocity.y = move_toward(velocity.y, flight_target_y, flight_vertical_acceleration * delta)
		elif not is_on_floor():
			var gravity_scale: float = 1.0

			if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
				gravity_scale = low_jump_gravity_multiplier
			elif abs(velocity.y) < 40.0:
				gravity_scale = apex_gravity_multiplier
			elif velocity.y > 0.0:
				gravity_scale = fall_gravity_multiplier

			velocity.y += gravity * gravity_scale * delta

			if velocity.y > max_fall_speed:
				velocity.y = max_fall_speed

		if hitstun_timer <= 0.0:
			if dash_timer > 0.0:
				velocity.x = dash_direction * dash_speed
				velocity.y = 0.0
			else:
				var target_speed: float = dir * speed

				if is_flying:
					target_speed *= flight_horizontal_speed_scale

				if is_crouching and is_on_floor():
					target_speed *= crouch_speed_scale

				if is_on_floor():
					var applied_acceleration: float = acceleration
					if dir != 0.0 and signf(dir) != signf(velocity.x) and velocity.x != 0.0:
						applied_acceleration = turn_acceleration

					if dir != 0.0:
						velocity.x = move_toward(velocity.x, target_speed, applied_acceleration * delta)
					else:
						velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
				else:
					var applied_air_acceleration: float = air_acceleration
					var applied_air_deceleration: float = air_deceleration

					if is_flying:
						applied_air_acceleration *= 0.85
						applied_air_deceleration *= 0.85

					if dir != 0.0:
						velocity.x = move_toward(velocity.x, target_speed, applied_air_acceleration * delta)
					else:
						velocity.x = move_toward(velocity.x, 0.0, applied_air_deceleration * delta)

				if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
					if is_crouching:
						is_crouching = false
						_apply_crouch_state(false)

					velocity.y = jump_velocity
					jump_buffer_timer = 0.0
					coyote_timer = 0.0

				if Input.is_action_just_released("jump") and velocity.y < 0.0 and not is_flying:
					velocity.y *= jump_cut_multiplier

				if Input.is_action_just_pressed("special"):
					use_special()

				if Input.is_action_just_pressed("shoot_charge"):
					pass

				if Input.is_action_just_released("shoot_charge"):
					pass
		else:
			# Preserve knockback during hitstun.
			# Do not overwrite velocity.x here.
			pass

	var was_falling: bool = velocity.y > 0.0

	move_and_slide()
	_apply_corner_correction()
	_apply_enemy_contact_damage(was_falling)
	_update_facing()
	_update_animation()
	_update_charge_pips()

func _handle_grapple_input() -> void:
	if is_grapple_winding_up or is_grapple_pulling:
		return

	if grapple_cooldown_timer > 0.0:
		return

	if is_climbing:
		return

	if dash_timer > 0.0:
		return

	if Input.is_action_just_pressed("grapple"):
		_cancel_charge_state()
		is_crouching = false
		_apply_crouch_state(false)
		if _is_grapple_attack_active():
			_end_grapple_attack()
		_stop_flight()

		var grapple_facing := facing_dir
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			grapple_facing = -1
		elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			grapple_facing = 1

		var preview_target := _find_grapple_target(grapple_facing)
		if preview_target == null:
			grapple_cooldown_timer = grapple_cooldown
			grapple_target = null
			_update_grapple_traverse_visual()
			return

		grapple_target = preview_target
		grapple_face_dir = grapple_facing
		facing_dir = grapple_facing

		if grapple_windup_time <= 0.0:
			_try_begin_grapple_pull(grapple_facing)
			return

		is_grapple_winding_up = true
		grapple_windup_timer = grapple_windup_time
		_update_grapple_traverse_visual()

func _try_begin_grapple_pull(grapple_facing: int = facing_dir) -> void:
	var best_target: Node2D = grapple_target

	if best_target == null or not is_instance_valid(best_target):
		best_target = _find_grapple_target(grapple_facing)

	if best_target == null:
		grapple_cooldown_timer = grapple_cooldown
		grapple_target = null
		_update_grapple_traverse_visual()
		return

	grapple_target = best_target
	grapple_face_dir = grapple_facing
	is_grapple_pulling = true
	velocity = Vector2.ZERO
	_update_grapple_traverse_visual()

func _process_grapple_pull(delta: float) -> void:
	if grapple_target == null or not is_instance_valid(grapple_target):
		is_grapple_pulling = false
		grapple_target = null
		_update_grapple_traverse_visual()
		return

	var pull_target := grapple_target.global_position + Vector2(-grapple_face_dir * grapple_stop_offset_x, grapple_stop_offset_y)

	global_position = global_position.move_toward(pull_target, grapple_pull_speed * delta)
	_update_grapple_traverse_visual()

	if global_position.distance_to(pull_target) <= grapple_arrival_distance:
		global_position = pull_target
		is_grapple_pulling = false
		is_grapple_hopping = true
		grapple_hop_timer = grapple_hop_time
		grapple_target = null
		grapple_cooldown_timer = grapple_cooldown
		_update_grapple_traverse_visual()
		velocity = Vector2(0.0, grapple_hop_y)
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		return

	move_and_slide()

func _find_grapple_target(grapple_facing: int) -> Node2D:
	var best_target: Node2D = null
	var best_distance: float = INF

	for node in get_tree().get_nodes_in_group("grapple_target"):
		var target := node as Node2D
		if target == null:
			continue

		var to_target: Vector2 = target.global_position - global_position

		if to_target.length() > grapple_range:
			continue

		if to_target.x * grapple_facing < -6.0:
			continue

		if to_target.y > 24.0:
			continue

		var dist := to_target.length()
		if dist < best_distance:
			best_distance = dist
			best_target = target

	return best_target

func _initialize_grapple_traverse_visual() -> void:
	if grapple_rope_visual != null or grapple_head_visual != null:
		return

	grapple_rope_visual = PLAYER_VISUAL_HELPER.create_rope_visual(grapple_rope_texture, 9)
	add_child(grapple_rope_visual)

	grapple_head_visual = PLAYER_VISUAL_HELPER.create_head_visual(grapple_head_texture, 10)
	add_child(grapple_head_visual)

func _update_grapple_traverse_visual() -> void:
	if grapple_rope_visual == null or grapple_head_visual == null:
		return

	if grapple_target == null or not is_instance_valid(grapple_target):
		grapple_rope_visual.visible = false
		grapple_head_visual.visible = false
		return

	if not is_grapple_winding_up and not is_grapple_pulling:
		grapple_rope_visual.visible = false
		grapple_head_visual.visible = false
		return

	var local_start := Vector2(
		facing_dir * grapple_visual_start_offset_x,
		grapple_visual_start_offset_y
	)
	var local_end := to_local(grapple_target.global_position)
	var direction := local_end - local_start
	var distance := direction.length()

	if distance <= 0.001:
		grapple_rope_visual.visible = false
		grapple_head_visual.visible = false
		return

	var angle := direction.angle()
	PLAYER_VISUAL_HELPER.update_rope_and_head_visual(
		grapple_rope_visual,
		grapple_head_visual,
		grapple_rope_texture,
		grapple_head_texture,
		local_start,
		local_end,
		distance,
		angle
	)

func _apply_corner_correction() -> void:
	if not corner_correction_enabled:
		return

	if velocity.y >= 0.0:
		return

	if not is_on_ceiling():
		return

	for offset in range(1, corner_correction_pixels + 1):
		if not test_move(global_transform, Vector2(offset, 0.0)):
			global_position.x += offset
			return

		if not test_move(global_transform, Vector2(-offset, 0.0)):
			global_position.x -= offset
			return

func _on_ladder_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		ladder_count += 1

func _on_ladder_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		ladder_count -= 1
		if ladder_count < 0:
			ladder_count = 0
func _get_max_charge_power() -> int:
	return PLAYER_CHARGE_HELPER.get_max_charge_power(RunState.current_archetype, RunState.ARCHETYPE_TORCH)

func _get_charge_power_from_timer() -> int:
	return PLAYER_CHARGE_HELPER.get_charge_power_from_timer(
		charge_timer,
		current_shots,
		_get_max_charge_power(),
		charge_first_pip_time,
		charge_two_hit_time,
		charge_three_hit_time
	)

func _start_shot_recharge() -> void:
	if current_shots >= burst_shots:
		shot_recharge_delay_timer = 0.0
		shot_recharge_timer = 0.0
		return

	shot_recharge_delay_timer = shot_recharge_delay
	shot_recharge_timer = 0.0

func _clear_charge_state() -> void:
	is_charging = false
	stored_charge_power = 0
	charge_timer = 0.0

func _cancel_charge_state() -> void:
	var had_charge: bool = is_charging or stored_charge_power > 0
	_clear_charge_state()

	if had_charge and current_shots < burst_shots:
		_start_shot_recharge()

func _is_torch_aim_input_active() -> bool:
	if InputMap.has_action("torch_aim") and Input.is_action_pressed("torch_aim"):
		return true

	return false

func _enter_torch_aim() -> void:
	is_torch_aiming = true

func _exit_torch_aim() -> void:
	is_torch_aiming = false

func _handle_torch_aim_input() -> void:
	if not input_enabled:
		_exit_torch_aim()
		return

	if _is_torch_aim_input_active():
		_enter_torch_aim()
	else:
		_exit_torch_aim()

func _get_facing_locked_shot_direction() -> Vector2:
	var horizontal_default := Vector2(float(facing_dir), 0.0)

	var stick := Vector2(
		Input.get_joy_axis(0, 2),
		Input.get_joy_axis(0, 3)
	)

	var stick_deadzone: float = maxf(controller_aim_deadzone, 0.35)
	var vertical_override_threshold: float = 0.55
	var keyboard_vertical_override_threshold: float = 0.5
	var mouse_vertical_override_threshold: float = 0.35

	# Controller aim: horizontal is the default unless vertical is pushed clearly.
	if stick.length() > stick_deadzone:
		if absf(stick.y) < vertical_override_threshold:
			return horizontal_default

		var stick_dir := stick.normalized()
		if facing_dir > 0 and stick_dir.x < 0.0:
			stick_dir.x = 0.0
		elif facing_dir < 0 and stick_dir.x > 0.0:
			stick_dir.x = 0.0

		if stick_dir.length() <= 0.01:
			return Vector2(0.0, signf(stick.y))

		var stick_angle := stick_dir.angle()
		var forward_center := 0.0 if facing_dir > 0 else PI
		var relative := wrapf(stick_angle - forward_center, -PI, PI)
		relative = clamp(relative, -PI * 0.5, PI * 0.5)

		var step := PI / 8.0
		relative = round(relative / step) * step

		var final_angle := forward_center + relative
		var shoot_dir := Vector2.RIGHT.rotated(final_angle).normalized()

		if absf(shoot_dir.y) < 0.2:
			return horizontal_default

		return shoot_dir

	# Keyboard fallback: only override horizontal if up/down is pressed clearly.
	var kb_aim := Vector2.ZERO
	kb_aim.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	kb_aim.y = Input.get_action_strength("climb_down") - Input.get_action_strength("climb_up")

	if absf(kb_aim.y) >= keyboard_vertical_override_threshold:
		var kb_x: float = 0.0
		if facing_dir > 0 and kb_aim.x > 0.0:
			kb_x = 1.0
		elif facing_dir < 0 and kb_aim.x < 0.0:
			kb_x = -1.0

		var kb_dir := Vector2(kb_x, signf(kb_aim.y)).normalized()
		return kb_dir

	# Mouse fallback: horizontal unless the mouse is clearly above/below enough.
	var mouse_dir := get_global_mouse_position() - global_position
	if mouse_dir.length() > 4.0:
		var mouse_norm := mouse_dir.normalized()

		if absf(mouse_norm.y) < mouse_vertical_override_threshold:
			return horizontal_default

		if facing_dir > 0 and mouse_norm.x < 0.0:
			mouse_norm.x = 0.0
		elif facing_dir < 0 and mouse_norm.x > 0.0:
			mouse_norm.x = 0.0

		if mouse_norm.length() <= 0.01:
			return Vector2(0.0, signf(mouse_dir.y))

		var mouse_angle := mouse_norm.angle()
		var forward_center := 0.0 if facing_dir > 0 else PI
		var relative := wrapf(mouse_angle - forward_center, -PI, PI)
		relative = clamp(relative, -PI * 0.5, PI * 0.5)

		var step := PI / 8.0
		relative = round(relative / step) * step

		var final_angle := forward_center + relative
		var shoot_dir := Vector2.RIGHT.rotated(final_angle).normalized()

		if absf(shoot_dir.y) < 0.2:
			return horizontal_default

		return shoot_dir

	return horizontal_default

func fire_torch_shot() -> bool:
	if not _is_torch_aim_input_active() and not is_torch_aiming:
		return false

	if current_fuel < fuel_cost_per_torch_shot:
		return false

	if not fire_projectile(1, 0):
		return false

	return spend_fuel(fuel_cost_per_torch_shot)

func fire_projectile(hit_power: int = 1, shot_cost: int = 1) -> bool:
	if shot_fire_cooldown_timer > 0.0:
		return false

	if current_shots < shot_cost:
		return false

	var projectile: Node2D = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(projectile)

	var shoot_dir: Vector2 = _get_facing_locked_shot_direction()

	var spawn_origin := global_position + Vector2(
		facing_dir * shot_spawn_offset_x,
		shot_spawn_offset_y
	)

	projectile.direction = shoot_dir
	projectile.global_position = spawn_origin + (shoot_dir * shot_spawn_forward_distance)
	projectile.rotation = shoot_dir.angle()

	if projectile.has_method("set_hit_power"):
		projectile.set_hit_power(hit_power)

	if projectile.has_method("set_shooter"):
		projectile.set_shooter(self)

	shoot_anim_timer = 0.12
	current_shots -= shot_cost
	shot_fire_cooldown_timer = shot_fire_cooldown

	return true

func _initialize_grapple_attack_visual() -> void:
	if grapple_attack_rope_visual != null or grapple_attack_head_visual != null:
		return

	grapple_attack_rope_visual = PLAYER_VISUAL_HELPER.create_rope_visual(grapple_attack_rope_texture, 10)
	add_child(grapple_attack_rope_visual)

	grapple_attack_head_visual = PLAYER_VISUAL_HELPER.create_head_visual(grapple_attack_head_texture, 11)
	add_child(grapple_attack_head_visual)

func _update_grapple_attack_visual() -> void:
	if grapple_attack_rope_visual == null or grapple_attack_head_visual == null:
		return

	if not _is_grapple_attack_active() or grapple_attack_length <= 0.0:
		grapple_attack_rope_visual.visible = false
		grapple_attack_head_visual.visible = false
		return

	var local_start := Vector2(
		facing_dir * grapple_attack_start_offset_x,
		grapple_attack_offset_y
	)
	var base_end := Vector2(
		facing_dir * (grapple_attack_start_offset_x + grapple_attack_length),
		grapple_attack_offset_y
	)

	var local_end := base_end

	match grapple_attack_state:

		GrappleAttackState.ATTACK_EXTEND:
			local_end = base_end

		GrappleAttackState.ATTACK_HIT_CONFIRM:
			local_end = base_end

		GrappleAttackState.ATTACK_DROP:
			local_end = base_end + Vector2(0, 12)

		GrappleAttackState.ATTACK_RESET_RECALL:
			local_end = local_start.lerp(base_end, 0.35)

		GrappleAttackState.ATTACK_COMBO_2:
			var combo_2_duration = max(grapple_attack_combo_2_active_duration, 0.001)
			var combo_2_progress = 1.0 - (grapple_attack_state_timer / combo_2_duration)
			var combo_2_arc_x = facing_dir * lerp(-grapple_attack_combo_2_arc_width, grapple_attack_combo_2_arc_width, combo_2_progress)
			var combo_2_arc_y = -sin(combo_2_progress * PI) * grapple_attack_combo_2_arc_height
			local_end = base_end + Vector2(combo_2_arc_x, combo_2_arc_y)

		GrappleAttackState.ATTACK_COMBO_3:
			var combo_3_duration = max(grapple_attack_combo_3_active_duration, 0.001)
			var combo_3_progress = 1.0 - (grapple_attack_state_timer / combo_3_duration)
			var combo_3_finish_x = facing_dir * lerp(-grapple_attack_combo_3_forward_distance * 0.25, grapple_attack_combo_3_forward_distance, combo_3_progress)
			var combo_3_finish_y = lerp(grapple_attack_combo_3_vertical_start, grapple_attack_combo_3_vertical_end, combo_3_progress)
			local_end = base_end + Vector2(combo_3_finish_x, combo_3_finish_y)

		GrappleAttackState.ATTACK_CHARGE:
			local_end = local_start + Vector2(facing_dir * 6.0, 0)

		GrappleAttackState.ATTACK_HEAVY_RELEASE:
			local_end = base_end + Vector2(facing_dir * 18.0, 0)

		_:
			local_end = base_end

	var direction := local_end - local_start
	var distance := direction.length()

	if distance <= 0.001:
		grapple_attack_rope_visual.visible = false
		grapple_attack_head_visual.visible = false
		return

	var angle := direction.angle()
	PLAYER_VISUAL_HELPER.update_rope_and_head_visual(
		grapple_attack_rope_visual,
		grapple_attack_head_visual,
		grapple_attack_rope_texture,
		grapple_attack_head_texture,
		local_start,
		local_end,
		distance,
		angle
	)

func _start_grapple_attack() -> void:
	grapple_attack_length = 0.0
	_begin_grapple_attack_strike(1, GrappleAttackState.ATTACK_EXTEND)
	_cancel_charge_state()
	_update_grapple_attack_visual()

func _begin_grapple_attack_retract() -> void:
	if not _is_grapple_attack_active():
		return

func _begin_grapple_attack_strike(strike_index: int, state: int) -> void:
	grapple_attack_current_strike = strike_index
	grapple_attack_has_hit_this_strike = false
	grapple_attack_hit_targets.clear()
	grapple_attack_combo_step_ready = 0
	grapple_attack_combo_window_timer = 0.0
	_set_grapple_attack_state(state)

func _open_grapple_attack_combo_window(combo_step: int) -> void:
	grapple_attack_combo_step_ready = combo_step

	match combo_step:
		1:
			grapple_attack_combo_window_timer = grapple_attack_combo_window_1_duration
		2:
			grapple_attack_combo_window_timer = grapple_attack_combo_window_2_duration
		_:
			grapple_attack_combo_window_timer = 0.0
			grapple_attack_combo_step_ready = 0

func _reset_grapple_attack_feedback() -> void:
	if anim != null:
		anim.modulate = Color(1, 1, 1, 1)

func _apply_grapple_attack_feedback(_delta: float) -> void:
	if anim == null:
		return

	var color := Color(1, 1, 1, 1)

	if grapple_attack_combo_window_timer > 0.0:
		if grapple_attack_combo_step_ready == 1:
			color = Color(1.0, 1.0, 0.2)
		elif grapple_attack_combo_step_ready == 2:
			color = Color(1.0, 0.6, 0.2)
	elif grapple_attack_state == GrappleAttackState.ATTACK_CHARGE:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
		color = Color(0.2, 0.6 + pulse * 0.4, 1.0)
	elif grapple_attack_state == GrappleAttackState.ATTACK_HEAVY_RELEASE:
		color = Color(1.0, 0.2, 0.2)

	anim.modulate = color

func _clear_grapple_attack_combo_window() -> void:
	grapple_attack_combo_step_ready = 0
	grapple_attack_combo_window_timer = 0.0

func _resolve_grapple_attack_hit_confirm() -> void:
	match grapple_attack_current_strike:
		1:
			_open_grapple_attack_combo_window(1)
			_set_grapple_attack_state(GrappleAttackState.ATTACK_DROP)
		2:
			_open_grapple_attack_combo_window(2)
			_set_grapple_attack_state(GrappleAttackState.ATTACK_DROP)
		_:
			_clear_grapple_attack_combo_window()
			_set_grapple_attack_state(GrappleAttackState.ATTACK_RESET_RECALL)

func _end_grapple_attack() -> void:
	grapple_attack_length = 0.0
	grapple_attack_drop_timer = 0.0
	grapple_attack_state_timer = 0.0
	grapple_attack_combo_window_timer = 0.0
	grapple_attack_combo_step_ready = 0
	grapple_attack_current_strike = 0
	grapple_attack_has_hit_this_strike = false
	grapple_attack_hit_targets.clear()
	grapple_attack_cooldown_timer = grapple_attack_cooldown
	_set_grapple_attack_state(GrappleAttackState.READY)
	_update_grapple_attack_visual()
	_reset_grapple_attack_feedback()

func _process_grapple_attack(delta: float) -> void:
	_apply_grapple_attack_feedback(delta)

	match grapple_attack_state:

		GrappleAttackState.ATTACK_EXTEND:
			grapple_attack_length = min(grapple_attack_length + grapple_attack_extend_speed * delta, grapple_attack_range)
			grapple_attack_state_timer = max(grapple_attack_state_timer - delta, 0.0)

			if _grapple_attack_hits_something():
				_set_grapple_attack_state(GrappleAttackState.ATTACK_HIT_CONFIRM)
				return

			if grapple_attack_length >= grapple_attack_range or grapple_attack_state_timer <= 0.0:
				_clear_grapple_attack_combo_window()
				_set_grapple_attack_state(GrappleAttackState.ATTACK_DROP)
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_HIT_CONFIRM:
			grapple_attack_state_timer = max(grapple_attack_state_timer - delta, 0.0)

			if grapple_attack_state_timer <= 0.0:
				_resolve_grapple_attack_hit_confirm()
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_DROP:
			grapple_attack_drop_timer = max(grapple_attack_drop_timer - delta, 0.0)

			if grapple_attack_combo_step_ready != 0:
				grapple_attack_combo_window_timer = max(grapple_attack_combo_window_timer - delta, 0.0)
				if grapple_attack_combo_window_timer <= 0.0:
					_clear_grapple_attack_combo_window()

			if grapple_attack_drop_timer <= 0.0:
				_clear_grapple_attack_combo_window()
				_set_grapple_attack_state(GrappleAttackState.ATTACK_RESET_RECALL)
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_RESET_RECALL:
			grapple_attack_length = move_toward(grapple_attack_length, 0.0, grapple_attack_retract_speed * delta)

			if grapple_attack_length <= 0.0:
				_set_grapple_attack_state(GrappleAttackState.ATTACK_RECOVERY)
				_end_grapple_attack()
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_COMBO_2:
			grapple_attack_state_timer = max(grapple_attack_state_timer - delta, 0.0)

			if _grapple_attack_hits_something():
				_set_grapple_attack_state(GrappleAttackState.ATTACK_HIT_CONFIRM)
				return

			if grapple_attack_state_timer <= 0.0:
				_clear_grapple_attack_combo_window()
				_set_grapple_attack_state(GrappleAttackState.ATTACK_RECOVERY)
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_COMBO_3:
			grapple_attack_state_timer = max(grapple_attack_state_timer - delta, 0.0)

			if _grapple_attack_hits_something():
				# FULL COMBO COMPLETION FEEDBACK
				if anim != null:
					anim.modulate = Color(1.0, 1.0, 1.0) # white flash
				print("FULL COMBO COMPLETE")

				_set_grapple_attack_state(GrappleAttackState.ATTACK_HIT_CONFIRM)
				return

			if grapple_attack_state_timer <= 0.0:
				_clear_grapple_attack_combo_window()
				_set_grapple_attack_state(GrappleAttackState.ATTACK_RESET_RECALL)
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_CHARGE:
			# Stay in charge as long as button is held
			if not grapple_attack_button_held:
				# Safety: if somehow released without going through input handler
				_begin_grapple_attack_strike(4, GrappleAttackState.ATTACK_HEAVY_RELEASE)
				return

			# Lock position / prevent drift behavior
			grapple_attack_length = 0.0

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_HEAVY_RELEASE:
			grapple_attack_length = grapple_attack_range
			grapple_attack_state_timer = max(grapple_attack_state_timer - delta, 0.0)

			if _grapple_attack_hits_something():
				_set_grapple_attack_state(GrappleAttackState.ATTACK_HIT_CONFIRM)
				return

			if grapple_attack_state_timer <= 0.0:
				_clear_grapple_attack_combo_window()
				_set_grapple_attack_state(GrappleAttackState.ATTACK_RECOVERY)
				return

			_update_grapple_attack_visual()


		GrappleAttackState.ATTACK_RECOVERY:
			_set_grapple_attack_state(GrappleAttackState.READY)


		_:
			pass

func _grapple_attack_hits_something() -> bool:
	if grapple_attack_length <= 0.0:
		return false

	if grapple_attack_has_hit_this_strike:
		return false

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(grapple_attack_length, grapple_attack_height)

	var center: Vector2 = global_position + Vector2(
		facing_dir * (grapple_attack_start_offset_x + (grapple_attack_length * 0.5)),
		grapple_attack_offset_y
	)

	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, center)
	params.exclude = [self]
	params.collision_mask = collision_mask
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var results: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(params, 8)

	for result in results:
		var collider: Node = result.get("collider") as Node
		if collider == null or collider == self:
			continue

		var target: Node = collider

		if collider is Area2D:
			var parent: Node = collider.get_parent() as Node
			if parent != null and parent.is_in_group("enemy"):
				target = parent

		if not target.is_in_group("enemy"):
			continue

		var target_id: int = target.get_instance_id()
		if grapple_attack_hit_targets.has(target_id):
			continue

		grapple_attack_hit_targets[target_id] = true
		grapple_attack_has_hit_this_strike = true
		_apply_grapple_attack_to_target(target)
		add_fuel(fuel_per_grapple_hit)
		return true

	return false

func _apply_grapple_attack_to_target(target: Node) -> void:
	if target.has_method("apply_grapple_attack"):
		target.apply_grapple_attack(facing_dir, grapple_attack_damage)
		return

	if target.has_method("apply_dash_strike"):
		target.apply_dash_strike(
			facing_dir,
			grapple_attack_damage,
			grapple_attack_fallback_knockback_x,
			grapple_attack_fallback_knockback_y
		)
		return

	if target.has_method("take_damage"):
		target.take_damage(grapple_attack_damage)
		return

func _handle_dash_input() -> void:
	if not can_dash:
		return

	if is_climbing:
		return

	if dash_timer > 0.0 or dash_cooldown_timer > 0.0:
		return

	if not Input.is_action_just_pressed("dash"):
		return

	var dash_input_dir := facing_dir

	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		dash_input_dir = -1
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		dash_input_dir = 1

	_start_dash(dash_input_dir)

func _handle_shield_input() -> void:
	if not can_shield:
		return

	if Input.is_action_just_pressed("shield"):
		if shield_active:
			_break_shield()
		else:
			_activate_shield()

func _handle_crouch_input() -> void:
	if not input_enabled:
		return

	if not Input.is_action_just_pressed("crouch"):
		return

	if is_crouching:
		_try_exit_crouch()
		return

	if not is_on_floor():
		return

	_enter_crouch()

func _handle_grapple_attack_input(delta: float) -> void:
	grapple_attack_requested = false

	grapple_attack_button_pressed = Input.is_action_just_pressed("shoot_charge")
	grapple_attack_button_held = Input.is_action_pressed("shoot_charge")
	grapple_attack_button_released = Input.is_action_just_released("shoot_charge")

	if not input_enabled:
		return

	if is_torch_aiming:
		return

	if is_climbing:
		return

	if is_grapple_winding_up or is_grapple_pulling or is_grapple_hopping:
		return

	if dash_timer > 0.0:
		return

	# HOLD TIMER
	if grapple_attack_button_held:
		grapple_attack_hold_time += delta
	else:
		grapple_attack_hold_time = 0.0

	# -------------------------
	# STATE-BASED INPUT LOGIC
	# -------------------------

	match grapple_attack_state:

		GrappleAttackState.READY:
			if grapple_attack_cooldown_timer > 0.0:
				return

			if grapple_attack_button_pressed:
				grapple_attack_requested = true
				_start_grapple_attack()

		GrappleAttackState.ATTACK_EXTEND:
			if grapple_attack_button_held and grapple_attack_hold_time >= grapple_attack_hold_threshold:
				_set_grapple_attack_state(GrappleAttackState.ATTACK_CHARGE)

		GrappleAttackState.ATTACK_DROP:
			if grapple_attack_button_pressed:
				if grapple_attack_combo_step_ready == 1 and grapple_attack_combo_window_timer > 0.0:
					_begin_grapple_attack_strike(2, GrappleAttackState.ATTACK_COMBO_2)
				elif grapple_attack_combo_step_ready == 2 and grapple_attack_combo_window_timer > 0.0:
					_begin_grapple_attack_strike(3, GrappleAttackState.ATTACK_COMBO_3)
				else:
					_clear_grapple_attack_combo_window()
					_set_grapple_attack_state(GrappleAttackState.ATTACK_RESET_RECALL)

			elif grapple_attack_button_held and grapple_attack_hold_time >= grapple_attack_hold_threshold:
				_set_grapple_attack_state(GrappleAttackState.ATTACK_CHARGE)

		GrappleAttackState.ATTACK_CHARGE:
			if grapple_attack_button_released:
				_begin_grapple_attack_strike(4, GrappleAttackState.ATTACK_HEAVY_RELEASE)
				return

		GrappleAttackState.ATTACK_RECOVERY:
			pass

func _handle_torch_fire_input() -> void:
	if not input_enabled:
		return

	if not is_torch_aiming:
		return

	if Input.is_action_just_pressed("shoot_charge"):
		fire_torch_shot()

func _initialize_crouch_state() -> void:
	if main_collision == null:
		return

	var rect_shape := main_collision.shape as RectangleShape2D
	if rect_shape == null:
		return

	standing_collision_size = rect_shape.size
	standing_collision_position = main_collision.position
	crouching_collision_size = Vector2(standing_collision_size.x, crouch_collision_height)
	crouching_collision_position = standing_collision_position + Vector2(0.0, (standing_collision_size.y - crouching_collision_size.y) * 0.5)

	if anim != null:
		standing_sprite_position = anim.position
		crouching_sprite_position = standing_sprite_position + Vector2(0.0, crouch_sprite_offset_y)

	_apply_crouch_state(false)

func _enter_crouch() -> void:
	if main_collision == null:
		return

	is_crouching = true
	_apply_crouch_state(true)

func _try_exit_crouch() -> void:
	if not _can_exit_crouch():
		return

	is_crouching = false
	_apply_crouch_state(false)

func _apply_crouch_state(crouched: bool) -> void:
	if main_collision != null:
		var rect_shape := main_collision.shape as RectangleShape2D
		if rect_shape != null:
			if crouched:
				rect_shape.size = crouching_collision_size
				main_collision.position = crouching_collision_position
			else:
				rect_shape.size = standing_collision_size
				main_collision.position = standing_collision_position

	if anim != null:
		anim.position = crouching_sprite_position if crouched else standing_sprite_position

func _can_exit_crouch() -> bool:
	if main_collision == null:
		return true

	var rect_shape := main_collision.shape as RectangleShape2D
	if rect_shape == null:
		return true

	var standing_shape := RectangleShape2D.new()
	standing_shape.size = standing_collision_size

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = standing_shape
	params.transform = global_transform * Transform2D(0.0, standing_collision_position)
	params.exclude = [self]
	params.collision_mask = collision_mask
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var results := get_world_2d().direct_space_state.intersect_shape(params)

	for result in results:
		var collider = result.get("collider")
		if collider != self:
			return false

	return true

func _handle_flight_input() -> void:
	if not can_flight:
		return

	if is_climbing:
		return

	if dash_timer > 0.0:
		return

	if Input.is_action_just_pressed("flight"):
		if not is_flying:
			if flight_time_left > 0.0:
				_start_flight()
		elif flight_flap_cooldown_timer <= 0.0:
			velocity.y = min(velocity.y, flight_flap_velocity)
			flight_flap_cooldown_timer = flight_flap_cooldown

func _start_flight() -> void:
	is_flying = true
	is_crouching = false
	_apply_crouch_state(false)
	_cancel_charge_state()
	velocity.y = min(velocity.y, flight_start_velocity)
	flight_flap_cooldown_timer = flight_flap_cooldown
func _stop_flight() -> void:
	is_flying = false
	flight_flap_cooldown_timer = 0.0

func _activate_shield() -> void:
	shield_active = true
	shield_timer = shield_duration
	_sync_shield_visuals()

func _break_shield(grant_break_invulnerability: bool = true) -> void:
	shield_active = false
	shield_timer = 0.0
	shield_cooldown_timer = shield_cooldown

	if grant_break_invulnerability:
		invulnerability_timer = max(invulnerability_timer, shield_break_invulnerability_time)

	_sync_shield_visuals()

func _sync_shield_visuals() -> void:
	var shield_enabled: bool = can_shield and shield_active

	if shield_sprite != null:
		shield_sprite.visible = shield_enabled

	if shield_collision != null:
		shield_collision.set_deferred("disabled", not shield_enabled)

	if shield_area != null:
		shield_area.set_deferred("monitoring", shield_enabled)

func _start_dash(direction: int) -> void:
	dash_direction = direction
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_just_started = true
	is_crouching = false
	_apply_crouch_state(false)
	_cancel_charge_state()
	if _is_grapple_attack_active():
		_end_grapple_attack()
	_stop_flight()
	velocity.x = dash_direction * dash_speed
	velocity.y = 0.0

func _cancel_dash_if_input() -> void:
	if dash_timer <= 0.0 or dash_just_started:
		return

	if (
		Input.is_action_just_pressed("move_left")
		or Input.is_action_just_pressed("move_right")
		or Input.is_action_just_pressed("jump")
		or Input.is_action_just_pressed("shoot_charge")
		or Input.is_action_just_pressed("grapple_attack")
		or Input.is_action_pressed("flight")
		or Input.is_action_pressed("climb_up")
		or Input.is_action_pressed("climb_down")
	):
		dash_timer = 0.0
		dash_direction = 0

func _update_facing() -> void:
	if anim == null:
		return

	if is_grapple_pulling or is_grapple_hopping:
		facing_dir = grapple_face_dir
	elif dash_timer > 0.0:
		facing_dir = dash_direction
	elif velocity.x > 0.0:
		facing_dir = 1
	elif velocity.x < 0.0:
		facing_dir = -1

	anim.flip_h = facing_dir < 0

func _update_animation() -> void:
	if anim == null or anim.sprite_frames == null:
		return

	var moving_on_ground: bool = is_on_floor() and absf(velocity.x) > 10.0

	if moving_on_ground:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")

func _update_charge_pips() -> void:
	if charge_pip_1 == null or charge_pip_2 == null or charge_pip_3 == null:
		return

	var shown_charge: int = stored_charge_power
	if is_charging:
		shown_charge = _get_charge_power_from_timer()
	PLAYER_VISUAL_HELPER.update_charge_pips(charge_pip_1, charge_pip_2, charge_pip_3, shown_charge)

func _apply_enemy_contact_damage(was_falling: bool) -> void:
	if invulnerability_timer > 0.0:
		return

	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision == null:
			continue

		var collider: Node = collision.get_collider() as Node
		if collider == null:
			continue

		if not collider.is_in_group("enemy"):
			continue

		if dash_timer > 0.0:
			if collider.has_method("apply_dash_strike"):
				collider.apply_dash_strike(
					dash_direction,
					dash_strike_damage,
					dash_strike_knockback_x,
					dash_strike_knockback_y
				)

				dash_timer = 0.0
				dash_direction = 0
				dash_just_started = false
				velocity.x = 0.0
				velocity.y = 0.0
				return
			continue

		if collider.has_method("can_damage_player") and not collider.can_damage_player():
			continue

		var normal: Vector2 = collision.get_normal()

		# Only treat it as a stomp if the player was falling before movement
		# and the collision came from above.
		if was_falling and normal.y < -0.7 and collider.has_method("stomp"):
			collider.stomp()
			velocity.y = jump_velocity * 0.5
			return

		take_damage(collider.global_position.x)
		return

func take_damage(from_x: float) -> void:
	if invulnerability_timer > 0.0:
		return

	if dash_timer > 0.0:
		return

	_cancel_charge_state()
	dash_timer = 0.0
	dash_direction = 0
	is_crouching = false
	_apply_crouch_state(false)
	is_climbing = false
	is_grapple_winding_up = false
	is_grapple_pulling = false
	grapple_target = null
	_update_grapple_traverse_visual()
	if _is_grapple_attack_active():
		_end_grapple_attack()
	_stop_flight()

	if can_shield and shield_active:
		_break_shield()
		return

	shield_active = false
	_sync_shield_visuals()

	if bonus_hp > 0:
		bonus_hp -= 1
	else:
		current_hp -= 1

	hp_changed.emit(current_hp + bonus_hp)

	invulnerability_timer = invulnerability_time
	hitstun_timer = hitstun_time
	
	var horizontal_dir: float = sign(global_position.x - from_x)
	if horizontal_dir == 0.0:
		horizontal_dir = -1.0

	velocity.x = horizontal_dir * knockback_x
	velocity.y = knockback_y

	print("Player HP: ", current_hp, " Bonus HP: ", bonus_hp)

	if current_hp <= 0:
		die()

func bounce_from_stomp() -> void:
	velocity.y = jump_velocity * 0.5

func apply_powerup() -> void:
	if current_hp < max_hp:
		current_hp += 1
	elif bonus_hp < max_bonus_hp:
		bonus_hp += 1

	hp_changed.emit(current_hp + bonus_hp)

func add_special_tick() -> void:
	if current_special >= max_special:
		return

	current_special += 1
	special_changed.emit(current_special)

func add_fuel(amount: int) -> void:
	if amount <= 0:
		return

	current_fuel = min(current_fuel + amount, max_fuel)
	current_shots = current_fuel
	fuel_changed.emit(current_fuel)

func spend_fuel(amount: int) -> bool:
	if amount <= 0:
		return true

	if current_fuel < amount:
		return false

	current_fuel -= amount
	current_shots = current_fuel
	fuel_changed.emit(current_fuel)
	return true

func can_use_special() -> bool:
	return current_special >= max_special

func use_special() -> void:
	if not can_use_special():
		return

	_cancel_charge_state()

	if not fire_projectile(special_hit_power, 0):
		return

	current_special = 0
	special_changed.emit(current_special)

func _shield_should_block_node(node: Node) -> bool:
	if node == null:
		return false

	if node == self:
		return false

	return node.is_in_group("enemy") or node.is_in_group("hazard")

func _on_shield_area_body_entered(body: Node2D) -> void:
	if not can_shield or not shield_active:
		return

	if invulnerability_timer > 0.0:
		return

	if _shield_should_block_node(body):
		_break_shield()

func _on_shield_area_area_entered(area: Area2D) -> void:
	if not can_shield or not shield_active:
		return

	if invulnerability_timer > 0.0:
		return

	if _shield_should_block_node(area):
		_break_shield()

signal hp_changed(current_hp)
signal special_changed(current_special)
signal fuel_changed(current_fuel)
signal player_died

func die() -> void:
	player_died.emit()
	queue_free()
