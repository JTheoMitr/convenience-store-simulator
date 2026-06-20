class_name CursorManager
extends Control

@onready var hotspot_marker: ColorRect = $HotspotMarker
@export var show_hotspot_debug: bool = true

enum CursorState {
	IDLE,
	OPEN_HAND,
	CLOSED_HAND,
	FINGER_POINTED,
	FINGER_CLICKED,
	MAG_GLASS
}

@export var camera: Camera3D
@export var interaction_ray_length: float = 100.0
@export var draggable_collision_mask: int = 1

@onready var cursor_sprite: AnimatedSprite2D = $CursorSprite

static var instance: CursorManager

var current_state: CursorState = CursorState.IDLE
var dragging_item: bool = false

var cursor_offsets := {
	CursorState.IDLE: Vector2(40, 50),
	CursorState.OPEN_HAND: Vector2(10, -14),
	CursorState.CLOSED_HAND: Vector2(10, -14),
	CursorState.FINGER_POINTED: Vector2(40, 50),
	CursorState.FINGER_CLICKED: Vector2(40, 50),
	CursorState.MAG_GLASS: Vector2(-12, -12)
}


func _ready() -> void:
	instance = self

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	set_cursor_state(CursorState.IDLE)


func _process(_delta: float) -> void:

	var mouse_position := get_viewport().get_mouse_position()

	# The actual click point.
	hotspot_marker.global_position = mouse_position - hotspot_marker.size * 0.5
	hotspot_marker.visible = show_hotspot_debug

	# The visual cursor art, shifted by the current state offset.
	cursor_sprite.global_position = mouse_position + cursor_offsets[current_state]

	update_cursor_state_from_mouse()


func update_cursor_state_from_mouse() -> void:
	# Dragging always wins. The player should keep seeing the closed hand
	# even if the bottle passes over a UI panel or scanner.
	if dragging_item:
		set_cursor_state(CursorState.CLOSED_HAND)
		return

	var hovered_button := get_hovered_button()

	if hovered_button != null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			set_cursor_state(CursorState.FINGER_CLICKED)
		else:
			set_cursor_state(CursorState.FINGER_POINTED)

		return

	var hovered_3d_object := get_hovered_3d_object()

	if hovered_3d_object != null:
		if hovered_3d_object.is_in_group("draggable_counter_item"):
			set_cursor_state(CursorState.OPEN_HAND)
			return

		if hovered_3d_object.is_in_group("inspectable"):
			set_cursor_state(CursorState.MAG_GLASS)
			return

	set_cursor_state(CursorState.IDLE)


func get_hovered_button() -> Button:
	var hovered_control := get_viewport().gui_get_hovered_control()

	while hovered_control != null:
		if hovered_control is Button:
			return hovered_control as Button

		hovered_control = hovered_control.get_parent() as Control

	return null


func get_hovered_3d_object() -> CollisionObject3D:
	if camera == null:
		return null

	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_position) * interaction_ray_length

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = draggable_collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	return result.get("collider") as CollisionObject3D


func set_dragging(is_now_dragging: bool) -> void:
	dragging_item = is_now_dragging


func set_cursor_state(new_state: CursorState) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	match current_state:
		CursorState.IDLE:
			cursor_sprite.frame = 0
		CursorState.OPEN_HAND:
			cursor_sprite.frame = 1
		CursorState.CLOSED_HAND:
			cursor_sprite.frame = 2
		CursorState.FINGER_POINTED:
			cursor_sprite.frame = 3
		CursorState.FINGER_CLICKED:
			cursor_sprite.frame = 4
		CursorState.MAG_GLASS:
			cursor_sprite.frame = 5
