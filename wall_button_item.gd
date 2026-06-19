extends Button

@export var item_id: String
@export var order_manager: Node


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	order_manager.add_wall_item(item_id)
