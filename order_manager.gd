extends Node

@export var selected_items_label: Label
@export var result_label: Label
@export var customer_manager: Node
@export var current_total_label: Label
@export var money_given_label: Label
@export var change_input: LineEdit
@export var day_manager: Node
@export var sale_result_popup: Control

@export var register_monitor: Control

@export var payment_label: Label
@export var change_due_label: Label

@export var cash_drawer_ui: Control
@export var make_change_button: Button

var cash_change_confirmed: bool = false

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
	
	cash_change_confirmed = is_card_payment()
	
	if make_change_button != null:
		make_change_button.text = "Open Drawer"
	
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
		parts.append("%s (%d)" % [format_item_name(item_id), count])

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
	#removed the bottom change input for the cash minigame
	#var typed_change_text := change_input.text.strip_edges()
#
	#if typed_change_text == "":
		#result_label.text = "Enter the customer's change."
		#return
#
	#var player_change := float(typed_change_text)
	#var expected_change := get_expected_change()
#
	#var change_correct := is_equal_approx(player_change, expected_change)

	if items_correct and gas_correct and cash_change_confirmed: # and change_correct:
		var completed_sale_total: float = calculate_total(get_selected_all_items()) + gas_amount

		if day_manager != null:
			day_manager.record_sale(completed_sale_total)

		var ending_mood: float = 100.0

		if customer_manager != null:
			ending_mood = customer_manager.stop_customer_mood()

		if sale_result_popup != null:
			sale_result_popup.show_sale_completed(
				completed_sale_total,
				ending_mood,
				50
			)

		result_label.text = "Perfect sale! Correct items, gas, and change."

		await get_tree().create_timer(1.5).timeout

		if customer_manager != null:
			customer_manager.next_customer()

	elif !items_correct:
		result_label.text = build_wrong_order_message(expected_items, selected_items)

		if !gas_correct:
			result_label.text += "\nExpected gas: $%.2f" % get_expected_gas_amount()
			result_label.text += "\nYou entered: $%.2f" % gas_amount

		#if !change_correct:
			#result_label.text += "\nExpected change: $%.2f" % expected_change

	elif !gas_correct:
		result_label.text = "Wrong gas amount!"
		result_label.text += "\nExpected: $%.2f" % get_expected_gas_amount()
		result_label.text += "\nYou entered: $%.2f" % gas_amount

		#if !change_correct:
			#result_label.text += "\nExpected change: $%.2f" % expected_change
	elif !cash_change_confirmed:
		result_label.text = "Make the customer's change first."
		return
	#else:
		#result_label.text = "Wrong change!\nExpected: $%.2f\nYou entered: $%.2f" % [
			#expected_change,
			#player_change
		#]
		
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
	AudioManager.play_error()

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
	if is_card_payment():
		return 0.0

	var sale_total: float = calculate_total(get_selected_all_items()) + gas_amount
	return snappedf(get_money_given() - sale_total, 0.01)


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
	update_payment_details()
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

func get_payment_type() -> String:
	return str(current_order.get("payment_type", "cash"))


func is_card_payment() -> bool:
	return get_payment_type() == "card"

func update_payment_details() -> void:
	if payment_label == null or change_due_label == null:
		return
		
	if make_change_button != null:
		#make_change_button.visible = !is_card_payment()
		make_change_button.disabled = is_card_payment()

	if is_card_payment():
		payment_label.text = "PAID BY CARD"
		change_due_label.visible = false
	else:
		payment_label.text = "CASH PAID: $%.2f" % get_money_given()
		change_due_label.text = "CHANGE DUE: $%.2f" % maxf(get_expected_change(), 0.0)
		change_due_label.visible = true


func open_cash_drawer() -> void:
	if current_order.is_empty():
		return

	if is_card_payment():
		return

	if cash_drawer_ui != null:
		cash_drawer_ui.open_drawer(get_expected_change())
		
		
func confirm_cash_change(change_given: float) -> void:
	if is_equal_approx(change_given, get_expected_change()):
		cash_change_confirmed = true
		result_label.text = "Change ready."

		if make_change_button != null:
			make_change_button.disabled = true
			make_change_button.text = "CHANGE READY"
	else:
		cash_change_confirmed = false
		
		
func _ready() -> void:
	if cash_drawer_ui != null and cash_drawer_ui.has_signal("change_submitted"):
		cash_drawer_ui.change_submitted.connect(confirm_cash_change)

func should_show_make_change_button() -> bool:
	return !current_order.is_empty() and !is_card_payment()
