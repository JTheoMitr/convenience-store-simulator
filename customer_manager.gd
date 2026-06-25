extends Node

@export var dialogue_label: Label
@export var order_manager: Node
@export var customer_sprite: AnimatedSprite3D

@export var counter_items_parent: Node3D
@export var whiskey_bottle_scene: PackedScene
@export var croky_chips_scene: PackedScene
@export var spawn_point_1: Marker3D
@export var spawn_point_2: Marker3D
@export var spawn_point_3: Marker3D

@export var camera: Camera3D
@export var station_manager: Node
@export var counter_drag_bounds: Area3D
@export var computer_drag_blocker: Area3D

var current_customer_index: int = 0

var customers: Array[Dictionary] = [
	{
	"name": "Customer 1",
	"dialogue": "Can I get a pack of Reds and a Mega Money?",
	"sprite_frame": 0,
	"money_given": 20.00,
	"wall_items": {
		"reds": 1,
		"mega_money": 1
	},
	"counter_items": {},
	"gas_amount": 0.0
	},
	{
		"name": "Customer 2",
		"dialogue": "Give me two King D's and this whiskey bottle.",
		"sprite_frame": 1,
		"money_given": 50.00,
		"wall_items": {
			"king_diamond": 2
		},
		"counter_items": {
			"whiskey_bottle": 1
		},
		"gas_amount": 0.0
	},
	{
	"name": "Customer 3",
	"dialogue": "Can I get a pack of Reds and fifteen dollars on gas?",
	"sprite_frame": 2,
	"money_given": 30.00,
	"wall_items": {
		"reds": 1
	},
	"counter_items": {},
	"gas_amount": 15.00
	},
	{
	"name": "Customer 4",
	"dialogue": "I'll get these and a pack of Chapmans... and twenty on the pump.",
	"sprite_frame": 3,
	"money_given": 35.00,
	"wall_items": {
		"chapmans": 1
	},
	"counter_items": {
		"croky_chips": 1
	},
	"gas_amount": 20.00
	}
]


func _ready() -> void:
	load_customer(current_customer_index)


func load_customer(index: int) -> void:
	if index >= customers.size():
		dialogue_label.text = "No more customers for now."
		customer_sprite.visible = false
		order_manager.clear_current_order()
		return

	var customer := customers[index]

	customer_sprite.visible = true
	customer_sprite.animation = "customers"
	customer_sprite.stop()
	customer_sprite.frame = customer.get("sprite_frame", 0)

	dialogue_label.text = customer["dialogue"]
	order_manager.set_current_order(customer)
	
	update_counter_items(customer)

	print("Loaded customer:", customer["name"])
	print("Sprite frame:", customer_sprite.frame)


func next_customer() -> void:
	current_customer_index += 1

	if current_customer_index >= customers.size():
		current_customer_index = 0

	load_customer(current_customer_index)
	
func update_counter_items(customer: Dictionary) -> void:
	clear_counter_items()

	var counter_items: Dictionary = customer.get("counter_items", {})
	var spawn_points: Array[Marker3D] = [
		spawn_point_1,
		spawn_point_2,
		spawn_point_3
	]
	print("Updating counter items for: ", customer.get("name", "Unknown"))
	print("Counter item order: ", customer.get("counter_items", {}))

	var spawn_index: int = 0

	for item_id in counter_items.keys():
		var quantity: int = int(counter_items[item_id])

		for item_number in range(quantity):
			if spawn_index >= spawn_points.size():
				push_warning("Too many counter items for available spawn points.")
				return
			print("Spawning item: ", item_id, " at slot ", spawn_index)
			spawn_counter_item(item_id, spawn_points[spawn_index])
			spawn_index += 1
			
func clear_counter_items() -> void:
	for child in counter_items_parent.get_children():
		child.queue_free()
		
func spawn_counter_item(item_id: String, spawn_point: Marker3D) -> void:
	var item_scene: PackedScene
	
	

	match item_id:
		"whiskey_bottle":
			item_scene = whiskey_bottle_scene
		"croky_chips":
			item_scene = croky_chips_scene
		_:
			push_warning("No counter item scene registered for: " + item_id)
			return

	var item_instance := item_scene.instantiate() as Area3D
	
	if item_instance.has_method("setup"):
		item_instance.setup(
			camera,
			station_manager,
			counter_drag_bounds,
			computer_drag_blocker
		)

	if item_instance == null:
		push_warning("Counter item scene root must be an Area3D.")
		return

	counter_items_parent.add_child(item_instance)
	print("Spawned ", item_id, " as child of ", counter_items_parent.name)
	print("Spawn position: ", spawn_point.global_position)

	if item_instance.has_method("set_spawn_transform"):
		item_instance.set_spawn_transform(
			spawn_point.global_position,
			spawn_point.global_rotation
		)
	else:
		item_instance.global_position = spawn_point.global_position
		item_instance.global_rotation = spawn_point.global_rotation
