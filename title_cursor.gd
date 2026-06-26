extends Control

@export var cursor_offset := Vector2(8, 8)

@onready var cursor_sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta: float) -> void:
	cursor_sprite.position = get_viewport().get_mouse_position() + cursor_offset
