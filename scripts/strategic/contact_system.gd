class_name ContactSystem
extends RefCounted

const BattleContextScript = preload("res://scripts/battle/battle_context.gd")
const EventLogScript = preload("res://scripts/core/event_log.gd")

var contact_radius: int = 0

func check_contacts(units: Array, cell_map: CellMap) -> Array:
	var battles: Array = []
	var processed_pairs: Dictionary = {}

	for i in range(units.size()):
		for j in range(i + 1, units.size()):
			var unit_a = units[i]
			var unit_b = units[j]
			if unit_a == null or unit_b == null:
				continue
			if unit_a.faction == unit_b.faction:
				continue
			if not _units_in_contact(unit_a, unit_b):
				continue

			var pair_key := _pair_key(unit_a.id, unit_b.id)
			if processed_pairs.has(pair_key):
				continue
			processed_pairs[pair_key] = true

			var contact_cell: Vector2i = unit_a.position if unit_a.position == unit_b.position else unit_a.position
			var battle = BattleContextScript.create_from_contact(unit_a, unit_b, contact_cell, cell_map)
			battles.append(battle)

	return battles

func _units_in_contact(unit_a, unit_b) -> bool:
	if contact_radius <= 0:
		return unit_a.position == unit_b.position
	return _chebyshev_distance(unit_a.position, unit_b.position) <= contact_radius

func _chebyshev_distance(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))

func _pair_key(id_a: String, id_b: String) -> String:
	if id_a <= id_b:
		return "%s|%s" % [id_a, id_b]
	return "%s|%s" % [id_b, id_a]
