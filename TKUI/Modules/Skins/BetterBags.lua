local T, C, L = unpack(TKUI)
if not C_AddOns.IsAddOnLoaded("BetterBags") then return end


---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class SearchBox: AceModule
local searchBox = addon:GetModule('SearchBox')

---@class Themes: AceModule
local themes = addon:GetModule('Themes')

---@class Fonts: AceModule
local fonts = addon:GetModule('Fonts')

---@type table<string, ItemButton>
local itemButtons = {}

---@class TKUIDecoration: Frame
---@field title FontString
---@field search SearchFrame
---@field bg BackdropTemplate|Frame

---@type table<string, TKUIDecoration>
local decoratorFrames = {}

---@type Theme
local TKUI = {
  -- This is the name of the theme, as it appears in the UI when selecting themes.
  Name = 'TKUI',
  -- This is a description of the theme, as it appears in the UI when selecting themes.
  Description = 'BetterBags TKUI Theme.',
  -- This is a boolean that determines if the theme is available to the user. You can use this to
  -- detect if the user has a specific addon installed, or if a specific condition is met, and only
  -- then present this theme, i.e. only show this theme if ElvUI is installed.
  Available = true,
  -- This function will theme a portrait frame. These frames are used for the main bag and
  -- bank windows.
  Portrait = function(frame)
    -- 'frame' is the main frame of the window. Do not add anything to this frame
    -- except for your decoration frame.

    -- You want to only generate your decoration frame once, when the user first activates the theme.
    -- After generation, you need to cache the decoration frame so you can show and hide it as needed.
    local decoration = decoratorFrames[frame:GetName()]

    -- The decoration does not exist, so make it.
    if not decoration then
      -- A decoration is just another frame that we "overlay" on top of the 'frame' provided by this function
      -- This decoration will be used to add a backdrop, title, and close button to the frame.
      decoration = CreateFrame("Frame", frame:GetName() .. "ThemeTKUI", frame) --[[@as TKUIDecoration]]
      decoration:SetAllPoints()
      decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
      decoration:SetTemplate("Transparent")
      -- decoration.bg = CreateFrame("Frame", decoration:GetName() .. "BG", decoration, "BackdropTemplate")
      -- decoration.bg:SetAllPoints()
      -- decoration.bg:SetFrameLevel(frame:GetFrameLevel() - 1)
      -- decoration.bg:SetBackdrop({
      --   bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeSize = 1,
      -- })
      -- decoration.bg:SetBackdropColor(0, 0, 0, 1)
      -- decoration.bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

      -- Title text
      local title = decoration:CreateFontString(nil, "OVERLAY")
      title:SetFontObject(fonts.UnitFrame12White)
      title:SetPoint("TOP", decoration, "TOP", 0, 0)
      title:SetHeight(30)
      decoration.title = title

      -- Titles for frames can change at any time, so make sure you pull the title text
      -- from the themes title table for this specific frame.
      if themes.titles[frame:GetName()] then
        decoration.title:SetText(themes.titles[frame:GetName()])
      end

      local close = CreateFrame("Button", nil, decoration)
      close:SetNormalTexture("Interface\\AddOns\\BetterBags\\textures\\close.png")
      close:GetNormalTexture():SetInside(close, 5, 5)
      close:SetHighlightTexture("Interface\\AddOns\\BetterBags\\textures\\close.png")
      close:GetHighlightTexture():SetInside(close, 5, 5)
      close:SetSize(20, 20)
      close:SetTemplate("Transparent")
      close:SetPoint("TOPRIGHT", decoration, "TOPRIGHT", -8, -8)
      close:SetScript("OnClick", function()
        -- frame.Owner is the bag construct itself in 'frames\bag.lua'. You can use this
        -- to access the bag construct's methods and properties if needed.
        frame.Owner:Hide()
      end)
      close:SetFrameLevel(1001)

      local box = searchBox:CreateBox(frame.Owner.kind, decoration --[[@as Frame]])
      box.frame:SetPoint("TOP", decoration, "TOP", 0, -16)
      box.frame:SetSize(150, 20)
      decoration.search = box

      -- The bag button is abstracted here as it's a common element across all themes.
      -- This function does return the bag button, and you can modify it as you need.
      local bagButton = themes.SetupBagButton(frame.Owner, decoration --[[@as Frame]])
      bagButton:SetPoint("TOPLEFT", decoration, "TOPLEFT", 4, -6)
      local w, h = bagButton.portrait:GetSize()
      bagButton.portrait:SetSize((w / 10) * 8.5, (h / 10) * 8.5)
      bagButton.highlightTex:SetSize((w / 10) * 8.5, (h / 10) * 8.5)

      -- Save the decoration frame for reuse.
      decoratorFrames[frame:GetName()] = decoration
    else
      -- The decoration frame was previously created here, so just show it.
      decoration:Show()
    end
  end,
  -- Simple frames are the frames for sidebar and configuration screens.
  Simple = function(frame)
    local decoration = decoratorFrames[frame:GetName()]
    if not decoration then
      -- Backdrop
      decoration = CreateFrame("Frame", frame:GetName() .. "ThemeTKUI", frame) --[[@as TKUIDecoration]]
      decoration:SetAllPoints()
      decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
      decoration:SetTemplate("Transparent")
      -- decoration.bg = CreateFrame("Frame", decoration:GetName() .. "BG", decoration, "BackdropTemplate")
      -- decoration.bg:SetAllPoints()
      -- decoration.bg:SetFrameLevel(frame:GetFrameLevel() - 1)
      -- decoration.bg:SetBackdrop({
      --   bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeSize = 1,
      -- })
      -- decoration.bg:SetBackdropColor(0, 0, 0, 1)
      -- decoration.bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

      -- Title text
      local title = decoration:CreateFontString(nil, "OVERLAY")
      title:SetFontObject(fonts.UnitFrame12White)
      title:SetPoint("TOP", decoration, "TOP", 0, 0)
      title:SetHeight(30)
      decoration.title = title

      local close = CreateFrame("Button", nil, decoration)
      close:SetNormalTexture("Interface\\AddOns\\BetterBags\\textures\\close.png")
      close:GetNormalTexture():SetInside(close, 5, 5)
      close:SetHighlightTexture("Interface\\AddOns\\BetterBags\\textures\\close.png")
      close:GetHighlightTexture():SetInside(close, 5, 5)
      close:SetSize(20, 20)
      close:SetTemplate("Transparent")
      close:SetPoint("TOPRIGHT", decoration, "TOPRIGHT", -8, -8)
      close:SetScript("OnClick", function()
        frame:Hide()
      end)
      close:SetFrameLevel(1001)

      if themes.titles[frame:GetName()] then
        decoration.title:SetText(themes.titles[frame:GetName()])
      end
      -- Save the decoration frame for reuse.
      decoratorFrames[frame:GetName()] = decoration
    else
      decoration:Show()
    end
  end,
  -- Flat frames are small frames with no close buttons, such as modals, the bag slot menu, etc.
  Flat = function(frame)
    local decoration = decoratorFrames[frame:GetName()]
    if not decoration then
      -- Backdrop
      decoration = CreateFrame("Frame", frame:GetName() .. "ThemeTKUI", frame) --[[@as TKUIDecoration]]
      decoration:SetAllPoints()
      decoration:SetFrameLevel(frame:GetFrameLevel() - 1)
      decoration:SetTemplate("Transparent")
      -- decoration.bg = CreateFrame("Frame", decoration:GetName() .. "BG", decoration, "BackdropTemplate")
      -- decoration.bg:SetAllPoints()
      -- decoration.bg:SetFrameLevel(frame:GetFrameLevel() - 1)
      -- decoration.bg:SetBackdrop({
      --   bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeFile = 'Interface\\ChatFrame\\ChatFrameBackground',
      --   edgeSize = 1,
      -- })
      -- decoration.bg:SetBackdropColor(0, 0, 0, 1)
      -- decoration.bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

      -- Title text
      local title = decoration:CreateFontString(nil, "OVERLAY")
      title:SetFontObject(fonts.UnitFrame12White)
      title:SetPoint("TOP", decoration, "TOP", 0, 0)
      title:SetHeight(30)
      decoration.title = title

      if themes.titles[frame:GetName()] then
        decoration.title:SetText(themes.titles[frame:GetName()])
      end
      -- Save the decoration frame for reuse.
      decoratorFrames[frame:GetName()] = decoration
    else
      decoration:Show()
    end
  end,
  -- The Opacity function is called when the user updates the opacity for a given frame. You need
  -- to apply the opacity to the decoration frame you created in the Portrait, Simple, or Flat functions.
  Opacity = function(frame, alpha)
    local decoration = decoratorFrames[frame:GetName()]
    -- if decoration then
    --   decoration.bg:SetAlpha(alpha / 100)
    -- end
  end,
  -- The SetSectionFont function is called when the user updates the font for item sections
  -- such as "Reagent", "Recent Items", etc. This is also applied on load.
  SectionFont = function(font)
    font:SetFontObject(fonts.UnitFrame12White)
  end,
  -- SetTitle is called when the title of a frame changes.
  SetTitle = function(frame, title)
    local decoration = decoratorFrames[frame:GetName()]
    if decoration then
      decoration.title:SetText(title)
    end
  end,
  -- Reset is called when your frame is unloaded. You should hide your decoration frames here.
  -- Ideally, all changes made should only exist within a decoration frame, making reset a simple
  -- function to hide all decoration frames.
  Reset = function()
    for _, frame in pairs(decoratorFrames) do
      frame:Hide()
    end
  end,
  ItemButton = function(item)
    local buttonName = item.button:GetName()
    local button = itemButtons[buttonName]
    if button then
      button:SetFrameLevel(item.button:GetFrameLevel())
      button:Show()
      return button
    end

    button = themes.CreateBlankItemButtonDecoration(item.frame, "TKUI", buttonName)
    if button.IconBorder then
      button.IconBorder:SetAlpha(0)
      button.IconBorder.Show = button.IconBorder.Hide
    end
    button:StripTextures()
    button:SetTemplate("Transparent")
    button:SetFrameLevel(item.button:GetFrameLevel())

    button:GetNormalTexture():SetAlpha(0)

    -- Crop the icon texture
    local icon = button.icon or button.Icon or button:GetNormalTexture()
    if icon then
      icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      icon:SetInside(button, 3, 3)
    end

    if button.Count then
      button.Count:ClearAllPoints()
      button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
      button.Count:SetJustifyH("RIGHT")
      -- button.Count:SetFontObject(T.GetFont(12)) -- Adjust font and size as needed
    end

    if item.ilvlText then
      item.ilvlText:ClearAllPoints()
      item.ilvlText:SetPoint("TOP", button, "TOP", 0, -2)
      item.ilvlText:SetJustifyH("CENTER")
    end

    -- Set up textures
    button:StyleButton()

    -- Set up quality coloring
    hooksecurefunc(button, "SetItemButtonQuality", function(self, quality)
      if quality and quality > Enum.ItemQuality.Common then
        local r, g, b = GetItemQualityColor(quality)
        self:SetBackdropBorderColor(r, g, b)
      else
        self:SetBackdropBorderColor(unpack(C.media.border_color))
      end
    end)

    itemButtons[buttonName] = button
    return button
  end,
  -- ToggleSearch is called when the user enables or disables in-bag search.
  ToggleSearch = function(frame, shown)
    local decoration = decoratorFrames[frame:GetName()]
    if decoration then
      decoration.search:SetShown(shown)
      if shown then
        decoration.title:Hide()
      else
        decoration.title:Show()
      end
    end
  end
}

themes:RegisterTheme('TKUI', TKUI)
