extends Area3D

@export var order_manager: Node
@export var scanner_arrows: AnimatedSprite3D


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if !area.has_method("scan_item"):
		return
		
	play_scan_flash()

	area.scan_item(order_manager)

func play_scan_flash() -> void:
	if scanner_arrows == null:
		return

	scanner_arrows.stop()
	scanner_arrows.frame = 1

	await get_tree().create_timer(0.2).timeout

	if scanner_arrows != null:
		scanner_arrows.frame = 0	
