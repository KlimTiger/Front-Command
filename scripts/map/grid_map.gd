class_name CellMap
extends RefCounted

var width: int = 0
var height: int = 0
var cells: Dictionary = {}

static func create(map_width: int, map_height: int, default_terrain: Terrain.Type = Terrain.Type.OPEN) -> CellMap:
	var cell_map := CellMap.new()
	cell_map.width = max(map_width, 1)
	cell_map.height = max(map_height, 1)
	for y in cell_map.height:
		for x in cell_map.width:
			var coords := Vector2i(x, y)
			cell_map.cells[coords] = Cell.create(coords, default_terrain)
	return cell_map

func is_in_bounds(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.y >= 0 and coords.x < width and coords.y < height

func get_cell(coords: Vector2i) -> Cell:
	if not is_in_bounds(coords):
		return null
	return cells.get(coords)

func set_terrain(coords: Vector2i, terrain_type: Terrain.Type) -> void:
	var cell := get_cell(coords)
	if cell == null:
		return
	cell.apply_terrain(terrain_type)

func add_occupant(coords: Vector2i, unit_id: String) -> void:
	var cell := get_cell(coords)
	if cell == null:
		return
	cell.add_occupant(unit_id)

func remove_occupant(coords: Vector2i, unit_id: String) -> void:
	var cell := get_cell(coords)
	if cell == null:
		return
	cell.remove_occupant(unit_id)

func get_occupants(coords: Vector2i) -> Array[String]:
	var cell := get_cell(coords)
	if cell == null:
		return []
	return cell.occupancy.duplicate()

func get_neighbors(coords: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var next_coords := coords + offset
		if is_in_bounds(next_coords):
			neighbors.append(next_coords)
	return neighbors

func describe() -> String:
	return "CellMap %dx%d cells=%d" % [width, height, cells.size()]
