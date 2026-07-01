extends Button

@export var order_manager: Node


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	order_manager.checkout()
	AudioManager.play_sale_completed_sound()
