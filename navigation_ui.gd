extends Control

@export var station_manager: Node

@onready var counter_button: Button = $HBoxContainer/CounterButton
@onready var register_button: Button = $HBoxContainer/RegisterButton
@onready var wall_button: Button = $HBoxContainer/WallButton


func _ready() -> void:
	counter_button.pressed.connect(_on_counter_pressed)
	register_button.pressed.connect(_on_register_pressed)
	wall_button.pressed.connect(_on_wall_pressed)


func _on_counter_pressed() -> void:
	AudioManager.play_ui_click()
	station_manager.go_to_station("counter")


func _on_register_pressed() -> void:
	AudioManager.play_ui_click()
	station_manager.go_to_station("register")


func _on_wall_pressed() -> void:
	AudioManager.play_ui_click()
	station_manager.go_to_station("wall")
	#station_manager.go_to_station("pinpad")
