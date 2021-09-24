--lua
local unpack, select, pairs, wipe, type, tContains, tinsert, tremove, tsort, tconcat
=     unpack, select, pairs, wipe, type, tContains, table.insert, table.remove, table.sort, table.concat

--WoW API
local GetGuildInfo, GuildControlSetRank, GuildControlGetRankFlags, GetUnitName, GetItemInfoFromHyperlink, SendChatMessage, GetInventorySlotInfo, GetSpecializationInfo, GetChannelList, EnumerateServerChannels, IsInGroup, IsInGuild, UnitInRaid
=     GetGuildInfo, GuildControlSetRank, GuildControlGetRankFlags, GetUnitName, GetItemInfoFromHyperlink, SendChatMessage, GetInventorySlotInfo, GetSpecializationInfo, GetChannelList, EnumerateServerChannels, IsInGroup, IsInGuild, UnitInRaid
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local Overview = BestInSlot:GetMenuPrototype(L["Overview"])
local selectedReport, selectedChannel
local dropdownDungeon, dropdownDifficulty, dropdownReport, dropdownFilter
local reportButton
local contentContainer
local hasContent
local requiredItems = {}
local processedItems
local bossLootGroups
local misc
local customitems
local specFilter
local showObtainedOnly = true

Overview.Width = 700
Overview.Height = 600

--TODO: GuildControlSetRank() protected function since 7.3. return put to false until workaround.
function Overview:IsOfficer()
  --local rank = select(3, GetGuildInfo("player"))
  --rank = rank + 1
  --GuildControlSetRank(rank)
  --local officer = select(3, GuildControlGetRankFlags())
  local officer = false
  return officer
end

local function tableSize(table)
  local size = 0
  for _ in pairs(table) do
    size = size + 1
  end
  if size == 0 then size = nil end
  return size
end

function Overview:ReportRequiredItems()
  local selectedDungeon = self:GetSelected(self.INSTANCE)
  local selectedDifficulty = self:GetSelected(self.DIFFICULTY)
  local playerName = GetUnitName("player")
  local notAcquiredItems = {}
  for i=1,#requiredItems do
    if #requiredItems[i] > 0 then
      for j=1,#requiredItems[i] do
        if not self:HasItem(requiredItems[i][j], selectedDifficulty) then
          if not notAcquiredItems[i] then
            notAcquiredItems[i] = {}
          end
          tinsert(notAcquiredItems[i], self:GetItem(GetItemInfoFromHyperlink(requiredItems[i][j]), id, selectedDifficulty).link)
        end
      end
    end
  end
  local str = {}
  for i,list in pairs(notAcquiredItems) do
    local bossName = self:GetDescription(self.BOSS, selectedDungeon, i)
    str[#str+1] = bossName
    for j=1,#list do
      if (#list[j] + #str[#str]) > 250 then
        str[#str + 1] = bossName..": "..list[j]
      else
        if j == 1 then
          str[#str] = str[#str]..": "..list[j]
        else
          str[#str] = str[#str].." & "..list[j]
        end
      end
    end
  end
  if not tableSize(notAcquiredItems) then
    SendChatMessage(
      (L["%1$s needs nothing from %2$s %3$s"]):format(
        playerName,
        self:GetDescription(self.INSTANCE, selectedDungeon),
        self:GetDifficulties(self.INSTANCE, selectedDungeon)[selectedDifficulty]
      ),
      selectedReport, nil, selectedChannel
    )
  else
    --local bislink = self:GetModule("BiSLink")
    local msg
    --if bislink:IsEnabled() then
    --  msg = bislink:GetShareLink(playerName, self.INSTANCE, selectedDungeon, selectedDifficulty, self:GetSelected(self.SPECIALIZATION))
    --else
      msg = (L["%1$s needs the following bosses from %2$s %3$s"]):format(
        playerName, 
        self:GetDescription(self.INSTANCE, selectedDungeon), 
        self:GetDifficulties(self.INSTANCE, selectedDungeon)[selectedDifficulty]
      )
    --end
    SendChatMessage(msg, selectedReport, nil, selectedChannel)
    for i=1,#str do
      SendChatMessage(str[i], selectedReport, nil, selectedChannel)
    end
  end
end

local function count(table)
  local counter = 0
  for _, v in pairs(table) do
    if v then
      counter = counter + 1
    end
  end
  return counter
end

function Overview:CheckSlotData(bisList, slotId, selectedDungeon, selectedRaidTier, selectedDifficulty, specName)
  if bisList[slotId] and type(bisList[slotId].item) == "number" then
    local id = bisList[slotId].item
    local hasItem = self:HasItem(id, selectedDifficulty, true)
    local hasItemOnHigherDifficulty = hasItem and hasItem > selectedDifficulty
    local item = self:GetItem(id)
    if not showObtainedOnly or not hasItem then
      if item then
        local bosses
        if item.multiplesources and item.multiplesources[selectedDungeon] then
          for bossid in pairs(item.multiplesources[selectedDungeon]) do
            bosses = bossid
            break
          end
        elseif item.dungeon == selectedDungeon then
          bosses = item.bossid
        end
        if bosses or item.misc or item.customitem then
          local label = processedItems[item.itemid] or self:GetItemLinkLabel(id, selectedDifficulty)
          local udt = label:GetUserDataTable()
          local specs = udt.specs or {}
          local firstLabel = #specs == 0
          if not tContains(specs, specName) then
            specs[#specs+1] = specName
          end
          udt.specs = specs
          label:SetFullWidth(true)
          label:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
          local text = item.link
          if count(specFilter) ~= 1 then
            text = ("%s (%s)"):format(text, tconcat(specs, "/"))
          end
          if hasItemOnHigherDifficulty then
            text = ("%s - %s"):format(text, (L["You have this item on '%s'"]):format(self:GetDescription(self.DIFFICULTY, selectedDungeon, hasItem)))
          elseif hasItem then
            text = ("%s - %s"):format(text, L["You have this item"])
          end
          label:SetText(text)
          if firstLabel then
            if bosses then
              local bossGroup = bossLootGroups[bosses]
              bossGroup:AddChild(label)
              tinsert(requiredItems[bosses], item.link)
            elseif item.misc then
              misc = misc or {}
              if not misc[item.misc] then misc[item.misc] = {} end
              tinsert(misc[item.misc], label)
            elseif item.customitem then
              customitems = customitems or {}
              tinsert(customitems, label)
            end
            processedItems[item.itemid] = label
          end
        end
      end
    end
  end
end

function Overview:UpdateContent()
  local selectedDungeon = self:GetSelected(self.INSTANCE)
  local selectedRaidTier = self:GetSelected(self.RAIDTIER)
  local selectedDifficulty = self:GetSelected(self.DIFFICULTY)
  wipe(requiredItems)
  contentContainer:ReleaseChildren()
  local bossList = self:GetInstanceBosses(selectedDungeon)
  local difficulties = self:GetDifficulties(self.INSTANCE, selectedDungeon)
  bossLootGroups = {}
  for i=1,#bossList do
    local bossGroup = AceGUI:Create("SimpleGroup")
    bossGroup:SetFullWidth(true)
    bossGroup:SetLayout("Flow")
    local label = AceGUI:Create("Heading")
    label:SetFullWidth(true)
    label:SetText(bossList[i])
    bossGroup:AddChild(label)
    tinsert(bossLootGroups, bossGroup)
    requiredItems[i] = {}
  end
  misc = nil
  customitems = nil
  local slots = self.slots
  local specs = self:GetCustomLists(self:GetAllSpecializations())
  processedItems = {}
  for specId, specName in pairs(specs) do
    local list = specId
    local bisList = self:GetOrderedBestInSlotItems(selectedRaidTier, selectedDifficulty, list)
    if type(specId) == "string" then
      specId = specName
      specName = list
    end
    if count(specFilter) == 0 or specFilter[list] then
      for i=1,#slots do
        local slotId = GetInventorySlotInfo(slots[i])
        self:CheckSlotData(bisList, slotId, selectedDungeon, selectedRaidTier, selectedDifficulty, specName)
      end
      if selectedRaidTier >= 70000 and selectedRaidTier < 80000 and self.Artifacts then
        local artifactBis = {self.Artifacts:GetBestInSlotRelics(selectedRaidTier, selectedDifficulty, specId)}
        local formattedList = {}
        for i=1,3 do
          formattedList[29 + i] = {item = artifactBis[i]}
        end
        for i=1,3 do
          self:CheckSlotData(formattedList, 29 + i, selectedDungeon, selectedRaidTier, selectedDifficulty, specName)
        end
      end
    end
  end
  for i=#bossLootGroups,1, -1 do
    if #bossLootGroups[i].children == 1 then --When it only has the boss label, thus no loot
      bossLootGroups[i]:Release()
      tremove(bossLootGroups, i)
    end
  end
  if #bossLootGroups == 0 and not misc then
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetFont(GameFontNormalSmall:GetFont(), 14, nil)
    label:SetText(
      "\n"..L["It looks like this instance does not drop any of your BestInSlot items."].."\n"..
      "\n"..L["It could also be that you haven't set the BestInSlot for this raid tier yet"].."\n"..
      "\n"..L["You can use the BiS Manager on the left to set your BestInSlot"]
    )
    hasContent = false
    reportButton:SetDisabled(true)
    contentContainer:AddChild(label)
  else
    hasContent = true
    if selectedReport then
      reportButton:SetDisabled(false)
    end
    for i=1,#bossLootGroups do
      contentContainer:AddChild(bossLootGroups[i])
    end
    if misc then
      for miscDesc, labels in pairs(misc) do
        local miscgroup = AceGUI:Create("SimpleGroup")    
        miscgroup:SetFullWidth(true)
        miscgroup:SetLayout("Flow")
        local header = AceGUI:Create("Heading")
        header:SetText(miscDesc)
        header:SetFullWidth(true)
        miscgroup:AddChild(header)
        for i=1,#labels do
          miscgroup:AddChild(labels[i])
        end
        contentContainer:AddChild(miscgroup)
      end
    end
    if customitems then
        local customItemGroup = AceGUI:Create("SimpleGroup")    
        customItemGroup:SetFullWidth(true)
        customItemGroup:SetLayout("Flow")
        local header = AceGUI:Create("Heading")
        header:SetText(L["Custom Items"])
        header:SetFullWidth(true)
        customItemGroup:AddChild(header)
        for i=1,#customitems do
          customItemGroup:AddChild(customitems[i])
        end
        contentContainer:AddChild(customItemGroup)
    end
    self:ShowTutorial(L["Overview"], 1)
  end
end

local function dropdownDungeonOnValueChanged(widget,_,value)
  local selectedDungeon = value
  Overview:UpdateContent()
end

local function dropdownDifficultyOnValueChanged(_,_,value)
  Overview:SetSelected(Overview.DIFFICULTY, value)
  local raidTier = Overview:GetSelected(Overview.RAIDTIER)
  Overview:UpdateContent()
end

local function dropdownFilterOnValueChanged(widget,event, spec, value)
  if spec ~= 'obtainedOnly' then
    specFilter[spec] = value
  else
    showObtainedOnly = value
  end
  Overview:UpdateContent()
end

local function packChannels(...)
  local channels = {...}
  local result = {}
  for i=1,#channels do
    local id = channels[i]
    i = i + 1
    local name = channels[i]
    result[i] = name
  end
  return result
end

local function packGlobalChannels(...)
  return {...}
end

function Overview:Draw(container)
  container:PauseLayout()
  
  specFilter = self.db.char.options.overviewfilter
  
  dropdownDungeon = self:GetDropdown(self.INSTANCE, nil, dropdownDungeonOnValueChanged)
  dropdownDungeon:SetPoint("TOPLEFT", container.frame, "TOPLEFT", 10, -10)
  container:AddChild(dropdownDungeon)
  
  dropdownDifficulty = self:GetDropdown(self.DIFFICULTY, nil, dropdownDifficultyOnValueChanged)
  dropdownDifficulty:SetPoint("TOPLEFT", dropdownDungeon.frame, "TOPRIGHT")
  dropdownDifficulty:SetWidth(120)
  
  dropdownDifficulty:SetCallback("OnValueChanged", dropdownDifficultyOnValueChanged)
  
  container:AddChild(dropdownDifficulty)
  dropdownFilter = AceGUI:Create("Dropdown")
  dropdownFilter:SetList({})  
  local specs = self:GetAllSpecializations()
  local customLists, hasCustomLists = self:GetCustomLists()
  if hasCustomLists then
    dropdownFilter:AddItem("header1", L["Specialization"])
    dropdownFilter:SetItemDisabled("header1")
  end
  for k,v in pairs(specs) do
    dropdownFilter:AddItem(k,v)
  end
  if hasCustomLists then
    dropdownFilter:AddItem("spacer3", "")
    dropdownFilter:AddItem("header2", L["Custom Lists"])
    dropdownFilter:SetItemDisabled("spacer3", true)
    dropdownFilter:SetItemDisabled("header2", true)
    for k,v in pairs(customLists) do
      dropdownFilter:AddItem(k, k)
    end
  end
  dropdownFilter:AddItem("spacer", "")
  dropdownFilter:AddItem("obtainedOnly", L["Only show missing items"])
  dropdownFilter:AddItem("spacer2", "")
  dropdownFilter:SetItemDisabled("spacer", true)
  dropdownFilter:SetItemDisabled("spacer2", true)
    
  dropdownFilter:SetMultiselect(true)
  dropdownFilter:SetItemValue('obtainedOnly', showObtainedOnly)
  dropdownFilter:SetItemDisabled('spacer', true)
  dropdownFilter:SetItemDisabled('spacer2', true)
  if hasCustomLists then
    dropdownFilter:SetItemDisabled("header1", true)
    dropdownFilter:SetItemDisabled("header2", true)
    dropdownFilter:SetItemDisabled("spacer3", true)
  end
  if count(specFilter) == 0 then
    local filter = GetSpecializationInfo(self:GetSpecialization())
    dropdownFilter:SetItemValue(filter, true)
    specFilter[filter] = true
  else
    for specId in pairs(specFilter) do
      if specFilter[specId] then
        dropdownFilter:SetItemValue(specId, true)
      end
    end
  end
  dropdownFilter:SetLabel(FILTER) -- Blizzard global string
  dropdownFilter:SetPoint("TOPLEFT", dropdownDifficulty.frame, "TOPRIGHT")
  dropdownFilter:SetPoint("TOPRIGHT", container.frame, "TOPRIGHT", -10, -10)
  dropdownFilter:SetCallback("OnValueChanged", dropdownFilterOnValueChanged)
  
  container:AddChild(dropdownFilter)
  container:SetUserData("filter", dropdownFilter)
  
  contentContainer = AceGUI:Create("ScrollFrame")
  contentContainer:SetPoint("TOPLEFT", dropdownDungeon.frame, "BOTTOMLEFT")
  contentContainer:SetPoint("BOTTOMRIGHT", container.frame, "BOTTOMRIGHT", -10, 50)
  contentContainer:SetLayout("List")
  
  container:AddChild(contentContainer)
  dropdownReport = AceGUI:Create("Dropdown")
  dropdownReport:SetPoint("TOPLEFT", contentContainer.frame, "BOTTOMLEFT")
  dropdownReport:SetLabel(L["Report your BestInSlot to:"])
  dropdownReport:SetText(L["Select an option"])
  local dropdownList = {
    SAY = _G["SAY"],
    PARTY = _G["PARTY"],
    GUILD = _G["GUILD"],
    OFFICER = _G["OFFICER"],
    RAID = _G["RAID"],
    INSTANCE_CHAT = _G["INSTANCE_CHAT"]
  }
  dropdownReport:SetList(dropdownList)
  local channels = packChannels(GetChannelList())
  local globalchannels = packGlobalChannels(EnumerateServerChannels())
  for i=1,#channels / 2 do
    local id = channels[(i * 2) - 1]
    local name = channels[i * 2]
    if id and name and not tContains(globalchannels, name) then
      dropdownReport:AddItem("channel"..id, name)
    end
  end
  if not IsInGroup() then
    dropdownReport:SetItemDisabled("PARTY", true)
  end
  if not IsInGuild() then
    dropdownReport:SetItemDisabled("GUILD", true)
    dropdownReport:SetItemDisabled("OFFICER", true)
  elseif not self:IsOfficer() then
    dropdownReport:SetItemDisabled("OFFICER", true)
  end
  if not UnitInRaid("player") then
    dropdownReport:SetItemDisabled("RAID", true)
  end
  if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
    dropdownReport:SetItemDisabled("INSTANCE_CHAT", true)
  end
  if selectedReport then
    dropdownReport:SetValue(selectedReport)
  end
  dropdownReport:SetCallback("OnValueChanged", function(_,_, value)
    if value:find("channel") then
      selectedReport = "CHANNEL"
      selectedChannel = value:sub(8)
    else
      selectedReport = value
      selectedChannel = nil
    end
    if hasContent then
      reportButton:SetDisabled(false)
    end
  end)
  container:SetUserData("report", dropdownReport)
  container:AddChild(dropdownReport)
  
  reportButton = AceGUI:Create("Button")
  reportButton:SetText(L["Report BestInSlot"])
  reportButton:SetDisabled(selectedReport == nil)
  reportButton:SetPoint("BOTTOMLEFT", dropdownReport.frame, "BOTTOMRIGHT")
  reportButton:SetCallback("OnClick", function() Overview:ReportRequiredItems() end)
  
  container:AddChild(reportButton)
  local raidTier = self:GetSelected(self.RAIDTIER)
  Overview:UpdateContent()
end

function Overview:Close()
  dropdownDungeon, dropdownDifficulty, dropdownReport, dropdownFilter = nil
  reportButton = nil
  contentContainer = nil
  hasContent = nil
  wipe(requiredItems)
end

Overview:RegisterTutorials(L["Overview"], {
  [1] = {text = L["On this page you can overview your BestInSlot list per instance."], xOffset = 0, yOffset = -50, container = "content", onRequest = true},
  [2] = {text = L["The filter is set to only show the items you have not obtained yet. You can also make multiple specializations appear here."], xOffset = 0, yOffset = -25, container = "content", element = "filter", UpArrow = true},
  [3] = {text = L["If you want to share your BestInSlot list, you can report it here."], text2 = L["Note: This could send a long list of items depending on the amount of items you still need, and might be considered spam."], xOffset = 0, yOffset = 25, container = "content", element = "report", DownArrow = true}
})