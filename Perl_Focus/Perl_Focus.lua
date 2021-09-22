---------------
-- Variables --
---------------
Perl_Focus_Config = {};
local Perl_Focus_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Focus_GetVars)
local locked = 0;		-- unlocked by default
local showclassicon = 1;	-- show the class icon
local showclassframe = 1;	-- show the class frame
local showpvpicon = 1;		-- show the pvp icon
local numbuffsshown = 16;	-- buff row is 16 long
local numdebuffsshown = 16;	-- debuff row is 16 long
local scale = 0.9;		-- default scale
local transparency = 1;		-- transparency for frames
local buffdebuffscale = 1;	-- default scale for buffs and debuffs
local showportrait = 0;		-- portrait is hidden by default
local threedportrait = 0;	-- 3d portraits are off by default
local portraitcombattext = 0;	-- Combat text is disabled by default on the portrait frame
local showrareeliteframe = 0;	-- rare/elite frame is hidden by default
local nameframecombopoints = 0;	-- combo points are not displayed in the name frame by default
local comboframedebuffs = 0;	-- combo point frame will not be used for debuffs by default
local framestyle = 1;		-- default frame style is "classic"
local compactmode = 0;		-- compact mode is disabled by default
local compactpercent = 0;	-- percents are not shown in compact mode by default
local hidebuffbackground = 0;	-- buff and debuff backgrounds are shown by default
local shortbars = 0;		-- Health/Power/Experience bars are all normal length
local healermode = 0;		-- nurfed unit frame style
local displaycastablebuffs = 0;	-- display all buffs by default
local classcolorednames = 0;	-- names are colored based on pvp status by default
local showmanadeficit = 0;	-- Mana deficit in healer mode is off by default
local invertbuffs = 0;		-- buffs and debuffs are below the Focus frame by default
local displaycurabledebuff = 0;	-- display all debuffs by default
local displaybufftimers = 1;	-- buff/debuff timers are on by default
local displayonlymydebuffs = 0;	-- display all debuffs by default

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized

-- Fade Bar Variables
local Perl_Focus_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Focus_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Focus_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Focus_ManaBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0

-- Local variables to save memory
local focushealth, focushealthmax, focushealthpercent, focusmana, focusmanamax, focusmanapercent, focuspower, focuslevel, focuslevelcolor, focusclassification, focusclassificationframetext, englishclass, creatureType, r, g, b, bufffilter, debufffilter;


----------------------
-- Loading Function --
----------------------
function Perl_Focus_OnLoad(self)
	-- Combat Text
	CombatFeedback_Initialize(self, Perl_Focus_HitIndicator, 30);

	-- Events
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_DYNAMIC_FLAGS");
	self:RegisterEvent("UNIT_ENERGY");
	self:RegisterEvent("UNIT_FOCUS");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_MANA");
	self:RegisterEvent("UNIT_MAXENERGY");
	self:RegisterEvent("UNIT_MAXFOCUS");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_MAXMANA");
	self:RegisterEvent("UNIT_MAXRAGE");
	self:RegisterEvent("UNIT_MAXRUNIC_POWER");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_PVP_UPDATE");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("UNIT_RAGE");
	self:RegisterEvent("UNIT_RUNIC_POWER");
	self:RegisterEvent("UNIT_SPELLMISS");
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
	self:RegisterEvent("VOICE_START");
	self:RegisterEvent("VOICE_STOP");

	-- Scripts
	self:SetScript("OnEvent", Perl_Focus_OnEvent);
	self:SetScript("OnUpdate", CombatFeedback_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Focus_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_NameFrame:GetFrameLevel() + 2);
	Perl_Focus_Name:SetFrameLevel(Perl_Focus_NameFrame:GetFrameLevel() + 1);
	Perl_Focus_LevelFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_LevelFrame:GetFrameLevel() + 1);
	Perl_Focus_RareEliteFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_RareEliteFrame:GetFrameLevel() + 1);
	Perl_Focus_PortraitFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_PortraitFrame:GetFrameLevel() + 2);
	Perl_Focus_PortraitTextFrame:SetFrameLevel(Perl_Focus_PortraitFrame:GetFrameLevel() + 1);
	Perl_Focus_ClassNameFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_ClassNameFrame:GetFrameLevel() + 1);
	Perl_Focus_CivilianFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_CivilianFrame:GetFrameLevel() + 1);
	Perl_Focus_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Focus_StatsFrame:GetFrameLevel() + 1);
	Perl_Focus_RaidIconFrame:SetFrameLevel(Perl_Focus_PortraitFrame_CastClickOverlay:GetFrameLevel() - 1);
	Perl_Focus_HealthBarFadeBar:SetFrameLevel(Perl_Focus_HealthBar:GetFrameLevel() - 1);
	Perl_Focus_ManaBarFadeBar:SetFrameLevel(Perl_Focus_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "focus");

	-- Misc
	self.unit = "focus";
end


-------------------
-- Event Handler --
-------------------
function Perl_Focus_OnEvent()
	local func = Perl_Focus_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Focus: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Focus_Events:PLAYER_FOCUS_CHANGED()
	if (UnitExists(Perl_Focus_Frame:GetAttribute("unit"))) then
		Perl_Focus_Update_Once();		-- Set the unchanging info for the Focus
	end
end
Perl_Focus_Events.PARTY_MEMBERS_CHANGED = Perl_Focus_Events.PLAYER_FOCUS_CHANGED;
Perl_Focus_Events.PARTY_MEMBER_ENABLE = Perl_Focus_Events.PLAYER_FOCUS_CHANGED;
Perl_Focus_Events.PARTY_MEMBER_DISABLE = Perl_Focus_Events.PLAYER_FOCUS_CHANGED;

function Perl_Focus_Events:UNIT_HEALTH()
	if (arg1 == "focus") then
		Perl_Focus_Update_Health();		-- Update health values
	end
end
Perl_Focus_Events.UNIT_MAXHEALTH = Perl_Focus_Events.UNIT_HEALTH;

function Perl_Focus_Events:UNIT_ENERGY()
	if (arg1 == "focus") then
		Perl_Focus_Update_Mana();		-- Update energy/mana/rage values
	end
end
Perl_Focus_Events.UNIT_MAXENERGY = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_MANA = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_MAXMANA = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_RAGE = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_MAXRAGE = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_FOCUS = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_MAXFOCUS = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_RUNIC_POWER = Perl_Focus_Events.UNIT_ENERGY;
Perl_Focus_Events.UNIT_MAXRUNIC_POWER = Perl_Focus_Events.UNIT_ENERGY;

function Perl_Focus_Events:UNIT_AURA()
	if (arg1 == "focus") then
		Perl_Focus_Buff_UpdateAll();		-- Update the buffs
	end
end

function Perl_Focus_Events:UNIT_DYNAMIC_FLAGS()
	if (arg1 == "focus") then
		Perl_Focus_Update_Text_Color();		-- Has the Focus been tapped by someone else?
	end
end

function Perl_Focus_Events:UNIT_COMBAT()
	if (arg1 == "focus") then
		CombatFeedback_OnCombatEvent(Perl_Focus_Frame, arg2, arg3, arg4, arg5);
	end
end

function Perl_Focus_Events:UNIT_SPELLMISS()
	if (arg1 == "focus") then
		CombatFeedback_OnSpellMissEvent(arg2);
	end
end

function Perl_Focus_Events:UNIT_NAME_UPDATE()
	if (arg1 == "focus") then
		Perl_Focus_Frame_Set_Level();
		Perl_Focus_Update_Name();
	end
end

function Perl_Focus_Events:UNIT_FACTION()
	Perl_Focus_Update_Text_Color();			-- Is the character PvP flagged?
	Perl_Focus_Update_PvP_Status_Icon();		-- Set pvp status icon
end
Perl_Focus_Events.UNIT_PVP_UPDATE = Perl_Focus_Events.UNIT_FACTION;

function Perl_Focus_Events:UNIT_PORTRAIT_UPDATE()
	if (arg1 == "focus") then
		Perl_Focus_Update_Portrait();
	end
end

function Perl_Focus_Events:RAID_TARGET_UPDATE()
	Perl_Focus_UpdateRaidFocusIcon();
end

function Perl_Focus_Events:UNIT_LEVEL()
	if (arg1 == "focus") then
		Perl_Focus_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
	end
end

function Perl_Focus_Events:UNIT_DISPLAYPOWER()
	if (arg1 == "focus") then
		Perl_Focus_Update_Mana_Bar();		-- What type of energy are they using now?
		Perl_Focus_Update_Mana();		-- Update the energy info immediately
	end
end

function Perl_Focus_Events:VOICE_START()
	if (arg1 == "focus") then
		Perl_Focus_VoiceChatIconFrame:Show();
	end
end

function Perl_Focus_Events:VOICE_STOP()
	if (arg1 == "focus") then
		Perl_Focus_VoiceChatIconFrame:Hide();
	end
end

function Perl_Focus_Events:UNIT_THREAT_LIST_UPDATE()
	if (arg1 == "focus") then
		Perl_Focus_Update_Threat();
	end
end

function Perl_Focus_Events:PLAYER_LOGIN()
	Perl_Focus_Initialize();
end
Perl_Focus_Events.PLAYER_ENTERING_WORLD = Perl_Focus_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Focus_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Focus_Set_Scale_Actual();		-- Set the scale
		Perl_Focus_Set_Transparency();		-- Set the transparency
		if (UnitExists("focus")) then
			Perl_Focus_Update_Once();
		end
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Focus_Config[UnitName("player")]) == "table") then
		Perl_Focus_GetVars();
	else
		Perl_Focus_UpdateVars();
	end

	-- Major config options.
	Perl_Focus_Initialize_Frame_Color();		-- Give the borders (and background if applicable) that "Perl" look
	Perl_Focus_Frame_Style();			-- Layout the frame according to our mode
	Perl_Focus_Buff_Debuff_Background();		-- Do the buffs and debuffs have their transparent background frame?
	Perl_Focus_Reset_Buffs();			-- Hide any unnecessary buff/debuff buttons

	Perl_Focus_NameFrame_CPMeter:SetMinMaxValues(0, 5);	-- REMOVE THIS LATER
	Perl_Focus_NameFrame_CPMeter:SetValue(0);		-- REMOVE THIS LATER

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(FocusFrame);
	Perl_clearBlizzardFrameDisable(FocusFrameSpellBar);
	Perl_clearBlizzardFrameDisable(FocusFrameToT);

	-- MyAddOns Support
	Perl_Focus_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_Focus_Frame:SetUserPlaced(1);

	-- WoW 2.0 Secure API Stuff
	RegisterUnitWatch(Perl_Focus_Frame);

	-- Set the initialization flag
	Initialized = 1;
end

function Perl_Focus_Initialize_Frame_Color()
	Perl_Focus_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_ClassNameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_ClassNameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_CivilianFrame:SetBackdropColor(1, 1, 1, 1);
	Perl_Focus_CivilianFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_LevelFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_BuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_DebuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_PortraitFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Focus_RareEliteFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Focus_RareEliteFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Focus_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Focus_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_Focus_ClassNameBarText:SetTextColor(1, 1, 1);
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Focus_Update_Once()
	Perl_Focus_HealthBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_Focus_ManaBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_Focus_HealthBar:SetValue(0);	-- Do this so we don't fade the bar on a fresh Focus switch
	Perl_Focus_ManaBar:SetValue(0);		-- Do this so we don't fade the bar on a fresh Focus switch
	Perl_Focus_Update_Portrait();		-- Set the Focus's portrait and adjust the combo point frame
	Perl_Focus_Update_Health();		-- Set the Focus's health
	Perl_Focus_Update_Mana_Bar();		-- What type of mana bar is it?
	Perl_Focus_Update_Mana();		-- Set the Focus's mana
	Perl_Focus_Update_PvP_Status_Icon();	-- Set pvp status icon
	Perl_Focus_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
	Perl_Focus_Buff_UpdateAll();		-- Update the buffs
	Perl_Focus_UpdateRaidFocusIcon();	-- Display the raid Focus icon if needed
	Perl_Focus_Update_Name();		-- Update the name
	Perl_Focus_Update_Text_Color();		-- Has the Focus been tapped by someone else?
	Perl_Focus_Update_Threat();		-- Update the threat icon if needed

	-- Begin: Draw the class icon?
	if (showclassicon == 1) then
		if (UnitIsPlayer("focus")) then
			_, englishclass = UnitClass("focus");
			Perl_Focus_ClassTexture:SetTexCoord(PCUF_CLASSPOSRIGHT[englishclass], PCUF_CLASSPOSLEFT[englishclass], PCUF_CLASSPOSTOP[englishclass], PCUF_CLASSPOSBOTTOM[englishclass]);
			Perl_Focus_ClassTexture:Show();
		else
			Perl_Focus_ClassTexture:Hide();
		end
	end
	-- End: Draw the class icon?

	-- Begin: Set the Focus's class in the class frame
	if (showclassframe == 1) then
		if (UnitIsPlayer("focus")) then
			Perl_Focus_ClassNameBarText:SetText(UnitClass("focus"));
		else
			creatureType = UnitCreatureType("focus");
			if (creatureType == PERL_LOCALIZED_NOTSPECIFIED) then
				creatureType = PERL_LOCALIZED_CREATURE;
			end
			Perl_Focus_ClassNameBarText:SetText(creatureType);
		end
	end
	-- End: Set the Focus's class in the class frame

	-- Begin: Voice Chat Icon already in progress?
	if (UnitIsTalking(UnitName("focus"))) then
		Perl_Focus_VoiceChatIconFrame:Show();
	else
		Perl_Focus_VoiceChatIconFrame:Hide();
	end
	-- End: Voice Chat Icon already in progress?
end

function Perl_Focus_Update_Health()
	focushealth = UnitHealth("focus");
	focushealthmax = UnitHealthMax("focus");
	focushealthpercent = floor(focushealth/focushealthmax*100+0.5);

	if (UnitIsDead("focus") or UnitIsGhost("focus")) then				-- This prevents negative health
		focushealth = 0;
		focushealthpercent = 0;
	end

	-- Set Dead Icon
	if (UnitIsDead("focus") or UnitIsGhost("focus")) then
		Perl_Focus_DeadStatus:Show();
	else
		Perl_Focus_DeadStatus:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (focushealth < Perl_Focus_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and focushealth > Perl_Focus_HealthBar:GetValue())) then
			Perl_Focus_HealthBarFadeBar:SetMinMaxValues(0, focushealthmax);
			Perl_Focus_HealthBarFadeBar:SetValue(Perl_Focus_HealthBar:GetValue());
			Perl_Focus_HealthBarFadeBar:Show();
			Perl_Focus_HealthBar_Fade_Color = 1;
			Perl_Focus_HealthBar_Fade_Time_Elapsed = 0;
			Perl_Focus_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Focus_HealthBar:SetMinMaxValues(0, focushealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Focus_HealthBar:SetValue(focushealthmax - focushealth);
	else
		Perl_Focus_HealthBar:SetValue(focushealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((focushealthpercent <= 100) and (focushealthpercent > 75)) then
--			Perl_Focus_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_Focus_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((focushealthpercent <= 75) and (focushealthpercent > 50)) then
--			Perl_Focus_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_Focus_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((focushealthpercent <= 50) and (focushealthpercent > 25)) then
--			Perl_Focus_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_Focus_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_Focus_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_Focus_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = focushealth / focushealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_Focus_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_Focus_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_Focus_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Focus_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (framestyle == 1) then
		Perl_Focus_HealthBarTextRight:SetText();							-- Hide this text in this frame style
		Perl_Focus_HealthBarTextCompactPercent:SetText();						-- Hide this text in this frame style
		Perl_Focus_HealthBarText:SetText(focushealth.."/"..focushealthmax.." | "..focushealthpercent.."%");
	elseif (framestyle == 2) then
		if (compactmode == 0) then
			if (healermode == 0) then
				Perl_Focus_HealthBarTextCompactPercent:SetText();					-- Hide this text in this frame style
				Perl_Focus_HealthBarText:SetText(focushealthpercent.."%");
				Perl_Focus_HealthBarTextRight:SetText(focushealth.."/"..focushealthmax);
			else
				Perl_Focus_HealthBarTextCompactPercent:SetText();					-- Hide this text in this frame style
				Perl_Focus_HealthBarText:SetText(focushealth.."/"..focushealthmax);
				Perl_Focus_HealthBarTextRight:SetText("-"..focushealthmax - focushealth);
			end
			
		else
			if (compactpercent == 0) then
				if (healermode == 0) then
					Perl_Focus_HealthBarTextRight:SetText();					-- Hide this text in this frame style
					Perl_Focus_HealthBarTextCompactPercent:SetText();				-- Hide this text in this frame style
				else
					Perl_Focus_HealthBarTextRight:SetText("-"..focushealthmax - focushealth);
					Perl_Focus_HealthBarTextCompactPercent:SetText();				-- Hide this text in this frame style
				end
				Perl_Focus_HealthBarText:SetText(focushealth.."/"..focushealthmax);
			else
				if (healermode == 0) then
					Perl_Focus_HealthBarTextRight:SetText();					-- Hide this text in this frame style
				else
					Perl_Focus_HealthBarTextRight:SetText("-"..focushealthmax - focushealth);
				end
				Perl_Focus_HealthBarText:SetText(focushealth.."/"..focushealthmax);
				Perl_Focus_HealthBarTextCompactPercent:SetText(focushealthpercent.."%");
			end
		end
	end

	if (UnitIsDead("focus")) then
		if (UnitIsPlayer("focus")) then
			_, englishclass = UnitClass("focus");
			if (englishclass == "HUNTER") then	-- If the dead is a hunter, check for Feign Death
				local buffnum = 1;
				local _, _, buffTexture = UnitBuff("focus", buffnum);
				while (buffTexture) do
					if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
						Perl_Focus_HealthBarText:SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						break;
					end
					buffnum = buffnum + 1;
					_, _, buffTexture = UnitBuff("focus", buffnum);
				end
			end
		end
	end
end

function Perl_Focus_Update_Mana()
	focusmana = UnitMana("focus");
	focusmanamax = UnitManaMax("focus");
	focuspower = UnitPowerType("focus");

	if (UnitIsDead("focus") or UnitIsGhost("focus")) then				-- This prevents negative mana
		focusmana = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (focusmana < Perl_Focus_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and focusmana > Perl_Focus_ManaBar:GetValue())) then
			Perl_Focus_ManaBarFadeBar:SetMinMaxValues(0, focusmanamax);
			Perl_Focus_ManaBarFadeBar:SetValue(Perl_Focus_ManaBar:GetValue());
			Perl_Focus_ManaBarFadeBar:Show();
			Perl_Focus_ManaBar_Fade_Color = 1;
			Perl_Focus_ManaBar_Fade_Time_Elapsed = 0;
			Perl_Focus_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Focus_ManaBar:SetMinMaxValues(0, focusmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Focus_ManaBar:SetValue(focusmanamax - focusmana);
	else
		Perl_Focus_ManaBar:SetValue(focusmana);
	end

	if (framestyle == 1) then
		Perl_Focus_ManaBarTextRight:SetTextColor(1, 1, 1, 1);
		Perl_Focus_ManaBarTextRight:SetText();			-- Hide this text in this frame style
		Perl_Focus_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style

		if (focuspower == 1 or focuspower == 2 or focuspower == 6) then
			Perl_Focus_ManaBarText:SetText(focusmana);
		else
			Perl_Focus_ManaBarText:SetText(focusmana.."/"..focusmanamax);
		end
	elseif (framestyle == 2) then
		focusmanapercent = floor(focusmana/focusmanamax*100+0.5);

		if (compactmode == 0) then
			Perl_Focus_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style

			if (healermode == 0) then
				Perl_Focus_ManaBarTextRight:SetTextColor(1, 1, 1, 1);
				if (focuspower == 1 or focuspower == 2 or focuspower == 6) then
					Perl_Focus_ManaBarText:SetText(focusmana.."%");
					Perl_Focus_ManaBarTextRight:SetText(focusmana);
				else
					Perl_Focus_ManaBarText:SetText(focusmanapercent.."%");
					Perl_Focus_ManaBarTextRight:SetText(focusmana.."/"..focusmanamax);
				end
			else
				Perl_Focus_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
				if (showmanadeficit == 1) then
					Perl_Focus_ManaBarTextRight:SetText("-"..focusmanamax - focusmana);
				else
					Perl_Focus_ManaBarTextRight:SetText();
				end
				if (focuspower == 1 or focuspower == 2 or focuspower == 6) then
					Perl_Focus_ManaBarText:SetText(focusmana);
				else
					Perl_Focus_ManaBarText:SetText(focusmana.."/"..focusmanamax);
				end
			end
		else
			if (compactpercent == 0) then
				Perl_Focus_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style
				if (healermode == 1) then
					if (showmanadeficit == 1) then
						Perl_Focus_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
						Perl_Focus_ManaBarTextRight:SetText("-"..focusmanamax - focusmana);			-- Hide this text in this frame style
					else
						Perl_Focus_ManaBarTextRight:SetText();			-- Hide this text in this frame style
					end
				else
					Perl_Focus_ManaBarTextRight:SetText();			-- Hide this text in this frame style
				end
				if (focuspower == 1 or focuspower == 2 or focuspower == 6) then
					Perl_Focus_ManaBarText:SetText(focusmana);
				else
					Perl_Focus_ManaBarText:SetText(focusmana.."/"..focusmanamax);
				end
			else
				if (healermode == 1) then
					if (showmanadeficit == 1) then
						Perl_Focus_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
						Perl_Focus_ManaBarTextRight:SetText("-"..focusmanamax - focusmana);			-- Hide this text in this frame style
					else
						Perl_Focus_ManaBarTextRight:SetText();			-- Hide this text in this frame style
					end
				else
					Perl_Focus_ManaBarTextRight:SetText();			-- Hide this text in this frame style
				end

				if (focuspower == 1 or focuspower == 2 or focuspower == 6) then
					Perl_Focus_ManaBarText:SetText(focusmana);
					Perl_Focus_ManaBarTextCompactPercent:SetText(focusmana.."%");
				else
					Perl_Focus_ManaBarText:SetText(focusmana.."/"..focusmanamax);
					Perl_Focus_ManaBarTextCompactPercent:SetText(focusmanapercent.."%");
				end
			end
		end
	end
end

function Perl_Focus_Update_Mana_Bar()
	focuspower = UnitPowerType("focus");

	-- Set mana bar color
	if (UnitManaMax("focus") == 0) then
		Perl_Focus_ManaBar:Hide();
		Perl_Focus_ManaBarBG:Hide();
	elseif (focuspower == 1) then
		Perl_Focus_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Focus_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		Perl_Focus_ManaBar:Show();
		Perl_Focus_ManaBarBG:Show();
	elseif (focuspower == 2) then
		Perl_Focus_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Focus_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		Perl_Focus_ManaBar:Show();
		Perl_Focus_ManaBarBG:Show();
	elseif (focuspower == 3) then
		Perl_Focus_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Focus_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_Focus_ManaBar:Show();
		Perl_Focus_ManaBarBG:Show();
	elseif (focuspower == 6) then
		Perl_Focus_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
		Perl_Focus_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
		Perl_Focus_ManaBar:Show();
		Perl_Focus_ManaBarBG:Show();
	else
		Perl_Focus_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Focus_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		Perl_Focus_ManaBar:Show();
		Perl_Focus_ManaBarBG:Show();
	end
end

function Perl_Focus_Update_PvP_Status_Icon()
	if (showpvpicon == 1) then
		if (UnitIsPVPFreeForAll("focus")) then
			Perl_Focus_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			Perl_Focus_PVPStatus:Show();
		elseif (UnitFactionGroup("focus") and UnitIsPVP("focus")) then
			Perl_Focus_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup("focus"));
			Perl_Focus_PVPStatus:Show();
		else
			Perl_Focus_PVPStatus:Hide();
		end
	else
		Perl_Focus_PVPStatus:Hide();
	end
end

function Perl_Focus_Update_Name()
	if (UnitIsPlayer("focus")) then
		if (showclassicon == 1) then
			Perl_Focus_NameBarText:SetPoint("LEFT", "Perl_Focus_ClassTexture", "RIGHT", 2, 0);
			if (showpvpicon == 1) then
				Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 44);
			else
				Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 28);
			end
		else
			Perl_Focus_NameBarText:SetPoint("LEFT", "Perl_Focus_ClassTexture", "RIGHT", -13, 0);
			if (showpvpicon == 1) then
				Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 28);
			else
				Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 12);
			end
		end
	else
		Perl_Focus_NameBarText:SetPoint("LEFT", "Perl_Focus_ClassTexture", "RIGHT", -13, 0);
		if (UnitIsPVP("focus") and showpvpicon == 1) then
			Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 28);
		else
			Perl_Focus_NameBarText:SetWidth(Perl_Focus_Name:GetWidth() - 12);
		end
	end
	Perl_Focus_NameBarText:SetText(UnitName("focus"));
end

function Perl_Focus_Update_Text_Color()
	if (classcolorednames == 1) then
		if (UnitIsPlayer("focus")) then
			_, englishclass = UnitClass("focus");
			Perl_Focus_NameBarText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
			return;
		end
	end

	if (UnitPlayerControlled("focus")) then					-- is it a player
		if (UnitCanAttack("focus", "player")) then				-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", "focus")) then			-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else								-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", "focus")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP("focus") and not UnitIsPVPSanctuary("focus") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
			-- Players we can assist but are PvP flagged are green
			r = 0.0;
			g = 1.0;
			b = 0.0;
		else									-- friendly non pvp enabled character
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.5;
			g = 0.5;
			b = 1.0;
		end
		Perl_Focus_NameBarText:SetTextColor(r, g, b);
	elseif (UnitIsTapped("focus") and not UnitIsTappedByPlayer("focus")) then
		Perl_Focus_NameBarText:SetTextColor(0.5, 0.5, 0.5);			-- not our tap
	else
		if (UnitIsVisible("focus")) then
			local reaction = UnitReaction("focus", "player");
			if (reaction) then
				r = FACTION_BAR_COLORS[reaction].r;
				g = FACTION_BAR_COLORS[reaction].g;
				b = FACTION_BAR_COLORS[reaction].b;
				Perl_Focus_NameBarText:SetTextColor(r, g, b);
			else
				Perl_Focus_NameBarText:SetTextColor(0.5, 0.5, 1.0);
			end
		else
			if (UnitCanAttack("focus", "player")) then				-- are we in an enemy controlled zone
				-- Hostile players are red
				if (not UnitCanAttack("player", "focus")) then			-- enemy is not pvp enabled
					r = 0.5;
					g = 0.5;
					b = 1.0;
				else								-- enemy is pvp enabled
					r = 1.0;
					g = 0.0;
					b = 0.0;
				end
			elseif (UnitCanAttack("player", "focus")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
				-- Players we can attack but which are not hostile are yellow
				r = 1.0;
				g = 1.0;
				b = 0.0;
			elseif (UnitIsPVP("focus") and not UnitIsPVPSanctuary("focus") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
				-- Players we can assist but are PvP flagged are green
				r = 0.0;
				g = 1.0;
				b = 0.0;
			else									-- friendly non pvp enabled character
				-- All other players are blue (the usual state on the "blue" server)
				r = 0.5;
				g = 0.5;
				b = 1.0;
			end
			Perl_Focus_NameBarText:SetTextColor(r, g, b);
		end
	end
end

function Perl_Focus_Frame_Set_Level()
	focuslevel = UnitLevel("focus");			-- Get and store the level of the Focus
	focuslevelcolor = GetQuestDifficultyColor(focuslevel);	-- Get the "con color" of the Focus
	focusclassification = UnitClassification("focus");	-- Get the type of character the Focus is (rare, elite, worldboss)
	focusclassificationframetext = nil;			-- Variable set to nil so we can easily track if Focus is a player or not elite

	Perl_Focus_LevelBarText:SetVertexColor(focuslevelcolor.r, focuslevelcolor.g, focuslevelcolor.b);
	Perl_Focus_RareEliteBarText:SetVertexColor(focuslevelcolor.r, focuslevelcolor.g, focuslevelcolor.b);

	if (focuslevel < 0) then
		Perl_Focus_LevelBarText:SetTextColor(1, 0, 0);
		if (UnitIsPlayer("focus")) then
			focusclassificationframetext = nil;
		end
		focuslevel = "??";
	end

	if (focusclassification == "worldboss") then
		Perl_Focus_RareEliteBarText:SetTextColor(1, 0, 0);
		focusclassificationframetext = PERL_LOCALIZED_Focus_BOSS;
	end

	if (focusclassification == "rareelite") then
		focusclassificationframetext = PERL_LOCALIZED_Focus_RAREELITE;
		focuslevel = focuslevel.."r+";
	elseif (focusclassification == "elite") then
		focusclassificationframetext = PERL_LOCALIZED_Focus_ELITE;
		focuslevel = focuslevel.."+";
	elseif (focusclassification == "rare") then
		focusclassificationframetext = PERL_LOCALIZED_Focus_RARE;
		focuslevel = focuslevel.."r";
	end

	Perl_Focus_LevelBarText:SetText(focuslevel);						-- Set level frame text

	if (showrareeliteframe == 1) then
		if (focusclassificationframetext == nil) then
			Perl_Focus_RareEliteBarText:SetText(PERL_LOCALIZED_TARGET_NA);
		else
			Perl_Focus_RareEliteBarText:SetText(focusclassificationframetext);	-- Set the text
		end
	end
end

function Perl_Focus_UpdateRaidFocusIcon()
	local index = GetRaidTargetIndex("focus");
	if (index) then
		SetRaidTargetIconTexture(Perl_Focus_RaidFocusIcon, index);
		Perl_Focus_RaidFocusIcon:Show();
	else
		Perl_Focus_RaidFocusIcon:Hide();
	end
end

function Perl_Focus_Update_Portrait()
	if (showportrait == 1) then
		if (threedportrait == 0) then
			SetPortraitTexture(Perl_Focus_Portrait, "focus");			-- Load the correct 2d graphic
		else
			if UnitIsVisible("focus") then
				Perl_Focus_PortraitFrame_FocusModel:SetUnit("focus");	-- Load the correct 3d graphic
				Perl_Focus_PortraitFrame_FocusModel:SetCamera(0);
				Perl_Focus_Portrait:Hide();					-- Hide the 2d graphic
				Perl_Focus_PortraitFrame_FocusModel:Show();			-- Show the 3d graphic
			else
				SetPortraitTexture(Perl_Focus_Portrait, "focus");		-- Load the correct 2d graphic
				Perl_Focus_PortraitFrame_FocusModel:Hide();			-- Hide the 3d graphic
				Perl_Focus_Portrait:Show();					-- Show the 2d graphic
			end
		end
	end
end

function Perl_Focus_Update_Threat()
	local status = UnitThreatSituation("player", "focus");

	if (status == nil) then
		Perl_Focus_ThreatIndicator:Hide();
		return;
	end

	if (status > 0 and PCUF_THREATICON == 1) then
		Perl_Focus_ThreatIndicator:SetVertexColor(GetThreatStatusColor(status));
		Perl_Focus_ThreatIndicator:Show();
	else
		Perl_Focus_ThreatIndicator:Hide();
	end
end

function Perl_Focus_Buff_Debuff_Background()
	if (hidebuffbackground == 0) then
		Perl_Focus_BuffFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
		Perl_Focus_DebuffFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
		Perl_Focus_BuffFrame:SetBackdropColor(0, 0, 0, 1);
		Perl_Focus_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Focus_DebuffFrame:SetBackdropColor(0, 0, 0, 1);
		Perl_Focus_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	else
		Perl_Focus_BuffFrame:SetBackdrop(nil);
		Perl_Focus_DebuffFrame:SetBackdrop(nil);
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Focus_Frame_Style()
	Perl_Focus_Main_Style();
	Perl_Focus_Text_Positions();
end

function Perl_Focus_Main_Style()
	Perl_Focus_RareEliteFrame:ClearAllPoints();
	Perl_Focus_RareEliteFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_LevelFrame", "TOPLEFT", 0, -2);

	if (framestyle == 1) then
		Perl_Focus_HealthBar:SetWidth(200);
		Perl_Focus_HealthBarFadeBar:SetWidth(200);
		Perl_Focus_HealthBarBG:SetWidth(200);
		Perl_Focus_ManaBar:SetWidth(200);
		Perl_Focus_ManaBarFadeBar:SetWidth(200);
		Perl_Focus_ManaBarBG:SetWidth(200);
		Perl_Focus_HealthBar:SetPoint("TOP", "Perl_Focus_StatsFrame", "TOP", 0, -10);
		Perl_Focus_ManaBar:SetPoint("TOP", "Perl_Focus_HealthBar", "BOTTOM", 0, -2);

		Perl_Focus_CivilianFrame:SetWidth(95);
		Perl_Focus_ClassNameFrame:SetWidth(95);
		Perl_Focus_LevelFrame:SetWidth(46);
		Perl_Focus_Frame:SetWidth(177);
		Perl_Focus_Name:SetWidth(177);
		Perl_Focus_NameFrame:SetWidth(177);
		Perl_Focus_RareEliteFrame:SetWidth(46);
		Perl_Focus_StatsFrame:SetWidth(221);

		Perl_Focus_NameFrame_CPMeter:SetWidth(170);

		Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(95);
		Perl_Focus_NameFrame_CastClickOverlay:SetWidth(180);
		Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(221);
	elseif (framestyle == 2) then
		Perl_Focus_HealthBar:SetWidth(150);
		Perl_Focus_HealthBarFadeBar:SetWidth(150);
		Perl_Focus_HealthBarBG:SetWidth(150);
		Perl_Focus_ManaBar:SetWidth(150);
		Perl_Focus_ManaBarFadeBar:SetWidth(150);
		Perl_Focus_ManaBarBG:SetWidth(150);
		Perl_Focus_HealthBar:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "TOPLEFT", 10, -10);
		Perl_Focus_ManaBar:SetPoint("TOP", "Perl_Focus_HealthBar", "BOTTOM", 0, -2);

		if (compactmode == 0) then
			Perl_Focus_CivilianFrame:SetWidth(114);
			Perl_Focus_ClassNameFrame:SetWidth(95);
			Perl_Focus_LevelFrame:SetWidth(46);
			Perl_Focus_Frame:SetWidth(211);
			Perl_Focus_Name:SetWidth(211);
			Perl_Focus_NameFrame:SetWidth(211);
			Perl_Focus_RareEliteFrame:SetWidth(46);
			Perl_Focus_StatsFrame:SetWidth(255);

			Perl_Focus_NameFrame_CPMeter:SetWidth(189);

			Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(114);
			Perl_Focus_NameFrame_CastClickOverlay:SetWidth(214);
			Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(255);
		else
			if (shortbars == 0) then
				if (compactpercent == 0) then
					Perl_Focus_CivilianFrame:SetWidth(85);
					Perl_Focus_ClassNameFrame:SetWidth(95);
					Perl_Focus_LevelFrame:SetWidth(46);
					Perl_Focus_Frame:SetWidth(126);
					Perl_Focus_Name:SetWidth(126);
					Perl_Focus_NameFrame:SetWidth(126);
					Perl_Focus_RareEliteFrame:SetWidth(46);
					Perl_Focus_StatsFrame:SetWidth(170);

					Perl_Focus_NameFrame_CPMeter:SetWidth(119);

					Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(85);
					Perl_Focus_NameFrame_CastClickOverlay:SetWidth(129);
					Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(170);
				else
					Perl_Focus_CivilianFrame:SetWidth(79);
					Perl_Focus_ClassNameFrame:SetWidth(95);
					Perl_Focus_LevelFrame:SetWidth(46);
					Perl_Focus_Frame:SetWidth(161);
					Perl_Focus_Name:SetWidth(161);
					Perl_Focus_NameFrame:SetWidth(161);
					Perl_Focus_RareEliteFrame:SetWidth(46);
					Perl_Focus_StatsFrame:SetWidth(205);

					Perl_Focus_NameFrame_CPMeter:SetWidth(154);

					Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(79);
					Perl_Focus_NameFrame_CastClickOverlay:SetWidth(164);
					Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(205);
				end
			else
				Perl_Focus_HealthBar:SetWidth(115);
				Perl_Focus_HealthBarFadeBar:SetWidth(115);
				Perl_Focus_HealthBarBG:SetWidth(115);
				Perl_Focus_ManaBar:SetWidth(115);
				Perl_Focus_ManaBarFadeBar:SetWidth(115);
				Perl_Focus_ManaBarBG:SetWidth(115);

				if (compactpercent == 0) then				-- civilian probably needs resizing
					Perl_Focus_CivilianFrame:SetWidth(79);
					Perl_Focus_ClassNameFrame:SetWidth(91);
					Perl_Focus_LevelFrame:SetWidth(46);
					Perl_Focus_Frame:SetWidth(91);
					Perl_Focus_Name:SetWidth(91);
					Perl_Focus_NameFrame:SetWidth(91);
					Perl_Focus_RareEliteFrame:SetWidth(46);
					Perl_Focus_StatsFrame:SetWidth(135);

					Perl_Focus_NameFrame_CPMeter:SetWidth(84);

					Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(79);
					Perl_Focus_NameFrame_CastClickOverlay:SetWidth(94);
					Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(135);
				else
					Perl_Focus_CivilianFrame:SetWidth(79);
					Perl_Focus_ClassNameFrame:SetWidth(95);
					Perl_Focus_LevelFrame:SetWidth(46);
					Perl_Focus_Frame:SetWidth(126);
					Perl_Focus_Name:SetWidth(126);
					Perl_Focus_NameFrame:SetWidth(126);
					Perl_Focus_RareEliteFrame:SetWidth(46);
					Perl_Focus_StatsFrame:SetWidth(170);

					Perl_Focus_NameFrame_CPMeter:SetWidth(119);

					Perl_Focus_CivilianFrame_CastClickOverlay:SetWidth(79);
					Perl_Focus_NameFrame_CastClickOverlay:SetWidth(129);
					Perl_Focus_StatsFrame_CastClickOverlay:SetWidth(170);
				end
			end
		end
	end

	if (showportrait == 1) then
		Perl_Focus_HitIndicator:SetPoint("CENTER", Perl_Focus_PortraitFrame, "CENTER", 0, 0);			-- Position the Combat Text correctly on the portrait
		Perl_Focus_PortraitFrame:Show();									-- Show the main portrait frame

		if (threedportrait == 0) then
			Perl_Focus_PortraitFrame_FocusModel:Hide();							-- Hide the 3d graphic
			Perl_Focus_Portrait:Show();									-- Show the 2d graphic
		end
	else
		Perl_Focus_HitIndicator:SetPoint("CENTER", Perl_Focus_PortraitFrame, "CENTER", 0, 0);		-- Position the Combat Text correctly on the portrait
		Perl_Focus_PortraitFrame:Hide();									-- Hide the frame and 2d/3d portion
	end

	if (showrareeliteframe == 1) then		-- Are we showing the Rare/Elite frame?
		Perl_Focus_RareEliteFrame:Show();
	else
		Perl_Focus_RareEliteFrame:Hide();
	end

	if (showclassframe == 1) then
		Perl_Focus_ClassNameFrame:Show();
		Perl_Focus_CivilianFrame:Hide();	-- Hide is normally Show here, but we are changing what this frame does later to guild names
	else
		Perl_Focus_ClassNameFrame:Hide();
		Perl_Focus_CivilianFrame:Hide();
	end

	if (showclassicon == 0) then			-- Are we showing the class icon?
		Perl_Focus_ClassTexture:Hide();
	end

	if (portraitcombattext == 1) then		-- Are we showing combat text?
		Perl_Focus_PortraitTextFrame:Show();
	else
		Perl_Focus_PortraitTextFrame:Hide();
	end

	Perl_Focus_NameBarText:SetHeight(Perl_Focus_Name:GetHeight() - 10);
	Perl_Focus_NameBarText:SetNonSpaceWrap(false);
	Perl_Focus_NameBarText:SetJustifyH("LEFT");

	Perl_Focus_ClassNameBarText:SetWidth(Perl_Focus_ClassNameFrame:GetWidth() - 10);
	Perl_Focus_ClassNameBarText:SetHeight(Perl_Focus_ClassNameFrame:GetHeight() - 10);
	Perl_Focus_ClassNameBarText:SetNonSpaceWrap(false);

	if (Initialized) then
		Perl_Focus_ArcaneBar_Support();
	end
end

function Perl_Focus_ArcaneBar_Support()
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_ArcaneBar_focus:SetPoint("TOPLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 5, -5);
		Perl_ArcaneBar_focus_CastTime:ClearAllPoints();
		if (Perl_ArcaneBar_Config[UnitName("player")]["FocusLeftTimer"] == 0) then
			if (showportrait == 1) then
				Perl_ArcaneBar_focus_CastTime:SetPoint("LEFT", "Perl_Focus_PortraitFrame", "RIGHT", 0, 0);
			else
				Perl_ArcaneBar_focus_CastTime:SetPoint("LEFT", "Perl_Focus_LevelFrame", "RIGHT", 0, 0);
			end
		else
			Perl_ArcaneBar_focus_CastTime:SetPoint("RIGHT", "Perl_Focus_NameFrame", "LEFT", 0, 0);
		end

		Perl_ArcaneBar_focus:SetWidth(Perl_Focus_NameFrame:GetWidth() - 10);
		Perl_ArcaneBar_focus_Flash:SetWidth(Perl_Focus_NameFrame:GetWidth() + 5);
		Perl_ArcaneBar_Set_Spark_Width(nil, nil, Perl_Focus_NameFrame:GetWidth(), nil);
	end
end

function Perl_Focus_Text_Positions()
	-- Begin: Set the text positions
	Perl_Focus_HealthBarText:ClearAllPoints();
	Perl_Focus_ManaBarText:ClearAllPoints();
	if (framestyle == 1) then
		Perl_Focus_HealthBarText:SetPoint("TOP", 0, 1);
		Perl_Focus_ManaBarText:SetPoint("TOP", 0, 1);
	elseif (framestyle == 2) then
		if (compactmode == 0) then
			Perl_Focus_HealthBarText:SetPoint("TOP", 0, 1);
			Perl_Focus_ManaBarText:SetPoint("TOP", 0, 1);
			Perl_Focus_HealthBarTextRight:SetPoint("RIGHT", 85, 0);
			Perl_Focus_ManaBarTextRight:SetPoint("RIGHT", 85, 0);
		else
			if (healermode == 0) then
				Perl_Focus_HealthBarText:SetPoint("TOP", 0, 1);
				Perl_Focus_ManaBarText:SetPoint("TOP", 0, 1);
			else
				Perl_Focus_HealthBarText:SetPoint("TOPLEFT", 5, 1);
				Perl_Focus_ManaBarText:SetPoint("TOPLEFT", 5, 1);
				Perl_Focus_HealthBarTextRight:SetPoint("RIGHT", -5, 0);
				Perl_Focus_ManaBarTextRight:SetPoint("RIGHT", -5, 0);
			end
		end
	end
	-- End: Set the text positions
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Focus_HealthBar_Fade(arg1)
	Perl_Focus_HealthBar_Fade_Color = Perl_Focus_HealthBar_Fade_Color - arg1;
	Perl_Focus_HealthBar_Fade_Time_Elapsed = Perl_Focus_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Focus_HealthBarFadeBar:SetStatusBarColor(0, Perl_Focus_HealthBar_Fade_Color, 0, Perl_Focus_HealthBar_Fade_Color);

	if (Perl_Focus_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Focus_HealthBar_Fade_Color = 1;
		Perl_Focus_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Focus_HealthBarFadeBar:Hide();
		Perl_Focus_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Focus_ManaBar_Fade(arg1)
	Perl_Focus_ManaBar_Fade_Color = Perl_Focus_ManaBar_Fade_Color - arg1;
	Perl_Focus_ManaBar_Fade_Time_Elapsed = Perl_Focus_ManaBar_Fade_Time_Elapsed + arg1;

	if (focuspower == 0) then
		Perl_Focus_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Focus_ManaBar_Fade_Color, Perl_Focus_ManaBar_Fade_Color);
	elseif (focuspower == 1) then
		Perl_Focus_ManaBarFadeBar:SetStatusBarColor(Perl_Focus_ManaBar_Fade_Color, 0, 0, Perl_Focus_ManaBar_Fade_Color);
	elseif (focuspower == 2) then
		Perl_Focus_ManaBarFadeBar:SetStatusBarColor(Perl_Focus_ManaBar_Fade_Color, (Perl_Focus_ManaBar_Fade_Color-0.5), 0, Perl_Focus_ManaBar_Fade_Color);
	elseif (focuspower == 3) then
		Perl_Focus_ManaBarFadeBar:SetStatusBarColor(Perl_Focus_ManaBar_Fade_Color, Perl_Focus_ManaBar_Fade_Color, 0, Perl_Focus_ManaBar_Fade_Color);
	elseif (focuspower == 6) then
		Perl_Focus_ManaBarFadeBar:SetStatusBarColor(0, Perl_Focus_ManaBar_Fade_Color, Perl_Focus_ManaBar_Fade_Color, Perl_Focus_ManaBar_Fade_Color);
	end

	if (Perl_Focus_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Focus_ManaBar_Fade_Color = 1;
		Perl_Focus_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Focus_ManaBarFadeBar:Hide();
		Perl_Focus_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Focus_Set_Buffs(newbuffnumber)
	if (newbuffnumber == nil) then
		newbuffnumber = 16;
	end
	numbuffsshown = newbuffnumber;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Debuffs(newdebuffnumber)
	if (newdebuffnumber == nil) then
		newdebuffnumber = 16;
	end
	numdebuffsshown = newdebuffnumber;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Class_Buffs(newvalue)
	if (newvalue ~= nil) then
		displaycastablebuffs = newvalue;
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Buff_Timers(newvalue)
	if (newvalue ~= nil) then
		displaybufftimers = newvalue;
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Class_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displaycurabledebuff = newvalue;
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Only_Self_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displayonlymydebuffs = newvalue;
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Invert_Buffs(newvalue)
	if (newvalue ~= nil) then
		invertbuffs = newvalue;
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Reset_Buffs();		-- Reset the buff icons
	Perl_Focus_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Focus_Set_Class_Icon(newvalue)
	showclassicon = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_PvP_Status_Icon(newvalue)
	showpvpicon = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Class_Frame(newvalue)
	showclassframe = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
end

function Perl_Focus_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Rare_Elite(newvalue)
	showrareeliteframe = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Portrait_Combat_Text(newvalue)
	portraitcombattext = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Combo_Name_Frame(newvalue)
	nameframecombopoints = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Combo_Frame_Debuffs(newvalue)
	comboframedebuffs = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Frame_Style(newvalue)
	framestyle = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Compact_Mode(newvalue)
	compactmode = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Compact_Percents(newvalue)
	compactpercent = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Short_Bars(newvalue)
	shortbars = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Healer(newvalue)
	healermode = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Buff_Debuff_Background(newvalue)
	hidebuffbackground = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Buff_Debuff_Background();
end

function Perl_Focus_Set_Mana_Deficit(newvalue)
	showmanadeficit = newvalue;
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("focus")) then
		Perl_Focus_Update_Once();	-- Update the Focus frame information if appropriate
	end
end

function Perl_Focus_Set_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		scale = (number / 100);		-- convert the user input to a wow acceptable value
	end
	Perl_Focus_UpdateVars();		-- Save the new setting
	Perl_Focus_Set_Scale_Actual();
end

function Perl_Focus_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Focus_Set_Scale_Actual);
	else
		Perl_Focus_Frame:SetScale(1 - UIParent:GetEffectiveScale() + scale);	-- run it through the scaling formula introduced in 1.9
		Perl_Focus_Set_BuffDebuff_Scale(buffdebuffscale*100);			-- maintain the buff/debuff scale
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			Perl_ArcaneBar_Set_Scale_Actual(nil, nil, scale, nil);
		end
	end
end

function Perl_Focus_Set_BuffDebuff_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		buffdebuffscale = (number / 100);				-- convert the user input to a wow acceptable value
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + buffdebuffscale;	-- run it through the scaling formula introduced in 1.9
	Perl_Focus_BuffFrame:SetScale(buffdebuffscale);
	Perl_Focus_DebuffFrame:SetScale(buffdebuffscale);
	Perl_Focus_UpdateVars();		-- Save the new setting
end

function Perl_Focus_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);					-- convert the user input to a wow acceptable value
	end
	Perl_Focus_Frame:SetAlpha(transparency);
	Perl_Focus_UpdateVars();		-- Save the new setting
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Focus_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Focus_Config[name]["Locked"];
	showclassicon = Perl_Focus_Config[name]["ClassIcon"];
	showclassframe = Perl_Focus_Config[name]["ClassFrame"];
	showpvpicon = Perl_Focus_Config[name]["PvPIcon"]; 
	numbuffsshown = Perl_Focus_Config[name]["Buffs"];
	numdebuffsshown = Perl_Focus_Config[name]["Debuffs"];
	scale = Perl_Focus_Config[name]["Scale"];
	transparency = Perl_Focus_Config[name]["Transparency"];
	buffdebuffscale = Perl_Focus_Config[name]["BuffDebuffScale"];
	showportrait = Perl_Focus_Config[name]["ShowPortrait"];
	threedportrait = Perl_Focus_Config[name]["ThreeDPortrait"];
	portraitcombattext = Perl_Focus_Config[name]["PortraitCombatText"];
	showrareeliteframe = Perl_Focus_Config[name]["ShowRareEliteFrame"];
	nameframecombopoints = Perl_Focus_Config[name]["NameFrameComboPoints"];
	comboframedebuffs = Perl_Focus_Config[name]["ComboFrameDebuffs"];
	framestyle = Perl_Focus_Config[name]["FrameStyle"];
	compactmode = Perl_Focus_Config[name]["CompactMode"];
	compactpercent = Perl_Focus_Config[name]["CompactPercent"];
	hidebuffbackground = Perl_Focus_Config[name]["HideBuffBackground"];
	shortbars = Perl_Focus_Config[name]["ShortBars"];
	healermode = Perl_Focus_Config[name]["HealerMode"];
	displaycastablebuffs = Perl_Focus_Config[name]["DisplayCastableBuffs"];
	classcolorednames = Perl_Focus_Config[name]["ClassColoredNames"];
	showmanadeficit = Perl_Focus_Config[name]["ShowManaDeficit"];
	invertbuffs = Perl_Focus_Config[name]["InvertBuffs"];
	displaycurabledebuff = Perl_Focus_Config[name]["DisplayCurableDebuff"];
	displaybufftimers = Perl_Focus_Config[name]["DisplayBuffTimers"];
	displayonlymydebuffs = Perl_Focus_Config[name]["DisplayOnlyMyDebuffs"];


	if (locked == nil) then
		locked = 0;
	end
	if (showclassicon == nil) then
		showclassicon = 1;
	end
	if (showclassframe == nil) then
		showclassframe = 1;
	end
	if (showpvpicon == nil) then
		showpvpicon = 1;
	end
	if (numbuffsshown == nil) then
		numbuffsshown = 16;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 16;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (buffdebuffscale == nil) then
		buffdebuffscale = 1;
	end
	if (showportrait == nil) then
		showportrait = 0;
	end
	if (threedportrait == nil) then
		threedportrait = 0;
	end
	if (portraitcombattext == nil) then
		portraitcombattext = 0;
	end
	if (showrareeliteframe == nil) then
		showrareeliteframe = 0;
	end
	if (nameframecombopoints == nil) then
		nameframecombopoints = 0;
	end
	if (comboframedebuffs == nil) then
		comboframedebuffs = 0;
	end
	if (framestyle == nil) then
		framestyle = 1;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (compactpercent == nil) then
		compactpercent = 0;
	end
	if (hidebuffbackground == nil) then
		hidebuffbackground = 0;
	end
	if (shortbars == nil) then
		shortbars = 0;
	end
	if (healermode == nil) then
		healermode = 0;
	end
	if (displaycastablebuffs == nil) then
		displaycastablebuffs = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (showmanadeficit == nil) then
		showmanadeficit = 0;
	end
	if (invertbuffs == nil) then
		invertbuffs = 0;
	end
	if (displaycurabledebuff == nil) then
		displaycurabledebuff = 0;
	end
	if (displaybufftimers == nil) then
		displaybufftimers = 1;
	end
	if (displayonlymydebuffs == nil) then
		displayonlymydebuffs = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Focus_UpdateVars();

		-- Call any code we need to activate them
		Perl_Focus_Reset_Buffs();		-- Reset the buff icons
		Perl_Focus_Frame_Style();		-- Reposition the frames
		Perl_Focus_Buff_Debuff_Background();	-- Hide/Show the background frame
		Perl_Focus_Set_Scale_Actual();		-- Set the scale
		Perl_Focus_Set_Transparency();		-- Set the transparency
		if (UnitExists("focus")) then
			Perl_Focus_Update_Once();
		end
		return;
	end

	local vars = {
		["locked"] = locked,
		["showclassicon"] = showclassicon,
		["showclassframe"] = showclassframe,
		["showpvpicon"] = showpvpicon,
		["numbuffsshown"] = numbuffsshown,
		["numdebuffsshown"] = numdebuffsshown,
		["scale"] = scale,
		["transparency"] = transparency,
		["buffdebuffscale"] = buffdebuffscale,
		["showportrait"] = showportrait,
		["threedportrait"] = threedportrait,
		["portraitcombattext"] = portraitcombattext,
		["showrareeliteframe"] = showrareeliteframe,
		["nameframecombopoints"] = nameframecombopoints,
		["comboframedebuffs"] = comboframedebuffs,
		["framestyle"] = framestyle,
		["compactmode"] = compactmode,
		["compactpercent"] = compactpercent,
		["hidebuffbackground"] = hidebuffbackground,
		["shortbars"] = shortbars,
		["healermode"] = healermode,
		["displaycastablebuffs"] = displaycastablebuffs,
		["classcolorednames"] = classcolorednames,
		["showmanadeficit"] = showmanadeficit,
		["invertbuffs"] = invertbuffs,
		["displaycurabledebuff"] = displaycurabledebuff,
		["displaybufftimers"] = displaybufftimers,
		["displayonlymydebuffs"] = displayonlymydebuffs,
	}
	return vars;
end

function Perl_Focus_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["ClassIcon"] ~= nil) then
				showclassicon = vartable["Global Settings"]["ClassIcon"];
			else
				showclassicon = nil;
			end
			if (vartable["Global Settings"]["ClassFrame"] ~= nil) then
				showclassframe = vartable["Global Settings"]["ClassFrame"];
			else
				showclassframe = nil;
			end
			if (vartable["Global Settings"]["PvPIcon"] ~= nil) then
				showpvpicon = vartable["Global Settings"]["PvPIcon"];
			else
				showpvpicon = nil;
			end
			if (vartable["Global Settings"]["Buffs"] ~= nil) then
				numbuffsshown = vartable["Global Settings"]["Buffs"];
			else
				numbuffsshown = nil;
			end
			if (vartable["Global Settings"]["Debuffs"] ~= nil) then
				numdebuffsshown = vartable["Global Settings"]["Debuffs"];
			else
				numdebuffsshown = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["BuffDebuffScale"] ~= nil) then
				buffdebuffscale = vartable["Global Settings"]["BuffDebuffScale"];
			else
				buffdebuffscale = nil;
			end
			if (vartable["Global Settings"]["ShowPortrait"] ~= nil) then
				showportrait = vartable["Global Settings"]["ShowPortrait"];
			else
				showportrait = nil;
			end
			if (vartable["Global Settings"]["ThreeDPortrait"] ~= nil) then
				threedportrait = vartable["Global Settings"]["ThreeDPortrait"];
			else
				threedportrait = nil;
			end
			if (vartable["Global Settings"]["PortraitCombatText"] ~= nil) then
				portraitcombattext = vartable["Global Settings"]["PortraitCombatText"];
			else
				portraitcombattext = nil;
			end
			if (vartable["Global Settings"]["ShowRareEliteFrame"] ~= nil) then
				showrareeliteframe = vartable["Global Settings"]["ShowRareEliteFrame"];
			else
				showrareeliteframe = nil;
			end
			if (vartable["Global Settings"]["NameFrameComboPoints"] ~= nil) then
				nameframecombopoints = vartable["Global Settings"]["NameFrameComboPoints"];
			else
				nameframecombopoints = nil;
			end
			if (vartable["Global Settings"]["ComboFrameDebuffs"] ~= nil) then
				comboframedebuffs = vartable["Global Settings"]["ComboFrameDebuffs"];
			else
				comboframedebuffs = nil;
			end
			if (vartable["Global Settings"]["FrameStyle"] ~= nil) then
				framestyle = vartable["Global Settings"]["FrameStyle"];
			else
				framestyle = nil;
			end
			if (vartable["Global Settings"]["CompactMode"] ~= nil) then
				compactmode = vartable["Global Settings"]["CompactMode"];
			else
				compactmode = nil;
			end
			if (vartable["Global Settings"]["CompactPercent"] ~= nil) then
				compactpercent = vartable["Global Settings"]["CompactPercent"];
			else
				compactpercent = nil;
			end
			if (vartable["Global Settings"]["HideBuffBackground"] ~= nil) then
				hidebuffbackground = vartable["Global Settings"]["HideBuffBackground"];
			else
				hidebuffbackground = nil;
			end
			if (vartable["Global Settings"]["ShortBars"] ~= nil) then
				shortbars = vartable["Global Settings"]["ShortBars"];
			else
				shortbars = nil;
			end
			if (vartable["Global Settings"]["HealerMode"] ~= nil) then
				healermode = vartable["Global Settings"]["HealerMode"];
			else
				healermode = nil;
			end
			if (vartable["Global Settings"]["DisplayCastableBuffs"] ~= nil) then
				displaycastablebuffs = vartable["Global Settings"]["DisplayCastableBuffs"];
			else
				displaycastablebuffs = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["ShowManaDeficit"] ~= nil) then
				showmanadeficit = vartable["Global Settings"]["ShowManaDeficit"];
			else
				showmanadeficit = nil;
			end
			if (vartable["Global Settings"]["InvertBuffs"] ~= nil) then
				invertbuffs = vartable["Global Settings"]["InvertBuffs"];
			else
				invertbuffs = nil;
			end
			if (vartable["Global Settings"]["DisplayCurableDebuff"] ~= nil) then
				displaycurabledebuff = vartable["Global Settings"]["DisplayCurableDebuff"];
			else
				displaycurabledebuff = nil;
			end
			if (vartable["Global Settings"]["DisplayBuffTimers"] ~= nil) then
				displaybufftimers = vartable["Global Settings"]["DisplayBuffTimers"];
			else
				displaybufftimers = nil;
			end
			if (vartable["Global Settings"]["DisplayOnlyMyDebuffs"] ~= nil) then
				displayonlymydebuffs = vartable["Global Settings"]["DisplayOnlyMyDebuffs"];
			else
				displayonlymydebuffs = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (showclassicon == nil) then
			showclassicon = 1;
		end
		if (showclassframe == nil) then
			showclassframe = 1;
		end
		if (showpvpicon == nil) then
			showpvpicon = 1;
		end
		if (numbuffsshown == nil) then
			numbuffsshown = 16;
		end
		if (numdebuffsshown == nil) then
			numdebuffsshown = 16;
		end
		if (scale == nil) then
			scale = 0.9;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (buffdebuffscale == nil) then
			buffdebuffscale = 1;
		end
		if (showportrait == nil) then
			showportrait = 0;
		end
		if (threedportrait == nil) then
			threedportrait = 0;
		end
		if (portraitcombattext == nil) then
			portraitcombattext = 0;
		end
		if (showrareeliteframe == nil) then
			showrareeliteframe = 0;
		end
		if (nameframecombopoints == nil) then
			nameframecombopoints = 0;
		end
		if (comboframedebuffs == nil) then
			comboframedebuffs = 0;
		end
		if (framestyle == nil) then
			framestyle = 1;
		end
		if (compactmode == nil) then
			compactmode = 0;
		end
		if (compactpercent == nil) then
			compactpercent = 0;
		end
		if (hidebuffbackground == nil) then
			hidebuffbackground = 0;
		end
		if (shortbars == nil) then
			shortbars = 0;
		end
		if (healermode == nil) then
			healermode = 0;
		end
		if (displaycastablebuffs == nil) then
			displaycastablebuffs = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (showmanadeficit == nil) then
			showmanadeficit = 0;
		end
		if (invertbuffs == nil) then
			invertbuffs = 0;
		end
		if (displaycurabledebuff == nil) then
			displaycurabledebuff = 0;
		end
		if (displaybufftimers == nil) then
			displaybufftimers = 1;
		end
		if (displayonlymydebuffs == nil) then
			displayonlymydebuffs = 0;
		end

		-- Call any code we need to activate them
		Perl_Focus_Reset_Buffs();		-- Reset the buff icons
		Perl_Focus_Frame_Style();		-- Reposition the frames
		Perl_Focus_Buff_Debuff_Background();	-- Hide/Show the background frame
		Perl_Focus_Set_Scale_Actual();		-- Set the scale
		Perl_Focus_Set_Transparency();		-- Set the transparency
		if (UnitExists("focus")) then
			Perl_Focus_Update_Once();
		end
	end

	Perl_Focus_Config[UnitName("player")] = {
		["Locked"] = locked,
		["ClassIcon"] = showclassicon,
		["ClassFrame"] = showclassframe,
		["PvPIcon"] = showpvpicon,
		["Buffs"] = numbuffsshown,
		["Debuffs"] = numdebuffsshown,
		["Scale"] = scale,
		["Transparency"] = transparency,
		["BuffDebuffScale"] = buffdebuffscale,
		["ShowPortrait"] = showportrait,
		["ThreeDPortrait"] = threedportrait,
		["PortraitCombatText"] = portraitcombattext,
		["ShowRareEliteFrame"] = showrareeliteframe,
		["NameFrameComboPoints"] = nameframecombopoints,
		["ComboFrameDebuffs"] = comboframedebuffs,
		["FrameStyle"] = framestyle,
		["CompactMode"] = compactmode,
		["CompactPercent"] = compactpercent,
		["HideBuffBackground"] = hidebuffbackground,
		["ShortBars"] = shortbars,
		["HealerMode"] = healermode,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["ClassColoredNames"] = classcolorednames,
		["ShowManaDeficit"] = showmanadeficit,
		["InvertBuffs"] = invertbuffs,
		["DisplayCurableDebuff"] = displaycurabledebuff,
		["DisplayBuffTimers"] = displaybufftimers,
		["DisplayOnlyMyDebuffs"] = displayonlymydebuffs,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Focus_Buff_UpdateAll()
	if (UnitName("focus")) then

		if (nameframecombopoints == 1 or comboframedebuffs == 1) then
			Perl_Focus_Buff_UpdateCPMeter();
		end

		local button, buffCount, buffTexture, buffApplications, color, debuffType, duration, timeLeft, cooldown;		-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
		local curableDebuffFound = 0;

		local numBuffs = 0;											-- Buff counter for correct layout
		for buffnum=1,numbuffsshown do										-- Start main buff loop
			if (displaycastablebuffs == 0) then								-- Which buff filter mode are we in?
				bufffilter = "HELPFUL";
			else
				bufffilter = "HELPFUL RAID";
			end
			_, _, buffTexture, buffApplications, _, duration, timeLeft, _, _ = UnitAura("focus", buffnum, bufffilter);	-- Get the texture and buff stacking information if any
			button = getglobal("Perl_Focus_Buff"..buffnum);						-- Create the main icon for the buff
			if (buffTexture) then										-- If there is a valid texture, proceed with buff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);				-- Set the texture
				getglobal(button:GetName().."DebuffBorder"):Hide();					-- Hide the debuff border
				buffCount = getglobal(button:GetName().."Count");					-- Declare the buff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);						-- Set the text to the number of applications if greater than 0
					buffCount:Show();								-- Show the text
				else
					buffCount:Hide();								-- Hide the text if equal to 0
				end
				if (displaybufftimers == 1) then
					cooldown = getglobal(button:GetName().."Cooldown");				-- Handle cooldowns
					if (duration) then
						if (duration > 0) then
							CooldownFrame_SetTimer(cooldown, timeLeft - duration, duration, 1);
							cooldown:Show();
						else
							CooldownFrame_SetTimer(cooldown, 0, 0, 0);
							cooldown:Hide();
						end
					else
						CooldownFrame_SetTimer(cooldown, 0, 0, 0);
						cooldown:Hide();
					end
				end
				numBuffs = numBuffs + 1;								-- Increment the buff counter
				button:Show();										-- Show the final buff icon
			else
				button:Hide();										-- Hide the icon since there isn't a buff in this position
			end
		end													-- End main buff loop

		local numDebuffs = 0;											-- Debuff counter for correct layout
		for debuffnum=1,numdebuffsshown do									-- Start main debuff loop
			Perl_Focus_Debuff_Set_Filter();								-- Are we targeting a friend or enemy and which filter do we need to apply?
			_, _, buffTexture, buffApplications, debuffType, duration, timeLeft, _, _ = UnitAura("focus", debuffnum, debufffilter);	-- Get the texture and debuff stacking information if any
			button = getglobal("Perl_Focus_Debuff"..debuffnum);						-- Create the main icon for the debuff
			if (buffTexture) then										-- If there is a valid texture, proceed with debuff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);				-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (UnitIsFriend("player", "focus")) then
								if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
									Perl_Focus_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_LevelFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_PortraitFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_ClassNameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_CivilianFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_RareEliteFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Focus_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									curableDebuffFound = 1;
								end
							end
						end
					end
				else
					color = DebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				getglobal(button:GetName().."DebuffBorder"):SetVertexColor(color.r, color.g, color.b);	-- Set the debuff border color
				getglobal(button:GetName().."DebuffBorder"):Show();					-- Show the debuff border
				buffCount = getglobal(button:GetName().."Count");					-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);						-- Set the text to the number of applications if greater than 0
					buffCount:Show();								-- Show the text
				else
					buffCount:Hide();								-- Hide the text if equal to 0
				end
				if (displaybufftimers == 1) then
					cooldown = getglobal(button:GetName().."Cooldown");				-- Handle cooldowns
					if (duration) then
						if (duration > 0) then
							CooldownFrame_SetTimer(cooldown, timeLeft - duration, duration, 1);
							cooldown:Show();
						else
							CooldownFrame_SetTimer(cooldown, 0, 0, 0);
							cooldown:Hide();
						end
					else
						CooldownFrame_SetTimer(cooldown, 0, 0, 0);
						cooldown:Hide();
					end
				end
				numDebuffs = numDebuffs + 1;								-- Increment the debuff counter
				button:Show();										-- Show the final debuff icon
			else
				button:Hide();										-- Hide the icon since there isn't a debuff in this position
			end
		end													-- End main debuff loop

		if (numBuffs == 0) then
			Perl_Focus_BuffFrame:Hide();
		else
			if (invertbuffs == 0) then
				Perl_Focus_BuffFrame:ClearAllPoints();
				if (UnitIsFriend("player", "focus")) then
					Perl_Focus_BuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, 2);
				else
					if (numDebuffs > 8) then
						Perl_Focus_BuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, -56);
					else
						Perl_Focus_BuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, -29);
					end
				end
			else
				Perl_Focus_BuffFrame:ClearAllPoints();
				if (UnitIsFriend("player", "focus")) then
					if (showclassframe == 1 or showrareeliteframe == 1) then
						Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 20);
					else
						Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, -2);
					end
				else
					if (showclassframe == 1 or showrareeliteframe == 1) then
						if (numDebuffs > 8) then
							Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 78);
						else
							Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 51);
						end
					else
						if (numDebuffs > 8) then
							Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 56);
						else
							Perl_Focus_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 29);
						end
					end
				end
			end

			Perl_Focus_BuffFrame:Show();
			if (numBuffs > 8) then
				Perl_Focus_BuffFrame:SetWidth(221);			-- 5 + 8 * (24 + 3)	5 = border gap, 8 buffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Focus_BuffFrame:SetHeight(61);			-- 2 rows tall
			else
				Perl_Focus_BuffFrame:SetWidth(5 + numBuffs * 27);	-- Dynamically extend the background frame
				Perl_Focus_BuffFrame:SetHeight(34);			-- 1 row tall
			end
		end

		if (numDebuffs == 0) then
			Perl_Focus_DebuffFrame:Hide();
		else
			if (invertbuffs == 0) then
				Perl_Focus_DebuffFrame:ClearAllPoints();
				if (UnitIsFriend("player", "focus")) then
					if (numBuffs > 8) then
						Perl_Focus_DebuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, -56);
					else
						Perl_Focus_DebuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, -29);
					end
				else
					Perl_Focus_DebuffFrame:SetPoint("TOPLEFT", "Perl_Focus_StatsFrame", "BOTTOMLEFT", 0, 2);
				end
			else
				Perl_Focus_DebuffFrame:ClearAllPoints();
				if (UnitIsFriend("player", "focus")) then
					if (showclassframe == 1 or showrareeliteframe == 1) then
						if (numBuffs > 8) then
							Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 78);
						else
							Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 51);
						end
					else
						if (numBuffs > 8) then
							Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 56);
						else
							Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 29);
						end
					end
				else
					if (showclassframe == 1 or showrareeliteframe == 1) then
						Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, 20);
					else
						Perl_Focus_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Focus_NameFrame", "TOPLEFT", 0, -2);
					end
				end
			end

			Perl_Focus_DebuffFrame:Show();
			if (numDebuffs > 8) then
				Perl_Focus_DebuffFrame:SetWidth(221);			-- 5 + 8 * (24 + 3)	5 = border gap, 8 buffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Focus_DebuffFrame:SetHeight(61);			-- 2 rows tall
			else
				Perl_Focus_DebuffFrame:SetWidth(5 + numDebuffs * 27);	-- Dynamically extend the background frame
				Perl_Focus_DebuffFrame:SetHeight(34);			-- 1 row tall
			end
		end

		if (curableDebuffFound == 0) then
			Perl_Focus_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_ClassNameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_CivilianFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_RareEliteFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Focus_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end
	end
end

function Perl_Focus_Debuff_Set_Filter()
	if (UnitIsFriend("player", "focus")) then
		if (displaycurabledebuff == 1) then
			debufffilter = "HARMFUL RAID";
			return;
		end
	else
		if (displayonlymydebuffs == 1) then
			debufffilter = "HARMFUL PLAYER";
			return;
		end
	end
	debufffilter = "HARMFUL";
end

function Perl_Focus_Buff_UpdateCPMeter()
	local debuffapplications;
	local _, playerclass = UnitClass("player");

	if (playerclass == "MAGE") then
		debuffapplications = Perl_Focus_Buff_GetApplications(PERL_LOCALIZED_Focus_FIRE_VULNERABILITY);
	elseif (playerclass == "PRIEST") then
		debuffapplications = Perl_Focus_Buff_GetApplications(PERL_LOCALIZED_Focus_SHADOW_VULNERABILITY);
	elseif (playerclass == "WARRIOR") then
		debuffapplications = Perl_Focus_Buff_GetApplications(PERL_LOCALIZED_Focus_SUNDER_ARMOR);
	elseif ((playerclass == "ROGUE") or (playerclass == "DRUID")) then
		return;
	else
		Perl_Focus_NameFrame_CPMeter:Hide();
		return;
	end

	if (debuffapplications == 0) then
		--Perl_Focus_CPFrame:Hide();
		Perl_Focus_NameFrame_CPMeter:Hide();
	else
		if (comboframedebuffs == 1) then
			Perl_Focus_CPText:SetText(debuffapplications);
			Perl_Focus_CPText:SetTextHeight(20);
			if (debuffapplications == 5) then
				Perl_Focus_CPFrame:Show();
				Perl_Focus_CPText:SetTextColor(1, 0, 0);	-- red text
			elseif (debuffapplications == 4) then
				Perl_Focus_CPFrame:Show();
				Perl_Focus_CPText:SetTextColor(1, 0.5, 0);	-- orange text
			elseif (debuffapplications == 3) then
				Perl_Focus_CPFrame:Show();
				Perl_Focus_CPText:SetTextColor(1, 1, 0);	-- yellow text
			elseif (debuffapplications == 2) then
				Perl_Focus_CPFrame:Show();
				Perl_Focus_CPText:SetTextColor(0.5, 1, 0);	-- yellow-green text
			elseif (debuffapplications == 1) then
				Perl_Focus_CPFrame:Show();
				Perl_Focus_CPText:SetTextColor(0, 1, 0);	-- green text
			else
				--Perl_Focus_CPFrame:Hide();
			end
		else
			--Perl_Focus_CPFrame:Hide();
		end

		if (nameframecombopoints == 1) then				-- this isn't nested since you can have both combo point styles on at the same time
			Perl_Focus_NameFrame_CPMeter:SetMinMaxValues(0, 5);
			Perl_Focus_NameFrame_CPMeter:SetValue(debuffapplications);
			if (debuffapplications == 5) then
				Perl_Focus_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 4) then
				Perl_Focus_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 3) then
				Perl_Focus_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 2) then
				Perl_Focus_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 1) then
				Perl_Focus_NameFrame_CPMeter:Show();
			else
				Perl_Focus_NameFrame_CPMeter:Hide();
			end
		else
			Perl_Focus_NameFrame_CPMeter:Hide();
		end
	end
end

function Perl_Focus_Buff_GetApplications(debuffname)
	local debuffApplications;
	local i = 1;

	while UnitDebuff("focus", i) do
		Perl_Focus_Tooltip:SetOwner(Perl_Focus_Frame, "ANCHOR_BOTTOMRIGHT");
		Perl_Focus_Tooltip:SetUnitDebuff("focus", i);
		if (Perl_Focus_TooltipTextLeft1:GetText() == debuffname) then
			_, _, _, debuffApplications = UnitDebuff("focus", i);
			Perl_Focus_Tooltip:Hide();
			return debuffApplications;
		end

		i = i + 1;
	end

	Perl_Focus_Tooltip:Hide();
	return 0;
end

function Perl_Focus_Reset_Buffs()
	local button, cooldown;
	for buffnum=1,16 do
		button = getglobal("Perl_Focus_Buff"..buffnum);
		cooldown = getglobal(button:GetName().."Cooldown");
		CooldownFrame_SetTimer(cooldown, 0, 0, 0);
		cooldown:Hide();
		button:Hide();

		button = getglobal("Perl_Focus_Debuff"..buffnum);
		cooldown = getglobal(button:GetName().."Cooldown");
		CooldownFrame_SetTimer(cooldown, 0, 0, 0);
		cooldown:Hide();
		button:Hide();
	end
end

function Perl_Focus_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 16) then
		GameTooltip:SetUnitDebuff("focus", self:GetID()-16, displaycurabledebuff);
	else
		GameTooltip:SetUnitBuff("focus", self:GetID(), displaycastablebuffs);
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Focus_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_Focus_DropDown, "Perl_Focus_NameFrame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "focus", showmenu);

	self:SetAttribute("unit", "focus");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_FocusDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_FocusDropDown_Initialize, "MENU");
end

function Perl_FocusDropDown_Initialize()
	local menu, name;
	if (UnitIsUnit("focus", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("focus", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("focus")) then
		if (UnitInParty("focus")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Focus_DropDown, menu, "focus", name);
	end
end

function Perl_Focus_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Focus_Frame:StartMoving();
	end
end

function Perl_Focus_DragStop(button)
	Perl_Focus_Frame:StopMovingOrSizing();
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Focus_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Focus_myAddOns_Details = {
			name = "Perl_Focus",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Focus_myAddOns_Help = {};
		Perl_Focus_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Focus_myAddOns_Details, Perl_Focus_myAddOns_Help);
	end
end
