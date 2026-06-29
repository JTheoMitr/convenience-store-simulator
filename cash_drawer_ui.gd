extends Control

signal change_submitted(change_given: float)
signal drawer_cancelled

@onready var change_due_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ChangeDueLabel
@onready var change_given_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ChangeGivenLabel
@onready var drawer_result_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DrawerResultLabel

var expected_change: float = 0.0
var change_given: float = 0.0


func _ready() -> void:
	visible = false


func open_drawer(amount_due: float) -> void:
	expected_change = amount_due
	change_given = 0.0

	change_due_label.text = "CHANGE DUE: $%.2f" % expected_change
	drawer_result_label.text = ""

	update_change_display()

	visible = true


func add_money(amount: float) -> void:
	change_given = snappedf(change_given + amount, 0.01)
	update_change_display()


func clear_change() -> void:
	change_given = 0.0
	drawer_result_label.text = ""
	update_change_display()


func submit_change() -> void:
	if is_equal_approx(change_given, expected_change):
		change_submitted.emit(change_given)
		visible = false
	else:
		drawer_result_label.text = "WRONG CHANGE"
		drawer_result_label.modulate = Color(1.0, 0.3, 0.3, 1.0)


func cancel_drawer() -> void:
	drawer_cancelled.emit()
	visible = false


func update_change_display() -> void:
	change_given_label.text = "CHANGE GIVEN: $%.2f" % change_given

func _on_bill_20_button_pressed() -> void:
	add_money(20.0)


func _on_bill_10_button_pressed() -> void:
	add_money(10.0)


func _on_bill_5_button_pressed() -> void:
	add_money(5.0)


func _on_bill_1_button_pressed() -> void:
	add_money(1.0)


func _on_quarter_button_pressed() -> void:
	add_money(0.25)


func _on_dime_button_pressed() -> void:
	add_money(0.10)
	

func _on_nickel_button_pressed() -> void:
	add_money(0.05)


func _on_penny_button_pressed() -> void:
	add_money(0.01)


func _on_clear_button_pressed() -> void:
	clear_change()


func _on_submit_change_button_pressed() -> void:
	submit_change()


func _on_cancel_button_pressed() -> void:
	cancel_drawer()
