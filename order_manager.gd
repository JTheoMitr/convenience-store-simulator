extends Node

@export var selected_items_label: Label
@export var result_label: Label
@export var customer_manager: Node

var current_order: Dictionary = {}
var selected_wall_items: Dictionary = {}


func set_current_order(order: Dictionary) -> void:
	current_order = order
	selected_wall_items.clear()
	update_selected_items_label()	
	result_label.text = "test"


func clear_current_order() -> void:
	current_order.clear()
	selected_wall_items.clear()
	update_selected_items_label()
	result_label.text = ""


func add_wall_item(item_id: String) -> void:
	if selected_wall_items.has(item_id):
		selected_wall_items[item_id] += 1
	else:
		selected_wall_items[item_id] = 1

	update_selected_items_label()
	print("Selected wall items:", selected_wall_items)


func update_selected_items_label() -> void:
	if selected_wall_items.is_empty():
		selected_items_label.text = "Selected: none"
		return

	var parts: Array[String] = []

	for item_id in selected_wall_items.keys():
		var count: int = selected_wall_items[item_id]
		parts.append("%s x%d" % [format_item_name(item_id), count])

	selected_items_label.text = "Selected: " + ", ".join(parts)


func checkout() -> void:
	if current_order.is_empty():
		result_label.text = "No active customer."
		return

	var expected_items: Dictionary = current_order.get("wall_items", {})

	if dictionaries_match(expected_items, selected_wall_items):
		result_label.text = "Perfect sale! Customer is happy."
		await get_tree().create_timer(1.5).timeout
		customer_manager.next_customer()
	else:
		result_label.text = build_wrong_order_message(expected_items, selected_wall_items)

func dictionaries_match(expected: Dictionary, actual: Dictionary) -> bool:
	if expected.size() != actual.size():
		return false

	for key in expected.keys():
		if !actual.has(key):
			return false

		if actual[key] != expected[key]:
			return false

	return true


func build_wrong_order_message(expected: Dictionary, actual: Dictionary) -> String:
	var message := "Wrong order!\n"

	message += "Expected: " + dictionary_to_readable_text(expected) + "\n"
	message += "You selected: " + dictionary_to_readable_text(actual)

	return message


func dictionary_to_readable_text(dict: Dictionary) -> String:
	if dict.is_empty():
		return "nothing"

	var parts: Array[String] = []

	for item_id in dict.keys():
		parts.append("%s x%d" % [format_item_name(item_id), dict[item_id]])

	return ", ".join(parts)


func format_item_name(item_id: String) -> String:
	match item_id:
		"reds":
			return "Reds"
		"blues":
			return "Blues"
		"holiday":
			return "Holiday"
		"lucky_duck":
			return "Lucky Duck"
		_:
			return item_id
