---------------
-- Variables --
---------------
Perl_Player_Config = {};
local Perl_Player_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Player_GetVars)
local locked = 0;		-- unlocked by default
local xpbarstate = 1;		-- show default xp bar by default
local compactmode = 0;		-- compact mode is disabled by default
local showraidgroup = 1;	-- show the raid group number by default when in raids
local scale = 0.9;		-- default scale
local healermode = 0;		-- nurfed unit frame style
local transparency = 1;		-- transparency for frames
local showportrait = 0;		-- portrait is hidden by default
local compactpercent = 0;	-- percents are not shown in compact mode by default
local threedportrait = 0;	-- 3d portraits are off by default
local portraitcombattext = 0;	-- Combat text is disabled by default on the portrait frame
local showdruidbar = 0;		-- Druid Bar support is enabled by default
local shortbars = 0;		-- Health/Power/Experience bars are all normal length
local classcolorednames = 0;	-- names are colored based on pvp status by default
local hideclasslevelframe = 0;	-- Showing the class icon and level frame by default
local showmanadeficit = 0;	-- Mana deficit in healer mode is off by default
local hiddeninraid = 0;		-- player frame is shown in a raid by default
local showpvpicon = 1;		-- show the pvp icon
local showbarvalues = 0;	-- healer mode will have the bar values hidden by default
local showraidgroupinname = 0;	-- raid number is not shown in the name by default
local fivesecondrule = 0;	-- five second rule is off by default
local totemtimers = 1;		-- default for totem timers is on by default
local runeframe = 1;		-- default for rune frame is on by default
local pvptimer = 0;		-- pvp timer is hidden by default

-- Default Local Variables
local InCombat = 0;		-- used to track if the player is in combat and if the icon should be displayed
local Initialized = nil;	-- waiting to be initialized
local Perl_Player_ManaBar_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Player_ManaBar_Time_Update_Rate = 0.1;	-- the update interval
local Perl_Player_DruidBar_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Player_DruidBar_Time_Update_Rate = 0.2;	-- the update interval
local Perl_Player_PvP_Text_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Player_PvP_Text_Time_Update_Rate = 0.1;	-- the update interval
local mouseoverhealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovermanaflag = 0;	-- is the mouse over the mana bar for healer mode?

-- Fade Bar Variables
local Perl_Player_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Player_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Player_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Player_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
--local Perl_Player_DruidBar_Fade_Color = 1;		-- the color fading interval
--local Perl_Player_DruidBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0

-- Local variables to save memory
local playerhealth, playerhealthmax, playerhealthpercent, playermana, playermanamax, playermanapercent, playerdruidbarmana, playerdruidbarmanamax, playerdruidbarmanapercent, playerpower, englishclass, playeronupdatemana, pvptimeleft;
local fivesecondrulelastmana = 0;
local fivesecondruletime = nil;


----------------------
-- Loading Function --
----------------------
function Perl_Player_OnLoad(self)
	-- Combat Text
	CombatFeedback_Initialize(self, Perl_Player_HitIndicator, 30);

	-- Events
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_COMBAT");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_ENERGY");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_MANA");
	self:RegisterEvent("UNIT_MAXENERGY");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_MAXMANA");
	self:RegisterEvent("UNIT_MAXRAGE");
	self:RegisterEvent("UNIT_MAXRUNIC_POWER");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_PVP_UPDATE");
	self:RegisterEvent("UNIT_RAGE");
	self:RegisterEvent("UNIT_RUNIC_POWER");
	self:RegisterEvent("UNIT_SPELLMISS");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("VOICE_START");
	self:RegisterEvent("VOICE_STOP");

	-- Scripts
	self:SetScript("OnEvent", Perl_Player_OnEvent);
	self:SetScript("OnUpdate", CombatFeedback_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Player_Name_CastClickOverlay:SetFrameLevel(Perl_Player_Name:GetFrameLevel() + 2);
	Perl_Player_RaidGroupNumberFrame_CastClickOverlay:SetFrameLevel(Perl_Player_RaidGroupNumberFrame:GetFrameLevel() + 1);
	Perl_Player_LevelFrame_CastClickOverlay:SetFrameLevel(Perl_Player_LevelFrame:GetFrameLevel() + 1);
	Perl_Player_PortraitFrame_CastClickOverlay:SetFrameLevel(Perl_Player_PortraitFrame:GetFrameLevel() + 2);
	Perl_Player_PortraitTextFrame:SetFrameLevel(Perl_Player_PortraitFrame:GetFrameLevel() + 1);
	Perl_Player_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Player_StatsFrame:GetFrameLevel() + 1);
	Perl_Player_HealthBar_CastClickOverlay:SetFrameLevel(Perl_Player_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_ManaBar_CastClickOverlay:SetFrameLevel(Perl_Player_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_DruidBar_CastClickOverlay:SetFrameLevel(Perl_Player_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_XPBar_CastClickOverlay:SetFrameLevel(Perl_Player_StatsFrame:GetFrameLevel() + 2);
	Perl_Player_HealthBarFadeBar:SetFrameLevel(Perl_Player_HealthBar:GetFrameLevel() - 1);
	Perl_Player_ManaBarFadeBar:SetFrameLevel(Perl_Player_ManaBar:GetFrameLevel() - 1);
	--Perl_Player_DruidBarFadeBar:SetFrameLevel(Perl_Player_DruidBar:GetFrameLevel() - 1);

	TotemFrame:SetParent(Perl_Player_Frame);
	RuneFrame:SetParent(Perl_Player_Frame);
end


-------------------
-- Event Handler --
-------------------
function Perl_Player_OnEvent()
	local func = Perl_Player_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Player: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Player_Events:UNIT_HEALTH()
	if (arg1 == "player") then
		Perl_Player_Update_Health();		-- Update health values
	end
end
Perl_Player_Events.UNIT_MAXHEALTH = Perl_Player_Events.UNIT_HEALTH;

function Perl_Player_Events:UNIT_MANA()
	if (arg1 == "player") then
		Perl_Player_Update_Mana();		-- Update mana values
	end
end

function Perl_Player_Events:UNIT_MAXMANA()
	if (arg1 == "player") then
		Perl_Player_Update_Mana();		-- Update mana/rage values
	end
end
Perl_Player_Events.UNIT_RAGE = Perl_Player_Events.UNIT_MAXMANA;
Perl_Player_Events.UNIT_MAXRAGE = Perl_Player_Events.UNIT_MAXMANA;
Perl_Player_Events.UNIT_RUNIC_POWER = Perl_Player_Events.UNIT_MAXMANA;
Perl_Player_Events.UNIT_MAXRUNIC_POWER = Perl_Player_Events.UNIT_MAXMANA;

function Perl_Player_Events:UNIT_ENERGY()
	if (arg1 == "player") then
		Perl_Player_Update_Mana();		-- Update energy values
	end
end
Perl_Player_Events.UNIT_MAXENERGY = Perl_Player_Events.UNIT_ENERGY;

function Perl_Player_Events:UNIT_DISPLAYPOWER()
	if (arg1 == "player") then
		Perl_Player_Update_Mana_Bar();		-- What type of energy are we using now?
		Perl_Player_Update_Mana();		-- Update the energy info immediately
	end
end

function Perl_Player_Events:UNIT_AURA()
	if (arg1 == "player") then
		Perl_Player_BuffUpdateAll();
	end
end

function Perl_Player_Events:UNIT_COMBAT()
	if (arg1 == "player") then
		CombatFeedback_OnCombatEvent(Perl_Player_Frame, arg2, arg3, arg4, arg5);
	end
end

function Perl_Player_Events:UNIT_SPELLMISS()
	if (arg1 == "player") then
		CombatFeedback_OnSpellMissEvent(arg2);
	end
end

function Perl_Player_Events:PLAYER_UPDATE_RESTING()
	Perl_Player_Update_Combat_Status(event);	-- Are we fighting, resting, or none?
end
Perl_Player_Events.PLAYER_REGEN_DISABLED = Perl_Player_Events.PLAYER_UPDATE_RESTING;
Perl_Player_Events.PLAYER_REGEN_ENABLED = Perl_Player_Events.PLAYER_UPDATE_RESTING;

function Perl_Player_Events:PLAYER_XP_UPDATE()
	if (xpbarstate == 1) then
		Perl_Player_Update_Experience();	-- Set the experience bar info
	end
end

function Perl_Player_Events:UPDATE_FACTION()
	if (xpbarstate == 4) then
		Perl_Player_Update_Reputation();	-- Set faction info
	end
end

function Perl_Player_Events:UNIT_FACTION()
	Perl_Player_Update_PvP_Status();		-- Is the character PvP flagged?
end
Perl_Player_Events.UNIT_PVP_UPDATE = Perl_Player_Events.UNIT_FACTION;

function Perl_Player_Events:UNIT_LEVEL()
	if (arg1 == "player") then
		Perl_Player_LevelFrame_LevelBarText:SetText(UnitLevel("player"));	-- Set the player's level
	end
end

function Perl_Player_Events:RAID_ROSTER_UPDATE()
	Perl_Player_Update_Raid_Group_Number();		-- What raid group number are we in?
	Perl_Player_Check_Hidden();			-- Are suppossed to hide the frame?
end

function Perl_Player_Events:PARTY_LEADER_CHANGED()
	Perl_Player_Update_Leader();			-- Are we the party leader?
	Perl_Player_Update_Loot_Method();
	Perl_Player_Update_Role();
end
Perl_Player_Events.PARTY_MEMBERS_CHANGED = Perl_Player_Events.PARTY_LEADER_CHANGED;

function Perl_Player_Events:PARTY_LOOT_METHOD_CHANGED()
	Perl_Player_Update_Loot_Method();
end

function Perl_Player_Events:UNIT_PORTRAIT_UPDATE()
	if (arg1 == "player") then
		Perl_Player_Update_Portrait();
	end
end
Perl_Player_Events.UNIT_MODEL_CHANGED = Perl_Player_Events.UNIT_PORTRAIT_UPDATE;

function Perl_Player_Events:VOICE_START()
	if (arg1 == "player") then
		Perl_Player_VoiceChatIconFrame:Show();
	end
end

function Perl_Player_Events:VOICE_STOP()
	if (arg1 == "player") then
		Perl_Player_VoiceChatIconFrame:Hide();
	end
end

function Perl_Player_Events:UNIT_THREAT_SITUATION_UPDATE()
	if (arg1 == "player") then
		Perl_Player_Update_Threat();
	end
end

function Perl_Player_Events:PLAYER_FLAGS_CHANGED()
	Perl_Player_Update_PvP_Timer();
end

function Perl_Player_Events:PLAYER_LOGIN()
	Perl_Player_Initialize();
end
Perl_Player_Events.PLAYER_ENTERING_WORLD = Perl_Player_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Player_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		InCombat = 0;				-- You can't be fighting if you're zoning, and no event is sent, force it to no combat.
		Perl_Player_Set_Scale_Actual();		-- Set the scale
		Perl_Player_Set_Transparency();		-- Set the transparency
		Perl_Player_Update_Once();		-- Set all the correct information
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Player_Config[UnitName("player")]) == "table") then
		Perl_Player_GetVars();
	else
		Perl_Player_UpdateVars();
	end

	-- Major config options.
	Perl_Player_Initialize_Frame_Color();		-- Give the borders (and background if applicable) that "Perl" look

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(PlayerFrame);

	-- MyAddOns Support
	Perl_Player_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_Player_Frame:SetUserPlaced(1);

	Initialized = 1;
end

function Perl_Player_Initialize_Frame_Color()
	Perl_Player_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_LevelFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_RaidGroupNumberFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_RaidGroupNumberFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Player_PortraitFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Player_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	Perl_Player_HealthBarText:SetTextColor(1, 1, 1, 1);
	--Perl_Player_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_Player_RaidGroupNumberBarText:SetTextColor(1, 1, 1);
end


----------------------
-- Update Functions --
----------------------
function Perl_Player_Update_Once()
	_, englishclass = UnitClass("player");

	-- Anytime functions
	Perl_Player_NameBarText:SetText(UnitName("player"));			-- Set the player's name
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then				-- ArcaneBar Support
		Perl_ArcaneBar_player.unitname = Perl_Player_NameBarText:GetText();
	end
	Perl_Player_LevelFrame_LevelBarText:SetText(UnitLevel("player"));	-- Set the player's level
	Perl_Player_ClassTexture:SetTexCoord(PCUF_CLASSPOSRIGHT[englishclass], PCUF_CLASSPOSLEFT[englishclass], PCUF_CLASSPOSTOP[englishclass], PCUF_CLASSPOSBOTTOM[englishclass]);	-- Set the player's class icon
	Perl_Player_Update_Portrait();						-- Set the player's portrait
	Perl_Player_Update_PvP_Status();					-- Is the character PvP flagged?
	Perl_Player_Update_PvP_Timer();						-- Is the PvP timer counting down?
	Perl_Player_Update_Health();						-- Set the player's health on load or toggle
	Perl_Player_Update_Mana_Bar();						-- Set the type of mana used
	Perl_Player_Update_Mana();						-- Set the player's mana/energy on load or toggle
	Perl_Player_Update_Leader();						-- Are we the party leader?
	Perl_Player_Update_Loot_Method();					-- Are we the master looter?
	Perl_Player_Update_Role();						-- What group role are we playing as?
	Perl_Player_Update_Combat_Status();					-- Are we already fighting or resting?
	Perl_Player_Update_Threat();						-- Are we agro on something?
	Perl_Player_BuffUpdateAll();						-- Do we have any curable debuffs on us?

	-- Out of Combat ONLY functions
	Perl_Player_Update_Raid_Group_Number();					-- Are we in a raid?
	Perl_Player_Frame_Style();
end

function Perl_Player_Update_Health()
	playerhealth = UnitHealth("player");
	playerhealthmax = UnitHealthMax("player");
	playerhealthpercent = floor(playerhealth/playerhealthmax*100+0.5);

	if (UnitIsDead("player") or UnitIsGhost("player")) then			-- This prevents negative health
		playerhealth = 0;
		playerhealthpercent = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (playerhealth < Perl_Player_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and playerhealth > Perl_Player_HealthBar:GetValue())) then
			Perl_Player_HealthBarFadeBar:SetMinMaxValues(0, playerhealthmax);
			Perl_Player_HealthBarFadeBar:SetValue(Perl_Player_HealthBar:GetValue());
			Perl_Player_HealthBarFadeBar:Show();
			Perl_Player_HealthBar_Fade_Color = 1;
			Perl_Player_HealthBar_Fade_Time_Elapsed = 0;
			Perl_Player_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Player_HealthBar:SetMinMaxValues(0, playerhealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Player_HealthBar:SetValue(playerhealthmax - playerhealth);
	else
		Perl_Player_HealthBar:SetValue(playerhealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((playerhealthpercent <= 100) and (playerhealthpercent > 75)) then
--			Perl_Player_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_Player_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((playerhealthpercent <= 75) and (playerhealthpercent > 50)) then
--			Perl_Player_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_Player_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((playerhealthpercent <= 50) and (playerhealthpercent > 25)) then
--			Perl_Player_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_Player_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_Player_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_Player_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = playerhealth / playerhealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_Player_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_Player_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_Player_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_Player_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (compactmode == 0) then
		if (healermode == 1) then									-- Compact mode OFF and Healer mode ON
			Perl_Player_HealthBarText:SetText("-"..playerhealthmax - playerhealth);
			if (showbarvalues == 0) then
				if (mouseoverhealthflag == 0) then
					Perl_Player_HealthBarTextPercent:SetText();					-- Add text here if you dont't want the bar values hidden in healer mode.  Set the value in the function Perl_Player_HealthHide to the same as this.
				else
					Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
				end
			else
				Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
			end
		else												-- Compact mode OFF and Healer mode OFF
			Perl_Player_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
			Perl_Player_HealthBarTextPercent:SetText(playerhealthpercent .. "%");
		end
		Perl_Player_HealthBarTextCompactPercent:SetText();						-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then									-- Compact mode ON and Healer mode ON
			Perl_Player_HealthBarText:SetText("-"..playerhealthmax - playerhealth);
			if (showbarvalues == 0) then
				if (mouseoverhealthflag == 0) then
					Perl_Player_HealthBarTextPercent:SetText();					-- Add text here if you dont't want the bar values hidden in healer mode.  Set the value in the function Perl_Player_HealthHide to the same as this.
				else
					Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
				end
			else
				Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
			end
		else												-- Compact mode ON and Healer mode OFF
			Perl_Player_HealthBarText:SetText();
			Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
		end

		if (compactpercent == 1) then
			Perl_Player_HealthBarTextCompactPercent:SetText(playerhealthpercent.."%");
		else
			Perl_Player_HealthBarTextCompactPercent:SetText();
		end
	end
end

function Perl_Player_Update_Mana()
	playermana = UnitMana("player");
	playermanamax = UnitManaMax("player");
	playermanapercent = floor(playermana/playermanamax*100+0.5);

	if (UnitIsDead("player") or UnitIsGhost("player") or playermanamax == 0) then			-- This prevents negative mana
		playermana = 0;
		playermanapercent = 0;
	end

	if (playermana ~= playermanamax) then
		Perl_Player_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_Player_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (playermana < Perl_Player_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and playermana > Perl_Player_ManaBar:GetValue())) then
			Perl_Player_ManaBarFadeBar:SetMinMaxValues(0, playermanamax);
			Perl_Player_ManaBarFadeBar:SetValue(Perl_Player_ManaBar:GetValue());
			Perl_Player_ManaBarFadeBar:Show();
			Perl_Player_ManaBar_Fade_Color = 1;
			Perl_Player_ManaBar_Fade_Time_Elapsed = 0;
			Perl_Player_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_Player_ManaBar:SetMinMaxValues(0, playermanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_Player_ManaBar:SetValue(playermanamax - playermana);
	else
		Perl_Player_ManaBar:SetValue(playermana);
	end

	Perl_Player_Update_Mana_Text()

	if (showdruidbar == 1) then
		_, englishclass = UnitClass("player");
		if (englishclass == "DRUID") then				-- Are we a Druid?
			if (UnitPowerType("player") > 0) then		-- Are we in a manaless form?
				playerdruidbarmana = UnitPower("player", 0);
				playerdruidbarmanamax = UnitPowerMax("player", 0);
				playerdruidbarmanapercent = floor(playerdruidbarmana/playerdruidbarmanamax*100+0.5);

				if (playerdruidbarmanapercent == 100) then			-- This is to ensure the value isn't 1 or 2 mana under max when 100%
					playerdruidbarmana = playerdruidbarmanamax;
				end

		--		if (PCUF_FADEBARS == 1) then
		--			if (playerdruidbarmana < Perl_Player_DruidBar:GetValue()) then
		--				Perl_Player_DruidBarFadeBar:SetMinMaxValues(0, playerdruidbarmanamax);
		--				Perl_Player_DruidBarFadeBar:SetValue(Perl_Player_DruidBarFadeBar:GetValue());
		--				Perl_Player_DruidBarFadeBar:Show();
		--				Perl_Player_DruidBar_Fade_Color = 1;
		--				Perl_Player_DruidBar_Fade_Time_Elapsed = 0;
		--				Perl_Player_DruidBar_Fade_OnUpdate_Frame:Show();
		--			end
		--		end

				Perl_Player_DruidBar:SetMinMaxValues(0, playerdruidbarmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_Player_DruidBar:SetValue(playerdruidbarmanamax - playerdruidbarmana);
				else
					Perl_Player_DruidBar:SetValue(playerdruidbarmana);
				end

				-- Display the needed text
				if (compactmode == 0) then
					if (healermode == 1) then
						Perl_Player_DruidBarText:SetTextColor(0.5, 0.5, 0.5, 1);
						if (showmanadeficit == 1) then
							Perl_Player_DruidBarText:SetText("-"..playerdruidbarmanamax - playerdruidbarmana);
						else
							Perl_Player_DruidBarText:SetText();
						end
						if (showbarvalues == 0) then
							if (mouseovermanaflag == 0) then
								Perl_Player_DruidBarTextPercent:SetText();
							else
								Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
							end
						else
							Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
						end
					else
						Perl_Player_DruidBarText:SetTextColor(1, 1, 1, 1);
						Perl_Player_DruidBarText:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
						Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmanapercent.."%");
					end
					Perl_Player_DruidBarTextCompactPercent:SetText();	-- Hide the compact mode percent text in full mode
				else
					if (healermode == 1) then
						Perl_Player_DruidBarText:SetTextColor(0.5, 0.5, 0.5, 1);
						if (showmanadeficit == 1) then
							Perl_Player_DruidBarText:SetText("-"..playermanamax - playermana);
						else
							Perl_Player_DruidBarText:SetText();
						end
						if (showbarvalues == 0) then
							if (mouseovermanaflag == 0) then
								Perl_Player_DruidBarTextPercent:SetText();
							else
								Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
							end
						else
							Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
						end
					else
						Perl_Player_DruidBarText:SetTextColor(1, 1, 1, 1);
						Perl_Player_DruidBarText:SetText();
						Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
					end

					if (compactpercent == 1) then
						Perl_Player_DruidBarTextCompactPercent:SetText(playerdruidbarmanapercent.."%");
					else
						Perl_Player_DruidBarTextCompactPercent:SetText();
					end
				end
			else
				-- Hide it all (bars and text)
				Perl_Player_DruidBarText:SetText();
				Perl_Player_DruidBarTextPercent:SetText();
				Perl_Player_DruidBarTextCompactPercent:SetText();
				Perl_Player_DruidBar:SetMinMaxValues(0, 1);
				Perl_Player_DruidBar:SetValue(0);
			end
		else
			-- Hide it all (bars and text)
			Perl_Player_DruidBarText:SetText();
			Perl_Player_DruidBarTextPercent:SetText();
			Perl_Player_DruidBarTextCompactPercent:SetText();
			Perl_Player_DruidBar:SetMinMaxValues(0, 1);
			Perl_Player_DruidBar:SetValue(0);
		end
	end

	if (UnitPowerType("player") == 0 and fivesecondrule == 1) then
		if (playermana < fivesecondrulelastmana) then
			fivesecondruletime = GetTime();
			Perl_Player_FiveSecondRule:Show();
		end
		fivesecondrulelastmana = playermana
	end
end

function Perl_Player_Update_Mana_Text()
	playermanapercent = floor(playermana/playermanamax*100+0.5);

	if (compactmode == 0) then
		if (healermode == 1) then
			Perl_Player_ManaBarText:SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				Perl_Player_ManaBarText:SetText("-"..playermanamax - playermana);
			else
				Perl_Player_ManaBarText:SetText();
			end
			if (showbarvalues == 0) then
				if (mouseovermanaflag == 0) then
					Perl_Player_ManaBarTextPercent:SetText();
				else
					if (playerpower == 1 or playerpower == 6) then
						Perl_Player_ManaBarTextPercent:SetText(playermana);
					else
						Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
					end
				end
			else
				if (playerpower == 1 or playerpower == 6) then
					Perl_Player_ManaBarTextPercent:SetText(playermana);
				else
					Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
				end
			end
		else
			Perl_Player_ManaBarText:SetTextColor(1, 1, 1, 1);
			Perl_Player_ManaBarText:SetText(playermana.."/"..playermanamax);
			if (playerpower == 1 or playerpower == 6) then
				Perl_Player_ManaBarTextPercent:SetText(playermana);
			else
				Perl_Player_ManaBarTextPercent:SetText(playermanapercent.."%");
			end
		end
		Perl_Player_ManaBarTextCompactPercent:SetText();		-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then
			Perl_Player_ManaBarText:SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				Perl_Player_ManaBarText:SetText("-"..playermanamax - playermana);
			else
				Perl_Player_ManaBarText:SetText();
			end
			if (showbarvalues == 0) then
				if (mouseovermanaflag == 0) then
					Perl_Player_ManaBarTextPercent:SetText();
				else
					if (playerpower == 1 or playerpower == 6) then
						Perl_Player_ManaBarTextPercent:SetText(playermana);
					else
						Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
					end
				end
			else
				if (playerpower == 1 or playerpower == 6) then
					Perl_Player_ManaBarTextPercent:SetText(playermana);
				else
					Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
				end
			end
		else
			Perl_Player_ManaBarText:SetTextColor(1, 1, 1, 1);
			Perl_Player_ManaBarText:SetText();
			if (playerpower == 1 or playerpower == 6) then
				Perl_Player_ManaBarTextPercent:SetText(playermana);
			else
				Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
			end
		end

		if (compactpercent == 1) then
			Perl_Player_ManaBarTextCompactPercent:SetText(playermanapercent.."%");
		else
			Perl_Player_ManaBarTextCompactPercent:SetText();
		end
	end
end

function Perl_Player_OnUpdate_ManaBar(arg1)
	Perl_Player_ManaBar_Time_Elapsed = Perl_Player_ManaBar_Time_Elapsed + arg1;
	if (Perl_Player_ManaBar_Time_Elapsed > Perl_Player_ManaBar_Time_Update_Rate) then
		Perl_Player_ManaBar_Time_Elapsed = 0;

		playeronupdatemana = UnitPower("player", UnitPowerType("player"));
		if (playeronupdatemana ~= playermana) then
			playermana = playeronupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Player_ManaBar:SetValue(playermanamax - playeronupdatemana);
			else
				Perl_Player_ManaBar:SetValue(playeronupdatemana);
			end
			Perl_Player_Update_Mana_Text();
		end
	end
end

function Perl_Player_Update_Mana_Bar()
	playerpower = UnitPowerType("player");

	-- Set mana bar color
	if (playerpower == 0) then		-- mana
		Perl_Player_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	elseif (playerpower == 1) then		-- rage
		Perl_Player_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
	elseif (playerpower == 3) then		-- energy
		Perl_Player_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
	elseif (playerpower == 6) then		-- runic
		Perl_Player_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
		Perl_Player_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
	end

	Perl_Player_FiveSecondRule:Hide();	-- reset the five second rule ticker
	fivesecondrulelastmana = 0;
end

function Perl_Player_Update_Experience()
	Perl_Player_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);		-- move this to the frame style function later
	Perl_Player_XPRestBar:SetStatusBarColor(0, 0.6, 0.6, 0.5);
	Perl_Player_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);

	if (UnitLevel("player") ~= 80) then
		-- XP Bar stuff
		local playerxp = UnitXP("player");
		local playerxpmax = UnitXPMax("player");
		local playerxprest = GetXPExhaustion();

		Perl_Player_XPBar:SetMinMaxValues(0, playerxpmax);
		Perl_Player_XPRestBar:SetMinMaxValues(0, playerxpmax);
		Perl_Player_XPBar:SetValue(playerxp);

		-- Set xp text
		local xptext = playerxp.."/"..playerxpmax;
		local xptextpercent = floor(playerxp/playerxpmax*100+0.5);

		if (playerxprest) then
			xptext = xptext.."(+"..(playerxprest)..")";
			Perl_Player_XPRestBar:SetValue(playerxp + playerxprest);
			Perl_Player_XPBarText:SetText(xptextpercent.."%".." (+"..floor(playerxprest/playerxpmax*100+0.5).."%)");
		else
			Perl_Player_XPRestBar:SetValue(playerxp);
			Perl_Player_XPBarText:SetText(xptextpercent.."%");
		end
	else
		Perl_Player_XPBar:SetMinMaxValues(0, 1);
		Perl_Player_XPRestBar:SetMinMaxValues(0, 1);
		Perl_Player_XPBar:SetValue(1);
		Perl_Player_XPRestBar:SetValue(1);

		Perl_Player_XPBarText:SetText(PERL_LOCALIZED_PLAYER_LEVEL_EIGHTY);
	end
	
end

function Perl_Player_Update_Reputation()
	local name, reaction, min, max, value = GetWatchedFactionInfo();
	if (name) then
		value = value - min;
		max = max - min;
		min = 0;
		
		Perl_Player_XPBar:SetMinMaxValues(min, max);
		Perl_Player_XPRestBar:SetMinMaxValues(min, max);
		Perl_Player_XPBar:SetValue(value);
		Perl_Player_XPRestBar:SetValue(value);

		local color = FACTION_BAR_COLORS[reaction];
		Perl_Player_XPBar:SetStatusBarColor(color.r, color.g, color.b, 1);
		Perl_Player_XPRestBar:SetStatusBarColor(color.r, color.g, color.b, 0.5);
		Perl_Player_XPBarBG:SetStatusBarColor(color.r, color.g, color.b, 0.25);

		Perl_Player_XPBarText:SetText(value.."/"..max);
	else
		Perl_Player_XPBar:SetMinMaxValues(0, 1);
		Perl_Player_XPRestBar:SetMinMaxValues(0, 1);
		Perl_Player_XPBar:SetValue(1);
		Perl_Player_XPRestBar:SetValue(1);

		Perl_Player_XPBar:SetStatusBarColor(0.9, 0.7, 0, 1);
		Perl_Player_XPRestBar:SetStatusBarColor(0.9, 0.7, 0, 0.5);
		Perl_Player_XPBarBG:SetStatusBarColor(0.9, 0.7, 0, 0.25);

		Perl_Player_XPBarText:SetText(PERL_LOCALIZED_PLAYER_SELECT_REPUTATION);
	end
end

function Perl_Player_Update_Combat_Status(event)
	-- Rest/Combat Status Icon
	if (event == "PLAYER_REGEN_DISABLED") then
		InCombat = 1;
		Perl_Player_ActivityStatus:SetTexCoord(0.5, 1.0, 0.0, 0.5);
		Perl_Player_ActivityStatus:Show();
	elseif (event == "PLAYER_REGEN_ENABLED") then
		InCombat = 0;
		if (IsResting()) then
			Perl_Player_ActivityStatus:SetTexCoord(0, 0.5, 0.0, 0.5);
			Perl_Player_ActivityStatus:Show();
		else
			Perl_Player_ActivityStatus:Hide();
		end
	elseif (IsResting()) then
		if (InCombat == 1) then
			return;
		else
			Perl_Player_ActivityStatus:SetTexCoord(0, 0.5, 0.0, 0.5);
			Perl_Player_ActivityStatus:Show();
		end
	else
		if (InCombat == 1) then
			return;
		else
			Perl_Player_ActivityStatus:Hide();
		end
	end
end

function Perl_Player_Update_Raid_Group_Number()
	local numRaidMembers = GetNumRaidMembers();

	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Update_Raid_Group_Number);
	else
		if (showraidgroup == 1) then
			if (numRaidMembers == 0) then
				Perl_Player_RaidGroupNumberFrame:Hide();
				Perl_Player_MasterIcon:Hide();		-- This was added to correctly hide the master loot icon after leaving a party/raid
			else
				Perl_Player_RaidGroupNumberFrame:Show();
			end
		else
			Perl_Player_RaidGroupNumberFrame:Hide();
		end
	end

	if (showraidgroupinname == 0) then
		Perl_Player_NameBarText:SetText(UnitName("player"));
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then	-- ArcaneBar Support
			Perl_ArcaneBar_player.unitname = Perl_Player_NameBarText:GetText();
		end
		if (showraidgroup == 0) then
			if (numRaidMembers == 0) then
				Perl_Player_MasterIcon:Hide();
			end
			return;
		end
	end

	if (numRaidMembers == 0) then
		Perl_Player_NameBarText:SetText(UnitName("player"));
		Perl_Player_MasterIcon:Hide();
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then	-- ArcaneBar Support
			Perl_ArcaneBar_player.unitname = Perl_Player_NameBarText:GetText();
		end
		return;
	end

	local name, rank, subgroup;
	for i=1,40 do				-- taken from 1.8
		if (i <= numRaidMembers) then
			name, rank, subgroup = GetRaidRosterInfo(i);
			-- Set the player's group number indicator
			if (name == UnitName("player")) then
				Perl_Player_RaidGroupNumberBarText:SetText(PERL_LOCALIZED_PLAYER_GROUP..subgroup);
				if (showraidgroupinname == 1) then
					Perl_Player_NameBarText:SetText(UnitName("player")..":"..subgroup);
					if (Perl_ArcaneBar_Frame_Loaded_Frame) then	-- ArcaneBar Support
						Perl_ArcaneBar_player.unitname = Perl_Player_NameBarText:GetText();
					end
				end
				return;
			end
		end
	end
end

function Perl_Player_Update_Leader()
	if (IsPartyLeader()) then
		Perl_Player_LeaderIcon:Show();
	else
		Perl_Player_LeaderIcon:Hide();
	end
end

function Perl_Player_Update_Loot_Method()
	local _, lootMaster = GetLootMethod();
	if (lootMaster == 0) then
		Perl_Player_MasterIcon:Show();
	else
		Perl_Player_MasterIcon:Hide();
	end
end

function Perl_Player_Update_Role()
	local isTank, isHealer, isDamage = UnitGroupRolesAssigned("player");
	if(isTank) then
		Perl_Player_RoleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		Perl_Player_RoleIcon:Show();
	elseif(isHealer) then
		Perl_Player_RoleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		Perl_Player_RoleIcon:Show();
	elseif(isDamage) then
		Perl_Player_RoleIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64);
		Perl_Player_RoleIcon:Show();
	else
		Perl_Player_RoleIcon:Hide();
	end
end

function Perl_Player_Update_PvP_Status()
	if (UnitIsPVP("player") and not UnitIsPVPSanctuary("player")) then
		if (UnitIsPVPFreeForAll("player")) then
			if (showpvpicon == 1) then
				Perl_Player_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
				Perl_Player_PVPStatus:Show();
			else
				Perl_Player_PVPStatus:Hide();
			end
		elseif (UnitFactionGroup("player")) then
			Perl_Player_NameBarText:SetTextColor(0, 1, 0);		-- Green if PvP flagged
			if (showpvpicon == 1) then
				Perl_Player_PVPStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..UnitFactionGroup("player"));
				Perl_Player_PVPStatus:Show();
			else
				Perl_Player_PVPStatus:Hide();
			end
		else
			Perl_Player_NameBarText:SetTextColor(1, 0, 0);		-- Red if charmed
			Perl_Player_PVPStatus:Hide();
		end
	else
		Perl_Player_NameBarText:SetTextColor(0.5, 0.5, 1);		-- Blue if not PvP flagged
		Perl_Player_PVPStatus:Hide();
	end

	if (classcolorednames == 1) then				-- Color by class
		_, englishclass = UnitClass("player");
		Perl_Player_NameBarText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
	end
end

function Perl_Player_Update_Threat()
	local status = UnitThreatSituation("player");

	if (status == nil) then
		Perl_Player_ThreatIndicator:Hide();
		return;
	end

	if (status > 0 and PCUF_THREATICON == 1) then
		Perl_Player_ThreatIndicator:SetVertexColor(GetThreatStatusColor(status));
		Perl_Player_ThreatIndicator:Show();
	else
		Perl_Player_ThreatIndicator:Hide();
	end
end

function Perl_Player_Update_PvP_Timer()
	if (IsPVPTimerRunning() and pvptimer == 1) then
		Perl_Player_PvP_Timer_OnUpdate_Frame:Show();
		Perl_Player_NameBarPvPTimerText:Show();
	else
		Perl_Player_PvP_Timer_OnUpdate_Frame:Hide();
		Perl_Player_NameBarPvPTimerText:Hide();
		Perl_Player_NameBarPvPTimerText:SetText();
	end
end

function Perl_Player_OnUpdate_PvP_Timer()
	Perl_Player_PvP_Text_Time_Elapsed = Perl_Player_PvP_Text_Time_Elapsed + arg1;
	if (Perl_Player_PvP_Text_Time_Elapsed > Perl_Player_PvP_Text_Time_Update_Rate) then
		Perl_Player_PvP_Text_Time_Elapsed = 0;

		pvptimeleft = floor(GetPVPTimer()/1200);
		if (pvptimeleft > 60) then
			Perl_Player_NameBarPvPTimerText:SetText(floor(pvptimeleft/60).."m"..(pvptimeleft%60).."s");
		else
			Perl_Player_NameBarPvPTimerText:SetText(pvptimeleft.."s");
		end
	end
end

function Perl_Player_HealthShow()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			playerhealth = UnitHealth("player");
			playerhealthmax = UnitHealthMax("player");

			if (UnitIsDead("player") or UnitIsGhost("player")) then				-- This prevents negative health
				playerhealth = 0;
			end

			Perl_Player_HealthBarTextPercent:SetText(playerhealth.."/"..playerhealthmax);
			mouseoverhealthflag = 1;
		end
	end
end

function Perl_Player_HealthHide()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			Perl_Player_HealthBarTextPercent:SetText();
			mouseoverhealthflag = 0;
		end
	end
end

function Perl_Player_ManaShow()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			playermana = UnitMana("player");
			playermanamax = UnitManaMax("player");

			if (UnitIsDead("player") or UnitIsGhost("player")) then				-- This prevents negative mana
				playermana = 0;
			end

			if (UnitPowerType("player") == 1 or UnitPowerType("player") == 6) then
				Perl_Player_ManaBarTextPercent:SetText(playermana);
			else
				Perl_Player_ManaBarTextPercent:SetText(playermana.."/"..playermanamax);
			end
			mouseovermanaflag = 1;
		end
	end
end

function Perl_Player_ManaHide()
	if (healermode == 1) then
		if (showbarvalues == 0) then
			Perl_Player_ManaBarTextPercent:SetText();
			mouseovermanaflag = 0;
		end
	end
end

function Perl_Player_DruidBarManaShow()
	_, englishclass = UnitClass("player");
	if (DruidBarKey and (englishclass == "DRUID")) then
		if (healermode == 1) then
			playerdruidbarmana = floor(DruidBarKey.keepthemana);
			playerdruidbarmanamax = DruidBarKey.maxmana;
			playerdruidbarmanapercent = floor(playerdruidbarmana/playerdruidbarmanamax*100+0.5);

			if (playerdruidbarmanapercent == 100) then			-- This is to ensure the value isn't 1 or 2 mana under max when 100%
				playerdruidbarmana = playerdruidbarmanamax;
			end

			if (UnitIsDead("player") or UnitIsGhost("player")) then		-- This prevents negative mana
				playerdruidbarmana = 0;
			end

			Perl_Player_DruidBarTextPercent:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);

			mouseovermanaflag = 1;
		end
	end
end

function Perl_Player_DruidBarManaHide()
	if (healermode == 1) then
		Perl_Player_DruidBarTextPercent:SetText();
		mouseovermanaflag = 0;
	end
end

function Perl_Player_Update_Portrait()
	if (showportrait == 1) then
		if (threedportrait == 0) then
			SetPortraitTexture(Perl_Player_Portrait, "player");		-- Load the correct 2d graphic
		else
			Perl_Player_PortraitFrame_PlayerModel:SetUnit("player");	-- Load the correct 3d graphic
			Perl_Player_PortraitFrame_PlayerModel:SetCamera(0);
		end
	end
end

function Perl_Player_FiveSecondRule_OnUpdate(self, elapsed)
	local bartime = GetTime() - fivesecondruletime;
	Perl_Player_FiveSecondRuleSpark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * (bartime / 5), 0);
	if (bartime > 5) then
		self:Hide();
		fivesecondrulelastmana = 0;
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Player_HealthBar_Fade(arg1)
	Perl_Player_HealthBar_Fade_Color = Perl_Player_HealthBar_Fade_Color - arg1;
	Perl_Player_HealthBar_Fade_Time_Elapsed = Perl_Player_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Player_HealthBarFadeBar:SetStatusBarColor(0, Perl_Player_HealthBar_Fade_Color, 0, Perl_Player_HealthBar_Fade_Color);

	if (Perl_Player_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Player_HealthBar_Fade_Color = 1;
		Perl_Player_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Player_HealthBarFadeBar:Hide();
		Perl_Player_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Player_ManaBar_Fade(arg1)
	Perl_Player_ManaBar_Fade_Color = Perl_Player_ManaBar_Fade_Color - arg1;
	Perl_Player_ManaBar_Fade_Time_Elapsed = Perl_Player_ManaBar_Fade_Time_Elapsed + arg1;

	if (playerpower == 0) then
		Perl_Player_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Player_ManaBar_Fade_Color, Perl_Player_ManaBar_Fade_Color);
	elseif (playerpower == 1) then
		Perl_Player_ManaBarFadeBar:SetStatusBarColor(Perl_Player_ManaBar_Fade_Color, 0, 0, Perl_Player_ManaBar_Fade_Color);
	elseif (playerpower == 3) then
		Perl_Player_ManaBarFadeBar:SetStatusBarColor(Perl_Player_ManaBar_Fade_Color, Perl_Player_ManaBar_Fade_Color, 0, Perl_Player_ManaBar_Fade_Color);
	elseif (playerpower == 6) then
		Perl_Player_ManaBarFadeBar:SetStatusBarColor(0, Perl_Player_ManaBar_Fade_Color, Perl_Player_ManaBar_Fade_Color, Perl_Player_ManaBar_Fade_Color);
	end

	if (Perl_Player_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Player_ManaBar_Fade_Color = 1;
		Perl_Player_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Player_ManaBarFadeBar:Hide();
		Perl_Player_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

--function Perl_Player_DruidBar_Fade(arg1)
--	Perl_Player_DruidBar_Fade_Color = Perl_Player_DruidBar_Fade_Color - arg1;
--	Perl_Player_DruidBar_Fade_Time_Elapsed = Perl_Player_DruidBar_Fade_Time_Elapsed + arg1;
--
--	Perl_Player_DruidBarFadeBar:SetStatusBarColor(0, 0, Perl_Player_DruidBar_Fade_Color, Perl_Player_DruidBar_Fade_Color);
--
--	if (Perl_Player_DruidBar_Fade_Time_Elapsed > 1) then
--		Perl_Player_DruidBar_Fade_Color = 1;
--		Perl_Player_DruidBar_Fade_Time_Elapsed = 0;
--		Perl_Player_DruidBarFadeBar:Hide();
--		Perl_Player_DruidBar_Fade_OnUpdate_Frame:Hide();
--	end
--end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Player_Frame_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Frame_Style);
	else
		-- Begin: Set the xp bar mode and update the experience if needed
		if (xpbarstate == 1) then						-- Experience
			Perl_Player_StatsFrame:SetHeight(54);
			Perl_Player_StatsFrame_CastClickOverlay:SetHeight(54);
			Perl_Player_XPBar:Show();
			Perl_Player_XPBarBG:Show();
			Perl_Player_XPRestBar:Show();
			Perl_Player_XPBar_CastClickOverlay:Show();
			Perl_Player_Update_Experience();
		elseif (xpbarstate == 2) then						-- PvP
			Perl_Player_StatsFrame:SetHeight(54);
			Perl_Player_StatsFrame_CastClickOverlay:SetHeight(54);
			Perl_Player_XPBar:Show();
			Perl_Player_XPBarBG:Show();
			Perl_Player_XPRestBar:Show();
			Perl_Player_XPBar_CastClickOverlay:Show();
			local rankNumber, rankName, rankProgress;
			rankNumber = UnitPVPRank("player")
			if (rankNumber < 1) then
				rankName = "Unranked"
			else
				rankName = GetPVPRankInfo(rankNumber, "player");
			end
			Perl_Player_XPBar:SetMinMaxValues(0, 1);
			Perl_Player_XPRestBar:SetMinMaxValues(0, 1);
			Perl_Player_XPBar:SetValue(GetPVPRankProgress());
			Perl_Player_XPRestBar:SetValue(GetPVPRankProgress());
			Perl_Player_XPBarText:SetText(rankName);
			Perl_Player_XPBar:SetStatusBarColor(0, 0.6, 0.6, 1);
			Perl_Player_XPRestBar:SetStatusBarColor(0, 0.6, 0.6, 0.5);
			Perl_Player_XPBarBG:SetStatusBarColor(0, 0.6, 0.6, 0.25);
		elseif (xpbarstate == 3) then						-- Hidden
			Perl_Player_XPBar:Hide();
			Perl_Player_XPBarBG:Hide();
			Perl_Player_XPRestBar:Hide();
			Perl_Player_XPBar_CastClickOverlay:Hide();
			Perl_Player_StatsFrame:SetHeight(42);
			Perl_Player_StatsFrame_CastClickOverlay:SetHeight(42);
		elseif (xpbarstate == 4) then						-- Reputation
			Perl_Player_StatsFrame:SetHeight(54);
			Perl_Player_StatsFrame_CastClickOverlay:SetHeight(54);
			Perl_Player_XPBar:Show();
			Perl_Player_XPBarBG:Show();
			Perl_Player_XPRestBar:Show();
			Perl_Player_XPBar_CastClickOverlay:Show();
			Perl_Player_Update_Reputation();
		end
		-- End: Set the xp bar mode and update the experience if needed

		-- Begin: Set the druid bar and tweak the experience bar if needed
		_, englishclass = UnitClass("player");
		if (showdruidbar == 1 and englishclass == "DRUID") then
			Perl_Player_DruidBar:Show();
			Perl_Player_DruidBarBG:Show();
			Perl_Player_DruidBar_CastClickOverlay:Show();
			Perl_Player_XPBar:SetPoint("TOPLEFT", "Perl_Player_DruidBar", "BOTTOMLEFT", 0, -2);

			if (xpbarstate == 3) then
				Perl_Player_StatsFrame:SetHeight(54);			-- Experience Bar is hidden
				Perl_Player_StatsFrame_CastClickOverlay:SetHeight(54);
			else
				Perl_Player_StatsFrame:SetHeight(66);			-- Experience Bar is shown
				Perl_Player_StatsFrame_CastClickOverlay:SetHeight(66);
			end
		else
			-- Hide it all (bars and text)
			Perl_Player_DruidBarText:SetText();
			Perl_Player_DruidBarTextPercent:SetText();
			Perl_Player_DruidBarTextCompactPercent:SetText();
			Perl_Player_DruidBar:Hide();
			Perl_Player_DruidBarBG:Hide();
			Perl_Player_DruidBar_CastClickOverlay:Hide();
			Perl_Player_XPBar:SetPoint("TOPLEFT", "Perl_Player_ManaBar", "BOTTOMLEFT", 0, -2);
		end
		-- End: Set the druid bar and tweak the experience bar if needed

		-- Begin: Are we using compact mode?
		if (compactmode == 0) then
			Perl_Player_XPBar:SetWidth(235);
			Perl_Player_XPRestBar:SetWidth(235);
			Perl_Player_XPBarBG:SetWidth(235);
			Perl_Player_XPBar_CastClickOverlay:SetWidth(235);
			Perl_Player_StatsFrame:SetWidth(255);
			Perl_Player_StatsFrame_CastClickOverlay:SetWidth(255);
		else
			if (compactpercent == 0) then
				if (shortbars == 0) then
					Perl_Player_XPBar:SetWidth(150);
					Perl_Player_XPRestBar:SetWidth(150);
					Perl_Player_XPBarBG:SetWidth(150);
					Perl_Player_XPBar_CastClickOverlay:SetWidth(150);
					Perl_Player_StatsFrame:SetWidth(170);
					Perl_Player_StatsFrame_CastClickOverlay:SetWidth(170);
				else
					Perl_Player_XPBar:SetWidth(115);
					Perl_Player_XPRestBar:SetWidth(115);
					Perl_Player_XPBarBG:SetWidth(115);
					Perl_Player_XPBar_CastClickOverlay:SetWidth(115);
					Perl_Player_StatsFrame:SetWidth(135);
					Perl_Player_StatsFrame_CastClickOverlay:SetWidth(135);
				end
			else
				if (shortbars == 0) then
					Perl_Player_XPBar:SetWidth(185);
					Perl_Player_XPRestBar:SetWidth(185);
					Perl_Player_XPBarBG:SetWidth(185);
					Perl_Player_XPBar_CastClickOverlay:SetWidth(185);
					Perl_Player_StatsFrame:SetWidth(205);
					Perl_Player_StatsFrame_CastClickOverlay:SetWidth(205);
				else
					Perl_Player_XPBar:SetWidth(150);
					Perl_Player_XPRestBar:SetWidth(150);
					Perl_Player_XPBarBG:SetWidth(150);
					Perl_Player_XPBar_CastClickOverlay:SetWidth(150);
					Perl_Player_StatsFrame:SetWidth(170);
					Perl_Player_StatsFrame_CastClickOverlay:SetWidth(170);
				end
			end
		end

		if (compactmode == 1 and shortbars == 1) then
			Perl_Player_Frame:SetWidth(167);
			Perl_Player_NameFrame:SetWidth(167);
			Perl_Player_Name:SetWidth(167);
			Perl_Player_Name_CastClickOverlay:SetWidth(167);

			Perl_Player_HealthBar:SetWidth(115);
			Perl_Player_HealthBarFadeBar:SetWidth(115);
			Perl_Player_HealthBarBG:SetWidth(115);
			Perl_Player_HealthBar_CastClickOverlay:SetWidth(115);
			Perl_Player_ManaBar:SetWidth(115);
			Perl_Player_ManaBarFadeBar:SetWidth(115);
			Perl_Player_ManaBarBG:SetWidth(115);
			Perl_Player_ManaBar_CastClickOverlay:SetWidth(115);
			Perl_Player_DruidBar:SetWidth(115);
			--Perl_Player_DruidBarFadeBar:SetWidth(115);
			Perl_Player_DruidBarBG:SetWidth(115);
			Perl_Player_DruidBar_CastClickOverlay:SetWidth(115);
		else
			Perl_Player_Frame:SetWidth(202);
			Perl_Player_NameFrame:SetWidth(202);
			Perl_Player_Name:SetWidth(202);
			Perl_Player_Name_CastClickOverlay:SetWidth(202);

			Perl_Player_HealthBar:SetWidth(150);
			Perl_Player_HealthBarFadeBar:SetWidth(150);
			Perl_Player_HealthBarBG:SetWidth(150);
			Perl_Player_HealthBar_CastClickOverlay:SetWidth(150);
			Perl_Player_ManaBar:SetWidth(150);
			Perl_Player_ManaBarFadeBar:SetWidth(150);
			Perl_Player_ManaBarBG:SetWidth(150);
			Perl_Player_ManaBar_CastClickOverlay:SetWidth(150);
			Perl_Player_DruidBar:SetWidth(150);
			--Perl_Player_DruidBarFadeBar:SetWidth(150);
			Perl_Player_DruidBarBG:SetWidth(150);
			Perl_Player_DruidBar_CastClickOverlay:SetWidth(150);
		end

		if (hideclasslevelframe == 1) then
			Perl_Player_LevelFrame:Hide();
			Perl_Player_StatsFrame:SetPoint("TOPLEFT", Perl_Player_NameFrame, "BOTTOMLEFT", 0, 2);
			Perl_Player_StatsFrame:SetWidth(Perl_Player_StatsFrame:GetWidth() + 32);
			Perl_Player_StatsFrame_CastClickOverlay:SetWidth(Perl_Player_StatsFrame_CastClickOverlay:GetWidth() + 30);
			
			Perl_Player_HealthBar:SetWidth(Perl_Player_HealthBar:GetWidth() + 30);
			Perl_Player_HealthBarFadeBar:SetWidth(Perl_Player_HealthBarFadeBar:GetWidth() + 30);
			Perl_Player_HealthBarBG:SetWidth(Perl_Player_HealthBarBG:GetWidth() + 30);
			Perl_Player_HealthBar_CastClickOverlay:SetWidth(Perl_Player_HealthBar_CastClickOverlay:GetWidth() + 30);
			
			Perl_Player_ManaBar:SetWidth(Perl_Player_ManaBar:GetWidth() + 30);
			Perl_Player_ManaBarFadeBar:SetWidth(Perl_Player_ManaBarFadeBar:GetWidth() + 30);
			Perl_Player_ManaBarBG:SetWidth(Perl_Player_ManaBarBG:GetWidth() + 30);
			Perl_Player_ManaBar_CastClickOverlay:SetWidth(Perl_Player_ManaBar_CastClickOverlay:GetWidth() + 30);
			
			Perl_Player_DruidBar:SetWidth(Perl_Player_DruidBar:GetWidth() + 30);
			--Perl_Player_DruidBarFadeBar:SetWidth(Perl_Player_DruidBarFadeBar:GetWidth() + 30);
			Perl_Player_DruidBarBG:SetWidth(Perl_Player_DruidBarBG:GetWidth() + 30);
			Perl_Player_DruidBar_CastClickOverlay:SetWidth(Perl_Player_DruidBar_CastClickOverlay:GetWidth() + 30);

			Perl_Player_XPBar:SetWidth(Perl_Player_XPBar:GetWidth() + 30);
			Perl_Player_XPRestBar:SetWidth(Perl_Player_XPRestBar:GetWidth() + 30);
			Perl_Player_XPBarBG:SetWidth(Perl_Player_XPBarBG:GetWidth() + 30);
			Perl_Player_XPBar_CastClickOverlay:SetWidth(Perl_Player_XPBar_CastClickOverlay:GetWidth() + 30);
		else
			Perl_Player_LevelFrame:Show();
			Perl_Player_StatsFrame:SetPoint("TOPLEFT", Perl_Player_NameFrame, "BOTTOMLEFT", 32, 2);
		end
		-- Begin: Are we using compact mode?

		-- Begin: Align the text according to compact and healer mode
		Perl_Player_HealthBarTextPercent:ClearAllPoints();
		Perl_Player_ManaBarTextPercent:ClearAllPoints();
		Perl_Player_DruidBarTextPercent:ClearAllPoints();
		if (compactmode == 0) then
			Perl_Player_HealthBarText:SetPoint("RIGHT", 85, 0);
			Perl_Player_HealthBarTextPercent:SetPoint("TOP", 0, 1);
			Perl_Player_ManaBarText:SetPoint("RIGHT", 85, 0);
			Perl_Player_ManaBarTextPercent:SetPoint("TOP", 0, 1);
			Perl_Player_DruidBarText:SetPoint("RIGHT", 85, 0);
			Perl_Player_DruidBarTextPercent:SetPoint("TOP", 0, 1);
		else
			if (healermode == 0) then
				Perl_Player_HealthBarText:SetPoint("RIGHT", 85, 0);
				Perl_Player_HealthBarTextPercent:SetPoint("TOP", 0, 1);
				Perl_Player_ManaBarText:SetPoint("RIGHT", 85, 0);
				Perl_Player_ManaBarTextPercent:SetPoint("TOP", 0, 1);
				Perl_Player_DruidBarText:SetPoint("RIGHT", 85, 0);
				Perl_Player_DruidBarTextPercent:SetPoint("TOP", 0, 1);
			else
				Perl_Player_HealthBarText:SetPoint("RIGHT", -10, 0);
				Perl_Player_HealthBarTextPercent:SetPoint("TOPLEFT", 5, 1);
				Perl_Player_ManaBarText:SetPoint("RIGHT", -10, 0);
				Perl_Player_ManaBarTextPercent:SetPoint("TOPLEFT", 5, 1);
				Perl_Player_DruidBarText:SetPoint("RIGHT", -10, 0);
				Perl_Player_DruidBarTextPercent:SetPoint("TOPLEFT", 5, 1);
			end
		end
		-- End: Align the text according to compact and healer mode

		-- Begin: Show/Hide the portrait frame
		if (showportrait == 1) then
			Perl_Player_PortraitFrame:Show();					-- Show the main portrait frame
			if (threedportrait == 0) then
				Perl_Player_PortraitFrame_PlayerModel:Hide();			-- Hide the 3d graphic
				Perl_Player_Portrait:Show();					-- Show the 2d graphic
			else
				Perl_Player_Portrait:Hide();					-- Hide the 2d graphic
				Perl_Player_PortraitFrame_PlayerModel:Show();			-- Show the 3d graphic
			end
		else
			Perl_Player_PortraitFrame:Hide();					-- Hide the frame and 2d/3d portion
		end
		-- End: Show/Hide the portrait frame

		-- Begin: Align the player_buff mod if appropriate
		if (Perl_Player_Buff_Script_Frame) then
			if (showportrait == 1) then
				if (xpbarstate == 3) then
					Perl_Player_BuffFrame:SetPoint("TOPLEFT", "Perl_Player_PortraitFrame", "BOTTOMLEFT", 0, -2);
				else
					Perl_Player_BuffFrame:SetPoint("TOPLEFT", "Perl_Player_PortraitFrame", "BOTTOMLEFT", 0, -10);
				end
			else
				Perl_Player_BuffFrame:SetPoint("TOPLEFT", "Perl_Player_StatsFrame", "BOTTOMLEFT", 0, -2);
			end
		end
		-- End: Align the player_buff mod if appropriate

		-- Begin: Are we showing combat text?
		if (portraitcombattext == 1) then
			Perl_Player_PortraitTextFrame:Show();
		else
			Perl_Player_PortraitTextFrame:Hide();
		end
		-- End: Are we showing combat text?

		-- Begin: Are we in a raid and suppossed to be hidden?
		Perl_Player_Check_Hidden();
		-- End: Are we in a raid and suppossed to be hidden?

		-- Update text for these bars
		Perl_Player_Update_Health();
		Perl_Player_Update_Mana();

		-- Hi-jack the Blizzard totem frame
		if (totemtimers == 1) then
			TotemFrame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 0, 0);
		else
			TotemFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -10000, -10000);
		end

		-- Hi-jack the Blizzard rune frame
		if (runeframe == 1) then
			RuneFrame:SetPoint("TOPLEFT", Perl_Player_StatsFrame, "BOTTOMLEFT", 20, -2);
		else
			RuneFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -10000, -10000);
		end

		-- Update the five second rule
		Perl_Player_FiveSecondRule:SetWidth(Perl_Player_ManaBar:GetWidth());

		Perl_Player_NameBarText:SetWidth(Perl_Player_Name:GetWidth() - 40);
		Perl_Player_NameBarText:SetHeight(Perl_Player_Name:GetHeight() - 10);
		Perl_Player_NameBarText:SetNonSpaceWrap(false);

		if (Initialized) then
			if (Perl_ArcaneBar_Frame_Loaded_Frame) then
				Perl_ArcaneBar_player:SetPoint("TOPLEFT", "Perl_Player_NameFrame", "TOPLEFT", 5, -5);
				Perl_ArcaneBar_player_CastTime:ClearAllPoints();
				if (Perl_ArcaneBar_Config[UnitName("player")]["PlayerLeftTimer"] == 0) then
					Perl_ArcaneBar_player_CastTime:SetPoint("LEFT", "Perl_Player_NameFrame", "RIGHT", 0, 0);
				else
					if (showportrait == 1) then
						Perl_ArcaneBar_player_CastTime:SetPoint("RIGHT", "Perl_Player_PortraitFrame", "LEFT", 0, 0);
					else
						Perl_ArcaneBar_player_CastTime:SetPoint("RIGHT", "Perl_Player_NameFrame", "LEFT", 0, 0);
					end
				end

				Perl_ArcaneBar_player:SetWidth(Perl_Player_NameFrame:GetWidth() - 10);
				Perl_ArcaneBar_player_Flash:SetWidth(Perl_Player_NameFrame:GetWidth() + 5);
				Perl_ArcaneBar_Set_Spark_Width(Perl_Player_NameFrame:GetWidth(), nil, nil, nil);
			end
		end
	end
end

function Perl_Player_Check_Hidden()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Check_Hidden);
	else
		if (hiddeninraid == 1) then
			if (UnitInRaid("player")) then
				Perl_Player_Frame:Hide();
			else
				Perl_Player_Frame:Show();
			end
		else
			Perl_Player_Frame:Show();
		end
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Player_XPBar_Display(newvalue)
	xpbarstate = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_DruidBar(newvalue)
	showdruidbar = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Compact(newvalue)
	compactmode = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Healer(newvalue)
	healermode = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_RaidGroupNumber(newvalue)
	showraidgroup = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Raid_Group_Number();
end

function Perl_Player_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Player_UpdateVars();
end

function Perl_Player_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
	Perl_Player_Update_Portrait();
end

function Perl_Player_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
	Perl_Player_Update_Portrait();
end

function Perl_Player_Set_Portrait_Combat_Text(newvalue)
	portraitcombattext = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Compact_Percent(newvalue)
	compactpercent = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Short_Bars(newvalue)
	shortbars = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_PvP_Status();
end

function Perl_Player_Set_Hide_Class_Level_Frame(newvalue)
	hideclasslevelframe = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Mana_Deficit(newvalue)
	showmanadeficit = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Mana();
end

function Perl_Player_Set_Hidden_In_Raids(newvalue)
	hiddeninraid = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Check_Hidden();
end

function Perl_Player_Set_PvP_Icon(newvalue)
	showpvpicon =  newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_PvP_Status();
end

function Perl_Player_Set_Show_Bar_Values(newvalue)
	showbarvalues = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Health();
	Perl_Player_Update_Mana();
end

function Perl_Player_Set_Show_Raid_Group_In_Name(newvalue)
	showraidgroupinname = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_Raid_Group_Number();
end

function Perl_Player_Set_Show_Five_second_Rule(newvalue)
	fivesecondrule = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Show_Totem_Timers(newvalue)
	totemtimers = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Show_Rune_Frame(newvalue)
	runeframe = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Frame_Style();
end

function Perl_Player_Set_Show_PvP_Timer(newvalue)
	pvptimer = newvalue;
	Perl_Player_UpdateVars();
	Perl_Player_Update_PvP_Timer();
end

function Perl_Player_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);							-- convert the user input to a wow acceptable value
	end
	Perl_Player_UpdateVars();
	Perl_Player_Set_Scale_Actual();
end

function Perl_Player_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Player_Set_Scale_Actual);
	else
		Perl_Player_Frame:SetScale(1 - UIParent:GetEffectiveScale() + scale);	-- run it through the scaling formula introduced in 1.9
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			Perl_ArcaneBar_Set_Scale_Actual(scale, nil, nil, nil);
		end
	end
end

function Perl_Player_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);						-- convert the user input to a wow acceptable value
	end
	Perl_Player_UpdateVars();
	Perl_Player_Frame:SetAlpha(transparency);
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Player_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Player_Config[name]["Locked"];
	xpbarstate = Perl_Player_Config[name]["XPBarState"];
	compactmode = Perl_Player_Config[name]["CompactMode"];
	showraidgroup = Perl_Player_Config[name]["ShowRaidGroup"];
	scale = Perl_Player_Config[name]["Scale"];
	healermode = Perl_Player_Config[name]["HealerMode"];
	transparency = Perl_Player_Config[name]["Transparency"];
	showportrait = Perl_Player_Config[name]["ShowPortrait"];
	compactpercent = Perl_Player_Config[name]["CompactPercent"];
	threedportrait = Perl_Player_Config[name]["ThreeDPortrait"];
	portraitcombattext = Perl_Player_Config[name]["PortraitCombatText"];
	showdruidbar = Perl_Player_Config[name]["ShowDruidBar"];
	shortbars = Perl_Player_Config[name]["ShortBars"];
	classcolorednames = Perl_Player_Config[name]["ClassColoredNames"];
	hideclasslevelframe = Perl_Player_Config[name]["HideClassLevelFrame"];
	showmanadeficit = Perl_Player_Config[name]["ShowManaDeficit"];
	hiddeninraid = Perl_Player_Config[name]["HiddenInRaid"];
	showpvpicon = Perl_Player_Config[name]["ShowPvPIcon"];
	showbarvalues = Perl_Player_Config[name]["ShowBarValues"];
	showraidgroupinname = Perl_Player_Config[name]["ShowRaidGroupInName"];
	fivesecondrule = Perl_Player_Config[name]["FiveSecondRule"];
	totemtimers = Perl_Player_Config[name]["TotemTimers"];
	runeframe = Perl_Player_Config[name]["RuneFrame"];
	pvptimer = Perl_Player_Config[name]["PvPTimer"];

	if (locked == nil) then
		locked = 0;
	end
	if (xpbarstate == nil) then
		xpbarstate = 1;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (showraidgroup == nil) then
		showraidgroup = 1;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (healermode == nil) then
		healermode = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (showportrait == nil) then
		showportrait = 0;
	end
	if (compactpercent == nil) then
		compactpercent = 0;
	end
	if (threedportrait == nil) then
		threedportrait = 0;
	end
	if (portraitcombattext == nil) then
		portraitcombattext = 0;
	end
	if (showdruidbar == nil) then
		showdruidbar = 0;
	end
	if (shortbars == nil) then
		shortbars = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (hideclasslevelframe == nil) then
		hideclasslevelframe = 0;
	end
	if (showmanadeficit == nil) then
		showmanadeficit = 0;
	end
	if (hiddeninraid == nil) then
		hiddeninraid = 0;
	end
	if (showpvpicon == nil) then
		showpvpicon = 1;
	end
	if (showbarvalues == nil) then
		showbarvalues = 0;
	end
	if (showraidgroupinname == nil) then
		showraidgroupinname = 0;
	end
	if (fivesecondrule == nil) then
		fivesecondrule = 0;
	end
	if (totemtimers == nil) then
		totemtimers = 1;
	end
	if (runeframe == nil) then
		runeframe = 1;
	end
	if (pvptimer == nil) then
		pvptimer = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Player_UpdateVars();

		-- Call any code we need to activate them
		Perl_Player_Update_Once();
		Perl_Player_Set_Scale_Actual();
		Perl_Player_Set_Transparency();
		return;
	end

	local vars = {
		["locked"] = locked,
		["xpbarstate"] = xpbarstate,
		["compactmode"] = compactmode,
		["showraidgroup"] = showraidgroup,
		["scale"] = scale,
		["healermode"] = healermode,
		["transparency"] = transparency,
		["showportrait"] = showportrait,
		["compactpercent"] = compactpercent,
		["threedportrait"] = threedportrait,
		["portraitcombattext"] = portraitcombattext,
		["showdruidbar"] = showdruidbar,
		["shortbars"] = shortbars,
		["classcolorednames"] = classcolorednames,
		["hideclasslevelframe"] = hideclasslevelframe,
		["showmanadeficit"] = showmanadeficit,
		["hiddeninraid"] = hiddeninraid,
		["showpvpicon"] = showpvpicon,
		["showbarvalues"] = showbarvalues,
		["showraidgroupinname"] = showraidgroupinname,
		["fivesecondrule"] = fivesecondrule,
		["totemtimers"] = totemtimers,
		["runeframe"] = runeframe,
		["pvptimer"] = pvptimer,
	}
	return vars;
end

function Perl_Player_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["XPBarState"] ~= nil) then
				xpbarstate = vartable["Global Settings"]["XPBarState"];
			else
				xpbarstate = nil;
			end
			if (vartable["Global Settings"]["CompactMode"] ~= nil) then
				compactmode = vartable["Global Settings"]["CompactMode"];
			else
				compactmode = nil;
			end
			if (vartable["Global Settings"]["ShowRaidGroup"] ~= nil) then
				showraidgroup = vartable["Global Settings"]["ShowRaidGroup"];
			else
				showraidgroup = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["HealerMode"] ~= nil) then
				healermode = vartable["Global Settings"]["HealerMode"];
			else
				healermode = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["ShowPortrait"] ~= nil) then
				showportrait = vartable["Global Settings"]["ShowPortrait"];
			else
				showportrait = nil;
			end
			if (vartable["Global Settings"]["CompactPercent"] ~= nil) then
				compactpercent = vartable["Global Settings"]["CompactPercent"];
			else
				compactpercent = nil;
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
			if (vartable["Global Settings"]["ShowDruidBar"] ~= nil) then
				showdruidbar = vartable["Global Settings"]["ShowDruidBar"];
			else
				showdruidbar = nil;
			end
			if (vartable["Global Settings"]["ShortBars"] ~= nil) then
				shortbars = vartable["Global Settings"]["ShortBars"];
			else
				shortbars = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["HideClassLevelFrame"] ~= nil) then
				hideclasslevelframe = vartable["Global Settings"]["HideClassLevelFrame"];
			else
				hideclasslevelframe = nil;
			end
			if (vartable["Global Settings"]["ShowManaDeficit"] ~= nil) then
				showmanadeficit = vartable["Global Settings"]["ShowManaDeficit"];
			else
				showmanadeficit = nil;
			end
			if (vartable["Global Settings"]["HiddenInRaid"] ~= nil) then
				hiddeninraid = vartable["Global Settings"]["HiddenInRaid"];
			else
				hiddeninraid = nil;
			end
			if (vartable["Global Settings"]["ShowPvPIcon"] ~= nil) then
				showpvpicon = vartable["Global Settings"]["ShowPvPIcon"];
			else
				showpvpicon = nil;
			end
			if (vartable["Global Settings"]["ShowBarValues"] ~= nil) then
				showbarvalues = vartable["Global Settings"]["ShowBarValues"];
			else
				showbarvalues = nil;
			end
			if (vartable["Global Settings"]["ShowRaidGroupInName"] ~= nil) then
				showraidgroupinname = vartable["Global Settings"]["ShowRaidGroupInName"];
			else
				showraidgroupinname = nil;
			end
			if (vartable["Global Settings"]["FiveSecondRule"] ~= nil) then
				fivesecondrule = vartable["Global Settings"]["FiveSecondRule"];
			else
				fivesecondrule = nil;
			end
			if (vartable["Global Settings"]["TotemTimers"] ~= nil) then
				totemtimers = vartable["Global Settings"]["TotemTimers"];
			else
				totemtimers = nil;
			end
			if (vartable["Global Settings"]["RuneFrame"] ~= nil) then
				runeframe = vartable["Global Settings"]["RuneFrame"];
			else
				runeframe = nil;
			end
			if (vartable["Global Settings"]["PvPTimer"] ~= nil) then
				pvptimer = vartable["Global Settings"]["PvPTimer"];
			else
				pvptimer = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (xpbarstate == nil) then
			xpbarstate = 1;
		end
		if (compactmode == nil) then
			compactmode = 0;
		end
		if (showraidgroup == nil) then
			showraidgroup = 1;
		end
		if (scale == nil) then
			scale = 0.9;
		end
		if (healermode == nil) then
			healermode = 0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (showportrait == nil) then
			showportrait = 0;
		end
		if (compactpercent == nil) then
			compactpercent = 0;
		end
		if (threedportrait == nil) then
			threedportrait = 0;
		end
		if (portraitcombattext == nil) then
			portraitcombattext = 0;
		end
		if (showdruidbar == nil) then
			showdruidbar = 0;
		end
		if (shortbars == nil) then
			shortbars = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (hideclasslevelframe == nil) then
			hideclasslevelframe = 0;
		end
		if (showmanadeficit == nil) then
			showmanadeficit = 0;
		end
		if (hiddeninraid == nil) then
			hiddeninraid = 0;
		end
		if (showpvpicon == nil) then
			showpvpicon = 1;
		end
		if (showbarvalues == nil) then
			showbarvalues = 0;
		end
		if (showraidgroupinname == nil) then
			showraidgroupinname = 0;
		end
		if (fivesecondrule == nil) then
			fivesecondrule = 0;
		end
		if (totemtimers == nil) then
			totemtimers = 1;
		end
		if (runeframe == nil) then
			runeframe = 1;
		end
		if (pvptimer == nil) then
			pvptimer = 0;
		end

		-- Call any code we need to activate them
		Perl_Player_Update_Once();
		Perl_Player_Set_Scale_Actual();
		Perl_Player_Set_Transparency();
	end

	Perl_Player_Config[UnitName("player")] = {
		["Locked"] = locked,
		["XPBarState"] = xpbarstate,
		["CompactMode"] = compactmode,
		["ShowRaidGroup"] = showraidgroup,
		["Scale"] = scale,
		["HealerMode"] = healermode,
		["Transparency"] = transparency,
		["ShowPortrait"] = showportrait,
		["CompactPercent"] = compactpercent,
		["ThreeDPortrait"] = threedportrait,
		["PortraitCombatText"] = portraitcombattext,
		["ShowDruidBar"] = showdruidbar,
		["ShortBars"] = shortbars,
		["ClassColoredNames"] = classcolorednames,
		["HideClassLevelFrame"] = hideclasslevelframe,
		["ShowManaDeficit"] = showmanadeficit,
		["HiddenInRaid"] = hiddeninraid,
		["ShowPvPIcon"] = showpvpicon,
		["ShowBarValues"] = showbarvalues,
		["ShowRaidGroupInName"] = showraidgroupinname,
		["FiveSecondRule"] = fivesecondrule,
		["TotemTimers"] = totemtimers,
		["RuneFrame"] = runeframe,
		["PvPTimer"] = pvptimer,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Player_BuffUpdateAll()
	local color, debuffType;
	local curableDebuffFound = 0;

	for debuffnum=1,20 do											-- Start main debuff loop
		_, _, _, _, debuffType, _, _ = UnitDebuff("player", debuffnum, 1);		-- Get the texture and debuff stacking information if any
			if (debuffType) then
				if (PCUF_COLORFRAMEDEBUFF == 1) then
					if (curableDebuffFound == 0) then
						if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
							color = DebuffTypeColor[debuffType];
							Perl_Player_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							Perl_Player_RaidGroupNumberFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							Perl_Player_LevelFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							Perl_Player_PortraitFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							Perl_Player_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							curableDebuffFound = 1;
							break;
						end
					end
				end
			end
	end

	if (curableDebuffFound == 0) then
		Perl_Player_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Player_RaidGroupNumberFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Player_LevelFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Player_PortraitFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Player_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Player_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_Player_DropDown, "Perl_Player_NameFrame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "player", showmenu);

	self:SetAttribute("unit", "player");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_PlayerDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_PlayerDropDown_Initialize, "MENU");
end

function Perl_PlayerDropDown_Initialize()
	UnitPopup_ShowMenu(Perl_Player_DropDown, "SELF", "player");
end

function Perl_Player_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Player_Frame:StartMoving();
	end
end

function Perl_Player_DragStop(button)
	Perl_Player_Frame:StopMovingOrSizing();
end


------------------------
-- Experience Tooltip --
------------------------
function Perl_Player_XPTooltip(self)
	local playerxp, playerxpmax, xptext
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	if (xpbarstate == 1) then
		local playerlevel = UnitLevel("player");			-- Player's next level
		if (playerlevel < 80) then
			playerxp = UnitXP("player");				-- Player's current XP
			playerxpmax = UnitXPMax("player");			-- Experience for the current level
			local playerxprest = GetXPExhaustion();			-- Amount of bonus xp we have
			local xptolevel = playerxpmax - playerxp		-- XP till level

			if (playerxprest) then
				xptext = playerxp.."/"..playerxpmax .." (+"..(playerxprest)..")";	-- Create the experience string w/ rest xp
			else
				xptext = playerxp.."/"..playerxpmax;		-- Create the experience string w/ no rest xp
			end

			GameTooltip:SetText(xptext, 255/255, 209/255, 0/255);
			if (GetLocale() == "deDE") then
				GameTooltip:AddLine(xptolevel.." ("..floor((playerxpmax-playerxp)/playerxpmax*100+0.5).."%) bis Level "..(playerlevel + 1), 255/255, 209/255, 0/255);
			elseif (GetLocale() == "koKR") then
				GameTooltip:AddLine((playerlevel + 1).." 레벨 까지 "..xptolevel.." ("..floor((playerxpmax-playerxp)/playerxpmax*100+0.5).."%) 남음", 255/255, 209/255, 0/255);
			elseif (GetLocale() == "zhCN") then
				GameTooltip:AddLine("还有"..xptolevel.." ("..floor((playerxpmax-playerxp)/playerxpmax*100+0.5).."%) 才能到达级别 "..(playerlevel + 1), 255/255, 209/255, 0/255);
			else
				GameTooltip:AddLine(xptolevel.." ("..floor((playerxpmax-playerxp)/playerxpmax*100+0.5).."%) until level "..(playerlevel + 1), 255/255, 209/255, 0/255);
			end
		else
			GameTooltip:SetText(PERL_LOCALIZED_PLAYER_NOMORE_EXPERIENCE, 255/255, 209/255, 0/255);
		end
		
	elseif (xpbarstate == 2) then
		local rankNumber, rankName, rankProgress;			-- Some variables
		rankNumber = UnitPVPRank("player")
		if (rankNumber < 1) then
			rankName = "Unranked"
			GameTooltip:SetText(PERL_LOCALIZED_PLAYER_UNRANKED, 255/255, 209/255, 0/255);
		else
			rankName = GetPVPRankInfo(rankNumber, "player");
			rankProgress = floor(GetPVPRankProgress() * 100);
			if (GetLocale() == "deDE") then
				GameTooltip:SetText(rankProgress.."% in Rang "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
			elseif (GetLocale() == "koKR") then
				GameTooltip:SetText((rankNumber - 4).."등급 ("..rankName..")의 "..rankProgress.."% 입니다", 255/255, 209/255, 0/255);
			elseif (GetLocale() == "zhCN") then
				GameTooltip:SetText(rankProgress.."% 处于荣誉 "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
			else
				GameTooltip:SetText(rankProgress.."% into Rank "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
			end
			if (rankNumber < 18) then
				rankNumber = rankNumber + 1;
				rankName = GetPVPRankInfo(rankNumber, "player");
				if (GetLocale() == "deDE") then
					GameTooltip:AddLine((100 - rankProgress).."% bis Rang "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
				elseif (GetLocale() == "koKR") then
					GameTooltip:AddLine((rankNumber - 4).."등급 ("..rankName..")까지 "..(100 - rankProgress).."% 남음", 255/255, 209/255, 0/255);
				elseif (GetLocale() == "zhCN") then
					GameTooltip:AddLine("还有"..(100 - rankProgress).."% 将达到荣誉 "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
				else
					GameTooltip:AddLine((100 - rankProgress).."% until Rank "..(rankNumber - 4).." ("..rankName..")", 255/255, 209/255, 0/255);
				end
			end
		end
	elseif (xpbarstate == 4) then
		local name, reaction, min, max, value = GetWatchedFactionInfo();
		if (name) then
			value = value - min;
			max = max - min;
			min = 0;
			if (FFF_HandlerFrame) then
				FFF_ReputationTick_Tooltip();
				GameTooltip:AddLine(" ", 255/255, 255/255, 255/255);
			else
				GameTooltip:SetText(name, 255/255, 209/255, 0/255);
			end
			if (GetLocale() == "koKR") then
				GameTooltip:AddLine(Perl_Player_Get_Reaction_Name(reaction).."의 "..floor(value/max*100+0.5).."%", 255/255, 209/255, 0/255);
			elseif (GetLocale() == "zhCN") then
				GameTooltip:AddLine(Perl_Player_Get_Reaction_Name( reaction).."进度 "..floor(value/max*100+0.5).."%", 255/255, 209/255, 0/255);
			else
				GameTooltip:AddLine(floor(value/max*100+0.5).."% into "..Perl_Player_Get_Reaction_Name(reaction), 255/255, 209/255, 0/255);
			end
			GameTooltip:AddLine(value.."/"..max, 255/255, 209/255, 0/255);
			if (reaction ~= 8) then
				if (GetLocale() == "koKR") then
					GameTooltip:AddLine(Perl_Player_Get_Reaction_Name(reaction + 1).."까지 "..(max - value).." 남음", 255/255, 209/255, 0/255);
				elseif (GetLocale() == "zhCN") then
					GameTooltip:AddLine("还有"..(max - value).." 到达 "..Perl_Player_Get_Reaction_Name(reaction + 1), 255/255, 209/255, 0/255);
				else
					GameTooltip:AddLine((max - value).." until "..Perl_Player_Get_Reaction_Name(reaction + 1), 255/255, 209/255, 0/255);
				end
			end
		else
			GameTooltip:SetText(PERL_LOCALIZED_PLAYER_NO_REPUTATION, 255/255, 209/255, 0/255);
		end
	end
	GameTooltip:Show();
end

function Perl_Player_Get_Reaction_Name(reaction)
	local reactionname;
	if (reaction == 1) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_ONE;
	elseif (reaction == 2) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_TWO;
	elseif (reaction == 3) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_THREE;
	elseif (reaction == 4) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_FOUR;
	elseif (reaction == 5) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_FIVE;
	elseif (reaction == 6) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_SIX;
	elseif (reaction == 7) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_SEVEN;
	elseif (reaction == 8) then
		reactionname = PERL_LOCALIZED_PLAYER_REACTIONNAME_EIGHT;
	end
	return reactionname;
end


-----------------------
-- Scripting Support --
-----------------------
function Perl_Player_InCombat()
	if (InCombat == 1) then
		return 1;
	else
		return nil;
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Player_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Player_myAddOns_Details = {
			name = "Perl_Player",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Player_myAddOns_Help = {};
		Perl_Player_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Player_myAddOns_Details, Perl_Player_myAddOns_Help);
	end
end
