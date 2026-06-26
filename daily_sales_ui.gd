extends Control

@export var day_manager: Node

@onready var sales_label: Label = $PanelContainer/MarginContainer/SalesLabel


func _ready() -> void:
	if day_manager == null:
		push_warning("DailySalesUI has no DayManager assigned.")
		return

	day_manager.daily_sales_changed.connect(_on_daily_sales_changed)

	# Populate immediately at startup.
	_on_daily_sales_changed(day_manager.daily_sales_total)


func _on_daily_sales_changed(total_sales: float) -> void:
	sales_label.text = "TODAY: $%.2f" % total_sales
