local unpack, select, pairs, type, tostring =
      unpack, select, pairs, type, tostring
local GetLocale, UnitClass, UnitRace, GetAddOnMetadata, UnitLevel, GetSpecializationInfo, GetSpecialization =
      GetLocale, UnitClass, UnitRace, GetAddOnMetadata, UnitLevel, GetSpecializationInfo, GetSpecialization
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local Reporting = BestInSlot:GetMenuPrototype(L["Bugs and recommendations"])
Reporting.Width = 700
Reporting.Height = 600

local reportTypes ={
  BUG = HELPFRAME_REPORT_BUG_TITLE,
  MISSINGITEM = L["Submit Missing item"],
  SUGGESTION = HELPFRAME_SUBMIT_SUGGESTION_TITLE
}


function Reporting:Close()
  self.panel = nil
  self.bug = nil
  self.bug_error = nil
  self.missing_itemid = nil
  self.missing_instance = nil
  self.missing_slot = nil
  self.missing_additional = nil
  self.suggestion = nil
end

function Reporting:CreateReport(reportType, text)
  local window = self:QuickCreate("Window")
  window:AddChild(self:CreateUneditableTextbox("https://github.com/anhility/BestInSlotRedux/issues/", L["Please navigate to the issue tracker."] .. " " .. (L["Please select the type: %s"]):format(reportType)))
  --self:QuickCreate("Label", {SetText = (L["Please select the type: %s"]):format(reportType)}, window)
  local editbox = self:CreateUneditableTextbox(text, L["Copy paste underlying information in the description field."], "MultiLineEditBox")
  editbox:SetNumLines(20)
  window:AddChild(editbox)
end

local function onButtonClick(btn)
  local type = btn:GetUserData("type")
  local panel = Reporting.panel
  if panel then panel:ReleaseChildren() end
  if type == "BUG" then
    Reporting:DrawBugSection(panel)
  elseif type == "MISSINGITEM" then
    Reporting:DrawMissingItemSection(panel)
  elseif type == "SUGGESTION" then
    Reporting:DrawSuggestionSection(panel)
  end
end

local function renderBugSectionDump()
  local bug = Reporting.bug:GetText()
  local error = Reporting.bug_error:GetText()
  local selected = Reporting:GetSelected()
  local stringifiedDB = ""
  local args = {
    bug, --1 The report
    select(2, UnitClass("player")), --2 the class of the player
    select(2, UnitRace("player")), --3 the race of the player
    GetLocale(), --4 the locale of the player
    GetAddOnMetadata("BestInSlotRedux", "Version"), --5 the version the player is using
    Reporting:GetActiveModules(), --6 the active modules
    GetSpecializationInfo(GetSpecialization()), --7 Active specialization
    selected.expansion, -- 8 Selected expansion
    selected.raidtier, -- 9 Selected raid tier
    selected.instance, -- 10 Selected instance
    selected.difficulty, --11 Selected difficulty
    selected.specialization, --12 Selected specialization
    Reporting:GetCustomItems(), --13 the custom items
    UnitLevel("player"), --14 The player level,
    Reporting:GetPlayerOptions(), -- 15 the player options
    error, --16 the LUA error pasted by the user
    Reporting:GetConsoleErrors(), --17 the console errors
  }
  for i=1,#args do
    args[i] = tostring(args[i])
  end
  Reporting:CreateReport("Defect",
([[Bug Report:
Description
%1$s

Player class:
%2$s

Player race:
%3$s

Player level:
%14$s

Player specialization
%7$s

Player locale:
%4$s

BestInSlot Version:
%5$s

BestInSlot Selected information:
Expansion: %8$s
Raid Tier: %9$s
Instance: %10$s
Difficulty: %11$s
Specialization: %12$s
 

Active modules:
%6$s

Custom items:
%13$s

Character options:
%15$s

Console errors:
%17$s

LUA error:
%16$s

]]):format(unpack(args)))
end

function Reporting:DrawBugSection(panel)
  self.bug = self:QuickCreate("MultiLineEditBox", {SetNumLines = 10, SetLabel = L["Describe what you were doing when the bug occured"], SetFullWidth = true}, panel)
  self.bug_error = self:QuickCreate("MultiLineEditBox", {SetNumLines = 10, SetLabel = L["Paste any LUA errors in this field"], SetFullWidth = true}, panel)
  self:QuickCreate("Button", {SetFullWidth = true, SetText = SUBMIT, SetCallback = {"OnClick", renderBugSectionDump}}, panel)
end

function Reporting:GetActiveModules()
  local modules = ""
  for k, v in pairs(BestInSlot.modules) do
    modules = ("%s- %s (%s)\r\n"):format(modules, k, v:IsEnabled() and "Loaded" or "Not loaded")
  end
  return modules
end

function Reporting:GetCustomItems()
  local customItems = ""
  local count = 0
  for dung, list in pairs(BestInSlot:GetCustomItems()) do
    count = count + #list
    for i=1,#list do
      if i == 1 then
        customItems = ("%s%s\r\n"):format(customItems, dung)
      end
      customItems = ("%s%s\r\n"):format(customItems, tostring(list[i]))
    end
  end
  return count > 0 and customItems or "No custom items"
end

local formats
formats = {
  string = function(str) return ("\"%s\""):format(str) end,
  number = function(str) return ("%d"):format(str) end,
  table = function(tbl, depth)
    local str = "{\r\n"
    depth = depth or 0
    local indent = (depth + 1) * 2
    for k, v in pairs(tbl) do
      str = ("%s%s[%s] = %s,\r\n"):format(str,(" "):rep(indent), k, formats[type(v)](v, depth + 1))
    end
    return str .. (" "):rep(depth * 2) .. "}"
  end,
  ["nil"] = function() return "nil" end,
  ["function"] = function(str) return tostring(str) end,
  boolean = function(bool) return tostring(bool) end,
  userdata = function(ud) return tostring(ud) end
}

function Reporting:GetPlayerOptions()
  return formats.table(BestInSlot.db.char.options)
end


function Reporting:GetConsoleErrors()
  local errors = self.console:GetErrors()
  if #errors == 0 then
    return "There are no errors"
  else
    local str = ""
    for i=1,#errors do
      local error = errors[i]
      str = ("%sError %d: %s\r\n"):format(str, i, error.descr)
      for j=1,#error.param do
        local param = error.param[j]
        str = ("%s  Parameter %d:%s\r\n"):format(str, j, formats[type(param)](param, 2))
      end
    end
    return str
  end
end

local function renderMissingSectionDump()
  local itemid = Reporting.missing_itemid:GetText()
  local instance = Reporting.missing_instance:GetText()
  local slot = Reporting.missing_slot:GetText()
  local additional = Reporting.missing_additional:GetText()
  Reporting:CreateReport("Patch",
([[Missing Item Report
ItemID:
%s

Dungeon Information: 
%s

Slot and information: 
%s

Additional Information: 
%s]]):format(itemid, instance, slot, additional))
end

function Reporting:DrawMissingItemSection(panel)
  self.missing_itemid = self:QuickCreate("EditBox", {SetLabel = L["What is the item ID for the item you miss in BestInSlot?"], SetFullWidth = true}, panel)
  self.missing_instance = self:QuickCreate("EditBox", {SetLabel = L["Should this item be added to an instance? If so which one, and which boss."], SetFullWidth = true}, panel)
  self.missing_slot = self:QuickCreate("EditBox", {SetLabel = L["Is the item missing for a particular class or slot? If so, which one."], SetFullWidth = true}, panel)
  self.missing_additional = self:QuickCreate("MultiLineEditBox", {SetNumLines = 10, SetLabel = L["Additional Information"], SetFullWidth = true}, panel)
  self:QuickCreate("Button", {SetFullWidth = true, SetText = SUBMIT, SetCallback = {"OnClick", renderMissingSectionDump}}, panel)
end

local function renderSuggestionSectionDump()
  local suggestion = Reporting.suggestion:GetText()
  Reporting:CreateReport("Enhancement",
([[Suggestion Report:
%s
]]):format(suggestion))
end

function Reporting:DrawSuggestionSection(panel)
  self.suggestion = self:QuickCreate("MultiLineEditBox", {SetNumLines = 10, SetLabel = L["Describe what you would like to see implemented"], SetFullWidth = true}, panel)
  self:QuickCreate("Button", {SetFullWidth = true, SetText = SUBMIT, SetCallback = {"OnClick", renderSuggestionSectionDump}}, panel)
end

function Reporting:Draw(container)
  local settings = {
    SetFullWidth = true,
    SetCallback = {"OnClick", onButtonClick},
    SetUserData = {"type"}
  }
  container:AddChild(self:QuickCreate("Heading",{SetText = L["Bugs and recommendations"]    , SetFullWidth = true, SetCallback = {"OnClick", }}))
  for k,v in pairs(reportTypes) do
    settings.SetText = v
    settings.SetUserData[2] = k
    container:AddChild(self:QuickCreate("Button", settings))
  end
  local group = self:QuickCreate("SimpleGroup", {SetFullWidth = true})
  self:QuickCreate("Label", {SetText = L["Please choose what you would like to submit"] , SetFullWidth = true}, group)
  container:AddChild(group)
  self.panel = group
end

local function onSlashCommand()
  --we assume that when users use this way of getting to the frame, they can't access the main frame, so we make a new one
  local frame = AceGUI:Create("Frame")
  frame:SetWidth(Reporting.Width)
  frame.frame:SetFrameStrata("HIGH")
  frame:SetHeight(Reporting.Height)
  frame:SetCallback("OnClose", function(widget) widget.frame:SetFrameStrata("FULLSCREEN_DIALOG") widget:Release() end)
  frame:SetTitle("BestInSlot " .. L["Bugs and recommendations"])
  frame:SetStatusText(L["This window is intended for when the normal BestInSlot window won't open!"])
  frame:EnableResize(false)
  Reporting:Draw(frame)
end

BestInSlot:RegisterSlashCmd("bug", (L["%s - Shows the report bug window"]):format("/bis bug"), onSlashCommand)