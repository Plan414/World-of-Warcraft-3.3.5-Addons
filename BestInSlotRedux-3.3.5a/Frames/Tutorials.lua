local unpack, select
=     unpack, select
local BestInSlot, L, AceGUI = unpack(select(2, ...))
---
--format for each tutorial:
--Array with these keys, [] is optional
--text1(string): The BigText to appear in the glowbox
--text2(string): The SmallText to appear in the glowbox
--xOffset(number): The offset on the X-axis
--yOffest(number): The offset on the Y-axis
--[container](string): Either 'menu' or 'content' for the offsets parent being either of these elements
--[element](string): If container is set, you can also set an element. This element must be in the containers UserData table.
--[UpArrow](boolean): When true shows an UpArrow
--[DownArrow](boolean): When true shows a DownArrow
--[onRequest](boolean): When true this one will not be shown automatically
--[specialAnchor](string): custom anchors as implemented in ShowTutorial
local tutorials = {}


function BestInSlot:RegisterTutorials(menuId, tutorialInfo)
  tutorials[menuId] = tutorialInfo
end

function BestInSlot:CheckTutorials(menu)
  if BestInSlotTutorialFrame:IsShown() then return end
  local id
  if self.db.global.tutorials then
    if not menu then menu = self:GetSelectedMenuItem() end
    local tutorials = tutorials[menu]
    if not tutorials then return end
    local db = self.db.char.tutorials[menu]
    if not db then 
      id = 1 
    else 
      for i=1,#tutorials do
        if not db[i] then 
          id = i 
          break 
        end
      end
    end
    if not id or tutorials[id].onRequest then return end
    self:ShowTutorial(menu, id)
  end
end

function BestInSlot:ShowTutorial(menu, id)
  if not self.db.global.tutorials then return end
  local db = self.db.char.tutorials
  if db[menu] and db[menu][id] then 
    return 
  else
    db[menu] = db[menu] or {}
    db[menu][id] = true
  end
  if self.frame then
    local tutorial = tutorials[menu][id]
    local frame = self.frame
    local tutorialFrame = BestInSlotTutorialFrame
    local height = 58
    tutorialFrame:SetParent(frame.frame)
    tutorialFrame:SetPoint("TOPLEFT", frame.frame, "TOPLEFT", 5, -5)
    tutorialFrame:SetPoint("BOTTOMRIGHT", frame.frame, "BOTTOMRIGHT", -5, 5)
    tutorialFrame:SetFrameStrata("TOOLTIP")
    tutorialFrame.currentMenu = menu
    tutorialFrame.currentId = id
    tutorialFrame.GlowBox.CheckBox:SetChecked(false)
    
    local glowBox = tutorialFrame.GlowBox
    glowBox.BigText:SetText(tutorial.text)
    height = height + glowBox.BigText:GetHeight();
    if tutorial.text2 then
      glowBox.SmallText:SetText(tutorial.text2)
      glowBox.SmallText:Show()
      height = height + 12 + glowBox.SmallText:GetHeight();
    else
      glowBox.SmallText:Hide()
    end
    local offsetFrame = frame.frame
    if tutorial.container then
      local container = frame:GetUserData(tutorial.container)
      if container then
        offsetFrame = container.frame
        if tutorial.element then
          local element = container:GetUserData(tutorial.element)
          if element then
            offsetFrame = element.frame
          end
        end
      end
    end
    glowBox:ClearAllPoints()
    if tutorial.specialAnchor == "StatusBar" then
      glowBox:SetPoint("BOTTOM", frame.statustext, "TOP", tutorial.xOffset, tutorial.yOffset)
    elseif tutorial.DownArrow then
      glowBox:SetPoint("BOTTOM", offsetFrame, "TOP", tutorial.xOffset, tutorial.yOffset)
    elseif tutorial.UpArrow then
      glowBox:SetPoint("TOP", offsetFrame, "BOTTOM", tutorial.xOffset, tutorial.yOffset)
    else
      glowBox:SetPoint("TOP", offsetFrame, "TOP", tutorial.xOffset, tutorial.yOffset)
    end
    glowBox:SetHeight(height)
    glowBox.ArrowUp:Hide()
    glowBox.ArrowGlowUp:Hide()
    glowBox.ArrowDown:Hide()
    glowBox.ArrowGlowDown:Hide()
    if tutorial.DownArrow then
      glowBox.ArrowDown:Show()
      glowBox.ArrowGlowDown:Show()
    elseif tutorial.UpArrow then
      glowBox.ArrowUp:Show()
      glowBox.ArrowGlowUp:Show()
    end      
    tutorialFrame:Show()
  end
end

function BestInSlot:ResetTutorials()
  self.db.char.tutorials = {}
  self:Print(L["Tutorials have been reset."], true)
end

function BestInSlot_TutorialNext()
  local tutorialFrame = BestInSlotTutorialFrame
  if tutorialFrame.GlowBox.CheckBox:GetChecked() then
    BestInSlot.db.global.tutorials = false
    BestInSlot:Print("Tutorials disabled. You can enable them in the options.", true)
  end
  if tutorialFrame:IsShown() then
    local menu = tutorialFrame.currentMenu
    local id = tutorialFrame.currentId
    if BestInSlot.db.global.tutorials and tutorials[menu][id+1] and not tutorials[menu][id+1].onRequest then
      BestInSlot:ShowTutorial(menu, id+1)
    else
      tutorialFrame:Hide()
      tutorialFrame.currentMenu = nil
      tutorialFrame.currentId = nil
    end
  end
end

BestInSlotTutorialFrame:Hide()