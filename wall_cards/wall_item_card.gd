extends PanelContainer

@export var item_id: String
@export var item_display_name: String
@export var order_manager: Node
@export var hover_animation: StringName = &"spin"

@export var normal_panel_style: StyleBoxFlat
@export var hover_panel_style: StyleBoxFlat

@onready var item_sprite: AnimatedSprite2D = $MarginContainer/VBoxContainer/PreviewArea/ItemSprite
@onready var item_name_label: Label = $MarginContainer/VBoxContainer/ItemNameLabel


func _ready() -> void:
	add_theme_stylebox_override("panel", normal_panel_style)
	item_name_label.text = item_display_name

	item_sprite.animation = hover_animation
	item_sprite.frame = 0
	item_sprite.play(hover_animation)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	add_to_group("clickable_ui")


func _on_mouse_entered() -> void:
	AudioManager.play_ui_select()
	add_theme_stylebox_override("panel", hover_panel_style)
	item_sprite.pause()
	item_sprite.frame = 0


func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", normal_panel_style)
	item_sprite.frame = 0
	item_sprite.play(hover_animation)

	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			add_item()
			accept_event()
			
func add_item() -> void:
	if order_manager == null:
		push_warning("WallItemCard has no OrderManager assigned.")
		return
	
	AudioManager.play_ui_click()
	order_manager.add_wall_item(item_id)
