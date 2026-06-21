extends Node

@export var camera: Camera3D

@export var counter_marker: Marker3D
@export var register_marker: Marker3D
@export var wall_marker: Marker3D

@export var customer_dialogue_panel: Control
@export var register_ui: Control
@export var wall_item_ui: Control

@export var register_monitor: Control

var current_station: String = "counter"
var is_moving: bool = false


func _ready() -> void:
	go_to_station("counter", true)
	
	print("StationManager ready")
	print("Camera:", camera)
	print("Counter marker:", counter_marker)
	


func go_to_station(station_name: String, instant: bool = false) -> void:
	if is_moving:
		return

	var target_marker := get_marker_for_station(station_name)

	if target_marker == null:
		push_warning("No marker found for station: " + station_name)
		return

	current_station = station_name
	update_ui_for_station(station_name)

	if instant:
		camera.global_position = target_marker.global_position
		camera.global_rotation = target_marker.global_rotation
		return

	is_moving = true

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		camera,
		"global_position",
		target_marker.global_position,
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		camera,
		"global_rotation",
		target_marker.global_rotation,
		0.85
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_camera_move_finished)


func get_marker_for_station(station_name: String) -> Marker3D:
	match station_name:
		"counter":
			return counter_marker
		"register":
			return register_marker
		"wall":
			return wall_marker
		_:
			return null


func update_ui_for_station(station_name: String) -> void:
	customer_dialogue_panel.visible = station_name == "counter"
	register_ui.visible = station_name == "register"
	wall_item_ui.visible = station_name == "wall"
	register_monitor.visible = station_name == "register"


func _on_camera_move_finished() -> void:
	is_moving = false
	
func is_at_register() -> bool:
	return current_station == "register"
