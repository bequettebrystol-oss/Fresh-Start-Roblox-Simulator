# Brainrot Signal Simulator

A first playable Roblox simulator built for **Fresh Start**, place `86677440142411`.

Tune a radio, follow a moving frequency window, capture strange characters, and let your best performers earn money. Twelve original characters have distinct colors and accessories. Duplicates amplify a character's income, up to ten copies. The collection retains additional copies. Stations now have 76×58-stud decks, higher ceilings, an equipment workbench, a wider porch, and room for six booths.

## Play

In the connected Fresh Start Studio project, press **Play**, then use **Tune Radio** or the prompt on your desk. Choose a band and clear/easy or faint/risky reception. Drag the white marker, hold the left/right buttons, or use A/D or arrow keys to follow the glowing target. Hold Shift for finer keyboard control. Directional hints and a faint forecast marker help you follow the target.

The base capture requires 3.5 seconds of lock. Staying inside the gold center builds progress 25% faster. Brief slips preserve progress for a grace period before it decays at 0.30 seconds per second. There is a half-second acquisition period before progress begins; signals time out after 40 seconds. Sustained perfect tracking earns 25% extra capture cash. Signal position and input freshness are checked on the server, with bounded server-measured latency compensation.

Your strongest three different characters initially occupy your booths; booth upgrades expand this to six. Money arrives every second, boosted by broadcast amplifiers. Use **Upgrades** or the prompt on the equipment workbench to browse current/next effects, prices, and levels. Purchases require enough money and cannot occur during a capture. Opening the workbench cancels an active capture.

| Upgrade | Maximum level | Effect | Purchase prices |
| --- | --- | --- | --- |
| Antenna | 3 | Unlock Moonwave and Voidcast | $350 / $2,400 |
| Receiver | 8 | Wider tuning window, +2.2 percentage points per level | $100 / $300 / $900 / $2,500 / $6,000 / $14,000 / $30,000 |
| Signal stabilizer | 5 | 8% slower drift per level; grace grows from 0.20s to 0.44s | $125 / $450 / $1,500 / $4,500 |
| Signal decoder | 5 | Required lock falls from 3.5s to 2.1s | $180 / $650 / $2,200 / $7,000 |
| Broadcast amplifier | 6 | +25% broadcast income per level, up to +125% | $150 / $550 / $1,800 / $5,500 / $16,000 |
| Extra broadcast booths | 4 | Increase active booths from three to six | $500 / $2,000 / $6,500 |

A mystery broadcast first appears after 90 seconds, then every three minutes, lasting 45 seconds and improving rare odds in all unlocked bands. Faint signals retain better rare odds than clear signals during these events.

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

Studio sessions intentionally do not read or write production player data. In a published Roblox server, the game uses `BrainrotSignal_v1` with periodic saves, session leases, leave saves, and shutdown saves. Existing antenna, receiver, collection, and currency data are retained; new upgrade categories default to level one. All six upgrade levels are saved. If initial data access fails, the session is clearly marked as temporary and does not overwrite stored progress. Test live saving and rejoining in a private published server before release.

The yard supports **six players**. Set the Roblox experience's server capacity to six before public release. Multi-client isolation, disconnect/rejoin persistence, and live-service failures still need a published-server test. Character audio currently uses a bundled radio ping whose pitch changes with signal strength; bespoke creature voices and static are future polish.

Every completed change is recorded in `Project Notes.md` and pushed together with its source.
