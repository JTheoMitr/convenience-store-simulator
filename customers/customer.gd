extends Node3D

func setup(customer_data: Dictionary) -> void:
	var customer_sprite := get_node_or_null("CustomerSprite") as AnimatedSprite3D

	if customer_sprite == null:
		push_warning("Customer scene could not find CustomerSprite.")
		return

	var sprite_frame: int = int(customer_data.get("sprite_frame", 0))

	customer_sprite.animation = &"customers"
	customer_sprite.stop()
	customer_sprite.frame = sprite_frame
