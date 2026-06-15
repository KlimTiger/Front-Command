class_name EventLog
extends RefCounted

enum Type {
	ORDER_ISSUED,
	ORDER_ACCEPTED,
	ORDER_DELEGATED,
	ORDER_COMPLETED,
	ORDER_FAILED,
	ORDER_CANCELLED,
	REPORT_CREATED,
	REPORT_RECEIVED,
	UNIT_STATE_CHANGED,
	UNIT_DESTROYED,
	BATTLE_CONTEXT_CREATED
}

static var current = null

var events: Array[Dictionary] = []

static func set_current(log) -> void:
	current = log

static func record_global(event_type: Type, source_id: String, message: String, metadata: Dictionary = {}) -> void:
	if current == null:
		return
	current.record(event_type, source_id, message, metadata)

func record(event_type: Type, source_id: String, message: String, metadata: Dictionary = {}) -> Dictionary:
	var event := {
		"tick": Time.get_ticks_msec(),
		"type": type_to_string(event_type),
		"source_id": source_id,
		"message": message,
		"metadata": metadata.duplicate(true)
	}
	events.append(event)
	print("[EventLog] %s source=%s message='%s'" % [event["type"], source_id, message])
	return event

func get_events_by_type(event_type: Type) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var type_name := type_to_string(event_type)
	for event in events:
		if event.get("type", "") == type_name:
			result.append(event)
	return result

func dump_summary() -> void:
	print("--- EVENT LOG SUMMARY ---")
	print("Total events: %d" % events.size())
	for event in events:
		print("%s | %s | %s" % [event["type"], event["source_id"], event["message"]])

static func type_to_string(value: Type) -> String:
	match value:
		Type.ORDER_ISSUED:
			return "OrderIssued"
		Type.ORDER_ACCEPTED:
			return "OrderAccepted"
		Type.ORDER_DELEGATED:
			return "OrderDelegated"
		Type.ORDER_COMPLETED:
			return "OrderCompleted"
		Type.ORDER_FAILED:
			return "OrderFailed"
		Type.ORDER_CANCELLED:
			return "OrderCancelled"
		Type.REPORT_CREATED:
			return "ReportCreated"
		Type.REPORT_RECEIVED:
			return "ReportReceived"
		Type.UNIT_STATE_CHANGED:
			return "UnitStateChanged"
		Type.UNIT_DESTROYED:
			return "UnitDestroyed"
		Type.BATTLE_CONTEXT_CREATED:
			return "BattleContextCreated"
		_:
			return "UnknownEvent"