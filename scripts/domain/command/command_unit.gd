class_name CommandUnit
extends RefCounted

const UnitStateScript = preload("res://scripts/domain/state/unit_state.gd")
const EventLogScript = preload("res://scripts/core/event_log.gd")
const OrderScript = preload("res://scripts/domain/orders/order.gd")
const ReportScript = preload("res://scripts/domain/reports/report.gd")

signal report_created(report)
signal report_received(report)
signal order_received(order)
signal order_delegated(parent_order, child_order, target_unit)
signal unit_state_changed(unit, property_name: String, old_value: Variant, new_value: Variant)

enum Level {
	FRONT,
	ARMY,
	DIVISION,
	REGIMENT,
	COMPANY,
	SQUAD
}

enum ControlMode {
	AI_DELEGATED,
	PLAYER_DIRECT,
	PLAYER_ASSISTED
}

var id: String = ""
var display_name: String = ""
var level: Level = Level.FRONT
var commander_name: String = ""
var parent_unit_ref: WeakRef = null
var subordinates: Array = []
var current_order = null
var received_reports: Array = []
var control_mode: ControlMode = ControlMode.AI_DELEGATED
var unit_state = UnitStateScript.create()
var state: String = "ready"

var strategic_context: Dictionary = {}
var tactical_context: Dictionary = {}
var supply_context: Dictionary = {}

func _init(
	new_id: String = "",
	new_display_name: String = "Command Unit",
	new_level: Level = Level.FRONT,
	new_commander_name: String = "Unassigned"
) -> void:
	id = new_id if not new_id.is_empty() else _make_id(level_to_string(new_level).to_lower())
	display_name = new_display_name
	level = new_level
	commander_name = new_commander_name
	_set_unit_state(UnitStateScript.create())

func set_unit_state(new_unit_state) -> void:
	_set_unit_state(new_unit_state)

func add_subordinate(unit) -> void:
	if unit == null:
		return
	if subordinates.has(unit):
		return
	subordinates.append(unit)
	unit.parent_unit_ref = weakref(self)

func remove_subordinate(unit) -> void:
	if unit == null:
		return
	subordinates.erase(unit)
	if unit.get_parent_unit() == self:
		unit.parent_unit_ref = null

func get_parent_unit():
	if parent_unit_ref == null:
		return null
	return parent_unit_ref.get_ref()

func receive_order(order) -> void:
	if order == null:
		return
	current_order = order
	current_order.target_unit_id = id
	current_order.activate()
	emit_signal("order_received", current_order)
	EventLogScript.record_global(
		EventLogScript.Type.ORDER_ACCEPTED,
		id,
		"%s accepted order %s" % [display_name, current_order.id],
		{"order_id": current_order.id, "status": OrderScript.status_to_string(current_order.status)}
	)
	_log("accepted order -> %s" % current_order.describe())

	if should_delegate_order(current_order):
		delegate_order(current_order)
	else:
		_log("has no subordinate command level; holding order for local execution")

func should_delegate_order(order) -> bool:
	return order != null and not subordinates.is_empty() and control_mode != ControlMode.PLAYER_DIRECT

func delegate_order(order) -> void:
	if order == null:
		return
	if not order.mark_delegated():
		return
	for subordinate in subordinates:
		var child_order = order.make_child_order(
			subordinate.id,
			build_delegated_objective(order, subordinate)
		)
		emit_signal("order_delegated", order, child_order, subordinate)
		EventLogScript.record_global(
			EventLogScript.Type.ORDER_DELEGATED,
			id,
			"%s delegated order %s to %s" % [display_name, order.id, subordinate.display_name],
			{"parent_order_id": order.id, "child_order_id": child_order.id, "target_unit_id": subordinate.id}
		)
		_log("delegates to %s -> %s" % [subordinate.get_label(), child_order.describe()])
		subordinate.receive_order(child_order)

func complete_current_order() -> void:
	if current_order == null:
		return
	if current_order.complete():
		EventLogScript.record_global(EventLogScript.Type.ORDER_COMPLETED, id, "%s completed order %s" % [display_name, current_order.id], {"order_id": current_order.id})

func fail_current_order() -> void:
	if current_order == null:
		return
	if current_order.fail():
		EventLogScript.record_global(EventLogScript.Type.ORDER_FAILED, id, "%s failed order %s" % [display_name, current_order.id], {"order_id": current_order.id})

func cancel_current_order() -> void:
	if current_order == null:
		return
	if current_order.cancel():
		EventLogScript.record_global(EventLogScript.Type.ORDER_CANCELLED, id, "%s cancelled order %s" % [display_name, current_order.id], {"order_id": current_order.id})

func build_delegated_objective(order, subordinate) -> String:
	var root_objective: String = order.metadata.get("root_objective", order.objective)
	return "%s: execute assigned part of '%s'" % [subordinate.display_name, root_objective]

func send_report(
	report_type: ReportScript.Type,
	message: String,
	severity: ReportScript.Severity = ReportScript.Severity.INFO,
	related_order_id: String = "",
	metadata: Dictionary = {}
):
	var parent_unit = get_parent_unit()
	var destination_id: String = parent_unit.id if parent_unit != null else ""
	var report = ReportScript.create(report_type, id, destination_id, message, severity, related_order_id, metadata)
	emit_signal("report_created", report)
	EventLogScript.record_global(EventLogScript.Type.REPORT_CREATED, id, "%s created report %s" % [display_name, report.id], {"report_id": report.id, "type": ReportScript.type_to_string(report.report_type)})
	_log("sends report upward -> %s" % report.describe())
	if parent_unit != null:
		parent_unit.receive_report(report)
	else:
		receive_report(report)
	return report

func receive_report(report) -> void:
	if report == null:
		return
	received_reports.append(report)
	emit_signal("report_received", report)
	EventLogScript.record_global(EventLogScript.Type.REPORT_RECEIVED, id, "%s received report %s" % [display_name, report.id], {"report_id": report.id, "source_unit_id": report.source_unit_id})
	_log("received report from %s -> %s" % [report.source_unit_id, report.describe()])
	var parent_unit = get_parent_unit()
	if parent_unit != null:
		report.destination_unit_id = parent_unit.id
		parent_unit.receive_report(report)
	else:
		_log("front-level report reached command top")

func get_command_path() -> String:
	var units: Array[String] = []
	var unit = self
	while unit != null:
		units.push_front(unit.display_name)
		unit = unit.get_parent_unit()
	return " -> ".join(units)

func get_label() -> String:
	return "%s '%s'" % [level_to_string(level), display_name]

func get_tree_lines(depth: int = 0) -> Array[String]:
	var indent := "  ".repeat(depth)
	var lines: Array[String] = ["%s- %s commander=%s control=%s state=(%s)" % [
		indent,
		get_label(),
		commander_name,
		control_mode_to_string(control_mode),
		unit_state.describe()
	]]
	for subordinate in subordinates:
		lines.append_array(subordinate.get_tree_lines(depth + 1))
	return lines

func _set_unit_state(new_unit_state) -> void:
	if unit_state != null and unit_state.changed.is_connected(_on_unit_state_changed):
		unit_state.changed.disconnect(_on_unit_state_changed)
	unit_state = new_unit_state if new_unit_state != null else UnitStateScript.create()
	unit_state.changed.connect(_on_unit_state_changed)

func _on_unit_state_changed(property_name: String, old_value: Variant, new_value: Variant) -> void:
	emit_signal("unit_state_changed", self, property_name, old_value, new_value)
	EventLogScript.record_global(
		EventLogScript.Type.UNIT_STATE_CHANGED,
		id,
		"%s changed %s from %s to %s" % [display_name, property_name, str(old_value), str(new_value)],
		{"property": property_name, "old_value": old_value, "new_value": new_value}
	)
	if unit_state.is_destroyed():
		EventLogScript.record_global(EventLogScript.Type.UNIT_DESTROYED, id, "%s is no longer combat effective" % display_name, {"state": unit_state.describe()})

func _log(message: String) -> void:
	print("[%s] %s" % [get_label(), message])

static func level_to_string(value: Level) -> String:
	match value:
		Level.FRONT:
			return "Front"
		Level.ARMY:
			return "Army"
		Level.DIVISION:
			return "Division"
		Level.REGIMENT:
			return "Regiment"
		Level.COMPANY:
			return "Company"
		Level.SQUAD:
			return "Squad"
		_:
			return "Unknown"

static func control_mode_to_string(value: ControlMode) -> String:
	match value:
		ControlMode.AI_DELEGATED:
			return "AI_DELEGATED"
		ControlMode.PLAYER_DIRECT:
			return "PLAYER_DIRECT"
		ControlMode.PLAYER_ASSISTED:
			return "PLAYER_ASSISTED"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]