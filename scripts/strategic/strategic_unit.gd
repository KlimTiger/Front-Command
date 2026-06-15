class_name StrategicUnit
extends RefCounted

enum MovementState {
	IDLE,
	MOVING
}

enum Faction {
	SOVIET,
	GERMAN
}

var id: String = ""
var command_unit = null
var faction: Faction = Faction.SOVIET
var position: Vector2i = Vector2i.ZERO
var destination: Vector2i = Vector2i.ZERO
var movement_state: MovementState = MovementState.IDLE
var movement_points: float = 0.0
var base_speed: float = 1.0

static func create(
	new_command_unit,
	new_faction: Faction,
	new_position: Vector2i,
	new_base_speed: float = 1.0
) -> StrategicUnit:
	var unit := StrategicUnit.new()
	unit.command_unit = new_command_unit
	unit.id = new_command_unit.id if new_command_unit != null else _make_id("strategic_unit")
	unit.faction = new_faction
	unit.position = new_position
	unit.destination = new_position
	unit.base_speed = max(new_base_speed, 0.1)
	return unit

func set_destination(new_destination: Vector2i) -> void:
	destination = new_destination
	if destination != position:
		movement_state = MovementState.MOVING
	else:
		movement_state = MovementState.IDLE

func is_moving() -> bool:
	return movement_state == MovementState.MOVING

func describe() -> String:
	return "%s faction=%s pos=%s dest=%s state=%s speed=%.1f" % [
		id,
		faction_to_string(faction),
		str(position),
		str(destination),
		movement_state_to_string(movement_state),
		base_speed
	]

static func faction_to_string(value: Faction) -> String:
	match value:
		Faction.SOVIET:
			return "SOVIET"
		Faction.GERMAN:
			return "GERMAN"
		_:
			return "UNKNOWN"

static func movement_state_to_string(value: MovementState) -> String:
	match value:
		MovementState.IDLE:
			return "IDLE"
		MovementState.MOVING:
			return "MOVING"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]
