-- ************************************************************************** --
-- * TitanSpec.lua                                                         
-- *                                                                        
-- * By: Rothpada                                                           
-- * Acknowledgements: Animammal (http://wowinterface.com/downloads/info13386-SilentRespec.html)
-- ************************************************************************** --

local TITAN_SPEC_ID = "TitanSpec";
local L = LibStub("AceLocale-3.0"):GetLocale("TitanSpec", true)
local AceTimer = LibStub("AceTimer-3.0"); 

local IS_DEBUGGING = ( false and GetRealmName() == "Shadow Council" )
                                or ( UnitName("player") == "Balther"
                                     and GetRealmName() == "Shadow Council" )
                                or ( UnitName("player") == "Rothpada"
                                    and GetRealmName() == "Broxigar" );
local SPELL_LEARNED_PATTERN = "^"..string.gsub(ERR_LEARN_SPELL_S,"%%s",".*").."$"
local ABILITY_LEARNED_PATTERN = "^"..string.gsub(ERR_LEARN_ABILITY_S,"%%s",".*").."$"
local SPELL_UNLEARNED_PATTERN = "^"..string.gsub(ERR_SPELL_UNLEARNED_S,"%%s",".*").."$"

-- ************************************************************************** --
-- ******************************** Titan Functions ************************* --
-- ************************************************************************** --

function TitanPanelTitanSpecButton_OnLoad(self)
	self.registry = {
		id = TITAN_SPEC_ID,
		menuText = L["TITAN_SPEC_MENU_TEXT"],
		buttonTextFunction = "TitanPanelTitanSpecButton_GetButtonText",
		tooltipTitle = L["TITAN_SPEC_TOOLTIP_TITLE"],
		tooltipTextFunction = "TitanPanelTitanSpecButton_GetTooltipText",
		-- frequency = 30,
		savedVariables = {
			ShowLabelText = 1,
			ShowNumbers = 1,
			ShowColours = 1,
			HideSpam = 1,
			CustomLabel = { TITAN_NIL, TITAN_NIL },
			BuildName = { TITAN_NIL, TITAN_NIL },
			BuildPts = { TITAN_NIL, TITAN_NIL },
		}	
	};
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
    self:RegisterEvent("CHAT_MSG_SYSTEM");
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", TitanSpec_spamFilter);
	
	TitanSpec_output(TITAN_SPEC_ID.." by Rothpada (Shadow Council)");
	TitanSpec_refresh();
	TitanPanelPluginHandle_OnUpdate({TITAN_SPEC_ID, TITAN_PANEL_UPDATE_ALL});
	AceTimer.ScheduleTimer(TITAN_SPEC_ID, function() 
        TitanSpec_refresh();
        TitanPanelPluginHandle_OnUpdate({TITAN_SPEC_ID, TITAN_PANEL_UPDATE_ALL});
    end, 10);
end

function TitanPanelTitanSpecButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( GetNumTalentGroups() > 1 ) then
			SetActiveTalentGroup(mod(GetActiveTalentGroup(), GetNumTalentGroups()) + 1);
		end
		
		TitanPanelPluginHandle_OnUpdate({TITAN_SPEC_ID, TITAN_PANEL_UPDATE_ALL})
	end
end

function TitanPanelTitanSpecButton_OnEvent(self, event, ...)
	TitanSpec_refresh();
	TitanPanelButton_UpdateButton(TITAN_SPEC_ID);
	TitanPanelPluginHandle_OnUpdate({TITAN_SPEC_ID, TITAN_PANEL_UPDATE_ALL});
end

function TitanSpec_refresh()	
	TitanSpec_debug("Refreshing...");
	local buildName = TitanGetVar(TITAN_SPEC_ID, "BuildName");
	if ( buildName ~= nil ) then
		buildName[GetActiveTalentGroup()] = TitanSpec_getCurrentBuildName();
		TitanSetVar(TITAN_SPEC_ID, "BuildName", buildName);
	end
	
	local buildPts = TitanGetVar(TITAN_SPEC_ID, "BuildPts");
	if ( buildPts ~= nil ) then	
		buildPts[GetActiveTalentGroup()] = TitanSpec_getCurrentBuild();	
		TitanSetVar(TITAN_SPEC_ID, "BuildPts", buildPts);
	end
end

function TitanSpec_getCurrentBuildName() 
	local b1,_,t1,_ = GetTalentTabInfo(1, false, false);
	local b2,_,t2,_ = GetTalentTabInfo(2, false, false);
	local b3,_,t3,_ = GetTalentTabInfo(3, false, false);
		
	local threshold = (t1 + t2 + t3) * 40 / 71;
	local buildTree = L["TITAN_SPEC_HYBRID"];
	if ( t1 > threshold ) then
		buildTree = b1;
	elseif ( t2 > threshold ) then
		buildTree = b2;
	elseif ( t3 > threshold ) then
		buildTree = b3;
	end	
	TitanSpec_debug("buildTree="..buildTree);
	return buildTree;
end

function TitanSpec_getCurrentBuild()
	local b1,_,t1,_ = GetTalentTabInfo(1, false, false);
	local b2,_,t2,_ = GetTalentTabInfo(2, false, false);
	local b3,_,t3,_ = GetTalentTabInfo(3, false, false);
		
	return format("%d/%d/%d",t1,t2,t3);
end

function TitanPanelTitanSpecButton_GetButtonText(id)
	local specNum = GetActiveTalentGroup();
	local label = L["TITAN_SPEC_SPEC"].." "..specNum..": ";

    -- Build the button text	
	local customLabel = TitanGetVar(TITAN_SPEC_ID, "CustomLabel");
	local buildText;
		
	if ( customLabel == nil or customLabel[specNum] == TITAN_NIL ) then
		buildText = TitanSpec_getCurrentBuildName();
	else
		buildText = customLabel[specNum];
	end
	
	if ( TitanGetVar(TITAN_SPEC_ID, "ShowNumbers") ) then
		return label, TitanSpec_getColouredText(
		    format("%s (%s)", buildText, TitanSpec_getCurrentBuild()), "white");
	end
	return label, TitanSpec_getColouredText(buildText, "white");
end

function TitanPanelTitanSpecButton_GetTooltipText(self)
	local CustomLabel = TitanGetVar(TITAN_SPEC_ID, "CustomLabel");
	local BuildName = TitanGetVar(TITAN_SPEC_ID, "BuildName");
	local BuildPts = TitanGetVar(TITAN_SPEC_ID, "BuildPts");
	
	local t1 = L["TITAN_SPEC_PRIMARY_SPEC"];
	local t2 = L["TITAN_SPEC_SECONDARY_SPEC"];
	
	if ( CustomLabel[1] ~= TITAN_NIL ) then
		t1 = t1..CustomLabel[1].." - ";
	end
	if ( BuildName[1] ~= TITAN_NIL ) then
		t1 = t1..BuildName[1];
	else
		t1 = t1.."?";
	end
	if ( BuildPts[1] ~= TITAN_NIL ) then
		t1 = t1.." ("..BuildPts[1]..")";
	else
		t1 = t1.." (?)";
	end

	if ( GetNumTalentGroups() == 2 ) then
		if ( CustomLabel[2] ~= TITAN_NIL ) then
			t2 = t2..CustomLabel[2].." - ";
		end
		if ( BuildName[2] ~= TITAN_NIL ) then
			t2 = t2..BuildName[2];
		else
			t2 = t2.."?";
		end
		if ( BuildPts[2] ~= TITAN_NIL ) then
			t2 = t2.." ("..BuildPts[2]..")";
		else
			t2 = t2.." (?)";
		end
		
		if ( TitanGetVar(TITAN_SPEC_ID, "ShowColours") ) then
			if ( GetActiveTalentGroup() == 1 ) then
				t1 = TitanSpec_getColouredText(t1, "green");
				t2 = TitanSpec_getColouredText(t2, "yellow");
			else
				t1 = TitanSpec_getColouredText(t1, "yellow");
				t2 = TitanSpec_getColouredText(t2, "green");
			end
		end
	else
		t2 = t2..L["TITAN_SPEC_NONE"];
		if ( TitanGetVar(TITAN_SPEC_ID, "ShowColours") ) then
			t1 = TitanSpec_getColouredText(t1, "green");
			t2 = TitanSpec_getColouredText(t2, "red");
		end
	end
	return "\n"..t1.."\n"..t2.."\n".."\n"..L["TITAN_SPEC_HINT"];		
end

function TitanPanelRightClickMenu_PrepareTitanSpecMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SPEC_ID].menuText);
	TitanPanelRightClickMenu_AddSpacer();
	
	local info = {};
	info.text = L["TITAN_SPEC_RENAME"];
	info.func = function()
		StaticPopupDialogs["TITAN_SPEC_RENAME_DIALOG"] = {
		  text = L["TITAN_SPEC_RENAME_TEXT"],
		  button1 = L["TITAN_SPEC_ACCEPT"],
		  button2 = L["TITAN_SPEC_CANCEL"],
		  OnAccept = function()
		  	local newName = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		  	local labels = TitanGetVar(TITAN_SPEC_ID, "CustomLabel");
			labels[GetActiveTalentGroup()] = newName;
			TitanSetVar(TITAN_SPEC_ID, "CustomLabel", labels);
			TitanPanelButton_UpdateButton(TITAN_SPEC_ID);
		  end,
		  timeout = 0,
		  whileDead = 1,
		  hideOnEscape = 1,
		  hasEditBox = 1
		};
		StaticPopup_Show("TITAN_SPEC_RENAME_DIALOG");
	end
	UIDropDownMenu_AddButton(info);
	
	TitanPanelRightClickMenu_AddSpacer();
	
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_SPEC_SHOW_COLOURS"], TITAN_SPEC_ID, "ShowColours");
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_SPEC_HIDE_SPAM"], TITAN_SPEC_ID, "HideSpam");
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_SPEC_SHOW_BUILD"], TITAN_SPEC_ID, "ShowNumbers");
 	TitanPanelRightClickMenu_AddToggleLabelText(TITAN_SPEC_ID);
		
	TitanPanelRightClickMenu_AddSpacer();
	
	info = {};
	info.text = L["TITAN_SPEC_RESET"];	
	info.func = function()
		TitanSetVar(TITAN_SPEC_ID, "ShowLabelText", 1);
		TitanSetVar(TITAN_SPEC_ID, "ShowNumbers", 1);
		TitanSetVar(TITAN_SPEC_ID, "ShowColours", 1);
		TitanSetVar(TITAN_SPEC_ID, "HideSpam", 1);
		TitanSetVar(TITAN_SPEC_ID, "CustomLabel", { TITAN_NIL, TITAN_NIL });
		TitanSetVar(TITAN_SPEC_ID, "BuildPts", { TITAN_NIL, TITAN_NIL });
		TitanSetVar(TITAN_SPEC_ID, "BuildName", { TITAN_NIL, TITAN_NIL });
		TitanSpec_refresh();
		TitanPanelButton_UpdateButton(TITAN_SPEC_ID);
	end
	UIDropDownMenu_AddButton(info);
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_SPEC_HIDE"], TITAN_SPEC_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- ************************************************************************** --
-- ******************************** User Functions ************************** --
-- ************************************************************************** --

function TitanSpec_debug(msg)
	if IS_DEBUGGING then
		TitanSpec_output(msg);
	end
end

function TitanSpec_output(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1);
end


function TitanSpec_getColouredText(msg, colour)
	local colourCode = "";
	
	if ( colour == nil or colour == "default" ) then
		return msg;
	elseif ( colour == "red" ) then
		colourCode = "|cffff0000";
	elseif ( colour == "green" ) then
		colourCode = "|cff00ff00";
	elseif ( colour == "blue" ) then
		colourCode = "|cff0000ff";
	elseif ( colour == "yellow" ) then
		colourCode = "|cffffff00";
	elseif ( colour == "white" ) then
		colourCode = "|cffffffff";
	elseif ( colour == "black" ) then
		colourCode = "|cff000000";
	else
		colourCode = "|cff"..colour;
	end
        
	return colourCode..msg..FONT_COLOR_CODE_CLOSE;
end

function TitanSpec_spamFilter(self, event, ...)
	local msg = arg1;
	if ( ( strfind(msg, SPELL_LEARNED_PATTERN) or strfind(msg, ABILITY_LEARNED_PATTERN) 
										or strfind(msg, SPELL_UNLEARNED_PATTERN) )
										and TitanGetVar(TITAN_SPEC_ID, "HideSpam") ) then
		return true, args;
	end
	return false, args;
end
