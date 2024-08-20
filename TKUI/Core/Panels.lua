local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Bottom bars anchor
----------------------------------------------------------------------------------------
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", T_PetBattleFrameHider)
BottomBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.position.bottom_bars))
BottomBarAnchor:SetWidth((C.actionbar.button_size * 12) + (C.actionbar.button_space * 11))
BottomBarAnchor:SetHeight((C.actionbar.button_size * 3) + (C.actionbar.button_space * 2))
BottomBarAnchor:SetFrameStrata("LOW")

----------------------------------------------------------------------------------------
--	Right bars anchor
----------------------------------------------------------------------------------------
local RightBarAnchor = CreateFrame("Frame", "RightActionBarAnchor", T_PetBattleFrameHider)
RightBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.position.right_bars))
RightBarAnchor:SetHeight((C.actionbar.button_size * 12) + (C.actionbar.button_space * 11))
RightBarAnchor:SetWidth((C.actionbar.button_size * 3) + (C.actionbar.button_space * 2))
RightBarAnchor:SetFrameStrata("LOW")

----------------------------------------------------------------------------------------
--	Pet bar anchor
----------------------------------------------------------------------------------------
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", T_PetBattleFrameHider)
PetBarAnchor:CreatePanel("Invisible", (C.actionbar.button_size * 10) + (C.actionbar.button_space * 9),
	C.actionbar.button_size, unpack(C.position.pet_bars))

PetBarAnchor:SetFrameStrata("LOW")
RegisterStateDriver(PetBarAnchor, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")

----------------------------------------------------------------------------------------
--	Stance bar anchor
----------------------------------------------------------------------------------------
local StanceAnchor = CreateFrame("Frame", "StanceBarAnchor", T_PetBattleFrameHider)
StanceAnchor:SetFrameStrata("LOW")
StanceAnchor:SetPoint(C.position.stance_bar[1], C.position.stance_bar[2], C.position.stance_bar[3],
	C.position.stance_bar[4], C.position.stance_bar[5] - (C.actionbar.button_size + C.actionbar.button_space))
StanceAnchor:SetWidth((C.actionbar.button_size * 7) + (C.actionbar.button_space * 6))
StanceAnchor:SetHeight(C.actionbar.button_size)

StanceAnchor:RegisterEvent("PLAYER_LOGIN")
StanceAnchor:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
StanceAnchor:SetScript("OnEvent", function()
	local forms = GetNumShapeshiftForms()
	if forms > 0 then
		StanceAnchor:SetWidth((C.actionbar.button_size * forms) + (C.actionbar.button_space * (forms - 1)))
	end
	if not StanceAnchor.hook then
		RegisterStateDriver(StanceAnchor, "visibility", GetNumShapeshiftForms() == 0 and "hide" or "show")
		StanceAnchor.hook = true
	end
end)
