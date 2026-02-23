# LustMusic Changelog

## v0.2.1 — 2026-02-23
Summary: Enhanced sound control with channel selection and per-channel volume, improved UI layout, and bug fixes.

### Added
- **Advanced Sound Control**: Introduced the ability to select a specific sound channel for playback (e.g., Master, SFX, Music, Dialog) and adjust its volume independently.
- **Per-Channel Volume Persistence**: Volume settings are now saved per sound channel, ensuring your preferences are retained across game sessions.
- **Contextual UI Elements**: The "Reset Position" button now intelligently appears only when the icon is in test/movable mode, streamlining the interface.

### Changed
- **Enhanced Settings UI Layout**: The settings panel has been reorganized and aligned for a cleaner, more intuitive user experience, including repositioning controls and labels.
- **Dynamic Volume Slider**: The volume slider now dynamically reflects and controls the volume of the currently selected sound channel.
- **Improved Preview Functionality**: The sound preview button's text is clearer, and the preview itself now respects the chosen sound channel.
- **Internal Data Management**: Updated saved variables and initialization logic to support the new per-channel volume system, improving robustness.

### Fixed
- **Initialization Robustness**: Addressed issues related to variable initialization order and data type handling, preventing errors during addon loading and UI interactions.

### Removed / Deprecated
- Legacy volume saved variable, replaced by the more flexible per-channel volume system.

### Notes
- Users can now fine-tune where and how their custom LustMusic sounds are played, offering greater control over their audio experience.
- The `update_sounds.ps1` script remains unchanged and should be run after adding new `.mp3` files.

---

## Original v1.0 (from LustMusic.zip)
- Basic functionality: showed a movable countdown icon during lust and played a single `LustMusic.mp3` file.
- Exposed `/lusttest` to show the icon for positioning.
- Included a simple README (v1.0) and a `PACO` command in the original `core.lua`.
