local T, C, L = unpack(TKUI)
local _, ns = ...
local oUF = ns.oUF
local UF = T.UF

-- Upvalues
local unpack = unpack
local raid_width = C.raidframe.raid_width
local raid_height = C.raidframe.raid_height + C.raidframe.raid_power_height + 4
local raid_power_height = C.raidframe.raid_power_height


----------------------------------------------------------------------------------------
-- Party Frame Creation
----------------------------------------------------------------------------------------
local function CreateRaidFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateNameText(self)
    UF.CreateRaidDebuffs(self)
    UF.CreateRaidTargetIndicator(self)
    UF.CreateDebuffHighlight(self)
    UF.CreateGroupIcons(self)
    UF.ApplyGroupSettings(self)

    return self
end

----------------------------------------------------------------------------------------
-- Target Frame Initialization
----------------------------------------------------------------------------------------
oUF:Factory(function(self)
	oUF:RegisterStyle("TKUI_Raid", CreateRaidFrame)
	oUF:SetActiveStyle("TKUI_Raid")
	local raid = {}
		local raidgroup = self:SpawnHeader("oUF_Raid", nil, "custom [@raid6,exists] show;hide",
			"oUF-initialConfigFunction", [[
					local header = self:GetParent()
					self:SetWidth(header:GetAttribute("initial-width"))
					self:SetHeight(header:GetAttribute("initial-height"))
				]],
			"initial-width", raid_width,
			"initial-height", T.Scale(raid_height),
			"showRaid", true,
			-- "groupFilter", tostring(i),
			"groupBy", C.raidframe.by_role and "ASSIGNEDROLE",
			"groupingOrder", C.raidframe.by_role and "TANK,HEALER,DAMAGER,NONE",
			"sortMethod", C.raidframe.by_role and "NAME",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(14),
			"yOffset", T.Scale(-60),
			"point", "TOP",
			"columnAnchorPoint", "RIGHT"
		)
		raidgroup:SetPoint("RIGHT", _G["RaidAnchor"])
		_G["RaidAnchor"]:SetSize(raid_width, T.Scale(raid_height) * 5 + T.Scale(7) * 4)
		_G["RaidAnchor"]:SetPoint(unpack(C.position.unitframes.raid))
end)

local raid = CreateFrame("Frame", "RaidAnchor", UIParent)


----------------------------------------------------------------------------------------
-- Expose CreateTargetFrame function
----------------------------------------------------------------------------------------
T.CreateRaidFrame = CreateRaidFrame
