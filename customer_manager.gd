extends Node

@export var dialogue_label: Label
@export var order_manager: Node
@export var customer_sprite: AnimatedSprite3D

var current_customer_index: int = 0

var customers: Array[Dictionary] = [
	{
		"name": "Customer 1",
		"dialogue": "Can I get a pack of Reds and a Mega Money?",
		"sprite_frame": 0,
		"money_given": 20.00,
		"wall_items": {
			"reds": 1,
			"mega_money": 1
		}
	},
	{
		"name": "Customer 2",
		"dialogue": "Give me two King D's and this whiskey bottle?",
		"sprite_frame": 1,
		"money_given": 50.00,
		"wall_items": {
			"king_diamond": 2
		},
		"counter_items": {
			"whiskey_bottle": 1
		}
	}
]


func _ready() -> void:
	load_customer(current_customer_index)


func load_customer(index: int) -> void:
	if index >= customers.size():
		dialogue_label.text = "No more customers for now."
		customer_sprite.visible = false
		order_manager.clear_current_order()
		return

	var customer := customers[index]

	customer_sprite.visible = true
	customer_sprite.animation = "customers"
	customer_sprite.stop()
	customer_sprite.frame = customer.get("sprite_frame", 0)

	dialogue_label.text = customer["dialogue"]
	order_manager.set_current_order(customer)

	print("Loaded customer:", customer["name"])
	print("Sprite frame:", customer_sprite.frame)


func next_customer() -> void:
	current_customer_index += 1

	if current_customer_index >= customers.size():
		current_customer_index = 0

	load_customer(current_customer_index)
