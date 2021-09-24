--lua
local unpack, select, type, pairs, tContains, wipe, tinsert, tsort
=     unpack, select, type, pairs, tContains, wipe, table.insert, table.sort
-- WoW Api
local GetGuildInfo, GetItemInfo, GetItemInfoFromHyperlink, GetItemIcon, GetOSLocale, GetNumSpecializationsForClassID, GetSpecializationInfoForClassID, GetInventorySlotInfo, IsInGuild, CreateFrame, StaticPopup_Show, EasyMenu
=     GetGuildInfo, GetItemInfo, GetItemInfoFromHyperlink, GetItemIcon, GetOSLocale, GetNumSpecializationsForClassID, GetSpecializationInfoForClassID, GetInventorySlotInfo, IsInGuild, CreateFrame, StaticPopup_Show, EasyMenu
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local GuildLists = BestInSlot:GetMenuPrototype(L["Guild BiS lists"])
local dropdownRaidTier, dropdownDifficulty, dropdownFilter, contentPanel
local selectedCharacter, selectedSort
local itemGroups = {}
local SORT_NAME, SORT_CLASS, SORT_GUILDRANKS = NAME, CLASS, GUILDCONTROL_GUILDRANKS
GuildLists.Height = function() if GuildLists.Artifacts then return 650 else return 600 end end
GuildLists.Width = 800
local classIds = {
  WARRIOR = 1,
  PALADIN = 2,
  HUNTER = 3,
  ROGUE = 4,
  PRIEST = 5,
  DEATHKNIGHT = 6,
  SHAMAN = 7,
  MAGE = 8,
  WARLOCK = 9,
  MONK = 10,
  DRUID = 11,
  DEMONHUNTER = 12,
}

local function deleteCachedData(dialog, character, table)
  if type(table) ~= "table" or type(character) ~= "string" then return end
  local guildCache = GuildLists.db.factionrealm[GetGuildInfo("player")]
  if table.all then
    guildCache[character] = nil
  elseif table.spec then
    guildCache[character][table.raidtier][table.difficulty][table.spec] = nil
  elseif table.difficulty then
    guildCache[character][table.raidtier][table.difficulty] = nil
  elseif table.raidtier then
    guildCache[character][table.raidtier] = nil
  end
  GuildLists:SendEvent("GuildCacheUpdated")
  GuildLists:GeneratePlayerScrollContainer()
end

local function confirmDeletion(dialog, arg1, arg2)
  local popup = StaticPopup_Show("BESTINSLOT_CONFIRMDELETECACHE", dialog.value)
  popup:SetFrameStrata("TOOLTIP")
  popup.data = arg1
  popup.data2 = arg2
end

local function showHistory(dailog, character, data)
  local raidtier = data.raidtier
  local difficulty = data.difficulty
  GuildLists:SetMenu(GuildLists.History.menuid, character, raidtier, difficulty)
end

local function GeneratePlayerScrollContainer()
  GuildLists:GeneratePlayerScrollContainer()
end

function GuildLists:GetContextMenu(character, spec)
  local menu = {}
  local raidTier = dropdownRaidTier:GetValue()
  local difficulty = dropdownDifficulty:GetValue()
  if self.History:HasHistory(character, raidTier, difficulty) then
    tinsert(menu, {text = L["Show history for %s"]:format(character),           func = showHistory,     arg1 = character, arg2 = {raidtier = raidTier, difficulty = difficulty}})   
  else
    tinsert(menu, {text = L["There is no history available for %s"]:format(character), disabled = true})
  end
  tinsert(menu, {text = L["Delete options"], isTitle = true})
  if spec ~= nil then
    tinsert(menu, { text = L["Delete this specialization from this raid tier"], func = confirmDeletion, arg1 = character, arg2 = {raidtier = raidTier, difficulty = difficulty, spec = spec} })
  end
  tinsert(menu, {text = L["Delete %s from this difficulty"]:format(character),  func = confirmDeletion, arg1 = character, arg2 = {raidtier = raidTier, difficulty = difficulty}})
  tinsert(menu, { text = L["Delete %s from this raidtier"]:format(character),   func = confirmDeletion, arg1 = character, arg2 = {raidtier = raidTier}})
  tinsert(menu, { text = L["Delete %s completely."]:format(character),          func = confirmDeletion, arg1 = character, arg2 = {all = true}})

  tinsert(menu, { text = CLOSE})
  if not self.dialog then
    self.dialog = CreateFrame("Frame", "BiSGuildListDialog", UIParent, "UIDropDownMenuTemplate")
    self.dialog:SetFrameStrata("TOOLTIP")
  end
  
  -- Make the menu appear at the cursor: 
  EasyMenu(menu, self.dialog, "cursor", 0 , 0, "MENU")
  self.dialog:Show()
end

function GuildLists:SetCustomItem(itemlink, specId)
  if not self.processedSlots then return end
  local _, link, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(itemlink)
  local slotId, slotId2 = self:GetItemSlotID(equipSlot, specId)
  if slotId2 and tContains(self.processedSlots, slotId) then
    slotId = slotId2
  end
  local label = itemGroups[slotId]:GetUserData("label")
  local icon = itemGroups[slotId]:GetUserData("icon")
  label:SetText(link)
  label:SetUserData("itemid", GetItemInfoFromHyperlink(link))
  label:SetUserData("itemlink", link)
  label:SetUserData("difficulty", 1)
  icon:SetImage(texture)
  tinsert(self.processedSlots, slotId)
end

function GuildLists:FillItemGroupsForSpec(specId)
  if not selectedCharacter then self.console:AddError("Selected Character variable is not set!") return end
  local difficulty = dropdownDifficulty:GetValue()
  local BiSList = selectedCharacter[specId]
  self.processedSlots = {}
  local selectedRaidTier = self:GetSelected(self.RAIDTIER)
  if selectedRaidTier >= 70000 and selectedRaidTier < 80000 and self.Artifacts then
    local artMH, artOH = self.Artifacts:ForSpecialization(specId)
    local label = itemGroups[16]:GetUserData("label")
    local icon = itemGroups[16]:GetUserData("icon")
    label:SetText(artMH.link)
    label:SetUserData("itemid", artMH.id)
    label:SetUserData("itemlink", artMH.link)
    icon:SetImage(artMH.texture)
    tinsert(self.processedSlots, 16)
    if artOH then
      local label = itemGroups[17]:GetUserData("label")
      local icon = itemGroups[17]:GetUserData("icon")
      label:SetText(artOH.link)
      label:SetUserData("itemid", artOH.id)
      label:SetUserData("itemlink", artOH.link)
      icon:SetImage(artOH.texture)
      tinsert(self.processedSlots, 17)
    end
  end
  for i in pairs(BiSList) do
    if not BiSList[i].customitem then
      local item = self:GetItem(BiSList[i].item, difficulty)
      if item ~= nil then
        local slotId, slotId2 = self:GetItemSlotID(item.equipSlot, specId)
        if slotId2 and tContains(self.processedSlots, slotId) then
          slotId = slotId2
        end
        if not slotId then
          slotId = i
        end
        local label = itemGroups[slotId]:GetUserData("label")
        local icon = itemGroups[slotId]:GetUserData("icon")
        label:SetText(item.link)
        label:SetUserData("itemid", item.itemid)
        label:SetUserData("itemlink", item.link)
        label:SetUserData("difficulty", difficulty)
        icon:SetImage(GetItemIcon(item.itemid))
        tinsert(self.processedSlots, slotId)
      end
    else
      local name = GetItemInfo(BiSList[i].item) 
      if not name then
        local eventId = self:RegisterEvent("GET_ITEM_INFO_RECEIVED", function(_, itemid)
          if BiSList[i].item == itemid then
            GuildLists:SetCustomItem(BiSList[i].customitem, specId)
          end
        end)
        C_Timer.NewTimer(0.5, function() self:UnregisterEvent("GET_ITEM_INFO_RECEIVED", eventId) end)
      else
        GuildLists:SetCustomItem(BiSList[i].customitem, specId)
      end
    end
  end
  for slotId, itemGroup in pairs(itemGroups) do
    local processed = false
    for i=1,#self.processedSlots do
      if slotId == self.processedSlots[i] then
        processed = true
        break
      end
    end
    if not processed then
      local label = itemGroups[slotId]:GetUserData("label")
      local icon = itemGroups[slotId]:GetUserData("icon")
      label:SetText("")
      label:SetUserData("itemid", nil)
      label:SetUserData("itemlink", nil)
      label:SetUserData("difficulty", nil)
      icon:SetImage(unpack(icon:GetUserData("default")))
    end
  end
end

local function setRelicDefaults(specId)
  local relics = GuildLists.Artifacts:GetRelicsForSpecialization(specId)
  local texture = GuildLists.Artifacts:GetTexture()
  for i=1,3 do
    local itemGroup = itemGroups[i+29]
    if itemGroup then
      local icon = itemGroup:GetUserData("icon")
      local relicCoords = GuildLists.Artifacts:GetTextureCoordinatesForRelic(relics[i])
      icon:SetUserData("default", {texture, unpack(relicCoords)})
    end
  end
end

local function specIconOnClick(icon, event, button)
  if button == "LeftButton" then
    local selectedSpec = icon:GetUserData("specid")
    if GuildLists.Artifacts then
      setRelicDefaults(selectedSpec)
    end
    GuildLists:FillItemGroupsForSpec(selectedSpec)
  elseif button == "RightButton" then
    GuildLists:GetContextMenu(icon:GetUserData("player"), icon:GetUserData("specid"))
  end
end

function GuildLists:GetOrderTable(players)
  local order = selectedSort or SORT_NAME
  local sorted = {}
  for k in pairs(players) do
    sorted[#sorted + 1] = k
  end
  if order == SORT_NAME then return self:GetNameOrder(sorted) end
  if order == SORT_CLASS then return self:GetClassOrder(sorted) end
  if order == SORT_GUILDRANKS then return self:GetGuildRankOrder(sorted) end
end

local function indexOfValue(tbl, value)
  for k, v in pairs(tbl) do
    if v == value then return k end
  end
end

function GuildLists:GetNameOrder(players)
  tsort(players)
  return players
end

function GuildLists:GetClassOrder(players)
  local function sort(a, b)
    local indexA = indexOfValue(CLASS_SORT_ORDER, self:GetPlayerClass(a)) or -1
    local indexB = indexOfValue(CLASS_SORT_ORDER, self:GetPlayerClass(b)) or -1
    if indexA == -1 then return true
    elseif indexB == -1 then return false end
    local indexDif = indexA - indexB
    if indexDif == 0 then
      return a < b --sort by name if the class is the same
    else
      return indexDif < 0
    end
  end
  tsort(players, sort)
  return players
end

function GuildLists:GetGuildRankOrder(players)
  tsort(players, function(a,b)
    local rankA = self:GetGuildRank(a) or -1
    local rankB = self:GetGuildRank(b) or -1
    if rankA == -1 then return true
    elseif rankB == -1 then return false
    end
    if rankA == rankB then return a < b end
    return rankA < rankB
  end)
  return players
end

local function itemGroupHelper(textureName, slotId, width, ...)
  local itemGroup = AceGUI:Create("SimpleGroup")
  itemGroup:SetHeight(45)
  itemGroup:PauseLayout()
  itemGroup:SetRelativeWidth(width or 0.49)
  
  local icon = AceGUI:Create("Icon")
  icon:SetImageSize(40,40)
  icon:SetWidth(40)
  icon:SetHeight(45)
  icon:SetImage(textureName, ...)
  icon:SetPoint("TOPLEFT", itemGroup.frame, "TOPLEFT")
  icon:SetUserData("default", {textureName})
  itemGroup:AddChild(icon)
  itemGroup:SetUserData("icon", icon)
  
  local label = GuildLists:GetItemLinkLabel("PLACEHOLDER")
  label:SetFontObject(GameFontNormal)
  label:SetPoint("LEFT", icon.frame, "RIGHT")
  label:SetWidth(260)
  
  itemGroup:AddChild(label)
  itemGroup:SetUserData("label", label)
  
  
  icon:SetCallback("OnEnter", function(widget, ...) label:Fire("OnEnter", ...) end)
  icon:SetCallback("OnLeave", function(widget, ...) label:Fire("OnLeave", ...) end)
  icon:SetCallback("OnClick", function(widget, ...) label:Fire("OnClick", ...) end)
  
  itemGroup:SetCallback("OnRelease", function()
    itemGroups[slotId] = nil
  end)
  itemGroups[slotId] = itemGroup
  return itemGroup
end

function GuildLists:GeneratePlayerBiSList(player, class)
  if contentPanel == nil then return end
  if self.dialog and self.dialog:IsShown() then
    self.dialog:Hide()
  end
  contentPanel:ReleaseChildren()
  contentPanel:SetWidth(600)
  contentPanel:SetHeight(485)
  contentPanel:SetLayout("Flow")
  local label = AceGUI:Create("InteractiveLabel")
  label:SetText(L["Return to character selection"])
  label:SetWidth(295)
  label:SetHeight(24)
  label:SetFontObject(GameFontNormal)
  label:SetColor(1, 1, 0)
  label:SetCallback("OnClick", function() GuildLists:GeneratePlayerScrollContainer() end)
  label:SetImage("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
  label:SetHighlight("Interface\\Buttons\\UI-Common-MouseHilight")
  label:SetImageSize(24,24)
  contentPanel:AddChild(label)
  local label = AceGUI:Create("Label")
  if (player):sub(-1) == "s" and GetOSLocale() == "enUS" then
    label:SetText(string.format("%s' BestInSlot lists", self:GetPlayerString(player)))
  else
    label:SetText(string.format(L["%s's BestInSlot lists"], self:GetPlayerString(player)))
  end
  label:SetFontObject(GameFontNormal)
  label:SetHeight(24)
  label:SetWidth(295)
  label:SetColor(1, 1, 0)
  contentPanel:AddChild(label)
  local numSpecs = GetNumSpecializationsForClassID(classIds[class])
  for i=1,numSpecs do
    local icon = AceGUI:Create("Icon")
    local specId, specName, specDescr, specTexture = GetSpecializationInfoForClassID(classIds[class],i)
    icon:SetImage(specTexture)
    icon:SetLabel(specName)
    icon:SetUserData("specid", specId)
    icon:SetUserData("player", player)
    icon:SetImageSize(30,30)
    icon:SetHeight(50)
    icon.frame:RegisterForClicks("AnyDown")
    icon:SetCallback("OnClick", specIconOnClick)
    icon:SetRelativeWidth(1 / numSpecs - 0.01)
    icon:SetDisabled(selectedCharacter[specId] == nil)
    if i == 1 then
      self.frame:GetUserData("content"):SetUserData("talent", icon)
    end
    contentPanel:AddChild(icon)
  end
  local slots = self.slots
  for i=1,#slots do
    local slotId, textureName = GetInventorySlotInfo(slots[i])
    local itemGroup = itemGroups[slotId]
    if not itemGroup then
      itemGroup = itemGroupHelper(textureName, slotId)
      contentPanel:AddChild(itemGroup)
    end
  end
  if self.Artifacts then
    local placeHolderTexture = self.Artifacts:GetTexture()
    local placeHolderCoords = self.Artifacts:GetPlaceholderLocation()
    for i=1,3 do
      local itemGroup = itemGroups[29 + i]
      if not itemGroup then
        itemGroup = itemGroupHelper(placeHolderTexture, 29 + i, 0.32, unpack(placeHolderCoords))
        itemGroups[29+i] = itemGroup
        contentPanel:AddChild(itemGroup)
      end
    end
  end
  self:ShowTutorial(L["Guild BiS lists"], 4)
  dropdownFilter:SetDisabled(true)
end

local function playerIconOnClick(widget, event, button)
  if button == "LeftButton" then
    local table = widget:GetUserDataTable()
    local player = widget:GetUserData("char")
    local playerClass = widget:GetUserData("class")
    local raidTier = dropdownRaidTier:GetValue()
    selectedCharacter = GuildLists.db.factionrealm[GetGuildInfo("player")][player][raidTier][dropdownDifficulty:GetValue()]
    GuildLists:GeneratePlayerBiSList(player, playerClass)
  elseif button == "RightButton" then
    GuildLists:GetContextMenu(widget:GetUserData("char"))
  end
end

function GuildLists:GeneratePlayerScrollContainer()
  if contentPanel == nil then return end
  selectedCharacter = nil
  local raidTier = self:GetSelected(self.RAIDTIER)
  local difficulty = self:GetSelected(self.DIFFICULTY)
  local guild = GetGuildInfo("player")
  local players = self:GetCacheData()
  local sortedTable = self:GetOrderTable(players)
  contentPanel:ReleaseChildren()
  contentPanel:SetWidth(600)
  contentPanel:SetHeight(485)
  contentPanel:SetLayout("Fill")
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("Flow")
  contentPanel:AddChild(scroll)
  local first = true
  for i=1,#sortedTable do
    local player = sortedTable[i]
    local playerData = players[player]
    local hasABiSList = false
    for j=1,#playerData do
      if playerData.guild == guild and playerData[j][1] == raidTier and playerData[j][2] == difficulty then
        hasABiSList = true
        break
      end 
    end
    if hasABiSList then
      local playerClass = self:GetPlayerClass(player) or UNKNOWN
      if playerClass ~= UNKNOWN then
        local icon = AceGUI:Create("Icon")
        icon:SetLabel(self:GetPlayerString(player))
        icon:SetImage("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", unpack(CLASS_ICON_TCOORDS[playerClass]))
        icon:SetRelativeWidth(0.14)
        icon:SetUserData("char", player)
        icon:SetUserData("class", playerClass)
        icon.frame:RegisterForClicks("AnyDown")
        icon:SetCallback("OnClick", playerIconOnClick)
        scroll:AddChild(icon)
        if first then
          self.frame:GetUserData("content"):SetUserData("firstchar", icon)
          first = false
        end
      end
    end
  end
  dropdownFilter:SetDisabled(false)
end

function GuildLists:FillFilterOptions(dropdown)
  local list = {
    [SORT_NAME] = SORT_NAME,
    [SORT_CLASS] = SORT_CLASS,
    [SORT_GUILDRANKS] = SORT_GUILDRANKS,
  }
  local order = {SORT_NAME, SORT_CLASS, SORT_GUILDRANKS}
  dropdown:SetList(list, order)
  dropdown:SetValue(selectedSort or SORT_NAME)
end

local function filterOnValueChanged(dropdown, _, value)
  selectedSort = value
  GuildLists:GeneratePlayerScrollContainer()
end

function GuildLists:Draw(container)  
  dropdownRaidTier = self:GetDropdown(self.RAIDTIER, nil, GeneratePlayerScrollContainer)
  dropdownRaidTier:SetRelativeWidth(0.32)
  
  dropdownDifficulty = self:GetDropdown(self.DIFFICULTY, nil, GeneratePlayerScrollContainer)
  dropdownDifficulty:SetRelativeWidth(0.32)
  
  dropdownFilter = AceGUI:Create("Dropdown")
  dropdownFilter:SetLabel(COMPACT_UNIT_FRAME_PROFILE_SORTBY)
  dropdownFilter:SetRelativeWidth(0.32)
  dropdownFilter:SetCallback("OnValueChanged", filterOnValueChanged)
  self:FillFilterOptions(dropdownFilter)
  
  container:AddChild(dropdownRaidTier)
  container:AddChild(dropdownDifficulty)
  container:AddChild(dropdownFilter)
  
  container:SetUserData("raidtier", dropdownRaidTier)
  
  if dropdownRaidTier.disabled and dropdownDifficulty.disabled then
    local label = AceGUI:Create("Label")
    label:SetFont(GameFontNormal:GetFont(), 14, nil)
    label:SetFullWidth(true)
    label:SetText(L["There are no Best in Slot lists from any of your guild members available. Have you requested their Best In Slot info?"])
    container:AddChild(label)
  else
    contentPanel = AceGUI:Create("SimpleGroup")
    contentPanel:SetWidth(600)
    contentPanel:SetHeight(485)
    contentPanel:SetPoint("TOPLEFT", dropdownRaidTier.frame, "BOTTOMLEFT", 10, 10)
    
    container:AddChild(contentPanel)
    GuildLists:GeneratePlayerScrollContainer()
    GuildLists:ShowTutorial(L["Guild BiS lists"], 1)
  end
end

function GuildLists:Close()
  contentPanel:ClearAllPoints()
  dropdownDifficulty = nil
  dropdownRaidTier = nil
  dropdownFilter = nil
  contentPanel = nil
  wipe(itemGroups)
  if self.processedSlots then
    wipe(self.processedSlots)
  end
end

function GuildLists:IsShown()
  if IsInGuild() then
    local _,raidtiers,_, difficulties =  GuildLists:GetCacheData()
    return #raidtiers > 0
  end
  return false
end

GuildLists:RegisterTutorials(L["Guild BiS lists"], {
  [1] = {text = L["On this page you can view the BestInSlot lists of your guild."], xOffset = 0, yOffset = -50, container = "content", onRequest = true},
  [2] = {text = L["The dropdowns will only show BestInSlot lists that you have available."], text2 = (L["You can request BestInSlot lists in the '%s' page."]):format(L["Request BiS"]), xOffset = 0, yOffset = -10, container = "content", element = "raidtier", UpArrow = true },
  [3] = {text = L["Click on the class icons to view that characters BestInSlot list."], text2 = L["Right clicking the icons gives you options to delete them from your Saved Variables."], xOffset = 0, yOffset = -20, container = "content", element = "firstchar", UpArrow = true},
  [4] = {text = L["Click on any specialization icon to view that specializations list."], text2 = L["Only the specializations that you received are enabled."], xOffset = 0, yOffset = -20, container = "content", element = "talent", onRequest = true, UpArrow = true}  
})

StaticPopupDialogs["BESTINSLOT_CONFIRMDELETECACHE"] = {
  text = L["You've picked: %s"].."\n"..L["Deleting this is irreversible. Are you sure?"],
  button1 = YES,
  button2 = NO,
  OnAccept = deleteCachedData,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  exclusive = 1,
}