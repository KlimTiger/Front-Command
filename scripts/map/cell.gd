class_name Cell
extends RefCounted

var coords: Vector2i = Vector2i.ZERO
var terrain_type: Terrain.Type = Terrain.Type.OPEN
var movement_cost: int = 1
var supply_modifier: float = 1.0
var occupancy: Array[String] = []

static func create(coords: Vector2i, terrain_type: Terrain.Type = Terrain.Type.OPEN) -> Cell:
	var cell := Cell.new()
	cell.coords = coords
	cell.apply_terrain(terrain_type)
	return cell

func apply_terrain(terrain_type: Terrain.Type) -> void:
	self.terrain_type = terrain_type
	movement_cost = Terrain.get_movement_cost(terrain_type)
	supply_modifier = Terrain.get_supply_modifier(terrain_type)

func add_occupant(unit_id: String) -> void:
	if unit_id.is_empty() or occupancy.has(unit_id):
		return
	occupancy.append(unit_id)

func remove_occupant(unit_id: String) -> void:
	occupancy.erase(unit_id)

func has_occupants() -> bool:
	return not occupancy.is_empty()

func describe() -> String:
	return "(%d,%d) terrain=%s cost=%d supply=%.2f occupants=%s" % [
		coords.x,
		coords.y,
		Terrain.type_to_string(terrain_type),
		movement_cost,
		supply_modifier,
		str(occupancy)
	]
