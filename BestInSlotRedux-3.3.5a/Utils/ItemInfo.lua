SLASH_ITEMINFO1 = "/iteminfo"

function SlashCmdList.ITEMINFO(msg, editbox)
  local AceGUI = LibStub("AceGUI-3.0")
  local window = AceGUI:Create("Window")
  window:SetHeight(700)
  window:SetWidth(300)
  window:SetLayout("Flow")
  local iteminfo = {strsplit(":", msg)}
  --item:itemId:enchantId:gemId1:gemId2:gemId3:gemId4:suffixId:uniqueId:linkLevel:specializationID:upgradeId:instanceDifficultyId:numBonusIds:bonusId1:bonusId2:upgradeValue
  local indexDescription = {
    "itemid",
    "enchantId",
    "gemId1",
    "gemId2",
    "gemId3",
    "gemId4",
    "suffixId",
    "uniqueId",
    "linkLevel",
    "specializationId",
    "upgradeId",
    "instanceDifficultyId",
    "numBonusIds",
    "bonusId1",
    "bonusId2",
    "upgradeValue",
    "Unknown",
    "Unknown",
    "Unknown",
    "Unknown",
    "Unknown",
    "Unknown",
  }
  local editBoxes = {}
  for i=1,#indexDescription do
    local label = AceGUI:Create("Label")
    label:SetRelativeWidth(0.40)
    label:SetText(indexDescription[i])
    local editBox = AceGUI:Create("EditBox")
    editBox:SetRelativeWidth(0.40)
    editBoxes[i] = editBox
    if #iteminfo < (i + 1) then
      editBox:SetText("")
    else
      local txt = tostring(iteminfo[i+1])
      if not txt:find("%[") then
        editBox:SetText(txt)
      end
    end
    window:AddChild(label)
    window:AddChild(editBox)
  end
  local button = AceGUI:Create("Button")
  button:SetText("Generate Link")
  button:SetCallback("OnClick", function()
    local input = "item"
    for i=1,#editBoxes do
      input = input .. ":" ..editBoxes[i]:GetText()
    end
    local name, link = GetItemInfo(input)
    print(link)
  end)
  window:AddChild(button)
end