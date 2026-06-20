extends Area3D

@export var item_id: String = "whiskey_bottle"
@export var item_display_name: String = "Whiskey Bottle"
@export var item_price: float = 18.99

@export var camera: Camera3D

var is_dragging: bool = false
var has_been_scanned: bool = false
var drag_plane_y: float = 1.0


func _ready() -> void:
	input_event.connect(_on_input_event)


func _on_input_event(
	_camera: Camera3D,
	event: InputEvent,
	_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	print("Whiskey input event:", event)
	if has_been_scanned:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_plane_y = global_position.y

			if CursorManager.instance != null:
				CursorManager.instance.set_dragging(true)
		else:
			is_dragging = false

			if CursorManager.instance != null:
				CursorManager.instance.set_dragging(false)


func _unhandled_input(event: InputEvent) -> void:
	if !is_dragging:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			is_dragging = false

			if CursorManager.instance != null:
				CursorManager.instance.set_dragging(false)


func _process(_delta: float) -> void:
	if !is_dragging or camera == null:
		return

	var mouse_position := get_viewport().get_mouse_position()

	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)

	var drag_plane := Plane(Vector3.UP, drag_plane_y)
	var hit_position = drag_plane.intersects_ray(ray_origin, ray_direction)

	if hit_position != null:
		global_position.x = hit_position.x
		global_position.z = hit_position.z
		
func scan_item(order_manager: Node) -> void:
	
	if CursorManager.instance != null:
		CursorManager.instance.set_dragging(false)
	if has_been_scanned:
		return

	has_been_scanned = true
	is_dragging = false

	order_manager.add_scanned_item(item_id)

	queue_free()


func _on_area_entered(_area: Area3D) -> void:
	pass # Replace with function body.
