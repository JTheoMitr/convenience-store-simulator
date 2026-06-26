extends OmniLight3D

@export var base_energy: float = 1.2
@export var flicker_amount: float = 0.18
@export var flicker_speed: float = 8.0

var time_offset: float = 0.0


func _ready() -> void:
	time_offset = randf() * 100.0
	light_energy = base_energy


func _process(delta: float) -> void:
	time_offset += delta * flicker_speed

	var flicker := sin(time_offset) * flicker_amount
	flicker += sin(time_offset * 2.7) * flicker_amount * 0.35

	light_energy = base_energy + flicker
