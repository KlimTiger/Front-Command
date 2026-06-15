class_name BattleContext
extends RefCounted

const CommandUnitScript = preload("res://scripts/domain/command/command_unit.gd")
const EventLogScript = preload("res://scripts/domain/events/event_log.gd")

enum Status {
	CREATED,
	TACTICAL_READY,
	RESOLVED,
	APPLIED_TO_STRATEGIC_LAYER,
	CANCELLED
}

var id: String = ""
var strategic_battle_id: String = ""
var tactical_battle_id: String = ""
var attacker_unit_ids: Array[String] = []
var defender_unit_ids: Array[String] = []
var participating_units: Array = []
var status: Status = Status.CREATED
var strategic_snapshot: Dictionary = {}
var tactical_result: Dictionary = {}
var metadata: Dictionary = {}

static func create(
	new_strategic_battle_id: String,
	new_participating_units: Array = [],
	new_metadata: Dictionary = {}
):
	var context = load("res://scripts/domain/battle/battle_context.gd").new()
	context.id = _make_id("battle_context")
	context.strategic_battle_id = new_strategic_battle_id
	context.participating_units = new_participating_units.duplicate()
	context.metadata = new_metadata.duplicate(true)
	context.capture_strategic_snapshot()
	EventLogScript.record_global(
		EventLogScript.Type.BATTLE_CONTEXT_CREATED,
		context.id,
		"Battle context created for strategic battle '%s'" % new_strategic_battle_id,
		{"unit_count": context.participating_units.size()}
	)
	return context

func capture_strategic_snapshot() -> void:
	strategic_snapshot.clear()
	for unit in participating_units:
		strategic_snapshot[unit.id] = {
			"name": unit.display_name,
			"level": CommandUnitScript.level_to_string(unit.level),
			"state": unit.unit_state.describe()
		}

func set_tactical_result(result: Dictionary) -> void:
	tactical_result = result.duplicate(true)
	status = Status.RESOLVED

func describe() -> String:
	return "BattleContext id=%s status=%s units=%d" % [id, status_to_string(status), participating_units.size()]

static func status_to_string(value: Status) -> String:
	match value:
		Status.CREATED:
			return "CREATED"
		Status.TACTICAL_READY:
			return "TACTICAL_READY"
		Status.RESOLVED:
			return "RESOLVED"
		Status.APPLIED_TO_STRATEGIC_LAYER:
			return "APPLIED_TO_STRATEGIC_LAYER"
		Status.CANCELLED:
			return "CANCELLED"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]