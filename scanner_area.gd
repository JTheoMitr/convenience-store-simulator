extends Area3D

@export var order_manager: Node


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if !area.has_method("scan_item"):
		return

	area.scan_item(order_manager)
