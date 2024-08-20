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
local function CreateArenaFrame(self)
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
oUF:RegisterStyle('TKUI_Arena', CreateArenaFrame)
oUF:SetActiveStyle('TKUI_Arena')
local arena = {}
for i = 1, 5 do
	arena[i] = oUF:Spawn("arena" .. i, "oUF_Arena" .. i)
	if i == 1 then
		arena[i]:SetPoint(unpack(C.position.unitframes.arena))
	else
		arena[i]:SetPoint("BOTTOM", arena[i - 1], "TOP", 0, 30)
	end
	arena[i]:SetSize(frame_width, frame_height)

	local arenatarget = {}
	for i = 1, 5 do
		arenatarget[i] = oUF:Spawn("arena" .. i .. "target", "oUF_Arena" .. i .. "Target")
		if i == 1 then
			arenatarget[i]:SetPoint("TOPLEFT", arena[i], "TOPRIGHT", 7, 0)
		else
			arenatarget[i]:SetPoint("BOTTOM", arenatarget[i - 1], "TOP", 0, 30)
		end
		arenatarget[i]:SetSize(frame_width, frame_height)
	end
end

----------------------------------------------------------------------------------------
--	Arena preparation(by Blizzard)(../Blizzard_ArenaUI/Blizzard_ArenaUI.lua)
----------------------------------------------------------------------------------------
if C.unitframe.show_arena == true then
	local arenaprep = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame("Frame", "oUF_ArenaPrep" .. i, UIParent)
		arenaprep[i]:SetAllPoints(_G["oUF_Arena" .. i])
		arenaprep[i]:CreateBackdrop("Default")
		arenaprep[i]:SetFrameStrata("BACKGROUND")

		arenaprep[i].Health = CreateFrame("StatusBar", nil, arenaprep[i])
		arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetStatusBarTexture(C.media.texture)

		arenaprep[i].Spec = UF.SetFontString(arenaprep[i].Health, C.font.unitframes_font, C.font.unitframes_font_size,
			C.font.unitframes_font_style)
		arenaprep[i].Spec:SetPoint("CENTER")

		arenaprep[i]:Hide()
	end

	local arenaprepupdate = CreateFrame("Frame")
	arenaprepupdate:RegisterEvent("PLAYER_LOGIN")
	arenaprepupdate:RegisterEvent("PLAYER_ENTERING_WORLD")
	arenaprepupdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
	arenaprepupdate:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	arenaprepupdate:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_LOGIN" then
			for i = 1, 5 do
				arenaprep[i]:SetAllPoints(_G["oUF_Arena" .. i])
			end
		elseif event == "ARENA_OPPONENT_UPDATE" then
			for i = 1, 5 do
				arenaprep[i]:Hide()
			end
		else
			local numOpps = GetNumArenaOpponentSpecs()

			if numOpps > 0 then
				for i = 1, 5 do
					local f = arenaprep[i]

					if i <= numOpps then
						local s = GetArenaOpponentSpec(i)
						local _, spec, class = nil, "UNKNOWN", "UNKNOWN"

						if s and s > 0 then
							_, spec, _, _, _, class = GetSpecializationInfoByID(s)
						end

						if class and spec then
							local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
							if color then
								f.Health:SetStatusBarColor(color.r, color.g, color.b)
							else
								f.Health:SetStatusBarColor(unpack(C.unitframe.uf_color))
							end
							f.Spec:SetText(spec)
							f:Show()
						end
					else
						f:Hide()
					end
				end
			else
				for i = 1, 5 do
					arenaprep[i]:Hide()
				end
			end
		end
	end)
end

----------------------------------------------------------------------------------------
-- Expose CreatePlayerFrame function
----------------------------------------------------------------------------------------
UF.CreateArenaFrame = CreateArenaFrame