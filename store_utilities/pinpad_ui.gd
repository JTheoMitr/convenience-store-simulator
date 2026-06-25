extends Control

@export var station_manager: Node
@export var order_manager: Node

@onready var amount_label: Label = $AmountLabel

@onready var one_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/OneButton
@onready var two_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/TwoButton
@onready var three_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/ThreeButton
@onready var four_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/FourButton
@onready var five_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/FiveButton
@onready var six_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/SixButton
@onready var seven_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/SevenButton
@onready var eight_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/EightButton
@onready var nine_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/NineButton
@onready var zero_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/ZeroButton
@onready var decimal_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/LeftSide/NumberGrid/DecimalButton

@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/ActionColumn/CancelButton
@onready var backspace_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/ActionColumn/BackspaceButton
@onready var submit_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/ActionColumn/SubmitButton

var entered_amount: String = ""


func _ready() -> void:
	one_button.pressed.connect(func(): add_character("1"))
	two_button.pressed.connect(func(): add_character("2"))
	three_button.pressed.connect(func(): add_character("3"))
	four_button.pressed.connect(func(): add_character("4"))
	five_button.pressed.connect(func(): add_character("5"))
	six_button.pressed.connect(func(): add_character("6"))
	seven_button.pressed.connect(func(): add_character("7"))
	eight_button.pressed.connect(func(): add_character("8"))
	nine_button.pressed.connect(func(): add_character("9"))
	zero_button.pressed.connect(func(): add_character("0"))
	decimal_button.pressed.connect(func(): add_decimal())

	cancel_button.pressed.connect(_on_cancel_pressed)
	backspace_button.pressed.connect(_on_backspace_pressed)
	submit_button.pressed.connect(_on_submit_pressed)

	update_amount_label()


func add_character(character: String) -> void:
	if entered_amount.length() >= 6:
		return

	AudioManager.play_pinpad()
	entered_amount += character
	update_amount_label()


func add_decimal() -> void:
	if entered_amount.contains("."):
		return

	if entered_amount.is_empty():
		entered_amount = "0"

	AudioManager.play_pinpad()
	entered_amount += "."
	update_amount_label()


func _on_backspace_pressed() -> void:
	if entered_amount.is_empty():
		return

	AudioManager.play_pinpad()
	entered_amount = entered_amount.left(entered_amount.length() - 1)
	update_amount_label()


func _on_cancel_pressed() -> void:
	AudioManager.play_pinpad()
	clear_amount()

	if station_manager != null:
		station_manager.go_to_station("register")


func _on_submit_pressed() -> void:
	if entered_amount.is_empty():
		return

	var gas_total: float = entered_amount.to_float()

	if gas_total <= 0.0:
		return

	AudioManager.play_pinpad()

	if order_manager != null:
		order_manager.add_gas_amount(gas_total)

	clear_amount()

	if station_manager != null:
		station_manager.go_to_station("register")


func clear_amount() -> void:
	entered_amount = ""
	update_amount_label()


func update_amount_label() -> void:
	var visible_amount := entered_amount

	if visible_amount.is_empty():
		visible_amount = "0"

	amount_label.text = "$" + visible_amount
