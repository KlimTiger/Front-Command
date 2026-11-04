# Foundation and Current Architecture

## Purpose

Front Command is a data-first Godot 4.x project. The foundation is not combat, graphics, or UI. The foundation is the relationship between command hierarchy, orders, reports, unit state, strategic map, and future tactical battles.

## Current Status

Implemented and verified in the no-graphics test scene:

- Stage 0: command hierarchy, orders, reports, delegation.
- Stage 0.5: Soldier as executor, UnitState, order lifecycle, EventLog, BattleContext.
- Stage 1 base: CellMap, terrain, GameTime, StrategicUnit, MovementSystem, ContactSystem, BattleContext from contact.

## Command Hierarchy

```text
Front
  Army
    Division
      Regiment
        Company
          Squad
            Soldier[]
```

`Soldier` is not a `CommandUnit`. Soldiers do not delegate orders and do not send reports as command nodes. A `Squad` can report something observed by a soldier through report metadata.

## Core Objects

### CommandUnit

Base class for command nodes:

- id
- display_name
- level
- commander_name
- parent_unit_ref
- subordinates
- current_order
- received_reports
- control_mode
- unit_state
- strategic_context
- tactical_context
- supply_context

### UnitState

Shared readiness object for campaign, strategy, tactics, AI, reports, and supply:

- strength
- ammo
- fatigue
- morale
- combat_effectiveness

### Soldier

Executor data inside Squad:

- id
- display_name
- health
- rounds
- fatigue
- weapon
- grenades
- role
- accuracy
- experience

### Order

Intent object:

- type
- status
- objective
- issuer_unit_id
- target_unit_id
- parent_order_id
- priority
- metadata
- status_history

Valid lifecycle:

```text
DRAFT -> ACTIVE
DRAFT -> CANCELLED
ACTIVE -> DELEGATED
ACTIVE -> COMPLETED
ACTIVE -> FAILED
ACTIVE -> CANCELLED
DELEGATED -> COMPLETED
DELEGATED -> FAILED
DELEGATED -> CANCELLED
```

Terminal states do not transition further:

```text
COMPLETED
FAILED
CANCELLED
```

### Report

Message object moving upward:

- type
- severity
- source_unit_id
- destination_unit_id
- message
- related_order_id
- metadata

### EventLog

Central append-only event stream for debugging and future AI reasoning.

Current events:

- OrderIssued
- OrderAccepted
- OrderDelegated
- OrderCompleted
- OrderFailed
- OrderCancelled
- ReportCreated
- ReportReceived
- UnitStateChanged
- UnitDestroyed
- BattleContextCreated
- UnitMoved
- StrategicContact
- GameTick

## Strategic Layer

### CellMap

Grid map with cells.

Each cell stores:

- coords
- terrain_type
- movement_cost
- supply_modifier
- occupancy

### Terrain

Current terrain types:

- OPEN
- FOREST
- ROAD
- HILL
- RIVER
- VILLAGE

### StrategicUnit

Map wrapper around an existing CommandUnit. It does not own separate campaign data.

Stores:

- command_unit
- faction
- position
- destination
- movement_state
- movement_points
- base_speed

### MovementSystem

Moves StrategicUnit objects from cell to cell using terrain movement cost.

Current limitation: direct stepping only, no pathfinding yet.

### ContactSystem

Detects enemy units in the same cell or within contact_radius. Creates BattleContext and writes StrategicContact.

### BattleContext

Bridge container between strategic contact and future tactical battle.

Stores:

- strategic_battle_id
- tactical_battle_id
- attacker_unit_ids
- defender_unit_ids
- participating_units
- contact_cell
- strategic_snapshot
- tactical_result
- metadata
- status

## Test Scenario

`Game.tscn` runs `scripts/scenes/game.gd`.

The current test scenario:

1. Builds the command chain.
2. Prints UnitState and soldier roster.
3. Delegates a HOLD order from Front to Squad.
4. Sends reports upward through the chain.
5. Builds an 8x10 CellMap.
6. Places Soviet and German regiments.
7. Moves them toward each other.
8. Detects contact.
9. Creates BattleContext.
10. Prints EventLog summary.

## Architectural Rules

- No independent copies of units between strategy and tactics.
- StrategicUnit references CommandUnit.
- BattleContext snapshots state for handoff, but does not replace source data.
- Tactical battle must return changes to UnitState.
- Combat systems must wait until strategic/tactical data flow is clean.