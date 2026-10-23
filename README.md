# Brainrot Signal Simulator

A first playable Roblox simulator built for **Fresh Start**, place `86677440142411`.

Tune a radio, follow a moving frequency window, capture strange characters, and let your best performers earn money. Twelve original characters have distinct colors and accessories. Duplicates add 3% income per copy, up to ten copies (+27%). The collection retains additional copies. Stations have 76×58-stud decks, equipment workbenches, and purchasable second floors with staircases and room for twelve total booths.

## Play

In the connected Fresh Start Studio project, press **Play**, then use **Tune Radio** or the prompt on your desk. Choose a band and clear/easy or faint/risky reception. Drag the white marker, hold the left/right buttons, or use A/D or arrow keys to follow the glowing target. Hold Shift for finer keyboard control. Directional hints and a faint forecast marker help you follow the target.

Base lock requirements are 8/10/12 seconds on clear signals across the three bands, or 10/12/14 seconds on faint signals. Decoders reduce those requirements by up to two seconds. The gold center builds progress 10% faster. Brief slips preserve progress before decay at 0.30 seconds per second. There is a 0.75-second acquisition period; signals time out after 70 seconds. Capture cash is 40% of base creature income, increased 10% for sustained perfect tracking, with a $1 minimum. Signal position and input freshness are checked on the server, with bounded server-measured latency compensation.

Your strongest three different characters initially occupy your booths; ground-floor upgrades expand this to six. Money arrives every second, boosted by broadcast amplifiers. Fractional earnings are retained and displayed, so even a $0.25/sec creature earns money. Base income now ranges from $0.25 to $15/sec. Use **Upgrades** or the equipment workbench to browse current/next effects, prices, and levels. Purchases require enough money and cannot occur during a capture. Opening the workbench cancels an active capture.

## Build upstairs

Walk onto the circle pad near the front of your own station to pay **$6,500** and construct a second floor with a staircase, railings, raised roof, and three extra booths. Upstairs, a second **$35,000** circle pad activates three more booths. With all ground upgrades, this gives six ground and six upstairs slots. Upstairs slots unlock independently of the ground-floor booth upgrades.

Pads use server-side circle occupancy checks. Entering a pad attempts one purchase; step off and back on to retry after insufficient funds. Other players cannot buy your station's floor. Purchased pads disappear. Construction fades in and plays a short chime. Floor ownership is saved and reconstructed on rejoin.

| Upgrade | Maximum level | Effect | Purchase prices |
| --- | --- | --- | --- |
| Antenna | 3 | Unlock Moonwave and Voidcast | $900 / $14,000 |
| Receiver | 8 | Wider tuning window, +2.2 percentage points per level | $80 / $300 / $1,100 / $4,000 / $12,000 / $32,000 / $65,000 |
| Signal stabilizer | 5 | 8% slower drift per level; grace grows from 0.20s to 0.44s | $120 / $500 / $2,100 / $7,500 |
| Signal decoder | 5 | Subtract up to two seconds of required lock | $180 / $850 / $3,800 / $14,000 |
| Broadcast amplifier | 6 | +10% broadcast income per level, up to +50% | $250 / $1,300 / $6,000 / $20,000 / $55,000 |
| Ground floor booths | 4 | Increase ground-floor booths from three to six | $650 / $3,200 / $12,000 |

A mystery broadcast first appears after 90 seconds, then every three minutes, lasting 45 seconds and improving rare odds in all unlocked bands. Faint signals retain better rare odds than clear signals during these events.

## Balance checks

All 27 purchases, including both building pads, cost $298,330. The maximum broadcast income with twelve unique characters, ten copies of each, and all amplifiers is $97.54/sec. The optimistic fresh-start accounting bound is about 50.4 minutes even assuming maximum income from the start; real progression starts much lower. Fifty simplified, perfect-tracking purchase simulations modeled about 87–93 minutes. These are estimates, not a completed human playthrough; pacing still needs live feedback. Existing saved money and upgrades are preserved, so those estimates apply to fresh starts.

Run `tools/Check-Balance.commandbar.luau` in Studio's Command Bar after installation for read-only checks of the current costs, income cap, floor slot mapping, fractional income, and optimistic accounting bound.

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

Studio sessions intentionally do not read or write production player data. In a published Roblox server, the game uses `BrainrotSignal_v1` with periodic saves, session leases, leave saves, and shutdown saves. Existing upgrades, collection, and currency are retained; old profiles default to no upstairs. All six upgrade levels, the floor stage, and fractional money are saved. Building purchases request an immediate save. If initial data access fails, the session is clearly marked as temporary and does not overwrite stored progress. Test live saving and rejoining in a private published server before release.

The yard supports **six players**. Set the Roblox experience's server capacity to six before public release. Multi-client isolation, disconnect/rejoin persistence, and live-service failures still need a published-server test. Character audio currently uses a bundled radio ping whose pitch changes with signal strength; bespoke creature voices and static are future polish.

Every completed change is recorded in `Project Notes.md` and pushed together with its source.
