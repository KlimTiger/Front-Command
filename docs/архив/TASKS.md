# Front Command - Roadmap

## Current Priority

Stage 1 - Strategic Map Prototype.

Stage 0 and Stage 0.5 are complete. The project now has the data foundation, command hierarchy, order lifecycle, reports, EventLog, UnitState, and BattleContext bridge. The current work is still strategic-layer foundation, not tactical combat.

Do not implement yet:

- shooting;
- tactical battle simulation;
- tanks;
- artillery;
- UI-heavy gameplay;
- historical campaign content.

## Stage 0 - Project Foundation

Goal: create the basic game architecture.

### Command Hierarchy

- [x] Front
- [x] Army
- [x] Division
- [x] Regiment
- [x] Company
- [x] Squad
- [x] Soldier as executor data inside Squad

### Orders

- [x] Base Order object
- [x] Order types: HOLD, DEFEND, ATTACK, RECON, WITHDRAW, ENTRENCH, ASSAULT, SUPPORT, RESUPPLY
- [x] Delegation downward through CommandUnit chain

### Reports

- [x] Base Report object
- [x] Report flow upward through CommandUnit chain
- [x] Report types for contact, ammo, losses, reinforcement, completion/failure, status, supply

### Test Scene

- [x] No-graphics test scene
- [x] Command tree demo
- [x] Order delegation demo
- [x] Report flow demo

## Stage 0.5 - Foundation Hardening

Goal: prepare architecture for strategic map, tactical map, AI, supply, and reports.

### Architecture

- [x] Soldier no longer inherits CommandUnit
- [x] Squad owns `soldiers: Array`
- [x] UnitState object created
- [x] BattleContext bridge created
- [x] Central EventLog created

### UnitState

- [x] strength
- [x] ammo
- [x] fatigue
- [x] morale
- [x] combat_effectiveness

### Order Lifecycle

- [x] DRAFT -> ACTIVE
- [x] ACTIVE -> DELEGATED
- [x] ACTIVE/DELEGATED -> COMPLETED
- [x] ACTIVE/DELEGATED -> FAILED
- [x] DRAFT/ACTIVE/DELEGATED -> CANCELLED
- [x] terminal states cannot transition further
- [x] status history recorded

### EventLog

- [x] OrderIssued
- [x] OrderAccepted
- [x] OrderDelegated
- [x] OrderCompleted
- [x] OrderFailed
- [x] OrderCancelled
- [x] ReportCreated
- [x] ReportReceived
- [x] UnitStateChanged
- [x] UnitDestroyed
- [x] BattleContextCreated
- [x] UnitMoved
- [x] StrategicContact
- [x] GameTick

## Stage 1 - Strategic Map Prototype

Goal: create the first working strategic layer. This layer remains data-first and has no graphics requirement.

### World

- [x] CellMap grid
- [x] Cell data
- [x] Terrain types
- [x] terrain movement cost
- [x] terrain supply modifier placeholder
- [x] GameTime tick clock
- [x] pause flag
- [x] time scale

### Strategic Units

- [x] StrategicUnit wrapper that references CommandUnit
- [x] faction: SOVIET / GERMAN
- [x] position and destination
- [x] movement state
- [x] movement points and speed

### Movement

- [x] MovementSystem
- [x] cell-to-cell movement
- [x] terrain movement cost
- [ ] pathfinding beyond simple direct stepping
- [ ] blocked cell rules
- [ ] stacking rules

### Contact

- [x] ContactSystem
- [x] enemy contact detection
- [x] StrategicContact event
- [x] BattleContext creation from contact
- [x] strategic snapshot in BattleContext
- [ ] strategic report sent upward when contact occurs
- [ ] contact report includes enemy, location, terrain, and battle_context_id

### Strategic Orders

- [x] temporary destination assignment through StrategicUnit
- [ ] strategic movement order object/action
- [ ] connect command Order metadata to StrategicUnit destination
- [ ] report order completion/failure on strategic movement

### Stage 1 Next Steps

1. Add strategic reports on contact through the command chain.
2. Add a StrategicOrderResolver that applies movement orders to StrategicUnit.
3. Add basic map occupancy/stacking rules.
4. Add a simple strategic report summary for Front HQ.
5. Only then prepare the handoff into Stage 2 tactical prototype.

## Stage 2 - Tactical Map Prototype

Goal: create the first no-frills tactical layer using the same data. Do not start combat before the handoff is clean.

### Before Tactical Combat

- [ ] TacticalBattleContext reader
- [ ] tactical setup from BattleContext
- [ ] create tactical participants from existing CommandUnit/Soldier data
- [ ] return result into UnitState

### Tactical Map

- [ ] free-position 2D map
- [ ] forests
- [ ] roads
- [ ] buildings
- [ ] trenches
- [ ] fortifications

### Tactical Units

- [ ] companies
- [ ] squads
- [ ] soldiers as executors
- [ ] no independent copies of campaign units

### Combat Later

- [ ] spotting
- [ ] shooting
- [ ] ammo spending
- [ ] casualties
- [ ] wounded

## Stage 3 - Strategic/Tactical Link

Goal: connect both maps into one campaign data flow.

- [ ] create battle from strategic contact
- [ ] load tactical context
- [ ] pause strategic time during tactical battle
- [ ] apply tactical result to UnitState
- [ ] return losses, ammo, fatigue, morale, experience
- [ ] verify no duplicated unit data

## Stage 4 - AI Commanders

Goal: commanders reason through orders, reports, and state.

- [ ] evaluate threats
- [ ] split parent orders into tasks
- [ ] allocate subordinates
- [ ] keep reserves
- [ ] request reinforcement
- [ ] report losses/contact/ammo

## Stage 5 - Delegation and Player Intervention

Goal: implement the main game feature.

- [ ] AI_DELEGATED control mode behavior
- [ ] PLAYER_DIRECT control mode behavior
- [ ] PLAYER_ASSISTED control mode behavior
- [ ] player override of orders
- [ ] return control to AI

## Stage 6 - Moscow Defense Campaign

Goal: first campaign after the systems can support it.

- [ ] campaign map
- [ ] historical initial deployment
- [ ] Stavka orders
- [ ] reinforcements
- [ ] victory conditions

## Stage 7 - Advanced Combat Systems

- [ ] artillery units
- [ ] tanks
- [ ] anti-tank weapons
- [ ] reconnaissance/fog of war

## Stage 8 - Supply

- [ ] ammunition
- [ ] fuel
- [ ] supply lines
- [ ] replacements
- [ ] equipment replacement

## Stage 9 - Report System Depth

- [ ] enemy contact reports
- [ ] low ammo reports
- [ ] heavy losses reports
- [ ] objective completed reports
- [ ] support requested reports
- [ ] player response options

## Stage 10 - Full Version

- [ ] campaigns beyond Moscow
- [ ] save/load
- [ ] UI polish
- [ ] sound
- [ ] optimization
- [ ] balancing