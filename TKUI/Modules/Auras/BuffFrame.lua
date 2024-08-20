----------------------------------------------------------------------------------------
--	Player Buff Frame for TKUI
--	This module styles and manages the player's buff frame, including layout, duration,
--	and visual elements like cooldown swipes and border colors.
--	Based on Tukz's original buff styling
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)

----------------------------------------------------------------------------------------
--	Constants and Configuration
----------------------------------------------------------------------------------------
local rowbuffs = 16
local alpha = 0

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------
local GetFormattedTime = function(s)
    if s >= 86400 then
        return format("%dd", floor(s / 86400 + 0.5))
    elseif s >= 3600 then
        return format("%dh", floor(s / 3600 + 0.5))
    elseif s >= 60 then
        return format("%dm", floor(s / 60 + 0.5))
    end
    return floor(s + 0.5)
end

----------------------------------------------------------------------------------------
--	Buff Frame Anchor
----------------------------------------------------------------------------------------
local BuffsAnchor = CreateFrame("Frame", "BuffsAnchor", UIParent)
BuffsAnchor:SetPoint(unpack(C.position.player_buffs))
BuffsAnchor:SetSize((15 * C.aura.player_buff_size) + 42, (C.aura.player_buff_size * 2) + 3)

----------------------------------------------------------------------------------------
--	Aura Update Functions
----------------------------------------------------------------------------------------
local function UpdateDuration(aura, timeLeft)
    local duration = aura.Duration
    if timeLeft and C.aura.show_timer == true then
        duration:SetVertexColor(1, 1, 1)
        duration:SetFormattedText(GetFormattedTime(timeLeft))
    else
        duration:Hide()
    end
end

local function UpdateBorderColor(aura)
    if aura.buttonInfo and aura.buttonInfo.duration and aura.buttonInfo.duration > 0 then
        if C.aura.player_buff_classcolor == true then
            aura:SetBackdropBorderColor(unpack(C.media.classborder_color))
        else
            aura:SetBackdropBorderColor(0, 1, 0, 1) -- Green border for timed buffs
        end
    else
        aura:SetBackdropBorderColor(unpack(C.media.border_color)) -- Default border for permanent buffs
    end
end

local function UpdateCooldownSwipe(aura)
    if aura.buttonInfo and aura.buttonInfo.duration and aura.buttonInfo.duration > 0 then
        local start = aura.buttonInfo.expirationTime - aura.buttonInfo.duration
        aura.cooldown:SetCooldown(start, aura.buttonInfo.duration)
        aura.cooldown:Show()
    else
        aura.cooldown:Hide()
    end
    UpdateBorderColor(aura)
end

----------------------------------------------------------------------------------------
--	Buff Frame Styling and Layout
----------------------------------------------------------------------------------------
hooksecurefunc(BuffFrame.AuraContainer, "UpdateGridLayout", function(self, auras)
    local previousBuff, aboveBuff
    for index, aura in ipairs(auras) do
        -- Set size and template
        aura:SetSize(C.aura.player_buff_size, C.aura.player_buff_size)
        aura:SetTemplate("Default")

        -- Handle temporary enchant border
        aura.TempEnchantBorder:SetAlpha(0)
        hooksecurefunc(aura.TempEnchantBorder, "Show", function(self)
            aura:SetBackdropBorderColor(0.6, 0.1, 0.6)
        end)

        hooksecurefunc(aura.TempEnchantBorder, "Hide", function(self)
            if C.aura.player_buff_classcolor == true then
                aura:SetBackdropBorderColor(unpack(C.media.classborder_color))
            else
                aura:SetBackdropBorderColor(0, 1, 0, 1)
            end
        end)

        -- Set initial border color
        if aura.player_buff_classcolor then
            aura:SetBackdropBorderColor(unpack(C.media.classborder_color))
        else
            aura:SetBackdropBorderColor(0, 1, 0, 1)
        end

        -- Position auras in grid layout
        aura:ClearAllPoints()
        if (index > 1) and (mod(index, rowbuffs) == 1) then
            aura:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -3)
            aboveBuff = aura
        elseif index == 1 then
            aura:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
            aboveBuff = aura
        else
            aura:SetPoint("RIGHT", previousBuff, "LEFT", -3, 0)
        end

        previousBuff = aura

        -- Create and configure cooldown swipe
        if not aura.cooldown then
            aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
            aura.cooldown:SetAllPoints(aura)
            aura.cooldown:SetDrawBling(false)
            aura.cooldown:SetDrawEdge(false)
            aura.cooldown:SetSwipeColor(0, 0, 0, 0.8)
            aura.cooldown:SetReverse(true)
        end

        aura.cooldown:SetFrameLevel(aura:GetFrameLevel() + 1)

        -- Adjust the Icon
        aura.Icon:CropIcon()

        -- Create separate frame for icon to control stacking order
        if not aura.iconFrame then
            aura.iconFrame = CreateFrame("Frame", nil, aura)
            aura.iconFrame:SetPoint("TOPLEFT", aura, "TOPLEFT", 3, -3)
            aura.iconFrame:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", -3, 3)
            aura.Icon:SetParent(aura.iconFrame)
        end

        aura.iconFrame:SetFrameLevel(aura.cooldown:GetFrameLevel() + 1)

        -- Configure duration text
        local duration = aura.Duration
        duration:ClearAllPoints()
        duration:SetPoint("CENTER", 0, 0)
        duration:SetParent(aura.iconFrame)
        duration:SetFont(C.font.auras_font, C.font.player_buffs_font_size, C.font.player_buffs_font_style)
        duration:SetShadowOffset(C.font.player_buffs_font_shadow and 1 or 0, C.font.player_buffs_font_shadow and -1 or 0)

        -- Hook duration update function
        if not aura.hook then
            hooksecurefunc(aura, "UpdateDuration", function(aura, timeLeft)
                UpdateDuration(aura, timeLeft)
            end)
            aura.hook = true
        end

        -- Configure stack count
        if aura.Count then
            aura.Count:ClearAllPoints()
            aura.Count:SetPoint("BOTTOMRIGHT", 0, 1)
            aura.Count:SetParent(aura.iconFrame)
            aura.Count:SetFont(C.font.player_buffs_count_font, C.font.player_buffs_count_font_size,
                C.font.player_buffs_count_font_style)
            aura.Count:SetShadowOffset(C.font.player_buffs_count_font_shadow and 1 or 0,
                C.font.player_buffs_count_font_shadow and -1 or 0)
        end

        UpdateCooldownSwipe(aura)

        -- Hook Update function for cooldown swipe
        if not aura.cooldownHook then
            hooksecurefunc(aura, "Update", function(self, buttonInfo)
                self.buttonInfo = buttonInfo
                UpdateCooldownSwipe(self)
            end)
            aura.cooldownHook = true
        end

        -- Initial update of cooldown swipe and border color
        UpdateCooldownSwipe(aura)
    end
end)

----------------------------------------------------------------------------------------
--	Hide Default UI Elements
----------------------------------------------------------------------------------------
-- Hide collapse button
BuffFrame.CollapseAndExpandButton:Kill()

-- Hide debuffs
DebuffFrame.AuraContainer:Hide()
