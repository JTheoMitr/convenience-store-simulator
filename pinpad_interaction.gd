extends Area3D

@export var station_manager: Node

@onready var hover_glow: MeshInstance3D = $HoverGlow

var is_hovered: bool = false


func _ready() -> void:
	add_to_group("clickable_3d")

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	hover_glow.visible = false


func _on_mouse_entered() -> void:
	if station_manager == null or !station_manager.is_at_register():
		return

	is_hovered = true
	hover_glow.visible = true


func _on_mouse_exited() -> void:
	is_hovered = false
	hover_glow.visible = false


func _on_input_event(
	_camera: Camera3D,
	event: InputEvent,
	_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if station_manager == null:
		return

	if !station_manager.is_at_register():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hover_glow.visible = false
			AudioManager.play_ui_click()
			station_manager.go_to_station("pinpad")
