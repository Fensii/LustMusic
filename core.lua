-- 1. CONFIGURATION
local LUST_ID = 2825 -- Bloodlust (2825) as the primary icon
local SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\LustMusic.mp3"
local LUST_SPELL_IDS = { [2825]=true, [32182]=true, [80353]=true, [264667]=true, [390386]=true }
local availableSounds = {
    "LustMusic.mp3",
    "pedrolust.mp3",
}
local isTestMode = false
local isPlaying = false
local startTime = nil

-- LUST_SPELL_IDS
-- 2825   Bloodlust
-- 32182  Heroism
-- 80353  Time Warp
-- 264667 Primal Rage
-- 390386 Fury of the Aspects

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
settingsFrame:SetSize(300, 200)
settingsFrame:SetPoint("CENTER")
settingsFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = {left = 11, right = 12, top = 12, bottom = 11}})
settingsFrame:Hide()

local isPreviewPlaying = false

local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -16)
title:SetText("LustMusic Settings")

local soundDropdown = CreateFrame("Frame", "LustMusicSoundDropdown", settingsFrame, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("TOPLEFT", 20, -40)
UIDropDownMenu_SetWidth(soundDropdown, 200)

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
playButton:SetSize(100, 25)
playButton:SetPoint("TOPLEFT", 20, -80)
playButton:SetText("Play Preview")
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
        local _, handle = PlaySoundFile(soundPath, "Dialog")
        settingsFrame.previewHandle = handle
        isPreviewPlaying = true
        playButton:SetText("Stop Preview")
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

local closeButton = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
closeButton:SetSize(100, 25)
closeButton:SetPoint("BOTTOM", 0, 20)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    -- Stop preview if playing when closing
    if isPreviewPlaying then
        if settingsFrame.previewHandle then
            StopSound(settingsFrame.previewHandle)
            settingsFrame.previewHandle = nil
        end
        isPreviewPlaying = false
        playButton:SetText("Play Preview")
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
frame:RegisterUnitEvent("UNIT_AURA", "player")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if LustMusicPos then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LustMusicPos.x, LustMusicPos.y)
        end
        if not LustMusicSelectedSound then
            LustMusicSelectedSound = availableSounds[1]
        end
        SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\" .. LustMusicSelectedSound
        return
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
        local _, handle = PlaySoundFile(SOUND_FILE, "Dialog")
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

-- 7. LOCK/UNLOCK & TEST COMMAND
SLASH_LUSTTEST1 = "/lusttest"
SlashCmdList["LUSTTEST"] = function()
    isTestMode = not isTestMode -- Toggle the test state

    if isTestMode then
        -- UNLOCKED & VISIBLE
        frame:Show()
        frame:Raise()
        frame:SetMovable(true)
        frame:EnableMouse(true)
        startTime = GetTime()
        frame:SetScript("OnUpdate", UpdateCooldown)
        print("|cffffff00[LustMusic]:|r Test Mode ON. Icon is UNLOCKED. Drag it now!")
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
    end
end

-- 8. SETTINGS COMMAND
SLASH_LUSTSETTINGS1 = "/lustsettings"
SlashCmdList["LUSTSETTINGS"] = function()
    settingsFrame:Show()
    UIDropDownMenu_Initialize(soundDropdown, InitializeSoundDropdown)
    UIDropDownMenu_SetSelectedValue(soundDropdown, LustMusicSelectedSound or availableSounds[1])
end