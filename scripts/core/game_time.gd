class_name GameTime
extends RefCounted

signal tick_advanced(tick_number: int)

var tick_number: int = 0
var seconds_per_tick: float = 60.0
var time_scale: float = 1.0
var paused: bool = false

func set_paused(value: bool) -> void:
	paused = value

func set_time_scale(value: float) -> void:
	time_scale = max(value, 0.0)

func advance_tick() -> int:
	if paused:
		return tick_number
	tick_number += 1
	tick_advanced.emit(tick_number)
	return tick_number

func advance_ticks(count: int) -> void:
	if paused or count <= 0:
		return
	for _i in count:
		advance_tick()

func get_game_minutes() -> float:
	return float(tick_number) * seconds_per_tick / 60.0

func describe() -> String:
	return "tick=%d game_minutes=%.1f scale=%.1fx paused=%s" % [
		tick_number,
		get_game_minutes(),
		time_scale,
		str(paused)
	]
