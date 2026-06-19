extends Node

@export var dialogue_label: Label
@export var order_manager: Node

var current_customer_index: int = 0

var customers: Array[Dictionary] = [
	{
		"name": "Customer 1",
		"dialogue": "Can I get a pack of Reds and one Holiday scratcher?",
		"wall_items": {
			"reds": 1,
			"holiday": 1
		}
	},
	{
		"name": "Customer 2",
		"dialogue": "Can I get two Lucky Ducks?",
		"wall_items": {
			"lucky_duck": 2
		}
	}
]


func _ready() -> void:
	load_customer(current_customer_index)


func load_customer(index: int) -> void:
	if index >= customers.size():
		dialogue_label.text = "No more customers for now."
		order_manager.clear_current_order()
		return

	var customer := customers[index]

	dialogue_label.text = customer["dialogue"]

	order_manager.set_current_order(customer)

	print("Loaded customer:", customer["name"])
	print("Order:", customer)


func next_customer() -> void:
	current_customer_index += 1

	if current_customer_index >= customers.size():
		current_customer_index = 0

	load_customer(current_customer_index)
