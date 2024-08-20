local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Collect minimap buttons in one line
----------------------------------------------------------------------------------------
local BlackList = {
	["QueueStatusButton"] = true,
	["MiniMapTracking"] = true,
	["MiniMapMailFrame"] = true,
	["HelpOpenTicketButton"] = true,
	["GameTimeFrame"] = true,
}

local buttons = {}
local collectFrame = CreateFrame("Frame", "ButtonCollectFrame", UIParent)
local line = math.ceil(C.minimap.size / 12)

local texList = {
	["136430"] = true,	-- Interface\\Minimap\\MiniMap-TrackingBorder
	["136467"] = true,	-- Interface\\Minimap\\UI-Minimap-Background
}

local function SkinButton(f)
	f:SetPushedTexture(0)
	f:SetHighlightTexture(0)
	f:SetDisabledTexture(0)
	f:SetSize(line, line)

	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:IsVisible() and region:GetObjectType() == "Texture" then
			local tex = tostring(region:GetTexture())

			if tex and (texList[tex] or tex:find("Border") or tex:find("Background") or tex:find("AlphaMask")) then
				region:SetTexture(nil)
			else
				region:ClearAllPoints()
				region:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
				region:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
				region:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				region:SetDrawLayer("ARTWORK")
				if f:GetName() == "PS_MinimapButton" then
					region.SetPoint = T.dummy
				end
			end
		end
	end

	f:SetTemplate("ClassColor")
end

local function PositionAndStyle()
    collectFrame:SetSize(20.8, 20.8)
    collectFrame:SetPoint(unpack(C.position.minimap_buttons))
    local buttonsPerRow = line -- Use the existing 'line' variable for buttons per row
    for i = 1, #buttons do
        local f = buttons[i]
        f:ClearAllPoints()
        local row = math.floor((i-1) / buttonsPerRow)
        local col = (i-1) % buttonsPerRow
        if i == 1 then
            f:SetPoint("TOPLEFT", collectFrame, "TOPLEFT", 0, 0)
        else
            if col == 0 then
                -- Start of a new row
                f:SetPoint("TOPLEFT", buttons[i-buttonsPerRow], "BOTTOMLEFT", 0, -1)
            else
                -- Continue the current row
                f:SetPoint("LEFT", buttons[i-1], "RIGHT", 4, 0)
            end
        end
        f.ClearAllPoints = T.dummy
        f.SetPoint = T.dummy
        if C.skins.minimap_buttons_mouseover then
            f:SetAlpha(0)
            f:HookScript("OnEnter", function()
                f:FadeIn()
            end)
            f:HookScript("OnLeave", function()
                f:FadeOut()
            end)
        end
        SkinButton(f)
    end
end

local collect = CreateFrame("Frame")
collect:RegisterEvent("PLAYER_ENTERING_WORLD")
collect:SetScript("OnEvent", function()
	for _, child in ipairs({Minimap:GetChildren()}) do
		if not BlackList[child:GetName()] then
			if child:GetObjectType() == "Button" and child:GetNumRegions() >= 3 and child:IsShown() then
				child:SetParent(collectFrame)
				tinsert(buttons, child)
			end
		end
	end
	if #buttons == 0 then
		collectFrame:Hide()
	end
	PositionAndStyle()

	if WIM3MinimapButton and WIM3MinimapButton:GetParent() == UIParent then
		SkinButton(WIM3MinimapButton)
		WIM3MinimapButton.backGround:Hide()
	end
	collect:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)