class_name Terrain
extends RefCounted

enum Type {
	OPEN,
	FOREST,
	ROAD,
	HILL,
	RIVER,
	VILLAGE
}

static func get_movement_cost(terrain_type: Type) -> int:
	match terrain_type:
		Type.OPEN:
			return 1
		Type.FOREST:
			return 2
		Type.ROAD:
			return 1
		Type.HILL:
			return 2
		Type.RIVER:
			return 3
		Type.VILLAGE:
			return 1
		_:
			return 1

static func get_supply_modifier(terrain_type: Type) -> float:
	match terrain_type:
		Type.OPEN:
			return 1.0
		Type.FOREST:
			return 0.85
		Type.ROAD:
			return 1.15
		Type.HILL:
			return 0.95
		Type.RIVER:
			return 0.70
		Type.VILLAGE:
			return 1.05
		_:
			return 1.0

static func type_to_string(terrain_type: Type) -> String:
	match terrain_type:
		Type.OPEN:
			return "OPEN"
		Type.FOREST:
			return "FOREST"
		Type.ROAD:
			return "ROAD"
		Type.HILL:
			return "HILL"
		Type.RIVER:
			return "RIVER"
		Type.VILLAGE:
			return "VILLAGE"
		_:
			return "UNKNOWN"
