extends Node

@export var logo_sprite: Sprite2D
@export var glitch_logo_sprite: Sprite2D
@export var title_screen: PackedScene
@export var main_theme: AudioStream

@export var logo_fade_in_duration: float = 1.2
@export var hold_duration: float = 3.0
@export var transition_wait_duration: float = 1.0
@export var transition_duration: float = 1.5

@export var glitch_stretch_amount: float = 0.78
@export var glitch_duration: float = 0.035
@export var time_between_glitches: float = 0.65
@export var glitch_offset_amount: float = 12.0

@onready var glitch_sound: AudioStreamPlayer = $AudioStreamPlayer

var logo_base_scale: Vector2
var logo_base_position: Vector2
var glitch_logo_base_position: Vector2


func _ready() -> void:
	logo_sprite.modulate.a = 0.0
	logo_base_scale = logo_sprite.scale
	logo_base_position = logo_sprite.position

	if glitch_logo_sprite != null:
		glitch_logo_sprite.visible = false
		glitch_logo_sprite.scale = logo_base_scale
		glitch_logo_base_position = glitch_logo_sprite.position

	MusicManager.play_track(main_theme)

	await get_tree().create_timer(1.5).timeout
	play_intro()


func play_intro() -> void:
	var logo_tween := create_tween()

	logo_tween.tween_property(
		logo_sprite,
		"modulate:a",
		1.0,
		logo_fade_in_duration
	)

	await logo_tween.finished
	await get_tree().create_timer(hold_duration).timeout

	await play_logo_glitch()
	await get_tree().create_timer(time_between_glitches).timeout
	await play_logo_glitch()

	await get_tree().create_timer(transition_wait_duration).timeout

	logo_sprite.scale = logo_base_scale
	logo_sprite.position = logo_base_position

	TransitionManager.change_scene(
		title_screen,
		transition_duration,
		transition_duration
	)


func play_logo_glitch() -> void:
	if glitch_sound != null:
		glitch_sound.play()

	var stretch_x := randf_range(
		1.0 - glitch_stretch_amount,
		1.0 + glitch_stretch_amount
	)

	var stretch_y := randf_range(
		1.0 - glitch_stretch_amount * 0.35,
		1.0 + glitch_stretch_amount * 0.35
	)

	logo_sprite.scale = logo_base_scale * Vector2(stretch_x, stretch_y)

	if glitch_logo_sprite != null:
		glitch_logo_sprite.visible = true

		if randf() < 0.5:
			glitch_logo_sprite.modulate = Color(0.2, 0.9, 1.0, 0.8)
		else:
			glitch_logo_sprite.modulate = Color(1.0, 0.15, 0.65, 0.8)

		glitch_logo_sprite.position = glitch_logo_base_position + Vector2(
			randf_range(-glitch_offset_amount, glitch_offset_amount),
			randf_range(-3.0, 3.0)
		)

		glitch_logo_sprite.scale = logo_sprite.scale

	await get_tree().create_timer(glitch_duration).timeout

	logo_sprite.scale = logo_base_scale
	logo_sprite.position = logo_base_position

	if glitch_logo_sprite != null:
		glitch_logo_sprite.visible = false
		glitch_logo_sprite.position = glitch_logo_base_position
		glitch_logo_sprite.scale = logo_base_scale
