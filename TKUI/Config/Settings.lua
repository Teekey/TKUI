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
-- Media options
----------------------------------------------------------------------------------------
local media = CreateSection("media")

media.normal_font = [[Interface\AddOns\TKUI\Media\Fonts\ITCAvantGardeStd-Demi.ttf]] -- Normal font
media.bold_font = [[Interface\AddOns\TKUI\Media\Fonts\ITCAvantGardeStd-Bold.ttf]]   -- Bold font
media.blank_font = [[Interface\AddOns\TKUI\Media\Fonts\Blank.ttf]]                  -- Blank font
media.pixel_font = [[Interface\AddOns\TKUI\Media\Fonts\m5x7.ttf]]                   -- Pixel font
media.pixel_font_style =
"MONOCHROMEOUTLINE"                                                                 -- Pixel font style ("MONOCHROMEOUTLINE" or "OUTLINE")
media.pixel_font_size = 8                                                           -- Pixel font size for those places where it is not specified
media.blank = [[Interface\AddOns\TKUI\Media\Textures\TKUIBlank.tga]]                -- Texture for borders
media.texture = [[Interface\AddOns\TKUI\Media\Textures\TKUITexture.tga]]            -- Texture for status bars
media.nameplate_texture =
[[Interface\AddOns\TKUI\Media\Textures\TKUITexture.tga]]                            -- Texture for status bars
media.highlight =
[[Interface\AddOns\TKUI\Media\Textures\Highlight.tga]]                              -- Texture for debuffs highlight
media.whisp_sound = [[Interface\AddOns\TKUI\Media\Sounds\Whisper.ogg]]              -- Sound for whispers
media.warning_sound = [[Interface\AddOns\TKUI\Media\Sounds\Warning.ogg]]            -- Sound for warning
media.proc_sound = [[Interface\AddOns\TKUI\Media\Sounds\Proc.ogg]]                  -- Sound for procs
media.classborder_color = { T.color.r, T.color.g, T.color.b, 1 }                    -- Color for class borders
media.border_color = { 0.45, 0.45, 0.45, 1 }                                        -- Color for borders
media.backdrop_color = { 0, 0, 0, 1 }                                               -- Color for borders backdrop
media.backdrop_alpha = 0.7                                                          -- Alpha for transparent backdrop                                                  -- Color for shadows
media.glow_texture = [[Interface\AddOns\TKUI\Media\Textures\GlowTex.tga]]           -- Texture for glow effects

----------------------------------------------------------------------------------------
-- Skins options
----------------------------------------------------------------------------------------
local skins = CreateSection("skins")
skins.shadow = true   -- Enable shadows
skins.shadow_color = { 0, 0, 0 }
skins.shadow_size = 4 -- Shadow size

----------------------------------------------------------------------------------------
-- General options
----------------------------------------------------------------------------------------
local general = CreateSection("general")

general.error_filter = "BLACKLIST" -- Filter Blizzard red errors (BLACKLIST, WHITELIST, COMBAT, NONE)
general.move_blizzard = true       -- Allow Moving some Blizzard frames
general.color_picker = false       -- Improved ColorPicker
general.vehicle_mouseover = false  -- Vehicle frame on mouseover
general.minimize_mouseover = false -- Mouseover for quest minimize button

----------------------------------------------------------------------------------------
-- Skins options
----------------------------------------------------------------------------------------
local skins = CreateSection("skins")

skins.minimap_buttons_mouseover = true -- Addons icons on mouseover
-- Addons
skins.ace3 = false                     -- Ace3 options elements skin
skins.bigwigs = true                   -- BigWigs skin
skins.clique = false                   -- Clique skin
skins.dbm = false                      -- DBM skin
skins.details = true                   -- Details skin
skins.npcscan = false                  -- NPCScan skin
skins.opie = true                      -- OPie skin
skins.rarescanner = false              -- RareScanner skin
skins.rematch = false                  -- Rematch skin
skins.weak_auras = true                -- WeakAuras skin

----------------------------------------------------------------------------------------
-- Unit Frames options
----------------------------------------------------------------------------------------
local unitframe = CreateSection("unitframe")

-- Main
unitframe.enable = true           -- Enable unit frames
unitframe.style = "Digit"       -- or "Digit"
unitframe.color_value = false     -- Health/mana value is colored
unitframe.bar_color_value = false -- Health bar color by current health remaining
-- Cast bars
unitframe.castbar_latency = true  -- Castbar latency

-- Icons
unitframe.icons_pvp = false               -- Mouseover PvP text (not icons) on player and target frames
unitframe.icons_combat = true             -- Combat icon
unitframe.icons_resting = true            -- Resting icon
-- Plugins
unitframe.plugins_combat_feedback = false -- Combat text on player/target frame
unitframe.plugins_fader = false           -- Fade unit frames
unitframe.plugins_diminishing = false     -- Diminishing Returns icons on arena frames

-- Size
unitframe.frame_width = 160  -- Player and Target width
unitframe.health_height = 14 -- Additional height for health
unitframe.power_height = 3   -- Additional height for power
unitframe.boss_width = 150   -- Boss and Arena width

----------------------------------------------------------------------------------------
-- Unit Frames Class bar options
----------------------------------------------------------------------------------------
local unitframe_class_bar = CreateSection("unitframe_class_bar")

unitframe_class_bar.combo = true         -- Rogue/Druid Combo bar
unitframe_class_bar.combo_always = false -- Always show Combo bar for Druid

unitframe_class_bar.totem = true         -- Totem bar for Shaman
unitframe_class_bar.totem_other = false  -- Totem bar for other classes

----------------------------------------------------------------------------------------
-- Raid Frames options
----------------------------------------------------------------------------------------
local raidframe = CreateSection("raidframe")

-- Main

raidframe.solo_mode = false                    -- Show player frame always
raidframe.player_in_party = true               -- Show player frame in party
raidframe.raid_groups = 5                      -- Number of groups in raid
raidframe.auto_position =
"DYNAMIC"                                      -- Auto reposition raid frame (only for Heal layout) (DYNAMIC, STATIC, NONE)
raidframe.by_role = true                       -- Sorting players in group by role
raidframe.range_alpha = 0.5                    -- Alpha of unitframes when unit is out of range
-- Plugins
raidframe.plugins_debuffhighlight = true       -- Show texture for dispellable debuff
raidframe.plugins_aura_watch = true            -- Raid debuff icons (from the list)
raidframe.plugins_aura_watch_size = 18         -- Raid debuff icons (from the list)
raidframe.plugins_aura_watch_timer = false     -- Timer on raid debuff icons
raidframe.plugins_debuffhighlight_icon = false -- Show dispellable debuff icon
raidframe.plugins_pvp_debuffs = false          -- Show PvP debuff icons (from the list)
raidframe.plugins_healcomm = true              -- Incoming heal bar on raid frame
raidframe.plugins_over_absorb = false          -- Show over absorb bar on raid frame
raidframe.plugins_over_heal_absorb = false     -- Show over heal absorb on raid frame (from enemy debuffs)

-- Raid/Party layout size
raidframe.party_width = 160     -- Party width
raidframe.party_health = 14     -- Party height
raidframe.party_power = 2       -- Party power height
raidframe.raid_width = 140      -- Raid width
raidframe.raid_height = 12      -- Raid height
raidframe.raid_power_height = 2 -- Raid power height

----------------------------------------------------------------------------------------
-- Auras/Buffs/Debuffs options
----------------------------------------------------------------------------------------
local aura = CreateSection("aura")

aura.player_buff_size = 48          -- Player buffs size
aura.player_buff_classcolor = false -- Player buffs classcolor
aura.player_debuff_size = 32        -- Debuffs size on unitframes
aura.debuff_size = 24               -- Debuffs size on unitframes
aura.show_spiral = true             -- Spiral on aura icons
aura.show_timer = true              -- Show cooldown timer on aura icons
aura.player_aura_only = true        -- Only your debuff on target frame
aura.debuff_color_type = true       -- Color debuff by type

----------------------------------------------------------------------------------------
-- ActionBar options
----------------------------------------------------------------------------------------
local actionbar = CreateSection("actionbar")

-- Main
actionbar.hotkey = false                -- Show hotkey on buttons
actionbar.macro = false                 -- Show macro name on buttons
actionbar.show_grid = false             -- Show empty action bar buttons
actionbar.button_size = 36              -- Buttons size
actionbar.button_space = 3              -- Buttons space
actionbar.toggle_mode = true            -- Enable toggle mode

-- Bottom bars
actionbar.bottombars = 2                -- Number of action bars on the bottom (1, 2 or 3)
actionbar.bottombars_mouseover = false  -- Bottom bars on mouseover
-- Right bars
actionbar.rightbars = 3                 -- Number of action bars on right (0, 1, 2 or 3)
actionbar.rightbars_mouseover = true    -- Right bars on mouseover
-- Pet bar
actionbar.petbar_hide = false           -- Hide pet bar
actionbar.petbar_horizontal = false     -- Enable horizontal pet bar
actionbar.petbar_mouseover = true      -- Pet bar on mouseover (only for horizontal pet bar)
-- Stance bar
actionbar.stancebar_hide = false        -- Hide stance bar
actionbar.stancebar_horizontal = true   -- Enable horizontal stance bar
actionbar.stancebar_mouseover = true    -- Stance bar on mouseover (only for horizontal stance bar)
actionbar.stancebar_mouseover_alpha = 0 -- Stance bar mouseover alpha
-- MicroMenu
actionbar.micromenu = false             -- Enable micro menu
actionbar.micromenu_mouseover = false   -- Micro menu on mouseover

-- Bar 7
actionbar.bar7_enable = false    -- Enable custom bar 7
actionbar.bar7_num = 12          -- Number of buttons
actionbar.bar7_row = 12          -- Buttons per row
actionbar.bar7_size = 25         -- Buttons size
actionbar.bar7_mouseover = false -- Bar on mouseover
-- Bar 8
actionbar.bar8_enable = false    -- Enable custom bar 8
actionbar.bar8_num = 12          -- Number of buttons
actionbar.bar8_row = 12          -- Buttons per row
actionbar.bar8_size = 25         -- Buttons size
actionbar.bar8_mouseover = false -- Bar on mouseover

----------------------------------------------------------------------------------------
-- AutoBar options
----------------------------------------------------------------------------------------
local autoitembar = CreateSection("autoitembar")

autoitembar.enable = true                  -- Enable actionbars
autoitembar.consumable_mouseover = true    -- Set to false to always show the bar
autoitembar.min_consumable_item_level = 60 -- Set the minimum item level for consumables

----------------------------------------------------------------------------------------
-- Tooltip options
----------------------------------------------------------------------------------------
local tooltip = CreateSection("tooltip")

tooltip.cursor = true          -- Tooltip above cursor
tooltip.hidebuttons = false    -- Hide tooltip for actions bars
tooltip.hide_combat = true     -- Hide tooltip in combat
-- Plugins
tooltip.title = false          -- Player title in tooltip
tooltip.realm = true           -- Player realm name in tooltip
tooltip.rank = true            -- Player guild-rank in tooltip
tooltip.target = true          -- Target player in tooltip
tooltip.average_lvl = false    -- Average items level
tooltip.show_shift = true      -- Show items level and spec when Shift is pushed
tooltip.raid_icon = false      -- Raid icon
tooltip.unit_role = false      -- Unit role in tooltip
tooltip.who_targetting = false -- Show who is targetting the unit (in raid or party)
tooltip.achievements = true    -- Comparing achievements in tooltip
tooltip.mount = true           -- Show source of mount

----------------------------------------------------------------------------------------
-- Chat options
----------------------------------------------------------------------------------------
local chat = CreateSection("chat")

chat.width = 600               -- Chat width
chat.height = 300              -- Chat height
chat.filter = true             -- Removing some systems spam ("Player1" won duel "Player2")
chat.spam = false              -- Removing some players spam (gold/portals/etc)
chat.whisp_sound = true        -- Sound when whisper
chat.combatlog = true          -- Show CombatLog tab
chat.tabs_mouseover = true     -- Chat tabs on mouseover
chat.damage_meter_spam = false -- Merge damage meter spam in one line-link

----------------------------------------------------------------------------------------
-- Nameplate options
----------------------------------------------------------------------------------------
local nameplate = CreateSection("nameplate")

nameplate.width = 120               -- Nameplate width
nameplate.height = 14               -- Nameplate height
nameplate.alpha = 0.7               -- Non-target nameplate alpha out of combat
nameplate.alpha_in_combat = 0.8     -- Alpha for non-target NPCs in combat with the player
nameplate.alpha_not_in_combat = 0.4 -- Alpha for non-target NPCs not in combat with the player
nameplate.combat = true             -- Automatically show nameplate in combat
nameplate.class_icons = false       -- Icons by class in PvP
nameplate.name_abbrev = true        -- Display abbreviated names
nameplate.short_name = true         -- Replace names with short ones
nameplate.clamp = true              -- Clamp nameplates to the top of the screen when outside of view
nameplate.track_debuffs = true      -- Show your debuffs (from the list)
nameplate.track_buffs = false       -- Show dispellable enemy buffs and buffs from the list
nameplate.auras_size = 20           -- Auras size
nameplate.healer_icon = false       -- Show icon above enemy healers nameplate in battlegrounds
nameplate.totem_icons = false       -- Show icon above enemy totems nameplate
nameplate.target_glow = true        -- Show glow texture for target
nameplate.target_arrow = true       -- Show arrow for target
nameplate.only_name = true          -- Show only name for friendly units
nameplate.quests = true             -- Show quest icon
nameplate.cast_color = false        -- Show color border for casting important spells
nameplate.kick_color = false        -- Change cast color if interrupt on cd

-- Threat
nameplate.enhance_threat = true          -- Enable threat feature, automatically changes by your role
nameplate.good_color = { 0.2, 0.8, 0.2 } -- Good threat color
nameplate.near_color = { 1, 1, 0 }       -- Near threat color
nameplate.bad_color = { 1, 0, 0 }        -- Bad threat color
nameplate.offtank_color = { 0, 0.5, 1 }  -- Offtank threat color
nameplate.extra_color = { 1, 0.3, 0 }    -- Explosive and Spiteful affix color
nameplate.mob_color_enable = false       -- Change color for important mobs in dungeons
nameplate.mob_color = { 0, 0.5, 0.8 }    -- Color for mobs

----------------------------------------------------------------------------------------
-- Scrolling Combat Text options
----------------------------------------------------------------------------------------
local sct = CreateSection("sct")

sct.enable = true            -- Global enable combat text
sct.overkill = false         -- Use blizzard damage/healing output (above mob/player head)
sct.x_offset = 0             -- Horizontal offset for text
sct.y_offset = 35            -- Vertical offset for text
sct.default_color = "ffff00" -- Default text color
sct.alpha = 1              -- Text transparency

-- Off-target options
sct.offtarget_enable = true -- Enable off-target text
sct.offtarget_size = 12     -- Off-target text size
sct.offtarget_alpha = 0.6   -- Off-target text transparency

-- Personal text options
sct.personal_enable = false           -- Enable personal text
sct.personal_only = false             -- Show only personal text
sct.personal_default_color = "ffff00" -- Personal text color
sct.personal_x_offset = 0             -- Personal text horizontal offset
sct.personal_y_offset = 0             -- Personal text vertical offset

-- Strata options
sct.strata_enable = false       -- Enable custom strata
sct.strata_target = "HIGH"      -- Target strata level
sct.strata_offtarget = "MEDIUM" -- Off-target strata level

-- Icon options
sct.icon_enable = true      -- Enable icons
sct.icon_scale = 1          -- Icon scale
sct.icon_shadow = true      -- Show icon shadow
sct.icon_position = "RIGHT" -- Icon position relative to text
sct.icon_x_offset = 0       -- Icon horizontal offset
sct.icon_y_offset = 0       -- Icon vertical offset

-- Truncate options
sct.truncate_enable = true -- Enable text truncation
sct.truncate_letter = true -- Use letter abbreviations (K, M, etc.)
sct.truncate_comma = true  -- Use comma for thousands separator

-- Size options
sct.size_crits = true                  -- Enlarge critical hits
sct.size_crit_scale = 1                -- Critical hit scale factor
sct.size_miss = false                  -- Enlarge misses
sct.size_miss_scale = 1                -- Miss scale factor
sct.size_small_hits = true             -- Reduce size of small hits
sct.size_small_hits_scale = 0.9        -- Small hit scale factor
sct.size_small_hits_hide = true        -- Hide small hits
sct.size_autoattack_crit_sizing = true -- Use crit sizing for auto-attack crits

-- Animation options
sct.animations_ability = "verticalUp"        -- Animation for ability text
sct.animations_crit = "verticalUp"           -- Animation for critical hits
sct.animations_miss = "verticalUp"           -- Animation for misses
sct.animations_autoattack = "verticalUp"     -- Animation for auto-attacks
sct.animations_autoattackcrit = "verticalUp" -- Animation for auto-attack crits
sct.animations_speed = 1                     -- Animation speed

-- Personal animation options
sct.personalanimations_normal = "verticalUp" -- Animation for normal personal text
sct.personalanimations_crit = "verticalUp"   -- Animation for personal crits
sct.personalanimations_miss = "verticalUp"   -- Animation for personal misses

----------------------------------------------------------------------------------------
-- Minimap options
----------------------------------------------------------------------------------------
local minimap = CreateSection("minimap")

minimap.size = 300                -- Minimap size
minimap.zoom_reset = true         -- Show toggle menu
minimap.reset_time = 15           -- Show toggle menu
-- Other
minimap.bg_map_stylization = true -- BG map stylization
minimap.fog_of_war = false        -- Remove fog of war on World Map

----------------------------------------------------------------------------------------
-- Loot options
----------------------------------------------------------------------------------------
local loot = CreateSection("loot")

loot.icon_size = 22         -- Icon size
loot.width = 221            -- Loot window width
loot.auto_greed = false     -- Push "greed" or "disenchant" button for green item roll at max level
loot.auto_confirm_de = true -- Auto confirm disenchant and take BoP loot

----------------------------------------------------------------------------------------
-- Loot Filter options
----------------------------------------------------------------------------------------
local lootfilter = CreateSection("lootfilter")

lootfilter.enable = true                                -- Enable loot frame
lootfilter.min_quality = 3                              -- Minimum quality to always loot (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
-- User Configuration
lootfilter.junk_minprice = 10                           -- Minimum value (in gold) of grey items to loot
lootfilter.tradeskill_subtypes = { "Parts", "Jewelcrafting", "Cloth", "Leather", "Metal & Stone", "Cooking", "Herb",
    "Elemental", "Other", "Enchanting", "Inscription" } -- Tradeskill subtypes to always loot
lootfilter.tradeskill_min_quality = 1                   -- Quality cap for autolooting tradeskill items (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
lootfilter.gear_min_quality = 2                         -- Minimum quality of BoP weapons and armor to autoloot (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
lootfilter.gear_unknown = true                          -- Override other gear settings to loot unknown appearances
lootfilter.gear_price_override = 20                     -- Minimum vendor price (in gold) to loot gear regardless of other criteria

----------------------------------------------------------------------------------------
-- Filger options
----------------------------------------------------------------------------------------
local filger = CreateSection("filger")

filger.enable = true           -- Enable Filger
filger.show_tooltip = false    -- Show tooltip
filger.expiration = true       -- Sort cooldowns by expiration time
-- Elements
filger.show_buff = true        -- Player buffs
filger.show_proc = true        -- Player procs
filger.show_debuff = false     -- Debuffs on target
filger.show_aura_bar = false   -- Aura bars on target
filger.show_special = true     -- Special buffs on player
filger.show_pvp_player = false -- PvP debuffs on player
filger.show_pvp_target = false -- PvP auras on target
filger.show_cd = false         -- Cooldowns
-- Icons size
filger.buffs_size = 48         -- Buffs size
filger.buffs_space = 3         -- Buffs space
filger.pvp_size = 60           -- PvP auras size
filger.pvp_space = 3           -- PvP auras space
filger.cooldown_size = 30      -- Cooldowns size
filger.cooldown_space = 3      -- Cooldowns space
-- Testing
filger.test_mode = false       -- Test icon mode
filger.max_test_icon = 5       -- Number of icons in test mode

----------------------------------------------------------------------------------------
-- Automation options
----------------------------------------------------------------------------------------
local automation = CreateSection("automation")

automation.release = true           -- Auto release the spirit in battlegrounds
automation.screenshot = false       -- Take screenshot when player get achievement
automation.accept_invite = false    -- Auto accept invite
automation.zone_track = true        -- Auto-Track Quests by Zone
automation.auto_collapse = "NONE"   -- Auto collapse Objective Tracker (RAID, RELOAD, SCENARIO, NONE)
automation.skip_cinematic = true    -- Auto skip cinematics/movies that have been seen (disabled if hold Ctrl)
automation.auto_role = false        -- Auto set your role
automation.cancel_bad_buffs = false -- Auto cancel annoying holiday buffs (from the list)
automation.resurrection = false     -- Auto confirm resurrection
automation.whisper_invite = false   -- Auto invite when whisper keyword
automation.invite_keyword = "inv +" -- List of keyword (separated by space)
automation.auto_repair = true       -- Auto repair
automation.guild_repair = true      -- Auto repair with guild funds first (if able)

----------------------------------------------------------------------------------------
-- Buffs reminder options
----------------------------------------------------------------------------------------
local reminder = CreateSection("reminder")

-- Self buffs
reminder.solo_buffs_enable = true  -- Enable buff reminder
reminder.solo_buffs_sound = false  -- Enable warning sound notification for buff reminder
reminder.solo_buffs_size = 64      -- Icon size
-- Raid buffs
reminder.raid_buffs_enable = false -- Show missing raid buffs
reminder.raid_buffs_always = true  -- Show frame always (default show only in raid)
reminder.raid_buffs_size = 32      -- Icon size
reminder.raid_buffs_alpha = 0      -- Transparent icons when the buff is present

----------------------------------------------------------------------------------------
-- Raid cooldowns options
----------------------------------------------------------------------------------------
local raidcooldown = CreateSection("raidcooldown")

raidcooldown.enable = true       -- Enable raid cooldowns
raidcooldown.height = 15         -- Bars height
raidcooldown.width = 186         -- Bars width (if show_icon = false, bar width+28)
raidcooldown.upwards = false     -- Sort upwards bars
raidcooldown.expiration = false  -- Sort by expiration time
raidcooldown.show_self = true    -- Show self cooldowns
raidcooldown.show_icon = true    -- Show icons
raidcooldown.show_inraid = true  -- Show in raid zone
raidcooldown.show_inparty = true -- Show in party zone
raidcooldown.show_inarena = true -- Show in arena zone

----------------------------------------------------------------------------------------
-- Enemy cooldowns options
----------------------------------------------------------------------------------------
local enemycooldown = CreateSection("enemycooldown")

enemycooldown.enable = true        -- Enable enemy cooldowns
enemycooldown.size = 30            -- Icon size
enemycooldown.direction = "RIGHT"  -- Icon direction
enemycooldown.show_always = false  -- Show everywhere
enemycooldown.show_inpvp = false   -- Show in bg zone
enemycooldown.show_inarena = true  -- Show in arena zone
enemycooldown.show_inparty = false -- Show in party zone for allies
enemycooldown.class_color = false  -- Enable classcolor border

----------------------------------------------------------------------------------------
-- Pulse cooldowns options
----------------------------------------------------------------------------------------
local pulsecooldown = CreateSection("pulsecooldown")

pulsecooldown.enable = false    -- Show cooldowns pulse
pulsecooldown.size = 75         -- Icon size
pulsecooldown.sound = false     -- Warning sound notification
pulsecooldown.anim_scale = 1.5  -- Animation scaling
pulsecooldown.hold_time = 0     -- Max opacity hold time
pulsecooldown.threshold = 3     -- Minimal threshold time
pulsecooldown.whitelist = false -- Use whitelist instead of ignore list

----------------------------------------------------------------------------------------
-- Trade options
----------------------------------------------------------------------------------------
local trade = CreateSection("trade")

trade.profession_tabs = true -- Professions tabs on TradeSkill frames
trade.already_known = true   -- Colorizes recipes/mounts/pets/toys that is already known
trade.sum_buyouts = true     -- Sum up all current auctions

----------------------------------------------------------------------------------------
-- Quest options
----------------------------------------------------------------------------------------
local quest = CreateSection("quest")

quest.auto_quest_enable = true           -- Enable QuickQuest
quest.auto_quest_share = false           -- Share quests automatically
quest.auto_quest_skipgossip = true       -- Skip gossip for NPCs
quest.auto_quest_skipgossipwhen = 1      -- Skip gossip when: 1 = Always, 2 = Instanced, 3 = City
quest.auto_quest_paydarkmoonfaire = true -- Automatically pay Darkmoon Faire fees
quest.auto_quest_pausekey = 'SHIFT'      -- Key to pause automation
quest.auto_quest_pausekeyreverse = false -- Reverse pause key behavior

----------------------------------------------------------------------------------------
-- Miscellaneous options
----------------------------------------------------------------------------------------
local misc = CreateSection("misc")

misc.afk_spin_camera = true  -- Spin camera while afk
misc.sticky_targeting = true -- Sticky targeting in combat

----------------------------------------------------------------------------------------
-- Combat Crosshair options
----------------------------------------------------------------------------------------
local combatcrosshair = CreateSection("combatcrosshair")

combatcrosshair.enable = true                                                    -- Enable combat crosshair
combatcrosshair.texture = [[Interface\AddOns\TKUI\Media\Textures\Crosshair.tga]] -- Crosshair texture
combatcrosshair.color = { 1, 1, 1 }                                              -- Crosshair color (RGB)
combatcrosshair.size = 20                                                        -- Crosshair size
combatcrosshair.offsetx = 0                                                      -- Horizontal offset
combatcrosshair.offsety = -25                                                    -- Vertical offset

----------------------------------------------------------------------------------------
-- Combat Cursor options
----------------------------------------------------------------------------------------
local combatcursor = CreateSection("combatcursor")
combatcursor.enable = true                                                       -- Enable combat cursor
combatcursor.texture = [[Interface\AddOns\TKUI\Media\Textures\CursorCircle.blp]] -- Cursor texture
combatcursor.color = { 1, 1, 1, 1 }                                              -- Cursor color (RGBA)
combatcursor.size = 50                                                           -- Cursor size

----------------------------------------------------------------------------------------
-- BigWigs Timeline options
----------------------------------------------------------------------------------------
local bwtimeline = CreateSection("bwtimeline")

bwtimeline.enable = true           -- Enable BigWigs Timeline
bwtimeline.refresh_rate = 0.05     -- Refresh rate for the timeline
bwtimeline.smooth_queueing = true  -- Enable smooth queueing
bwtimeline.bw_alerts = true        -- Enable BigWigs alerts
bwtimeline.invisible_queue = false -- Enable BigWigs alerts

-- Bar settings
bwtimeline.bar = {}
bwtimeline.bar_reverse = false                  -- Reverse bar direction
bwtimeline.bar_length = 316                     -- Length of the bar
bwtimeline.bar_width = 8                        -- Width of the bar
bwtimeline.bar_max_time = 20                    -- Maximum time displayed on the bar
bwtimeline.bar_hide_out_of_combat = true        -- Hide bar when out of combat
bwtimeline.bar_has_ticks = false                -- Show ticks on the bar
bwtimeline.bar_above_icons = true               -- Display bar above icons
bwtimeline.bar_tick_spacing = 5                 -- Spacing between ticks
bwtimeline.bar_tick_length = 20                 -- Length of ticks
bwtimeline.bar_tick_width = 1                   -- Width of ticks
bwtimeline.bar_tick_color = { 1, 1, 1, 1 }      -- Color of ticks (RGBA)
bwtimeline.bar_tick_text = true                 -- Show text on ticks
bwtimeline.bar_tick_text_font_size = 10         -- Font size of tick text
bwtimeline.bar_tick_text_position = "LEFT"      -- Position of tick text
bwtimeline.bar_tick_text_color = { 1, 1, 1, 1 } -- Color of tick text (RGBA)

-- Icon settings
bwtimeline.icons = {}
bwtimeline.icons_width = 35                      -- Width of icons
bwtimeline.icons_height = 35                     -- Height of icons
bwtimeline.icons_spacing = 3                     -- Adjust this value to increase/decrease spacing
bwtimeline.icons_duration = true                 -- Show duration on icons
bwtimeline.icons_duration_position = "CENTER"    -- Position of duration text on icons
bwtimeline.icons_duration_color = { 1, 1, 1, 1 } -- Color of duration text (RGBA)
bwtimeline.icons_name = true                     -- Show name on icons
bwtimeline.icons_name_position = "RIGHT"         -- Position of name text on icons
bwtimeline.icons_name_color = { 1, 1, 1, 1 }     -- Color of name text (RGBA)
bwtimeline.icons_name_acronym = false            -- Use acronyms for names
bwtimeline.icons_name_number = false             -- Show number on icons

----------------------------------------------------------------------------------------
-- Databar options
----------------------------------------------------------------------------------------
local databar = CreateSection("databar")

databar.enable = true                    -- Enable databar
databar.fontcolor = { 0.8, 0.8, 0.8, 1 } -- Font color (RGBA)
databar.iconsize = 32                    -- Icon size
databar.iconcolor = { 0.8, 0.8, 0.8, 1 } -- Icon color (RGBA)
databar.enableMouseover = true
databar.mouseoverAlpha = 1
databar.normalAlpha = .5
