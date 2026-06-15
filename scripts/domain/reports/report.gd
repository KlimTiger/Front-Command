class_name Report
extends RefCounted

enum Type {
	CONTACT,
	AMMO_LOW,
	HEAVY_LOSSES,
	REQUEST_REINFORCEMENT,
	ORDER_COMPLETED,
	ORDER_FAILED,
	STATUS_UPDATE,
	SUPPLY_REQUEST
}

enum Severity {
	INFO,
	WARNING,
	URGENT,
	CRITICAL
}

var id: String = ""
var report_type: Type = Type.STATUS_UPDATE
var source_unit_id: String = ""
var destination_unit_id: String = ""
var message: String = ""
var severity: Severity = Severity.INFO
var related_order_id: String = ""
var created_tick: int = 0
var metadata: Dictionary = {}

static func create(
	new_report_type: Type,
	new_source_unit_id: String,
	new_destination_unit_id: String,
	new_message: String,
	new_severity: Severity = Severity.INFO,
	new_related_order_id: String = "",
	new_metadata: Dictionary = {}
) -> Report:
	var report := Report.new()
	report.id = _make_id("report")
	report.report_type = new_report_type
	report.source_unit_id = new_source_unit_id
	report.destination_unit_id = new_destination_unit_id
	report.message = new_message
	report.severity = new_severity
	report.related_order_id = new_related_order_id
	report.metadata = new_metadata.duplicate(true)
	report.created_tick = Time.get_ticks_msec()
	return report

func describe() -> String:
	return "%s | severity=%s | message='%s'" % [
		type_to_string(report_type),
		severity_to_string(severity),
		message
	]

static func type_to_string(value: Type) -> String:
	match value:
		Type.CONTACT:
			return "CONTACT"
		Type.AMMO_LOW:
			return "AMMO_LOW"
		Type.HEAVY_LOSSES:
			return "HEAVY_LOSSES"
		Type.REQUEST_REINFORCEMENT:
			return "REQUEST_REINFORCEMENT"
		Type.ORDER_COMPLETED:
			return "ORDER_COMPLETED"
		Type.ORDER_FAILED:
			return "ORDER_FAILED"
		Type.STATUS_UPDATE:
			return "STATUS_UPDATE"
		Type.SUPPLY_REQUEST:
			return "SUPPLY_REQUEST"
		_:
			return "UNKNOWN"

static func severity_to_string(value: Severity) -> String:
	match value:
		Severity.INFO:
			return "INFO"
		Severity.WARNING:
			return "WARNING"
		Severity.URGENT:
			return "URGENT"
		Severity.CRITICAL:
			return "CRITICAL"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]
