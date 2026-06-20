extends PanelContainer

@export var item_id: String
@export var item_display_name: String
@export var order_manager: Node
@export var hover_animation: StringName = &"spin"

@onready var item_sprite: AnimatedSprite2D = $MarginContainer/VBoxContainer/PreviewArea/ItemSprite
@onready var item_name_label: Label = $MarginContainer/VBoxContainer/ItemNameLabel
@onready var add_button: Button = $MarginContainer/VBoxContainer/AddButton


func _ready() -> void:
	item_name_label.text = item_display_name
	add_button.text = "Add"

	item_sprite.animation = hover_animation
	item_sprite.stop()
	item_sprite.frame = 0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	add_button.pressed.connect(_on_add_button_pressed)


func _on_mouse_entered() -> void:
	item_sprite.frame = 0
	item_sprite.play(hover_animation)


func _on_mouse_exited() -> void:
	item_sprite.stop()
	item_sprite.frame = 0


func _on_add_button_pressed() -> void:
	if order_manager == null:
		push_warning("WallItemCard has no OrderManager assigned.")
		return

	order_manager.add_wall_item(item_id)
