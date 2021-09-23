---------------
-- Variables --
---------------
Perl_Target_Config = {};
local Perl_Target_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Target_GetVars)
local locked = 0;		-- unlocked by default
local showcp = 1;		-- combo points displayed by default
local showclassicon = 1;	-- show the class icon
local showclassframe = 1;	-- show the class frame
local showpvpicon = 1;		-- show the pvp icon
local numbuffsshown = 20;	-- buff row is 2x10
local numdebuffsshown = 20;	-- debuff row is 4x10
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
local soundtargetchange = 0;	-- sound when changing targets is off by default
local displaycastablebuffs = 0;	-- display all buffs by default
local classcolorednames = 0;	-- names are colored based on pvp status by default
local showmanadeficit = 0;	-- Mana deficit in healer mode is off by default
local invertbuffs = 0;		-- buffs and debuffs are below the target frame by default
local showguildname = 0;	-- guild names are hidden by default
local eliteraregraphic = 0;	-- the blizzard elite/rare graphic is off by default
local displaycurabledebuff = 0;	-- display all debuffs by default
local displaybufftimers = 1;	-- buff/debuff timers are on by default
local displaynumbericthreat = 1;-- threat is displayed numerically by default
local displayonlymydebuffs = 0;	-- display all debuffs by default

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized

-- Fade Bar Variables
local Perl_Target_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Target_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Target_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Target_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Target_ManaBar_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Target_ManaBar_Time_Update_Rate = 0.1;	-- the update interval

-- Local variables to save memory
local targethealth, targethealthmax, targethealthpercent, targetmana, targetmanamax, targetmanapercent, targetpower, targetlevel, targetlevelcolor, targetclassification, targetclassificationframetext, englishclass, creatureType, r, g, b, guildName, targetonupdatemana, bufffilter, debufffilter;


----------------------
-- Loading Function --
----------------------
function Perl_Target_OnLoad(self)
	-- Combat Text
	CombatFeedback_Initialize(self, Perl_Target_HitIndicator, 30);

	-- Events
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("UNIT_COMBO_POINTS");
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
	self:SetScript("OnEvent", Perl_Target_OnEvent);
	self:SetScript("OnHide", Perl_Target_OnHide);
	self:SetScript("OnShow", Perl_Target_OnShow);
	self:SetScript("OnUpdate", CombatFeedback_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Target_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Target_NameFrame:GetFrameLevel() + 2);
	Perl_Target_Name:SetFrameLevel(Perl_Target_NameFrame:GetFrameLevel() + 1);
	Perl_Target_LevelFrame_CastClickOverlay:SetFrameLevel(Perl_Target_LevelFrame:GetFrameLevel() + 1);
	Perl_Target_RareEliteFrame_CastClickOverlay:SetFrameLevel(Perl_Target_RareEliteFrame:GetFrameLevel() + 1);
	Perl_Target_PortraitFrame_CastClickOverlay:SetFrameLevel(Perl_Target_PortraitFrame:GetFrameLevel() + 2);
	Perl_Target_PortraitTextFrame:SetFrameLevel(Perl_Target_PortraitFrame:GetFrameLevel() + 1);
	Perl_Target_ClassNameFrame_CastClickOverlay:SetFrameLevel(Perl_Target_ClassNameFrame:GetFrameLevel() + 1);
	Perl_Target_GuildFrame_CastClickOverlay:SetFrameLevel(Perl_Target_GuildFrame:GetFrameLevel() + 1);
	Perl_Target_CPFrame_CastClickOverlay:SetFrameLevel(Perl_Target_CPFrame:GetFrameLevel() + 1);
	Perl_Target_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Target_StatsFrame:GetFrameLevel() + 1);
	Perl_Target_RaidIconFrame:SetFrameLevel(Perl_Target_PortraitFrame_CastClickOverlay:GetFrameLevel() - 1);
	Perl_Target_HealthBarFadeBar:SetFrameLevel(Perl_Target_HealthBar:GetFrameLevel() - 1);
	Perl_Target_ManaBarFadeBar:SetFrameLevel(Perl_Target_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "target");

	-- Misc
	self.unit = "target";
end


-------------------
-- Event Handler --
-------------------
function Perl_Target_OnEvent()
	local func = Perl_Target_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Target: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Target_Events:PLAYER_TARGET_CHANGED()
	if (UnitExists(Perl_Target_Frame:GetAttribute("unit"))) then
		Perl_Target_Update_Once();		-- Set the unchanging info for the target
	end
end
Perl_Target_Events.PARTY_MEMBERS_CHANGED = Perl_Target_Events.PLAYER_TARGET_CHANGED;
Perl_Target_Events.PARTY_LEADER_CHANGED = Perl_Target_Events.PLAYER_TARGET_CHANGED;
Perl_Target_Events.PARTY_MEMBER_ENABLE = Perl_Target_Events.PLAYER_TARGET_CHANGED;
Perl_Target_Events.PARTY_MEMBER_DISABLE = Perl_Target_Events.PLAYER_TARGET_CHANGED;

function Perl_Target_Events:PARTY_LOOT_METHOD_CHANGED()
	Perl_Target_Update_Loot_Method();
end
Perl_Target_Events.RAID_ROSTER_UPDATE = Perl_Target_Events.PARTY_LOOT_METHOD_CHANGED;

function Perl_Target_Events:UNIT_HEALTH()
	if (arg1 == "target") then
		Perl_Target_Update_Health();		-- Update health values
	end
end
Perl_Target_Events.UNIT_MAXHEALTH = Perl_Target_Events.UNIT_HEALTH;

function Perl_Target_Events:UNIT_ENERGY()
	if (arg1 == "target") then
		Perl_Target_Update_Mana();		-- Update energy/mana/rage values
	end
end
Perl_Target_Events.UNIT_MAXENERGY = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_MANA = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_MAXMANA = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_RAGE = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_MAXRAGE = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_FOCUS = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_MAXFOCUS = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_RUNIC_POWER = Perl_Target_Events.UNIT_ENERGY;
Perl_Target_Events.UNIT_MAXRUNIC_POWER = Perl_Target_Events.UNIT_ENERGY;

function Perl_Target_Events:UNIT_AURA()
	if (arg1 == "target") then
		Perl_Target_Buff_UpdateAll();		-- Update the buffs
	end
end

function Perl_Target_Events:UNIT_DYNAMIC_FLAGS()
	if (arg1 == "target") then
		Perl_Target_Update_Text_Color();	-- Has the target been tapped by someone else?
	end
end

function Perl_Target_Events:UNIT_COMBAT()
	if (arg1 == "target") then
		CombatFeedback_OnCombatEvent(Perl_Target_Frame, arg2, arg3, arg4, arg5);
	end
end

function Perl_Target_Events:UNIT_SPELLMISS()
	if (arg1 == "target") then
		CombatFeedback_OnSpellMissEvent(arg2);
	end
end

function Perl_Target_Events:UNIT_NAME_UPDATE()
	if (arg1 == "target") then
		Perl_Target_Frame_Set_Level();
		Perl_Target_Update_Name();
	end
end

function Perl_Target_Events:UNIT_FACTION()
	Perl_Target_Update_Text_Color();		-- Is the character PvP flagged?
	Perl_Target_Update_PvP_Status_Icon();		-- Set pvp status icon
end
Perl_Target_Events.UNIT_PVP_UPDATE = Perl_Target_Events.UNIT_FACTION;

function Perl_Target_Events:UNIT_PORTRAIT_UPDATE()
	if (arg1 == "target") then
		Perl_Target_Update_Portrait();
	end
end

function Perl_Target_Events:UNIT_COMBO_POINTS()
	if (arg1 == "player" or arg1 == "vehicle") then
		Perl_Target_Update_Combo_Points();		-- How many combo points are we at?
	end
end

function Perl_Target_Events:RAID_TARGET_UPDATE()
	Perl_Target_UpdateRaidTargetIcon();
end

function Perl_Target_Events:UNIT_LEVEL()
	if (arg1 == "target") then
		Perl_Target_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
	end
end

function Perl_Target_Events:UNIT_DISPLAYPOWER()
	if (arg1 == "target") then
		Perl_Target_Update_Mana_Bar();		-- What type of energy are they using now?
		Perl_Target_Update_Mana();		-- Update the energy info immediately
	end
end

function Perl_Target_Events:VOICE_START()
	if (arg1 == "target") then
		Perl_Target_VoiceChatIconFrame:Show();
	end
end

function Perl_Target_Events:VOICE_STOP()
	if (arg1 == "target") then
		Perl_Target_VoiceChatIconFrame:Hide();
	end
end

function Perl_Target_Events:UNIT_THREAT_LIST_UPDATE()
	if (arg1 == "target") then
		Perl_Target_Update_Threat();
	end
end

function Perl_Target_Events:PLAYER_LOGIN()
	Perl_Target_Initialize();
end
Perl_Target_Events.PLAYER_ENTERING_WORLD = Perl_Target_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Target_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Target_Set_Scale_Actual();		-- Set the scale
		Perl_Target_Set_Transparency();		-- Set the transparency
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Target_Config[UnitName("player")]) == "table") then
		Perl_Target_GetVars();
	else
		Perl_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Target_Initialize_Frame_Color();		-- Give the borders (and background if applicable) that "Perl" look
	Perl_Target_Frame_Style();			-- Layout the frame according to our mode
	Perl_Target_Buff_Debuff_Background();		-- Do the buffs and debuffs have their transparent background frame?
	Perl_Target_Reset_Buffs();			-- Hide any unnecessary buff/debuff buttons

	local _, class = UnitClass("player");
	if (not (class == "ROGUE" or class == "DRUID" or class == "WARRIOR" or class == "PRIEST" or class == "PALADIN" or class == "MAGE")) then
		showcp = 0;
		Perl_Target_UpdateVars();		-- I suck, I know, go away
	end

	Perl_Target_CPText:SetText(0);
	Perl_Target_NameFrame_CPMeter:SetMinMaxValues(0, 5);
	Perl_Target_NameFrame_CPMeter:SetValue(0);

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(TargetFrame);
	Perl_clearBlizzardFrameDisable(ComboFrame);
	Perl_clearBlizzardFrameDisable(TargetFrameSpellBar);
	Perl_clearBlizzardFrameDisable(TargetFrameToT);

	-- Disable Blizzard's Target Cast Bar
	--TargetFrameSpellBar:UnregisterEvent("CVAR_UPDATE");
	--TargetFrameSpellBar:UnregisterEvent("PLAYER_TARGET_CHANGED");

	-- MyAddOns Support
	Perl_Target_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_Target_Frame:SetUserPlaced(1);

	-- WoW 2.0 Secure API Stuff
	RegisterUnitWatch(Perl_Target_Frame);

	-- Set the initialization flag
	Initialized = 1;
end

function Perl_Target_Initialize_Frame_Color()
	Perl_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_ClassNameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_ClassNameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_GuildFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_GuildFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_LevelFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_BuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_DebuffFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_CPFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_CPFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_PortraitFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_RareEliteFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_RareEliteFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_ClassNameBarText:SetTextColor(1, 1, 1);
	Perl_Target_GuildBarText:SetTextColor(1, 1, 1, 1);
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Target_Update_Once()
	Perl_Target_HealthBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_Target_ManaBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_Target_HealthBar:SetValue(0);	-- Do this so we don't fade the bar on a fresh target switch
	Perl_Target_ManaBar:SetValue(0);	-- Do this so we don't fade the bar on a fresh target switch
	Perl_Target_Update_Combo_Points();	-- Do we have any combo points (we shouldn't)
	Perl_Target_Update_Portrait();		-- Set the target's portrait and adjust the combo point frame
	Perl_Target_Update_Health();		-- Set the target's health
	Perl_Target_Update_Mana_Bar();		-- What type of mana bar is it?
	Perl_Target_Update_Mana();		-- Set the target's mana
	Perl_Target_Update_PvP_Status_Icon();	-- Set pvp status icon
	Perl_Target_Frame_Set_Level();		-- What level is it and is it rare/elite/boss
	Perl_Target_Buff_UpdateAll();		-- Update the buffs
	Perl_Target_UpdateRaidTargetIcon();	-- Display the raid target icon if needed
	Perl_Target_Update_Name();		-- Update the name
	Perl_Target_Update_Text_Color();	-- Has the target been tapped by someone else?
	Perl_Target_Update_Leader();		-- Is the target the party/raid leader?
	Perl_Target_Update_Loot_Method();	-- Is the target the loot master?
	Perl_Target_Update_Threat();		-- Update the threat icon if needed

	-- Begin: Draw the class icon?
	if (showclassicon == 1) then
		if (UnitIsPlayer("target")) then
			_, englishclass = UnitClass("target");
			Perl_Target_ClassTexture:SetTexCoord(PCUF_CLASSPOSRIGHT[englishclass], PCUF_CLASSPOSLEFT[englishclass], PCUF_CLASSPOSTOP[englishclass], PCUF_CLASSPOSBOTTOM[englishclass]);
			Perl_Target_ClassTexture:Show();
		else
			Perl_Target_ClassTexture:Hide();
		end
	end
	-- End: Draw the class icon?

	-- Begin: Set the target's class in the class frame
	if (showclassframe == 1) then
		if (UnitIsPlayer("target")) then
			Perl_Target_ClassNameBarText:SetText(UnitClass("target"));
		else
			creatureType = UnitCreatureType("target");
			if (creatureType == PERL_LOCALIZED_NOTSPECIFIED) then
				creatureType = PERL_LOCALIZED_CREATURE;
			end
			Perl_Target_ClassNameBarText:SetText(creatureType);
		end
	end
	-- End: Set the target's class in the class frame

	-- Begin: Set the guild name
	if (showguildname == 1) then
		if (UnitIsPlayer("target") and UnitIsVisible("target")) then
			guildName = GetGuildInfo("target");
			if (guildName == nil) then
				guildName = PERL_LOCALIZED_TARGET_UNGUILDED;
			end
		else
			guildName = PERL_LOCALIZED_TARGET_NA;
		end
		Perl_Target_GuildBarText:SetText(guildName);
	end
	-- End: Set the guild name

	-- Begin: Voice Chat Icon already in progress?
	if (UnitIsTalking(UnitName("target"))) then
		Perl_Target_VoiceChatIconFrame:Show();
	else
		Perl_Target_VoiceChatIconFrame:Hide();
	end
	-- End: Voice Chat Icon already in progress?
end

function Perl_Target_Update_Health()
	targethealth = UnitHealth("target");
	targethealthmax = UnitHealthMax("target");
	targethealthpercent = floor(targethealth/targethealthmax*100+0.5);

	if (UnitIsDead("target") or UnitIsGhost("target")) then				-- This prevents negative health
		targethealth = 0;
		targethealthpercent = 0;
	end

	-- Set Dead Icon
	if (UnitIsDead("target") or UnitIsGhost("target")) then
		Perl_Target_DeadStatus:Show();
	else
		Perl_Target_DeadStatus:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (targethealth < Perl_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targethealth > Perl_Target_HealthBar:GetValue())) then
			Perl_Target_HealthBarFadeBar:SetMinMaxValues(0, targethealthmax);
			Perl_Target_HealthBarFadeBar:SetValue(Perl_Target_HealthBar:GetValue());
			Perl_Target_HealthBarFadeBar:Show();
			Perl_Target_HealthBar_Fade_Color = 1;
			Perl_Target_HealthBar_Fade_Time_Elapsed = 0;
			Perl_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Target_HealthBar:SetValue(targethealthmax - targethealth);
	else
		Perl_Target_HealthBar:SetValue(targethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((targethealthpercent <= 100) and (targethealthpercent > 75)) then
--			Perl_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((targethealthpercent <= 75) and (targethealthpercent > 50)) then
--			Perl_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((targethealthpercent <= 50) and (targethealthpercent > 25)) then
--			Perl_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = targethealth / targethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (framestyle == 1) then
		Perl_Target_HealthBarTextRight:SetText();							-- Hide this text in this frame style
		Perl_Target_HealthBarTextCompactPercent:SetText();						-- Hide this text in this frame style
		Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax.." | "..targethealthpercent.."%");
	elseif (framestyle == 2) then
		if (compactmode == 0) then
			if (healermode == 0) then
				Perl_Target_HealthBarTextCompactPercent:SetText();					-- Hide this text in this frame style
				Perl_Target_HealthBarText:SetText(targethealthpercent.."%");
				Perl_Target_HealthBarTextRight:SetText(targethealth.."/"..targethealthmax);
			else
				Perl_Target_HealthBarTextCompactPercent:SetText();					-- Hide this text in this frame style
				Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
				Perl_Target_HealthBarTextRight:SetText("-"..targethealthmax - targethealth);
			end
			
		else
			if (compactpercent == 0) then
				if (healermode == 0) then
					Perl_Target_HealthBarTextRight:SetText();					-- Hide this text in this frame style
					Perl_Target_HealthBarTextCompactPercent:SetText();				-- Hide this text in this frame style
				else
					Perl_Target_HealthBarTextRight:SetText("-"..targethealthmax - targethealth);
					Perl_Target_HealthBarTextCompactPercent:SetText();				-- Hide this text in this frame style
				end
				Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
			else
				if (healermode == 0) then
					Perl_Target_HealthBarTextRight:SetText();					-- Hide this text in this frame style
				else
					Perl_Target_HealthBarTextRight:SetText("-"..targethealthmax - targethealth);
				end
				Perl_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
				Perl_Target_HealthBarTextCompactPercent:SetText(targethealthpercent.."%");
			end
		end
	end

	if (UnitIsDead("target")) then
		if (UnitIsPlayer("target")) then
			_, englishclass = UnitClass("target");
			if (englishclass == "HUNTER") then	-- If the dead is a hunter, check for Feign Death
				local buffnum = 1;
				local _, _, buffTexture = UnitBuff("target", buffnum);
				while (buffTexture) do
					if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
						Perl_Target_HealthBarText:SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						break;
					end
					buffnum = buffnum + 1;
					_, _, buffTexture = UnitBuff("target", buffnum);
				end
			end
		end
	end
end

function Perl_Target_Update_Mana()
	targetmana = UnitMana("target");
	targetmanamax = UnitManaMax("target");
	targetpower = UnitPowerType("target");

	if (UnitIsDead("target") or UnitIsGhost("target")) then				-- This prevents negative mana
		targetmana = 0;
	end

	if (targetmana ~= targetmanamax) then
		Perl_Target_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_Target_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (targetmana < Perl_Target_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targetmana > Perl_Target_ManaBar:GetValue())) then
			Perl_Target_ManaBarFadeBar:SetMinMaxValues(0, targetmanamax);
			Perl_Target_ManaBarFadeBar:SetValue(Perl_Target_ManaBar:GetValue());
			Perl_Target_ManaBarFadeBar:Show();
			Perl_Target_ManaBar_Fade_Color = 1;
			Perl_Target_ManaBar_Fade_Time_Elapsed = 0;
			Perl_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Target_ManaBar:SetValue(targetmanamax - targetmana);
	else
		Perl_Target_ManaBar:SetValue(targetmana);
	end

	Perl_Target_Update_Mana_Text();
end

function Perl_Target_Update_Mana_Text()
	if (framestyle == 1) then
		Perl_Target_ManaBarTextRight:SetTextColor(1, 1, 1, 1);
		Perl_Target_ManaBarTextRight:SetText();			-- Hide this text in this frame style
		Perl_Target_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style

		if (targetpower == 1 or targetpower == 2 or targetpower == 6) then
			Perl_Target_ManaBarText:SetText(targetmana);
		else
			Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
		end
	elseif (framestyle == 2) then
		targetmanapercent = floor(targetmana/targetmanamax*100+0.5);

		if (compactmode == 0) then
			Perl_Target_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style

			if (healermode == 0) then
				Perl_Target_ManaBarTextRight:SetTextColor(1, 1, 1, 1);
				if (targetpower == 1 or targetpower == 2 or targetpower == 6) then
					Perl_Target_ManaBarText:SetText(targetmana.."%");
					Perl_Target_ManaBarTextRight:SetText(targetmana);
				else
					Perl_Target_ManaBarText:SetText(targetmanapercent.."%");
					Perl_Target_ManaBarTextRight:SetText(targetmana.."/"..targetmanamax);
				end
			else
				Perl_Target_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
				if (showmanadeficit == 1) then
					Perl_Target_ManaBarTextRight:SetText("-"..targetmanamax - targetmana);
				else
					Perl_Target_ManaBarTextRight:SetText();
				end
				if (targetpower == 1 or targetpower == 2 or targetpower == 6) then
					Perl_Target_ManaBarText:SetText(targetmana);
				else
					Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
				end
			end
		else
			if (compactpercent == 0) then
				Perl_Target_ManaBarTextCompactPercent:SetText();	-- Hide this text in this frame style
				if (healermode == 1) then
					if (showmanadeficit == 1) then
						Perl_Target_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
						Perl_Target_ManaBarTextRight:SetText("-"..targetmanamax - targetmana);			-- Hide this text in this frame style
					else
						Perl_Target_ManaBarTextRight:SetText();			-- Hide this text in this frame style
					end
				else
					Perl_Target_ManaBarTextRight:SetText();			-- Hide this text in this frame style
				end
				if (targetpower == 1 or targetpower == 2 or targetpower == 6) then
					Perl_Target_ManaBarText:SetText(targetmana);
				else
					Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
				end
			else
				if (healermode == 1) then
					if (showmanadeficit == 1) then
						Perl_Target_ManaBarTextRight:SetTextColor(0.5, 0.5, 0.5, 1);
						Perl_Target_ManaBarTextRight:SetText("-"..targetmanamax - targetmana);			-- Hide this text in this frame style
					else
						Perl_Target_ManaBarTextRight:SetText();			-- Hide this text in this frame style
					end
				else
					Perl_Target_ManaBarTextRight:SetText();			-- Hide this text in this frame style
				end

				if (targetpower == 1 or targetpower == 2 or targetpower == 6) then
					Perl_Target_ManaBarText:SetText(targetmana);
					Perl_Target_ManaBarTextCompactPercent:SetText(targetmana.."%");
				else
					Perl_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
					Perl_Target_ManaBarTextCompactPercent:SetText(targetmanapercent.."%");
				end
			end
		end
	end
end

function Perl_Target_OnUpdate_ManaBar(arg1)
	Perl_Target_ManaBar_Time_Elapsed = Perl_Target_ManaBar_Time_Elapsed + arg1;
	if (Perl_Target_ManaBar_Time_Elapsed > Perl_Target_ManaBar_Time_Update_Rate) then
		Perl_Target_ManaBar_Time_Elapsed = 0;

		targetonupdatemana = UnitPower("target", UnitPowerType("target"));
		if (playeronupdatemana ~= targetmana) then
			targetmana = targetonupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Target_ManaBar:SetValue(targetmanamax - targetonupdatemana);
			else
				Perl_Target_ManaBar:SetValue(targetonupdatemana);
			end
			Perl_Target_Update_Mana_Text();
		end
	end
end

function Perl_Target_Update_Mana_Bar()
	targetpower = UnitPowerType("target");

	-- Set mana bar color
	if (UnitManaMax("target") == 0) then
		Perl_Target_ManaBar:Hide();
		Perl_Target_ManaBarBG:Hide();
	elseif (targetpower == 1) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
	elseif (targetpower == 2) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
	elseif (targetpower == 3) then
		Perl_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
	elseif (targetpower == 6) then
		Perl_Target_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
	else
		Perl_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		Perl_Target_ManaBar:Show();
		Perl_Target_ManaBarBG:Show();
	end
end

function Perl_Target_Update_Combo_Points()
	local _, playerclass = UnitClass("player");
	if (playerclass == "ROGUE" or playerclass == "DRUID" or CanExitVehicle()) then	-- Noticed in 2.1.3 that this is being called for warriors also...huh?
		local combopoints = GetComboPoints("vehicle","target");			-- How many Combo Points does the player have in their vehicle?
		if (combopoints == 0) then
			combopoints = GetComboPoints("player");				-- We aren't in a vehicle, get regular combo points
		end

		if (showcp == 1) then
			Perl_Target_CPText:SetText(combopoints);
			if (combopoints == 5) then
				Perl_Target_CPText:SetTextColor(1, 0, 0);		-- red text
			elseif (combopoints == 4) then
				Perl_Target_CPText:SetTextColor(1, 0.5, 0);		-- orange text
			elseif (combopoints == 3) then
				Perl_Target_CPText:SetTextColor(1, 1, 0);		-- yellow text
			elseif (combopoints == 2) then
				Perl_Target_CPText:SetTextColor(0.5, 1, 0);		-- yellow-green text
			elseif (combopoints == 1) then
				Perl_Target_CPText:SetTextColor(0, 1, 0);		-- green text
			else
				Perl_Target_CPText:SetTextColor(0, 0.5, 0);		-- dark green text
			end
		end

		if (nameframecombopoints == 1) then					-- this isn't nested since you can have both combo point styles on at the same time
			Perl_Target_NameFrame_CPMeter:SetMinMaxValues(0, 5);
			Perl_Target_NameFrame_CPMeter:SetValue(combopoints);
			if (combopoints == 5) then
				Perl_Target_NameFrame_CPMeter:Show();
				
			elseif (combopoints == 4) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (combopoints == 3) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (combopoints == 2) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (combopoints == 1) then
				Perl_Target_NameFrame_CPMeter:Show();
			else
				Perl_Target_NameFrame_CPMeter:Hide();
			end
		else
			Perl_Target_NameFrame_CPMeter:Hide();
		end
	end
end

function Perl_Target_Update_PvP_Status_Icon()
	if (showpvpicon == 1 and UnitIsPVP("target") and not UnitIsPVPSanctuary("target")) then
		if (UnitIsPVPFreeForAll("target")) then
			Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			Perl_Target_PVPStatus:Show();
		elseif (UnitFactionGroup("target")) then
			Perl_Target_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup("target"));
			Perl_Target_PVPStatus:Show();
		else
			Perl_Target_PVPStatus:Hide();
		end
	else
		Perl_Target_PVPStatus:Hide();
	end
end

function Perl_Target_Update_Name()
	if (UnitIsPlayer("target")) then
		if (showclassicon == 1) then
			Perl_Target_NameBarText:SetPoint("LEFT", "Perl_Target_ClassTexture", "RIGHT", 2, 0);
			if (showpvpicon == 1) then
				Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 44);
			else
				Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 28);
			end
		else
			Perl_Target_NameBarText:SetPoint("LEFT", "Perl_Target_ClassTexture", "RIGHT", -13, 0);
			if (showpvpicon == 1) then
				Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 28);
			else
				Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 12);
			end
		end
	else
		Perl_Target_NameBarText:SetPoint("LEFT", "Perl_Target_ClassTexture", "RIGHT", -13, 0);
		if (UnitIsPVP("target") and showpvpicon == 1) then
			Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 28);
		else
			Perl_Target_NameBarText:SetWidth(Perl_Target_Name:GetWidth() - 12);
		end
	end
	Perl_Target_NameBarText:SetText(UnitName("target"));
end	

function Perl_Target_Update_Text_Color()
	if (classcolorednames == 1) then
		if (UnitIsPlayer("target")) then
			_, englishclass = UnitClass("target");
			Perl_Target_NameBarText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
			return;
		end
	end

	if (UnitPlayerControlled("target")) then						-- is it a player
		if (UnitCanAttack("target", "player")) then					-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", "target")) then				-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else									-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", "target")) then					-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP("target") and not UnitIsPVPSanctuary("target") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
			-- Players we can assist but are PvP flagged are green
			r = 0.0;
			g = 1.0;
			b = 0.0;
		else										-- friendly non pvp enabled character
			-- All other players are blue (the usual state on the "blue" server)
			r = 0.5;
			g = 0.5;
			b = 1.0;
		end
		Perl_Target_NameBarText:SetTextColor(r, g, b);
	elseif (UnitIsTapped("target") and not UnitIsTappedByPlayer("target")) then
		Perl_Target_NameBarText:SetTextColor(0.5, 0.5, 0.5);				-- not our tap
	else
		if (UnitIsVisible("target")) then
			local reaction = UnitReaction("target", "player");
			if (reaction) then
				r = FACTION_BAR_COLORS[reaction].r;
				g = FACTION_BAR_COLORS[reaction].g;
				b = FACTION_BAR_COLORS[reaction].b;
				Perl_Target_NameBarText:SetTextColor(r, g, b);
			else
				Perl_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
			end
		else
			if (UnitCanAttack("target", "player")) then				-- are we in an enemy controlled zone
				-- Hostile players are red
				if (not UnitCanAttack("player", "target")) then			-- enemy is not pvp enabled
					r = 0.5;
					g = 0.5;
					b = 1.0;
				else								-- enemy is pvp enabled
					r = 1.0;
					g = 0.0;
					b = 0.0;
				end
			elseif (UnitCanAttack("player", "target")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
				-- Players we can attack but which are not hostile are yellow
				r = 1.0;
				g = 1.0;
				b = 0.0;
			elseif (UnitIsPVP("target") and not UnitIsPVPSanctuary("target") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
			Perl_Target_NameBarText:SetTextColor(r, g, b);
		end
		
	end
end

function Perl_Target_Frame_Set_Level()
	targetlevel = UnitLevel("target");			-- Get and store the level of the target
	targetlevelcolor = GetQuestDifficultyColor(targetlevel);-- Get the "con color" of the target
	targetclassification = UnitClassification("target");	-- Get the type of character the target is (rare, elite, worldboss)
	targetclassificationframetext = nil;			-- Variable set to nil so we can easily track if target is a player or not elite

	Perl_Target_LevelBarText:SetVertexColor(targetlevelcolor.r, targetlevelcolor.g, targetlevelcolor.b);
	if (displaynumbericthreat == 0) then
		Perl_Target_RareEliteBarText:SetVertexColor(targetlevelcolor.r, targetlevelcolor.g, targetlevelcolor.b);
	end

	if (targetlevel < 0) then
		Perl_Target_LevelBarText:SetTextColor(1, 0, 0);
		if (UnitIsPlayer("target")) then
			targetclassificationframetext = nil;
		end
		targetlevel = "??";
	end

	if (targetclassification == "worldboss") then
		Perl_Target_RareEliteBarText:SetTextColor(1, 0, 0);
		Perl_Target_EliteRareGraphic:SetTexture("Interface\\AddOns\\Perl_Config\\Perl_Elite");
		targetclassificationframetext = PERL_LOCALIZED_TARGET_BOSS;
	elseif (targetclassification == "rareelite") then
		Perl_Target_EliteRareGraphic:SetTexture("Interface\\AddOns\\Perl_Config\\Perl_RareElite");
		targetclassificationframetext = PERL_LOCALIZED_TARGET_RAREELITE;
		targetlevel = targetlevel.."r+";
	elseif (targetclassification == "elite") then
		Perl_Target_EliteRareGraphic:SetTexture("Interface\\AddOns\\Perl_Config\\Perl_Elite");
		targetclassificationframetext = PERL_LOCALIZED_TARGET_ELITE;
		targetlevel = targetlevel.."+";
	elseif (targetclassification == "rare") then
		Perl_Target_EliteRareGraphic:SetTexture("Interface\\AddOns\\Perl_Config\\Perl_Rare");
		targetclassificationframetext = PERL_LOCALIZED_TARGET_RARE;
		targetlevel = targetlevel.."r";
	else
		Perl_Target_EliteRareGraphic:SetTexture();
	end

	Perl_Target_LevelBarText:SetText(targetlevel);						-- Set level frame text

	if (showrareeliteframe == 1 and displaynumbericthreat == 0) then
		if (targetclassificationframetext == nil) then
			Perl_Target_RareEliteBarText:SetText(PERL_LOCALIZED_TARGET_NA);
		else
			Perl_Target_RareEliteBarText:SetText(targetclassificationframetext);	-- Set the text
		end
	end
end

function Perl_Target_UpdateRaidTargetIcon()
	local index = GetRaidTargetIndex("target");
	if (index) then
		SetRaidTargetIconTexture(Perl_Target_RaidTargetIcon, index);
		Perl_Target_RaidTargetIcon:Show();
	else
		Perl_Target_RaidTargetIcon:Hide();
	end
end

function Perl_Target_Update_Leader()
	if (UnitIsPartyLeader("target")) then
		Perl_Target_LeaderIcon:Show();
	else
		Perl_Target_LeaderIcon:Hide();
	end
end

function Perl_Target_Update_Loot_Method()
	local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod();
	if (masterlooterRaidID ~= nil) then
		if (masterlooterRaidID < 10) then
			if (UnitName("raid0"..masterlooterRaidID) == UnitName("target")) then
				Perl_Target_MasterIcon:Show();
				return;
			end
		else
			if (UnitName("raid"..masterlooterRaidID) == UnitName("target")) then
				Perl_Target_MasterIcon:Show();
				return;
			end
		end
	elseif (masterlooterPartyID ~= nil) then
		if (UnitName("masterlooterPartyID") == UnitName("target")) then
			Perl_Target_MasterIcon:Show();
			return;
		end
	end
	Perl_Target_MasterIcon:Hide();
end

function Perl_Target_Update_Portrait()
	if (showportrait == 1) then
		if (threedportrait == 0) then
			SetPortraitTexture(Perl_Target_Portrait, "target");			-- Load the correct 2d graphic
		else
			if (UnitIsVisible("target")) then
				Perl_Target_PortraitFrame_TargetModel:SetUnit("target");	-- Load the correct 3d graphic
				Perl_Target_PortraitFrame_TargetModel:SetCamera(0);
				Perl_Target_Portrait:Hide();					-- Hide the 2d graphic
				Perl_Target_PortraitFrame_TargetModel:Show();			-- Show the 3d graphic
			else
				SetPortraitTexture(Perl_Target_Portrait, "target");		-- Load the correct 2d graphic
				Perl_Target_PortraitFrame_TargetModel:Hide();			-- Hide the 3d graphic
				Perl_Target_Portrait:Show();					-- Show the 2d graphic
			end
		end
	end
end

function Perl_Target_Update_Threat()
	local status = UnitThreatSituation("player", "target");

	if (status == nil) then
		Perl_Target_ThreatIndicator:Hide();
	else
		if (status > 0 and PCUF_THREATICON == 1) then
			Perl_Target_ThreatIndicator:SetVertexColor(GetThreatStatusColor(status));
			Perl_Target_ThreatIndicator:Show();
		else
			Perl_Target_ThreatIndicator:Hide();
		end
	end

	local _, statustwo, threatpct, _, _ = UnitDetailedThreatSituation("player", "target")
	if (statustwo ~= nil and displaynumbericthreat == 1) then
		Perl_Target_RareEliteBarText:SetVertexColor(GetThreatStatusColor(status));
		Perl_Target_RareEliteBarText:SetText(floor(tostring(threatpct)+0.5));
	else
		if (displaynumbericthreat == 1) then
			Perl_Target_RareEliteBarText:SetVertexColor(GetThreatStatusColor(status));
			Perl_Target_RareEliteBarText:SetText(PERL_LOCALIZED_TARGET_NA);
		end
	end
	
end

function Perl_Target_Buff_Debuff_Background()
	if (hidebuffbackground == 0) then
		Perl_Target_BuffFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
		Perl_Target_DebuffFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }});
		Perl_Target_BuffFrame:SetBackdropColor(0, 0, 0, 1);
		Perl_Target_BuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Target_DebuffFrame:SetBackdropColor(0, 0, 0, 1);
		Perl_Target_DebuffFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	else
		Perl_Target_BuffFrame:SetBackdrop(nil);
		Perl_Target_DebuffFrame:SetBackdrop(nil);
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Target_Frame_Style()
	Perl_Target_Main_Style();
	Perl_Target_Text_Positions();
end

function Perl_Target_Main_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Target_Main_Style);
	else
		Perl_Target_GuildFrame:ClearAllPoints();
		Perl_Target_GuildFrame:SetPoint("TOPLEFT", "Perl_Target_ClassNameFrame", "TOPRIGHT", -2, 0);

		if (framestyle == 1) then
			Perl_Target_HealthBar:SetWidth(200);
			Perl_Target_HealthBarFadeBar:SetWidth(200);
			Perl_Target_HealthBarBG:SetWidth(200);
			Perl_Target_ManaBar:SetWidth(200);
			Perl_Target_ManaBarFadeBar:SetWidth(200);
			Perl_Target_ManaBarBG:SetWidth(200);
			Perl_Target_HealthBar:SetPoint("TOP", "Perl_Target_StatsFrame", "TOP", 0, -10);
			Perl_Target_ManaBar:SetPoint("TOP", "Perl_Target_HealthBar", "BOTTOM", 0, -2);

			if (showrareeliteframe == 1) then				-- wtf is going on here, why is this working?!?
				Perl_Target_GuildFrame:SetWidth(125);
			else
				Perl_Target_GuildFrame:SetWidth(128);
			end
			Perl_Target_ClassNameFrame:SetWidth(95);
			Perl_Target_LevelFrame:SetWidth(46);
			Perl_Target_Frame:SetWidth(177);
			Perl_Target_Name:SetWidth(177);
			Perl_Target_NameFrame:SetWidth(177);
			Perl_Target_RareEliteFrame:SetWidth(46);
			Perl_Target_StatsFrame:SetWidth(221);

			Perl_Target_NameFrame_CPMeter:SetWidth(170);
		elseif (framestyle == 2) then
			Perl_Target_HealthBar:SetWidth(150);
			Perl_Target_HealthBarFadeBar:SetWidth(150);
			Perl_Target_HealthBarBG:SetWidth(150);
			Perl_Target_ManaBar:SetWidth(150);
			Perl_Target_ManaBarFadeBar:SetWidth(150);
			Perl_Target_ManaBarBG:SetWidth(150);
			Perl_Target_HealthBar:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "TOPLEFT", 10, -10);
			Perl_Target_ManaBar:SetPoint("TOP", "Perl_Target_HealthBar", "BOTTOM", 0, -2);

			if (compactmode == 0) then
				if (showrareeliteframe == 1) then			-- wtf is going on here, why is this working?!?
					Perl_Target_GuildFrame:SetWidth(159);
				else
					Perl_Target_GuildFrame:SetWidth(162);
				end
				Perl_Target_ClassNameFrame:SetWidth(95);
				Perl_Target_LevelFrame:SetWidth(46);
				Perl_Target_Frame:SetWidth(211);
				Perl_Target_Name:SetWidth(211);
				Perl_Target_NameFrame:SetWidth(211);
				Perl_Target_RareEliteFrame:SetWidth(46);
				Perl_Target_StatsFrame:SetWidth(255);

				Perl_Target_NameFrame_CPMeter:SetWidth(189);
			else
				if (shortbars == 0) then
					if (compactpercent == 0) then
						if (showrareeliteframe == 1) then
							Perl_Target_GuildFrame:SetWidth(74);
						else
							Perl_Target_GuildFrame:SetWidth(77);
						end
						
						Perl_Target_ClassNameFrame:SetWidth(95);
						Perl_Target_LevelFrame:SetWidth(46);
						Perl_Target_Frame:SetWidth(126);
						Perl_Target_Name:SetWidth(126);
						Perl_Target_NameFrame:SetWidth(126);
						Perl_Target_RareEliteFrame:SetWidth(46);
						Perl_Target_StatsFrame:SetWidth(170);

						Perl_Target_NameFrame_CPMeter:SetWidth(119);
					else
						if (showrareeliteframe == 1) then
							Perl_Target_GuildFrame:SetWidth(109);
						else
							Perl_Target_GuildFrame:SetWidth(112);
						end
						Perl_Target_ClassNameFrame:SetWidth(95);
						Perl_Target_LevelFrame:SetWidth(46);
						Perl_Target_Frame:SetWidth(161);
						Perl_Target_Name:SetWidth(161);
						Perl_Target_NameFrame:SetWidth(161);
						Perl_Target_RareEliteFrame:SetWidth(46);
						Perl_Target_StatsFrame:SetWidth(205);

						Perl_Target_NameFrame_CPMeter:SetWidth(154);
					end
				else
					Perl_Target_HealthBar:SetWidth(115);
					Perl_Target_HealthBarFadeBar:SetWidth(115);
					Perl_Target_HealthBarBG:SetWidth(115);
					Perl_Target_ManaBar:SetWidth(115);
					Perl_Target_ManaBarFadeBar:SetWidth(115);
					Perl_Target_ManaBarBG:SetWidth(115);

					if (compactpercent == 0) then
						if (showrareeliteframe == 1) then
							Perl_Target_GuildFrame:SetWidth(43);
						else
							Perl_Target_GuildFrame:SetWidth(46);
						end
						Perl_Target_ClassNameFrame:SetWidth(91);
						Perl_Target_LevelFrame:SetWidth(46);
						Perl_Target_Frame:SetWidth(91);
						Perl_Target_Name:SetWidth(91);
						Perl_Target_NameFrame:SetWidth(91);
						Perl_Target_RareEliteFrame:SetWidth(46);
						Perl_Target_StatsFrame:SetWidth(135);

						Perl_Target_NameFrame_CPMeter:SetWidth(84);

						if (showguildname == 1 and showrareeliteframe == 1) then
							Perl_Target_GuildFrame:ClearAllPoints();
							Perl_Target_GuildFrame:SetPoint("BOTTOMLEFT", "Perl_Target_ClassNameFrame", "TOPLEFT", 0, -2);
							Perl_Target_GuildFrame:SetWidth(135);
						end
					else
						if (showrareeliteframe == 1) then
							Perl_Target_GuildFrame:SetWidth(74);
						else
							Perl_Target_GuildFrame:SetWidth(77);
						end
						Perl_Target_ClassNameFrame:SetWidth(95);
						Perl_Target_LevelFrame:SetWidth(46);
						Perl_Target_Frame:SetWidth(126);
						Perl_Target_Name:SetWidth(126);
						Perl_Target_NameFrame:SetWidth(126);
						Perl_Target_RareEliteFrame:SetWidth(46);
						Perl_Target_StatsFrame:SetWidth(170);

						Perl_Target_NameFrame_CPMeter:SetWidth(119);
					end
				end
			end
		end

		Perl_Target_ClassNameFrame_CastClickOverlay:SetWidth(Perl_Target_ClassNameFrame:GetWidth());
		Perl_Target_GuildFrame_CastClickOverlay:SetWidth(Perl_Target_GuildFrame:GetWidth());
		Perl_Target_NameFrame_CastClickOverlay:SetWidth(Perl_Target_NameFrame:GetWidth());
		Perl_Target_StatsFrame_CastClickOverlay:SetWidth(Perl_Target_StatsFrame:GetWidth());

		if (showcp == 1) then				-- Are we showing the combo point frame?
			Perl_Target_CPFrame:Show();
		else
			Perl_Target_CPFrame:Hide();
		end

		if (showportrait == 1) then
			Perl_Target_HitIndicator:SetPoint("CENTER", Perl_Target_PortraitFrame, "CENTER", 0, 0);			-- Position the Combat Text correctly on the portrait
			Perl_Target_CPFrame:SetPoint("TOPLEFT", Perl_Target_PortraitFrame, "TOPRIGHT", -2, -34);		-- Reposition the combo point frame
			Perl_Target_PortraitFrame:Show();									-- Show the main portrait frame

			if (threedportrait == 0) then
				Perl_Target_PortraitFrame_TargetModel:Hide();							-- Hide the 3d graphic
				Perl_Target_Portrait:Show();									-- Show the 2d graphic
			end
		else
			if (showcp == 1) then
				Perl_Target_HitIndicator:SetPoint("CENTER", Perl_Target_PortraitFrame, "CENTER", 25, 0);	-- Position the Combat Text to the right of the combo point frame
			else
				Perl_Target_HitIndicator:SetPoint("CENTER", Perl_Target_PortraitFrame, "CENTER", 0, 0);		-- Position the Combat Text correctly on the portrait
			end
			Perl_Target_CPFrame:SetPoint("TOPLEFT", Perl_Target_StatsFrame, "TOPRIGHT", -2, 0);			-- Reposition the combo point frame
			Perl_Target_PortraitFrame:Hide();									-- Hide the frame and 2d/3d portion
		end

		if (showrareeliteframe == 1 or displaynumbericthreat == 1) then		-- Are we showing the Rare/Elite frame?
			Perl_Target_RareEliteFrame:Show();
		else
			Perl_Target_RareEliteFrame:Hide();
		end

		if (showclassframe == 1) then
			Perl_Target_ClassNameFrame:Show();
			Perl_Target_GuildFrame:Hide();	-- Hide is normally Show here, but we are changing what this frame does later to guild names
		else
			Perl_Target_ClassNameFrame:Hide();
			Perl_Target_GuildFrame:Hide();
		end

		if (showclassicon == 0) then			-- Are we showing the class icon?
			Perl_Target_ClassTexture:Hide();
		end

		if (portraitcombattext == 1) then		-- Are we showing combat text?
			Perl_Target_PortraitTextFrame:Show();
		else
			Perl_Target_PortraitTextFrame:Hide();
		end

		if (showguildname == 1) then
			if (showrareeliteframe == 1) then
				if (not (framestyle == 2 and compactmode == 1 and shortbars == 1 and compactpercent == 0)) then
					Perl_Target_GuildFrame:SetWidth(Perl_Target_GuildFrame:GetWidth() - 41);
					Perl_Target_GuildFrame_CastClickOverlay:SetWidth(Perl_Target_GuildFrame:GetWidth());
				end
			end
			Perl_Target_GuildFrame:Show();
		else
			Perl_Target_GuildFrame:Hide();
		end

		if (eliteraregraphic == 1) then
			Perl_Target_EliteRareGraphicFrame:ClearAllPoints();
			if (showportrait == 1) then
				Perl_Target_EliteRareGraphicFrame:SetPoint("TOPLEFT", "Perl_Target_PortraitFrame", "TOPRIGHT", -210, 25);
			else
				Perl_Target_EliteRareGraphicFrame:SetPoint("TOPLEFT", "Perl_Target_LevelFrame", "TOPRIGHT", -210, 25);
			end
			Perl_Target_EliteRareGraphicFrame:Show();
		else
			Perl_Target_EliteRareGraphicFrame:Hide();
		end

		Perl_Target_NameBarText:SetHeight(Perl_Target_Name:GetHeight() - 10);
		Perl_Target_NameBarText:SetNonSpaceWrap(false);
		Perl_Target_NameBarText:SetJustifyH("LEFT");

		Perl_Target_GuildBarText:SetWidth(Perl_Target_GuildFrame:GetWidth() - 13);
		Perl_Target_GuildBarText:SetHeight(Perl_Target_GuildFrame:GetHeight() - 10);
		Perl_Target_GuildBarText:SetNonSpaceWrap(false);

		Perl_Target_ClassNameBarText:SetWidth(Perl_Target_ClassNameFrame:GetWidth() - 10);
		Perl_Target_ClassNameBarText:SetHeight(Perl_Target_ClassNameFrame:GetHeight() - 10);
		Perl_Target_ClassNameBarText:SetNonSpaceWrap(false);

		if (Initialized) then
			Perl_Target_ArcaneBar_Support();
		end
	end
end

function Perl_Target_ArcaneBar_Support()
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		Perl_ArcaneBar_target:SetPoint("TOPLEFT", "Perl_Target_NameFrame", "TOPLEFT", 5, -5);
		Perl_ArcaneBar_target_CastTime:ClearAllPoints();
		if (Perl_ArcaneBar_Config[UnitName("player")]["TargetLeftTimer"] == 0) then
			if (showportrait == 1) then
				Perl_ArcaneBar_target_CastTime:SetPoint("LEFT", "Perl_Target_PortraitFrame", "RIGHT", 0, 0);
			else
				Perl_ArcaneBar_target_CastTime:SetPoint("LEFT", "Perl_Target_LevelFrame", "RIGHT", 0, 0);
			end
		else
			Perl_ArcaneBar_target_CastTime:SetPoint("RIGHT", "Perl_Target_NameFrame", "LEFT", 0, 0);
		end

		Perl_ArcaneBar_target:SetWidth(Perl_Target_NameFrame:GetWidth() - 10);
		Perl_ArcaneBar_target_Flash:SetWidth(Perl_Target_NameFrame:GetWidth() + 5);
		Perl_ArcaneBar_Set_Spark_Width(nil, Perl_Target_NameFrame:GetWidth(), nil, nil);
	end
end

function Perl_Target_Text_Positions()
	-- Begin: Set the text positions
	Perl_Target_HealthBarText:ClearAllPoints();
	Perl_Target_ManaBarText:ClearAllPoints();
	if (framestyle == 1) then
		Perl_Target_HealthBarText:SetPoint("TOP", 0, 1);
		Perl_Target_ManaBarText:SetPoint("TOP", 0, 1);
	elseif (framestyle == 2) then
		if (compactmode == 0) then
			Perl_Target_HealthBarText:SetPoint("TOP", 0, 1);
			Perl_Target_ManaBarText:SetPoint("TOP", 0, 1);
			Perl_Target_HealthBarTextRight:SetPoint("RIGHT", 85, 0);
			Perl_Target_ManaBarTextRight:SetPoint("RIGHT", 85, 0);
		else
			if (healermode == 0) then
				Perl_Target_HealthBarText:SetPoint("TOP", 0, 1);
				Perl_Target_ManaBarText:SetPoint("TOP", 0, 1);
			else
				Perl_Target_HealthBarText:SetPoint("TOPLEFT", 5, 1);
				Perl_Target_ManaBarText:SetPoint("TOPLEFT", 5, 1);
				Perl_Target_HealthBarTextRight:SetPoint("RIGHT", -5, 0);
				Perl_Target_ManaBarTextRight:SetPoint("RIGHT", -5, 0);
			end
		end
	end
	-- End: Set the text positions
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Target_HealthBar_Fade(arg1)
	Perl_Target_HealthBar_Fade_Color = Perl_Target_HealthBar_Fade_Color - arg1;
	Perl_Target_HealthBar_Fade_Time_Elapsed = Perl_Target_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Target_HealthBar_Fade_Color, 0, Perl_Target_HealthBar_Fade_Color);

	if (Perl_Target_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Target_HealthBar_Fade_Color = 1;
		Perl_Target_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Target_HealthBarFadeBar:Hide();
		Perl_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Target_ManaBar_Fade(arg1)
	Perl_Target_ManaBar_Fade_Color = Perl_Target_ManaBar_Fade_Color - arg1;
	Perl_Target_ManaBar_Fade_Time_Elapsed = Perl_Target_ManaBar_Fade_Time_Elapsed + arg1;

	if (targetpower == 0) then
		Perl_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Target_ManaBar_Fade_Color, Perl_Target_ManaBar_Fade_Color);
	elseif (targetpower == 1) then
		Perl_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_ManaBar_Fade_Color, 0, 0, Perl_Target_ManaBar_Fade_Color);
	elseif (targetpower == 2) then
		Perl_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_ManaBar_Fade_Color, (Perl_Target_ManaBar_Fade_Color-0.5), 0, Perl_Target_ManaBar_Fade_Color);
	elseif (targetpower == 3) then
		Perl_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_ManaBar_Fade_Color, Perl_Target_ManaBar_Fade_Color, 0, Perl_Target_ManaBar_Fade_Color);
	elseif (targetpower == 6) then
		Perl_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Target_ManaBar_Fade_Color, Perl_Target_ManaBar_Fade_Color, Perl_Target_ManaBar_Fade_Color);
	end

	if (Perl_Target_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Target_ManaBar_Fade_Color = 1;
		Perl_Target_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Target_ManaBarFadeBar:Hide();
		Perl_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Target_Set_Buffs(newbuffnumber)
	if (newbuffnumber == nil) then
		newbuffnumber = 20;
	end
	numbuffsshown = newbuffnumber;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Debuffs(newdebuffnumber)
	if (newdebuffnumber == nil) then
		newdebuffnumber = 20;
	end
	numdebuffsshown = newdebuffnumber;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Class_Buffs(newvalue)
	if (newvalue ~= nil) then
		displaycastablebuffs = newvalue;
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Buff_Timers(newvalue)
	if (newvalue ~= nil) then
		displaybufftimers = newvalue;
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Curable_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displaycurabledebuff = newvalue;
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Only_Self_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displayonlymydebuffs = newvalue;
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Invert_Buffs(newvalue)
	if (newvalue ~= nil) then
		invertbuffs = newvalue;
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Reset_Buffs();		-- Reset the buff icons
	Perl_Target_Buff_UpdateAll();		-- Repopulate the buff icons
end

function Perl_Target_Set_Class_Icon(newvalue)
	showclassicon = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_PvP_Status_Icon(newvalue)
	showpvpicon = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Class_Frame(newvalue)
	showclassframe = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Combo_Points(newvalue)
	showcp = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
end

function Perl_Target_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Rare_Elite(newvalue)
	showrareeliteframe = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Portrait_Combat_Text(newvalue)
	portraitcombattext = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Combo_Name_Frame(newvalue)
	nameframecombopoints = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Combo_Frame_Debuffs(newvalue)
	comboframedebuffs = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Frame_Style(newvalue)
	framestyle = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Compact_Mode(newvalue)
	compactmode = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Compact_Percents(newvalue)
	compactpercent = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Short_Bars(newvalue)
	shortbars = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Healer(newvalue)
	healermode = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Buff_Debuff_Background(newvalue)
	hidebuffbackground = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Buff_Debuff_Background();
end

function Perl_Target_Set_Sound_Target_Change(newvalue)
	soundtargetchange = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
end

function Perl_Target_Set_Mana_Deficit(newvalue)
	showmanadeficit = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Show_Guild_Name(newvalue)
	showguildname = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Elite_Rare_Graphic(newvalue)
	eliteraregraphic = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Display_Numeric_Threat(newvalue)
	displaynumbericthreat = newvalue;
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Frame_Style();		-- Apply any showing/hiding of frames and enabling/disabling of events
	if (UnitExists("target")) then
		Perl_Target_Update_Once();	-- Update the target frame information if appropriate
	end
end

function Perl_Target_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);		-- convert the user input to a wow acceptable value
	end
	Perl_Target_UpdateVars();		-- Save the new setting
	Perl_Target_Set_Scale_Actual();
end

function Perl_Target_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Target_Set_Scale_Actual);
	else
		Perl_Target_Frame:SetScale(1 - UIParent:GetEffectiveScale() + scale);	-- run it through the scaling formula introduced in 1.9
		Perl_Target_Set_BuffDebuff_Scale(buffdebuffscale*100);		-- maintain the buff/debuff scale
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			Perl_ArcaneBar_Set_Scale_Actual(nil, scale, nil, nil);
		end
	end
end

function Perl_Target_Set_BuffDebuff_Scale(number)
	local unsavedscale;
	if (number ~= nil) then
		buffdebuffscale = (number / 100);				-- convert the user input to a wow acceptable value
	end
	unsavedscale = 1 - UIParent:GetEffectiveScale() + buffdebuffscale;	-- run it through the scaling formula introduced in 1.9
	Perl_Target_BuffFrame:SetScale(buffdebuffscale);
	Perl_Target_DebuffFrame:SetScale(buffdebuffscale);
	Perl_Target_UpdateVars();		-- Save the new setting
end

function Perl_Target_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);					-- convert the user input to a wow acceptable value
	end
	Perl_Target_Frame:SetAlpha(transparency);
	Perl_Target_UpdateVars();		-- Save the new setting
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Target_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Target_Config[name]["Locked"];
	showcp = Perl_Target_Config[name]["ComboPoints"];
	showclassicon = Perl_Target_Config[name]["ClassIcon"];
	showclassframe = Perl_Target_Config[name]["ClassFrame"];
	showpvpicon = Perl_Target_Config[name]["PvPIcon"]; 
	numbuffsshown = Perl_Target_Config[name]["Buffs"];
	numdebuffsshown = Perl_Target_Config[name]["Debuffs"];
	scale = Perl_Target_Config[name]["Scale"];
	transparency = Perl_Target_Config[name]["Transparency"];
	buffdebuffscale = Perl_Target_Config[name]["BuffDebuffScale"];
	showportrait = Perl_Target_Config[name]["ShowPortrait"];
	threedportrait = Perl_Target_Config[name]["ThreeDPortrait"];
	portraitcombattext = Perl_Target_Config[name]["PortraitCombatText"];
	showrareeliteframe = Perl_Target_Config[name]["ShowRareEliteFrame"];
	nameframecombopoints = Perl_Target_Config[name]["NameFrameComboPoints"];
	comboframedebuffs = Perl_Target_Config[name]["ComboFrameDebuffs"];
	framestyle = Perl_Target_Config[name]["FrameStyle"];
	compactmode = Perl_Target_Config[name]["CompactMode"];
	compactpercent = Perl_Target_Config[name]["CompactPercent"];
	hidebuffbackground = Perl_Target_Config[name]["HideBuffBackground"];
	shortbars = Perl_Target_Config[name]["ShortBars"];
	healermode = Perl_Target_Config[name]["HealerMode"];
	soundtargetchange = Perl_Target_Config[name]["SoundTargetChange"];
	displaycastablebuffs = Perl_Target_Config[name]["DisplayCastableBuffs"];
	classcolorednames = Perl_Target_Config[name]["ClassColoredNames"];
	showmanadeficit = Perl_Target_Config[name]["ShowManaDeficit"];
	invertbuffs = Perl_Target_Config[name]["InvertBuffs"];
	showguildname = Perl_Target_Config[name]["ShowGuildName"];
	eliteraregraphic = Perl_Target_Config[name]["EliteRareGraphic"];
	displaycurabledebuff = Perl_Target_Config[name]["DisplayCurableDebuff"];
	displaybufftimers = Perl_Target_Config[name]["DisplayBuffTimers"];
	displaynumbericthreat = Perl_Target_Config[name]["DisplayNumbericThreat"];
	displayonlymydebuffs = Perl_Target_Config[name]["DisplayOnlyMyDebuffs"];

	if (locked == nil) then
		locked = 0;
	end
	if (showcp == nil) then
		showcp = 1;
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
		numbuffsshown = 20;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 20;
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
	if (soundtargetchange == nil) then
		soundtargetchange = 0;
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
	if (showguildname == nil) then
		showguildname = 0;
	end
	if (eliteraregraphic == nil) then
		eliteraregraphic = 0;
	end
	if (displaycurabledebuff == nil) then
		displaycurabledebuff = 0;
	end
	if (displaybufftimers == nil) then
		displaybufftimers = 1;
	end
	if (displaynumbericthreat == nil) then
		displaynumbericthreat = 1;
	end
	if (displayonlymydebuffs == nil) then
		displayonlymydebuffs = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Target_UpdateVars();

		-- Call any code we need to activate them
		Perl_Target_Reset_Buffs();		-- Reset the buff icons
		Perl_Target_Frame_Style();		-- Reposition the frames
		Perl_Target_Buff_Debuff_Background();	-- Hide/Show the background frame
		Perl_Target_Set_Scale_Actual();		-- Set the scale
		Perl_Target_Set_Transparency();		-- Set the transparency
		if (UnitExists("target")) then
			Perl_Target_Update_Once();
		end
		return;
	end

	local vars = {
		["locked"] = locked,
		["showcp"] = showcp,
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
		["soundtargetchange"] = soundtargetchange,
		["displaycastablebuffs"] = displaycastablebuffs,
		["classcolorednames"] = classcolorednames,
		["showmanadeficit"] = showmanadeficit,
		["invertbuffs"] = invertbuffs,
		["showguildname"] = showguildname,
		["eliteraregraphic"] = eliteraregraphic,
		["displaycurabledebuff"] = displaycurabledebuff,
		["displaybufftimers"] = displaybufftimers,
		["displaynumbericthreat"] = displaynumbericthreat,
		["displayonlymydebuffs"] = displayonlymydebuffs,
	}
	return vars;
end

function Perl_Target_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["ComboPoints"] ~= nil) then
				showcp = vartable["Global Settings"]["ComboPoints"];
			else
				showcp = nil;
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
			if (vartable["Global Settings"]["SoundTargetChange"] ~= nil) then
				soundtargetchange = vartable["Global Settings"]["SoundTargetChange"];
			else
				soundtargetchange = nil;
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
			if (vartable["Global Settings"]["ShowGuildName"] ~= nil) then
				showguildname = vartable["Global Settings"]["ShowGuildName"];
			else
				showguildname = nil;
			end
			if (vartable["Global Settings"]["EliteRareGraphic"] ~= nil) then
				eliteraregraphic = vartable["Global Settings"]["EliteRareGraphic"];
			else
				eliteraregraphic = nil;
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
			if (vartable["Global Settings"]["DisplayNumbericThreat"] ~= nil) then
				displaynumbericthreat = vartable["Global Settings"]["DisplayNumbericThreat"];
			else
				displaynumbericthreat = nil;
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
		if (showcp == nil) then
			showcp = 1;
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
			numbuffsshown = 20;
		end
		if (numdebuffsshown == nil) then
			numdebuffsshown = 20;
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
		if (soundtargetchange == nil) then
			soundtargetchange = 0;
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
		if (showguildname == nil) then
			showguildname = 0;
		end
		if (eliteraregraphic == nil) then
			eliteraregraphic = 0;
		end
		if (displaycurabledebuff == nil) then
			displaycurabledebuff = 0;
		end
		if (displaybufftimers == nil) then
			displaybufftimers = 1;
		end
		if (displaynumbericthreat == nil) then
			displaynumbericthreat = 1;
		end
		if (displayonlymydebuffs == nil) then
			displayonlymydebuffs = 0;
		end

		-- Call any code we need to activate them
		Perl_Target_Reset_Buffs();		-- Reset the buff icons
		Perl_Target_Frame_Style();		-- Reposition the frames
		Perl_Target_Buff_Debuff_Background();	-- Hide/Show the background frame
		Perl_Target_Set_Scale_Actual();		-- Set the scale
		Perl_Target_Set_Transparency();		-- Set the transparency
		if (UnitExists("target")) then
			Perl_Target_Update_Once();
		end
	end

	Perl_Target_Config[UnitName("player")] = {
		["Locked"] = locked,
		["ComboPoints"] = showcp,
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
		["SoundTargetChange"] = soundtargetchange,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["ClassColoredNames"] = classcolorednames,
		["ShowManaDeficit"] = showmanadeficit,
		["InvertBuffs"] = invertbuffs,
		["ShowGuildName"] = showguildname,
		["EliteRareGraphic"] = eliteraregraphic,
		["DisplayCurableDebuff"] = displaycurabledebuff,
		["DisplayBuffTimers"] = displaybufftimers,
		["DisplayNumbericThreat"] = displaynumbericthreat,
		["DisplayOnlyMyDebuffs"] = displayonlymydebuffs,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Target_Buff_UpdateAll()
	if (UnitName("target")) then

		if (nameframecombopoints == 1 or comboframedebuffs == 1) then
			Perl_Target_Buff_UpdateCPMeter();
		end

		local button, buffCount, buffTexture, buffApplications, color, debuffType, duration, timeLeft, cooldown;	-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
		local curableDebuffFound = 0;

		local numBuffs = 0;											-- Buff counter for correct layout
		for buffnum=1,numbuffsshown do										-- Start main buff loop
			if (displaycastablebuffs == 0) then								-- Which buff filter mode are we in?
				bufffilter = "HELPFUL";
			else
				bufffilter = "HELPFUL RAID";
			end
			_, _, buffTexture, buffApplications, _, duration, timeLeft, _, _ = UnitAura("target", buffnum, bufffilter);	-- Get the texture and buff stacking information if any
			button = getglobal("Perl_Target_Buff"..buffnum);						-- Create the main icon for the buff
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
			Perl_Target_Debuff_Set_Filter();								-- Are we targeting a friend or enemy and which filter do we need to apply?
			_, _, buffTexture, buffApplications, debuffType, duration, timeLeft, _, _ = UnitAura("target", debuffnum, debufffilter);	-- Get the texture and debuff stacking information if any
			button = getglobal("Perl_Target_Debuff"..debuffnum);						-- Create the main icon for the debuff
			if (buffTexture) then										-- If there is a valid texture, proceed with debuff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);				-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (UnitIsFriend("player", "target")) then
								if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
									Perl_Target_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_LevelFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_PortraitFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_ClassNameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_GuildFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_RareEliteFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_CPFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
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
					cooldown = getglobal(button:GetName().."Cooldown");					-- Handle cooldowns
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
			Perl_Target_BuffFrame:Hide();
		else
			Perl_Target_BuffFrame:ClearAllPoints();
			if (invertbuffs == 0) then
				if (UnitIsFriend("player", "target")) then
					Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 2);
				else
					if (numDebuffs > 30) then
						Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -110);
					elseif (numDebuffs > 20) then
						Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -83);
					elseif (numDebuffs > 10) then
						Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -56);
					else
						Perl_Target_BuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -29);
					end
				end
			else
				if (UnitIsFriend("player", "target")) then
					if (showclassframe == 1 or showrareeliteframe == 1) then
						Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 20);
					else
						Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, -2);
					end
				else
					if (showclassframe == 1 or showrareeliteframe == 1) then
						if (numDebuffs > 30) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 132);
						elseif (numDebuffs > 20) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 105);
						elseif (numDebuffs > 10) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 78);
						else
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 51);
						end
					else
						if (numDebuffs > 30) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 110);
						elseif (numDebuffs > 20) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 83);
						elseif (numDebuffs > 10) then
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 56);
						else
							Perl_Target_BuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 29);
						end
					end
				end
			end

			Perl_Target_BuffFrame:Show();
			if (numBuffs > 10) then
				Perl_Target_BuffFrame:SetWidth(275);			-- 5 + 10 * (24 + 3)	5 = border gap, 10 buffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Target_BuffFrame:SetHeight(61);			-- 2 rows tall
			else
				Perl_Target_BuffFrame:SetWidth(5 + numBuffs * 27);	-- Dynamically extend the background frame
				Perl_Target_BuffFrame:SetHeight(34);			-- 1 row tall
			end
		end

		if (numDebuffs == 0) then
			Perl_Target_DebuffFrame:Hide();
		else
			Perl_Target_DebuffFrame:ClearAllPoints();
			if (invertbuffs == 0) then
				if (UnitIsFriend("player", "target")) then
					if (numBuffs > 10) then
						Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -56);
					else
						Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, -29);
					end
				else
					Perl_Target_DebuffFrame:SetPoint("TOPLEFT", "Perl_Target_StatsFrame", "BOTTOMLEFT", 0, 2);
				end
			else
				if (UnitIsFriend("player", "target")) then
					if (showclassframe == 1 or showrareeliteframe == 1) then
						if (numBuffs > 10) then
							Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 78);
						else
							Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 51);
						end
					else
						if (numBuffs > 10) then
							Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 56);
						else
							Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 29);
						end
					end
				else
					if (showclassframe == 1 or showrareeliteframe == 1) then
						Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, 20);
					else
						Perl_Target_DebuffFrame:SetPoint("BOTTOMLEFT", "Perl_Target_NameFrame", "TOPLEFT", 0, -2);
					end
				end
			end

			Perl_Target_DebuffFrame:Show();
			if (numDebuffs > 30) then
				Perl_Target_DebuffFrame:SetWidth(275);			-- 5 + 10 * (24 + 3)	5 = border gap, 10 debuffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Target_DebuffFrame:SetHeight(115);			-- 4 rows tall
			elseif (numDebuffs > 20) then
				Perl_Target_DebuffFrame:SetWidth(275);			-- 5 + 10 * (24 + 3)	5 = border gap, 10 debuffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Target_DebuffFrame:SetHeight(88);			-- 3 rows tall
			elseif (numDebuffs > 10) then
				Perl_Target_DebuffFrame:SetWidth(275);			-- 5 + 10 * (24 + 3)	5 = border gap, 10 debuffs across, 24 = icon size + 3 for pixel alignment, only holds true for default size
				Perl_Target_DebuffFrame:SetHeight(61);			-- 2 rows tall
			else
				Perl_Target_DebuffFrame:SetWidth(5 + numDebuffs * 27);	-- Dynamically extend the background frame
				Perl_Target_DebuffFrame:SetHeight(34);			-- 1 row tall
			end
		end

		if (curableDebuffFound == 0) then
			Perl_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_ClassNameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_GuildFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_RareEliteFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_CPFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			Perl_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end
	end
end

function Perl_Target_Debuff_Set_Filter()
	if (UnitIsFriend("player", "target")) then
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

function Perl_Target_Buff_UpdateCPMeter()
	local debuffapplications;
	local _, playerclass = UnitClass("player");

	if (playerclass == "MAGE") then
		debuffapplications = Perl_Target_Buff_GetApplications(PERL_LOCALIZED_TARGET_FIRE_VULNERABILITY);
	elseif (playerclass == "PRIEST") then
		debuffapplications = Perl_Target_Buff_GetApplications(PERL_LOCALIZED_TARGET_SHADOW_VULNERABILITY);
	elseif (playerclass == "WARRIOR") then
		debuffapplications = Perl_Target_Buff_GetApplications(PERL_LOCALIZED_TARGET_SUNDER_ARMOR);
	elseif (playerclass == "PALADIN") then
		debuffapplications = Perl_Target_Buff_GetApplications(PERL_LOCALIZED_TARGET_HOLY_VENGEANCE);
	elseif ((playerclass == "ROGUE") or (playerclass == "DRUID")) then
		return;
	else
		Perl_Target_NameFrame_CPMeter:Hide();
		return;
	end

	if (debuffapplications == 0) then
		Perl_Target_CPText:SetText(0);
		Perl_Target_NameFrame_CPMeter:Hide();
	else
		if (comboframedebuffs == 1) then
			Perl_Target_CPText:SetText(debuffapplications);
			if (debuffapplications == 5) then
				Perl_Target_CPText:SetTextColor(1, 0, 0);	-- red text
			elseif (debuffapplications == 4) then
				Perl_Target_CPText:SetTextColor(1, 0.5, 0);	-- orange text
			elseif (debuffapplications == 3) then
				Perl_Target_CPText:SetTextColor(1, 1, 0);	-- yellow text
			elseif (debuffapplications == 2) then
				Perl_Target_CPText:SetTextColor(0.5, 1, 0);	-- yellow-green text
			elseif (debuffapplications == 1) then
				Perl_Target_CPText:SetTextColor(0, 1, 0);	-- green text
			else
				Perl_Target_CPText:SetTextColor(0, 0.5, 0);	-- dark green text
			end
		end

		if (nameframecombopoints == 1) then				-- this isn't nested since you can have both combo point styles on at the same time
			Perl_Target_NameFrame_CPMeter:SetMinMaxValues(0, 5);
			Perl_Target_NameFrame_CPMeter:SetValue(debuffapplications);
			if (debuffapplications == 5) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 4) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 3) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 2) then
				Perl_Target_NameFrame_CPMeter:Show();
			elseif (debuffapplications == 1) then
				Perl_Target_NameFrame_CPMeter:Show();
			else
				Perl_Target_NameFrame_CPMeter:Hide();
			end
		else
			Perl_Target_NameFrame_CPMeter:Hide();
		end
	end
end

function Perl_Target_Buff_GetApplications(debuffname)
	local debuffApplications, name;
	local i = 1;

	while UnitDebuff("target", i) do
		name, _, _, debuffApplications, _, _, _ = UnitDebuff("target", i);
		if (name == debuffname) then
			return debuffApplications;
		end
		i = i + 1;
	end

	return 0;
end

function Perl_Target_Reset_Buffs()
	local button, cooldown;
	for buffnum=1,20 do
		button = getglobal("Perl_Target_Buff"..buffnum);
		--button:Hide();
		cooldown = getglobal(button:GetName().."Cooldown");
		CooldownFrame_SetTimer(cooldown, 0, 0, 0);
		cooldown:Hide();
		button:Hide();
	end
	for debuffnum=1,40 do
		button = getglobal("Perl_Target_Debuff"..debuffnum);
		--button:Hide();
		cooldown = getglobal(button:GetName().."Cooldown");
		CooldownFrame_SetTimer(cooldown, 0, 0, 0);
		cooldown:Hide();
		button:Hide();
	end
end

function Perl_Target_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 20) then
		GameTooltip:SetUnitDebuff("target", self:GetID()-20, displaycastablebuffs);
	else
		GameTooltip:SetUnitBuff("target", self:GetID(), displaycastablebuffs);
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Target_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_Target_DropDown, "Perl_Target_NameFrame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "target", showmenu);

	self:SetAttribute("unit", "target");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_TargetDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_TargetDropDown_Initialize, "MENU");
end

function Perl_TargetDropDown_Initialize()
	local menu, name;
	local id = nil;
	if (UnitIsUnit("target", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("target", "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit("target", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("target")) then
		id = UnitInRaid("target");
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty("target")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Target_DropDown, menu, "target", name, id);
	end
end

function Perl_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Frame:StartMoving();
	end
end

function Perl_Target_DragStop(button)
	Perl_Target_Frame:StopMovingOrSizing();
end

function Perl_Target_OnShow()
	if (soundtargetchange == 1) then
		if (UnitIsEnemy("target", "player")) then
			PlaySound("igCreatureAggroSelect");
		elseif (UnitIsFriend("player", "target")) then
			PlaySound("igCharacterNPCSelect");
		else
			PlaySound("igCreatureNeutralSelect");
		end
	end
end

function Perl_Target_OnHide()
	if (soundtargetchange == 1) then
		PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Target_myAddOns_Details = {
			name = "Perl_Target",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Target_myAddOns_Help = {};
		Perl_Target_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Target_myAddOns_Details, Perl_Target_myAddOns_Help);
	end
end
