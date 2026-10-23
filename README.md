# Brainrot Signal Simulator

A first playable Roblox simulator built for **Fresh Start**, place `86677440142411`.

Tune a radio, follow a moving frequency window, capture strange characters, and let your best three performers earn money. Upgrade your antenna to unlock three bands and your receiver to make captures easier. Twelve original characters have distinct colors and accessories. Duplicates amplify a character's income, up to ten copies. The collection retains additional copies.

## Play

In the connected Fresh Start Studio project, press **Play**, then use **Tune Radio** or the prompt on your desk. Choose a band and clear/easy or faint/risky reception. Drag the white marker, hold the left/right buttons, or use A/D or arrow keys to follow the glowing target. Hold a total of 3.5 seconds of lock; missed tracking slowly reduces progress. Signals time out after 35 seconds.

Your strongest three different characters automatically occupy your booths. Money arrives every second. Antennas cost $350 and $2,400; receiver upgrades cost $100, $300, $900, and $2,500. A mystery broadcast first appears after 90 seconds, then every three minutes, lasting 45 seconds and improving rare odds in all unlocked bands.

## Source and recovery

- `game/Config.luau`: collection, bands, upgrade prices, and income rules.
- `game/Creature.luau`: shared procedural character models, including silhouettes.
- `game/World.luau`: reproducible backyard, six stations, trees, lighting, and equipment.
- `game/Server.server.luau`: server-checked captures, currency, upgrades, ownership, events, and persistence.
- `game/Client.client.luau`: responsive menus, tuning controls, reveals, collection, sound, and local performer animation.
- `default.project.json`: optional Rojo mapping.

Run `powershell -ExecutionPolicy Bypass -File tools/Build-Place.ps1` from the repository to regenerate `builds/BrainrotSignal.rbxlx` and `builds/Install.commandbar.luau`. No additional build tools are required.

Open the generated `.rbxlx` in Studio and press Play; the yard is generated automatically. For an editable scene before Play, paste the generated installer into Studio's Command Bar while in Edit mode. It installs the five scripts and builds the yard immediately. The installer replaces only this game's five named scripts and `SignalYard`; the original template baseplate and spawn are preserved under `ServerStorage.SignalTemplateBackup`.

The GitHub build contains source plus a reproducible starter place; the connected Studio scene also contains the generated yard. GitHub pushes do not publish the game to Roblox.

## Saving and release checks

Studio sessions intentionally do not read or write production player data. In a published Roblox server, the game uses `BrainrotSignal_v1` with periodic saves, session leases, leave saves, and shutdown saves. If initial data access fails, the session is clearly marked as temporary and does not overwrite stored progress. Test live saving and rejoining in a private published server before release.

The yard supports **six players**. Set the Roblox experience's server capacity to six before public release. Multi-client isolation, disconnect/rejoin persistence, and live-service failures still need a published-server test. Character audio currently uses a bundled radio ping whose pitch changes with signal strength; bespoke creature voices and static are future polish.

Every completed change is recorded in `Project Notes.md` and pushed together with its source.
