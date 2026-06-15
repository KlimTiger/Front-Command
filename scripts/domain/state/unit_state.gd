class_name UnitState
extends RefCounted

signal changed(property_name: String, old_value: Variant, new_value: Variant)

var strength: int = 0
var ammo: float = 1.0
var fatigue: float = 0.0
var morale: float = 1.0
var combat_effectiveness: float = 1.0

static func create(
	new_strength: int = 0,
	new_ammo: float = 1.0,
	new_fatigue: float = 0.0,
	new_morale: float = 1.0,
	new_combat_effectiveness: float = 1.0
):
	var state = load("res://scripts/domain/state/unit_state.gd").new()
	state.strength = max(new_strength, 0)
	state.ammo = clampf(new_ammo, 0.0, 1.0)
	state.fatigue = clampf(new_fatigue, 0.0, 1.0)
	state.morale = clampf(new_morale, 0.0, 1.0)
	state.combat_effectiveness = clampf(new_combat_effectiveness, 0.0, 1.0)
	return state

func set_strength(value: int) -> void:
	var old_value := strength
	strength = max(value, 0)
	_emit_if_changed("strength", old_value, strength)
	_recalculate_combat_effectiveness()

func apply_losses(losses: int) -> void:
	set_strength(strength - max(losses, 0))

func set_ammo(value: float) -> void:
	var old_value := ammo
	ammo = clampf(value, 0.0, 1.0)
	_emit_if_changed("ammo", old_value, ammo)
	_recalculate_combat_effectiveness()

func set_fatigue(value: float) -> void:
	var old_value := fatigue
	fatigue = clampf(value, 0.0, 1.0)
	_emit_if_changed("fatigue", old_value, fatigue)
	_recalculate_combat_effectiveness()

func set_morale(value: float) -> void:
	var old_value := morale
	morale = clampf(value, 0.0, 1.0)
	_emit_if_changed("morale", old_value, morale)
	_recalculate_combat_effectiveness()

func is_destroyed() -> bool:
	return strength <= 0 or combat_effectiveness <= 0.0

func duplicate_state():
	return load("res://scripts/domain/state/unit_state.gd").create(strength, ammo, fatigue, morale, combat_effectiveness)

func describe() -> String:
	return "strength=%d ammo=%.2f fatigue=%.2f morale=%.2f combat_effectiveness=%.2f" % [
		strength,
		ammo,
		fatigue,
		morale,
		combat_effectiveness
	]

func _recalculate_combat_effectiveness() -> void:
	var old_value := combat_effectiveness
	combat_effectiveness = clampf(ammo * morale * (1.0 - fatigue), 0.0, 1.0)
	_emit_if_changed("combat_effectiveness", old_value, combat_effectiveness)

func _emit_if_changed(property_name: String, old_value: Variant, new_value: Variant) -> void:
	if old_value == new_value:
		return
	emit_signal("changed", property_name, old_value, new_value)