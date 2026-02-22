# LustMusic Addon

A World of Warcraft addon that enhances lust effects (Bloodlust, Heroism, etc.) with a visual countdown icon and customizable music playback.

## Installation

1. Download or copy the `LustMusic` folder.
2. Place it in your `World of Warcraft/_retail_/Interface/AddOns/` directory.
3. Add your `.mp3` sound files to the `Media/` folder.
4. Run the `update_sounds.ps1` script to automatically update the addon with your sound files:
   ```
   powershell -ExecutionPolicy Bypass -File update_sounds.ps1
   ```
5. Restart WoW or reload your UI with `/reload`.

## Features

- **Visual Countdown**: When a lust effect is active, a movable icon appears showing a countdown from 40 to 0 seconds.
- **Customizable Music**: Choose from multiple sound files in the `Media/` folder.
- **Settings Interface**: Use `/lustsettings` to open a GUI for selecting sounds and previewing them.
- **Sound Preview**: Test sounds with a 40-second preview that can be stopped early.
- **Position Saving**: The icon's position is saved and restored between sessions.
- **Selected Sound Persistence**: Your chosen sound file is remembered between sessions.
- **Test Mode**: Use `/lusttest` to test the icon without needing a lust effect.

## Usage

### Automatic Playback
- The addon works automatically when lust effects are applied (e.g., Bloodlust, Heroism, Time Warp, etc.).
- Icon appears, counts down, and hides when the effect ends.
- Selected music plays for the duration of the effect.

### Settings Menu (`/lustsettings`)
- **Sound Selection**: Dropdown menu showing available sound files (without .mp3 extension).
- **Preview Button**: Click "Play Preview" to hear the first 40 seconds of the selected sound.
- **Stop Preview**: Click "Stop Preview" to stop playback early.
- **Close**: Saves your selection and closes the menu.

### Test Mode (`/lusttest`)
- Icon shows with a 40-second countdown.
- Hold left-click to drag and reposition the icon.
- Run `/lusttest` again to hide and lock it.

### Adding New Sounds
1. Place new `.mp3` files in the `Media/` folder.
2. Run `update_sounds.ps1` to update the addon.
3. Reload UI with `/reload`.
4. Use `/lustsettings` to select the new sound.

## Supported Spells

- Bloodlust (2825)
- Heroism (32182)
- Time Warp (80353)
- Primal Rage (264667)
- Fury of the Aspects (390386)

## Commands

- `/lustsettings` - Open the sound selection menu
- `/lusttest` - Toggle test mode for positioning the icon

## Notes

- Sounds play on the Dialog channel, respecting your Dialog volume settings.
- The icon is locked during real lust effects to prevent accidental movement.
- Sound files must be in MP3 format.
- The PowerShell script requires execution policy bypass on some systems.
- If you encounter issues, check for addon conflicts or ensure sound files are present and the script has been run.

## Version

1.1</content>
