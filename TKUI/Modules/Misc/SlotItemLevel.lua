----------------------------------------------------------------------------------------
--	Slot Item Level Display for TKUI
--	This module adds item level information to Character and Inspect frames.
--	It shows the item level for each equipment slot, enhancing gear assessment.
--	Features include real-time updates and support for both player and inspected characters.
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Constants and Variables
----------------------------------------------------------------------------------------
local minItemLevel = math.floor(GetAverageItemLevel() * 0.9) -- 90% of current average item level for missing enchant and gems checking
local _G = getfenv(0)
local equiped = {}       -- Table to store equipped items
local strfind, strmatch, tonumber = string.find, string.match, tonumber


local f = CreateFrame("Frame", nil, _G.PaperDollFrame) -- iLevel number frame
local g                                                -- iLevel number for Inspect frame

local fontObject = CreateFont("iLvLFont")
fontObject:SetFontObject("SystemFont_Outline_Small")

local itemLevelString = "^" .. gsub(ITEM_LEVEL, "%%d", "")

local itemLevelCache = setmetatable({}, { __mode = "kv" }) -- Use weak references
local CACHE_SIZE_LIMIT = 1000
local cacheSize = 0

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------

local function addToCache(itemLink, itemLevel)
	if cacheSize >= CACHE_SIZE_LIMIT then
		-- Clear 25% of the cache when limit is reached
		local toRemove = math.floor(CACHE_SIZE_LIMIT * 0.25)
		for k in pairs(itemLevelCache) do
			itemLevelCache[k] = nil
			toRemove = toRemove - 1
			if toRemove == 0 then break end
		end
		cacheSize = CACHE_SIZE_LIMIT - math.floor(CACHE_SIZE_LIMIT * 0.25)
	end

	itemLevelCache[itemLink] = itemLevel
	cacheSize = cacheSize + 1
end

local function _getRealItemLevel(slotId, unit)
	local itemLink = GetInventoryItemLink(unit, slotId)
	if not itemLink then return nil end

	if itemLevelCache[itemLink] then
		return itemLevelCache[itemLink]
	end

	local data = C_TooltipInfo.GetInventoryItem(unit, slotId)
	if not data then return nil end

	for i = 2, #data.lines do
		local text = data.lines[i].leftText
		if text then
			local level = strmatch(text, itemLevelString .. "(%d+)")
			if level then
				level = tonumber(level)
				if level > 0 then
					addToCache(itemLink, level)
					return level
				end
			end
		end
	end

	return nil
end

local function clearItemLevelCache()
	wipe(itemLevelCache)
	cacheSize = 0
end

local function _updateItems(unit, frame)
	local GetInventoryItemLink = GetInventoryItemLink
	local strsplit = strsplit
	local tonumber = tonumber
	local GetItemStats = GetItemStats

	for i = 1, 17 do
		if i ~= 4 then
			local itemLink = GetInventoryItemLink(unit, i)
			local frameElement = frame[i]
			local currentText = frameElement:GetText()

			if (frame == f and (equiped[i] ~= itemLink or currentText == nil or (itemLink == nil and currentText ~= ""))) or frame == g then
				if frame == f then
					equiped[i] = itemLink
				end

				local realItemLevel = _getRealItemLevel(i, unit)
				if not realItemLevel or tonumber(realItemLevel) == 1 then
					frameElement:SetText("")
				else
					local r, g, b = 1, 1, 0 -- Default yellow color

					-- Check missing enchants and gems
					if itemLink and tonumber(realItemLevel) > minItemLevel then
						local _, _, enchant, gem1, gem2, gem3 = strsplit(":", itemLink)
						if (i == INVSLOT_BACK or i == INVSLOT_CHEST or i == INVSLOT_MAINHAND or i == INVSLOT_FINGER1 or i == INVSLOT_FINGER2 or i == INVSLOT_WRIST or i == INVSLOT_FEET or i == INVSLOT_LEGS) and enchant == "" then
							r, g, b = 1, 0, 0 -- Red for missing enchant
						else
							local info = C_Item.GetItemStats(itemLink) or {}
							local numSocket = 0
							for socketType, count in pairs(info) do
								if strfind(socketType, "SOCKET") then
									numSocket = numSocket + count
								end
							end
							local numGem = (gem1 ~= "" and 1 or 0) + (gem2 ~= "" and 1 or 0) + (gem3 ~= "" and 1 or 0)
							if numGem < numSocket then
								r, g, b = 1, 0, 0.8 -- Pink for missing gems
							end
						end
					end

					frameElement:SetText(realItemLevel)
					frameElement:SetTextColor(r, g, b)
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------
--	Frame Creation Functions
----------------------------------------------------------------------------------------
local function _createStrings()
	local function _stringFactory(parent)
		local s = f:CreateFontString(nil, "OVERLAY", "iLvLFont")
		s:SetPoint("TOP", parent, "TOP", 0, -4)
		return s
	end

	f:SetFrameLevel(_G.CharacterHeadSlot:GetFrameLevel())

	f[1] = _stringFactory(_G.CharacterHeadSlot)
	f[2] = _stringFactory(_G.CharacterNeckSlot)
	f[3] = _stringFactory(_G.CharacterShoulderSlot)
	f[15] = _stringFactory(_G.CharacterBackSlot)
	f[5] = _stringFactory(_G.CharacterChestSlot)
	f[9] = _stringFactory(_G.CharacterWristSlot)
	f[10] = _stringFactory(_G.CharacterHandsSlot)
	f[6] = _stringFactory(_G.CharacterWaistSlot)
	f[7] = _stringFactory(_G.CharacterLegsSlot)
	f[8] = _stringFactory(_G.CharacterFeetSlot)
	f[11] = _stringFactory(_G.CharacterFinger0Slot)
	f[12] = _stringFactory(_G.CharacterFinger1Slot)
	f[13] = _stringFactory(_G.CharacterTrinket0Slot)
	f[14] = _stringFactory(_G.CharacterTrinket1Slot)
	f[16] = _stringFactory(_G.CharacterMainHandSlot)
	f[17] = _stringFactory(_G.CharacterSecondaryHandSlot)

	f:Hide()
end

local function _createGStrings()
	local function _stringFactory(parent)
		local s = g:CreateFontString(nil, "OVERLAY", "iLvLFont")
		s:SetPoint("TOP", parent, "TOP", 0, -2)
		return s
	end

	g:SetFrameLevel(_G.InspectHeadSlot:GetFrameLevel())

	g[1] = _stringFactory(_G.InspectHeadSlot)
	g[2] = _stringFactory(_G.InspectNeckSlot)
	g[3] = _stringFactory(_G.InspectShoulderSlot)
	g[15] = _stringFactory(_G.InspectBackSlot)
	g[5] = _stringFactory(_G.InspectChestSlot)
	g[9] = _stringFactory(_G.InspectWristSlot)
	g[10] = _stringFactory(_G.InspectHandsSlot)
	g[6] = _stringFactory(_G.InspectWaistSlot)
	g[7] = _stringFactory(_G.InspectLegsSlot)
	g[8] = _stringFactory(_G.InspectFeetSlot)
	g[11] = _stringFactory(_G.InspectFinger0Slot)
	g[12] = _stringFactory(_G.InspectFinger1Slot)
	g[13] = _stringFactory(_G.InspectTrinket0Slot)
	g[14] = _stringFactory(_G.InspectTrinket1Slot)
	g[16] = _stringFactory(_G.InspectMainHandSlot)
	g[17] = _stringFactory(_G.InspectSecondaryHandSlot)

	g:Hide()
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" and (...) == "Blizzard_InspectUI" then
		self:UnregisterEvent(event)

		if not InspectFrameiLvL and not C.tooltip.average_lvl then
			local text = InspectModelFrame:CreateFontString("InspectFrameiLvL", "OVERLAY", "SystemFont_Outline_Small")
			text:SetPoint("BOTTOM", 5, 20)
			text:Hide()
			InspectPaperDollFrame:HookScript("OnShow", function()
				local avgilvl = C_PaperDollInfo.GetInspectItemLevel("target")
				if avgilvl and tonumber(avgilvl) > 0 then
					text:SetText("|cFFFFFF00" .. avgilvl)
					text:Show()
				end
			end)
			InspectPaperDollFrame:HookScript("OnHide", function()
				text:Hide()
			end)
		end

		g = CreateFrame("Frame", nil, _G.InspectPaperDollFrame) -- iLevel number frame for Inspect
		_createGStrings()
		_createGStrings = nil

		_G.InspectPaperDollFrame:HookScript("OnShow", function()
			g:SetFrameLevel(_G.InspectHeadSlot:GetFrameLevel())
			f:RegisterEvent("INSPECT_READY")
			f:RegisterEvent("UNIT_INVENTORY_CHANGED")
			_updateItems("target", g)
			g:Show()
		end)

		_G.InspectPaperDollFrame:HookScript("OnHide", function()
			f:UnregisterEvent("INSPECT_READY")
			f:UnregisterEvent("UNIT_INVENTORY_CHANGED")
			g:Hide()
		end)
	elseif event == "PLAYER_LOGIN" then
		self:UnregisterEvent(event)

		_createStrings()
		_createStrings = nil

		_G.PaperDollFrame:HookScript("OnShow", function()
			f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
			_updateItems("player", f)
			f:Show()
		end)

		_G.PaperDollFrame:HookScript("OnHide", function()
			f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:Hide()
		end)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local slot = ...
		clearItemLevelCache() -- Clear cache when equipment changes
		if slot == 16 then
			equiped[16] = nil
			equiped[17] = nil
		else
			equiped[slot] = nil
		end
		_updateItems("player", f)
	elseif event == "INSPECT_READY" then
		clearItemLevelCache() -- Clear cache when inspecting a new target
		_updateItems("target", g)
	elseif event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if unit == "target" and g:IsShown() then
			_updateItems("target", g)
		end
	end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", OnEvent)

----------------------------------------------------------------------------------------
--	Item level on flyout buttons (by Merathilis)
----------------------------------------------------------------------------------------
local ItemDB = setmetatable({}, {__mode = "kv"}) -- Use weak references

local function GetRealItemLevel(link, bag, slot)
    if ItemDB[link] then return ItemDB[link] end

    local realItemLevel
    if bag and type(bag) == "string" then
        realItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slot))
    else
        realItemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromBagAndSlot(bag, slot))
    end

    if realItemLevel and realItemLevel > 1 then
        ItemDB[link] = realItemLevel
    end
    return realItemLevel
end

local function SetupFlyoutLevel(button)
    if not button.iLvl then
        button.iLvl = button:CreateFontString(nil, "OVERLAY", "iLvLFont")
        button.iLvl:SetPoint("TOP", 0, -2)
    end

    local location = button.location
    if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
        button.iLvl:SetText("")
        return
    end

    local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
    if voidStorage then return end

    local link, level
    if bags then
        link = C_Container.GetContainerItemLink(bag, slot)
    else
        link = GetInventoryItemLink("player", slot)
    end

    if link then
        level = GetRealItemLevel(link, bag, slot)
        if level and level > 1 then
            button.iLvl:SetText("|cFFFFFF00" .. level)
        else
            button.iLvl:SetText("")
        end
    else
        button.iLvl:SetText("")
    end
end

hooksecurefunc("EquipmentFlyout_DisplayButton", SetupFlyoutLevel)