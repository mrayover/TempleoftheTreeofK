extends RefCounted

static func create_rope_visual(texture: Texture2D, z_index: int) -> Sprite2D:
	var rope_visual := Sprite2D.new()
	rope_visual.centered = false
	rope_visual.visible = false
	rope_visual.z_index = z_index
	rope_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rope_visual.texture = texture
	return rope_visual

static func create_head_visual(texture: Texture2D, z_index: int) -> Sprite2D:
	var head_visual := Sprite2D.new()
	head_visual.centered = true
	head_visual.visible = false
	head_visual.z_index = z_index
	head_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head_visual.texture = texture
	return head_visual

static func update_rope_and_head_visual(
	rope_visual: Sprite2D,
	head_visual: Sprite2D,
	rope_texture: Texture2D,
	head_texture: Texture2D,
	local_start: Vector2,
	local_end: Vector2,
	distance: float,
	angle: float
) -> void:
	if rope_texture != null:
		var rope_width: float = max(1.0, float(rope_texture.get_width()))
		var rope_height: float = float(rope_texture.get_height())

		rope_visual.texture = rope_texture
		rope_visual.position = local_start
		rope_visual.rotation = angle
		rope_visual.scale = Vector2(distance / rope_width, 1.0)
		rope_visual.offset = Vector2(0.0, -rope_height * 0.5)
		rope_visual.visible = true
	else:
		rope_visual.visible = false

	if head_texture != null:
		head_visual.texture = head_texture
		head_visual.position = local_end
		head_visual.rotation = angle
		head_visual.scale = Vector2.ONE
		head_visual.offset = Vector2.ZERO
		head_visual.visible = true
	else:
		head_visual.visible = false

static func update_charge_pips(
	charge_pip_1: ColorRect,
	charge_pip_2: ColorRect,
	charge_pip_3: ColorRect,
	shown_charge: int
) -> void:
	charge_pip_1.visible = shown_charge >= 1
	charge_pip_2.visible = shown_charge >= 2
	charge_pip_3.visible = shown_charge >= 3

	charge_pip_1.color = Color.WHITE
	charge_pip_2.color = Color.WHITE
	charge_pip_3.color = Color.WHITE
