# Play MinePeak

This installation runs real Minecraft Java 26.3 alongside PEAK 2.6.b. PEAK draws Minecraft's blocks, items and inventory; Minecraft handles building, crafting and its player physics. This first version is for **Play Solo**.

## Start playing

1. Close any ordinary PEAK session. Double-click **Play MinePeak.cmd** in this folder.
2. In **Minecraft Launcher → Minecraft: Java Edition**, select **MinePeak** beside Play, then click **Play**. If it is missing, open **Installations**, enable the **Modded** filter, and select MinePeak there. Use your normal signed-in account.
3. In PEAK, choose **Play Solo**. Wait for the MinePeak status box to say the Minecraft world is ready. The Minecraft window hides automatically; play in the **PEAK window**.
4. Start in normal PEAK mode: use your passport/boarding pass and board the plane as usual.
5. After landing, close all menus and press **F6**. The Minecraft hotbar appears over PEAK. You can move, jump, build and open Minecraft inventory there.
6. Press **F6** again to restore PEAK climbing and PEAK items. Switch on original PEAK ground: Minecraft blocks are hidden and do not support the scout in PEAK mode.

The first launch can take a minute while Minecraft prepares its separate world. The status box at the bottom left shows the active mode. If it says “Waiting for Minecraft,” check that you launched the **MinePeak** profile, not your regular Minecraft installation.

The hardening fixes are installed. Repeated F6 switches and death/respawn still need live verification with that version. See `docs\VERIFICATION.md` for the audit results and remaining checks.

## Controls

| Key | Minecraft mode |
|---|---|
| F6 | Switch to/from PEAK controls; close both games' menus first |
| WASD / Space / Shift | Move / jump / sneak |
| Left / right mouse | Break Minecraft blocks / place or use selected item |
| 1–9 / mouse wheel | Minecraft hotbar |
| E | Minecraft inventory; the world starts in Creative |
| T | Minecraft chat and commands |
| F5 | Minecraft camera views, including your character |
| G | Interact with PEAK objects; hold when needed |
| O | Minecraft pause menu |
| Esc | Close an open Minecraft screen; otherwise open PEAK's pause menu |

In **PEAK mode**, the original PEAK bindings apply, including climbing, stamina, equipping items and using the summit flare. Your Minecraft player waits until you switch back, then moves to the scout's new position.

## Try building

Press F6, then E. Pick oak planks or a crafting table from the Creative inventory, put it on the hotbar, close inventory and right-click the PEAK ground. Left-click breaks the placed Minecraft block. You also receive a starter/builder kit in this separate world.

Crafting is Minecraft's real crafting. To try Survival after choosing supplies, open chat with T and enter `/gamemode survival`; use `/gamemode creative` to return. Survival is experimental: PEAK hazards can deal Minecraft damage. Use Creative for the first run.

## Quit and saves

Close PEAK normally through its menu. The linked Minecraft instance saves and quits after a few seconds. Avoid starting a second MinePeak instance while the first is still running.

Your MinePeak world is under `.runtime\minecraft\saves\SkyCraft` in this folder. Your regular `.minecraft\mods` and saves are separate. Buildings currently persist in that mirror world, even when PEAK loads another expedition. For a clean building world, close both games and move the `SkyCraft` save folder somewhere safe before launching again.

Launching PEAK normally from Steam or your existing Thunderstore profile uses that installation. This launcher selects MinePeak's separate BepInEx profile.

## Current limits

- Solo is the supported mode. Other PEAK players do not receive these Minecraft blocks.
- PEAK's mountain is collision scenery, not Minecraft terrain you can mine. You can place and break actual Minecraft blocks on it.
- Minecraft building/physics and normal PEAK climbing are separate modes. Minecraft blocks disappear in PEAK mode and do not have PEAK colliders.
- Normal Minecraft terrain generation is absent: this is a mirror world over PEAK, not a second full landscape pasted over the mountain.
- Start at 1280×720, as the launcher does. Higher resolutions increase the cost of transferring Minecraft's interface.

## Troubleshooting

- **MinePeak missing:** Java Edition → Installations → enable Modded. Restart Launcher if it was open while the profile was added.
- **No status box:** exit PEAK and use **Play MinePeak.cmd**. Opening the already-running ordinary game cannot load this plugin.
- **F6 has no effect:** close inventory, chat and pause menus, then wait for loading/cutscenes to finish.
- **Stuck or lagging:** switch back to PEAK mode, wait for the Minecraft world to finish loading, then try again. PEAK mode also returns automatically if Minecraft disconnects.
- **Minecraft crashes:** its log is `.runtime\minecraft\logs\latest.log`; PEAK's mod log is `.runtime\PEAK\BepInEx\LogOutput.log`. Do not post launcher account files or authentication details.
- **Windows Application Control blocks a graphics DLL:** use the official Launcher profile. The development launch encountered this block; do not disable Windows protection just to run the development command.
