--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local CD = FW:Module("Cooldown",1);
local FW = FW;
local FWL = FW.L;
--local FILTER_ALL = 1;

local SORT_CD_ORDER =	{17,2,1};
local SORT_CD_ASC =		{true,true,true};

--local GROUP_TIME = 0.3;
local GROUP_TIME = 0.01;
local NUM_COOLDOWNS = 15;
local NUM_SPLASH = 5;

local FLAG_SPELL = "Spell";
local FLAG_PET = "Pet";
local FLAG_ITEM = "Item";
local FLAG_SOULSTONE = "Soulstone";
local FLAG_HEALTHSTONE = "Healthstone";
local FLAG_POTION = "Potion";
local FLAG_POWERUP = "Powerup";
local FLAG_INTERNAL = "Internal";
local FLAG_RES_TIMER = "ResTimer";
local FLAG_BUFF = "Buff";
local FLAG_DEBUFF = "Debuff";
local FLAG_ENCHANT = "Enchant";
CD.FLAG_BUFF = FLAG_BUFF;
CD.FLAG_ENCHANT = FLAG_ENCHANT;

local ORA3_COOLDOWN = FW.ORA3_COOLDOWN;
local focustime = 0.5;

local abs = math.abs;
local ceil = math.ceil;
local floor = math.floor;
local GetTime = GetTime;
local strfind = strfind;
local pairs = pairs;
local ipairs = ipairs;
local unpack = unpack;
local pow = math.pow;
local _G = _G;
local type = type;
local strformat = string.format;
local SendAddonMessage = SendAddonMessage;

local erase = FW.ERASE;
local UnitAura = FW.UnitAura;
local UnitName = FW.FullUnitName;

local FILTER_ALWAYS = FW.FILTER_ALWAYS;
local FILTER_SHOW_COLOR = FW.FILTER_SHOW_COLOR;
local FILTER_SHOW = FW.FILTER_SHOW;
local FILTER_NONE = FW.FILTER_NONE;
local FILTER_HIDE = FW.FILTER_HIDE;
local FILTER_COLOR = FW.FILTER_COLOR;

local STATES = FW.STATES;

-- add a group icon override system!
-- meaning: I want to set an override icon to certain cooldown names,
-- that mark the whole EXACTLY matching group with this icon, without
-- the switching between icons in this group
-- however, fading will still have to work for overlapping icons that
-- do not exactly match the cooldown
-- for example:
-- I want to have have my seperate runes in the cooldown bars, and only
-- display the rune icons (or the most important related spell) in it.
-- I probably need to add a swing cooldown as well, but this has to be tested.
-- Another non-DK example is a icon group for items sharing potion cooldown
-- and sharing HS cooldown.

local frame1;
local frame2;

local CD_SpecialCooldown = {
	{FWL.MANA_POTION,		FLAG_POTION},
	{FWL.HEALING_POTION,	FLAG_POTION},
	{FWL.PROTECTION_POTION,	FLAG_POTION},
	{(FW:SpellName(20707)),	FLAG_SOULSTONE},
	
	{FWL.HEALTHSTONE,		FLAG_HEALTHSTONE}, -- all healthstone types
	{(FW:ItemName(22797)),	FLAG_HEALTHSTONE}, -- nightmare seed
	{(FW:ItemName(22795)),	FLAG_HEALTHSTONE}, -- fel blossom
}


--FW.SpecialBuffs = {};
local SpecialBuffs = {};

local MASTER_MANA_POTION = "Interface\\Icons\\INV_Alchemy_Elixir_02";
local MASTER_HEALING_POTION = "Interface\\Icons\\INV_Alchemy_Elixir_05";
local MASTER_PROTECTION_POTION = "Interface\\Icons\\INV_Potion_123";
local MASTER_HEALTHSTONE = "Interface\\Icons\\INV_Stone_04";

local Masters = {
	{FWL.MANA_POTION,		MASTER_MANA_POTION},
	{FWL.HEALING_POTION,	MASTER_HEALING_POTION},
	{FWL.PROTECTION_POTION,	MASTER_PROTECTION_POTION},
	
	{FWL.HEALTHSTONE,				MASTER_HEALTHSTONE}, -- all healthstone types
	{"^"..FW:ItemName(22797).."$",	MASTER_HEALTHSTONE}, -- nightmare seed
	{"^"..FW:ItemName(22795).."$",	MASTER_HEALTHSTONE}, -- fel blossom
}
CD.Masters = Masters;
local function CD_IsMasterCooldown(spell,texture)
	for i,v in ipairs(Masters) do
		if strfind(spell,v[1]) then
			return v[2] or texture;
		end
	end
end

local function CD_FixItemName(arg1,arg2,arg3)
	if arg2 then
		local item,valid = FW:ItemName(arg2);
		if valid then
			return arg1..item..arg3;
		end
	end
	return arg1;
end
--items in CD_SpecialCooldown and Masters must be fixed if they are not loaded properly
--doing it like this is the easiest considering how everything is added atm, but can be changed at some point
local function CD_FixItemNamesIn(t)
	for i,v in ipairs(t) do
		v[1] = v[1]:gsub("(.*)item:(%d+)(.*)",CD_FixItemName,1);
	end
end

local function CD_FixItemNames()
	CD_FixItemNamesIn(CD_SpecialCooldown);
	CD_FixItemNamesIn(Masters);
end

--function FW:RegisterGroupMasterItem(item)
--	item = FW:ItemName(item)
--	
--end

--function FW:RegisterGroupMaster(spell)
--	spell = FW:SpellName(spell);
--
--end

local hiddencooldown = {};

function CD:AddHiddenCooldown(item,buff,hiddencd) -- not using 'item' atm
	buff = FW:SpellName(buff);
	hiddencooldown[buff] = hiddencd;
	return self;
end

function FixNameForFind(name)
	name = gsub(name,"%-","%%%-");
	name = gsub(name,"%(","%%%(");
	return gsub(name,"%)","%%%)");
end

function CD:AddCooldownPowerup(item,buff)	-- these are items
	
	tinsert(CD_SpecialCooldown,{"^"..(FixNameForFind(FW:ItemName(item))),FLAG_POWERUP,(FW:SpellName(buff))});
	return self;
end

function CD:AddCooldownBuff(buff)
	tinsert(SpecialBuffs,{"^"..(FixNameForFind(FW:SpellName(buff))),FLAG_BUFF});
	return self;
end

local FW_OnCooldownUsed = {};
local FW_OnCooldownReady = {};
local FW_OnCooldownUpdate = {};

local CooldownsSpells = {};
local CooldownsPet = {};
local CooldownsBuffs = {};
FW.CooldownsSpells = CooldownsSpells;--accessable for auto filling filters atm
FW.CooldownsPet = CooldownsPet;--accessable for auto filling filters atm
FW.CooldownsBuffs = CooldownsBuffs;

local first = {};
local last = {};
local focus = {};
local cooldownString = {}
local cd = FW:NEW2D();
CD.CD = cd;

local function CD_SplashShow()
	frame2:Update();
end

local function CD_CooldownShow()
	frame1:Update();
end

local function FlagToFilterIndex(flag)
	if flag == FLAG_BUFF or flag == FLAG_DEBUFF then
		return 2;
	else
		return 3;
	end
end

--1:all 2:buff/debuff 3:all other
local function FlagToFilter(frame,spell,flag)
	if frame.s.Filter[spell] then
		if flag == FLAG_BUFF or flag == FLAG_DEBUFF then
			if frame.s.Filter[spell][2] and frame.s.Filter[spell][2][1]~=0 then
				return frame.s.Filter[spell][2];
			end
		else
			if frame.s.Filter[spell][3] and frame.s.Filter[spell][3][1]~=0 then
				return frame.s.Filter[spell][3];
			end
		end
		if frame.s.Filter[spell][1] and frame.s.Filter[spell][1][1]~=0 then
			return frame.s.Filter[spell][1];
		end
	end
end

local function FlagToAction(frame,spell,flag)
	local filter = FlagToFilter(frame,spell,flag);
	if filter and filter[1] ~= FILTER_NONE then
		if filter[1] == FILTER_COLOR then
			if frame.s[flag][0] then
				return FILTER_COLOR;
			else
				return FILTER_HIDE;
			end
		else
			return filter[1];
		end
	else
		if frame.s[flag][0] then
			return FILTER_NONE; -- using this instead of FILTER_SHOW so i can still see if a custom buff needs to be added
		else
			return FILTER_HIDE;
		end		
	end
end

local function ColorVal(frame,flag,spell,custom)
	if custom == FILTER_COLOR or custom == FILTER_SHOW_COLOR then
		return unpack(FlagToFilter(frame,spell,flag),2,4);
	else
		return unpack(frame.s[ flag ]); -- default colors
	end
end

local function CD_DrawSplash()
	frame2:Draw();
end

local function CD_DrawCooldowns()
	frame1:Draw()
end

local function CD_MakeMasters(frame)
	local frame = frame1;
	
	for j=1,cd.rows,1 do -- reset all
		cd[j][19] = "";
	end
	
	if frame.s.GroupOverride then -- recalculate masters
		for j=1,cd.rows,1 do
			-- set master texture if any
			--if cd[j][17]==0 then -- visible
			local master = CD_IsMasterCooldown(cd[j][1],cd[j][5]) or "";
				--new now i want to set only one to master icon per group,
				--and set others to "slave" (indicating that they should be skipped on cycling)
				if master ~= "" then
					-- see if i can find a master that matches this spell
					for i=1,cd.rows,1 do
						if cd[i][19] == master --[[and cd[i][4] == cd[j][4] ]] and abs(cd[i][3]-cd[j][3])<GROUP_TIME then -- matches timings and not a master
							master = i;
							cd[j][17] = cd[i][17];
							break;
						end
					end
					if type(master) ~= "number" then -- this is a new master
						-- see if i can find any non-masters that matches this master
						for i=1,cd.rows,1 do
							if cd[i][19] == "" --[[and cd[i][4] == cd[j][4] ]] and abs(cd[i][3]-cd[j][3])<GROUP_TIME then -- matches timings and not a master
								cd[i][19] = j;
								cd[i][17] = cd[j][17];
							end
						end
					end
				else
					-- see if i can find a master that matches this spell, if so make slave
					for i=1,cd.rows,1 do
						if cd[i][19] ~= "" --[[and cd[i][4] == cd[j][4] ]] and abs(cd[i][3]-cd[i][3])<GROUP_TIME then -- match
							master = i;
							cd[j][17] = cd[i][17];
							break;
						end
					
					end
				end
				cd[j][19] = master;
				
			--end
		end
	end
	--FW.Saved.TEST = cd;
end

local function CD_StartCooldown(spell, start, duration, texture, flag)
	FW:Debug("New cd: "..spell);
	local frame = frame1;
	-- in the cooldown timer it's always important to know what's hidden and what's not, not only for the draw func!
	local action = FlagToAction(frame,spell,flag);
	cd:insert( spell,duration,start,duration,texture, flag ,0,0,0,0,0,0,0,0,0,GetTime(),0,action,"",0,(action == FILTER_HIDE and 1) or 0);
	CD_MakeMasters();
	for i,f in ipairs(FW_OnCooldownUsed) do
		f(spell,duration,flag,texture);
	end
end

local function CD_EndCooldown(i)
	local spell = cd[i][1];
	local flag = cd[i][6];

	CD_MakeMasters(); -- can be a huge performance impact for nothing, will be fixed
	
	if flag == FLAG_PET then
		CooldownsPet[spell][1] = 0;
		CooldownsPet[spell][2] = 0;
	elseif flag == FLAG_BUFF or flag == FLAG_DEBUFF then
		CooldownsBuffs[spell][1] = 0;
		CooldownsBuffs[spell][2] = 0;
	else	
		CooldownsSpells[spell][1] = 0;
		CooldownsSpells[spell][2] = 0;
	end

	FW:Debug("Cd over: "..spell);

	cd[i][2] = 0; -- expired
	--local ih = frame1.s.IconSizeEnable and frame1.s.IconSize or frame1.s.Height;
	local ih = frame1.s.Height;
	local v = 1-(frame1.s.Width-ih)/frame1.s.Width;
	cd[i][7] = v;
	v = v*frame1.s.Width;
	cd[i][9] = v;
	cd[i][10] = v-ih*0.5;
	cd[i][11] = v-ih;

	cd[i][15] = -1; -- expired
	cd[i][14] = 1;
	cd[i][20] = 0; -- undo any focussing by cast attempts
	
	for i,f in ipairs(FW_OnCooldownReady) do
		f(spell,flag);
	end
end

local function CD_IsSpecialCooldown(spell,buff) -- buff==1 for buff, buff==2 for debuff
	if buff then
		-- allow for buffs to be added that are set in the filter
		local action = FlagToAction(frame1,spell,buff);
		if action == FILTER_SHOW or action == FILTER_SHOW_COLOR then
			return buff;
		end
		for i,v in ipairs(SpecialBuffs) do
			if strfind(spell,v[1]) then
				return v[2];
			end
		end
	else
		for i,v in ipairs(CD_SpecialCooldown) do
			if strfind(spell,v[1]) then
				return v[2],v[3]; -- special flag, name to use (items get renamed to their buff name)
			end
		end
	end
end

local cooldowns;
function CD:CheckCooldown(spell,start,duration,texture,flag)
	--if not FW.Settings then return; end
	local IgnoreCooldown = FW.Settings and FW.Settings.IgnoreCooldown or 2.99;
	local index;
	if flag == FLAG_BUFF or flag == FLAG_DEBUFF then
		cooldowns = CooldownsBuffs;
	elseif flag == FLAG_PET then
		cooldowns = CooldownsPet;
	else
		cooldowns = CooldownsSpells;
	end			
	--if spell == "Haunt" then
	--	FW:Show(GetTime()..": "..start.." "..duration);
	--end
	local end_time = start+duration;
	if cooldowns[spell] then
		if start ~= cooldowns[spell][1] or duration ~= cooldowns[spell][2] then -- something changed in the duration
			
			if duration == 0 then -- no event fired when cd is over :|

				index = cd:find3(spell,1, flag,6, 0,15) or cd:find3(spell,1, flag,6, 1,15);
				if index then
					--FW:Debug("force cd over: "..spell);
					cd[index][3] = GetTime();
					cd[index][4] = duration;
					if texture~="" then
						cd[index][5] = texture;
					end			
					CD_EndCooldown(index);
				end
				
			-- greater than the hard minimum duration
			-- or if it decreased the already running cooldown, even if it's shorten than the hard minimum
			elseif duration > IgnoreCooldown or end_time < cooldowns[spell][1]+cooldowns[spell][2] then 
				--FW:Debug("DIFF: "..start-cooldowns[spell][1]);
				index = cd:find3(spell,1, flag,6, 0,15) or cd:find3(spell,1, flag,6, 1,15);
				if index then
					--FW:Debug("Change cd: "..spell);
					cd[index][3] = start;
					cd[index][4] = duration;
					cd[index][5] = texture;
					for i,f in ipairs(FW_OnCooldownUpdate) do
						f(spell,duration,flag,texture,end_time);
					end
				elseif duration > IgnoreCooldown then
					CD_StartCooldown(spell,start,duration,texture,flag);
				end
			end
			--FW:Debug("DIFF: "..start-cooldowns[spell][1]);
			cooldowns[spell][1] = start;
			cooldowns[spell][2] = duration;
			cooldowns[spell][3] = texture;
			cooldowns[spell][4] = flag;
		elseif texture~="" and cooldowns[spell][3] ~= texture then -- texture update only, also update master texture for runes
			cooldowns[spell][3] = texture;
			index = cd:find3(spell,1, flag,6, 0,15) or cd:find3(spell,1, flag,6, 1,15);
			if index then
				cd[index][5] = texture;
				if type(cd[index][19]) == "string" and cd[index][19] ~= "" then
					cd[index][19] = texture;
				end
				for i,f in ipairs(FW_OnCooldownUpdate) do
					f(spell,duration,flag,texture,end_time);
				end
			end
		end
	elseif duration > IgnoreCooldown then
		cooldowns[spell] = {start,duration,texture,flag};
		--if  then
			 CD_StartCooldown(spell,start,duration,texture,flag);
		--end
	end
end
function CD:HiddenCooldown(spell,duration,texture)
	CD:CheckCooldown(spell,GetTime(),duration,texture,FLAG_INTERNAL);
end

--[[ cd
1: spell
2: timer
3: start
4: duration
5: texture
6: flag

7: highest bar val (0-1)
8: lowest bar val (0-1)

9: highest bar pos
10: icon center
11: lowest pos icon
12: lowest bar pos

13: Sharing space (1-x group)
14: Visibility (0 to 1)
15: Focussed (0,1 or -1 for fading)
16: last update (REMOVE PLX)
17: filter (0 or 1) 0 actually means visible (not being filtered) this includes time filtering now
18: custom filter/color (any filter value)

19: master texture, "" for no master texture, "slave" for slave of master
20: grab attention time remaining (Change to not use lastupdate plx)
21: hidden based on standard filter (0 or 1) 0 actually means visible (not being filtered)
]]
local function CD_TimeFilterRemaining(frame,t) 
	return (not frame.s.MinRemaining[0] or frame.s.MinRemaining[1] <= t)
		and (not frame.s.MaxRemaining[0] or frame.s.MaxRemaining[1] >= t); 
end

local function CD_TimeFilterDuration(frame,d) 
	return (not frame.s.MinRange[0] or frame.s.MinRange[1] <= d)
		and (not frame.s.MaxRange[0] or frame.s.MaxRange[1] >= d);
end


local function CD_CreateCooldowns(frame)
	local frame = frame1;
	--local ih = frame.s.IconSizeEnable and frame.s.IconSize or frame.s.Height;
	local ih = frame.s.Height;
	local f1 = (frame.s.Width-ih)/frame.s.Width;
	local f2 = 1-f1;
	local tim = GetTime();
	local i=1;
	while i<=cd.rows do
		local t = cd[i][4]-tim+cd[i][3];
		if t<=-1 then
			cd:remove(i);
		elseif t<= 0 then
			if cd[i][2]>0 then CD_EndCooldown(i);end
			i=i+1;
		else
			local v;
			cd[i][2] = t;
			if t > frame.s.Max then
				v = 1;
			else
				v = f1*pow(t/frame.s.Max,frame.s.Loga)+f2;
			end
			cd[i][7] = v;
			v = v*frame.s.Width;
			cd[i][9] = v;
			cd[i][10] = v-ih*0.5;
			cd[i][11] = v-ih;
			
			if cd[i][20] > 1 then -- this timer is focussed by attempting to cast it
				cd[i][20] = cd[i][20] - (tim-cd[i][16]);
			end
			
			i=i+1;
		end
	end
	if not frame.s.Enable and not frame2.s.Enable then return; end
	
	cd:sort(SORT_CD_ORDER,SORT_CD_ASC);

	local s3,s7,s8,s9,s12 = 0,0,0,0,0;
	
	local group = 0;
	erase(first);
	erase(last);
	erase(focus);
	i=1;
	-- filter by time is still quick n dirty!
	while i<=cd.rows do
		if cd[i][21] == 1 or not CD_TimeFilterRemaining(frame,cd[i][2]) or not CD_TimeFilterDuration(frame,cd[i][4]) then
			cd[i][17] = 1;
		else
			cd[i][17] = 0;
		end
		i = i + 1;
	end
	i=1;
	while i<=cd.rows do
		local t1,t2,t3,t4,_,_,t7,t8,t9,t10,_,t12,_,_,t15,_,t17,_,t19,t20 = unpack(cd[i]);
		if t17 == 0 then -- determine if this timer will be visible
		
			if i > 1 and ((s9 > t10 and t2~=0) or (t2==0 and abs(t3-s3)<GROUP_TIME) ) then -- more than half an icon overlap
				-- for runes t3==s3 seems not to work well enough, a margin is needed
				last[group] = i;
				-- set the minimum coordinates
				t8,t12=s8,s12;
				cooldownString[group] = cooldownString[group].."\n"..FW:SecToTime(t2).." "..t1;
			else -- also done when i=1
				group = group+1;
				first[group] = i;
				last[group] = i;
				-- set the minimum coordinates
				t8,t12=s7,s9;
				cooldownString[group] = FW:SecToTime(t2).." "..t1;
			end
			
			cd[i][8] = t8;
			cd[i][12] = t12;
			cd[i][13] = group;

			if t15 ~= 0 then -- see if this icon was focussed, if so keep using this one for this group
				if not focus[group] and (type(t19) ~= "number" or t20 > 1) then -- only using focus to init the first visibility
					--FW:Show("keeping focus on "..i);
					focus[group] = i;
				else
					cd[i][14] = 0;
					cd[i][15] = 0;
				end
			end
			if t2~=0 then
				s7,s8,s9,s12 = t7,t8,t9,t12;
			end
			s3 = t3;
		end
		i=i+1;
	end
	for g,n in ipairs(first) do
		if not focus[g] then
			--FW:Show("correcting focus");
			cd[n][14] = 1;
			cd[n][15] = 1;
		end
	end
	i=1;
	-- add group specific code below
	-- if at least one group master icon is present, only switch between those!
	while i<=cd.rows do
		local t13,t14 = cd[i][13],cd[i][14];	
		if cd[i][15] == 1 and cd[i][17] == 0 then
			--if not CD_TimeFilterRemaining(frame,cd[i][2]) or not CD_TimeFilterDuration(frame,cd[i][4]) then
			--	FW:Show("have to fix");
			--end
			t14 = t14+(tim-cd[i][16]);
			if t14 >= 1 then
				t14 = 1;
				if last[t13] ~= first[t13] then
					local n = i;
					-- i is currently focussed but needs to change
					cd[i][15] = 0;
					while true do
						n=n+1;
						if n > last[t13] then
							n = first[t13];
						end
						if ( type(cd[n][19]) ~= "number" or cd[n][20] > 1) or n==i then -- also n==i to avoid inf loop on bugs
							cd[n][15] = 1; -- make this new one fade in
							cd[n][14] = 0; -- set its visibilty to zero just to make sure
							break;
						end
					end
				end
			end
		else
			t14 = t14-tim+cd[i][16];
			if t14 < 0 then t14 = 0; end	
		end
		cd[i][14] = t14;
		cd[i][16] = tim;
		i=i+1;
	end

	CD_DrawCooldowns();
	CD_DrawSplash();
end

local function CD_ResTimerCooldown()
	if GetCorpseRecoveryDelay()>0 then
		CD:CheckCooldown(FWL.RESURRECT_TIMER,GetTime(),GetCorpseRecoveryDelay(),"Interface\\Icons\\Ability_Creature_Cursed_02",FLAG_RES_TIMER);
	end
end

local GetSpellBookItemInfo = GetSpellBookItemInfo;
local GetSpellCooldown = GetSpellCooldown;

local GetActionInfo = GetActionInfo;
local GetItemInfo = GetItemInfo;
local GetItemCooldown = GetItemCooldown;
local GetContainerNumSlots = GetContainerNumSlots;
local GetContainerItemID = GetContainerItemID;
local GetPetActionInfo = GetPetActionInfo;
local GetPetActionCooldown = GetPetActionCooldown;
local GetInventoryItemID = GetInventoryItemID;

local function CD_ScanBagCooldowns()
	--FW:Debug("Scanning Bag");
	local _,spell,start,duration,texture;
	local id;
	local applies;
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			id = GetContainerItemID(bag,slot)
			if id then
				spell,_,_,_,_,_,_,_,_,texture = GetItemInfo(id);
				if spell then
					start,duration,applies = GetItemCooldown(id);
					if applies == 1  then
						local flag,name = CD_IsSpecialCooldown(spell);
						CD:CheckCooldown(name or spell,start,duration,texture,flag or FLAG_ITEM);
					end
				end
			end
		end
	end
end

local function CD_ScanPetCooldowns()
	--FW:Debug("Scanning Pet");
	local _,spell,start,duration,texture;
	local applies;
	for i=1, 10 do
		spell, _, texture = GetPetActionInfo(i);
		if spell then
			start, duration, applies = GetPetActionCooldown(i);
			if applies == 1 then
				CD:CheckCooldown(spell,start,duration,texture,(CD_IsSpecialCooldown(spell)) or FLAG_PET);
			end
		end
	end
end

local function CD_ScanActionCooldowns()
	--FW:Debug("Scanning Actions");
	local _,spell,start,duration,enabled,texture;
	local what,id;
	local applies;
	for i=1, 120 do
		what,id = GetActionInfo(i);
		if what == "item" then
			spell,_,_,_,_,_,_,_,_,texture = GetItemInfo(id);
			if spell then
				start,duration,applies = GetItemCooldown(id);
				if applies == 1 then
					local flag,name = CD_IsSpecialCooldown(spell);
					CD:CheckCooldown(name or spell,start,duration,texture,flag or FLAG_ITEM);
				end
			end
		elseif what == "spell" then
			spell,texture = FW:SpellName(id);
			start,duration,enabled = GetSpellCooldown(id);
			if enabled == 1 then -- Number - 0 if the spell is active (Stealth, Shadowmeld, Presence of Mind, etc) and the cooldown will begin as soon as the spell is used/cancelled; 1 otherwise. 
				CD:CheckCooldown(spell,start,duration,texture,(CD_IsSpecialCooldown(spell)) or FLAG_SPELL);
			end
		end
	end
	for i=1,19,1 do -- all equipable
		id = GetInventoryItemID("player",i);
		if id then
			spell,_,_,_,_,_,_,_,_,texture = GetItemInfo(id);
			if spell then
				start,duration,applies = GetItemCooldown(id);
				if applies == 1 then
					local flag,name = CD_IsSpecialCooldown(spell);
					CD:CheckCooldown(name or spell,start,duration,texture,flag or FLAG_ITEM);
				end
			end
		end
	end
end

local function CD_ScanBookCooldowns()
	--FW:Debug("Scanning Book");

	local i = 1;
	local spell,start,duration,enabled,texture;
	local m = FW:GetNumSpellBookSpells(); -- NOT WORKING CORRECTLY
	--FW:Show(m);
	while i <= m do
		--FW:Show(i);
		spell = select(2,GetSpellBookItemInfo(i,"player"));
		
		if spell then
			spell,texture = FW:SpellName(spell);--FW:Show(spell);
			start,duration,enabled = GetSpellCooldown(i,"player");
			if enabled == 1 then -- Number - 0 if the spell is active (Stealth, Shadowmeld, Presence of Mind, etc) and the cooldown will begin as soon as the spell is used/cancelled; 1 otherwise. 
				CD:CheckCooldown(spell,start,duration,texture,(CD_IsSpecialCooldown(spell)) or FLAG_SPELL);
			end
			i=i+1;
		else
			break;
		end
	end
	
	i=1;
	while true do -- NOT WORKING AT ALL
		--FW:Show(i);
		spell = select(2,GetSpellBookItemInfo(i,"pet"));
		
		if spell then
			spell,texture = FW:SpellName(spell);--FW:Show(spell);
			start,duration,enabled = GetSpellCooldown(i,"pet");
			if enabled == 1 then
				--FW:Show("moo");
				CD:CheckCooldown(spell,start,duration,texture,(CD_IsSpecialCooldown(spell)) or FLAG_PET);
			end
			i=i+1;
		else
			break;
		end
	end
	
end

local function CD_ScanBuffCooldowns()
	local i;
	for spell,data in pairs(CooldownsBuffs) do
		if data[2] ~= 0 then
			if not (UnitAura("player",spell) or UnitAura("player",spell,nil,"HARMFUL")) then
				CD:CheckCooldown(spell,GetTime(),0,data[3],data[4]);
			end
		end
	end

	i = 1;
	local flag;
	while true do
		local spell,_,texture,count,_,duration,expire = UnitAura("player",i);
		if spell then
			-- hidden cd code
			if hiddencooldown[spell] then
				CD:CheckCooldown(spell,expire-duration,hiddencooldown[spell],texture,FLAG_INTERNAL);
			end
			-- normal buff code
			flag = CD_IsSpecialCooldown(spell,FLAG_BUFF);
			if flag then
				CD:CheckCooldown(spell,expire-duration,duration,texture,flag);
			end
			i=i+1;
		else
			break;
		end
	end
	i = 1;
	while true do
		local spell,_,texture,count,_,duration,expire = UnitAura("player",i,"HARMFUL");
		if spell then
			-- hidden cd code
			if hiddencooldown[spell] then
				CD:CheckCooldown(spell,expire-duration,hiddencooldown[spell],texture,FLAG_INTERNAL);
			end
			CD:CheckCooldown(spell,expire-duration,duration,texture,CD_IsSpecialCooldown(spell,FLAG_DEBUFF) or FLAG_DEBUFF);
			i=i+1;
		else
			break;
		end
	end
end

local select = select;
local GetInventoryItemTexture = GetInventoryItemTexture;
local function CD_ScanWeaponEnchant()
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges, hasThrownEnchant, thrownExpiration, thrownCharges = GetWeaponEnchantInfo();
	--FW:Show("scan");
	if hasMainHandEnchant then
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_MAIN,GetTime(),mainHandExpiration*0.001,GetInventoryItemTexture("player",select(1,GetInventorySlotInfo("MainHandSlot"))),FLAG_ENCHANT);
	else
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_MAIN,GetTime(),0,"",FLAG_ENCHANT);
	end
	if hasOffHandEnchant then
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_OFFHAND,GetTime(),offHandExpiration*0.001,GetInventoryItemTexture("player",select(1,GetInventorySlotInfo("SecondaryHandSlot"))),FLAG_ENCHANT);
	else
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_OFFHAND,GetTime(),0,"",FLAG_ENCHANT);
	end
	if hasThrownEnchant then
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_RANGED,GetTime(),thrownExpiration*0.001,GetInventoryItemTexture("player",select(1,GetInventorySlotInfo("RangedSlot"))),FLAG_ENCHANT);
	else
		CD:CheckCooldown(FWL.WEAPON_ENCHANT_RANGED,GetTime(),0,"",FLAG_ENCHANT);
	end
end

local function CD_ScanCooldowns()
	CD_ScanActionCooldowns();
	CD_ScanBookCooldowns();
	CD_ScanBagCooldowns();
	CD_ScanPetCooldowns();
	CD_ScanBuffCooldowns();
	CD_ScanWeaponEnchant();
end

--[[function FW:SCAN()
CD_ScanCooldowns();
end]]

local function CD_FocusTimer(i)
	-- FW:Show(cd[i][1]); -- shown or not, all active cooldowns are present
	-- now focus this icon within the group
	local group = cd[i][13];
	if group > 0 then -- got a group
		if first[group] then
			for j=first[group],last[group],1 do -- set all of this group to non-focussed
				cd[j][15] = 0;
				cd[j][14] = 0;
			end
		end
		cd[i][15] = 1;
		cd[i][14] = 1;
		cd[i][20] = 1 + focustime;
		
	end
end

---------------------------------------------------------------------------
-- globally accessable
---------------------------------------------------------------------------
function CD:RegisterOnCooldownUsed(func)
	tinsert(FW_OnCooldownUsed,func)
end

function CD:RegisterOnCooldownReady(func)
	tinsert(FW_OnCooldownReady,func)
end

function CD:RegisterOnCooldownUpdate(func)
	tinsert(FW_OnCooldownUpdate,func)
end


local function Splash_OnClick(button)
	if FW:Moved() then return; end
	if button == "RightButton" then
		FW:ScrollTo(FWL.SECONDARY_SPLASH);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

local function Frame_OnClick(button)
	if FW:Moved() then return; end
	if button == "RightButton" then
		FW:ScrollTo(FWL.COOLDOWN_TIMER);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

local function CD_ShowTimeFor(id)
	FW:ShowTimeFor(cd[id][1],cd[id][1],cd[id][2],cd[id][6]~=FLAG_BUFF and cd[id][6]~=FLAG_DEBUFF and cd[id][6]~=FLAG_ENCHANT);
end

if not _G["oRA3"] then -- don't do this if you have ora3
	if FW.CLASS == "DRUID" then
		local rebirth = FW:SpellName(FW.FLAG.DRUID);
		CD:RegisterOnCooldownUsed(function(s,cd)
			if s == rebirth and STATES.GROUPED then
				SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.DRUID,cd),"RAID");
			end
		end)
	elseif FW.CLASS == "SHAMAN" then
		local reinc = FW:SpellName(FW.FLAG.SHAMAN);
		CD:RegisterOnCooldownUsed(function(s,cd)
			if s == reinc and STATES.GROUPED then
				SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.SHAMAN,cd),"RAID");
			end
		end)
	elseif FW.CLASS == "PALADIN" then
		local di = FW:SpellName(FW.FLAG.PALADIN);
		CD:RegisterOnCooldownUsed(function(s,cd)
			if s == di and STATES.GROUPED then
				SendAddonMessage("oRA3",strformat(ORA3_COOLDOWN,FW.FLAG.PALADIN,cd),"RAID");
			end
		end)
	end
end

local function CD_CastFailed(event,unit,spell,sub,num,spellid) -- items that are on cooldown trigger a fail of their effects
	spell = FW:SpellName(spellid);
	if unit == "player" or unit == "pet" then
		for i=cd.rows,1,-1 do
			if cd[i][1] == spell and cd[i][6] ~= FLAG_BUFF and cd[i][6] ~= FLAG_DEBUFF then
				--FW:Show(spell);
				CD_FocusTimer(i);
				return;
			end
		end
	end
end

local function CD_SpellFailed()
	local frame = frame1;
	if frame.s.Warn then
		FW:RegisterToEvent("UNIT_SPELLCAST_FAILED",CD_CastFailed);
	else
		FW:UnregisterToEvent("UNIT_SPELLCAST_FAILED",CD_CastFailed);
	end
end

local function NewIcon(parent,n)
	local icon;
	parent.icons[n] = CreateFrame("Frame",nil,parent);
	icon = parent.icons[n];
	icon.parent = parent;
	icon:SetPoint("CENTER",parent,"CENTER",0,0);
	
	icon.texture = icon:CreateTexture(nil,"ARTWORK");
	icon.texture:SetTexture("Interface\\Icons\\Spell_Shadow_LastingAfflictions");
	icon.texture:SetAllPoints(icon);
	
	icon.spark = icon:CreateTexture(nil,"OVERLAY");
	icon.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	icon.spark:SetBlendMode("ADD");
	icon.spark:SetPoint("CENTER",icon,"CENTER",0,0);
	
	icon.Update = function(self)
		if self.parent.s.SplashGlow then
			self.texture:SetTexCoord(0.133,0.867,0.133,0.867);
			self.spark:Show();
		else
			self.texture:SetTexCoord(0,1,0,1);
			self.spark:Hide();
		end
	end
	icon:Update();
	return icon;
end

local function CD_NewSplashFrame(index)
	local frame = CreateFrame("Frame",nil,UIParent);
	frame.parent = UIParent;
	frame.index = index;
	frame.icons = {};
		
	--scripts
	frame:SetScript("OnMouseDown",function(self,button) FW:StartMoving(self,button); end);
	frame:SetScript("OnMouseUp",function(self,button) FW:StopMoving(self);	Splash_OnClick(button); end);

	--functions
	frame.NewIcon = NewIcon;
	frame.Finalize = function(self,i)
		while self.icons[i] and self.icons[i]:IsShown() do
			self.icons[i]:Hide();
			i=i+1;
		end
	end;
	frame.Draw = function(self)
		if not self:IsShown() then return; end
		local s = self.s;
		local index=1;
		local i = 1;
		local s1;
		local icon;

		while index <= cd.rows do
			if cd[index][14] > 0 and cd[index][17]==0 and cd[index][15]==-1 then
				icon = self.icons[i] or self:NewIcon(i);
				if cd[index][19] ~= "" and cd[index][19] ~= "slave" --[[ and cd[index][20] <= 1]] then
					icon.texture:SetTexture(cd[index][19]);
				else
					icon.texture:SetTexture(cd[index][5]);
				end
				s1 = 0.5-cd[index][14];
				s1= 1-4*s1*s1;
				icon:SetAlpha(s1*s.alpha);
				s1=32*(s.scale+(s.SecondSplashMax-s.scale)*s1);
				icon:SetWidth(s1);
				icon:SetHeight(s1);
				if s.SplashGlow then
					icon.spark:SetWidth(s1*2.2);
					icon.spark:SetHeight(s1*2.2);
					icon.spark:SetVertexColor(FW:FixIntensity(ColorVal(frame1,cd[index][6],cd[index][1],cd[index][18])));
				end
				icon:Show();
				i = i + 1;
			end
			index = index + 1;
		end
		if s.Enable and not s.lock and i==1 then
			icon = self.icons[i] or self:NewIcon(i);
			icon:SetAlpha(s.alpha);
			icon:SetWidth(32*s.scale);
			icon:SetHeight(32*s.scale);
			icon.spark:SetWidth(32*s.scale*2.2);
			icon.spark:SetHeight(32*s.scale*2.2);
			icon:Show();
			i = i + 1;
		end
		self:Finalize(i);
	end
	frame.Init = function(self)
		self.s = FW.Settings.Splash.Instances[self.index] or FW.Settings;
		FW:InitFrameVars(self);
	end
	frame.Update = function(self)
		if self.s.Enable then
			self:EnableMouse(not self.s.lock);
			self:SetAlpha(self.s.alpha);
			self:SetWidth(32*self.s.scale);
			self:SetHeight(32*self.s.scale);
			for i, icon in ipairs(self.icons) do
				icon:Update();
			end
			FW:CorrectPosition(self);
			self:SetFrameStrata(FW.Settings.SplashStrata);
			self:Show();
			self:Draw();
		else
			self:Hide();
		end
	end;
	return frame;
end

local function NewBar(parent,n)
	local bar;
	parent.bars[n] = CreateFrame("Frame",nil,parent);
	bar = parent.bars[n];
	bar.parent = parent;
	
	bar.splashiconspark = bar:CreateTexture(nil,"OVERLAY");
	bar.splashiconspark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	bar.splashiconspark:SetBlendMode("ADD");
	bar.splashiconspark:SetPoint("CENTER",bar,"CENTER");

	bar.splashicon = bar:CreateTexture(nil,"OVERLAY");
	bar.splashicon:SetPoint("CENTER",bar,"CENTER");

	bar.texture = bar:CreateTexture(nil,"ARTWORK");
	bar.texture:SetAllPoints(bar);
	
	-- icon
	bar.icon = CreateFrame("Button",nil,bar);
	bar.icon:SetPoint("CENTER",bar,"CENTER",0,0);

	bar.icon.attentionspark = bar.icon:CreateTexture(nil,"OVERLAY");
	bar.icon.attentionspark:SetPoint("CENTER",bar.icon,"CENTER");
	bar.icon.attentionspark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	bar.icon.attentionspark:SetBlendMode("ADD");
	
	bar.icon.spark = bar.icon:CreateTexture(nil,"OVERLAY");
	bar.icon.spark:SetPoint("CENTER",bar.icon,"CENTER");
	bar.icon.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	bar.icon.spark:SetBlendMode("ADD");
	
	bar.icon:SetNormalTexture("Interface\\TutorialFrame\\TutorialFrameAlert");
	bar.icon.texture = bar.icon:GetNormalTexture();
	bar.icon.texture:SetTexCoord(0.133,0.867,0.133,0.867);
	
	bar.tag = bar.icon:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.tag:SetJustifyH("CENTER");
	bar.tag:SetPoint("BOTTOMLEFT", bar.icon, "BOTTOMLEFT", 0, 0);
	
	--scripts
	bar.icon:SetScript("OnClick",function(self,button) 
		if button == "RightButton" then
			if FW.Settings.RightClickIconOptions then
				FW:ScrollTo(FWL.COOLDOWN_TIMER.." Color",1);
				FW:SetFilterName(FWL.COOLDOWN_TIMER.." Filter",cd[bar.id][1],FlagToFilterIndex(cd[bar.id][6]));
			end
		else
			if IsShiftKeyDown() then
				--put on ignore once
			else
				-- show duration
				CD_ShowTimeFor(bar.id);
			end
		end
	end);
	bar.icon:SetScript("OnEnter",function(self)
		self.over=1;
		FW:ShowTip(self);
	end);
	bar.icon:SetScript("OnLeave",function(self)
		self.over=nil;
		FW:HideTip(self);
	end);
	bar.icon:SetScript("OnUpdate",function(self)
		if self.over and self.oldtitle ~= self.title then
			self.oldtitle = self.title;
			FW:ShowTip(self);
		end
	end);
	bar.icon:RegisterForClicks("RightButtonUp","LeftButtonUp");

	--functions
	bar.Update = function(self)
		local s = self.parent.s;
		local ih = s.IconSize[0] and s.IconSize[1] or s.Height;
		self.texture:SetTexture(s.Texture);
		self.icon:SetWidth(ih);
		self.icon:SetHeight(ih);

		if s.Spark[0] then
			self.icon.spark:SetWidth((ih)*2.2);
			self.icon.spark:SetHeight((ih)*2.2);
			self.icon.spark:SetAlpha(s.Spark[1]);
			self.icon.spark:Show();
		else
			self.icon.spark:Hide();
		end
		if s.IconTime then
			self.tag:SetFont(unpack(s.IconFont));
			self.tag:Show();
		else
			self.tag:Hide();
		end		
		self:SetPoint("TOPLEFT", self.parent, "TOPLEFT", s.Backdrop[6],-s.Backdrop[6]);
		self:SetPoint("BOTTOMRIGHT", self.parent, "BOTTOMRIGHT", -s.Backdrop[6],s.Backdrop[6]);
		
		--local d = ih*0.5;
		local d = s.Height*0.5;
		local a,b,c;
		if s.Vertical then
			if s.Flip then
				a,b,c =  "TOP",0,-d;
			else
				a,b,c =  "BOTTOM",0,d;
			end
		else
			if s.Flip then
				a,b,c = "RIGHT",-d,0;
			else
				a,b,c = "LEFT",d,0;
			end
		end
		self.splashicon:SetPoint("CENTER",self,a,b,c);
		self.splashiconspark:SetPoint("CENTER",self,a,b,c);
	end;
	bar:Update();
	return bar;
end

local function NewTag(parent,n)
	local tag;
	parent.tags[n] = parent.tagsframe:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	tag = parent.tags[n];
	tag.parent = parent.tagsframe;
	tag:SetJustifyH("CENTER");
	return tag;
end

local tags = {};
local function CD_NewCooldownFrame(index)
	local frame = CreateFrame("Frame",nil,UIParent);
	frame.parent = UIParent;
	frame.index = index;
	---frame.displayname = displayname;
	frame.bars = {};
	frame.tags = {};
	
	frame.tagsframe = CreateFrame("Frame",nil,frame);
	frame.tagsframe:SetAllPoints(frame);
	
	frame:SetPoint("CENTER",UIParent,"CENTER");	
	frame:SetHeight(20);

	frame.back = frame:CreateTexture(nil,"OVERLAY");
	frame.back:SetPoint("TOPLEFT",frame,"TOPLEFT",3,-3);
	frame.back:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-3,3);
	frame.back:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
	
	--scripts
	frame:SetScript("OnMouseDown",function(self,button) FW:StartMoving(self, button);end);
	frame:SetScript("OnMouseUp",function(self,button) FW:StopMoving(self);	Frame_OnClick(button); end);

	--functions
	frame.NewBar = NewBar;
	frame.NewTag = NewTag;
	
	frame.SetTimeTags = function(self)
		
		local s = self.s;
		local ih = s.Height;
		
		if s.CustomTags[0] then
			--local ih = s.IconSizeEnable and s.IconSize or s.Height;
			local f1 = (s.Width-ih)/s.Width;
			local f2 = 1-f1;
			local val;
			local a,b,c;
			local tag;
			local i = 1;
			
			while #tags > 0 do
				tremove(tags);
			end
			for k,v in s.CustomTags[1]:gmatch("(%d+)") do
				--FW:Show(k);
				tinsert(tags,tonumber(k));
			end
			local v;
			while i <= #tags do
				v = tags[i];
				if v < s.Max then
					val = f1*pow(v/s.Max,s.Loga)+f2;
					local d = s.Backdrop[6]+val*(s.Width)-ih*0.5;
					if s.Vertical then
						if s.Flip then a,b,c = "TOP",0,-d;else a,b,c = "BOTTOM",0,d;end
					else
						if s.Flip then a,b,c = "RIGHT",-d,0;else a,b,c = "LEFT",d,0;end
					end
					tag = self.tags[i] or self:NewTag(i);
					tag:SetPoint("CENTER",self,a,b,c);
					if v>60 then v=(v/60);end
					tag:SetText(v);
					tag:SetFont(unpack(s.Font));
					tag:SetTextColor(unpack(s.TextColor));
					tag:Show();
					i=i+1;
				else
					break;
				end
			end
			v = s.Max;
			local d = s.Backdrop[6]+(s.Width)-ih*0.5;
			if s.Vertical then
				if s.Flip then a,b,c = "TOP",0,-d;else a,b,c = "BOTTOM",0,d;end
			else
				if s.Flip then a,b,c = "RIGHT",-d,0;else a,b,c = "LEFT",d,0;end
			end
			tag = self.tags[i] or self:NewTag(i);
			tag:SetPoint("CENTER",self,a,b,c);
			if v>60 then v=(v/60);end
			tag:SetText(v);
			tag:SetFont(unpack(s.Font));
			tag:SetTextColor(unpack(s.TextColor));
			tag:Show();
			i=i+1;
			while self.tags[i] and self.tags[i]:IsShown() do
				self.tags[i]:Hide();
				i=i+1;
			end
		else
			local a,b,c;
			local tag;
			local i = 0;
			local f1 = (s.Width-ih);
			local interval = 1/(s.Tags-1);

			while i < s.Tags do

				local v = pow( i*interval, 1/s.Loga); -- 0-1 value factor on the tags
				local d = s.Backdrop[6] + ih*0.5;
				
				v=v*s.Max; -- convert to actual time
				
				if v>60 then
					v=(v/60);
					v = FW:RoundTo(v,0.5); -- round v down to a whole number
					d = d + pow(v*60/s.Max,s.Loga)*f1;
				else
					v = FW:RoundTo(v,1); -- round v down to a whole number
					d = d + pow(v/s.Max,s.Loga)*f1;
				end
				
				if s.Vertical then
					if s.Flip then a,b,c = "TOP",0,-d;else a,b,c = "BOTTOM",0,d;end
				else
					if s.Flip then a,b,c = "RIGHT",-d,0;else a,b,c = "LEFT",d,0;end
				end
				i = i + 1;
				tag = self.tags[i] or self:NewTag(i);
				tag:SetPoint("CENTER",self,a,b,c);
					
				tag:SetText(v);
				tag:SetFont(unpack(s.Font));
				tag:SetTextColor(unpack(s.TextColor));
				tag:Show();
			end
			i = i + 1;
			while self.tags[i] and self.tags[i]:IsShown() do
				self.tags[i]:Hide();
				i=i+1;
			end
		end
	end
	frame.Finalize = function(self,i)
		while self.bars[i] and self.bars[i]:IsShown() do
			self.bars[i]:Hide();
			i=i+1;
		end
	end;
	frame.Draw = function(self)
		local s = self.s;
		if s.Enable and (not s.lock or not (s.Hide and not cd:find(0,17)) and not (s.HideCombat and not STATES.INCOMBAT) ) then -- auto-hide only
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
		
		local ih = s.IconSize[0] and s.IconSize[1] or s.Height;
		local _,t1,t2,t5,t6,t7,t8,t9,t10,t12,t13,t14,t15,t17,t18,t19,t20;
		local index=1;
		local i=1;
		local bar;
		while index <= cd.rows do
			t1,t2,_,_,t5,t6,t7,t8,t9,t10,_,t12,t13,t14,t15,_,t17,t18,t19,t20 = unpack(cd[index]);
			if t14 > 0 and t17==0 then
				bar = self.bars[i] or self:NewBar(i);
				if type(t19) ~= "number" and t19 ~= "" then -- use master texture if i have one
					t5 = t19; 
				end
				bar.icon:EnableMouse( t15==1 );
				bar.icon.title = FW:SecToTime(t2).." "..t1;
				bar.icon.tip = cooldownString[t13];
				bar.id = index;
				if s.Splash and t15==-1 then
					local size = s.SplashFactor*ih*(1-t14);
					bar.splashicon:SetTexture(t5);
					bar.splashicon:SetWidth(size);
					bar.splashicon:SetHeight(size);				
					if s.Spark[0] then
						bar.splashiconspark:SetWidth( 2.2*size);
						bar.splashiconspark:SetHeight( 2.2*size);
						bar.splashicon:SetTexCoord(0.133,0.867,0.133,0.867);
						bar.splashiconspark:Show();
					else
						bar.splashicon:SetTexCoord(0,1,0,1);
						bar.splashiconspark:Hide();
					end
					bar.splashicon:Show();
				else
					bar.splashicon:Hide();
					bar.splashiconspark:Hide();
				end
				--if t2>60 then t2=ceil(t2/60) else t2=floor(t2) end;
				bar.icon:SetNormalTexture(t5);
				bar.tag:SetText(FW:SecToTimeD(t2));
				bar:SetAlpha(t14);
				local r,g,b = ColorVal(self,t6,t1,t18);
				--local a = 1-(1-s.Alpha)*t7;
				local a = s.AlphaMax-(s.AlphaMax-s.Alpha)*t7;
				bar.texture:SetVertexColor(r,g,b,a);
				r,g,b = FW:FixIntensity(r,g,b);
				if t20>1 then -- attention pulse
					local size = 2.2*ih*(t20);
					bar.icon.attentionspark:SetWidth(size);
					bar.icon.attentionspark:SetHeight(size);
					bar.icon.attentionspark:SetVertexColor(r,g,b);
					bar.icon.attentionspark:Show();
				else
					bar.icon.attentionspark:Hide();
				end
				bar.icon.spark:SetVertexColor(r,g,b);
				bar.splashiconspark:SetVertexColor(r,g,b);
				if s.IconTime then
					if s.IconTextColor[0] then
						bar.tag:SetTextColor(unpack(s.IconTextColor));
					else
						bar.tag:SetTextColor(r,g,b);
					end
				end
				bar.texture:ClearAllPoints();
				if s.Vertical then
					if s.Flip then
						bar.texture:SetTexCoord(t8,0,t7,0, t8,1, t7,1);
						bar.texture:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, s.Width-t9);
						bar.texture:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, -t12);	
						bar.icon:SetPoint("CENTER", bar, "TOP", 0, -t10);
					else
						bar.texture:SetTexCoord(t7,0,t8,0, t7,1, t8,1);
						bar.texture:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, t9-s.Width);
						bar.texture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, t12);	
						bar.icon:SetPoint("CENTER", bar, "BOTTOM", 0, t10);
					end
				else
					if s.Flip then
						bar.texture:SetTexCoord(t7,0, t7,1, t8,0, t8,1);
						bar.texture:SetPoint("TOPRIGHT", bar, "TOPRIGHT",-t12, 0);
						bar.texture:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", s.Width-t9, 0);
						bar.icon:SetPoint("CENTER",bar, "RIGHT", -t10, 0);
					else
						bar.texture:SetTexCoord(t8,0, t8,1, t7,0, t7,1);
						bar.texture:SetPoint("TOPLEFT", bar, "TOPLEFT", t12, 0);
						bar.texture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", t9-s.Width, 0);
						bar.icon:SetPoint("CENTER", bar, "LEFT", t10, 0);
					end
				end
				bar:Show();
				i=i+1;
			end
			index=index+1;
		end
		self:Finalize(i);
	end
	frame.Init = function(self)
		self.s = FW.Settings.Cooldown.Instances[self.index];
		FW:InitFrameVars(self);
	end
	
	frame.Update = function(self)
		if self.s.Enable then
			self:EnableMouse( not self.s.lock );
			self:SetAlpha(self.s.alpha);
			self:SetScale(self.s.scale);

			self.back:SetTexture(self.s.Texture);
			self.back:SetVertexColor(unpack(self.s.BarColor));
			FW:SetBackdrop(self,unpack(self.s.Backdrop));
			self:SetBackdropColor(unpack(self.s.BgColor));
			self:SetBackdropBorderColor(unpack(self.s.BgColor));
			
			if self.s.Vertical then
				self:SetWidth(self.s.Height+self.s.Backdrop[6]*2);
				self:SetHeight(self.s.Width+self.s.Backdrop[6]*2);
				self.back:SetTexCoord(1,0, 0,0, 1,1, 0,1);
			else
				self:SetWidth(self.s.Width+self.s.Backdrop[6]*2);
				self:SetHeight(self.s.Height+self.s.Backdrop[6]*2);
				self.back:SetTexCoord(0,0, 0,1, 1,0, 1,1);
			end	
			for b, bar in ipairs(self.bars) do
				bar:Update();
			end
			self:SetTimeTags();
			FW:CorrectPosition(self);
			self:SetFrameStrata(FW.Settings.CooldownStrata);
			self:Show();
			self:Draw();
		else
			self:Hide();
		end
	end;
	return frame;
end

local function CD_CooldownFilterChange(frame) --this needs to include the entire fix
	-- dirty - but works for now
	local i = 1;
	while i <= cd.rows do
		if cd[i][6] == FLAG_BUFF then
			CooldownsBuffs[cd[i][1]][1] = 0;
			CooldownsBuffs[cd[i][1]][2] = 0;
			cd:remove(i);
		else
			i=i+1;
		end
	end
	
	for i=1,cd.rows,1 do
		local action = FlagToAction(frame1,cd[i][1],cd[i][6]);
		if action == FILTER_HIDE then
			cd[i][21] = 1;
		else
			cd[i][21] = 0;
		end
		cd[i][18] = action;
	end
	CD_ScanBuffCooldowns();
	CD_MakeMasters();
end

CD.FilterChange = CD_CooldownFilterChange;

FW:RegisterLoadClones(function() -- will be replaced by proper clone management similar to Spell Timer
	if FW.Settings.Cooldown then
		FW:CopyCloneSettings(FW.InstanceDefault.Cooldown,FW.Settings.Cooldown.Instances[1]);
	else
		-- create one instance by default
		FW.Settings.Cooldown = {Active=1,Instance="Cooldown",Instances={},Data={}, Links={}};
		FW:InstanceCreate(FWL.COOLDOWN_TIMER,FW.Settings.Cooldown,FW.InstanceDefault.Cooldown);
	end
	if not frame1 then
		frame1 = CD_NewCooldownFrame(1);
		FW:RegisterFrame("FX_Cooldown1",frame1,false,"Cooldown");
	end
	frame1:Init();
	if FW.Settings.Splash then
		FW:CopyCloneSettings(FW.InstanceDefault.Splash,FW.Settings.Splash.Instances[1]);
	else
		-- create one instance by default
		FW.Settings.Splash = {Active=1,Instance="Splash",Instances={}, Links={}, Data={}};
		FW:InstanceCreate(FWL.SECONDARY_SPLASH,FW.Settings.Splash,FW.InstanceDefault.Splash);
	end
	if not frame2 then
		frame2 = CD_NewSplashFrame(1);
		FW:RegisterFrame("FX_Splash1",frame2,false,"Splash");
	end
	frame2:Init();
end);

FW:RegisterDelayedLoadEvent(CD_ScanCooldowns);
FW:RegisterDelayedLoadEvent(CD_ResTimerCooldown);

FW:RegisterVariablesEvent(function()
	FW:RegisterToEvent("SPELL_UPDATE_COOLDOWN",		function() FW:RegisterThrottle(CD_ScanBookCooldowns);end);
	FW:RegisterToEvent("ACTIONBAR_UPDATE_COOLDOWN",	function() FW:RegisterThrottle(CD_ScanActionCooldowns);end);
	FW:RegisterToEvent("PET_BAR_UPDATE_COOLDOWN",	function() FW:RegisterThrottle(CD_ScanPetCooldowns);end);
	FW:RegisterToEvent("BAG_UPDATE_COOLDOWN",		CD_ScanBagCooldowns);
	FW:RegisterToEvent("BAG_UPDATE",				function() FW:RegisterThrottle(CD_ScanBookCooldowns);end);
	FW:RegisterToEvent("PLAYER_DEAD",				function() FW:RegisterThrottle(CD_ResTimerCooldown);end);
	FW:RegisterToEvent("UNIT_AURA",					function(event,arg1) if arg1=="player" then FW:RegisterThrottle(CD_ScanBuffCooldowns);end end);
	FW:RegisterToEvent("UNIT_INVENTORY_CHANGED",	function(event,arg1) if arg1=="player" then FW:RegisterThrottle(CD_ScanWeaponEnchant);end end);
	FW:RegisterTimedEvent("AnimationInterval",	CD_CreateCooldowns);
	
	CD_FixItemNames(); -- WORKS WHEN TRIGGERED HERE :)
	CD_SpellFailed();
	
end);

FW:RegisterOnProfileChange(CD_CooldownFilterChange);
FW:RegisterOnProfileChange(CD_MakeMasters);
FW:RegisterOnProfileChange(CD_SpellFailed);

CD:AddCooldownBuff(59230);--well fed

-- global melee trinket names
function CD:AddMeleePowerupCooldowns()
	self:AddCooldownPowerup(37166,60305) -- Sphere of Red Dragon's Blood,  Heart of a Dragon
	:AddCooldownPowerup(38259,50263) -- First Mate's Pocketwatch, Quickness of the Sailor
	:AddCooldownPowerup(45263,64800) -- Wrathstone, Wrathstone
	:AddCooldownPowerup(48020,67746) -- Vengeance of the Forsaken, Risen Fury	
	:AddCooldownPowerup(41093,54758) -- Hyperspeed Accelerators, Hyperspeed Acceleration	
	:AddCooldownPowerup(48722,67683) -- Shard of the Crystal Heart, Celerity
	:AddCooldownPowerup(59515,92213) -- Vial of Stolen Memories, Memory of Invincibility
	
	:AddHiddenCooldown(29301,35081,45) -- Band of the Eternal Champion, Band of the Eternal Champion
	:AddHiddenCooldown(40684,60065,45) -- Mirror of Truth, Reflection of Torment
	:AddHiddenCooldown(45286,65014,45) -- Pyrite Infuser, Pyrite Infusion
	:AddHiddenCooldown(40256,60437,45) -- Grim Toll, Grim Toll
	:AddHiddenCooldown(45522,64790,45) -- Blood of the Old God, Blood of the Old God
	:AddHiddenCooldown(42987,60229,45) -- Darkmoon Card: Greatness, Greatness, str
	:AddHiddenCooldown(44253,60233,45) -- Darkmoon Card: Greatness, Greatness, agi
	:AddHiddenCooldown(45931,65020,45) -- Mjolnir Runestone, Mjolnir Runestone
	:AddHiddenCooldown(47303,67708,45) -- Death's Choice, Paragon, str
	:AddHiddenCooldown(47214,67671,45) -- Banner of Victory, Fury
	:AddHiddenCooldown(50343,71541,45) -- Whispering Fanged Skull, Icy Rage
	:AddHiddenCooldown(50198,71403,45) -- Needle-Encrusted Scorpion, Fatal Flaws
	:AddHiddenCooldown(50363,71485,105) -- Deathbringer's Will, Agility of the Vrykul
	--:AddHiddenCooldown(50363,71487,105) -- Deathbringer's Will, Precision of the Iron Dwarves
	:AddHiddenCooldown(50363,71561,105) -- Deathbringer's Will, Strength of the Taunka
	:AddHiddenCooldown(50363,71491,105) -- Deathbringer's Will, Aim of the Iron Dwarves
	:AddHiddenCooldown(50363,71486,105) -- Deathbringer's Will, Power of the Taunka
	:AddHiddenCooldown(50363,71492,105) -- Deathbringer's Will, Speed of the Vrykul
	:AddHiddenCooldown(50404,72414,60) -- Ashen Band of Endless Courage, Frostforged Defender
	:AddHiddenCooldown(50402,72412,60) -- Ashen Band of Endless Vengeance, Frostforged Champion
	:AddHiddenCooldown(54590,75456,45) -- Sharpened Twilight Scale, Piercing Twilight
	:AddHiddenCooldown(54591,75480,45) -- Petrified Twilight Scale, Scaly Nimbleness
	
	:AddHiddenCooldown(56102,92096,50) -- Left Eye of Rajh, Eye of Vengeance 
	:AddHiddenCooldown(55795,92069,75) -- Key to the Endless Chamber, Final Key
	:AddHiddenCooldown(59473,92126,50) -- Essence of the Cyclone, Twisted 
	:AddHiddenCooldown(59520,92108,50) -- Unheeded Warning, Heedless Carnage 
	:AddHiddenCooldown(59441,92124,75) -- Prestor's Talisman of Machination, Nefarious Plot 
	:AddHiddenCooldown(55266,92052,100) -- Grace of the Herald, Herald of Doom
	:AddHiddenCooldown(59506,91821,75) -- Crushing Weight, Race Against Death
	:AddHiddenCooldown(59224,91816,100) -- Heart of Rage, Rageheart
	
	:AddHiddenCooldown(61046,85032,45) -- Vicious Gladiator's Insignia of Victory, Surge of Victory
	:AddHiddenCooldown(68994,96977,105) -- Matrix Restabilizer, Matrix Restabilized
	:AddHiddenCooldown(68927,96911,60) -- The Hungerer, Devour
	:AddHiddenCooldown(77202,107982,115) -- Starcatcher Compass, Velocity
	:AddHiddenCooldown(77205,107988,115) -- Creche of the Final Dragon, Find Weakness
	
	:AddHiddenCooldown(nil,59626,35) -- Black Magic
	:AddHiddenCooldown(nil,59620,35) -- Berserk, Enchant Weapon - Berserking
	:AddHiddenCooldown(nil,28093,35) -- Lightning Speed, Enchant Weapon - Mongoose
	
	:AddHiddenCooldown(nil,125489,55) -- Enchant Cloak - Swordguard Embroidery
end

-- global caster trinket names
function CD:AddCasterPowerupCooldowns()
	self:AddCooldownPowerup(23046,28779) -- The Restained Essence of Sapphiron, Essence of Sapphiron
	:AddCooldownPowerup(29179,35337) -- Xi'ri's Gift, Spell Power
	:AddCooldownPowerup(29370,35163) -- Icon of the Silver Crescent, Blessing of the Silver Crescent
	:AddCooldownPowerup(32483,40396) -- The Skull of Gul'dan, Fel Infusion
	:AddCooldownPowerup(19950,24659) -- Zandalarian Hero Charm, Unstable Power
	:AddCooldownPowerup(28040,33662) -- Vengeance of the Illidari
	:AddCooldownPowerup(33829,43712) -- Hex Shrunken Head, Mojo Madness
	:AddCooldownPowerup(35700,46783) -- Figurine - Crimson Serpent, Crimson Serpent
	:AddCooldownPowerup(38213,48846) -- Harbingers's Wrath, Runic Infusion
	:AddCooldownPowerup(37555,48846) -- Warsong's Wrath, Runic Infusion
	:AddCooldownPowerup(45466,64707) -- Scale of Fates, Scale of Fates
	:AddCooldownPowerup(45148,64712) -- Living Flame, Living Flame
	:AddCooldownPowerup(50259,71564) -- Nevermelting Ice Crystal, Deadly Precision
	:AddCooldownPowerup(48722,67683) -- Shard of the Crystal Heart, Celerity
	:AddCooldownPowerup(41093,54758) -- Hyperspeed Accelerators, Hyperspeed Acceleration	
	:AddCooldownPowerup(37873,60480) -- Mark of the War Prisoner, Mark of the War Prisoner	
	:AddCooldownPowerup(59514,91041) -- Heart of Ignacious, Heart's Judgement
	:AddCooldownPowerup(70142,100403) -- Moonwell Chalice, Blessing of the Moonwell
	
	:AddHiddenCooldown(27683,44605,18) -- Quagmirran's Eye, Spell Haste
	:AddHiddenCooldown(30626,38348,45) -- Sextant of Unstable Currents, Unstable Currents
	:AddHiddenCooldown(29305,35084,45) -- Band of the Eternal Sage, Band of the Eternal Sage
	:AddHiddenCooldown(40682,60064,45) -- Sundial of the Exiled, Now is the time!
	:AddHiddenCooldown(39229,60492,45) -- Embrace of the Spider, Embrace of the Spider
	:AddHiddenCooldown(44254,60234,45) -- Darkmoon Card: Greatness, Greatness, int
	:AddHiddenCooldown(44255,60235,45) -- Darkmoon Card: Greatness, Greatness, spi
	:AddHiddenCooldown(46017,64411,45) -- Val'anyr, Hammer of Ancient Kings, Blessing of Ancient Kings 
	:AddHiddenCooldown(50398,72416,60) -- Ashen Band of Endless Destruction, Frostforged Sage
	:AddHiddenCooldown(50400,72418,60) -- Ashen Band of Endless Wisdom, Item - Icecrown Reputation Ring Healer Effect
	:AddHiddenCooldown(50353,71601,45) -- Dislodged Foreign Object, Surge of Power
	:AddHiddenCooldown(47213,67669,45) -- Abyssal Rune, Elusive Power
	:AddHiddenCooldown(50360,71605,90) -- Phylactery of the Nameless Lich, Siphoned Power
	:AddHiddenCooldown(54588,75473,45) -- Charred Twilight Scale, Twilight Flames
	:AddHiddenCooldown(54589,75494,45) -- Glowing Twilight Scale, Twilight Renewal
	
	:AddHiddenCooldown(55819,91138,45) -- Tear of Blood, Cleansing Tears
	:AddHiddenCooldown(55995,91147,105) -- Blood of Isiset, Blessing of Isiset
	:AddHiddenCooldown(62470,91047,75) -- Stump of Time, Battle Magic
	:AddHiddenCooldown(62047,89091,45) -- Darkmoon Card: Volcano, Volcanic Destruction
	
	:AddHiddenCooldown(59326,91007,100) -- Bell of Enraging Resonance, Dire Magic
	:AddHiddenCooldown(59519,91024,90) -- Theralion's Mirror, Revelation
	:AddHiddenCooldown(62472,91192,50) -- Mandala of Stirring Patterns, Pattern of Light
	
	:AddHiddenCooldown(56320,90887,75) -- Witching Hourglass, Witching Hour
	:AddHiddenCooldown(59500,91184,75) -- Fall of Mortality, Grounded Soul
	:AddHiddenCooldown(77204,107982,120) -- Seal of the Seven Signs, Velocity
	:AddHiddenCooldown(77203,107982,110) -- Insignia of the Corrupted Mind, Velocity
	:AddHiddenCooldown(77190,107804,45) -- Ti'tahk, the Steps of Time, Slowing the Sands
	:AddHiddenCooldown(72898,102662,45) -- Foul Gift of the Demon Lord, Foul Gift
	
	:AddHiddenCooldown(69149,96966,45) -- Eye of Blazing Power, Blaze of Life -- WONT WORK BECAUSE NO BUFF
    :AddHiddenCooldown(77209,108000,20) -- Windward Heart, Nick of Time -- WONT WORK BECAUSE NO BUFF

	:AddHiddenCooldown(nil,59626,35) -- Black Magic
	:AddHiddenCooldown(nil,125487,65) -- Lightweave
	:AddHiddenCooldown(nil,74241,45) -- Enchant Weapon - Power Torrent
end

FW:SetMainCategory(FWL.COOLDOWN_TIMER,FW.ICON.CD,4,"COOLDOWN",nil,"Cooldown")
	:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
		:AddOption("INF",FWL.CD_HINT1)
		:AddOption("INF",FWL.CD_HINT2)
		:AddOption("INF",FWL.CD_HINT3)
		
	:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND)
		:AddOption("CHK",FWL.ENABLE,	FWL.CD_BASIC1_TT,	"Enable"):SetFunc(CD_CooldownShow)
		--:AddOption("CHK","Test Bars",	"",	"CooldownTest",CD_Test)
		:AddOption("CHK",FWL.CD_SPECIFIC2,	FWL.CD_SPECIFIC2_TT,	"Vertical"):SetFunc(CD_CooldownShow)
		:AddOption("CHK",FWL.FLIP_BAR,		FWL.FLIP_BAR_TT,		"Flip"):SetFunc(CD_CooldownShow)
		:AddOption("CHK",FWL.CD_SPECIFIC3,	FWL.CD_SPECIFIC3_TT,	"Hide")
		:AddOption("CHK",FWL.TIMER_HIDE,	FWL.TIMER_HIDE_TT,		"HideCombat")

	:SetSubCategory(FWL.SPECIFIC,FW.ICON.SPECIFIC,3)
		--:AddOption("CHK",FWL.CD_SPECIFIC5,	FWL.CD_SPECIFIC5_TT,	"Detail",		CD_CooldownShow)
		:AddOption("CHK",FWL.MASTER_ICONS,	FWL.MASTER_ICONS_TT,	"GroupOverride"):SetFunc(CD_MakeMasters)
		:AddOption("NU2",FWL.SHOW_GLOW, 	FWL.SHOW_GLOW_TT..FWL._EDITBOX_TRANSPARENCY,"Spark"):SetRange(0,1):SetFunc(CD_CooldownShow)
		:AddOption("CHK",FWL.CD_WARNING,	FWL.CD_WARNING_TT,		"Warn"):SetFunc(CD_SpellFailed)
		:AddOption("")
		:AddOption("NUM",FWL.CD_SPECIFIC9,	FWL.CD_SPECIFIC9_TT,	"Alpha"):SetRange(0,1)
		:AddOption("NUM",FWL.CD_SPECIFIC10,	FWL.CD_SPECIFIC10_TT,	"AlphaMax"):SetRange(0,1)
		:AddOption("CHK",FWL.ICON_TEXT,		FWL.ICON_TEXT_TT,		"IconTime"):SetFunc(CD_CooldownShow)
		:AddOption("CO2",FWL.ICON_TEXT_COLOR,FWL.ICON_TEXT_COLOR_TT,"IconTextColor"):SetFunc(CD_CooldownShow):SetEnabled("IconTime")
		:AddOption("FNT",FWL.ICON_FONT,		FWL.ICON_TEXT_TT,		"IconFont"):SetFunc(CD_CooldownShow):SetEnabled("IconTime")
	
	:SetSubCategory(FWL.CD_SPLASH,FW.ICON.GLOW,3)
		:AddOption("CHK",FWL.CD_SPLASH1,	FWL.CD_SPLASH1_TT,		"Splash")
		:AddOption("NUM",FWL.CD_SPLASH2,	FWL.CD_SPLASH2_TT,		"SplashFactor"):SetRange(1):SetEnabled("Splash")
				
	:SetSubCategory(FWL.TIME_RANGE,FW.ICON.TIME,4)	
		:AddOption("NUM",FWL.CD_SPECIFIC6,	FWL.CD_SPECIFIC6_TT,	"Max"):SetRange(5):SetFunc(CD_CooldownShow)
		:AddOption("NUM",FWL.USE_POWER_OF,	FWL.USE_POWER_OF_TT,	"Loga"):SetRange(0.1,1):SetFunc(CD_CooldownShow)
		:AddOption("NU2",FWL.MIN_DURATION,	FWL.MIN_DURATION_TT,	"MinRange"):SetRange(0):SetFunc(CD_CooldownFilterChange)
		:AddOption("NU2",FWL.MAX_DURATION,	FWL.MAX_DURATION_TT,	"MaxRange"):SetRange(0):SetFunc(CD_CooldownFilterChange)
		:AddOption("NU2",FWL.MIN_REMAINING,FWL.MIN_REMAINING_TT,	"MinRemaining"):SetRange(0):SetFunc(CD_CooldownFilterChange)
		:AddOption("NU2",FWL.MAX_REMAINING,FWL.MAX_REMAINING_TT,	"MaxRemaining"):SetRange(0):SetFunc(CD_CooldownFilterChange)
		:AddOption("NUM",FWL.NUM_TIME_TAGS,FWL.NUM_TIME_TAGS_TT,	"Tags"):SetRange(2):SetEnabled("not CustomTags"):SetFunc(CD_CooldownShow)
		:AddOption("MSG",FWL.CUSTOM_TAGS,	FWL.CUSTOM_TAGS_TT,		"CustomTags"):SetFunc(CD_CooldownShow)

	:SetSubCategory(FWL.COLORING_FILTERING,FW.ICON.FILTER,5)
		:AddOption("FIL",FWL.CUSTOMIZE,	FWL.CD_CUSTOMIZE_TT,	"Filter",99):SetRange(FW.FilterListOptions, FW.CDFilterListOptions):SetFunc(CD_CooldownFilterChange)

	:SetSubCategory(FWL.MY_COOLDOWNS,FW.ICON.FILTER,5,nil,FW.REDUCED_ALPHA)
		:AddOption("CO2",FWL.SPELL,					"",	"Spell"):SetFunc(CD_CooldownFilterChange)
		:AddOption("CO2",FWL.PET,					"",	"Pet"):SetFunc(CD_CooldownFilterChange)
		:AddOption("CO2",FWL.ITEM,					"",	"Item"):SetFunc(CD_CooldownFilterChange)
		:AddOption("CO2",FWL.POWERUP,				"",	"Powerup"):SetFunc(CD_CooldownFilterChange):SetSpellList(CD_SpecialCooldown,2,1)
		:AddOption("CO2","Internal/Hidden",			"",	"Internal"):SetFunc(CD_CooldownFilterChange):SetSpellList(hiddencooldown)
		:AddOption("CO2",FWL.POTION,				"",	"Potion"):SetFunc(CD_CooldownFilterChange):SetSpellList(CD_SpecialCooldown,2,1)
		:AddOption("CO2",FWL.HEALTHSTONE_NORMAL,	"",	"Healthstone"):SetFunc(CD_CooldownFilterChange):SetSpellList(CD_SpecialCooldown,2,1)
		:AddOption("CO2",FWL.SS,					"",	"Soulstone"):SetFunc(CD_CooldownFilterChange):SetSpellList(CD_SpecialCooldown,2,1)
		:AddOption("CO2",FWL.RESURRECT_TIMER,		"",	"ResTimer"):SetFunc(CD_CooldownFilterChange)
	
	:SetSubCategory(FWL.BUFFS_DEBUFFS_ON_ME,FW.ICON.FILTER,5,nil,FW.REDUCED_ALPHA)	
		:AddOption("CO2",FWL.BUFF,		FWL.CD_SPECIFIC7_TT,	"Buff"):SetFunc(CD_CooldownFilterChange):SetSpellList(SpecialBuffs,2,1)
		:AddOption("CO2",FWL.ALL_OTHER_BUFFS,	"",				"BuffOther"):SetFunc(CD_CooldownFilterChange):SetEnabled(false)
		:AddOption("CO2",FWL.DEBUFF,			"",				"Debuff"):SetFunc(CD_CooldownFilterChange)
		:AddOption("CO2",FWL.ALL_OTHER_DEBUFFS,	"",				"DebuffOther"):SetFunc(CD_CooldownFilterChange):SetEnabled(false)
		:AddOption("CO2",FWL.WEAPON_ENCHANT,	"",				"Enchant"):SetFunc(CD_CooldownFilterChange)

	:SetSubCategory(FWL.SIZING,FW.ICON.SIZE,6)	
		:AddOption("NUM",FWL.BAR_WIDTH,			"",			"Width"):SetRange(0):SetFunc(CD_CooldownShow)
		:AddOption("NUM",FWL.BAR_HEIGHT,		"",			"Height"):SetRange(0):SetFunc(CD_CooldownShow)
		:AddOption("NU2",FWL.ICON_SIZE,FWL.ICON_SIZE_TT,	"IconSize"):SetRange(0):SetFunc(CD_CooldownShow)

	:SetSubCategory(FWL.APPEARANCE,FW.ICON.APPEARANCE,7)
		:AddOption("COL",FWL.BAR,				"",			"BarColor"):SetFunc(CD_CooldownShow)
		:AddOption("COL",FWL.FRAME_BACKGROUND,	"",			"BgColor"):SetFunc(CD_CooldownShow)
		:AddOption("COL",FWL.BAR_TEXT,			"",			"TextColor"):SetFunc(CD_CooldownShow)
		:AddOption("FNT",FWL.BAR_FONT,			"",			"Font"):SetFunc(CD_CooldownShow)
		:AddOption("TXT",FWL.BAR_TEXTURE,		"",			"Texture"):SetFunc(CD_CooldownShow)
		:AddOption("BAC",FWL.BACKDROP,			"",			"Backdrop",99):SetFunc(CD_CooldownShow)

:SetMainCategory(FWL.SECONDARY_SPLASH,FW.ICON.CD,4,"COOLDOWN",nil,"Splash")
	:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
		:AddOption("INF",FWL.CD_SPLASH_HINT1)
		:AddOption("INF",FWL.CD_SPLASH_HINT2)
		
	:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND)
		:AddOption("CHK",FWL.CD_SPLASH3,	FWL.CD_SPLASH3_TT,	"Enable"):SetFunc(CD_SplashShow)
		
	:SetSubCategory(FWL.SPECIFIC,FW.ICON.SPECIFIC,3)
		:AddOption("NUM",FWL.CD_SPLASH2,	FWL.CD_SPLASH2_TT,	"SecondSplashMax"):SetRange(0.1)
		:AddOption("CHK",FWL.SHOW_GLOW, 	FWL.SHOW_GLOW_TT,	"SplashGlow"):SetFunc(CD_SplashShow)

:SetMainCategory(FWL.RAID_MESSAGES)
	:SetSubCategory(FWL.FADING,FW.ICON.SPECIFIC,2)
		:AddOption("INF",FWL.TIME_LEFT_HINT)
		:AddOption("MS2",FWL.COOLDOWN_LEFT,		"",	"CooldownLeft")
		:AddOption("MS2",FWL.TIME_LEFT_NOTARGET,"",	"TimeLeftNoTarg")
		
:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT")
	:SetSubCategory(FWL.COOLDOWN_TIMER,FW.ICON.DEFAULT,4)
		:AddOption("STR",FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"CooldownStrata"):SetFunc(CD_CooldownShow)
		:AddOption("NUM",FWL.MIN_DURATION,	"",					"IgnoreCooldown"):SetRange(2)
	:SetSubCategory(FWL.SECONDARY_SPLASH,FW.ICON.DEFAULT,4)
		:AddOption("STR",FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"SplashStrata"):SetFunc(CD_SplashShow)
		
-- globally used
FW.Default.IgnoreCooldown = 2.99;
FW.Default.CooldownStrata = FW.Default.Strata;
FW.Default.SplashStrata = FW.Default.Strata;

-- cooldown frame properties only
FW.InstanceDefault.Cooldown = {
	Enable = true,
	Width = 250,
	Height = 24,
	IconSize = {[0]=false,36},
	Font = FW.Default.Font,
	Texture = FW.Default.Texture,
	Vertical = false,
	Flip = false,
	IconFont = {FW.Default.Font[1],FW.Default.Font[2]-1,"OUTLINE"},
	Splash = true,
	SplashFactor = 4,
	Hide = false,
	HideCombat = false,
	Max = 300,
	Detail = true,
	Ignore = true,
	Alpha = 0.2,
	AlphaMax = 1.0,
	Spark = {[0]=true,1},
	Warn = true,
	GroupOverride = true,
	Swing = false,
	Test = false,

	MinRange = 		{[0]=false,0},
	MaxRange = 		{[0]=false,3600},
	MinRemaining = 	{[0]=false,0},
	MaxRemaining = 	{[0]=false,3600},

	Loga = 0.33,	
	Tags = 6,
	CustomTags = {[0]=true,"0 1 10 30 60 120 300 600"}, --[[900 1200 1800 2700 3600 5400]]

	IconTime = true,

	IconTextColor =		{[0]=false,1.00,1.00,1.00,1.00},
	TextColor = 		{1.00,1.00,1.00,0.20},
	BgColor = 			{0.00,0.00,0.00,0.50},
	BarColor = 			{1.00,1.00,1.00,0.20},

	Potion =		{[0]=true,0.00,1.00,0.00},
	Healthstone =	{[0]=true,0.00,1.00,0.50},
	Spell = 		{[0]=true,1.00,0.50,0.00},
	Pet = 			{[0]=true,1.00,0.00,0.95},
	Powerup =		{[0]=true,0.00,0.75,1.00},
	Internal =		{[0]=true,0.00,0.60,0.85},
	Item =			{[0]=true,1.00,1.00,0.00},
	ResTimer =		{[0]=true,1.00,0.00,0.00},
	Buff =			{[0]=true,1.00,1.00,1.00},
	BuffOther =		{[0]=false,0.50,0.50,0.50},
	Debuff =		{[0]=true,1.00,0.00,0.00},
	DebuffOther =	{[0]=false,0.50,0.00,0.00},
	Enchant =		{[0]=true,1.00,1.00,1.00},
	Soulstone =		{[0]=true,0.64,0.21,0.93},

	Backdrop = {
		"Interface\\AddOns\\Forte_Core\\Textures\\Background",
		"Interface\\AddOns\\Forte_Core\\Textures\\Border",
		false,16,5,3
	},

	Filter = {
		[FW:SpellName(11196)] = {nil,{-2,1,0.65,0}} --recently bandaged
	},
};

FW.InstanceDefault.Splash = {
	Enable = false,
	SecondSplashMax = 4,
	SplashGlow = true,
	alpha = 0.7,
	scale = 2,
};