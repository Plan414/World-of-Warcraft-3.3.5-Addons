--lua
local unpack, select, type, tinsert, ceil, abs, min, max
=     unpack, select, type, table.insert, math.ceil, math.abs, math.min, math.max
--WoW API
local IsControlKeyDown, IsShiftKeyDown, GetItemUniqueness, GetItemIcon, DressUpItemLink, GetInventorySlotInfo, GetNumSpecializations, GetSpecializationInfo
=     IsControlKeyDown, IsShiftKeyDown, GetItemUniqueness, GetItemIcon, DressUpItemLink, GetInventorySlotInfo, GetNumSpecializations, GetSpecializationInfo
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local frameName = (L["%s manager"]):format("BiS")
local Manager = BestInSlot:GetMenuPrototype(frameName)
local BabbleInventory = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
local dropdownRaidtier, dropdownDifficulty, dropdownSpecialization, dropdownImport, slotContainer --widgets that are referenced later
local itemGroups = {}
local legionRelicGroups = {}
local itemSelectionMode = false
local lowerRaidTiers = false
local showAllItems = false

Manager.Width = 800
Manager.Height = 600

function Manager:SetSlotContainerPosition(callback, funcArgs)
  local selectContainer = slotContainer:GetUserData("selectContainer")
  selectContainer.frame:ClearAllPoints()
  selectContainer:SetPoint("TOPLEFT", slotContainer.frame, "TOPLEFT", -10, -45)
  selectContainer:SetPoint("BOTTOMRIGHT", dropdownImport.frame, "BOTTOMRIGHT", 0, 20)
  if callback then
    local type = type(callback) 
    if type == "function" then
      callback(unpack(funcArgs))
    elseif type == "string" and self[callback] then
      self[callback](self, unpack(funcArgs))
    end
  end
end

function Manager:DoMoveAnimation(itemGroup, location, callback, ...)
  slotContainer:PauseLayout()
  itemGroup:ClearAllPoints()
  local button = itemGroup:GetUserData("button")
  local targetX = 0
  local targetY = 0
  if location == "RIGHT" then
    targetX = 150
  elseif location == "LEFT" then
    targetX = -150
  end
  if not self.options.instantAnimation then
    local index = itemGroup:GetUserData("index")
    local ofsX = 150
    local ofsY = -((ceil(index/2) - 1) * 45)
    if index % 2 == 1 then --right
      ofsX = -ofsX
    end
    itemGroup:SetPoint("TOP", slotContainer.frame, "TOP", ofsX, ofsY)
    local timer
    local funcArgs = {...}
    button:SetDisabled(true)
    timer = self:ScheduleRepeatingTimer(function()
      local speedX = 12
      local speedY
      if ofsX == targetX then 
        speedY = speedX 
      else 
        speedY = abs(speedX * (ofsY / ofsX)) 
      end
      if ofsX < targetX then
        ofsX = min(ofsX + speedX, targetX)
      else
        ofsX = max(ofsX - speedX, targetX)
      end
      ofsY = min(ofsY + speedY, targetY)
      itemGroup:SetPoint("TOP", slotContainer.frame, "TOP", ofsX, ofsY)
      if ofsX == targetX and ofsY == targetY then
        self:CancelTimer(timer)
        button:SetDisabled(false)
        Manager:SetSlotContainerPosition(callback, funcArgs)
      end
    end,
    0.0166)
  else
    itemGroup:SetPoint("TOP", slotContainer.frame, "TOP", targetX, targetY)
    self:SetSlotContainerPosition(callback, {...})
  end
end

local function selectItemLabelOnEnter(widget)
  if itemSelectionMode and GameTooltip:IsVisible() then
    local itemGroup = itemGroups[itemSelectionMode[1]]
    local itemid = itemGroup:GetUserData("icon"):GetUserData("itemid")
    if itemid then
      Manager:GetItemComparisonTooltip(GameTooltip, itemid, Manager:GetSelected(Manager.DIFFICULTY))
    end
  end
end

local function selectItemLabelOnClick(widget, _, key)
  if not IsControlKeyDown() and not IsShiftKeyDown() then
    local itemid = widget:GetUserData("itemid")
    local itemGroup = itemGroups[itemSelectionMode[1]]
    if itemSelectionMode[2] and key == "RightButton" then
      itemGroup = itemGroups[itemSelectionMode[2]]
    end
    local difficulty = widget:GetUserData("difficulty") or Manager:GetSelected(Manager.DIFFICULTY)
    local list, spec = Manager:GetSelected(Manager.SPECIALIZATION)
    local item = Manager:GetItem(itemid, difficulty)
    local raidTier = Manager:GetSelected(Manager.RAIDTIER)
    local slotid = itemGroup:GetUserData("slotid")
    Manager:SetItemBestInSlot(raidTier, difficulty, list, slotid, itemid)
    local icon = itemGroup:GetUserData("icon")
    local oldItemId = icon:GetUserData("itemid")
    if item then
      itemGroup:GetUserData("label"):SetText(item.link)
      icon:SetImage(GetItemIcon(itemid))
      icon:SetUserData("itemid", itemid)
      icon:SetUserData("itemlink", item.link)
    else
      icon:SetUserData("itemid", nil)
      icon:SetUserData("itemlink", nil)
      icon:SetImage(unpack(itemGroup:GetUserData("defaultTexture")))
      itemGroup:GetUserData("label"):SetText("")
    end
    if itemSelectionMode[1] == 15 then
      if select(2, Manager:GetSelected(Manager.SPECIALIZATION)) ~= 72 then --Don't disable for fury warriors
        local offhandGroup = itemGroups[16]
        local offhandIcon = offhandGroup:GetUserData("icon")
        local offhandLabel = offhandGroup:GetUserData("label")
        local offhandButton = offhandGroup:GetUserData("button")
        local subclass = select(7, GetItemInfo(itemid))
        if item and (item.equipSlot == "INVTYPE_2HWEAPON" or item.equipSlot == "INVTYPE_RANGED" or (item.equipSlot == "INVTYPE_RANGEDRIGHT" and subclass ~= BabbleInventory.Wands)) then
          offhandIcon:SetUserData("disabled", true)
          offhandIcon:SetImage(unpack(offhandGroup:GetUserData("defaultTexture")))
          offhandLabel:SetText("")
          offhandButton:SetDisabled(true)
          Manager:SetItemBestInSlot(raidTier, difficulty, spec, 17, nil)
        else
          offhandIcon:SetUserData("disabled", false)
          offhandButton:SetDisabled(false)
        end
      end
    end
    local uniqueness, oldUniqueness
    if item then
      uniqueness = GetItemUniqueness(item.itemid)
    end
    if oldItemId then
      oldUniqueness = GetItemUniqueness(oldItemId)
    end
    if uniqueness or oldUniqueness then
      Manager:FillSelectContainer(itemGroups[itemSelectionMode[1]], raidTier, difficulty, slotid)
    end
  end
end

function Manager:FillSelectContainer(itemGroup, raidTier, difficulty, slotid)
  local selectContainer = slotContainer:GetUserData("selectContainer")
  local itemhighlight = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
  selectContainer:SetLayout("Flow")
  selectContainer:ReleaseChildren()
  
  local header = AceGUI:Create("Heading")
  header:SetFullWidth(true)
  local slotData = self.invSlots[slotid]
  if type(slotData) == "table" then
    slotData = slotData[1]
  end
  
  --legion artifact relic
  local relic = itemGroup:GetUserData("relic")
  if relic then
    header:SetText((L["%1$s from raid tier: %2$s"]):format(_G.RELIC_TOOLTIP_TYPE:format(_G["RELIC_SLOT_TYPE_" ..relic]), self:GetDescription(self.RAIDTIER, raidTier)))
  else
    header:SetText((L["%1$s from raid tier: %2$s"]):format(_G[slotData], self:GetDescription(self.RAIDTIER, raidTier)))
  end
  selectContainer:AddChild(header)
  
  if itemSelectionMode[2] then
    local helpText = AceGUI:Create("Label")
    helpText:SetText(self.colorNormal..L["Use left-click to (de)select the left one, and right-click to select the right one"].."|r")
    helpText:SetFullWidth(true)
    selectContainer:AddChild(helpText)
  end
  
  local scroll = AceGUI:Create("ScrollFrame")
  local simpleGroup = AceGUI:Create("SimpleGroup")
  simpleGroup:SetFullWidth(true)
  simpleGroup:AddChild(scroll)
  simpleGroup:SetHeight(375)
  simpleGroup:SetLayout("Fill")
  selectContainer:AddChild(simpleGroup)
  local lootOrder
  if relic then
    lootOrder = self.Artifacts:GetRelicsForRaidTier(relic, raidTier, difficulty, lowerRaidTiers)
  else
    if showAllItems then
      lootOrder = self:GetLootOrder(self:GetLootTableBySlot(raidTier, slotid, difficulty, lowerRaidTiers))
    else
      local list, spec = self:GetSelected(self.SPECIALIZATION)
      lootOrder = self:GetLootOrder(self:GetPersonalizedLootTableBySlot(raidTier, slotid, difficulty, spec, lowerRaidTiers))
    end
  end
  local deselectIcon = AceGUI:Create("InteractiveLabel")
  deselectIcon:SetImage("Interface\\Buttons\\UI-GroupLoot-Pass-Up.blp")
  deselectIcon:SetText(L["Deselect item"])
  deselectIcon:SetCallback("OnClick", selectItemLabelOnClick)
  deselectIcon:SetFullWidth(true)
  deselectIcon:SetImageSize(30,30)
  deselectIcon:SetHighlight(itemhighlight)
  deselectIcon:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
  scroll:AddChild(deselectIcon)
  local firstItem
  for i = 1, #lootOrder do
    local id = lootOrder[i]
    local texture = GetItemIcon(id)
    local label = self:GetItemLinkLabel(id, difficulty)
    if lowerRaidTiers then
      local item = BestInSlot:GetItem(id)
      local itemRaidTier = self:GetRaidTiers(self.INSTANCE, item.dungeon)
      if itemRaidTier ~= raidTier then
        label:SetText(label:GetUserData("itemlink")..(" - (%s)"):format(self:GetDescription(self.RAIDTIER, itemRaidTier)))
      end
    end
    label:SetFullWidth(true)
    label:SetHighlight(itemhighlight)
    label:SetImageSize(30,30)
    local callbacks = label:GetUserData("callbacks")
    callbacks.OnClick = {selectItemLabelOnClick}
    callbacks.OnEnter = {selectItemLabelOnEnter}
    label:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
    firstItem = firstItem or label
    scroll:AddChild(label)
  end
  if not relic then
    local showAllLabel = AceGUI:Create("InteractiveLabel")
    showAllLabel:SetHighlight(itemhighlight)
    showAllLabel:SetFullWidth(true)
    showAllLabel:SetImageSize(30,30)
    showAllLabel:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
    showAllLabel:SetImage(showAllItems and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or "Interface\\PaperDollInfoFrame\\Character-Plus")
    showAllLabel:SetText(showAllItems and L["Only show items for specialization"] or L["Show all items"])
    showAllLabel:SetCallback("OnClick", function() showAllItems = not showAllItems Manager:FillSelectContainer(itemGroup, raidTier, difficulty, slotid) end)
    scroll:AddChild(showAllLabel)
    local customItemLabel = AceGUI:Create("InteractiveLabel")
    customItemLabel:SetHighlight(itemhighlight)
    customItemLabel:SetFullWidth(true)
    customItemLabel:SetImageSize(30,30)
    customItemLabel:SetImage("Interface\\PaperDollInfoFrame\\Character-Plus")
    customItemLabel:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
    customItemLabel:SetText(L["Add a custom item"])
    customItemLabel:SetCallback("OnClick", function() Manager:SetMenu(3, Manager:GetSelected(Manager.INSTANCE)) end)
    scroll:AddChild(customItemLabel)
  end
  if itemSelectionMode[2] then
    self.frame:GetUserData("content"):SetUserData("selectedItem", deselectIcon)
    self:ShowTutorial(frameName, 5)
  end
  if #self:GetRaidTiers(self.RAIDTIER, raidTier) > 0 then --if we have lower raid ters then our own
    local lowerRaidTierLabel = AceGUI:Create("InteractiveLabel")
    lowerRaidTierLabel:SetHighlight(itemhighlight)
    lowerRaidTierLabel:SetFullWidth(true)
    lowerRaidTierLabel:SetImageSize(30,30)
    lowerRaidTierLabel:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
    lowerRaidTierLabel:SetImage(lowerRaidTiers and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or "Interface\\PaperDollInfoFrame\\Character-Plus")
    lowerRaidTierLabel:SetText(lowerRaidTiers and L["Only show this raid tier"] or L["Add lower raid tiers"])
    lowerRaidTierLabel:SetCallback("OnClick", function() lowerRaidTiers = not lowerRaidTiers Manager:FillSelectContainer(itemGroup, raidTier, difficulty, slotid) end)
    scroll:AddChild(lowerRaidTierLabel)    
  end
end

function Manager:HideItemList(callback, ...)
  local raidtier = self:GetSelected(self.RAIDTIER)
  for i=1,#itemSelectionMode do
    local itemGroup = itemGroups[itemSelectionMode[i]]
    local button = itemGroup:GetUserData("button")
    button:SetText(L["Select an item"])
    local selectContainer = slotContainer:GetUserData("selectContainer")
    selectContainer:ClearAllPoints()
    selectContainer:ReleaseChildren()
    if not self.options.instantAnimation then
      local index = itemGroup:GetUserData("index")
      local targetX = 150
      local targetY = -((ceil(index/2) - 1) * 45)
      local currentX = 0
      local currentY = 0
      if itemSelectionMode[2] then
        if i == 1 then
          currentX = -150
        else
          currentX = 150
        end
      end
      if index % 2 == 1 then --right
        targetX = -targetX
      end
      local timer
      button:SetDisabled(true)
      local funcArgs = {...}
      timer = self:ScheduleRepeatingTimer(function()
          local speedX = 8
          local speedY = abs(targetY / targetX * speedX)
          currentY = max(currentY - speedY, targetY)
          if targetX > 0 then
            currentX = min(currentX + speedX, targetX)
          else
            currentX = max(currentX - speedX, targetX)
          end
          itemGroup:SetPoint("TOP", slotContainer.frame, "TOP", currentX, currentY)
          if currentY == targetY and currentX == targetX then
            self:CancelTimer(timer)
            slotContainer:ResumeLayout()
            slotContainer:DoLayout()
            if BestInSlot.Artifacts then
              if raidtier >= 70000 and raidtier < 800000 then
                for i=1,#legionRelicGroups do
                  legionRelicGroups[i].frame:Show()
                end
              else
                for i=1,#legionRelicGroups do
                  legionRelicGroups[i].frame:Hide()
                end
              end
            end
            button:SetDisabled(false)
            itemSelectionMode = false
            if callback and type(callback) == "function" and i == 1 then
              callback(unpack(funcArgs))
            end
          end
      end,
      0.0166)
    end
  end
  itemSelectionMode = false
  if self.options.instantAnimation then
    slotContainer:ResumeLayout()
    slotContainer:DoLayout()
    if self.Artifacts then
      if raidtier >= 70000 and raidtier < 800000 then
        for i=1,#legionRelicGroups do
          legionRelicGroups[i].frame:Show()
        end
      else
        for i=1,#legionRelicGroups do
          legionRelicGroups[i].frame:Hide()
        end
      end
    end
    if callback and type(callback) == "function" then
      callback(...)
    end
  end
end

function Manager:ShowItemList(widget)
  if itemSelectionMode then
    self:HideItemList()
  else
    local data = widget:GetUserDataTable() --{raidTier = 50400, difficulty = 1, slotid = 1}
    data.difficulty = data.difficulty or self:GetSelected(Manager.DIFFICULTY)
    data.raidTier = data.raidTier or self:GetSelected(Manager.RAIDTIER)
    if not data.difficulty or not data.raidTier or widget:GetUserData("disabled") then return end
    local dualSelect = nil
    if data.slotid == 11 or data.slotid == 12 then --Ring
      dualSelect = {11,12}
      itemSelectionMode = {11,12}
    elseif data.slotid == 13 or data.slotid == 14 then --Trinket
      dualSelect = {13,14}
      itemSelectionMode = {13,14}
    end
    for i=1,#itemGroups do
      local button = itemGroups[i]:GetUserData("button")
      local buttonSlot = button:GetUserData("slotid")
      if buttonSlot == data.slotid or (dualSelect and (dualSelect[1] == buttonSlot or dualSelect[2] == buttonSlot)) then
        button:SetText(DONE)
        if dualSelect then
          if buttonSlot == dualSelect[1] then
            self:DoMoveAnimation(itemGroups[i], "LEFT", "FillSelectContainer", itemGroups[i], data.raidTier, data.difficulty, data.slotid)
          else
            self:DoMoveAnimation(itemGroups[i], "RIGHT")
          end
        else
          itemSelectionMode = {i}
          self:DoMoveAnimation(itemGroups[i], nil, "FillSelectContainer", itemGroups[i], data.raidTier, data.difficulty, data.slotid)
        end
      else
        itemGroups[i].frame:Hide()
      end
    end
  end
end

local function iconOnEnter(icon)
  local itemid = icon:GetUserData("itemid")
  local itemLink = icon:GetUserData("itemlink")
  if itemid then
    Manager:GetItemTooltip(itemid, Manager:GetSelected(Manager.DIFFICULTY), Manager.frame, itemLink)
  end
end

local function iconOnLeave() Manager:HideItemTooltip()  end

local function iconOnClick(widget, _, button)
  local itemid = widget:GetUserData("itemid")
  local shift, ctrl = IsShiftKeyDown(), IsControlKeyDown()
  local item = Manager:GetItem(itemid, Manager:GetSelected(Manager.DIFFICULTY))
  if shift then
    local link = (item and item.link) or widget:GetUserData("itemlink")
    if not ChatEdit_InsertLink(link) then
      ChatFrame_OpenChat(link)
    end
  elseif ctrl then
    local link = (item and item.link) or widget:GetUserData("itemlink")
    if link then
      DressUpItemLink(link)
    end
  elseif not shift and not ctrl then
    if button == "LeftButton" then
      Manager:ShowItemList(widget)
    elseif button == "RightButton" then
      local index = widget:GetUserData("group"):GetUserData("index")
      if widget:GetUserData("disabled") then return end
      if widget:GetUserData("itemid") then
        widget:SetUserData("itemid", nil)
        if type(itemSelectionMode) == "table" and tContains(itemSelectionMode, index) then
          return --use deselect item icon instead
        else
          local oldItemSelectMode = itemSelectionMode
          itemSelectionMode = {index}
          selectItemLabelOnClick(widget,nil,"LeftButton")
          itemSelectionMode = oldItemSelectMode
        end
      end
    end
  end
end

local function selectItemButtonOnClick(widget)
  Manager:ShowItemList(widget)
end

function Manager:SetLegionRelics(enabled, container, specialization, bis)
  if enabled then
    local relics = self.Artifacts:GetRelicsForSpecialization(specialization)
    local texture = self.Artifacts:GetTexture()
    for i=1,#legionRelicGroups do
      local group = legionRelicGroups[i]
      group.frame:Show()
      group:SetUserData("relic", relics[i])
      local icon = group:GetUserData("icon")
      local label = group:GetUserData("label")
      local normalCoords, highLightcoords = self.Artifacts:GetTextureCoordinatesForRelic(relics[i])
      local bisRelic = bis[29 + i]
      if not bisRelic or not bisRelic.item then
        icon:SetImage(texture, unpack(normalCoords))
      else
        local relic = self:GetItem(bisRelic.item)
        icon:SetImage(GetItemIcon(relic.itemid))
        icon:SetUserData("itemid", relic.itemid)
        label:SetText(relic.link)
      end
      group:SetUserData("defaultTexture", {texture, unpack(normalCoords)})
    end
  else
    for i=1,#legionRelicGroups do
      legionRelicGroups[i].frame:Hide()
      legionRelicGroups[i]:SetUserData("relic", nil)
    end
  end
end

function Manager:PopulateSlots(slotContainer)
  local container = slotContainer
  local isTwoHander = false
  local raidTier = self:GetSelected(self.RAIDTIER)
  local difficulty = self:GetSelected(self.DIFFICULTY)
  local list, specialization = self:GetSelected(self.SPECIALIZATION)
  local BiSList = self:GetOrderedBestInSlotItems(raidTier, difficulty, list)
  for i=1,#itemGroups do
    local itemGroup = itemGroups[i]
    local slotId = itemGroup:GetUserData("slotid")
    local icon = itemGroup:GetUserData("icon")
    local button = itemGroup:GetUserData("button")
    local label = itemGroup:GetUserData("label")
    local itemid = BiSList[slotId] and BiSList[slotId].item
    local isLegionWeapon = false
    -- Fix by dioxina
    if slotId == 2 and (self:GetSelected(self.RAIDTIER) >= 80000 and self:GetSelected(self.RAIDTIER) < 90000) then
      --Artifact neck      
      icon:SetUserData("disabled", true)
      button:SetDisabled(true)
      NeckItemId = 158075
      local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(NeckItemId)
      icon:SetImage(texture)
      icon:SetUserData("itemid", NeckItemId)
      icon:SetUserData("itemlink", link)
      label:SetText(link)
      isLegionWeapon = true
    elseif (slotId == 16 or slotId == 17) and (self:GetSelected(self.RAIDTIER) >= 70000 and self:GetSelected(self.RAIDTIER) < 80000) then
      --Artifact weapons
      icon:SetUserData("disabled", true)
      button:SetDisabled(true)
      local artifactInfo = select(slotId == 16 and 1 or 2, self.Artifacts:ForSpecialization(specialization))
      if artifactInfo then
        icon:SetImage(artifactInfo.texture)
        icon:SetUserData("itemid", artifactInfo.id)
        icon:SetUserData("itemlink", artifactInfo.link)
        label:SetText(artifactInfo.link)
        isLegionWeapon = true
      end
    --Code for disabling the off-hand slot in Two-handed cases
    elseif slotId == 17 and isTwoHander and select(2, self:GetSelected(self.SPECIALIZATION)) ~= 72 then --72 is a fury warrior
      local selected = self:GetSelected()
      self:SetItemBestInSlot( selected.raidtier, selected.difficulty, selected.specialization, slotId, nil)
      icon:SetUserData("itemid", nil)
      icon:SetUserData("disabled", true)
      
      button:SetDisabled(true)
      
      itemid = nil
    else
      icon:SetUserData("disabled", false)
      
      button:SetDisabled(false)
    end
    if type(itemid) == "number" and self:GetItem(itemid) then --Has a valid itemid value in the database
      local item = self:GetItem(itemid, difficulty)
      if slotId == 16 then
        local subclass = select(7, GetItemInfo(itemid))
        if item.equipSlot == "INVTYPE_2HWEAPON" or item.equipSlot == "INVTYPE_RANGED" or (item.equipSlot == "INVTYPE_RANGEDRIGHT" and subclass ~= BabbleInventory.Wands) then
          isTwoHander = true
        end
      end
      icon:SetImage(GetItemIcon(itemid))
      icon:SetUserData("itemid", itemid)
      
      label:SetText(item.link)
      
      button:SetDisabled(false)
    elseif not isLegionWeapon then
      icon:SetImage(unpack(itemGroup:GetUserData("defaultTexture")))
      icon:SetUserData("itemid", nil)
      label:SetText("")
    end
    icon:SetUserData("raidTier",  self:GetSelected(self.RAIDTIER))
    icon:SetUserData("difficulty", self:GetSelected(self.DIFFICULTY))
    button:SetUserData("raidTier",  self:GetSelected(self.RAIDTIER))
    button:SetUserData("difficulty", self:GetSelected(self.DIFFICULTY))
  end
  
  self:SetLegionRelics(raidTier >= 70000 and raidTier < 80000, container, specialization, BiSList)
end

function Manager:GetItemSelectionGroup(slotId, textureName, bisIndex)
  local itemGroup = AceGUI:Create("SimpleGroup")
  itemGroup:SetHeight(45)
  itemGroup:PauseLayout()
  
  local icon = AceGUI:Create("Icon")
  icon:SetImage(textureName)
  icon:SetImageSize(40,40)
  icon:SetWidth(40)
  icon:SetHeight(45)
  icon:SetPoint("TOPLEFT", itemGroup.frame, "TOPLEFT")
  icon.frame:RegisterForClicks("AnyDown")
  icon:SetCallback("OnEnter", iconOnEnter)
  icon:SetCallback("OnLeave", iconOnLeave)
  icon:SetCallback("OnClick", iconOnClick)
  icon:SetUserData("slotid", slotId)
  icon:SetUserData("group", itemGroup)
  itemGroup:AddChild(icon)
  
  local label = AceGUI:Create("Label")
  label:SetHeight(20)
  label:SetPoint("TOPLEFT", icon.frame, "TOPRIGHT", 0, -5)
  itemGroup:AddChild(label)
  
  local button = AceGUI:Create("Button")
  button:SetText(L["Select an item"])
  button:SetCallback("OnClick", selectItemButtonOnClick)
  button:SetHeight(25)
  button:SetPoint("BOTTOMLEFT", icon.frame, "BOTTOMRIGHT")
  button:SetUserData("slotid", slotId)
  itemGroup:AddChild(button)
  
  itemGroup:SetUserData("defaultTexture", {textureName})
  itemGroup:SetUserData("slotid", slotId)
  itemGroup:SetUserData("index", bisIndex)
  itemGroup:SetUserData("icon", icon)
  itemGroup:SetUserData("label",label)
  itemGroup:SetUserData("button", button)
  itemGroup:SetRelativeWidth(0.48)
  return itemGroup
end

function Manager:GetSlotContainer(raidTier, difficulty)
  local container = AceGUI:Create("SimpleGroup")
  itemGroups = {}
  container:SetFullWidth(true)
  container:SetHeight(0)
  container:SetLayout("Flow")
  for i=1,#self.slots do
    local slotId, textureName = GetInventorySlotInfo(self.slots[i])
    local itemGroup = self:GetItemSelectionGroup(slotId, textureName, i)
    container:AddChild(itemGroup)
    tinsert(itemGroups, itemGroup)
  end
  if self.Artifacts then
    local texture = self.Artifacts:GetTexture()
    for i=1,3 do
      local itemGroup = self:GetItemSelectionGroup(29 + i, texture, 16 + i) --30, 31, 32 slotIndex & 17, 18, 19 BiS
      legionRelicGroups[i] = itemGroup
      tinsert(itemGroups, itemGroup)
      container:AddChild(itemGroup)
    end
    --add a dummy group for the AceGUI flow layout to properly line out all the bottom
    container:AddChild(self:QuickCreate("SimpleGroup", {SetRelativeWidth = 0.49, SetHeight = 45, PauseLayout = true}))
  end
  local selectContainer = AceGUI:Create("SimpleGroup")
  selectContainer:SetFullWidth()
  selectContainer:SetHeight(1)
  container:AddChild(selectContainer)
  container:SetUserData("selectContainer", selectContainer)
  return container
end

local function dropdownRaidtierOnValueChanged(_,_,value)
  if itemSelectionMode then
    Manager:HideItemList(dropdownRaidtierOnValueChanged, _, _, value)
    return
  end
  Manager:SetImportDropdownData(dropdownImport)
  Manager:PopulateSlots(slotContainer)
end

local function dropdownDifficultyOnValueChanged(dropdown,_,value)
  if itemSelectionMode then
    Manager:HideItemList(dropdownDifficultyOnValueChanged, _,_,value)
    return
  end
  Manager:SetImportDropdownData(dropdownImport)
  Manager:PopulateSlots(slotContainer)
  Manager:ShowTutorial(frameName, 4)
end

local function dropdownSpecializationOnValueChanged(_,_,value)
  if itemSelectionMode then
    Manager:HideItemList(dropdownSpecializationOnValueChanged, _,_,value)
    return
  end
  Manager:PopulateSlots(slotContainer)
end

local function dropdownImport_OnValueChanged(_,_,value)
  local popup
  if tonumber(value) then
    popup = StaticPopup_Show("BESTINSLOT_CONFIRMIMPORT", Manager:GetDescription(Manager.DIFFICULTY, Manager:GetSelected(Manager.RAIDTIER), value))
  else
    popup = StaticPopup_Show("BESTINSLOT_CONFIRMCHARIMPORT", value)
  end
  popup:SetFrameStrata("TOOLTIP")
end

function Manager:SetImportDropdownData(dropdown)
  local selecDifficulty = self:GetSelected(self.DIFFICULTY)
  local selectedRaidTier = self:GetSelected(self.RAIDTIER)
  local selectedSpecialization = self:GetSelected(self.SPECIALIZATION)
  local list = self:GetDifficulties(self.RAIDTIER, selectedRaidTier)
  dropdownImport:SetList(list)
  dropdown:SetValue(nil)
  dropdown:SetItemDisabled(selecDifficulty, true)
  dropdown:SetItemDisabled(4, true)
  dropdown:SetDisabled(self:GetSelected(self.RAIDTIER) < 59999 or #dropdown.list < 2 or selecDifficulty == 4)
  dropdown:AddItem("spacer", "")
  dropdown:SetItemDisabled("spacer", true)
  local firstChar = true
  local thisChar = self.db:GetCurrentProfile()
  for id, profile in pairs(self.db:GetProfiles()) do
    local charDb = BestInSlotDB.char[profile]
    if charDb and profile ~= thisChar and charDb[selectedRaidTier] and charDb[selectedRaidTier][selecDifficulty] and charDb[selectedRaidTier][selecDifficulty][selectedSpecialization] then
      if firstChar then
        firstChar = false
      end
      dropdown:AddItem(profile, profile)
    end
  end
  if firstChar then
    dropdown:AddItem("no_alt", L["No other characters to import"])
    dropdown:SetItemDisabled("no_alt", true)
  end
end

function Manager:Draw(container)
  container:PauseLayout()
  
  dropdownRaidtier = self:GetDropdown(self.RAIDTIER, nil, dropdownRaidtierOnValueChanged)
  dropdownRaidtier:SetPoint("TOPLEFT", container.frame, "TOPLEFT", 10, -10)
  container:AddChild(dropdownRaidtier)
  
  dropdownDifficulty = self:GetDropdown(self.DIFFICULTY, nil, dropdownDifficultyOnValueChanged)
  dropdownDifficulty:SetPoint("TOPLEFT", dropdownRaidtier.frame, "TOPRIGHT")
  container:AddChild(dropdownDifficulty)
  
  container:SetUserData("difficulty", dropdownDifficulty)
  
  dropdownSpecialization = self:GetDropdown(self.SPECIALIZATION, nil, dropdownSpecializationOnValueChanged)
  dropdownSpecialization:SetPoint("TOPLEFT", dropdownDifficulty.frame, "TOPRIGHT")
  container:AddChild(dropdownSpecialization)
  
  slotContainer = self:GetSlotContainer(self:GetSelected(self.RAIDTIER),1)
  slotContainer:SetPoint("TOPLEFT", dropdownRaidtier.frame, "BOTTOMLEFT")
  slotContainer:SetWidth(600)
  slotContainer:SetPoint("BOTTOMLEFT", container.frame, "BOTTOMLEFT", 0, 40)
  container:AddChild(slotContainer)
  dropdownImport = AceGUI:Create("Dropdown")
  dropdownImport:SetList(dropdownDifficulty.list)
  dropdownImport:SetLabel(L["Import from other difficulty/character"])
  dropdownImport:SetPoint("BOTTOMRIGHT", container.frame, "BOTTOMRIGHT", -78, 0)
  dropdownImport:SetCallback("OnValueChanged", dropdownImport_OnValueChanged)
  
  self:SetImportDropdownData(dropdownImport)
  
  container:AddChild(dropdownImport)
  container:SetUserData("importButton", dropdownImport)
  
  self:PopulateSlots(slotContainer)
  slotContainer:DoLayout()
end

function Manager:Close()
  self:HideItemTooltip()
  dropdownRaidtier = nil
  dropdownDifficulty = nil
  dropdownSpecialization = nil
  slotContainer = nil
  itemSelectionMode = false
  itemGroups = {}
end

function Manager:DoImport()
  local importDifficulty = dropdownImport:GetValue()
  local raidTier = self:GetSelected(self.RAIDTIER)
  local difficulty = self:GetSelected(self.DIFFICULTY)
  local list, specialization = self:GetSelected(self.SPECIALIZATION)
  local importList, slotInfo = self:GetBestInSlotItems(raidTier, importDifficulty, list)
  for i, itemInfo in pairs(importList) do
    self:SetItemBestInSlot(raidTier, difficulty, list, slotInfo[i], itemInfo.item)
  end
  self:PopulateSlots(slotContainer)
end

function Manager:DoCopyChar()
    local selectedChar = dropdownImport:GetValue()
    local selectedInfo = Manager:GetSelected()
    local otherCharList = BestInSlotDB.char[selectedChar][selectedInfo.raidtier][selectedInfo.difficulty][selectedInfo.specialization]
    for i, iteminfo in pairs(otherCharList) do
      self:Print(i .. ": "..iteminfo)
      self:SetItemBestInSlot(selectedInfo.raidtier, selectedInfo.difficulty, selectedInfo.specialization, i, iteminfo)
    end
    --if charDb and profile ~= thisChar and charDb[selectedRaidTier] and charDb[selectedRaidTier][selecDifficulty] and charDb[selectedRaidTier][selecDifficulty][selectedSpecialization] then
    self:PopulateSlots(slotContainer)
end

Manager:RegisterTutorials(frameName,{
  [1] = {text = L["In this menu you can select different parts of the AddOn. The selected menu is displayed in white."], xOffset = 0, yOffset = 350, container = "menu", UpArrow = true},
  [2] = {text = L["On most pages you can set your instance, difficulty and specialization in the top of the page. These settings are saved across all pages."], xOffset = 0, yOffset = -20, UpArrow = true, container = "content", element="difficulty"},
  [3] = {text = (L["On this page you can set your BestInSlot list. You can use the '%s' buttons to select your item for that slot"]):format(L["Select an item"]), text2 = L["You can right-click icons to quickly remove them from your list."], xOffset = 0, yOffset = -50, container = "content"},
  [4] = {text = L["When you've set a difficulty before, you can easily import a previously set list."], onRequest = true, xOffset = 0, yOffset = 0, container="content", element="importButton", DownArrow = true},
  [5] = {text = L["When selecting rings or trinkets, you can see both items at once."], text2 = L["Use left-click to (de)select the left one, and right-click to select the right one"], xOffset = -200, yOffset = -50, container = "content", element = "selectedItem", onRequest = true, UpArrow = true},
})

local function cancel()
 dropdownImport:SetValue(nil)
end

local function doImport()
  Manager:DoImport()
  cancel()
end

local function copyChar()
  Manager:DoCopyChar()
  cancel()
end

StaticPopupDialogs["BESTINSLOT_CONFIRMIMPORT"] = {
  text = L["Are you sure you want to import the %s difficulty? This will override your old BiS list!"],
  button1 = YES,
  button2 = NO,
  OnAccept = doImport,
  OnCancel = cancel,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  exclusive = 1,
}
StaticPopupDialogs["BESTINSLOT_CONFIRMCHARIMPORT"] = {
  text = L["Are you sure you want to import the list from %s? This will override your old BiS list!"],
  button1 = YES,
  button2 = NO,
  OnAccept = copyChar,
  OnCancel = cancel,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  exclusive = 1
}