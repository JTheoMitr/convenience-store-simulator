extends Control

@export var customer_manager: Node

@onready var mood_face: AnimatedSprite2D = $PanelContainer/MarginContainer/HBoxContainer/MoodFace
@onready var mood_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MoodLabel
@onready var mood_bar: ProgressBar = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/MoodBar


func _ready() -> void:
	if customer_manager == null:
		push_warning("CustomerMoodUI has no CustomerManager assigned.")
		return

	customer_manager.customer_mood_changed.connect(_on_customer_mood_changed)

	visible = true
	_on_customer_mood_changed(customer_manager.current_customer_mood)


func _on_customer_mood_changed(mood: float) -> void:
	mood_bar.value = mood
	mood_label.text = "MOOD: %d%%" % roundi(mood)

	if mood >= 80.0:
		mood_face.frame = 0
	elif mood >= 60.0:
		mood_face.frame = 1
	elif mood >= 40.0:
		mood_face.frame = 2
	elif mood >= 20.0:
		mood_face.frame = 3
	else:
		mood_face.frame = 4
