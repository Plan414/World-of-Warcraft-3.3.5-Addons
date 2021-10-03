local ScrollingDropDown = LibStub and LibStub:GetLibrary('LibScrollingDropDown-1.0')

SBFOptions.GlobalTabInitialise = function(self, var)
  SBFOHidePartyButtonText:SetFormattedText(self.strings.HIDEPARTY)
  SBFONoCasterNamesButtonText:SetFormattedText(self.strings.NOCASTERNAME)
	SBFOAuraMaxTimeCheckButton:SetChecked(SBF.db.profile.auraMaxTime)
	SBFOEnchantsFirstCheckButton:SetChecked(SBF.db.profile.enchantsFirst)
	SBFOTrackingCheckButton:SetChecked(SBF.db.profile.showTracking)
  if IsAddOnLoaded("ButtonFacade") then
    SBFODisableBFButton:Show()
    SBFODisableBFButtonText:SetFormattedText(self.strings.DISABLEBF)
    SBFODisableBFButton:SetChecked(SBF.db.global.disableBF)
  else
    SBFODisableBFButton:Hide()
  end
  
  self:TotemButtons()
  SBFOTotemNonBuffButtonText:SetText(self.strings.TOTEMNONBUFF)
  SBFOTotemOutOfRangeButtonText:SetText(self.strings.TOTEMOUTOFRANGE)
end

SBFOptions.GlobalTabSelectTab = function(self)
  SBFOHidePartyButton:SetChecked(SBF.db.global.hideParty)
end

SBFOptions.AuraMaxTime = function(self)
  SBF.db.profile.auraMaxTime = this:GetChecked()
  SBF:UpdateTracking()
end

SBFOptions.EnchantsFirst = function(self)
  SBF.db.profile.enchantsFirst = this:GetChecked()
end

SBFOptions.ShowTracking = function(self)
  SBF.db.profile.showTracking = this:GetChecked()
  if SBF.db.profile.showTracking then
    MiniMapTracking:Hide()
  else
    MiniMapTracking:Show()
  end
  SBF:UpdateTracking()
end

SBFOptions.DisableBF = function(self, checked)
  SBF.db.global.disableBF = checked
  SBF:Print("This change requires you to either reload UI or log out and back in to take effect")
end

SBFOptions.HideParty = function(self, checked)
  SBF.db.global.hideParty = checked
end

SBFOptions.CasterNames = function(self, checked)
  SBF.db.profile.settings.noCasterName = checked
end

SBFOptions.TotemTimers = function(self)
  SBF.db.profile.noTotemTimers = this:GetChecked()
  SBF.db.profile.noTotemNonBuffs = false
  self:TotemButtons()
end

SBFOptions.TotemNonBuffs = function(self)
  SBF.db.profile.noTotemNonBuffs = this:GetChecked()
  SBF.db.profile.noTotemTimers = false
  self:TotemButtons()
end

SBFOptions.TotemOutOfRange = function(self)
  SBF.db.profile.totemOutOfRange = this:GetChecked()
  SBF.db.profile.noTotemTimers = false
  self:TotemButtons()
end


SBFOptions.TotemButtons = function(self)
  if SBF.db.profile.noTotemTimers then
    self:EnableCheckbox(SBFOTotemTimersButton)
    self:DisableCheckbox(SBFOTotemNonBuffButton)
    self:DisableCheckbox(SBFOTotemOutOfRangeButton)
    SBFOTotemTimersButton:SetChecked(true)
  elseif SBF.db.profile.noTotemNonBuffs or SBF.db.profile.totemOutOfRange then
    self:DisableCheckbox(SBFOTotemTimersButton)
    self:EnableCheckbox(SBFOTotemNonBuffButton)
    self:EnableCheckbox(SBFOTotemOutOfRangeButton)
    SBFOTotemOutOfRangeButton:SetChecked(SBF.db.profile.totemOutOfRange)
    SBFOTotemNonBuffButton:SetChecked(SBF.db.profile.noTotemNonBuffs)
  else
    self:EnableCheckbox(SBFOTotemTimersButton)
    self:EnableCheckbox(SBFOTotemNonBuffButton)
    self:EnableCheckbox(SBFOTotemOutOfRangeButton)
    SBFOTotemTimersButton:SetChecked(false)
    SBFOTotemNonBuffButton:SetChecked(false)
    SBFOTotemOutOfRangeButton:SetChecked(false)
  end
end