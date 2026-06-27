extends Control

@onready var result_title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ResultTitleLabel
@onready var sale_total_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SaleTotalLabel
@onready var mood_label: Label = $PanelContainer/MarginContainer/VBoxContainer/MoodLabel
@onready var xp_label: Label = $PanelContainer/MarginContainer/VBoxContainer/XPLabel

var show_duration: float = 4.0
var popup_version: int = 0


func _ready() -> void:
	visible = false


func show_sale_completed(
	sale_total: float,
	ending_mood: float,
	xp_earned: int = 50
) -> void:
	popup_version += 1
	var this_popup_version: int = popup_version
	print("SALE-RESULT-NOW")

	result_title_label.text = "SALE COMPLETED"
	sale_total_label.text = "TOTAL: $%.2f" % sale_total
	mood_label.text = "CUSTOMER MOOD: %d%%" % roundi(ending_mood)
	xp_label.text = "+%d XP" % xp_earned

	visible = true
	modulate.a = 0.0

	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.18)

	await get_tree().create_timer(show_duration).timeout

	if this_popup_version != popup_version:
		return

	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.25)

	await fade_out.finished

	if this_popup_version == popup_version:
		visible = false
