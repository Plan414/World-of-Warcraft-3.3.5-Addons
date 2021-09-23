---------------
-- Variables --
---------------
Perl_Target_Target_Config = {};
local Perl_Target_Target_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Target_Target_GetVars)
local locked = 0;		-- unlocked by default
local scale = 0.9;		-- default scale
local totsupport = 1;		-- target of target support enabled by default
local tototsupport = 1;		-- target of target of target support enabled by default
local transparency = 1;		-- transparency for frames
local alertsound = 0;		-- audible alert disabled by default
local alertmode = 0;		-- DPS, Tank, Healer modes
local alertsize = 0;		-- Variable which controls the size of the text
local showtotbuffs = 0;		-- ToT buffs are off by default
local showtototbuffs = 0;	-- ToToT buffs are off by default
local hidepowerbars = 0;	-- Power bars are shown by default
local showtotdebuffs = 0;	-- ToT debuffs are off by default
local showtototdebuffs = 0;	-- ToToT debuffs are off by default
local displaycastablebuffs = 0;	-- display all buffs by default
local classcolorednames = 0;	-- names are colored based on pvp status by default
local showfriendlyhealth = 0;	-- show numerical friendly health is disbaled by default
local displaycurabledebuff = 0;	-- display all debuffs by default
local displayonlymydebuffs = 0;	-- display all debuffs by default

-- Default Local Variables
local Initialized = nil;				-- waiting to be initialized
local Perl_Target_Target_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Target_Target_Time_Update_Rate = 0.2;	-- the update interval
local aggroWarningCount = 0;				-- the check to see if we have alerted the player of a ToT event
local aggroToToTWarningCount = 0;			-- the check to see if we have alerted the player of a ToToT event
local startTime = 0;					-- used to keep track of fading the big alert text
local mouseovertargettargethealthflag = 0;		-- is the mouse over the health bar for healer mode?
local mouseovertargettargetmanaflag = 0;		-- is the mouse over the mana bar for healer mode?
local mouseovertargettargettargethealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovertargettargettargetmanaflag = 0;		-- is the mouse over the mana bar for healer mode?

-- Fade Bar Variables
local Perl_Target_Target_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Target_Target_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Target_Target_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Target_Target_ManaBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_Target_Target_Target_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Target_Target_Target_ManaBar_Fade_Color = 1;			-- the color fading interval
local Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0

-- Local variables to save memory
-- ToT variables
local targettargethealth, targettargethealthmax, targettargethealthpercent, targettargetmana, targettargetmanamax, targettargetpower, raidtargettargetindex, targettargetbufffilter, targettargetdebufffilter;

-- ToToT variables
local targettargettargethealth, targettargettargethealthmax, targettargettargethealthpercent, targettargettargetmana, targettargettargetmanamax, targettargettargetpower, raidtargettargettargetindex, targettargettargetbufffilter, targettargettargetdebufffilter;

-- Shared
local r, g, b, reaction, englishclass;

----------------------
-- Loading Function --
----------------------
function Perl_Target_Target_OnLoad(self)
	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");

	-- Scripts
	self:SetScript("OnEvent", Perl_Target_Target_OnEvent);
	self:SetScript("OnUpdate", Perl_Target_Target_OnUpdate);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_Target_Target_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Target_Target_NameFrame:GetFrameLevel() + 1);
	Perl_Target_Target_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Target_Target_StatsFrame:GetFrameLevel() + 1);
	Perl_Target_Target_HealthBar_CastClickOverlay:SetFrameLevel(Perl_Target_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Target_Target_ManaBar_CastClickOverlay:SetFrameLevel(Perl_Target_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Target_Target_RaidIconFrame:SetFrameLevel(Perl_Target_Target_NameFrame_CastClickOverlay:GetFrameLevel() - 1);
	Perl_Target_Target_Target_NameFrame_CastClickOverlay:SetFrameLevel(Perl_Target_Target_Target_NameFrame:GetFrameLevel() + 1);
	Perl_Target_Target_Target_StatsFrame_CastClickOverlay:SetFrameLevel(Perl_Target_Target_Target_StatsFrame:GetFrameLevel() + 1);
	Perl_Target_Target_Target_HealthBar_CastClickOverlay:SetFrameLevel(Perl_Target_Target_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Target_Target_Target_ManaBar_CastClickOverlay:SetFrameLevel(Perl_Target_Target_Target_StatsFrame:GetFrameLevel() + 2);
	Perl_Target_Target_HealthBarFadeBar:SetFrameLevel(Perl_Target_Target_HealthBar:GetFrameLevel() - 1);
	Perl_Target_Target_ManaBarFadeBar:SetFrameLevel(Perl_Target_Target_ManaBar:GetFrameLevel() - 1);
	Perl_Target_Target_Target_HealthBarFadeBar:SetFrameLevel(Perl_Target_Target_Target_HealthBar:GetFrameLevel() - 1);
	Perl_Target_Target_Target_ManaBarFadeBar:SetFrameLevel(Perl_Target_Target_Target_ManaBar:GetFrameLevel() - 1);
end


-------------------
-- Event Handler --
-------------------
function Perl_Target_Target_OnEvent()
	local func = Perl_Target_Target_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Target of Target: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Target_Target_Events:PLAYER_TARGET_CHANGED()
	aggroWarningCount = 0;
end
Perl_Target_Target_Events.PLAYER_REGEN_ENABLED = Perl_Target_Target_Events.PLAYER_TARGET_CHANGED;

function Perl_Target_Target_Events:PLAYER_LOGIN()
	Perl_Target_Target_Initialize();
end
Perl_Target_Target_Events.PLAYER_ENTERING_WORLD = Perl_Target_Target_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Target_Target_Initialize()
	if (Initialized) then
		Perl_Target_Target_Set_Scale_Actual();		-- Set the scale
		Perl_Target_Target_Set_Transparency();	-- Set the transparency
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Target_Target_Config[UnitName("player")]) == "table") then
		Perl_Target_Target_GetVars();
	else
		Perl_Target_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Target_Target_Initialize_Frame_Color();
	Perl_Target_Target_Frame_Style();
	Perl_Target_Target_Reset_Buffs();
	Perl_Target_Target_Target_Reset_Buffs();

	-- MyAddOns Support
	Perl_Target_Target_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_Target_Target_Frame:SetUserPlaced(1);
	Perl_Target_Target_Target_Frame:SetUserPlaced(1);

	Initialized = 1;
end

function Perl_Target_Target_Initialize_Frame_Color()
	Perl_Target_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_Target_ManaBarText:SetTextColor(1, 1, 1, 1);

	Perl_Target_Target_Target_StatsFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_Target_NameFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_Target_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_Target_Target_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_Target_Target_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


--------------------------
-- The Update Functions --
--------------------------
function Perl_Target_Target_OnUpdate()
	Perl_Target_Target_Time_Elapsed = Perl_Target_Target_Time_Elapsed + arg1;
	if (Perl_Target_Target_Time_Elapsed > Perl_Target_Target_Time_Update_Rate) then
		Perl_Target_Target_Time_Elapsed = 0;

		if (UnitExists(Perl_Target_Target_Frame:GetAttribute("unit"))) then
			Perl_Target_Target_Warn();				-- Display any warnings if needed

			-- Begin: Set the name
			Perl_Target_Target_NameBarText:SetText(UnitName("targettarget"));
			-- End: Set the name

			-- Begin: Set the name text color
			if (UnitPlayerControlled("targettarget")) then		-- is it a player
				if (UnitCanAttack("targettarget", "player")) then				-- are we in an enemy controlled zone
					-- Hostile players are red
					if (not UnitCanAttack("player", "targettarget")) then			-- enemy is not pvp enabled
						r = 0.5;
						g = 0.5;
						b = 1.0;
					else									-- enemy is pvp enabled
						r = 1.0;
						g = 0.0;
						b = 0.0;
					end
				elseif (UnitCanAttack("player", "targettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
					-- Players we can attack but which are not hostile are yellow
					r = 1.0;
					g = 1.0;
					b = 0.0;
				elseif (UnitIsPVP("targettarget") and not UnitIsPVPSanctuary("targettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
				Perl_Target_Target_NameBarText:SetTextColor(r, g, b);
			elseif (UnitIsTapped("targettarget") and not UnitIsTappedByPlayer("targettarget")) then
				Perl_Target_Target_NameBarText:SetTextColor(0.5,0.5,0.5);			-- not our tap
			else
				if (UnitIsVisible("targettarget")) then
					reaction = UnitReaction("targettarget", "player");
					if (reaction) then
						r = FACTION_BAR_COLORS[reaction].r;
						g = FACTION_BAR_COLORS[reaction].g;
						b = FACTION_BAR_COLORS[reaction].b;
						Perl_Target_Target_NameBarText:SetTextColor(r, g, b);
					else
						Perl_Target_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
					end
				else
					if (UnitCanAttack("targettarget", "player")) then				-- are we in an enemy controlled zone
						-- Hostile players are red
						if (not UnitCanAttack("player", "targettarget")) then			-- enemy is not pvp enabled
							r = 0.5;
							g = 0.5;
							b = 1.0;
						else									-- enemy is pvp enabled
							r = 1.0;
							g = 0.0;
							b = 0.0;
						end
					elseif (UnitCanAttack("player", "targettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
						-- Players we can attack but which are not hostile are yellow
						r = 1.0;
						g = 1.0;
						b = 0.0;
					elseif (UnitIsPVP("targettarget") and not UnitIsPVPSanctuary("targettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
					Perl_Target_Target_NameBarText:SetTextColor(r, g, b);
				end
			end

			if (classcolorednames == 1) then
				if (UnitIsPlayer("targettarget")) then
					_, englishclass = UnitClass("targettarget");
					Perl_Target_Target_NameBarText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
				end
			end
			-- End: Set the name text color

			-- Begin: Update the health bar
			targettargethealth = UnitHealth("targettarget");
			targettargethealthmax = UnitHealthMax("targettarget");
			targettargethealthpercent = floor(targettargethealth/targettargethealthmax*100+0.5);

			if (UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then				-- This prevents negative health
				targettargethealth = 0;
				targettargethealthpercent = 0;
			end

			Perl_Target_Target_HealthBar_Fade_Check();

			Perl_Target_Target_HealthBar:SetMinMaxValues(0, targettargethealthmax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Target_Target_HealthBar:SetValue(targettargethealthmax - targettargethealth);
			else
				Perl_Target_Target_HealthBar:SetValue(targettargethealth);
			end

			if (PCUF_COLORHEALTH == 1) then
--				if ((targettargethealthpercent <= 100) and (targettargethealthpercent > 75)) then
--					Perl_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--					Perl_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--				elseif ((targettargethealthpercent <= 75) and (targettargethealthpercent > 50)) then
--					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--				elseif ((targettargethealthpercent <= 50) and (targettargethealthpercent > 25)) then
--					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--				else
--					Perl_Target_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--					Perl_Target_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--				end

				local rawpercent = targettargethealth / targettargethealthmax;
				local red, green;

				if(rawpercent > 0.5) then
					red = (1.0 - rawpercent) * 2;
					green = 1.0;
				else
					red = 1.0;
					green = rawpercent * 2;
				end

				Perl_Target_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
				Perl_Target_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
			else
				Perl_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
				Perl_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			end

			if (mouseovertargettargethealthflag == 1) then
				Perl_Target_Target_HealthShow();
			else
				if (showfriendlyhealth == 1) then
					if (targettargethealthmax == 100) then
						Perl_Target_Target_HealthBarText:SetText(targettargethealthpercent.."%");
					else
						Perl_Target_Target_HealthBarText:SetText(targettargethealth.."/"..targettargethealthmax);
					end
				else
					Perl_Target_Target_HealthBarText:SetText(targettargethealthpercent.."%");
				end
			end
			-- End: Update the health bar

			if (hidepowerbars == 0) then
				-- Begin: Update the mana bar
				targettargetmana = UnitMana("targettarget");
				targettargetmanamax = UnitManaMax("targettarget");

				if (UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then				-- This prevents negative mana
					targettargetmana = 0;
				end

				Perl_Target_Target_ManaBar_Fade_Check();

				Perl_Target_Target_ManaBar:SetMinMaxValues(0, targettargetmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_Target_Target_ManaBar:SetValue(targettargetmanamax - targettargetmana);
				else
					Perl_Target_Target_ManaBar:SetValue(targettargetmana);
				end

				if (mouseovertargettargetmanaflag == 1) then
					if (UnitPowerType("targettarget") == 1 or UnitPowerType("targettarget") == 2 or UnitPowerType("targettarget") == 6) then
						Perl_Target_Target_ManaBarText:SetText(targettargetmana);
					else
						Perl_Target_Target_ManaBarText:SetText(targettargetmana.."/"..targettargetmanamax);
					end
				else
					Perl_Target_Target_ManaBarText:Hide();
				end
				-- End: Update the mana bar

				-- Begin: Update the mana bar color
				targettargetpower = UnitPowerType("targettarget");

				-- Set mana bar color
				if (UnitManaMax("targettarget") == 0) then
					Perl_Target_Target_ManaBar:SetStatusBarColor(0, 0, 0, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 0, 0.25);
				elseif (targettargetpower == 1) then
					Perl_Target_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				elseif (targettargetpower == 2) then
					Perl_Target_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				elseif (targettargetpower == 3) then
					Perl_Target_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				elseif (targettargetpower == 6) then
					Perl_Target_Target_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
				else
					Perl_Target_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
					Perl_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
				end
				-- End: Update the mana bar color
			end

			-- Begin: Raid Icon
			Perl_Target_Target_Update_Raid_Icon();
			-- End: Raid Icon

			-- Begin: Update buffs and debuffs
			Perl_Target_Target_Update_Buffs();			-- Apparently too many nested if's make lua cry, slow function call MUST be done here to avoid errors.
			-- End: Update buffs and debuffs
		end

		if (UnitExists(Perl_Target_Target_Target_Frame:GetAttribute("unit"))) then

			if (UnitAffectingCombat("targettarget")) then
				if (UnitIsDead("targettargettarget") or UnitIsCorpse("targettargettarget")) then
					-- Im thinking targetting something that is targetting a corpse or dead thing is causing crashes
					-- Hence this safety check. If it is, we do nothing.
				else
					if (UnitName("targettargettarget")) then
						if (UnitIsEnemy("targettarget", "player")) then
							if (UnitName("targettargettarget") == UnitName("player")) then			-- play the warning sound if needed
								if (aggroWarningCount == 0 and aggroToToTWarningCount == 0) then
									-- Its coming right for us!
									aggroToToTWarningCount = 1;
									Perl_Target_Target_Play_Sound();
								end
							else
								-- Whew it isnt fighting us
								aggroToToTWarningCount = 0;
							end
						else
							-- Friendly target
							aggroToToTWarningCount = 0;
						end
					end
				end
			end

			-- Begin: Set the name
			Perl_Target_Target_Target_NameBarText:SetText(UnitName("targettargettarget"));
			-- End: Set the name

			-- Begin: Set the name text color
			if (UnitPlayerControlled("targettargettarget")) then	-- is it a player
				if (UnitCanAttack("targettargettarget", "player")) then					-- are we in an enemy controlled zone
					-- Hostile players are red
					if (not UnitCanAttack("player", "targettargettarget")) then			-- enemy is not pvp enabled
						r = 0.5;
						g = 0.5;
						b = 1.0;
					else										-- enemy is pvp enabled
						r = 1.0;
						g = 0.0;
						b = 0.0;
					end
				elseif (UnitCanAttack("player", "targettargettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
					-- Players we can attack but which are not hostile are yellow
					r = 1.0;
					g = 1.0;
					b = 0.0;
				elseif (UnitIsPVP("targettargettarget") and not UnitIsPVPSanctuary("targettargettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
					-- Players we can assist but are PvP flagged are green
					r = 0.0;
					g = 1.0;
					b = 0.0;
				else											-- friendly non pvp enabled character
					-- All other players are blue (the usual state on the "blue" server)
					r = 0.5;
					g = 0.5;
					b = 1.0;
				end
				Perl_Target_Target_Target_NameBarText:SetTextColor(r, g, b);
			elseif (UnitIsTapped("targettargettarget") and not UnitIsTappedByPlayer("targettargettarget")) then
				Perl_Target_Target_Target_NameBarText:SetTextColor(0.5,0.5,0.5);			-- not our tap
			else
				if (UnitIsVisible("targettargettarget")) then
					reaction = UnitReaction("targettargettarget", "player");
					if (reaction) then
						local r, g, b;
						r = FACTION_BAR_COLORS[reaction].r;
						g = FACTION_BAR_COLORS[reaction].g;
						b = FACTION_BAR_COLORS[reaction].b;
						Perl_Target_Target_Target_NameBarText:SetTextColor(r, g, b);
					else
						Perl_Target_Target_Target_NameBarText:SetTextColor(0.5, 0.5, 1.0);
					end
				else
					if (UnitCanAttack("targettargettarget", "player")) then					-- are we in an enemy controlled zone
						-- Hostile players are red
						if (not UnitCanAttack("player", "targettargettarget")) then			-- enemy is not pvp enabled
							r = 0.5;
							g = 0.5;
							b = 1.0;
						else										-- enemy is pvp enabled
							r = 1.0;
							g = 0.0;
							b = 0.0;
						end
					elseif (UnitCanAttack("player", "targettargettarget")) then				-- enemy in a zone controlled by friendlies or when we're a ghost
						-- Players we can attack but which are not hostile are yellow
						r = 1.0;
						g = 1.0;
						b = 0.0;
					elseif (UnitIsPVP("targettargettarget") and not UnitIsPVPSanctuary("targettargettarget") and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
						-- Players we can assist but are PvP flagged are green
						r = 0.0;
						g = 1.0;
						b = 0.0;
					else											-- friendly non pvp enabled character
						-- All other players are blue (the usual state on the "blue" server)
						r = 0.5;
						g = 0.5;
						b = 1.0;
					end
					Perl_Target_Target_Target_NameBarText:SetTextColor(r, g, b);
				end
			end

			if (classcolorednames == 1) then
				if (UnitIsPlayer("targettargettarget")) then
					_, englishclass = UnitClass("targettargettarget");
					Perl_Target_Target_Target_NameBarText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
				end
			end
			-- End: Set the name text color

			-- Begin: Update the health bar
			targettargettargethealth = UnitHealth("targettargettarget");
			targettargettargethealthmax = UnitHealthMax("targettargettarget");
			targettargettargethealthpercent = floor(targettargettargethealth/targettargettargethealthmax*100+0.5);

			if (UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then				-- This prevents negative health
				targettargettargethealth = 0;
				targettargettargethealthpercent = 0;
			end

			Perl_Target_Target_Target_HealthBar_Fade_Check();

			Perl_Target_Target_Target_HealthBar:SetMinMaxValues(0, targettargettargethealthmax);
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_Target_Target_Target_HealthBar:SetValue(targettargettargethealthmax - targettargettargethealth);
			else
				Perl_Target_Target_Target_HealthBar:SetValue(targettargettargethealth);
			end

			if (PCUF_COLORHEALTH == 1) then
--				if ((targettargettargethealthpercent <= 100) and (targettargettargethealthpercent > 75)) then
--					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--				elseif ((targettargettargethealthpercent <= 75) and (targettargettargethealthpercent > 50)) then
--					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--				elseif ((targettargettargethealthpercent <= 50) and (targettargettargethealthpercent > 25)) then
--					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--				else
--					Perl_Target_Target_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--					Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--				end

				local rawpercent = targettargettargethealth / targettargettargethealthmax;
				local red, green;

				if(rawpercent > 0.5) then
					red = (1.0 - rawpercent) * 2;
					green = 1.0;
				else
					red = 1.0;
					green = rawpercent * 2;
				end

				Perl_Target_Target_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
				Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
			else
				Perl_Target_Target_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
				Perl_Target_Target_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			end

			if (mouseovertargettargettargethealthflag == 1) then
				Perl_Target_Target_Target_HealthShow();
			else
				if (showfriendlyhealth == 1) then
					if (targettargettargethealthmax == 100) then
						Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealthpercent.."%");
					else
						Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."/"..targettargettargethealthmax);
					end
				else
					Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealthpercent.."%");
				end
			end
			-- End: Update the health bar

			if (hidepowerbars == 0) then
				-- Begin: Update the mana bar
				targettargettargetmana = UnitMana("targettargettarget");
				targettargettargetmanamax = UnitManaMax("targettargettarget");

				if (UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then				-- This prevents negative mana
					targettargettargetmana = 0;
				end

				Perl_Target_Target_Target_ManaBar_Fade_Check();

				Perl_Target_Target_Target_ManaBar:SetMinMaxValues(0, targettargettargetmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_Target_Target_Target_ManaBar:SetValue(targettargettargetmanamax - targettargettargetmana);
				else
					Perl_Target_Target_Target_ManaBar:SetValue(targettargettargetmana);
				end

				if (mouseovertargettargettargetmanaflag == 1) then
					if (UnitPowerType("targettargettarget") == 1 or UnitPowerType("targettargettarget") == 2 or UnitPowerType("targettargettarget") == 6) then
						Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana);
					else
						Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana.."/"..targettargettargetmanamax);
					end
				else
					Perl_Target_Target_Target_ManaBarText:Hide();
				end
				-- End: Update the mana bar

				-- Begin: Update the mana bar color
				targettargettargetpower = UnitPowerType("targettargettarget");

				-- Set mana bar color
				if (UnitManaMax("targettargettarget") == 0) then
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(0, 0, 0, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 0, 0.25);
				elseif (targettargettargetpower == 1) then
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
				elseif (targettargettargetpower == 2) then
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
				elseif (targettargettargetpower == 3) then
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
				elseif (targettargettargetpower == 6) then
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
				else
					Perl_Target_Target_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
					Perl_Target_Target_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
				end
				-- End: Update the mana bar color
			end

			-- Begin: Raid Icon
			Perl_Target_Target_Target_Update_Raid_Icon();
			-- End: Raid Icon

			-- Begin: Update buffs and debuffs
			Perl_Target_Target_Target_Update_Buffs();		-- Apparently too many nested if's make lua cry, slow function call MUST be done here to avoid errors.
			-- End: Update buffs and debuffs
		end

	end
end

function Perl_Target_Target_Update_Raid_Icon()
	raidtargettargetindex = GetRaidTargetIndex("targettarget");
	if (raidtargettargetindex) then
		SetRaidTargetIconTexture(Perl_Target_Target_RaidTargetIcon, raidtargettargetindex);
		Perl_Target_Target_RaidTargetIcon:Show();
	else
		Perl_Target_Target_RaidTargetIcon:Hide();
	end
end

function Perl_Target_Target_Target_Update_Raid_Icon()
	raidtargettargettargetindex = GetRaidTargetIndex("targettargettarget");
	if (raidtargettargettargetindex) then
		SetRaidTargetIconTexture(Perl_Target_Target_Target_RaidTargetIcon, raidtargettargettargetindex);
		Perl_Target_Target_Target_RaidTargetIcon:Show();
	else
		Perl_Target_Target_Target_RaidTargetIcon:Hide();
	end
end

function Perl_Target_Target_Update_Buffs()
	local button, buffCount, buffTexture, buffApplications, color, debuffType;							-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
	local curableDebuffFound = 0;

	local numBuffs = 0;														-- Buff counter for correct layout
	if (showtotbuffs == 1) then
		for buffnum=1,16 do													-- Start main buff loop
			if (displaycastablebuffs == 0) then								-- Which buff filter mode are we in?
				targettargetbufffilter = "HELPFUL";
			else
				targettargetbufffilter = "HELPFUL RAID";
			end
			_, _, buffTexture, buffApplications = UnitAura("targettarget", buffnum, targettargetbufffilter);	-- Get the texture and buff stacking information if any
			button = getglobal("Perl_Target_Target_BuffFrame_Buff"..buffnum);						-- Create the main icon for the buff
			if (buffTexture) then												-- If there is a valid texture, proceed with buff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);						-- Set the texture
				getglobal(button:GetName().."DebuffBorder"):Hide();							-- Hide the debuff border
				buffCount = getglobal(button:GetName().."Count");							-- Declare the buff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);								-- Set the text to the number of applications if greater than 0
					buffCount:Show();										-- Show the text
				else
					buffCount:Hide();										-- Hide the text if equal to 0
				end
				numBuffs = numBuffs + 1;										-- Increment the buff counter
				button:Show();												-- Show the final buff icon
			else
				button:Hide();												-- Hide the icon since there isn't a buff in this position
			end
		end															-- End main buff loop
	else
		numBuffs = 0;														-- ToT Buffs are disabled
	end

	local numDebuffs = 0;														-- Debuff counter for correct layout
	if (showtotdebuffs == 1) then
		for debuffnum=1,16 do													-- Start main debuff loop
			Perl_Target_Target_Debuff_Set_Filter();								-- Are we targeting a friend or enemy and which filter do we need to apply?
			_, _, buffTexture, buffApplications, debuffType = UnitAura("targettarget", debuffnum, targettargetdebufffilter);	-- Get the texture and debuff stacking information if any
			button = getglobal("Perl_Target_Target_BuffFrame_Debuff"..debuffnum);						-- Create the main icon for the debuff
			if (buffTexture) then												-- If there is a valid texture, proceed with debuff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);						-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (UnitIsFriend("player", "targettarget")) then
								if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
									Perl_Target_Target_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_Target_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									curableDebuffFound = 1;
								end
							end
						end
					end
				else
					color = DebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				getglobal(button:GetName().."DebuffBorder"):SetVertexColor(color.r, color.g, color.b);			-- Set the debuff border color
				getglobal(button:GetName().."DebuffBorder"):Show();							-- Show the debuff border
				buffCount = getglobal(button:GetName().."Count");							-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);								-- Set the text to the number of applications if greater than 0
					buffCount:Show();										-- Show the text
				else
					buffCount:Hide();										-- Hide the text if equal to 0
				end
				numDebuffs = numDebuffs + 1;										-- Increment the debuff counter
				button:Show();												-- Show the final debuff icon
			else
				button:Hide();												-- Hide the icon since there isn't a debuff in this position
			end
		end															-- End main debuff loop
	else
		numDebuffs = 0;														-- ToT Debuffs are disabled
	end

	if (UnitIsFriend("player", "targettarget")) then										-- Position the buffs according to friendly or enemy status
		if (numBuffs < 9) then
			if (showtotbuffs == 0) then
				Perl_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			else
				Perl_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
				Perl_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_BuffFrame_Buff1", "BOTTOMLEFT", 0, -1);
			end
		else
			Perl_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			Perl_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_BuffFrame_Buff9", "BOTTOMLEFT", 0, -1);
		end
	else
		if (numDebuffs < 9) then
			if (showtotdebuffs == 0) then
				Perl_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			else
				Perl_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
				Perl_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_BuffFrame_Debuff1", "BOTTOMLEFT", 0, -1);
			end
		else
			Perl_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			Perl_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_BuffFrame_Debuff9", "BOTTOMLEFT", 0, -1);
		end
	end

	if (curableDebuffFound == 0) then
		Perl_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end

	if (showtotbuffs == 1 or showtotdebuffs == 1) then
		Perl_Target_Target_BuffFrame:Show();											-- Show the final buff/debuff frame
	else
		Perl_Target_Target_BuffFrame:Hide();											-- Hide the buff/debuff frame since it's disabled
	end
end

function Perl_Target_Target_Target_Update_Buffs()
	local button, buffCount, buffTexture, buffApplications, color, debuffType;							-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
	local curableDebuffFound = 0;

	local numBuffs = 0;														-- Buff counter for correct layout
	if (showtototbuffs == 1) then
		for buffnum=1,16 do
			if (displaycastablebuffs == 0) then								-- Which buff filter mode are we in?
				targettargettargetbufffilter = "HELPFUL";
			else
				targettargettargetbufffilter = "HELPFUL RAID";
			end
			_, _, buffTexture, buffApplications = UnitAura("targettargettarget", buffnum, targettargettargetbufffilter);	-- Get the texture and buff stacking information if any
			button = getglobal("Perl_Target_Target_Target_BuffFrame_Buff"..buffnum);					-- Create the main icon for the buff
			if (buffTexture) then
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);						-- Set the texture
				getglobal(button:GetName().."DebuffBorder"):Hide();							-- Hide the debuff border
				buffCount = getglobal(button:GetName().."Count");							-- Declare the buff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);								-- Set the text to the number of applications if greater than 0
					buffCount:Show();										-- Show the text
				else
					buffCount:Hide();										-- Hide the text if equal to 0
				end
				numBuffs = numBuffs + 1;										-- Increment the buff counter
				button:Show();												-- Show the final buff icon
			else
				button:Hide();												-- Hide the icon since there isn't a buff in this position
			end
		end
	else
		numBuffs = 0;														-- ToToT Buffs are disabled
	end

	local numDebuffs = 0;														-- Debuff counter for correct layout
	if (showtototdebuffs == 1) then
		for debuffnum=1,16 do
			Perl_Target_Target_Target_Debuff_Set_Filter();								-- Are we targeting a friend or enemy and which filter do we need to apply?
			_, _, buffTexture, buffApplications, debuffType = UnitAura("targettargettarget", debuffnum, targettargettargetdebufffilter);	-- Get the texture and debuff stacking information if any
			button = getglobal("Perl_Target_Target_Target_BuffFrame_Debuff"..debuffnum);					-- Create the main icon for the debuff
			if (buffTexture) then
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);						-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (UnitIsFriend("player", "targettargettarget")) then
								if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
									Perl_Target_Target_Target_NameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									Perl_Target_Target_Target_StatsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
									curableDebuffFound = 1;
								end
							end
						end
					end
				else
					color = DebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				getglobal(button:GetName().."DebuffBorder"):SetVertexColor(color.r, color.g, color.b);			-- Set the debuff border color
				getglobal(button:GetName().."DebuffBorder"):Show();							-- Show the debuff border
				buffCount = getglobal(button:GetName().."Count");							-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);								-- Set the text to the number of applications if greater than 0
					buffCount:Show();										-- Show the text
				else
					buffCount:Hide();										-- Hide the text if equal to 0
				end
				numDebuffs = numDebuffs + 1;										-- Increment the debuff counter
				button:Show();												-- Show the final debuff icon
			else
				button:Hide();												-- Hide the icon since there isn't a debuff in this position
			end
		end
	else
		numBuffs = 0;														-- ToToT Debuffs are disabled
	end

	if (UnitIsFriend("player", "targettargettarget")) then										-- Position the buffs according to friendly or enemy status
		if (numBuffs < 9) then
			if (showtototbuffs == 0) then
				Perl_Target_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			else
				Perl_Target_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
				Perl_Target_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_BuffFrame_Buff1", "BOTTOMLEFT", 0, -1);
			end
		else
			Perl_Target_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			Perl_Target_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_BuffFrame_Buff9", "BOTTOMLEFT", 0, -1);
		end
	else
		if (numDebuffs < 9) then
			if (showtotdebuffs == 0) then
				Perl_Target_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			else
				Perl_Target_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
				Perl_Target_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_BuffFrame_Debuff1", "BOTTOMLEFT", 0, -1);
			end
		else
			Perl_Target_Target_Target_BuffFrame_Debuff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_StatsFrame", "BOTTOMLEFT", 3, 1);
			Perl_Target_Target_Target_BuffFrame_Buff1:SetPoint("TOPLEFT", "Perl_Target_Target_Target_BuffFrame_Debuff9", "BOTTOMLEFT", 0, -1);
		end
	end

	if (curableDebuffFound == 0) then
		Perl_Target_Target_Target_NameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		Perl_Target_Target_Target_StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end

	if (showtototbuffs == 1 or showtototdebuffs == 1) then
		Perl_Target_Target_Target_BuffFrame:Show();										-- Show the final buff/debuff frame
	else
		Perl_Target_Target_Target_BuffFrame:Hide();										-- Hide the buff/debuff frame since it's disabled
	end
end

function Perl_Target_Target_Debuff_Set_Filter()
	if (UnitIsFriend("player", "targettarget")) then
		if (displaycurabledebuff == 1) then
			targettargetdebufffilter = "HARMFUL RAID";
			return;
		end
	else
		if (displayonlymydebuffs == 1) then
			targettargetdebufffilter = "HARMFUL PLAYER";
			return;
		end
	end
	targettargetdebufffilter = "HARMFUL";
end

function Perl_Target_Target_Target_Debuff_Set_Filter()
	if (UnitIsFriend("player", "targettargettarget")) then
		if (displaycurabledebuff == 1) then
			targettargettargetdebufffilter = "HARMFUL RAID";
			return;
		end
	else
		if (displayonlymydebuffs == 1) then
			targettargettargetdebufffilter = "HARMFUL PLAYER";
			return;
		end
	end
	targettargettargetdebufffilter = "HARMFUL";
end

function Perl_Target_Target_Warn()
	-- Player has something targetted
	if (UnitAffectingCombat("target")) then								-- Target is in an active combat situation
		if (UnitIsDead("targettarget") or UnitIsCorpse("targettarget")) then			-- Target is dead, do nothing
			-- Previous author had this in as a safety check
		else
			if (not UnitIsFriend("target", "player")) then					-- Target isn't dead
				-- Stupid mobs dont have targets when they are trapped/polyd/sapped/stunned, check for this
				if (alertmode == 0) then	-- Disabled but still have audible alert enabled
					if (UnitName("targettarget") == UnitName("player")) then	-- play the warning sound if needed
						-- Its coming right for us!
						if (aggroWarningCount == 0) then
							aggroWarningCount = 1;
							Perl_Target_Target_Play_Sound();
						end
					else
						-- Whew it isnt fighting us
						aggroWarningCount = 0;
					end
				elseif (alertmode == 1) then	-- DPS Mode
					if (UnitName("targettarget") == UnitName("player")) then
						-- Its coming right for us!
						if (aggroWarningCount == 0) then
							if (alertsize == 0) then
								UIErrorsFrame:AddMessage(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU,1,0,0,1,3);
							elseif (alertsize == 1) then
								Perl_Target_Target_BigWarning_Show(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU);
							elseif (alertsize == 2) then
								-- Warning disabled
							end
							aggroWarningCount = 1;
							Perl_Target_Target_Play_Sound();
						end
					else
						-- Whew it isnt fighting us
						aggroWarningCount = 0;
					end
				elseif (alertmode == 2) then	-- Tank mode
					if (UnitName("targettarget") == UnitName("player")) then
						-- Its coming right for us! (A good thing, im tanking it)
						aggroWarningCount = 0;
					else
						-- Some dumb hunter pulled aggro
						if (aggroWarningCount == 0) then
							if (alertsize == 0) then
								if (GetLocale() == "deDE") then
									UIErrorsFrame:AddMessage("Du hast die Aggro verloren an "..UnitName("targettarget").."!",1,0,0,1,3);
								elseif (GetLocale() == "koKR") then
									UIErrorsFrame:AddMessage("당신은 "..UnitName("targettarget").."의 어그로 획득에 실패했습니다!",1,0,0,1,3);
								elseif (GetLocale() == "zhCN") then
									UIErrorsFrame:AddMessage("你的目标已经转移到 "..UnitName("targettarget").."!",1,0,0,1,3);
								else
									UIErrorsFrame:AddMessage("You have lost aggro to "..UnitName("targettarget").."!",1,0,0,1,3);
								end
							elseif (alertsize == 1) then
								if (GetLocale() == "deDE") then
									Perl_Target_Target_BigWarning_Show("Du hast die Aggro verloren an "..UnitName("targettarget").."!");
								elseif (GetLocale() == "koKR") then
									Perl_Target_Target_BigWarning_Show("당신은 "..UnitName("targettarget").."의 어그로 획득에 실패했습니다!");
								elseif (GetLocale() == "zhCN") then
									Perl_Target_Target_BigWarning_Show("你的目标已经转移到 "..UnitName("targettarget").."!");
								else
									Perl_Target_Target_BigWarning_Show("You have lost aggro to "..UnitName("targettarget").."!");
								end
							elseif (alertsize == 2) then
								-- Warning disabled
							end
							aggroWarningCount = 1;
							Perl_Target_Target_Play_Sound();
						end
					end
				elseif (alertmode == 3) then	-- Healer Mode (Do this check down here for sanity reasons)
					Perl_Target_Target_Warn_Healer_Mode();
				else
					-- Friendly target
					aggroWarningCount = 0;
				end
				--end
			else
				if (alertmode == 3) then	-- Healer Mode (Do this check down here for sanity reasons)
					Perl_Target_Target_Warn_Healer_Mode();
				else
					-- Friendly target
					aggroWarningCount = 0;
				end
			end
		end
	end
end

function Perl_Target_Target_Warn_Healer_Mode()		-- This chunk of code is called in 2 places so may as well place it as it's own function
	if (UnitIsPlayer("target")) then
		if (UnitIsFriend("player", "target")) then
			if (UnitIsUnit("target", "targettargettarget")) then	-- The target and the targets target target (whew) are the same
				if (aggroWarningCount == 0) then
					if (alertsize == 0) then
						if (GetLocale() == "deDE") then
							UIErrorsFrame:AddMessage(UnitName("target").." tankt nun "..UnitName("targettarget"),1,0,0,1,3);
						elseif (GetLocale() == "koKR") then
							UIErrorsFrame:AddMessage(UnitName("target").."님이 "..UnitName("targettarget").."|1을;를; 탱킹중입니다.",1,0,0,1,3);
						elseif (GetLocale() == "zhCN") then
							UIErrorsFrame:AddMessage(UnitName("targettarget").." 正在攻击 "..UnitName("target"),1,0,0,1,3);
						else
							UIErrorsFrame:AddMessage(UnitName("target").." is now tanking "..UnitName("targettarget"),1,0,0,1,3);
						end
					elseif (alertsize == 1) then
						if ((UnitName("player") == UnitName("target")) or (UnitName("target") == UnitName("targettarget"))) then
							-- Do nothing
						else
							if (GetLocale() == "deDE") then
								Perl_Target_Target_BigWarning_Show(UnitName("target").." tankt nun "..UnitName("targettarget"));
							elseif (GetLocale() == "koKR") then
								Perl_Target_Target_BigWarning_Show(UnitName("target").."님이 "..UnitName("targettarget").."|1을;를; 탱킹중입니다.");
							elseif (GetLocale() == "zhCN") then
								Perl_Target_Target_BigWarning_Show(UnitName("targettarget").." 正在攻击 "..UnitName("target"));
							else
								Perl_Target_Target_BigWarning_Show(UnitName("target").." is now tanking "..UnitName("targettarget"));
							end
						end
					elseif (alertsize == 2) then
						-- Warning disabled
					end
					aggroWarningCount = 1;
				end
			else
				-- Lazy warrior isnt tanking anything!
				aggroWarningCount = 0;
			end
		else
			if (UnitName("targettarget") == UnitName("player")) then
				-- Its coming right for us!
				if (aggroWarningCount == 0) then
					if (alertsize == 0) then
						UIErrorsFrame:AddMessage(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU,1,0,0,1,3);
					elseif (alertsize == 1) then
						Perl_Target_Target_BigWarning_Show(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU);
					elseif (alertsize == 2) then
						-- Warning disabled
					end
					aggroWarningCount = 1;
					Perl_Target_Target_Play_Sound();
				end
			else
				-- Whew it isnt fighting us
				aggroWarningCount = 0;
			end
		end
	else
		if (UnitName("targettarget") == UnitName("player")) then
			-- Its coming right for us!
			if (aggroWarningCount == 0) then
				if (alertsize == 0) then
					UIErrorsFrame:AddMessage(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU,1,0,0,1,3);
				elseif (alertsize == 1) then
					Perl_Target_Target_BigWarning_Show(UnitName("target")..PERL_LOCALIZED_TARGET_TARGET_CHANGED_TO_YOU);
				elseif (alertsize == 2) then
					-- Warning disabled
				end
				aggroWarningCount = 1;
				Perl_Target_Target_Play_Sound();
			end
		else
			-- Whew it isnt fighting us
			aggroWarningCount = 0;
		end
	end
end

function Perl_Target_Target_Play_Sound()
	if (alertsound == 1) then
		PlaySoundFile("Sound\\Spells\\PVPFlagTakenHorde.wav");
	end
end

function Perl_Target_Target_Reset_Buffs()
	local button, debuff;
	for buffnum=1,16 do
		button = getglobal("Perl_Target_Target_BuffFrame_Buff"..buffnum);
		debuff = getglobal(button:GetName().."DebuffBorder");
		button:Hide();
		debuff:Hide();
	end
	for debuffnum=1,16 do
		button = getglobal("Perl_Target_Target_BuffFrame_Debuff"..debuffnum);
		debuff = getglobal(button:GetName().."DebuffBorder");
		button:Hide();
		debuff:Hide();
	end
end

function Perl_Target_Target_Target_Reset_Buffs()
	local button, debuff;
	for buffnum=1,16 do
		button = getglobal("Perl_Target_Target_Target_BuffFrame_Buff"..buffnum);
		debuff = getglobal(button:GetName().."DebuffBorder");
		button:Hide();
		debuff:Hide();
	end
	for debuffnum=1,16 do
		button = getglobal("Perl_Target_Target_Target_BuffFrame_Debuff"..debuffnum);
		debuff = getglobal(button:GetName().."DebuffBorder");
		button:Hide();
		debuff:Hide();
	end
end


-------------------------
-- Mouseover Functions --
-------------------------
-- Target of Target Start
function Perl_Target_Target_HealthShow()
	targettargethealth = UnitHealth("targettarget");
	targettargethealthmax = UnitHealthMax("targettarget");

	if (UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then				-- This prevents negative health
		targettargethealth = 0;
		targettargethealthpercent = 0;
	end

	Perl_Target_Target_HealthBarText:SetText(targettargethealth.."/"..targettargethealthmax);	-- Self/Party/Raid member

	mouseovertargettargethealthflag = 1;
end

function Perl_Target_Target_HealthHide()
	targettargethealthpercent = floor(UnitHealth("targettarget")/UnitHealthMax("targettarget")*100+0.5);

	if (UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then				-- This prevents negative health
		targettargethealthpercent = 0;
	end

	Perl_Target_Target_HealthBarText:SetText(targettargethealthpercent.."%");
	mouseovertargettargethealthflag = 0;
end

function Perl_Target_Target_ManaShow()
	targettargetmana = UnitMana("targettarget");
	targettargetmanamax = UnitManaMax("targettarget");

	if (UnitIsDead("targettarget") or UnitIsGhost("targettarget")) then				-- This prevents negative mana
		targettargetmana = 0;
	end

	if (UnitPowerType("targettarget") == 1 or UnitPowerType("targettarget") == 2 or UnitPowerType("targettarget") == 6) then
		Perl_Target_Target_ManaBarText:SetText(targettargetmana);
	else
		Perl_Target_Target_ManaBarText:SetText(targettargetmana.."/"..targettargetmanamax);
	end
	Perl_Target_Target_ManaBarText:Show();
	mouseovertargettargetmanaflag = 1;
end

function Perl_Target_Target_ManaHide()
	Perl_Target_Target_ManaBarText:Hide();
	mouseovertargettargetmanaflag = 0;
end
-- Target of Target End

-- Target of Target of Target Start
function Perl_Target_Target_Target_HealthShow()
	targettargettargethealth = UnitHealth("targettargettarget");
	targettargettargethealthmax = UnitHealthMax("targettargettarget");

	if (UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then				-- This prevents negative health
		targettargettargethealth = 0;
		targettargettargethealthpercent = 0;
	end

	Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealth.."/"..targettargettargethealthmax);	-- Self/Party/Raid member

	mouseovertargettargettargethealthflag = 1;
end

function Perl_Target_Target_Target_HealthHide()
	targettargettargethealthpercent = floor(UnitHealth("targettargettarget")/UnitHealthMax("targettargettarget")*100+0.5);

	if (UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then				-- This prevents negative health
		targettargettargethealthpercent = 0;
	end

	Perl_Target_Target_Target_HealthBarText:SetText(targettargettargethealthpercent.."%");
	mouseovertargettargettargethealthflag = 0;
end

function Perl_Target_Target_Target_ManaShow()
	targettargettargetmana = UnitMana("targettargettarget");
	targettargettargetmanamax = UnitManaMax("targettargettarget");

	if (UnitIsDead("targettargettarget") or UnitIsGhost("targettargettarget")) then				-- This prevents negative mana
		targettargettargetmana = 0;
	end

	if (UnitPowerType("targettargettarget") == 1 or UnitPowerType("targettargettarget") == 2 or UnitPowerType("targettargettarget") == 6) then
		Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana);
	else
		Perl_Target_Target_Target_ManaBarText:SetText(targettargettargetmana.."/"..targettargettargetmanamax);
	end
	Perl_Target_Target_Target_ManaBarText:Show();
	mouseovertargettargettargetmanaflag = 1;
end

function Perl_Target_Target_Target_ManaHide()
	Perl_Target_Target_Target_ManaBarText:Hide();
	mouseovertargettargettargetmanaflag = 0;
end
-- Target of Target of Target End


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Target_Target_HealthBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (targettargethealth < Perl_Target_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targettargethealth > Perl_Target_Target_HealthBar:GetValue())) then
			Perl_Target_Target_HealthBarFadeBar:SetMinMaxValues(0, targettargethealthmax);
			Perl_Target_Target_HealthBarFadeBar:SetValue(Perl_Target_Target_HealthBar:GetValue());
			Perl_Target_Target_HealthBarFadeBar:Show();
			Perl_Target_Target_HealthBar_Fade_Color = 1;
			Perl_Target_Target_HealthBar_Fade_Time_Elapsed = 0;
			Perl_Target_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_HealthBar_Fade_Color, 0, Perl_Target_Target_HealthBar_Fade_Color);
			Perl_Target_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Target_Target_ManaBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (targettargetmana < Perl_Target_Target_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targettargetmana > Perl_Target_Target_ManaBar:GetValue())) then
			Perl_Target_Target_ManaBarFadeBar:SetMinMaxValues(0, targettargetmanamax);
			Perl_Target_Target_ManaBarFadeBar:SetValue(Perl_Target_Target_ManaBar:GetValue());
			Perl_Target_Target_ManaBarFadeBar:Show();
			Perl_Target_Target_ManaBar_Fade_Color = 1;
			Perl_Target_Target_ManaBar_Fade_Time_Elapsed = 0;
			if (targettargetpower == 0) then			-- Forcing an initial value will prevent the fade from starting incorrectly
				Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color);
			elseif (targettargetpower == 1) then
				Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, 0, 0, Perl_Target_Target_ManaBar_Fade_Color);
			elseif (targettargetpower == 2) then
				Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, (Perl_Target_Target_ManaBar_Fade_Color-0.5), 0, Perl_Target_Target_ManaBar_Fade_Color);
			elseif (targettargetpower == 3) then
				Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color, 0, Perl_Target_Target_ManaBar_Fade_Color);
			elseif (targettargetpower == 6) then
				Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color);
			end
			Perl_Target_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Target_Target_Target_HealthBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (targettargettargethealth < Perl_Target_Target_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targettargettargethealth > Perl_Target_Target_Target_HealthBar:GetValue())) then
			Perl_Target_Target_Target_HealthBarFadeBar:SetMinMaxValues(0, targettargettargethealthmax);
			Perl_Target_Target_Target_HealthBarFadeBar:SetValue(Perl_Target_Target_Target_HealthBar:GetValue());
			Perl_Target_Target_Target_HealthBarFadeBar:Show();
			Perl_Target_Target_Target_HealthBar_Fade_Color = 1;
			Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed = 0;
			Perl_Target_Target_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_Target_HealthBar_Fade_Color, 0, Perl_Target_Target_Target_HealthBar_Fade_Color);
			Perl_Target_Target_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Target_Target_Target_ManaBar_Fade_Check()
	if (PCUF_FADEBARS == 1) then
		if (targettargettargetmana < Perl_Target_Target_Target_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targettargettargetmana > Perl_Target_Target_Target_ManaBar:GetValue())) then
			Perl_Target_Target_Target_ManaBarFadeBar:SetMinMaxValues(0, targettargettargetmanamax);
			Perl_Target_Target_Target_ManaBarFadeBar:SetValue(Perl_Target_Target_Target_ManaBar:GetValue());
			Perl_Target_Target_Target_ManaBarFadeBar:Show();
			Perl_Target_Target_Target_ManaBar_Fade_Color = 1;
			Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed = 0;
			if (targettargettargetpower == 0) then
				Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color);
			elseif (targettargettargetpower == 1) then
				Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, 0, 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
			elseif (targettargettargetpower == 2) then
				Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, (Perl_Target_Target_Target_ManaBar_Fade_Color-0.5), 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
			elseif (targettargettargetpower == 3) then
				Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color, 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
			elseif (targettargettargetpower == 6) then
				Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color);
			end
			Perl_Target_Target_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end
end

function Perl_Target_Target_HealthBar_Fade(arg1)
	Perl_Target_Target_HealthBar_Fade_Color = Perl_Target_Target_HealthBar_Fade_Color - arg1;
	Perl_Target_Target_HealthBar_Fade_Time_Elapsed = Perl_Target_Target_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Target_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_HealthBar_Fade_Color, 0, Perl_Target_Target_HealthBar_Fade_Color);

	if (Perl_Target_Target_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Target_Target_HealthBar_Fade_Color = 1;
		Perl_Target_Target_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Target_Target_HealthBarFadeBar:Hide();
		Perl_Target_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Target_Target_ManaBar_Fade(arg1)
	Perl_Target_Target_ManaBar_Fade_Color = Perl_Target_Target_ManaBar_Fade_Color - arg1;
	Perl_Target_Target_ManaBar_Fade_Time_Elapsed = Perl_Target_Target_ManaBar_Fade_Time_Elapsed + arg1;

	if (targettargetpower == 0) then
		Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color);
	elseif (targettargetpower == 1) then
		Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, 0, 0, Perl_Target_Target_ManaBar_Fade_Color);
	elseif (targettargetpower == 2) then
		Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, (Perl_Target_Target_ManaBar_Fade_Color-0.5), 0, Perl_Target_Target_ManaBar_Fade_Color);
	elseif (targettargetpower == 3) then
		Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color, 0, Perl_Target_Target_ManaBar_Fade_Color);
	elseif (targettargetpower == 6) then
		Perl_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_ManaBar_Fade_Color);
	end

	if (Perl_Target_Target_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Target_Target_ManaBar_Fade_Color = 1;
		Perl_Target_Target_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Target_Target_ManaBarFadeBar:Hide();
		Perl_Target_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Target_Target_Target_HealthBar_Fade(arg1)
	Perl_Target_Target_Target_HealthBar_Fade_Color = Perl_Target_Target_Target_HealthBar_Fade_Color - arg1;
	Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed = Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Target_Target_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_Target_HealthBar_Fade_Color, 0, Perl_Target_Target_Target_HealthBar_Fade_Color);

	if (Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Target_Target_Target_HealthBar_Fade_Color = 1;
		Perl_Target_Target_Target_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Target_Target_Target_HealthBarFadeBar:Hide();
		Perl_Target_Target_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Target_Target_Target_ManaBar_Fade(arg1)
	Perl_Target_Target_Target_ManaBar_Fade_Color = Perl_Target_Target_Target_ManaBar_Fade_Color - arg1;
	Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed = Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed + arg1;

	if (targettargettargetpower == 0) then
		Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color);
	elseif (targettargettargetpower == 1) then
		Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, 0, 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
	elseif (targettargettargetpower == 2) then
		Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, (Perl_Target_Target_Target_ManaBar_Fade_Color-0.5), 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
	elseif (targettargettargetpower == 3) then
		Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color, 0, Perl_Target_Target_Target_ManaBar_Fade_Color);
	elseif (targettargettargetpower == 6) then
		Perl_Target_Target_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color, Perl_Target_Target_Target_ManaBar_Fade_Color);
	end

	if (Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Target_Target_Target_ManaBar_Fade_Color = 1;
		Perl_Target_Target_Target_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Target_Target_Target_ManaBarFadeBar:Hide();
		Perl_Target_Target_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Target_Target_Frame_Style()
	if (totsupport == 0) then
		Perl_Target_Target_Frame:Hide();
		UnregisterUnitWatch(Perl_Target_Target_Frame);
	else
		RegisterUnitWatch(Perl_Target_Target_Frame);
	end

	if (tototsupport == 0) then
		Perl_Target_Target_Target_Frame:Hide();
		UnregisterUnitWatch(Perl_Target_Target_Target_Frame);
	else
		RegisterUnitWatch(Perl_Target_Target_Target_Frame);
	end

	if (hidepowerbars == 0) then
		Perl_Target_Target_ManaBar:Show();
		Perl_Target_Target_ManaBarBG:Show();
		Perl_Target_Target_ManaBar_CastClickOverlay:Show();
		Perl_Target_Target_StatsFrame:SetHeight(42);
		Perl_Target_Target_StatsFrame_CastClickOverlay:SetHeight(42);

		Perl_Target_Target_Target_ManaBar:Show();
		Perl_Target_Target_Target_ManaBarBG:Show();
		Perl_Target_Target_Target_ManaBar_CastClickOverlay:Show();
		Perl_Target_Target_Target_StatsFrame:SetHeight(42);
		Perl_Target_Target_Target_StatsFrame_CastClickOverlay:SetHeight(42);
	else
		Perl_Target_Target_ManaBar:Hide();
		Perl_Target_Target_ManaBarBG:Hide();
		Perl_Target_Target_ManaBar_CastClickOverlay:Hide();
		Perl_Target_Target_StatsFrame:SetHeight(30);
		Perl_Target_Target_StatsFrame_CastClickOverlay:SetHeight(30);

		Perl_Target_Target_Target_ManaBar:Hide();
		Perl_Target_Target_Target_ManaBarBG:Hide();
		Perl_Target_Target_Target_ManaBar_CastClickOverlay:Hide();
		Perl_Target_Target_Target_StatsFrame:SetHeight(30);
		Perl_Target_Target_Target_StatsFrame_CastClickOverlay:SetHeight(30);
	end

	Perl_Target_Target_NameBarText:SetWidth(Perl_Target_Target_NameFrame:GetWidth() - 13);
	Perl_Target_Target_NameBarText:SetHeight(Perl_Target_Target_NameFrame:GetHeight() - 10);
	Perl_Target_Target_NameBarText:SetNonSpaceWrap(false);
	Perl_Target_Target_NameBarText:SetJustifyH("LEFT");

	Perl_Target_Target_Target_NameBarText:SetWidth(Perl_Target_Target_Target_NameFrame:GetWidth() - 13);
	Perl_Target_Target_Target_NameBarText:SetHeight(Perl_Target_Target_Target_NameFrame:GetHeight() - 10);
	Perl_Target_Target_Target_NameBarText:SetNonSpaceWrap(false);
	Perl_Target_Target_Target_NameBarText:SetJustifyH("LEFT");
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Target_Target_Set_ToT(newvalue)
	totsupport = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Frame_Style();
end

function Perl_Target_Target_Set_ToToT(newvalue)
	tototsupport = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Frame_Style();
end

function Perl_Target_Target_Set_Mode(newvalue)
	alertmode = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Sound_Alert(newvalue)
	alertsound = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Alert_Size(newvalue)
	alertsize = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Buffs(newvalue)
	showtotbuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Set_Debuffs(newvalue)
	showtotdebuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Target_Set_Buffs(newvalue)
	showtototbuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Target_Set_Debuffs(newvalue)
	showtototdebuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Set_Hide_Power_Bars(newvalue)
	hidepowerbars = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Frame_Style();
end

function Perl_Target_Target_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Class_Buffs(newvalue)
	displaycastablebuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Reset_Buffs();
	Perl_Target_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Set_Class_Debuffs(newvalue)
	displaycurabledebuff = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Reset_Buffs();
	Perl_Target_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Set_Only_Self_Debuffs(newvalue)
	displayonlymydebuffs = newvalue;
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Reset_Buffs();
	Perl_Target_Target_Target_Reset_Buffs();
end

function Perl_Target_Target_Set_Show_Friendly_Health(newvalue)
	showfriendlyhealth = newvalue;
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);						-- convert the user input to a wow acceptable value
	end
	Perl_Target_Target_UpdateVars();
	Perl_Target_Target_Set_Scale_Actual();
end

function Perl_Target_Target_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Target_Target_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
		Perl_Target_Target_Frame:SetScale(unsavedscale);
		Perl_Target_Target_Target_Frame:SetScale(unsavedscale);
	end
end

function Perl_Target_Target_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);					-- convert the user input to a wow acceptable value
	end
	Perl_Target_Target_Frame:SetAlpha(transparency);
	Perl_Target_Target_Target_Frame:SetAlpha(transparency);
	Perl_Target_Target_UpdateVars();
end

function Perl_Target_Target_Allign(button)
	if (Perl_Target_Frame) then
		local vartable = Perl_Target_GetVars();			-- Get the target frame settings

		Perl_Target_Target_Frame:SetUserPlaced(1);		-- This makes wow remember the changes if the frames have never been moved before
		Perl_Target_Target_Target_Frame:SetUserPlaced(1);

		if (button == 1) then
			if (vartable["showportrait"] == 1) then
				if (vartable["showcp"] == 1 or vartable["comboframedebuffs"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_PortraitFrame, "TOPRIGHT", 17, 0);
					Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", -4, 0);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_PortraitFrame, "TOPRIGHT", -4, 0);
					Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", -4, 0);
				end
			else
				if (vartable["showcp"] == 1 or vartable["comboframedebuffs"] == 1) then
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_LevelFrame, "TOPRIGHT", 17, 0);
					Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", -4, 0);
				else
					Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_LevelFrame, "TOPRIGHT", -4, 0);
					Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", -4, 0);
				end
			end
		elseif (button == 2) then
			if (vartable["showclassframe"] == 1 or vartable["showrareeliteframe"] == 1) then
				Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_NameFrame, "TOPLEFT", 0, 77);
				Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", 1, 0);
			else
				Perl_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_NameFrame, "TOPLEFT", 0, 57);
				Perl_Target_Target_Target_Frame:SetPoint("TOPLEFT", Perl_Target_Target_Frame, "TOPRIGHT", 1, 0);
			end
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("This feature is disabled due to Perl_Target not being installed/enabled.");
	end
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Target_Target_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Target_Target_Config[name]["Locked"];
	scale = Perl_Target_Target_Config[name]["Scale"];
	totsupport = Perl_Target_Target_Config[name]["ToTSupport"];
	tototsupport = Perl_Target_Target_Config[name]["ToToTSupport"];
	transparency = Perl_Target_Target_Config[name]["Transparency"];
	alertsound = Perl_Target_Target_Config[name]["AlertSound"];
	alertmode = Perl_Target_Target_Config[name]["AlertMode"];
	alertsize = Perl_Target_Target_Config[name]["AlertSize"];
	showtotbuffs = Perl_Target_Target_Config[name]["ShowToTBuffs"];
	showtototbuffs = Perl_Target_Target_Config[name]["ShowToToTBuffs"];
	hidepowerbars = Perl_Target_Target_Config[name]["HidePowerBars"];
	showtotdebuffs = Perl_Target_Target_Config[name]["ShowToTDebuffs"];
	showtototdebuffs = Perl_Target_Target_Config[name]["ShowToToTDebuffs"];
	displaycastablebuffs = Perl_Target_Target_Config[name]["DisplayCastableBuffs"];
	classcolorednames = Perl_Target_Target_Config[name]["ClassColoredNames"];
	showfriendlyhealth = Perl_Target_Target_Config[name]["ShowFriendlyHealth"];
	displaycurabledebuff = Perl_Target_Target_Config[name]["DisplayCurableDebuff"];
	displayonlymydebuffs = Perl_Target_Target_Config[name]["DisplayOnlyMyDebuffs"];

	if (locked == nil) then
		locked = 0;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (totsupport == nil) then
		totsupport = 1;
	end
	if (tototsupport == nil) then
		tototsupport = 1;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (alertsound == nil) then
		alertsound = 0;
	end
	if (alertmode == nil) then
		alertmode = 0;
	end
	if (alertsize == nil) then
		alertsize = 0;
	end
	if (showtotbuffs == nil) then
		showtotbuffs = 0;
	end
	if (showtototbuffs == nil) then
		showtototbuffs = 0;
	end
	if (hidepowerbars == nil) then
		hidepowerbars = 0;
	end
	if (showtotdebuffs == nil) then
		showtotdebuffs = 0;
	end
	if (showtototdebuffs == nil) then
		showtototdebuffs = 0;
	end
	if (displaycastablebuffs == nil) then
		displaycastablebuffs = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (showfriendlyhealth == nil) then
		showfriendlyhealth = 0;
	end
	if (displaycurabledebuff == nil) then
		displaycurabledebuff = 0;
	end
	if (displayonlymydebuffs == nil) then
		displayonlymydebuffs = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Target_Target_UpdateVars();

		-- Call any code we need to activate them
		Perl_Target_Target_Frame_Style();
		Perl_Target_Target_Set_Scale_Actual();
		Perl_Target_Target_Set_Transparency();
		return;
	end

	local vars = {
		["locked"] = locked,
		["scale"] = scale,
		["totsupport"] = totsupport,
		["tototsupport"] = tototsupport,
		["transparency"] = transparency,
		["alertsound"] = alertsound,
		["alertmode"] = alertmode,
		["alertsize"] = alertsize,
		["showtotbuffs"] = showtotbuffs,
		["showtototbuffs"] = showtototbuffs,
		["hidepowerbars"] = hidepowerbars,
		["showtotdebuffs"] = showtotdebuffs,
		["showtototdebuffs"] = showtototdebuffs,
		["displaycastablebuffs"] = displaycastablebuffs,
		["classcolorednames"] = classcolorednames,
		["showfriendlyhealth"] = showfriendlyhealth,
		["displaycurabledebuff"] = displaycurabledebuff,
		["displayonlymydebuffs"] = displayonlymydebuffs,
	}
	return vars;
end

function Perl_Target_Target_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["ToTSupport"] ~= nil) then
				totsupport = vartable["Global Settings"]["ToTSupport"];
			else
				totsupport = nil;
			end
			if (vartable["Global Settings"]["ToToTSupport"] ~= nil) then
				tototsupport = vartable["Global Settings"]["ToToTSupport"];
			else
				tototsupport = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["AlertSound"] ~= nil) then
				alertsound = vartable["Global Settings"]["AlertSound"];
			else
				alertsound = nil;
			end
			if (vartable["Global Settings"]["AlertMode"] ~= nil) then
				alertmode = vartable["Global Settings"]["AlertMode"];
			else
				alertmode = nil;
			end
			if (vartable["Global Settings"]["AlertSize"] ~= nil) then
				alertsize = vartable["Global Settings"]["AlertSize"];
			else
				alertsize = nil;
			end
			if (vartable["Global Settings"]["ShowToTBuffs"] ~= nil) then
				showtotbuffs = vartable["Global Settings"]["ShowToTBuffs"];
			else
				showtotbuffs = nil;
			end
			if (vartable["Global Settings"]["ShowToToTBuffs"] ~= nil) then
				showtototbuffs = vartable["Global Settings"]["ShowToToTBuffs"];
			else
				showtototbuffs = nil;
			end
			if (vartable["Global Settings"]["HidePowerBars"] ~= nil) then
				hidepowerbars = vartable["Global Settings"]["HidePowerBars"];
			else
				hidepowerbars = nil;
			end
			if (vartable["Global Settings"]["ShowToTDebuffs"] ~= nil) then
				showtotdebuffs = vartable["Global Settings"]["ShowToTDebuffs"];
			else
				showtotdebuffs = nil;
			end
			if (vartable["Global Settings"]["ShowToToTDebuffs"] ~= nil) then
				showtototdebuffs = vartable["Global Settings"]["ShowToToTDebuffs"];
			else
				showtototdebuffs = nil;
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
			if (vartable["Global Settings"]["ShowFriendlyHealth"] ~= nil) then
				showfriendlyhealth = vartable["Global Settings"]["ShowFriendlyHealth"];
			else
				showfriendlyhealth = nil;
			end
			if (vartable["Global Settings"]["DisplayCurableDebuff"] ~= nil) then
				displaycurabledebuff = vartable["Global Settings"]["DisplayCurableDebuff"];
			else
				displaycurabledebuff = nil;
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
		if (scale == nil) then
			scale = 0.9;
		end
		if (totsupport == nil) then
			totsupport = 1;
		end
		if (tototsupport == nil) then
			tototsupport = 1;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (alertsound == nil) then
			alertsound = 0;
		end
		if (alertmode == nil) then
			alertmode = 0;
		end
		if (alertsize == nil) then
			alertsize = 0;
		end
		if (showtotbuffs == nil) then
			showtotbuffs = 0;
		end
		if (showtototbuffs == nil) then
			showtototbuffs = 0;
		end
		if (hidepowerbars == nil) then
			hidepowerbars = 0;
		end
		if (showtotdebuffs == nil) then
			showtotdebuffs = 0;
		end
		if (showtototdebuffs == nil) then
			showtototdebuffs = 0;
		end
		if (displaycastablebuffs == nil) then
			displaycastablebuffs = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (showfriendlyhealth == nil) then
			showfriendlyhealth = 0;
		end
		if (displaycurabledebuff == nil) then
			displaycurabledebuff = 0;
		end
		if (displayonlymydebuffs == nil) then
			displayonlymydebuffs = 0;
		end

		-- Call any code we need to activate them
		Perl_Target_Target_Frame_Style();
		Perl_Target_Target_Set_Scale_Actual();
		Perl_Target_Target_Set_Transparency();
	end

	Perl_Target_Target_Config[UnitName("player")] = {
		["Locked"] = locked,
		["Scale"] = scale,
		["ToTSupport"] = totsupport,
		["ToToTSupport"] = tototsupport,
		["Transparency"] = transparency,
		["AlertSound"] = alertsound,
		["AlertMode"] = alertmode,
		["AlertSize"] = alertsize,
		["ShowToTBuffs"] = showtotbuffs,
		["ShowToToTBuffs"] = showtototbuffs,
		["HidePowerBars"] = hidepowerbars,
		["ShowToTDebuffs"] = showtotdebuffs,
		["ShowToToTDebuffs"] = showtototdebuffs,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["ClassColoredNames"] = classcolorednames,
		["ShowFriendlyHealth"] = showfriendlyhealth,
		["DisplayCurableDebuff"] = displaycurabledebuff,
		["DisplayOnlyMyDebuffs"] = displayonlymydebuffs,
	};
end


--------------------
-- Click Handlers --
--------------------
-- Target of Target Start
function Perl_TargetTarget_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_Target_Target_DropDown, "Perl_Target_Target_NameFrame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "targettarget", showmenu);

	self:SetAttribute("unit", "targettarget");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_TargetTargetDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_TargetTargetDropDown_Initialize, "MENU");
end

function Perl_TargetTargetDropDown_Initialize()
	local menu, name;
	local id = nil;
	if (UnitIsUnit("targettarget", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("targettarget", "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit("targettarget", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("targettarget")) then
		id = UnitInRaid("targettarget");
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty("targettarget")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Target_Target_DropDown, menu, "targettarget", name, id);
	end
end

function Perl_Target_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Target_Frame:StartMoving();
	end
end

function Perl_Target_Target_DragStop(button)
	Perl_Target_Target_Frame:StopMovingOrSizing();
end
-- Target of Target End

-- Target of Target of Target Start
function Perl_TargetTargetTarget_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_Target_Target_Target_DropDown, "Perl_Target_Target_Target_NameFrame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "targettargettarget", showmenu);

	self:SetAttribute("unit", "targettargettarget");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_TargetTargetTargetDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_TargetTargetTargetDropDown_Initialize, "MENU");
end

function Perl_TargetTargetTargetDropDown_Initialize()
	local menu, name;
	local id = nil;
	if (UnitIsUnit("targettargettarget", "player")) then
		menu = "SELF";
	elseif (UnitIsUnit("targettargettarget", "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit("targettargettarget", "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer("targettargettarget")) then
		id = UnitInRaid("targettargettarget");
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty("targettargettarget")) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Target_Target_Target_DropDown, menu, "targettargettarget", name, id);
	end
end

function Perl_Target_Target_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Target_Target_Target_Frame:StartMoving();
	end
end

function Perl_Target_Target_Target_DragStop(button)
	Perl_Target_Target_Target_Frame:StopMovingOrSizing();
end
-- Target of Target of Target End


----------------------------
-- Big Warning Text Frame --
----------------------------
-- Fade in/out frame stuff
-- Ripped/modified from FadingFrame from Blizzard
-- Ripped from AggroAlert 1.5

function Perl_Target_Target_BigWarning_OnLoad(self)
	Perl_Target_Target_BigWarning:Hide();

	-- Scripts
	self:SetScript("OnUpdate", Perl_Target_Target_BigWarning_OnUpdate);
end

function Perl_Target_Target_BigWarning_Show(message)
	startTime = GetTime();
	if (message) then
		Perl_Target_Target_BigWarning_Text:SetText(message);
	end
	Perl_Target_Target_BigWarning:Show();
end


function Perl_Target_Target_BigWarning_OnUpdate()
	local elapsed = GetTime() - startTime;
	local fadeInTime = 0.2;
	if (elapsed < fadeInTime) then
		local alpha = (elapsed / fadeInTime);
		Perl_Target_Target_BigWarning:SetAlpha(alpha);
		return;
	end
	local holdTime = 2.5;
	if (elapsed < (fadeInTime + holdTime)) then
		Perl_Target_Target_BigWarning:SetAlpha(1.0);
		return;
	end
	local fadeOutTime = 2;
	if (elapsed < (fadeInTime + holdTime + fadeOutTime)) then
		local alpha = 1.0 - ((elapsed - holdTime - fadeInTime) / fadeOutTime);
		Perl_Target_Target_BigWarning:SetAlpha(alpha);
		return;
	end
	Perl_Target_Target_BigWarning:Hide();
end


-------------
-- Tooltip --
-------------
function Perl_Target_Target_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 16) then
		GameTooltip:SetUnitDebuff("targettarget", self:GetID()-16, displaycurabledebuff);		-- 16 being the number of buffs before debuffs in the xml
	else
		GameTooltip:SetUnitBuff("targettarget", self:GetID(), displaycastablebuffs);
	end
end

function Perl_Target_Target_Target_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 16) then
		GameTooltip:SetUnitDebuff("targettargettarget", self:GetID()-16, displaycurabledebuff);		-- 16 being the number of buffs before debuffs in the xml
	else
		GameTooltip:SetUnitBuff("targettargettarget", self:GetID(), displaycastablebuffs);
	end
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Target_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Target_Target_myAddOns_Details = {
			name = "Perl_Target_Target",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Target_Target_myAddOns_Help = {};
		Perl_Target_Target_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Target_Target_myAddOns_Details, Perl_Target_Target_myAddOns_Help);
	end
end
