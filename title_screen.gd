extends Node3D

@export var clock_in_button: Button
@export var gameplay_scene: PackedScene


func _ready() -> void:
	clock_in_button.pressed.connect(_on_clock_in_pressed)


func _on_clock_in_pressed() -> void:
	get_tree().change_scene_to_packed(gameplay_scene)
