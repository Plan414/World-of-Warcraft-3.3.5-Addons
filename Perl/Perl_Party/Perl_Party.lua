---------------
-- Variables --
---------------
Perl_Party_Config = {};
local Perl_Party_Events = {};		-- event manager
local Perl_Party_Script_Events = {};	-- event manager

-- Default Saved Variables (also set in Perl_Party_GetVars)
local locked = 0;		-- unlocked by default
local compactmode = 0;		-- compact mode is disabled by default
local partyhidden = 0;		-- party frame is set to always show by default
local partyspacing = -95;	-- default spacing between party member frames
local scale = 0.9;		-- default scale
local showpets = 1;		-- show pets by default
local healermode = 0;		-- nurfed unit frame style
local transparency = 1.0;	-- transparency for frames
local bufflocation = 6;		-- default buff location
local debufflocation = 3;	-- default debuff location
local verticalalign = 1;	-- default alignment is vertically
local compactpercent = 0;	-- percents are not shown in compact mode by default
local showportrait = 0;		-- portrait is hidden by default
local showfkeys = 1;		-- show appropriate F key in the name frame by default
local displaycastablebuffs = 0;	-- display all buffs by default
local threedportrait = 0;	-- 3d portraits are off by default
local buffsize = 16;		-- default buff size is 16
local debuffsize = 16;		-- default debuff size is 16
local numbuffsshown = 16;	-- buff row is 16 long
local numdebuffsshown = 16;	-- debuff row is 16 long
local classcolorednames = 0;	-- names are colored based on pvp status by default
local shortbars = 0;		-- Health/Power/Experience bars are all normal length
local hideclasslevelframe = 0;	-- Showing the class icon and level frame by default
local showmanadeficit = 0;	-- Mana deficit in healer mode is off by default
local showpvpicon = 1;		-- show the pvp icon
local showbarvalues = 0;	-- healer mode will have the bar values hidden by default
local displaycurabledebuff = 0;	-- display all debuffs by default
local portraitbuffs = 1;	-- buffs will be pushed over to the portrait if it is displayed
local displaybufftimers = 0;	-- buff/debuff timers are off by default

-- Default Local Variables
local Initialized = nil;	-- waiting to be initialized
local mouseoverhealthflag = 0;	-- is the mouse over the health bar for healer mode?
local mouseovermanaflag = 0;	-- is the mouse over the mana bar for healer mode?
local mouseoverpethealthflag = 0;	-- is the mouse over the pet health bar for healer mode?

-- Fade Bar Variables
local Perl_Party_One_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_HealthBar_Fade_Color = 1;	-- the color fading interval
local Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_HealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_One_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_ManaBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_One_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Two_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Three_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0
local Perl_Party_Four_PetHealthBar_Fade_Color = 1;		-- the color fading interval
local Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;	-- set the update timer to 0

-- Local variables to save memory
local partyhealth, partyhealthmax, partyhealthpercent, partymana, partymanamax, partymanapercent, partypethealth, partypethealthmax, partypethealthpercent, englishclass, bufffilter, debufffilter;


----------------------
-- Loading Function --
----------------------
function Perl_Party_Script_OnLoad(self)
	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("RAID_ROSTER_UPDATE");

	-- Scripts
	self:SetScript("OnEvent", Perl_Party_Script_OnEvent);
end

function Perl_Party_OnLoad(self)
	self.id = self:GetID();
	self.unit = "party"..self.id;
	self.unitpet = "partypet"..self.id;

	self.classTexture = getglobal("Perl_Party_MemberFrame"..self.id.."_LevelFrame_ClassTexture");
	self.deadStatus = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_DeadStatus");
	self.disconnectStatus = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_DisconnectStatus");
	self.fKeyText = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_FKeyText");
	self.leaderIcon = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_LeaderIcon")
	self.levelText = getglobal("Perl_Party_MemberFrame"..self.id.."_LevelFrame_LevelBarText");
	self.masterLootIcon = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_MasterIcon");
	self.nameText = getglobal("Perl_Party_MemberFrame"..self.id.."_Name_NameBarText");
	self.portrait2D = getglobal("Perl_Party_MemberFrame"..self.id.."_PortraitFrame_Portrait");
	self.portrait3D = getglobal("Perl_Party_MemberFrame"..self.id.."_PortraitFrame_PartyModel");
	self.pvpStatus = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_PVPStatus");
	self.roleIcon = getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame_RoleIcon");
	self.threatIcon = getglobal("Perl_Party_MemberFrame"..self.id.."_Name_ThreatIndicator");
	self.voiceChat = getglobal("Perl_Party_MemberFrame"..self.id.."_VoiceChatIconFrame");
	self.voiceChat:ClearAllPoints();	-- Didn't feel like moving this line and the one below it to the style function
	self.voiceChat:SetPoint("CENTER", "Perl_Party_MemberFrame"..self.id, "TOPRIGHT", -35, -12);

	self.healthBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar");
	self.healthBarBG = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBarBG");
	self.healthBarFadeBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBarFadeBar");
	self.healthBarText = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar_HealthBarText");
	self.healthBarTextPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar_HealthBarTextPercent");
	self.healthBarTextCompactPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar_HealthBarTextCompactPercent");
	self.manaBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBar");
	self.manaBarBG = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBarBG");
	self.manaBarFadeBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBarFadeBar");
	self.manaBarText = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBar_ManaBarText");
	self.manaBarTextPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBar_ManaBarTextPercent");
	self.manaBarTextCompactPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_ManaBar_ManaBarTextCompactPercent");
	self.petHealthBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBar");
	self.petHealthBarBG = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBarBG");
	self.petHealthBarFadeBar = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBarFadeBar");
	self.petHealthBarText = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBar_PetHealthBarText");
	self.petHealthBarTextPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent");
	self.petHealthBarTextCompactPercent = getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_PetHealthBar_PetHealthBarTextCompactPercent");

	-- Events
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_AURA");
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
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UNIT_PVP_UPDATE");
	self:RegisterEvent("UNIT_RAGE");
	self:RegisterEvent("UNIT_RUNIC_POWER");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("VOICE_START");
	self:RegisterEvent("VOICE_STOP");

	-- Scripts
	self:SetScript("OnEvent", Perl_Party_OnEvent);

	-- WoW 2.0 Secure API Stuff
	self:SetAttribute("unit", self.unit);
end


-------------------
-- Event Handler --
-------------------
function Perl_Party_Script_OnEvent()
	local func = Perl_Party_Script_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Script_Events:PLAYER_LOGIN()
	if (Initialized) then
		Perl_Party_Check_Hidden();		-- Are we running a hidden mode?
	end
end
Perl_Party_Events.PLAYER_ENTERING_WORLD = Perl_Party_Events.PLAYER_LOGIN;

function Perl_Party_Script_Events:RAID_ROSTER_UPDATE()
	Perl_Party_Check_Hidden();
end


function Perl_Party_OnEvent()
	local func = Perl_Party_Events[event];
	if (func) then
		func();
	else
		if (PCUF_SHOW_DEBUG_EVENTS == 1) then
			DEFAULT_CHAT_FRAME:AddMessage("Perl Classic - Party: Report the following event error to the author: "..event);
		end
	end
end

function Perl_Party_Events:UNIT_HEALTH()
	if (arg1 == this.unit) then
		Perl_Party_Update_Health(this);
	elseif (showpets == 1) then
		if (arg1 == this.unitpet) then
			Perl_Party_Update_Pet_Health(this);
		end
	end
end
Perl_Party_Events.UNIT_MAXHEALTH = Perl_Party_Events.UNIT_HEALTH;

function Perl_Party_Events:UNIT_ENERGY()
	if (arg1 == this.unit) then
		Perl_Party_Update_Mana(this);
	end
end
Perl_Party_Events.UNIT_MAXENERGY = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MANA = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MAXMANA = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_RAGE = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MAXRAGE = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_RUNIC_POWER = Perl_Party_Events.UNIT_ENERGY;
Perl_Party_Events.UNIT_MAXRUNIC_POWER = Perl_Party_Events.UNIT_ENERGY;

function Perl_Party_Events:UNIT_AURA()
	if (arg1 == this.unit) then
		Perl_Party_Buff_UpdateAll(this);
	end
end

function Perl_Party_Events:UNIT_DISPLAYPOWER()
	if (arg1 == this.unit) then
		Perl_Party_Update_Mana_Bar(this);	-- What type of energy are we using now?
		Perl_Party_Update_Mana(this);		-- Update the power info immediately
	end
end

function Perl_Party_Events:UNIT_FACTION()
	if (arg1 == this.unit) then
		Perl_Party_Update_PvP_Status(this);	-- Is the character PvP flagged?
	end
end
Perl_Party_Events.UNIT_PVP_UPDATE = Perl_Party_Events.UNIT_FACTION;

function Perl_Party_Events:UNIT_NAME_UPDATE()
	if (arg1 == this.unit) then
		Perl_Party_Set_Name(this);		-- Set the player's name and class icon
	end
end

function Perl_Party_Events:UNIT_PET()
	if (arg1 == this.unit) then
		Perl_Party_Update_Pet_Health(this);	-- Update the pet health bar
	end
end

function Perl_Party_Events:UNIT_LEVEL()
	if (arg1 == this.unit) then
		Perl_Party_Update_Level(this);		-- Set the player's level
	end
end

function Perl_Party_Events:PARTY_MEMBERS_CHANGED()
	Perl_Party_MembersUpdate(this);			-- How many members are in the group and show the correct frames and do UpdateOnce things
end

function Perl_Party_Events:PARTY_LEADER_CHANGED()
	Perl_Party_Update_Leader(this);			-- Who is the group leader
end

function Perl_Party_Events:UNIT_PORTRAIT_UPDATE()
	if (arg1 == this.unit) then
		Perl_Party_Update_Portrait(this);
	end
end
Perl_Party_Events.UNIT_MODEL_CHANGED = Perl_Party_Events.UNIT_PORTRAIT_UPDATE;

function Perl_Party_Events:PARTY_LOOT_METHOD_CHANGED()
	Perl_Party_Update_Loot_Method(this);		-- Who is the master looter if any
end

function Perl_Party_Events:PLAYER_ALIVE()
	Perl_Party_Check_Hidden();			-- Are we running a hidden mode? (Hopefully the last check we need to add for this)
end

function Perl_Party_Events:VOICE_START()
	if (arg1 == this.unit) then
		this.voiceChat:Show();
	end
end

function Perl_Party_Events:VOICE_STOP()
	if (arg1 == this.unit) then
		this.voiceChat:Hide();
	end
end

function Perl_Party_Events:UNIT_THREAT_SITUATION_UPDATE()
	if (arg1 == this.unit) then
		Perl_Party_Update_Threat(this);
	end
end

function Perl_Party_Events:PLAYER_ENTERING_WORLD()
	Perl_Party_Initialize();			-- We also force update info here in case of a /console reloadui
end


-------------------------------
-- Loading Settings Function --
-------------------------------
function Perl_Party_Initialize()
	-- Code to be run after zoning or logging in goes here
	if (Initialized) then
		Perl_Party_Set_Scale_Actual();		-- Set the frame scale
		Perl_Party_Set_Transparency();		-- Set the frame transparency
		Perl_Party_Force_Update()		-- Attempt to forcefully update information
		Perl_Party_Update_Health_Mana();	-- You know the drill
		Perl_Party_Check_Hidden();		-- Are we running a hidden mode?
		return;
	end

	-- Check if a previous exists, if not, enable by default.
	if (type(Perl_Party_Config[UnitName("player")]) == "table") then
		Perl_Party_GetVars();
	else
		Perl_Party_UpdateVars();
	end

	-- Major config options.
	Perl_Party_Initialize_Frame_Color();		-- Color the frame borders
	Perl_Party_Frame_Style();

	-- Unregister and Hide the Blizzard frames
	Perl_clearBlizzardFrameDisable(PartyMemberFrame1);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame1PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame2);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame2PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame3);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame3PetFrame);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame4);
	Perl_clearBlizzardFrameDisable(PartyMemberFrame4PetFrame);

	hooksecurefunc("ShowPartyFrame",		-- Thanks Zek
		function()
			if (not InCombatLockdown()) then
				for i = 1,4 do
					getglobal("PartyMemberFrame"..i):Hide();
				end
			end
		end
	);

	-- Set the ID of the frame
	for id=1,4 do
		getglobal("Perl_Party_MemberFrame"..id.."_Name_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_CastClickOverlay"):SetID(id);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetID(id);
	end

	-- Button Click Overlays (in order of occurrence in XML)
	for id=1,4 do
		getglobal("Perl_Party_MemberFrame"..id.."_Name_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_Name"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_MemberFrame"..id.."_Name_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_Name"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_LevelFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):GetFrameLevel() + 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):GetFrameLevel() + 2);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_HealthBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_ManaBar"):GetFrameLevel() - 1);
		getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarFadeBar"):SetFrameLevel(getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):GetFrameLevel() - 1);
	end

	-- MyAddOns Support
	Perl_Party_myAddOns_Support();

	-- IFrameManager Support (Deprecated)
	Perl_Party_Frame:SetUserPlaced(1);

	-- WoW 2.0 Secure API Stuff
	Perl_Party_Register_All()

	Initialized = 1;
	Perl_Party_MembersUpdate(Perl_Party_MemberFrame1);
	Perl_Party_MembersUpdate(Perl_Party_MemberFrame2);
	Perl_Party_MembersUpdate(Perl_Party_MemberFrame3);
	Perl_Party_MembersUpdate(Perl_Party_MemberFrame4);
end

function Perl_Party_Initialize_Frame_Color()
	for partynum=1,4 do
		getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_PortraitFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropColor(0, 0, 0, 1);
		getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
	end
end


----------------------
-- Update Functions --
----------------------
function Perl_Party_MembersUpdate(self)
	Perl_Party_Set_Name(self);
	Perl_Party_Update_PvP_Status(self);
	Perl_Party_Update_Level(self);
	Perl_Party_Update_Health(self);
	Perl_Party_Update_Mana(self);
	Perl_Party_Update_Mana_Bar(self);
	Perl_Party_Update_Pet_Health(self);
	Perl_Party_Update_Leader(self);
	Perl_Party_Update_Loot_Method(self);
	Perl_Party_Update_Role(self);
	Perl_Party_Update_Portrait(self);
	Perl_Party_Buff_UpdateAll(self);
	Perl_Party_VoiceChat(self);
	Perl_Party_Update_Threat(self);
end

function Perl_Party_Update_Health(self)
	partyhealth = UnitHealth(self.unit);
	partyhealthmax = UnitHealthMax(self.unit);
	partyhealthpercent = floor(partyhealth/partyhealthmax*100+0.5);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then			-- This prevents negative health
		partyhealth = 0;
		partyhealthpercent = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (partyhealth < self.healthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partyhealth > self.healthBar:GetValue())) then
			self.healthBarFadeBar:SetMinMaxValues(0, partyhealthmax);
			self.healthBarFadeBar:SetValue(self.healthBar:GetValue());
			self.healthBarFadeBar:Show();
			if (self.id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
				Perl_Party_One_HealthBar_Fade_Color = 1;
				Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;
				Perl_Party_1_HealthBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 2) then
				Perl_Party_Two_HealthBar_Fade_Color = 1;
				Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;
				Perl_Party_2_HealthBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 3) then
				Perl_Party_Three_HealthBar_Fade_Color = 1;
				Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;
				Perl_Party_3_HealthBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 4) then
				Perl_Party_Four_HealthBar_Fade_Color = 1;
				Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;
				Perl_Party_4_HealthBar_Fade_OnUpdate_Frame:Show();
			end
		end
	end

	self.healthBar:SetMinMaxValues(0, partyhealthmax);
	if (PCUF_INVERTBARVALUES == 1) then
		self.healthBar:SetValue(partyhealthmax - partyhealth);
	else
		self.healthBar:SetValue(partyhealth);
	end

	if (PCUF_COLORHEALTH == 1) then
--		if ((partyhealthpercent <= 100) and (partyhealthpercent > 75)) then
--			self.healthBar:SetStatusBarColor(0, 0.8, 0);
--			self.healthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
--		elseif ((partyhealthpercent <= 75) and (partyhealthpercent > 50)) then
--			self.healthBar:SetStatusBarColor(1, 1, 0);
--			self.healthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
--		elseif ((partyhealthpercent <= 50) and (partyhealthpercent > 25)) then
--			self.healthBar:SetStatusBarColor(1, 0.5, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
--		else
--			self.healthBar:SetStatusBarColor(1, 0, 0);
--			self.healthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
--		end

		local rawpercent = partyhealth / partyhealthmax;
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

	if (compactmode == 0) then
		if (healermode == 1) then
			self.healthBarText:SetText("-"..partyhealthmax - partyhealth);
			if (showbarvalues == 0) then
				if (tonumber(mouseoverhealthflag) == tonumber(self.id)) then
					self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
				else
					self.healthBarTextPercent:SetText();
				end
			else
				self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
			end
		else
			self.healthBarText:SetText(partyhealth.."/"..partyhealthmax);
			self.healthBarTextPercent:SetText(partyhealthpercent.."%");
		end
		self.healthBarTextCompactPercent:SetText();						-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then
			self.healthBarText:SetText("-"..partyhealthmax - partyhealth);
			if (showbarvalues == 0) then
				if (tonumber(mouseoverhealthflag) == tonumber(self.id)) then
					self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
				else
					self.healthBarTextPercent:SetText();
				end
			else
				self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
			end
		else
			self.healthBarText:SetText();
			self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
		end

		if (compactpercent == 1) then
			self.healthBarTextCompactPercent:SetText(partyhealthpercent.."%");
		else
			self.healthBarTextCompactPercent:SetText();
		end
	end

	-- Handle death state
	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then
		self.deadStatus:Show();
		_, englishclass = UnitClass(self.unit);
		if (englishclass == "HUNTER") then	-- If the dead is a hunter, check for Feign Death
			local buffnum = 1;
			local currentlyfd = 0;
			local _, _, buffTexture = UnitBuff(self.unit, buffnum);
			while (buffTexture) do
				if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
					if (compactmode == 0) then
						self.healthBarText:SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
					else
						self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
					end
					currentlyfd = 1;
					break;
				end
				buffnum = buffnum + 1;
				_, _, buffTexture = UnitBuff(self.unit, buffnum);
			end
			if (currentlyfd == 0) then				-- If the hunter is not Feign Death, then lol
				if (compactmode == 0) then
					self.healthBarText:SetText(PERL_LOCALIZED_STATUS_DEAD);
				else
					self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_DEAD);
				end
			end
		else								-- If the dead is not a hunter, well...
			if (compactmode == 0) then
				self.healthBarText:SetText(PERL_LOCALIZED_STATUS_DEAD);
			else
				self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_DEAD);
			end
		end
	else
		self.deadStatus:Hide();
	end

	-- Handle disconnected state
	if (UnitIsConnected(self.unit)) then
		self.disconnectStatus:Hide();
	else
		self.disconnectStatus:Show();
		if (compactmode == 0) then
			self.healthBarText:SetText(PERL_LOCALIZED_STATUS_OFFLINE);
		else
			self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_OFFLINE);
		end
	end
end

function Perl_Party_Update_Mana(self)
	partymana = UnitMana(self.unit);
	partymanamax = UnitManaMax(self.unit);
	partymanapercent = floor(partymana/partymanamax*100+0.5);

	if (UnitIsDead(self.unit) or UnitIsGhost(self.unit) or partymanamax == 0) then			-- This prevents negative mana
		partymana = 0;
		partymanapercent = 0;
	end

	if (PCUF_FADEBARS == 1) then
		if (partymana < self.manaBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partymana > self.manaBar:GetValue())) then
			self.manaBarFadeBar:SetMinMaxValues(0, partymanamax);
			self.manaBarFadeBar:SetValue(self.manaBar:GetValue());
			self.manaBarFadeBar:Show();
			if (self.id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
				Perl_Party_One_ManaBar_Fade_Color = 1;
				Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;
				Perl_Party_1_ManaBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 2) then
				Perl_Party_Two_ManaBar_Fade_Color = 1;
				Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;
				Perl_Party_2_ManaBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 3) then
				Perl_Party_Three_ManaBar_Fade_Color = 1;
				Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;
				Perl_Party_3_ManaBar_Fade_OnUpdate_Frame:Show();
			elseif (self.id == 4) then
				Perl_Party_Four_ManaBar_Fade_Color = 1;
				Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;
				Perl_Party_4_ManaBar_Fade_OnUpdate_Frame:Show();
			end
		end
	end

	self.manaBar:SetMinMaxValues(0, partymanamax);
	if (PCUF_INVERTBARVALUES == 1) then
		self.manaBar:SetValue(partymanamax - partymana);
	else
		self.manaBar:SetValue(partymana);
	end

	if (compactmode == 0) then
		if (healermode == 1) then
			self.manaBarText:SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				self.manaBarText:SetText("-"..partymanamax - partymana);
			else
				self.manaBarText:SetText();
			end
			if (showbarvalues == 0) then
				if (tonumber(mouseovermanaflag) == tonumber(self.id)) then
					if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
						self.manaBarTextPercent:SetText(partymana);
					else
						self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
					end
				else
					self.manaBarTextPercent:SetText();
				end
			else
				if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
					self.manaBarTextPercent:SetText(partymana);
				else
					self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
				end
			end
		else
			self.manaBarText:SetTextColor(1, 1, 1, 1);
			self.manaBarText:SetText(partymana.."/"..partymanamax);
			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
				self.manaBarTextPercent:SetText(partymana);
			else
				self.manaBarTextPercent:SetText(partymanapercent.."%");
			end
		end
		self.manaBarTextCompactPercent:SetText();						-- Hide the compact mode percent text in full mode
	else
		if (healermode == 1) then
			self.manaBarText:SetTextColor(0.5, 0.5, 0.5, 1);
			if (showmanadeficit == 1) then
				self.manaBarText:SetText("-"..partymanamax - partymana);
			else
				self.manaBarText:SetText();
			end
			if (showbarvalues == 0) then
				if (tonumber(mouseovermanaflag) == tonumber(self.id)) then
					if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
						self.manaBarTextPercent:SetText(partymana);
					else
						self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
					end
				else
					self.manaBarTextPercent:SetText();
				end
			else
				if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
					self.manaBarTextPercent:SetText(partymana);
				else
					self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
				end
			end
		else
			self.manaBarText:SetTextColor(1, 1, 1, 1);
			self.manaBarText:SetText();
			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
				self.manaBarTextPercent:SetText(partymana);
			else
				self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
			end
		end

		if (compactpercent == 1) then
			self.manaBarTextCompactPercent:SetText(partymanapercent.."%");
		else
			self.manaBarTextCompactPercent:SetText();
		end
	end
end

function Perl_Party_Update_Mana_Bar(self)
	local partypower = UnitPowerType(self.unit);

	if (partypower == 0) then	-- Mana
		self.manaBar:SetStatusBarColor(0, 0, 1, 1);
		self.manaBarBG:SetStatusBarColor(0, 0, 1, 0.25);
	elseif (partypower == 1) then	-- Energy
		self.manaBar:SetStatusBarColor(1, 0, 0, 1);
		self.manaBarBG:SetStatusBarColor(1, 0, 0, 0.25);
	elseif (partypower == 3) then	-- Rage
		self.manaBar:SetStatusBarColor(1, 1, 0, 1);
		self.manaBarBG:SetStatusBarColor(1, 1, 0, 0.25);
	elseif (partypower == 6) then	-- Runic
		self.manaBar:SetStatusBarColor(0, 0.82, 1, 1);
		self.manaBarBG:SetStatusBarColor(0, 0.82, 1, 0.25);
	end
end

function Perl_Party_Update_Pet_Health(self)
	if (UnitIsConnected(self.unit) and UnitExists(self.unitpet)) then
		partypethealth = UnitHealth(self.unitpet);
		partypethealthmax = UnitHealthMax(self.unitpet);
		partypethealthpercent = floor(partypethealth/partypethealthmax*100+0.5);

		if (UnitIsDead(self.unitpet) or UnitIsGhost(self.unitpet)) then				-- This prevents negative health
			partypethealth = 0;
			partypethealthpercent = 0;
		end

		if (PCUF_FADEBARS == 1) then
			if (partypethealth < self.petHealthBar:GetValue() or (PCUF_INVERTBARVALUES == 1 and partypethealth > self.petHealthBar:GetValue())) then
				self.petHealthBarFadeBar:SetMinMaxValues(0, partypethealthmax);
				self.petHealthBarFadeBar:SetValue(self.petHealthBar:GetValue());
				self.petHealthBarFadeBar:Show();
				if (self.id == 1) then						-- This makes the bars fade much smoother when lots of change is happening to a given bar
					Perl_Party_One_PetHealthBar_Fade_Color = 1;
					Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;
					Perl_Party_1_PetHealthBar_Fade_OnUpdate_Frame:Show();
				elseif (self.id == 2) then
					Perl_Party_Two_PetHealthBar_Fade_Color = 1;
					Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;
					Perl_Party_2_PetHealthBar_Fade_OnUpdate_Frame:Show();
				elseif (self.id == 3) then
					Perl_Party_Three_PetHealthBar_Fade_Color = 1;
					Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;
					Perl_Party_3_PetHealthBar_Fade_OnUpdate_Frame:Show();
				elseif (self.id == 4) then
					Perl_Party_Four_PetHealthBar_Fade_Color = 1;
					Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;
					Perl_Party_4_PetHealthBar_Fade_OnUpdate_Frame:Show();
				end
			end
		end

		self.petHealthBar:SetMinMaxValues(0, partypethealthmax);
		if (PCUF_INVERTBARVALUES == 1) then
			self.petHealthBar:SetValue(partypethealthmax - partypethealth);
		else
			self.petHealthBar:SetValue(partypethealth);
		end

		if (PCUF_COLORHEALTH == 1) then
			if ((partypethealthpercent <= 100) and (partypethealthpercent > 75)) then
				self.petHealthBar:SetStatusBarColor(0, 0.8, 0);
				self.petHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
			elseif ((partypethealthpercent <= 75) and (partypethealthpercent > 50)) then
				self.petHealthBar:SetStatusBarColor(1, 1, 0);
				self.petHealthBarBG:SetStatusBarColor(1, 1, 0, 0.25);
			elseif ((partypethealthpercent <= 50) and (partypethealthpercent > 25)) then
				self.petHealthBar:SetStatusBarColor(1, 0.5, 0);
				self.petHealthBarBG:SetStatusBarColor(1, 0.5, 0, 0.25);
			else
				self.petHealthBar:SetStatusBarColor(1, 0, 0);
				self.petHealthBarBG:SetStatusBarColor(1, 0, 0, 0.25);
			end
		else
			self.petHealthBar:SetStatusBarColor(0, 0.8, 0, 1);
			self.petHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0.25);
		end

		if (compactmode == 0) then
			if (healermode == 1) then
				self.petHealthBarText:SetText("-"..partypethealthmax - partypethealth);
				if (showbarvalues == 0) then
					if (tonumber(mouseoverpethealthflag) == tonumber(self.id)) then
						self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
					else
						self.petHealthBarTextPercent:SetText();
					end
				else
					self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
				end
			else
				self.petHealthBarText:SetText(partypethealth.."/"..partypethealthmax);
				self.petHealthBarTextPercent:SetText(partypethealthpercent.."%");
			end
			self.petHealthBarTextCompactPercent:SetText();				-- Hide the compact mode percent text in full mode
		else
			if (healermode == 1) then
				self.petHealthBarText:SetText("-"..partypethealthmax - partypethealth);
				if (showbarvalues == 0) then
					if (tonumber(mouseoverpethealthflag) == tonumber(self.id)) then
						self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
					else
						self.petHealthBarTextPercent:SetText();
					end
				else
					self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
				end
			else
				self.petHealthBarText:SetText();
				self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
			end

			if (compactpercent == 1) then
				self.petHealthBarTextCompactPercent:SetText(partypethealthpercent.."%");
			else
				self.petHealthBarTextCompactPercent:SetText();
			end
		end

	else
		-- pet doesn't exist, so lets black it out
		self.petHealthBar:SetStatusBarColor(0, 0.8, 0, 0);
		self.petHealthBarBG:SetStatusBarColor(0, 0.8, 0, 0);
		self.petHealthBar:SetValue(0);
		self.petHealthBarText:SetText();
		self.petHealthBarTextPercent:SetText();
		self.petHealthBarTextCompactPercent:SetText();
	end
end

function Perl_Party_Set_Name(self)
	-- Set Name
	if (UnitName(self.unit) ~= nil) then
		local partyname = UnitName(self.unit);

		if (showfkeys == 1) then
			local key1 = GetBindingKey("TARGETPARTYMEMBER"..self.id);
			self.fKeyText:SetText(key1);
		else
			self.fKeyText:SetText();
		end

		self.nameText:SetText(partyname);

		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			getglobal("Perl_ArcaneBar_party"..self.id).unitname = partyname;
		end
	end

	-- Set Class Icon
	if (UnitIsPlayer(self.unit)) then
		_, englishclass = UnitClass(self.unit);
		self.classTexture:SetTexCoord(PCUF_CLASSPOSRIGHT[englishclass], PCUF_CLASSPOSLEFT[englishclass], PCUF_CLASSPOSTOP[englishclass], PCUF_CLASSPOSBOTTOM[englishclass]);	-- Set the party member's class icon
		self.classTexture:Show();
	else
		self.classTexture:Hide();
	end
end

function Perl_Party_Update_PvP_Status(self)				-- Modeled after 1.9 code
	local factionGroup = UnitFactionGroup(self.unit);
	if (factionGroup == nil) then
		factionGroup = UnitFactionGroup("player");
	end

	-- Color their name if PvP flagged
	if (UnitIsPVPFreeForAll(self.unit)) then
		self.nameText:SetTextColor(0,1,0);							-- FFA PvP will still use normal PvP coloring since you're grouped
		if (showpvpicon == 1) then
			self.pvpStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");		-- Set the FFA PvP icon
			self.pvpStatus:Show();								-- Show the icon
		else
			self.pvpStatus:Hide();								-- Hide the icon
		end
	elseif (factionGroup and UnitIsPVP(self.unit) and not UnitIsPVPSanctuary(self.unit)) then
		self.nameText:SetTextColor(0,1,0);							-- Color the name for PvP
		if (showpvpicon == 1) then
			self.pvpStatus:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);	-- Set the correct team icon
			self.pvpStatus:Show();								-- Show the icon
		else
			self.pvpStatus:Hide();								-- Hide the icon
		end
	else
		self.nameText:SetTextColor(0.5,0.5,1);							-- Set the non PvP name color
		self.pvpStatus:Hide();									-- Hide the icon
	end

	if (not UnitPlayerControlled(self.unit)) then													-- is it a player (added this check for charmed party members)
		if (UnitIsVisible(self.unit)) then
			local reaction = UnitReaction(self.unit, "player");
			if (reaction) then
				self.nameText:SetTextColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b);
			end
		end
	end

	if (classcolorednames == 1) then
		_, englishclass = UnitClass(self.unit);
		if (englishclass) then
			self.nameText:SetTextColor(RAID_CLASS_COLORS[englishclass].r,RAID_CLASS_COLORS[englishclass].g,RAID_CLASS_COLORS[englishclass].b);
		end
	end
end

function Perl_Party_Update_Level(self)
	if (id ~= 0) then		-- Do this check to prevent showing a player level of zero when the player is zoning or dead or cant have info received (linkdead)
		self.levelText:SetText(UnitLevel(self.unit));
	end
end

function Perl_Party_Update_Leader(self)
	if (GetPartyLeaderIndex() == self.id) then
		self.leaderIcon:Show();
	else
		self.leaderIcon:Hide();
	end
end

function Perl_Party_Update_Loot_Method(self)
	local lootMaster;
	_, lootMaster = GetLootMethod();
	if (self.id == lootMaster) then
		self.masterLootIcon:Show();
	else
		self.masterLootIcon:Hide();
	end
end

function Perl_Party_Update_Role(self)
	local isTank, isHealer, isDamage = UnitGroupRolesAssigned("party"..self.id);
	if(isTank) then
		self.roleIcon:SetTexCoord(0, 19/64, 22/64, 41/64);
		self.roleIcon:Show();
	elseif(isHealer) then
		self.roleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64);
		self.roleIcon:Show();
	elseif(isDamage) then
		self.roleIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64);
		self.roleIcon:Show();
	else
		self.roleIcon:Hide();
	end
end

function Perl_Party_Update_Threat(self)
	local status = UnitThreatSituation(self.unit);

	if (status == nil) then
		self.threatIcon:Hide();
		return;
	end

	if (status > 0 and PCUF_THREATICON == 1) then
		self.threatIcon:SetVertexColor(GetThreatStatusColor(status));
		self.threatIcon:Show();
	else
		self.threatIcon:Hide();
	end
end

function Perl_Party_Check_Hidden()
	if (partyhidden == 1) then
		if (InCombatLockdown()) then
			Perl_Config_Queue_Add(Perl_Party_Unregister_All);
		else
			Perl_Party_Unregister_All();
		end
	elseif (partyhidden == 2) then
		if (UnitInRaid("player")) then
			if (InCombatLockdown()) then
				Perl_Config_Queue_Add(Perl_Party_Unregister_All);
			else
				Perl_Party_Unregister_All();
			end
		else
			if (InCombatLockdown()) then
				Perl_Config_Queue_Add(Perl_Party_Register_All);
			else
				Perl_Party_Register_All();
			end
		end
	else
		if (InCombatLockdown()) then
			Perl_Config_Queue_Add(Perl_Party_Register_All);
		else
			Perl_Party_Register_All();
		end
	end
end

function Perl_Party_Register_All()
	RegisterUnitWatch(Perl_Party_MemberFrame1);
	RegisterUnitWatch(Perl_Party_MemberFrame2);
	RegisterUnitWatch(Perl_Party_MemberFrame3);
	RegisterUnitWatch(Perl_Party_MemberFrame4);
end

function Perl_Party_Unregister_All()
	UnregisterUnitWatch(Perl_Party_MemberFrame1);
	UnregisterUnitWatch(Perl_Party_MemberFrame2);
	UnregisterUnitWatch(Perl_Party_MemberFrame3);
	UnregisterUnitWatch(Perl_Party_MemberFrame4);
	Perl_Party_MemberFrame1:Hide();
	Perl_Party_MemberFrame2:Hide();
	Perl_Party_MemberFrame3:Hide();
	Perl_Party_MemberFrame4:Hide();
end

function Perl_Party_HealthShow(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			partyhealth = UnitHealth(self.unit);
			partyhealthmax = UnitHealthMax(self.unit);

			if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative health
				partyhealth = 0;
			end

			self.healthBarTextPercent:SetText(partyhealth.."/"..partyhealthmax);
			mouseoverhealthflag = self.id;
		end
	end
end

function Perl_Party_HealthHide(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			self.healthBarTextPercent:SetText();
			mouseoverhealthflag = 0;

			if (compactmode == 1) then
				if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then
					_, englishclass = UnitClass(self.unit);
					if (englishclass == "HUNTER") then
						local buffnum = 1;
						local currentlyfd = 0;
						local _, _, buffTexture = UnitBuff(self.unit, buffnum);
						while (buffTexture) do
							if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
								self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
								currentlyfd = 1;
								break;
							end
							buffnum = buffnum + 1;
							_, _, buffTexture = UnitBuff(self.unit, buffnum);
						end
						if (currentlyfd == 0) then
							self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_DEAD);
						end
					else
						self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_DEAD);
					end
				end
			end

			-- Handle disconnected state
			if (not UnitIsConnected(self.unit)) then
				if (compactmode == 0) then
					self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_OFFLINE);
				else
					self.healthBarTextPercent:SetText(PERL_LOCALIZED_STATUS_OFFLINE);
				end
			end
		end
	end
end

function Perl_Party_ManaShow(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			partymana = UnitMana(self.unit);
			partymanamax = UnitManaMax(self.unit);

			if (UnitIsDead(self.unit) or UnitIsGhost(self.unit)) then	-- This prevents negative mana
				partymana = 0;
			end

			if (UnitPowerType(self.unit) == 1 or UnitPowerType(self.unit) == 6) then
				self.manaBarTextPercent:SetText(partymana);
			else
				self.manaBarTextPercent:SetText(partymana.."/"..partymanamax);
			end
			mouseovermanaflag = id;
		end
	end
end

function Perl_Party_ManaHide(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			self.manaBarTextPercent:SetText();
			mouseovermanaflag = 0;
		end
	end
end

function Perl_Party_Pet_HealthShow(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			partypethealth = UnitHealth(self.unitpet);
			partypethealthmax = UnitHealthMax(self.unitpet);

			if (UnitIsDead(self.unitpet) or UnitIsGhost(self.unitpet)) then	-- This prevents negative health
				partypethealth = 0;
			end

			self.petHealthBarTextPercent:SetText(partypethealth.."/"..partypethealthmax);
			mouseoverpethealthflag = self.id;
		end
	end
end

function Perl_Party_Pet_HealthHide(self)
	if (healermode == 1) then
		if (showbarvalues == 0) then
			self.petHealthBarTextPercent:SetText();
			mouseoverpethealthflag = 0;
		end
	end
end

function Perl_Party_Update_Portrait(self)
	if (showportrait == 1) then
		if (threedportrait == 0) then
			SetPortraitTexture(self.portrait2D, self.unit);		-- Load the correct 2d graphic
		else
			if (UnitIsVisible(self.unit)) then
				self.portrait3D:SetUnit(self.unit);		-- Load the correct 3d graphic
				self.portrait3D:SetCamera(0);
				self.portrait2D:Hide();				-- Hide the 2d graphic
				self.portrait3D:Show();				-- Show the 3d graphic
			else
				SetPortraitTexture(self.portrait2D, self.unit);	-- Load the correct 2d graphic
				self.portrait3D:Hide();				-- Hide the 3d graphic
				self.portrait2D:Show();				-- Show the 2d graphic
			end
		end
	end
end

function Perl_Party_VoiceChat(self)
	if (UnitIsTalking(self.unit)) then
		self.voiceChat:Show();
	else
		self.voiceChat:Hide();
	end
end

function Perl_Party_Update_Health_Mana()
	local self;
	for id=1,4 do
		self = getglobal("Perl_Party_MemberFrame"..id);
		if (UnitName(self.unit) ~= nil) then
			Perl_Party_Update_Health(self);
			Perl_Party_Update_Mana(self);
			Perl_Party_Update_Pet_Health(self);
		end
	end
end

function Perl_Party_Force_Update()
	Perl_Party_Reset_Buffs();			-- Reset Buffs

	local self;
	for id = 1, 4 do
		self = getglobal("Perl_Party_MemberFrame"..id);
		Perl_Party_Set_Name(self);		-- Set Name & Class Icon
		Perl_Party_Update_Level(self);		-- Set Level
		Perl_Party_Update_Health(self);		-- Set Death State & Disconnected State
		Perl_Party_Update_PvP_Status(self);	-- Set PvP Info & Name Color
		Perl_Party_Update_Mana_Bar(self);	-- Set Power Bar Color
		Perl_Party_Update_Portrait(self);	-- Set Portraits
		Perl_Party_Buff_UpdateAll(self);	-- Set Buffs
	end
end


------------------------
-- Fade Bar Functions --
------------------------
function Perl_Party_One_HealthBar_Fade(arg1)
	Perl_Party_One_HealthBar_Fade_Color = Perl_Party_One_HealthBar_Fade_Color - arg1;
	Perl_Party_One_HealthBar_Fade_Time_Elapsed = Perl_Party_One_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame1_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_One_HealthBar_Fade_Color, 0, Perl_Party_One_HealthBar_Fade_Color);

	if (Perl_Party_One_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_HealthBar_Fade_Color = 1;
		Perl_Party_One_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_1_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_HealthBar_Fade(arg1)
	Perl_Party_Two_HealthBar_Fade_Color = Perl_Party_Two_HealthBar_Fade_Color - arg1;
	Perl_Party_Two_HealthBar_Fade_Time_Elapsed = Perl_Party_Two_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame2_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Two_HealthBar_Fade_Color, 0, Perl_Party_Two_HealthBar_Fade_Color);

	if (Perl_Party_Two_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_HealthBar_Fade_Color = 1;
		Perl_Party_Two_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_2_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_HealthBar_Fade(arg1)
	Perl_Party_Three_HealthBar_Fade_Color = Perl_Party_Three_HealthBar_Fade_Color - arg1;
	Perl_Party_Three_HealthBar_Fade_Time_Elapsed = Perl_Party_Three_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame3_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Three_HealthBar_Fade_Color, 0, Perl_Party_Three_HealthBar_Fade_Color);

	if (Perl_Party_Three_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_HealthBar_Fade_Color = 1;
		Perl_Party_Three_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_3_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_HealthBar_Fade(arg1)
	Perl_Party_Four_HealthBar_Fade_Color = Perl_Party_Four_HealthBar_Fade_Color - arg1;
	Perl_Party_Four_HealthBar_Fade_Time_Elapsed = Perl_Party_Four_HealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame4_StatsFrame_HealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Four_HealthBar_Fade_Color, 0, Perl_Party_Four_HealthBar_Fade_Color);

	if (Perl_Party_Four_HealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_HealthBar_Fade_Color = 1;
		Perl_Party_Four_HealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_HealthBarFadeBar:Hide();
		Perl_Party_4_HealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_One_ManaBar_Fade(arg1)
	Perl_Party_One_ManaBar_Fade_Color = Perl_Party_One_ManaBar_Fade_Color - arg1;
	Perl_Party_One_ManaBar_Fade_Time_Elapsed = Perl_Party_One_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party1") == 0) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1") == 1) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, 0, 0, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1") == 3) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color, 0, Perl_Party_One_ManaBar_Fade_Color);
	elseif (UnitPowerType("party1") == 6) then
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color, Perl_Party_One_ManaBar_Fade_Color);
	end

	if (Perl_Party_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_ManaBar_Fade_Color = 1;
		Perl_Party_One_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_1_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_ManaBar_Fade(arg1)
	Perl_Party_Two_ManaBar_Fade_Color = Perl_Party_Two_ManaBar_Fade_Color - arg1;
	Perl_Party_Two_ManaBar_Fade_Time_Elapsed = Perl_Party_Two_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party2") == 0) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Two_ManaBar_Fade_Color, Perl_Party_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2") == 1) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Two_ManaBar_Fade_Color, 0, 0, Perl_Party_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2") == 3) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Two_ManaBar_Fade_Color, Perl_Party_Two_ManaBar_Fade_Color, 0, Perl_Party_Two_ManaBar_Fade_Color);
	elseif (UnitPowerType("party2") == 6) then
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Two_ManaBar_Fade_Color, Perl_Party_Two_ManaBar_Fade_Color, Perl_Party_Two_ManaBar_Fade_Color);
	end

	if (Perl_Party_One_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_ManaBar_Fade_Color = 1;
		Perl_Party_Two_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_2_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_ManaBar_Fade(arg1)
	Perl_Party_Three_ManaBar_Fade_Color = Perl_Party_Three_ManaBar_Fade_Color - arg1;
	Perl_Party_Three_ManaBar_Fade_Time_Elapsed = Perl_Party_Three_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party3") == 0) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3") == 1) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Three_ManaBar_Fade_Color, 0, 0, Perl_Party_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3") == 3) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color, 0, Perl_Party_Three_ManaBar_Fade_Color);
	elseif (UnitPowerType("party3") == 6) then
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color, Perl_Party_Three_ManaBar_Fade_Color);
	end

	if (Perl_Party_Three_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_ManaBar_Fade_Color = 1;
		Perl_Party_Three_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_3_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_ManaBar_Fade(arg1)
	Perl_Party_Four_ManaBar_Fade_Color = Perl_Party_Four_ManaBar_Fade_Color - arg1;
	Perl_Party_Four_ManaBar_Fade_Time_Elapsed = Perl_Party_Four_ManaBar_Fade_Time_Elapsed + arg1;

	if (UnitPowerType("party4") == 0) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, 0, Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4") == 1) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Four_ManaBar_Fade_Color, 0, 0, Perl_Party_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4") == 3) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color, 0, Perl_Party_Four_ManaBar_Fade_Color);
	elseif (UnitPowerType("party4") == 6) then
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:SetStatusBarColor(0, Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color, Perl_Party_Four_ManaBar_Fade_Color);
	end

	if (Perl_Party_Four_ManaBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_ManaBar_Fade_Color = 1;
		Perl_Party_Four_ManaBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_ManaBarFadeBar:Hide();
		Perl_Party_4_ManaBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_One_PetHealthBar_Fade(arg1)
	Perl_Party_One_PetHealthBar_Fade_Color = Perl_Party_One_PetHealthBar_Fade_Color - arg1;
	Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = Perl_Party_One_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame1_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_One_PetHealthBar_Fade_Color, 0, Perl_Party_One_PetHealthBar_Fade_Color);

	if (Perl_Party_One_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_One_PetHealthBar_Fade_Color = 1;
		Perl_Party_One_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame1_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_1_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Two_PetHealthBar_Fade(arg1)
	Perl_Party_Two_PetHealthBar_Fade_Color = Perl_Party_Two_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame2_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Two_PetHealthBar_Fade_Color, 0, Perl_Party_Two_PetHealthBar_Fade_Color);

	if (Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Two_PetHealthBar_Fade_Color = 1;
		Perl_Party_Two_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame2_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_2_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Three_PetHealthBar_Fade(arg1)
	Perl_Party_Three_PetHealthBar_Fade_Color = Perl_Party_Three_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame3_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Three_PetHealthBar_Fade_Color, 0, Perl_Party_Three_PetHealthBar_Fade_Color);

	if (Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Three_PetHealthBar_Fade_Color = 1;
		Perl_Party_Three_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame3_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_3_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end

function Perl_Party_Four_PetHealthBar_Fade(arg1)
	Perl_Party_Four_PetHealthBar_Fade_Color = Perl_Party_Four_PetHealthBar_Fade_Color - arg1;
	Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed + arg1;

	Perl_Party_MemberFrame4_StatsFrame_PetHealthBarFadeBar:SetStatusBarColor(0, Perl_Party_Four_PetHealthBar_Fade_Color, 0, Perl_Party_Four_PetHealthBar_Fade_Color);

	if (Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed > 1) then
		Perl_Party_Four_PetHealthBar_Fade_Color = 1;
		Perl_Party_Four_PetHealthBar_Fade_Time_Elapsed = 0;
		Perl_Party_MemberFrame4_StatsFrame_PetHealthBarFadeBar:Hide();
		Perl_Party_4_PetHealthBar_Fade_OnUpdate_Frame:Hide();
	end
end


-------------------------------
-- Style Show/Hide Functions --
-------------------------------
function Perl_Party_Frame_Style()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Frame_Style);
	else
		-- Begin: Set the frame size for pets
		if (showpets == 1) then
			for id=1,4 do
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):SetHeight(54);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetHeight(54);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):Show();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):Show();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):Show();
			end
		else
			for id=1,4 do
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame"):SetHeight(42);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_CastClickOverlay"):SetHeight(42);
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar"):Hide();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBarBG"):Hide();
				getglobal("Perl_Party_MemberFrame"..id.."_StatsFrame_PetHealthBar_CastClickOverlay"):Hide();
			end
		end
		-- End: Set the frame size for pets

		-- Begin: Set the frame spacing
		if (verticalalign == 1) then
			Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", 0, partyspacing);
			Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", 0, partyspacing);
			Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", 0, partyspacing);

			if (showpets == 1) then
				local partypetspacing;
				if (partyspacing < 0) then			-- Frames are normal
					partypetspacing = partyspacing - 12;
				else						-- Frames are inverted
					partypetspacing = partyspacing + 12;
				end
			end
		else
			local horizontalspacing;
			if (partyspacing < 0) then
				horizontalspacing = partyspacing - 195;
			else
				horizontalspacing = partyspacing + 195;
			end
			Perl_Party_MemberFrame2:SetPoint("TOPLEFT", "Perl_Party_MemberFrame1", "TOPLEFT", horizontalspacing, 0);
			Perl_Party_MemberFrame3:SetPoint("TOPLEFT", "Perl_Party_MemberFrame2", "TOPLEFT", horizontalspacing, 0);
			Perl_Party_MemberFrame4:SetPoint("TOPLEFT", "Perl_Party_MemberFrame3", "TOPLEFT", horizontalspacing, 0);
		end
		-- End: Set the frame spacing

		-- Begin: Compact Mode
		if (compactmode == 0) then
			Perl_Party_MemberFrame1_StatsFrame:SetWidth(255);
			Perl_Party_MemberFrame2_StatsFrame:SetWidth(255);
			Perl_Party_MemberFrame3_StatsFrame:SetWidth(255);
			Perl_Party_MemberFrame4_StatsFrame:SetWidth(255);
			Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(255);
			Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(255);
			Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(255);
			Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(255);
		else
			if (shortbars == 0) then
				if (compactpercent == 0) then
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(170);
				else
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(205);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(205);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(205);
				end
			else
				if (compactpercent == 0) then
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(135);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(135);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(135);
				else
					Perl_Party_MemberFrame1_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame:SetWidth(170);
					Perl_Party_MemberFrame1_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame2_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame3_StatsFrame_CastClickOverlay:SetWidth(170);
					Perl_Party_MemberFrame4_StatsFrame_CastClickOverlay:SetWidth(170);
				end
			end
		end
		-- End: Compact Mode

		-- Begin: Short Bars
		if (compactmode == 1 and shortbars == 1) then
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num):SetWidth(167);
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"):SetWidth(167);
				getglobal("Perl_Party_MemberFrame"..num.."_Name"):SetWidth(167);
				getglobal("Perl_Party_MemberFrame"..num.."_Name_CastClickOverlay"):SetWidth(167);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(115);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(115);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(115);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(115);
			end
		else
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num):SetWidth(202);
				getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"):SetWidth(202);
				getglobal("Perl_Party_MemberFrame"..num.."_Name"):SetWidth(202);
				getglobal("Perl_Party_MemberFrame"..num.."_Name_CastClickOverlay"):SetWidth(202);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(150);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(150);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(150);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(150);
			end
		end
		-- End: Short Bars

		-- Begin: Hide Class Level Frame
		if (hideclasslevelframe == 1) then
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame"):Hide();
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetPoint("TOPLEFT", getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"), "BOTTOMLEFT", 0, 2);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_CastClickOverlay"):GetWidth() + 30);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_HealthBar_CastClickOverlay"):GetWidth() + 30);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_ManaBar_CastClickOverlay"):GetWidth() + 30);

				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarFadeBar"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBarBG"):GetWidth() + 30);
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):SetWidth(getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame_PetHealthBar_CastClickOverlay"):GetWidth() + 30);
			end
		else
			for num=1,4 do
				getglobal("Perl_Party_MemberFrame"..num.."_LevelFrame"):Show();
				getglobal("Perl_Party_MemberFrame"..num.."_StatsFrame"):SetPoint("TOPLEFT", getglobal("Perl_Party_MemberFrame"..num.."_NameFrame"), "BOTTOMLEFT", 32, 2);
			end
		end
		-- End: Hide Class Level Frame

		-- Begin: Set Text Positions
		for partynum=1,4 do
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):ClearAllPoints();
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):ClearAllPoints();
			getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):ClearAllPoints();
		end
		if (compactmode == 0) then
			for partynum=1,4 do
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", 85, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", 0, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", 85, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", 0, 1);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", 85, 0);
				getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", 0, 1);
			end
		else
			if (healermode == 0) then
				for partynum=1,4 do
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", 85, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOP", 0, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", 85, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOP", 0, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", 85, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOP", 0, 1);
				end
			else
				for partynum=1,4 do
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_ManaBar_ManaBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarText"):SetPoint("RIGHT", -10, 0);
					getglobal("Perl_Party_MemberFrame"..partynum.."_StatsFrame_PetHealthBar_PetHealthBarTextPercent"):SetPoint("TOPLEFT", 5, 1);
				end
			end
		end
		-- End: Set Text Positions

		-- Begin: Show/Hide the portrait frame
		for id=1,4 do
			if (showportrait == 1) then
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame"):Show();			-- Show the main portrait frame
				if (threedportrait == 0) then
					getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_PartyModel"):Hide();	-- Hide the 3d graphic
					getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame_Portrait"):Show();	-- Show the 2d graphic
				end
			else
				getglobal("Perl_Party_MemberFrame"..id.."_PortraitFrame"):Hide();			-- Hide the frame and 2d/3d portion
			end
		end
		-- End: Show/Hide the portrait frame

		Perl_Party_Update_All_Buff_Positions();	-- Update Buff Positions

		for id=1,4 do				-- Update the name length
			getglobal("Perl_Party_MemberFrame"..id.."_Name_NameBarText"):SetWidth(getglobal("Perl_Party_MemberFrame"..id.."_Name"):GetWidth() - 45);
			getglobal("Perl_Party_MemberFrame"..id.."_Name_NameBarText"):SetHeight(getglobal("Perl_Party_MemberFrame"..id.."_Name"):GetHeight() - 10);
			getglobal("Perl_Party_MemberFrame"..id.."_Name_NameBarText"):SetNonSpaceWrap(false);
		end

		if (Initialized) then
			Perl_Party_ArcaneBar_Support();
		end

		-- Added this to update when placement mode is enabled
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame1);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame2);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame3);
		Perl_Party_MembersUpdate(Perl_Party_MemberFrame4);
	end
end

function Perl_Party_ArcaneBar_Support()
	if (Perl_ArcaneBar_Frame_Loaded_Frame) then
		for id=1,4 do
			getglobal("Perl_ArcaneBar_party"..id):SetPoint("TOPLEFT", getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"), "TOPLEFT", 5, -5);
			getglobal("Perl_ArcaneBar_party"..id.."_CastTime"):ClearAllPoints();
			getglobal("Perl_ArcaneBar_party"..id.."_CastTime"):SetPoint("LEFT", getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"), "RIGHT", 0, 0);

			getglobal("Perl_ArcaneBar_party"..id):SetWidth(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetWidth() - 10);
			getglobal("Perl_ArcaneBar_party"..id.."_Flash"):SetWidth(getglobal("Perl_Party_MemberFrame"..id.."_NameFrame"):GetWidth() + 5);
		end

		Perl_ArcaneBar_Set_Spark_Width(nil, nil, nil, Perl_Party_MemberFrame1_NameFrame:GetWidth());
	end
end


--------------------------
-- GUI Config Functions --
--------------------------
function Perl_Party_Set_Space(number)
	if (number ~= nil) then
		partyspacing = -number;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
end

function Perl_Party_Set_Hidden(newvalue)
	if (newvalue ~= nil) then
		partyhidden = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Check_Hidden();
end

function Perl_Party_Set_Compact(newvalue)
	if (newvalue ~= nil) then
		compactmode = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Healer(newvalue)
	if (newvalue ~= nil) then
		healermode = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Pets(newvalue)
	if (newvalue ~= nil) then
		showpets = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Lock(newvalue)
	locked = newvalue;
	Perl_Party_UpdateVars();
end

function Perl_Party_Set_VerticalAlign(newvalue)
	verticalalign = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
end

function Perl_Party_Set_Compact_Percent(newvalue)
	compactpercent = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
end

function Perl_Party_Set_Short_Bars(newvalue)
	shortbars = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
end

function Perl_Party_Set_Portrait(newvalue)
	showportrait = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame1);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame2);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame3);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame4);
end

function Perl_Party_Set_3D_Portrait(newvalue)
	threedportrait = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Frame_Style();
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame1);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame2);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame3);
	Perl_Party_Update_Portrait(Perl_Party_MemberFrame4);
end

function Perl_Party_Set_FKeys(newvalue)
	showfkeys = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Mana_Deficit(newvalue)
	showmanadeficit = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Class_Buffs(newvalue)
	if (newvalue ~= nil) then
		displaycastablebuffs = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Class_Debuffs(newvalue)
	if (newvalue ~= nil) then
		displaycurabledebuff = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Buff_Timers(newvalue)
	if (newvalue ~= nil) then
		displaybufftimers = newvalue;
	end
	Perl_Party_UpdateVars();		-- Save the new setting
	Perl_Party_Reset_Buffs();		-- Reset the buff icons
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Buff_Location(newvalue)
	if (newvalue ~= nil) then
		bufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Update_All_Buff_Positions();
end

function Perl_Party_Set_Debuff_Location(newvalue)
	if (newvalue ~= nil) then
		debufflocation = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Update_All_Buff_Positions();
end

function Perl_Party_Set_Buff_Size(newvalue)
	if (newvalue ~= nil) then
		buffsize = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Debuff_Size(newvalue)
	if (newvalue ~= nil) then
		debuffsize = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Buffs(newvalue)
	if (newvalue ~= nil) then
		numbuffsshown = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Debuffs(newvalue)
	if (newvalue ~= nil) then
		numdebuffsshown = newvalue;
	end
	Perl_Party_UpdateVars();
	Perl_Party_Reset_Buffs();		-- Reset the buff icons and set size
	Perl_Party_Update_Buffs();		-- Repopulate the buff icons
end

function Perl_Party_Set_Class_Colored_Names(newvalue)
	classcolorednames = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Hide_Class_Level_Frame(newvalue)
	hideclasslevelframe = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Set_Compact();
	Perl_Party_Update_All_Buff_Positions();
end

function Perl_Party_Set_PvP_Icon(newvalue)
	showpvpicon = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Force_Update();
end

function Perl_Party_Set_Show_Bar_Values(newvalue)
	showbarvalues = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Update_Health_Mana();
end

function Perl_Party_Set_Portrait_Buffs(newvalue)
	portraitbuffs = newvalue;
	Perl_Party_UpdateVars();
	Perl_Party_Update_All_Buff_Positions();
end

function Perl_Party_Set_Scale(number)
	if (number ~= nil) then
		scale = (number / 100);
	end
	Perl_Party_UpdateVars();
	Perl_Party_Set_Scale_Actual();
end

function Perl_Party_Set_Scale_Actual()
	if (InCombatLockdown()) then
		Perl_Config_Queue_Add(Perl_Party_Set_Scale_Actual);
	else
		Perl_Party_Frame:SetScale(1 - UIParent:GetEffectiveScale() + scale);	-- run it through the scaling formula introduced in 1.9
		if (Perl_ArcaneBar_Frame_Loaded_Frame) then
			Perl_ArcaneBar_Set_Scale_Actual(nil, nil, nil, scale);
		end
	end
end

function Perl_Party_Set_Transparency(number)
	if (number ~= nil) then
		transparency = (number / 100);
	end
	Perl_Party_UpdateVars();
	Perl_Party_MemberFrame1:SetAlpha(transparency);
	Perl_Party_MemberFrame2:SetAlpha(transparency);
	Perl_Party_MemberFrame3:SetAlpha(transparency);
	Perl_Party_MemberFrame4:SetAlpha(transparency);
end


------------------------------
-- Saved Variable Functions --
------------------------------
function Perl_Party_GetVars(name, updateflag)
	if (name == nil) then
		name = UnitName("player");
	end

	locked = Perl_Party_Config[name]["Locked"];
	compactmode = Perl_Party_Config[name]["CompactMode"];
	partyhidden = Perl_Party_Config[name]["PartyHidden"];
	partyspacing = Perl_Party_Config[name]["PartySpacing"];
	scale = Perl_Party_Config[name]["Scale"];
	showpets = Perl_Party_Config[name]["ShowPets"];
	healermode = Perl_Party_Config[name]["HealerMode"];
	transparency = Perl_Party_Config[name]["Transparency"];
	bufflocation = Perl_Party_Config[name]["BuffLocation"];
	debufflocation = Perl_Party_Config[name]["DebuffLocation"];
	verticalalign = Perl_Party_Config[name]["VerticalAlign"];
	compactpercent = Perl_Party_Config[name]["CompactPercent"];
	showportrait = Perl_Party_Config[name]["ShowPortrait"];
	showfkeys = Perl_Party_Config[name]["ShowFKeys"];
	displaycastablebuffs = Perl_Party_Config[name]["DisplayCastableBuffs"];
	threedportrait = Perl_Party_Config[name]["ThreeDPortrait"];
	buffsize = Perl_Party_Config[name]["BuffSize"];
	debuffsize = Perl_Party_Config[name]["DebuffSize"];
	numbuffsshown = Perl_Party_Config[name]["Buffs"];
	numdebuffsshown = Perl_Party_Config[name]["Debuffs"];
	classcolorednames = Perl_Party_Config[name]["ClassColoredNames"];
	shortbars = Perl_Party_Config[name]["ShortBars"];
	hideclasslevelframe = Perl_Party_Config[name]["HideClassLevelFrame"];
	showmanadeficit = Perl_Party_Config[name]["ShowManaDeficit"];
	showpvpicon = Perl_Party_Config[name]["ShowPvPIcon"];
	showbarvalues = Perl_Party_Config[name]["ShowBarValues"];
	displaycurabledebuff = Perl_Party_Config[name]["DisplayCurableDebuff"];
	portraitbuffs = Perl_Party_Config[name]["PortraitBuffs"];
	displaybufftimers = Perl_Party_Config[name]["DisplayBuffTimers"];

	if (locked == nil) then
		locked = 0;
	end
	if (compactmode == nil) then
		compactmode = 0;
	end
	if (partyhidden == nil) then
		partyhidden = 0;
	end
	if (partyspacing == nil) then
		partyspacing = -95;
	end
	if (scale == nil) then
		scale = 0.9;
	end
	if (showpets == nil) then
		showpets = 1;
	end
	if (healermode == nil) then
		healermode = 0;
	end
	if (transparency == nil) then
		transparency = 1;
	end
	if (bufflocation == nil) then
		bufflocation = 6;
	end
	if (debufflocation == nil) then
		debufflocation = 3;
	end
	if (verticalalign == nil) then
		verticalalign = 1;
	end
	if (compactpercent == nil) then
		compactpercent = 0;
	end
	if (showportrait == nil) then
		showportrait = 0;
	end
	if (showfkeys == nil) then
		showfkeys = 1;
	end
	if (displaycastablebuffs == nil) then
		displaycastablebuffs = 0;
	end
	if (threedportrait == nil) then
		threedportrait = 0;
	end
	if (buffsize == nil) then
		buffsize = 16;
	end
	if (debuffsize == nil) then
		debuffsize = 16;
	end
	if (numbuffsshown == nil) then
		numbuffsshown = 16;
	end
	if (numdebuffsshown == nil) then
		numdebuffsshown = 16;
	end
	if (classcolorednames == nil) then
		classcolorednames = 0;
	end
	if (shortbars == nil) then
		shortbars = 0;
	end
	if (hideclasslevelframe == nil) then
		hideclasslevelframe = 0;
	end
	if (showmanadeficit == nil) then
		showmanadeficit = 0;
	end
	if (showpvpicon == nil) then
		showpvpicon = 1;
	end
	if (showbarvalues == nil) then
		showbarvalues = 0;
	end
	if (displaycurabledebuff == nil) then
		displaycurabledebuff = 0;
	end
	if (portraitbuffs == nil) then
		portraitbuffs = 1;
	end
	if (displaybufftimers == nil) then
		displaybufftimers = 0;
	end

	if (updateflag == 1) then
		-- Save the new values
		Perl_Party_UpdateVars();

		-- Call any code we need to activate them
		Perl_Party_Check_Hidden();
		Perl_Party_Set_Compact();
		Perl_Party_Set_Healer();
		Perl_Party_Set_Pets();
		Perl_Party_Reset_Buffs();		-- Reset the buff icons and set sizes
		Perl_Party_Update_Buffs();		-- Repopulate the buff icons
		Perl_Party_Frame_Style();
		Perl_Party_Set_Scale_Actual();
		Perl_Party_Set_Transparency();
		return;
	end

	local vars = {
		["locked"] = locked,
		["compactmode"] = compactmode,
		["partyhidden"] = partyhidden,
		["partyspacing"] = partyspacing,
		["scale"] = scale,
		["showpets"] = showpets,
		["healermode"] = healermode,
		["transparency"] = transparency,
		["bufflocation"] = bufflocation,
		["debufflocation"] = debufflocation,
		["verticalalign"] = verticalalign,
		["compactpercent"] = compactpercent,
		["showportrait"] = showportrait,
		["showfkeys"] = showfkeys,
		["displaycastablebuffs"] = displaycastablebuffs,
		["threedportrait"] = threedportrait,
		["buffsize"] = buffsize,
		["debuffsize"] = debuffsize,
		["numbuffsshown"] = numbuffsshown,
		["numdebuffsshown"] = numdebuffsshown,
		["classcolorednames"] = classcolorednames,
		["shortbars"] = shortbars,
		["hideclasslevelframe"] = hideclasslevelframe,
		["showmanadeficit"] = showmanadeficit,
		["showpvpicon"] = showpvpicon,
		["showbarvalues"] = showbarvalues,
		["displaycurabledebuff"] = displaycurabledebuff,
		["portraitbuffs"] = portraitbuffs,
		["displaybufftimers"] = displaybufftimers,
	}
	return vars;
end

function Perl_Party_UpdateVars(vartable)
	if (vartable ~= nil) then
		-- Sanity checks in case you use a load from an old version
		if (vartable["Global Settings"] ~= nil) then
			if (vartable["Global Settings"]["Locked"] ~= nil) then
				locked = vartable["Global Settings"]["Locked"];
			else
				locked = nil;
			end
			if (vartable["Global Settings"]["CompactMode"] ~= nil) then
				compactmode = vartable["Global Settings"]["CompactMode"];
			else
				compactmode = nil;
			end
			if (vartable["Global Settings"]["PartyHidden"] ~= nil) then
				partyhidden = vartable["Global Settings"]["PartyHidden"];
			else
				partyhidden = nil;
			end
			if (vartable["Global Settings"]["PartySpacing"] ~= nil) then
				partyspacing = vartable["Global Settings"]["PartySpacing"];
			else
				partyspacing = nil;
			end
			if (vartable["Global Settings"]["Scale"] ~= nil) then
				scale = vartable["Global Settings"]["Scale"];
			else
				scale = nil;
			end
			if (vartable["Global Settings"]["ShowPets"] ~= nil) then
				showpets = vartable["Global Settings"]["ShowPets"];
			else
				showpets = nil;
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
			if (vartable["Global Settings"]["BuffLocation"] ~= nil) then
				bufflocation = vartable["Global Settings"]["BuffLocation"];
			else
				bufflocation = nil;
			end
			if (vartable["Global Settings"]["DebuffLocation"] ~= nil) then
				debufflocation = vartable["Global Settings"]["DebuffLocation"];
			else
				debufflocation = nil;
			end
			if (vartable["Global Settings"]["VerticalAlign"] ~= nil) then
				verticalalign = vartable["Global Settings"]["VerticalAlign"];
			else
				verticalalign = nil;
			end
			if (vartable["Global Settings"]["CompactPercent"] ~= nil) then
				compactpercent = vartable["Global Settings"]["CompactPercent"];
			else
				compactpercent = nil;
			end
			if (vartable["Global Settings"]["ShowPortrait"] ~= nil) then
				showportrait = vartable["Global Settings"]["ShowPortrait"];
			else
				showportrait = nil;
			end
			if (vartable["Global Settings"]["ShowFKeys"] ~= nil) then
				showfkeys = vartable["Global Settings"]["ShowFKeys"];
			else
				showfkeys = nil;
			end
			if (vartable["Global Settings"]["DisplayCastableBuffs"] ~= nil) then
				displaycastablebuffs = vartable["Global Settings"]["DisplayCastableBuffs"];
			else
				displaycastablebuffs = nil;
			end
			if (vartable["Global Settings"]["ThreeDPortrait"] ~= nil) then
				threedportrait = vartable["Global Settings"]["ThreeDPortrait"];
			else
				threedportrait = nil;
			end
			if (vartable["Global Settings"]["BuffSize"] ~= nil) then
				buffsize = vartable["Global Settings"]["BuffSize"];
			else
				buffsize = nil;
			end
			if (vartable["Global Settings"]["DebuffSize"] ~= nil) then
				debuffsize = vartable["Global Settings"]["DebuffSize"];
			else
				debuffsize = nil;
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
			if (vartable["Global Settings"]["ClassColoredNames"] ~= nil) then
				classcolorednames = vartable["Global Settings"]["ClassColoredNames"];
			else
				classcolorednames = nil;
			end
			if (vartable["Global Settings"]["ShortBars"] ~= nil) then
				shortbars = vartable["Global Settings"]["ShortBars"];
			else
				shortbars = nil;
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
			if (vartable["Global Settings"]["DisplayCurableDebuff"] ~= nil) then
				displaycurabledebuff = vartable["Global Settings"]["DisplayCurableDebuff"];
			else
				displaycurabledebuff = nil;
			end
			if (vartable["Global Settings"]["PortraitBuffs"] ~= nil) then
				portraitbuffs = vartable["Global Settings"]["PortraitBuffs"];
			else
				portraitbuffs = nil;
			end
			if (vartable["Global Settings"]["DisplayBuffTimers"] ~= nil) then
				displaybufftimers = vartable["Global Settings"]["DisplayBuffTimers"];
			else
				displaybufftimers = nil;
			end
		end

		-- Set the new values if any new values were found, same defaults as above
		if (locked == nil) then
			locked = 0;
		end
		if (compactmode == nil) then
			compactmode = 0;
		end
		if (partyhidden == nil) then
			partyhidden = 0;
		end
		if (partyspacing == nil) then
			partyspacing = -95;
		end
		if (scale == nil) then
			scale = 0.9;
		end
		if (showpets == nil) then
			showpets = 1;
		end
		if (healermode == nil) then
			healermode = 0;
		end
		if (transparency == nil) then
			transparency = 1;
		end
		if (bufflocation == nil) then
			bufflocation = 6;
		end
		if (debufflocation == nil) then
			debufflocation = 3;
		end
		if (verticalalign == nil) then
			verticalalign = 1;
		end
		if (compactpercent == nil) then
			compactpercent = 0;
		end
		if (showportrait == nil) then
			showportrait = 0;
		end
		if (showfkeys == nil) then
			showfkeys = 1;
		end
		if (displaycastablebuffs == nil) then
			displaycastablebuffs = 0;
		end
		if (threedportrait == nil) then
			threedportrait = 0;
		end
		if (buffsize == nil) then
			buffsize = 16;
		end
		if (debuffsize == nil) then
			debuffsize = 16;
		end
		if (numbuffsshown == nil) then
			numbuffsshown = 16;
		end
		if (numdebuffsshown == nil) then
			numdebuffsshown = 16;
		end
		if (classcolorednames == nil) then
			classcolorednames = 0;
		end
		if (shortbars == nil) then
			shortbars = 0;
		end
		if (hideclasslevelframe == nil) then
			hideclasslevelframe = 0;
		end
		if (showmanadeficit == nil) then
			showmanadeficit = 0;
		end
		if (showpvpicon == nil) then
			showpvpicon = 1;
		end
		if (showbarvalues == nil) then
			showbarvalues = 0;
		end
		if (displaycurabledebuff == nil) then
			displaycurabledebuff = 0;
		end
		if (portraitbuffs == nil) then
			portraitbuffs = 1;
		end
		if (displaybufftimers == nil) then
			displaybufftimers = 0;
		end

		-- Call any code we need to activate them
		Perl_Party_Check_Hidden();
		Perl_Party_Set_Compact();
		Perl_Party_Set_Healer();
		Perl_Party_Set_Pets();
		Perl_Party_Reset_Buffs();		-- Reset the buff icons and set sizes
		Perl_Party_Update_Buffs();		-- Repopulate the buff icons
		Perl_Party_Frame_Style();
		Perl_Party_Set_Scale_Actual();
		Perl_Party_Set_Transparency();
	end

	Perl_Party_Config[UnitName("player")] = {
		["Locked"] = locked,
		["CompactMode"] = compactmode,
		["PartyHidden"] = partyhidden,
		["PartySpacing"] = partyspacing,
		["Scale"] = scale,
		["ShowPets"] = showpets,
		["HealerMode"] = healermode,
		["Transparency"] = transparency,
		["BuffLocation"] = bufflocation,
		["DebuffLocation"] = debufflocation,
		["VerticalAlign"] = verticalalign,
		["CompactPercent"] = compactpercent,
		["ShowPortrait"] = showportrait,
		["ShowFKeys"] = showfkeys,
		["DisplayCastableBuffs"] = displaycastablebuffs,
		["ThreeDPortrait"] = threedportrait,
		["BuffSize"] = buffsize,
		["DebuffSize"] = debuffsize,
		["Buffs"] = numbuffsshown,
		["Debuffs"] = numdebuffsshown,
		["ClassColoredNames"] = classcolorednames,
		["ShortBars"] = shortbars,
		["HideClassLevelFrame"] = hideclasslevelframe,
		["ShowManaDeficit"] = showmanadeficit,
		["ShowPvPIcon"] = showpvpicon,
		["ShowBarValues"] = showbarvalues,
		["DisplayCurableDebuff"] = displaycurabledebuff,
		["PortraitBuffs"] = portraitbuffs,
		["DisplayBuffTimers"] = displaybufftimers,
	};
end


--------------------
-- Buff Functions --
--------------------
function Perl_Party_Buff_UpdateAll(self)
	if (UnitName(self.unit)) then
		local button, buffCount, buffTexture, buffApplications, color, debuffType, cooldown, duration, timeLeft;	-- Variables for both buffs and debuffs (yes, I'm using buff names for debuffs, wanna fight about it?)
		local curableDebuffFound = 0;

		for buffnum=1,numbuffsshown do									-- Start main buff loop
			if (displaycastablebuffs == 0) then							-- Which buff filter mode are we in?
				bufffilter = "HELPFUL";
			else
				bufffilter = "HELPFUL RAID";
			end
			_, _, buffTexture, buffApplications, _, duration, timeLeft, _, _ = UnitAura(self.unit, buffnum, bufffilter);	-- Get the texture and buff stacking information if any
			button = getglobal("Perl_Party_MemberFrame"..self.id.."_BuffFrame_Buff"..buffnum);				-- Create the main icon for the buff
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
				button:Show();												-- Show the final buff icon
			else
				button:Hide();												-- Hide the icon since there isn't a buff in this position
			end
		end															-- End main buff loop

		for debuffnum=1,numdebuffsshown do											-- Start main debuff loop
			if (displaycurabledebuff == 1) then								-- Are we targeting a friend or enemy and which filter do we need to apply?
				debufffilter = "HARMFUL RAID";
			else
				debufffilter = "HARMFUL";
			end
			_, _, buffTexture, buffApplications, debuffType, duration, timeLeft, _, _ = UnitAura(self.unit, debuffnum, debufffilter);	-- Get the texture and debuff stacking information if any
			button = getglobal("Perl_Party_MemberFrame"..self.id.."_BuffFrame_Debuff"..debuffnum);				-- Create the main icon for the debuff
			if (buffTexture) then												-- If there is a valid texture, proceed with debuff icon creation
				getglobal(button:GetName().."Icon"):SetTexture(buffTexture);						-- Set the texture
				if (debuffType) then
					color = DebuffTypeColor[debuffType];
					if (PCUF_COLORFRAMEDEBUFF == 1) then
						if (curableDebuffFound == 0) then
							if (Perl_Config_Set_Curable_Debuffs(debuffType) == 1) then
								getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame"):SetBackdropBorderColor(color.r, color.g, color.b, 1);
								getglobal("Perl_Party_MemberFrame"..self.id.."_LevelFrame"):SetBackdropBorderColor(color.r, color.g, color.b, 1);
								getglobal("Perl_Party_MemberFrame"..self.id.."_PortraitFrame"):SetBackdropBorderColor(color.r, color.g, color.b, 1);
								getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame"):SetBackdropBorderColor(color.r, color.g, color.b, 1);
								curableDebuffFound = 1;
							end
						end
					end
				else
					color = DebuffTypeColor[PERL_LOCALIZED_BUFF_NONE];
				end
				getglobal(button:GetName().."DebuffBorder"):SetVertexColor(color.r, color.g, color.b);		-- Set the debuff border color
				getglobal(button:GetName().."DebuffBorder"):Show();						-- Show the debuff border
				buffCount = getglobal(button:GetName().."Count");						-- Declare the debuff counting text variable
				if (buffApplications > 1) then
					buffCount:SetText(buffApplications);							-- Set the text to the number of applications if greater than 0
					buffCount:Show();									-- Show the text
				else
					buffCount:Hide();									-- Hide the text if equal to 0
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
				button:Show();											-- Show the final debuff icon
			else
				button:Hide();											-- Hide the icon since there isn't a debuff in this position
			end
		end														-- End main debuff loop

		if (curableDebuffFound == 0) then
			getglobal("Perl_Party_MemberFrame"..self.id.."_NameFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..self.id.."_LevelFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..self.id.."_PortraitFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
			getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame"):SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
		end

		if (UnitIsDead(self.unit)) then
			_, englishclass = UnitClass(self.unit);
			if (englishclass == "HUNTER") then	-- If the dead is a hunter, check for Feign Death
				local buffnum = 1;
				_, _, buffTexture = UnitBuff(self.unit, buffnum);
				while (buffTexture) do
					if (buffTexture == "Interface\\Icons\\Ability_Rogue_FeignDeath") then
						if (compactmode == 0) then
							getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar_HealthBarText"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						else
							getglobal("Perl_Party_MemberFrame"..self.id.."_StatsFrame_HealthBar_HealthBarTextPercent"):SetText(PERL_LOCALIZED_STATUS_FEIGNDEATH);
						end
						break;
					end
					buffnum = buffnum + 1;
					_, _, buffTexture = UnitBuff(self.unit, buffnum);
				end
			end
		end
	end
end

function Perl_Party_Update_Buffs()
	Perl_Party_Buff_UpdateAll(Perl_Party_MemberFrame1);
	Perl_Party_Buff_UpdateAll(Perl_Party_MemberFrame2);
	Perl_Party_Buff_UpdateAll(Perl_Party_MemberFrame3);
	Perl_Party_Buff_UpdateAll(Perl_Party_MemberFrame4);
end

function Perl_Party_Update_All_Buff_Positions()
	Perl_Party_Buff_Position_Update(1);
	Perl_Party_Buff_Position_Update(2);
	Perl_Party_Buff_Position_Update(3);
	Perl_Party_Buff_Position_Update(4);
end

function Perl_Party_Buff_Position_Update(id)
	getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):ClearAllPoints();
	if (bufflocation == 1) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "TOPLEFT", 3, 20);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 3, 20);
		end
	elseif (bufflocation == 2) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "TOPLEFT", 3, 0);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 3, 0);
		end
	elseif (bufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (bufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (bufflocation == 6) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "BOTTOMLEFT", 3, 0);
		else
			if (hideclasslevelframe == 0) then
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, 0);
			end
		end
	elseif (bufflocation == 7) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "BOTTOMLEFT", 3, -20);
		else
			if (hideclasslevelframe == 0) then
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, -20);
			end
		end
	end

	getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):ClearAllPoints();
	if (debufflocation == 1) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "TOPLEFT", 3, 20);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 3, 20);
		end
	elseif (debufflocation == 2) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "TOPLEFT", 3, 0);
		else
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("BOTTOMLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPLEFT", 3, 0);
		end
	elseif (debufflocation == 3) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_NameFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 4) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -3);
	elseif (debufflocation == 5) then
		getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "TOPRIGHT", 0, -23);
	elseif (debufflocation == 6) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "BOTTOMLEFT", 3, 0);
		else
			if (hideclasslevelframe == 0) then
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, 0);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, 0);
			end
		end
	elseif (debufflocation == 7) then
		if (portraitbuffs == 1 and showportrait == 1) then
			getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_PortraitFrame", "BOTTOMLEFT", 3, -20);
		else
			if (hideclasslevelframe == 0) then
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", -27, -20);
			else
				getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff1"):SetPoint("TOPLEFT", "Perl_Party_MemberFrame"..id.."_StatsFrame", "BOTTOMLEFT", 3, -20);
			end
		end
	end
end

function Perl_Party_Reset_Buffs()
	local button, debuff, icon, cooldown;
	for id=1,4 do
		for buffnum=1,16 do
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Buff"..buffnum);
			icon = getglobal(button:GetName().."Icon");
			debuff = getglobal(button:GetName().."DebuffBorder");
			cooldown = getglobal(button:GetName().."Cooldown");
			CooldownFrame_SetTimer(cooldown, 0, 0, 0);
			cooldown:Hide();
			button:SetHeight(buffsize);
			button:SetWidth(buffsize);
			icon:SetHeight(buffsize);
			icon:SetWidth(buffsize);
			debuff:SetHeight(buffsize);
			debuff:SetWidth(buffsize);
			button:Hide();
			debuff:Hide();
		end
		for buffnum=1,16 do
			button = getglobal("Perl_Party_MemberFrame"..id.."_BuffFrame_Debuff"..buffnum);
			icon = getglobal(button:GetName().."Icon");
			debuff = getglobal(button:GetName().."DebuffBorder");
			cooldown = getglobal(button:GetName().."Cooldown");
			CooldownFrame_SetTimer(cooldown, 0, 0, 0);
			cooldown:Hide();
			button:SetHeight(debuffsize);
			button:SetWidth(debuffsize);
			icon:SetHeight(debuffsize);
			icon:SetWidth(debuffsize);
			debuff:SetHeight(debuffsize);
			debuff:SetWidth(debuffsize);
			button:Hide();
			debuff:Hide();
		end
	end
end

function Perl_Party_SetBuffTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	if (self:GetID() > 16) then
		GameTooltip:SetUnitDebuff("party"..self:GetParent():GetParent():GetID(), self:GetID()-16, displaycurabledebuff);	-- 16 being the number of buffs before debuffs in the xml
	else
		GameTooltip:SetUnitBuff("party"..self:GetParent():GetParent():GetID(), self:GetID(), displaycastablebuffs);
	end
end


--------------------
-- Click Handlers --
--------------------
function Perl_Party_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_MemberFrame"..self:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_MemberFrame"..self:GetParent():GetParent():GetID(), 0, 0);
	end
	SecureUnitButton_OnLoad(self, "party"..self:GetParent():GetParent():GetID(), showmenu);

	self:SetAttribute("unit", "party"..self:GetParent():GetParent():GetID());
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end

function Perl_PartyDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, Perl_PartyDropDown_Initialize, "MENU");
end

function Perl_PartyDropDown_Initialize(self)
	local dropdown = UIDROPDOWNMENU_OPEN_MENU or self;
	UnitPopup_ShowMenu(dropdown, "PARTY", "party"..dropdown:GetParent():GetID());
end

function Perl_Party_DragStart(button)
	if (button == "LeftButton" and locked == 0) then
		Perl_Party_Frame:StartMoving();
	end
end

function Perl_Party_DragStop(button)
	Perl_Party_Frame:StopMovingOrSizing();
end

function Perl_Party_Pet_CastClickOverlay_OnLoad(self)
	local showmenu = function()
		ToggleDropDownMenu(1, nil, getglobal("Perl_Party_MemberFrame"..self:GetParent():GetParent():GetID().."_DropDown"), "Perl_Party_MemberFrame"..self:GetParent():GetParent():GetID(), 0, 0);
	end
	SecureUnitButton_OnLoad(self, "partypet"..self:GetParent():GetParent():GetID(), showmenu);

	self:SetAttribute("unit", "partypet"..self:GetParent():GetParent():GetID());
	if (not ClickCastFrames) then
		ClickCastFrames = {};
	end
	ClickCastFrames[self] = true;
end


----------------------
-- myAddOns Support --
----------------------
function Perl_Party_myAddOns_Support()
	-- Register the addon in myAddOns
	if (myAddOnsFrame_Register) then
		local Perl_Party_myAddOns_Details = {
			name = "Perl_Party",
			version = PERL_LOCALIZED_VERSION,
			releaseDate = PERL_LOCALIZED_DATE,
			author = "Perl; Maintained by Global",
			email = "global@g-ball.com",
			website = "http://www.curse-gaming.com/mod.php?addid=2257",
			category = MYADDONS_CATEGORY_OTHERS
		};
		Perl_Party_myAddOns_Help = {};
		Perl_Party_myAddOns_Help[1] = "/perl";
		myAddOnsFrame_Register(Perl_Party_myAddOns_Details, Perl_Party_myAddOns_Help);
	end
end
