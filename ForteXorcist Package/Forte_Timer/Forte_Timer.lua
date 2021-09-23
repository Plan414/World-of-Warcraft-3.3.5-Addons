--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local FW = FW;
local FWL = FW.L;
local ST = FW:Module("Timer",1);
local CA = FW:Module("Casting");
local CD = FW:Module("Cooldown");

local STATES = FW.STATES;
local GetTime = GetTime;
local strfind = strfind;
local gsub = string.gsub;
local strsub = strsub;
local UnitAura = FW.UnitAura;
local UnitName = FW.FullUnitName;
--local InCombatLockdown = InCombatLockdown;
local erase = FW.ERASE;
local pairs = pairs;
local ipairs = ipairs;
local unpack = unpack;
local _G = _G;
local math = math;
local abs = math.abs;
local cos = math.cos;
--local sin = math.sin;
local sqrt = math.sqrt;
local max = math.max;
local pow = math.pow;
local band = bit.band;
local instances = FW:NEW2D();
--local FILTER_ALL = 1;

local maxlag = 1.00; -- lower is better, but once you get over this with your actual lag weird things may happen

local IGNORE = -1;
local NORMAL = 0;
local FADING_INSTANT = 1;
local FADING = 2;
local REMOVE = 3;
local FAILED = 4;

local FILTER_ALWAYS = FW.FILTER_ALWAYS;
local FILTER_SHOW = FW.FILTER_SHOW;
local FILTER_NONE = FW.FILTER_NONE;
local FILTER_HIDE = FW.FILTER_HIDE;
local FILTER_COLOR = FW.FILTER_COLOR;
local FILTER_SHOW_COLOR = FW.FILTER_SHOW_COLOR;

local PRIOR_NONE = 0;
local PRIOR_COOLDOWN = -1;
local PRIOR_DEBUFF = -2;
local PRIOR_SELF_DEBUFF = -3;
local PRIOR_POWERUP = -4;

ST.PRIOR_NONE = PRIOR_NONE;
ST.PRIOR_COOLDOWN = PRIOR_COOLDOWN;
ST.PRIOR_DEBUFF = PRIOR_DEBUFF;
ST.PRIOR_SELF_DEBUFF = PRIOR_SELF_DEBUFF;
ST.PRIOR_POWERUP = PRIOR_POWERUP;

local FADE_SHOW = {FWL.SHORT_HIDE,FWL.SHORT_FADE,FWL.SHORT_REMOVED,FWL.SHORT_RESISTED,FWL.SHORT_IMMUNE,FWL.SHORT_EVADED,FWL.SHORT_REFLECTED};
local feign = FW:SpellName(5384);

local ActiveDots = FW:NEW2D();
local ST_OnTimerFade = {};
local ST_OnTimerBreak = {};
local ST_OnBuffGain = {};

local BuffDelay = 4.0; -- absolute maximum time before checking if a buff/debuff is still present after a cast
-- TO DO : ADD A FLAG FOR INSTANT OR TRAVEL TIME SPELLS TO IMPROVE TIMER!
-- TO DO : ACTUALLY ADD A 'WAITING' STATE TO TRAVEL TIME SPELLS IN WHICH THE TIMER STILL LISTENS FOR RESISTS

local st = FW:NEW2D();

local function addLinks(index)
	for i=1,instances.rows,1 do
		instances[i][2]:addLink(index);
	end
end
local function removeLinks(index)
	for i=1,instances.rows,1 do
		instances[i][2]:removeLink(index);
	end
end
local function eraseLinks()
	for i=1,instances.rows,1 do
		instances[i][2]:eraseLinks();
	end
end

local function rebuildLinks()
	for i=1,instances.rows,1 do
		instances[i][2]:rebuildLinks();
	end
end

local function setValueLinks(index,col,val)
	for i=1,instances.rows,1 do
		instances[i][2]:setValueLinks(index,col,val);
	end
end

local orig_insert = st.insert;
st.insert = function(self,...)
	orig_insert(self,...);
	addLinks(self.rows);
	--FXT();
	--FW:Show("works");
end
local orig_remove = st.remove;
st.remove = function(self,index)
	orig_remove(self,index);
	if index then
		removeLinks(index);
	end
	--FXT();
end
local orig_erase = st.erase;
st.erase = function(self)
	orig_erase(self);
	eraseLinks();
	--FXT();
end

--[[function FXT()
	FW:Show("TIMERS");
	st:print();
	for i=1,instances.rows,1 do
		FW:Show("INSTANCE "..i);
		instances[i][2]:printLinks();
	end
end]]

local ManualSpell = {};

local SpellAdd = {};
local Track = {};
local TrackBuffs = {};
local Stacks = {};
local TrackSelfDebuffs = {};
local TrackDebuffs = {};
local TrackCooldowns = {};
local Tick = {}
local Hasted = {};
local Drain = {};
local SpellRemap = {};
local DurationPVP = {};

ST.ManualSpell = ManualSpell;

ST.ST = st; -- to access it from modules
ST.Track = Track;
ST.Tick = Tick;
ST.Hasted = Hasted;
ST.Drain = Drain;
ST.SpellRemap = SpellRemap;
ST.DurationPVP = DurationPVP;

local maxi = 100;
local sortSwapTable = {};
local function UpdateSortOrder(powerup,selfdebuff,debuff,cooldown,none)
	-- create a table for easier swapping
	sortSwapTable[PRIOR_NONE] = none;
	sortSwapTable[PRIOR_COOLDOWN] = cooldown;
	sortSwapTable[PRIOR_DEBUFF] = debuff;
	sortSwapTable[PRIOR_SELF_DEBUFF] = selfdebuff;
	sortSwapTable[PRIOR_POWERUP] = powerup;
	
	-- swap the priorities
	for i=1,st.rows,1 do
		if st[i][13] <= 0 or st[i][13] >= maxi then
			st[i][13] = sortSwapTable[ st[i][13] ];
		end
	end

	-- keep track of the current settings
	PRIOR_NONE = none;
	PRIOR_COOLDOWN = cooldown;
	PRIOR_DEBUFF = debuff;
	PRIOR_SELF_DEBUFF = selfdebuff;
	PRIOR_POWERUP = powerup;
	
	ST.PRIOR_NONE = PRIOR_NONE;
	ST.PRIOR_COOLDOWN = PRIOR_COOLDOWN;
	ST.PRIOR_DEBUFF = PRIOR_DEBUFF;
	ST.PRIOR_SELF_DEBUFF = PRIOR_SELF_DEBUFF;
	ST.PRIOR_POWERUP = PRIOR_POWERUP;
end

local str = {};
local ord = {};

local function ST_CreateSortOrder()
	-- "buff,selfdebuff,debuff,cooldown,notarget,target";

	str[1],str[2],str[3],str[4],str[5],str[6] = strsplit(" ",FW.Settings.TimerSortOrder);
	for i=1,6 do
		if not str[i] then
			FW.Settings.TimerSortOrder = FW.Default.TimerSortOrder;
			--FW:RefreshOptions();
			ST_CreateSortOrder();
			return;
		end
	end
	local offset = -5; -- this is the default offset for 5 flags
	for i=1,6 do
		if str[i] == "target" then -- if target is seen make sure the next ones are always higher
			offset = maxi;
		else
			ord[ str[i] ] = offset + i;
		end
	end
	UpdateSortOrder(ord["buff"],ord["selfdebuff"],ord["debuff"],ord["cooldown"],ord["notarget"]);
end

--local combat_log_active = false; -- patch 3.1.3 has some combat log issues

--local pauzed;
--local pauzedq = {};

-- http://www.wowwiki.com/Diminishing_returns
-- i'll use the combat log to track this completely seperately
-- and simply look inside this new tracking table to see if my spell
-- will be affected
-- (preferably warn when immune even before you cast)
-- I will add an extra type bar to show returns as well, so you know
-- when your spell will have the full duration again


-- http://www.wowwiki.com/Debuff#List_of_shared_.28non-stacking.29_debuffs

--FW.STACK_CRIT = 1;
--[[
Critical strike chance increase (general)

    * Paladin Heart of the Crusader: Tier 2 Retribution talent, 2 ranks, causes judgements to increase critical strike chance against the target by 3% at max rank.
    * Shaman Totem of Wrath: Tier 9 Elemental talent ability, 3% to attacks and offensive spells, each shaman can only have one active Fire Totem at a time. 
]]
--FW.STACK_CRIT_MAGIC = 2;
--[[
Critical strike chance increase (spell)

    * Mage Enduring Winter: Tier 6 frost talent, 3 ranks, gives frost talent spells a 100% chance to apply the Winter's Chill debuff @ max rank, increasing spell critical strike chance by 1% per stack, stacks up to 5 times.
    * Mage Improved Scorch: Tier 4 fire talent, 3 ranks, gives Scorch a 100% chance to apply the Improved Scorch debuff (or applications of the Improved Scorch debuff if glyphed) @ max rank, increasing spell critical strike chance by 1% per stack, stacks up to 5 times.
    * Warlock Improved Shadow Bolt: Tier 1 Destruction talent, 5 ranks, causes Shadow Bolt to increase spell critical strike damage against the target by 5% @ max rank. 
]]
--FW.STACK_DAMAGE_BLEED = 3;
--[[
Damage increase (bleed)

    * Druid Mangle (Bear) / Mangle (Cat): Tier 9 Feral Combat talent abilities, +30%.
    * Warrior Trauma: Tier 6 Arms talent, +30%, triggered by melee critical strikes. 
]]
--FW.STACK_DAMAGE_MAGIC = 4;
--[[
Damage increase (magic)

    * Death knight Ebon Plaguebringer: Tier 9 Unholy talent, 3 ranks, requires 3 ranks of Crypt Fever. The death knight's diseases cause Ebon Plague instead of Crypt Fever, in addition to Crypt Fever's disease damage increase, Ebon Plague increases magic damage by 13% @ max rank.
    * Druid Earth and Moon: Tier 10 Balance talent, 3 ranks. Causes the druid's Starfire and Wrath spells to apply the Earth and Moon debuff, which increases magic damage taken by 13% @ max rank.
    * Warlock Curse of the Elements: +13% @ max rank, also reduces Arcane, Fire, Frost, Nature and Shadow resistance. 
]]
--FW.STACK_DAMAGE_PHYSICAL = 5;
--[[
Damage increase (physical)

    * Rogue Savage Combat: Tier 9 Combat talent, 2 ranks, causes the rogue's poison debuffs to increase physical damage caused to the target by 4%.
    * Warrior Blood Freny: Tier 9 Arms talent, 2 ranks, causes Deep Wounds and Rend to increase phyical damage caused to the target by 4%. 
]]
--FW.STACK_HEALING_DECREASE = 6;
--[[
Healing decrease

    * Hunter Aimed Shot: Tier 3 Marksmanship talent ability, -50%.
    * Rogue Wound Poison: -50%, each weapon can only have one poison applied to it at a time.
    * Warrior Furious Attacks: Tier 8 Fury talent, 2 ranks, gives whit melee attacks a chance to reduce healing by 25%, stacks 2 times, higher proc rate @ rank 2.
    * Warrior Mortal Strike: Tier 7 Arms talent ability, -50%. 
]]
--FW.STACK_HIT_DECREASE = 7;
--[[
Hit chance decrease (melee and ranged)

    * Druid Insect Swarm: Tier 5 Balance talent ability, -3%.
    * Hunter Scorpid Sting: -3%, each hunter can only have one sting active on each target. 
]]
--FW.STACK_HIT_INCREASE = 8;
--[[
Hit chance increase (spell)

    * Druid Improved Faerie Fire: Tier 7 Balance talent, 3 ranks, causes Faerie Fire to increase spell hit chance against the target by 3% @ max rank.
    * Priest Misery: Tier 8 Shadow talent, 3 ranks, causes Mind Flay, Shadow Word: Pain and Vampiric Touch spells to increase spell hit chance against the target by 3% @ max rank. 
]]

--[[Armor reduction

    * Minor (stacks with major)
    * Druid Faerie Fire / Faerie Fire (Feral): -5%, also prevents stealth.
    * Hunter Sting: Wasp ability, -5%, also prevents stealth.
    * Rogue Expose Armor: -20%.
    * Warlock Curse of Weakness: -5%, also reduces melee attack power, each warlock can only have one active curse per target.
    * Major (stacks with minor)
          o Hunter Acid Spit: Worm (Exotic Hunter pet) ability, -10%, stacks twice.
          o Rogue Expose Armor: -4% per application, stacks up to 5 times.
          o Warrior Sunder Armor: -4% per application, stacks up to 5 times. 
    * Unknown
          o Warrior Shattering Throw: -20%, known to stack with Sunder Armor, unsustainable. 

Attack interval increase (melee)

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting time and melee and ranged attack intervals by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Druid Infected Wounds: Tier 8 Feral Combat talent, 3 ranks, causes Mangle, Maul and Shred to apply the Infected Wound debuff, which stacks 2 times, and increases melee attack interval by 10% per application @ max rank, also reduces movement speed.
    * Mage Slow (mage): Tier 7 Arcane talent ability, increases melee and ranged attack intervals by 60%, also increases casting time, each mage can only have one Slow spell active at a time.
    * Paladin Judgements of the Just: Tier 9 Protection talent, 2 ranks, causes Judgements to increase melee attack intervals 20% @ max rank.
    * Warrior Thunder Clap: Reduces melee and ranged attack intervals by 10%. 

Attack interval increase (ranged)

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting time and melee and ranged attack intervals by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Mage Slow (mage): Tier 7 Arcane talent ability, increases melee and ranged attack intervals by 60%, also increases casting time.
    * Warrior Thunder Clap: Increases melee and ranged attack intervals by 10%. 

Attack power reduction (melee)

    * Druid Demoralizing Roar: -408 @ max rank (~571.2 fully talented with Feral Aggression, a tier 1 Feral Combat talent with 5 ranks), Bear Form and Dire Bear form only.
    * Hunter Demoralizing Screech: Carrion Bird ability, -210 @ max rank.
    * Warlock Curse of Weakness: -478 @ max rank (573 fully talented w/ Improved Curse of Weakness, a tier 2 Affliction talent with 2 ranks), also reduces armor.
    * Warrior Demoralizing Shout: -410 @ max rank (-574 fully talented with Improved Demoralizing Shout, a tier 2 Fury talent with 5 ranks). 

Casting time increase

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting, melee and ranged speed by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Mage Slow (mage): Tier 7 Arcane talent ability, +30%, also increases attack intervals, each mage can only have one Slow spell active at a time.
    * Rogue Mind-Numbing Poison: +30%, each weapon can only have one poison applied to it at a time.
    * Warlock Curse of Tongues: +30% @ max rank, each warlock can only have one active curse per target. 
]]

--[[local ST_Diminish = {
	-- name	PVP PVE category
	--Druid
	["Bash"] =  			{1,0,"Stun"},
	["Entangling Roots"] =  {1,0,"Root"},
	["Hibernate"] =  		{1,0,"Sleep"},
	["Cyclone"] =  			{1,1,"Blind/Cyclone"},
	["Celestial Focus"] =  	{1,1,"Stun Proc "},
	--Hunter  
	--Freezing Trap  No  No  None  
	--Entrapment  Yes  TBD  None  
	--Wyvern Sting  TBD  TBD  Sleep
	--Mage
	["Frost Nova"] = 		{1,0,"Root"},
	["Polymorph"] = 		{1,0,"Gouge/Polymorph/Sap"},
	["Impact"] = 			{1,1,"Stun"},
	["Frostbite"] = 		{1,0,"Root Proc"},
	--Shaman  
	--Frost Shock  No (in 2.3)  No  None 
	["Stoneclaw Totem"] = 	{1,1,"Stun Proc"},
	--Earth Shock  No  No  None  
	--Paladin
	["Hammer of Justice"] = {1,1,"Stun"},
	["Seal of Justice"] = 	{1,1,"Stun Proc"},
	--Priest
	["Psychic Scream"] = 	{1,0,"Fear"},
	["Mind Control"] = 		{1,0,"Charm"},
	["Blackout"] = 			{1,1,"Stun Proc"},
	--Rogue
	["Sap"] = 				{1,0,"Gouge/Polymorph/Sap"},
	["Gouge"] = 			{1,0,"Gouge/Polymorph/Sap"},
	["Blind"] = 			{1,1,"Blind/Cyclone"},
	["Cheap Shot"] = 		{1,1,"Stun"},
	["Kidney Shot"] = 		{1,1,"Kidney Shot"},
	["Mace Specialization"] = {1,1,"Stun Proc"},
	--Warlock 
	["Fear"] = 				{1,0,"Fear"},
	["Seduction"] = 		{1,0,"Fear"},
	["Howl of Terror"] = 	{1,0,"Fear"},
	["Death Coil"] = 		{1,0,"Horror"},
	["Shadowfury"] = 		{1,0,"Stun"},
	--Warrior
	["Mace Specialization (Stun)"] = {1,1,"Stun Proc"},
	["Charge"] = 			{1,1,"Stun"},
	["Intercept"] = 		{1,1,"Stun"},
	["Concussion"] = 		{1,1,"Stun"},
	--Hamstring  No  No  None  
};]]

local FW_RaidIconCoords  = {
	{0.00,0.25,0.00,0.25},
	{0.25,0.50,0.00,0.25},
	{0.50,0.75,0.00,0.25},
	{0.75,1.00,0.00,0.25},
	{0.00,0.25,0.25,0.50},
	{0.25,0.50,0.25,0.50},
	{0.50,0.75,0.25,0.50},
	{0.75,1.00,0.25,0.50}
};

--[[
st

1:Expiring at time
2:Cast Time
3:Duration of Spell
4:Target
5:show ticks (log ticks)
6:MAIN SPELL TYPE
7:Texture
8:Name
9:Target Type (0:trash 1:boss 2:player)
10:ready to check for removal
11:GUID
12:Expire msg at time (0 for none or already triggered)
13:Unique ID (still using this to sort by, see flags)
14:Timer state 0:normal 1:expired instant 2:expired 3:removed 4+:failed
15:USED AS SPECIAL FLAG (HUNTER: TRAP NEEDS TRIGGERING)
16:Stacks or similar
17:Remove time
18:Show tick time
19:Raid target icon
20:Expire Time I'm using (#1 is always the real time)
21:OPTION GROUP (AND SHARED GROUP) Magic/Curse/Crowd Control etc 
22:Haste duration factor (so lower than or equal to 1 usually)
23:isfriendly
24:isshared
25:isunique
26:keep_after_combat
27:Unit token
28:Aura ID

GameTooltip:SetUnitAura("unitId", auraIndex[, filter]) - Shows the tooltip for a unit's aura. (Exclusive to 3.x.x / WotLK)
"HELPFUL", "HARMFUL", "PLAYER", "RAID", "CANCELABLE", "NOT_CANCELABLE"

links
1:index at st
 -- copied from st TO SORT BY only:
2: st13 Unique ID
3: st20 Expire Time I'm using
 -- instance specific values
4: Visibility in this instance
5: Filter
6: Currently used maximum time
7: Time at which 'hide long' was enabled
]]
local function byte_me(n) -- pun intended! ;)
	return pow(2, n);
end

local function fbit(val,flag)
	return (band(val,flag) ~= 0) and 1 or 0;
end

local SORT_TIMER_ORDER=		{3};
local SORT_TIMER_ASC=		{true};	
local SORT_TIMER_ORDER2=	{2,3};
local SORT_TIMER_ASC2=		{true,true};

local F = {
	NOTARGET = byte_me(0), -- NOTARGET VS TARGET
	BUFF = byte_me(1), -- BUFF VS DEBUFF
	SHARED = byte_me(2), -- ONLY ONE OF THIS GROUP ALLOWED ON A SINGLE TARGET
	UNIQUE = byte_me(3), -- ONLY ONE OF THIS NAME IS ALLOWED AT ANY TIME
	TICKS = byte_me(4), -- TRACK TICKS
	REFRESH = byte_me(5), -- SPECIAL REFRESH
	KEEP = byte_me(6) -- KEEP AFTER COMBAT (WHEN REMOVE MOB TIMERS IS SET)
};
-- some shorthands
F.HOT = F.BUFF + F.TICKS;
F.CHARM = F.UNIQUE + F.KEEP;
F.SUMMON = F.NOTARGET + F.KEEP;
F.AOE = F.NOTARGET; -- AOE will get more useful properties in the future
F.AOE_HOT = F.NOTARGET + F.TICKS + F.KEEP + F.BUFF;
F.AOE_DMG = F.NOTARGET + F.TICKS + F.KEEP;

ST.F = F;

-- MAIN SPELL TYPE spell timer flags
local DEFAULT = 1;
local POWERUP = 2;
local SELF_DEBUFF = 3;
local COOLDOWN = 4;
local DEBUFF = 5;
local DRAIN = 6;
local ENCHANT = 7;

ST.DEFAULT = DEFAULT;
ST.POWERUP = POWERUP;
ST.SELF_DEBUFF = SELF_DEBUFF;
ST.COOLDOWN = COOLDOWN;
ST.DEBUFF = DEBUFF;
ST.DRAIN = DRAIN;
ST.ENCHANT = ENCHANT;


--1:all 2:other debuffs 3:all other
local function FlagToFilterIndex(flag)
	if flag == DEBUFF or flag == POWERUP or flag == ENCHANT then
		return 2;
	elseif flag == COOLDOWN then
		return 4;
	elseif flag == SELF_DEBUFF then
		return 5;
	else -- all other
		return 3;
	end
end

function ST:AddManualSpellOfType(spell,flag)
	ManualSpell[spell] = flag;
end

local function addedByDefault(spell,flag)
	if flag == ENCHANT or ManualSpell[spell] == flag then -- to show special class module flags by default
		return 1;
	elseif flag == DEBUFF then
		return TrackDebuffs[spell];
	elseif flag == POWERUP then
		return TrackBuffs[spell];
	elseif flag == COOLDOWN then
		return TrackCooldowns[spell];
	elseif flag == SELF_DEBUFF then
		return TrackSelfDebuffs[spell];
	elseif flag == DRAIN then
		return Drain[spell];
	else -- all other
		return Track[spell];
	end
end

local function FlagToFilter(frame,spell,flag)
	if frame.s.Filter[spell] then
		if flag == DEBUFF or flag == POWERUP or flag == ENCHANT then
			if frame.s.Filter[spell][2] and frame.s.Filter[spell][2][1]~=0 then
				return frame.s.Filter[spell][2];
			end
		elseif flag == COOLDOWN then
			if frame.s.Filter[spell][4] and frame.s.Filter[spell][4][1]~=0 then
				return frame.s.Filter[spell][4];
			end
		elseif flag == SELF_DEBUFF then
			if frame.s.Filter[spell][5] and frame.s.Filter[spell][5][1]~=0 then
				return frame.s.Filter[spell][5];
			end
		else -- all other
			if frame.s.Filter[spell][3] and frame.s.Filter[spell][3][1]~=0 then
				return frame.s.Filter[spell][3];
			end
		end
		-- all
		if frame.s.Filter[spell][1] and frame.s.Filter[spell][1][1]~=0 then
			return frame.s.Filter[spell][1];
		end
	end
end

local function FlagToAction(frame,spell,flag,group,ignore_default)
	if frame then -- if no frame is specified this is meant to check if any non-default spells are added for show
		local filter = FlagToFilter(frame,spell,flag);
		if filter and filter[1] ~= FILTER_NONE then
			if filter[1] == FILTER_COLOR then
				if addedByDefault(spell,flag) and frame.s[group][0] then
					return FILTER_COLOR;
				else
					return FILTER_HIDE;
				end
			else
				return filter[1];
			end
		else
			if addedByDefault(spell,flag) and frame.s[group][0] then
				return FILTER_NONE;
			else
				return FILTER_HIDE;
			end
		end
	else
		-- if no frame is given, check for custom filters in all instances
		-- this gives the addon a list of only the spells that are possible to show up
		-- don't check if enabled for default spells because of sound queues etc!!
		for i=1,instances.rows do 
			local filter = FlagToFilter(instances[i][2],spell,flag);
			if ( not ignore_default and addedByDefault(spell,flag) ) or (filter and ( filter[1] == FILTER_SHOW or filter[1] == FILTER_SHOW_COLOR )) then
				return FILTER_SHOW;
			end
		end
		return FILTER_NONE;
	end
end

local current_spell;

function ST:AddSpellRemap(spell,newname)
	SpellRemap[(FW:SpellName(spell))] = (FW:SpellName(newname));
	return self;
end

function ST:AddExtraSpell(extraspell)
	if not SpellAdd[current_spell] then SpellAdd[current_spell] = {};end
	tinsert(SpellAdd[current_spell], (FW:SpellName(extraspell)) );
	return self;
end
local default_hasted = 1;
-- best would if it can 'replace' the shared/curse behaviour with something more flexible
function ST:SetDefaultHasted(hasted)
	default_hasted = hasted;
	return self;
end

function ST:AddSpell(spell, duration, group, flags)
	local s,t = FW:SpellName(spell);
	current_spell = s;
	flags = flags or 0;
	local ticks = fbit(flags,F.TICKS);
	if ticks == 1 then
		Tick[s] = 3;
		Hasted[s] = default_hasted;
	end
	Track[s]={fbit(flags,F.NOTARGET),duration,ticks,DEFAULT, t or "", group or "Default",fbit(flags,F.BUFF),fbit(flags,F.SHARED),fbit(flags,F.UNIQUE),fbit(flags,F.REFRESH),fbit(flags,F.KEEP)};
	return self;
end

function ST:SetHasted(hasted,spell)
	Hasted[spell or current_spell] = hasted;
	return self;
end

function ST:SetStacks(stacks,spell)
	Stacks[spell or current_spell] = stacks;
	return self;
end

function ST:AddChannel(spell,hastarget, tickspeed)
	local s = FW:SpellName(spell);
	current_spell = s;
	Drain[s] = {hastarget,tickspeed,"Channel"};
	return self;
end

function ST:SetTickSpeed(tick,spell)
	Tick[spell or current_spell] = tick;
	return self;
end

function ST:SetHastedGlyph(requires_glyph)
	requires_glyph = FW:SpellName(requires_glyph);
	if not FW.Glyph[requires_glyph] then FW.Glyph[requires_glyph] = 0; end
	if not Track[current_spell]["hg"] then Track[current_spell]["hg"] = {};end
	Track[current_spell]["hg"][requires_glyph] = 1;
	return self;
end

function ST:SetHastedStance(requires_stace)
	if not Track[current_spell]["hs"] then Track[current_spell]["hs"] = {};end
	if not Track[current_spell]["hs"][requires_stace] then Track[current_spell]["hs"][requires_stace] = 1;end
	return self;
end

function ST:SetDurationPVP(reduced_in_pvp)
	DurationPVP[current_spell] = reduced_in_pvp;
	return self;
end

function ST:SetSpellModSetB(setb,rank,modi)
	if not FW.SetBonus[setb] then FW.SetBonus[setb] = 0; end
	if not Track[current_spell]["s"] then Track[current_spell]["s"] = {};end
	if not Track[current_spell]["s"][setb] then Track[current_spell]["s"][setb] = {};end
	Track[current_spell]["s"][setb][rank] = modi;
	return self;
end

function ST:SetSpellModTlnt(tal,modis)  -- modis table
	tal = FW:SpellName(tal);
	if not FW.Talent[tal] then FW.Talent[tal] = 0; end
	if not Track[current_spell]["t"] then Track[current_spell]["t"] = {};end
	Track[current_spell]["t"][tal] = modis;
	return self;
end

function ST:SetSpellModGlph(gl,modi)
	gl = FW:SpellName(gl);
	if not FW.Glyph[gl] then FW.Glyph[gl] = 0; end
	if not Track[current_spell]["g"] then Track[current_spell]["g"] = {};end
	Track[current_spell]["g"][gl] = modi;
	return self;
end

function ST:SetSpellModComb(points,modis) -- modis table
	if not Track[current_spell]["c"] then Track[current_spell]["c"] = {};end
	Track[current_spell]["c"]=modis;
	return self;
end

function ST:AddBuff(buff,group)
	buff = FW:SpellName(buff);
	current_spell = buff;
	TrackBuffs[buff] = group or "SelfBuff";
	return self;
end

function ST:AddSelfDebuff(debuff,group)
	debuff = FW:SpellName(debuff);
	current_spell = debuff;
	TrackSelfDebuffs[debuff] = group or "SelfDebuff";
	return self;
end

function ST:AddCooldown(spell,duration,group)
	local s,t = FW:SpellName(spell);
	current_spell = s;
	TrackCooldowns[s] = {duration,t,group or "Cooldown"};
	return self;
end

function ST:SetCooldownModSetB(setb,rank,modi)
	if not FW.SetBonus[setb] then FW.SetBonus[setb] = 0; end
	if not TrackCooldowns[current_spell]["s"] then TrackCooldowns[current_spell]["s"] = {};end
	if not TrackCooldowns[current_spell]["s"][setb] then TrackCooldowns[current_spell]["s"][setb] = {};end
	TrackCooldowns[current_spell]["s"][setb][rank] = modi;
	return self;
end

function ST:SetCooldownModTlnt(tal,data)  -- data table
	tal = FW:SpellName(tal);
	if not FW.Talent[tal] then FW.Talent[tal] = 0; end
	if not TrackCooldowns[current_spell]["t"] then TrackCooldowns[current_spell]["t"] = {};end
	TrackCooldowns[current_spell]["t"][tal] = data;
	return self;
end

function ST:SetCooldownModGlph(gl,modi)
	gl = FW:SpellName(gl);
	if not FW.Glyph[gl] then FW.Glyph[gl] = 0; end
	if not TrackCooldowns[current_spell]["g"] then TrackCooldowns[current_spell]["g"] = {};end
	TrackCooldowns[current_spell]["g"][gl] = modi;
	return self;
end

local function ST_CooldownDuration(s)
	local dura = 0;
	-- duration adjustments
	if TrackCooldowns[s] then
		dura = TrackCooldowns[s][1];
		-- change based on talents
		if TrackCooldowns[s]["t"] then
			for k, v in pairs(TrackCooldowns[s]["t"]) do
				if v[FW.Talent[k]] then
					dura = dura + v[FW.Talent[k]];
				end
			end
		end
		-- change based on setbonus
		if TrackCooldowns[s]["s"] then
			for k, v in pairs(TrackCooldowns[s]["s"]) do
				for n, a in pairs(v) do
					if FW.SetBonus[k] >= n then
						dura = dura + a;
					end
				end
			end
		end
		-- change based on glyphs
		if TrackCooldowns[s]["g"] then
			for k, v in pairs(TrackCooldowns[s]["g"]) do
				if FW.Glyph[k] and FW.Glyph[k] > 0 then
					dura = dura + v;
				end
			end
		end
	
		-- % change based on talents removed
	end
	return dura;
end


local function ST_AddNewCooldown(spell,dura,prior,texture)
	-- I use 'target type' to store the prior, triggered by cd module is higher prior
	local index = st:find2(COOLDOWN,6,spell,8);
	--if prior == 2 then FW:Show("cd");else FW:Show("st");end
	if not index or prior >= st[index][9] then
		st:remove(index);
		st:insert(dura+GetTime(),FW:CastTime(spell),dura,spell,0,COOLDOWN,texture,spell,prior,0,"none",0,PRIOR_COOLDOWN,0,1,0,0,00000,0,dura+GetTime(),"Cooldown",1.0,0,0,0,0,"",0);		
	end
end

local function ST_OnCooldownUsed(spell,dura,flag,texture)
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then
		if FlagToAction(nil,spell,COOLDOWN,"Cooldown") == FILTER_SHOW then
			ST_AddNewCooldown(spell,dura,2,texture);
		end
	end
end

local function ST_OnCooldownUpdate(spell,dura,flag,texture,end_time)
	--FW:Show("update");
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then
		local index = st:find2(COOLDOWN,6,spell,8);
		if index then
			st[index][1] = end_time;
			st[index][7] = texture;
		else
			--ST_OnCooldownUsed(spell,dura,flag,texture); -- is a bit ineffient here, make sure to update code below!
			if FlagToAction(nil,spell,COOLDOWN,"Cooldown") == FILTER_SHOW then
				st:insert(dura+GetTime(),FW:CastTime(spell),dura,spell,0,COOLDOWN,texture,spell,2,0,"none",0,PRIOR_COOLDOWN,0,1,0,0,00000,0,dura+GetTime(),"Cooldown",1.0,0,0,0,0,"",0);		
			end
		end
	end
end
local function ST_OnCooldownReady(spell,flag)
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then
		local index = st:find2(COOLDOWN,6,spell,8);
		if index then
			st[index][1] = GetTime();
			st[index][20] = st[index][1];
		end
	end
end

local function ST_SelfSuccess(spell)
	if TrackCooldowns[spell] then
		ST_AddNewCooldown(spell,ST_CooldownDuration(spell),1,TrackCooldowns[spell][2]);
	end
end

-- rebuild the RegisterDebuff function to take a 'doesn't stack' ID and priority number (will multiply this with the number of stacks to determine what to show)
-- AddSpell spells should never get overwritten by this feature

function ST:AddDebuff(debuff,group)
	debuff = FW:SpellName(debuff);
	current_spell = debuff;
	TrackDebuffs[debuff] = group or "TargetDebuff";
	return self;
end

local function ST_FindSimilarSimple(spell,guid,friendly)
	for i=1,st.rows,1 do -- return only if this isnt a resist
		if st[i][14] <= REMOVE then
			if st[i][8] == spell and st[i][11] == guid and st[i][23] == friendly then
				return i;
			end
		end
	end
end

local function ST_AddDot(unit,spell)
	if FW.Settings.TimerImprove and Track[spell] and Track[spell][1] == 0 and Track[spell][3] == 1 then
		local index = ActiveDots:find2(unit,1,spell,2);
		if index then
			ActiveDots[index][3] = GetTime()+(Tick[spell] or 3)+FW.Settings.DotTicksDelayNew;
		else
			ActiveDots:insert( unit,spell,GetTime()+(Tick[spell] or 3)+FW.Settings.DotTicksDelayNew);
		end
	end
end

local function ST_OnTick(unit,guid,spell,iscast)
	if Tick[spell] then
		--FW:Show("TICK "..unit.." "..guid.." "..spell.." "..tostring(iscast));
		ST_AddDot(unit,spell);
		if guid ~= "none" and guid ~= "" then
			ST_AddDot(guid,spell);
		end
		if not iscast then
			local index = (Track[spell] and Track[spell][1] == 1 or Drain[spell] and Drain[spell][1] == 0) and st:find(spell,8) or st:find2(spell,8,guid,11);
			if index then
				st[index][18] = GetTime();
			end
		end
	end
end

function ST:AddNewTimerSimple(expire,total,targetname,spell,targettype,id,icon,guid,haste,texture,stacks)--only use for non-(de)buff based adding
	local found = ST_FindSimilarSimple(spell,guid,0);
	
	if found then -- found a spell i may need to remove - if it's an exact match keep using it
		if st[found][8] == spell and st[found][11] == guid and abs(st[found][1]-expire)<maxlag then 
			st[found][1] = expire;
			if abs(st[found][20]-expire)>maxlag then
				st[found][3] = total;
				st[found][20] = expire;
				--st[found][21] = total;
			end
			return;
		else
			st:remove(found);
		end
	end
	st:insert(expire,FW:CastTime(spell),total,targetname,0,DEFAULT,texture,spell,targettype,0,guid,ST_GetFadeTime(spell),id,0,1,stacks,0,00000,icon,expire,"Default",haste,0,0,0,0,"",0);
end

function ST:AddNewTimer(expire,total,targetname,spell,targettype,id,icon,guid,haste,realduration) --only use for non-(de)buff based adding
	if total > 0 --[[or expire==0]] then -- dont add if duration isnt greater than 0
		local group,friendly,shared,unique,keep = Track[spell][6],Track[spell][7],Track[spell][8],Track[spell][9],Track[spell][11];
		local stacks = Stacks[spell] and Stacks[spell] > 0 and 1 or 0;
		local i=1;
		local exact = false;
		local extratime = 0;
		while i<=st.rows do 
			if st[i][14] <= REMOVE then -- only if this isnt a resist
				
				-- REMOVE OTHER ACTIVE UNIQUE OR SHARED SPELLS
				if st[i][8] == spell and st[i][11] == guid then -- spell match on same unit
					if abs(st[i][1]-expire)<maxlag then -- exact match, just correct time
						st[i][1] = expire;
						if abs(st[i][20]-expire)>maxlag then
							st[i][3] = total;
							st[i][20] = expire;
						end
						exact = true;
						i=i+1;
					else
						if Stacks[spell] and Stacks[spell] > 0 then
							stacks = st[i][16] + 1;
							if stacks > Stacks[spell] then
								 stacks = Stacks[spell];
							end
						end
						--FW:Debug("using new time");
						extratime = 0;
						if Tick[spell] then -- must have ticks
							local remaining = st[i][1]-GetTime();
							if remaining > 0 then
								extratime = remaining%(st[i][22]*Tick[spell]);
							end
							--FW:Show(extratime);
						end
						st:remove(i);
					end
				elseif st[i][21] == group and (shared == 1  and st[i][11] == guid or unique == 1 and st[i][8] == spell) then
					st:remove(i);
				else
					i=i+1;
				end
				
			else
				i=i+1;
			end
		end
		if not exact then
			st:insert(expire+extratime,FW:CastTime(spell),total,targetname,Track[spell][3],DEFAULT,Track[spell][5],spell,targettype,0,guid,ST_GetFadeTime(spell),id,0,1,stacks,0,00000,icon,expire,group,haste,friendly,shared,unique,keep,"",0);
		end
		ST_OnTick(targetname,guid,spell,true);
	end	
end

local function ST_Exception(set)
	if UnitName("target") then
		FW.Saved.Exceptions[UnitName("target")] = set;
	end
end

local function ST_HideTicks()
	for i=1,instances.rows,1 do
		instances[i][2]:HideTicks();
	end
end

local function ST_TimerShow(instance)
	if instance then
		instance:Update();
	else
		for i=1,instances.rows,1 do
			instances[i][2]:Update();
		end
	end
end
local function ST_SpellFail(s,resist,target,typ,id,icon,guid,...)
	if FW.Settings.TimerResistsColor[0] then 
		FW:Show(_G.CombatLog_OnEvent(_G.Blizzard_CombatLog_Filters.filters[_G.Blizzard_CombatLog_Filters.currentFilter], ...),unpack(FW.Settings.TimerResistsColor));
	end
	FW:PlaySound("TimerResistSound");
	for i=1,st.rows,1 do -- remove any other resist of this spell that's still on the bar
		if st[i][8] == s and st[i][14] >= FAILED and st[i][11] == guid then
			st:remove(i);
			break;
		end
	end
	st:insert(GetTime(),0,1,target,Track[s][3],DEFAULT,Track[s][5],s,typ,0,guid,0,id,resist,1,0,GetTime(),00000,icon,GetTime(),Track[s][6],1.0,Track[s][7],Track[s][8],Track[s][9],Track[s][11]);	
end

local function ST_TrackedSuccess(spell,target,realduration,rank,targettype,s,p,id,icon,guid,delay,haste_old)
	if Track[s][1] == 1 then -- spells without a target
		target = s;
		targettype = 0;
		id = PRIOR_NONE;
		icon = 0;
		guid = "none";
	end
	 -- add an extra debuff! this is still very basic in functionality but it's something
	if SpellAdd[spell] then
		for i,a in ipairs(SpellAdd[spell]) do
			local ha = CA:HasteFactor(a);
			local dura = CA:Duration(a,p,targettype)*ha;
			--
			ST:AddNewTimer(GetTime()+dura-delay,dura,target,a,targettype,id,icon,guid,ha,dura);
		end
	end
	local haste = CA:HasteFactor(spell);
	local newdura;
	--FW:Show(realduration);
	--
	if Tick[spell] then
		newdura = math.floor(realduration/(Tick[spell]*haste))*Tick[spell]*haste;
	else
		newdura = realduration*haste;
	end
	--FW:Show(newdura);
	ST:AddNewTimer(GetTime()+newdura-delay,newdura,target,s,targettype,id,icon,guid,haste,realduration);
end

function ST:Fade(i,t)
	if i then
		if st[i][14] == IGNORE then -- if ignored already, remove instantly
			st[i][1] = 0;
		elseif st[i][14] ~= t then
			st[i][17] = GetTime();
			st[i][14] = t;
		end
	end
end

local function ST_BreakMessages(unit,mark,spell)
	for i, f in ipairs(ST_OnTimerBreak) do
		if f(unit,mark,spell) then
			FW:PlaySound("TimerBreakSound");
		end
	end
end

local maxdelay, maxdelay_instant = 0, 0;
local function ST_CalculateMaxDelay() -- calc new max delays
	maxdelay_instant = FW.Settings.TimerFadeSpeed;
	maxdelay = 0;
	for i=1,instances.rows,1 do
		maxdelay = max(maxdelay,instances[i][2].s.FailTime);
		maxdelay = max(maxdelay,instances[i][2].s.FadeTime);
	end
	maxdelay = maxdelay + maxdelay_instant;
end

local function ST_UpdateSpellTimers()--preferably only remove timers in this function and not outside
	local t = GetTime();
	local smooth = FW.Settings.TimerSmooth;
	local i = 1;
	
	while i <= st.rows do
		local t6,t14 = st[i][6],st[i][14];
		local timeleft = st[i][1]-t;
		st[i][20] = st[i][20] + (st[i][1]-st[i][20])/smooth;
		--FW:Show(timeleft);
		-- fade messages if time <= X sec
		if st[i][12] > 0 and timeleft <= st[i][12] and t14<=NORMAL then -- marked as not expiring
			st[i][12] = 0;
			
			local unit,mark = st[i][4],st[i][19];
			if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
			CA:CastShow(ST_OnTimerFade[ st[i][8] ],unit);
			FW:PlaySound("TimerFadeSound");
		end	

		if t14 == IGNORE then -- instantly remove ignored timers on expire
			if timeleft <= 0 then
				st:remove(i);
			else
				i=i+1;
			end
		elseif t14 == NORMAL then -- set to fade
			if timeleft <= 0 and st[i][3] > 0 then
				-- normal fade and instant fade
				ST:Fade(i, (t6 == DRAIN or t6 == DEBUFF or t6 == POWERUP or t6 == SELF_DEBUFF) and FADING_INSTANT or FADING);
			end		
			i=i+1;
		else -- keep expired timers alive for X sec max
			if st[i][17] + ((t6 == DRAIN or t6 == DEBUFF or t6 == POWERUP or t6 == SELF_DEBUFF) and maxdelay_instant or maxdelay) < t then
				st:remove(i);
			else
				i=i+1;
			end
		end
	end
end

local function ST_ClearMobTimers()
	--FW:Debug("clear timer");
	local i = 1;
	while i <= st.rows do
		if st[i][6] == DEFAULT and st[i][26] == 0 and st[i][9] < 2 then -- remove all non-player timers except charms
			st:remove(i);
		else
			i=i+1;
		end
	end
end

-- OLD:
-- do NOT make this add my own dots that may be missing, this would correct the tiny chance
-- of the timer missing a cast, but would also make the manual remove function unusable...
local isMine = {["player"]=true,["pet"]=true,["vehicle"]=true};
local function ST_ScanForMissing(unit,guid,filter)
	-- add any spells that i'm tracking that are mine
	local i=1;
	while true do
		local spell,rank,texture,stacks,_,total,expire,caster = UnitAura(unit,i,filter);
		if spell then
			if isMine[caster] and (Track[spell] and Track[spell][7] or 0) == (filter == "HELPFUL" and 1 or 0) then
				if Track[spell] and Track[spell][1] == 0 then
					local index = st:find2(spell,8,guid,11)
					if not index or st[index][14] >= FADING_INSTANT then -- don't add when i already have this added
						--FW:Debug("moo??");
						--FW:Show(rank);
						local h = CA:HasteFactor(spell);
						local d = CA:Duration(spell,GetComboPoints("player",unit),unit)*h;
						--FW:Debug("guess: "..d.." real:"..total);
						ST:AddNewTimer(expire,total,UnitName(unit),spell,CA:Unique(unit),CA:GiveID(guid),GetRaidTargetIndex(unit) or 0,guid,h,0);
					end
				elseif FlagToAction(nil,spell,DEFAULT,"Default",1) == FILTER_SHOW then
					ST:AddNewTimerSimple(expire,total,UnitName(unit),spell,CA:Unique(unit),CA:GiveID(guid),GetRaidTargetIndex(unit) or 0,guid,CA:HasteFactor(spell),texture,stacks);
				end
			end
			i=i+1;
		else
			break;
		end
	end
end

local function UnitHasYourAura(unit,buff,filter)
	--name 1, rank 2, icon 3, count 4, debuffType 5, duration 6, expirationTime 7, unitCaster 8, isStealable, shouldConsolidate 9, spellId 10		
	local b = 1;
	local _,d,t,m,s,tt;--buff name, texture
	while true do
		d,_,_,s,_,tt,t,m = UnitAura(unit,b,filter);
		if d then
			if d == buff and isMine[m] then
				return t,b,s,tt;
			end
			b=b+1;
		else
			return nil,b,0,0;
		end
	end
end

--main tracking for spells cast by you (type6: 9+ = friendly buff)
local function ST_CorrectionScan(unit)
	--FW:Show("standard scan "..unit);
	local guid = UnitGUID(unit);
	if guid then -- this unit exists, which is always nice
		local t = GetTime();
		-- remove or correct timers already on the spelltimer
		local i=1;
		while i<=st.rows do -- spelltimer part
			local spell_type = st[i][6];
			if spell_type == DEFAULT or spell_type == DRAIN then
				local spell_name,friendly = st[i][8],st[i][23];
				if st[i][14]<=NORMAL then
					if st[i][11] == "" then -- uncertain cast, attempt to correct
						local expire = UnitHasYourAura(unit,spell_name,friendly == 1 and "HELPFUL" or "HARMFUL");
						-- does this unit maybe have this debuff on my timer?
						if expire then
							if st[i][6] == DRAIN then -- drains are special cases, and never added by debuff/buff scans
								if abs( expire-st[i][1] )<maxlag then
									st[i][9] = CA:Unique(unit);
									st[i][11] = guid;
									st[i][13] = CA:GiveID(guid);
									st[i][19] = GetRaidTargetIndex(unit) or 0;
									rebuildLinks(); -- IMPORTANT
								end
							else
								if abs( expire-st[i][1] )<maxlag or Tick[spell_name] and ((expire > st[i][1] - maxlag) and (expire - Tick[spell_name]*st[i][22] - maxlag < st[i][1])) then --if it's found for correction, it will be added anyway, so can remove this now
									st:remove(i);
									i=i-1;
								end
							end
							FW:Debug("correct uncertain");
						end	
						
					elseif st[i][11] == guid then
					
						local t6 = st[i][6];
						if spell_type == DEFAULT then -- only check the 'normal' buff/debuff types
							local expire,index,stacks,total,rank = UnitHasYourAura(unit,spell_name,friendly == 1 and "HELPFUL" or "HARMFUL");
							
							if st[i][10] == 0 then -- makes early (de)buff removing faster and hopefully bug free
								if expire then -- no need to match for duration here because i already have a fixed id
									st[i][10] = 1;-- i have already seen this debuff
									if expire > st[i][1] or abs(st[i][1]-expire)<maxlag then st[i][1] = expire;st[i][16] = stacks or 0; end
									--st[i][1] = expire;
								elseif (st[i][3]-st[i][1]+t) >= BuffDelay then
									st[i][10] = 1;-- it should have been on already at this time
								end						
							end

							-- do the other 'normal' stuff
							if expire then
								if Track[spell_name] and Track[spell_name][10] == 1 then
									local haste = CA:HasteFactor(spell_name);
									if st[i][22] ~= haste and expire-st[i][1] > maxlag then
										st[i][22] = haste;
									end
								end
								st[i][1] = expire;
								st[i][16] = (Stacks[spell_name] ~= 0 and stacks) or 0;
								st[i][3] = total;
								
								st[i][19] = GetRaidTargetIndex(unit) or 0;
								st[i][27] = unit;
								st[i][28] = index;
								
							elseif st[i][10] == 1 and (st[i][1]==0 or st[i][1]-t>maxlag) then -- dont remove if only maxlag left
								if not UnitIsDead(unit) then
									ST_BreakMessages(st[i][4],st[i][19],spell_name);
								end
								ST:Fade(i,REMOVE);
								--FW:Debug("remove");
							end
						end
					end	
				end
			end
			i=i+1;
		end
		ST_ScanForMissing(unit,guid,"HARMFUL");
		ST_ScanForMissing(unit,guid,"HELPFUL");
	end
end

local function ST_TargetDebuffs()
	local i = 1;	
	-- remove any faded debuffs that i'm tracking
	while i<= st.rows do
		if st[i][14] <= NORMAL and st[i][6] == DEBUFF then
			if not UnitAura("target",st[i][8],nil,"HARMFUL") then
				ST:Fade(i,FADING_INSTANT);
			end
		end
		i=i+1;
	end
	i = 1;
	local t = GetTime();
	-- scan my target for debuffs that i want to track (and may not be mine)
	while true do
		local debuff,_,texture,count,_,total,expire,caster = UnitAura("target",i,"HARMFUL");
		if debuff then
			if FlagToAction(nil,debuff,DEBUFF,"TargetDebuff") == FILTER_SHOW then
				local guid = UnitGUID("target");
				local index = st:find2(DEBUFF,6, debuff,8); -- find timers marked 'tdebuff' with this name
				if index then
					-- currently i'm not using guid for raid debuffs, so no need to update that
					if st[index][1] ~= expire or st[index][14] > NORMAL --[[or guid ~= st[index][11] ]]then
						st[index][1] = expire;
						--st[index][11] = guid;
						st[index][14] = 0;
						st[index][17] = 0;
						--st[index][12] = ST_GetFadeTime(debuff);
					end
					st[index][3] = total;
					st[index][16] = count or 0;
					st[index][19] = GetRaidTargetIndex("target") or 0;
					st[index][28] = i;
					
					--FW:Debug("tdebuff correct");
				elseif not st:find2(debuff,8,guid,11) then -- don't add when i already have this debuff added, but as my own cast
					--FW:Show("tdebuff insert");
					st:insert(expire,FW:CastTime(debuff),total,debuff,0,DEBUFF,texture,debuff,CA:Unique("target"),0,guid,0,PRIOR_DEBUFF,0,1,count or 0,0,00000,GetRaidTargetIndex("target") or 0,expire,"TargetDebuff",1.0,0,0,0,0,"target",i);
				end
			end
			i=i+1;
		else
			break;
		end
	end
end

local function ST_PlayerBuffs()

	-- remove any faded buffs that i'm tracking
	local i = 1;
	while i<= st.rows do
		if st[i][14] <= NORMAL then 
			if st[i][6] == POWERUP then
				if not UnitAura("player",st[i][8]) then
					ST:Fade(i,FADING_INSTANT);
				end
			elseif st[i][6] == SELF_DEBUFF then
				if not UnitAura("player",st[i][8],nil,"HARMFULL") then
					ST:Fade(i,FADING_INSTANT);
				end
			end
		end
		i=i+1;
	end
	i = 1;
	while true do
		local buff,_,texture,count,_,total,expire = UnitAura("player",i);
		if buff then
			-- I also want people to be able to add powerups that may be missing!
			if FlagToAction(nil,buff,POWERUP,"SelfBuff") == FILTER_SHOW then
				local index = st:find2(POWERUP,6, buff,8);
				if index then
					if st[index][1] ~= expire or st[index][14] > NORMAL then
						st[index][1] = expire;
						st[index][17] = 0;
						st[index][14] = 0;
					end
					st[index][3] = total;
					st[index][16] = (Stacks[buff] ~=0 and count) or 0;
					--st[index][19] = GetRaidTargetIndex("player") or 0;
					st[index][28] = i;
				else
					st:insert(expire,FW:CastTime(buff),total,buff,0,POWERUP,texture,buff,0,0,"none",0,PRIOR_POWERUP,0,1,(Stacks[buff] ~=0 and count) or 0,0,00000,0,expire,"SelfBuff",1.0,1,0,0,0,"player",i);
					for n, f in	ipairs(ST_OnBuffGain) do
						f(buff);
					end
				end
			end
			i=i+1;
		else
			break;
		end
	end
	
	i = 1;
	while true do
		local buff,_,texture,count,_,total,expire = UnitAura("player",i,"HARMFUL");
		if buff then
			-- I also want people to be able to add powerups that may be missing!
			if FlagToAction(nil,buff,SELF_DEBUFF,"SelfDebuff") == FILTER_SHOW then
				local index = st:find2(SELF_DEBUFF,6, buff,8);
				if index then
					if st[index][1] ~= expire or st[index][14] > NORMAL then
						st[index][1] = expire;
						st[index][17] = 0;
						st[index][14] = 0;
					end
					st[index][3] = total;
					st[index][16] = count or 0;
					st[index][19] = GetRaidTargetIndex("player") or 0;
					st[index][28] = i;
				else
					st:insert(expire,0,total,buff,0,SELF_DEBUFF,texture,buff,0,0,"none",0,PRIOR_SELF_DEBUFF,0,1,count or 0,0,00000,0,expire,"SelfDebuff",1.0,0,0,0,0,"player",i);
					--[[for n, f in	ipairs(ST_OnSelfDebuffGain) do
						f(buff);
					end]]
				end
			end
			i=i+1;
		else
			break;
		end
	end
	
	
end
local function checkWeaponEnchant(has,left,count,name,slotname)
	local index = st:find2(ENCHANT,6,name,8);
	if has then
		left = left*0.001;
		local expire = GetTime()+left;
		if index then
			if --[[st[index][1] ~= expire]] abs( st[index][1]-expire ) > 0.1 or st[index][14] > NORMAL then
				st[index][1] = expire;
				st[index][3] = left;
				st[index][17] = 0;
				st[index][14] = 0;
				--FW:Show("update");
			end
			st[index][16] = (Stacks[name] ~=0 and count) or 0;
		else
			st:insert(expire,0,left,name,0,ENCHANT,GetInventoryItemTexture("player",select(1,GetInventorySlotInfo(slotname))),name,0,0,"none",0,PRIOR_POWERUP,0,1,count or 0,0,00000,0,expire,"Enchant",1.0,0,0,0,0,"",0);
		end
	else
		if index and st[index][14] <= NORMAL then 
			ST:Fade(index,FADING_INSTANT);
		end
	end
end

local function ST_ScanWeaponEnchant()
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges, hasThrownEnchant, thrownExpiration, thrownCharges = GetWeaponEnchantInfo();
	checkWeaponEnchant(hasMainHandEnchant,mainHandExpiration,mainHandCharges,FWL.WEAPON_ENCHANT_MAIN,"MainHandSlot");
	checkWeaponEnchant(hasOffHandEnchant,offHandExpiration,offHandCharges,FWL.WEAPON_ENCHANT_OFFHAND,"SecondaryHandSlot");
	checkWeaponEnchant(hasThrownEnchant,thrownExpiration,thrownCharges,FWL.WEAPON_ENCHANT_RANGED,"RangedSlot");
end

local function ST_ScanWeaponEnchantTrottle(event,arg1)
	if arg1=="player" then FW:RegisterThrottle(ST_ScanWeaponEnchant);end
end
	
local function ST_AuraChanged(event,unit) -- triggered by "UNIT_AURA"
	-- do special stuff
	--FW:Show("aura "..unit);
	if unit == "target" then
		FW:DelayedExec(FW.Settings.Delay,1,ST_TargetDebuffs);
		--ST_TargetDebuffs(); -- really have to make this work!!
	elseif unit == "player" or unit == "vehicle" then
		FW:RegisterThrottle(ST_PlayerBuffs);
	end
	-- also do standard stuff
	FW:RegisterThrottle(ST_CorrectionScan,unit);
end

-- target/focus change tracking ONLY, doesnt look at debuffs anymore

local function ST_TargetChanged()
	FW:Changed("target");
	ST_TargetDebuffs();
	ST_CorrectionScan("target");
	
	rebuildLinks(); -- IMPORTANT
	local t = GetTime();
	for i=1,st.rows,1 do -- spelltimer part
		if st[i][11] == FW.target then -- briefly show hidden timers on reselect
			setValueLinks(i,7,t);
	 	end
	end
end

local function ST_FocusChanged()
	FW:Changed("focus");
	ST_CorrectionScan("focus");
	
	rebuildLinks(); -- IMPORTANT
	local t = GetTime();
	for i=1,st.rows,1 do -- spelltimer part
		if st[i][11] == FW.focus then -- briefly show hidden timers on reselect
			setValueLinks(i,7,t);
	 	end
	end
end

local function ST_MouseOverChanged() --with improvement enabled, I want to scan my mouseover target for removed debuffs
	FW:Changed("mouseover");
	ST_CorrectionScan("mouseover");
end

local scanned = {};
local function ST_ScanUnitDebuffs(unit)
	local guid = UnitGUID(unit);
	if guid and not scanned[guid] then
		scanned[guid] = 1;
		ST_CorrectionScan(unit);
	end
end

local function ST_ScanUnitDebuffs2(unit)
	ST_ScanUnitDebuffs(unit.."pet");
	ST_ScanUnitDebuffs(unit.."target");
end

local function ST_RaidTargetScan()
	if not FW.Settings.TimerImproveRaidTarget then return;end
	erase(scanned);
	FW:ForGroupMembers(ST_ScanUnitDebuffs2);
end

-- also USED TO DO a normal scan on target, focus, mouseover, pet and pettarget
local function ST_ExtraScan()
	--FW:Show("extra scan");
	
	-- those never triggered by unitaura event:
	ST_CorrectionScan("mouseover");
	ST_CorrectionScan("pettarget");
	
	-- also scan the rest to make sure...
	ST_CorrectionScan("player");
	ST_CorrectionScan("target");
	ST_CorrectionScan("focus");
	ST_CorrectionScan("pet");
	
	-- and new unit tokens...
	ST_CorrectionScan("arena1");
	ST_CorrectionScan("arena2");
	ST_CorrectionScan("arena3");
	ST_CorrectionScan("arena4");
	ST_CorrectionScan("arena5");

	ST_CorrectionScan("boss1");
	ST_CorrectionScan("boss2");
	ST_CorrectionScan("boss3");
	ST_CorrectionScan("boss4");
end

local function ST_MobDies(guid)
	for i=1,st.rows,1 do
		if st[i][11] == guid then
			ST:Fade(i,REMOVE);
		end
	end
end

local function ST_RegisterImproved()
	ActiveDots:erase();
end

local function ST_RemoveDots()
	if FW.Settings.TimerImprove then
		local i=1;
		local t = GetTime();
		while i<= ActiveDots.rows do
			if ActiveDots[i][3] < t then
				local t1,t2 = unpack(ActiveDots[i]);
				ActiveDots:remove(i);
				
				if strfind(t1,"^0x") then
					for j=1,st.rows,1 do
						if st[j][11] == t1 and st[j][14] <= NORMAL and st[j][8] == t2 then
							ST:Fade(j,REMOVE);
							break;
						end
					end			
				else
					for j=1,st.rows,1 do
						if st[j][4] == t1 and st[j][14] <= NORMAL and st[j][8] == t2 then
							ST:Fade(j,REMOVE);
						end
					end
				end
				--FW:Show("removing "..t2.." on "..t1);
			else
				i=i+1;
			end
		end
	end
end

local function ColorVal(frame,v,total,flag,flag2,custom,spell,group)
	local r,g,b,a;
	if flag2 > REMOVE then
		if frame.s.HighlightColor[0] and v > -0.5 then
			r,g,b = FW:MixColors(-2*v,frame.s.HighlightColor,frame.s.Fail);
		else
			r,g,b = unpack(frame.s.Fail);
		end
	elseif flag2 == REMOVE then
		r,g,b = unpack(frame.s.Fail);
	else	
		if frame.s.HighlightColor[0] and total-v<0.5 then
			if custom == FILTER_COLOR or custom == FILTER_SHOW_COLOR then
				local filter = FlagToFilter(frame,spell,flag);
				r,g,b = FW:MixColors2((total-v)*2,
				frame.s.HighlightColor[1],frame.s.HighlightColor[2],frame.s.HighlightColor[3],
				filter[2],filter[3],filter[4]
				);
			elseif FW.Settings.TimerColorOverride[0] then
				r,g,b = FW:MixColors((total-v)*2,frame.s.HighlightColor,FW.Settings.TimerColorOverride);
			else
				r,g,b = FW:MixColors((total-v)*2,frame.s.HighlightColor,frame.s[group]);
			end
		else
		 	if custom == FILTER_COLOR or custom == FILTER_SHOW_COLOR then
				r,g,b = unpack(FlagToFilter(frame,spell,flag),2,4);
			elseif FW.Settings.TimerColorOverride[0] then
				r,g,b = unpack(FW.Settings.TimerColorOverride);
			else
				r,g,b = unpack(frame.s[group]);
			end
		end
	end
	--alpha
	if total == 0 then
		a = 1;
	elseif v <= 0 and frame.s.ExpiredColor[0] then
		r,g,b,a = unpack(frame.s.ExpiredColor);
	elseif frame.s.Blink[0] and v <= frame.s.Blink[1] and v>0 then
		-- if bg alpha is set to 0.5 or higher: move from baralpha to baralpha -0.5
		-- if bg alpha is set to lower than 0.5: move from baralpha to baralpha +0.5
		if frame.s.BarBackgroundAlpha >= 0.5 then
			a = frame.s.BarBackgroundAlpha-0.25*(1-cos(25*sqrt(v)));
		else
			a = frame.s.BarBackgroundAlpha+0.25*(1-cos(25*sqrt(v)));
		end
	else
		a=frame.s.BarBackgroundAlpha;
	end
	return r,g,b,a;
end

local function ST_DrawTimers()
	for i=1,instances.rows,1 do
		instances[i][2]:Draw();
	end
end

local function ST_ShowTimeFor(id)
	local target = st[id][4];
	if st[id][19] ~= 0 then 
		target = FW.RaidIcons[st[id][19]]..target;
	end
	FW:ShowTimeFor(st[id][8],target,st[id][1]-GetTime(),st[id][6] == COOLDOWN);
end

function ST_GetFadeTime(spellname)
	local what = ST_OnTimerFade[spellname];
	if what then
		local _,_,t = strfind(FW.Settings[what][1],"([%.%d]+)");
		if t then t = tonumber(t); end
		return t or 0.1;	
	else
		return 0;
	end
end

function ST:RegisterOnTimerFade(spellname,option)
	ST_OnTimerFade[spellname] = option;
end

function ST:RegisterOnTimerBreak(func)
	tinsert(ST_OnTimerBreak,func);
end

function ST:RegisterOnBuffGain(func)
	tinsert(ST_OnBuffGain,func);
end

local function NewTick(parent,n)
	local tick;
	parent.ticks[n] = parent:CreateTexture(nil,"OVERLAY");
	tick = parent.ticks[n];
	tick.parent = parent;
	tick:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark");
	tick:SetBlendMode("ADD");
	
	tick.Update = function(self)
		local s = self.parent.parent.parent.s;
		self:SetWidth(s.Height*0.5);
		self:SetHeight(s.Height*1.5);
	end;
	tick:Update();
	return tick;
end

local function NewStatusBar(parent)
	local bar = CreateFrame("Frame",nil,parent);
	bar.parent = parent;
	bar.texture = bar:CreateTexture(nil,"ARTWORK");
	--bar.texture:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0);
	
	bar.origSetWidth = bar.SetWidth;
	bar.SetWidth = function(self,val)
		self:origSetWidth(val);
		self:SetValue(self.value);
	end
	bar.SetStatusBarColor = function(self,r,g,b,a)
		self.texture:SetVertexColor(r,g,b,a);
	end
	bar.GetStatusBarColor = function(self)
		return self.texture:GetVertexColor();
	end
	bar.SetFlipped = function(self,flip)
		self.flipped = flip;
		self.texture:ClearAllPoints();
		if flip then
			self.texture:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
		else
			self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
		end
	end
	bar.SetValue = function(self,value)
		--[[if value < 0 then
			value = 0;
		elseif value > 1 then
			value = 1;
		end]]
		self.value = value;
		if self.flipped then
			self.texture:SetTexCoord(1-value, 1, 0, 1);
			self.texture:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", (1-value)*self:GetWidth(), 0);
		else
			self.texture:SetTexCoord(0, value, 0, 1);
			self.texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (value-1)*self:GetWidth(), 0);
		end
	end
	bar.SetStatusBarTexture = function(self,texture)
		self.texture:SetTexture(texture);
	end
	bar:SetFlipped(false);
	bar:SetValue(1);
	return bar;
end

local function NewBar(parent,n)
	local bar;
	parent.bars[n] = NewStatusBar(parent);
	bar = parent.bars[n];
	bar.ticks = {};
	
	-- clickable icon
	bar.button = CreateFrame("Button",nil,bar);	
	
	bar.button.spark = bar.button:CreateTexture(nil,"OVERLAY");
	bar.button.spark:SetPoint("CENTER",bar.button,"CENTER");
	bar.button.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	bar.button.spark:SetBlendMode("ADD");
	bar.button:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\ST");
	bar.button.texture = bar.button:GetNormalTexture();
	bar.button.texture:SetTexCoord(0.133,0.867,0.133,0.867);
	
	bar.tag = bar.button:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.tag:SetJustifyH("CENTER");	
	bar.tag:SetPoint("BOTTOMRIGHT", bar.button, "BOTTOMRIGHT", 0, 0);	

	-- texts
	bar.name = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.name:SetPoint("CENTER", bar, "CENTER",0,0);
	
	bar.time = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.time:SetJustifyH("LEFT");
	bar.timedummy = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.timedummy:SetJustifyH("LEFT");
	bar.timedummy:Hide();
	
	--sparks
	bar.spark = bar:CreateTexture(nil,"OVERLAY");
	bar.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark");
	bar.spark:SetBlendMode("ADD");
	bar.spark:SetPoint("CENTER",bar,"CENTER");
	
	bar.castarea = bar:CreateTexture(nil,"OVERLAY");
	bar.castarea:SetBlendMode("ADD");

	--raid target icon
	bar.raidicon = bar:CreateTexture(nil,"OVERLAY");
	bar.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
	bar.raidicon:SetPoint("CENTER", bar, "CENTER",0,0);
	
	--background
	bar.back = bar:CreateTexture(nil,"BACKGROUND");
	bar.back:SetAllPoints(bar);
	bar.back:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
		
	--scripts
	bar.button:SetScript("OnClick",function(self,button)
		if button == "RightButton" then
			if FW.Settings.RightClickIconOptions then
				FW:ScrollTo(FWL.SPELL_TIMER.." Color",1,bar.parent.parent.index);
				FW:SetFilterName(FWL.SPELL_TIMER.." Filter",st[bar.id][8],FlagToFilterIndex(st[bar.id][6]));
			end
		else
			if IsShiftKeyDown() then
				--put on ignore once
				st[bar.id][14] = IGNORE;
			else
				-- show duration
				ST_ShowTimeFor(bar.id);
			end
		end
	end);
	bar.button:SetScript("OnEnter",function(self)
		self.over=1;
		--FW:ShowTip(self);
		FW:ShowSpellTip(self);
	end);
	bar.button:SetScript("OnLeave",function(self)
		self.over=nil;
		FW:HideTip(self);
	end);
	bar.button:SetScript("OnUpdate",function(self)
		if self.over and self.oldtitle ~= self.title then
			self.oldtitle = self.title;
			--FW:ShowTip(self);
			FW:ShowSpellTip(self);
		end
	end);
	bar.button:RegisterForClicks("RightButtonUp","LeftButtonUp");

	--functions
	bar.NewTick = NewTick;
	bar.SetTicks = function(self,totaltime,interval,barval,r,g,b)
		local s = self.parent.parent.s;
		if s.Ticks[0] then
			
			if totaltime > 0 then
				local w = bar:GetWidth();
				interval = w/(totaltime/interval);
				barval = barval*w;
				local dist = 0;
				if s.TicksNext then -- next only
					barval = barval-interval;
					while(dist<barval) do
						dist = dist + interval;
					end
					local tick = bar.ticks[1] or bar:NewTick(1);
					if dist<w and barval+interval>0 then
						if self.flipped then
							tick:SetPoint("CENTER", bar, "LEFT", w-dist, 0);
						else
							tick:SetPoint("CENTER", bar, "LEFT", dist, 0);
						end
						tick:SetVertexColor(r,g,b);
						tick:SetAlpha(s.Ticks[1]);
						tick:Show();
					else
						tick:Hide();
					end
					
				else -- all ticks
					local i=1;
					while dist<barval and dist<w do
						local tick = bar.ticks[i] or bar:NewTick(i);
						if self.flipped then
							tick:SetPoint("CENTER", bar, "LEFT", w-dist, 0);
						else
							tick:SetPoint("CENTER", bar, "LEFT", dist, 0);
						end
						tick:SetVertexColor(r,g,b);
						tick:SetAlpha(s.Ticks[1]);
						tick:Show();
						dist = dist + interval;
						i=i+1;
					end
					while bar.ticks[i] and bar.ticks[i]:IsShown() do
						bar.ticks[i]:Hide();
						i=i+1;
					end
				end
			else
				if s.TicksNext then
					if bar.ticks[1] then
						bar.ticks[1]:Hide();
					end
				else
					for i, tick in ipairs(bar.ticks) do
						tick:Hide();
					end
				end
			end
		end
	end
	bar.Update = function(self)
		local s = self.parent.parent.s;
	
		self:ClearAllPoints();
		self:SetHeight(s.Height);
		self:SetStatusBarTexture(s.Texture);
		self.castarea:SetTexture(s.Texture);
		self.back:SetTexture(s.Texture);
		
		self.button:SetWidth(s.Height);
		self.button.spark:SetWidth(s.Height*2.2);
		self.tag:SetFont(unpack(s.StacksFont));

		if s.Spark[0] then
			self.spark:SetWidth(s.Height);
			self.spark:SetHeight(s.Height*2);
			self.spark:SetAlpha(s.Spark[1]);
			self.spark:Show();
		else
			self.spark:Hide();
		end
		self.castarea:SetAlpha(s.CastSpark[1]);
		
		self.raidicon:SetWidth(s.Height);
		self.raidicon:SetAlpha(s.RaidTargets[1]);
		
		self.name:SetFont(unpack(s.Font));
		self.time:SetFont(unpack(s.Font));
		self.timedummy:SetFont(unpack(s.Font));
		self.time:SetTextColor(unpack(s.NormalColor));
		
		self:SetFlipped(s.Flip);
		
		if s.Icon then -- icon is placed outside of the actual bar!!
			self:SetWidth(s.Width-s.Height-1);
			self.button:ClearAllPoints();
			if s.IconRight then -- icon on right side of bar
				self.button:SetPoint("TOPLEFT",self,"TOPRIGHT",1,0);
				self.button:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT",1,0);
			else -- icon on left side of bar
				self.button:SetPoint("TOPRIGHT",self,"TOPLEFT",-1,0);
				self.button:SetPoint("BOTTOMRIGHT",self,"BOTTOMLEFT",-1,0);
			end
			self.button:Show();
		else
			self.button:Hide();
			self:SetWidth(s.Width);
		end
		if s.Time then
			self.time:ClearAllPoints();
			if s.TimeRight then -- time on right side of bar
				self.time:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, 0);
				self.time:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 0);
			else -- time on left side of bar
				self.time:SetPoint("TOPLEFT", self, "TOPLEFT", 2, 0);
				self.time:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 0);
			end
			self.time:Show();
		else
			self.time:Hide();
		end
		if s.Name then
			self.name:SetHeight(self:GetHeight());
			self.name:Show();
		else
			self.name:Hide();
		end
	end;
	bar:Update();
	return bar;
end

local function NewGroup(parent,n)
	local group;
	parent.groups[n] = CreateFrame("Frame",nil,parent);
	group = parent.groups[n];
	group.bars = {};
	group.parent = parent;
	
	group.usewidth = 0;
	
	group.background = CreateFrame("Frame",nil,group);
	group.background:SetAllPoints(group);
	group.background:SetFrameLevel(1);	
		
	group.label = group:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	group.raidicon = group:CreateTexture(nil,"OVERLAY");
	group.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
	group.raidicon:SetPoint("CENTER", group, "CENTER",0,0);
	
	group.NewBar = NewBar;
	group.NewLabel = NewLabel;

	group.Finalize = function(self,i)
		while self.bars[i] and self.bars[i]:IsShown() do
			self.bars[i]:Hide();
			i=i+1;
		end
	end;
	
	group.Update = function(self)
		local s = self.parent.s;
		
		self:ClearAllPoints();
		self.label:ClearAllPoints();
		self.raidicon:ClearAllPoints();
		if s.Expand == true then 
			self:SetPoint("BOTTOM",self.parent,"BOTTOM");
		else
			self:SetPoint("TOP",self.parent,"TOP");
		end
		self:SetWidth(s.Width+s.Backdrop[6]*2);
		
		self.label:SetFont(unpack(s.LabelFont));
		self.background:SetBackdrop(self.parent.header.backdrop);
		
		self.raidicon:SetWidth(s.LabelHeight);
		self.raidicon:SetAlpha(s.RaidTargets[1]);
	end;
	group:Update();
	return group;
end

local function ST_NewTimerFrame(index,root)
	local frame = CreateFrame("Frame",nil,UIParent);
	frame.parent = UIParent;
	frame.index = index;
	frame.root = root;
	--frame.displayname = displayname;
	frame.groups = {};
	frame:SetPoint("CENTER",UIParent,"CENTER");	
	frame:SetHeight(20);
	
	frame.header = CreateFrame("Frame",nil,frame);
	frame.header:SetAllPoints(frame);
	frame.header.title = frame.header:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	frame.header.title:SetAllPoints(frame);
	
	--scripts
	frame:SetScript("OnMouseDown",function(self,button)
		FW:StartMoving(self, button);
	end);
	frame:SetScript("OnMouseUp",function(self,button)
		FW:StopMoving(self);
		if FW:Moved() then return; end
		if button == "RightButton" then
			FW:ScrollTo(FWL.SPELL_TIMER,nil,frame.index);
		end
		PlaySound("igMainMenuOptionCheckBoxOn");
	end);

	--functions
	frame.NewGroup = NewGroup;
	
	local links = FW:NEW2D();

	local function VisibleUnit(id,guid)
		if id<=0 or id>=maxi then
			if guid == "" then
				return frame.s.UnknownTarget;
			else
				if id == PRIOR_NONE then
					return frame.s.NoTarget;
				elseif id == PRIOR_DEBUFF then	
					return frame.s.RaidDebuffs;
				else
					return frame.s.You;
				end
			end

		elseif guid==FW.target or guid==FW.focus then
			return (guid==FW.target and frame.s.Target) or (guid==FW.focus and frame.s.Focus);
		else
			return frame.s.Other;	
		end
	end
	
	local function Alpha(trigger,t)
		if t <= trigger then
			return 1;
		elseif t<trigger+FW.Settings.TimerFadeSpeed then 
			return 1 - pow( ((t-trigger)/FW.Settings.TimerFadeSpeed),3);
		else
			return 0;
		end
	end
	local function Visible(index)
		return (VisibleUnit( st[index][13], st[index][11]) and (st[index][14] < FAILED or frame.s.Fail[0]) and FlagToAction(frame, st[index][8],st[index][6],st[index][21])) or FILTER_HIDE;
	end
	frame.addLink = function(self,index)
		local action = Visible(index);
		if action ~= FILTER_HIDE then
			--FW:Show("add");
			links:insert( index, st[index][13] , st[index][20] , 1, action, st[index][3], 0);
		end
	end
	frame.removeLink = function(self,index)
		--FW:Show("remove");
		links:remove( links:find( index , 1 ) );
		for i=1, links.rows do -- super important to update ids too!!
			if links[i][1] > index then
				links[i][1] = links[i][1] - 1;
			end
		end
	end
	frame.setValueLinks = function(self,index,col,val)
		local l = links:find( index , 1 );
		if l then
			links[l][col] = val;
		end
	end
	frame.eraseLinks = function(self)
		links:erase();
	end
	frame.printLinks = function(self)
		links:print();
	end
	frame.rebuildLinks = function(self)
		local action, l;
		for index=1,st.rows do
			action, l = Visible(index), links:find(index,1);
			if action == FILTER_HIDE then
				links:remove(l);
			else
				if l then
					links[l][5] = action; -- update filter action in case of filter change
				else
					links:insert(index,st[index][13],st[index][20],1,action,st[index][3],0);
				end
			end
		end
	end
	
	local function drawLabel(s,group,label,baroffset,groupsize,vis,t4,t9,t11,t13)
		if t13 > 0 and t13 < maxi and s.Label then -- add a name label
			
			if s.ShowID and t9 == 0 then
				label:SetText("#"..t13.." "..t4);
			else
				label:SetText(t4);
			end
			if t11 == FW.target then
				label:SetTextColor(unpack(s.TargetColor));
			elseif t11 == FW.focus then
				label:SetTextColor(unpack(s.FocusColor));
			else
				label:SetTextColor(unpack(s.NormalColor));
			end
			if s.Expand == true then
				if s.LabelLimit then
					label:SetPoint("BOTTOMLEFT",group,"BOTTOMLEFT",2,baroffset);
					label:SetPoint("BOTTOMRIGHT",group,"BOTTOMRIGHT",-2,baroffset);
				else
					label:SetPoint("BOTTOM",group,"BOTTOM",0,baroffset);
				end
				group.raidicon:SetPoint("BOTTOM",group,"BOTTOM",0,baroffset);
			else
				if s.LabelLimit then
					label:SetPoint("TOPLEFT",group,"TOPLEFT",2,-baroffset);
					label:SetPoint("TOPRIGHT",group,"TOPRIGHT",-2,-baroffset);
				else
					label:SetPoint("TOP",group,"TOP",0,-baroffset);
				end
				group.raidicon:SetPoint("TOP",group,"TOP",0,-baroffset);
			end
			baroffset = baroffset + group.labelsize;
			groupsize = baroffset;
			baroffset = baroffset + vis*s.Space;
			label:Show();
		else
			label:Hide();
		end
		return baroffset, groupsize;
	end
		
	frame.Draw = function(self)
		local s = self.s;
		if s.Enable and (not s.Hide or not s.lock or STATES.INCOMBAT) then -- auto-hide only
			if self:GetAlpha()<s.alpha then
				self:SetAlpha(self:GetAlpha()+0.1);
			end
			if not self:IsShown() then
				self:Show();
			end
		else
			if self:GetAlpha()>0.1 then
				self:SetAlpha(self:GetAlpha()-0.1);
			elseif self:IsShown() then
				self:Hide();
			end
		end
	
		if not self:IsShown() then return; end
		local smooth = FW.Settings.TimerSmooth;
		local baroffset = s.Backdrop[6];
		local index=1;
		local lastid;
		local higha = 0;
		local barvisibility = 0;
		local highh = 0;
		local bar,spark,label;
		local barval;
		local _,t1,t2,t3,t4,t6,t7,t8,t9,t10,t11,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,t23,t27,t28;
		local filter,maxtime,vis;
		local i = 1;
		local g = 1; -- used for group index
		local groupsize = 0;
		local groupoffset = 0;
		local groupvisibility = 0;
		local group;
		local t = GetTime();
		local highestduration = 0; 
		--pre-compute stuff
		local k = 1;
		-- copy some values from st to sort links by
		for k=1, links.rows do
			i = links[k][1];
			links[k][2],links[k][3] = st[i][13],st[i][20]; -- set these for sorting only
			
			-- calc visibility
			t14,t17 = st[i][14],st[i][17];
			if t14 == IGNORE then
				links[k][4] = 0;
			elseif t14 == NORMAL then
				if s.HideLonger[0] and (not s.HideLongerNoBoss or st[i][9]~=1) and (st[i][1]-t) >= s.HideLonger[1] then
					if links[k][7] == 0 then
						links[k][7] = t;
					end
				else
					links[k][7] = 0;
				end			
				if links[k][7] == 0 then
					links[k][4] = 1;
				else
					links[k][4] = Alpha(links[k][7]+s.HideTime,t); 
				end
			elseif t14 == FADING_INSTANT then
				links[k][4] = Alpha(t17,t); 
			elseif t14 == FADING then
				links[k][4] = Alpha(t17+s.FadeTime,t); 
			else -- removed/failed
				links[k][4] = Alpha(t17+s.FailTime,t); 
			end
		end
		if s.GroupID then
			if s.Outwands then
				SORT_TIMER_ASC2[2]=true;
			else
				SORT_TIMER_ASC2[2]=false;
			end
			links:sort(SORT_TIMER_ORDER2,SORT_TIMER_ASC2);
		else
			if s.Outwands then
				SORT_TIMER_ASC[1]=true;
			else
				SORT_TIMER_ASC[1]=false;
			end
			links:sort(SORT_TIMER_ORDER,SORT_TIMER_ASC);
		end
		
		local visible = 0;

		for k=1, links.rows do
			i = links[k][1];
			
			if (not s.Max[0] or visible < s.Max[1]) and links[k][4] > 0 then -- visibility (yes or no) based on num timers and alpha
				visible = visible + 1;

				if not s.ForceMax then
					t3 = st[i][3];
					if s.OneMax then
						if t3 > highestduration then
							if s.MaxTime[0] and t3 > s.MaxTime[1] then
								highestduration = s.MaxTime[1];
							else
								highestduration = t3;
							end
						end
					else
						if s.MaxTime[0] and t3 > s.MaxTime[1] then
							links[k][6] = s.MaxTime[1];
						else
							links[k][6] = t3;
						end
					end
				end
				-- pre-calculate group scaling and alpha (and pre-make groups)
				if s.GroupID and lastid ~= st[i][13] or lastid == nil then --  create a new group!
					group = self.groups[g] or self:NewGroup(g);
					g=g+1; -- new group number for next group
					group.factor = 0;
				end
				if group.factor < links[k][4] then
					group.factor = links[k][4];
				end
				lastid = st[i][13];
			else
				links[k][4] = 0;
			end
		end
		
		if s.ForceMax then
			highestduration = s.MaxTime[1];
			for k=1,links.rows do
				if links[k][4] == 1 then
					links[k][6] = links[k][6]+(highestduration-links[k][6])/smooth;
				end
			end
		elseif s.OneMax then
			for k=1,links.rows do
				if links[k][4] == 1 then
					links[k][6] = links[k][6]+(highestduration-links[k][6])/smooth;
				end
			end
		end
		
		lastid = nil;
		group = nil;
		g = 1;
		i=1;
		

		for k=1,links.rows do -- stuff to make it 'skip' certain timers for display
			vis = links[k][4];
			if vis > 0 then -- is visible
				_,t2,t3,t4,_,t6,t7,t8,t9,t10,t11,_,t13,t14,_,t16,_,t18,t19,t20,t21,t22,t23,_,_,_,t27,t28 = unpack(st[ links[k][1] ]);
				-- add linked instance values
				filter,maxtime = links[k][5],links[k][6];
				
				-- GROUP AND BAR CREATION
				t1 = t20 - t;
				if maxtime == 0 then
					maxtime = 1;
				end
				--t20 = t20 - t;
				if s.GroupID then
					if lastid ~= t13 then --  create a new group!
						if group then -- finish the 'last' group
							group:Finalize(i);
							if s.LabelFlip then
								baroffset,groupsize = drawLabel(s,group,label,baroffset,groupsize,group.factor,t4,t9,t11,t13);
							end
							group:SetHeight( groupsize+group.bordersize );
							group.background:SetAlpha(groupvisibility);
							label:SetHeight(group.labelsize);
							label:SetAlpha(groupvisibility);
							group.raidicon:SetAlpha(s.RaidTargets[1]*groupvisibility);
							group.raidicon:SetHeight(group.labelsize);

							groupoffset = groupoffset + group:GetHeight() + s.SpacingHeight*group.factor;
						end
						
						group = self.groups[g] or self:NewGroup(g);
						label = group.label;
						group.bordersize = s.Backdrop[6]*group.factor;
						group.labelsize = s.LabelHeight*group.factor;
						baroffset = group.bordersize;
						i=1;
						g=g+1; -- new group number for next group
						groupvisibility = 0;
						
						if not s.LabelFlip then
							baroffset,groupsize = drawLabel(s,group,label,baroffset,groupsize,group.factor,t4,t9,t11,t13);
						end
						
						if s.TargetBgColor[0] and t11 == FW.target then
							group.background:SetBackdropBorderColor(unpack(s.TargetBgColor));
							group.background:SetBackdropColor(unpack(s.TargetBgColor));
						elseif s.FocusBgColor[0] and t11 == FW.focus then
							group.background:SetBackdropBorderColor(unpack(s.FocusBgColor));
							group.background:SetBackdropColor(unpack(s.FocusBgColor));
						else
							group.background:SetBackdropBorderColor(unpack(s.NormalBgColor));
							group.background:SetBackdropColor(unpack(s.NormalBgColor));
						end
					end
				else -- without grouping, just create one group to use for all bars
					if lastid == nil then
						group = self.groups[g] or self:NewGroup(g);
						label = group.label;
						group.bordersize = s.Backdrop[6]*group.factor;
						group.labelsize = s.LabelHeight*group.factor;
						label:Hide();
						g=g+1;
					end
					group.background:SetBackdropBorderColor(unpack(s.NormalBgColor));
					group.background:SetBackdropColor(unpack(s.NormalBgColor));
				end
				
				bar = group.bars[i] or group:NewBar(i);
				spark = bar.spark;
				
				-- SIZE AND ALPHA STUFF
				if s.Expand == true then
					if s.Icon and not s.IconRight then
						bar:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT",s.Height+1+s.Backdrop[6], baroffset);
					else
						bar:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT",s.Backdrop[6], baroffset);
					end
					group:SetPoint("BOTTOM",self,"BOTTOM",0, groupoffset);
				else
					if s.Icon and not s.IconRight then
						bar:SetPoint("TOPLEFT", group, "TOPLEFT",s.Height+1+s.Backdrop[6], -baroffset);
					else
						bar:SetPoint("TOPLEFT", group, "TOPLEFT",s.Backdrop[6], -baroffset);
					end
					group:SetPoint("TOP",self,"TOP",0, -groupoffset);
				end
				
				baroffset = baroffset + vis*s.Height;
				groupsize = baroffset;
				baroffset = baroffset + vis*s.Space;

				if t13<=0 or t13>=maxi or t11==FW.target or t14>REMOVE then
					barvisibility = vis;
				else
					barvisibility = s.NormalAlpha*vis;
				end
				if barvisibility > groupvisibility then
					groupvisibility = barvisibility;
				end
				bar:SetAlpha(barvisibility); 
				
				-- ALL OTHER STUFF
				if t19 == 0 or not s.RaidTargets[0] then
					bar.raidicon:Hide();
					group.raidicon:Hide();
				else
					if s.Label and s.GroupID then
						group.raidicon:SetTexCoord(unpack(FW_RaidIconCoords[t19]));
						group.raidicon:Show();
						bar.raidicon:Hide();
					else
						bar.raidicon:SetTexCoord(unpack(FW_RaidIconCoords[t19]));
						bar.raidicon:SetHeight(vis*s.Height);
						bar.raidicon:Show();
						group.raidicon:Hide();
					end
				end
				local r,g,b,a = ColorVal(self,t1,t3,t6,t14,filter,t8,t21);
				bar:SetStatusBarColor(r,g,b);
				bar.back:SetVertexColor(r,g,b,a);		
				r,g,b = FW:FixIntensity(r,g,b);
				if t1<0 then
					t1=0;
				end
				if t1==0 and (not s.SparkDamage[0] or t18==0 or (t18 - t) <= -0.3) then
					spark:Hide();
				else
					if s.Spark[0] then
						spark:SetVertexColor(r,g,b);
						if s.SparkDamage[0] then -- if disabled the update function sets the right height / alpha
							if t18 >= t-0.3 then
								local dt = (t18-t+0.3)/0.3; -- 1 to 0
								spark:SetHeight(s.Height*2*( dt*(s.SparkDamage[1]-1) + 1 ) );
								spark:SetAlpha(dt + (1-dt)*s.Spark[1]);
							else
								spark:SetHeight(s.Height*2);
								spark:SetAlpha(s.Spark[1]);
							end
						end
						spark:Show();
					else
						spark:Hide();
					end
				end
				-- set tooltip stuff
				bar.button.title = FW:SecToTime(t1).." "..t8;
				bar.button.tip = t4.."\n"..FW:SecToTime(t1).."/"..FW:SecToTime(t3);
				bar.button.spell = t8;
				bar.button.friendly = t23;
				bar.button.token = t27;
				bar.button.buffid = t28;
			
				--t1 = curent time, t3 = total time, maxtime = adapted time			
				if t1>maxtime then
					barval=1;
				else
					barval = t1/maxtime;
				end
				if s.Ticks[0] and Tick[t8] then
					bar:SetTicks(maxtime,Tick[t8]*t22,barval,r,g,b);
				else
					bar:SetTicks(0,1,0,r,g,b);
				end
				bar:SetValue(barval);
				bar.id = links[k][1];
				-- t1 = remaining, t2 = cast time, t3 = total time, maxtime = maximum used (end of bar)
				local offset = 0;
				if s.CastSparkTickOverlap and Tick[t8] then
					offset = -Tick[t8]*t22	
				end
				local from,to = barval,barval;
				-- from is the original spark, to is the cast spark
				if s.CastSpark[0] then
					if t1<=t2-offset and t3>0 and (t1==0 or t6 ~= COOLDOWN) then -- Cast Spark, t3>0 to hide if it's a resist etc
						bar.button.spark:SetVertexColor(r,g,b);
						bar.button.spark:Show();
					else
						bar.button.spark:Hide();
					end
					local length = 0;
					local shiftme = false;
					-- manages the cast sparks REWRITE PLXX!!!
					if t2>0 and t3>0 then -- does have a cast time
						length = t2;
						shiftme = t6 ~= COOLDOWN;
					elseif s.CastSparkGCD and t6 == DEFAULT or t6==COOLDOWN then
						length = CA.GlobalCooldown;
					end
					length = length/maxtime;
					from = from+offset/maxtime;
					if shiftme then
						from = from - length;
					end
					if from < 0 then
						from = 0;
					elseif from > 1 then
						from = 1;
					end
					to = from+length;
					if to > 1 then
						to = 1;
					end					
				else
					bar.button.spark:Hide();
				end
				if to == from then
					bar.castarea:Hide();
				else
					bar.castarea:SetVertexColor(r,g,b);
					if bar.flipped then
						to,from = 1-from,1-to;
					end
					bar.castarea:SetTexCoord(from,to,0,1);
					bar.castarea:SetPoint("TOPLEFT",bar,"TOPLEFT",from*bar:GetWidth(),0);
					bar.castarea:SetPoint("BOTTOMRIGHT",bar,"BOTTOMLEFT",to*bar:GetWidth(),0);
					bar.castarea:Show();
				end
				
				if s.IconStacks and t16 ~= 0 and s.Icon then
					bar.tag:SetText(t16);
					t16 = 0;
				else
					bar.tag:SetText("");
				end
				if s.Time then
					if t14 > REMOVE then
						bar.time:SetText(FADE_SHOW[t14]);
					elseif t3 == 0 then
						bar.time:SetText("");
					else
						bar.time:SetText(FW:SecToTimeD(t1));
					end
					bar.timedummy:SetText(bar.time:GetText());
					if FW.Settings.TimerSmartSpace[0] then
						group.usewidth = max(group.usewidth, bar.timedummy:GetWidth());
					else
						group.usewidth = bar.timedummy:GetWidth();
					end
					bar.time:SetWidth(group.usewidth);
				else
					group.usewidth = 0;
				end
				if s.Name then
					if s.CustomTag[0] then
						local str = s.CustomTag[1];
						if t13 > 0 and t13 < maxi and t9 == 0 then -- add ID
							str = gsub(str,"id","#"..t13);
						else
							str = gsub(str,"id","");
						end
						if  t16 ~= 0 then -- add stacks
							str = gsub(str,"stacks","("..t16..")");
						else
							str = gsub(str,"stacks","");
						end
						if t4 ~= t8 then
							str = gsub(str,"target",t4);
						else
							str = gsub(str,"target","");
						end
						str = gsub(str,"spell",t8);
						bar.name:SetText(str);
					else
						if s.Spell or t4 == "" then
							t4 = t8;
						end
						if s.ShowID and t13 > 0 and t13 < maxi and t9 == 0 and not s.Spell then
							bar.name:SetText("#"..t13.." "..t4);
						elseif t16 ~= 0 then
							bar.name:SetText(t4.." ("..t16..")");
						else
							bar.name:SetText(t4);
						end
					end
					if s.TargetColor[0] and t11 == FW.target then
						bar.name:SetTextColor(unpack(s.TargetColor));
					elseif s.FocusColor[0] and t11 == FW.focus then
						bar.name:SetTextColor(unpack(s.FocusColor));
					else
						bar.name:SetTextColor(unpack(s.NormalColor));
					end		

					bar.name:SetWidth(bar:GetWidth()-2*group.usewidth-4); -- 4 margin (2 on both sizes)
				end
				bar:SetHeight(vis*s.Height);
				bar.button.spark:SetHeight(vis*s.Height*2.2);
				
				if bar.flipped then
					spark:SetPoint("CENTER", bar, "LEFT",(1-barval)*bar:GetWidth(), 0);
				else
					spark:SetPoint("CENTER", bar, "LEFT",barval*bar:GetWidth(), 0);
				end
				
				bar.button.texture:SetTexture(t7);
				lastid = t13;
			
				bar:Show();
				group:Show();
				i=i+1;
			end
		end
		-- bar/bg positioning
		if group then
			group:Finalize(i);
			if s.LabelFlip and s.GroupID then
				baroffset,groupsize = drawLabel(s,group,label,baroffset,groupsize,group.factor,t4,t9,t11,t13);
			end
			group.background:SetAlpha(groupvisibility);
			group:SetHeight( groupsize+group.bordersize );
			label:SetHeight( group.labelsize );
			label:SetAlpha(groupvisibility);
			
			group.raidicon:SetAlpha(s.RaidTargets[1]*groupvisibility);
			group.raidicon:SetHeight(group.labelsize);
			
			self.header:Hide();
		elseif not s.lock then
			self.header:Show();
		else
			self.header:Hide();
		end
		
		while self.groups[g] and self.groups[g]:IsShown() do
			self.groups[g]:Hide();
			g=g+1;
		end

	end
	frame.HideTicks = function(self)
		for g, group in ipairs(self.groups) do
			for b, bar in ipairs(group.bars) do
				for i, tick in ipairs(bar.ticks) do
					tick:Hide();
				end
			end
		end	
	end
	frame.ResetDurationTextSize = function(self)
		for g, group in ipairs(self.groups) do
			group.usewidth = 0;
		end
	end
	frame.Init = function(self)
		self.s = FW.Settings.Timer.Instances[self.index] or FW.Settings;
		FW:InitFrameVars(self);
	end
	frame.Update = function(self)
		if self.s.Enable then
			self:EnableMouse( not self.s.lock );
			self:SetAlpha(self.s.alpha);
			self:SetWidth(self.s.Width+self.s.Backdrop[6]*2);
			self:SetHeight(self.s.Height+self.s.Backdrop[6]*2);
			self:SetScale(self.s.scale);
			self.header.title:SetFont(unpack(self.s.LabelFont));
			self.header.title:SetText(FW:InstanceIndexToName(self.index,FW.Settings.Timer)..FWL._RIGHTCLICK_FOR_OPTIONS);
			
			FW:SetBackdrop(self.header,unpack(self.s.Backdrop));
			self.header:SetBackdropBorderColor(unpack(self.s.NormalBgColor));
			self.header:SetBackdropColor(unpack(self.s.NormalBgColor));
			
			for g, group in ipairs(self.groups) do
				group:Update();
				for b, bar in ipairs(group.bars) do
					bar:Update();
					for j, tick in ipairs(bar.ticks) do
						tick:Update();
					end
				end
			end
			FW:CorrectPosition(self);
			self:SetFrameStrata(FW.Settings.TimerStrata);
			self:Show();
			self:Draw();
		else
			self:Hide();
		end
		
	end
	return frame;
end

-- cloning code
local function ST_NewTimerInstance(index) -- create new timer instance for index
	FW:CopyCloneSettings(FW.InstanceDefault.Timer,FW.Settings.Timer.Instances[index]); -- init the config of this instance
	local frame_name, frame = "FX_Timer"..index;
	
	if instances.rows < #instances then
		--FW:Show("recycling");
		local n = instances.rows+1;
		frame = instances[n][2];
		instances[n][1] = frame_name;
		frame.index = index;
		instances.rows = n;
	else
		--FW:Show("new instance");
		frame = ST_NewTimerFrame(index);
		instances:insert(frame_name,frame);
	end
	
	FW:RegisterFrame(frame_name,frame,false,"Timer");
	frame:Init();
	frame:rebuildLinks();
	frame:Update();
end

function ST:NewTimerInstance(index)
	ST_NewTimerInstance(index);
end

local function ST_CreateTimerInstance() -- create and permanently SAVE a new frame instance
	local active = FW.Settings.Timer.Active;
	local index = FW:InstanceCreate("Clone of "..FW.Settings.Timer.Data[active].name,FW.Settings.Timer,FW.Settings.Timer.Instances[active]);
	
	FW.Settings.Timer.Active = index;
	FW.Settings.Timer.Instances[index].lock = false; -- make sure a new instance is always unlocked!
	ST_NewTimerInstance(index); -- create the new frame and its options

	FW:BuildOptions();
	FW:RefreshOptions();
end

local function ST_RemoveAllInstances()
	while instances.rows > 0 do -- remove all
		FW:UnregisterFrame(instances[1][1]);
		instances:remove(1);
	end
end

local function ST_RemoveTimerInstance(dialog,obj) -- permanently delete a SAVED frame instance
	if obj.index then
		local done, curr = FW:InstanceDelete(obj.index,FW.Settings.Timer);
		if done then
			ST_RemoveAllInstances(); -- 'remove' all current instance frames
			-- add the right ones
			for i, v in ipairs(FW.Settings.Timer.Instances) do -- load custom instances
				ST_NewTimerInstance(i);
			end
			
			FW:BuildOptions();
			FW:RefreshOptions();
		end
	end
end

local function ST_RenameTimerInstance(obj,newname)
	FW:InstanceRename(obj.index,newname,FW.Settings.Timer)
	instances[obj.index][2]:Update();
	FW:BuildOptions();
	FW:RefreshOptions();
end

local function ST_SelectTimerInstance(obj)
	FW.Settings.Timer.Active = obj.index;
	FW:BuildOptions();
	FW:RefreshOptions();
end

local function ST_RemoveTimerInstanceDialog(obj)
	_G.StaticPopupDialogs["FX_CONFIRM_DELETE_CLONE"].OnAccept = ST_RemoveTimerInstance; -- differs per instance type
	_G.StaticPopup_Show("FX_CONFIRM_DELETE_CLONE",obj.displayname,obj.index,obj);
end

local tab_actions = {
	ST_CreateTimerInstance,
	ST_RemoveTimerInstanceDialog,
	ST_RenameTimerInstance,
	ST_SelectTimerInstance,
}

local function ST_TimerFilterChange(instance)
	--FW:Show(tostring(instance));
	if instance then
		instance:rebuildLinks();
	else
		local i = 1;
		while i <= st.rows do
			if st[i][6] == DEBUFF or st[i][6] == POWERUP or st[i][6] == SELF_DEBUFF or st[i][6] == ENCHANT then -- kinda dirty, but it works
				st:remove(i);
			else
				i=i+1;
			end
		end
		ST_PlayerBuffs();
		ST_TargetDebuffs();
		ST_ScanWeaponEnchant();
		
		rebuildLinks();
	end
end

ST.FilterChange = ST_TimerFilterChange;

do
	local PLAYER = FW.PLAYER;
	local select = select;
	local dura = 30;
	
	local function ST_CombatLogEvent(event,...)
		local arg2 = select(2,...);
		--combat_log_active = true;
		if select(5,...) == PLAYER then
			if arg2 == "SPELL_PERIODIC_DAMAGE" or arg2 == "SPELL_PERIODIC_MISSED" or arg2 == "SPELL_PERIODIC_HEAL" or arg2 == "SPELL_DAMAGE" then
				ST_OnTick(select(9,...),select(8,...),select(13,...),false);
			elseif arg2 == "SPELL_SUMMON" and (select(12,...) == 71843 or select(12,...) == 71844) then
				local expire = GetTime()+dura;
				local summon_valkyr = FWL.SUMMON_VALKYR or select(9,...);
				st:insert(expire,0,dura,summon_valkyr,0,DEFAULT,"Interface\\Icons\\Achievement_Boss_SvalaSorrowgrave",summon_valkyr,0,0,"none",0,PRIOR_NONE,0,1, 0 ,0,00000,0,expire,"Pet",1.0,0,0,0,1,"",0);
			end
		else
			if arg2 == "UNIT_DIED" then
				ST_MobDies(select(8,...));
			end
		end
	end
	local lspell;
	local function ST_UpdateTest()
		local guid = UnitGUID("target") or "";
		local targetname = UnitName("target") or FWL.NOTARGET;
		local id = CA:GiveID(guid);
		if st.rows<50 then
			lspell = next(Track,lspell);
			if lspell then
				if Track[lspell][1] == 1 then
					targetname = lspell;
					id=0;icon=0;guid="none";
				end
				ST:AddNewTimer(
				GetTime()+Track[lspell][2],
				Track[lspell][2],
				targetname,
				lspell,
				CA:Unique("target"),
				id,
				0,
				guid,1.0,0);
			end
		end
	end
	local testing = false;
	function Test(frame)
		if frame then -- to avoid errors on profile change...
			testing = frame.s.Test;
		else
			testing = false;
		end
		for i=1,instances.rows,1 do
			instances[i][2].s.Test = testing; --  copy to all instances
		end
		if testing then
			FW:UnregisterToEvent("UPDATE_MOUSEOVER_UNIT",		ST_MouseOverChanged);
			FW:UnregisterToEvent("UNIT_AURA", 					ST_AuraChanged);
			FW:UnregisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
			FW:UnregisterToEvent("UNIT_INVENTORY_CHANGED", 		ST_ScanWeaponEnchantTrottle);

			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_ExtraScan);
			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_RemoveDots);
			FW:UnregisterTimedEvent("UpdateInterval",			ST_RaidTargetScan);

			FW:RegisterTimedEvent("SpellTimerInterval",			ST_UpdateTest);		
		else
			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_UpdateTest);
			
			st:erase(); -- remove all timers
			FW:RegisterToEvent("UPDATE_MOUSEOVER_UNIT",			ST_MouseOverChanged);
			FW:RegisterToEvent("UNIT_AURA", 					ST_AuraChanged);
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
			FW:RegisterToEvent("UNIT_INVENTORY_CHANGED", 		ST_ScanWeaponEnchantTrottle);

			FW:RegisterTimedEvent("SpellTimerInterval",			ST_ExtraScan);
			FW:RegisterTimedEvent("SpellTimerInterval",			ST_RemoveDots);
			FW:RegisterTimedEvent("UpdateInterval",				ST_RaidTargetScan);
			
			ST_PlayerBuffs(); -- add real timers back
			ST_TargetDebuffs();
		end
	end
	
	-- create default timer frame
	FW:RegisterLoadClones(function()
		if not FW.Settings.Timer then
			-- create one instance by default
			FW.Settings.Timer = {Active=1,Instance="Timer",Instances={}, Links={}, Data={}};
			FW:InstanceCreate(FWL.SPELL_TIMER,FW.Settings.Timer,FW.InstanceDefault.Timer);
		end
		
		ST_RemoveAllInstances(); -- 'remove' all current instance frames
		-- add the right ones
		for i, v in ipairs(FW.Settings.Timer.Instances) do -- load custom instances
			ST_NewTimerInstance(i,nil); -- don't refresh, update is triggered after load clones
		end

	end);
	
	FW:RegisterVariablesEvent(function()
	
		FW:RegisterToEvent("PLAYER_TARGET_CHANGED",			ST_TargetChanged);
		FW:RegisterToEvent("PLAYER_FOCUS_CHANGED",			ST_FocusChanged);
		FW:RegisterToEvent("UPDATE_MOUSEOVER_UNIT",			ST_MouseOverChanged);
		FW:RegisterToEvent("UNIT_AURA", 					ST_AuraChanged); --<-- apparently also needed for powerups
		FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
		FW:RegisterToEvent("UNIT_INVENTORY_CHANGED", 		ST_ScanWeaponEnchantTrottle);

		FW:RegisterTimedEvent("AnimationInterval",	ST_UpdateSpellTimers);
		FW:RegisterTimedEvent("SpellTimerInterval",	ST_ExtraScan);
		FW:RegisterTimedEvent("SpellTimerInterval",	ST_RemoveDots);
		FW:RegisterTimedEvent("AnimationInterval",	ST_DrawTimers);
		FW:RegisterTimedEvent("UpdateInterval",		ST_RaidTargetScan);
		
		FW:RegisterTimedEvent("TimerSmartSpace",function()
			for i=1,instances.rows,1 do
				instances[i][2]:ResetDurationTextSize();
			end
		end);
		
		ST_CreateSortOrder();--init sorting direction (advanced settings)
		ST_CalculateMaxDelay();		
	end);
	
	CA:RegisterOnSelfCastFail(ST_SpellFail);
	CA:RegisterOnSelfCastTracked(ST_TrackedSuccess);
	CA:RegisterOnSelfCastEnd(ST_SelfSuccess); -- always triggered regardless of resists
	
	FW:RegisterDelayedLoadEvent(ST_PlayerBuffs);
	FW:RegisterDelayedLoadEvent(ST_ScanWeaponEnchant);
	
	if CD then
		CD:RegisterOnCooldownUsed(ST_OnCooldownUsed);
		CD:RegisterOnCooldownUpdate(ST_OnCooldownUpdate);
		CD:RegisterOnCooldownReady(ST_OnCooldownReady);
	end
	
	FW:RegisterOnLeaveCombat(function()
		if FW.Settings.RemoveAfterCombat and not UnitIsDeadOrGhost("player") and not UnitAura("player",feign) then --  remove non-player timers when dropped from combat, keep if player died
			ST_ClearMobTimers();
		end
	end);
	FW:AddCommand("u",function(s)
		if s == "trash" then
			ST_Exception(0);
		elseif s == "boss" then
			ST_Exception(1);
		elseif s == "none" then
			ST_Exception(nil);
		end
	end);
	--FW:Show("Timer Module Loaded");
	
	--FW:RegisterOnProfileChange(function() tab_actions[6] = FW.Settings.TimerInstances; end);
	FW:RegisterOnProfileChange(ST_TimerFilterChange);
	FW:RegisterOnProfileChange(Test);
	
	FW:RegisterOnProfileChange(ST_CreateSortOrder);
	FW:RegisterOnProfileChange(ST_CalculateMaxDelay);
end

function ST:AddMeleeBuffs()
	self:AddBuff(32182) -- Heroism
	:AddBuff(80353) -- Time Warp
	:AddBuff(2825) -- Bloodlust
	:AddBuff(33649) -- Rage of the Unraveller
	:AddBuff(33667) -- Ferocity
	:AddBuff(34519) -- Time's Favor, Moroes' Lucky Pocket Watch
	:AddBuff(43738) -- Primal Instinct, Idol of Terror
	:AddBuff(40464) -- Protector's Vigor, Shadowmoon Insignia
	:AddBuff(40729) -- Heightened Reflexes, Badge of Tenacity
	:AddBuff(35166) -- Lust for Battle
	:AddBuff(28507) -- Haste
	:AddBuff(35733) -- Ancient Power
	:AddBuff(32362) -- Burning Hatred
	:AddBuff(45053) -- Disdain
	:AddBuff(42084) -- Fury of the Crashing Waves
	:AddBuff(45401) -- Righteousness
	:AddBuff(35081) -- Band of the Eternal Champion
	:AddBuff(43716) -- Call of the Berserker
	:AddBuff(45040) -- Battle Trance
	:AddBuff(35476) -- Drums of Battle
	:AddBuff(35475) -- Drums of War
	:AddBuff(28093) -- Lightning Speed
	:AddBuff(20007) -- Holy Strength
	:AddBuff(57330) -- Horn of Winter (DK raid buff)
	:AddBuff(60305) -- Heart of a Dragon
	:AddBuff(60065) -- Reflection of Torment (mirror of thruth procc)
	:AddBuff(60054) -- Valor Medal of the First War 
	:AddBuff(60218) -- Essence of Gossamer 
	:AddBuff(65014) -- Pyrite Infuser
	:AddBuff(60437) -- Grim Toll
	:AddBuff(59620) -- Berserk, Enchant Weapon - Berserking
	:AddBuff(60286) -- Defender's Code
	:AddBuff(60258) -- Rune of Repulsion
	:AddBuff(60314) -- Fury of the Five Flights
	:AddBuff(50263) -- Quickness of the Sailor
	:AddBuff(64800) -- Wrathstone
	:AddBuff(64792) -- Blood of the Old God
	:AddBuff(53908) -- Speed (potion)
	:AddBuff(28494) -- Insane Strength Potion
	:AddBuff(60229) -- Greatness, str
	:AddBuff(60233) -- Greatness, agi	
	:AddBuff(54758) -- Hyperspeed Acceleration
	:AddBuff(50198) -- Fatal Flaws
	:AddBuff(72414) -- Frostforged Defender
	:AddBuff(72412) -- Frostforged Champion
	:AddBuff(59626) -- Black Magic
	:AddBuff(71485) -- Agility of the Vrykul
	--:AddBuff(71487) -- Precision of the Iron Dwarves
	:AddBuff(71484) -- Strength of the Taunka
	:AddBuff(71491) -- Aim of the Iron Dwarves
	:AddBuff(71486) -- Power of the Taunka
	:AddBuff(71492) -- Speed of the Vrykul
	:AddBuff(67683) -- Celerity, Shard of the Crystal Heart
	:AddBuff(67708) -- Paragon
	:AddBuff(67671) -- Fury
	:AddBuff(53762) -- Indestructible (potion)
	:AddBuff(75456) -- Piercing Twilight
	:AddBuff(75480) -- Scaly Nimbleness
	
	:AddBuff(79633) -- Tol'vir Agility
	:AddBuff(79476) -- Volcanic Power
	:AddBuff(79475) -- Earthen Armor
	:AddBuff(79634) -- Golem's Strength
	:AddBuff(92104) -- Fluid Death, River of Death
	
	:AddBuff(92096) -- Left Eye of Rajh, Eye of Vengeance 
	:AddBuff(92069) -- Key to the Endless Chamber, Final Key
	:AddBuff(92126) -- Essence of the Cyclone, Twisted 
	:AddBuff(92108) -- Unheeded Warning, Heedless Carnage 
	:AddBuff(92124) -- Prestor's Talisman of Machination, Nefarious Plot 
	:AddBuff(92052) -- Grace of the Herald, Herald of Doom
	:AddBuff(91821) -- Crushing Weight, Race Against Death
	:AddBuff(91816) -- Heart of Rage, Rageheart
	:AddBuff(125489) -- Enchant Cloak - Swordguard Embroidery
	
	:AddBuff(85032) -- Vicious Gladiator's Insignia of Victory, Surge of Victory
	
	:AddBuff(92213) -- Vial of Stolen Memories, Memory of Invincibility
	:AddBuff(96977) -- Matrix Restabilizer, Matrix Restabilized
	:AddBuff(96911) -- The Hungerer, Devour
	:AddBuff(49016) -- Unholy Frenzy (DK raid buff)
	:AddBuff(96923) -- Titanic Power
	
	
	-- IMPORTANT DEBUFFS FROM OTHERS I WANT TO TRACK
	-- Death Knight
	:AddDebuff(81326) -- Physical Vulnerability
	:AddDebuff(73975) -- Necrotic Strike
		
	--warrior
 	:AddDebuff(113746) -- Weakened Armor
	:AddDebuff(115804) -- Mortal Wounds

	--shaman
	:AddBuff(30809) -- Unleashed Rage
	
	--paladin
	
	--druid
	:AddDebuff(  770) -- Faerie Fire
	:AddDebuff(102355) -- Faerie Swarm
	:AddDebuff(33878) -- Mangle - Bear
	:AddDebuff(33876) -- Mangle - Cat
	
	:AddDebuff(115798) -- Weakened Blows
	
	--rogue
	:AddDebuff(60842) -- Expose Armor

	return self;
end


function ST:AddCasterBuffs()
	self:AddBuff(32182) -- Heroism
	:AddBuff(80353) -- Time Warp
	:AddBuff(2825) -- Bloodlust
	:AddBuff(28779) -- Essence of Sapphiron
	:AddBuff(23271) -- Ephemeral Power
	:AddBuff(44605) -- Spell Haste
	:AddBuff(24659) -- Unstable Power
	:AddBuff(35163) -- Blessing of the Silver Crescent
	:AddBuff(34747) -- Recurring Power
	:AddBuff(34321) -- Call of the Nexus
	:AddBuff(32108) -- Lesser Spell Blasting
	:AddBuff(25907) -- Spell Blasting
	:AddBuff(38348) -- Unstable Currents
	:AddBuff(35337) -- Spell Power
	:AddBuff(40396) -- Fel Infusion
	:AddBuff(33662)	-- Arcane Energy
	:AddBuff(39441) -- Aura of the Crusader
	:AddBuff(35084) -- Band of the Eternal Sage
	:AddBuff(43712) -- Mojo Madness
	:AddBuff(39530) -- Focus
	:AddBuff(46783) -- Crimson Serpent
	:AddBuff(48846) -- Runic Infusion
	:AddBuff(60064) -- Now is the time!
	:AddBuff(60492) -- Embrace of the Spider
	:AddBuff(60479) -- Forge Ember
	:AddBuff(60494) -- Dying Curse
	--:AddBuff(47236) -- Demonic Pact
	:AddBuff(60486) -- Illustration of the Dragon Soul
	:AddBuff(60062) -- The Egg of Mortal Essence
	:AddBuff(65006) -- Eye of the Broodmother
	:AddBuff(64707) -- Scale of Fates
	:AddBuff(64712) -- Living Flame
	--:AddBuff(77746) -- Totemic Wrath +spell dmg
	:AddBuff(60234) -- Greatness, int
	:AddBuff(60235) -- Greatness, spi
	:AddBuff(64411) -- Blessing of Ancient Kings
	:AddBuff(53909) -- Wild Magic
	:AddBuff(53908) -- Speed (potion)
	:AddBuff(67669) -- Elusive Power
	:AddBuff(54758) -- Hyperspeed Acceleration
	:AddBuff(125487) -- Lightweave
	:AddBuff(72416) -- Frostforged Sage
	:AddBuff(72418) -- Item - Icecrown Reputation Ring Healer Effect
	:AddBuff(71572) -- Cultivated Power
	:AddBuff(71601) -- Surge of Power
	--:AddBuff(71600) -- Surging Power
	:AddBuff(71564) -- Deadly Precision
	:AddBuff(59626) -- Black Magic
	:AddBuff(67683) -- Celerity, Shard of the Crystal Heart
	:AddBuff(67750) -- Energized
	:AddBuff(71584) -- Revitalized
	:AddBuff(71605) -- Siphoned Power
	:AddBuff(75473) -- Twilight Flames
	:AddBuff(75494) -- Twilight Renewal
	:AddBuff(64741) -- Pandora's Plea
	
	:AddBuff(91138) -- Tear of Blood, Cleansing Tears
	:AddBuff(91147) -- Blood of Isiset, Blessing of Isiset
	:AddBuff(91047) -- Stump of Time, Battle Magic
	:AddBuff(89091) -- Darkmoon Card: Volcano, Volcanic Destruction
	:AddBuff(91027) -- Heart of Ignacious, Heart's Revelation
	:AddBuff(91041) -- Heart of Ignacious, Heart's Judgement
	:AddBuff(74241) -- Enchant Weapon - Power Torrent
	:AddBuff(91024) -- Theralion's Mirror, Revelation
	
	:AddBuff(91007) -- Bell of Enraging Resonance, Dire Magic
	
	:AddBuff(91192) -- Mandala of Stirring Patterns, Pattern of Light
	:AddBuff(90887) -- Witching Hourglass, Witching Hour
	:AddBuff(91184) -- Fall of Mortality, Grounded Soul
	:AddBuff(100403) -- Moonwell Chalice, Blessing of the Moonwell
	:AddBuff(107982) -- Seal of the Seven Signs/Insignia of the Corrupted Mind, Velocity
	:AddBuff(107804) -- Ti'tahk, the Steps of Time, Slowing the Sands
	
	:AddBuff(107970) -- Will of Unbinding, Combat Mind
	
	:AddBuff(109908) -- Foul Gift (immolate), Foul Gift of the Demon Lord
	:AddBuff(102662) -- Foul Gift (procc), Foul Gift of the Demon Lord
	
	:AddBuff(96962) -- Soul Fragment, Necromantic Focus
	
	:AddBuff(109773) -- Dark Intent	(Warlock raid buff)
	
	-- IMPORTANT DEBUFFS FROM OTHERS I WANT TO TRACK
	:AddDebuff(26017) -- Vindication, Retribution Debuff -10/20% stats on target
	
	:AddDebuff(51339) -- Decimate +5% dmg

	--:AddDebuff(33196) -- Misery
	:AddDebuff( 1490) -- Curse of the Elements (most 'stable')
	--:AddDebuff(85547) -- Jinx: Curse of the Elements
	--:AddDebuff(65142) -- Ebon Plague
	--:AddDebuff(60433) -- Earth and Moon
	
	--:AddDebuff(17800) -- Shadow and Flame +5% crit all schools	
	--:AddDebuff(22959) -- Improved Scorch, +5% crit all schools
	--:AddDebuff(12579) -- Winter's Chill, +1% crit all schools per stack (5max)
	return self;
end

-- Race specific spell and buffs
if FW.RACE == "Draenei" then
	--ST:SetDefaultHasted(1);
	ST:AddSpell(59548,15,"Heal",F.HOT);
elseif FW.RACE == "Orc" then
	ST:AddBuff(33702);
elseif FW.RACE == "Tauren" then
	ST:AddSpell(20549, 2,"Crowd",F.NOTARGET);
elseif FW.RACE == "Blood  Elf" then
	ST:AddSpell(25046, 2,"Crowd",F.NOTARGET);
elseif FW.RACE == "Troll" then
	ST:AddBuff(26297);
elseif FW.RACE == "Dwarf" then
	ST:AddBuff(20594);
end
ST:AddBuff(55503); -- Lifeblood
ST:AddBuff(7001); -- Lightwell Renew
	
-- create options
FW:SetMainCategory(FWL.SPELL_TIMER,FW.ICON.ST,3,"TIMER",nil,"Timer",tab_actions)
	
	:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
		:AddOption("INF",FWL.ST_HINT1)
		:AddOption("INF",FWL.ST_HINT2)
		:AddOption("INF",FWL.ST_HINT3)
		
	:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND)
		:AddOption("CHK",FWL.ENABLE,			FWL.ST_BASIC1_TT ,			"Enable"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.EXPAND_UP,			FWL.EXPAND_UP_TT,			"Expand"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.TIMER_OUTWARDS,	FWL.TIMER_OUTWARDS_TT,		"Outwands")
		:AddOption("CHK",FWL.FLIP_BAR,			FWL.FLIP_BAR_TT,			"Flip"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.TEST_BARS,			FWL.TEST_BARS_TT,			"Test"):SetFunc(Test)
		:AddOption("CHK",FWL.TIMER_HIDE,		FWL.TIMER_HIDE_TT,			"Hide")
	
	:SetSubCategory(FWL.TIMER_FORMATS,FW.ICON.SPECIFIC,3)
		:AddOption("NU2",FWL.EXTRA1,			FWL.EXTRA1_TT,				"RaidTargets"):SetRange(0,1):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.TIMER_COUNTDOWN,	FWL.TIMER_COUNTDOWN_TT,		"Time"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.COUNTDOWN_ON_RIGHT,FWL.COUNTDOWN_ON_RIGHT_TT,	"TimeRight"):SetFunc(ST_TimerShow):SetEnabled("Time")

		:AddOption("CHK",FWL.TIMER_ICONS,		FWL.TIMER_ICONS_TT,			"Icon"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.TIMER_ICONS_RIGHT,	FWL.TIMER_ICONS_RIGHT_TT,	"IconRight"):SetFunc(ST_TimerShow):SetEnabled("Icon")

		:AddOption("CHK",FWL.TIMER_STACKS,		FWL.TIMER_STACKS_TT,		"IconStacks"):SetFunc(ST_TimerShow):SetEnabled("Icon")
		:AddOption("FNT",FWL.ICON_FONT,			"",							"StacksFont",99):SetFunc(ST_TimerShow):SetEnabled(function(obj) return obj.s.Icon and obj.s.IconStacks; end)

	:SetSubCategory(FWL.NAMING_GROUPING,FW.ICON.SPECIFIC,3)
		:AddOption("CHK",FWL.DISPLAY_MODES7,	FWL.DISPLAY_MODES7_TT,	"GroupID")
		:AddOption("CHK",FWL.DISPLAY_MODES10,	FWL.DISPLAY_MODES10_TT,	"Label"):SetEnabled("GroupID")
		:AddOption("CHK",FWL.FLIP_TAG,			FWL.FLIP_TAG_TT,		"LabelFlip"):SetFunc(ST_TimerShow):SetEnabled(function(obj) return obj.s.GroupID and obj.s.Label; end)
		:AddOption("CHK",FWL.LABEL_LIMIT,		FWL.LABEL_LIMIT_TT,		"LabelLimit"):SetFunc(ST_TimerShow):SetEnabled(function(obj) return obj.s.GroupID and obj.s.Label; end)
		:AddOption("CHK",FWL.TIMER_BAR_LABELS,	FWL.TIMER_BAR_LABELS_TT,"Name"):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.DISPLAY_MODES9,	FWL.DISPLAY_MODES9_TT,	"Spell"):SetEnabled("Name")
		:AddOption("MSG",FWL.CUSTOM_TAG,		FWL.CUSTOM_TAG_TT,		"CustomTag"):SetEnabled("Name")
		:AddOption("CHK",FWL.DISPLAY_MODES8,	FWL.DISPLAY_MODES8_TT,	"ShowID"):SetEnabled("Name")

	:SetSubCategory(FWL.SPARKS_AND_GLOW,FW.ICON.GLOW,3)
		:AddOption("NU2",FWL.SHOW_SPARK,	FWL.TIMER_SPARK_TT..FWL._EDITBOX_TRANSPARENCY,		"Spark"):SetRange(0,1):SetFunc(ST_TimerShow)
		:AddOption("NU2",FWL.SPARK_TICK,	FWL.SPARK_TICK_TT,									"SparkDamage"):SetRange(1,2):SetFunc(ST_TimerShow):SetEnabled("Spark")
		:AddOption("NU2",FWL.CAST_GLOW,		FWL.CAST_GLOW_TT..FWL._EDITBOX_TRANSPARENCY,		"CastSpark"):SetRange(0,1):SetFunc(ST_TimerShow)
		:AddOption("CHK",FWL.CAST_OVERLAP,	FWL.CAST_OVERLAP_TT,								"CastSparkTickOverlap"):SetEnabled("CastSpark")
		:AddOption("CHK",FWL.CAST_GCD,		FWL.CAST_GCD_TT,									"CastSparkGCD"):SetEnabled("CastSpark")
		:AddOption("")
		:AddOption("NU2",FWL.TICKS,			FWL.TICKS_TT..FWL._EDITBOX_TRANSPARENCY,			"Ticks"):SetFunc(ST_HideTicks):SetRange(0,1)
		:AddOption("CHK",FWL.TICKS_NEXT,	FWL.TICKS_NEXT_TT,									"TicksNext"):SetFunc(ST_HideTicks):SetEnabled("Ticks")

	:SetSubCategory(FWL.TIMER_MAXIMUM_TIME,FW.ICON.TIME,3)
		:AddOption("CHK",FWL.ONEMAX,		FWL.ONEMAX_TT,			"OneMax")
		:AddOption("NU2",FWL.MAXTIME,		FWL.MAXTIME_TT,			"MaxTime"):SetRange(0)
		:AddOption("CHK",FWL.FORCEMAX,		FWL.FORCEMAX_TT,		"ForceMax"):SetEnabled("MaxTime")
		:AddOption("NU2",FWL.DISPLAY_TYPES3,FWL.DISPLAY_TYPES3_TT,	"HideLonger"):SetRange(0)
		:AddOption("CHK",FWL.DISPLAY_TYPES11,FWL.DISPLAY_TYPES11_TT,"HideLongerNoBoss"):SetEnabled("HideLonger")
		:AddOption("NUM",FWL.DISPLAY_TYPES4,FWL.DISPLAY_TYPES4_TT,	"HideTime"):SetRange(0):SetEnabled("HideLonger")
	
	:SetSubCategory(FWL.FADING,FW.ICON.FADE,3)
		:AddOption("NUM",FWL.FADING3,		FWL.FADING3_TT,			"FadeTime"):SetRange(0,120):SetFunc(ST_CalculateMaxDelay)
		:AddOption("NUM",FWL.DISPLAY_TYPES6,FWL.DISPLAY_TYPES6_TT,	"FailTime"):SetRange(0,120):SetFunc(ST_CalculateMaxDelay)
		:AddOption("NU2",FWL.FADING1,		FWL.FADING1_TT,			"Blink"):SetRange(0)
		:AddOption("NUM",FWL.BAR_BG_ALPHA,	FWL.BAR_BG_ALPHA_TT,	"BarBackgroundAlpha"):SetRange(0,1)	
		:AddOption("CO2",FWL.EXPIRED,		FWL.EXPIRED_TT,			"ExpiredColor")
		:AddOption("CO2",FWL.HIGHLIGHT,		FWL.FADING5_TT,			"HighlightColor")

	:SetSubCategory(FWL.TIMER_UNITS,FW.ICON.UNITS,6)
		:AddOption("CHK",FWL.TIMER_RAID_DEBUFFS,FWL.TIMER_RAID_DEBUFFS_TT,	"RaidDebuffs"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.TIMER_SHOW_TARGET,	FWL.TIMER_SHOW_TARGET_TT,	"Target"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.TIMER_SHOW_FOCUS,	FWL.TIMER_SHOW_FOCUS_TT,	"Focus"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.TIMER_SHOW_OTHER,	FWL.TIMER_SHOW_OTHER_TT,	"Other"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.TIMER_SHOW_UKNOWN,	FWL.TIMER_SHOW_UKNOWN_TT,	"UnknownTarget"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.SHOW_WITHOUT_UNIT,	FWL.SHOW_WITHOUT_UNIT_TT,	"NoTarget"):SetFunc(ST_TimerFilterChange)
		:AddOption("CHK",FWL.TIMER_SHOW_YOU,	FWL.TIMER_SHOW_YOU_TT,		"You"):SetFunc(ST_TimerFilterChange)
		:AddOption("NUM",FWL.FADING6,			FWL.FADING6_TT,				"NormalAlpha"):SetRange(0.1,1):SetFunc(ST_TimerFilterChange)
		
	:SetSubCategory(FWL.COLORING_FILTERING,FW.ICON.FILTER,7)
		:AddOption("FIL",FWL.CUSTOMIZE,		FWL.ST_CUSTOMIZE_TT,	"Filter",99):SetRange(FW.FilterListOptions, FW.STFilterListOptions):SetFunc(ST_TimerFilterChange)
		
	:SetSubCategory(FWL.MY_SPELLS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA)
		:AddOption("CO2",FWL.NORMAL_TYPE,	FWL.NORMAL_TYPE_TT,		"Default"):SetFunc(ST_TimerFilterChange):SetSpellList(Track,6)
		:AddOption("CO2",FWL.CC,			FWL.CC_TT,				"Crowd",99):SetFunc(ST_TimerFilterChange):SetSpellList(Track,6)
		:AddOption("CO2",FWL.HEAL,			FWL.DISPLAY_TYPES8_TT,	"Heal",99):SetFunc(ST_TimerFilterChange):SetSpellList(Track,6)
		:AddOption("CO2",FWL.FRIENDLY_BUFFS,FWL.DISPLAY_TYPES9_TT,	"Buff",99):SetFunc(ST_TimerFilterChange):SetSpellList(Track,6)
		:AddOption("CO2",FWL.CHANNEL,		FWL.CHANNEL_TT,			"Channel",99):SetFunc(ST_TimerFilterChange):SetSpellList(Drain,3)
		:AddOption("CO2",FWL.PET,			FWL.DISPLAY_TYPES10_TT,	"Pet",99):SetFunc(ST_TimerFilterChange):SetSpellList(Track,6)
		:AddOption("CO2",FWL.FAIL,			FWL.DISPLAY_TYPES5_TT,	"Fail",99):SetFunc(ST_TimerFilterChange)
	
	:SetSubCategory(FWL.MY_COOLDOWNS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA)
		:AddOption("CO2",FWL.COOLDOWNS,		FWL.COOLDOWNS_TT,		"Cooldown"):SetFunc(ST_TimerFilterChange):SetSpellList(TrackCooldowns,3)
		:AddOption("CO2",FWL.ALL_OTHER_COOLDOWNS,	"",				"CooldownOther"):SetFunc(ST_TimerFilterChange):SetEnabled(false)
		
	:SetSubCategory(FWL.BUFFS_DEBUFFS_ON_ME,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA)	
		:AddOption("CO2",FWL.POWERUP_BUFFS,	FWL.DISPLAY_TYPES1_TT,	"SelfBuff"):SetFunc(ST_TimerFilterChange):SetSpellList(TrackBuffs)
		:AddOption("CO2",FWL.ALL_OTHER_BUFFS,"",					"SelfBuffOther"):SetFunc(ST_TimerFilterChange):SetEnabled(false)
		:AddOption("CO2",FWL.DEBUFFS,		FWL.DEBUFFS_TT,			"SelfDebuff"):SetFunc(ST_TimerFilterChange):SetSpellList(TrackSelfDebuffs)
		:AddOption("CO2",FWL.ALL_OTHER_DEBUFFS,		"",				"SelfDebuffOther"):SetFunc(ST_TimerFilterChange):SetEnabled(false)
		:AddOption("CO2",FWL.WEAPON_ENCHANT,		"",				"Enchant"):SetFunc(ST_TimerFilterChange)

	:SetSubCategory(FWL.RAID_DEBUFFS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA)
		:AddOption("CO2",FWL.OTHER_DEBUFFS,	FWL.OTHER_DEBUFFS_TT,	"TargetDebuff"):SetFunc(ST_TimerFilterChange):SetSpellList(TrackDebuffs)
		:AddOption("CO2",FWL.ALL_OTHER_DEBUFFS,			"",			"TargetDebuffOther"):SetFunc(ST_TimerFilterChange):SetEnabled(false)

	:SetSubCategory(FWL.SIZING,FW.ICON.SIZE,8)	
		:AddOption("NUM",FWL.BAR_WIDTH,					"",					"Width"):SetRange(0):SetFunc(ST_TimerShow)
		:AddOption("NUM",FWL.BAR_HEIGHT,				"",					"Height"):SetRange(0):SetFunc(ST_TimerShow)
		:AddOption("NUM",FWL.BAR_SPACING,				"",					"Space"):SetRange(0):SetFunc(ST_TimerShow)
		:AddOption("NUM",FWL.UNIT_SPACING,		FWL.UNIT_SPACING_TT,		"SpacingHeight"):SetRange(0)
		:AddOption("NUM",FWL.UNIT_LABEL_HEIGHT,	FWL.UNIT_LABEL_HEIGHT_TT,	"LabelHeight"):SetRange(0)
		--:AddOption("CHK",FWL.MAXIMIZE_SPACE,	FWL.MAXIMIZE_SPACE_TT,		"MaximizeName"):SetFunc(ST_TimerShow)
		:AddOption("NU2",FWL.MAX_SHOWN,					"",					"Max"):SetRange(0)

	:SetSubCategory(FWL.APPEARANCE,FW.ICON.APPEARANCE,9)	
		:AddOption("COL",FWL.NORMAL_TEXT,	FWL.NORMAL_TEXT_TT,	"NormalColor"):SetFunc(ST_TimerShow)
		:AddOption("COL",FWL.FRAME_BACKGROUND,	"",				"NormalBgColor"):SetFunc(ST_TimerShow)
		:AddOption("CO2",FWL.TARGET_TEXT,	FWL.TARGET_TEXT_TT,	"TargetColor")
		:AddOption("CO2",FWL.FOCUS_TEXT,	FWL.FOCUS_TEXT_TT,	"FocusColor")		
		:AddOption("CO2",FWL.TARGET_BACKGROUND,"",				"TargetBgColor"):SetFunc(ST_TimerShow)
		:AddOption("CO2",FWL.FOCUS_BACKGROUND,	"",				"FocusBgColor"):SetFunc(ST_TimerShow)
		:AddOption("FNT",FWL.BAR_FONT,			"",				"Font",99):SetFunc(ST_TimerShow)
		:AddOption("FNT",FWL.LABEL_FONT,	FWL.LABEL_FONT_TT,	"LabelFont",99):SetFunc(ST_TimerShow)
		:AddOption("TXT",FWL.BAR_TEXTURE,		"",				"Texture",99):SetFunc(ST_TimerShow)
		:AddOption("BAC",FWL.BACKDROP,			"",				"Backdrop",99):SetFunc(ST_TimerShow)
		
-- non-intance-specific options
:SetMainCategory(FWL.RAID_MESSAGES)
	:SetSubCategory(FWL.FADING,FW.ICON.SPECIFIC,2)
		:AddOption("INF",FWL.TIME_LEFT_HINT)
		:AddOption("MS2",FWL.TIME_LEFT,	"",	"TimeLeft")
		:AddOption("MS2",FWL.TIME_LEFT_NOTARGET,"",	"TimeLeftNoTarg")
	
:SetMainCategory(FWL.SELF_MESSAGES)
	:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2)
		:AddOption("CO2",FWL.SHOW_FAILED,	FWL.SHOW_FAILED_TT,"TimerResistsColor")

:SetMainCategory(FWL.SOUND)
	:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2)
		:AddOption("SND",FWL.FADE,"","TimerFadeSound")
		:AddOption("SND",FWL.BREAK,"","TimerBreakSound")
		:AddOption("SND",FWL.RESIST,"","TimerResistSound")
		
:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT")
	:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,3)
		:AddOption("STR",FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"TimerStrata"):SetFunc(ST_TimerShow)
		:AddOption("NUM",FWL.TIMER_SMOOTHING,FWL.TIMER_SMOOTHING_TT,"TimerSmooth"):SetRange(1,20)
		:AddOption("NU2",FWL.SMART_COUNTDOWN_WIDTH,FWL.SMART_COUNTDOWN_WIDTH_TT,"TimerSmartSpace"):SetRange(1,60)
		:AddOption("STR",FWL.TIMER_SORT_ORDER,	FWL.TIMER_SORT_ORDER_TT,	"TimerSortOrder"):SetSpan(2):SetFunc(ST_CreateSortOrder)
		:AddOption("NUM",FWL.UPDATE_INTERVAL_SPELL_TIMER,"",	"SpellTimerInterval"):SetRange(0.1,1.0)
		:AddOption("NUM",FWL.DELAY_DOT_TICKS,			"",	"DotTicksDelayNew"):SetRange(0.5,3.0)
		:AddOption("NUM",FWL.FADING4,	FWL.FADING4_TT,	"TimerFadeSpeed"):SetRange(0.0,1.0):SetFunc(ST_CalculateMaxDelay)
		:AddOption("CHK",FWL.EXTRA3,	FWL.EXTRA3_TT,	"TimerImprove"):SetFunc(ST_RegisterImproved)
		:AddOption("CHK",FWL.EXTRA4,	FWL.EXTRA4_TT,	"TimerImproveRaidTarget")
		:AddOption("CHK",FWL.EXTRA6,	FWL.EXTRA6_TT,	"RemoveAfterCombat")
		:AddOption("CO2","Type color override","",		"TimerColorOverride")

-- following are used globally
FW.Default.TimerFadeSpeed = 0.5;
FW.Default.SpellTimerInterval = 0.20;
FW.Default.DotTicksDelayNew = 1.5; -- max 1.5 sec lag
FW.Default.TimerSmooth = 5;
FW.Default.TimerStrata = FW.Default.Strata;
FW.Default.TimerResistsColor = 	{[0]=true,1.00,0.00,0.54};

FW.Default.TimerFadeSound = 		{[0]=true,"Sound\\Spells\\ShaysBell.wav",2};
FW.Default.TimerBreakSound = 		{[0]=true,"Sound\\Spells\\SimonGame_Visual_LevelStart.wav",4};
FW.Default.TimerResistSound = 		{[0]=true,"Sound\\Spells\\SimonGame_Visual_BadPress.wav",1};
FW.Default.TimerInstantSound = 		{[0]=false,"Sound\\Spells\\ShadowWard.wav",4};
FW.Default.TimerClearcastingSound = {[0]=false,"Sound\\Spells\\SimonGame_Visual_GameStart.wav",4};

FW.Default.RemoveAfterCombat = false;
FW.Default.TimerImprove = false;
FW.Default.TimerImproveRaidTarget = false;
FW.Default.TimerSortOrder = "buff selfdebuff debuff cooldown notarget target";

FW.Default.TimerSmartSpace = {[0]=true,30};
FW.Default.TimerColorOverride = {[0]=false,0.24,0.24,0.24};

--following settings are stored for each instance of a spell timer
FW.InstanceDefault.Timer = {
	Test = false,
	Enable = true,
	Max = {[0]=false,15},
	Font = FW.Default.Font,
	Texture = FW.Default.Texture,
	ShowID = false,
	GroupID = true,
	IgnoreLong = false,
	Expand = true,
	Background = true,

	Time = true,
	TimeRight = false,
	Icon = true,
	IconRight = false,
	Name = true,

	IconStacks = true,
	Hide = false,
	Flip = false,
	Outwands = true,

	Blink = {[0]=true,3},
	MaximizeName = false,
	HideTime = 2,
	FailTime = 2,
	FadeTime = 1,
	Spell = false,
	Label = false,
	LabelFlip = false,
	LabelLimit = false,
	LabelHeight = 18,
	SpacingHeight = 2, -- between groups
	LabelFont = FW.Default.Font,
	StacksFont = {FW.Default.Font[1],FW.Default.Font[2]-1,"OUTLINE"},
	RaidTargets = {[0]=false,0.7},
	Target = true,
	Focus = true,
	Other = true,
	NoTarget = true,
	UnknownTarget = true,
	You = true,
	RaidDebuffs = true,

	OneMax = true,
	MaxTime = {[0]=true,30},
	ForceMax = false,
	HideLonger = {[0]=false,30},
	HideLongerNoBoss = false,

	Height = 14,
	Space = 2, -- between units
	Width = 250,
	NormalAlpha = 0.50,
	BarBackgroundAlpha = 0.3,

	Filter = {},

	ExpiredColor = 		{[0]=false,0.50,0.50,0.50,1.00},
	HighlightColor =	{[0]=true,1.00,1.00,1.00},
	
	Channel = 			{[0]=true,0.42,0.00,1.00},
	Fail =				{[0]=true,1.00,0.00,0.30},
	
	Curse = 			{[0]=true,0.64,0.21,0.93},
	Bane = 				{[0]=true,0.00,0.54,0.42},

	Crowd = 			{[0]=true,0.00,1.00,0.50},
	Default = 			{[0]=true,1.00,0.50,0.00},
	Pet = 				{[0]=true,1.00,0.00,0.95},
	Heal = 				{[0]=true,0.00,1.00,0.00},
	Buff = 				{[0]=true,1.00,1.00,0.00},
	Enchant = 			{[0]=true,1.00,1.00,1.00},

	SelfBuff = 			{[0]=true,0.00,0.75,1.00},
	SelfBuffOther = 	{[0]=false,0.50,0.50,0.50},
	TargetDebuff = 		{[0]=true,0.00,0.36,1.00},
	TargetDebuffOther =	{[0]=false,0.00,0.18,0.50},
	Cooldown =			{[0]=true,1.00,0.39,0.35},
	CooldownOther =		{[0]=false,0.50,0.20,0.18},
	SelfDebuff =		{[0]=true,1.00,0.00,0.00},
	SelfDebuffOther =	{[0]=false,0.50,0.00,0.00},

	NormalColor = 		{1.00,1.00,1.00,1.00},
	NormalBgColor =		{0.00,0.00,0.00,0.50},
	TargetColor = 		{[0]=false,1.00,1.00,1.00,1.00},
	FocusColor = 		{[0]=false,1.00,1.00,0.50,1.00},
	TargetBgColor =		{[0]=false,0.00,0.00,0.00,1.00},
	FocusBgColor = 		{[0]=false,1.00,1.00,0.50,1.00},

	Ticks = {[0]=true,0.3},
	TicksNext = true,

	CastSpark = {[0]=true,0.3},
	CastSparkTickOverlap = true,
	CastSparkGCD = true,
	Spark = {[0]=true,0.7},
	SparkDamage = {[0]=true,1.5},

	CustomTag = {[0]=false,"id target :: spell stacks"},

	Backdrop = {
		"Interface\\AddOns\\Forte_Core\\Textures\\Background",
		"Interface\\AddOns\\Forte_Core\\Textures\\Border",
		false,16,5,3
	},
};