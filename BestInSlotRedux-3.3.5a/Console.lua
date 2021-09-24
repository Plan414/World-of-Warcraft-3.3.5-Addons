--lua function
local unpack, select, type, tostring, print, tonumber, pairs, error, tinsert, tremove
=     unpack, select, type, tostring, print, tonumber, pairs, error, table.insert, table.remove
--WoW API
local LoadAddOn, UnitAffectingCombat
=     LoadAddOn, UnitAffectingCombat
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local MAXHISTORY = 250
local MAXTOOLTIPARRAY = 5
local BestInSlotConsole = {}
local history = {}
local window
local cleanupTimer

local DevTools_Dump
DevTools_Dump = function(value)
  if not _G.DevTools_Dump then
    LoadAddOn("Blizzard_DebugTools")
  end
  DevTools_Dump = _G.DevTools_Dump
  DevTools_Dump(value)
end

--- Used to print BestInslot info
--@param #multiple str Something to be printed, if it's a string, nil, or a number, it will simply print out it's value. Otherwise it will call Blizzard's DevTools_Dump to dump the value
--@param #boolean overrideDebug Override the debug setting, if not set, it'll hide this message if the debug setting is disabled
--@param #boolean second Defines wether this message was part of a previous message.
function BestInSlot.Print(module, str, overrideDebug, second)
  if BestInSlot.options.DEBUG or overrideDebug then
    local normalColor = module.colorNormal
    local colorHighlight = module.colorHighlight
    local textFormatSize = 40
    local maxSize = 255
    local name = module.Description and "BestInSlotRedux "..module.Description or module.name or "BestInSlotRedux"
    if type(str) == "string" or type(str) == "number" or type(str) == "nil" then
      str = tostring(str)
      if (#str + textFormatSize) > maxSize then
        local printString
        if not second then
          printString = ("%s%s: %s%s..|r"):format(colorHighlight, name, normalColor, (str):sub(1,maxSize-textFormatSize))
        else
          printString = ("%s%s: %s..%s..|r"):format(colorHighlight, name, normalColor, (str):sub(1,maxSize-textFormatSize))
        end
        DEFAULT_CHAT_FRAME:AddMessage(printString)
        module:Print((str):sub(maxSize - textFormatSize), overrideDebug, true)
      else
        if second then
          DEFAULT_CHAT_FRAME:AddMessage(("%s%s: %s..%s|r"):format(colorHighlight, name, normalColor, str))
        else
          DEFAULT_CHAT_FRAME:AddMessage(("%s%s: %s%s|r"):format(colorHighlight, name, normalColor, str))
        end
      end
    else
      DEFAULT_CHAT_FRAME:AddMessage(("%s%s: %sDump of %s:|r"):format(BestInSlot.colorHighlight, name, BestInSlot.colorNormal, type(str)))
      DevTools_Dump(str)
    end
  end
end

local function addNewItem(data)
  data.hour = tonumber(date("%H"))
  data.minute = tonumber(date("%M"))
  data.second = tonumber(date("%S"))
  tinsert(history, data)
  while #history > MAXHISTORY do
    tremove(history, 1) -- remove oldes
  end
  if window then
    local scroll = window:GetUserData("scroll")
    local scrollDown = scroll.scrollbar:GetValue() >= 1000 or not scroll.scrollbar:IsVisible()
    local label = BestInSlotConsole:GetLabel(data)
    scroll:AddChild(label)
    if scrollDown then
      scroll:SetScroll(1000)
    end
  end
  if not cleanupTimer then
    cleanupTimer = BestInSlot:ScheduleRepeatingTimer(BestInSlotConsole.Cleanup, 150)
  end
end
--- Adds item to the BestInSlot console. This function will only work when DEBUG is enabled in the options
-- @param #string descr Any description which will be shown in the main window of the console
-- @param #any ... Any other parameters will be dumped in the OnHover tooltip
function BestInSlotConsole:Add(descr, ...)
  if not BestInSlot.options.DEBUG then return end
  local data = {
    descr = descr, 
    param = {...},
  }
  addNewItem(data)
end

--- Adds item to the BestInSlot console as an error. Erros won't be cleaned up and are shown in red
-- @param #string descr Any description which will be shown in the main window of the console
-- @param #any ... Any other parameters will be dumped in the OnHover tooltip
function BestInSlotConsole:AddError(descr, ...)
  local data = {
    descr = descr,
    param = {...},
    error = true,
  }
  addNewItem(data)
end
--- Will get called by a timer to cleanup history data to free up memory.
function BestInSlotConsole:Cleanup()
  if UnitAffectingCombat("player") then
    BestInSlot:ScheduleTimer(BestInSlotConsole.Cleanup, 60) --delay the cleanup when in combat
    return
  end
  local currentTime = tonumber(date("%H")) * 60 + tonumber(date("%M")) --currentTime in amount of minutes from 00:00
  for i=#history, 1, -1 do
    if not history[i].error then --Don't clean up errors
      local time = history[i].hour * 60 + history[i].minute
      local timeSince = ((currentTime - time + 1440) % 1440)
      if timeSince >= 15 then
        tremove(history, i)
      end
    end
  end
  if #history == 0 or BestInSlotConsole:HasOnlyErrors() then
    BestInSlot:CancelTimer(cleanupTimer)
    cleanupTimer = nil
  end
end

--- Checks if the console contains only errors
-- @return #boolean True if it only contains errors, otherwise false
function BestInSlotConsole:HasOnlyErrors()
  for i=1,#history do
    if not history[i].error then
      return false
    end
  end
  return true
end

local function OnEvent(event, ...)
  BestInSlotConsole:Add(event, ...)
end

function BestInSlotConsole:EnableConsole()
  BestInSlot:RegisterEvent("*", OnEvent)
  self:Add("Enabled console")
end

function BestInSlotConsole:DisableConsole()
  BestInSlot:UnregisterEvent("*", OnEvent)
  self:Add("Disabled console")
end

function BestInSlotConsole:GetErrors()
  local errors = {}
  for i=1,#history do
    if history[i].error then
      tinsert(errors, history[i])
    end
  end
  return errors
end

local function windowOnClose()
  window:Release()
  window = nil
end

local function getLastIndex(table)
  local last = 0
  for i,v in pairs(table) do
    if type(i) == "string" then error("Can only use this function with number indexes!") end
    if i > last then
      last = i
    end
  end
  return last
end

local function tableSize(table)
  local size = 0
  for _ in pairs(table) do
    size = size + 1
  end
  return size
end

local function helperDumpTable(table, GameTooltip, indent)
  indent = indent or 2
  if indent > 6 then return end
  local size = tableSize(table)
  local counter = 0
  local indentString = (" "):rep(indent)
  if indent == 2 then
    GameTooltip:AddLine("{")
  end
  for k,v in pairs(table) do
    counter = counter + 1
    if type(v) == "table" then
      GameTooltip:AddLine(indentString.."["..tostring(k).."] = {")
      helperDumpTable(v, GameTooltip, indent + 2)
      GameTooltip:AddLine(indentString.."},")
    else
      GameTooltip:AddLine(indentString.."["..tostring(k).."] = "..tostring(v)..",")
    end
  end
  if indent == 2 then
    GameTooltip:AddLine("}")
  end
end

local function Label_OnEnter(label)
  local data = label:GetUserData("param")
  GameTooltip:SetOwner(window.frame)
  GameTooltip:SetAnchorType("ANCHOR_NONE")
  GameTooltip:SetPoint("TOPLEFT", window.frame, "TOPRIGHT")
  GameTooltip:AddLine(("%s (%s):"):format(data.descr, BestInSlotConsole:GetTimeString(data)))
  if getLastIndex(data.param) == 0 then
    GameTooltip:AddLine("No extra parameters given")
  else
    local first = true
    for i=1, getLastIndex(data.param) do
      local param = data.param[i]
      if not first then
        GameTooltip:AddLine(" ")
      end
      local paramType
      if type(param) == "table" then
        paramType = tostring(param)
      else
        paramType = type(param)
      end
      GameTooltip:AddLine(("%sParameter %d (%s):|r"):format(BestInSlot.colorHighlight, i, paramType))
      if type(param) == "table" then
        helperDumpTable(param, GameTooltip)
      else
        GameTooltip:AddLine(tostring(param))
      end
      first = false
    end  
  end
  GameTooltip:Show()
end

local function Label_OnLeave(Label)
  if GameTooltip:IsShown() then
    GameTooltip:Hide()
  end
end

function BestInSlotConsole:GetTimeString(data)
  return ("%02d:%02d:%02d"):format(data.hour, data.minute, data.second)
end

function BestInSlotConsole:GetLabel(data)
  local label = AceGUI:Create("InteractiveLabel")
  local text = ("%s - %s"):format(self:GetTimeString(data), data.descr)
  if data.error then
    text = BestInSlot.colorHighlight..text.."|r"
  end
  label:SetText(text)
  label:SetFullWidth(true)
  label:SetUserData("param", data)
  label:SetCallback("OnEnter", Label_OnEnter)
  label:SetCallback("OnLeave", Label_OnLeave)
  label:SetHighlight("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
  return label
end

function BestInSlotConsole:ShowWindow()
  if window then return end
  window = AceGUI:Create("Window")
  window:SetLayout("Fill")
  window:SetWidth(400)
  window:SetPoint("TOPRIGHT", -300, -200)
  window:EnableResize(nil)
  window:SetTitle("Best In Slot Console")
  window:SetCallback("OnClose", windowOnClose)
  
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  scroll:SetLayout("List")
  
  window:AddChild(scroll)
  window:SetUserData("scroll", scroll)
  for i=1,#history do
    local widget = self:GetLabel(history[i])
    scroll:AddChild(widget)
    scroll:DoLayout()
  end
  BestInSlot:ScheduleTimer(function()
    if scroll.scrollbar:IsVisible() then
      scroll:SetScroll(1000)
    end
  end, 0.1)
end

local function onSlashCommand()
  BestInSlotConsole:ShowWindow()
end

if BestInSlot.options.DEBUG then
  BestInSlotConsole:EnableConsole()
end

BestInSlot:RegisterEvent("DebugOptionsChanged", function(event, debug)
  if debug then
    BestInSlotConsole:EnableConsole()
  else
    BestInSlotConsole:DisableConsole()
  end
end)

BestInSlot:RegisterSlashCmd("console", (L["%s - Shows a debugging console"]):format("/bis console"), onSlashCommand)

BestInSlot.console = BestInSlotConsole