local T, C, L = unpack(TKUI)
local _, ns = ...
local oUF = ns.oUF
local UF = T.UF

-- Upvalues
local unpack = unpack
local frame_width = C.unitframe.frame_width
local frame_height = C.unitframe.health_height + C.unitframe.power_height + 1

----------------------------------------------------------------------------------------
-- Player Frame Creation
----------------------------------------------------------------------------------------
local function CreateFocusFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateCastBar(self)
    UF.CreateNameText(self)
    UF.CreateAuras(self)
    UF.CreateRaidTargetIndicator(self)
    return self
end

----------------------------------------------------------------------------------------
-- Player Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the player frame style
oUF:RegisterStyle('TKUI_Focus', CreateFocusFrame)
oUF:SetActiveStyle('TKUI_Focus')

-- Spawn the player frame
local focus = oUF:Spawn("focus", "oUF_Focus")
focus:SetPoint(unpack(C.position.unitframes.focus))
focus:SetSize(frame_width, frame_height)


----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
UF.CreateFocusFrame = CreateFocusFrame