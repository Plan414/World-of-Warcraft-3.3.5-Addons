--lua
local unpack, select, strsplit, tonumber, pairs, wipe, tinsert, tconcat
=     unpack, select, strsplit, tonumber, pairs, wipe, table.insert, table.concat
-- WoW APi
local GetItemInfoFromHyperlink, GetItemInfo, CreateFrame, GetItemUniqueness
=     GetItemInfoFromHyperlink, GetItemInfo, CreateFrame, GetItemUniqueness
local BestInSlot, L, AceGUI = unpack(select(2, ...))
local CustomItems = BestInSlot:GetMenuPrototype(L["Custom Items"])
CustomItems.Width = 500
CustomItems.Height = 400
local minimumIlvl = 300
local failtimer
local upgradeStages = {
  [525] = "Stage 1", 
  [526] = "Stage 2",
  [527] = "Stage 3",
  [593] = "Stage 4",
  [617] = "Stage 5",
  [618] = "Stage 6" 
}

local upgradeTypes = {
  427,  --of the Auger
  150,  --of the Aurora
  129,  --of the Deft
  385,  --of the Diviner
  343,  --of the Fanatic
  108,  --of the Feverflare
  19,   --of the Fireflash
  238,  --of the Guileful
  196,  --of the Harmonious
  406,  --of the Herald
  175,  --of the Merciless
  280,  --of the Noble
  45,   --of the Peerless
  87,   --of the Quickblade
  66,   --of the Savage
  322,  --of the Stalwart
  301,  --of the Stormbreaker
  217,  --of the Strategist
  259,  --of the Windshaper
  364,  --of the Zealot
}

local upgradeNames = {}

local function onEnterPreviewLabel(widget)
  local link = widget:GetUserData("link")
  if not link then return end
  GameTooltip:SetOwner(CustomItems.frame.frame)
  GameTooltip:SetAnchorType("ANCHOR_CURSOR")
  GameTooltip:SetHyperlink(link)
  GameTooltip:Show()
end

local function onLeavePreviewLabel(widget)
  GameTooltip:Hide()
end

local function editBoxOnEnterPressed(widget, _,value)
  if #value > 0 then
    CustomItems:TryGenerateCustomItem(value)
  else
    CustomItems:ResetCustomItem("")
  end
end

local function OnItemInfoReceived(event, itemid)
  CustomItems:TryGenerateCustomItem(itemid)
end

local function timerFailedQuery()
  CustomItems:FailedItemQuery()
end

function CustomItems:EnablePreviewLabel(text, success)
  local label = self.successlabel
  if not label then return end
  label:SetText(("\n%s\n"):format(text))
  label:SetCallback("OnEnter", onEnterPreviewLabel)
  label:SetCallback("OnLeave", onLeavePreviewLabel)
  if GetItemInfoFromHyperlink(text) ~= nil then
    label:SetUserData("link", text)
  end
  if success then
    self.verifytext:SetText(L["Please verify that this is the item you would like to add:"])
  end
  self.container:DoLayout()
end

function CustomItems:ResetCustomItem(text)
  local label = self.successlabel
  if not label then return end
  label:SetText(text)
  label:SetCallback("OnEnter", nil)
  label:SetCallback("OnLeave", nil)
  self.verifytext:SetText("")
  self.notallowedlabel:SetText("")
  self.suffixDropdown:SetDisabled(true)
  self.stageDropdown:SetDisabled(true)
  self.dungeonDropdown:SetDisabled(true)
  self.submitButton:SetDisabled(true)
  self.cancelButton:SetDisabled(true)
  self.stageDropdown:SetValue()
  self.suffixDropdown:SetValue()
  self:DisableInput(false)
  self.customItemDropdown:SetValue()
  self:DisableInput(false)
  self.deleteButton:SetDisabled(true)
  self.container:DoLayout()
end

function CustomItems:IsItemAllowed(itemid)
  local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemid)
  local errors = {}
  local label = self.notallowedlabel
  if quality < 3 then
    tinsert(errors, ("- "..L["You can only add items of %ssuperior%s quality or higher!"]):format(ITEM_QUALITY_COLORS[3].hex, RED_FONT_COLOR_CODE))
  end
  if #equipSlot == 0 and not IsArtifactRelicItem(itemid) then --empty string means no equipment slot?
    tinsert(errors, "- "..L["You must be able to equip the item!"])
  elseif equipSlot == "INVTYPE_TABARD" or equipSlot == "INVTYPE_BODY" then
    tinsert(errors, "- "..(L["You cannot add items of type: %s!"]):format(_G[equipSlot]))
  elseif equipSlot == "INVTYPE_BODY" then
    tinsert(errors, "- "..(L["You cannot add items of type: %s!"]):format(_G[equipSlot]))
  end
  if self:ItemExists(itemid) then
    local item = self:GetItem(itemid)
    if item.customitem then
      self.customItemDropdown:SetValue(itemid)
      label:SetText(L["Warning! Editing this item will overwrite the previous item set on this itemid!"])
      return self:LoadCustomItem(itemid)
    else
      local raidtier = self:GetRaidTiers(self.INSTANCE, item.dungeon)
      tinsert(errors, ("- "..L["This item already exists in the database! It is registered to %s"]):format(self:GetDescription(self.RAIDTIER, raidtier)))
    end
  end
  if iLevel < minimumIlvl then
    tinsert(errors, "- "..(L["The minimum item level of custom items is %d!"]):format(minimumIlvl))
  end
  if #errors > 0 then
    tinsert(errors, 1, L["Failed to add item because of the following reasons:"])
    label:SetText("|cffff0000"..tconcat(errors, "\n"))
  end
  return #errors == 0
end

function BestInSlot:GetWarlordsCraftedLink(itemid, stage, upgradeType)
  return ("item:%d:0:0:0:0:0:0:0:0:0:0:0:2:%d:%d"):format(itemid, stage, upgradeType)
end

function CustomItems:DisableInput(disable)
  self.inputbox:SetDisabled(disable)
  local customItemCount = self.customItemDropdown:GetUserData("count")
  self.customItemDropdown:SetDisabled(customItemCount == 0 or disable)
end

function CustomItems:LoadCustomItem(itemid)
  local item = self:GetItem(itemid)
  if item then 
    self.itemid = itemid
    self.itemstr = item.customitem
    self:DisableInput(true)
    self:EnablePreviewLabel(item.link, true)
    self.dungeonDropdown:SetValue(item.dungeon)
    self.container:DoLayout()
    self:EnableImportOptions(itemid, item.link)
    self.deleteButton:SetDisabled(false)
  end
  return false
end

function CustomItems:GenerateUpgradeNames(itemid)
  local spirit = "SPIRIT"
  local stats = {
    [427] = {spirit, "VERSATILITY"}, --of the Auger
    [150] = {"HASTE", "VERSATILITY"},  --of the Aurora
    [129]= {"HASTE", "MULTISTRIKE"},  --of the Deft
    [385] = {spirit, "MASTERY"}, --of the Diviner
    [343] = {spirit, "CRITICAL_STRIKE"},
    [108] = {"HASTE", "MASTERY"},  --of the Feverflare
    [19]  = {"HASTE", "CRITICAL_STRIKE"},   --of the Fireflash
    [238] = {"BONUS_ARMOR", "CRITICAL_STRIKE"},  --of the Guileful
    [196] = {"MASTERY", "VERSATILITY"},  --of the Harmonious
    [406] = {spirit, "MULTISTRIKE"}, --of the Herald
    [175] = {"MASTERY", "MULTISTRIKE"},  --of the Merciless
    [280] = {"BONUS_ARMOR", "MASTERY"},  --of the Noble
    [45] = {"CRITICAL_STRIKE", "MASTERY"},   --of the Peerless
    [87] = {"CRITICAL_STRIKE", "VERSATILITY"},   --of the Quickblade
    [66] = {"CRITICAL_STRIKE", "MULTISTRIKE"},   --of the Savage
    [322] = {"BONUS_ARMOR", "VERSATILITY"},  --of the Stalwart
    [301] = {"BONUS_ARMOR", "MULTISTRIKE"},  --of the Stormbreaker
    [217] = {"MULTISTRIKE", "VERSATILITY"},  --of the Strategist
    [259] = {"BONUS_ARMOR", "HASTE"},  --of the Windshaper
    [364] = {spirit, "HASTE"}, --of the Zealot
  }
  local name = GetItemInfo(itemid) --original name to compare with other results
  local tooltip = CreateFrame("GAMETOOLTIP", "BestInSlotScanTooltip", UIParent, "GameTooltipTemplate")
  local stage = 525
  for i=1,#upgradeTypes do
    local upgradeType = upgradeTypes[i]
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:ClearLines()
    tooltip:SetHyperlink(self:GetWarlordsCraftedLink(itemid, stage, upgradeType))
    tooltip:Show()
    local typeName = BestInSlotScanTooltipTextLeft1:GetText()
    tooltip:Hide()
    if stats[upgradeType][1] == spirit then
      upgradeNames[upgradeType] = typeName:sub(#name + 1)..(" (%s + %s)"):format(ITEM_MOD_SPIRIT_SHORT, _G["STAT_"..stats[upgradeType][2]])
    else
      upgradeNames[upgradeType] = typeName:sub(#name + 1)..(" (%s + %s)"):format(_G["STAT_"..stats[upgradeType][1]], _G["STAT_"..stats[upgradeType][2]])
    end
  end
  tooltip:Hide()
end

local function warlordsCraftedDropdownChanged()
  if not CustomItems.itemid then error("The itemid is not known!") end
  local isTrinket = select(9,GetItemInfo(CustomItems.itemid)) == "INVTYPE_TRINKET"
  local stage = CustomItems.stageDropdown:GetValue() or 525
  local suffix = CustomItems.suffixDropdown:GetValue() or not isTrinket and 150
  local hyperlink = CustomItems:GetWarlordsCraftedLink(CustomItems.itemid, stage, suffix)
  local link = select(2, GetItemInfo(hyperlink))
  if isTrinket then
    CustomItems.submitButton:SetDisabled(CustomItems.stageDropdown:GetValue() == nil)
  else
    CustomItems.submitButton:SetDisabled(CustomItems.stageDropdown:GetValue() == nil or CustomItems.suffixDropdown:GetValue() == nil)
  end
  CustomItems.successlabel:SetText("\n"..link.."\n")
  CustomItems.successlabel:SetUserData("link", link)
end

function CustomItems:GenerateWarlordsCraftedOptions(itemlink)  
  local _,_, _, _, _, _, _, _, _, _, _, _, _, numBonusID, bonusId1, bonusId2 = strsplit(":", (itemlink):sub(1,(itemlink):find("|h") - 1), 15)
  numBonusID, bonusId1, bonusId2 = tonumber(numBonusID), tonumber(bonusId1), tonumber(bonusId2)
  for _,bonusId in pairs({bonusId1, bonusId2}) do
    if upgradeNames[bonusId] then
      self.suffixDropdown:SetValue(bonusId)
    elseif upgradeStages[bonusId] then
      self.stageDropdown:SetValue(bonusId)
    end
  end
end

function CustomItems:EnableImportOptions(itemid, link)
  local container = self.container
  if not container then return end
  local isWarlordsCraftedItem = GetItemUniqueness(itemid) == 341
  self.suffixDropdown:SetDisabled(not isWarlordsCraftedItem or select(9, GetItemInfo(itemid)) == "INVTYPE_TRINKET")
  self.stageDropdown:SetDisabled(not isWarlordsCraftedItem)
  self.cancelButton:SetDisabled(false)
  if isWarlordsCraftedItem then --warlords crafted
    if not upgradeNames[upgradeTypes[1]] then
      self:GenerateUpgradeNames(itemid)
      self.suffixDropdown:SetList(upgradeNames)
    end
    self:GenerateWarlordsCraftedOptions(link)
    self:ShowTutorial(L["Custom Items"], 3)
  end
  self.submitButton:SetDisabled(isWarlordsCraftedItem and (self.suffixDropdown:GetValue() == nil or self.stageDropdown:GetValue() == nil))
  self.dungeonDropdown:SetDisabled(false)
end

function CustomItems:TryGenerateCustomItem(input)
  self:ResetCustomItem(self.colorNormal..L["Looking up item"].."...".."|r")
  self:DisableInput(true)
  local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(input)
  if name then
    local itemStr = link:match("|H(item.-)|h")
    local itemid = GetItemInfoFromHyperlink(link)
    self.itemid = itemid
    self.itemstr = itemStr
    if failtimer then 
      failtimer:Cancel()
      self:UnregisterEvent("GET_ITEM_INFO_RECEIVED", OnItemInfoReceived)
    end
    local success = self:IsItemAllowed(itemid)
    self.successlabel:SetUserData("link", link)
    self:EnablePreviewLabel(link, success)
    self:DisableInput(success)
    if success then
      self:EnableImportOptions(itemid, link)
    end
  else
    self.itemid = nil
    failtimer = C_Timer.NewTimer(1.5, timerFailedQuery)
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", OnItemInfoReceived)
  end
end

function CustomItems:FailedItemQuery()
  self:UnregisterEvent("GET_ITEM_INFO_RECEIVED", OnItemInfoReceived)
  failtimer = nil
  self:ResetCustomItem((RED_FONT_COLOR_CODE.."%s\n%s: %s"):format(L["Couldn't find item!"], LABEL_NOTE, L["You can only use the item name if you have the item in your inventory!"]))
  self:DisableInput(false)
end

local function onDungeonChanged(dropdown, _, value)
  CustomItems:SetSelected(CustomItems.INSTANCE, value)
end

function CustomItems:SubmitCustomItem()
  local itemid = self.itemid
  local itemStr = self.itemstr
  local updatePrevious = self.customItemDropdown:GetValue() ~= nil
  local warlordsCrafted = not self.stageDropdown.disabled
  local suffixType = self.suffixDropdown:GetValue()
  local stageType = self.stageDropdown:GetValue()
  local dungeon = self:GetSelected(self.INSTANCE)
  self:AddCustomItem(itemid, itemStr, dungeon, updatePrevious)
  self.inputbox:SetText("")
  local link = select(2, GetItemInfo(itemStr))
  self:ResetCustomItem("|cff00ff00"..(L["Successfully added %s to the custom items of %s!"]):format(link.."|cff00ff00", self:GetDescription(self.INSTANCE, dungeon)))
  self:SetCustomItemDropdown()
end

function CustomItems:SetCustomItemDropdown()
  local dropdown = self.customItemDropdown
  local customItems, count = self:GetCustomItems()
  if count > 0 then
    dropdown:SetList({})
    for dungeon, list in pairs(customItems) do
      for i=1,#list do
        local itemid = list[i]
        dropdown:AddItem(itemid, self:GetItem(itemid).link)
      end
    end
  end
  local disabled = count == 0
  dropdown:SetDisabled(disabled)
  dropdown:SetText(disabled and L["There are no custom items present"] or "")
  dropdown:SetUserData("count", count)
  
end

local function customItemDropdownValueChanged(widget, _, value)
  CustomItems:LoadCustomItem(value)
end

function CustomItems:Draw(container, dungeon)
  local editBox = AceGUI:Create("EditBox")
  editBox:SetFullWidth(true)
  editBox:SetLabel(L["Insert item ID, item link or item name"])
  editBox:SetCallback("OnEnterPressed", editBoxOnEnterPressed)
  container:SetUserData("input", editBox)
  container:AddChild(editBox)
  
  local customItemDropdown = AceGUI:Create("Dropdown")
  customItemDropdown:SetFullWidth(true)
  customItemDropdown:SetLabel(L["Pick a previously created custom item"])
  customItemDropdown:SetCallback("OnValueChanged", customItemDropdownValueChanged)
  container:AddChild(customItemDropdown)
  container:SetUserData("customitem", customItemDropdown)
  
  
  local verifytext = AceGUI:Create("Label")
  verifytext:SetFullWidth(true)
  container:AddChild(verifytext)
  
  local successlabel = AceGUI:Create("InteractiveLabel")
  successlabel:SetFullWidth(true)
  successlabel:SetText("")
  container:AddChild(successlabel)
  
  local notallowedlabel = AceGUI:Create("Label")
  notallowedlabel:SetFullWidth(true)
  notallowedlabel:SetText("")
  container:AddChild(notallowedlabel)
  
  
  local suffixDropdown = AceGUI:Create("Dropdown")
  suffixDropdown:SetList(upgradeNames)
  suffixDropdown:SetFullWidth(true)
  suffixDropdown:SetLabel(L["Warlords crafted options:"])
  suffixDropdown:SetCallback("OnValueChanged", warlordsCraftedDropdownChanged)
  suffixDropdown:SetDisabled(true)
  --container:AddChild(suffixDropdown)
  
  local stageDropdown = AceGUI:Create("Dropdown")
  stageDropdown:SetList(upgradeStages)
  stageDropdown:SetFullWidth(true)
  stageDropdown:SetCallback("OnValueChanged", warlordsCraftedDropdownChanged)
  stageDropdown:SetDisabled(true)
  --container:AddChild(stageDropdown)
  container:SetUserData("stage", stageDropdown)
  
  local dungeonDropdown = AceGUI:Create("Dropdown")
  dungeonDropdown:SetLabel(L["Select the instance that you would like to add this item to."])
  local raidTiers = self:GetRaidTiers()
  dungeonDropdown:SetList({})
  for _,raidtier in pairs(raidTiers) do
    local raidtierDungeons = self:GetInstances(self.RAIDTIER, raidtier)
    dungeonDropdown:AddItem(raidtier, "  "..self:GetDescription(self.RAIDTIER, raidtier))
    dungeonDropdown:SetItemDisabled(raidtier, true)
    for _, dungeon in pairs(raidtierDungeons) do
      dungeonDropdown:AddItem(dungeon, self:GetDescription(self.INSTANCE, dungeon))
    end
  end
  dungeonDropdown:SetFullWidth(true)
  dungeonDropdown:SetDisabled(true)
  dungeonDropdown:SetCallback("OnValueChanged", onDungeonChanged)
  dungeonDropdown:SetValue(dungeon or self:GetSelected(self.INSTANCE))
  container:AddChild(dungeonDropdown)
  
  local submitButton = AceGUI:Create("Button")
  submitButton:SetText(SUBMIT)
  submitButton:SetRelativeWidth(0.33)
  submitButton:SetDisabled(true)
  submitButton:SetCallback("OnClick", function() CustomItems:SubmitCustomItem() end)
  container:AddChild(submitButton)
  
  local cancelButton = AceGUI:Create("Button")
  cancelButton:SetText(CANCEL)
  cancelButton:SetRelativeWidth(0.33)
  cancelButton:SetDisabled(true)
  cancelButton:SetCallback("OnClick", function() CustomItems:ResetCustomItem() end)
  container:AddChild(cancelButton)
  
  local deleteButton = AceGUI:Create("Button")
  deleteButton:SetText(DELETE)
  deleteButton:SetRelativeWidth(0.33)
  deleteButton:SetDisabled(true)
  deleteButton:SetCallback("OnClick", function() CustomItems:DeleteCustomItem() end)
  container:AddChild(deleteButton)
  
  
  
  self.inputbox = editBox
  self.customItemDropdown = customItemDropdown
  self.verifytext = verifytext
  self.successlabel = successlabel
  self.notallowedlabel = notallowedlabel
  self.container = container
  self.suffixDropdown = suffixDropdown
  self.stageDropdown = stageDropdown
  self.dungeonDropdown = dungeonDropdown
  self.submitButton = submitButton
  self.cancelButton = cancelButton
  self.deleteButton = deleteButton
  
  
  self:SetCustomItemDropdown()
end

function CustomItems:DeleteCustomItem(doDelete)
  local item = self:GetItem(self.itemid)
  local isBiS = false
  for difficulty, difficTable in pairs(item.isBiS) do
    for specId, bis in pairs(difficTable) do
      if bis then
        isBiS = true
        break
      end
    end
  end
  if not doDelete and isBiS then
    local popup = StaticPopup_Show("BESTINSLOT_CONFIRMDELETECUSTOMITEM", self:GetItem(self.itemid).link)
    popup:SetFrameStrata("TOOLTIP")
    return
  end
  self:UnregisterCustomItem(self.itemid)
  self:ResetCustomItem("|cff00ff00"..(L["Successfully deleted %s%s from the custom items!"]):format(item.link, "|cff00ff00"))
  self:SetCustomItemDropdown()
end

function CustomItems:Close()
  self.successlabel = nil
  self.inputbox = nil
  self.container = nil
  self.notallowedlabel = nil
  self.itemid = nil
  self.itemstr = nil
  self.stageDropdown = nil
  self.suffixDropdown = nil
  self.dungeonDropdown = nil
  self.submitButton = nil
  self.cancelButton = nil
  self.deleteButton = nil
  self.customItemDropdown = nil
  if failtimer then failtimer:Cancel() failtimer = nil end
  wipe(upgradeNames) --memory saving, user should barely ever use this screen
end

StaticPopupDialogs["BESTINSLOT_CONFIRMDELETECUSTOMITEM"] = {
  text = L["Are you sure you want to delete %s? This item is on your Best In Slot list!"],
  button1 = YES,
  button2 = NO,
  OnAccept = function() CustomItems:DeleteCustomItem(true) end,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  exclusive = 1,
}

CustomItems:RegisterTutorials(L["Custom Items"],{
  [1] = {text = L["In this menu you can add custom items. Use this edit box to submit your item."], text2 = L["You can only use the item name if you have the item in your inventory!"], xOffset = 0, yOffset = -20, container = "content", UpArrow = true, element = "input"},
  [2] = {text = L["You can edit previously made custom items by selecting them with this dropdown box."], xOffset = 0, yOffset = -20, container = "content", UpArrow = true, element = "customitem"},
  --[3] = {text = L["When adding crafted items, you can select the random stats and the stage of the item with these dropdown boxes."], xOffset = 0, yOffset = -20, container = "content", Uparrow = true, element = "stage", UpArrow = true, onRequest = true}
})