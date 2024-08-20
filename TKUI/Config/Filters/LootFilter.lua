local T, C, L = unpack(TKUI)
if C.lootfilter.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Loot Filter
----------------------------------------------------------------------------------------

-- Items that shouldn't be looted
T.LootFilterItems = {
    -- Tradeskill Items
    [2589] = "Linen Cloth",
    [4306] = "Silk Cloth",
    [25649] = "Fel Hide",
    [36908] = "Frost Lotus",
    [124113] = "Felhide",
    [124106] = "Felwort",
    [124444] = "Infernal Brimstone",
    [173204] = "Lightless Silk",

    -- Annoying Quest Items
    [6522] = "Hardened Walleye",
    [124129] = "Fel Blood",
    [124131] = "Undivided Hide",
    [124130] = "Stormscale Spark",
    [178040] = "Devoured Anima",
    [180248] = "Mawsworn Emblem",
    [180479] = "Rugged Carapace",
    [187322] = "Korthian Repository",

    -- Special fish
    [6358] = "Oily Blackmouth",
    [6359] = "Firefin Snapper",
    [13422] = "Stonescale Eel",
    [13757] = "Lightning Eel",

    -- Common elemental items
    [120945] = "Primal Spirit",
    [37700] = "Crystallized Fire",
    [37701] = "Crystallized Earth",
    [52325] = "Volatile Earth",
    [52326] = "Volatile Fire",
    -- [190315] = "Rousing Earth",
    -- [190320] = "Rousing Fire",

    -- Pigments
    [39151] = "Alabaster Pigment",
    [39334] = "Dusky Pigment",
    [39338] = "Golden Pigment",
}

-- Currency types that will not be looted
T.LootFilterCurrency = {
	-- Shadowlands
	[1828] = true,		-- Soul Ash
	[1906] = true,		-- Soul Cinders
	[2009] = true,		-- Cosmic Flux
	[1979] = true,		-- Cyphers of the First Ones
	
	-- Draenor & Legion
	[824] = true,		-- Garrison Resources
	[1220] = true,		-- Order Resources
}

T.LootFilterCustom = T.LootFilterCustom or {}

-- Merge saved custom filter with T.LootFilterCustom
local function SaveCustomFilters()
    TKUILootFilter = TKUILootFilter or {}
    wipe(TKUILootFilter)
    for itemID, value in pairs(T.LootFilterCustom) do
        TKUILootFilter[itemID] = value
    end
end

-- Make these functions available to other parts of your addon if needed
T.AddToCustomFilter = AddToCustomFilter
T.RemoveFromCustomFilter = RemoveFromCustomFilter

-- Register a event to ensure TKUILootFilter is properly initialized
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        TKUILootFilter = TKUILootFilter or {}
        -- Re-merge saved filters in case they weren't available when this file first loaded
        for itemID, value in pairs(TKUILootFilter) do
            T.LootFilterCustom[itemID] = value
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)