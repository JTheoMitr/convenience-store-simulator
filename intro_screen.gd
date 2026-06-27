extends Node

@export var logo_sprite: Sprite2D
@export var title_screen: PackedScene

@export var main_theme: AudioStream

@export var logo_fade_in_duration: float = 1.2
@export var hold_duration: float = 3.0
@export var transition_duration: float = 1.5


func _ready() -> void:
	logo_sprite.modulate.a = 0.0
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

	TransitionManager.change_scene(
		title_screen,
		transition_duration,
		transition_duration
	)
