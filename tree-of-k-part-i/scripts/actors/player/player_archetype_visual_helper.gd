extends RefCounted

static func apply_archetype_frames(anim: AnimatedSprite2D, texture: Texture2D) -> void:
	if anim == null or texture == null:
		return

	var total_frames: int = 8
	var idle_frames: int = 5
	var walk_frames: int = 3

	var frame_width: int = int(texture.get_width() / total_frames)
	var frame_height: int = texture.get_height()

	var frames := SpriteFrames.new()

	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 6.0)

	for i in range(idle_frames):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		frames.add_frame("idle", atlas)

	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 10.0)

	for i in range(walk_frames):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2((idle_frames + i) * frame_width, 0, frame_width, frame_height)
		frames.add_frame("walk", atlas)

	anim.sprite_frames = frames
	anim.animation = &"idle"
	anim.play("idle")