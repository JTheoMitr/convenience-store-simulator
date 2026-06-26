extends Node

signal time_changed(formatted_time: String)
signal shift_ended()

signal daily_sales_changed(total_sales: float)

var daily_sales_total: float = 0.0
var completed_sales_count: int = 0

@export var opening_hour: int = 9
@export var closing_hour: int = 20

# One real second equals one in-game minute for now.
@export var real_seconds_per_game_minute: float = 1.0

var current_day: int = 1
var current_minutes: float = 0.0
var shift_is_active: bool = true


func _ready() -> void:
	current_minutes = opening_hour * 60
	emit_current_time()


func _process(delta: float) -> void:
	if !shift_is_active:
		return

	current_minutes += delta / real_seconds_per_game_minute

	if current_minutes >= closing_hour * 60:
		current_minutes = closing_hour * 60
		emit_current_time()
		end_shift()
		return

	emit_current_time()


func emit_current_time() -> void:
	time_changed.emit(get_formatted_time())
	#print(get_formatted_time())


func get_formatted_time() -> String:
	var total_minutes: int = int(current_minutes)

	var hour_24: int = floori(total_minutes / 60.0)
	var minute: int = total_minutes % 60

	var suffix: String = "AM"
	var display_hour: int = hour_24

	if hour_24 >= 12:
		suffix = "PM"

	if hour_24 == 0:
		display_hour = 12
	elif hour_24 > 12:
		display_hour = hour_24 - 12

	return "%d:%02d %s" % [display_hour, minute, suffix]


func end_shift() -> void:
	if !shift_is_active:
		return

	shift_is_active = false
	print("Shift ended — closing time.")
	shift_ended.emit()


func start_new_shift() -> void:
	current_day += 1
	current_minutes = opening_hour * 60
	shift_is_active = true

	reset_daily_sales()

	print("Starting Day ", current_day)
	emit_current_time()


func record_sale(sale_total: float) -> void:
	if sale_total <= 0.0:
		return

	daily_sales_total = snappedf(daily_sales_total + sale_total, 0.01)
	completed_sales_count += 1

	print("Sale recorded: $%.2f | Daily total: $%.2f" % [
		sale_total,
		daily_sales_total
	])

	daily_sales_changed.emit(daily_sales_total)


func reset_daily_sales() -> void:
	daily_sales_total = 0.0
	completed_sales_count = 0
	daily_sales_changed.emit(daily_sales_total)
