extends Node

@export var gameplay_scene_path: String = "res://c_store_prototype.tscn"
@export var minimum_screen_time: float = 1.5
@export var transition_duration: float = 0.6

var loading_started_at: int = 0


func _ready() -> void:
	start_loading()


func start_loading() -> void:
	loading_started_at = Time.get_ticks_msec()

	var error := ResourceLoader.load_threaded_request(gameplay_scene_path)

	if error != OK:
		push_error("Could not start loading gameplay scene: " + gameplay_scene_path)
		return


func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(
		gameplay_scene_path,
		progress
	)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		return

	if status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Gameplay scene failed to load.")
		set_process(false)
		return

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return

	set_process(false)

	var elapsed_seconds := (
		Time.get_ticks_msec() - loading_started_at
	) / 1000.0

	var remaining_time := maxf(0.0, minimum_screen_time - elapsed_seconds)

	if remaining_time > 0.0:
		await get_tree().create_timer(remaining_time).timeout

	var gameplay_scene := ResourceLoader.load_threaded_get(
		gameplay_scene_path
	) as PackedScene

	if gameplay_scene == null:
		push_error("Loaded gameplay resource was not a PackedScene.")
		return

	TransitionManager.change_scene(
		gameplay_scene,
		transition_duration,
		transition_duration
	)
