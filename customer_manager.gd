extends Node

@export var dialogue_label: Label
@export var order_manager: Node
@export var customers_parent: Node3D
@export var customer_scene: PackedScene
@export var customer_spot: Marker3D

@export var counter_items_parent: Node3D
@export var whiskey_bottle_scene: PackedScene
@export var croky_chips_scene: PackedScene
@export var genshin_energy_scene: PackedScene
@export var spawn_point_1: Marker3D
@export var spawn_point_2: Marker3D
@export var spawn_point_3: Marker3D

@export var camera: Camera3D
@export var station_manager: Node
@export var counter_drag_bounds: Area3D
@export var computer_drag_blocker: Area3D

signal customer_mood_changed(mood: float)
signal customer_mood_finished(mood: float)

@export var mood_loss_per_second: float = 0.5

var current_customer_mood: float = 100.0
var customer_is_active: bool = false

var current_customer_instance: Node3D

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
			"whiskey_bottle": 1,
			"croky_chips": 1,
			"genshin_energy": 1
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
		clear_current_customer()
		order_manager.clear_current_order()
		clear_counter_items()
		return

	var customer: Dictionary = customers[index]

	spawn_customer(customer)
	start_customer_mood()

	dialogue_label.text = customer["dialogue"]
	order_manager.set_current_order(customer)
	update_counter_items(customer)

	print("Loaded customer:", customer["name"])

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
		"genshin_energy":
			item_scene = genshin_energy_scene
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
		
func spawn_customer(customer_data: Dictionary) -> void:
	clear_current_customer()

	if customer_scene == null:
		push_warning("CustomerManager has no Customer Scene assigned.")
		return

	if customers_parent == null:
		push_warning("CustomerManager has no Customers Parent assigned.")
		return

	if customer_spot == null:
		push_warning("CustomerManager has no Customer Spot assigned.")
		return

	current_customer_instance = customer_scene.instantiate() as Node3D

	if current_customer_instance == null:
		push_warning("Customer scene root must be a Node3D.")
		return

	customers_parent.add_child(current_customer_instance)

	current_customer_instance.global_position = customer_spot.global_position
	current_customer_instance.global_rotation = customer_spot.global_rotation

	if current_customer_instance.has_method("setup"):
		current_customer_instance.setup(customer_data)
		
func clear_current_customer() -> void:
	if current_customer_instance != null:
		current_customer_instance.queue_free()
		current_customer_instance = null
		
		
func start_customer_mood() -> void:
	current_customer_mood = randf_range(70.0, 100.0)
	customer_is_active = true
	customer_mood_changed.emit(current_customer_mood)


func stop_customer_mood() -> float:
	customer_is_active = false
	customer_mood_finished.emit(current_customer_mood)
	return current_customer_mood


func _process(delta: float) -> void:
	if !customer_is_active:
		return

	current_customer_mood = maxf(
		0.0,
		current_customer_mood - mood_loss_per_second * delta
	)

	customer_mood_changed.emit(current_customer_mood)	
