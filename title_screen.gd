extends Node3D

@export var clock_in_button: Button
@export var gameplay_scene: PackedScene

@export var breathing_fov_amount: float = 1.0
@export var breathing_speed: float = 0.65

@export var title_camera: Camera3D

var base_fov: float
var breathing_time: float = 0.0


func _ready() -> void:
	base_fov = title_camera.fov
	clock_in_button.pressed.connect(_on_clock_in_pressed)


func _on_clock_in_pressed() -> void:
	get_tree().change_scene_to_packed(gameplay_scene)

func _process(delta: float) -> void:
	if title_camera == null:
		return

	breathing_time += delta * breathing_speed

	title_camera.fov = base_fov + sin(breathing_time) * breathing_fov_amount
