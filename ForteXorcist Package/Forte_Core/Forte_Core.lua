--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

--## X-Curse-Packaged-Version: r9\r\n## X-Curse-Project-Name: ForteXorcist\r\n## X-Curse-Project-ID: fortexorcist\r\n## X-Curse-Repository-ID: wow/fortexorcist/mainline

FW = {}; -- core table
local FW = FW;

FC_Saved = {}; -- old save table
local FC_Saved;
FX_Saved = {}; -- new save table
local FX_Saved;
FW.InstanceDefault = {};
local FW_Debug = false;

FW.TITLE = "ForteXorcist";
local VERSION = "v"..GetAddOnMetadata("Forte_Core", "Version");
FW.VERSION = VERSION;
local ENABLE = false;

local STATES = {};
FW.STATES = STATES;
STATES.GROUPED = false;
STATES.RAID = false;
STATES.INCOMBAT = false;

FW.L = {}; -- locale table
local FWL = FW.L;

FW.Frames = {};
FW.ICON = {};
FW.REDUCED_ALPHA = 0.33;
FW.EXPAND = 1;
--[[
special ability events:
SPELL_ACTIVATION_OVERLAY_SHOW #1:17941 #2:TEXTURES\SPELLACTIVATIONOVERLAYS\NIGHTFALL.BLP #3:Left + Right (Flipped) #4:1 #5:255 #6:255 #7:255
SPELL_ACTIVATION_OVERLAY_GLOW_SHOW #1:686

COMBAT_TEXT_UPDATE #1:SPELL_CAST #2:Shadow Trance
]]

FW.DIS_COL = "|cff999999"; -- colour to use for disabled options

local Frames = FW.Frames;
local Commands = {};

--local FW_Loaded = {};
local FW_DelayedLoaded = {};
local FW_VariablesLoaded = {};
local FW_Messages = {};
local FW_oRAMessages = {};
local FW_EnterPartyRaid = {};
local FW_OnEnterCombat = {};
local FW_OnLeaveCombat = {};

local FilterRefresh = {};

local strfind = strfind;
local strformat = string.format;
local ipairs = ipairs;
local pairs = pairs;
local unpack = unpack;
local select = select;
local GetTime = GetTime;
local type = type;
local _G = _G;

local GetNumGroupMembers = GetNumGroupMembers;

do
	local RAID = {};
	for i=1,40,1 do tinsert(RAID,"raid"..i);end
	local PARTY = {};
	for i=1,4,1 do tinsert(PARTY,"party"..i);end
	
	function FW:ForGroupMembers(func,...)
		local ret;
		if IsInRaid() then
			for i=1,GetNumGroupMembers(),1 do
				ret = func(RAID[i],...);
				if ret then return ret; end
			end		
		else
			if IsInGroup() then
				for i=1,GetNumGroupMembers()-1,1 do -- player can't be identified by partyN, but full party count IS 5 members...
					ret = func(PARTY[i],...);
					if ret then return ret; end
				end
			end
			ret = func("player",...);
			if ret then return ret; end	
		end
	end
end

do
	local origUnitName = UnitName;
	FW.FullUnitName = function(token)
		local name, realm = origUnitName(token);
		if realm and realm~="" then
			return name.."-"..realm;
		else
			return name;
		end
	end
end
local UnitName = FW.FullUnitName;
local UnitClass = UnitClass;

----------------------------------------------------------------------------------------------------------------------------
--------- STUFF TO MINIMIZE TABLE MEMORY GARBAGE SINCE I LIKE TO USE '2D' TABLES A LOT -------------------------------------
----------------------------------------------------------------------------------------------------------------------------

do
	local function FW_BSTR(t,i,j,c,asc,a)
		local val1 = t[j-1][ c[a] ];
		local val2 = t[j][ c[a] ];
		
		if val1 == val2 then
			if c[a+1] then		
				FW_BSTR(t,i,j,c,asc,a+1);
			end
		elseif asc[a] == (val1 > val2) then
			t[j-1],t[j] = t[j],t[j-1];
		end
	end

	local function FW_BST(t,c,asc) -- sorts my '2d table', using 'column - ascending' table pairs
		local i = 1;
		local j;
		while i <= t.rows do
			j = t.rows;
			while i<j do
				FW_BSTR(t,i,j,c,asc,1);
				j=j-1;
			end
			i=i+1;
		end
	end

	local function FW_INS(t,...) -- insert new row, must be the same number of columns (for sort to work properly)!!
		t.rows = t.rows + 1;
		if t[t.rows] then
			for i=1,select('#',...),1 do
				t[t.rows][i] = select(i,...);
			end
		else
			tinsert(t,{...});
		end
	end

	local function FW_REM(t,row) -- remove row
		if row and row <= t.rows then
			t.rows=t.rows-1;
			for r=row,t.rows,1 do
				t[r],t[r+1] = t[r+1],t[r];
			end
		end
	end

	local function FW_ERASE2(t) -- erases my 2d tables ONLY
		t.rows = 0; -- lol :p
	end
	
	local function FW_FIND(t,v,c) -- find value v in '2d table' t at column c, returns ROW
		for r=1,t.rows,1 do
			if t[r][c]==v then
				return r;
			end
		end
	end

	local function FW_FIND2(t,v1,c1,v2,c2) -- returns ROW
		for r=1,t.rows,1 do
			if t[r][c1]==v1 and t[r][c2]==v2 then
				return r;
			end
		end
	end

	local function FW_FIND3(t,v1,c1,v2,c2,v3,c3) -- returns ROW
		for r=1,t.rows,1 do
			if t[r][c1]==v1 and t[r][c2]==v2 and t[r][c3]==v3 then
				return r;
			end
		end
	end

	local function FW_SETKEY(t,k,...) -- Set a row with 'key', MUST have the same num columns!
		local n = FW_FIND(t,k,1);
		if n then
			for i=1,select('#',...),1 do
				t[n][i+1] = select(i,...);
			end
		else
			FW_INS(t,k,...);
		end
	end

	local function FW_P(t)
		local str;
		for r=1,t.rows,1 do
			str = r..":";
			for c=1,#t[r],1 do
				str = str.." ["..c.."]"..tostring(t[r][c]);
			end
			FW:Show(str);
		end
	end

	function FW:NEW2D() -- CURRENTLY ONLY SUPPORTS A STATIC NUMBER OF COLUMNS (for one 2d table) TO INCREASE PERFORMANCE!!
		local t = {};
		t.rows = 0;
		t.erase = FW_ERASE2;
		t.remove = FW_REM;
		t.insert = FW_INS;
		t.find = FW_FIND;
		t.find2 = FW_FIND2;
		t.find3 = FW_FIND3;
		t.sort = FW_BST;
		t.setkey = FW_SETKEY;
		t.print = FW_P;
		return t;
	end
end

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
local LastRess;
local LeaveCombat;

local function FW_EnterCombat()
	--FW:Debug("enter combat");
	for i,f in ipairs(FW_OnEnterCombat) do
		f();
	end
	STATES.INCOMBAT = true;
end
local function FW_LeaveCombat()
	--FW:Debug("leave combat");
	STATES.INCOMBAT = false;
	for i,f in ipairs(FW_OnLeaveCombat) do
		f();
	end
end

local function FW_Ress()
	if not UnitIsDeadOrGhost("player") and not LastRess then
		LastRess = GetTime()+5; -- wait 5 seconds with checking combat
	end
end

local InCombatLockdown = InCombatLockdown;
local function FC_ExtraCombatCheck()
	if not InCombatLockdown() then FW_LeaveCombat(); end
end

do -- update frame related stuff uses locals with the smallest scope possible
	local FC_UpdateFrame = CreateFrame("Frame");
	local FW_Events = {};
	local FW_Updated = {};
	local FC_DelayedExecQueue = FW:NEW2D();
	local GetTime = GetTime;
	
	function FW:RegisterToEvent(event,func)
		if not FW_Events[event] then
			FC_UpdateFrame:RegisterEvent(event);
			FW_Events[event] = {};
		end
		for i,f in ipairs(FW_Events[event]) do
			if f == func then
				return;
			end
		end
		tinsert(FW_Events[event],func);
	end
	function FW:UnregisterToEvent(event,func)
		if not FW_Events[event] then return; end
		for i,f in ipairs(FW_Events[event]) do
			if f == func then
				tremove(FW_Events[event],i);
				if #FW_Events[event]==0 then
					FW_Events[event] = nil;
					FC_UpdateFrame:UnregisterEvent(event);
				end
				return;
			end
		end
	end
	function FW:RegisterUpdatedEvent(func)
		tinsert(FW_Updated,func);
	end

	function FW:UnregisterUpdatedEvent(func)
		for i,f in ipairs(FW_Updated) do
			if f == func then
				tremove(FW_Updated,i);
				return;
			end
		end
	end

	function FW:DelayedExec(delay,times,func,...)
		FC_DelayedExecQueue:insert(GetTime()+delay,delay,times,func,...);
	end
	local function FC_OnEvent(self,event,...)
		--[[if strfind(event,"COMBAT_LOG") then
			if strfind(select(2,...),"SPELL") then
				local d = GetTime().." "..event;
				for i=1,select('#',...),1 do
					if select(i,...) ~= nil then d = d.." #"..i..":"..tostring(select(i,...)); end
				end
				FW:Show(d,0,1,1);
			end
		end]]
		
		--if FW_Events[event] then -- check can be removed in theory... IF NOT ALL EVENTS ARE REGISTERED
		for k,v in ipairs(FW_Events[event]) do
			v(event,...);
		end
		--end
	end
	local FW_Timed = {};
	
	function FW:RegisterTimedEvent(interval,func)
		if type(interval) == "string" then
			if type(FW.Settings[interval]) == "table" then
				interval = FW.Settings[interval][1];
			else
				if FW.Settings[interval] then
					interval = FW.Settings[interval];
				else
					FW:Show("error adding interval: "..interval);
				end
			end
		end
		if not FW_Timed[interval] then
			FW_Timed[interval] = {[0]=0};
		end
		tinsert(FW_Timed[interval],func);
	end

	function FW:UnregisterTimedEvent(interval,func)
		if type(interval) == "string" then
			if type(FW.Settings[interval]) == "table" then
				interval = FW.Settings[interval][1];
			else
				if FW.Settings[interval] then
					interval = FW.Settings[interval];
				else
					FW:Show("error removing interval: "..interval);
				end
			end
		end
		if FW_Timed[interval] then
			for i,f in ipairs(FW_Timed[interval]) do
				if f == func then
					tremove(FW_Timed[interval],i);
					return;
				end
			end
		end
	end
	
	local function FC_OnUpdate(self, elapsed) -- normal onupdate
		if LastRess and LastRess <= GetTime() then -- delays combat checking when you're ressed, so in case of a combat res or ss use your timers wont be cleared instantly
			FC_ExtraCombatCheck();
			LastRess = nil;
		end
		if LeaveCombat then -- this is only used when zoning, to make sure buttons arent still locked when FW_LeaveCombat is called
			FC_ExtraCombatCheck();
			LeaveCombat = nil;
		end
		-- run the timed events
		for key, val in pairs(FW_Timed) do
			FW_Timed[key][0] = FW_Timed[key][0] + elapsed;
			if FW_Timed[key][0] >= key then
				FW_Timed[key][0] = FW_Timed[key][0]%key;
				for k, v in ipairs(FW_Timed[key]) do
					v();
				end
			end
		end
		for i, f in ipairs(FW_Updated) do
			f(elapsed);
		end
		-- delayed exec code
		local t = GetTime();
		local i = 1;
		while i <= FC_DelayedExecQueue.rows do
			if FC_DelayedExecQueue[i][1] <= t then
				FC_DelayedExecQueue[i][4](unpack(FC_DelayedExecQueue[i],5));
				if FC_DelayedExecQueue[i][3] > 1 then
					FC_DelayedExecQueue[i][3]=FC_DelayedExecQueue[i][3]-1;
					FC_DelayedExecQueue[i][1] = FC_DelayedExecQueue[i][1] + FC_DelayedExecQueue[i][2];
				 else
					for k in ipairs(FC_DelayedExecQueue[i]) do -- erase all data so i can use any argument count
						FC_DelayedExecQueue[i][k] = nil;
					end
					FC_DelayedExecQueue:remove(i);
				end
			else
				i=i+1;
			end
		end
	end
	local UILoaded;
	local function FC_OnPreUpdate(self, elapsed) -- pre onupdate
		if UILoaded then -- enable update actions 2 sec after UI is fully loaded
			if GetTime() >= UILoaded then
				FC_UpdateFrame:SetScript("OnUpdate", FC_OnUpdate); -- start doing stuff when the addon is fully enabled!
				for i, f in ipairs(FW_DelayedLoaded) do
					f();
				end
			end
		elseif FW.Settings and FW.Settings.LoadDelay then
			UILoaded = GetTime() + FW.Settings.LoadDelay;
		end	
	end
	FC_UpdateFrame:SetScript("OnEvent", FC_OnEvent);
	FC_UpdateFrame:SetScript("OnUpdate", FC_OnPreUpdate);
	--FC_UpdateFrame:RegisterAllEvents(); -- for debugging only
	function FW:UnregisterAllEvents()
		FC_UpdateFrame:UnregisterAllEvents();
	end
end

do
	local type = type;
	local origUnitAura = UnitAura;
	local CustomIDToName = {};
	local CustomNameToID = {};
	FW.UnitAura = function(unit,buff,r,filter) -- works exactly like the original, but takes custom names into account
		if type(buff) == "string" then
			local id = CustomNameToID[buff];
			if id then
				local i = 1;
				while true do
					local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = origUnitAura(unit,i,filter);
					if name then
						if id == spellId then
							return buff, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3;
						end
						i=i+1;
					else
						return nil;
					end
				end
			else
				return origUnitAura(unit,buff,r,filter);
			end
		else
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = origUnitAura(unit,buff,r,filter);
			return CustomIDToName[spellId] or name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3;
		end
	end
	function FW:SetCustomName(id,name)
		CustomIDToName[id] = name;
		CustomNameToID[name] = id;
	end
	local GetSpellInfo = GetSpellInfo;
	function FW:SpellName(spell)
		local s,_,t = GetSpellInfo(spell);
		s = CustomIDToName[spell] or s;
		if s then
			if not FW.SpellInfo[s] then
				FW.SpellInfo[s] = {spell,0,0,0};
			end
			return s,t;
		else
			--FW:Show("spell:"..spell);
			return "spell:"..spell;
		end
	end
end

FW.Sets = {};

FW.BORDER = 3;
--FW.pet,target,focus is also non-nil (guid) when present
FW.PLAYER = UnitName("player");
FW.CLASS = select(2,UnitClass("player"));
FW.SERVER = GetRealmName();
FW.RACE = select(2,UnitRace("player"));

FW.ID_HEALTHSTONE = 5512;

FW.OPTION_COLOR = {};
FW.OPTION_COLOR.CLASS = {RAID_CLASS_COLORS[FW.CLASS].r,RAID_CLASS_COLORS[FW.CLASS].g,RAID_CLASS_COLORS[FW.CLASS].b};
FW.OPTION_COLOR.COOLDOWN = {0.00,1.00,0.50};
FW.OPTION_COLOR.TIMER = {1.00,0.50,0.00};

FW.OPTION_COLOR.SOULSTONE = {0.55,0.00,0.70};
FW.OPTION_COLOR.SHARD = {0.55,0.00,0.70};
FW.OPTION_COLOR.HEALTHSTONE = {0.00,1.00,0.00};
FW.OPTION_COLOR.SHARDMANAGER = {0.55,0.00,0.70};
FW.OPTION_COLOR.SUMMON = {0.55,0.00,0.70};
FW.OPTION_COLOR.TALENT = {1.00,0.00,0.00};

FW.OPTION_COLOR.RAIDMESSAGES = {0.00,0.50,1.00};
FW.OPTION_COLOR.SELFMESSAGES = {0.00,0.50,1.00};
FW.OPTION_COLOR.SOUND = {0.00,0.50,1.00};
FW.OPTION_COLOR.ABOUT = {1.00,1.00,0.00};

FW.FLAG = {};
FW.FLAG.RES = 0; -- can res with ss
FW.FLAG.DI = 1; -- is di-ed
FW.FLAG.TIME = 2; -- normal soulstone duration
FW.FLAG.WARLOCK = 6203; -- Soulstone
FW.FLAG.DRUID = 20484; -- Rebirth
FW.FLAG.PALADIN = 114153; -- Divine Intervention MOP
FW.FLAG.SHAMAN = 20608; -- Reincarnation

FW.ORA3_COOLDOWN = "^1^SCooldown^N%d^N%d^^";

FW.FLAG.LEFT = -2;
FW.FLAG.OFFLINE = -1;
FW.FLAG.NORMAL = 0;
FW.FLAG.UNKNOWN = 1;
FW.FLAG.DEAD = 2;

FW.FILTER_ALWAYS = 3;
FW.FILTER_SHOW = 1;
FW.FILTER_NONE = 0;
FW.FILTER_HIDE = -1;
FW.FILTER_COLOR = -2;
FW.FILTER_SHOW_COLOR = 2;

FW.RaidIcons = {"{rt1}","{rt2}","{rt3}","{rt4}","{rt5}","{rt6}","{rt7}","{rt8}"};

FW.FontList = {};
FW.SoundList = {};
FW.BorderList = {};
FW.BackgroundList = {};

--[[function FW:RT(val,roundto)
	FW:Show(tostring(FW:RoundTo(val,roundto)));
end]]

function FW:RoundTo(val,roundto)
	if not roundto or roundto <= 0 then
		return val;
	end
	local f = 100;
	val = f*val;
	roundto = f*roundto;
	
	local remain = val%roundto;
	val = val - remain;
	if remain >= roundto*0.5 then
		return (val + roundto)/f;
	elseif remain < -roundto*0.5 then
		return (val - roundto)/f;
	else
		return val/f;
	end
end

function FW:Show(msg,r,g,b,a) DEFAULT_CHAT_FRAME:AddMessage(tostring(msg),r,g,b,a); end

function FW:Debug(msg) if FW_Debug then FW:Show("Debug: "..tostring(msg),1,0.5,0); end end

function FW:RegisterFont(path,name)
	tinsert(FW.FontList,{path,name});
end

function FW:RegisterBorder(path,name)
	tinsert(FW.BorderList,{path,name});
end

function FW:RegisterBackground(path,name)
	tinsert(FW.BackgroundList,{path,name});
end

function FW:RegisterSound(path,name)
	tinsert(FW.SoundList,{path,name});
end

function FW:SetDefaultFont(path,size)
	FW.Default.Font = {path,size};
	 -- setting the options default font here makes more sense
	FW.Default.OptionsFont = FW.Default.Font;
	FW.Default.OptionsHeaderFont = {};
	if FW.Default.Font[1] == "Interface\\AddOns\\Forte_Core\\Fonts\\GOTHIC.TTF" then
		FW.Default.OptionsHeaderFont[1] = "Interface\\AddOns\\Forte_Core\\Fonts\\GOTHICB.TTF";
	else
		FW.Default.OptionsHeaderFont[1] = FW.Default.Font[1];
	end
	FW.Default.OptionsHeaderFont[2] = FW.Default.Font[2];
end

FW.ERASE = function(t) -- erases any table
	for k in pairs(t) do
		if type(t[k])=="table" then
			FW.ERASE(t[k]);
		end
		t[k]= nil;
	end
end
local erase = FW.ERASE;

FW:RegisterFont("Fonts\\ARIALN.TTF", "Arial Narrow");
FW:RegisterFont("Fonts\\FRIZQT__.TTF", "Friz Quadrata TT");
FW:RegisterFont("Fonts\\MORPHEUS.TTF", "Morpheus");
FW:RegisterFont("Fonts\\SKURRI.TTF", "Skurri");
FW:RegisterFont("Interface\\AddOns\\Forte_Core\\Fonts\\FORTE.TTF", "Forte");
FW:RegisterFont("Interface\\AddOns\\Forte_Core\\Fonts\\HandelGothicBT.TTF", "Handel Gothic BT");
FW:RegisterFont("Interface\\AddOns\\Forte_Core\\Fonts\\GOTHIC.TTF", "Century Gothic");
FW:RegisterFont("Interface\\AddOns\\Forte_Core\\Fonts\\GOTHICB.TTF", "Century Gothic Bold");

FW:RegisterBorder("None", "None");
FW:RegisterBorder("Interface\\AddOns\\Forte_Core\\Textures\\Border", "ForteXorcist");

FW:RegisterBackground("None", "None");
FW:RegisterBackground("Interface\\AddOns\\Forte_Core\\Textures\\Background", "ForteXorcist");
FW:RegisterBackground("Interface\\AddOns\\Forte_Core\\Textures\\Otravi", "Otravi");
FW:RegisterBackground("Interface\\AddOns\\Forte_Core\\Textures\\Smooth", "Smooth");

FW:RegisterSound("Interface\\AddOns\\Forte_Core\\Sounds\\SoulstoneExpire.mp3", "FX: Soulstone Expire");
FW:RegisterSound("Sound\\Spells\\SoulstoneResurrection_Base.wav","Soulstone");
FW:RegisterSound("Sound\\Spells\\EnlargeCast.wav","Enlarge");
FW:RegisterSound("Sound\\Spells\\FluteRun.wav","Flute");
FW:RegisterSound("Sound\\Spells\\ShadowWard.wav","Shadow Ward");
FW:RegisterSound("Sound\\Spells\\ShadowWordSilence.wav","Silence");
FW:RegisterSound("Sound\\Spells\\ShadowWordPain_Chest.wav","Shadow Word Pain");
FW:RegisterSound("Sound\\Spells\\ShadowWordFumble.wav","Fumble");
FW:RegisterSound("Sound\\Spells\\AntiHoly.wav","Anti Holy");
FW:RegisterSound("Sound\\Spells\\Bonk1.wav","Bonk1");
FW:RegisterSound("Sound\\Spells\\Bonk2.wav","Bonk2");
FW:RegisterSound("Sound\\Spells\\Bonk3.wav","Bonk3");
FW:RegisterSound("Sound\\Spells\\consume_magic_impact.wav","Consume Magic");
FW:RegisterSound("Sound\\Spells\\Creature_SpellPortalLarge_All_Colors.wav","Spell Portal");
FW:RegisterSound("Sound\\Spells\\Ingvar_ResurrectionGroundVisual.wav","Resurrection Ground");
FW:RegisterSound("Sound\\Spells\\Resurrection.wav","Resurrection");
FW:RegisterSound("Sound\\Spells\\Rogue_shadowdance_state.wav","Shadow Dance");
FW:RegisterSound("Sound\\Spells\\ShaysBell.wav","Shay's Bell");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_BadPress.wav","Simon Error");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_GameFailedLarge.wav","Simon Failed Large");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_GameFailedSmall.wav","Simon Failed Small");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_GameStart.wav","Simon Start");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_GameTick.wav","Simon Tick");
FW:RegisterSound("Sound\\Spells\\SimonGame_Visual_LevelStart.wav","Simon Level Start");

FW.TextureList = {
	"Interface\\AddOns\\Forte_Core\\Textures\\Aluminium",
	"Interface\\AddOns\\Forte_Core\\Textures\\Minimalist",
	"Interface\\AddOns\\Forte_Core\\Textures\\Xus",
	"Interface\\AddOns\\Forte_Core\\Textures\\Otravi",
	"Interface\\AddOns\\Forte_Core\\Textures\\LiteStep",
	"Interface\\AddOns\\Forte_Core\\Textures\\BantoBar",
	"Interface\\AddOns\\Forte_Core\\Textures\\Charcoal",
	"Interface\\AddOns\\Forte_Core\\Textures\\Perl",
	"Interface\\AddOns\\Forte_Core\\Textures\\Smooth",
	"Interface\\AddOns\\Forte_Core\\Textures\\Smudge",
	"Interface\\AddOns\\Forte_Core\\Textures\\Striped",
	"Interface\\AddOns\\Forte_Core\\Textures\\Glaze",
	"Interface\\AddOns\\Forte_Core\\Textures\\Frost",
	"Interface\\AddOns\\Forte_Core\\Textures\\HealBot",
	"Interface\\AddOns\\Forte_Core\\Textures\\Rocks",
	"Interface\\AddOns\\Forte_Core\\Textures\\Runes",
	"Interface\\AddOns\\Forte_Core\\Textures\\Xeon",
	"Interface\\AddOns\\Forte_Core\\Textures\\SWSDefault",
	"Interface\\AddOns\\Forte_Core\\Textures\\Flat",
	"Interface\\TargetingFrame\\UI-StatusBar",
	"Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
};

function FW:SoundName(sound)
	for i, data in ipairs(FW.SoundList) do
		if strlower(data[1]) == strlower(sound) then
			return data[2];
		end
	end
	return "Custom Sound";
end

function FW:FontName(font)
	for i, data in ipairs(FW.FontList) do
		if strlower(data[1]) == strlower(font) then
			return data[2];
		end
	end
	return "Custom Font";
end

function FW:TypeName(t,list)
	for i, data in ipairs(list) do
		if data[1] == t then
			return data[2];
		end
	end	
end

FW.Modules = {};
function FW:ClassModule(module) -- only difference is setting the class module variable
	FW.ClassModules = module;
	return FW:Module(module,1);
end
function FW:Module(module,create)
	FW.Modules[module] = FW.Modules[module] or (create and {}) or nil;
	return FW.Modules[module];
end

local DeleteOld = 1800;

FW.GET_SHARDS = "SG";
FW.GET_HEALTHSTONE = "HG"
FW.SEND_HEALTHSTONE = "HS";
FW.SEND_SHARDS = "SH";

local SEND_VERSION = "VE"
local GET_VERSION = "VG";
local GET_SPECC = "SPG";
local SEND_SPECC = "SPS";

FW.LastHSCheck = 0;

FW.Healthstone = {};

FW.Zones = {};
FW.Ranks = {};
FW.Ready = {};

FW.SetBonus = {};
FW.Talent = {};
FW.Glyph = {};

FW.SpellInfo = {};-- id [,casttime,minrange,maxrange]

do
	local SpecialCastTimes = {};
	function FW:RegisterSpecialCastTime(spell,func)
		spell = FW:SpellName(spell);
		SpecialCastTimes[spell] = func;
	end

	function FW:CastTime(spell)
		if SpecialCastTimes[spell] then
			return SpecialCastTimes[spell]() or 0;
		else
			return FW.SpellInfo[spell] and FW.SpellInfo[spell][2] or 0;
		end
	end
end

function FW:SpellId(name)
	return FW.SpellInfo[name][1] or name;
end

function FW:FrameScaleCheck(editbox)
	local num = tonumber(editbox:GetText());
	if num then
		if num < 0.2 then 
			return 0.2;
		elseif num > 5.0 then
			return 5.0;
		end
		return num;
	end
end
function FW:FrameAlphaCheck(editbox)
	local num = tonumber(editbox:GetText());
	if num then
		if num < 0.1 then 
			return 0.1;
		elseif num > 1.0 then
			return 1.0;
		end
		return num;
	end
end

function FW:NumberCheck(editbox)
	local num = tonumber(editbox:GetText());
	if num then
		if editbox.maximum and num>editbox.maximum then
			return editbox.maximum;
		elseif editbox.minimum and num<editbox.minimum then
			return editbox.minimum;
		end
		return num;
	end
end

function FW:GetNumSpellBookSpells()
	local num = 0;
	for i = 1, GetNumSpellTabs() do
		local _, _, _, numSpells, _ = GetSpellTabInfo(i);
		num = num + numSpells;
	end
	return num;
end

do
	local max = math.max;
	function FW:FixIntensity(r,g,b)
		local largest = max(max(r,g),b);
		if largest == 1 then
			return 0.7*r+0.3,0.7*g+0.3,0.7*b+0.3;
		elseif largest > 0 and largest < 1 then
			return 0.7*r/largest+0.3,0.7*g/largest+0.3,0.7*b/largest+0.3;
		else
			return 1,1,1;
		end
	end

	local GetItemInfo = GetItemInfo;
	function FW:ItemName(item)
		local name = GetItemInfo(item);
		if name then
			return name,true;
		else
			return "item:"..item,false;
		end
	end
	local UnitGUID = UnitGUID;
	function FW:Changed(unit)
		FW[unit] = UnitGUID(unit);
	end
	
	local GameTooltip = _G.GameTooltip;
	local GameTooltip_SetDefaultAnchor = _G.GameTooltip_SetDefaultAnchor;
	function FW:ShowTip(self)
		if self.tip and self.title and FW.Settings.Tips then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetText(self.title, 1.0, 1.0, 1.0);
			GameTooltip:AddLine(self.tip, _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b, 1);
			GameTooltip:Show();
		end
	end
	
	function FW:ShowSpellTip(self)
		if FW.Settings.Tips then
			if self.token == "" then
				local i = 1;
				local spell;
				local m = FW:GetNumSpellBookSpells();
				while i<=m do
					spell = select(2,GetSpellBookItemInfo(i,"player"));
					if spell then
						spell = FW:SpellName(spell);
						--FW:Show(spell);
						if (spell == self.spell) then
							GameTooltip_SetDefaultAnchor(GameTooltip, self);
							GameTooltip:SetSpellBookItem(i,"player");
							--GameTooltip:AddLine(self.tip, _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b, 1);
							GameTooltip:Show();
							return;
						end
						i=i+1;
					else
						break;
					end
				end
				i=1;
				while true do
					spell = select(2,GetSpellBookItemInfo(i,"pet"));
					if spell then
						spell = FW:SpellName(spell);
						--FW:Show(spell);
						if (spell == self.spell) then
							GameTooltip_SetDefaultAnchor(GameTooltip, self);
							GameTooltip:SetSpellBookItem(i,"pet");
							--GameTooltip:SetText(self.title, 1.0, 1.0, 1.0);
							--GameTooltip:AddLine(self.tip, _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b, 1);
							GameTooltip:Show();
							return;
						end
						i=i+1;
					else
						break;
					end
				end
			else
				GameTooltip_SetDefaultAnchor(GameTooltip, self);
				GameTooltip:SetUnitAura(self.token,self.buffid,self.friendly == 1 and "HELPFUL" or "HARMFUL");
				GameTooltip:Show();
			end
		end
	end
	
	local HideUIPanel = HideUIPanel;
	function FW:HideTip(self)
		HideUIPanel(GameTooltip);
	end
end

local function FW_VersionCheck()
	FW:SendData(GET_VERSION);
end
--[[local function FW_GetSpeccInfo()
	FW:SendData(GET_SPECC);
end]]

local function FW_MakeSpeccInfo(inspect) -- creates you own specc information string, or that of someone you're inspecting
	--[[local player,class;
	if inspect then
		if not InspectFrame or not InspectFrame.unit then return; end -- avoid saving wrong speccs to the wrong ppl for now!!
		player = UnitName("target");
		class = select(2,UnitClass("target"));
		if not player or not class or (not UnitInParty("target") and not UnitInRaid("target")) or player == FW.PLAYER then return;end
	else
		player = FW.PLAYER;
		class = FW.CLASS;
	end
	--FW:Show("building talents for "..player);
	local currentRank;
	local str = "";
	for tab=1,GetNumSpecializations(inspect),1 do
		for i=1,GetNumTalents(tab,inspect),1 do
			currentRank = ( select( 5,GetTalentInfo(tab,i,inspect,nil,GetActiveSpecGroup(inspect)) ) );
			if currentRank > 0 then
				str = str..strformat("%02d",i)..currentRank;
			end
		end
		str=str.." ";
	end
	if not FX_Saved.Speccs[class] then
		FX_Saved.Speccs[class] = {};
	end
	FX_Saved.Speccs[class][player] = str.."00";]]
	-- will later use the last digits for other classes as well, for now it's always zero for non-warlocks
end

------------------------------------------------------------------------------------------------------------------
local FW_Scans = {};
local UnitIsConnected = UnitIsConnected;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
--FW.Online = {};

local function FW_ScanUnit(unit,update)
	local unitName = UnitName(unit);
	local _, unitClass = UnitClass(unit);
	local flag;
	if UnitIsConnected(unit) then
		if UnitIsDeadOrGhost(unit) then	
			flag = FW.FLAG.DEAD;
		else
			flag = FW.FLAG.NORMAL;
		end
	else
		flag = FW.FLAG.OFFLINE;
	end
	
	for i,f in ipairs(FW_Scans) do
		f(unit,unitName,unitClass,flag,update);
	end
end


local function FW_Scan()
	local update = GetTime();
	FW:RosterInfo();
	for k in pairs(FX_Saved.RaidStatus) do -- in case i want to be able to tell who left the raid
		FX_Saved.RaidStatus[k][1] = FW.FLAG.LEFT;
	end
	FW:ForGroupMembers(FW_ScanUnit,update);
	FX_Saved.Update = update; 
	-- updating raw data complete
end

local fx2temp = {};
local ora3temp = {};

local function FW_RaidStatusScan(unit,unitName,unitClass,flag,update)
	if not FX_Saved.RaidStatus[unitName] then
		FX_Saved.RaidStatus[unitName] = {flag,update,unitClass,(unitName==FW.PLAYER and VERSION) or fx2temp[unitName] or (unitName==FW.PLAYER and _G.oRA3 and _G.oRA3.VERSION) or ora3temp[unitName]};
	end
	FX_Saved.RaidStatus[unitName][1] = flag;
	FX_Saved.RaidStatus[unitName][3] = unitClass;
	if flag ~= FW.FLAG.OFFLINE then
		FX_Saved.RaidStatus[unitName][2] = update;
	end
end

local SpecialSaved = {};
local function FW_Reset()
	for k, v in pairs(SpecialSaved) do
		if v==true then
			erase(FX_Saved[k]);
		end
	end
end

local function FW_ResetOld(t)
	for k, v in pairs(FX_Saved.RaidStatus) do
		if (t-v[2] > DeleteOld) then
			FX_Saved.RaidStatus[k] = nil;
		end
	end
	for key, val in pairs(SpecialSaved) do
		if val==true then
			for k, v in pairs(FX_Saved[key]) do
				if k == "Timers" then -- still old style
					if (t-v[2] > DeleteOld) then
						FX_Saved[key][k] = nil;
					end
				elseif not FX_Saved["RaidStatus"][k] then
					FX_Saved[key][k] = nil;
				end
			end
		end
	end
end

local function FW_RefreshAllFilters()
	for i,f in ipairs(FilterRefresh) do
		f();
	end
end

--[[do
	local type = type;
	local function MatchOption(self,from,to,name)
		if type(from[name]) == type(to[name]) then
			if type(from[name]) == "table" then
				local m = true;
				for k, v in pairs(from[name]) do
					if not MatchOption(self,from[name],to[name],k) then
						m = false;
						break;
					end
				end
				return m;
			else
				return to[name] == from[name];
			end
		else
			return false;
		end
	end

	FW.MatchOption = MatchOption;
end
do
	local type = type;
	function CopyOption(self,from,to,name)
		if type(from[name]) == "table" then
			if type(to[name]) == "table" then
				erase(to[name]);
			else
				to[name] = {};
			end
			for k, v in pairs(from[name]) do
				CopyOption(self,from[name],to[name],k)
			end
		else
			to[name] = from[name];
		end
	end
	FW.CopyOption = CopyOption;
end
]]

local function FW_CopyNew(from,to) -- copies only new values or values of wrong old type
	for key, val in pairs(from) do
		if type(val) == "table" then
			if to[key] == nil or type(to[key]) ~= "table" then
				to[key] = {};
			end
			FW_CopyNew(val,to[key]);
		else
			if to[key] == nil or type(to[key]) ~= type(from[key]) then
				to[key] = val;
			end
		end
	end
end

function FW:CopyCloneSettings(from,to)
	FW_CopyNew(from,to);
end

function FW:FullName()
	return FW.PLAYER.."-"..FW.SERVER;
end

local function FW_InitConfig()
	if FW.Saved.Profiles.Characters[FW:FullName()] then -- load the proper profile or use the last used one if loading for the first time
		FW:UseProfile(FW.Saved.Profiles.Characters[FW:FullName()],1); -- <-- new style profiles
	else
		FW:UseProfile(FW.Saved.Profiles.Active,1); -- <-- simply use the last active profile if i can't find any match
	end
end

function FW:FixStringFormat(str)
	str = gsub(str,"%%","%%%%");
	str = gsub(str,"%%%%s","%%s");
	return str;
end

local function fixTimerSettings19743(settings)
	if settings then
		if settings["Time"] ~= nil then
			settings["TimeRight"] = settings["Time"];
			settings["Time"] = true;
		end
	end
end

local function renameOption(from,to,settings)
	if settings[from] then
		settings[to] = settings[from];
		settings[from] = nil;
	end
end

local function fixCooldownSettings19746(settings)
	if settings then
		if settings["IconTextColor"] ~= nil then
			if settings["IconTextColor"][4] == 0.00 and settings["IconTextEnable"] == true then
				settings["IconText"] = false;
				settings["IconTextColor"][4] = 1.00;
			end
		end
	end
end
local function fixCooldownSettings1975(settings)
	if settings then
		if settings["IconText"] ~= nil then
			settings["IconTime"] = settings["IconText"];
			settings["IconText"] = nil;
		end
	end
end

local function fixTimerSettings(settings)
	if settings then
		-- fix downgrade-upgrade bug...
		if type(settings["Blink"]) == "boolean" then 
			settings["BlinkEnable"] = settings["Blink"] or true;
			settings["Blink"] = 3;
		end

		-- fix spark settings
		if type(settings["Spark"]) == "boolean" then
			settings["SparkEnable"] = true;
			settings["Spark"] = 0.7;
			settings["SparkColor"]  = nil;
		end
		
		if type(settings["CastSpark"]) == "boolean" then
			settings["CastSparkEnable"] = settings["CastSpark"] or true;
			settings["CastSpark"] = 0.3;
		end
		if type(settings["Ticks"]) == "boolean" then
			settings["TicksEnable"] = settings["Ticks"] or true;
			settings["Ticks"] = 0.3;
		end
		
		-- fix raid icon setting
		if type(settings["RaidTargets"]) == "boolean" then
			settings["RaidTargetsEnable"] = settings["RaidTargets"] or false;
			settings["RaidTargets"] = settings["RaidTargetsAlpha"] or 0.7;
		end
		
		if settings["Filter"] then
			-- fix old unknown spells that got saved as numbers
			for k,v in pairs(settings["Filter"]) do
				if type(k) == "number" then
					settings["Filter"][k] = nil;
				end
			end
		end
	end
end

local function fixCooldownSettings(settings)
	if settings then
		-- fix spark settings
		if type(settings["Spark"]) == "boolean" then
			settings["SparkEnable"] = true;
			settings["Spark"] = 1.0;
		end
		if settings["Filter"] then
			-- fix old unknown spells that got saved as numbers
			for k,v in pairs(settings["Filter"]) do
				if type(k) == "number" then
					settings["Filter"][k] = nil;
				end
			end
		end
	end
end

local function fixFilterRenames(settings)
	--" - Bear" -> " (Bear)"
	--" - Cat" -> " (Cat)"
	if settings and settings["Filter"] then
		-- fix old unknown spells that got saved as numbers
		for k,v in pairs(settings["Filter"]) do
			local v1 = strfind(k," %- Bear");
			if v1 then
				local newkey = strsub(k,0,v1-1).." (Bear)";
				--local newkey = gsub(k," %- Bear$"," (Bear)");
				settings["Filter"][newkey] = {settings["Filter"][k][1],settings["Filter"][k][2],settings["Filter"][k][3],settings["Filter"][k][4]};
				settings["Filter"][k] = nil;
			end
			local v2 = strfind(k," %- Cat");
			if v2 then
				local newkey = strsub(k,0,v2-1).." (Cat)";
				settings["Filter"][newkey] = {settings["Filter"][k][1],settings["Filter"][k][2],settings["Filter"][k][3],settings["Filter"][k][4]};
				settings["Filter"][k] = nil;
			end
		end
	end
end

local function fixOptions1975(settings)
	local _,f,t1,t2,t3,t4,t5;
	if settings then -- check if this group of settings exists
		settings["RAID"] = nil;
		settings["PARTY"] = nil;
		for k, v in pairs(settings) do
			
			if type(v) == "table" then
				--COLOR type options
				_,_,f = strfind(k,"(.+)Color$");
				if f then
					settings[k][0] = settings[f.."Enable"];
					for i,v in ipairs(settings[k]) do
						settings[k][i] = FW:RoundTo(settings[k][i],0.01); -- fix to 2 decimals only
					end
					settings[f.."Enable"] = nil;
				end
			else
				-- MSG type options
				_,_,f = strfind(k,"(.+)Msg$");
				if f then
					t1 = settings[f];
					t2 = settings[k];
					settings[f] = {t2};
					settings[f][0] = t1;
					settings[k] = nil;
				end
				-- FONT type options
				f = strfind(k,"Font$");
				if f then
					t1 = settings[k];
					t2 = settings[k.."Size"];
					settings[k] = {t1,t2};
					settings[k.."Size"] = nil;
				end
				-- SOUND type options
				f = strfind(k,"Sound$");
				if f then
					t1 = settings[k];
					t2 = settings[k.."Volume"];
					settings[k] = {t1,t2};
					settings[k][0] = settings[k.."Enable"];
					settings[k.."Volume"] = nil;
					settings[k.."Enable"] = nil;
				end
			end
		end
		-- DO THIS AFTER SOUND (because of SoundEnable)
		for k, v in pairs(settings) do
			if type(v) ~= "table" then
				-- NU2 type options
				_,_,f = strfind(k,"(.+)Enable$");
				if f then
					if type(settings[f])=="number" then
						--FW:Show("found "..k);
						t1 = settings[f];
						t2 = settings[k];
						
						settings[f] = {t1};
						settings[f][0] = t2;
						settings[k] = nil;
					end
				end
			end
		end
	end
end

function FW:Popup1975(update)
	local txt = "|cff00ff00This version introduces 'Options linking'!\n\nYou can choose to link all your profiles and clones together now, and link the options that are the same everywhere. This will also automatically link every new profile or clone in the future.\n\nYou can always change or re-run this at 'Advanced Options > Options linking'.|r\n\n|cffffcc00Do you want to smart link everything now?\nSELECT 'NO' IF YOU'RE NOT SURE!|r";
	if update then
		txt = "|cffff6600Your settings are now converted for v1.975+. ForteXorcist keeps a backup of your current configuration in case you want to revert back to a previous version. If you go back to using a previous version, your settings will go back to this backup!|r\n\n"..txt;
	end
	if LUI_versions and tostring(LUI_versions.forte) < "v1.975" then
		txt = "|cffff0000This version of ForteXorcist is incompatible with your current version of LUI. Please install the latest version of LUI (or just the latest forte LUI module) or reinstall ForteXorcist v1.974.8.|r\n\n"..txt;
	end
	_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button1 = "Yes, smart link now!";
	_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button2 = "No thanks, maybe later.";
	_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].OnAccept = FW.SmartLinkAll;
	_G.StaticPopup_Show("FX_MULTI_PURPOSE","A MESSAGE FROM FORTEXORCIST\n\n"..txt);
end

local function IsOldModuleLoaded()
	local loaded = false;
	local modules = {
		"Forte_DeathKnight",
		"Forte_Druid",
		"Forte_Hunter",
		"Forte_Mage",
		"Forte_Paladin",
		"Forte_Priest",
		"Forte_Rogue",
		"Forte_Shaman",
		"Forte_Vehicle",
		"Forte_Warlock",
		"Forte_Warrior"
	};
	for i,module in ipairs(modules) do
		if IsAddOnLoaded(module) then
			DisableAddOn(module);
			loaded = true;
		end
	end
	
	return loaded;
end

local function FW_Variables()
	FW:UnregisterToEvent("PLAYER_ENTERING_WORLD",	FW_Variables);
	
	local t = GetTime();
	
	FC_Saved = _G.FC_Saved; -- sets the local upval again
	FX_Saved = _G.FX_Saved; -- sets the local upval again
	
	if FW:Size(FX_Saved) == 0 then -- only copy if empty!!
		FW_CopyNew(FC_Saved,FX_Saved); -- rename saved table and keep old table in tact for now
	end
	FX_Saved.RESETTING = nil;
	
	FW.Saved = FX_Saved; -- use to access the saved table globally
	
	FW:RegisterSpecialSaved("Profiles",false,{Active=1,Characters={},Instances={{}},Data={{name=FW:FullName()}}, Links={}});
	FW:RegisterSpecialSaved("VERSION",false,"");
	FW:RegisterSpecialSaved("RAID",false,false);
	FW:RegisterSpecialSaved("GROUPED",false,false);

	FW:RegisterSpecialSaved("CATEGORIES",false,{});
	
	--FW:RegisterSpecialSaved("Speccs",false,{});
	FW:RegisterSpecialSaved("Exceptions",false,{});
	FW:RegisterSpecialSaved("Update",false,0);
	
	FW:RegisterSpecialSaved("RaidStatus",true,{});	 -- need a last seen table
	
	FW:RegisterSpecialSaved("Timers",true,{}); -- old style
	FW:RegisterSpecialSaved("Cooldowns",true,{}); -- old style

	FW:RegisterSpecialSaved("Healthstone",true,{}); -- new style

	FW_CopyNew(FW.Exceptions,FX_Saved.Exceptions);
	
	--FX_Saved.VERSION = "v1.959.1"; -- REMOVE IF NOT TESTING!!!!!
	if IsOldModuleLoaded() then
		EnableAddOn("Forte_Class");
		local err = "|cffffffffYou still had old Class Modules enabled. These will automatically be disabled when you reload your interface. ForteXorcist will not function before you do this.\n\n To make sure you don't get this message on other characters, delete or disable Forte_DeathKnight, Forte_Druid, Forte_Hunter, Forte_Mage, Forte_Paladin, Forte_Priest, Forte_Rogue, Forte_Shaman, Forte_Vehicle, Forte_Warlock and Forte_Warrior.";
		_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button1 = "Okay, reload now";
		_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button2 = "No, reload later";
		_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].OnAccept = ReloadUI;
		_G.StaticPopup_Show("FX_MULTI_PURPOSE","A MESSAGE FROM FORTEXORCIST\n\n"..err);

		FW:UnregisterAllEvents();
		FW.Settings = {};
		return;
	end
	
	if FX_Saved.VERSION ~= VERSION then -- version change
	
		-- !!! COMPATIBILITY FIXES - ONLY DONE ONCE SO MAKE SURE ALL PROFILES GET UPDATED AT ONCE !!! --
		-- always use real values for defaults in modules, since these defaults/modules may not be loaded

		if FX_Saved.VERSION ~= "" then
			-- this check is to fix the v1.975(.1) bug and will check if the format is really pre-v1.975
			if not FX_Saved.Profiles.Instances or FW:Size(FX_Saved.Profiles.Instances) == 0 then
			
				if FX_Saved.VERSION < "v1.90" then
					local err = "|cffff0000You are updating from a too old version. If you want to keep your settings and make this work, install and run v1.958 first and then this version. If you don't care about keeping your old settings they can be reset now. ForteXorcist will then restart as if it were a fresh install.|r\n\n|cffffcc00Do you want to reset ForteXorcist now?|r";
					_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button1 = "Okay, wipe my settings";
					_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].button2 = "No, I will install v1.958";
					_G.StaticPopupDialogs["FX_MULTI_PURPOSE"].OnAccept = Commands["resetall"];
					_G.StaticPopup_Show("FX_MULTI_PURPOSE","A MESSAGE FROM FORTEXORCIST\n\n"..err);
			
					FW:UnregisterAllEvents();
					FW.Settings = {};
					return;
				end
				if FX_Saved.VERSION < "v1.959.2" then
					if FX_Saved.Profiles then
						FX_Saved.ProfileNames = {};
						for p,d in pairs( FX_Saved.Profiles ) do
							tinsert(FX_Saved.ProfileNames,{p,p});
						end
					end
				end
				if FX_Saved.VERSION < "v1.959.5" then
					FX_Saved.GotORA = nil; -- no longer used
					FX_Saved.Warlocks = nil; -- no longer used
					
					FX_Saved.Healthstone = {}; -- reset
					FX_Saved.Cooldowns = {}; -- reset
				end
				if FX_Saved.VERSION < "v1.959.7" then
					FX_Saved.PARTY = nil; -- no longer used
				end
				if FX_Saved.VERSION < "v1.966.1" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do

							if type(FX_Saved.Profiles[p]["GlobalSpark"]) == "boolean" then -- fix downgrade-upgrade bug...
								FX_Saved.Profiles[p]["GlobalSparkEnable"] = FX_Saved.Profiles[p]["GlobalSpark"] or FW.Default.GlobalSparkEnable;
								FX_Saved.Profiles[p]["GlobalSpark"] = FW.Default.GlobalSpark;
							end
							
							fixTimerSettings(FX_Saved.Profiles[p]["Timer"]);
							if FX_Saved.Profiles[p]["CustomInstances"] and FX_Saved.Profiles[p]["CustomInstances"]["Timer"] then
								for clone,data in ipairs(FX_Saved.Profiles[p]["CustomInstances"]["Timer"]) do
									fixTimerSettings(FX_Saved.Profiles[p][ data[1] ]);
								end
							end
							fixCooldownSettings(FX_Saved.Profiles[p]["Cooldown"]);
							
							-- set ignore cd time to 2.99 instead of 3.00
							FX_Saved.Profiles[p]["IgnoreCooldown"] = 2.99;
						end
					end
				end
				if FX_Saved.VERSION < "v1.966.3" then
					FX_Saved.Shards = nil; -- no longer used
				end
				if FX_Saved.VERSION < "v1.966.5" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do
							if FX_Saved.Profiles[p]["TimerSortOrder"] then
								FX_Saved.Profiles[p]["TimerSortOrder"] = gsub(FX_Saved.Profiles[p]["TimerSortOrder"],","," ");
							end
						end
					end
				end
				if FX_Saved.VERSION < "v1.966.6" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do
							FX_Saved.Profiles[p]["AnimateScroll"] = false;
							
							fixFilterRenames(FX_Saved.Profiles[p]["Timer"]);
							if FX_Saved.Profiles[p]["CustomInstances"] and FX_Saved.Profiles[p]["CustomInstances"]["Timer"] then
								for clone,data in ipairs(FX_Saved.Profiles[p]["CustomInstances"]["Timer"]) do
									fixFilterRenames(FX_Saved.Profiles[p][ data[1] ]);
								end
							end
							fixFilterRenames(FX_Saved.Profiles[p]["Cooldown"]);
						end
					end
				end
				if FX_Saved.VERSION < "v1.974.3" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do
							fixTimerSettings19743(FX_Saved.Profiles[p]["Timer"]);
							if FX_Saved.Profiles[p]["CustomInstances"] and FX_Saved.Profiles[p]["CustomInstances"]["Timer"] then
								for clone,data in ipairs(FX_Saved.Profiles[p]["CustomInstances"]["Timer"]) do
									fixTimerSettings19743(FX_Saved.Profiles[p][ data[1] ]);
								end
							end
						end
					end
				end
				if FX_Saved.VERSION < "v1.974.6" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do
							fixCooldownSettings19746(FX_Saved.Profiles[p]["Cooldown"]);
						end
					end
				end
				if FX_Saved.VERSION < "v1.975" then
					if FX_Saved.Profiles then
						for p,d in pairs( FX_Saved.Profiles ) do
							
							FX_Saved.Profiles[p].OptionsSubHeaderBackdrop = nil;
							FX_Saved.Profiles[p].OptionsHeaderBackdrop = nil;
						
							fixOptions1975(FX_Saved.Profiles[p]);	
						
							if FX_Saved.Profiles[p]["Timer"] then -- move and fix
								local temp = {Active=1,Instance="Timer",Instances={}, Links={}, Data={}};
								local index = FW:InstanceCreate(FWL.SPELL_TIMER or "Spell Timer",temp,FX_Saved.Profiles[p]["Timer"]);
								fixOptions1975(temp.Instances[index]);
								FX_Saved.Profiles[p]["Timer"] = {};
								if FX_Saved.Profiles[p]["CustomInstances"] and FX_Saved.Profiles[p]["CustomInstances"]["Timer"] then
									for clone,data in ipairs(FX_Saved.Profiles[p]["CustomInstances"]["Timer"]) do
										index = FW:InstanceCreate(data[2],temp,FX_Saved.Profiles[p][ data[1] ]);
										fixOptions1975(temp.Instances[index]);
										FX_Saved.Profiles[p][ data[1] ] = nil;
									end
									FX_Saved.Profiles[p]["CustomInstances"] = nil;
								end
								FW_CopyNew(temp,FX_Saved.Profiles[p]["Timer"]);
							end
							if FX_Saved.Profiles[p]["Cooldown"] then -- move and fix
								local temp = {Active=1,Instance="Cooldown",Instances={}, Links={}, Data={}};
								local index = FW:InstanceCreate(FWL.COOLDOWN_TIMER or "Cooldown Timer",temp,FX_Saved.Profiles[p]["Cooldown"]);
								fixOptions1975(temp.Instances[index]);
								FX_Saved.Profiles[p]["Cooldown"] = {};
								FW_CopyNew(temp,FX_Saved.Profiles[p]["Cooldown"]);
							end
							if FX_Saved.Profiles[p]["Splash"] then -- move and fix
								local temp = {Active=1,Instance="Splash",Instances={}, Links={}, Data={}};
								local index = FW:InstanceCreate(FWL.SECONDARY_SPLASH or "Secondary Splash",temp,FX_Saved.Profiles[p]["Splash"]);
								fixCooldownSettings1975(temp.Instances[index])
								fixOptions1975(temp.Instances[index]);
								FX_Saved.Profiles[p]["Splash"] = {};
								FW_CopyNew(temp,FX_Saved.Profiles[p]["Splash"]);
							end
						end
						local temp = {Active=1,Characters={},Instances={}, Links={}, Data={}};
						for i,d in ipairs( FX_Saved.ProfileNames ) do
							FW:InstanceCreate(d[2],temp, FX_Saved.Profiles[ d[1] ]);
							if FX_Saved.PROFILE == d[1] then
								temp.Active = i;
							end
							for key, val in pairs(FX_Saved.PROFILES) do
								if val == d[1] then
									temp.Characters[key] = i;
								end
							end
						end
						FX_Saved.Profiles = {}; -- clear the old options
						FW_CopyNew(temp,FX_Saved.Profiles);
						-- delete old tables
						FX_Saved.ProfileNames = nil; -- old
						FX_Saved.PROFILES = nil; -- old
						FX_Saved.PROFILE = nil; -- old
						FX_Saved.SCALE = nil; -- old
						FX_Saved.Speccs = nil; -- incompatible data
						FX_Saved.Shards = nil; -- module removed
					end
				end
			end -- end of fix for v1.975(.1) bug
			-- add new compatibility fixes here:
			
			if FX_Saved.VERSION < "v1.975.7" then
				for instance,settings in ipairs( FX_Saved.Profiles.Instances ) do
					if settings.RebirthStart then
						settings.RebirthStart[1] = ">>> Rebirth on %s <<<";
					end
					if settings.InnervateStart then
						settings.InnervateStart[1] = ">>> Innervate on %s <<<";
					end
				end
			end
			if FX_Saved.VERSION < "v1.976" then
				for instance,settings in ipairs( FX_Saved.Profiles.Instances ) do
					if settings.Timer then
						for i,s in ipairs( settings.Timer.Instances ) do
							renameOption("FailColor","Fail",s);
							
							renameOption("DrainColor","Drain",s);
							renameOption("MagicColor","Default",s);
							renameOption("CurseColor","Shared1",s);
							renameOption("Shared2Color","Shared2",s);
							renameOption("Shared3Color","Shared3",s);
							renameOption("CrowdColor","Unique",s);
							renameOption("PetColor","Pet",s);
							renameOption("BuffColor","SelfBuff",s);
							renameOption("BuffOtherColor","SelfBuffOther",s);
							renameOption("SelfDebuffColor","SelfDebuff",s);
							renameOption("SelfDebuffOtherColor","SelfDebuffOther",s);
							renameOption("CooldownsColor","Cooldown",s);
							renameOption("CooldownsOtherColor","CooldownOther",s);
							renameOption("DebuffsColor","TargetDebuff",s);
							renameOption("DebuffsOtherColor","TargetDebuffOther",s);
							renameOption("HealColor","Heal",s);
							renameOption("FriendlyBuffColor","Buff",s);
							
							renameOption("TotemFireColor","TotemFire",s);
							renameOption("TotemEarthColor","TotemEarth",s);
							renameOption("TotemWaterColor","TotemWater",s);
							renameOption("TotemAirColor","TotemAir",s);
						end
					end
				end
			end
			if FX_Saved.VERSION < "v1.976.1" then
				for instance,settings in ipairs( FX_Saved.Profiles.Instances ) do
					if settings.Timer then
						for i,s in ipairs( settings.Timer.Instances ) do
							renameOption("Drain","Channel",s);
							renameOption("Shared1","Curse",s);
							renameOption("Shared2","Bane",s);
							renameOption("Unique","Crowd",s);
							s["Shared3"] = nil;
						end
					end
				end
			end
			if FX_Saved.VERSION < "v1.976.3" then
				for instance,settings in ipairs( FX_Saved.Profiles.Instances ) do
					if settings.Cooldown then
						for i,s in ipairs( settings.Cooldown.Instances ) do
							renameOption("SpellColor","Spell",s);
							renameOption("PetColor","Pet",s);
							renameOption("ItemColor","Item",s);
							renameOption("SoulstoneColor","Soulstone",s);
							renameOption("HealthstoneColor","Healthstone",s);
							renameOption("PotionColor","Potion",s);
							renameOption("PowerupColor","Powerup",s);
							renameOption("ResTimerColor","ResTimer",s);
							
							renameOption("BuffColor","Buff",s);
							renameOption("BuffOtherColor","BuffOther",s);
							renameOption("DebuffColor","Debuff",s);
							renameOption("DebuffOtherColor","DebuffOther",s);
							
							renameOption("EnchantColor","Enchant",s);
							
							renameOption("RuneBloodColor","RuneBlood",s);
							renameOption("RuneDeathColor","RuneDeath",s);
							renameOption("RuneFrostColor","RuneFrost",s);
						end
					end
				end
			end
		end
		if FX_Saved.VERSION < "v1.975" then
			FW:Popup1975(FX_Saved.VERSION ~= "");
		end
		-- !!! END COMPATIBILITY FIXES !!! --
		FX_Saved.VERSION = VERSION;
	end 
	STATES.GROUPED = FX_Saved.GROUPED;
	STATES.RAID = FX_Saved.RAID;
	
	FW:RegisterFrame("FWOptions",FW:NewOptionsPanel()); -- needs to be done at least before FW_InitConfig!!!
	
	FW_InitConfig(); -- set the right profile
	
	if FW.Settings.ShowStartupText then
		FW:Show(FW:Title().." - /fx for options",0,1,0);
		FW:Show("Class Module: "..FW.ClassModules.." - Modules: "..FW:Size(FW.Modules),0,1,0);	
	end
	FW:Debug("Warning: Debug mode is on!");
	
	if FX_Saved.Update > t then -- pc rebooted, have to clear all timers
		FW_Reset();
	else
		FW_ResetOld(t);
	end

	for i,f in ipairs(FW_VariablesLoaded) do
		f();
	end
end

function FW:Title()
	return FW.TITLE.." "..VERSION.." by Xus - "..FW:InstanceIndexToName(FW.Saved.Profiles.Active,FW.Saved.Profiles);
end

function FW:RegisterEnterPartyRaid(func)
	tinsert(FW_EnterPartyRaid,func);
end

local function FW_PartyRaid() -- also run on ui load plx!
	for i,f in ipairs(FW_EnterPartyRaid) do
		f(STATES.GROUPED);
	end
end

local function FW_TimedRaidParty()
	local t1, t2 = IsInInstance();
	local t3;
	local party,raid;
	if t1 and t2 ~= "raid" and t2 ~= "party" then -- switch everything raid related off if we're inside a battleground
		party = false;
		raid = false;
	else
		party = IsInGroup();
		raid = IsInRaid();
	end
	t3 = (party or raid);
	if STATES.RAID ~= raid then
		FX_Saved.RAID = raid;
		STATES.RAID = raid;
	end
	if STATES.GROUPED ~= t3 then
		FX_Saved.GROUPED = t3;
		STATES.GROUPED = t3;
		FW_PartyRaid();
	end
end

-- ids here is in numbers too!
function FW:RegisterSet(name,...)
	for i=1,select('#',...), 1 do
		FW.Sets[select(i,...)] = name;
	end
	if not FW.SetBonus[name] then FW.SetBonus[name] = 0; end
end

local function FW_RelevantTalent()
	--FW:Show("TALENTS");
	--[[for tab=1,GetNumSpecializations(),1 do
		for i=1,GetNumTalents(tab),1 do
			local name, _, _, _, rank = GetTalentInfo(tab, i, nil,nil,GetActiveSpecGroup());
			if FW.Talent[name] then
				FW.Talent[name] = rank;
			end
		end
	end]]
end

local function FW_RelevantStance()
	FW.Stance = GetShapeshiftForm();
	--FW:Show("STANCE "..FW.Stance);
end

-- glyph API changed in 4.0.1
local GetGlyphLink = GetGlyphLink;
local function FW_RelevantGlyph()
	--FW:Show("check");
	for k, v in pairs(FW.Glyph) do
		FW.Glyph[k] = 0;
	end
	local val;
	for i = 1, 9, 1 do
		val = GetGlyphLink(i,GetActiveSpecGroup());
		if val and val ~= "" then
			val = select(3,strfind(val,"%[(.+)%]"));
			FW.Glyph[val] = 1;
		end
	end
end
	
local function FW_RelevantSetBonus()
	--FW:Show( "SET SCAN" );
	for k, v in pairs(FW.SetBonus) do
		FW.SetBonus[k] = 0;
	end
	local t1;
	for i=1,12,1 do -- from head to 2nd ring
		t1 = GetInventoryItemID("player", i); -- is a number
		if t1 then
			t1 = FW.Sets[t1];
			if t1 then
				FW.SetBonus[t1] = FW.SetBonus[t1] + 1;
			end
		end
	end
end

function FW:SecToTimeD(t)
	if FW.Settings.TimeFormat then
		if t >= 60 then 
			return math.floor(t/60)..":"..strformat("%02d",t%60);
		else
			return strformat("%.1f",t);
		end
	else
		if t >= 3600 then
			return ceil(t/3600).."h";
		elseif t >= 60 then
			return ceil(t/60).."m";
		else
			return floor(t).."s";
		end
	end
end

function FW:SecToTime(t)
	if FW.Settings.TimeFormat then
		return math.floor(t/60)..":"..strformat("%02d",t%60);
	else
		if t >= 3600 then
			return ceil(t/3600).."h";
		elseif t >= 60 then
			return ceil(t/60).."m";
		else
			return floor(t).."s";
		end
	end
end
do
	local function MatchNameToId(unit,name)
		if name == UnitName(unit) then
			return unit;
		end
	end
	function FW:NameToID(name)
		if name == FW.PLAYER then return "player";end
		return FW:ForGroupMembers(MatchNameToId,name);
	end
end

function FW:RosterInfo()
	if GetNumGroupMembers()>0 then
		local name,rank,zone,_;
		for i=1,40,1 do
			name, rank, _, _, _, _, zone = GetRaidRosterInfo(i);
			if name then
				FW.Ranks[name] = rank;
				FW.Zones[name] = zone;
			end
		end
	end
end


function FW:IsWarlock(unit)
	if select(2,UnitClass(unit)) == "WARLOCK" then return 1;end
end

do
	local GetItemCount = GetItemCount;
	function FW:GotHealthstone() -- returns the name of the best hs in your inventory
		return GetItemCount(FW.ID_HEALTHSTONE);
	end
end

function FW:BestSoulstone() -- returns name of best soulstone you can create, ising in cooldown and soulstone module
	if FW.CLASS == "WARLOCK" then
		return FW:ItemName(FW.ID_SOULSTONE);
	else
		return FWL.NONE;
	end
end

function FW:BestHealthstone()
	if FW.CLASS == "WARLOCK" then
		return FW:ItemName(FW.ID_HEALTHSTONE);
	else
		return FWL.NONE;
	end
end

--[[
function FW:TimeStart()
	FW.StartTime = GetTime();
end

function FW:TimeEnd(label)
	FW:Show(label..": "..(GetTime()-FW.StartTime),0,0,1);
end]]

local function FW_SendVersion()
	FW:SendData(SEND_VERSION..VERSION);
end


--[[local function FW_SendSpeccInfo()
	if FX_Saved.Speccs[FW.CLASS] and FX_Saved.Speccs[FW.CLASS][FW.PLAYER] then
		FW:SendData(SEND_SPECC..FX_Saved.Speccs[FW.CLASS][FW.PLAYER]);
	--else
		--FW:Show("failed to send");
	end
end]]

local function FW_AddonMessage(msg,from)
	for i,d in ipairs(FW_Messages) do
		if strfind(msg,d[1]) then
			FW:Debug("FX2 Running function for "..d[1],0,1,1);
			if d[2]( strsub(msg,strlen(d[1])), from ) then return; end
		end
	end
end

local function FW_AddonMessageReceived(event,...)
	local arg1,arg2,arg3,arg4 = ...;
	if arg1 == "FX2" then
		--FW:Debug(arg4..": "..arg2,0,1,1);
		if arg4 ~= FW.PLAYER then -- ignore messages from self
			FW_AddonMessage(arg2,arg4);
		end
	elseif arg1 == "oRA3" then
		if FX_Saved.RaidStatus[arg4] then
			if not FX_Saved.RaidStatus[arg4][4] then
				FX_Saved.RaidStatus[arg4][4] = 1;
			end
		else
			ora3temp[arg4] = 1;
		end
		--[[local debug = GetTime().." "..event;
		if arg1 then debug = debug.." "..tostring(arg1); end
		if arg2 then debug = debug.." "..tostring(arg2); end
		if arg3 then debug = debug.." "..tostring(arg3); end
		if arg4 then debug = debug.." "..tostring(arg4); end
		FW:Show(debug,0,1,1);]]
		local _,t1,t2;
		for i,d in ipairs(FW_oRAMessages) do
			_,_,t1,t2 = strfind(arg2,d[1]);
			if t1 then
				FW:Debug("oRA3 Running function for "..d[1],0,1,1);
				if d[2]( t1,t2, arg4 ) then return; end -- stop looking if function actually returns something
			end
		end
	end
end

--------------------------------------------

function FW:SendData(msg)
	FW_AddonMessage(msg,FW.PLAYER);
	if FW.STATES.GROUPED then
		SendAddonMessage("FX2",msg,"RAID");
	end
end
--------------------------------------------

local function FW_CheckHealthstone()
	FW:Debug("HS check response");
	FW:SendHealthstone(FX_Saved.Healthstone[FW.PLAYER] or -1);
end

function FW:SendHealthstone(id)
	SendAddonMessage("FX2",FW.SEND_HEALTHSTONE..id,"RAID");--can completely ignore this yourself
end

---------------------------------------------------------------------------
-- register functions
---------------------------------------------------------------------------
local FW_Throttle = FW:NEW2D();

function FW:RegisterThrottle(func,arg1) -- every same function will only be triggered 20x per second by default
	for i=1,FW_Throttle.rows,1 do
		 if FW_Throttle[i][1] == func and FW_Throttle[i][2] == arg1 then
			return;
		 end
	end
	FW_Throttle:insert(func,arg1);
end

local function FW_ExecuteThrottle()
	for i=1,FW_Throttle.rows,1 do
		--FW:Show(tostring(FW_Throttle[i][1]).."("..tostring(FW_Throttle[i][2])..")");
		FW_Throttle[i][1](FW_Throttle[i][2]);
	end
	FW_Throttle:erase();
end

function FW:RegisterORAMessage(start,func,ignorewithfw) -- note that the ora message recognition needs the function to give a return value to stop/break early
	tinsert(FW_oRAMessages,{"^"..start,func}); -- ignorewithfw IS DISABLED
end

function FW:RegisterMessage(start,func,merge) -- will always stop/break when a prefix match is found at this time
	tinsert(FW_Messages,{"^"..start,func});
end

function FW:RegisterSpecialSaved(saved,reset,default)
	SpecialSaved[saved] = reset;
	if FX_Saved[saved]==nil then  FX_Saved[saved] = default; end
end

function FW:RegisterOnProfileChange(func)
	tinsert(FilterRefresh,func);
end

-- the normal events aren't accurate enough in case of zoning for instance
function FW:RegisterOnLeaveCombat(func)
	tinsert(FW_OnLeaveCombat,func);
end
function FW:RegisterOnEnterCombat(func)
	tinsert(FW_OnEnterCombat,func);
end

function FW:RegisterScan(func)
	tinsert(FW_Scans,func);
end

function FW:AddCommand(k,f)
	Commands[k] = f;
end

function FW:GetFrame(name)
	return Frames[name];
end

function FW:UnregisterFrame(name)
	Frames[name]:Hide();
	Frames[name] = nil;
end

function FW:RegisterFrame(name,frame,combat_sensitive,instanceof)
	Frames[name] = frame;
	Frames[name].combat_sensitive = combat_sensitive;
	Frames[name].name = name;
	Frames[name].instanceof = instanceof; -- for defaults only?
end

function FW:RegisterVariablesEvent(func)
	tinsert(FW_VariablesLoaded,func);
end

--[[function FW:RegisterLoadEvent(func)
	tinsert(FW_Loaded,func);
end]]

function FW:RegisterDelayedLoadEvent(func)
	tinsert(FW_DelayedLoaded,func);
end
---------------------------------------------------------------------------
-- some local frame functions
---------------------------------------------------------------------------
function FW:GetCenter(frame)
	local x,y = frame:GetCenter()
	return x*frame:GetEffectiveScale(),y*frame:GetEffectiveScale();
end

function FW:RefreshFrames()
	for f,d in pairs(Frames) do
		d:Update();
	end
end

function FW:SetPosition(frame,x,y)
	frame:ClearAllPoints();
	frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/frame:GetEffectiveScale(), y/frame:GetEffectiveScale());
end

function FW:InitFrameVars(frame) -- also contains compatibility fixes (these should be removed at some point, e.g. ver2.00)
	if not frame.instanceof then -- for old style frames
		if not FW.Settings[frame.name] then
			FW.Settings[frame.name] = {};
		end
		frame.s = FW.Settings[frame.name];
	end
	if frame.s.lock == nil then -- init value
		frame.s.lock = false; -- never lock by default
	end
	if frame.s.alpha == nil then -- init value
		frame.s.alpha = frame.instanceof and FW.InstanceDefault[frame.instanceof].alpha or 1;
	end
	if frame.s.scale == nil then -- init value
		frame.s.scale = frame.instanceof and FW.InstanceDefault[frame.instanceof].scale or 1;
	end
	if frame.s.x == nil or frame.s.y == nil then
		frame.s.x,frame.s.y = FW:GetCenter(UIParent);
	elseif not frame.combat_sensitive or not FW.STATES.INCOMBAT then
		FW:SetPosition(frame,frame.s.x,frame.s.y);
	end
	if frame.name == "FWOptions" then
		_G["FWOptions"] = frame;
		tinsert(UISpecialFrames,"FWOptions");
	elseif FW.Settings.GlobalFrameNames then
		_G[frame.name] = frame;
	end
end

---------------------------------------------------------------------------
-- globally accessable
---------------------------------------------------------------------------

function FW:ToGroup(msg)
	if not FW.Settings["OutputRaid"] then return; end
	if IsInRaid() then
		SendChatMessage(msg,"RAID");
	elseif GetNumGroupMembers() > 0 then
		SendChatMessage(msg,"PARTY");
	else
		FW:Show(msg);
	end

end

function FW:ToChannel(msg)
	if not (FW.Settings["Output"] and FW.Settings["Output"][0]) then return; end
	if strlower(FW.Settings["Output"][1]) == "say" then
		SendChatMessage(msg,"SAY");
	elseif strlower(FW.Settings["Output"][1]) == "yell" then
		SendChatMessage(msg,"YELL");
	else
		local index = tonumber(FW.Settings["Output"][1]) or GetChannelName(FW.Settings["Output"][1]);
		if index then
			SendChatMessage(msg,"CHANNEL",nil,index);
		end
	end
end

function FW:PlaySound(option)
	if FW.Settings[option][0] then
		for i=1,FW.Settings[option][2],1 do
			PlaySoundFile(FW.Settings[option][1]);
		end
	end
end

function FW:MixColors(v,c1,c2)
	-- v == 0 then color = c1, v == 1 then color = c2
	if v<0 then v=0; elseif v>1 then v=1;end
	return c1[1]*(1-v)+c2[1]*v,c1[2]*(1-v)+c2[2]*v,c1[3]*(1-v)+c2[3]*v;
end

function FW:MixColors2(v,c1r,c1g,c1b,c2r,c2g,c2b)
	-- v == 0 then color = c1, v == 1 then color = c2
	if v<0 then v=0; elseif v>1 then v=1;end
	return c1r*(1-v)+c2r*v,c1g*(1-v)+c2g*v,c1b*(1-v)+c2b*v;
end

function FW:Whisper(msg,to)
	SendChatMessage(msg,"WHISPER",nil,to);
end

function FW:Size(t)
	local i = 0;
	for k, v in pairs(t) do i=i+1;end
	return i;
end

local loadclones = {};
function FW:RegisterLoadClones(func)
	tinsert(loadclones,func);
end

local function FW_InitClones()
	for i,f in ipairs(loadclones) do
		f();
	end
end

function FW:InstanceDelete(index,root)
	if #root.Instances > 1 then
		FW:InstanceSetLink(index,root,nil); -- manage links
		tremove(root.Instances,index);
		tremove(root.Data,index);
		if root.Active == index then -- update active
			root.Active = 1;
			return 1, 1;
		elseif root.Active > index then
			root.Active = root.Active - 1;
		end
		--[[for i,v in ipairs(root.Instances) do -- also keep index updated
			v.index = i;
		end]]
		return 1;
	end
end

function FW:InstanceCreate(name,root,data) -- create new profile or clone
	tinsert(root.Data,{name=name});
	local index = #root.Data;
	tinsert(root.Instances,{--[[index=index]]});
	FW_CopyNew(data,root.Instances[index]);
	
	FW:LinkOnCreate(index,root);

	return index;
end

function FW:UseProfile(index,onload)
	if not FX_Saved.Profiles.Instances[index] then -- make sure i always load a profile!!!!
		if FX_Saved.Profiles.Instances[FW.Saved.Profiles.Active] then
			index = FW.Saved.Profiles.Active;
		else
			index = 1;
		end
	end
	FW.Saved.Profiles.Active = index;
	FW.Saved.Profiles.Characters[FW:FullName()] = index;
	FW.Settings = FX_Saved.Profiles.Instances[index];
	FW_CopyNew(FW.Default,FW.Settings);
	
	FW_InitClones();
	FW:RefreshFrames(); -- also updates the settings tables of clones, so make sure this is called before doing anything with them
	if not onload then
		FW_RefreshAllFilters();
		FW:BuildOptions();
		FW:RefreshOptions();
	end	
end

function FW:InstanceNameToIndex(name,root,case) -- case insensitive by default
	if case then
		for i, v in ipairs(root.Data) do
			if v["name"] == name then
				return i;
			end
		end
	else
		for i, v in ipairs(root.Data) do
			if strlower(v["name"]) == strlower(name) then
				return i;
			end
		end
	end
end

function FW:InstanceIndexToName(index,root)
	return root.Data[index]["name"];
end

function FW:InstanceRename(index,newname,root)
	root.Data[index]["name"] = newname;
end

function FW:ShowTimeFor(spell,target,timeleft,iscooldown)
	if spell ~= target then -- really has a target
		if bit.band(1,FW.Settings.TimeLeft[0]) ~= 0 then
			FW:ToGroup( strformat( FW.Settings.TimeLeft[1],spell,target, FW:SecToTimeD(timeleft) ) );
		end
		if bit.band(2,FW.Settings.TimeLeft[0]) ~= 0 then
			FW:ToChannel( strformat( FW.Settings.TimeLeft[1],spell,target, FW:SecToTimeD(timeleft) ) );
		end
	else
		if iscooldown then
			if bit.band(1,FW.Settings.CooldownLeft[0]) ~= 0 then
				FW:ToGroup( strformat( FW.Settings.CooldownLeft[1],spell,FW:SecToTimeD(timeleft) ) );
			end
			if bit.band(2,FW.Settings.CooldownLeft[0]) ~= 0 then
				FW:ToChannel( strformat( FW.Settings.CooldownLeft[1],spell,FW:SecToTimeD(timeleft) ) );
			end
		else
			if bit.band(1,FW.Settings.TimeLeftNoTarg[0]) ~= 0 then
				FW:ToGroup( strformat( FW.Settings.TimeLeftNoTarg[1],spell,FW:SecToTimeD(timeleft) ) );
			end
			if bit.band(2,FW.Settings.TimeLeftNoTarg[0]) ~= 0 then
				FW:ToChannel( strformat( FW.Settings.TimeLeftNoTarg[1],spell,FW:SecToTimeD(timeleft) ) );
			end
		end
	end
end

function FW:MakeBackdrop(backdrop,bg,edge,tile,tilesize,edgesize)
	if not backdrop.insets then backdrop.insets = {}; end
	backdrop.bgFile = bg;
	backdrop.edgeFile = edge;
	backdrop.tile = tile;
	backdrop.tileSize = tilesize;
	backdrop.edgeSize = edgesize;
	backdrop.insets.left = edgesize;
	backdrop.insets.right = edgesize;
	backdrop.insets.top = edgesize;
	backdrop.insets.bottom = edgesize;
end

function FW:SetBackdrop(frame,bg,edge,tile,tilesize,edgesize)
	if not frame.backdrop then frame.backdrop = {}; end
	FW:MakeBackdrop(frame.backdrop,bg,edge,tile,tilesize,edgesize);
	frame:SetBackdrop(frame.backdrop);
end
---------------------------------------------------------------------------
-- template/option functions
---------------------------------------------------------------------------
local FW_Bindings = {};
function FW:RegisterButtonPress(bindingname,buttonname,button)
	tinsert(FW_Bindings, {bindingname,buttonname,button} );
end

local function FW_UpdateBindings()
	--FW:Show("update");
	if not STATES.INCOMBAT then
		for i,t in ipairs(FW_Bindings) do
			_G.ClearOverrideBindings(_G[t[2]]);
		end
		for i,t in ipairs(FW_Bindings) do
			local b1,b2 = _G.GetBindingKey(t[1]);
			if b1 then
				_G.SetOverrideBindingClick(_G[t[2]], false, b1,t[2],t[3]);
			end
			if b2 then
				_G.SetOverrideBindingClick(_G[t[2]], false, b2,t[2],t[3]);
			end
		end
	end
end

local function FW_ScanBags() -- send item counts regardless of installed modules to improve usefulness
	FW:Debug("scan bags");

	if not FX_Saved.Healthstone[FW.PLAYER] then
		FX_Saved.Healthstone[FW.PLAYER] = -1;
	end
	local t1 = FW:GotHealthstone();
	if FX_Saved.Healthstone[FW.PLAYER] ~= t1 then
		FX_Saved.Healthstone[FW.PLAYER] = t1;
		if STATES.GROUPED then
			FW:SendHealthstone(t1);
		end
	end
end
local function FW_ScanBagsChilled()
	FW:RegisterThrottle(FW_ScanBags);
end
---------------------------------------------------------------------------
-- options & events
---------------------------------------------------------------------------
FW:RegisterToEvent("VARIABLES_LOADED",FW_Variables);

-- things to do at load (after load delay)
FW:RegisterDelayedLoadEvent(FW_Scan);
FW:RegisterDelayedLoadEvent(FW_RelevantSetBonus);
FW:RegisterDelayedLoadEvent(FW_RelevantTalent);
FW:RegisterDelayedLoadEvent(FW_RelevantGlyph);
FW:RegisterDelayedLoadEvent(FW_RelevantStance);
FW:RegisterDelayedLoadEvent(FW_TimedRaidParty);
FW:RegisterDelayedLoadEvent(FW_PartyRaid);
--FW:RegisterDelayedLoadEvent(FW_MakeSpeccInfo);--doesnt work yet at load event
FW:RegisterDelayedLoadEvent(FW_ScanBagsChilled);

--FW:RegisterOnLeaveCombat(FW_InitFramePositions); -- this is just a 'backup' init

FW:RegisterScan(FW_RaidStatusScan);
FW:RegisterEnterPartyRaid( function(joined) if joined then FW_VersionCheck();end end );
--FW:RegisterEnterPartyRaid( function(joined) if joined then FW_GetSpeccInfo();end end );
	
-- done when all addon variables are loaded
FW:RegisterVariablesEvent(function()
	FW:RegisterToEvent("UPDATE_BINDINGS",			FW_UpdateBindings);

	FW:RegisterToEvent("PLAYER_REGEN_ENABLED",		FW_LeaveCombat);
	FW:RegisterToEvent("PLAYER_REGEN_DISABLED",		FW_EnterCombat);
	FW:RegisterToEvent("PLAYER_ALIVE",				FW_Ress)
	FW:RegisterToEvent("PLAYER_UNGHOST",			FW_Ress);
	FW:RegisterToEvent("PLAYER_LEAVING_WORLD",		function() LeaveCombat = 1; end);
	FW:RegisterToEvent("UNIT_INVENTORY_CHANGED",	function() FW:RegisterThrottle(FW_RelevantSetBonus);end);

	--FW:RegisterToEvent("INSPECT_TALENT_READY",		function() FW_MakeSpeccInfo(1); end);
	FW:RegisterToEvent("CHAT_MSG_ADDON",			FW_AddonMessageReceived);
	
	if not IsAddonMessagePrefixRegistered("FX2") then
		RegisterAddonMessagePrefix("FX2");
	end
	if not IsAddonMessagePrefixRegistered("oRA3") then
		RegisterAddonMessagePrefix("oRA3");
	end
	
	FW:RegisterToEvent("UNIT_PET", function(event,arg1) if arg1 == "player" then FW:Changed("pet");end end);

	FW:RegisterToEvent("GLYPH_ADDED", 	function() FW:RegisterThrottle(FW_RelevantGlyph); end);
	FW:RegisterToEvent("GLYPH_REMOVED", function() FW:RegisterThrottle(FW_RelevantGlyph); end);
	FW:RegisterToEvent("GLYPH_UPDATED", function() FW:RegisterThrottle(FW_RelevantGlyph); end);

	FW:RegisterToEvent("GROUP_ROSTER_UPDATE",FW_TimedRaidParty);

	FW:RegisterToEvent("BAG_UPDATE",FW_ScanBagsChilled);
	
	FW:RegisterToEvent("UI_SCALE_CHANGED",FW.RefreshFrames);
	--FW:RegisterToEvent("UI_SCALE_CHANGED",function() FW:Show("scale"); end);

	FW:RegisterTimedEvent("UpdateInterval",		FW_TimedRaidParty);
	FW:RegisterTimedEvent("UpdateInterval",		FW_Scan);
	FW:RegisterTimedEvent("Chill",				FW_ExecuteThrottle);
	
	FW:RegisterToEvent("PLAYER_TALENT_UPDATE",	FW_RelevantTalent);
	--FW:RegisterToEvent("PLAYER_TALENT_UPDATE",	function() FW_MakeSpeccInfo(nil); end);
	--FW:RegisterToEvent("PLAYER_TALENT_UPDATE",	function() FW_SendSpeccInfo(nil); end);
	
	FW:RegisterToEvent("UPDATE_SHAPESHIFT_FORM", FW_RelevantStance);
end);

SlashCmdList["FORTEXORCIST"] = function(msg)
	local s = strsplit(" ",msg);
	if Commands[s] then
		Commands[s]( strsub(msg,strlen(s)+2) );
	else
		FW:ToggleOptions();
	end
end
SLASH_FORTEXORCIST1 = "/fw";
SLASH_FORTEXORCIST2 = "/fortewarlock";
SLASH_FORTEXORCIST3 = "/fx";
SLASH_FORTEXORCIST4 = "/fortexorcist";
	
FW:AddCommand("commands",
	function()
		for k,v in pairs(Commands) do
			FW:Show(k,1,1,0);
		end
	end
);

FW:AddCommand("version",
	function()
		for k, v in pairs(FX_Saved.RaidStatus) do
			if v[4] then
				if type(v[4])=="string" then
					FW:Show(k.." FX: "..v[4]);
				else
					FW:Show(k.." FX: no, oRA3: yes" );
				end
			else
				FW:Show(k.." FX: no, oRA3: ??");
			end
		end
	end
);
	
local function FW_ResetOptionsFrame()
	FW.Frames["FWOptions"]:Reset();
end

FW:AddCommand("position",FW_ResetOptionsFrame);
FW:AddCommand("reset",FW_ResetOptionsFrame);

FW:AddCommand("resetall",
	function()
		_G.FX_Saved = {RESETTING=true}; -- also indicate that I'm currently resetting to avoid copying the backup
		ReloadUI();
	end
);
FW:AddCommand("usebackup",
	function()
		if FW:Size(FC_Saved) > 0 then -- check if backup is available
			_G.FX_Saved = {};
			ReloadUI();
		end
	end
);

FW:AddCommand("profile",
	function(profile)
		FW:UseProfile( FW:InstanceNameToIndex(profile,FX_Saved.Profiles) );
	end
);

FW:AddCommand("debug",
	function()
		FW_Debug = not FW_Debug;
		if FW_Debug then
			FW:Show("fw debugging enabled",1,1,0);
		else
			FW:Show("fw debugging disabled",1,1,0);
		end
	end
);
FW:AddCommand("wowbuild",
	function()
		local version, build, date, tocversion = GetBuildInfo();
		FW:Show("version:"..version..", build:"..build..", date:"..date..", tocversion:"..tocversion);
	end
);
FW:AddCommand("resetfont",
	function()
		FW.Settings.OptionsHeaderFont[1] = FW.Default.OptionsHeaderFont[1];
		FW.Settings.OptionsHeaderFont[2] = FW.Default.OptionsHeaderFont[2];
		FW.Settings.OptionsFont[1] = FW.Default.OptionsFont[1];
		FW.Settings.OptionsFont[2] = FW.Default.OptionsFont[2];
		FW:RefreshOptions();
	end
);

FW:RegisterMessage(FW.GET_HEALTHSTONE,
	function() 
		if FW.LastHSCheck + 5 < GetTime() then
			FW.LastHSCheck = GetTime();
			FW_CheckHealthstone();
		end
		return 1;
	end,
nil);
FW:RegisterMessage(GET_VERSION,FW_SendVersion,nil);
FW:RegisterMessage(SEND_VERSION,
	function(m,f)
		if FX_Saved.RaidStatus[f] then
			FX_Saved.RaidStatus[f][4] = m;
		else
			fx2temp[f] = a1;
		end
		return 1;
	end,
nil);
--[[FW:RegisterMessage(GET_SPECC,FW_SendSpeccInfo,nil);
FW:RegisterMessage(SEND_SPECC,
	function(m,f)
		local id = FW:NameToID(f);
		if id then
			local class = select(2,UnitClass(id));
			if not FX_Saved.Speccs[class] then
				FX_Saved.Speccs[class] = {};
			end
			FX_Saved.Speccs[class][f] =  m;
		end
		return 1;
	end,
nil);]]

FW.Default = {
	OptionsFontLabelColor = {1,1,1},
	OptionsFontInputColor = {1,1,1},

	AnimationInterval = 0.04,
	LoadDelay = 1,
	UpdateInterval = 0.5,
	Chill = 0.05,

	AnimateScroll = false,

	FrameSnapDistance = 5,
	FrameDistance = 0,
	FrameSnap = true,
	--FrameAnchor = false,
	OptionsColums = 2,
	OptionsHeight = 440,

	TimeFormat = true,
	Texture = "Interface\\AddOns\\Forte_Core\\Textures\\Aluminium",

	RightClickOptions = true,
	RightClickIconOptions = true,

	LinkProfile = false,
	LinkClone = false,

	OptionBackgroundColor =	{0.18,0.18,0.18,0.90},

	OptionHeaderColor = 	{0.20,0.20,0.20},
	LinkProfileColor = 		{[0]=true,1.00,1.00,0.00,0.10},
	LinkCloneColor = 		{[0]=true,1.00,0.50,0.00,0.10},
	LinkBothColor = 		{[0]=true,1.00,1.00,1.00,0.10},
	LinkNoneColor = 		{[0]=false,0.50,0.00,1.00,0.10},

	DiffProfileColor = 		{[0]=true,1.00,1.00,0.00,0.20},
	DiffCloneColor = 		{[0]=true,1.00,0.50,0.00,0.20},
	DiffBothColor = 		{[0]=true,1.00,1.00,1.00,0.20},
	DiffNoneColor = 		{[0]=false,0.00,1.00,0.00,0.20},

	Font = {"Interface\\AddOns\\Forte_Core\\Fonts\\GOTHIC.TTF",11},
	GlobalLock = false,
	GlobalAlpha = 1.0,
	GlobalScale = 1.0,
	GlobalSpark = {[0]=true,0.7},

	--SparkOverrideEnable = false,
	--SparkOverrideColor = {1.00,1.00,1.00},

	OutputRaid = true,
	Output = {[0]=true,"MyProChannel"},

	OptionsModuleColor = true,
	Tips = true,
	SpellGroupTips = true,

	TimeLeft = 			{[0]=1,">> %s on %s is fading in %s <<"},
	TimeLeftNoTarg =	{[0]=1,">> %s is fading in %s <<"},
	CooldownLeft = 		{[0]=1,">> %s is ready in %s <<"},

	GlobalFrameNames = false,

	Strata = "MEDIUM",

	ShowStartupText = true,
	ExpandSubcats = false,
	LoadExpandSubcats = true,

	OptionsBackdrop = {
		"Interface\\AddOns\\Forte_Core\\Textures\\Background",
		"Interface\\AddOns\\Forte_Core\\Textures\\Border",
		false,16,5,5
	},
	OptionsHeaderTexture = "Interface\\AddOns\\Forte_Core\\Textures\\Otravi",
	OptionsSubHeaderTexture = "Interface\\AddOns\\Forte_Core\\Textures\\Minimalist",
	
	TimerSpellsTooltip = true,
};
FW:SetDefaultFont("Interface\\AddOns\\Forte_Core\\Fonts\\GOTHIC.TTF", 11);