--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local FW = FW;
local FWL = FW.L;
local CA = FW:Module("Casting",1);
local ST; -- access to spell timer module (after loaded vars)
local CD; -- access to cooldown timer module (after loaded vars)
local GetTime = GetTime;
local strfind = strfind;
local unpack = unpack;
local pairs = pairs;
local ipairs = ipairs;
local strsplit = strsplit;
local UnitName = FW.FullUnitName;
local strformat = string.format;
local erase = FW.ERASE;
local UnitAura = UnitAura;
local SendAddonMessage = SendAddonMessage;

local LastCast = 0;

--local OtherQueue = FW:NEW2D();
local FW_OnSelfCastSuccess = {};
local FW_OnSelfCastCancel = {};
local FW_OnSelfCastStart = {};
local FW_OnSelfCastEnd = {};
local FW_OnSelfCastDelay = {};
local FW_OnSelfChannelStart = {};
local FW_OnSelfChannelUpdate = {};

local FW_OnSelfCastFail = {};
local FW_OnSelfCastTracked = {};

local FW_OnPetCastSuccess = {};
local FW_OnPetCastFailed = {};
local FW_OnPetCastStart = {};

local CA_IsChannel = {}; -- keys in here are marked as special channeling spells

local CA_SelfQueue = FW:NEW2D();
local STATES = FW.STATES;

-- used in casting, warlock, summon
--[[FW.SU_CAST_START = "SuS";
FW.SU_CAST_CANCEL = "SuC";
FW.SU_CAST_END = "SuE";
]]

local CA_SpellHaste = 0.1; -- just an 'impossible' starting value
local TrackGCD = {};

CA.GlobalCooldown = 1.5;

function CA:SetGCDStance(requires_stace, new_gcd)
	TrackGCD[requires_stace] = new_gcd;
end
local hastebuffs = {
	["ALL"] = {
		[FW:SpellName(32182)] = 1.30, -- heroism
		[FW:SpellName(2825)] = 1.30, -- bloodlust
		[FW:SpellName(80353)] = 1.30, -- Time warp
		--[FW:SpellName(68933)] = 2.00, -- wrath of air totem
		[FW:SpellName(49868)] = 1.05, -- Mind Quikening
		[FW:SpellName(10060)] = 1.20, -- power infusion
		[FW:SpellName(63277)] = 2.00, -- shadow crash
	},
	["PRIEST"] = {
		[FW:SpellName(59889)] = 1.15, -- Borrowed Time
	},
	["WARLOCK"] = {
		
	},
	["DRUID"] = {
		[FW:SpellName(16886)] = 1.15, -- Nature's Grace
	},
	["SHAMAN"] = {
		[FW:SpellName(16166)] = 1.20, -- Elemental Mastery
	},
	["Troll"] = {
		[FW:SpellName(26297)] = 1.20, -- berserking
	},
	-- Improved Moonkin Form, Swift Retribution
}
-- also register the talents for 'relevant talent' function !!!!
--FW.Talent[FW:SpellName(15259)] = 0; -- Darkness
local hastetalents = {
	--[[["PRIEST"] = {
		[FW:SpellName(15259)] = {1.01,1.02,1.03}, -- Darkness
	},]]
}

local function CA_AddSpecialHasteBuffs(group,haste)
	if hastebuffs[group] then
		for k, v in pairs(hastebuffs[group]) do
			if UnitAura("player",k) then -- WATCH OUT WITH CUSTOM NAMES, THIS WON'T WORK IF THE ORIGINAL UNITAURA ISNT USED
				haste = haste * v;
			end
		end
	end
	return haste;
end

local function CA_AddSpecialHasteTalents(group,haste)
	if hastetalents[group] then
		for k, v in pairs(hastetalents[group]) do
			if FW.Talent[k] > 0 then
				haste = haste * v[  FW.Talent[k] ];
			end
		end
	end
	return haste;
end

local function CA_AddSpecialHaste(haste)
	-- special haste increasing buffs per race or class
	haste = CA_AddSpecialHasteBuffs("ALL",haste);
	haste = CA_AddSpecialHasteBuffs(FW.CLASS,haste);
	haste = CA_AddSpecialHasteBuffs(FW.RACE,haste);
	-- special haste increasing talents
	haste = CA_AddSpecialHasteTalents("ALL",haste);
	haste = CA_AddSpecialHasteTalents(FW.CLASS,haste);
	haste = CA_AddSpecialHasteTalents(FW.RACE,haste);
	return haste;
end

local function CA_CheckCastSpeed()
	--FW:Show("checking cast speed");
	for key, val in pairs(FW.SpellInfo) do
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(val[1])
		if castTime then
			FW.SpellInfo[key][2] = castTime*0.001;
			FW.SpellInfo[key][3] = minRange;
			FW.SpellInfo[key][4] = maxRange;
		end
	end
	if ST then
		for i=1, ST.ST.rows, 1 do
			ST.ST[i][2] = FW:CastTime(ST.ST[i][8]); -- should be used if the function gets more compelx
		end
	end
end

local function CA_CheckGlobalCooldown()
	local gcd = (TrackGCD[FW.Stance] or 1.5)*CA_SpellHaste;
	if gcd < 1.0 then
		gcd = 1.0;
	end
	CA.GlobalCooldown = gcd;
end

local function CA_StatsUpdate2()
	--[[local haste = CA_AddSpecialHaste( 1.0 + GetCombatRatingBonus(20)*0.01 ); 
	-- some things that increase casting speed, but not actual haste
	local newhaste = 1.0/haste;
	if CA_SpellHaste ~= newhaste then -- doesn't work
		CA_SpellHaste = newhaste;
		CA_CheckCastSpeed();
	end]]
	CA_SpellHaste = 1.0/CA_AddSpecialHaste( 1.0 + GetCombatRatingBonus(20)*0.01 );
	CA_CheckCastSpeed();
	CA_CheckGlobalCooldown();
end

local function CA_StatsUpdate()
	CA_StatsUpdate2();
	FW:DelayedExec(0.1,5,CA_StatsUpdate2);
end

-- I still can't use combat-only code because I'm lacking target info in the cast start event and a success event is lacking for non-instant casts :(

function CA:RegisterIsChannel(spell) -- only for making sure that channels being cast have the right target assigned
	CA_IsChannel[FW:SpellName(spell)] = 1;
end

function CA:Unique(unit)
	if not unit then return 0;end
	local name = UnitName(unit);
	if FW.Saved.Exceptions[name] then
		return FW.Saved.Exceptions[name];
	end
	
	if UnitPlayerControlled(unit) then
		return 2; -- unique player / pet
	elseif UnitClassification(unit) == "rareelite" or UnitClassification(unit) == "worldboss" then
		return 1; -- unique boss
	else
		return 0; -- not unique
	end
end

local validOn = {};

local function CA_ValidOn(target,unitid) -- narrow this down as much as possible (i'm asuming that i cannot cast on dead units unless they are playercontrolled)
	--FW:Debug("validOn "..unitid);
	if target == UnitName(unitid) and (not UnitIsDead(unitid) or UnitPlayerControlled(unitid)) then
		--FW:Debug("yes");
		tinsert(validOn,unitid);
	end
end
local tokens;
local function CA_UpdateTokens()
	tokens = {strsplit(" ",FW.Settings.UseTokens)};
end
local function CA_CastOn(target)
	local t,f = 0,0;
	erase(validOn);
	CA_ValidOn(target,"target");
	CA_ValidOn(target,FW:NameToID(target) or ""); -- convert a party/raid member name to party/raid token
	--only missing party/raid pets casts by using macros, but i think we can live with that
	for i,v in ipairs(tokens) do
		CA_ValidOn(target,v);
	end
	if #validOn > 0 then
		for i=1, #validOn, 1 do -- yes, starting at 1! i suck ;)
			if not UnitIsUnit(validOn[1],validOn[i]) then -- if they are not all the same i cannot be certain
				return "";
			end
		end
	else
		return "";
	end
	return validOn[1];
end

---------------------------------------------------------------------------
-- SelfQueue 13: GUID "" for uncertain, "none" for none
-- SelfQueue 12: raid target icon
-- SelfQueue 11: UniqueID# (for sorting)
-- SelfQueue 10: NOT USED
-- SelfQueue 9: Renamed spell name
-- SelfQueue 8: Target Type (0:trash 1:boss 2:player)
-- SelfQueue 7: Spell Rank
-- SelfQueue 6: Full spell name
-- SelfQueue 5: Target name

-- SelfQueue 4: Success/Cancel (or whatever) Time (including check delay)
-- SelfQueue 3: Time of cast completion (from event) non-zero means casting spell
-- SelfQueue 2: 0 currently casting, 1 'successfully' casted, -1 maybe cancelled

-- SelfQueue 1: Original Spell Name

local origend;
local function CA_SelfChannelUpdate(spell)
	-- *** new drain code ***
	if ST and ST.Drain[spell] --[[and not FW.Settings.TimerTest]] then 
		local i = ST.ST:find(spell,8);
		if i then
			local spellName, _, _, _, startTime, endTime = UnitChannelInfo("player");
			if endTime then -- silly bug
			endTime = endTime*0.001;
			startTime = startTime*0.001;
			
			if origend > endTime then -- interrupt fix
				endTime = origend - math.ceil((origend - endTime)/ST.Tick[spellName])*ST.Tick[spellName];
			else
				origend = endTime;
			end
			ST.ST[i][1] = endTime; 
			ST.ST[i][3] = endTime-startTime;
			end
		end
	end
	for i,f in ipairs(FW_OnSelfChannelUpdate) do
		f(spell);
	end
end

local function CA_SelfChannelStart(spell)
	--FW:Debug("Channel Start");
	local spellName, _, _, texture, startTime, endTime = UnitChannelInfo("player");
	
	if not CA_IsChannel[spellName] then -- if marked as special channel it's already taken care off
		local target = UnitName("target"); -- simple target
		startTime = startTime*0.001;
		endTime = endTime*0.001;
		local realduration = endTime-startTime;
		origend = endTime;
		-- *** new drain code ***
		if ST and ST.Drain[spellName] then
			
			local i = CA_SelfQueue:find(spellName,1);
			if i then
				ST.ST:remove(ST.ST:find(ST.DRAIN,6,spellName,8));
				local t = GetTime();
				--FW:Debug("|cff00ff00"..t.." start:"..startTime..","..endTime..":"..realduration);
				local tar = CA_SelfQueue[i][5];
				local targettype = CA_SelfQueue[i][8];
				local id = CA_SelfQueue[i][11];
				local icon = CA_SelfQueue[i][12];
				local guid = CA_SelfQueue[i][13];
				if ST.Drain[spellName][1] ~= 1 then
					tar = spellName;
					targettype = 0;
					id = ST.PRIOR_NONE;
					icon = 0;
					guid = "none";
				end
				ST.Tick[spellName] = CA_SpellHaste * ST.Drain[spellName][2];
				ST.ST:insert(endTime,FW:CastTime(spell),realduration,tar,0,ST.DRAIN,texture,spellName,targettype,0,guid,0,id,0,1,0,0,00000,icon,endTime,"Channel",1.0,0,0,0,0,"",0);
			end
		end
		-- *** end new drain code ***
		if target then
			CA_SelfQueue:insert( spellName.." (C)",0,endTime,0,target,realduration,"",0,0,0,0,0,UnitGUID("target"),1.0);
			for i,f in ipairs(FW_OnSelfChannelStart) do
				f(spellName,target);
			end
		end
	end
end

local function CA_SelfStart(spell)
	--FW:Debug("Spell Start");
	local i = CA_SelfQueue:find2(spell,1,0,3);
	if i then
		CA_SelfQueue[i][3] = select(6,UnitCastingInfo("player"));
		-----------------------------------------------------------
		for i,f in ipairs(FW_OnSelfCastStart) do
			f(spell,CA_SelfQueue[i][5]);
		end
		-----------------------------------------------------------
	end
end

local function CA_SelfRemove(n)
	--FW:Debug("Cancelling spell");
	local spell,_,t3,_,target = unpack(CA_SelfQueue[n]);
	if t3~= 0 then
		-----------------------------------------------------------
		for i,f in ipairs(FW_OnSelfCastCancel) do
			f(spell,target);
		end
		-----------------------------------------------------------
	end
	CA_SelfQueue:remove(n); 
end

--0 currently casting, 1 'successfully' casted, -1 maybe cancelled
local function CA_SelfCancel(spell)
	--FW:Debug("Cancelling spell");
	local i = CA_SelfQueue:find2(spell,1,0,2);-- not awaiting resist check, and not already cancelled
	if i then
		CA_SelfQueue[i][2] = -1;
		CA_SelfQueue[i][4] = GetTime() + FW.Settings.CancelDelay;
	end
end
--[["ABSORB" 
"BLOCK" 
"DEFLECT" 
"DODGE" 
"EVADE" 
"IMMUNE" 
"MISS" 
"PARRY" 
"REFLECT" 
"RESIST" ]]
local CA_CombatEventToMiss = {
	--caster
	["RESIST"] = 4,
	["IMMUNE"] = 5,
	["EVADE"] = 6,
	["REFLECT"] = 7,
	--melee
	["PARRY"] = 4,
	["DODGE" ] = 4,
	["MISS" ] = 4,
	["BLOCK"] = 4,
	["DEFLECT"] = 7
};

local function CA_SelfResist(...)
	local name = select(13,...);
	local i=1;
	while i <= CA_SelfQueue.rows do
		local spell,state,_,_,target,_,_,typ,s,_,id,icon,guid = unpack(CA_SelfQueue[i]);
		if state == 1 then
			local t;
			if spell == name then -- right spell name ofc
				t = CA_CombatEventToMiss[select(15,...)];
			end
			if t then
				for n, f in ipairs(FW_OnSelfCastFail) do
					f(s,t,target,typ,id,icon,guid,...);-- s is spell name as it would appear on the timer
				end
				CA_SelfQueue:remove(i);
				break;
			end
		end
		i=i+1;
	end
end

local function CA_SelfDelay(spell)
	--FW:Debug("Spell delay");
	local endTime = select(6,UnitCastingInfo("player"));
	if endTime then
		local i = CA_SelfQueue:find2(spell,1,0,2);
		if i then
			
			-----------------------------------------------------------
			for n, f in ipairs(FW_OnSelfCastDelay) do
				f( spell, endTime - CA_SelfQueue[i][3] );
			end
			-----------------------------------------------------------
			CA_SelfQueue[i][3] = endTime;
		end
	end
end

function CA:HasteFactor(s) -- spell
	-- duration adjustments
	if ST and ST.Track[s] then
		-- always hasted
		if ST.Hasted[s] and ST.Hasted[s] > 0 then
			return CA_SpellHaste;
		-- hasted duration with stance
		elseif ST.Track[s]["hs"] then
			if ST.Track[s]["hs"][FW.Stance] then
				return CA_SpellHaste;
			end
		elseif ST.Track[s]["hg"] then -- hasted duration with glyph
			for k, v in pairs(ST.Track[s]["hg"]) do
				if FW.Glyph[k] and FW.Glyph[k] > 0 then
					return CA_SpellHaste;
				end
			end
		end
	end
	return 1;
end

function CA:Duration(s,p,u) -- RETURNS DURATION UNAFFECTED BY HASTE spell, combopoints, unit type (2=players)
	local dura = 0;
	-- duration adjustments
	if ST and ST.Track[s] then
		dura = ST.Track[s][2];
		-- change based on talents
		if ST.Track[s]["t"] then
			for k, v in pairs(ST.Track[s]["t"]) do
				if v[FW.Talent[k]] then
					dura = dura + v[FW.Talent[k]];
				end
			end
		end
		-- change based on setbonus
		if ST.Track[s]["s"] then
			for k, v in pairs(ST.Track[s]["s"]) do
				for n, a in pairs(v) do
					if FW.SetBonus[k] >= n then
						dura = dura + a;
					end
				end
			end
		end
		-- change based on combopoints
		if ST.Track[s]["c"] and p then
			dura = dura + (ST.Track[s]["c"][p] or 0);
		end
		-- change based on glyphs
		if ST.Track[s]["g"] then
			for k, v in pairs(ST.Track[s]["g"]) do
				if FW.Glyph[k] and FW.Glyph[k] > 0 then
					dura = dura + v;
				end
			end
		end

		-- % change based on talents removed
		
		-- set max duration in pvp
		if u == 2 then 
			local pvp = ST.DurationPVP[s];
			if pvp and dura>pvp then
				dura=pvp;
			end
		end
	end
	return dura;
end

local function CA_SelfSucces(delay,n)
	local spell,_,_,_,target,realduration,rank,targettype,s,p,id,icon,guid,haste = unpack(CA_SelfQueue[n]);
	--CA_SelfQueue:print();
	-- realduration is now adjusted duration!
	if ST and ST.Track[s] then
		for i,f in ipairs(FW_OnSelfCastTracked) do
			f(spell,target,realduration,rank,targettype,s,p,id,icon,guid,delay,haste);
		end
	end
	--FW:Debug(spell.." cast successfull on "..target);
	-----------------------------------------------------------
	for i,f in ipairs(FW_OnSelfCastSuccess) do
		f(spell,target,rank,icon)
	end
	-----------------------------------------------------------
	-- makes it skip the remove if it has a return value, used in channeling spells
	if CA_IsChannel[spell] then
		CA_SelfQueue[n][1] = spell.." (C)"; -- rename to channeling
		CA_SelfQueue[n][2] = 0; -- 
		CA_SelfQueue[n][4] = 0; -- set this spell to not finished again
	else
		CA_SelfQueue:remove(n);
	end
end

--local summonchannel = FW:SpellName(46546).." (C)";

local function CA_SelfEnd(arg2)
	--FW:Debug("Ending spell");
	local i=1;
	while i <= CA_SelfQueue.rows do
		local spell = CA_SelfQueue[i][1];
		
		if CA_SelfQueue[i][4]~=1 and (not arg2 or spell==arg2) then
			local s = CA_SelfQueue[i][9];
			if ST and ST.Track[s] and ST.Track[s][1] == 0 then
				CA_SelfQueue[i][2] = 1;
				CA_SelfQueue[i][4] = GetTime() + FW.Settings.Delay;
				
			-- put weird exceptions below!
			--[[elseif spell == summonchannel then
				CA_SelfQueue[i][2] = 1;
				CA_SelfQueue[i][4] = GetTime() + 1; -- 1 sec delay on checking if shard is used]]
			else
				CA_SelfSucces(0,i); -- ignore possible resists
			end

			break;
		else
			i=i+1;
		end
	end		
	for i,f in ipairs(FW_OnSelfCastEnd) do
		f(arg2); -- spell
	end
end

--[[function FW:SelfChannelUpdate(remain)
	FW:Debug("Channelling Update "..remain);
end]]

local function CA_SelfChannelEnd(spell)
	--FW:Debug("Channelling End");
	-- problem: when you start casting a new spell while still channeling a spell, channel end may fire after the new spell sent event, making it 'complete' the new cast instantly
	-- solution: a spell already channeling, will always be queued at slot [1], so if this isnt a channeling spell ignore this event!

	-- *** new drain code ***
	if ST and ST.Drain[spell] then 
		local i = ST.ST:find(spell,8);
		if i then
			ST:Fade(i,1);
			--FW:Debug("|cffff0000"..GetTime().." end");
		end
	end
	-- *** end new drain code ***
	
	if CA_SelfQueue.rows > 0 and strfind(CA_SelfQueue[1][1]," %(C%)$") then CA_SelfEnd();end
end

local function CA_SelfSent(spell,rank,target)
	local s = (ST and ST.SpellRemap[spell]) or spell;
	--FW:Debug("Spell Sent");
	LastCast = GetTime();
	CA_SelfChannelEnd();
	local i = CA_SelfQueue.rows;
	while i>0 do
		if CA_SelfQueue[i][2] == 0 and CA_SelfQueue[i][3] == 0 then -- replace 'garbage sent events'
			CA_SelfQueue:remove(i);
			--FW:Debug("remove garbage sent");
		end
		i=i-1;
	end
	local u,id,r,guid,p = CA:CastTargetInfo(target);
	--FW:Debug(spell.." on: "..guid);
	--rank = tonumber(select(3,strfind(rank,"(%d+)")) or 1);
	rank=1; --  remove rank completely plx
	CA_SelfQueue:insert(spell,0,0,0,target,CA:Duration(s,p,u),rank,u,s,p,id,r,guid,1); -- last (haste) unused now!!
	--CA_SelfQueue:print();
end

-- target debuffs scan is now delayed just as much as the cast success (due to resist checking)
-- this should make the cast success trigger before any debuffs are added 

local function CA_TimedSpellSuccess()
	local i=1;
	local t = GetTime();
	while i <= CA_SelfQueue.rows do
		local state,t4 = CA_SelfQueue[i][2],CA_SelfQueue[i][4];
		if t4 > 0 and t4 < t then
			if state == 1 then
				--FW:Show(t-t4);
				CA_SelfSucces(t-t4+FW.Settings.Delay,i); 
			elseif state == -1 then
				CA_SelfRemove(i);
			end
		else
			i=i+1;
		end
	end
end

local function CA_TimedClearCastBuffer()
	if UnitCastingInfo("player") or UnitChannelInfo("player") then -- if not casting or channelling for 2 sec, remove everything from cast queue to avoid bugs
		LastCast = GetTime();
	elseif LastCast ~= 0 and GetTime() - LastCast >= 3 then
		--FW:Debug("CLEARING BUFFER "..CA_SelfQueue.rows);
		
		CA_SelfQueue:erase();
		
		LastCast = 0;
	end
end
---------------------------------------------------------------------------
-- globally accessable
---------------------------------------------------------------------------

-- used for messaging mostly
function CA:RegisterOnSelfCastEnd(func)
	tinsert(FW_OnSelfCastEnd,func);
end

function CA:RegisterOnSelfCastSuccess(func)
	tinsert(FW_OnSelfCastSuccess,func);
end

function CA:RegisterOnSelfCastTracked(func)
	tinsert(FW_OnSelfCastTracked,func);
end

function CA:RegisterOnSelfCastStart(func)
	tinsert(FW_OnSelfCastStart,func);
end

function CA:RegisterOnSelfCastDelay(func)
	tinsert(FW_OnSelfCastDelay,func);
end

function CA:RegisterOnSelfCastCancel(func)
	tinsert(FW_OnSelfCastCancel,func);
end

function CA:RegisterOnSelfCastFail(func)
	tinsert(FW_OnSelfCastFail,func);
end

function CA:RegisterOnSelfChannelStart(func)
	tinsert(FW_OnSelfChannelStart,func);
end
function CA:RegisterOnSelfChannelUpdate(func)
	tinsert(FW_OnSelfChannelUpdate,func);
end

-- pet cast
function CA:RegisterOnPetCastSuccess(func)
	tinsert(FW_OnPetCastSuccess,func);
end

function CA:RegisterOnPetCastFailed(func)
	tinsert(FW_OnPetCastFailed,func);
end

function CA:RegisterOnPetCastStart(func)
	tinsert(FW_OnPetCastStart,func);
end
---------------------------------------------------------------------------
-- SOMETHING GOES WRONG WITH ID ASSIGNMENT (WITH AOE)
function CA:GiveID(guid)
	local high,id = 0,0;
	if ST then
		for i=1,ST.ST.rows,1 do
			id = ST.ST[i][13];
			if id > 0 and id < 100 then
				if high < id then high = id; end
				if ST.ST[i][11] == guid then
					return id;
				end
			end
		end
	end
	for i=1,CA_SelfQueue.rows,1 do
		id = CA_SelfQueue[i][11];
		if id > 0 and id < 100 then
			if high < id then high = id;end
			if CA_SelfQueue[i][13] == guid then
				return id;
			end
		end
	end
	return high+1;
end

function CA:CastTargetInfo(target)
	local unit = CA_CastOn(target);
	if unit ~= "" then
		local id = UnitGUID(unit);
		return CA:Unique(unit),CA:GiveID(id),GetRaidTargetIndex(unit) or 0,id,GetComboPoints("player",unit);
	else
		return 0,(ST and ST.PRIOR_NONE) or 0,0,"",0; -- uncertain about target, will use debuff check to get guid
	end
end

function CA:CastShow(key,target)
	if bit.band(1,FW.Settings[key][0]) ~= 0 then
		FW:ToGroup(strformat(FW:FixStringFormat(FW.Settings[key][1]),target or "")); 
	end
	if bit.band(2,FW.Settings[key][0]) ~= 0 then
		FW:ToChannel(strformat(FW:FixStringFormat(FW.Settings[key][1]),target or ""));
	end
	if FW.Settings[key.."Whisper"] and FW.Settings[key.."Whisper"][0] and target~=FW.PLAYER then
		FW:Whisper( FW.Settings[key.."Whisper"][1],target or "");
	end
end

local ORA3_COOLDOWN = FW.ORA3_COOLDOWN;
local function CA_VariablesLoaded()
	ST = FW:Module("Timer");
	CD = FW:Module("Cooldown");
	
	FW:RegisterToEvent("UNIT_SPELLCAST_INTERRUPTED",
	function(event,arg1,arg2)
		--FW:Show(event.." arg1 "..arg1);
		if arg1 == "player" then
			CA_SelfCancel(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_FAILED",
	function(event,arg1,arg2)
		if arg1 == "player" then
			CA_SelfCancel(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_DELAYED",
	function(event,arg1,arg2) 
		if arg1 == "player" then
			CA_SelfDelay(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_SENT",
	function(event,arg1,arg2,arg3,arg4)
		if arg1 == "player" then
			CA_SelfSent(arg2,arg3,arg4);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_START",		
	function(event,arg1,arg2) 
		if arg1 == "player" then 
			CA_SelfStart(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_SUCCEEDED",
	function(event,arg1,arg2)
		if arg1 == "player" then
			CA_SelfEnd(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_CHANNEL_START",
	function(event,arg1,arg2)
		if arg1 == "player" then
			CA_SelfChannelStart(arg2);
		end
	end);
	FW:RegisterToEvent("UNIT_SPELLCAST_CHANNEL_STOP",
	function(event,arg1,arg2)
		if arg1 == "player" then
			CA_SelfChannelEnd(arg2);
		end
	end);

	FW:RegisterToEvent("UNIT_SPELLCAST_CHANNEL_UPDATE",
	function(event,arg1,arg2)
		if arg1 == "player" then
			CA_SelfChannelUpdate(arg2);
		end
	end);

	FW:RegisterToEvent("PLAYER_LEAVING_WORLD",	function() CA_SelfQueue:erase();end);
	FW:RegisterToEvent("PLAYER_DEAD",			function() CA_SelfQueue:erase();end);
	FW:RegisterToEvent("UNIT_AURA",function(event,arg1)
		if arg1=="player" then
			FW:RegisterThrottle(CA_StatsUpdate);
		end
	end);

	FW:RegisterToEvent("COMBAT_RATING_UPDATE",CA_StatsUpdate);
	--FW:RegisterTimedEvent("UpdateInterval",CA_StatsUpdate); -- backup check
	
	FW:RegisterTimedEvent("UpdateInterval",CA_TimedClearCastBuffer);
	-- also check if you actually get cast success events from party/raid members now!!!
	--[[if not _G["oRA3"] and not CD then -- using ora3 or cooldown module over this
		if FW.CLASS == "SHAMAN" then
			local reinc = FW:SpellName(FW.FLAG.SHAMAN);
			CA:RegisterOnSelfCastSuccess(function(s,t)
				if s == reinc and STATES.GROUPED then
					local impreinc = FW:SpellName(16209);
					local dur = 1800;
					for tab=1,GetNumSpecializations(),1 do
						for i=1,GetNumTalents(tab),1 do
							local name, _, _, _, rank = GetTalentInfo(tab, i,nil,nil,GetActiveSpecGroup());
							if name == impreinc then
								dur = dur - rank*450;
								break;
							end
						end
					end
					SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.SHAMAN,dur),"RAID");
				end
			end)
		elseif FW.CLASS == "PALADIN" then
			local di = FW:SpellName(FW.FLAG.PALADIN);
			CA:RegisterOnSelfCastSuccess(function(s,t)
				if s == di and STATES.GROUPED then
					SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.PALADIN,600),"RAID");
				end
			end)
		elseif FW.CLASS == "DRUID" then
			local rebirth = FW:SpellName(FW.FLAG.DRUID);
			CA:RegisterOnSelfCastSuccess(function(s,t)
				if s == rebirth and STATES.GROUPED then
					SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.DRUID,600),"RAID");
				end
			end)
		end
	end]]
		
	do
		local PLAYER = FW.PLAYER;
		local FW = FW;
		local select = select;
		
		local function CA_CombatLogEvent(event,...)
			if select(5,...) == PLAYER then
				if select(2,...) == "SPELL_MISSED" then
					CA_SelfResist(...);
				end
			elseif select(4,...) == FW.pet then
				--FW:Show("moo");
				local arg2 = select(2,...);
				if arg2 == "SPELL_MISSED" then
					for i,f in ipairs(FW_OnPetCastFailed) do
						f(select(13,...));
					end
				elseif arg2 == "SPELL_CAST_FAILED" then
					for i,f in ipairs(FW_OnPetCastFailed) do
						f(select(13,...));
					end
				elseif arg2 == "SPELL_CAST_START" then
					for i,f in ipairs(FW_OnPetCastStart) do
						f(select(13,...));
					end
				elseif arg2 == "SPELL_CAST_SUCCESS" then
					for i,f in ipairs(FW_OnPetCastSuccess) do
						f(select(13,...));
						--FW:Show(select(9,...));
					end
				end
			end
		end
		FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	CA_CombatLogEvent);
	end

end

FW:RegisterUpdatedEvent(CA_TimedSpellSuccess);
FW:RegisterVariablesEvent(CA_VariablesLoaded);
FW:RegisterVariablesEvent(CA_StatsUpdate);
FW:RegisterVariablesEvent(CA_UpdateTokens);

FW:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT");
	FW:SetSubCategory(FWL.CASTING,FW.ICON.DEFAULT,2);
		FW:AddOption("NUM",FWL.DELAY_MAX_FAIL,		"","Delay"):SetRange(0.01,1);
		FW:AddOption("NUM",FWL.DELAY_MAX_FASTCAST,	"","CancelDelay"):SetRange(0.1,1);
		FW:AddOption("STR","Additional unit tokens","In addition to target and party/raid tokens use only these for casting. Fewer tokens means it's more likely the FX will find the correct target you have casted on instantly. If you remove any tokens make sure that you really won't use those (in macros for example). Using tokens that are not listed here means that FX may not be able to figure out what unit is cast on right away, so be careful.","UseTokens"):SetSpan(2):SetFunc(CA_UpdateTokens);
		
FW.Default.Delay = 0.05; -- maximum delay between cast success event and evade/resist/immune event (seems to be system lag only)
FW.Default.CancelDelay = 0.5; -- maximum delay between a possible fastcast macro generated fail and the actual success (server lag)
FW.Default.DisableFocus = false;
FW.Default.DisableMouseover = false;

FW.Default.MeetingStoneSummon = {[0]=0,"Summoning >> %s << Clicky clicky!"};
FW.Default.UseTokens = "pet pettarget vehicle focus mouseover";