extends Control

@export var glitch_min_delay: float = 1.5
@export var glitch_max_delay: float = 5.0
@export var glitch_offset_amount: float = 6.0

@export var neon_base_alpha: float = 1.0
@export var neon_flicker_amount: float = 0.12
@export var neon_flicker_speed: float = 5.0

@export var blackout_chance: float = 0.12
@export var blackout_min_duration: float = 0.02
@export var blackout_max_duration: float = 0.08

@onready var title_label: Label = $TitleLabel
@onready var glitch_label: Label = $GlitchLabel

var glitch_timer: Timer
var title_base_position: Vector2
var glitch_base_position: Vector2
var flicker_time: float = 0.0
var is_blackout: bool = false


func _ready() -> void:
	title_base_position = title_label.position
	glitch_base_position = glitch_label.position

	glitch_label.visible = false

	glitch_timer = Timer.new()
	glitch_timer.one_shot = true
	add_child(glitch_timer)

	glitch_timer.timeout.connect(_play_glitch)
	_schedule_next_glitch()


func _process(delta: float) -> void:
	if is_blackout:
		return

	flicker_time += delta * neon_flicker_speed

	var flicker := sin(flicker_time) * neon_flicker_amount
	flicker += sin(flicker_time * 2.7) * neon_flicker_amount * 0.35

	title_label.modulate.a = clampf(neon_base_alpha + flicker, 0.0, 1.0)


func _schedule_next_glitch() -> void:
	glitch_timer.start(randf_range(glitch_min_delay, glitch_max_delay))


func _play_glitch() -> void:
	var flashes: int = randi_range(2, 4)

	for i in range(flashes):
		title_label.position = title_base_position + Vector2(
			randf_range(-2.0, 2.0),
			randf_range(-1.0, 1.0)
		)

		glitch_label.visible = true
		glitch_label.position = glitch_base_position + Vector2(
			randf_range(-glitch_offset_amount, glitch_offset_amount),
			randf_range(-2.0, 2.0)
		)

		if randf() < 0.5:
			glitch_label.modulate = Color(0.2, 0.9, 1.0, 0.8)
		else:
			glitch_label.modulate = Color(1.0, 0.15, 0.65, 0.8)

		if randf() < blackout_chance:
			await _flicker_out()

		await get_tree().create_timer(randf_range(0.02, 0.06)).timeout
		glitch_label.visible = false

		await get_tree().create_timer(randf_range(0.02, 0.05)).timeout

	title_label.position = title_base_position
	glitch_label.position = glitch_base_position
	glitch_label.visible = false

	_schedule_next_glitch()


func _flicker_out() -> void:
	is_blackout = true
	title_label.visible = false

	await get_tree().create_timer(
		randf_range(blackout_min_duration, blackout_max_duration)
	).timeout

	title_label.visible = true
	is_blackout = false
