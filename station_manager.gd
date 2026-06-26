extends Node

@export var camera: Camera3D

@export var navigation_ui: Control

@export var counter_marker: Marker3D
@export var register_marker: Marker3D
@export var wall_marker: Marker3D
@export var pinpad_marker: Marker3D

@export var pinpad_placeholder: Sprite3D

@export var customer_dialogue_panel: Control
@export var register_ui: Control
@export var wall_item_ui: Control

@export var register_monitor: Control
@export var pinpad_ui: Control

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
	
	if navigation_ui != null:
		navigation_ui.update_active_station(station_name)
	
	hide_station_ui()

	if instant:
		camera.global_position = target_marker.global_position
		camera.global_rotation = target_marker.global_rotation
		update_ui_for_station(station_name)
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

	tween.finished.connect(_on_camera_move_finished.bind(station_name))


func get_marker_for_station(station_name: String) -> Marker3D:
	match station_name:
		"counter":
			return counter_marker
		"register":
			return register_marker
		"wall":
			return wall_marker
		"pinpad":
			return pinpad_marker
		_:
			return null


func update_ui_for_station(station_name: String) -> void:
	customer_dialogue_panel.visible = station_name == "counter"
	register_ui.visible = station_name == "register"
	wall_item_ui.visible = station_name == "wall"
	if pinpad_ui != null:
		pinpad_ui.visible = station_name == "pinpad"
	#await get_tree().create_timer(1.5).timeout
	#register_monitor.visible = station_name == "register" or station_name == "pinpad"
	if pinpad_placeholder != null:
		pinpad_placeholder.visible = station_name != "pinpad"
func _on_camera_move_finished(station_name: String) -> void:
	var rot := camera.global_rotation_degrees
	rot.y = wrapf(rot.y, -180.0, 180.0)
	camera.global_rotation_degrees = rot

	update_ui_for_station(station_name)
	is_moving = false
	
func is_at_register() -> bool:
	return current_station == "register"
	
func hide_station_ui() -> void:
	customer_dialogue_panel.visible = false
	register_ui.visible = false
	wall_item_ui.visible = false

	if pinpad_ui != null:
		pinpad_ui.visible = false
