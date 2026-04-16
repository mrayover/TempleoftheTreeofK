extends Node

const ARCHETYPE_TORCH := 0
const ARCHETYPE_SNAKE := 1
const ARCHETYPE_CROW := 2
const ARCHETYPE_HEART := 3

var guardian_fragment_collected: bool = false
var champion_key_half_a_collected: bool = false
var champion_key_half_b_collected: bool = false
var champion_cleared: bool = false
var current_stage: int = 1

var current_archetype: int = ARCHETYPE_TORCH

var can_dash: bool = false
var can_flight: bool = false
var can_shield: bool = false

func has_champion_key() -> bool:
	return champion_key_half_a_collected and champion_key_half_b_collected

func get_active_key_pair_index() -> int:
	return current_archetype

func reset_for_new_run() -> void:
	guardian_fragment_collected = false
	champion_key_half_a_collected = false
	champion_key_half_b_collected = false
	champion_cleared = false
	current_stage = 1
	_apply_current_archetype_powers()

func set_champion_key_half(key_half_id: String, collected: bool) -> void:
	match key_half_id:
		"A":
			champion_key_half_a_collected = collected
		"B":
			champion_key_half_b_collected = collected

func clear_champion_keys() -> void:
	champion_key_half_a_collected = false
	champion_key_half_b_collected = false

func mark_stage_1_cleared() -> void:
	guardian_fragment_collected = true
	champion_cleared = true
	clear_champion_keys()
	current_stage = 2

func mark_stage_2_cleared() -> void:
	guardian_fragment_collected = true
	champion_cleared = true
	clear_champion_keys()
	current_stage = 1

	if current_archetype < ARCHETYPE_HEART:
		current_archetype += 1

	_apply_current_archetype_powers()

func advance_after_champion_clear() -> void:
	mark_stage_2_cleared()

func _apply_current_archetype_powers() -> void:
	match current_archetype:
		ARCHETYPE_TORCH:
			can_dash = false
			can_flight = false
			can_shield = false
		ARCHETYPE_SNAKE:
			can_dash = true
			can_flight = false
			can_shield = false
		ARCHETYPE_CROW:
			can_dash = true
			can_flight = true
			can_shield = false
		ARCHETYPE_HEART:
			can_dash = true
			can_flight = true
			can_shield = true

func get_archetype_name() -> String:
	match current_archetype:
		ARCHETYPE_TORCH:
			return "torch"
		ARCHETYPE_SNAKE:
			return "snake"
		ARCHETYPE_CROW:
			return "crow"
		ARCHETYPE_HEART:
			return "heart"

	return "torch"

func sync_player_powers_from(player: Node) -> void:
	if player == null:
		return

	can_dash = player.can_dash
	can_flight = player.can_flight
	can_shield = player.can_shield

func apply_player_powers_to(player: Node) -> void:
	if player == null:
		return

	player.can_dash = can_dash
	player.can_flight = can_flight
	player.can_shield = can_shield
