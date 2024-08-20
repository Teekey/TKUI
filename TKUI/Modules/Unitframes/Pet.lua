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
local function CreatePetFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self, "Default")

    -- Create frame elements
    UF.CreateHealthBar(self)
    return self
end

----------------------------------------------------------------------------------------
-- Player Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the player frame style
oUF:RegisterStyle('TKUI_Pet', CreatePetFrame)
oUF:SetActiveStyle('TKUI_Pet')

-- Spawn the player frame
local pet = oUF:Spawn("pet", "oUF_Pet")
pet:SetPoint(unpack(C.position.unitframes.pet))
pet:SetSize(frame_width, frame_height)


----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
UF.CreatePetFrame = CreatePetFrame