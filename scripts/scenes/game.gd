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
const EventLogScript = preload("res://scripts/core/event_log.gd")
const BattleContextScript = preload("res://scripts/battle/battle_context.gd")
const GameTimeScript = preload("res://scripts/core/game_time.gd")
const CellMapScript = preload("res://scripts/map/grid_map.gd")
const TerrainScript = preload("res://scripts/map/terrain.gd")
const StrategicUnitScript = preload("res://scripts/strategic/strategic_unit.gd")
const MovementSystemScript = preload("res://scripts/strategic/movement_system.gd")
const ContactSystemScript = preload("res://scripts/strategic/contact_system.gd")

var event_log
var game_time
var cell_map
var movement_system
var contact_system
var strategic_units: Array = []
var battle_contexts: Array = []

func _ready() -> void:
	event_log = EventLogScript.new()
	EventLogScript.set_current(event_log)
	game_time = GameTimeScript.new()
	movement_system = MovementSystemScript.new()
	contact_system = ContactSystemScript.new()

	print("=== FRONT COMMAND — STAGE 0.5 FOUNDATION ===")
	var setup = _build_command_chain()
	var front = setup["front"]
	var enemy_regiment = setup["enemy_regiment"]
	_print_command_tree(front)
	_run_order_delegation_demo(front)
	_run_report_demo(front)

	print("")
	print("=== FRONT COMMAND — STAGE 1 STRATEGIC MAP ===")
	_run_strategic_map_demo(front, enemy_regiment)

	event_log.dump_summary()
	print("=== STAGE 1 PROTOTYPE COMPLETE ===")

func _build_command_chain():
	var front = FrontScript.new("front_western", "Western Front Headquarters", "Front Staff")
	var army = ArmyScript.new("army_16", "16th Army", "Army Commander")
	var division = DivisionScript.new("division_316", "316th Rifle Division", "Division Commander")
	var regiment = RegimentScript.new("regiment_1075", "1075th Rifle Regiment", "Regiment Commander")
	var regiment_enemy = RegimentScript.new("regiment_98", "98th Infantry Regiment", "Regiment Commander")
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
	regiment_enemy.call("set_unit_state", UnitStateScript.create(1620, 0.76, 0.22, 0.74, 0.62))
	company.call("set_unit_state", UnitStateScript.create(145, 0.68, 0.22, 0.74, 0.59))
	squad.call("set_unit_state", UnitStateScript.create(squad.soldiers.size(), 0.55, 0.30, 0.72, 0.48))

	regiment.supply_context = {
		"future_supply_enabled": true,
		"ammo_percent": regiment.unit_state.ammo
	}
	squad.tactical_context = {
		"future_tactical_map": true,
		"terrain_hint": "village edge"
	}
	front.strategic_context = {
		"future_strategic_map": true,
		"sector": "Volokolamsk direction"
	}

	return {"front": front, "enemy_regiment": regiment_enemy}

func _run_strategic_map_demo(front, enemy_regiment) -> void:
	cell_map = _build_test_map()
	strategic_units.clear()
	battle_contexts.clear()

	var division = front.subordinates[0].subordinates[0]
	var friendly_regiment = division.subordinates[0]

	var friendly_unit = StrategicUnitScript.create(
		friendly_regiment,
		StrategicUnitScript.Faction.SOVIET,
		Vector2i(1, 3),
		1.0
	)
	var enemy_unit = StrategicUnitScript.create(
		enemy_regiment,
		StrategicUnitScript.Faction.GERMAN,
		Vector2i(1, 6),
		0.8
	)
	strategic_units = [friendly_unit, enemy_unit]

	cell_map.add_occupant(friendly_unit.position, friendly_unit.id)
	cell_map.add_occupant(enemy_unit.position, enemy_unit.id)

	print("--- CELL MAP ---")
	print(cell_map.describe())
	print("Friendly: %s" % friendly_unit.describe())
	print("Enemy: %s" % enemy_unit.describe())

	friendly_unit.set_destination(Vector2i(1, 8))
	enemy_unit.set_destination(Vector2i(1, 4))
	print("Orders: friendly -> %s, enemy -> %s" % [str(friendly_unit.destination), str(enemy_unit.destination)])

	game_time.set_time_scale(2.0)
	var max_ticks := 24
	for _tick_index in max_ticks:
		game_time.advance_tick()
		movement_system.process_tick(cell_map, strategic_units)
		var new_battles = contact_system.check_contacts(strategic_units, cell_map)
		for battle in new_battles:
			battle_contexts.append(battle)
			print("CONTACT -> %s" % battle.describe())
		if not battle_contexts.is_empty():
			break

	print("After simulation: %s" % game_time.describe())
	print("Friendly position: %s" % str(friendly_unit.position))
	print("Enemy position: %s" % str(enemy_unit.position))
	print("Battles created: %d" % battle_contexts.size())
	if not battle_contexts.is_empty():
		print("Snapshot: %s" % str(battle_contexts[0].strategic_snapshot))

func _build_test_map():
	var map = CellMapScript.create(8, 10, TerrainScript.Type.OPEN)
	for x in map.width:
		map.set_terrain(Vector2i(x, 5), TerrainScript.Type.FOREST)
	map.set_terrain(Vector2i(1, 5), TerrainScript.Type.ROAD)
	map.set_terrain(Vector2i(1, 6), TerrainScript.Type.VILLAGE)
	map.set_terrain(Vector2i(2, 4), TerrainScript.Type.HILL)
	map.set_terrain(Vector2i(0, 7), TerrainScript.Type.RIVER)
	return map

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

	regiment.send_report(
		ReportScript.Type.REQUEST_REINFORCEMENT,
		"Requesting reserve company to strengthen the southern approach.",
		ReportScript.Severity.URGENT,
		regiment.current_order.id if regiment.current_order != null else "",
		{"requested_unit_type": "company", "future_player_decision": true}
	)

	print("Front received reports: %d" % front.received_reports.size())

func _print_command_tree(front) -> void:
	print("--- COMMAND TREE ---")
	for line in front.get_tree_lines():
		print(line)
