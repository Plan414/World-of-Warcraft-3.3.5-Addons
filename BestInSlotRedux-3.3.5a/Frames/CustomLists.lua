local unpack, select, pairs, tinsert, tremove
=     unpack, select, pairs, table.insert, table.remove
local GetSpecializationInfoByID =
      GetSpecializationInfoByID
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local CustomLists = BestInSlot:GetMenuPrototype(L["Custom Lists"])
local MAXCHARS = 20
local db
CustomLists.Width = 500
CustomLists.Height = 600

function CustomLists:Close()
  self.spec = nil
  self.name = nil
  self.error = nil
  self.container = nil
end

function CustomLists:Draw(container)
  db = db or self.db.char.customlists
  self:QuickCreate("Heading", {SetText = L["New custom list"], SetFullWidth = true}, container)
  self:QuickCreate("Label", {SetText = L["Each custom list must be tied to a talent specialization."], SetFullWidth = true}, container)
  self.name = self:QuickCreate("EditBox", {SetLabel = NAME, SetMaxLetters = MAXCHARS}, container)
  local dropdown = AceGUI:Create("Dropdown")
  dropdown:SetLabel(L["Specialization"])
  dropdown:SetList(self:GetAllSpecializations())
  dropdown:SetValue(self:GetSelected(self.SPECIALIZATION))
  self.spec = dropdown
  container:AddChild(dropdown)
  self:QuickCreate("Button", {SetText = ADD, SetCallback = {"OnClick", function() CustomLists:AddCustomList() end}}, container)
  self.error = self:QuickCreate("Label", {SetText = "", SetColor = {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b}}, container)
  local heading = self:QuickCreate("Heading", {SetText = L["Your custom lists"], SetFullWidth = true}, container)
  self.container = self:QuickCreate("ScrollFrame", {SetFullWidth = true, SetLayout = "Flow", SetHeight = 350})
  self.container:SetPoint("TOPLEFT", heading.frame, "BOTTOMLEFT")
  self.container:SetPoint("BOTTOMRIGHT", container.frame, "BOTTOMRIGHT")
  container:AddChild(self.container)
  self:ResetYourCustomLists()
end

function CustomLists:ResetYourCustomLists()
  if not self.container then return end
  self.container:ReleaseChildren()
  for id, data in pairs(db) do
    self:CustomListMenuItem(data.name, data.spec, id)
  end
end

local function onDeleteClick(widget)
  CustomLists:DeleteCustomList(widget:GetUserData("id"))
end

function CustomLists:CustomListMenuItem(customListName, customListSpecId, id)
    local group = self:QuickCreate("SimpleGroup", {SetFullWidth = true, SetLayout = "Flow"}, self.container)
    local label = self:QuickCreate("Label", {SetText = customListName, SetRelativeWidth = 0.499})
    local textHeight = label.frame:GetHeight()
    local icon = self:QuickCreate("Icon", {SetImageSize = {textHeight, textHeight}, SetRelativeWidth = 0.1, SetImage = select(4, GetSpecializationInfoByID(customListSpecId))}, group)
    group:AddChild(label)
    self:QuickCreate("InteractiveLabel", {
      SetUserData = {"id", id}, 
      SetText = DELETE, SetRelativeWidth = 0.399, 
      SetColor = self:IsCustomListInUse(id) and {0.5, 0.5, 0.5} or {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b}, 
      SetHighlight = "Interface\\QuestFrame\\UI-QuestTitleHighlight", 
      SetCallback = {"OnClick", onDeleteClick}}, group)
    group:SetHeight(textHeight)
end

function CustomLists:DeleteCustomList(id)
  if not db[id] then return end
  local inUse = self:IsCustomListInUse(id)
  if inUse then
    local listHasBiSLists = ""
    for i=1,#inUse do
      listHasBiSLists = ("%s-%s %s\r\n"):format(listHasBiSLists, self:GetDescription(self.RAIDTIER, inUse[i].raidtier), self:GetDescription(self.DIFFICULTY, inUse[i].raidtier, inUse[i].difficulty))
    end
    StaticPopup_Show("BESTINSLOT_CANTDELETECUSTOMLIST", listHasBiSLists)
    return
  end
  if self:GetSelected(self.SPECIALIZATION) == db[id].name then
    self:SetSelected(self.SPECIALIZATION, db[id].spec)
  end
  tremove(db, id)
  self:ResetYourCustomLists()
end

function CustomLists:IsCustomListInUse(id)
  if not db[id] then return end
  local listName = db[id].name
  local lists = {}
  for i, raidTier in pairs(self:GetRaidTiers()) do
    for difficId, difficName in pairs(self:GetDifficulties(self.RAIDTIER, raidTier)) do
      for _,_ in pairs(BestInSlot.db.char[raidTier][difficId][listName]) do
        tinsert(lists, {raidtier = raidTier, difficulty = difficId})
        break
      end
    end
  end
  return #lists > 0 and lists
end

function CustomLists:AddCustomList()
  self.error:SetText("")
  local name = self.name:GetText()
  local spec = self.spec:GetValue()
  if spec == nil then
    return self.error:SetText(L["You must select a specialization."])
  end
  if not name or #name == 0 then
    return self.error:SetText(L["This name is invalid"])
  elseif #name > MAXCHARS then
    return self.error:SetText((L["A custom list's name can be no longer then %d characters."]):format(MAXCHARS))
  else
    for i=1,#db do
      if db[i].name:lower() == name:lower() then
        return self.error:SetText(L["A list with this name already exists"])
      end
    end
  end
  tinsert(db, {name = name, spec = spec})
  self:CustomListMenuItem(name, spec, #db)
  self.name:SetText("")
end

function BestInSlot:GetCustomLists(tbl)
  local result = tbl or {}
  for _,data in pairs(self.db.char.customlists) do
    result[data.name] = data.spec
  end
  return result, #self.db.char.customlists > 0
end

function BestInSlot:GetSpecForCustomList(name)
  for _, data in pairs(self.db.char.customlists) do
    if data.name == name then return data.spec end
  end
  return nil
end

StaticPopupDialogs["BESTINSLOT_CANTDELETECUSTOMLIST"] = {
  text = L["You can't delete this custom list."].."\r\n"..L["It's in use at:"].."\r\n%s",
  button1 = CLOSE,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  exclusive = 1,
}