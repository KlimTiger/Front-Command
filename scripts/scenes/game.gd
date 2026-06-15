extends Node

const FrontScript = preload("res://scripts/domain/command/front.gd")
const ArmyScript = preload("res://scripts/domain/command/army.gd")
const DivisionScript = preload("res://scripts/domain/command/division.gd")
const RegimentScript = preload("res://scripts/domain/command/regiment.gd")
const CompanyScript = preload("res://scripts/domain/command/company.gd")
const SquadScript = preload("res://scripts/domain/command/squad.gd")
const SoldierScript = preload("res://scripts/domain/personnel/soldier.gd")
const OrderScript = preload("res://scripts/domain/orders/order.gd")
const ReportScript = preload("res://scripts/domain/reports/report.gd")
const UnitStateScript = preload("res://scripts/domain/state/unit_state.gd")
const EventLogScript = preload("res://scripts/domain/events/event_log.gd")
const BattleContextScript = preload("res://scripts/domain/battle/battle_context.gd")

var event_log

func _ready() -> void:
	event_log = EventLogScript.new()
	EventLogScript.set_current(event_log)

	print("=== FRONT COMMAND FOUNDATION PROTOTYPE 0.5 ===")
	var front = _build_command_chain()
	_print_command_tree(front)
	_run_order_delegation_demo(front)
	_run_report_demo(front)
	_run_unit_state_demo(front)
	_run_order_lifecycle_demo()
	_run_battle_context_demo(front)
	event_log.dump_summary()
	print("=== PROTOTYPE 0.5 COMPLETE ===")

func _build_command_chain():
	var front = FrontScript.new("front_western", "Western Front Headquarters", "Front Staff")
	var army = ArmyScript.new("army_16", "16th Army", "Army Commander")
	var division = DivisionScript.new("division_316", "316th Rifle Division", "Division Commander")
	var regiment = RegimentScript.new("regiment_1075", "1075th Rifle Regiment", "Regiment Commander")
	var company = CompanyScript.new("company_4", "4th Rifle Company", "Company Commander")
	var squad = SquadScript.new("squad_1", "1st Squad", "Squad Leader")
	var rifleman = SoldierScript.new("soldier_rifleman_1", "Rifleman Ivanov", SoldierScript.Role.RIFLEMAN)
	var machine_gunner = SoldierScript.new("soldier_mg_1", "Machine Gunner Petrov", SoldierScript.Role.MACHINE_GUNNER)

	front.add_subordinate(army)
	army.add_subordinate(division)
	division.add_subordinate(regiment)
	regiment.add_subordinate(company)
	company.add_subordinate(squad)
	squad.add_soldier(rifleman)
	squad.add_soldier(machine_gunner)

	front.call("set_unit_state", UnitStateScript.create(120000, 0.78, 0.15, 0.82, 0.70))
	army.call("set_unit_state", UnitStateScript.create(42000, 0.74, 0.20, 0.80, 0.65))
	division.call("set_unit_state", UnitStateScript.create(11200, 0.70, 0.25, 0.76, 0.60))
	regiment.call("set_unit_state", UnitStateScript.create(1840, 0.82, 0.18, 0.79, 0.68))
	company.call("set_unit_state", UnitStateScript.create(145, 0.68, 0.22, 0.74, 0.59))
	squad.call("set_unit_state", UnitStateScript.create(squad.soldiers.size(), 0.55, 0.30, 0.72, 0.48))

	front.strategic_context = {
		"future_strategic_map": true,
		"sector": "Volokolamsk direction"
	}
	regiment.supply_context = {
		"future_supply_enabled": true,
		"ammo_percent": regiment.unit_state.ammo
	}
	squad.tactical_context = {
		"future_tactical_map": true,
		"terrain_hint": "village edge"
	}

	return front

func _run_order_delegation_demo(front) -> void:
	print("--- ORDER DELEGATION DEMO ---")
	var order = OrderScript.create(
		OrderScript.Type.HOLD,
		"Hold the Volokolamsk direction",
		"player_front_staff",
		front.id,
		5,
		{
			"future_manual_intervention": true,
			"future_assets": ["artillery", "tanks", "supply"]
		}
	)
	front.receive_order(order)

func _run_report_demo(front) -> void:
	print("--- REPORT FLOW DEMO ---")
	var army = front.subordinates[0]
	var division = army.subordinates[0]
	var regiment = division.subordinates[0]
	var company = regiment.subordinates[0]
	var squad = company.subordinates[0]
	var rifleman = squad.soldiers[0]

	squad.send_report(
		ReportScript.Type.CONTACT,
		"Enemy patrol sighted near the southern tree line.",
		ReportScript.Severity.WARNING,
		squad.current_order.id if squad.current_order != null else "",
		{"observer_soldier_id": rifleman.id, "future_tactical_position": Vector2(120.0, 85.0)}
	)

	squad.send_report(
		ReportScript.Type.AMMO_LOW,
		"Squad ammunition is below expected level.",
		ReportScript.Severity.WARNING,
		squad.current_order.id if squad.current_order != null else "",
		{"ammo_percent": squad.unit_state.ammo}
	)

	regiment.send_report(
		ReportScript.Type.REQUEST_REINFORCEMENT,
		"Requesting reserve company to strengthen the southern approach.",
		ReportScript.Severity.URGENT,
		regiment.current_order.id if regiment.current_order != null else "",
		{"requested_unit_type": "company", "future_player_decision": true}
	)

	print("Front received reports: %d" % front.received_reports.size())

func _run_unit_state_demo(front) -> void:
	print("--- UNIT STATE DEMO ---")
	var squad = front.subordinates[0].subordinates[0].subordinates[0].subordinates[0].subordinates[0]
	print("Before: %s" % squad.unit_state.describe())
	squad.unit_state.set_ammo(0.35)
	squad.unit_state.set_fatigue(0.42)
	print("After: %s" % squad.unit_state.describe())

func _run_order_lifecycle_demo() -> void:
	print("--- ORDER LIFECYCLE DEMO ---")
	var lifecycle_order = OrderScript.create(OrderScript.Type.RECON, "Check the forest edge", "company_4", "squad_1", 2)
	print("DRAFT -> COMPLETED valid? %s" % str(lifecycle_order.complete()))
	print("DRAFT -> ACTIVE valid? %s" % str(lifecycle_order.activate()))
	print("ACTIVE -> DELEGATED valid? %s" % str(lifecycle_order.mark_delegated()))
	print("DELEGATED -> COMPLETED valid? %s" % str(lifecycle_order.complete()))
	print("COMPLETED -> CANCELLED valid? %s" % str(lifecycle_order.cancel()))
	print("Lifecycle history: %s" % str(lifecycle_order.status_history))

func _run_battle_context_demo(front) -> void:
	print("--- BATTLE CONTEXT DEMO ---")
	var army = front.subordinates[0]
	var division = army.subordinates[0]
	var regiment = division.subordinates[0]
	var company = regiment.subordinates[0]
	var context = BattleContextScript.create(
		"strategic_contact_volokolamsk_001",
		[regiment, company],
		{"future_tactical_scene": "pending", "future_result_application": true}
	)
	print(context.describe())
	print("Strategic snapshot: %s" % str(context.strategic_snapshot))

func _print_command_tree(front) -> void:
	print("--- COMMAND TREE ---")
	for line in front.get_tree_lines():
		print(line)