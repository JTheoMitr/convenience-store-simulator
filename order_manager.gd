extends Node

@export var selected_items_label: Label
@export var result_label: Label
@export var customer_manager: Node
@export var current_total_label: Label
@export var money_given_label: Label
@export var change_input: LineEdit

@export var register_monitor: Control

var current_order: Dictionary = {}
var selected_wall_items: Dictionary = {}
var selected_scanned_items: Dictionary = {}
var gas_amount: float = 0.0

var item_names: Dictionary = {
	"reds": "Reds",
	"blues": "Blues",
	"chapmans": "Chapmans",
	"manchesters": "Manchesters",
	"mega_money": "Mega Money",
	"king_diamond": "King of Diamonds",
	"cash_fever": "Cash Fever",
	"jackpot": "Jackpot",
	"whiskey_bottle": "Whiskey Bottle",
	"croky_chips": "Croky Chips",
	"genshin_energy": "Genshin Energy"
}

var item_prices: Dictionary = {
	"reds": 8.50,
	"blues": 8.25,
	"chapmans": 8.75,
	"manchesters": 8.75,
	"mega_money": 5.00,
	"king_diamond": 10.00,
	"cash_fever": 8.00,
	"jackpot": 7.50,
	"whiskey_bottle": 18.99,
	"croky_chips": 2.99,
	"genshin_energy": 1.99
}

func set_current_order(order: Dictionary) -> void:
	current_order = order
	selected_wall_items.clear()
	selected_scanned_items.clear()
	gas_amount = 0.0
	
	update_selected_items_label()
	update_register_labels()
	result_label.text = ""
	change_input.text = ""
	
	

func clear_current_order() -> void:
	current_order.clear()
	selected_wall_items.clear()
	selected_scanned_items.clear()
	gas_amount = 0.0
	
	update_selected_items_label()
	update_register_labels()
	result_label.text = ""
	change_input.text = ""
	


func add_wall_item(item_id: String) -> void:
	if selected_wall_items.has(item_id):
		selected_wall_items[item_id] += 1
	else:
		selected_wall_items[item_id] = 1

	update_selected_items_label()
	update_register_labels()

	print("Selected wall items:", selected_wall_items)


func update_selected_items_label() -> void:
	var selected_items: Dictionary = get_selected_all_items()
	var parts: Array[String] = []

	for item_id in selected_items.keys():
		var count: int = selected_items[item_id]
		parts.append("%s x%d" % [format_item_name(item_id), count])

	if gas_amount > 0.0:
		parts.append("Gas $%.2f" % gas_amount)

	if parts.is_empty():
		selected_items_label.text = "Selected: none"
	else:
		selected_items_label.text = "Selected: " + ", ".join(parts)

func checkout() -> void:
	if current_order.is_empty():
		result_label.text = "No active customer."
		return

	var expected_items := get_expected_all_items()
	var selected_items := get_selected_all_items()
	var items_correct := dictionaries_match(expected_items, selected_items)
	var gas_correct: bool = is_gas_correct()
	var typed_change_text := change_input.text.strip_edges()

	if typed_change_text == "":
		result_label.text = "Enter the customer's change."
		return

	var player_change := float(typed_change_text)
	var expected_change := get_expected_change()

	var change_correct := is_equal_approx(player_change, expected_change)

	if items_correct and gas_correct and change_correct:
		result_label.text = "Perfect sale! Correct items, gas, and change."
		await get_tree().create_timer(1.5).timeout
		customer_manager.next_customer()

	elif !items_correct:
		result_label.text = build_wrong_order_message(expected_items, selected_items)

		if !gas_correct:
			result_label.text += "\nExpected gas: $%.2f" % get_expected_gas_amount()
			result_label.text += "\nYou entered: $%.2f" % gas_amount

		if !change_correct:
			result_label.text += "\nExpected change: $%.2f" % expected_change

	elif !gas_correct:
		result_label.text = "Wrong gas amount!"
		result_label.text += "\nExpected: $%.2f" % get_expected_gas_amount()
		result_label.text += "\nYou entered: $%.2f" % gas_amount

		if !change_correct:
			result_label.text += "\nExpected change: $%.2f" % expected_change

	else:
		result_label.text = "Wrong change!\nExpected: $%.2f\nYou entered: $%.2f" % [
			expected_change,
			player_change
		]
		
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
		"chapmans":
			return "Chapmans"
		"manchesters":
			return "Manchesters"
		"mega_money":
			return "Mega Money"
		"king_diamond":
			return "King of Diamonds"
		"cash_fever":
			return "Cash Fever"
		"jackpot":
			return "Jackpot"
		"whiskey_bottle":
			return "Whiskey Bottle"
		"croky_chips":
			return "Croky Chips"
		"genshin_energy":
			return "Genshin Energy"
		_:
			return item_id

func calculate_total(items: Dictionary) -> float:
	var total := 0.0

	for item_id in items.keys():
		var count: int = items[item_id]
		var price: float = item_prices.get(item_id, 0.0)
		total += price * count

	return total


func get_money_given() -> float:
	return float(current_order.get("money_given", 0.0))

func get_expected_gas_amount() -> float:
	return float(current_order.get("gas_amount", 0.0))


func is_gas_correct() -> bool:
	return is_equal_approx(gas_amount, get_expected_gas_amount())
	
	
func get_expected_change() -> float:
	var expected_items: Dictionary = get_expected_all_items()
	var item_total: float = calculate_total(expected_items)
	var expected_gas: float = get_expected_gas_amount()
	var money_given: float = get_money_given()

	return snapped(money_given - item_total - expected_gas, 0.01)


func update_register_labels() -> void:
	if current_order.is_empty():
		current_total_label.text = "Total: $0.00"
		money_given_label.text = "Customer paid: $0.00"
		return

	var selected_items := get_selected_all_items()
	var total := calculate_total(selected_items) + gas_amount
	var money_given := get_money_given()
	

	current_total_label.text = "Total: $%.2f" % total
	money_given_label.text = "Customer paid: $%.2f" % money_given
	var display_prices := item_prices.duplicate()
	var display_names := item_names.duplicate()

	if register_monitor != null:
		if gas_amount > 0.0:
			display_prices["gas"] = gas_amount
			display_names["gas"] = "Gas"

			register_monitor.update_sale(
				get_selected_items_for_display(),
				display_prices,
				display_names
			)
		else:
			register_monitor.update_sale(
				get_selected_all_items(),
				item_prices,
				item_names
			)
	#if register_monitor != null:
		#register_monitor.update_sale(
			#get_selected_all_items(),
			#item_prices,
			#item_names
		#)

func clear_selected_wall_items() -> void:
	selected_wall_items.clear()
	update_selected_items_label()
	update_register_labels()
	result_label.text = ""

func add_scanned_item(item_id: String) -> void:
	if selected_scanned_items.has(item_id):
		selected_scanned_items[item_id] += 1
	else:
		selected_scanned_items[item_id] = 1

	update_register_labels()

	print("Scanned item:", item_id)
	print("Scanned items:", selected_scanned_items)
	
func get_expected_all_items() -> Dictionary:
	var combined_items: Dictionary = {}

	merge_item_dictionary(combined_items, current_order.get("wall_items", {}))
	merge_item_dictionary(combined_items, current_order.get("counter_items", {}))

	return combined_items


func get_selected_all_items() -> Dictionary:
	var combined_items: Dictionary = {}

	merge_item_dictionary(combined_items, selected_wall_items)
	merge_item_dictionary(combined_items, selected_scanned_items)

	return combined_items


func merge_item_dictionary(target: Dictionary, source: Dictionary) -> void:
	for item_id in source.keys():
		if target.has(item_id):
			target[item_id] += source[item_id]
		else:
			target[item_id] = source[item_id]
			
			
func add_gas_amount(amount: float) -> void:
	gas_amount = amount
	update_selected_items_label()
	update_register_labels()
	
func get_selected_items_for_display() -> Dictionary:
	var display_items := get_selected_all_items()

	if gas_amount > 0.0:
		display_items["gas"] = 1

	return display_items
