extends RefCounted

static func apply_archetype_frames(anim: AnimatedSprite2D, texture: Texture2D) -> void:
	var frame_width: int = 36
	var frame_height: int = 45

	var frames := SpriteFrames.new()

	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 6.0)

	for i in range(5):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		frames.add_frame("idle", atlas)

	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 10.0)

	for i in range(5, 8):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		frames.add_frame("walk", atlas)

	anim.sprite_frames = frames
	anim.animation = &"idle"
	anim.play("idle")
