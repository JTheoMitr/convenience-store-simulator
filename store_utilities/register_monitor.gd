extends Control

@onready var item_list_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemListLabel
@onready var status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/StatusLabel
@onready var total_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TotalLabel


func update_sale(items: Dictionary, item_prices: Dictionary, item_names: Dictionary) -> void:
	var item_count := 0
	var total := 0.0
	var lines: Array[String] = []

	for item_id in items.keys():
		var quantity: int = items[item_id]
		var price: float = item_prices.get(item_id, 0.0)
		var display_name: String = item_names.get(item_id, item_id)

		var line_total := price * quantity

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
