# Verification and edge cases

Evidence collected on 9 October 2026 from the actual PEAK/Minecraft session and build outputs. “Observed” is a narrow result, not a claim that every related scenario passes.

## Verified baseline

| Check | Result |
|---|---|
| PEAK plugin compiled against installed 2.6.b assemblies | Passed; zero warnings/errors |
| Minecraft Fabric mod build | Passed |
| SkyRay/TriCollider and new PlayerHold automated tests | All 25 passed (21 geometry tests, 4 parking-state tests) |
| PEAK protocol layout/ring checks and five Harmony patches | Passed in live game |
| Official MinePeak Minecraft Launcher profile | Started 26.3/Fabric 0.19.5 successfully |
| Live Minecraft HUD/items/avatar in PEAK airport | Observed in screenshots and logs; user confirmed working |
| Block mesh transfer | A newly created mirror world sent a section mesh; PEAK drew a live section |
| PEAK pause menu and returning Minecraft input | Ownership changes and release-all observed |
| F6 returning control to PEAK | Observed; follower released and input released |
| Boarding/flight/landing | Observed: Airport → Level_19, cutscene, then normal PEAK mode |
| F6 resuming Minecraft on the beach | Observed: fresh teleport acknowledgement and Minecraft control restored |
| F5 third-person mode | Mode changes/third-person camera observed in live logs |
| Hardening fixes | Built and installed; live edge-case verification remains incomplete |
| MinePeak branding | PEAK assembly title/product and plugin display name, package metadata, Minecraft bridge display name, launcher and current READMEs checked; inherited IDs retained |

## Finding: follower drift

The original follower sometimes put PEAK's physical torso several metres from Minecraft's reported feet. The camera followed Minecraft correctly, hiding the discrepancy. This can affect triggers or where the scout resumes normal physics.

The installed correction snapshots every ragdoll Rigidbody's world position before translating it, rather than moving a transform root and leaving child physics poses stale. It computes the delta from the torso's physics position. Releasing the follower does not warp it back during a PEAK cutscene. Unity's [Rigidbody position API](https://docs.unity3d.com/6000.0/Documentation/ScriptReference/Rigidbody-position.html) explains the distinction between physics poses and transforms.

The rebuilt PEAK plugin and Minecraft mod are installed. Live tests were interrupted when computer control was stopped with the physical Escape key. Check standing still, walking, jumping, repeated F6 switches and death/respawn before calling the related findings resolved. Compilation and automated tests do not establish those live results.

## Remaining play checks, in priority order

1. **Repeated F6:** switch ten times on original ground, then after walking/jumping; the scout should resume at the same place with working climbing/items. Do not switch while supported only by a Minecraft block.
2. **Building and crafting:** place/break blocks on flat and sloped ground, open a crafting table, craft an item, use a chest, and verify the result after a restart.
3. **Death and recovery:** in Survival, test falling, PEAK hazards and Minecraft death; verify respawn/end screen/return to airport. Confirm a parked Minecraft death cannot kill the scout in PEAK mode.
4. **Save/exit/relaunch:** close PEAK normally; verify the hidden Minecraft client saves and exits, then relaunch without a duplicate client and confirm inventory/buildings.
5. **Later expedition transitions:** progress to another segment, campfires, fog and ending/flare in PEAK mode. Confirm collision refresh and teleport handoffs after each load.
6. **Input edges:** inventory/chat open, held movement keys, Alt-Tab, pause, remapped keys and resolution changes; no stuck movement, clicks or cursor lock.
7. **Performance:** a longer run with many blocks/entities, chunk boundaries and water/TNT. Record frame rate, memory and any exporter errors. Use 720p initially.

Multiplayer remains unsupported and is outside these acceptance checks. Mining PEAK terrain and keeping Minecraft blocks solid in normal PEAK mode require additional implementation, not just testing.
