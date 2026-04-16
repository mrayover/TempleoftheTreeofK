extends CanvasLayer

@onready var health_regular: Array[Sprite2D] = [
	$TopHealth/HealthRegular1,
	$TopHealth/HealthRegular2,
	$TopHealth/HealthRegular3,
	$TopHealth/HealthRegular4,
	$TopHealth/HealthRegular5
]

@onready var health_extra: Array[Sprite2D] = [
	$TopHealth/HealthExtra1,
	$TopHealth/HealthExtra2,
	$TopHealth/HealthExtra3
]

@onready var special_pips: Array[Sprite2D] = [
	$SpecialBar/SpecialPip1,
	$SpecialBar/SpecialPip2,
	$SpecialBar/SpecialPip3,
	$SpecialBar/SpecialPip4,
	$SpecialBar/SpecialPip5
]

@onready var shot_pips: Array[Sprite2D] = [
	$ShotBar/ShotPip5,
	$ShotBar/ShotPip4,
	$ShotBar/ShotPip3,
	$ShotBar/ShotPip2,
	$ShotBar/ShotPip1
]

var player: Node = null

func _ready() -> void:
	_find_player()
	_refresh_all()

func _process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		_find_player()
		return

	_update_shot_display()

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if not player.hp_changed.is_connected(_on_player_hp_changed):
		player.hp_changed.connect(_on_player_hp_changed)

	if not player.special_changed.is_connected(_on_player_special_changed):
		player.special_changed.connect(_on_player_special_changed)

	_refresh_all()

func _refresh_all() -> void:
	_update_hp_display()
	_update_special_display()
	_update_shot_display()

func _on_player_hp_changed(_current_hp: int) -> void:
	_update_hp_display()

func _on_player_special_changed(_current_special: int) -> void:
	_update_special_display()

func _update_hp_display() -> void:
	if player == null or not is_instance_valid(player):
		for pip in health_regular:
			pip.visible = false

		for pip in health_extra:
			pip.visible = false

		return

	for i in range(health_regular.size()):
		health_regular[i].visible = i < player.current_hp

	for i in range(health_extra.size()):
		health_extra[i].visible = i < player.bonus_hp

func _update_special_display() -> void:
	if player == null or not is_instance_valid(player):
		for pip in special_pips:
			pip.visible = false
		return

	for i in range(special_pips.size()):
		special_pips[i].visible = i < player.current_special

func _update_shot_display() -> void:
	if player == null or not is_instance_valid(player):
		for pip in shot_pips:
			pip.visible = false
		return

	for i in range(shot_pips.size()):
		shot_pips[i].visible = i < player.current_shots
