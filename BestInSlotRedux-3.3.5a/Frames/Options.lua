--lua
local unpack, select, tonumber, pairs, max
=     unpack, select, tonumber, pairs, math.max
-- WoW API
local IsInGuild, GuildControlGetNumRanks, GuildControlGetRankName
=     IsInGuild, GuildControlGetNumRanks, GuildControlGetRankName

local BestInSlot, L, AceGUI = unpack(select(2, ...))
local Options = BestInSlot:GetMenuPrototype(L["Options"])
local dropdownGuildRanks
Options.Width = 700
Options.Height = 600

function Options:Close()
  dropdownGuildRanks = nil
end

function Options:CreateOptionHeading(str)
  local header = AceGUI:Create("Heading")
  header:SetFullWidth(true)
  header:SetText(str)
  header:SetHeight(40)
  return header
end

function Options:CreateDefaultCheckBox(text)
  local checkBox = AceGUI:Create("CheckBox")
  checkBox:SetLabel(text)
  checkBox:SetFullWidth(true)
  return checkBox
end

function Options:DrawAnimationSection(container)
  container:AddChild(self:CreateOptionHeading(ANIMATION))
  
  local checkBox = self:CreateDefaultCheckBox(L["Instant animations"])
  checkBox:SetDescription(
    L["Changes the behavior of the BestInSlot frame."].."\n"..
    L["Checking this disables the animation, and makes the frame instantly change size."].."\n"..
    L["This setting is account wide and saved between sessions."]
  )
  
  checkBox:SetValue(self.options.instantAnimation)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) 
    self.options.instantAnimation = value 
    self.db.global.options.instantAnimation = value  
  end)
  container:AddChild(checkBox)
  
  local checkBox = self:CreateDefaultCheckBox(L["Disable resizing"])
  
  checkBox:SetDescription(
    L["This will disable resizing and set the window on a fixed size"]
  )
  checkBox:SetValue(self.options.windowFixed)
  checkBox:SetCallback("OnValueChanged", function(_,_,value)
    self.options.windowFixed = value
    self.db.char.options.windowFixed = value
  end)
  container:AddChild(checkBox)
end

function Options:DrawTooltipSection(container)
  container:AddChild(self:CreateOptionHeading(L["Tooltip"]))
  
  local checkBox = self:CreateDefaultCheckBox(L["Show BestInSlot in Item tooltip"])
  
  checkBox:SetDescription(
    L["This will put a note underneath Item tooltips when the item is part of your BestInSlot"]
  )
  checkBox:SetValue(self.options.showBiSTooltip)
  checkBox:SetCallback("OnValueChanged", function(_,_,value)
    self.options.showBiSTooltip = value
    self.db.char.options.showBiSTooltip = value  
  end)
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Show BestInSlot in boss tooltips"])
  
  checkBox:SetDescription(
    L["This will show items on the boss tooltip that you consider BestInSlot"]
  )
  checkBox:SetValue(self.db.char.options.showBossTooltip)
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Show tooltips in combat"])
  checkBox:SetDescription(
    L["You can preserve speed by preventing BestInSlot from adding information to tooltips while you are in combat"]
  )
  checkBox:SetValue(self.db.char.options.tooltipCombat)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) self.db.char.options.tooltipCombat = value end)
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Show item source in tooltip."])
  checkBox:SetDescription(
    L["Show the item source in the tooltip, for example a boss that drops it, or a quest chain."]
  )
  checkBox:SetValue(self.db.char.options.tooltipSource)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) self.db.char.options.tooltipSource = value end)
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Show guild members in Item Tooltip"])
  checkBox:SetValue(self.db.char.options.guildtooltip)
  checkBox:SetDescription(
    L["This will show the guild members who also have BestInSlot in your item tooltips."]
  )
  checkBox:SetCallback("OnValueChanged", function(_,_,value) self.db.char.options.guildtooltip = value dropdownGuildRanks:SetDisabled(not value) end)
  container:AddChild(checkBox)
  
  dropdownGuildRanks = AceGUI:Create("Dropdown")
  dropdownGuildRanks:SetLabel(GUILDCONTROL_GUILDRANKS)
  dropdownGuildRanks:SetRelativeWidth(0.49)
  dropdownGuildRanks:SetMultiselect(true)
  dropdownGuildRanks:SetList({})
  dropdownGuildRanks:SetCallback("OnValueChanged", function(widget, _, rankId, value) self.db.char.options.showGuildRankInTooltip[rankId] = value end)
  if IsInGuild() then
    for i=1,GuildControlGetNumRanks() do
      local rankName = GuildControlGetRankName(i)
      dropdownGuildRanks:AddItem(i, rankName)
      dropdownGuildRanks:SetItemValue(i, self.db.char.options.showGuildRankInTooltip[i])
    end
    dropdownGuildRanks:SetDisabled(not self.db.char.options.guildtooltip)
  else
    dropdownGuildRanks:SetDisabled(true)
  end
  container:AddChild(dropdownGuildRanks)
end

function Options:DrawHistory(container)
  container:AddChild(self:CreateOptionHeading(HISTORY))
  local checkBox = self:CreateDefaultCheckBox(L["History tracking"])
  checkBox:SetValue(self.db.char.options.keepHistory)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) self.db.char.options.keepHistory = value end)
  checkBox:SetDescription(
    L["Tracks changes made by Guild Members to their BestInSlot lists"]
  )
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Automatically delete history"])
  checkBox:SetValue(self.db.char.options.historyAutoDelete)
  checkBox:SetDescription(
    L["Automatically deletes history based on the time set below"]
  )
  checkBox:SetCallback("OnValueChanged", function(widget, _, value)
    self.db.char.options.historyAutoDelete = value
    local udt = widget:GetUserDataTable()
    udt.input:SetDisabled(not value)
    udt.dropdown:SetDisabled(not value)
  end)
  local checkBoxUdt = checkBox:GetUserDataTable()
  container:AddChild(checkBox)
  local inputField = AceGUI:Create("EditBox")
  local input, value = (self.db.char.options.historyLength):match("(%d+)(%a)")
  input = tonumber(input)
  if value ~= "d" and value ~= "h" then
    value = nil
  end
  if not input or not value then
    input = 30
    value = "d"
    self.db.char.options.historyLength = "30d"
  end
  inputField:SetText(input)
  local inputDropdown = AceGUI:Create("Dropdown")
  inputDropdown:SetList({
    d = DAYS,
    h = HOURS
  })
  inputDropdown:SetValue(value)
  inputField:SetUserData("dropdown", inputDropdown)
  inputDropdown:SetUserData("input", inputField)
  checkBoxUdt.input = inputField
  checkBoxUdt.dropdown = inputDropdown
  for _,widget in pairs({inputField, inputDropdown}) do
    widget:SetDisabled(not checkBox:GetValue())
    widget:SetRelativeWidth(0.32)
  end
  inputField:SetCallback("OnEnterPressed", function(widget, _, text)
    local dropdown = widget:GetUserData("dropdown")
    local number = tonumber(text)
    if not number or number < 1 then widget:SetText("-1") return end
    local timespan = dropdown:GetValue()
    self.db.char.options.historyLength = number..timespan
  end)
  inputDropdown:SetCallback("OnValueChanged", function(widget, _, value)
    local input = widget:GetUserData("input")
    local number = tonumber(input:GetText())
    if not number or number == -1 then return end
    self.db.char.options.historyLength = number..value
  end)
  container:AddChild(inputField)
  container:AddChild(inputDropdown)
  local button = AceGUI:Create("Button")
  button:SetText(L["Wipe history"])
  button:SetRelativeWidth(0.32)
  button:SetCallback("OnClick", function()
    self.History:DeleteAllHistory()
  end)
  container:AddChild(button)
end

function Options:DrawTutorials(container)
  container:AddChild(self:CreateOptionHeading(SHOW_TUTORIALS))
  local checkBox = AceGUI:Create("CheckBox")
  checkBox:SetLabel(SHOW_TUTORIALS)
  checkBox:SetRelativeWidth(0.70)
  checkBox:SetDescription((L["Shows interactive tutorials on how to efficiently use %s"]):format("BestInSlot"))
  
  checkBox:SetValue(self.db.global.tutorials)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) self.db.global.tutorials = value end)
  container:AddChild(checkBox)
  
  local button = AceGUI:Create("Button")
  button:SetText(RESET_TUTORIALS)
  button:SetRelativeWidth(0.25)
  button:SetCallback("OnClick", function() self:ResetTutorials() end)
  container:AddChild(button)
end

function Options:DrawAutomatization(container)
  container:AddChild(self:CreateOptionHeading(L["Automatization"]))
  
  local checkBox = self:CreateDefaultCheckBox(L["Send automatic updates"])
  
  checkBox:SetDescription(
    L["When you update your BiS list, it'll automatically send the updates to the guild"]
  )
  checkBox:SetValue(self.options.sendAutomaticUpdates)
  checkBox:SetCallback("OnValueChanged", function(_,_,value)
    self.options.sendAutomaticUpdates = value
    self.db.char.options.sendAutomaticUpdates = value
  end)
  container:AddChild(checkBox)
  
  checkBox = self:CreateDefaultCheckBox(L["Receive automatic updates"])
  
  checkBox:SetDescription(
    L["When others in your guild update their BiS list, automatically save it."]
  )
  checkBox:SetValue(self.options.receiveAutomaticUpdates)
  checkBox:SetCallback("OnValueChanged", function(_,_,value)
    self.options.receiveAutomaticUpdates = value
    self.db.char.options.receiveAutomaticUpdates = value
  end)
  container:AddChild(checkBox)
end

function Options:DrawOtherOptions(container)
  container:AddChild(self:CreateOptionHeading(CALENDAR_TYPE_OTHER))
  local checkBox = self:CreateDefaultCheckBox(L["Show minimap button"])
  
  checkBox:SetValue(self.db.char.options.minimapButton)
  checkBox:SetCallback("OnValueChanged", self.MiniMapButtonHideShow)
  container:AddChild(checkBox)
  
  local checkBox = self:CreateDefaultCheckBox(L["Debug messages"])
  checkBox:SetDescription(
    L["Debug messages will be shown in the chat window if enabled."].."\n"..
    L["These can be used to identify problems."].."\n"..
    L["Generally encouraged to keep this disabled"].."\n"..
    L["This setting is not saved between sessions, and off by default."]
  )
  
  checkBox:SetValue(self.options.DEBUG)
  checkBox:SetCallback("OnValueChanged", function(_,_,value) 
    self.options.DEBUG = value 
    self:SendEvent("DebugOptionsChanged", value) 
  end)
  container:AddChild(checkBox)
  
end

function Options:Draw(container)
  container:SetLayout("Fill")
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  scroll:SetLayout("Flow")
  container:AddChild(scroll)
  self:DrawAnimationSection(scroll)
  self:DrawTooltipSection(scroll)
  self:DrawAutomatization(scroll)
  self:DrawHistory(scroll)
  self:DrawTutorials(scroll)
  self:DrawOtherOptions(scroll)
end
