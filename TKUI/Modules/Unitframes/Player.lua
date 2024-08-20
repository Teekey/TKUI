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
local function CreatePlayerFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self)
    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateCastBar(self)
    UF.CreateClassResources(self)
    UF.CreateDebuffs(self)
    UF.CreateRaidTargetIndicator(self)
    return self
end

----------------------------------------------------------------------------------------
-- Player Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the player frame style
oUF:RegisterStyle('TKUI_Player', CreatePlayerFrame)
oUF:SetActiveStyle('TKUI_Player')

-- Spawn the player frame
local player = oUF:Spawn("player", "oUF_Player")
player:SetPoint(unpack(C.position.unitframes.player))
player:SetSize(frame_width, frame_height)


----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
UF.CreatePlayerFrame = CreatePlayerFrame
