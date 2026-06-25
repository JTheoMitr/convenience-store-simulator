extends Area3D

@export var item_id: String = "genshin_energy"
@export var item_display_name: String = "Genshin Energy"
@export var item_price: float = 1.99
@export var computer_drag_blocker: Area3D

@export var counter_drag_bounds: Area3D
@export var station_manager: Node
@export var camera: Camera3D

# How far above the counter the bottle floats while being dragged.
@export var drag_height_offset: float = 0.2

var is_dragging: bool = false
var has_been_scanned: bool = false
var drag_plane_y: float = 1.0
var resting_y: float = 0.0


func _ready() -> void:
	resting_y = global_position.y
	input_event.connect(_on_input_event)


func _on_input_event(
	_camera: Camera3D,
	event: InputEvent,
	_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	print("Genshin Energy input event:", event)

	if station_manager == null or !station_manager.is_at_register():
		return

	if has_been_scanned:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			AudioManager.play_bottle_grab()

			is_dragging = true
			drag_plane_y = resting_y + drag_height_offset

			if CursorManager.instance != null:
				CursorManager.instance.set_dragging(true)
		else:
			stop_dragging()


func _unhandled_input(event: InputEvent) -> void:
	if !is_dragging:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			stop_dragging()


func stop_dragging() -> void:
	is_dragging = false
	global_position.y = resting_y

	if CursorManager.instance != null:
		CursorManager.instance.set_dragging(false)


func _process(_delta: float) -> void:
	if !is_dragging or camera == null:
		return

	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)

	var drag_plane := Plane(Vector3.UP, drag_plane_y)
	var hit_position: Variant = drag_plane.intersects_ray(ray_origin, ray_direction)

	if hit_position is Vector3:
		var clamped_position: Vector3 = clamp_to_counter_bounds(hit_position)
		clamped_position = avoid_computer_blocker(clamped_position)

		global_position.x = clamped_position.x
		global_position.y = drag_plane_y
		global_position.z = clamped_position.z


func scan_item(order_manager: Node) -> void:
	if has_been_scanned:
		return

	has_been_scanned = true
	is_dragging = false

	if CursorManager.instance != null:
		CursorManager.instance.set_dragging(false)

	order_manager.add_scanned_item(item_id)
	AudioManager.play_scan()

	queue_free()


func clamp_to_counter_bounds(world_position: Vector3) -> Vector3:
	if counter_drag_bounds == null:
		return world_position

	var shape_node := counter_drag_bounds.get_node_or_null("CollisionShape3D") as CollisionShape3D

	if shape_node == null:
		return world_position

	var box_shape := shape_node.shape as BoxShape3D

	if box_shape == null:
		return world_position

	# Use the CollisionShape3D itself so its transform is respected.
	var local_position: Vector3 = shape_node.to_local(world_position)
	var half_size: Vector3 = box_shape.size * 0.5

	var item_margin: float = 0.0

	half_size.x -= item_margin
	half_size.z -= item_margin

	local_position.x = clampf(local_position.x, -half_size.x, half_size.x)
	local_position.z = clampf(local_position.z, -half_size.z, half_size.z)

	return shape_node.to_global(local_position)
	
func avoid_computer_blocker(world_position: Vector3) -> Vector3:
	if computer_drag_blocker == null:
		return world_position

	var shape_node := computer_drag_blocker.get_node_or_null("CollisionShape3D") as CollisionShape3D

	if shape_node == null:
		return world_position

	var box_shape := shape_node.shape as BoxShape3D

	if box_shape == null:
		return world_position

	var local_position: Vector3 = shape_node.to_local(world_position)
	var half_size: Vector3 = box_shape.size * 0.5

	# Slightly expand the blocked zone so the bottle does not visually clip in.
	var padding: float = 0.08
	half_size.x += padding
	half_size.z += padding

	var inside_x: bool = absf(local_position.x) < half_size.x
	var inside_z: bool = absf(local_position.z) < half_size.z

	if !inside_x or !inside_z:
		return world_position

	var distance_x: float = half_size.x - absf(local_position.x)
	var distance_z: float = half_size.z - absf(local_position.z)

	if distance_x < distance_z:
		if local_position.x < 0.0:
			local_position.x = -half_size.x
		else:
			local_position.x = half_size.x
	else:
		if local_position.z < 0.0:
			local_position.z = -half_size.z
		else:
			local_position.z = half_size.z

	return shape_node.to_global(local_position)

func setup(
	new_camera: Camera3D,
	new_station_manager: Node,
	new_counter_drag_bounds: Area3D,
	new_computer_drag_blocker: Area3D
) -> void:
	camera = new_camera
	station_manager = new_station_manager
	counter_drag_bounds = new_counter_drag_bounds
	computer_drag_blocker = new_computer_drag_blocker
	
func set_spawn_transform(spawn_position: Vector3, spawn_rotation: Vector3) -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation

	resting_y = global_position.y
	drag_plane_y = resting_y
