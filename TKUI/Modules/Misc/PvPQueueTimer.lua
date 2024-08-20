local T, C, L = unpack(TKUI)
if C_AddOns.IsAddOnLoaded("DBM-Core") then return end

----------------------------------------------------------------------------------------
--	Queue timer on PVPReadyDialog
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame", nil, PVPReadyDialog)
frame:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 8)
frame:CreateBackdrop("Overlay")
frame:SetSize(240, 10)

frame.bar = CreateFrame("StatusBar", nil, frame)
frame.bar:SetStatusBarTexture(C.media.texture)
frame.bar:SetAllPoints()
frame.bar:SetFrameLevel(PVPReadyDialog:GetFrameLevel() + 1)
frame.bar:SetStatusBarColor(1, 0.7, 0)

PVPReadyDialog.nextUpdate = 0

local function UpdateBar()
	local obj = PVPReadyDialog
	local oldTime = GetTime()
	local flag = 0
	local duration = 90
	local interval = 0.1
	obj:SetScript("OnUpdate", function(_, elapsed)
		obj.nextUpdate = obj.nextUpdate + elapsed
		if obj.nextUpdate > interval then
			local newTime = GetTime()
			if (newTime - oldTime) < duration then
				local width = frame:GetWidth() * (newTime - oldTime) / duration
				frame.bar:SetPoint("BOTTOMRIGHT", frame, 0 - width, 0)
				flag = flag + 1
				if flag >= 10 then
					flag = 0
				end
			else
				obj:SetScript("OnUpdate", nil)
			end
			obj.nextUpdate = 0
		end
	end)
end

frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:SetScript("OnEvent", function()
	if PVPReadyDialog:IsShown() then
		UpdateBar()
	end
end)
