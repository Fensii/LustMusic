# LustMusic Addon

A World of Warcraft addon that enhances lust effects (Bloodlust, Heroism, etc.) with a visual countdown icon and customizable music playback. Features an integrated settings interface for sound selection, preview, and icon positioning.

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
- **Settings Interface**: Use `/lustsettings` to open a GUI for selecting sounds, previewing them, and testing icon positioning.
- **Advanced Sound Control**: Select playback channel (Master, SFX, Music, Dialog, Ambience, Voice) and adjust its volume.
- **Per-Channel Volume Persistence**: Volume settings are saved for each channel, ensuring your preferences are retained across game sessions.
- **Sound Preview**: Test sounds with a 40-second preview that can be stopped early.
- **Icon Positioning**: Test and reposition the countdown icon directly from the settings menu.
- **Contextual UI Elements**: The "Reset Position" button now intelligently appears only when the icon is in test/movable mode, streamlining the interface.
- **Position Saving**: The icon's position is saved and restored between sessions.
- **Selected Sound Persistence**: Your chosen sound file is remembered between sessions.

## Usage

### Automatic Playback
- The addon works automatically when lust effects are applied (e.g., Bloodlust, Heroism, Time Warp, etc.).
- Icon appears, counts down, and hides when the effect ends.
- Selected music plays for the duration of the effect on the chosen sound channel.

### Settings Menu (`/lustsettings`)
- **Sound Selection**: Dropdown menu showing available sound files (without .mp3 extension).
- **Sound Channel Selection**: Dropdown to choose the sound output channel (Master, SFX, Music, Dialog, Ambience, Voice).
- **Channel Volume Slider**: Adjusts the volume for the currently selected sound channel.
- **Preview Button**: Click "Play Preview" to hear the first 40 seconds of the selected sound on the currently chosen channel.
- **Stop Preview**: Click "Stop" to stop playback early.
- **Test Icon Button**: Click "Unlock" to show the countdown icon for positioning. While unlocked, the button changes to "Hide Icon". Click "Hide Icon" to hide the icon and lock it.
- **Reset Pos Button**: Appears when the icon is unlocked, allowing you to reset its position.
- **Close**: Saves your selection and closes the menu (automatically stops test mode if active).

### Test Mode
- Icon shows with a 40-second countdown.
- Hold left-click to drag and reposition the icon.
- Use the "Test Icon" button in the settings menu to enable/disable test mode.
- Test mode automatically disables when closing the settings window.

### Adding New Sounds
1. Place new `.mp3` files in the `Media/` folder.
2. Run `update_sounds.ps1` to update the addon.
3. Reload UI with `/reload`.
4. Use `/lustsettings` to select the new sound.

## Running the PowerShell Script

The `update_sounds.ps1` script updates the addon with your current sound files. Here are different ways to run it:

### Method 1: Command Prompt (Recommended)
1. Open Command Prompt as Administrator
2. Navigate to your addon folder:
3. Right-click and select "Copy as path" on `update_sounds.ps1` in File Explorer 
   ```
   cd "<insert path here>"
   ```
4. Run the script:
   ```
   powershell -ExecutionPolicy Bypass -File update_sounds.ps1
   ```

### Troubleshooting
- **Execution Policy Error**: Use `-ExecutionPolicy Bypass` or change policy with `Set-ExecutionPolicy RemoteSigned`
- **Path Issues**: Make sure you're in the correct directory or use full paths
- **Permission Denied**: Run as Administrator or check folder permissions
- **Script Not Found**: Verify the file exists and has `.ps1` extension

After running the script successfully, you'll see output like:
```
Updated availableSounds in core.lua with 3 MP3 files:
  - file1.mp3
  - file2.mp3
  - file3.mp3
```

## Supported Spells

- Bloodlust (2825)
- Heroism (32182)
- Time Warp (80353)
- Primal Rage (264667)
- Fury of the Aspects (390386)
- Harrier's Cry (466904)
- Drums (various versions: Deathly Ferocity, Mountain, Maelstrom, Fury, Rage)

## Commands

- `/lustsettings` - Open the sound selection menu (includes sound preview and icon positioning)

## Notes

- Sounds play on the Dialog channel, respecting your Dialog volume settings.
- The icon is locked during real lust effects to prevent accidental movement.
- Sound files must be in MP3 format.
- The PowerShell script requires execution policy bypass on some systems.
- If you encounter issues, check for addon conflicts or ensure sound files are present and the script has been run.

## Version

0.2.3
