class_name MovementSystem
extends RefCounted

const EventLogScript = preload("res://scripts/core/event_log.gd")

func process_tick(cell_map: CellMap, units: Array) -> void:
	for unit in units:
		if unit == null or not unit.is_moving():
			continue
		if unit.position == unit.destination:
			unit.movement_state = StrategicUnit.MovementState.IDLE
			continue

		unit.movement_points += unit.base_speed
		var next_coords := _next_step(unit.position, unit.destination, cell_map)
		if next_coords == unit.position:
			unit.movement_state = StrategicUnit.MovementState.IDLE
			continue

		var cell := cell_map.get_cell(next_coords)
		if cell == null:
			continue

		if unit.movement_points < float(cell.movement_cost):
			continue

		unit.movement_points -= float(cell.movement_cost)
		_move_unit(cell_map, unit, next_coords)

func _move_unit(cell_map: CellMap, unit, new_coords: Vector2i) -> void:
	var old_coords: Vector2i = unit.position
	cell_map.remove_occupant(old_coords, unit.id)
	unit.position = new_coords
	cell_map.add_occupant(new_coords, unit.id)

	if unit.position == unit.destination:
		unit.movement_state = StrategicUnit.MovementState.IDLE

	EventLogScript.record_global(
		EventLogScript.Type.UNIT_MOVED,
		unit.id,
		"%s moved from %s to %s" % [unit.id, str(old_coords), str(new_coords)],
		{
			"from": {"x": old_coords.x, "y": old_coords.y},
			"to": {"x": new_coords.x, "y": new_coords.y},
			"destination": {"x": unit.destination.x, "y": unit.destination.y}
		}
	)

func _next_step(from_coords: Vector2i, to_coords: Vector2i, cell_map: CellMap) -> Vector2i:
	var diff := to_coords - from_coords
	if diff == Vector2i.ZERO:
		return from_coords

	var primary := Vector2i(signi(diff.x), 0)
	if diff.x == 0:
		primary = Vector2i(0, signi(diff.y))

	var primary_coords := from_coords + primary
	if cell_map.is_in_bounds(primary_coords):
		return primary_coords

	var secondary := Vector2i(0, signi(diff.y))
	if diff.y == 0:
		secondary = Vector2i(signi(diff.x), 0)

	return from_coords + secondary
