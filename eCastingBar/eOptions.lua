local eCB_FMT_Orig_BeginFlight;
local eCB_FMT_Orig_EndFlight;
local f = CreateFrame("Button", "eCBTestButton", UIParent, "TabButtonTemplate")
f:SetText(CASTINGBAR_CASTING_TAB..CASTINGBAR_MIRROR_TAB..CASTINGBAR_TARGET_TAB..CASTINGBAR_FOCUS_TAB..CASTINGBAR_PROFILE_TAB)
eCB_Tab_Padding = ((362 - f:GetTextWidth())/5)-24

function eCastingBarOptions_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	tinsert(UISpecialFrames, "eCB_OptionFrame");
end

function eCastingBarOptions_OnEvent()
	if (event == "PLAYER_ENTERING_WORLD") then
		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
		ECB_addChat( CASTINGBAR_LOADED )
		eCB_FMT_Orig_BeginFlight = FlightMapTimes_BeginFlight;
		eCB_FMT_Orig_EndFlight = FlightMapTimes_EndFlight;
		FlightMapTimes_BeginFlight = eCB_FMT_BeginFlight;
		FlightMapTimes_EndFlight = eCB_FMT_EndFlight;
		if not eCastingBar_Saved  or eCastingBar_Saved == 1 then
			eCastingBar_Saved = {}
			ECB_addChat( CASTINGBAR_BROKENSAVE )
			eCastingBar_ResetSettings()
		end
		eCastingBar_CheckSettings()
		eCastingBar_LoadVariables()
	end
end

function eCB_FMT_BeginFlight(duration, destination)
	if eCastingBar_Saved.MirrorUseFlightTimer == 0 then
  	eCB_FMT_Orig_BeginFlight(duration, destination)
  else
    if not FlightMap.Opts.useTimer then return; end
    local endTime = 0;
    if (duration) then 
    	endTime = (duration * 1000);
    end
    eCastingBarMirror_Show("FLIGHT", endTime, endTime, -1, 0, destination)
	end
end

function eCB_FMT_EndFlight()
	this.started = false;
	for index = 1, MIRRORTIMER_NUMTIMERS, 1 do
		local frame = getglobal("eCastingBarMirror"..index);
		if ( frame.timer == "FLIGHT") then
			getglobal(frame:GetName().."Flash"):SetAlpha( 0.0 )
			getglobal(frame:GetName().."Flash"):Show()
			frame.flash = 1
			frame.fadeOut = 1
		end
	end
end
function eCastingBar_Defaults()
  eCastingBar_ResetSettings()
  eCastingBar_LoadVariables()
end

function eCastingBarConfig_OnShow()
  eCB_OptionFrame_CastingTab_Click();
end

function eCastingBar_CloseConfig()
	HideUIPanel(eCB_OptionFrame);
	getglobal("eCastingBarSettings_Setting"):SetText("")
end

function eCastingBar_ColorPicker_OnClick()
	if (ColorPickerFrame:IsShown()) then
		eCastingBar_ColorPicker_Cancelled(ColorPickerFrame.previousValues)
		ColorPickerFrame:Hide()
  else
		local Red, Green, Blue, Alpha = unpack(eCastingBar_Saved[this.objindex])
		ColorPickerFrame.previousValues = {Red, Green, Blue, Alpha}
		ColorPickerFrame.cancelFunc = eCastingBar_ColorPicker_Cancelled
		ColorPickerFrame.opacityFunc = eCastingBar_ColorPicker_OpacityChanged
		ColorPickerFrame.func = eCastingBar_ColorPicker_ColorChanged
		ColorPickerFrame.index = this:GetName().."Texture"
		ColorPickerFrame.objindex = this.objindex
		ColorPickerFrame.whenindex = this.whenindex
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = Alpha
		ColorPickerFrame:SetColorRGB(Red, Green, Blue)
		ColorPickerFrame:ClearAllPoints()
		local x = eCB_OptionFrame:GetCenter()
		if (x < UIParent:GetWidth() / 2) then
			ColorPickerFrame:SetPoint("LEFT", "eCB_OptionFrame", "RIGHT", 0, 0)
		else
			ColorPickerFrame:SetPoint("RIGHT", "eCB_OptionFrame", "LEFT", 0, 0)
		end
    ColorPickerFrame:Show()
  end
end

function eCastingBar_ColorPicker_Cancelled(color)
	eCastingBar_Saved[ColorPickerFrame.objindex] = color
  getglobal(ColorPickerFrame.index):SetVertexColor(unpack(color))
  if (ColorPickerFrame.objindex == "FlashBorderColor" 
  or ColorPickerFrame.objindex == "MirrorFlashBorderColor" 
  or ColorPickerFrame.objindex == "TargetBarFlashBorderColor"
  or ColorPickerFrame.objindex == "FocusBarFlashBorderColor") then
    eCastingBar_checkFlashBorderColors()
  end
end

function eCastingBar_ColorPicker_OpacityChanged()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	getglobal(ColorPickerFrame.index):SetVertexColor(r, g, b, a)
end

function eCastingBar_ColorPicker_ColorChanged()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	getglobal(ColorPickerFrame.index):SetVertexColor(r,g,b,a)
	if (not ColorPickerFrame:IsShown()) then
		eCastingBar_Saved[ColorPickerFrame.objindex] = {r,g,b,a}
    if (ColorPickerFrame.objindex == "FlashBorderColor" or ColorPickerFrame.objindex == "TargetBarFlashBorderColor" or ColorPickerFrame.objindex == "MirrorFlashBorderColor") then
      eCastingBar_checkFlashBorderColors()
    elseif (ColorPickerFrame.objindex == "TimeColor" or ColorPickerFrame.objindex == "TargetBarTimeColor" or ColorPickerFrame.objindex == "MirrorTimeColor") then
    	eCastingBar_checkTimeColors()
    elseif (ColorPickerFrame.objindex == "DelayColor" or ColorPickerFrame.objindex == "TargetBarDelayColor") then
    	eCastingBar_setDelayColor()
    elseif (ColorPickerFrame.objindex == "SpellColor" 
    	or ColorPickerFrame.objindex == "ChannelColor" 
    	or ColorPickerFrame.objindex == "TargetBarSpellColor" 
    	or ColorPickerFrame.objindex == "TargetBarChannelColor"  	
    	or ColorPickerFrame.objindex == "FocusBarSpellColor" 
    	or ColorPickerFrame.objindex == "FocusBarChannelColor"
    	or ColorPickerFrame.objindex == "FeignDeathColor"
    	or ColorPickerFrame.objindex == "BreathColor"
    	or ColorPickerFrame.objindex == "ExhaustionColor"
    	or ColorPickerFrame.objindex == "FlightColor")
    	then
    	eCastingBar_setColor(ColorPickerFrame.objindex);
    end
	end
end

------- [1] Tab Menu Control (by Bitz) -----------------------------------------
function eCB_OptionFrame_CastingTab_Click()
	PanelTemplates_SelectTab(eCB_OptionFrameCastingTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameMirrorTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameTargetTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameFocusTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameProfileTab);
	eCB_OptionFrameTabbedCasting:Show();
	eCB_OptionFrameTabbedMirror:Hide();
	eCB_OptionFrameTabbedTarget:Hide();
	eCB_OptionFrameTabbedFocus:Hide();
	eCB_OptionFrameTabbedProfile:Hide();
	eCastingBar_DropMenu:Hide();
	eCastingBar_checkTextures();
end

function eCB_OptionFrame_MirrorTab_Click()
	PanelTemplates_SelectTab(eCB_OptionFrameMirrorTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameCastingTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameTargetTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameFocusTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameProfileTab);
	eCB_OptionFrameTabbedCasting:Hide();
	eCB_OptionFrameTabbedMirror:Show();
	eCB_OptionFrameTabbedTarget:Hide();
	eCB_OptionFrameTabbedFocus:Hide();
	eCB_OptionFrameTabbedProfile:Hide();
	eCastingBar_DropMenu:Hide();
	eCastingBar_checkTextures();
end

function eCB_OptionFrame_TargetTab_Click()
	PanelTemplates_SelectTab(eCB_OptionFrameTargetTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameCastingTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameMirrorTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameFocusTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameProfileTab);
	eCB_OptionFrameTabbedCasting:Hide();
	eCB_OptionFrameTabbedMirror:Hide();
	eCB_OptionFrameTabbedTarget:Show();
	eCB_OptionFrameTabbedFocus:Hide();
	eCB_OptionFrameTabbedProfile:Hide();
	eCastingBar_DropMenu:Hide();
	eCastingBar_checkTextures();
end

function eCB_OptionFrame_FocusTab_Click()
	PanelTemplates_SelectTab(eCB_OptionFrameFocusTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameCastingTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameMirrorTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameTargetTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameProfileTab);
	eCB_OptionFrameTabbedCasting:Hide();
	eCB_OptionFrameTabbedMirror:Hide();
	eCB_OptionFrameTabbedTarget:Hide();
	eCB_OptionFrameTabbedFocus:Show();
	eCB_OptionFrameTabbedProfile:Hide();
	eCastingBar_DropMenu:Hide();
	eCastingBar_checkTextures();
end

function eCB_OptionFrame_ProfileTab_Click()
	PanelTemplates_SelectTab(eCB_OptionFrameProfileTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameCastingTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameMirrorTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameTargetTab);
	PanelTemplates_DeselectTab(eCB_OptionFrameFocusTab);
	eCB_OptionFrameTabbedCasting:Hide();
	eCB_OptionFrameTabbedMirror:Hide();
	eCB_OptionFrameTabbedTarget:Hide();
	eCB_OptionFrameTabbedFocus:Hide();
	eCB_OptionFrameTabbedProfile:Show();
	eCastingBar_DropMenu:Hide();
end
------- End of [1] -------------------------------------------------------------

function eCastingBar_CheckButton_OnClick()
  eCastingBar_Saved[this.index] = convertBooleanToInt(this:GetChecked())
  if (string.find(this.index, "Locked")) then
    eCastingBar_checkLocked()
  elseif (string.find(this.index, "Enabled")) then
    if (string.find(this.index, "Mirror")) then
      if (convertBooleanToInt(this:GetChecked()) == 0) then
        showAllBlizzardMirrorFrames()
      else
        hideAllBlizzardMirrorFrames()
      end
    end
    eCastingBar_checkEnabled()
  elseif (string.find(this.index, "HideBorder")) then
    eCastingBar_checkBorders()
  end
end

function convertBooleanToInt(val)
	if (val) then
		return 1
  else
    return 0
	end
end

function eCastingBarSlider_OnValueChanged()
  eCastingBar_Saved[this.index] = this:GetValue()
  if (getglobal("eCastingBar"..this.index.."EditBox")) then
    getglobal("eCastingBar"..this.index.."EditBox"):SetNumber(this:GetValue())
  end
  -- set the tool tip text
	if (this:GetValue() == floor(this:GetValue())) then
		GameTooltip:SetText(format("%d", this:GetValue()))
	else
		GameTooltip:SetText(format("%.2f", this:GetValue()))
	end
  eCastingBar_SetSize()
end

function eCastingBarSlider_OnEnter()
  -- put the tool tip in the default position
	GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
  -- set the tool tip text
	if (this:GetValue() == floor(this:GetValue())) then
		GameTooltip:SetText(format("%d", this:GetValue()))
	else
		GameTooltip:SetText(format("%.2f", this:GetValue()))
	end
	GameTooltip:Show()
end

function eCastingBarSlider_OnLeave()
	GameTooltip:Hide()
end

function eCastingBar_setAnchor(subframe, xoffset, yoffset)
	xoffset = getglobal(this:GetName().."_Label"):GetWidth() + xoffset + 5
	this:SetPoint("TOPLEFT", this:GetParent():GetName()..subframe, "BOTTOMLEFT", xoffset, yoffset)
end

function eCastingBar_Menu_TimeOut(elapsed)
	if (this.timer) then
		this.timer = this.timer - elapsed
		if (this.timer < 0) then
			this.timer = nil
			this:Hide()
		end
	end
end

function eCastingBar_Menu_Show(menu, index, controlbox)
	if (not menu) then return end
	if (eCastingBar_DropMenu:IsVisible()) then
		eCastingBar_DropMenu:Hide()
		return
	end
  
  if (menu == "SavedSettings") then
		menu = eCastingBar_MENU_SAVEDSETTINGS
	end
  
	eCastingBar_DropMenu.index = index
	eCastingBar_DropMenu.controlbox = controlbox
  
	local width = 0
	local count = 1
	local textwidth
  local frame
  
	for _,v in pairs(menu) do
    frame = getglobal("eCastingBar_DropMenu_Option"..count)
    frame:SetFrameLevel(getglobal(controlbox):GetFrameLevel())
		frame:Show()
		getglobal("eCastingBar_DropMenu_Option"..count.."_Text"):SetText(v.text)
		frame.value =v.value
		textwidth = getglobal("eCastingBar_DropMenu_Option"..count.."_Text"):GetWidth()
		if (textwidth > width) then
			width = textwidth
		end
		count = count + 1
	end
	for i=1, 40 do
		if (i < count) then
			getglobal("eCastingBar_DropMenu_Option"..i):SetWidth(width)
		else
			getglobal("eCastingBar_DropMenu_Option"..i):Hide()
		end
	end
	count = count - 1
	eCastingBar_DropMenu:SetWidth(width + 20)
	eCastingBar_DropMenu:SetHeight(count * 15 + 20)
	eCastingBar_DropMenu:ClearAllPoints()
	eCastingBar_DropMenu:SetPoint("TOPRIGHT", controlbox, "BOTTOMRIGHT", 0, 0)
	if (eCastingBar_DropMenu:GetBottom() < UIParent:GetBottom()) then
		local yoffset = UIParent:GetBottom() - eCastingBar_DropMenu:GetBottom()
		eCastingBar_DropMenu:ClearAllPoints()
		eCastingBar_DropMenu:SetPoint("TOPRIGHT", controlbox, "BOTTOMRIGHT", 0, yoffset)
	end
	eCastingBar_DropMenu:Show()
end

function eCastingBar_Menu_OnClick()
	this:GetParent():Hide()
	getglobal(eCastingBar_DropMenu.controlbox.."_Setting"):SetText(getglobal(this:GetName().."_Text"):GetText())
	if (eCastingBar_DropMenu.index == "SavedSettings") then
		eCastingBar_SETTINGS_INDEX = this.value
		eCastingBarLoadSettingsButton:Enable(); -- added by Bitz
		eCastingBarDeleteSettingsButton:Enable();
    return
  	elseif (eCastingBar_DropMenu.index == "SelectTexture") then
		eCastingBar_Saved.Texture = this.value;
		eCastingBar_checkTextures();
	elseif (eCastingBar_DropMenu.index == "MirrorSelectTexture") then
		eCastingBar_Saved.MirrorTexture = this.value
		eCastingBar_checkTextures();
	elseif (eCastingBar_DropMenu.index == "TargetBarSelectTexture") then
		eCastingBar_Saved.TargetBarTexture = this.value
		eCastingBar_checkTextures();
	elseif (eCastingBar_DropMenu.index == "FocusBarSelectTexture") then
		eCastingBar_Saved.FocusBarTexture = this.value
		eCastingBar_checkTextures();
	elseif (eCastingBar_DropMenu.index == "IconPosition") then
		eCastingBar_Saved.IconPosition = this.value
		eCastingBar_setIcons();
	elseif (eCastingBar_DropMenu.index == "TargetBarIconPosition") then
		eCastingBar_Saved.TargetBarIconPosition = this.value
		eCastingBar_setIcons();
	elseif (eCastingBar_DropMenu.index == "FocusBarIconPosition") then
		eCastingBar_Saved.FocusBarIconPosition = this.value
		eCastingBar_setIcons();
	end
end