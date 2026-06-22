extends Area3D

@export var item_id: String = "whiskey_bottle"
@export var item_display_name: String = "Whiskey Bottle"
@export var item_price: float = 18.99
@export var counter_drag_bounds: Area3D
@export var station_manager: Node

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
	
	if station_manager == null or !station_manager.is_at_register():
		return
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
		var clamped_position := clamp_to_counter_bounds(hit_position)
		global_position.x = clamped_position.x
		global_position.z = clamped_position.z
		
func scan_item(order_manager: Node) -> void:
	
	if CursorManager.instance != null:
		CursorManager.instance.set_dragging(false)
	if has_been_scanned:
		return

	has_been_scanned = true
	is_dragging = false

	order_manager.add_scanned_item(item_id)
	AudioManager.play_scan()

	queue_free()


func _on_area_entered(_area: Area3D) -> void:
	pass # Replace with function body.
	
func clamp_to_counter_bounds(world_position: Vector3) -> Vector3:
	if counter_drag_bounds == null:
		return world_position

	var shape_node := counter_drag_bounds.get_node_or_null("CollisionShape3D") as CollisionShape3D

	if shape_node == null:
		return world_position

	var box_shape := shape_node.shape as BoxShape3D

	if box_shape == null:
		return world_position

	# Use the CollisionShape3D itself, not the Area3D parent,
	# so its position, scale, and rotation are respected.
	var local_position := shape_node.to_local(world_position)
	var half_size := box_shape.size * 0.5

	# Temporarily keep this at 0 while dialing in the usable area.
	var item_margin := 0.0

	half_size.x -= item_margin
	half_size.z -= item_margin

	local_position.x = clampf(local_position.x, -half_size.x, half_size.x)
	local_position.z = clampf(local_position.z, -half_size.z, half_size.z)

	return shape_node.to_global(local_position)
