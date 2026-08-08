# Runnable World Framework v0.1

## What is playable now

- A camera-driven 4096 x 2304 2D region, rather than a single static test screen.
- Three launch regions: Yunlan Village, Mist Border, and Ancient Ridge.
- Region gates, resource nodes, and NPC interaction markers are created from data in `playable_world.gd`.
- Mist-Stream Water Palace is a separate visual dungeon scene reached from the Yunlan Village map.
- The dungeon uses the same player controller and supports a local boss-hit loop against Qiao Tide Demoness Lansa.
- Yunlan Village now has an original generated base-map asset and a first-chapter onboarding chain: Shen Yan's guidance → Mist-Stream Herb → Water Palace.
- Mist-Stream Water Palace now has an original dungeon base-map asset with the boss anchor aligned to its inner circular arena.
- The current player proof uses a separate eight-direction body layer plus a separate Qinglan Sword layer, attached through hand offsets and weapon follow/swing logic. It is deliberately not yet called a complete animation package because the matching walk and attack frame sequences remain to be produced.
- Player art, map art, NPCs, weapons, costumes, and effects are separate assets. Replacing them does not require rewiring map navigation or interaction logic.
- The Old Caravan Road now includes its first authored, transparent, Y-sorted roadside waystation asset. It demonstrates how future trade-route buildings can replace a placeholder without shrinking the map or moving ecology anchors. Its physical interaction opens the current local market prototype and records one non-repeatable road-ledger observation; it is not a menu-only decoration.

## Current map layer contract

| Layer | Current implementation | Final asset replacement |
|---|---|---|
| Ground | Procedural 2D region drawing | Tileable terrain background |
| Roads and water | Procedural paths | Painted base and decal layers |
| Buildings and landmarks | First transparent Old Caravan Road waystation plus procedural placeholders elsewhere | Individual transparent building/landmark sprites |
| Foreground/occlusion | Reserved | Trees, roofs, cliffs and mist on a foreground layer |
| Interactions | `WorldMarker` area nodes | Same nodes, with final map anchors |

## Next construction steps

1. Replace each structural map layer with approved original art while preserving the anchor coordinates.
2. Add collision/occlusion polygons for buildings, cliffs, water, and dungeon doors.
3. Implement the full eight-direction walk and attack sets, then weapon-specific attack packages.
4. Extend the existing local profile save into account/cloud save, then add server API boundaries and the authoritative multiplayer service required for trade and the broader PVP loop.

## Honest prototype boundary

This is a Godot world prototype, not a finished MMO. The three-region structure, dungeon entry, map scale, interaction wiring, local save, weak nonlinear story weave, and a localhost two-player duel slice are now present. The duel slice has the server validate positions, range, cooldowns, HP, and victory with fixed fair rules; account/cloud save, production-scale network synchronization, final map art, complete content, progression balance, and WeChat export remain later phases.
