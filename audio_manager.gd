extends Node

@export var ui_click_sound: AudioStream
@export var ui_select_sound: AudioStream
@export var scan_sound: AudioStream
@export var bag_rustle_sound: AudioStream
@export var pinpad_sound: AudioStream
@export var error_sound: AudioStream
@export var bottle_grab_sound: AudioStream

@onready var ui_button_player: AudioStreamPlayer = $UIButtonPlayer
@onready var ui_select_player: AudioStreamPlayer = $UISelectPlayer
@onready var scanner_player: AudioStreamPlayer = $ScannerPlayer
@onready var bag_rustle_player: AudioStreamPlayer = $BagRustlePlayer
@onready var pinpad_player: AudioStreamPlayer = $PinpadPlayer
@onready var error_player: AudioStreamPlayer = $ErrorPlayer
@onready var bottle_grab_player: AudioStreamPlayer = $BottleGrab


func _ready() -> void:
	ui_button_player.stream = ui_click_sound
	ui_select_player.stream = ui_select_sound
	scanner_player.stream = scan_sound
	bag_rustle_player.stream = bag_rustle_sound
	pinpad_player.stream = pinpad_sound
	error_player.stream = error_sound
	bottle_grab_player.stream = bottle_grab_sound
	print("AudioManager autoload ready")

func play_ui_click() -> void:
	_play_from_start(ui_button_player)
	
func play_ui_select() -> void:
	_play_from_start(ui_select_player)


func play_scan() -> void:
	_play_from_start(scanner_player)


func play_bag_rustle() -> void:
	_play_from_start(bag_rustle_player)


func play_pinpad() -> void:
	_play_from_start(pinpad_player)


func play_error() -> void:
	_play_from_start(error_player)
	
func play_bottle_grab() -> void:
	_play_from_start(bottle_grab_player)


func _play_from_start(player: AudioStreamPlayer) -> void:
	player.stop()
	player.play()
