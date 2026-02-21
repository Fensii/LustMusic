# LustMusic Addon

A World of Warcraft addon that enhances lust effects (Bloodlust, Heroism, etc.) with a visual countdown icon and music.

## Installation

1. Download or copy the `LustMusic` folder.
2. Place it in your `World of Warcraft/_retail_/Interface/AddOns/` directory.
3. Ensure the `Media` folder contains the required sound files: `LustMusic.mp3`.
4. Restart WoW or reload your UI with `/reload`

## Features

- **Visual Countdown**: When a lust effect is active, a movable icon appears showing a countdown from 40 to 0 seconds.
- **Music Playback**: Plays `LustMusic.mp3` on the Dialog channel when lust starts.
- **Position Saving**: The icon's position is saved and restored between sessions.
- **Test Mode**: Use `/lusttest` to test the icon without needing a lust effect.

## Usage

- The addon works automatically when lust effects are applied (e.g., Bloodlust, Heroism, Time Warp, etc.).
- Icon appears, counts down, and hides when the effect ends.
- In test mode (`/lusttest`):
  - Icon shows with a 40-second countdown.
  - Hold left-click to drag and reposition the icon.
  - Run `/lusttest` again to hide and lock it.

## Supported Spells

- Bloodlust
- Heroism
- Time Warp
- Primal Rage
- Fury of the Aspects

## Notes

- Sounds play on the Dialog channel, respecting your Dialog volume settings.
- The icon is locked during real lust effects to prevent accidental movement.
- If you encounter issues, check for addon conflicts or ensure sound files are present.

## Version

1.0</content>
