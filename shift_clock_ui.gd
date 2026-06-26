extends Control

@export var day_manager: Node

@onready var time_label: Label = $PanelContainer/MarginContainer/TimeLabel


func _ready() -> void:
	if day_manager == null:
		push_warning("ShiftClockUI has no DayManager assigned.")
		return

	day_manager.time_changed.connect(_on_time_changed)

	# Populate immediately so it does not wait a minute to display.
	time_label.text = "DAY %d — %s" % [
		day_manager.current_day,
		day_manager.get_formatted_time()
	]


func _on_time_changed(formatted_time: String) -> void:
	time_label.text = "DAY %d — %s" % [
		day_manager.current_day,
		formatted_time
	]
