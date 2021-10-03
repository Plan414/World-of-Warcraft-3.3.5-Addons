local ScrollingDropDown = LibStub and LibStub:GetLibrary('LibScrollingDropDown-1.0')
local sbfo = SBFOptions
local strings = SBFOptions.strings
local SBFOSpellListButtons = {}
local _var
local _buffs = true
local _currentSpellIndex = -1

local blacklist = function()
  if _var.general.blacklist then
    SBFOSpellListCheckButtonText:SetFormattedText(strings.BLACKLISTCHECK)
  else
    SBFOSpellListCheckButtonText:SetFormattedText(strings.WHITELISTCHECK)
  end
end

SBFOptions.SpellTabInitialise = function(self)
  SBFOSpellTTLEditLabel:SetText(self.strings.SPELLTTL)
  SBFOSpellMineCheckButtonText:SetText(self.strings.MINE)
	for i=1,10 do
		SBFOSpellListButtons[i] = getglobal("SBFOSpellList"..i)
	end
end

SBFOptions.SpellTabSelectTab = function(self)
  blacklist()
  SBFOSpellTTLEdit.edit:SetText(SBF.db.global.spellTTL)
end

SBFOptions.SpellTabSelectFrame = function(self, var)
  if var then
    _var = var
  end
  self:SetSpellList(true)
  blacklist()
end

SBFOptions.SpellFilter = function(self)
	local spell = self.cache[_currentSpellIndex]
  local filterIndex, filter = self:FindFilter(spell)
  if filterIndex then 
    table.remove(_var.filters, filterIndex)
  end
  local flt
  if SBFOSpellMineCheckButton:GetChecked() then
    flt = format("n=%s&my", strlower(spell))
  elseif SBFOSpellListCheckButton:GetChecked() then
    flt = format("n=%s", strlower(spell))
  end
  if flt then
    if filterIndex then
      table.insert(_var.filters, filterIndex, flt)
    else
      table.insert(_var.filters, flt)
    end
  end
  self:FindFilter(spell)
	self:UpdateSpellList()
	self:SelectSpell()
end

SBFOptions.SpellsCastable = function(self, mine)
  if mine and SBFOSpellMineCheckButton:GetChecked() then
    SBFOSpellMineCheckButton:SetChecked(true)
    SBFOSpellCastableCheckButton:SetChecked(false)
  elseif not mine and SBFOSpellCastableCheckButton:GetChecked() then
    SBFOSpellMineCheckButton:SetChecked(false)
    SBFOSpellCastableCheckButton:SetChecked(true)
  else
    SBFOSpellMineCheckButton:SetChecked(false)
    SBFOSpellCastableCheckButton:SetChecked(false)
  end
  if SBFOSpellMineCheckButton:GetChecked() or SBFOSpellCastableCheckButton:GetChecked() then
    SBFOSpellListCheckButton:SetChecked(true)
  end
  self:SpellFilter()
end

SBFOptions.AlwaysWarn = function(self)
	if this:GetChecked() then
		SBF:AddAlwaysWarn(self.cache[_currentSpellIndex], self.curFrame.id)
	else
		SBF:RemoveAlwaysWarn(self.cache[_currentSpellIndex], self.curFrame.id)
	end
	self:UpdateSpellList()
end

SBFOptions.ClearSpellCache = function(self)
  SBF:PutTable(SBF.db.global.spells)
  SBF.db.global.spells = SBF:GetTable()
  self:SetSpellList(true)
end

SBFOptions.SetSpellList = function(self, buffs)
  if buffs then
    SBFOShowBuffsCheckButton:SetChecked(true)
    SBFOShowDebuffsCheckButton:SetChecked(false)
  else
    SBFOShowBuffsCheckButton:SetChecked(false)
    SBFOShowDebuffsCheckButton:SetChecked(true)
  end
  _buffs = (buffs == true)
  self:FillSpellList()
end

SBFOptions.FillSpellList = function(self)
  self.cacheSize = #SBF.db.global.spells
  SBF:PutTable(self.cache)
  self.cache = SBF:GetTable()
  local pattern = strlower(SBFOSpellFilterEdit.edit:GetText())
  for name,data in pairs(SBF.db.global.spells) do 
    if data[3] then
      if (data[3] >= SBF.HARMFUL) and not _buffs then
        if not pattern or string.find(strlower(name), pattern) then
          table.insert(self.cache, name)
        end
      elseif (data[3] < SBF.HARMFUL) and _buffs then
        if not pattern or string.find(strlower(name), pattern) then
          table.insert(self.cache, name)
        end
      end
    else
      SBF.db.global.spells[name] = nil
    end
  end
  table.sort(self.cache)
  _currentSpellIndex = -1
  self:UpdateSpellList()
  self:SelectSpell()
end

SBFOptions.UpdateSpellList = function(self)
	local listIndex, spell, frame, filter, alwaysWarn, filterFrame, filter, rFilterFrame, rFilter
	local offset = FauxScrollFrame_GetOffset(SBFOSpellListScrollFrame)
	if not SBFOptions.fauxBuff then
		SBFOptions.fauxBuff = {}
	end

  for i=1,10 do
    listIndex = offset + i
    button = SBFOSpellListButtons[i]
    spell = SBFOptions.cache[listIndex]

    if spell then
      button.label:SetFormattedText(spell)
      button.index = listIndex

      filter = sbfo:FindFilter(spell)
      alwaysWarn = SBF:IsAlwaysWarn(spell, sbfo.curFrame.id)
      if filter or alwaysWarn then
        button.label:SetTextColor(GREEN_FONT_COLOR.r,GREEN_FONT_COLOR.g,GREEN_FONT_COLOR.b)
      elseif filterFrame or rFilterFrame then
        button.label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      else
        button.label:SetTextColor(GRAY_FONT_COLOR.r,GRAY_FONT_COLOR.g,GRAY_FONT_COLOR.b)
      end
    else	
      button.label:SetFormattedText("")
      button.listIndex = nil
    end

    -- Highlight selected 
    if (_currentSpellIndex == listIndex) then
      button:LockHighlight()
    else
      button:UnlockHighlight()
    end
	end
	FauxScrollFrame_Update(SBFOSpellListScrollFrame, #SBFOptions.cache, 10, 14)
end

SBFOptions.FindFilter = function(self, spell)
  if not spell then
    return
  end
  local s = string.gsub(strlower(spell), "([%-%+%?%(%)%.])", "%%%1")
  local flt = format("n=%s", s)
  for k,v in pairs(_var.filters) do
    if string.match(v, flt) then
      return k,v
    end
  end
  return nil
end

SBFOptions.SelectSpell = function(self, index)
	if index then
    _currentSpellIndex = index
  end
  if (_currentSpellIndex > 0) then
    local spell = self.cache[_currentSpellIndex]
    filterIndex,filter = self:FindFilter(spell)
    if filter then
      SBFOSpellName:SetFormattedText("%s (%s)", spell, filter)
    else
      SBFOSpellName:SetFormattedText("%s", spell)
    end
    SBFOptions:EnableCheckbox(SBFOAlwaysWarnCheckButton)
    SBFOptions:EnableCheckbox(SBFOSpellListCheckButton)
    SBFOAlwaysWarnCheckButton:SetChecked(SBF:IsAlwaysWarn(spell, sbfo.curFrame.id))
    SBFOSpellListCheckButton:SetChecked(filter ~= nil)
    if SBF:Castable(spell, (_buffs and "HELPFUL" or "HARMFUL")) then
      sbfo:EnableCheckbox(SBFOSpellCastableCheckButton)
      sbfo:EnableCheckbox(SBFOSpellMineCheckButton)
      if filter and string.match(filter, "&my") then
        SBFOSpellMineCheckButton:SetChecked(true)
        SBFOSpellCastableCheckButton:SetChecked(false)
      elseif filter and string.match(filter, "&c") then
        SBFOSpellMineCheckButton:SetChecked(false)
        SBFOSpellCastableCheckButton:SetChecked(true)
      else
        SBFOSpellMineCheckButton:SetChecked(false)
        SBFOSpellCastableCheckButton:SetChecked(false)
      end
    else
      sbfo:DisableCheckbox(SBFOSpellCastableCheckButton)
      sbfo:DisableCheckbox(SBFOSpellMineCheckButton)
    end
  else
    SBFOSpellName:SetText()
    SBFOptions:DisableCheckbox(SBFOAlwaysWarnCheckButton)
    SBFOptions:DisableCheckbox(SBFOSpellListCheckButton)
    SBFOptions:DisableCheckbox(SBFOSpellCastableCheckButton)
    SBFOptions:DisableCheckbox(SBFOSpellMineCheckButton)
    button:UnlockHighlight()
  end
	self:UpdateSpellList()
end

SBFOptions.SpellTTLEditEnterPressed = function(self, slider)
  local x = tonumber(SBFOSpellTTLEdit.edit:GetText())
  if x then
    SBF.db.global.spellTTL = x
  end
  SBFOSpellTTLEdit.edit:SetText(SBF.db.global.spellTTL)
end
