local T, C, L = unpack(TKUI)


----------------------------------------------------------------------------------------
--	Major Factions skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	local frame = _G.MajorFactionRenownFrame

	T.SkinFrame(frame)
	frame.Background:SetAlpha(0)
end

T.SkinFuncs["Blizzard_MajorFactions"] = LoadSkin