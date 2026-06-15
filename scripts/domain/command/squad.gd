class_name Squad
extends "res://scripts/domain/command/command_unit.gd"

var soldiers: Array = []

func _init(new_id: String = "", new_display_name: String = "Squad", new_commander_name: String = "Squad Leader") -> void:
	super(new_id, new_display_name, Level.SQUAD, new_commander_name)

func add_soldier(soldier) -> void:
	if soldier == null:
		return
	if soldiers.has(soldier):
		return
	soldiers.append(soldier)
	unit_state.strength = soldiers.size()

func remove_soldier(soldier) -> void:
	if soldier == null:
		return
	soldiers.erase(soldier)
	unit_state.strength = soldiers.size()

func get_tree_lines(depth: int = 0) -> Array[String]:
	var lines := super.get_tree_lines(depth)
	var indent := "  ".repeat(depth + 1)
	for soldier in soldiers:
		lines.append("%s* Soldier '%s' role=%s health=%.2f ammo=%d" % [
			indent,
			soldier.display_name,
			soldier.get_role_name(),
			soldier.health,
			soldier.rounds
		])
	return lines