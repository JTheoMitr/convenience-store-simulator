extends Control

signal change_submitted(change_given: float)
signal drawer_cancelled

@export var drawer_slide_duration: float = 0.18
@export var drawer_start_offset_y: float = -260.0

@onready var drawer_texture: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/DrawerVisualArea/DrawerBackground
@onready var cash_buttons_container: Control = $PanelContainer/MarginContainer/VBoxContainer/DrawerVisualArea/CashButtons

@onready var change_due_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DrawerVisualArea/ChangeDueLabel
@onready var change_given_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DrawerVisualArea/ChangeGivenLabel
@onready var drawer_result_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DrawerVisualArea/DrawerResultLabel

var expected_change: float = 0.0
var change_given: float = 0.0

var drawer_rest_position: Vector2


func _ready() -> void:
	drawer_rest_position = drawer_texture.position
	visible = false


func open_drawer(amount_due: float) -> void:
	expected_change = amount_due
	change_given = 0.0

	change_due_label.text = "CHANGE DUE: $%.2f" % expected_change
	drawer_result_label.text = ""

	update_change_display()

	# Reset drawer above its resting position every time.
	drawer_texture.position = drawer_rest_position + Vector2(0.0, drawer_start_offset_y)

	# Hide all clickable cash until the drawer finishes opening.
	cash_buttons_container.visible = false

	visible = true

	var drawer_tween := create_tween()
	drawer_tween.set_trans(Tween.TRANS_QUAD)
	drawer_tween.set_ease(Tween.EASE_OUT)

	drawer_tween.tween_property(
		drawer_texture,
		"position",
		drawer_rest_position,
		drawer_slide_duration
	)

	await drawer_tween.finished

	# Drawer is fully open; now reveal the bills and coins.
	cash_buttons_container.visible = true


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
		reset_drawer_visuals()
		visible = false
	else:
		drawer_result_label.text = "WRONG CHANGE"
		drawer_result_label.modulate = Color(1.0, 0.3, 0.3, 1.0)
		await get_tree().create_timer(2.0).timeout
		drawer_result_label.text = ""


func cancel_drawer() -> void:
	drawer_cancelled.emit()
	reset_drawer_visuals()
	visible = false


func update_change_display() -> void:
	change_given_label.text = "Current: $%.2f" % change_given

func _on_bill_20_button_pressed() -> void:
	add_money(20.0)
	add_cash_sound("bill")


func _on_bill_10_button_pressed() -> void:
	add_money(10.0)
	add_cash_sound("bill")


func _on_bill_5_button_pressed() -> void:
	add_money(5.0)
	add_cash_sound("bill")


func _on_bill_1_button_pressed() -> void:
	add_money(1.0)
	add_cash_sound("bill")


func _on_quarter_button_pressed() -> void:
	add_money(0.25)
	add_cash_sound("quarter")


func _on_dime_button_pressed() -> void:
	add_money(0.10)
	add_cash_sound("dime")
	

func _on_nickel_button_pressed() -> void:
	add_money(0.05)
	add_cash_sound("nickel")


func _on_penny_button_pressed() -> void:
	add_money(0.01)
	add_cash_sound("penny")


func _on_clear_button_pressed() -> void:
	clear_change()


func _on_submit_change_button_pressed() -> void:
	submit_change()


func _on_cancel_button_pressed() -> void:
	cancel_drawer()
	
	
func add_cash_sound(sound_type: String) -> void:
	#add_money(amount)

	match sound_type:
		"bill":
			AudioManager.play_paper_money_sound()
		"penny":
			AudioManager.play_coin_penny_sound()
		"nickel":
			AudioManager.play_coin_nickel_sound()
		"dime":
			AudioManager.play_coin_dime_sound()
		"quarter":
			AudioManager.play_coin_quarter_sound()


func reset_drawer_visuals() -> void:
	cash_buttons_container.visible = false
	drawer_texture.position = drawer_rest_position + Vector2(0.0, drawer_start_offset_y)
