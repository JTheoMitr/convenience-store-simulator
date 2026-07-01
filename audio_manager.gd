extends Node

@export var ui_click_sound: AudioStream
@export var ui_select_sound: AudioStream
@export var scan_sound: AudioStream
@export var bag_rustle_sound: AudioStream
@export var pinpad_sound: AudioStream
@export var error_sound: AudioStream
@export var bottle_grab_sound: AudioStream
@export var chips_grab_sound: AudioStream
@export var register_checkout_sound: AudioStream
@export var paper_money_sound: AudioStream
@export var coin_quarter_sound: AudioStream
@export var coin_dime_sound: AudioStream
@export var coin_nickel_sound: AudioStream
@export var coin_penny_sound: AudioStream
@export var drawer_close_sound: AudioStream
@export var sale_completed_sound: AudioStream




@onready var ui_button_player: AudioStreamPlayer = $UIButtonPlayer
@onready var ui_select_player: AudioStreamPlayer = $UISelectPlayer
@onready var scanner_player: AudioStreamPlayer = $ScannerPlayer
@onready var bag_rustle_player: AudioStreamPlayer = $BagRustlePlayer
@onready var pinpad_player: AudioStreamPlayer = $PinpadPlayer
@onready var error_player: AudioStreamPlayer = $ErrorPlayer
@onready var bottle_grab_player: AudioStreamPlayer = $BottleGrab
@onready var chips_grab_player: AudioStreamPlayer = $ChipsGrab
@onready var register_checkout_player: AudioStreamPlayer = $RegisterPlayer
@onready var paper_money_player: AudioStreamPlayer = $PaperMoneyPlayer
@onready var coin_quarter_player: AudioStreamPlayer = $CoinQuarterPlayer
@onready var coin_dime_player: AudioStreamPlayer = $CoinDimePlayer
@onready var coin_nickel_player: AudioStreamPlayer = $CoinNickelPlayer
@onready var coin_penny_player: AudioStreamPlayer = $CoinPennyPlayer
@onready var drawer_close_player: AudioStreamPlayer = $DrawerClosePlayer
@onready var sale_completed_player: AudioStreamPlayer = $SaleCompletedPlayer


func _ready() -> void:
	ui_button_player.stream = ui_click_sound
	ui_select_player.stream = ui_select_sound
	scanner_player.stream = scan_sound
	bag_rustle_player.stream = bag_rustle_sound
	pinpad_player.stream = pinpad_sound
	error_player.stream = error_sound
	register_checkout_player.stream = register_checkout_sound
	paper_money_player.stream = paper_money_sound
	bottle_grab_player.stream = bottle_grab_sound
	chips_grab_player.stream = chips_grab_sound
	drawer_close_player.stream = drawer_close_sound
	sale_completed_player.stream = sale_completed_sound
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
	
func play_chips_grab() -> void:
	_play_from_start(chips_grab_player)
	
func play_register_checkout_sound() -> void:
	_play_from_start(register_checkout_player)
	
func play_paper_money_sound() -> void:
	_play_from_start(paper_money_player)
	
func play_coin_quarter_sound() -> void:
	_play_from_start(coin_quarter_player)
	
func play_coin_dime_sound() -> void:
	_play_from_start(coin_dime_player)
	
func play_coin_nickel_sound() -> void:
	_play_from_start(coin_nickel_player)
	
func play_coin_penny_sound() -> void:
	_play_from_start(coin_penny_player)
	
func play_drawer_close_sound() -> void:
	_play_from_start(drawer_close_player)
	
func play_sale_completed_sound() -> void:
	_play_from_start(sale_completed_player)


func _play_from_start(player: AudioStreamPlayer) -> void:
	player.stop()
	player.play()
