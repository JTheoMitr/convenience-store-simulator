extends Node

@export var logo_sprite: Sprite2D
@export var title_screen: PackedScene

@export var main_theme: AudioStream

@export var logo_fade_in_duration: float = 1.2
@export var hold_duration: float = 3.0
@export var transition_duration: float = 1.5

@export var glitch_min_delay: float = 0.5
@export var glitch_max_delay: float = 1.6
@export var glitch_stretch_amount: float = 0.78
@export var glitch_duration: float = 0.035

var logo_base_scale: Vector2
var intro_is_running: bool = true


func _ready() -> void:
	logo_sprite.modulate.a = 0.0
	logo_base_scale = logo_sprite.scale
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

	# Fire off the visual glitches while the logo is held.
	glitch_logo_loop()

	await get_tree().create_timer(hold_duration).timeout

	intro_is_running = false
	logo_sprite.scale = logo_base_scale

	TransitionManager.change_scene(
		title_screen,
		transition_duration,
		transition_duration
	)
	
func glitch_logo_loop() -> void:
	while intro_is_running:
		await get_tree().create_timer(
			randf_range(glitch_min_delay, glitch_max_delay)
		).timeout

		if !intro_is_running:
			return

		var stretch_x := randf_range(
			1.0 - glitch_stretch_amount,
			1.0 + glitch_stretch_amount
		)

		var stretch_y := randf_range(
			1.0 - glitch_stretch_amount * 0.35,
			1.0 + glitch_stretch_amount * 0.35
		)

		logo_sprite.scale = logo_base_scale * Vector2(stretch_x, stretch_y)

		await get_tree().create_timer(glitch_duration).timeout

		logo_sprite.scale = logo_base_scale
