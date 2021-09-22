-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>
-- Major updates by
-- Oozebull of Twisting Nether
-- Banjankri of Blackrock
-- --------------------


function TellMeWhen_SlashCommand(cmd)
	if ( cmd == TELLMEWHEN_CMD_RESET ) then
		TellMeWhen_Reset();
	elseif (cmd == TELLMEWHEN_CMD_OPTIONS) then
		TellMeWhen_ShowConfig();
	else
		TellMeWhen_LockToggle();
	end
end

-- -----------------------
-- INTERFACE OPTIONS PANEL
-- -----------------------

function TellMeWhen_GroupPositionReset_OnClick(self)
	local groupID = self:GetParent():GetID();
	local locked = TellMeWhen_Settings["Locked"];
	if ( locked ) then
		TellMeWhen_Settings["Locked"] = false;
		TellMeWhen_Group_Update(groupID);
	end
	local group = getglobal("TellMeWhen_Group"..groupID);
	group:SetPoint("CENTER", "WorldFrame", "CENTER");
	group["Scale"] = 2.0
	TellMeWhen_Group_Update(groupID);
	if ( locked ) then
		TellMeWhen_Settings["Locked"] = true;
		TellMeWhen_Group_Update(groupID);
	end
	DEFAULT_CHAT_FRAME:Add_Message("TellMeWhen Group "..groupID.." position reset.");
end

function TellMeWhen_GroupEnableButton_OnClick(self)
	local groupID = self:GetParent():GetID();
	if ( self:GetChecked() ) then
		TellMeWhen_Settings["Groups"][groupID]["Enabled"] = true;
	else
		TellMeWhen_Settings["Groups"][groupID]["Enabled"] = false;
	end
	TellMeWhen_Group_Update(groupID);
end

function TellMeWhen_GroupEnableButton_Update(self)
	local groupID = self:GetParent():GetID();
	self:SetChecked(TellMeWhen_Settings["Groups"][groupID]["Enabled"]);
end

function TellMeWhen_RowColumnsWidget_Update(self, variable)
	local groupID = self:GetParent():GetID();
	local number = TellMeWhen_Settings["Groups"][groupID][variable];
	local text = getglobal(self:GetName().."Text");
	local leftButton = getglobal(self:GetName().."LeftButton");
	local rightButton = getglobal(self:GetName().."RightButton");
	text:SetText(number);
	leftButton:Enable();
	rightButton:Enable();
	if ( number == 1 ) then
		leftButton:Disable();
	elseif ( number == TELLMEWHEN_MAXROWS ) then
		rightButton:Disable();
	end
end

function TellMeWhen_RowColumnsButton_OnClick(self, variable, increment)
	local groupID = self:GetParent():GetParent():GetID();
	local oldNumber = TellMeWhen_Settings["Groups"][groupID][variable];
	if ( oldNumber == 1 ) and ( increment < 0 ) then
		return;
	elseif ( oldNumber == TELLMEWHEN_MAXROWS ) and ( increment > 0 ) then
		return;
	end
	TellMeWhen_Settings["Groups"][groupID][variable] = oldNumber + increment;
	TellMeWhen_Group_Update(groupID);
	TellMeWhen_RowColumnsWidget_Update(self:GetParent(), variable);
end

function TellMeWhen_OnlyInCombatButton_Update(self)
	self:SetChecked(TellMeWhen_Settings["Groups"][self:GetParent():GetID()]["OnlyInCombat"]);
end

function TellMeWhen_PrimarySpecButton_Update(self)
	self:SetChecked(TellMeWhen_Settings["Groups"][self:GetParent():GetID()]["PrimarySpec"]);
end

function TellMeWhen_SecondarySpecButton_Update(self)
	self:SetChecked(TellMeWhen_Settings["Groups"][self:GetParent():GetID()]["SecondarySpec"]);
end



function TellMeWhen_OnlyInCombatButton_OnClick(self)
	local groupID = self:GetParent():GetID();
	if ( self:GetChecked() ) then
		TellMeWhen_Settings["Groups"][groupID]["OnlyInCombat"] = true;
	else
		TellMeWhen_Settings["Groups"][groupID]["OnlyInCombat"] = false;
	end
	TellMeWhen_Group_Update(groupID);
end

function TellMeWhen_PrimarySpecButton_OnClick(self)
	local groupID = self:GetParent():GetID();
	if ( self:GetChecked() ) then
		TellMeWhen_Settings["Groups"][groupID]["PrimarySpec"] = true;
	else
		TellMeWhen_Settings["Groups"][groupID]["PrimarySpec"] = false;
	end
	TellMeWhen_Group_Update(groupID);
end


function TellMeWhen_SecondarySpecButton_OnClick(self)
	local groupID = self:GetParent():GetID();
	if ( self:GetChecked() ) then
		TellMeWhen_Settings["Groups"][groupID]["SecondarySpec"] = true;
	else
		TellMeWhen_Settings["Groups"][groupID]["SecondarySpec"] = false;
	end
	TellMeWhen_Group_Update(groupID);
end


function TellMeWhen_LockUnlockButton_Update(self)
	local locked = TellMeWhen_Settings["Locked"];
	local text = getglobal(self:GetName().."Text");
	if ( locked ) then
		text:SetText(TELLMEWHEN_UIPANEL_UNLOCK);
	else
		text:SetText(TELLMEWHEN_UIPANEL_LOCK);
	end
end

function TellMeWhen_LockToggle()
	if ( TellMeWhen_Settings["Locked"] ) then
		TellMeWhen_Settings["Locked"] = false;
	else
		TellMeWhen_Settings["Locked"] = true;
	end
	PlaySound("UChatScrollButton");
	TellMeWhen_Update();
end

function TellMeWhen_Reset()
	TellMeWhen_Settings = CopyTable(TellMeWhen_Defaults);
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		local group = getglobal("TellMeWhen_Group"..groupID);
		group:ClearAllPoints();
		group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 100, -50 - 30*groupID);
		TellMeWhen_Settings["Groups"][groupID]["Enabled"] = false;
	end
	TellMeWhen_Settings["Groups"][1]["Enabled"] = true;
	TellMeWhen_Update();			-- default setting is unlocked?
	TellMeWhen_UIPanelUpdate();
	DEFAULT_CHAT_FRAME:AddMessage("[TellMeWhen]: Groups have been Reset");
end

function TellMeWhen_ShowConfig()
	local uIPanel = getglobal("InterfaceOptionsTellMeWhenPanel");
	InterfaceOptionsFrame_OpenToCategory(uIPanel);
end

function TellMeWhen_UIPanelUpdate()
	local uIPanel = getglobal("InterfaceOptionsTellMeWhenPanel");
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		local enableButton = getglobal(uIPanel:GetName().."Group"..groupID.."EnableButton");
		local columnsWidget = getglobal(uIPanel:GetName().."Group"..groupID.."ColumnsWidget");
		local rowsWidget = getglobal(uIPanel:GetName().."Group"..groupID.."RowsWidget");
		local onlyInCombatButton = getglobal(uIPanel:GetName().."Group"..groupID.."OnlyInCombatButton");
		local PrimarySpecButton = getglobal(uIPanel:GetName().."Group"..groupID.."PrimarySpecButton");
		local SecondarySpecButton = getglobal(uIPanel:GetName().."Group"..groupID.."SecondarySpecButton");
		TellMeWhen_GroupEnableButton_Update(enableButton);
		TellMeWhen_RowColumnsWidget_Update(columnsWidget, "Columns");
		TellMeWhen_RowColumnsWidget_Update(rowsWidget, "Rows");
		TellMeWhen_OnlyInCombatButton_Update(onlyInCombatButton);
		TellMeWhen_PrimarySpec_Update(PrimarySpecButton);
		TellMeWhen_SecondarySpec_Update(SecondarySpecButton);
	end
	lockUnlockButton = getglobal("InterfaceOptionsTellMeWhenPanelLockUnlockButton");
	TellMeWhen_LockUnlockButton_Update(lockUnlockButton);
end

function TellMeWhen_Cancel()
	TellMeWhen_Settings = CopyTable(TellMeWhen_OldSettings);
	TellMeWhen_Update();
end



-- --------
-- ICON GUI
-- --------

TellMeWhen_CurrentIcon = { groupID = 1, iconID = 1 };		-- a dirty hack, i know.

StaticPopupDialogs["TELLMEWHEN_CHOOSENAME_DIALOG"] = {
	text = TELLMEWHEN_CHOOSENAME_DIALOG,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 200,
	OnShow = function()
		local groupID = TellMeWhen_CurrentIcon["groupID"];
		local iconID = TellMeWhen_CurrentIcon["iconID"];
		local text = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"];
		getglobal(this:GetName().."EditBox"):SetText(text);
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnAccept = function(iconNumber)
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		TellMeWhen_IconMenu_ChooseName(text);
	end,
	EditBoxOnEnterPressed = function(iconNumber)
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		TellMeWhen_IconMenu_ChooseName(text);
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	OnHide = function()
		if ( ChatFrameEditBox and ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

TellMeWhen_IconMenu_CooldownOptions = {
	{ VariableName = "CooldownType", MenuText = TELLMEWHEN_ICONMENU_COOLDOWNTYPE, HasSubmenu = true },
	{ VariableName = "CooldownShowWhen", MenuText = TELLMEWHEN_ICONMENU_SHOWWHEN, HasSubmenu = true },
	{ VariableName = "ShowTimer", MenuText = TELLMEWHEN_ICONMENU_SHOWTIMER },
};

TellMeWhen_IconMenu_ReactiveOptions = {
	{ VariableName = "CooldownShowWhen", MenuText = TELLMEWHEN_ICONMENU_SHOWWHEN, HasSubmenu = true},
	{ VariableName = "ShowTimer", MenuText = TELLMEWHEN_ICONMENU_SHOWTIMER },
};

TellMeWhen_IconMenu_BuffOptions = {
	{ VariableName = "BuffOrDebuff", MenuText = TELLMEWHEN_ICONMENU_BUFFTYPE, HasSubmenu = true },
	{ VariableName = "Unit", MenuText = TELLMEWHEN_ICONMENU_UNIT, HasSubmenu = true },
	{ VariableName = "BuffShowWhen", MenuText = TELLMEWHEN_ICONMENU_BUFFSHOWWHEN, HasSubmenu = true },
	{ VariableName = "ShowTimer", MenuText = TELLMEWHEN_ICONMENU_SHOWTIMER },
	{ VariableName = "OnlyMine", MenuText = TELLMEWHEN_ICONMENU_ONLYMINE },
};

TellMeWhen_IconMenu_WpnEnchantOptions = {
	{ VariableName = "WpnEnchantType", MenuText = TELLMEWHEN_ICONMENU_WPNENCHANTTYPE, HasSubmenu = true },
	{ VariableName = "BuffShowWhen", MenuText = TELLMEWHEN_ICONMENU_SHOWWHEN, HasSubmenu = true },
	{ VariableName = "ShowTimer", MenuText = TELLMEWHEN_ICONMENU_SHOWTIMER },
};

TellMeWhen_IconMenu_TotemOptions = {
	{ VariableName = "Unit", MenuText = TELLMEWHEN_ICONMENU_UNIT, HasSubmenu = true },
	{ VariableName = "BuffShowWhen", MenuText = TELLMEWHEN_ICONMENU_SHOWWHEN, HasSubmenu = true },
	{ VariableName = "ShowTimer", MenuText = TELLMEWHEN_ICONMENU_SHOWTIMER },
};

TellMeWhen_IconMenu_SubMenus = {
	-- the keys on this table need to match the settings variable names
	Type = {
	  	{ Setting = "cooldown", MenuText = TELLMEWHEN_ICONMENU_COOLDOWN },
	  	{ Setting = "buff", MenuText = TELLMEWHEN_ICONMENU_BUFFDEBUFF },
	  	{ Setting = "reactive", MenuText = TELLMEWHEN_ICONMENU_REACTIVE },
	  	{ Setting = "wpnenchant", MenuText = TELLMEWHEN_ICONMENU_WPNENCHANT },
		{ Setting = "totem", MenuText = TELLMEWHEN_ICONMENU_TOTEM },
	},
	CooldownType = {
	  	{ Setting = "spell", MenuText = TELLMEWHEN_ICONMENU_SPELL },
	  	{ Setting = "item", MenuText = TELLMEWHEN_ICONMENU_ITEM },
	},
	BuffOrDebuff = {
	  	{ Setting = "HELPFUL", MenuText = TELLMEWHEN_ICONMENU_BUFF },
	  	{ Setting = "HARMFUL", MenuText = TELLMEWHEN_ICONMENU_DEBUFF },
	},
	Unit = {
		{ Setting = "player", MenuText = TELLMEWHEN_ICONMENU_PLAYER },
		{ Setting = "target", MenuText = TELLMEWHEN_ICONMENU_TARGET },
		{ Setting = "targettarget", MenuText = TELLMEWHEN_ICONMENU_TARGETTARGET },
		{ Setting = "focus", MenuText = TELLMEWHEN_ICONMENU_FOCUS },
		{ Setting = "focustarget", MenuText = TELLMEWHEN_ICONMENU_FOCUSTARGET },
		{ Setting = "pet", MenuText = TELLMEWHEN_ICONMENU_PET },
		{ Setting = "pettarget", MenuText = TELLMEWHEN_ICONMENU_PETTARGET },
	},
	BuffShowWhen = {
	  	{ Setting = "present", MenuText = TELLMEWHEN_ICONMENU_PRESENT },
	  	{ Setting = "absent", MenuText = TELLMEWHEN_ICONMENU_ABSENT },
	  	{ Setting = "always", MenuText = TELLMEWHEN_ICONMENU_ALWAYS },
	},
	CooldownShowWhen = {
	  	{ Setting = "usable", MenuText = TELLMEWHEN_ICONMENU_USABLE },
	  	{ Setting = "unusable", MenuText = TELLMEWHEN_ICONMENU_UNUSABLE },
	  	{ Setting = "always", MenuText = TELLMEWHEN_ICONMENU_ALWAYS },
	},
	WpnEnchantType = {
	  	{ Setting = "mainhand", MenuText = TELLMEWHEN_ICONMENU_MAINHAND },
	  	{ Setting = "offhand", MenuText = TELLMEWHEN_ICONMENU_OFFHAND },
	},
};


function TellMeWhen_Icon_OnEnter(self, motion)
	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	GameTooltip:AddLine(TELLMEWHEN_ICON_TOOLTIP1, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:AddLine(TELLMEWHEN_ICON_TOOLTIP2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	GameTooltip:Show();
end

function TellMeWhen_Icon_OnMouseDown(self, button)
	if ( button == "RightButton" ) then
 		PlaySound("UChatScrollButton");
		TellMeWhen_CurrentIcon["iconID"] = self:GetID();		-- yay for dirty hacks
		TellMeWhen_CurrentIcon["groupID"] = self:GetParent():GetID();
		ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDown"), "cursor", 0, 0);
 	end
end

function TellMeWhen_IconMenu_Initialize()

	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];

	local name = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"];
	local iconType = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Type"];
	local enabled = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Enabled"];

	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		local subMenus = TellMeWhen_IconMenu_SubMenus;
		for index, value in ipairs(subMenus[UIDROPDOWNMENU_MENU_VALUE]) do
			-- here, UIDROPDOWNMENU_MENU_VALUE is the setting name
			local info = UIDropDownMenu_CreateInfo();
			info.text = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["MenuText"];
			info.value = subMenus[UIDROPDOWNMENU_MENU_VALUE][index]["Setting"];
			info.checked = ( info.value == TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][UIDROPDOWNMENU_MENU_VALUE] );
			info.func = TellMeWhen_IconMenu_ChooseSetting;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return;
	end

	-- show name
	if ( name ) and ( name ~= "" ) then
		local info = UIDropDownMenu_CreateInfo();
		info.text = name;
		info.isTitle = true;
		UIDropDownMenu_AddButton(info);
	end

	-- choose name
	if ( iconType ~= "wpnenchant" ) then
		info = UIDropDownMenu_CreateInfo();
		info.value = "TELLMEWHEN_ICONMENU_CHOOSENAME";
		info.text = TELLMEWHEN_ICONMENU_CHOOSENAME;
		info.func = TellMeWhen_IconMenu_ShowNameDialog;
		UIDropDownMenu_AddButton(info);
	end

	-- enable icon
	info = UIDropDownMenu_CreateInfo();
	info.value = "Enabled";
	info.text = TELLMEWHEN_ICONMENU_ENABLE;
	info.checked = enabled;
	info.func = TellMeWhen_IconMenu_ToggleSetting;
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info);

	-- icon type
	info = UIDropDownMenu_CreateInfo();
	info.value = "Type";
	info.text = TELLMEWHEN_ICONMENU_TYPE;
	info.hasArrow = true;
	UIDropDownMenu_AddButton(info);

	-- additional options
	if ( iconType == "cooldown" )
	or ( iconType == "buff" )
	or ( iconType == "reactive" )
	or ( iconType == "wpnenchant" )
	or ( iconType == "totem" )
	then
		info = UIDropDownMenu_CreateInfo();
		info.disabled = true;
		UIDropDownMenu_AddButton(info);

		local moreOptions;
		if ( iconType == "cooldown" ) then
			moreOptions = TellMeWhen_IconMenu_CooldownOptions;
		elseif ( iconType == "buff" ) then
			moreOptions = TellMeWhen_IconMenu_BuffOptions;
		elseif ( iconType == "reactive" ) then
			moreOptions = TellMeWhen_IconMenu_ReactiveOptions;
		elseif ( iconType == "wpnenchant" ) then
			moreOptions = TellMeWhen_IconMenu_WpnEnchantOptions;
		elseif ( iconType == "totem" ) then
			moreOptions = TellMeWhen_IconMenu_TotemOptions;
		end

		for index, value in ipairs(moreOptions) do
			info = UIDropDownMenu_CreateInfo();
			info.text = moreOptions[index]["MenuText"];
			info.value = moreOptions[index]["VariableName"];
			info.hasArrow = moreOptions[index]["HasSubmenu"];
			if not info.hasArrow then
				info.func = TellMeWhen_IconMenu_ToggleSetting;
				info.checked = TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][info.value];
			end
			info.keepShownOnClick = true;
			UIDropDownMenu_AddButton(info);
		end

	else
		info = UIDropDownMenu_CreateInfo();
		info.text = TELLMEWHEN_ICONMENU_OPTIONS;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	end

	-- clear settings
	if (( name ) and ( name ~= "" )) or ( iconType ~= "" ) then

		info = UIDropDownMenu_CreateInfo();
		info.disabled = true;
		UIDropDownMenu_AddButton(info);

		info = UIDropDownMenu_CreateInfo();
		info.text = TELLMEWHEN_ICONMENU_CLEAR;
		info.func = TellMeWhen_IconMenu_ClearSettings;
		UIDropDownMenu_AddButton(info);
	end

end

function TellMeWhen_IconMenu_ShowNameDialog()
	local dialog = StaticPopup_Show("TELLMEWHEN_CHOOSENAME_DIALOG");
end

function TellMeWhen_IconMenu_ChooseName(text)
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID]["Name"] = text;
	getglobal("TellMeWhen_Group"..groupID.."_Icon"..iconID).learnedTexture = nil;
	TellMeWhen_Icon_Update(getglobal("TellMeWhen_Group"..groupID.."_Icon"..iconID), groupID, iconID);
end

function TellMeWhen_IconMenu_ToggleSetting()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][this.value] = this.checked;
	TellMeWhen_Icon_Update(getglobal("TellMeWhen_Group"..groupID.."_Icon"..iconID), groupID, iconID);
end

function TellMeWhen_IconMenu_ChooseSetting()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID][UIDROPDOWNMENU_MENU_VALUE] = this.value;
	TellMeWhen_Icon_Update(getglobal("TellMeWhen_Group"..groupID.."_Icon"..iconID), groupID, iconID);
	if ( UIDROPDOWNMENU_MENU_VALUE == "Type" ) then
		CloseDropDownMenus();
	end
end

function TellMeWhen_IconMenu_ClearSettings()
	local groupID = TellMeWhen_CurrentIcon["groupID"];
	local iconID = TellMeWhen_CurrentIcon["iconID"];
	TellMeWhen_Settings["Groups"][groupID]["Icons"][iconID] = CopyTable(TellMeWhen_Icon_Defaults);
	TellMeWhen_Icon_Update(getglobal("TellMeWhen_Group"..groupID.."_Icon"..iconID), groupID, iconID);
	CloseDropDownMenus();
end



-- -------------
-- RESIZE BUTTON
-- -------------

function TellMeWhen_GUIButton_OnEnter(self, shortText, longText)
	local tooltip = getglobal("GameTooltip");
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(tooltip, self);
		tooltip:AddLine(shortText, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
		tooltip:AddLine(longText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		tooltip:Show();
	else
		tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		tooltip:SetText(shortText);
	end
end

function TellMeWhen_StartSizing(self, button)
	local scalingFrame = self:GetParent();
	scalingFrame.oldScale = scalingFrame:GetScale();
	self.oldCursorX, self.oldCursorY = GetCursorPosition(UIParent);
	scalingFrame.oldX = scalingFrame:GetLeft();
	scalingFrame.oldY = scalingFrame:GetTop();
	self:SetScript("OnUpdate", TellMeWhen_SizeUpdate);
end

function TellMeWhen_SizeUpdate(self)
	local uiScale = UIParent:GetScale();
	local scalingFrame = self:GetParent();
	local cursorX, cursorY = GetCursorPosition(UIParent);

	-- calculate new scale
	local newXScale = scalingFrame.oldScale * (cursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale) / (self.oldCursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale) ;
	local newYScale = scalingFrame.oldScale * (cursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale) / (self.oldCursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale) ;
	local newScale = max(0.6, newXScale, newYScale);
	scalingFrame:SetScale(newScale);

	-- calculate new frame position
	local newX = scalingFrame.oldX * scalingFrame.oldScale / newScale;
	local newY = scalingFrame.oldY * scalingFrame.oldScale / newScale;
	scalingFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", newX, newY);
end

function TellMeWhen_StopSizing(self, button)
	self:SetScript("OnUpdate", nil)
	TellMeWhen_Settings["Groups"][self:GetParent():GetID()]["Scale"] = self:GetParent():GetScale();
end


