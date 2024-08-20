local T, C, L = unpack(TKUI)
local _, ns = ...
local oUF = ns.oUF
local NP = T.UF

-- Upvalues
local unpack = unpack
local frame_width = C.unitframe.frame_width
local frame_height = C.unitframe.health_height + C.unitframe.power_height + 1

----------------------------------------------------------------------------------------
-- Player Frame Creation
----------------------------------------------------------------------------------------
local function CreateNameplate(self)
    -- Configure base unit frame
    NP.ConfigureNameplate(self)

    -- Create frame elements
    NP.CreateHealthBar(self)
    NP.CreatePowerBar(self)
    NP.CreateCastBar(self)
    NP.CreateNameText(self)
    NP.CreateAuras(self)
    NP.CreateRaidIcon(self)
    NP.CreateQuestIcon(self)
    NP.CreateTargetGlow(self)
    NP.CreateTargetArrows(self)

    return self
end

----------------------------------------------------------------------------------------
-- Player Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the player frame style
oUF:RegisterStyle("TKUINameplates", CreateNameplate)
oUF:SetActiveStyle("TKUINameplates")
oUF:SpawnNamePlates("TKUINameplates", NP.Callback)



----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
NP.CreateNameplate = CreateNameplate