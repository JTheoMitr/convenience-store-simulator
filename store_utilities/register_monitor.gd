extends Control

@onready var item_list_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemListLabel
@onready var status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/StatusLabel
@onready var total_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TotalLabel
	
var is_initialized: bool = false
var pending_items: Dictionary = {}
var pending_prices: Dictionary = {}
var pending_names: Dictionary = {}


func _ready() -> void:
	is_initialized = true

	if !pending_items.is_empty() or !pending_prices.is_empty() or !pending_names.is_empty():
		update_sale(pending_items, pending_prices, pending_names)
	
		
func update_sale(items: Dictionary, item_prices: Dictionary, item_names: Dictionary) -> void:
	if !is_initialized:
		pending_items = items.duplicate()
		pending_prices = item_prices.duplicate()
		pending_names = item_names.duplicate()
		return

	var item_count: int = 0
	var total: float = 0.0
	var lines: Array[String] = []

	for item_id in items.keys():
		var quantity: int = items[item_id]
		var price: float = item_prices.get(item_id, 0.0)
		var display_name: String = item_names.get(item_id, item_id)

		var line_total: float = price * quantity

		total += line_total
		item_count += quantity

		lines.append("%s x%d    $%.2f" % [
			display_name,
			quantity,
			line_total
		])

	if lines.is_empty():
		item_list_label.text = "No items scanned."
	else:
		item_list_label.text = "\n".join(lines)

	status_label.text = "ITEMS: %d" % item_count
	total_label.text = "TOTAL: $%.2f" % total
