# LustMusic Changelog

This changelog summarizes the differences between the original release (from LustMusic.zip) and the current workspace state.

## v2.0 — 2026-02-22
Summary: Major feature additions and UI improvements. Settings GUI, multiple sound support, previewing, and automated sound-list updating were added.

### Added
- Settings window (`/lustsettings`) with GUI for:
  - Sound selection dropdown (shows names without `.mp3` extension)
  - Play/Stop preview button (plays first 40 seconds)
  - "Test Icon" button to show/hide and reposition the countdown icon
  - Close button that cleans up preview/test state
- Persisted selected sound via saved variable `LustMusicSelectedSound` (added in TOC)
- `update_sounds.ps1` — PowerShell helper script to scan `Media/` and update `availableSounds` in `core.lua`
- `CHANGELOG.md` (this file)
- Support for multiple `.mp3` files in `Media/` (dropdown populated from `availableSounds`)

### Changed
- `core.lua` rewritten/extended to include the settings UI and preview/test integrations:
  - Icon is still shown automatically during lust spells, with music playback managed by `PlaySoundFile` and sound handles properly stopped.
  - Test functionality moved into the settings UI ("Test Icon") for easier positioning.
  - Dropdown displays filenames without the `.mp3` extension for user-friendly labels.
- `README.md` updated to document new usage, PowerShell script, and commands.
- Version bumped from `1.0` to `2.0` in README.

### Removed / Deprecated
- `/lusttest` as the primary configuration method — test functionality is now accessed from `/lustsettings`. Any legacy references were removed.
- Any hard-coded single-sound assumption; the addon now supports multiple files.

### Notes & Migration
- To add or remove sounds, place `.mp3` files in the `Media/` folder and run `update_sounds.ps1`, then `/reload` in WoW.
- Because WoW addons cannot enumerate local directories at runtime, `update_sounds.ps1` updates the `availableSounds` Lua table before loading the addon.
- The settings menu automatically stops previews and test mode when closed to avoid leftover audio or UI state.

---

## Original v1.0 (from LustMusic.zip)
- Basic functionality: showed a movable countdown icon during lust and played a single `LustMusic.mp3` file.
- Exposed `/lusttest` to show the icon for positioning.
- Included a simple README (v1.0) and a `PACO` command in the original `core.lua`.

If you'd like, I can:
- Produce a more detailed line-by-line diff between the two `core.lua` files,
- Update the TOC `SavedVariables` or version fields, or
- Add a release-style changelog entry per change (e.g., with dates and authors).
