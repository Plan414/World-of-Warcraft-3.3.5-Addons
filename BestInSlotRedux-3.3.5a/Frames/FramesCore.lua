--lua
local unpack, select, pairs, strjoin, type, wipe, tostring, tonumber, error, setmetatable, tinsert, tsort, tremove, max, min
=     unpack, select, pairs, strjoin, type, wipe, tostring, tonumber, error, setmetatable, table.insert, table.sort, table.remove, math.max, math.min
-- WoW API
local GetSpecializationInfoByID, GetItemStatDelta, IsControlKeyDown, IsShiftKeyDown, SetCursor, ResetCursor, DressUpItemLink, GetItemIcon, GetAddOnMetadata, GetSpecializationInfo, PlaySound, GetNumSpecializations, UnitAffectingCombat
=     GetSpecializationInfoByID, GetItemStatDelta, IsControlKeyDown, IsShiftKeyDown, SetCursor, ResetCursor, DressUpItemLink, GetItemIcon, GetAddOnMetadata, GetSpecializationInfo, PlaySound, GetNumSpecializations, UnitAffectingCombat
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local frameName = "BestInSlotFrame"
local frame
local menuItems = {}
local menuLabels
local container, menuContainer
local selectedMenuId = 1
local MINIMUMWIDTH, MINIMUMHEIGHT = 250, 300
local animating = false
local biggestWidth, biggestHeight

local function getWidthForModule(module)
  local type = type(module.Width)
  if type == "number" then return module.Width
  elseif type == "function" then return module.Width() end
end

local function getHeightForModule(module)
  local type = type(module.Height)
  if type == "number" then return module.Height
  elseif type == "function" then return module.Height() end
end

local function getBiggestWidth()
  if not biggestWidth then
    biggestWidth = getWidthForModule(menuItems[1]) 
    for i=2,#menuItems do
      local modWidth = getWidthForModule(menuItems[i])
      if modWidth > biggestWidth then
        biggestWidth = modWidth
      end
    end
  end
  return biggestWidth
end

local function getBiggestHeight()
  if not biggestHeight then
    biggestHeight = getHeightForModule(menuItems[1])
    for i=2,#menuItems do
      local height = getHeightForModule(menuItems[i])
      if height > biggestHeight then
        biggestHeight = height
      end
    end
  end
  return biggestHeight
end

local function addGuildInfoToTooltip(tooltip, itemId, difficultyId)
  if BestInSlot.db.char.options.guildtooltip then
    local players = BestInSlot:GetGuildMembersByItemID(itemId, difficultyId)
    local first = true
    local obtainedPlayers = {}
    for player, playerSpecs in pairs(players) do
      local guildRank = BestInSlot:GetGuildRank(player)
      if guildRank and BestInSlot.db.char.options.showGuildRankInTooltip[guildRank] then
        local specNames = {}
        local specNamesObtained = {}
        for specId, obtained in pairs(playerSpecs) do
          local tbl = specNames
          if obtained then tbl = specNamesObtained end
          local specName = select(2, GetSpecializationInfoByID(specId))
          tinsert(tbl, specName)
        end
        if #specNames > 0 then
          if first then
            tooltip:AddLine(L["The following people in your guild also need this item:"], nil, nil, nil, true)
            first = false
          end 
          tooltip:AddLine(("- %s (%s)"):format(BestInSlot:GetPlayerString(player), strjoin("/", unpack(specNames))))
        end
        if #specNamesObtained > 0 then
          obtainedPlayers[player] = specNamesObtained
        end
      end
    end
    first = true
    for player, specNames in pairs(obtainedPlayers) do
      if first then
        tooltip:AddLine("")
        tooltip:AddLine(L["The following people in your guild already obtained this item"], nil, nil, nil, true)
        first = false
      end
      tooltip:AddLine(("- %s (%s)"):format(BestInSlot:GetPlayerString(player), strjoin("/", unpack(specNames))))
    end
  end
end

--- Helper for starting an animation
local function startAnimating()
  animating = true
end

--- Helper for stopping an animation
local function stopAnimating()
  animating = false
end

--- Set the size of the frame
-- @param #number targetWidth The new width
-- @param #number targetHeight the new height
-- @param #function func The function to run when the frame is done resizing
function BestInSlot:SetFrameSize(targetWidth, targetHeight, func, ...)
  if not frame then return end
  if self.options.windowFixed then
    frame:SetWidth(getBiggestWidth())
    frame:SetHeight(getBiggestHeight())
    if func and type(func) == "function" then
      func(...)
    end
    return
  end
  local currentWidth, currentHeight = frame.frame.width, frame.frame.height
  if not targetWidth then targetWidth = currentWidth end
  if not targetHeight then targetHeight = currentHeight end
  if targetWidth == currentWidth and targetHeight == currentHeight then
    if type(func) == "function" then
      func(...)
    end
    return
  end
  if self.options.instantAnimation then
    frame:SetHeight(targetHeight)
    frame:SetWidth(targetWidth)
    if type(func) == "function" then
      func(...)
    end
  else
    local ANIMATIONTIME = 500 --milliseconds
    local timer = 0
    local incWidth = (targetWidth - currentWidth) / (ANIMATIONTIME / 80)
    local incHeight = (targetHeight - currentHeight) / (ANIMATIONTIME / 80)
    startAnimating()
    local resizeTimerId
    local funcArgs = {...}
    resizeTimerId = self:ScheduleRepeatingTimer(function()
      if not frame then stopAnimating() BestInSlot:CancelTimer(resizeTimerId) end
      if incHeight < 0 then
        frame:SetHeight(max(frame.frame.height + incHeight, targetHeight))
      else
        frame:SetHeight(min(frame.frame.height + incHeight, targetHeight))
      end
      if incWidth < 0 then
        frame:SetWidth(max(frame.frame.width + incWidth, targetWidth))
      else
        frame:SetWidth(min(frame.frame.width + incWidth, targetWidth))
      end
      if frame.frame.width == targetWidth and frame.frame.height == targetHeight then
        BestInSlot:CancelTimer(resizeTimerId)
        if func and type(func) == "function" then
          stopAnimating()
          func(unpack(funcArgs))
        end
      end
    end,
    0.025)
  end
end

--- Sets the content to the supplied menuWidget
-- @param #table menuWidget An AceGUI Widget with the UserData "id" set to the id of the menu to set the content to
local function SetContent(menuWidget)
  local id = menuWidget:GetUserData("id")
  if not id then error("The menu widget that has been made didn't provide an id") end
  if animating then return false end
  return BestInSlot:SetMenu(id)
end

function BestInSlot:SetMenu(id, ...)
  local args = {...}
  local item = menuItems[id]
  if selectedMenuId then
    local selectedItem = menuItems[selectedMenuId] 
    selectedItem:Close() 
    BestInSlot:HideItemTooltip()
    wipe(container:GetUserDataTable())
    local menuLabel = menuLabels[selectedMenuId]
    if menuLabel then
      menuLabel:SetColor(0.8941, 0.73725, 0.01961)
      menuLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    end
  end
  local menuLabel = menuLabels[id]
  if menuLabel then
    menuLabel:SetColor(1,1,1)
    menuLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
  end
  container:ReleaseChildren()
  container:SetLayout("Flow")
  self:SetFrameSize(getWidthForModule(item), getHeightForModule(item), function() container:ResumeLayout() item:Draw(container, unpack(args)) BestInSlot:CheckTutorials(item.Description) end)
  selectedMenuId = id
  return true
end

function BestInSlot:HideItemTooltip()
  if GameTooltip:IsShown() then
    GameTooltip.itemInfo = nil
    GameTooltip:Hide()
  end
  if BISComparisonTooltip then
    BISComparisonTooltip:Hide()
  end
end

local playerClass

function BestInSlot:GetItemTooltip(itemid, difficulty, frame, itemlink)
  if frame then
    GameTooltip:SetOwner(frame.frame)
    GameTooltip:SetAnchorType("ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", frame.frame, "TOPRIGHT", 10, 0)
  else
    GameTooltip:SetOwner(UIParent)
  end
  if not self:ItemExists(itemid) and itemlink then
    GameTooltip:SetHyperlink(itemlink)
  end
  local item = self:GetItem(itemid, difficulty)
  if not item then return end
  playerClass = playerClass or select(3, UnitClass("player"))
  GameTooltip:SetHyperlink(item.link, playerClass, select(2, self:GetSelected(self.SPECIALIZATION)))
  GameTooltip.itemInfo = item
  if self.options.DEBUG then
    GameTooltip:AddLine("itemid: "..tostring(itemid))
    GameTooltip:AddLine("dungeon: "..tostring(item.dungeon))
    GameTooltip:AddLine("bossid: "..tostring(item.bossid))
    GameTooltip:AddLine("link: "..tostring(item.link))
    GameTooltip:AddLine("difficulty: "..tostring(item.difficulty))
    GameTooltip:AddLine("equipslot: "..tostring(item.equipSlot))
    if item.misc then
      GameTooltip:AddLine("Item is misc source: "..item.misc)
    end
    if item.tieritem then
      GameTooltip:AddLine("Item is tier item")
    end
    if item.tiertoken then
      GameTooltip:AddLine("Item is tier token")
    end
  end
  GameTooltip:Show()
  return GameTooltip
end

function BestInSlot:GetItemComparisonTooltip(tooltip, selectedItem, difficulty)
  local compareItem = tooltip.itemInfo
  local item = self:GetItem(selectedItem, difficulty)
  if not compareItem then return end
  if compareItem.itemid == item.itemid and compareItem.difficulty == item.difficulty then return end --don't show then it's comparing itself!
  if not BISComparisonTooltip then
    CreateFrame("GameTooltip", "BISComparisonTooltip", tooltip, "GameTooltipTemplate")
  end
  if not BISComparisonTooltip:IsShown() then
    BISComparisonTooltip:SetOwner(BestInSlot.frame.frame)
    BISComparisonTooltip:SetAnchorType("ANCHOR_NONE")
    BISComparisonTooltip:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT")
  end
  BISComparisonTooltip:SetHyperlink(item.link, playerClass, select(2, self:GetSelected(self.SPECIALIZATION)))
  local statDelta = GetItemStatDelta(item.link, compareItem.link)
  for stat,value in pairs(statDelta) do
    BISComparisonTooltip:AddLine(("%s%d %s"..FONT_COLOR_CODE_CLOSE):format((value > 0 and GREEN_FONT_COLOR_CODE or RED_FONT_COLOR_CODE), value, tostring(_G[stat])))
  end
  BISComparisonTooltip:Show()
end

function BestInSlot:GameTooltip_OnTooltipSetItem(tooltip, ...)
  if self.db.char.options.showBiSTooltip and (self.db.char.options.tooltipCombat or not UnitAffectingCombat("player")) then
    local _, link = tooltip:GetItem()
    if link then
      local itemId, instanceID = self:GetItemInfoFromLink(link)
      local exists, existType = self:ItemExists(itemId)
      if not exists then return end
      if itemId then
        instanceID = tonumber(instanceID)
        instanceID = self:GetDifficultyIdForDungeon(instanceID, nil, true) or 1
        local bisInfo 
        if existType == "item" then
          bisInfo = self:IsItemBestInSlot(itemId, instanceID)
        else 
          bisInfo = self:IsTokenBestInSlot(itemId, instanceID)
        end
        local isBiS = false --catch empty tables
        if bisInfo and type(bisInfo) == "table" then
          local specsText = ""
          local first = true
          for specId in pairs(bisInfo) do
            isBiS = true
            if not first then
              specsText = specsText.."/"
            end
            specsText = specsText..(type(specId) == "string" and specId or select(2,GetSpecializationInfoByID(specId))) --custom lists can just show as custom list, otherwise lookup spec name
            first = false
          end
          if isBiS then
            local color = self.colorHighlight
            if self:HasItem(itemId, instanceID, true) then
              color = GREEN_FONT_COLOR_CODE
            end
            tooltip:AddLine(("%1$s (%2$s)"):format(color.."BestInSlot"..self.colorNormal, color..specsText.."|r"))
          end
        end
        local item = self:GetItem(itemId)
        if item and (self.db.char.options.tooltipSource or self.options.DEBUG) then
          if item.multiplesources then
            tooltip:AddLine(SOURCES..":")
            for dungeonname,v in pairs(item.multiplesources) do
              for bossid in pairs(v) do
                tooltip:AddLine(("%s%s %s(%s)|r"):format(self.colorHighlight, self:GetDescription(self.BOSS, dungeonname, bossid), self.colorNormal, dungeonname))
              end
            end
          elseif item.dungeon and item.bossid then
            tooltip:AddLine(("%s %s%s"):format(SOURCE, self.colorHighlight, self:GetDescription(self.BOSS, item.dungeon, item.bossid)))
          elseif item.misc then
            tooltip:AddLine(("%s %s%s"):format(SOURCE, self.colorHighlight, item.misc))
          end
        end
        if self:ItemExists(itemId) then
          addGuildInfoToTooltip(tooltip, itemId, instanceID)
        end
      end
    end
  end
end

local function helperOnEnter(widget, ...)
  local itemid = widget:GetUserData("itemid")
  local itemlink = widget:GetUserData("itemlink")
  local callbacks = widget:GetUserData("callbacks")
  local difficulty = widget:GetUserData("difficulty")
  if not itemid then return end
  BestInSlot:GetItemTooltip(itemid,difficulty, BestInSlot.frame, itemlink)
  if IsControlKeyDown() then
    SetCursor("INSPECT_CURSOR")
  else
    ResetCursor()
  end
  
  if callbacks.OnEnter then
    for i=1,#callbacks.OnEnter do
      callbacks.OnEnter[i](widget, ...)
    end
  end
end

local function helperOnLeave(widget, ...)
  ResetCursor()
  local callbacks = widget:GetUserData("callbacks")
  BestInSlot:HideItemTooltip()
  if callbacks.OnLeave then
    for i=1,#callbacks.OnLeave do
      callbacks.OnLeave[i](widget, ...) 
    end
  end
end

local function helperOnClick(widget, ...)
  local itemlink = widget:GetUserData("itemlink")
  local callbacks = widget:GetUserData("callbacks")
  if not itemlink then return end
  if IsShiftKeyDown() then
    if not ChatEdit_InsertLink(itemlink) then
      ChatFrame_OpenChat(itemlink)
    end
  elseif IsControlKeyDown() then
    DressUpItemLink(itemlink)
  end
  if callbacks.OnClick then
    for i=1,#callbacks.OnClick do
      callbacks.OnClick[i](widget, ...) 
    end
  end
end

local function itemLinkCallback(self, name, func)
  if type(func) ~= "function" then error("2nd parameter should be function") end
  local callbacks = self:GetUserData("callbacks")
  if name == "OnEnter" or name == "OnLeave" or name == "OnClick" then
    if not callbacks[name] then
      callbacks[name] = {}
    end
    tinsert(callbacks[name], func)
  else
    error("Invalid callback method")
  end
end

function BestInSlot:GetItemLinkLabel(itemid, difficulty, withIcon)
  if not withIcon and withIcon ~= false then
    withIcon = true
  end
  if not itemid then
    error("GetItemLinkLabel cannot be called without itemid argument")
    return
  end
  local label = AceGUI:Create("InteractiveLabel")
  label:SetUserData("itemid", itemid)
  label:SetUserData("difficulty", difficulty)
  label:SetCallback("OnEnter", helperOnEnter)
  label:SetCallback("OnLeave", helperOnLeave)
  label:SetCallback("OnClick", helperOnClick)
  if itemid ~= "PLACEHOLDER" then
    local item = self:GetItem(itemid, difficulty)
    if not item then
      label:SetText("Undefined itemid")
    else
      label:SetUserData("itemlink", item.link)
      label:SetText(item.link)
    end
    if withIcon then
      label:SetImage(GetItemIcon(itemid))
    end
  else
    label:SetText("")
  end
  label:SetUserData("callbacks", {})
  return label
end

local UISpecialFramesId
local function frameClosed(widget)
  if UISpecialFrames[UISpecialFramesId] == frameName then
    tremove(UISpecialFrames, UISpecialFramesId)
  end  
  BestInSlot:HideFrame()
end

local function GetFrame()
  if frame then return end
  frame = AceGUI:Create("Frame")
  frame.frame:SetFrameStrata("HIGH")
  BestInSlot.frame = frame
  
  --make closable with escape
  _G[frameName] = frame.frame
  tinsert(UISpecialFrames, frameName)
  UISpecialFramesId = #UISpecialFrames
  frame:SetTitle("Best In Slot Redux "..GetAddOnMetadata("BestInSlotRedux", "Version"))
  frame:SetStatusText(("By: %s, %s, %s."):format(BestInSlot.Author1, BestInSlot.Author2, BestInSlot.Author3))
  local FrameBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
  }
  frame.frame:SetBackdrop(FrameBackdrop)
  frame:SetCallback("OnClose", frameClosed)
  frame:EnableResize(nil)
  local dimensionsSet = false
  local initItem
  if selectedMenuId then --GUI has been opened before
    local item = menuItems[selectedMenuId]
    initItem = item
    if item.Height then
      frame:SetHeight(getHeightForModule(item))
      frame:SetWidth(getWidthForModule(item))
      dimensionsSet = true
    end
  end
  if not dimensionsSet or BestInSlot.db.char.options.windowFixed then
    if BestInSlot.db.char.options.windowFixed then
      frame:SetHeight(getBiggestHeight())
      frame:SetWidth(getBiggestWidth())
    else
      frame:SetHeight(MINIMUMHEIGHT)
      frame:SetWidth(MINIMUMWIDTH)
    end
  end
  frame:PauseLayout()
  frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -250)
  
  if not BestInSlot.hasModules then
    local label = AceGUI:Create("Label")
    label:SetText(L["This addon requires atleast 1 expansion module! Please enable one!"])
    label:SetFullWidth(true)
    label:SetPoint("TOPLEFT", frame.frame, "TOPLEFT")
    frame:AddChild(label)
    return
  end
  
  menuContainer = AceGUI:Create("SimpleGroup")
  menuContainer:SetPoint("TOPLEFT", frame.frame, "TOPLEFT", 10, -20)
  menuContainer:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOMLEFT", 160, 50)
  menuContainer:PauseLayout()
  local previousLabel
  menuLabels = {}
  for i=1,#menuItems do
    local item = menuItems[i]
    if item.IsShown() then
      local interactiveLabel = AceGUI:Create("InteractiveLabel")
      interactiveLabel:SetText(item.Description)
      interactiveLabel:SetWidth(140)
      interactiveLabel:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
      interactiveLabel:SetUserData("name", item.Description)
      interactiveLabel:SetUserData("id", i)
      
      if selectedMenuId and selectedMenuId == i then
        interactiveLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
        interactiveLabel:SetColor(1,1,1)
      else
        interactiveLabel:SetColor(0.8941, 0.73725, 0.01961)
        interactiveLabel:SetHighlight("Interface\\QuestFrame\\UI-QuestTitleHighlight")
      end
      interactiveLabel:SetCallback("OnClick", SetContent)
      if not previousLabel then
        interactiveLabel:SetPoint("TOPLEFT", menuContainer.frame, "TOPLEFT", 10, -10)
        interactiveLabel:SetPoint("TOPRIGHT", menuContainer.frame, "TOPRIGHT", -10, -10)
      else
        interactiveLabel:SetPoint("TOPLEFT", previousLabel.frame, "BOTTOMLEFT", 0, -10)
        interactiveLabel:SetPoint("TOPRIGHT", previousLabel.frame, "BOTTOMRIGHT", 0, -10)    
      end
      previousLabel = interactiveLabel
      menuLabels[i] = interactiveLabel
      menuContainer:AddChild(interactiveLabel)
    end
  end
  
  frame:AddChild(menuContainer)
  frame:SetUserData("menu", menuContainer)
  
  container = AceGUI:Create("SimpleGroup")
  container:SetPoint("TOPRIGHT", frame.frame, "TOPRIGHT", -20, -20)
  container:SetPoint("BOTTOMLEFT", menuContainer.frame, "BOTTOMRIGHT", 5, 0)
  container:SetLayout("Flow")
  frame:AddChild(container)
  frame:SetUserData("content", container)
  
  if initItem then
    initItem:Draw(container)
    BestInSlot:CheckTutorials()
  end
  
  local windowpos = BestInSlot.db.char.windowpos
  if windowpos.point then
    frame:ClearAllPoints()
    frame:SetPoint(windowpos.point, windowpos.relativeTo, windowpos.relativePoint, windowpos.xOffset, windowpos.yOffset)
  end
end

function BestInSlot:HideFrame()
  if frame then
    local point, relativeTo, relativePoint, xOffset, yOffset = frame.frame:GetPoint(1)
    self.db.char.windowpos = {
      point = point,
      relativeTo = type(relativeTo) == "table" and relativeTo:GetName() or relativeTo,
      relativePoint = relativePoint,
      xOffset = xOffset,
      yOffset = yOffset
    }
    if selectedMenuId then
      local item = menuItems[selectedMenuId]
      if item then
        item:Close()
      end
    end
    frame.frame:SetBackdrop({ --set backdrop back to the original backdrop for other users
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:Release()
    frame = nil
    container = nil
    menuContainer = nil
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    if BestInSlotTutorialFrame:IsVisible() then
      BestInSlotTutorialFrame:Hide()
    end
    BestInSlot.frame = nil
    menuLabels = nil
  end
end

function BestInSlot:GetSelectedMenuItem()
  return menuItems[selectedMenuId].Description
end

local function defaultDraw(menu, container)
  local label = AceGUI:Create("Label")
  label:SetText("This menu has not been implemented yet")
  container:AddChild(label)
end

local function defaultClose() end
local function defaultIsShown() return true end
-- {
--  descr = "Description",
--  draw = drawFunction(),
--  [width = 100,]
--  [height = 100,] 
--  [close = closeFunction(),]
--  [isShown = isShownFunction(),]
-- }
local menuPrototype = setmetatable({
  Draw = defaultDraw,
  Width = 500,
  Height = 600,
  Close = defaultClose,
  IsShown = defaultIsShown,
},
{__index = BestInSlot})
function BestInSlot:GetMenuPrototype(menuName)
  if not menuName or type(menuName) ~= "string" then error("GetMenuPrototype must always have a name in the form of a string") end
  local menuIndex = #menuItems + 1
  local prototype = setmetatable({Description = menuName, menuindex = menuIndex}, {__index = menuPrototype})
  menuItems[menuIndex] = prototype
  return prototype
end

-------------------------------------------------
-- Functions for add-on wide selection values
-- 
local selected

function BestInSlot:InitSelectedSettings()
  if selected == nil then
    selected = self.db.char.selected
    local verify = {self.EXPANSION, self.RAIDTIER, self.INSTANCE, self.DIFFICULTY, self.SPECIALIZATION}
    local verified = true
    for _, type in pairs(verify) do
      if not selected[type] then
        verified = false
        break
      end
    end
    if not verified or not tContains(self:GetInstances(), selected[self.INSTANCE]) then
      selected = {} --when not verified, reset selected
      self:SetSelected(self.EXPANSION, self:GetLatest(self.EXPANSION))
      self:SetSelected(self.SPECIALIZATION)
    else
      self:ValidateSelected(self.INSTANCE)
    end
  end
end

function BestInSlot:GetSelected(bisType)
  if not selected then 
    self:InitSelectedSettings()
  end
  if not selected[self.SPECIALIZATION] or selected[self.SPECIALIZATION] == -1 then
    self:SetSelected(self.SPECIALIZATION)
  end
  if bisType then
    if selected[bisType] then
      if bisType == self.SPECIALIZATION then
        return selected[bisType], type(selected[bisType]) == "string" and self:GetSpecForCustomList(selected[bisType]) or selected[bisType]
      end
      return selected[bisType] 
    else
      error("You supplied an invalid type!")
    end
  else
    return {expansion = selected[self.EXPANSION], raidtier = selected[self.RAIDTIER], instance = selected[self.INSTANCE], difficulty = selected[self.DIFFICULTY], specialization = selected[self.SPECIALIZATION]}
  end
end

function BestInSlot:ValidateSelected(type)
  if type == self.RAIDTIER then
    local expansion = self:GetExpansions(type, selected[type])
    if selected[self.EXPANSION] ~= expansion then
      self:SetSelected(self.EXPANSION, expansion)
    end
    local difficulties = self:GetDifficulties(type, selected[type])
    if not difficulties[selected[self.DIFFICULTY]] then
      self:SetSelected(self.DIFFICULTY, difficulties[#difficulties])
    end
  elseif type == self.INSTANCE then
    local raidTier = self:GetRaidTiers(type, selected[type])
    if selected[self.RAIDTIER] ~= raidTier then
      self:SetSelected(self.RAIDTIER, raidTier)
    end
  elseif type == self.DIFFICULTY then
    local difficulties = self:GetDifficulties(self.RAIDTIER, selected[self.RAIDTIER])
    if selected[type] > #difficulties then
      self:SetSelected(type, #difficulties)
    end
  end
  self.db.char.selected = selected
end

local eventBuffer = {}
local eventTimer
local function sendEvents()
  for k,v in pairs(eventBuffer) do
    BestInSlot:SendEvent("SelectedChange", k, v)
  end
  wipe(eventBuffer)
  eventTimer = nil
end
function BestInSlot:SetSelected(type, value)
  if not selected then
    self:InitSelectedSettings()
  end
  if value and selected[type] == value then return end
  if value then
    selected[type] = value
  end
  if type == self.EXPANSION then
    self:SetSelected(self.RAIDTIER, self:GetLatest(self.RAIDTIER, self.EXPANSION, value))
  elseif type == self.RAIDTIER then
    self:SetSelected(self.INSTANCE, self:GetLatest(self.INSTANCE, self.RAIDTIER, value))
  elseif type == self.INSTANCE then
    if (not selected[self.DIFFICULTY]) or #(self:GetDifficulties(type, selected[type])) < selected[self.DIFFICULTY] then 
      self:SetSelected(self.DIFFICULTY, self:GetLatest(self.DIFFICULTY, self.INSTANCE, value))
    end
  elseif type == self.SPECIALIZATION then
    if not value then
      selected[self.SPECIALIZATION] = GetSpecializationInfo(self:GetSpecialization())
    end
  end
  eventBuffer[type] = value
  if not eventTimer then
    eventTimer = C_Timer.After(0.001, sendEvents)
  end
  self:ValidateSelected(type)
  self.db.char.selected = selected
end

local function getRaidTierDropdown(dropdown)
  local order = BestInSlot:GetRaidTiers()
  local list = {}
  for i=1,#order do
    list[order[i]] = BestInSlot:GetDescription(BestInSlot.RAIDTIER, order[i])
  end
  dropdown:SetList(list)
  local value = BestInSlot:GetSelected(BestInSlot.RAIDTIER)
  dropdown:SetValue(value)
  dropdown:SetLabel(L["Raid Tier"])
  dropdown:SetUserData(BestInSlot.RAIDTIER, value)
  return dropdown
end

local function getDifficultyDropdown(dropdown)
  local raidTierValue = BestInSlot:GetSelected(BestInSlot.RAIDTIER)
  dropdown:SetList(BestInSlot:GetDifficulties(BestInSlot.RAIDTIER, raidTierValue))
  local value = BestInSlot:GetSelected(BestInSlot.DIFFICULTY)
  dropdown:SetValue(value)  
  dropdown:SetLabel(L["Difficulty"])
  dropdown:SetUserData(BestInSlot.DIFFICULTY, value)
  dropdown:SetUserData(BestInSlot.RAIDTIER, raidTierValue)
  return dropdown
end

local function getSpecializationDropdown(dropdown)
  local customLists = BestInSlot.db.char.customlists
  local hasCustomLists = #customLists > 0
  dropdown:SetList({})
  if hasCustomLists then
    dropdown:AddItem("_header1", L["Specialization"])
    dropdown:SetItemDisabled("_header1", true)
  end
  for i=1,GetNumSpecializations() do
    local id, name = GetSpecializationInfo(i)
    dropdown:AddItem(id, name)
  end
  dropdown:SetLabel(L["Specialization"])
  if #customLists > 0 then
    dropdown:AddItem("_spacer", "")
    dropdown:SetItemDisabled("_spacer", true)
    dropdown:AddItem("_header", L["Custom Lists"])
    dropdown:SetItemDisabled("_header", true)
    for i=1,#customLists do
      dropdown:AddItem(customLists[i].name, customLists[i].name)
    end
  end
  local value = BestInSlot:GetSelected(BestInSlot.SPECIALIZATION)
  dropdown:SetValue(value)
  dropdown:SetUserData(BestInSlot.SPECIALIZATION, value)
end

local function getDungeonDropdown(dropdown)
  dropdown:SetList({})
  local options = {}
  local instances = BestInSlot:GetInstances()
  tsort(instances, function(a,b) return BestInSlot:GetRaidTiers(BestInSlot.INSTANCE, a) < BestInSlot:GetRaidTiers(BestInSlot.INSTANCE, b) end)
  local selectedDungeon = BestInSlot:GetSelected(BestInSlot.INSTANCE)
  local lastExpansion
  for i=1,#instances do
    local expansion = BestInSlot:GetExpansions(BestInSlot.INSTANCE, instances[i])
    if expansion ~= lastExpansion then
      local name = BestInSlot:GetDescription(BestInSlot.EXPANSION, expansion)
      dropdown:AddItem(name, "    "..name)
      dropdown:SetItemDisabled(name, true)
      lastExpansion = expansion
      
    end
    dropdown:AddItem(instances[i], BestInSlot:GetDescription(BestInSlot.INSTANCE, instances[i]))
  end
  dropdown:SetLabel(L["Raid Instance"])
  dropdown:SetValue(selectedDungeon)
  dropdown:SetUserData(BestInSlot.INSTANCE, selectedDungeon)
end

local function dropDownCallback(dropdown, event, value, ...)
  local udt = dropdown:GetUserDataTable()  
  BestInSlot:SetSelected(udt.type, value)
  if udt.customcallback then udt.customcallback(dropdown, event, value, ...) end
end

local function dropdownReleased(dropdown)
  BestInSlot:UnregisterEvent("SelectedChange", dropdown:GetUserData("eventid"))
end

local dropdownConstructors = {
  [BestInSlot.RAIDTIER] = getRaidTierDropdown,
  [BestInSlot.INSTANCE] = getDungeonDropdown,
  [BestInSlot.DIFFICULTY] = getDifficultyDropdown,
  [BestInSlot.SPECIALIZATION] = getSpecializationDropdown 
}

local function verifyRequireChange(widget, typeChanged, value)
  local udt = widget:GetUserDataTable()
  return udt[typeChanged] and udt[typeChanged] ~= value or false
end

local function defaultOnChange(event, typeChanged, valueChanged, dropdown, ...)
  if verifyRequireChange(dropdown, typeChanged, valueChanged) then
    dropdown:SetValue(valueChanged)
    dropdown:SetUserData(typeChanged, valueChanged)
  end
end

local function difficultyOnChange(event, typeChanged, valueChanged, dropdown, ...)
  if typeChanged == BestInSlot.RAIDTIER or typeChanged == BestInSlot.INSTANCE then
    dropdownConstructors[BestInSlot.DIFFICULTY](dropdown)
  elseif typeChanged == BestInSlot.DIFFICULTY then
    dropdown:SetValue(valueChanged)
    dropdown:SetUserData(typeChanged, valueChanged)
  end
end

local dropdownOnChange = {
  [BestInSlot.RAIDTIER] = defaultOnChange,
  [BestInSlot.INSTANCE] = defaultOnChange,
  [BestInSlot.DIFFICULTY] = difficultyOnChange,
  [BestInSlot.SPECIALIZATION] = defaultOnChange
}

function BestInSlot:GetDropdown(type, dropdown, callback)
  local dropdown = dropdown or AceGUI:Create("Dropdown")
  if not dropdownConstructors[type] then error("Can't make a dropdown of that type!") end
  dropdownConstructors[type](dropdown)
  dropdown:SetUserData("type", type)
  dropdown:SetUserData("customcallback", callback)
  dropdown:SetUserData("eventid",self:RegisterEvent("SelectedChange", dropdownOnChange[type], dropdown))
  dropdown:SetCallback("OnValueChanged", dropDownCallback)
  dropdown:SetCallback("OnRelease", dropdownReleased)
  return dropdown
end

local function uneditableOnTextChanged(widget)
  widget:SetText(widget:GetUserData("contents"))
end

function BestInSlot:CreateUneditableTextbox(contents, description, type)
  local editBox = AceGUI:Create(type or "EditBox")
  if description then
    editBox:SetLabel(description)
  end
  editBox:SetText(contents)
  editBox:SetUserData("contents", contents)
  editBox:SetFullWidth(true)
  editBox:SetCallback("OnTextChanged", uneditableOnTextChanged)
  return editBox
end

function BestInSlot:QuickCreate(widgtype, options, addTo, point, ...)
  local result = AceGUI:Create(widgtype)
  
  if options then
    for k,v in pairs(options) do
      if type(v) == "table" then
        result[k](result, unpack(v))
      else
        result[k](result, v)
      end
    end
  end
  
  if addTo then
    if point then
      result:SetPoint(point, addTo.frame, ...)
    end
    addTo:AddChild(result)
  end
  return result
end


function BestInSlot:ShowFrame()
  if not frame then
    GetFrame()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
  end
end

function BestInSlot:ToggleFrame()
  if not frame then 
    self:ShowFrame()
  else 
    self:HideFrame()
  end
end
BestInSlot:RegisterSlashCmd("show", (L["%s or %s"]):format("/bis", "/bestinslot"), function() BestInSlot:ShowFrame() end, 1)
BestInSlot:RegisterSlashCmd("reset", ("/bis %s - %s"):format("reset", L["Resets the window to it's original position"]), function() if frame then BestInSlot:HideFrame() end wipe(BestInSlot.db.char.windowpos) end)
