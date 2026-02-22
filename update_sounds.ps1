# PowerShell script to automatically update the availableSounds table in core.lua
# Run this script before /reload in WoW to detect new .mp3 files in Media/

$mediaPath = ".\Media"
$coreLuaPath = ".\core.lua"

# Get all .mp3 files in Media folder
$mp3Files = Get-ChildItem -Path $mediaPath -Filter "*.mp3" | Select-Object -ExpandProperty Name | Sort-Object

# Format as Lua table entries
$soundList = $mp3Files | ForEach-Object { "    `"$_`"," }

# Join with newlines
$soundTable = $soundList -join "`n"

# The full table string
$tableString = "local availableSounds = {`n$soundTable`n}"

# Read the current core.lua content
$content = Get-Content -Path $coreLuaPath -Raw

# Replace the availableSounds table
# Look for the pattern: local availableSounds = { ... }
$pattern = "local availableSounds = \{\s*[^}]*\}"

$content = $content -replace $pattern, $tableString

# Write back to file
$content | Set-Content -Path $coreLuaPath -Encoding UTF8

Write-Host "Updated availableSounds in core.lua with $($mp3Files.Count) MP3 files:"
$mp3Files | ForEach-Object { Write-Host "  - $_" }