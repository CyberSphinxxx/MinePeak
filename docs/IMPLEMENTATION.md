# Implementation

## Installed versions

Verified on this computer on 9 October 2026:

- PEAK 2.6.b, Steam app 3527290 / build 25739797; Unity 6000.3.15f1, Mono.
- BepInEx 5.4.23.3, copied into a separate local profile from the existing installation.
- Minecraft Java 26.3, Fabric Loader 0.19.5, Fabric API 0.161.0+26.3.
- PeakCraft upstream revision `d07030ee527ee2a2facc989f5acae8a317968c02`.
- Portable .NET SDK 10.0.401 and Temurin Java 25.0.4.1+1, downloaded and checked against publisher hashes. Details are in ignored `.tools/toolchain.json`.
- Gradle wrapper 9.7.1 and Fabric Loom 1.18.3. Loom is pinned to this release for repeatable builds.

The local launcher uses the user's official Minecraft account without reading or storing its authentication tokens. Normal Minecraft saves/mods and the existing Thunderstore profile remain separate.

## How it works

Minecraft runs its real client and integrated server. Its window hides once connected. The PEAK BepInEx plugin receives block meshes, textures, avatar geometry and Minecraft HUD pixels through the `Local\MinePeak_v1` shared-memory mapping (protocol 11). PEAK exports nearby scene collision. Keyboard/mouse input in the PEAK window goes to Minecraft when Minecraft owns the body.

F6 starts or ends the handoff. Each new takeover publishes a teleport sequence; Minecraft must acknowledge the new position and receive collision before it controls the scout. In PEAK mode, the guest receives the Loading flag, which releases its held inputs and parks its player. The scout then uses PEAK's original climbing and equipment. Minecraft resumes from the scout's current position after the next handoff.

## Local layout

| Path | Purpose |
|---|---|
| `vendor/PeakCraft/peak` | PEAK C# plugin and upstream build files |
| `vendor/PeakCraft/fabric` | Minecraft Fabric mod and collision tests |
| `vendor/PeakCraft/protocol` | Existing cross-game protocol definitions |
| `.tools/dotnet`, `.tools/java`, `.tools/gradle` | Portable build tools/caches, ignored |
| `.runtime/PEAK/BepInEx` | Separate PEAK profile, ignored |
| `.runtime/minecraft` | Official MinePeak game directory, ignored |
| `.runtime/minecraft-dev` | Development run directory, ignored |
| `dist/MinePeak` | Mod-only build output and notices, ignored |

Minecraft Launcher stores a new custom profile `minepeak` in its normal `launcher_profiles.json`, plus public Fabric version metadata. The original profiles file was backed up locally before editing. Minecraft's base game libraries/assets are downloaded by its official launcher. Do not put account files or proprietary game assemblies into Git or a release bundle.

The ignored `.runtime/launch-paths.cmd` records the installed Steam and Minecraft Launcher executable paths. The launch command selects the separate BepInEx preloader using Doorstop's target-assembly option. It does not replace the user's existing Thunderstore mods.

## Build

On this configured computer, run `scripts/Build.ps1` from PowerShell. It builds both mods and runs the existing Java geometry tests, then creates `dist/MinePeak`. Use `-Install` only after closing PEAK and Minecraft. The play launcher copies a rebuilt PEAK plugin from `dist` before starting the next session.

For another computer, install Java 25 and .NET SDK 10, configure the game and BepInEx paths in `vendor/PeakCraft/peak/Config.Build.user.props` using its upstream template, install Fabric 26.3 and Fabric API in a separate Minecraft game directory, and match both sides' mapping name. The current launcher is configured for this machine; the bundle is not a universal installer.

The official-launcher route started successfully. Gradle `runClient` encountered a Windows Application Control block on a native OpenGL library. The security policy was not changed.

## MinePeak changes

- Isolated Minecraft development directory and shared mapping; Discord Rich Presence disabled; no e4mc tunnel dependency.
- Explicit F6 mode switch, normal PEAK controls on startup, status display, reserved mode-switch key and HUD restoration on plugin unload.
- PEAK mode ignores Minecraft death events to prevent a parked guest from killing the active scout.
- A key configured as `None` disables mode-switch polling safely.
- Ragdoll movement uses snapshots of all physics body positions instead of moving only a transform root. This addresses a drift observed in the original follower. The change is built and installed, but live verification of physics and transitions remains incomplete; see VERIFICATION.md.
- Both bridge display names and the PEAK package metadata use MinePeak. PeakCraft/SkyCraft remain upstream credits and inherited internal identifiers, not the current project name.

## Scope

No protocol extension, terrain mining, networking of Minecraft blocks to PEAK peers, or Unity colliders for placed blocks was implemented. The Java mod retains upstream Minecraft crafting, block placement, entity rendering, starter supplies and experimental Survival damage handling. Upstream paths and log messages still use some SkyCraft/Skyrim names.
