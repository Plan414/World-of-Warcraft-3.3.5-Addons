local unpack, select, pairs, tostring, type, tinsert
=     unpack, select, pairs, tostring, type, table.insert

local GetItemSpell
=     GetItemSpell

local BestInSlot, L, AceGUI = unpack(select(2, ...))
local IO = BestInSlot:GetMenuPrototype(L["Export"])
IO.Width = 700
IO.Height = 600
IO.simcraftconversion = {
  "head",
  "neck",
  "shoulder",
  "back",
  "chest",
  "wrist",
  "hands",
  "waist",
  "legs",
  "feet",
  "finger1",
  "finger2",
  "trinket1",
  "trinket2",
  "main_hand",
  "off_hand"
}

local function setExportLinks()
  IO:SetExportLinks()
end

local function setUneditableText(widget, newtext)
    widget:SetUserData("contents", newtext)
    widget:SetText(newtext)
end

function IO:Draw(container)
  for i, type in pairs({self.RAIDTIER, self.DIFFICULTY, self.INSTANCE, self.SPECIALIZATION}) do
    local dropdown = self:GetDropdown(type, nil, setExportLinks)
    dropdown:SetRelativeWidth(0.49)
    container:AddChild(dropdown)
  end
  local wowhead = self:CreateUneditableTextbox("", "WoWhead")
  container:AddChild(wowhead)
  self.wowhead = wowhead
  local simcraft = self:CreateUneditableTextbox("", "SimulationCraft", "MultiLineEditBox")
  simcraft:SetNumLines(16)
  container:AddChild(simcraft)
  self.simcraft = simcraft
  self:SetExportLinks()
end

function IO:Close()
  self.wowhead = nil
  self.simcraft = nil
end

local function getWowheadItemLink(item)
  if not item.difficulty or type(item.difficulty) == "table" or item.difficulty <= 1 or item.difficulty == 4 then
    return tostring(item.itemid)
  else
    return item.itemid .. ".0.0.0.0.0.0.0.0.0." .. (item.difficulty == 2 and "566" or "567")
  end
end

function IO:GenerateWoWHeadLink(bisList, selected)
  if not self.wowhead then return end
  local wowheadstr = "http://www.wowhead.com/compare?items="
  local result = false
  for i, iteminfo in pairs(bisList) do
    local item = self:GetItem(iteminfo.item, selected.difficulty)
    local itemstr = self:GetItemString(iteminfo.item, selected.difficulty)
    wowheadstr = wowheadstr .. (i == 1 and "" or ";") .. getWowheadItemLink(item)
    result = true
  end
  if not result then
    setUneditableText(self.wowhead, "")
  else
    setUneditableText(self.wowhead, wowheadstr)
  end
end

local function formatStringToSimcraft(str)
  return str:lower():gsub(" ", "_"):gsub("[^%a_]", "")
end

function IO:GenerateSimCraft(bisList, selected)
  local txt = ""
  local dungeonId
  if not (selected.difficulty == 1 or selected.difficulty == 4) then
    dungeonId = ",bonus_id=" .. select(2, self:GetDifficultyIdForDungeon(selected.difficulty, selected.instance))
  end
  local spells
  for i, iteminfo in pairs(bisList) do
    if self.simcraftconversion[i] then
      local item = self:GetItem(iteminfo.item, selected.difficulty)
      local itemName = item.link:match("%[(.+)%]")
      local simcraftName = formatStringToSimcraft(itemName)
      txt = txt .. ("%s=%s,id=%d"):format(self.simcraftconversion[i], simcraftName, iteminfo.item)
      if dungeonId and item.difficulty and not (item.difficulty == 1 or item.difficulty == 4) then
        txt = txt .. dungeonId
      end
      local spell = GetItemSpell(iteminfo.item)
      if spell then
        spells = spells or {}
        tinsert(spells, simcraftName)
      end
    end
    txt = txt .. "\r\n"
  end
  if spells then
    txt = txt .. "\r\n"
    for _, spell in pairs(spells) do
      txt = txt .. ("actions+=/use_item,name=%s\r\n"):format(spell)
    end
  end
  setUneditableText(self.simcraft,txt)
end

function IO:SetExportLinks()
  local selected = self:GetSelected()
  local bisList = self:GetBestInSlotItems(selected.raidtier, selected.difficulty, selected.specialization)
  self:GenerateWoWHeadLink(bisList, selected)
  self:GenerateSimCraft(bisList, selected)
end