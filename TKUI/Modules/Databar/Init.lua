----------------------------------------------------------------------------------------
--	TKUI Data Bar for TKUI
--	This module creates a custom data bar for TKUI, displaying information like
--  system performance, character stats, currency, and more.
----------------------------------------------------------------------------------------

local T, C, L = unpack(TKUI)
local DB = {}

----------------------------------------------------------------------------------------
--	Bar Creation
----------------------------------------------------------------------------------------

local function SetupMouseoverBehavior(frame)
    if C.databar.enableMouseover then
        frame:SetAlpha(C.databar.normalAlpha)

        local function OnEnter(self)
            frame:SetAlpha(C.databar.mouseoverAlpha)
        end

        local function OnLeave(self)
            C_Timer.After(0.1, function()
                if not MouseIsOver(frame) then
                    frame:SetAlpha(C.databar.normalAlpha)
                end
            end)
        end

        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)

        -- Apply to all child frames recursively
        local function ApplyToChildren(parent)
            for _, child in ipairs({ parent:GetChildren() }) do
                child:HookScript("OnEnter", OnEnter)
                child:HookScript("OnLeave", OnLeave)
                ApplyToChildren(child)
            end
        end

        ApplyToChildren(frame)

        -- Create a timer to check mouse position periodically
        frame.updateTimer = C_Timer.NewTicker(0.1, function()
            if MouseIsOver(frame) then
                frame:SetAlpha(C.databar.mouseoverAlpha)
            else
                frame:SetAlpha(C.databar.normalAlpha)
            end
        end)
    else
        frame:SetAlpha(C.databar.mouseoverAlpha)
    end
end

function DB:CreateLeftBar()
    -- Create the main frame for the left TKUIBar
    self.TKUILeftBar = CreateFrame("Frame", "TKUILeftBar", UIParent)
    self.TKUILeftBar:CreatePanel("Invisible", 600, 40, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    SetupMouseoverBehavior(self.TKUILeftBar)
end

function DB:CreateRightBar1()
    -- Create the main frame for the right TKUIBar (section 1)
    self.TKUIRightBar1 = CreateFrame("Frame", "TKUIRightBar1", UIParent)
    self.TKUIRightBar1:CreatePanel("Invisible", 300, 40, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 0)
    SetupMouseoverBehavior(self.TKUIRightBar1)
end

function DB:CreateRightBar2()
    -- Create the main frame for the right TKUIBar (section 2)
    self.TKUIRightBar2 = CreateFrame("Frame", "TKUIRightBar2", UIParent)
    self.TKUIRightBar2:CreatePanel("Invisible", 300, 40, "RIGHT", "TKUIRightBar1", "LEFT", -4, 0)
    SetupMouseoverBehavior(self.TKUIRightBar2)
end

-- If you need to access the TKUIBar module from other parts of your addon:
T.DB = DB
return DB
