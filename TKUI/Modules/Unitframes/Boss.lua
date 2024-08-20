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
local function CreateBossFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateCastBar(self)
    UF.CreateNameText(self)
    UF.CreateBossAuras(self)
    UF.CreateRaidTargetIndicator(self)
    self:HookScript("OnShow", UF.UpdateAllElements)

    return self
end

----------------------------------------------------------------------------------------
-- Player Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the player frame style
oUF:RegisterStyle('TKUI_Boss', CreateBossFrame)
oUF:SetActiveStyle('TKUI_Boss')

-- Spawn the player frame
local boss = {}
for i = 1, 8 do
	boss[i] = oUF:Spawn("boss" .. i, "oUF_Boss" .. i)
	if i == 1 then
		boss[i]:SetPoint(unpack(C.position.unitframes.boss))
	else
		boss[i]:SetPoint("BOTTOM", boss[i - 1], "TOP", 0, 90)
	end
	boss[i]:SetSize(frame_width, frame_height)
end

----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
UF.CreateBossFrame = CreateBossFrame