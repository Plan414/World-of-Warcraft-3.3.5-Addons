---------------
-- Variables --
---------------
Perl_Party_Target_Config = {};
local Perl_Party_Target_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Party_Target_GetVars)
local locked = 0;		-- unlocked by default
local scale = 0.9;		-- default scale for party target
local focusscale = 0.9;		-- default scale for focus target
local transparency = 1;		-- transparency for frames
local hidepowerbars = 0;	-- Power bars are shown by default
local classcolorednames = 0;	-- names are colored based on pvp status by default
local enabled = 1;		-- mod is shown by default
local partyhiddeninraid = 0;	-- party target is not hidden in raids by default
local enabledfocus = 1;		-- focus target is on by default
local focushiddeninraid = 0;	-- focus target is not hidden in raids by default


-- Default Local Variables
local Initialized = nil;			-- waiting to be initialized
local Perl_Party_Target_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Time_Update_Rate = 0.2;	-- the update interval
local mouseoverhealthflag = 0;			-- is the mouse over the health bar?
local mouseovermanaflag = 0;			-- is the mouse over the mana bar?
local Perl_Party_Target_One_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Two_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Three_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Four_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Five_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_One_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Two_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Three_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Four_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Target_Five_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0

-- Local variables to save memory
local r, g, b, currentunit, partytargethealth, partytargethealthmax, partytargethealthpercent, partytargetmana, partytargetmanamax, partytargetpower, englishclass, raidpartytargetindex;


----------------------
-- Loading Function --
----------------------
function Perl_Party_Target_Script_OnLoad(self)
	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("RAID_ROSTER_UPDATE");

	-- Scripts
	self:SetScript("OnEvent", Perl_Party_Target_Script_OnEvent);
	self:SetScript("OnUpdate", Perl_Party_Target_OnUpdate);
end

function Perl_Party_Target_OnLoad(self)
	self.id = self:GetID();
	if (self.id == 5) then
		self.unit = "focustarget";
	else
		self.unit = "party"..self.id.."target";
	end

	self.nameFrame = getglobal("Perl_Party_Target"..self.id.."_NameFrame");
	self.nameText = getglobal("Perl_Party_Target"..self.id.."_NameFrame_NameBarText");
	self.raidIcon = getglobal("Perl_Party_Target"..self.id.."_RaidIconFrame_RaidTargetIcon");
	self.statsFrame = getglobal("Perl_Party_Target"..self.id.."_StatsFrame");

	self.healthBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBar");
	self.healthBarBG = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBarBG");
	self.healthBarText = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBar_HealthBarText");
	self.healthBarFadeBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_HealthBarFadeBar");
	self.manaBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBar");
	self.manaBarBG = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBarBG");
	self.manaBarText = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBar_ManaBarText");
	self.manaBarFadeBar = getglobal("Perl_Party_Target"..self.id.."_StatsFrame_ManaBarFadeBar");
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_Target_Script_OnEvent()
	local func = Perl_Party_Target_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party Target: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Target_Events:RAID_ROSTER_UPDATE()
	Perl_Party_Target_Check_Hidden();
end

function Perl_Party_Target_Events:PLAYER_LOGIN()
	Perl_Party_Target_Initialize();
end
Perl_Party_Target_Events.PLAYER_ENTERING_WORLD = Perl_Party_Target_Events.PLAYER_LOGIN;


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Target_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Party_Target_Set_Scale_Actual();		-- Set the frame scale
		Perl_Party_Target_Set_Transparency();		-- Set the frame transparency
		Perl_Party_Target_Check_Hidden();		-- Hide the frames if in a raid
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Target_Config[UnitName("player")]) == "table") then
		Perl_Party_Target_GetVars();
	else
		Perl_Party_Target_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Target_Initialize_Frame_Color();		-- Color the frame borders
	Perl_Party_Target_Frame_Style();			-- Initialize the mod and set any frame settings

	-- Set the ID of the frame
	for num=1,5 do
		getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetID(num);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetID(num);
	end

	-- Button Click Overlays (in order of occurrence in XML)
	for num=1,5 do
		getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_NameFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_Target"..num.."_RaidIconFrame"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_NameFrame_CastClickOverlay"):GetFrameLevel() - 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame_HealthBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_Target"..num.."_StatsFrame_ManaBar"):GetFrameLevel() - 1);
	end

	-- MyAddOns Support
	Perl_Party_Target_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	for num=1,5 do
		getglobal("Perl_Party_Target"..num):SetUserPlaced(1);
	end

	Initialized = 1;
end

function Perl_Party_Target_Initialize_Frame_Color()
	for partynum=1,5 do
		getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_Target"..partynum.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetTextColor(1, 1, 1, 1);
		getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetTextColor(1, 1, 1, 1);
	end
end


-------------------------
-- The Update Function --
-------------------------
function Perl_Party_Target_OnUpdate()
	Perl_Party_Target_Time_Elapsed = Perl_Party_Target_Time_Elapsed + arg1;
	if (Perl_Party_Target_Time_Elapsed > Perl_Party_Target_Time_Update_Rate) then
		Perl_Party_Target_Time_Elapsed = 0;
		if (UnitExists(Perl_Party_Target1:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target1);
		end
		if (UnitExists(Perl_Party_Target2:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target2);
		end
		if (UnitExists(Perl_Party_Target3:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target3);
		end
		if (UnitExists(Perl_Party_Target4:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target4);
		end
		if (UnitExists(Perl_Party_Target5:GetAttribute("unit"))) then
			Perl_Party_Target_Work(Perl_Party_Target5);
		end
	end
end

function Perl_Party_Target_Work(self)
	-- Begin: Set the name
	self.nameText:SetText(UnitName(self.unit));
	-- End: Set the name

	-- Begin: Set the name text color
	if (UnitPlayerControlled(self.unit)) then						-- is it a player
		if (UnitCanAttack(self.unit, "player")) then					-- are we in an enemy controlled zone
			-- Hostile players are red
			if (not UnitCanAttack("player", self.unit)) then			-- enemy is not pvp enabled
				r = 0.5;
				g = 0.5;
				b = 1.0;
			else									-- enemy is pvp enabled
				r = 1.0;
				g = 0.0;
				b = 0.0;
			end
		elseif (UnitCanAttack("player", self.unit)) then				-- enemy in a zone controlled by friendlies or when we're a ghost
			-- Players we can attack but which are not hostile are yellow
			r = 1.0;
			g = 1.0;
			b = 0.0;
		elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
		self.nameText:SetTextColor(r, g, b);
	elseif (UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
		self.nameText:SetTextColor(0.5,0.5,0.5);					-- not our tap
	else
		if (UnitIsVisible(self.unit)) then
			reaction = UnitReaction(self.unit, "player");
			if (reaction) then
				r = FACTION_BAR_COLORS[reaction].r;
				g = FACTION_BAR_COLORS[reaction].g;
				b = FACTION_BAR_COLORS[reaction].b;
				self.nameText:SetTextColor(r, g, b);
			else
				self.nameText:SetTextColor(0.5, 0.5, 1.0);
			end
		else
			if (UnitCanAttack(self.unit, "player")) then					-- are we in an enemy controlled zone
				-- Hostile players are red
				if (not UnitCanAttack("player", self.unit)) then			-- enemy is not pvp enabled
					r = 0.5;
					g = 0.5;
					b = 1.0;
				else									-- enemy is pvp enabled
					r = 1.0;
					g = 0.0;
					b = 0.0;
				end
			elseif (UnitCanAttack("player", self.unit)) then				-- enemy in a zone controlled by friendlies or when we're a ghost
				-- Players we can attack but which are not hostile are yellow
				r = 1.0;
				g = 1.0;
				b = 0.0;
			elseif (UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit) and not UnitIsPVPSanctuary("player")) then	-- friendly pvp enabled character
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
			self.nameText:SetTextColor(r, g, b);
		end
	end

	if (classcolorednames == 1) then
		if (UnitIsPlayer(self.unit)) then
			_, englishclass = UnitClass(self.unit);
			self.nameText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
		end
	end
	-- End: Set the name text color

	-- Begin: Update the health bar
	partytargethealth = UnitHealth(self.unit);
	partytargethealthmax = UnitHealthMax(self.unit);
	partytargethealthpercent = floor(partytargethealth/partytargethealthmax*100+0.5);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative health
		partytargethealth = 0;
		partytargethealthpercent = 0;
	end

	Perl_Party_Target_HealthBar_Fade_Check(self);

	self.healthBar:SetMinMaxValues(0, partytargethealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		self.healthBar:SetValue(partytargethealthmax - partytargethealth);
	else
		self.healthBar:SetValue(partytargethealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((partytargethealthpercent <= 100) and (partytargethealthpercent > 75)) then
--			self.healthBar:SetStatusBarColor(0, 0.8, 0);
--			self.healthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((partytargethealthpercent <= 75) and (partytargethealthpercent > 50)) then
--			self.healthBar:SetStatusBarColor(1, 1, 0);
--			self.healthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((partytargethealthpercent <= 50) and (partytargethealthpercent > 25)) then
--			self.healthBar:SetStatusBarColor(1, 0.5, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			self.healthBar:SetStatusBarColor(1, 0, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = partytargethealth / partytargethealthmax;
		local red, green;

		if(rawpercent > 0.5) then
			red = (1.0 - rawpercent) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = rawpercent * 2;
		end

		self.healthBar:SetStatusBarColor(red, green, 0, 1);
		self.healthBarBG:SetStatusBarColor(red, green, 0, 0.25);
	else
		self.healthBar:SetStatusBarColor(0, 0.8, 0);
		self.healthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
	end

	if (tonumber(mouseoverhealthflag) == tonumber(self.id)) then
		Perl_Party_Target_HealthShow(self);
	else
		self.healthBarText:SetText(partytargethealthpercent.."%");
	end
	-- End: Update the health bar

	if (hidepowerbars == 0) then
		-- Begin: Update the mana bar color
		partytargetpower = UnitPowerType(self.unit);

		-- Set mana bar color
		if (UnitManaMax(self.unit) == 0) then
			self.manaBar:SetStatusBarColor(0, 0, 0, 0);
			self.manaBarBG:SetStatusBarColor(0, 0, 0, 0);
		elseif (partytargetpower == 1) then
			self.manaBar:SetStatusBarColor(1, 0, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
		elseif (partytargetpower == 2) then
			self.manaBar:SetStatusBarColor(1, 0.5, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
		elseif (partytargetpower == 3) then
			self.manaBar:SetStatusBarColor(1, 1, 0, 1);
			self.manaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
		elseif (partytargetpower == 6) then
			self.manaBar:SetStatusBarColor(0, 0.82, 1, 1);
			self.manaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
		else
			self.manaBar:SetStatusBarColor(0, 0, 1, 1);
			self.manaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
		end
		-- End: Update the mana bar color

		-- Begin: Update the mana bar
		partytargetmana = UnitMana(self.unit);
		partytargetmanamax = UnitManaMax(self.unit);

		if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative mana
			partytargetmana = 0;
		end

		Perl_Party_Target_ManaBar_Fade_Check(self);

		self.manaBar:SetMinMaxValues(0, partytargetmanamax);
		if (PCUF_INVERTBARVALUES == 1) then
			self.manaBar:SetValue(partytargetmanamax - partytargetmana);
		else
			self.manaBar:SetValue(partytargetmana);
		end

		if (tonumber(mouseovermanaflag) == tonumber(self.id)) then
			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 2 or UnitPowerType(self.unit) == 6) then
				self.manaBarText:SetText(partytargetmana);
			else
				self.manaBarText:SetText(partytargetmana.."/"..partytargetmanamax);
			end
		else
			self.manaBarText:SetText();
		end
		-- End: Update the mana bar
	end

	-- Begin: Raid Icon
	Perl_Party_Target_Update_Raid_Icon(self);
	-- End: Raid Icon

	-- Begin: Update buffs and debuffs
	Perl_Party_Target_Update_Buffs(self);
	-- End: Update buffs and debuffs
end

function Perl_Party_Target_HealthShow(self)
	partytargethealth = UnitHealth(self.unit);
	partytargethealthmax = UnitHealthMax(self.unit);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then				-- This prevents negative health
		partytargethealth = 0;
		partytargethealthpercent = 0;
	end

	self.healthBarText:SetText(partytargethealth.."/"..partytargethealthmax);
	mouseoverhealthflag = self.id;
end

function Perl_Party_Target_HealthHide(self)
	self.healthBarText:SetText(floor(UnitHealth(self.unit)/UnitHealthMax(self.unit)*100+0.5));
	mouseoverhealthflag = 0;
end

function Perl_Party_Target_ManaShow(self)
	partytargetmana = UnitMana(self.unit);
	partytargetmanamax = UnitManaMax(self.unit);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then						-- This prevents negative mana
		partytargetmana = 0;
	end

	if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 2 or UnitPowerType(self.unit) == 6) then
		self.manaBarText:SetText(partytargetmana);
	else
		self.manaBarText:SetText(partytargetmana.."/"..partytargetmanamax);
	end
	mouseovermanaflag = self.id;
end

function Perl_Party_Target_ManaHide(self)
	self.manaBarText:SetText();
	mouseovermanaflag = 0;
end

function Perl_Party_Target_Update_Raid_Icon(self)
	raidpartytargetindex = GetRaidTargetIndex(self.unit);
	if (raidpartytargetindex) then
		SetRaidTargetIconTexture(self.raidIcon, raidpartytargetindex);
		self.raidIcon:Show();
	else
		self.raidIcon:Hide();
	end
end

function Perl_Party_Target_Update_Buffs(self)
	local debuffType;
	local curableDebuffFound = 0;

	for debuffnum=1,40 do											-- Start main debuff loop
		_, _, _, _, debuffType, _, _ = UnitDebuff(self.unit, debuffnum, 1);		-- Get the texture and debuff stacking information if any
		if (debuffType) then
			if (PCUF_COLORFRAMEDEBUFF == 1) then
				if (curableDebuffFound == 0) then
					if (UnitIsFriend("player", self.unit)) then
						local color = DebuffTypeColor[debuffType];
						self.nameFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
						self.statsFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
						curableDebuffFound = 1;
						break;
					end
				end
			end
		end
	end

	if (curableDebuffFound == 0) then
		self.nameFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		self.statsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Party_Target_HealthBar_Fade_Check(self)
	if (PCUF_FADEBARS == 1) then
		if (partytargethealth < self.healthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partytargethealth > self.healthBar:GetValue())) then
			self.healthBarFadeBar:SetMinMaxValues(0, partytargethealthmax);
			self.healthBarFadeBar:SetValue(self.healthBar:GetValue());
			self.healthBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			getglobal("Perl_Party_Target"..self.id.."_HealthBar_Fade_OnUpdate_Frame"):Show();
		end
	end
end

function Perl_Party_Target_ManaBar_Fade_Check(self)
	if (PCUF_FADEBARS == 1) then
		if (partytargetmana < self.manaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partytargetmana > self.manaBar:GetValue())) then
			self.manaBarFadeBar:SetMinMaxValues(0, partytargetmanamax);
			self.manaBarFadeBar:SetValue(self.manaBar:GetValue());
			self.manaBarFadeBar:Show();
			-- We don't reset the values since this breaks fading due to not using individual variables for all 4 frames (not a big deal, still looks fine)
			getglobal("Perl_Party_Target"..self.id.."_ManaBar_Fade_OnUpdate_Frame"):Show();
		end
	end
end

function Perl_Party_Target_One_HealthBar_Fade(arg1)
	Perl_Party_Target_One_HealthBar_Fade_Color = Perl_Party_Target_One_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target1_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_One_HealthBar_Fade_Color, 0, Perl_Party_Target_One_HealthBar_Fade_Color);

	if (Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_One_HealthBar_Fade_Color = 1;
		Perl_Party_Target_One_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target1_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target1_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_HealthBar_Fade(arg1)
	Perl_Party_Target_Two_HealthBar_Fade_Color = Perl_Party_Target_Two_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target2_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Two_HealthBar_Fade_Color, 0, Perl_Party_Target_Two_HealthBar_Fade_Color);

	if (Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Two_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Two_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target2_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target2_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_HealthBar_Fade(arg1)
	Perl_Party_Target_Three_HealthBar_Fade_Color = Perl_Party_Target_Three_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target3_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Three_HealthBar_Fade_Color, 0, Perl_Party_Target_Three_HealthBar_Fade_Color);

	if (Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Three_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Three_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target3_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target3_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_HealthBar_Fade(arg1)
	Perl_Party_Target_Four_HealthBar_Fade_Color = Perl_Party_Target_Four_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target4_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Four_HealthBar_Fade_Color, 0, Perl_Party_Target_Four_HealthBar_Fade_Color);

	if (Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Four_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Four_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target4_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target4_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_HealthBar_Fade(arg1)
	Perl_Party_Target_Five_HealthBar_Fade_Color = Perl_Party_Target_Five_HealthBar_Fade_Color - arg1;
	Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_Target5_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Five_HealthBar_Fade_Color, 0, Perl_Party_Target_Five_HealthBar_Fade_Color);

	if (Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Five_HealthBar_Fade_Color = 1;
		Perl_Party_Target_Five_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target5_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_Target5_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_One_ManaBar_Fade(arg1)
	Perl_Party_Target_One_ManaBar_Fade_Color = Perl_Party_Target_One_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party1target") == 0) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 1) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 2) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, (Perl_Party_Target_One_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 3) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color, 0, Perl_Party_Target_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1target") == 6) then
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color, Perl_Party_Target_One_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_One_ManaBar_Fade_Color = 1;
		Perl_Party_Target_One_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target1_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target1_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Two_ManaBar_Fade(arg1)
	Perl_Party_Target_Two_ManaBar_Fade_Color = Perl_Party_Target_Two_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party2target") == 0) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 1) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 2) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, (Perl_Party_Target_Two_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 3) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color, 0, Perl_Party_Target_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2target") == 6) then
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color, Perl_Party_Target_Two_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Two_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Two_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target2_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target2_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Three_ManaBar_Fade(arg1)
	Perl_Party_Target_Three_ManaBar_Fade_Color = Perl_Party_Target_Three_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party3target") == 0) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 1) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 2) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, (Perl_Party_Target_Three_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 3) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color, 0, Perl_Party_Target_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3target") == 6) then
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color, Perl_Party_Target_Three_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Three_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Three_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target3_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target3_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Four_ManaBar_Fade(arg1)
	Perl_Party_Target_Four_ManaBar_Fade_Color = Perl_Party_Target_Four_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party4target") == 0) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 1) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 2) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, (Perl_Party_Target_Four_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 3) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color, 0, Perl_Party_Target_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4target") == 6) then
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color, Perl_Party_Target_Four_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Four_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Four_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target4_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target4_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Target_Five_ManaBar_Fade(arg1)
	Perl_Party_Target_Five_ManaBar_Fade_Color = Perl_Party_Target_Five_ManaBar_Fade_Color - arg1;
	Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("focustarget") == 0) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 1) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, 0, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 2) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, (Perl_Party_Target_Five_ManaBar_Fade_Color-0.5), 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 3) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color, 0, Perl_Party_Target_Five_ManaBar_Fade_Color);
	elseif (UnitPowerType("focustarget") == 6) then
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color, Perl_Party_Target_Five_ManaBar_Fade_Color);
	end

	if (Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Target_Five_ManaBar_Fade_Color = 1;
		Perl_Party_Target_Five_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_Target5_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_Target5_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Party_Target_Frame_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Frame_Style);
	else
		if (enabled == 1) then
			Perl_Party_Target_Register_All(1, 0);
		else
			Perl_Party_Target_Unregister_All(1, 0);
		end

		if (enabledfocus == 1) then
			Perl_Party_Target_Register_All(0, 1);
		else
			Perl_Party_Target_Unregister_All(0, 1);
		end

		Perl_Party_Target_Check_Hidden();

		if (hidepowerbars == 1) then
			for partynum=1,5 do
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"):Hide();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetHeight(30);
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"):SetHeight(30);
			end
		else
			for partynum=1,5 do
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBarBG"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_ManaBar_CastClickOverlay"):Show();
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame"):SetHeight(42);
				getglobal("Perl_Party_Target"..partynum.."_StatsFrame_CastClickOverlay"):SetHeight(42);
			end
		end

		for partynum=1,5 do
			getglobal("Perl_Party_Target"..partynum.."_NameFrame_NameBarText"):SetWidth(getglobal("Perl_Party_Target"..partynum.."_NameFrame"):GetWidth() - 13);
			getglobal("Perl_Party_Target"..partynum.."_NameFrame_NameBarText"):SetHeight(getglobal("Perl_Party_Target"..partynum.."_NameFrame"):GetHeight() - 10);
			getglobal("Perl_Party_Target"..partynum.."_NameFrame_NameBarText"):SetNonSpaceWrap(false);
			getglobal("Perl_Party_Target"..partynum.."_NameFrame_NameBarText"):SetJustifyH("LEFT");
		end
	end
end

function Perl_Party_Target_Check_Hidden()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Check_Hidden);
	else
		if (partyhiddeninraid == 1 or focushiddeninraid == 1) then
			if (UnitInRaid("player")) then
				Perl_Party_Target_Unregister_All(partyhiddeninraid, focushiddeninraid);
			else
				Perl_Party_Target_Register_All(enabled, enabledfocus);
			end
		end
	end
end

function Perl_Party_Target_Register_All(party, focus)
	if (party == 1) then
		RegisterUnitWatch(Perl_Party_Target1);
		RegisterUnitWatch(Perl_Party_Target2);
		RegisterUnitWatch(Perl_Party_Target3);
		RegisterUnitWatch(Perl_Party_Target4);
	end
	if (focus == 1) then
		RegisterUnitWatch(Perl_Party_Target5);
	end
	if (enabled == 0 and enabledfocus == 0) then
		Perl_Party_Target_Script_Frame:Hide();
	else
		Perl_Party_Target_Script_Frame:Show();
	end
end

function Perl_Party_Target_Unregister_All(party, focus)
	if (party == 1) then
		UnregisterUnitWatch(Perl_Party_Target1);
		UnregisterUnitWatch(Perl_Party_Target2);
		UnregisterUnitWatch(Perl_Party_Target3);
		UnregisterUnitWatch(Perl_Party_Target4);
		Perl_Party_Target1:Hide();
		Perl_Party_Target2:Hide();
		Perl_Party_Target3:Hide();
		Perl_Party_Target4:Hide();
	end
	if (focus == 1) then
		UnregisterUnitWatch(Perl_Party_Target5);
		Perl_Party_Target5:Hide();
	end
	if (enabled == 0 and enabledfocus == 0) then
		Perl_Party_Target_Script_Frame:Hide();
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Party_Target_Allign()
	Perl_Party_Target1:SetUserPlaced(1);		-- This makes WoW remember the changes if the frames have never been moved before
	Perl_Party_Target2:SetUserPlaced(1);
	Perl_Party_Target3:SetUserPlaced(1);
	Perl_Party_Target4:SetUserPlaced(1);
	Perl_Party_Target5:SetUserPlaced(1);

	Perl_Party_Target1:SetPoint("TOPLEFT", Perl_Party_MemberFrame1_StatsFrame, "TOPRIGHT", -2, 22);
	Perl_Party_Target2:SetPoint("TOPLEFT", Perl_Party_MemberFrame2_StatsFrame, "TOPRIGHT", -2, 22);
	Perl_Party_Target3:SetPoint("TOPLEFT", Perl_Party_MemberFrame3_StatsFrame, "TOPRIGHT", -2, 22);
	Perl_Party_Target4:SetPoint("TOPLEFT", Perl_Party_MemberFrame4_StatsFrame, "TOPRIGHT", -2, 22);
	Perl_Party_Target5:ClearAllPoints();
	if (Perl_Focus_PortraitFrame:IsShown()) then
		Perl_Party_Target5:SetPoint("TOPLEFT", Perl_Focus_PortraitFrame, "TOPRIGHT", -2, 0);
	else
		Perl_Party_Target5:SetPoint("TOPLEFT", Perl_Focus_LevelFrame, "TOPRIGHT", -2, 0);
	end
end

function Perl_Party_Target_Set_Enabled(newvalue)
	enabled = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Enabled_Focus(newvalue)
	enabledfocus = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Party_Hidden_In_Raid(newvalue)
	partyhiddeninraid = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Focus_Hidden_In_Raid(newvalue)
	focushiddeninraid = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Hide_Power_Bars(newvalue)
	hidepowerbars = newvalue;
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Frame_Style();
end

function Perl_Party_Target_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_Target_UpdateVars();
end

function Perl_Party_Target_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);
	end
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Set_Scale_Actual();
end

function Perl_Party_Target_Focus_Set_Scale(number)
	if (number ~= nil) then
		focusscale = (number / 100);
	end
	Perl_Party_Target_UpdateVars();
	Perl_Party_Target_Set_Scale_Actual();
end

function Perl_Party_Target_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Target_Set_Scale_Actual);
	else
		local unsavedscale = 1 - UIParent:GetEffectiveScale() + scale;	-- run it through the scaling formula introduced in 1.9
		local unsavedscaletwo = 1 - UIParent:GetEffectiveScale() + focusscale;	-- run it through the scaling formula introduced in 1.9
		Perl_Party_Target1:SetScale(unsavedscale);
		Perl_Party_Target2:SetScale(unsavedscale);
		Perl_Party_Target3:SetScale(unsavedscale);
		Perl_Party_Target4:SetScale(unsavedscale);
		Perl_Party_Target5:SetScale(unsavedscaletwo);
	end
end

function Perl_Party_Target_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);
	end
	Perl_Party_Target1:SetAlpha(transparency);
	Perl_Party_Target2:SetAlpha(transparency);
	Perl_Party_Target3:SetAlpha(transparency);
	Perl_Party_Target4:SetAlpha(transparency);
	Perl_Party_Target5:SetAlpha(transparency);
	Perl_Party_Target_UpdateVars();
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Party_Target_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Party_Target_Config[name]["Locked"];
	scale = Perl_Party_Target_Config[name]["Scale"];
	focusscale = Perl_Party_Target_Config[name]["FocusScale"];
	transparency = Perl_Party_Target_Config[name]["Transparency"];
	hidepowerbars = Perl_Party_Target_Config[name]["HidePowerBars"];
	classcolorednames = Perl_Party_Target_Config[name]["ClassColoredNames"];
	enabled = Perl_Party_Target_Config[name]["Enabled"];
	partyhiddeninraid = Perl_Party_Target_Config[name]["PartyHiddenInRaid"];
	enabledfocus = Perl_Party_Target_Config[name]["EnabledFocus"];
	focushiddeninraid = Perl_Party_Target_Config[name]["FocusHiddenInRaid"];

	if (locked == nil) then
		locked = 0;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (focusscale == nil) then
		focusscale = 0.9;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (hidepowerbars == nil) then
		hidepowerbars = 0;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (enabled == nil) then
		enabled = 1;
	end
	if (partyhiddeninraid == nil) then
		partyhiddeninraid = 0;
	end
	if (enabledfocus == nil) then
		enabledfocus = 1;
	end
	if (focushiddeninraid == nil) then
		focushiddeninraid = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Party_Target_UpdateVars();

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
		return;
	end

	local vars = {
		["locked"] = locked,
		["scale"] = scale,
		["focusscale"] = focusscale,
		["transparency"] = transparency,
		["hidepowerbars"] = hidepowerbars,
		["classcolorednames"] = classcolorednames,
		["enabled"] = enabled,
		["partyhiddeninraid"] = partyhiddeninraid,
		["enabledfocus"] = enabledfocus,
		["focushiddeninraid"] = focushiddeninraid,
	}
	return vars;
end

function Perl_Party_Target_UpdateVars(vartable)
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
			if (vartable["Global Settings"]["FocusScale"] ~= nil) then
				focusscale = vartable["Global Settings"]["FocusScale"];
			else
				focusscale = nil;
			end
			if (vartable["Global Settings"]["Transparency"] ~= nil) then
				transparency = vartable["Global Settings"]["Transparency"];
			else
				transparency = nil;
			end
			if (vartable["Global Settings"]["HidePowerBars"] ~= nil) then
				hidepowerbars = vartable["Global Settings"]["HidePowerBars"];
			else
				hidepowerbars = nil;
			end
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["Enabled"] ~= nil) then
				enabled = vartable["Global Settings"]["Enabled"];
			else
				enabled = nil;
			end
			if (vartable["Global Settings"]["PartyHiddenInRaid"] ~= nil) then
				partyhiddeninraid = vartable["Global Settings"]["PartyHiddenInRaid"];
			else
				partyhiddeninraid = nil;
			end
			if (vartable["Global Settings"]["EnabledFocus"] ~= nil) then
				enabledfocus = vartable["Global Settings"]["EnabledFocus"];
			else
				enabledfocus = nil;
			end
			if (vartable["Global Settings"]["FocusHiddenInRaid"] ~= nil) then
				focushiddeninraid = vartable["Global Settings"]["FocusHiddenInRaid"];
			else
				focushiddeninraid = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (scale == nil) then
			scale = 0.9;
		end
		if (focusscale == nil) then
			focusscale = 0.9;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (hidepowerbars == nil) then
			hidepowerbars = 0;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (enabled == nil) then
			enabled = 1;
		end
		if (partyhiddeninraid == nil) then
			partyhiddeninraid = 0;
		end
		if (enabledfocus == nil) then
			enabledfocus = 1;
		end
		if (focushiddeninraid == nil) then
			focushiddeninraid = 0;
		end

		-- Call any code we need to activate them
		Perl_Party_Target_Set_Scale_Actual();
		Perl_Party_Target_Set_Transparency();
		Perl_Party_Target_Frame_Style();
	end

	Perl_Party_Target_Config[UnitName("player")] = {
		["Locked"] = locked,
		["Scale"] = scale,
		["FocusScale"] = focusscale,
		["Transparency"] = transparency,
		["HidePowerBars"] = hidepowerbars,
		["ClassColoredNames"] = classcolorednames,
		["Enabled"] = enabled,
		["PartyHiddenInRaid"] = partyhiddeninraid,
		["EnabledFocus"] = enabledfocus,
		["FocusHiddenInRaid"] = focushiddeninraid,
	};
end


--------------------
-- Click Handlers --
--------------------
function Perl_Party_Target_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_Target"..self:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_Target"..self:GetParent():GetParent():GetID().."_NameFrame", 0, 0);
	end
	SecureUnitButton_OnLoad(self, "party"..self:GetParent():GetParent():GetID().."target", showmenu);

	if (self:GetParent():GetParent():GetID() == 5) then
		self:SetAttribute("unit", "focustarget");
	else
		self:SetAttribute("unit", "party"..self:GetParent():GetParent():GetID().."target");
	end
	
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

-- If there is a better way to do this please let me know
function Perl_Party_Target1DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_Party_Target1DropDown_Initialize, "MENU");
end

function Perl_Party_Target2DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_Party_Target2DropDown_Initialize, "MENU");
end

function Perl_Party_Target3DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_Party_Target3DropDown_Initialize, "MENU");
end

function Perl_Party_Target4DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_Party_Target4DropDown_Initialize, "MENU");
end

function Perl_Party_Target5DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_Party_Target5DropDown_Initialize, "MENU");
end

function Perl_Party_Target1DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party1target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target1_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target2DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party2target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target2_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target3DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party3target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target3_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target4DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "party4target";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target4_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target5DropDown_Initialize()
	local menu, name;
	local id = nil;
	currentunit = "focustarget";

	if (UnitIsUnit(currentunit, "player")) then
		menu = "SELF";
	elseif (UnitIsUnit(currentunit, "vehicle")) then
		menu = "VEHICLE";
	elseif (UnitIsUnit(currentunit, "pet")) then
		menu = "PET";
	elseif (UnitIsPlayer(currentunit)) then
		id = UnitInRaid(currentunit);
		if (id) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id + 1);
		elseif (UnitInParty(currentunit)) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end

	if (menu) then
		UnitPopup_ShowMenu(Perl_Party_Target5_DropDown, menu, currentunit, name, id);
	end
end

function Perl_Party_Target_DragStart(self, button)
	if (button == "LeftButton" and locked == 0) then
		getglobal("Perl_Party_Target"..self:GetID()):StartMoving();
	end
end

function Perl_Party_Target_DragStop(self, button)
	getglobal("Perl_Party_Target"..self:GetID()):SetUserPlaced(1);
	getglobal("Perl_Party_Target"..self:GetID()):StopMovingOrSizing();
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Party_Target_myAddOns_Support()
	-- Register the addon in myAddOns
	if(myAddOnsFrame_Register) then
		local Perl_Party_Target_myAddOns_Details = {
			name = "Perl_Party_Target",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Party_Target_myAddOns_Help = {};
		Perl_Party_Target_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Party_Target_myAddOns_Details, Perl_Party_Target_myAddOns_Help);
	end
end
