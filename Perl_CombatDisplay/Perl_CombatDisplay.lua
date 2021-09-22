---------------
-- Variables --
---------------
Perl_CombatDisplay_Config = {};
local Perl_CombatDisplay_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_CombatDisplay_GetVars)
local state = 3;		-- hidden unless in combat by default
local manapersist = 0;		-- mana persist is off by default
local healthpersist = 0;	-- health persist is off by default
local locked = 0;		-- unlocked by default
local scale = 0.9;		-- default scale
local transparency = 1;		-- transparency for the frame
local showtarget = 0;		-- target frame is disabled by default
local showdruidbar = 0;		-- Druid Bar support is enabled by default
local showpetbars = 0;		-- Pet info is hidden by default
local rightclickmenu = 0;	-- The ability to open a menu from CombatDisplay is disabled by default
local displaypercents = 0;	-- percents are off by default
local showcp = 0;		-- combo points are hidden by default
local clickthrough = 0;		-- frames are clickable by default

-- Default Local Variables
local InCombat = 0;
local Initialized = nil;
local IsAggroed = 0;
local Perl_CombatDisplay_ManaBar_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_CombatDisplay_ManaBar_Time_Update_Rate = 0.1;	-- the update interval
local Perl_CombatDisplay_Target_ManaBar_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_Target_ManaBar_Time_Update_Rate = 0.1;	-- the update interval
local Perl_CombatDisplay_DruidBar_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_CombatDisplay_DruidBar_Time_Update_Rate = 0.2;	-- the update interval
local healthfull = 0;
local manafull = 0;

-- Fade Bar Variables
local Perl_CombatDisplay_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0
--local Perl_CombatDisplay_DruidBar_Fade_Color = 1;		-- the color fading interval
--local Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_CPBar_Fade_Color = 1;			-- the color fading interval
local Perl_CombatDisplay_CPBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0
local Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_PetManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;			-- the color fading interval
local Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed = 0;		-- set the update timer to 0

-- Local variables to save memory
local playerhealth, playerhealthmax, playermana, playermanamax, playerpower, playerdruidbarmana, playerdruidbarmanamax, playerdruidbarmanapercent, pethealth, pethealthmax, petmana, petmanamax, targethealth, targethealthmax, targetmana, targetmanamax, targetpowertype, englishclass, playeronupdatemana, targetonupdatemana;


----------------------
-- Loading Function --
----------------------
function Perl_CombatDisplay_OnLoad(self)
	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_COMBO_POINTS");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_ENERGY");
	self:RegisterEvent("UNIT_FOCUS");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_MANA");
	self:RegisterEvent("UNIT_MAXENERGY");
	self:RegisterEvent("UNIT_MAXFOCUS");
	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_MAXMANA");
	self:RegisterEvent("UNIT_MAXRAGE");
	self:RegisterEvent("UNIT_MAXRUNIC_POWER");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_RAGE");
	self:RegisterEvent("UNIT_RUNIC_POWER");

	-- Scripts
	self:SetScript("OnEvent", Perl_CombatDisplay_OnEvent);

	-- Button Click Overlays (in order of occurrence in XML)
	Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetFrameLevel(Perl_CombatDisplay_ManaFrame:GetFrameLevel() + 2);
	Perl_CombatDisplay_HealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_HealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_ManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_ManaBar:GetFrameLevel() - 1);
	--Perl_CombatDisplay_DruidBarFadeBar:SetFrameLevel(Perl_CombatDisplay_DruidBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_CPBarFadeBar:SetFrameLevel(Perl_CombatDisplay_CPBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_PetHealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_PetHealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_PetManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_PetManaBar:GetFrameLevel() - 1);
end

function Perl_CombatDisplay_Target_OnLoad(self)
	-- Button Click Overlays (in order of occurrence in XML)
	Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:SetFrameLevel(Perl_CombatDisplay_Target_ManaFrame:GetFrameLevel() + 2);
	Perl_CombatDisplay_Target_HealthBarFadeBar:SetFrameLevel(Perl_CombatDisplay_Target_HealthBar:GetFrameLevel() - 1);
	Perl_CombatDisplay_Target_ManaBarFadeBar:SetFrameLevel(Perl_CombatDisplay_Target_ManaBar:GetFrameLevel() - 1);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", "target");
end


-------------------
-- Event Handler --
-------------------
function Perl_CombatDisplay_OnEvent()
	local func = Perl_CombatDisplay_Events[event];
	
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - CombatDisplay: Report the following event error to the author: "..event);
		end
	end
end

function Perl_CombatDisplay_Events:UNIT_HEALTH()
	if (arg1 == "player") then
		if (UnitHealth("player") == UnitHealthMax("player")) then
			healthfull = 1;
			if (healthpersist == 1) then
				Perl_CombatDisplay_UpdateDisplay();
			end
		else
			healthfull = 0;
		end
		Perl_CombatDisplay_Update_Health();
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_Update_Health();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetHealth();
		end
	end
end
Perl_CombatDisplay_Events.UNIT_MAXHEALTH = Perl_CombatDisplay_Events.UNIT_HEALTH;

function Perl_CombatDisplay_Events:UNIT_ENERGY()
	if (arg1 == "player") then
		if (UnitMana("player") == UnitManaMax("player")) then
			manafull = 1;
			if (manapersist == 1) then
				Perl_CombatDisplay_UpdateDisplay();
			end
		else
			manafull = 0;
		end
		Perl_CombatDisplay_Update_Mana();
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_Update_Mana();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetMana();
		end
	end
end
Perl_CombatDisplay_Events.UNIT_MAXENERGY = Perl_CombatDisplay_Events.UNIT_ENERGY;

function Perl_CombatDisplay_Events:UNIT_MANA()
	if (arg1 == "player") then
		if (UnitMana("player") == UnitManaMax("player")) then
			manafull = 1;
			if (manapersist == 1) then
				Perl_CombatDisplay_UpdateDisplay();
			end
		else
			manafull = 0;
		end
		Perl_CombatDisplay_Update_Mana();
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_Update_Mana();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetMana();
		end
	end
end
Perl_CombatDisplay_Events.UNIT_MAXMANA = Perl_CombatDisplay_Events.UNIT_MANA;

function Perl_CombatDisplay_Events:UNIT_RAGE()
	if (arg1 == "player") then
		if (UnitMana("player") == 0) then
			manafull = 1;
			if (manapersist == 1) then
				Perl_CombatDisplay_UpdateDisplay();
			end
		else
			manafull = 0;
		end
		Perl_CombatDisplay_Update_Mana();
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_Update_Mana();
	end
end
Perl_CombatDisplay_Events.UNIT_MAXRAGE = Perl_CombatDisplay_Events.UNIT_RAGE;
Perl_CombatDisplay_Events.UNIT_RUNIC_POWER = Perl_CombatDisplay_Events.UNIT_RAGE;
Perl_CombatDisplay_Events.UNIT_MAXRUNIC_POWER = Perl_CombatDisplay_Events.UNIT_RAGE;

function Perl_CombatDisplay_Events:UNIT_FOCUS()
	if (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetMana();
		end
	end
end
Perl_CombatDisplay_Events.UNIT_MAXFOCUS = Perl_CombatDisplay_Events.UNIT_FOCUS;

function Perl_CombatDisplay_Events:PLAYER_TARGET_CHANGED()
	Perl_CombatDisplay_UpdateDisplay();
	Perl_CombatDisplay_Update_Combo_Points();
end

function Perl_CombatDisplay_Events:UNIT_COMBO_POINTS()
	if (arg1 == "player" or arg1 == "vehicle") then
		Perl_CombatDisplay_Update_Combo_Points();
	end
end

function Perl_CombatDisplay_Events:PLAYER_REGEN_ENABLED()
	IsAggroed = 0;
	if (state == 3) then
		Perl_CombatDisplay_UpdateDisplay();
	end
end

function Perl_CombatDisplay_Events:PLAYER_REGEN_DISABLED()
	IsAggroed = 1;
	if (state == 3) then
		if (not InCombatLockdown()) then		-- REMOVE THIS CHECK WHEN YOU CAN
			Perl_CombatDisplay_Frame:Show();				-- Show the player frame if needed
			if (showtarget == 1) then
				RegisterUnitWatch(Perl_CombatDisplay_Target_Frame);	-- Register the target frame to show/hide on its own
			end
		end

		Perl_CombatDisplay_UpdateDisplay();
	end
end

function Perl_CombatDisplay_Events:UNIT_DISPLAYPOWER()
	if (arg1 == "player") then
		Perl_CombatDisplay_UpdateBars();
		Perl_CombatDisplay_Update_Mana();
		if (InCombat == 0 and IsAggroed == 0) then
			if (state == 1) then
				Perl_CombatDisplay_Frame:Show();
			else
				Perl_CombatDisplay_Frame:Hide();
			end
		end
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Target_UpdateBars();
		Perl_CombatDisplay_Target_Update_Mana();
	elseif (arg1 == "pet") then
		if (showpetbars == 1) then
			Perl_CombatDisplay_Update_PetManaBarColor();	-- What type of energy are we using now?
			Perl_CombatDisplay_Update_PetMana();		-- Update the energy info immediately
		end
	end
end

function Perl_CombatDisplay_Events:UNIT_AURA()
	if (arg1 == "player") then
		Perl_CombatDisplay_Buff_UpdateAll(arg1, Perl_CombatDisplay_ManaFrame);
	elseif (arg1 == "target") then
		Perl_CombatDisplay_Buff_UpdateAll(arg1, Perl_CombatDisplay_Target_ManaFrame);
	end
end

function Perl_CombatDisplay_Events:UNIT_PET()
	Perl_CombatDisplay_CheckForPets();
end

function Perl_CombatDisplay_Events:PLAYER_LOGIN()
	local powertype = UnitPowerType("player");
	InCombat = 0;
	IsAggroed = 0;

	if (UnitHealth("player") == UnitHealthMax("player")) then
		healthfull = 1;
	else
		healthfull = 0;
	end
	if (powertype == 0 or powertype == 3) then
		if (UnitMana("player") == UnitManaMax("player")) then
			manafull = 1;
		else
			manafull = 0;
		end
	elseif (powertype == 1) then
		if (UnitMana("player") == 0) then
			manafull = 1;
		else
			manafull = 0;
		end
	end

	Perl_CombatDisplay_Initialize();
end
Perl_CombatDisplay_Events.PLAYER_ENTERING_WORLD = Perl_CombatDisplay_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_CombatDisplay_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_CombatDisplay_UpdateBars();	-- what class are we? display the right color bars
		Perl_CombatDisplay_Update_Health();	-- make sure we dont display 0/0 on load
		Perl_CombatDisplay_Update_Mana();	-- make sure we dont display 0/0 on load
		Perl_CombatDisplay_UpdateDisplay();	-- what mode are we in?
		Perl_CombatDisplay_Set_Scale_Actual();	-- set the correct scale
		Perl_CombatDisplay_Set_Transparency();	-- set the transparency
		Perl_CombatDisplay_CheckForPets();	-- do we have a pet out?
		Perl_CombatDisplay_Update_Combo_Points();
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_CombatDisplay_Config[UnitName("player")]) == "table") then
		Perl_CombatDisplay_GetVars();
	else
		Perl_CombatDisplay_UpdateVars();
	end

	-- Major config options.
	Perl_CombatDisplay_Initialize_Frame_Color();
	Perl_CombatDisplay_Target_Frame:Hide();

	Perl_CombatDisplay_UpdateBars();		-- Display the bars appropriate to your class
	Perl_CombatDisplay_UpdateDisplay();		-- Show or hide the window based on whats happening
	Perl_CombatDisplay_CheckForPets();		-- do we have a pet out?

	Perl_CombatDisplay_Frame_Style();
	Perl_CombatDisplay_Buff_UpdateAll("player", Perl_CombatDisplay_ManaFrame);	-- call this so the energy ticker doesn't show up prematurely

	-- MyAddOns Support
	Perl_CombatDisplay_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_CombatDisplay_Frame:SetUserPlaced(1);
	Perl_CombatDisplay_Target_Frame:SetUserPlaced(1);

	Initialized = 1;
end

function Perl_CombatDisplay_Initialize_Frame_Color()
	Perl_CombatDisplay_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_ManaBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_CPBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_PetHealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_PetManaBarText:SetTextColor(1, 1, 1, 1);

	Perl_CombatDisplay_Target_ManaFrame:SetBackdropColor(0, 0, 0, 1);
	Perl_CombatDisplay_Target_ManaFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	Perl_CombatDisplay_Target_HealthBarText:SetTextColor(1, 1, 1, 1);
	Perl_CombatDisplay_Target_ManaBarText:SetTextColor(1, 1, 1, 1);
end


----------------------
-- Update Functions --
----------------------
function Perl_CombatDisplay_UpdateDisplay()
	Perl_CombatDisplay_Target_HealthBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_CombatDisplay_Target_ManaBarFadeBar:Hide();	-- Hide the fade bars so we don't see fading bars when we shouldn't
	Perl_CombatDisplay_Target_HealthBar:SetValue(0);	-- Do this so we don't fade the bar on a fresh target switch
	Perl_CombatDisplay_Target_ManaBar:SetValue(0);		-- Do this so we don't fade the bar on a fresh target switch

	if (state == 1) then
		Perl_CombatDisplay_Target_UpdateAll();
	elseif (state == 3) then
		if (IsAggroed == 1) then
			-- Do nothing
		elseif (manapersist == 1 and manafull == 0) then
			-- Do nothing
		elseif (healthpersist == 1 and healthfull == 0) then
			-- Do nothing
		else
			if (InCombatLockdown()) then						-- remove this line when zoning issue is fixed
				Perl_Config_Queue_Add(Perl_CombatDisplay_UpdateDisplay);	-- remove this line when zoning issue is fixed
			else									-- remove this line when zoning issue is fixed
				Perl_CombatDisplay_Frame:Hide();
				UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
				Perl_CombatDisplay_Target_Frame:Hide();
			end									-- remove this line when zoning issue is fixed
			return;
		end
		Perl_CombatDisplay_Target_UpdateAll();
	end
end

function Perl_CombatDisplay_Update_Health()
	playerhealth = UnitHealth("player");
	playerhealthmax = UnitHealthMax("player");

	if (UnitIsDead("player") or UnitIsGhost("player")) then				-- This prevents negative health
		playerhealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (playerhealth < Perl_CombatDisplay_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and playerhealth > Perl_CombatDisplay_HealthBar:GetValue())) then
			Perl_CombatDisplay_HealthBarFadeBar:SetMinMaxValues(0, playerhealthmax);
			Perl_CombatDisplay_HealthBarFadeBar:SetValue(Perl_CombatDisplay_HealthBar:GetValue());
			Perl_CombatDisplay_HealthBarFadeBar:Show();
			Perl_CombatDisplay_HealthBar_Fade_Color = 1;
			Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_HealthBar:SetMinMaxValues(0, playerhealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_HealthBar:SetValue(playerhealthmax - playerhealth);
	else
		Perl_CombatDisplay_HealthBar:SetValue(playerhealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local playerhealthpercent = floor(playerhealth/playerhealthmax*100+0.5);
--		if ((playerhealthpercent <= 100) and (playerhealthpercent > 75)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((playerhealthpercent <= 75) and (playerhealthpercent > 50)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((playerhealthpercent <= 50) and (playerhealthpercent > 25)) then
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
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

		Perl_CombatDisplay_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax);
	else
		Perl_CombatDisplay_HealthBarText:SetText(playerhealth.."/"..playerhealthmax.." | "..floor(playerhealth/playerhealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Update_Mana()
	playermana = UnitMana("player");
	playermanamax = UnitManaMax("player");
	playerpower = UnitPowerType("player");

	if (UnitIsDead("player") or UnitIsGhost("player")) then				-- This prevents negative mana
		playermana = 0;
	end

	if (playermana ~= playermanamax) then
		Perl_CombatDisplay_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_CombatDisplay_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (playermana < Perl_CombatDisplay_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and playermana > Perl_CombatDisplay_ManaBar:GetValue())) then
			Perl_CombatDisplay_ManaBarFadeBar:SetMinMaxValues(0, playermanamax);
			Perl_CombatDisplay_ManaBarFadeBar:SetValue(Perl_CombatDisplay_ManaBar:GetValue());
			Perl_CombatDisplay_ManaBarFadeBar:Show();
			Perl_CombatDisplay_ManaBar_Fade_Color = 1;
			Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_ManaBar:SetMinMaxValues(0, playermanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_ManaBar:SetValue(playermanamax - playermana);
	else
		Perl_CombatDisplay_ManaBar:SetValue(playermana);
	end

	Perl_CombatDisplay_Update_Mana_Text();

	if (showdruidbar == 1) then
		_, englishclass = UnitClass("player");
		if (englishclass == "DRUID") then
			if (playerpower > 0) then
				playerdruidbarmana = UnitPower("player", 0);
				playerdruidbarmanamax = UnitPowerMax("player", 0);
				playerdruidbarmanapercent = floor(playerdruidbarmana/playerdruidbarmanamax*100+0.5);

				if (playerdruidbarmanapercent == 100) then		-- This is to ensure the value isn't 1 or 2 mana under max when 100%
					playerdruidbarmana = playerdruidbarmanamax;
				end

		--		if (PCUF_FADEBARS == 1) then
		--			if (playerdruidbarmana < Perl_CombatDisplay_DruidBar:GetValue()) then
		--				Perl_CombatDisplay_DruidBarFadeBar:SetMinMaxValues(0, playerdruidbarmanamax);
		--				Perl_CombatDisplay_DruidBarFadeBar:SetValue(Perl_CombatDisplay_DruidBar:GetValue());
		--				Perl_CombatDisplay_DruidBarFadeBar:Show();
		--				Perl_CombatDisplay_DruidBar_Fade_Color = 1;
		--				Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;
		--				Perl_CombatDisplay_DruidBar_Fade_OnUpdate_Frame:Show();
		--			end
		--		end

				Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, playerdruidbarmanamax);
				if (PCUF_INVERTBARVALUES == 1) then
					Perl_CombatDisplay_DruidBar:SetValue(playerdruidbarmanamax - playerdruidbarmana);
				else
					Perl_CombatDisplay_DruidBar:SetValue(playerdruidbarmana);
				end

				-- Display the needed text
				if (displaypercents == 0) then
					Perl_CombatDisplay_DruidBarText:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax);
				else
					Perl_CombatDisplay_DruidBarText:SetText(playerdruidbarmana.."/"..playerdruidbarmanamax.." | "..playerdruidbarmanapercent.."%");
				end
			else
				-- Hide it all (bars and text)
				Perl_CombatDisplay_DruidBarText:SetText();
				Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
				Perl_CombatDisplay_DruidBar:SetValue(0);
			end
		else
			-- Hide it all (bars and text)
			Perl_CombatDisplay_DruidBarText:SetText();
			Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
			Perl_CombatDisplay_DruidBar:SetValue(0);
		end
	end
end

function Perl_CombatDisplay_Update_Mana_Text()
	if (playerpower == 1 or playerpower == 6) then
		Perl_CombatDisplay_ManaBarText:SetText(playermana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax);
		else
			Perl_CombatDisplay_ManaBarText:SetText(playermana.."/"..playermanamax.." | "..floor(playermana/playermanamax*100+0.5).."%");
		end
	end
end

function Perl_CombatDisplay_OnUpdate_ManaBar(arg1)
	Perl_CombatDisplay_ManaBar_Time_Elapsed = Perl_CombatDisplay_ManaBar_Time_Elapsed + arg1;
	if (Perl_CombatDisplay_ManaBar_Time_Elapsed > Perl_CombatDisplay_ManaBar_Time_Update_Rate) then
		Perl_CombatDisplay_ManaBar_Time_Elapsed = 0;

		playeronupdatemana = UnitPower("player", UnitPowerType("player"));
		if (playeronupdatemana ~= playermana) then
			playermana = playeronupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_ManaBar:SetValue(playermanamax - playeronupdatemana);
			else
				Perl_CombatDisplay_ManaBar:SetValue(playeronupdatemana);
			end
			Perl_CombatDisplay_Update_Mana_Text();
		end
	end
end

function Perl_CombatDisplay_Update_Combo_Points()
	if (showcp == 1) then
		local combopoints = GetComboPoints("vehicle","target");	-- How many Combo Points does the player have in their vehicle?
		if (combopoints == 0) then
			combopoints = GetComboPoints("player");		-- We aren't in a vehicle, get regular combo points
		end

		if (PCUF_FADEBARS == 1) then
			if (combopoints < Perl_CombatDisplay_CPBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and combopoints > Perl_CombatDisplay_CPBar:GetValue())) then
				Perl_CombatDisplay_CPBarFadeBar:SetMinMaxValues(0, 5);
				Perl_CombatDisplay_CPBarFadeBar:SetValue(Perl_CombatDisplay_CPBar:GetValue());
				Perl_CombatDisplay_CPBarFadeBar:Show();
				Perl_CombatDisplay_CPBar_Fade_Color = 1;
				Perl_CombatDisplay_CPBar_Fade_Time_Elapsed = 0;
				Perl_CombatDisplay_CPBar_Fade_OnUpdate_Frame:Show();
			end
		end

		Perl_CombatDisplay_CPBarText:SetText(combopoints..'/5');
		if (PCUF_INVERTBARVALUES == 1) then
			Perl_CombatDisplay_CPBar:SetValue(5 - combopoints);
		else
			Perl_CombatDisplay_CPBar:SetValue(combopoints);
		end
	end
end

function Perl_CombatDisplay_UpdateBars()
	playerpower = UnitPowerType("player");

	-- Set power type specific events and colors.
	if (playerpower == 0) then		-- mana
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		-- Hide CP Bar
		return;
	elseif (playerpower == 1) then		-- rage
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		-- Hide CP Bar
		return;
	elseif (playerpower == 3) then		-- energy
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		Perl_CombatDisplay_Update_Combo_Points();	-- Setup CP Bar
		return;
	elseif (playerpower == 6) then		-- runic
		Perl_CombatDisplay_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
		Perl_CombatDisplay_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
		-- Hide CP Bar
		return;
	end
end

function Perl_CombatDisplay_CheckForPets()
	if (showpetbars == 1 and UnitExists("pet")) then
		Perl_CombatDisplay_Update_PetManaBarColor();
		Perl_CombatDisplay_Update_PetHealth();
		Perl_CombatDisplay_Update_PetMana();
	else
		Perl_CombatDisplay_PetHealthBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_PetHealthBar:SetValue(0);
		Perl_CombatDisplay_PetHealthBarText:SetText();
		Perl_CombatDisplay_PetManaBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_PetManaBar:SetValue(0);
		Perl_CombatDisplay_PetManaBarText:SetText();
	end
end

function Perl_CombatDisplay_Update_PetManaBarColor()
	-- Set mana bar color
	if (UnitPowerType("pet") == 0) then			-- mana
		Perl_CombatDisplay_PetManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_PetManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	elseif (UnitPowerType("pet") == 2) then			-- focus
		Perl_CombatDisplay_PetManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_CombatDisplay_PetManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
	end
end

function Perl_CombatDisplay_Update_PetHealth()
	pethealth = UnitHealth("pet");
	pethealthmax = UnitHealthMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then				-- This prevents negative health
		pethealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (pethealth < Perl_CombatDisplay_PetHealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and pethealth > Perl_CombatDisplay_PetHealthBar:GetValue())) then
			Perl_CombatDisplay_PetHealthBarFadeBar:SetMinMaxValues(0, pethealthmax);
			Perl_CombatDisplay_PetHealthBarFadeBar:SetValue(Perl_CombatDisplay_PetHealthBar:GetValue());
			Perl_CombatDisplay_PetHealthBarFadeBar:Show();
			Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;
			Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_PetHealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_PetHealthBar:SetMinMaxValues(0, pethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_PetHealthBar:SetValue(pethealthmax - pethealth);
	else
		Perl_CombatDisplay_PetHealthBar:SetValue(pethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local pethealthpercent = floor(pethealth/pethealthmax*100+0.5);
--		if ((pethealthpercent <= 100) and (pethealthpercent > 75)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((pethealthpercent <= 75) and (pethealthpercent > 50)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((pethealthpercent <= 50) and (pethealthpercent > 25)) then
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = pethealth / pethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_PetHealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_PetHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_PetHealthBarText:SetText(pethealth.."/"..pethealthmax);
	else
		Perl_CombatDisplay_PetHealthBarText:SetText(pethealth.."/"..pethealthmax.." | "..floor(pethealth/pethealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Update_PetMana()
	petmana = UnitMana("pet");
	petmanamax = UnitManaMax("pet");

	if (UnitIsDead("pet") or UnitIsGhost("pet")) then				-- This prevents negative mana
		petmana = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (petmana < Perl_CombatDisplay_PetManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and petmana > Perl_CombatDisplay_PetManaBar:GetValue())) then
			Perl_CombatDisplay_PetManaBarFadeBar:SetMinMaxValues(0, petmanamax);
			Perl_CombatDisplay_PetManaBarFadeBar:SetValue(Perl_CombatDisplay_PetManaBar:GetValue());
			Perl_CombatDisplay_PetManaBarFadeBar:Show();
			Perl_CombatDisplay_PetManaBar_Fade_Color = 1;
			Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_PetManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_PetManaBar:SetMinMaxValues(0, petmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_PetManaBar:SetValue(petmanamax - petmana);
	else
		Perl_CombatDisplay_PetManaBar:SetValue(petmana);
	end

	if (UnitPowerType("pet") == 2) then
		Perl_CombatDisplay_PetManaBarText:SetText(petmana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_PetManaBarText:SetText(petmana.."/"..petmanamax);
		else
			Perl_CombatDisplay_PetManaBarText:SetText(petmana.."/"..petmanamax.." | "..floor(petmana/petmanamax*100+0.5).."%");
		end
	end
end


-------------------------------
-- Update Functions (Target) --
-------------------------------
function Perl_CombatDisplay_Target_UpdateAll()
	if (showtarget == 1) then
		if (UnitExists("target")) then
			Perl_CombatDisplay_Target_Update_Health();
			Perl_CombatDisplay_Target_Update_Mana();
			Perl_CombatDisplay_Target_UpdateBars();
			Perl_CombatDisplay_Buff_UpdateAll("target", Perl_CombatDisplay_Target_ManaFrame);
		end
	end
end

function Perl_CombatDisplay_Target_Update_Health()
	targethealth = UnitHealth("target");
	targethealthmax = UnitHealthMax("target");

	if (UnitIsDead("target") or UnitIsGhost("target")) then				-- This prevents negative health
		targethealth = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (targethealth < Perl_CombatDisplay_Target_HealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targethealth > Perl_CombatDisplay_Target_HealthBar:GetValue())) then
			Perl_CombatDisplay_Target_HealthBarFadeBar:SetMinMaxValues(0, targethealthmax);
			Perl_CombatDisplay_Target_HealthBarFadeBar:SetValue(Perl_CombatDisplay_Target_HealthBar:GetValue());
			Perl_CombatDisplay_Target_HealthBarFadeBar:Show();
			Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;
			Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_Target_HealthBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_Target_HealthBar:SetMinMaxValues(0, targethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_Target_HealthBar:SetValue(targethealthmax - targethealth);
	else
		Perl_CombatDisplay_Target_HealthBar:SetValue(targethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		local targethealthpercent = floor(targethealth/targethealthmax*100+0.5);
--		if ((targethealthpercent <= 100) and (targethealthpercent > 75)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((targethealthpercent <= 75) and (targethealthpercent > 50)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 1, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((targethealthpercent <= 50) and (targethealthpercent > 25)) then
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0.5, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(1, 0, 0);
--			Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
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

		Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(red, green, 0, 1);
		Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		Perl_CombatDisplay_Target_HealthBar:SetStatusBarColor(0, 0.8, 0);
		Perl_CombatDisplay_Target_HealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (displaypercents == 0) then
		Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax);
	else
		Perl_CombatDisplay_Target_HealthBarText:SetText(targethealth.."/"..targethealthmax.." | "..floor(targethealth/targethealthmax*100+0.5).."%");
	end
end

function Perl_CombatDisplay_Target_Update_Mana()
	targetmana = UnitMana("target");
	targetmanamax = UnitManaMax("target");
	targetpowertype = UnitPowerType("target");

	if (targetmanamax == 0) then
		Perl_CombatDisplay_Target_ManaBarText:SetText();
		return;
	end

	if (UnitIsDead("target") or UnitIsGhost("target")) then				-- This prevents negative mana
		targetmana = 0;
	end

	if (targetmana ~= targetmanamax) then
		Perl_CombatDisplay_Target_ManaBar_OnUpdate_Frame:Show();
	else
		Perl_CombatDisplay_Target_ManaBar_OnUpdate_Frame:Hide();
	end

	if (PCUF_FADEBARS == 1) then
		if (targetmana < Perl_CombatDisplay_Target_ManaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and targetmana > Perl_CombatDisplay_Target_ManaBar:GetValue())) then
			Perl_CombatDisplay_Target_ManaBarFadeBar:SetMinMaxValues(0, targetmanamax);
			Perl_CombatDisplay_Target_ManaBarFadeBar:SetValue(Perl_CombatDisplay_Target_ManaBar:GetValue());
			Perl_CombatDisplay_Target_ManaBarFadeBar:Show();
			Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;
			Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed = 0;
			Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame:Show();
		end
	end

	Perl_CombatDisplay_Target_ManaBar:SetMinMaxValues(0, targetmanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		Perl_CombatDisplay_Target_ManaBar:SetValue(targetmanamax - targetmana);
	else
		Perl_CombatDisplay_Target_ManaBar:SetValue(targetmana);
	end

	Perl_CombatDisplay_Target_Update_Mana_Text();
end

function Perl_CombatDisplay_Target_Update_Mana_Text()
	if (targetpowertype == 1 or targetpowertype == 2 or targetpowertype == 6) then
		Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana);
	else
		if (displaypercents == 0) then
			Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax);
		else
			Perl_CombatDisplay_Target_ManaBarText:SetText(targetmana.."/"..targetmanamax.." | "..floor(targetmana/targetmanamax*100+0.5).."%");
		end
	end
end

function Perl_CombatDisplay_Target_OnUpdate_ManaBar(arg1)
	Perl_CombatDisplay_Target_ManaBar_Time_Elapsed = Perl_CombatDisplay_Target_ManaBar_Time_Elapsed + arg1;
	if (Perl_CombatDisplay_Target_ManaBar_Time_Elapsed > Perl_CombatDisplay_Target_ManaBar_Time_Update_Rate) then
		Perl_CombatDisplay_Target_ManaBar_Time_Elapsed = 0;

		targetonupdatemana = UnitPower("target", UnitPowerType("target"));
		if (targetonupdatemana ~= targetmana) then
			targetmana = targetonupdatemana;
			if (PCUF_INVERTBARVALUES == 1) then
				Perl_CombatDisplay_Target_ManaBar:SetValue(targetmanamax - targetonupdatemana);
			else
				Perl_CombatDisplay_Target_ManaBar:SetValue(targetonupdatemana);
			end
			Perl_CombatDisplay_Target_Update_Mana_Text();
		end
	end
end

function Perl_CombatDisplay_Target_UpdateBars()
	targetmanamax = UnitManaMax("target");
	targetpowertype = UnitPowerType("target");

	-- Set power type specific events and colors.
	if (targetmanamax == 0) then
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0, 0, 0.25);
		Perl_CombatDisplay_Target_ManaBarText:SetText();
	elseif (targetpowertype == 0) then	-- mana
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0, 1, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		return;
	elseif (targetpowertype == 1) then	-- rage
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 0, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		return;
	elseif (targetpowertype == 2) then	-- focus
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 0.5, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		return;
	elseif (targetpowertype == 3) then	-- energy
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(1, 1, 0, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		return;
	elseif (targetpowertype == 6) then	-- runic
		Perl_CombatDisplay_Target_ManaBar:SetStatusBarColor(0, 0.82, 1, 1);
		Perl_CombatDisplay_Target_ManaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
		return;
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_CombatDisplay_HealthBar_Fade(arg1)
	Perl_CombatDisplay_HealthBar_Fade_Color = Perl_CombatDisplay_HealthBar_Fade_Color - arg1;
	Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed = Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_CombatDisplay_HealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_HealthBar_Fade_Color, 0, Perl_CombatDisplay_HealthBar_Fade_Color);

	if (Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_HealthBar_Fade_Color = 1;
		Perl_CombatDisplay_HealthBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_HealthBarFadeBar:Hide();
		Perl_CombatDisplay_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_ManaBar_Fade(arg1)
	Perl_CombatDisplay_ManaBar_Fade_Color = Perl_CombatDisplay_ManaBar_Fade_Color - arg1;
	Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed = Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed + arg1;

	if (playerpower == 0) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 1) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_ManaBar_Fade_Color, 0, 0, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 3) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color, 0, Perl_CombatDisplay_ManaBar_Fade_Color);
	elseif (playerpower == 6) then
		Perl_CombatDisplay_ManaBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color, Perl_CombatDisplay_ManaBar_Fade_Color);
	end

	if (Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_ManaBar_Fade_Color = 1;
		Perl_CombatDisplay_ManaBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_ManaBarFadeBar:Hide();
		Perl_CombatDisplay_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

--function Perl_CombatDisplay_DruidBar_Fade(arg1)
--	Perl_CombatDisplay_DruidBar_Fade_Color = Perl_CombatDisplay_DruidBar_Fade_Color - arg1;
--	Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed + arg1;
--
--	Perl_CombatDisplay_DruidBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_DruidBar_Fade_Color, Perl_CombatDisplay_DruidBar_Fade_Color);
--
--	if (Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed > 1) then
--		Perl_CombatDisplay_DruidBar_Fade_Color = 1;
--		Perl_CombatDisplay_DruidBar_Fade_Time_Elapsed = 0;
--		Perl_CombatDisplay_DruidBarFadeBar:Hide();
--		Perl_CombatDisplay_DruidBar_Fade_OnUpdate_Frame:Hide();
--	end
--end

function Perl_CombatDisplay_CPBar_Fade(arg1)
	Perl_CombatDisplay_CPBar_Fade_Color = Perl_CombatDisplay_CPBar_Fade_Color - arg1;
	Perl_CombatDisplay_CPBar_Fade_Time_Elapsed = Perl_CombatDisplay_CPBar_Fade_Time_Elapsed + arg1;

	Perl_CombatDisplay_CPBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_CPBar_Fade_Color, 0, 0, Perl_CombatDisplay_CPBar_Fade_Color);

	if (Perl_CombatDisplay_CPBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_CPBar_Fade_Color = 1;
		Perl_CombatDisplay_CPBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_CPBarFadeBar:Hide();
		Perl_CombatDisplay_CPBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_PetHealthBar_Fade(arg1)
	Perl_CombatDisplay_PetHealthBar_Fade_Color = Perl_CombatDisplay_PetHealthBar_Fade_Color - arg1;
	Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed = Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_CombatDisplay_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_PetHealthBar_Fade_Color, 0, Perl_CombatDisplay_PetHealthBar_Fade_Color);

	if (Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_PetHealthBar_Fade_Color = 1;
		Perl_CombatDisplay_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_PetHealthBarFadeBar:Hide();
		Perl_CombatDisplay_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_PetManaBar_Fade(arg1)
	Perl_CombatDisplay_PetManaBar_Fade_Color = Perl_CombatDisplay_PetManaBar_Fade_Color - arg1;
	Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed = Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("pet") == 0) then
		Perl_CombatDisplay_PetManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_PetManaBar_Fade_Color, Perl_CombatDisplay_PetManaBar_Fade_Color);
	elseif (UnitPowerType("pet") == 2) then
		Perl_CombatDisplay_PetManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_PetManaBar_Fade_Color, (Perl_CombatDisplay_PetManaBar_Fade_Color-0.5), 0, Perl_CombatDisplay_PetManaBar_Fade_Color);
	end

	if (Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_PetManaBar_Fade_Color = 1;
		Perl_CombatDisplay_PetManaBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_PetManaBarFadeBar:Hide();
		Perl_CombatDisplay_PetManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_Target_HealthBar_Fade(arg1)
	Perl_CombatDisplay_Target_HealthBar_Fade_Color = Perl_CombatDisplay_Target_HealthBar_Fade_Color - arg1;
	Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed = Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_CombatDisplay_Target_HealthBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_Target_HealthBar_Fade_Color, 0, Perl_CombatDisplay_Target_HealthBar_Fade_Color);

	if (Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_Target_HealthBar_Fade_Color = 1;
		Perl_CombatDisplay_Target_HealthBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_Target_HealthBarFadeBar:Hide();
		Perl_CombatDisplay_Target_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_CombatDisplay_Target_ManaBar_Fade(arg1)
	Perl_CombatDisplay_Target_ManaBar_Fade_Color = Perl_CombatDisplay_Target_ManaBar_Fade_Color - arg1;
	Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed = Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed + arg1;

	if (targetpowertype == 0) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 1) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, 0, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 2) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, (Perl_CombatDisplay_Target_ManaBar_Fade_Color-0.5), 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 3) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color, 0, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	elseif (targetpowertype == 6) then
		Perl_CombatDisplay_Target_ManaBarFadeBar:SetStatusBarColor(0, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color, Perl_CombatDisplay_Target_ManaBar_Fade_Color);
	end

	if (Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_CombatDisplay_Target_ManaBar_Fade_Color = 1;
		Perl_CombatDisplay_Target_ManaBar_Fade_Time_Elapsed = 0;
		Perl_CombatDisplay_Target_ManaBarFadeBar:Hide();
		Perl_CombatDisplay_Target_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_CombatDisplay_Frame_Style()
	_, englishclass = UnitClass("player");

	Perl_CombatDisplay_ManaFrame:SetHeight(42);
	Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(42);

	if (state == 0) then						-- Always Hidden
		Perl_CombatDisplay_Frame:Hide();
		UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		Perl_CombatDisplay_Target_Frame:Hide();
	elseif (state == 1) then					-- Always Shown
		Perl_CombatDisplay_Frame:Show();
		if (showtarget == 1) then
			Perl_CombatDisplay_Target_UpdateAll();
			RegisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		else
			UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
			Perl_CombatDisplay_Target_Frame:Hide();
		end
	elseif (state == 3) then					-- On Agro
		UnregisterUnitWatch(Perl_CombatDisplay_Target_Frame);
		Perl_CombatDisplay_Target_Frame:Hide();
	end

	if (showdruidbar == 1 and englishclass == "DRUID") then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 12);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 12);
		Perl_CombatDisplay_DruidBar:Show();
		Perl_CombatDisplay_DruidBarBG:Show();
		Perl_CombatDisplay_DruidBar:SetMinMaxValues(0, 1);
		Perl_CombatDisplay_DruidBar:SetValue(0);
		Perl_CombatDisplay_DruidBarText:SetText();
		Perl_CombatDisplay_DruidBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_ManaBar", "BOTTOMLEFT", 0, -2);
	else
		Perl_CombatDisplay_DruidBar:Hide();
		Perl_CombatDisplay_DruidBarBG:Hide();
	end

	if (showcp == 1) then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 12);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 12);
		Perl_CombatDisplay_CPBar:Show();
		Perl_CombatDisplay_CPBarBG:Show();
		Perl_CombatDisplay_CPBar:SetMinMaxValues(0, 5);
		if (showdruidbar == 1 and englishclass == "DRUID") then
			Perl_CombatDisplay_CPBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_DruidBar", "BOTTOMLEFT", 0, -2);
		else
			Perl_CombatDisplay_CPBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_ManaBar", "BOTTOMLEFT", 0, -2);
		end
	else
		Perl_CombatDisplay_CPBar:Hide();
		Perl_CombatDisplay_CPBarBG:Hide();
	end

	if (showpetbars == 1) then
		Perl_CombatDisplay_ManaFrame:SetHeight(Perl_CombatDisplay_ManaFrame:GetHeight() + 24);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:SetHeight(Perl_CombatDisplay_ManaFrame_CastClickOverlay:GetHeight() + 24);
		Perl_CombatDisplay_PetHealthBar:Show();
		Perl_CombatDisplay_PetHealthBarBG:Show();
		Perl_CombatDisplay_PetManaBar:Show();
		Perl_CombatDisplay_PetManaBarBG:Show();
		if (showdruidbar == 1 and showcp == 0 and englishclass == "DRUID") then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_DruidBar", "BOTTOMLEFT", 0, -2);
		elseif (showdruidbar == 1 and showcp == 1 and englishclass == "DRUID") then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_CPBar", "BOTTOMLEFT", 0, -2);
		elseif (showcp == 1) then
			Perl_CombatDisplay_PetHealthBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_CPBar", "BOTTOMLEFT", 0, -2);
		end
		Perl_CombatDisplay_PetManaBar:SetPoint("TOPLEFT", "Perl_CombatDisplay_PetHealthBar", "BOTTOMLEFT", 0, -2);
	else
		Perl_CombatDisplay_PetHealthBar:Hide();
		Perl_CombatDisplay_PetHealthBarBG:Hide();
		Perl_CombatDisplay_PetManaBar:Hide();
		Perl_CombatDisplay_PetManaBarBG:Hide();
	end

	if (clickthrough == 1) then
		Perl_CombatDisplay_Frame:EnableMouse(0);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:EnableMouse(0);
		Perl_CombatDisplay_Target_Frame:EnableMouse(0);
		Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:EnableMouse(0);
	else
		Perl_CombatDisplay_Frame:EnableMouse(1);
		Perl_CombatDisplay_ManaFrame_CastClickOverlay:EnableMouse(1);
		Perl_CombatDisplay_Target_Frame:EnableMouse(1);
		Perl_CombatDisplay_Target_ManaFrame_CastClickOverlay:EnableMouse(1);
	end

	Perl_CombatDisplay_Update_Mana();
	Perl_CombatDisplay_Update_Combo_Points();
	Perl_CombatDisplay_CheckForPets();
	Perl_CombatDisplay_UpdateDisplay();
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_CombatDisplay_Align_Horizontally()
	Perl_CombatDisplay_Frame:SetUserPlaced(1);
	Perl_CombatDisplay_Target_Frame:SetUserPlaced(1);
	Perl_CombatDisplay_Frame:ClearAllPoints();
	Perl_CombatDisplay_Target_Frame:ClearAllPoints();
	Perl_CombatDisplay_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ((UIParent:GetWidth() / 2) / (1 - UIParent:GetEffectiveScale() + scale)) - (Perl_CombatDisplay_Frame:GetWidth() / 2), floor(Perl_CombatDisplay_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Frame:GetScale()) + 0.5))
	Perl_CombatDisplay_Target_Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ((UIParent:GetWidth() / 2) / (1 - UIParent:GetEffectiveScale() + scale)) - (Perl_CombatDisplay_Target_Frame:GetWidth() / 2), floor(Perl_CombatDisplay_Target_Frame:GetTop() - (UIParent:GetTop() / Perl_CombatDisplay_Target_Frame:GetScale()) + 0.5))
end

function Perl_CombatDisplay_Set_State(newvalue)
	state = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Health_Persistance(newvalue)
	healthpersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Mana_Persistance(newvalue)
	manapersist = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Lock(newvalue)
	locked = newvalue;
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Target(newvalue)
	showtarget = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_DruidBar(newvalue)
	showdruidbar = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_PetBars(newvalue)
	showpetbars = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Right_Click(newvalue)
	rightclickmenu = newvalue;
	Perl_CombatDisplay_UpdateVars();
end

function Perl_CombatDisplay_Set_Display_Percents(newvalue)
	displaypercents = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Update_Health();
	Perl_CombatDisplay_Update_Mana();
	Perl_CombatDisplay_Target_UpdateAll();
end

function Perl_CombatDisplay_Set_ComboPoint_Bars(newvalue)
	showcp = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Click_Through(newvalue)
	clickthrough = newvalue;
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Frame_Style();
end

function Perl_CombatDisplay_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);					-- convert the user input to a wow acceptable value
	end
	Perl_CombatDisplay_UpdateVars();
	Perl_CombatDisplay_Set_Scale_Actual();
end

function Perl_CombatDisplay_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_CombatDisplay_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
		Perl_CombatDisplay_Frame:SetScale(unsavedscale);
		Perl_CombatDisplay_Target_Frame:SetScale(unsavedscale);
	end
end

function Perl_CombatDisplay_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);				-- convert the user input to a wow acceptable value
	end
	Perl_CombatDisplay_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_Target_Frame:SetAlpha(transparency);
	Perl_CombatDisplay_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_CombatDisplay_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	state = Perl_CombatDisplay_Config[name]["State"];
	locked = Perl_CombatDisplay_Config[name]["Locked"];
	healthpersist = Perl_CombatDisplay_Config[name]["HealthPersist"];
	manapersist = Perl_CombatDisplay_Config[name]["ManaPersist"];
	scale = Perl_CombatDisplay_Config[name]["Scale"];
	transparency = Perl_CombatDisplay_Config[name]["Transparency"];
	showtarget = Perl_CombatDisplay_Config[name]["ShowTarget"];
	showdruidbar = Perl_CombatDisplay_Config[name]["ShowDruidBar"];
	showpetbars = Perl_CombatDisplay_Config[name]["ShowPetBars"];
	rightclickmenu = Perl_CombatDisplay_Config[name]["RightClickMenu"];
	displaypercents = Perl_CombatDisplay_Config[name]["DisplayPercents"];
	showcp = Perl_CombatDisplay_Config[name]["ShowCP"];
	clickthrough = Perl_CombatDisplay_Config[name]["ClickThrough"];

	if (state == nil) then
		state = 3;
	end
	if (locked == nil) then
		locked = 0;
	end
	if (healthpersist == nil) then
		healthpersist = 0;
	end
	if (manapersist == nil) then
		manapersist = 0;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (showtarget == nil) then
		showtarget = 0;
	end
	if (showdruidbar == nil) then
		showdruidbar = 0;
	end
	if (showpetbars == nil) then
		showpetbars = 0;
	end
	if (rightclickmenu == nil) then
		rightclickmenu = 0;
	end
	if (displaypercents == nil) then
		displaypercents = 0;
	end
	if (showcp == nil) then
		showcp = 0;
	end
	if (clickthrough == nil) then
		clickthrough = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_CombatDisplay_UpdateVars();

		-- Call any code we need to activate them
		Perl_CombatDisplay_Set_Target(showtarget)
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Update_Mana();
		Perl_CombatDisplay_Set_Scale_Actual()
		Perl_CombatDisplay_Set_Transparency()
		Perl_CombatDisplay_UpdateDisplay();
		return;
	end

	local vars = {
		["state"] = state,
		["manapersist"] = manapersist,
		["healthpersist"] = healthpersist,
		["locked"] = locked,
		["scale"] = scale,
		["transparency"] = transparency,
		["showtarget"] = showtarget,
		["showdruidbar"] = showdruidbar,
		["showpetbars"] = showpetbars,
		["rightclickmenu"] = rightclickmenu,
		["displaypercents"] = displaypercents,
		["showcp"] = showcp,
		["clickthrough"] = clickthrough,
	}
	return vars;
end

function Perl_CombatDisplay_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["State"] ~= nil) then
				state = vartable["Global Settings"]["State"];
			else
				state = nil;
			end
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["HealthPersist"] ~= nil) then
				healthpersist = vartable["Global Settings"]["HealthPersist"];
			else
				healthpersist = nil;
			end
			if (vartable["Global Settings"]["ManaPersist"] ~= nil) then
				manapersist = vartable["Global Settings"]["ManaPersist"];
			else
				manapersist = nil;
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
			if (vartable["Global Settings"]["ShowTarget"] ~= nil) then
				showtarget = vartable["Global Settings"]["ShowTarget"];
			else
				showtarget = nil;
			end
			if (vartable["Global Settings"]["ShowDruidBar"] ~= nil) then
				showdruidbar = vartable["Global Settings"]["ShowDruidBar"];
			else
				showdruidbar = nil;
			end
			if (vartable["Global Settings"]["ShowPetBars"] ~= nil) then
				showpetbars = vartable["Global Settings"]["ShowPetBars"];
			else
				showpetbars = nil;
			end
			if (vartable["Global Settings"]["RightClickMenu"] ~= nil) then
				rightclickmenu = vartable["Global Settings"]["RightClickMenu"];
			else
				rightclickmenu = nil;
			end
			if (vartable["Global Settings"]["DisplayPercents"] ~= nil) then
				displaypercents = vartable["Global Settings"]["DisplayPercents"];
			else
				displaypercents = nil;
			end
			if (vartable["Global Settings"]["ShowCP"] ~= nil) then
				showcp = vartable["Global Settings"]["ShowCP"];
			else
				showcp = nil;
			end
			if (vartable["Global Settings"]["ClickThrough"] ~= nil) then
				clickthrough = vartable["Global Settings"]["ClickThrough"];
			else
				clickthrough = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (state == nil) then
			state = 3;
		end
		if (locked == nil) then
			locked = 0;
		end
		if (healthpersist == nil) then
			healthpersist = 0;
		end
		if (manapersist == nil) then
			manapersist = 0;
		end
		if (scale == nil) then
			scale = 0.9;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (showtarget == nil) then
			showtarget = 0;
		end
		if (showdruidbar == nil) then
			showdruidbar = 0;
		end
		if (showpetbars == nil) then
			showpetbars = 0;
		end
		if (rightclickmenu == nil) then
			rightclickmenu = 0;
		end
		if (displaypercents == nil) then
			displaypercents = 0;
		end
		if (showcp == nil) then
			showcp = 0;
		end
		if (clickthrough == nil) then
			clickthrough = 0;
		end

		-- Call any code we need to activate them
		Perl_CombatDisplay_Set_Target(showtarget)
		Perl_CombatDisplay_Target_Update_Health();
		Perl_CombatDisplay_Update_Mana();
		Perl_CombatDisplay_Set_Scale_Actual()
		Perl_CombatDisplay_Set_Transparency()
		Perl_CombatDisplay_UpdateDisplay();
	end

	Perl_CombatDisplay_Config[UnitName("player")] = {
		["State"] = state,
		["Locked"] = locked,
		["HealthPersist"] = healthpersist,
		["ManaPersist"] = manapersist,
		["Scale"] = scale,
		["Transparency"] = transparency,
		["ShowTarget"] = showtarget,
		["ShowDruidBar"] = showdruidbar,
		["ShowPetBars"] = showpetbars,
		["RightClickMenu"] = rightclickmenu,
		["DisplayPercents"] = displaypercents,
		["ShowCP"] = showcp,
		["ClickThrough"] = clickthrough,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_CombatDisplay_Buff_UpdateAll(unit, frame)
	local debuffType;
	local curableDebuffFound = 0;

	for debuffnum=1,40 do											-- Start main debuff loop
		_, _, _, _, debuffType, _, _ = UnitDebuff(unit, debuffnum, 1);		-- Get the texture and debuff stacking information if any
		if (PCUF_COLORFRAMEDEBUFF == 1) then
			if (curableDebuffFound == 0) then
				if (UnitIsFriend("player", unit)) then
					if (debuffType) then
						if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
							local color = DebuffTypeColor[debuffType];
							frame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
							curableDebuffFound = 1;
							break;
						end
					end
				end
			end
		end
	end

	if (curableDebuffFound == 0) then
		frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


-------------------
-- Click Handler --
-------------------
function Perl_CombatDisplay_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_CombatDisplay_DropDown, "Perl_CombatDisplay_Frame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "player", showmenu);

	self:SetAttribute("unit", "player");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_CombatDisplayDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_CombatDisplayDropDown_Initialize, "MENU");
end

function Perl_CombatDisplayDropDown_Initialize()
	if (rightclickmenu == 1) then
		UnitPopup_ShowMenu(Perl_CombatDisplay_DropDown, "SELF", "player");
	end
end

function Perl_CombatDisplay_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_DragStop(button)
	Perl_CombatDisplay_Frame:StopMovingOrSizing();
end


function Perl_CombatDisplayTargetDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_CombatDisplayTargetDropDown_Initialize, "MENU");
end

function Perl_CombatDisplayTargetDropDown_Initialize()
	if (rightclickmenu == 1) then
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
			UnitPopup_ShowMenu(Perl_CombatDisplay_Target_DropDown, menu, "target", name, id);
		end
	end
end

function Perl_CombatDisplay_Target_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, Perl_CombatDisplay_Target_DropDown, "Perl_CombatDisplay_Target_Frame", 40, 0);
	end
	SecureUnitButton_OnLoad(self, "target", showmenu);

	self:SetAttribute("unit", "target");
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_CombatDisplay_Target_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_CombatDisplay_Target_Frame:StartMoving();
	end
end

function Perl_CombatDisplay_Target_DragStop(button)
	Perl_CombatDisplay_Target_Frame:StopMovingOrSizing();
end


----------------------
-- myAddOns Support --
----------------------
function Perl_CombatDisplay_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_CombatDisplay_myAddOns_Details = {
			name = "Perl_CombatDisplay",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_CombatDisplay_myAddOns_Help = {};
		Perl_CombatDisplay_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_CombatDisplay_myAddOns_Details, Perl_CombatDisplay_myAddOns_Help);
	end
end
