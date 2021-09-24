--lua
local unpack, select, error, date, time, pairs, tremove
=     unpack, select, error, date, time, pairs, table.remove
--wow api
local GameTime_GetFormattedTime
=     GameTime_GetFormattedTime
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local History = BestInSlot:NewModule("History")
local HistoryFrame = BestInSlot:GetMenuPrototype("_history")
HistoryFrame.Width = 800
HistoryFrame.Height = 600
History.NEWLIST = 1
History.MODIFIEDITEM = 2
History.errorchecking = {
  [History.NEWLIST] = function(data) return data.raidtier and data.difficulty and data.spec and true end,
  [History.MODIFIEDITEM] = function(data) return data.raidtier and data.difficulty and data.slot and (data.previtem or data.newitem)  and true end
}

local function createHistoryObject(data)
  if data.time then error("You cannot set the time element yourself. This must be done by the createHistoryObject. Please use a differerent variable to save your data in.") end
  data.time = time()
  return data
end

function History:OnInitialize()
  BestInSlot.History = self
  self.db = BestInSlot.db.factionrealm._history
  self.options = BestInSlot.db.char.options
  self.menuid = HistoryFrame.menuindex
end

function History:OnEnable()
  local currentTime = time()
  local number, timespan = (self.options.historyLength):match("(%d+)(%a)")
  if not number or not timespan then return end
  if timespan == "d" then
    number = number * 86400
  elseif timespan == "h" then
    number = number * 3600
  end
  local deleteTime = currentTime - number
  for character,charHistory in pairs(self.db) do
    local deleteIndex = -1
    for i=1,#charHistory do
      if charHistory[i].time < deleteTime then
        deleteIndex = i
      else
        break
      end
    end
    if deleteIndex ~= -1 then
      for i=1,deleteIndex do
        tremove(charHistory, 1)
      end
    end
  end
end

function History:HasHistory(player, raidtier, difficulty, spec)
  if self.db[player] and #self.db[player] > 0 then
    for i=1,#self.db[player] do
      local historyitem = self.db[player][i]
      if historyitem.raidtier and historyitem.difficulty and historyitem.raidtier == raidtier and historyitem.difficulty == difficulty and historyitem.spec == spec then
        return true
      end
    end
  end
  return false
end

local function getDateString(time)
  local adate = date("*t", time)
  return (SHORTDATE):format(adate.day, adate.month, adate.year).." "..GameTime_GetFormattedTime(adate.hour, adate.min)
end

local function newListStringConstructor(obj, character)
  return ("%s - %s"):format(
    getDateString(obj.time), 
    L["Created BestInSlot list"]
  )
end

local function modifiedItemStringConstructor(obj, character, label)
  local previtem = History:GetItem(obj.previtem, obj.difficulty)
  local newitem = History:GetItem(obj.newitem, obj.difficulty)
  if previtem or newitem then
    label:SetUserData("itemid", obj.previtem or obj.newitem)
    label:SetUserData("difficulty", obj.difficulty)
    return ("%s - %s"):format(
      getDateString(obj.time),
      L["Modified the %s slot. Previous item: %s, new item: %s"]:format(
        _G[previtem and previtem.equipSlot or newitem and newitem.equipSlot or "UNKNOWN"],
        previtem and previtem.link or NONE,
        newitem and newitem.link or NONE
      )
    )
  else
    return ("%s - %s"):format(
      getDateString(obj.time),
      L["Modified the %s slot. Previous item: %s"]:format(
        History.slots[obj.slot],
        UNKNOWN
      )
    )
  end
end

local historyStringConstructors = {
  [History.NEWLIST] = newListStringConstructor,
  [History.MODIFIEDITEM] = modifiedItemStringConstructor
}

function History:GetHistoryLabel(historyObj, character, label)
  local label = self:GetItemLinkLabel("PLACEHOLDER", nil, false)
  label:SetFullWidth(true)
  if historyStringConstructors[historyObj.type] then
    label:SetText(historyStringConstructors[historyObj.type](historyObj, character, label))
  end
  return label
end

function History:GetHistoryByRaidTier(player)
  local history = self:GetHistoryForPlayer(player)
  local orderedHistory = {}
  for i=1,#history do
    local item = history[i]
    if item.raidtier and item.difficulty then
      local raidtier = orderedHistory[item.raidtier]
      if not raidtier then
        raidtier = {}
        orderedHistory[item.raidtier] = raidtier
      end
      local difficulty = raidtier[item.difficulty]
      if not difficulty then
        difficulty = {}
        raidtier[item.difficulty] = difficulty
      end
      difficulty[#difficulty+1] = item
    end
  end
  return orderedHistory
end

function History:GetHistoryForPlayer(player)
  return self.db[player]
end

function History:GetLatestRecord(player, raidtier, difficulty, slot)
  if not self.db[player] then return end
  local playerdb = self.db[player]
  if not raidtier then return playerdb[#playerdb] end
  for i=#playerdb, 1, -1 do
    local item = self.db[player][i]
    if raidtier == item.raidtier and not difficulty or difficulty == item.difficulty and not slot or slot == item.slot then
      return item
    end
  end
end

function History:Add(player, data, addType)
  local obj = createHistoryObject(data)
  self.db[player].lastUpdate = time()
  if not self.options.keepHistory then return end
  local historydb = self.db[player]
  addType = addType or self.MODIFIEDITEM
  data.type = addType
  if self.errorchecking[addType] and self.errorchecking[addType](data) then
    historydb[#historydb+1] = obj
  end
end

function HistoryFrame:Draw(container, character)
  if not character then
    self:SetMenu(1)
    return
  end
  container:SetLayout("Fill")
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  heading:SetText(L["History for %s"]:format(character))
  scroll:AddChild(heading)
  for raidtier, difficulties in pairs(History:GetHistoryByRaidTier(character)) do
    for difficulty, history in pairs(difficulties) do
      local heading = AceGUI:Create("Heading")
      heading:SetFullWidth(true)
      heading:SetText(("%s %s"):format(self:GetDescription(self.RAIDTIER, raidtier), self:GetDescription(self.DIFFICULTY, raidtier, difficulty)))
      scroll:AddChild(heading)
      for i=1,#history do
        scroll:AddChild(History:GetHistoryLabel(history[i], character))
      end
    end
  end
  container:AddChild(scroll)
end

function History:DeleteAllHistory()
  StaticPopup_Show("BIS_CONFIRM_DELETE_HISTORY")
end

StaticPopupDialogs.BIS_CONFIRM_DELETE_HISTORY = {
  text = L["Are you sure you want to delete ALL history?"],
  button1 = YES,
  button2 = NO,
  OnAccept = function()
    History.db = {}
  end,
  whileDead = false,
  hideOnEscape = true,
  preferredIndex = 3,
}

function HistoryFrame:IsShown()
  return false
end