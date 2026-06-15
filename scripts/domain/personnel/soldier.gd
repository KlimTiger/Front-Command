class_name Soldier
extends RefCounted

enum Role {
	RIFLEMAN,
	MACHINE_GUNNER,
	SNIPER,
	MORTAR_CREW,
	MEDIC,
	OFFICER
}

var id: String = ""
var display_name: String = ""
var health: float = 1.0
var rounds: int = 60
var fatigue: float = 0.0
var weapon: String = "Mosin-Nagant"
var grenades: int = 1
var role: Role = Role.RIFLEMAN
var accuracy: float = 0.45
var experience: float = 0.0

func _init(
	new_id: String = "",
	new_display_name: String = "Soldier",
	new_role: Role = Role.RIFLEMAN
) -> void:
	id = new_id if not new_id.is_empty() else _make_id("soldier")
	display_name = new_display_name
	role = new_role

func is_alive() -> bool:
	return health > 0.0

func get_role_name() -> String:
	return role_to_string(role)

func describe() -> String:
	return "%s role=%s health=%.2f ammo=%d fatigue=%.2f" % [
		display_name,
		role_to_string(role),
		health,
		rounds,
		fatigue
	]

static func role_to_string(value: Role) -> String:
	match value:
		Role.RIFLEMAN:
			return "RIFLEMAN"
		Role.MACHINE_GUNNER:
			return "MACHINE_GUNNER"
		Role.SNIPER:
			return "SNIPER"
		Role.MORTAR_CREW:
			return "MORTAR_CREW"
		Role.MEDIC:
			return "MEDIC"
		Role.OFFICER:
			return "OFFICER"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]