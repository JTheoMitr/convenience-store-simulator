extends Button

@export var order_manager: Node


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if order_manager != null:
		AudioManager.play_register_checkout_sound()
		order_manager.open_cash_drawer()
