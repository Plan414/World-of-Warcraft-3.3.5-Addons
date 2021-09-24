--[[
Adds a /exportraid slash command that can export loot tables from the EncounterJournal
]]

SLASH_EXPORTRAID1 = "/exportraid"
local txt = ""
local replace = ""
local replace2 = ""
local box
local function addLine(str)
  txt = txt .. "  ".. str .. "\r\n"
end
local function addSpacer(count, txt)
  if not count then
    addLine("\r\n")
  else
    addLine(string.rep("-", count) .. (txt and (" " .. txt) or ""))
  end
end
local function setText()
  local newTxt = txt:gsub("REPLACEME1",replace):gsub("REPLACEME2", replace2)
  box:SetText(newTxt)
end

function SlashCmdList.EXPORTRAID(msg,editbox)
  if not EncounterJournal or not EncounterJournal:IsVisible() then
    print("Open the encounter journal first!")
    return
  end
  local AceGUI = LibStub("AceGUI-3.0")
  if not AceGUI then 
    print("Enable AceGUI")
    return
  end
  local instanceName, _, _, _, _, _, mapId = EJ_GetInstanceInfo()
  local window = AceGUI:Create("Window")
  local nameBox = AceGUI:Create("EditBox")
  nameBox:SetText(replace)
  nameBox:SetLabel("Identifier")
  nameBox:SetCallback("OnTextChanged", function() replace = nameBox:GetText() setText() end)
  window:AddChild(nameBox)
  
  local tierBox = AceGUI:Create("EditBox")
  tierBox:SetText(replace2)
  tierBox:SetLabel("Tier")
  tierBox:SetCallback("OnTextChanged", function() replace2 = tierBox:GetText() setText() end)
  window:AddChild(tierBox)
  box = AceGUI:Create("MultiLineEditBox")
  box:SetFullWidth(true)
  box:SetHeight(window.frame:GetHeight() - 100)
  window:AddChild(box)
  txt = ""
  addLine("local REPLACEME1 = \"REPLACEME1\"")
  addLine(("local name = GetMapNameByID(%s)"):format(mapId))
  addLine("self:RegisterRaidInstance(REPLACEME2, REPLACEME1, name)")
  addSpacer(50)
  addSpacer(5, instanceName)
  addSpacer(50)
  addSpacer()
  local numLoot = EJ_GetNumLoot()
  local lootInfo = {}
  for i=1,numLoot do
    local itemId, encounterId, _, _, name, _, link = EJ_GetLootInfoByIndex(i)
    lootInfo[encounterId] = lootInfo[encounterId] or {}
    table.insert(lootInfo[encounterId], {id = itemId, name = GetItemInfo(itemId)})
  end
  local bossIndex = 1
  local bossName, _, encounterId = EJ_GetEncounterInfoByIndex(bossIndex)
  while bossName do
    addSpacer(35)
    addSpacer(5, bossName)
    addSpacer(35)
    
    addLine(("local bossName = EJ_GetEncounterInfo(%d)"):format(encounterId))
    addLine("local lootTable = {")
    for i=1,#(lootInfo[encounterId] or {}) do
      addLine(("  %d, --%s"):format(lootInfo[encounterId][i].id, lootInfo[encounterId][i].name or "NO NAME?"))
    end
    addLine("}")
    addLine("self:RegisterBossLoot(REPLACEME1, lootTable, bossName)")
    addSpacer()
    bossIndex = bossIndex + 1
    bossName, _, encounterId = EJ_GetEncounterInfoByIndex(bossIndex)
  end
  setText()
end