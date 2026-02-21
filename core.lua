-- 1. CONFIGURATION
local LUST_ID = 2825 -- Bloodlust (2825) as the primary icon
local SOUND_FILE = "Interface\\AddOns\\LustMusic\\Media\\LustMusic.mp3"
local LUST_SPELL_IDS = { [2825]=true, [32182]=true, [80353]=true, [264667]=true, [390386]=true }
local isTestMode = false
local isPlaying = false
local startTime = nil

--[[
    LUST_SPELL_IDS
    2825   Bloodlust
    32182  Heroism
    80353  Time Warp
    264667 Primal Rage
    390386 Fury of the Aspects
]]

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