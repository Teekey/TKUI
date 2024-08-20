local T, C, L = unpack(TKUI)

-- Helper function to create sections
local function CreateSection(name)
    C[name] = C[name] or {}
    return setmetatable({}, {
        __newindex = function(t, k, v)
            rawset(C[name], k, v)
        end
    })
end

----------------------------------------------------------------------------------------
--	Position options
--	BACKUP THIS FILE BEFORE UPDATING!
----------------------------------------------------------------------------------------
local position = CreateSection("position")

-- ActionBar positions
position.bottom_bars = {"BOTTOM", UIParent, "BOTTOM", 0, 230}                         -- Bottom bars
position.right_bars = {"RIGHT", UIParent, "RIGHT", 0, 0}              -- Right bars
position.pet_bars = {"TOPRIGHT", "ActionBarAnchor", "TOPLEFT", -7, 102}         -- Horizontal pet bar
position.stance_bar = {"TOPRIGHT", "ActionBarAnchor", "TOPLEFT", -7, 102}             -- Stance bar
position.vehicle_bar = {"BOTTOMRIGHT", ActionButton1, "BOTTOMLEFT", -3, 0}            -- Vehicle button
position.extra_button = {"BOTTOM", UIParent, "BOTTOM", 0, 100}           -- Extra action button
position.zone_button = {"BOTTOM", UIParent, "BOTTOM", 0, 100}            -- Zone action button
position.micro_menu = {"TOPLEFT", UIParent, "TOPLEFT", 2, -2}                         -- Micro menu

-- UnitFrame positions
position.unitframes = {
    player = {"BOTTOM", "ActionBarAnchor", "TOP", 0, 50},                             -- Player frame
    class_resources = {"BOTTOM", "oUF_Player", "TOP", 0, 9},  -- PlayerResources bar
    target = {"BOTTOMLEFT", "ActionBarAnchor", "TOPRIGHT", 5, 50},                   -- Target frame
    target_target = {"TOPRIGHT", "oUF_Target", "BOTTOMRIGHT", 0, -11},                -- ToT frame
    pet = {"TOPLEFT", "oUF_Player", "BOTTOMLEFT", 0, -11},                            -- Pet frame
    focus = {"BOTTOMRIGHT", "ActionBarAnchor", "TOPLEFT", -5, 50},                    -- Focus frame
    focus_target = {"TOPLEFT", "oUF_Target", "BOTTOMLEFT", 0, -11},                   -- Focus target frame
    party = {"CENTER", UIParent, "CENTER", -550, 0},                                  -- Heal layout Party frames
    raid = {"CENTER", UIParent, "CENTER", -550, 0},                                   -- Heal layout Raid frames
    party_heal = {"TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 11, -12},                   -- Heal layout Party frames
    raid_heal = {"TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 11, -12},                    -- Heal layout Raid frames
    party_dps = {"BOTTOMLEFT", UIParent, "LEFT", 23, -70},                            -- DPS layout Party frames
    raid_dps = {"TOPLEFT", UIParent, "TOPLEFT", 23, -23},                             -- DPS layout Raid frames
    arena = {"BOTTOMRIGHT", UIParent, "RIGHT", -60, -70},                             -- Arena frames
    boss = {"RIGHT", UIParent, "RIGHT", -650, 0},                              -- Boss frames
    tank = {"BOTTOMLEFT", "ActionBarAnchor", "BOTTOMRIGHT", 10, 18},                  -- Tank frames
    player_castbar = {"TOP", "oUF_Player", "BOTTOM", 0, -8},                          -- Player Castbar
    target_castbar = {"TOP", "oUF_Target", "BOTTOM", 0, -8},                          -- Target Castbar
    focus_castbar = {"CENTER", UIParent, "CENTER", 0, 250},                           -- Focus Castbar icon
}

-- Filger positions
position.filger = {
    player_buff_icon = {"CENTER", UIParent, "CENTER", -208, 0},             -- "P_BUFF_ICON"
    player_proc_icon = {"CENTER", UIParent, "CENTER", 208, 0},              -- "P_PROC_ICON"
    special_proc_icon = {"CENTER", UIParent, "CENTER", 0, -208},            -- "SPECIAL_P_BUFF_ICON"
    target_debuff_icon = {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 213},            -- "T_DEBUFF_ICON"
    target_buff_icon = {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253},              -- "T_BUFF"
    pve_debuff = {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253},                   -- "PVE/PVP_DEBUFF"
    pve_cc = {"TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44},                        -- "PVE/PVP_CC"
    cooldown = {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17},                     -- "COOLDOWN"
    target_bar = {"BOTTOMLEFT", "oUF_Target", "BOTTOMRIGHT", 9, -41},                 -- "T_DE/BUFF_BAR"
}

-- Miscellaneous positions
position.minimap = {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 40}                  -- Minimap
position.minimap_buttons = {"BOTTOMLEFT", Minimap, "TOPLEFT", -1, 10}                    -- Minimap buttons
position.tooltip = {"BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5}                         -- Tooltip
position.vehicle = {"BOTTOM", Minimap, "TOP", 0, 27}                                  -- Vehicle frame
position.ghost = {"BOTTOM", Minimap, "TOP", 0, 5}                                     -- Ghost frame
position.bag = {"BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5}                             -- Bag
position.bank = {"LEFT", UIParent, "LEFT", 23, 150}                                   -- Bank
position.archaeology = {"BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5}                     -- Archaeology frame
position.auto_button = {"BOTTOMLEFT", Minimap, "TOPLEFT", -2, 27}                     -- Quest Item auto button
position.autoitembar = {"TOP", "ActionBarAnchor", "BOTTOM", 10, 0}                     -- Quest Item auto button
position.chat = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 40}                        -- Chat
position.bn_popup = {"BOTTOMLEFT", ChatFrame1, "TOPLEFT", -3, 27}                     -- Battle.net popup
position.bwtimeline = {"LEFT", "PartyAnchor", "RIGHT", 25, 0}                   -- Battle.net popup
position.map = {"BOTTOM", UIParent, "BOTTOM", 0, 320}                                -- Map
position.quest = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10}                             -- Quest log
position.loot = {"TOPLEFT", UIParent, "TOPLEFT", 245, -220}                           -- Loot
position.group_loot = {"BOTTOMLEFT", "oUF_Player", "TOPLEFT", -2, 173}                -- Group roll loot
position.threat_meter = {"BOTTOMLEFT", "ActionBarAnchor", "BOTTOMRIGHT", 7, 16}       -- Threat meter
position.bg_score = {"BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 10, -2}             -- BG stats
position.raid_cooldown = {"TOPLEFT", UIParent, "TOPLEFT", 300, -21}                   -- Raid cooldowns
position.enemy_cooldown = {"BOTTOMLEFT", "oUF_Player", "TOPRIGHT", 33, 62}            -- Enemy cooldowns
position.pulse_cooldown = {"CENTER", UIParent, "CENTER", 0, 0}                        -- Pulse cooldowns
position.player_buffs = {"TOPRIGHT", UIParent, "TOPRIGHT", -10, -10}                  -- Player buffs
position.self_buffs = {"CENTER", UIParent, "CENTER", 0, 0}                          -- Self buff reminder
position.raid_buffs = {"TOPRIGHT", Minimap, "BOTTOMRIGHT", 3, -6}                       -- Raid buff reminder
position.raid_utility = {"TOP", UIParent, "TOP", 0, 0}                             -- Raid utility
position.top_panel = {"TOP", UIParent, "TOP", 0, -21}                                 -- Top panel
position.achievement = {"TOP", UIParent, "TOP", 0, -21}                               -- Achievements frame
position.uierror = {"TOP", UIParent, "TOP", 0, -30}                                   -- Errors frame
position.talking_head = {"TOP", UIParent, "TOP", 0, -21}                              -- Talking Head
position.alt_power_bar = {"TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -7}    -- Alt power bar
position.uiwidget_top = {"TOP", UIParent, "TOP", 0, -21}                              -- Top Widget
position.uiwidget_below = {"TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -15}  -- Below Widget