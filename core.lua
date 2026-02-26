-- 1. CONFIGURATION
local LUST_ID = 2825 -- Bloodlust (2825) as the primary icon
local SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\LustMusic.mp3"
local LUST_SPELL_IDS = {
    [2825] = true,   -- Bloodlust
    [32182] = true,  -- Heroism
    [80353] = true,  -- Time Warp
    [264667] = true, -- Primal Rage
    [390386] = true, -- Fury of the Aspects
    [466904] = true, -- Harrier's Cry
    [381301] = true, -- Drums of Deathly Ferocity (Dragonflight)
    [230935] = true, -- Drums of the Mountain (Legion)
    [256740] = true, -- Drums of the Maelstrom (BFA)
    [178207] = true, -- Drums of Fury (WoD)
    [146555] = true, -- Drums of Rage (MoP)
}
local availableSounds = {
    "BlingBangBangBorn.mp3",
    "pedrolust.mp3",
    "pumpit.mp3",
}
local isTestMode = false
local isPlaying = false
local startTime = nil

-- Ensure saved variables are initialized as tables if they don't exist
LustMusicChannelVolumes = LustMusicChannelVolumes or {}

-- 2. CREATE THE MAIN FRAME
local frame = CreateFrame("Button", "LustMusicIconFrame", UIParent, "BackdropTemplate")
frame:SetSize(60, 60)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetFrameStrata("DIALOG")
frame:Hide() -- Hide by default until Lust starts

-- 3. VISUALS (Icon and Text)
local tex = frame:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints()
tex:SetTexture(C_Spell.GetSpellTexture(LUST_ID)) -- Gets the red wolf icon

local cdText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
cdText:SetPoint("CENTER")
cdText:SetTextColor(1, 1, 1) -- White text

-- 3.5 SETTINGS FRAME
local settingsFrame = CreateFrame("Frame", "LustMusicSettings", UIParent, "BackdropTemplate")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = {left = 11, right = 12, top = 12, bottom = 11}})
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", settingsFrame.StartMoving)
settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    LustMusicSettingsPos = { point = point, relativePoint = relativePoint, x = x, y = y }
end)
settingsFrame:Hide()

local isPreviewPlaying = false

local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("CENTER", settingsFrame, "TOP", -10, -16)
title:SetText("LustMusic Settings")
title:SetJustifyH("CENTER")

local soundDropdown = CreateFrame("Frame", "LustMusicSoundDropdown", settingsFrame, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 140, -40)
UIDropDownMenu_SetWidth(soundDropdown, 140)
soundDropdown.Text:SetJustifyH("LEFT")
soundDropdown.Text:ClearAllPoints() -- This line is good, ensures previous points are removed
soundDropdown.Text:SetPoint("RIGHT", soundDropdown.Button, "LEFT", -8, 0)

local soundLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
soundLabel:SetPoint("RIGHT", soundDropdown, "LEFT", 0, 0)
soundLabel:SetText("Select Sound:")

local function InitializeSoundDropdown()
    local info = UIDropDownMenu_CreateInfo()
    for i, sound in ipairs(availableSounds) do
        info.text = sound:sub(1, -5)  -- Remove .mp3 extension for display
        info.value = sound
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(soundDropdown, self.value)
            LustMusicSelectedSound = self.value
            SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\" .. self.value
        end
        info.checked = (LustMusicSelectedSound == sound)
        UIDropDownMenu_AddButton(info)
    end
end

local playButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
playButton:SetSize(100, 22) -- Slightly reduced height for better spacing
playButton:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 158, -80)
playButton:SetText("Play Preview")

local previewLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
previewLabel:SetPoint("RIGHT", playButton, "LEFT", -18, 0)
previewLabel:SetText("Preview:")

playButton:SetScript("OnClick", function()
    if isPreviewPlaying then
        -- Stop the preview
        if settingsFrame.previewHandle then
            StopSound(settingsFrame.previewHandle)
            settingsFrame.previewHandle = nil
        end
        isPreviewPlaying = false
        playButton:SetText("Play Preview")
    else
        -- Start the preview
        local selected = UIDropDownMenu_GetSelectedValue(soundDropdown) or availableSounds[1]
        local soundPath = "Interface\\AddOns\\LustMusic\\Media\\" .. selected
        local _, handle = PlaySoundFile(soundPath, LustMusicSoundChannel) -- Use selected channel for preview
        settingsFrame.previewHandle = handle
        isPreviewPlaying = true
        playButton:SetText("Stop")
        C_Timer.After(40, function()
            if isPreviewPlaying then
                if settingsFrame.previewHandle then
                    StopSound(settingsFrame.previewHandle)
                    settingsFrame.previewHandle = nil
                end
                isPreviewPlaying = false
        playButton:SetText("Play Preview")
            end
        end)
    end
end)

local testButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
testButton:SetSize(100, 22)
testButton:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 158, -110)
testButton:SetText("Show Icon")

local testLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
testLabel:SetPoint("RIGHT", testButton, "LEFT", -18, 0)
testLabel:SetText("Test Icon:")

local resetButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
resetButton:SetSize(100, 22)
resetButton:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 158, -140)
resetButton:SetText("Reset Pos")
resetButton:Hide() -- Hide by default

testButton:SetScript("OnClick", function()
    isTestMode = not isTestMode -- Toggle the test state

    if isTestMode then
        -- UNLOCKED & VISIBLE
        frame:Show()
        frame:Raise()
        frame:SetMovable(true)
        frame:EnableMouse(true)
        startTime = GetTime()
        resetButton:Show() -- Show reset button when test mode is on
        frame:SetScript("OnUpdate", UpdateCooldown)
        print("|cffffff00[LustMusic]:|r Test Mode ON. Icon is UNLOCKED. Drag it now!")
        testButton:SetText("Hide Icon")
    else
        -- LOCKED & HIDDEN
        frame:Hide()
        frame:SetMovable(false)
        frame:EnableMouse(false)
        frame:SetScript("OnUpdate", nil)
        if frame.activeSoundHandle then StopSound(frame.activeSoundHandle) end
        isPlaying = false
        startTime = nil
        print("|cff00ff00[LustMusic]:|r Test Mode OFF. Icon is LOCKED and hidden.")
        resetButton:Hide() -- Hide reset button when test mode is off
        testButton:SetText("Unlock")
    end
end)

resetButton:SetScript("OnClick", function()
    LustMusicPos = nil
    LustMusicSettingsPos = nil
    frame:ClearAllPoints()
    frame:SetPoint("CENTER")
    settingsFrame:ClearAllPoints()
    settingsFrame:SetPoint("CENTER")
    print("|cff00ff00[LustMusic]:|r Positions reset to default.")
end)

-- Sound Channel Dropdown
local channelDropdown = CreateFrame("Frame", "LustMusicChannelDropdown", settingsFrame, "UIDropDownMenuTemplate")
channelDropdown:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 140, -170) -- Position below reset button
UIDropDownMenu_SetWidth(channelDropdown, 140)
channelDropdown.Text:SetJustifyH("LEFT")
channelDropdown.Text:ClearAllPoints()
channelDropdown.Text:SetPoint("RIGHT", channelDropdown.Button, "LEFT", -8, 0)

local channelLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
channelLabel:SetPoint("RIGHT", channelDropdown, "LEFT", 0, 0)
channelLabel:SetText("Sound Channel:")

-- Volume Slider
local volumeSlider = CreateFrame("Slider", "LustMusicVolumeSlider", settingsFrame, "OptionsSliderTemplate")
volumeSlider:SetSize(140, 17)
volumeSlider:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 158, -200) -- Position below channel dropdown
volumeSlider:SetMinMaxValues(0, 1) -- Volume is typically 0 to 1
volumeSlider:SetValueStep(0.01)
volumeSlider:SetObeyStepOnDrag(true)

local volumeLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
volumeLabel:SetPoint("RIGHT", volumeSlider, "LEFT", -18, 0)
volumeLabel:SetText("Channel Volume:")

volumeSlider:SetScript("OnValueChanged", function(self, value)
    if LustMusicSoundChannel then
        local cvarName = "Sound_" .. LustMusicSoundChannel .. "Volume"
        SetCVar(cvarName, value)
        LustMusicChannelVolumes[LustMusicSoundChannel] = value -- Save the new volume for the selected channel
    end
end)

local function InitializeChannelDropdown()
    local channels = { "Master", "SFX", "Music", "Dialog", "Ambience", "Voice" }
    local info = UIDropDownMenu_CreateInfo()
    for i, channel in ipairs(channels) do
        info.text = channel
        info.value = channel
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(channelDropdown, self.value)
            LustMusicSoundChannel = self.value
            -- Update the volume slider to reflect the newly selected channel's volume
            local currentChannelVolume = LustMusicChannelVolumes[self.value] or tonumber(GetCVar("Sound_" .. self.value .. "Volume")) or 1
            volumeSlider:SetValue(currentChannelVolume)
        end
        info.checked = (LustMusicSoundChannel == channel)
        UIDropDownMenu_AddButton(info)
    end
end



local closeButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
closeButton:SetSize(100, 25)
closeButton:SetPoint("BOTTOMRIGHT", -20, 20)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    -- Stop preview if playing when closing
    if isPreviewPlaying then
        if settingsFrame.previewHandle then
            StopSound(settingsFrame.previewHandle)
            settingsFrame.previewHandle = nil
        end
        isPreviewPlaying = false -- Reset state
        playButton:SetText("Play Preview") -- Reset button text
    end
    -- Disable test mode if active
    if isTestMode then
        frame:Hide()
        frame:SetMovable(false)
        frame:EnableMouse(false)
        frame:SetScript("OnUpdate", nil)
        if frame.activeSoundHandle then StopSound(frame.activeSoundHandle) end
        isPlaying = false
        startTime = nil
        isTestMode = false
        resetButton:Hide() -- Hide reset button when settings close and test mode was active
        testButton:SetText("Unlock")
        print("|cff00ff00[LustMusic]:|r Test Mode OFF. Settings closed.")
    end
    settingsFrame:Hide()
end)

-- 4. MAKE IT MOVABLE (Hold Left Click to Drag)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    LustMusicPos = { x = x, y = y } -- Saves the spot for next time!
end)

-- 5. THE COOLDOWN LOGIC
local function UpdateCooldown()
    if not startTime then return end
    local elapsed = GetTime() - startTime
    local countdown = math.max(0, 40 - elapsed)
    cdText:SetFormattedText("%d", countdown)
    if countdown <= 0 then
        frame:Hide()
        frame:SetScript("OnUpdate", nil)
        if frame.activeSoundHandle then StopSound(frame.activeSoundHandle) end
        isPlaying = false
        startTime = nil
    end
end

-- 6. THE EVENT LISTENER
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterUnitEvent("UNIT_AURA", "player")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if LustMusicPos then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LustMusicPos.x, LustMusicPos.y) -- This line seems to have a logical error in the original, should be frame:SetPoint(LustMusicPos.point, UIParent, LustMusicPos.relativePoint, LustMusicPos.x, LustMusicPos.y) if saving point, relativePoint, x, y. For now, just fixing the nil error.
        end
        if LustMusicSettingsPos then
            settingsFrame:ClearAllPoints()
            settingsFrame:SetPoint(LustMusicSettingsPos.point, UIParent, LustMusicSettingsPos.relativePoint, LustMusicSettingsPos.x, LustMusicSettingsPos.y)
        end
        if not LustMusicSelectedSound then
            LustMusicSelectedSound = availableSounds[1]
        end
        if not LustMusicSoundChannel then
            LustMusicSoundChannel = "Dialog" -- Default to Dialog channel
        end
        
        SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\" .. LustMusicSelectedSound

        -- Initialize and apply channel volumes on PLAYER_LOGIN
        local allChannels = { "Master", "SFX", "Music", "Dialog", "Ambience", "Voice" }
        for _, channel in ipairs(allChannels) do
            -- Initialize saved volume for each channel if not present, using current CVar
            LustMusicChannelVolumes[channel] = LustMusicChannelVolumes[channel] or tonumber(GetCVar("Sound_" .. channel .. "Volume")) or 1
            -- Apply saved volume to the game's CVar
            SetCVar("Sound_" .. channel .. "Volume", LustMusicChannelVolumes[channel])
        end
    end

    local activeAura = nil
    
    -- Check if any Lust is active
    for id in pairs(LUST_SPELL_IDS) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)
        if aura then activeAura = aura; break end
    end

    if activeAura and not isPlaying and not isTestMode then
        -- START LUST
        self:Show()
        startTime = GetTime()
        self:SetScript("OnUpdate", UpdateCooldown)
        local _, handle = PlaySoundFile(SOUND_FILE, LustMusicSoundChannel)
        self.activeSoundHandle = handle
        isPlaying = true
    elseif not activeAura and isPlaying and not isTestMode then
        -- END LUST
        self:Hide()
        self:SetScript("OnUpdate", nil)
        if self.activeSoundHandle then StopSound(self.activeSoundHandle) end
        isPlaying = false
        startTime = nil
    end
end)

-- 7. SETTINGS COMMAND
SLASH_LUSTSETTINGS1 = "/lustsettings"
SlashCmdList["LUSTSETTINGS"] = function()
    settingsFrame:Show()
    UIDropDownMenu_Initialize(soundDropdown, InitializeSoundDropdown)
    UIDropDownMenu_SetSelectedValue(soundDropdown, LustMusicSelectedSound or availableSounds[1])
    UIDropDownMenu_Initialize(channelDropdown, InitializeChannelDropdown)
    UIDropDownMenu_SetSelectedValue(channelDropdown, LustMusicSoundChannel or "Dialog")
    -- Set slider to the saved volume of the currently selected channel, with fallback
    local initialSliderValue = LustMusicChannelVolumes[LustMusicSoundChannel] or tonumber(GetCVar("Sound_" .. LustMusicSoundChannel .. "Volume")) or 1
    volumeSlider:SetValue(initialSliderValue)
end
