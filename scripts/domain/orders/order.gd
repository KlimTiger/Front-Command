class_name Order
extends RefCounted

const EventLogScript = preload("res://scripts/core/event_log.gd")

enum Type {
	HOLD,
	DEFEND,
	ATTACK,
	RECON,
	WITHDRAW,
	ENTRENCH,
	ASSAULT,
	SUPPORT,
	RESUPPLY
}

enum Status {
	DRAFT,
	ACTIVE,
	DELEGATED,
	COMPLETED,
	FAILED,
	CANCELLED
}

var id: String = ""
var parent_order_id: String = ""
var order_type: Type = Type.HOLD
var objective: String = ""
var issuer_unit_id: String = ""
var target_unit_id: String = ""
var priority: int = 1
var status: Status = Status.DRAFT
var created_tick: int = 0
var completed_tick: int = 0
var metadata: Dictionary = {}
var status_history: Array[Dictionary] = []

static func create(
	new_order_type: Type,
	new_objective: String,
	new_issuer_unit_id: String = "",
	new_target_unit_id: String = "",
	new_priority: int = 1,
	new_metadata: Dictionary = {}
):
	var order = load("res://scripts/domain/orders/order.gd").new()
	order.id = _make_id("order")
	order.order_type = new_order_type
	order.objective = new_objective
	order.issuer_unit_id = new_issuer_unit_id
	order.target_unit_id = new_target_unit_id
	order.priority = new_priority
	order.metadata = new_metadata.duplicate(true)
	if not order.metadata.has("root_objective"):
		order.metadata["root_objective"] = new_objective
	order.created_tick = Time.get_ticks_msec()
	order.status_history.append({"tick": order.created_tick, "status": status_to_string(order.status)})
	EventLogScript.record_global(
		EventLogScript.Type.ORDER_ISSUED,
		new_issuer_unit_id,
		"Issued %s order to %s" % [type_to_string(new_order_type), new_target_unit_id],
		{"order_id": order.id, "objective": new_objective}
	)
	return order

func make_child_order(new_target_unit_id: String, new_objective: String = ""):
	var child_order = load("res://scripts/domain/orders/order.gd").create(
		order_type,
		new_objective if not new_objective.is_empty() else objective,
		target_unit_id,
		new_target_unit_id,
		priority,
		metadata
	)
	child_order.parent_order_id = id
	return child_order

func activate() -> bool:
	return transition_to(Status.ACTIVE)

func mark_delegated() -> bool:
	return transition_to(Status.DELEGATED)

func complete() -> bool:
	return transition_to(Status.COMPLETED)

func fail() -> bool:
	return transition_to(Status.FAILED)

func cancel() -> bool:
	return transition_to(Status.CANCELLED)

func transition_to(new_status: Status) -> bool:
	if not can_transition_to(new_status):
		push_warning("Invalid order transition: %s -> %s for %s" % [
			status_to_string(status),
			status_to_string(new_status),
			id
		])
		return false
	status = new_status
	var tick := Time.get_ticks_msec()
	status_history.append({"tick": tick, "status": status_to_string(status)})
	if is_terminal():
		completed_tick = tick
	return true

func can_transition_to(new_status: Status) -> bool:
	if status == new_status:
		return true
	match status:
		Status.DRAFT:
			return new_status == Status.ACTIVE or new_status == Status.CANCELLED
		Status.ACTIVE:
			return new_status == Status.DELEGATED or new_status == Status.COMPLETED or new_status == Status.FAILED or new_status == Status.CANCELLED
		Status.DELEGATED:
			return new_status == Status.COMPLETED or new_status == Status.FAILED or new_status == Status.CANCELLED
		Status.COMPLETED, Status.FAILED, Status.CANCELLED:
			return false
		_:
			return false

func is_terminal() -> bool:
	return status == Status.COMPLETED or status == Status.FAILED or status == Status.CANCELLED

func describe() -> String:
	return "%s | objective='%s' | priority=%d | status=%s" % [
		type_to_string(order_type),
		objective,
		priority,
		status_to_string(status)
	]

static func type_to_string(value: Type) -> String:
	match value:
		Type.HOLD:
			return "HOLD"
		Type.DEFEND:
			return "DEFEND"
		Type.ATTACK:
			return "ATTACK"
		Type.RECON:
			return "RECON"
		Type.WITHDRAW:
			return "WITHDRAW"
		Type.ENTRENCH:
			return "ENTRENCH"
		Type.ASSAULT:
			return "ASSAULT"
		Type.SUPPORT:
			return "SUPPORT"
		Type.RESUPPLY:
			return "RESUPPLY"
		_:
			return "UNKNOWN"

static func status_to_string(value: Status) -> String:
	match value:
		Status.DRAFT:
			return "DRAFT"
		Status.ACTIVE:
			return "ACTIVE"
		Status.DELEGATED:
			return "DELEGATED"
		Status.COMPLETED:
			return "COMPLETED"
		Status.FAILED:
			return "FAILED"
		Status.CANCELLED:
			return "CANCELLED"
		_:
			return "UNKNOWN"

static func _make_id(prefix: String) -> String:
	return "%s_%d" % [prefix, Time.get_ticks_usec()]