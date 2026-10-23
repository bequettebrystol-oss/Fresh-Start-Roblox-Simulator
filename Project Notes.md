# Fresh Start

## Current project

- Roblox Studio game: **Fresh Start**.
- Place ID: `86677440142411`.
- GitHub repository: [Fresh-Start-Roblox-Simulator](https://github.com/bequettebrystol-oss/Fresh-Start-Roblox-Simulator).
- Studio connection verified in Edit mode on October 23, 2026.
- Goal: a simple, fast, attractive simulator with collection and upgrades.
- Selected concept: **Brainrot Signal Simulator**. The first playable version is installed in Fresh Start.

## Change workflow

After every completed project change, update these notes and commit and push the change and notes to the designated GitHub repository. Include game source or project files when the game changes.

## Change log

### October 23, 2026 — Build the first playable signal simulator

- Built a bright backyard radio yard with six personal stations, desks, antenna towers, broadcast booths, paths, lamps, trees, fences, and a mystery beacon. Preserved the original template baseplate and spawn in ServerStorage.
- Added clear/easy and faint/risky signal searches, moving tuning targets, gradual silhouette reveals, server-checked capture progress, and short result screens.
- Added twelve original procedural characters across Backyard FM, Moonwave, and Voidcast. Each character has a distinct color or accessory. The collection tracks duplicates, which amplify income up to ten copies.
- The strongest three different characters automatically perform in booths and earn money every second. Antenna purchases unlock bands; receiver purchases widen the tuning window. Equipment visibly upgrades.
- Added recurring 45-second mystery broadcasts that improve rare odds across unlocked bands, with a shared countdown and animated beacon.
- Added keyboard, mouse, and touch tuning controls, collection screens, reactive radio pings, and separate compact phone layouts. Movement touch controls hide while a radio menu is open.
- Added live-server data loading, session leases, periodic/leave/shutdown saves, and temporary-session behavior when data access fails. Studio intentionally avoids production data.
- Added five canonical source files, a Rojo mapping, build instructions, a generated `.rbxlx` starter place, and an Edit-mode installer that reconstructs the scene from source.
- Validation: completed multiple captures, duplicate amplification, automatic booth selection, passive income, both antenna unlocks, a receiver upgrade, and a faint third-band capture during a mystery event. Automated tracking used the normal server remote and earned in-session money; no test currency grants were used.
- Validation: rejected locked bands, unaffordable purchases, invalid/NaN/infinite dial values, and searches away from the player's radio. Verified real menu clicks, cancellation, and keyboard dial movement from 0.50 to 0.73.
- Validation: inspected desktop and iPhone 17 Pro landscape/portrait layouts; improved the compact menu and removed touch-control overlap. Restored Studio to the default viewport and Edit mode. No game runtime errors appeared in the checked console.
- Validation: constructed all twelve character models; verified all five Studio script sources exactly match local files, and all five packaged sources match the originals. Parsed the generated place XML.
- Remaining release checks: published-server save/rejoin behavior and multi-client isolation. Set server capacity to six before public release. Audio uses a bundled pitch-shifted radio ping; bespoke creature voices/static remain future polish. The generated recovery place has not been independently opened in Studio.
- GitHub delivery includes game source, notes, build tools, and generated recovery files. This does not publish the experience to Roblox.

### October 23, 2026 — Record project workflow

- Added persistent instructions in `AGENTS.md` for updating notes and pushing completed changes to GitHub.
- Created these project notes to track decisions, changes, and validation.
- Checked the current workspace: it contains a new Obsidian vault and is not yet a Git repository.
- Verified that the designated GitHub repository has no existing branches or commits before initializing this workspace.
- Excluded Obsidian settings from version control. The starter vault notes are not included in this initial commit.
- No game content was changed. Roblox game source has not yet been exported; this initial commit contains project notes and workflow instructions.
