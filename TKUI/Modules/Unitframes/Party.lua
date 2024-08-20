local T, C, L = unpack(TKUI)
local _, ns = ...
local oUF = ns.oUF
local UF = T.UF

-- Upvalues
local unpack = unpack
local party_width = C.raidframe.party_width
local party_height = C.raidframe.party_health + C.raidframe.party_power + 2
local party_power_height = C.raidframe.party_power_height


----------------------------------------------------------------------------------------
-- Party Frame Creation
----------------------------------------------------------------------------------------
local function CreatePartyFrame(self)
    -- Configure base unit frame
    UF.ConfigureFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateNameText(self)
    UF.CreateRaidDebuffs(self)
    UF.CreateRaidTargetIndicator(self)
    UF.CreateDebuffHighlight(self)
	UF.CreatePartyAuraWatch(self)
    UF.CreateGroupIcons(self)
    UF.ApplyGroupSettings(self)

    return self
end

----------------------------------------------------------------------------------------
-- Target Frame Initialization
----------------------------------------------------------------------------------------
oUF:Factory(function(self)
    oUF:RegisterStyle("TKUI_Party", CreatePartyFrame)
    oUF:SetActiveStyle("TKUI_Party")
	local party = self:SpawnHeader("oUF_Party", nil, "custom [@raid6,exists] hide;show",
		"oUF-initialConfigFunction", [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute("initial-width"))
				self:SetHeight(header:GetAttribute("initial-height"))
			]],
		"initial-width", party_width,
		"initial-height", T.Scale(party_height),
		"showSolo", C.raidframe.solo_mode,
		"showPlayer", C.raidframe.player_in_party,
		"groupBy", C.raidframe.by_role and "ASSIGNEDROLE",
		"groupingOrder", C.raidframe.by_role and "TANK,HEALER,DAMAGER,NONE",
		"sortMethod", C.raidframe.by_role and "NAME",
		"showParty", true,
		"showRaid", true,
		"xOffset", T.Scale(7),
		"yOffset", T.Scale(-60),
		"point", "TOP"
	)
	party:SetPoint("CENTER", _G["PartyAnchor"])
	_G["PartyAnchor"]:SetSize(party_width, party_height * 5 + T.Scale(7) * 4)

end)

-- Create anchors
local party = CreateFrame("Frame", "PartyAnchor", UIParent)
party:SetPoint(C.position.unitframes.party[1], C.position.unitframes.party[2],
	C.position.unitframes.party[3], C.position.unitframes.party[4] + 32,
	C.position.unitframes.party[5])


----------------------------------------------------------------------------------------
-- Expose CreateTargetFrame function
----------------------------------------------------------------------------------------
T.CreatePartyFrame = CreatePartyFrame
