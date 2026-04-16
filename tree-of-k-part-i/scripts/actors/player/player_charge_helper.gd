extends RefCounted

static func get_max_charge_power(current_archetype: int, torch_archetype: int) -> int:
	if current_archetype == torch_archetype:
		return 4
	return 3

static func get_charge_power_from_timer(
	charge_timer: float,
	current_shots: int,
	max_charge_power: int,
	charge_first_pip_time: float,
	charge_two_hit_time: float,
	charge_three_hit_time: float
) -> int:
	var max_chargeable: int = min(max_charge_power, current_shots)
	var charge_power: int = 0

	if charge_timer >= charge_first_pip_time:
		charge_power = 1
	if charge_timer >= charge_two_hit_time:
		charge_power = 2
	if charge_timer >= charge_three_hit_time:
		charge_power = 3
	if charge_timer >= charge_three_hit_time + charge_first_pip_time:
		charge_power = 4

	return min(charge_power, max_chargeable)
