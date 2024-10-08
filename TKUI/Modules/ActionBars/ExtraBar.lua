local T, C, L = unpack(TKUI)

------------------------------------------------------------------------------------------
--	Make ExtraActionBarFrame movable (use macro /click ExtraActionButton1)
------------------------------------------------------------------------------------------
local anchor = CreateFrame("Frame", "ExtraButtonAnchor", UIParent)
anchor:SetPoint(unpack(C.position.extra_button))
local size = C.actionbar.button_size * 1.5 + C.actionbar.button_space
anchor:SetSize(size, size)
anchor:SetFrameStrata("LOW")
RegisterStateDriver(anchor, "visibility", "[petbattle] hide; show")

ExtraActionBarFrame:SetParent(anchor)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetAllPoints()

-- Prevent reanchor
ExtraAbilityContainer.ignoreFramePositionManager = true
hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
	if parent == ExtraAbilityContainer then
		self:SetParent(anchor)
	end
end)

-- Zone Ability button
local zoneAnchor = CreateFrame("Frame", "ZoneButtonAnchor", UIParent)
zoneAnchor:SetPoint(unpack(C.position.zone_button))
zoneAnchor:SetSize(size * 2, size)
zoneAnchor:SetFrameStrata("LOW")
RegisterStateDriver(zoneAnchor, "visibility", "[petbattle] hide; show")

ZoneAbilityFrame:SetParent(zoneAnchor)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetAllPoints()
ZoneAbilityFrame.ignoreInLayout = true
ZoneAbilityFrame.SpellButtonContainer:SetPoint("TOP", zoneAnchor)
ZoneAbilityFrame.SpellButtonContainer.spacing = 3
hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
	if parent == ExtraAbilityContainer then
		self:SetParent(zoneAnchor)
	end
end)

C_Timer.After(0.1, function()
	ZoneAbilityFrame.SpellButtonContainer:SetSize(size, size)
end)

hooksecurefunc("ExtraActionBar_Update", function()
	local positionTable = T.CurrentProfile()
	if positionTable["ZoneButtonAnchor"] then return end
	if HasExtraActionBar() then
		zoneAnchor:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -3, 0)
	else
		zoneAnchor:SetPoint(unpack(C.position.zone_button))
	end
end)

------------------------------------------------------------------------------------------
--	Skin ExtraActionBarFrame(by Zork)
------------------------------------------------------------------------------------------
local button = ExtraActionButton1
local texture = button.style
local disableTexture = function(style, texture)
	if texture then
		style:SetTexture(nil)
	end
end
button.style:SetTexture(nil)
hooksecurefunc(texture, "SetTexture", disableTexture)

button:SetSize(size, size)

button.Count:SetFont(C.font.cooldown_timers_font, C.font.cooldown_timers_font_size, C.font.cooldown_timers_font_style)
button.Count:SetShadowOffset(C.font.cooldown_timers_font_shadow and 1 or 0,
	C.font.cooldown_timers_font_shadow and -1 or 0)
button.Count:SetPoint("BOTTOMRIGHT", 0, 1)
button.Count:SetJustifyH("RIGHT")

button:SetAttribute("showgrid", 1)

------------------------------------------------------------------------------------------
--	Skin ZoneAbilityFrame
------------------------------------------------------------------------------------------
local function SkinZoneAbilities()
	for button in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
		if not button.IsSkinned then
			button.NormalTexture:SetAlpha(0)
			button:StyleButton()
			button:SetSize(size, size)
			button:SetTemplate("Transparent")
			if C.actionbar.classcolor_border == true then
				button:SetBackdropBorderColor(unpack(C.media.classborder_color))
			end

			button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			button.Icon:SetPoint("TOPLEFT", button, 2, -2)
			button.Icon:SetPoint("BOTTOMRIGHT", button, -2, 2)
			button.Icon:SetDrawLayer("BACKGROUND", 7)

			button.Count:SetFont(C.font.cooldown_timers_font, C.font.cooldown_timers_font_size,
				C.font.cooldown_timers_font_style)
			button.Count:SetShadowOffset(C.font.cooldown_timers_font_shadow and 1 or 0,
				C.font.cooldown_timers_font_shadow and -1 or 0)
			button.Count:SetPoint("BOTTOMRIGHT", 0, 1)
			button.Count:SetJustifyH("RIGHT")

			button.Cooldown:SetAllPoints(button.Icon)

			button.IsSkinned = true
		end
	end
end

hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", SkinZoneAbilities)
ZoneAbilityFrame.Style:SetAlpha(0)
