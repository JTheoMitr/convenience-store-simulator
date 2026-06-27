extends Node

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

var is_transitioning: bool = false


func _ready() -> void:
	fade_rect.color.a = 0.0


func change_scene(scene: PackedScene, fade_out_duration: float = 1.0, fade_in_duration: float = 1.0) -> void:
	if is_transitioning:
		return

	is_transitioning = true

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "color:a", 1.0, fade_out_duration)
	await fade_out.finished

	get_tree().change_scene_to_packed(scene)

	# Let the new scene render once while the black overlay remains up.
	await get_tree().process_frame

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, fade_in_duration)
	await fade_in.finished

	is_transitioning = false
