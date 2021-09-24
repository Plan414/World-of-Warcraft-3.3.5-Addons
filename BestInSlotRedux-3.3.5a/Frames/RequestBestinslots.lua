--lua
local unpack, select, type, pairs, tostring, wipe, tinsert, tsort
=     unpack, select, type, pairs, tostring, wipe, table.insert, table.sort
local BabbleInventory = LibStub("LibBabble-Inventory-3.0"):GetLookupTable()
-- WoW API
local UnitName, GetGuildInfo, IsInGuild
=     UnitName, GetGuildInfo, IsInGuild
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local RequestBiS = BestInSlot:GetMenuPrototype(L["Request BiS"])
RequestBiS.Width = 700
RequestBiS.Height = 600
local dropdownSelection, dropdownRequestFrom, dropdownDifficulty, dropdownFilter
local whisperTarget
local whisperTo
local requestButton
local responseContainer
local selectedChannel
local normalColor = "|cffb5ffb4"
local history = {}
local filter = {}
local inQueue = {}
local queueTimer
local showObtainedItems = true
local showCached = false
local classTokens = {
  VANQUISHER = {"ROGUE", "DEATHKNIGHT", "MAGE", "DRUID"},
  PROTECTOR = {"WARRIOR", "HUNTER", "SHAMAN", "MONK"},
  CONQUEROR = {"PALADIN", "PRIEST", "WARLOCK", "DEMONHUNTER"},
}
local armorClasses = {
  [BabbleInventory.Cloth] = {"MAGE", "PRIES", "WARLOCK"},
  [BabbleInventory.Leather] = {"ROGUE", "DEMONHUNTER", "DRUID", "MONK"},
  [BabbleInventory.Mail] = {"HUNTER", "SHAMAN"},
  [BabbleInventory.Plate] = {"DEATHKNIGHT", "WARRIOR", "PALADIN"}
}
local guildName
---
-- Helper function to format the labels properly
---
function RequestBiS:SetText(label)
  local itemLink = label:GetUserData("itemlink")
  local chars = label:GetUserData("chars")
  local str = itemLink
  local first = true
  for player,specs in pairs(chars) do
    if first then --comma or colon
      str = str..": "
      first = false
    else
      str = str..", "
    end
    if #specs == 1 then
      str = str..self:GetPlayerString(player)
    elseif #specs > 1 then
      local addStr = self:GetClassColor(self:GetPlayerClass(player))..player.." ("
      for i=1,#specs do
        local specName = select(2, GetSpecializationInfoByID(specs[i]))
        addStr = addStr..specName..(i == #specs and "" or "/")
      end
      str = str..addStr..")|r"
    end
  end
  label:SetText(str)
end

function RequestBiS:FillBossGroups()
  local bosses = responseContainer:GetUserData("bosses")
  for i=1,bosses do
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    local header = AceGUI:Create("Heading")
    header:SetFullWidth(true)
    header:SetText(self:GetDescription(self.BOSS, responseContainer:GetUserData("selection"), i))
    group:AddChild(header)
    responseContainer:AddChild(group)
    responseContainer:SetUserData("boss"..i, group)
  end
end

function RequestBiS:ResetRaidTier()
  responseContainer:ReleaseChildren()
  self:FillBossGroups()
end

function RequestBiS:RegisterRaidTier(name, bis, specId)
  if type(bis) ~= "table" then return end
  for i,_ in pairs(bis) do
    local itemid, obtained, customitem = bis[i].item, bis[i].obtained, bis[i].customitem
    if showObtainedItems or not obtained then
      local item = self:GetItem(itemid)
      if not customitem and item and item.dungeon == responseContainer:GetUserData("selection") then --item should be from this instance
        local bossGroup = responseContainer:GetUserData("boss"..tostring(item.bossid))
        if bossGroup then
          local label = bossGroup:GetUserData(itemid)
          if not label then
            local label = self:GetItemLinkLabel(itemid, self:GetSelected(self.DIFFICULTY))
            label:SetUserData("chars", {[name] = {specId}})
            label:SetFullWidth(true)
            self:SetText(label)
            bossGroup:AddChild(label)
            bossGroup:SetUserData(itemid, label)
          else
            local chars = label:GetUserData("chars")
            chars[name] = chars[name] or {}
            chars[name][#chars[name] + 1] = specId
            self:SetText(label)
          end
        end
      end
    end
  end
end

function RequestBiS:PopulateRaidTier()
  responseContainer:SetLayout("List")
  local bosses = RequestBiS:GetInstanceBosses(responseContainer:GetUserData("selection"))
  responseContainer:SetUserData("bosses", #bosses)
  self:ResetRaidTier()
end

function RequestBiS:ProcessQueueItems()
  self.console:Add("Processing queued responses")
  for source, itemlist in pairs(inQueue) do
    self:DoRegister(source, itemlist)
  end
  inQueue = {}
  self:SetFilterOptions()
  responseContainer:DoLayout()
  self:ShowTutorial(L["Request BiS"], 4)
end

function RequestBiS:QueueRegister(source, itemlist)
  if queueTimer == nil or queueTimer._remainingIterations == 0 then
    self.console:Add("Queueing up responses")
    queueTimer = C_Timer.NewTimer(1, function() RequestBiS:ProcessQueueItems() end)
  end
  if not inQueue then
    inQueue = {}
  end
  inQueue[source] = itemlist
end

---Called when the actual request button is pressed, or to simulate it being pressed at startup
function RequestBiS:DoRequest()
  history = {}
  filter = {}
  if not responseContainer then return end
  responseContainer:ReleaseChildren()
  local selected = self:GetSelected()
  local msg = self:GetSelected()
  msg = {selection = selected.instance, difficulty = selected.difficulty}
  responseContainer:SetUserData("selection", selected.instance)
  responseContainer:SetUserData("channel", selectedChannel)
  responseContainer:SetUserData("difficulty", selected.difficulty)
  self:PopulateRaidTier()
  local raidtier = self:GetSelected(self.RAIDTIER)
  self:SendAddonMessage("requestRaidInstance", msg, selectedChannel, whisperTo)
  if selectedChannel ~= "WHISPER" then
    local player = UnitName("player")
    self:QueueRegister(player, self:GetBestInSlotItems(raidtier, selected.difficulty))
    filter[player] = {show = true, [self:GetSelected(self.SPECIALIZATION)] = true}
  end
end

function RequestBiS:CanRequest()
  if selectedChannel and (selectedChannel ~= "WHISPER" or whisperTo) then
    requestButton:SetDisabled(false)
  else
    requestButton:SetDisabled(true)
  end
end

local function dropdownRequestFromOnValueChanged(_,_,value)
  selectedChannel = value
  if value == "WHISPER" then
    whisperTarget:SetDisabled(false)
    RequestBiS:ShowTutorial(L["Request BiS"], 3)
  else
    whisperTarget:SetDisabled(true)
  end
  RequestBiS:CanRequest()
end

local function requestButtonOnClick()
  RequestBiS:DoRequest()
end

local function whisperToEnterPressed(_,_,value)
  whisperTo = value
  RequestBiS:CanRequest()  
end

function RequestBiS:Draw(container)
  dropdownSelection = self:GetDropdown(self.INSTANCE, nil, self.CanRequest)
  dropdownSelection:SetRelativeWidth(0.33)
  container:AddChild(dropdownSelection)
  
  dropdownDifficulty = self:GetDropdown(self.DIFFICULTY, nil, self.CanRequest)
  dropdownDifficulty:SetRelativeWidth(0.33)
  
  container:AddChild(dropdownDifficulty)
  
  dropdownRequestFrom = AceGUI:Create("Dropdown")
  dropdownRequestFrom:SetLabel(L["Request from"])
  dropdownRequestFrom:SetRelativeWidth(0.33)
  dropdownRequestFrom:SetList({
    RAID = ("%s/%s"):format(_G["PARTY"], _G["RAID"]),
    GUILD = _G["GUILD"],
    WHISPER = _G["WHISPER"],    
  })
  container:SetUserData("request", dropdownRequestFrom)
  if not IsInGuild() then
    dropdownRequestFrom:SetItemDisabled("GUILD", true)
  end
  if not IsInGroup() then
    dropdownRequestFrom:SetItemDisabled("RAID", true)
  end
  dropdownRequestFrom:SetText(L["Select a channel"])
  dropdownRequestFrom:SetCallback("OnValueChanged", dropdownRequestFromOnValueChanged)
  
  container:AddChild(dropdownRequestFrom)
  
  whisperTarget = AceGUI:Create("EditBox")
  whisperTarget:SetLabel(L["Whisper target"])
  whisperTarget:SetRelativeWidth(0.245)
  whisperTarget:SetDisabled(true)
  whisperTarget:SetCallback("OnEnterPressed", whisperToEnterPressed)
  
  container:AddChild(whisperTarget)
  
  container:SetUserData("wtarget", whisperTarget)
  
  requestButton = AceGUI:Create("Button")
  requestButton:SetText(L["Request"])
  requestButton:SetRelativeWidth(0.245)
  requestButton:SetDisabled(true)
  requestButton:SetCallback("OnClick", requestButtonOnClick)
    
  container:AddChild(requestButton)
  dropdownRequestFrom:SetValue(selectedChannel)
  if selectedChannel == "WHISPER" then
    whisperTarget:SetDisabled(false)
  end
  whisperTarget:SetText(whisperTo)
  
  dropdownFilter = AceGUI:Create("Dropdown")
  dropdownFilter:SetDisabled(true)
  dropdownFilter.dropdown.obj:SetDisabled(true)
  dropdownFilter:SetRelativeWidth(0.49)
  dropdownFilter:SetList({})
  dropdownFilter:SetLabel(FILTER)
  
  container:AddChild(dropdownFilter)
  container:SetUserData("filter", dropdownFilter)
  
  responseContainer = AceGUI:Create("ScrollFrame")
  responseContainer:SetLayout("List")
  responseContainer:SetFullWidth(true)
  responseContainer:SetFullHeight(true)
  responseContainer:SetPoint("BOTTOMRIGHT", container.frame, "BOTTOMRIGHT")
    
  container:AddChild(responseContainer)
  self:CanRequest()
end

function RequestBiS:Close()
  dropdownSelection = nil
  dropdownRequestFrom = nil
  dropdownDifficulty = nil
  dropdownFilter = nil
  whisperTarget = nil
  requestButton = nil
  responseContainer = nil
  history = nil
  inQueue = nil
  if queueTimer ~= nil then
    queueTimer:Cancel()
  end
end

local function sendRaidTierReply(raidTier, difficulty, source, version)
  local bisList
  if version >= 1 and version <= 96 then -- The >= 1 is ment for development versions
    local specId = GetSpecializationInfo(RequestBiS:GetSpecialization())
    bisList = RequestBiS:GetBestInSlotItems(raidTier, difficulty, specId)
  else
    bisList = RequestBiS:GetBestInSlotItems(raidTier, difficulty) 
  end
  RequestBiS:SendAddonMessage("requestRaidTierReply", bisList, "WHISPER", source)
end

local function requestRaidTier(data, channel, source, version)
  if not data.selection or not data.difficulty then RequestBiS.console:AddError("Invalid data received for requestRaidTier") return end
  local raidTier = data.selection
  local difficulty = data.difficulty
  sendRaidTierReply(raidTier, difficulty, source, version)
end

local function requestRaidInstance(data, channel, source, version)
  if not data.selection or not data.difficulty then RequestBiS.console:AddError("Invalid data received for requestRaidInstance") return end
  local instance = data.selection
  local difficulty = data.difficulty
  local raidTier = RequestBiS:GetRaidTiers(RequestBiS.INSTANCE, instance)
  sendRaidTierReply(raidTier, difficulty, source, version)
end

local function emptySetValue() end --Not used for dropdown-item-menu, therefore a filler empty function

function RequestBiS:ApplyNewFilter()
  self:ResetRaidTier()
  for char,data in pairs(history) do
    if filter[char].show then
      if data.spec then
        for specId, specData in pairs(data) do
          if specId ~= "spec" and filter[char][specId] then
            self:RegisterRaidTier(char, data[specId], specId)
          end
        end
      end
    end
  end
end

function RequestBiS:CheckArmorDisable()
  for i,armorType in pairs({BabbleInventory.Cloth, BabbleInventory.Leather, BabbleInventory.Mail, BabbleInventory.Plate}) do
    local armorSelector = dropdownFilter:GetUserData("Armor"..i)
    if armorSelector then
      local enabled = false
      for i=1,#armorClasses[armorType] do
        local class = armorClasses[armorType][i]
        local classSelector = dropdownFilter:GetUserData(class)
        if classSelector and classSelector:GetValue() then
          enabled = true
          break
        end
      end
      armorSelector:SetValue(enabled)
    end
  end
end

---Verifies the token filter menu with what is actually in the filter table
function RequestBiS:CheckTokenDisable()
  for tokenType, tokenClasses in pairs(classTokens) do
    local tokenSelector = dropdownFilter:GetUserData(tokenType)
    if tokenSelector then
      local tokenEnabled = false
      for i=1,#tokenClasses do
        local classSelector = dropdownFilter:GetUserData(tokenClasses[i])
        if classSelector and classSelector:GetValue() then
          tokenEnabled = true
          break
        end
      end
      tokenSelector:SetValue(tokenEnabled)
    end
  end
end

---Verifies the class filter menu with what is actually in the filter table
function RequestBiS:CheckClassDisable(recursive)
  recursive = recursive or true
  local hasChanged = false
  for class in pairs(RAID_CLASS_COLORS) do -- we use the RAID_CLASS_COLORS global since that contains all the classes
    local classWidget = dropdownFilter:GetUserData(class)
    if classWidget then
      local shouldShowClass = false
      for char in pairs(filter) do
        if RequestBiS:GetPlayerClass(char) == class then
          if filter[char].show then
            shouldShowClass = true
            break
          end
        end
      end
      if classWidget:GetValue() ~= shouldShowClass then
        hasChanged = true
        classWidget:SetValue(shouldShowClass)
      end
    end
  end
  if hasChanged and recursive then
    self:CheckTokenDisable()
  end
end

---Verifies the guild ranks filter menu with what is actually in the filter table
function RequestBiS:CheckGuildRankDisable(recursive)
  recursive = recursive or (recursive == nil and true)
  for i=1,GuildControlGetNumRanks() do
    local guildWidget = dropdownFilter:GetUserData("GuildRank"..i)
    if guildWidget then 
      guildWidget:SetValue(false)
      guildWidget:SetDisabled(true) 
    end --Disable it before looping through the roster
  end
  for i=1,GetNumGuildMembers() do
    local fullName, _, rankIndex = GetGuildRosterInfo(i)
    rankIndex = rankIndex + 1
    local playerName = (fullName):match("(%D+)-(%D+)")
    if filter[playerName] then --Player is known in our filter
      local guildWidget = dropdownFilter:GetUserData("GuildRank"..rankIndex) --get the widget for the player's guild rank
      if guildWidget  then
        if filter[playerName].show then
          guildWidget:SetValue(true) -- Tick the box if we have a player shown off this guild rank
        end
        guildWidget:SetDisabled(false) --Enable the tickbox for use
      end
    end
  end
end

---Verifies the character filter menu with what is actually in the filter table
function RequestBiS:CheckPlayerDisable(recursive)
  recursive = recursive or (recursive == nil and true)
  local hasChanged = false
  for char, charFilter in pairs(filter) do
    local charGroup = dropdownFilter:GetUserData(char)
    local widgetGroup = charGroup:GetUserDataTable()
    for widgetDescr,widget in pairs(widgetGroup) do
      if widgetDescr == "visible" then --if it's the show widget
        if widget:GetValue() ~= (charFilter.show or false) then
          hasChanged = true
        end
        widget:SetValue(charFilter.show or false)          
      elseif widget then --if it's a spec widget
        widget:SetValue(charFilter[widgetDescr] or false)
      end
    end
  end
  if hasChanged and recursive then
    self:CheckClassDisable()
  end
end

function RequestBiS:VerifyCheckBoxes()
  self:CheckPlayerDisable(false)
  self:CheckGuildRankDisable(false)
  self:CheckClassDisable(false)
  self:CheckTokenDisable(false)
  self:CheckArmorDisable(false)
end

--- Simply (un)ticks all the options in the filter
-- @param #boolean value Wether to tick, or untick everything
-- @param #boolean ignoreApply Optional, if true then doesn't apply the filter afterwards. 
function RequestBiS:SetAllFilter(value, ignoreApply)
  local userData = dropdownFilter:GetUserDataTable()
  for char, charFilter in pairs(filter) do
    charFilter.show = value
  end
  self:VerifyCheckBoxes()
  if not ignoreApply then
    self:ApplyNewFilter()
  end
end

--- Untick the character, and checks if other tickboxes should be unticked as a result
-- @param #string char Character name
-- @param #boolean value Was the character enabled (true) or disabled (false)
-- @param #boolean ignoreApply Optional, if true then doesn't apply the filter afterwards.
function RequestBiS:SetCharFilter(char, value, ignoreApply)
  local userData = dropdownFilter:GetUserDataTable()
  for filterType in pairs(filter[char]) do
    if filterType == "show" then
      filter[char][filterType] = value
    elseif (not value) or (history[char] and history[char].spec == filterType)  then --Set all specs to false when unticked, set active spec to true when ticked
      filter[char][filterType] = value
    end
  end
  filter[char].show = value
  local class = self:GetPlayerClass(char)
  local playerClassTickerEnabled = false
  for char, charData in pairs(filter) do
    if self:GetPlayerClass(char) == class and charData.show then --There is still a char with the same class enabled
      playerClassTickerEnabled = true
      break
    end
  end
  if userData[class] then userData[class]:SetValue(playerClassTickerEnabled) end
  self:CheckClassDisable()
  self:CheckGuildRankDisable()
  if not ignoreApply then
    self:ApplyNewFilter()
  end
end

function RequestBiS:SetSpecFilter(char, spec, value, ignoreApply)
  local shouldRefresh = not value --when ticking a box, it defualts to not show
  filter[char][spec] = value
  if value then
    filter[char].show = true
    shouldRefresh = true
  else
    for k,v in pairs(filter[char]) do
      if k ~= "show" and v then -- Check if a spec is still selected, if none
        shouldRefresh = false
        break
      end
    end
    if shouldRefresh then
      filter[char].show = false
    end
  end
  if shouldRefresh then
    self:VerifyCheckBoxes()
  end 
  if not ignoreApply then
    self:ApplyNewFilter()
  end
end

--- Untick the class, and check if other tickboxes should be unticked as a result
-- @param #string class Unlocalized class string
-- @param #boolean value Was the class enabled (true) or disabled (false)
-- @param #boolean ignoreApply Optional, if true then doesn't apply the filter afterwards.
function RequestBiS:SetClassFilter(class, value, ignoreApply)
  local userData = dropdownFilter:GetUserDataTable()
  for char, data in pairs(filter) do
    if self:GetPlayerClass(char) == class then
      data.show = value
      if userData[char] then
        local visible = userData[char]:GetUserData("visible")
        visible:SetValue(value)
      end
    end
  end
  if not ignoreApply then
    self:ApplyNewFilter()
  end
  self:CheckTokenDisable()
  self:CheckGuildRankDisable()
end

--- On clicking a guild filter it'll update the filter according to the guild rank that has been unticked
-- @param #number guildRank the number of the guildrank that is to be unticked
-- @param #boolean value True if enabled, otherwise false
-- @param #boolean ignoreApply Optional, if true then doesn't apply the filter afterwards.
function RequestBiS:SetGuildFilter(guildRank, value, ignoreApply)
  for i=1,GetNumGuildMembers() do
    local fullName, _, rankIndex = GetGuildRosterInfo(i)
    rankIndex = rankIndex + 1
    if rankIndex == guildRank then
      local playerName = (fullName):match("(%D+)-(%D+)")
      if filter[playerName] then
        filter[playerName].show = value
      end
    end
  end
  if not ignoreApply then
    self:ApplyNewFilter()
  end
  self:CheckPlayerDisable()
end

function RequestBiS:SetArmorFilter(armorType, value)
  for i=1,#armorClasses[armorType] do
    self:SetClassFilter(armorClasses[armorType][i], value, #armorClasses[armorType] < i)
  end
  self:CheckClassDisable()
end


local function onClassSelect(widget, _, value)
  local class = widget:GetUserData("class")
  RequestBiS:SetClassFilter(class, value)
end

local function onTokenSelect(widget, _, value)
  local token = widget:GetUserData("token")
  for i=1,#classTokens[token] do
    local classSelect = dropdownFilter:GetUserData(classTokens[token][i])
    if classSelect then
      classSelect:SetValue(value)
      RequestBiS:SetClassFilter(classTokens[token][i], value, true) --simulate that we're clicking all 3 or 4 class tokens buttons
    end
  end
  RequestBiS:ApplyNewFilter()
end

local function onClickSelectAll(widget)
  local selected = widget:GetUserData("select") or false
  RequestBiS:SetAllFilter(selected)
end

local function onCharacterView(widget, _, value)
  local char = widget:GetUserData("char")
  local specFilter = widget:GetUserData("specFilters")
  if not value then
    for i=1,#specFilter do
      specFilter[i]:SetValue(false)
    end
  else
    for i=1,#specFilter do
      if specFilter[i]:GetUserData("spec") == history[widget:GetUserData("char")].spec then
        specFilter[i]:SetValue(true)
      end
    end
  end
  RequestBiS:SetCharFilter(char, value)
end

local function onSpecChanged(widget, _, value)
  local char = widget:GetUserData("char")
  local spec = widget:GetUserData("spec")
  RequestBiS:SetSpecFilter(char, spec, value)
end

local function onGuildRankSelect(widget, _, value)
  local guildRankId = widget:GetUserData("rank")
  RequestBiS:SetGuildFilter(guildRankId, value)
end

local function onArmorSelect(widget, _, value)
  local armorType = widget:GetUserData("type")
  RequestBiS:SetArmorFilter(armorType, value)
end
function RequestBiS:GetDropdownSeperator()
  local seperator = AceGUI:Create("Dropdown-Item-Separator")
  seperator.SetValue = emptySetValue
  return seperator
end

local function onShowObtainedValue(widget, _, value)
  showObtainedItems = value
  RequestBiS:ApplyNewFilter()
end

local function showCacheOnValue(widget, _, value)
  showCached = value
  RequestBiS:ApplyNewFilter()
end

function RequestBiS:MakeStandardOptions(submenu)
  local hasItems = false
  for _ in pairs(filter) do
    hasItems = true
    break
  end
  local isGuildRequest = responseContainer:GetUserData("channel") == "GUILD" or not responseContainer:GetUserData("channel")
  if not hasItems or not isGuildRequest then
    if not isGuildRequest then --Don't show anything for party/whisper requests
      return
    end
    local header = AceGUI:Create("Dropdown-Item-Header")
    header:SetText(L["Not enough data to filter"])
    header.SetValue = emptySetValue
    submenu:AddItem(header)
    return
  end
  -- Add Select All button
  local selectAll = AceGUI:Create("Dropdown-Item-Execute")
  selectAll:SetText(L["Select all"])
  selectAll:SetCallback("OnClick", onClickSelectAll)
  selectAll.SetValue = emptySetValue
  selectAll:SetUserData("select", true)
  submenu:AddItem(selectAll)
  
  --Add Deselect All button
  local deselectAll = AceGUI:Create("Dropdown-Item-Execute")
  deselectAll:SetText(L["Deselect all"])
  deselectAll:SetCallback("OnClick", onClickSelectAll)
  deselectAll.SetValue = emptySetValue
  submenu:AddItem(deselectAll)
  
  
  local showObtained = AceGUI:Create("Dropdown-Item-Toggle")
  showObtained:SetText(L["Show obtained items"])
  showObtained:SetCallback("OnValueChanged", onShowObtainedValue)
  submenu:AddItem(showObtained)
  showObtained:SetValue(showObtainedItems)
  
  submenu:AddItem(self:GetDropdownSeperator())
  
  --Add the class Menu
  local classMenu = AceGUI:Create("Dropdown-Item-Menu")
  classMenu:SetText(L["Class filter"])
  classMenu.SetValue = emptySetValue
  local classSubMenu = AceGUI:Create("Dropdown-Pullout")
  classSubMenu.SetValue = emptySetValue
  local classesDone = {}
  for charName, charData in pairs(filter) do
    local class, localizedClass = self:GetPlayerClass(charName)
    if class and not classesDone[class] then
      local classToggle = AceGUI:Create("Dropdown-Item-Toggle")
      classToggle:SetUserData("class", class)
      classToggle:SetText(self:GetClassString(class))
      classToggle:SetCallback("OnValueChanged", onClassSelect)
      dropdownFilter:SetUserData(class, classToggle)
      classesDone[class] = classToggle
      classSubMenu:AddItem(classToggle)
    end
  end
  classMenu:SetMenu(classSubMenu)
  submenu:AddItem(classMenu)
  
  --Add the token menu
  local tokenMenu = AceGUI:Create("Dropdown-Item-Menu")
  tokenMenu:SetText(L["Token filter"])
  tokenMenu.SetValue = emptySetValue
  local tokenSubMenu = AceGUI:Create("Dropdown-Pullout")
  tokenSubMenu.SetValue = emptySetValue
  tokenSubMenu:SetWidth(300)
  local tokensDone = {}
  for tokenType, classes in pairs(classTokens) do
    for i=1, #classes do
      if classesDone[classes[i]] then
        local tokenToggle = tokensDone[tokenType] or AceGUI:Create("Dropdown-Item-Toggle")
        if not tokensDone[tokenType] then
          tokenToggle:SetUserData("token", tokenType)
          local text = L[tokenType].." ("
          for j=1,#classes do
            if j ~= 1 then
              text = text.." / "
            end
            text = text..self:GetClassString(classes[j])
          end
          text = text..")"
          tokenToggle:SetText(text)
          tokenToggle:SetCallback("OnValueChanged", onTokenSelect)
          dropdownFilter:SetUserData(tokenType, tokenToggle)
          tokensDone[tokenType] = tokenToggle
          tokenSubMenu:AddItem(tokenToggle)
          break
        end
      end
    end
  end
  tokenMenu:SetMenu(tokenSubMenu)
  submenu:AddItem(tokenMenu)
  
  --Adds the armor filter
  local armorMenu = AceGUI:Create("Dropdown-Item-Menu")
  armorMenu:SetText(L["Armor filter"])
  armorMenu.SetValue = emptySetValue
  local armorSubMenu = AceGUI:Create("Dropdown-Pullout")
  armorSubMenu.SetValue = emptySetValue
  for i,armorType in pairs({BabbleInventory.Cloth, BabbleInventory.Leather, BabbleInventory.Mail, BabbleInventory.Plate}) do
    local armorToggle = AceGUI:Create("Dropdown-Item-Toggle")
    armorToggle:SetText(armorType)
    armorToggle:SetUserData("type", armorType)
    armorToggle:SetCallback("OnValueChanged", onArmorSelect)
    armorSubMenu:AddItem(armorToggle)
    dropdownFilter:SetUserData("Armor"..i, armorToggle)
  end
  armorMenu:SetMenu(armorSubMenu)
  submenu:AddItem(armorMenu)
  
  --Adds the guild filter
  if responseContainer:GetUserData("channel") == "GUILD" or not responseContainer:GetUserData("channel") then -- if the guild window is shown
    local guildMenu = AceGUI:Create("Dropdown-Item-Menu")
    guildMenu:SetText(GUILDCONTROL_GUILDRANKS)
    guildMenu.SetValue = emptySetValue
    local guildSubMenu = AceGUI:Create("Dropdown-Pullout")
    guildSubMenu.SetValue = emptySetValue
    for i=1, GuildControlGetNumRanks() do
      local guildRank = AceGUI:Create("Dropdown-Item-Toggle")
      guildRank:SetText(GuildControlGetRankName(i))
      guildRank:SetUserData("rank", i)
      guildRank:SetCallback("OnValueChanged", onGuildRankSelect)
      guildSubMenu:AddItem(guildRank)
      dropdownFilter:SetUserData("GuildRank"..i, guildRank)
    end
    guildMenu:SetMenu(guildSubMenu)
    submenu:AddItem(guildMenu)
  end
  submenu:AddItem(self:GetDropdownSeperator())
end



function RequestBiS:MakeCharSpecificOptions(submenu, char)
  local header = AceGUI:Create("Dropdown-Item-Header")
  header:SetText(self:GetPlayerString(char))
  submenu:AddItem(header)
  local visibleItem = AceGUI:Create("Dropdown-Item-Toggle")
  visibleItem:SetText(SHOW)
  visibleItem:SetUserData("char", char)
  visibleItem:SetCallback("OnValueChanged", onCharacterView)
  submenu:SetUserData("visible", visibleItem)
  submenu:AddItem(visibleItem)
  local specFilters = {}
  if history[char] and history[char].spec then
    submenu:AddItem(self:GetDropdownSeperator())
    
    for specId in pairs(history[char]) do
      if type(tonumber(specId)) == "number" then
        local _, specName = GetSpecializationInfoByID(specId)
        local specOptions = AceGUI:Create("Dropdown-Item-Toggle")
        specOptions:SetText(specName)
        specOptions:SetUserData("spec", tonumber(specId))
        specOptions:SetUserData("char", char)
        specOptions:SetValue(history[char].spec == specId)
        specOptions:SetCallback("OnValueChanged", onSpecChanged)
        tinsert(specFilters, specOptions)
        submenu:AddItem(specOptions)
      end
    end
  end
  visibleItem:SetUserData("specFilters", specFilters)
end

function RequestBiS:ValidateFilters()
  for k,v in pairs(filter) do
    if not history[k] then
      filter[k] = nil
    end
  end
end

function RequestBiS:SetFilterOptions()
  dropdownFilter:SetList({})
  self:ValidateFilters()
  wipe(dropdownFilter:GetUserDataTable())
  self:MakeStandardOptions(dropdownFilter.pullout)
  local disabled = true
  local orderedList = {}
  for char in pairs(filter) do
    if not history[char] then
      filter[char] = nil
    else
      tinsert(orderedList, char)
    end
  end
  tsort(orderedList)
  for i,char in pairs(orderedList) do
    disabled = false
    local submenu = AceGUI:Create("Dropdown-Pullout")
    self:MakeCharSpecificOptions(submenu, char)
    
    local dropdownGroup = AceGUI:Create("Dropdown-Item-Menu")
    dropdownGroup:SetText(self:GetPlayerString(char))
    dropdownGroup:SetMenu(submenu)
    dropdownGroup.SetValue = emptySetValue
    
    dropdownFilter.pullout:AddItem(dropdownGroup)
    dropdownFilter:SetUserData(char, submenu)
  end
  dropdownFilter:SetDisabled(disabled)
  self:VerifyCheckBoxes()
end

function RequestBiS:FormatResponse(source, bisList)
  guildName = guildName or GetGuildInfo("player")
  if bisList.spec then
    local activeSpec = bisList.spec or self.db.factionrealm[guildName][source].activeSpec or bisList.spec
    history[source] = bisList
    filter[source] = filter[source] or {show = true, [activeSpec] = true}
    return bisList[bisList.spec], bisList.spec
  else
    self.console:AddError("Invalid data for registering responsecontainer. Is user using an outdated version of BestInSlot?", source, bisList)
  end
  return {}
end

function RequestBiS:DoRegister(source, bisList)
  local bisList, filteredSpec = self:FormatResponse(source, bisList)
  self:RegisterRaidTier(source, bisList, filteredSpec)
end

function RequestBiS:HasSpecsFilledIn(itemlist)
  for k,v in pairs(itemlist) do
    if k ~= "spec" then
      return true
    end
  end
  return false
end

---
-- Itemlist format: 
-- {
--  [specId1] = {{item = item1, obtained = false}, {item = item2, obtained = true}}
--  [specId2] = {{item = item1, obtained = false}, {item = item2, obtained = true}}
--  spec = CurrentSpec (used for the other client to define what to show)
-- }
---

local function hasEntries(tbl)
  for k,v in pairs(tbl) do
    return true
  end
  return false
end
local function requestRaidTierReply(itemlist, channel, source, version)
  RequestBiS:Print(itemlist)
  guildName = guildName or GetGuildInfo("player")
  for k,v in pairs(itemlist) do
    if k ~= "spec" then
      if not hasEntries(v) then
        itemlist[k] = nil
      end
    end
  end
  RequestBiS:Print(itemlist)
  if not itemlist or type(itemlist) ~= "table" then return end
  local selected = RequestBiS:GetSelected()
  if not responseContainer then return end
  if not RequestBiS:HasSpecsFilledIn(itemlist) then return end
  local responseChannel = responseContainer:GetUserData("channel")
  if responseChannel == "GUILD" then
    RequestBiS:SaveGuildBestInSlotList(guildName, source, itemlist, selected.raidtier, selected.difficulty, nil, version)
  elseif responseChannel == "WHISPER" then
    local list = RequestBiS:GetCacheData()
    if #list ~= 0 and list[source] and list[source].guild == guildName then
      RequestBiS:SaveGuildBestInSlotList(guildName, source, itemlist, selected.raidtier, selected.difficulty, nil, version)
    end
  end
  RequestBiS:Print(itemlist)
  RequestBiS:QueueRegister(source, itemlist)
end

RequestBiS:RegisterCommFunction("requestRaidTier", requestRaidTier)
RequestBiS:RegisterCommFunction("requestRaidInstance", requestRaidInstance)
RequestBiS:RegisterCommFunction("requestRaidTierReply", requestRaidTierReply)
RequestBiS:RegisterEvent("PLAYER_GUILD_UPDATE", function()
  if IsInGuild() then
    guildName = GetGuildInfo("player")
  else
    guildName = nil
  end
end)

RequestBiS:RegisterTutorials(L["Request BiS"], {
  [1] = {text = L["On this page you can request BestInSlot lists from your friends, guildmembers or raidmembers."], xOffset = 0, yOffset = -50, container = "content"},
  [2] = {text = (L["Use the '%s' dropdown to pick where you would like to request lists from."]):format(L["Request from"]), xOffset = 0, yOffset = -10, container = "content", element = "request", UpArrow = true},
  [3] = {text = L["When picking the whisper target, make sure you also fill in a recipient!"], xOffset = 0, yOffset = -10, container = "content", element = "wtarget", onRequest = true, UpArrow = true},
  [4] = {text = L["When you have successfully received BestInSlot lists you can use the filter to filter lists."], xOffset = 0, yOffset = -10, container = "content", element = "filter", onRequest = true, UpArrow = true}
})