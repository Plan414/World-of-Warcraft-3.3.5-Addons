--[[
    This code is responsible for creating the events and API associated with duration spells.
--]]
AsheylaLib:Package( "DoTimer" );
DoTimer = AsheylaLib:NewModule("DoTimer");

local TIME_REMAINING = "DOTIMER_TIME_REMAINING";

DoTimer.HELPFUL_TYPE = "HELPFUL";
DoTimer.HARMFUL_TYPE = "HARMFUL";

local GetTime = GetTime;
local match = string.match;
local abs = math.abs;
local floor = math.floor;
local lower = string.lower;
local find = string.find;
local gmatch = string.gmatch;
local GetSpellName, GetSpellTexture, UnitExists, UnitIsUnit, UnitCanAttack, 
    UnitIsGhost, UnitAffectingCombat, GetRaidTargetIndex, UnitDebuff, UnitBuff, 
    UnitChannelInfo, UnitIsPlayer, UnitPlayerControlled, UnitGUID = 
    GetSpellName, GetSpellTexture, UnitExists, UnitIsUnit, UnitCanAttack, 
    UnitIsGhost, UnitAffectingCombat, GetRaidTargetIndex, UnitDebuff, UnitBuff, 
    UnitChannelInfo, UnitIsPlayer, UnitPlayerControlled, UnitGUID;

local uniqueSpells = { --spells that can only be applied once globally, but lack of cooldown allows spamming
    ["Hunter's Mark"] = 1,
    ["Fear"] = 1,
    ["Seduction"] = 1,
    ["Prayer of Mending"] = 1,
    ["Hibernate"] = 1,
    ["Sap"] = 1,
    ["Polymorph"] = 1,
    ["Banish"] = 1,
    ["Enslave Demon"] = 1,
    ["Shackle Undead"] = 1,
    ["Entangling Roots"] = 1,
    ["Cyclone"] = 1,
    ["Turn Undead"] = 1,
    ["Living Bomb"] = 1,
}

local aoeSpells, localeData, cachedMana;
local SpellLib = AsheylaLib:Import("SpellLib");

local spellbooktables = {BOOKTYPE_SPELL,BOOKTYPE_PET};
local getEnglish;
local cachedEnglish = {};
setmetatable(cachedEnglish, {
    __index = function(t, k)
        local v = getEnglish(k);
        t[k] = v;
        return v;
    end,
});
function getEnglish(spellname)
    local english, texture;
    for index,value in ipairs(spellbooktables) do
        local i = 1
        while GetSpellName(i, value) do
            local spell = GetSpellName(i, value);
            if spell == spellname then
                texture = GetSpellTexture(i, value);
                break;
            end
            i = i + 1;
        end
    end
    if texture and localeData[texture] then return localeData[texture].name; end
    return "unknown";
end

function DoTimer:ReturnEnglish(spellname) --returns the english name of the spell
    return cachedEnglish[spellname];
end

-- holds all the targets that currently have timers
local targets = {};

local timerModule = DoTimerTimer;
local targetModule = DoTimerTarget;

-- sets up the initialization of the mod
local internalFrame = CreateFrame("Frame");
internalFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
internalFrame:SetScript("OnEvent", function(self, event, ...)
    DoTimer[event](DoTimer, ...);
end);

local updateFunc = function(self, elapsed)
    local time = GetTime();
    for _, target in ipairs(targets) do
        for timer in target:GetTimers() do
            if (time >= timer.time + timer.duration) then
                if target.name == "Party Buffs" then
                    DoTimer:UpdatePartyBuff(timer);
                else
                    target:RemoveTimer(timer);
                end
            else
                timer.announced = timer.announced or timer.duration;
                local remaining = timer.duration - time + timer.time;
                if remaining <= timer.announced - 1  or remaining > timer.announced then
                    timer.announced = floor(remaining + .5);
                    AsheylaLib:CallEvent(TIME_REMAINING, timer, timer.announced);
                end
            end
        end
    end
    if #targets == 0 then
        self:SetScript("OnUpdate", nil)
    end
end

function DoTimer:RemoveTarget(removed)
    for i, target in ipairs(targets) do
        if target == removed then
            table.remove(targets, i);
            break;
        end
    end
end

function DoTimer:GetTargets()
    return ipairs(targets);
end

function DoTimer:Commands()
    local loaded = LoadAddOn("DoTimer_Options");
    if loaded then
        AsheylaLib:Import( "GUILib" ):ShowPanel("DoTimer", "DoTimer");
    end
end
DoTimer:MakeSlashCmd("/dotimer", "/dot");

local loaded = false;
function DoTimer:PLAYER_ENTERING_WORLD()
    if not loaded then
        loaded = true;
        local _, class = UnitClass("player");
        aoeSpells, localeData = self:DefineSpells(class);
        self:AddSettingsUpdateScript(function(self)
            if self:GetUserSet("partyBuffs") == nil then
                self:Set("partyBuffs", {
                    [" spirit"] = 1,
                    ["fortitude"] = 1,
                    ["shadow protection"] = 1,
                    ["of the wild"] = 1,
                    ["arcane"] = 1,
                    ["blessing of"] = 1,
                    ["shout"] = 1,
                    ["soulstone"] = 1,
                    ["thorns"] = 1,
                    ["^elixir"] = 1,
                    ["^potion"] = 1,
                });
            end
            if self:Get("enabled") then
                internalFrame:RegisterEvent("UNIT_AURA");
                internalFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
                internalFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
                --internalFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
                internalFrame:RegisterEvent("PLAYER_ALIVE");
                internalFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
                internalFrame:RegisterEvent("PLAYER_TOTEM_UPDATE");
                internalFrame:RegisterEvent("UNIT_PET");
                local target = self:GetTarget("Party Buffs");
                if target then
                    if self:Get("usePartyBuffs") then
                        for timer in target:GetTimers() do
                            if not self:Get("partyBuffs", timer.partyBuffType) then
                                target:RemoveTimer(timer);
                            end
                        end
                    else
                        target:RemoveAllTimers();
                    end
                end
                for _, target in ipairs(targets) do
                    for timer in target:GetTimers() do
                        if not timer.isMine and not self:Get("otherTimers", string.lower(timer.name)) then
                            target:RemoveTimer(timer);
                        end
                    end
                end
                self:UNIT_AURA("player");
                self:UNIT_AURA("target");
                self:UNIT_AURA("focus");
                if GetNumRaidMembers() > 0 then
                    for i = 1, 40 do
                        self:UNIT_AURA("raid" .. i);
                    end
                elseif GetNumPartyMembers() > 0 then
                    for i = 1, 4 do
                        self:UNIT_AURA("party" .. i);
                    end
                end
            else
                internalFrame:UnregisterEvent("UNIT_AURA");
                internalFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
                internalFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
                --internalFrame:UnregisterEvent("UNIT_SPELLCAST_SENT");
                internalFrame:UnregisterEvent("PLAYER_ALIVE");
                internalFrame:UnregisterEvent("PLAYER_REGEN_ENABLED");
                internalFrame:UnregisterEvent("PLAYER_TOTEM_UPDATE");
                internalFrame:UnregisterEvent("UNIT_PET");
                for i = #targets, 1, -1 do
                    targets[i]:RemoveAllTimers();
                end
            end
        end);
        self:UpdateSettings();
    end
    
    self:PLAYER_TOTEM_UPDATE();
end

local petGUID;
function DoTimer:UNIT_PET(unit)
    if not UnitIsUnit(unit, "player") then return; end
    if UnitExists("pet") then
        petGUID = UnitGUID("pet");
    elseif petGUID then
        for _, target in ipairs(targets) do
            if target.uniqueID == petGUID then
                target:RemoveAllTimers();
            end
        end
        petGUID = nil;
    end
end

function DoTimer:PLAYER_TOTEM_UPDATE(n)
    for i = 1, 4 do
        local target = self:GetTarget("No Target");
        local haveTotem, totemName, startTime, duration, texture = GetTotemInfo(i);
    haveTotem = haveTotem and totemName;
        local hasTimer = false;
        if target then
            for timer in target:GetTimers() do
                local totemID = timer.totemID;
                if totemID == i then
                    hasTimer = true;
                    if haveTotem and duration > 0 then
                        timer:UpdateTimerData(totemName, texture, duration, startTime + duration, 1);
                    else
                        target:RemoveTimer(timer);
                    end
                end
            end
        end
        if haveTotem and not hasTimer and duration > 0 then
            --make new
            if not target then
                target = targetModule:NewAOETarget(self);
                table.insert(targets, target);
                internalFrame:SetScript("OnUpdate", updateFunc);
            end
            
            local timer = timerModule:NewTimer(self, totemName, nil, texture, 1, duration, startTime + duration, self.HARMFUL_TYPE, true);
            timer.totemID = i;
            target:AddTimer(timer);
        end
    end
end

function DoTimer:UNIT_AURA(unit)
    if (UnitExists(unit)) then
        if UnitCanAttack("player", unit) then 
            self:ScanAuras(unit, self.HARMFUL_TYPE);
            self:ScanAuras(unit, self.HELPFUL_TYPE);
        else 
            if 
            (
                (not UnitPlayerControlled(unit) or UnitIsPlayer(unit) or UnitIsUnit(unit, "pet"))
            and
                (not self:Get("filterUngroupedBuffs") or (UnitExists(UnitName(unit)) or UnitIsUnit(unit, "player"))) 
            and 
                (not self:Get("filterNonPlayerBuffs") or UnitIsPlayer(unit)) 
            )
            then
                self:ScanAuras(unit, self.HELPFUL_TYPE);
                self:ScanAuras(unit, self.HARMFUL_TYPE);
            end
        end
    end
end

function DoTimer:COMBAT_LOG_EVENT_UNFILTERED(timeStamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
    if (event == "UNIT_DIED") then
        for i, target in ipairs(targets) do
            if target.uniqueID == destGUID then
                target:RemoveAllTimers();
            end
        end
    elseif event == "PARTY_KILL" and self.announceDeaths then
        SendChatMessage(string.format("%s killed %s!", sourceName, destName), "RAID_WARNING")
    end
end

function DoTimer:PLAYER_ALIVE()
    if not UnitIsGhost("player") then return end
    for i = #targets, 1, -1 do
        targets[i]:RemoveAllTimers();
    end
end

local f = CreateFrame("Frame");
local combatFunc = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed;
    if (self.elapsed >= 3) then
        if not UnitAffectingCombat("player") then
            for i, target in ipairs(targets) do
                if target.type == "mob" and not string.find(target.name, "Training Dummy") then
                    target:RemoveAllTimers();
                end
            end
        end
        self:SetScript("OnUpdate", nil);
    end
end

function DoTimer:PLAYER_REGEN_ENABLED()
    f.elapsed = 0;
    f:SetScript("OnUpdate", combatFunc);
end

function DoTimer:UNIT_SPELLCAST_SUCCEEDED(...)
    local unit, spellName, spellRank = ...;
    
    if unit ~= "player" then return end;
    if self:IsAOESpell(spellName) then
        local target = self:GetTarget("No Target");
        if not target then
            target = targetModule:NewAOETarget(self);
            table.insert(targets, target);
            internalFrame:SetScript("OnUpdate", updateFunc);
        end
        local texture = GetSpellTexture( spellName );
        local duration = self:ReturnDuration(spellName, spellRank, texture);
        
        for t in target:GetTimers() do
            if t.name == spellName then
                t:UpdateTimerData(t.name, t.texture, duration, GetTime() + duration, 1);
                return;
            end
        end
        local timer = timerModule:NewTimer(self, spellName, spellRank, texture, 1, duration, GetTime() + duration, self.HARMFUL_TYPE, true);
        target:AddTimer(timer);
        local group = self:ReturnGroup(texture);
        if group > 0 then
            for t in target:GetTimers() do
                if self:ReturnGroup(t.texture) == group and t ~= timer then
                    target:RemoveTimer(t);
                end
            end
        end
    end
end

function DoTimer:UNIT_SPELLCAST_SENT()
    cachedMana = UnitMana("player");
end

function DoTimer:ReturnGroup(texture)
    return (localeData[texture] and localeData[texture].group or 0)
end

local function testIsMine(unit)
    if not unit then return false; end
    return UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") or UnitIsUnit(unit, "vehicle");
end

function DoTimer:ScanAuras(unit, filter)
    if UnitName(unit) == UNKNOWN then return; end
    local target = self:GetTarget(unit);
    if (target) then
        for timer in target:GetTimers() do
            timer.validated = false;
        end
        local newIcon = GetRaidTargetIndex(unit) or 0;
        target:UpdateIcon(newIcon);
        target.type = self:GetTargetType(unit);
    end
    local partyBuffs = filter == self.HELPFUL_TYPE and self:GetTarget("Party Buffs");
    local guid = UnitGUID(unit);
    local unitName = UnitName(unit);
    if (partyBuffs) then
        for timer in partyBuffs:GetTimers() do
            if timer.affecting[unitName] then
                timer.affecting[unitName].validated = false;
            end
        end
    end
    local i = 1;
    local name, rank, texture, count, debuffType, duration, endTime, isMine = UnitAura(unit, i, filter);
    isMine = testIsMine(isMine);
    while name do
        if duration > 0 then
            if partyBuffs and (isMine or self:Get("otherTimers", string.lower(name))) then
                for timer in partyBuffs:GetTimers() do
                    if timer.affecting[unitName] and timer.affecting[unitName].name == name then
                        if unitName == UnitName("player") then
                            local othersPresent = false;
                            for g in pairs(timer.affecting) do
                                if g ~= unitName then
                                    othersPresent = true;
                                    break;
                                end
                            end
                            if othersPresent then
                                timer.affecting[unitName].validated = true;
                            end
                        end
                    end
                end
            end
            
            if (not self:IsIgnoring(name, rank, texture, count, duration, endTime, filter, guid, unitName, unit, isMine)) then
                local adding = true;
                if target then
                    for _i, timer in ipairs(target.timers) do
                        if (timer.module == self and timer.name == name and timer.type == filter and timer.isMine == isMine and not timer.validated) then
                            timer.validated = true;
                            timer:UpdateTimerData(name, texture, duration, endTime, count, _i, i);
                            adding = false;
                            break;
                        end
                    end
                end
                if (adding) then
                    if uniqueSpells[self:ReturnEnglish(name)] and isMine then
                        for i, _t in ipairs(targets) do
                            for t in _t:GetTimers() do
                                if t.name == name then
                                    _t:RemoveTimer(t);
                                end
                            end
                        end
                    end
                    
                    if target then
                        if isMine then
                            local group = self:ReturnGroup(texture);
                            if group > 0 then
                                for t in target:GetTimers() do
                                    if self:ReturnGroup(t.texture) == group then
                                        target:RemoveTimer(t);
                                    end
                                end
                            end
                        end
                    else
                        target = targetModule:NewTarget(self, unit);
                        table.insert(targets, target);
                        internalFrame:SetScript("OnUpdate", updateFunc);
                    end
                    timer = timerModule:NewTimer(self, name, rank, texture, count, duration, endTime, filter, isMine);
                    target:AddTimer(timer);
                end
            end
        end
        
        i = i + 1;
        name, rank, texture, count, debuffType, duration, endTime, isMine = UnitAura(unit, i, filter);
        isMine = testIsMine(isMine);
    end
    
    if (target) then
        for timer in target:GetTimers() do
            if (timer.module == self and timer.type == filter and not timer.validated) then
                target:RemoveTimer(timer);
            end
        end
    end
    if (partyBuffs) then
        for timer in partyBuffs:GetTimers() do
            if timer.affecting[unitName] and not timer.affecting[unitName].validated then
                if UnitExists(timer.affecting[unitName].person) then
                    timer.notAffecting[unitName] = timer.affecting[unitName];
                else
                    releaseTable(timer.affecting[unitName]);
                end
                timer.affecting[unitName] = nil;
                self:UpdatePartyBuff(timer);
                if unitName ~= UnitName("player") then
                    self:UNIT_AURA("player");
                end
            end
        end
    end
end

function DoTimer:AddExternalTimer(module, name, rank, texture, count, duration, endTime, filter, tarName, level, type, icon, guid)
    local tar = DoTimer:GetTargetByGUID(guid);
    if not tar then
        tar = targetModule:NewTargetByData(self, tarName, level, type, icon, guid);
        table.insert(targets, target);
        internalFrame:SetScript("OnUpdate", updateFunc);
    end
    timer = timerModule:NewTimer(module, name, rank, texture, count, duration, endTime, filter, false);
    tar:AddTimer(timer);
    return timer;
end

function DoTimer:IsIgnoring(name, rank, texture, count, duration, endTime, filter, guid, tarName, unit, isMine)
    local interested = isMine or self:Get("otherTimers", string.lower(name));
    local maxBuffDur = self:Get("maxBuffDuration");
    return (
        (not interested)
    or
        (endTime - GetTime() < .5)
    or
        (filter == self.HARMFUL_TYPE and self:IsAOESpell(name))
    or
        (filter == self.HELPFUL_TYPE and maxBuffDur > 0 and duration > maxBuffDur * 60)
    or
        (filter == self.HELPFUL_TYPE and self:Get("usePartyBuffs") and self:IsPartyBuff(name, rank, texture, count, duration, endTime, filter, tarName, tarName))
    or
        (self:Get("filterSelf") and UnitIsUnit("player", unit))
    );
end

function DoTimer:IsAOESpell(name)
    return self:Get("useNoTarget") and aoeSpells[self:ReturnEnglish(name)] and true or false;
end

local getPB;
local cachedPB = {};
setmetatable(cachedPB, {
    __index = function(t, k)
        local v = getPB(k);
        t[k] = v;
        return v;
    end,
});
function getPB(name)
    local val = false;
    name = lower(name);
    for query in pairs(DoTimer:Get("partyBuffs")) do
        if string.find(query, "^%^") then
            if find(name, string.sub(query, 2)) then
                return false;
            end
        elseif find(name, query) then
            val = query;
        end
    end
    return val;
end
local function isPB(name)
    return cachedPB[name];
end

function DoTimer:IsPartyBuff(name, rank, texture, count, duration, endTime, filter, guid, tarName)
    --add to current party buff or make a new one
    --if new, timer.partyBuffType should be the partyBuffs string match
    --needs 2 tables: .affecting and .notAffecting
    --.affecting[guid] = {person = "Xanido", name = "Power Word: Fortitude", duration = 600, time = 12345, texture = "..."};
    --call UpdatePartyBuff(timer) at end so stack, time info can be recalculated
    local match = isPB(name);
    if match then
        local target = self:GetTarget("Party Buffs");
        local buffTimer;
        if not target then
            target = targetModule:NewPartyBuffsTarget(self);
            table.insert(targets, target);
            internalFrame:SetScript("OnUpdate", updateFunc);
        end
        if target then
            for timer in target:GetTimers() do
                if timer.partyBuffType == match then
                    buffTimer = timer;
                    break;
                end
            end
        end
        if guid == UnitName("player") then
            local othersPresent = false;
            if buffTimer then
                for g in pairs(buffTimer.affecting) do
                    if g ~= guid then
                        othersPresent = true;
                        break;
                    end
                end
                if not othersPresent then
                    return false;
                end
            else
                return false;
            end
        end
        if not buffTimer then
            if not target then
                target = targetModule:NewPartyBuffsTarget(self);
                table.insert(targets, target);
                internalFrame:SetScript("OnUpdate", updateFunc);
            end
            buffTimer = timerModule:NewPartyBuffsTimer(self, match, name, rank, texture, 1, duration, endTime, self.HELPFUL_TYPE);
            target:AddTimer(buffTimer);
        end
        buffTimer.affecting[guid] = buffTimer.affecting[guid] or buffTimer.notAffecting[guid];
        buffTimer.notAffecting[guid] = nil;
        if buffTimer.affecting[guid] then
            buffTimer.affecting[guid].validated = true;
            self:UpdatePartyBuff(buffTimer, guid, name, rank, texture, duration, endTime);
        else
            buffTimer.affecting[guid] = acquireTable();
            local t = buffTimer.affecting[guid];
            t.person = tarName;
            t.name = name;
            t.rank = rank;
            t.duration = duration;
            t.time = endTime - duration;
            t.texture = texture;
            t.validated = true;
            self:UpdatePartyBuff(buffTimer);
            if guid ~= UnitName("player") then
                self:UNIT_AURA("player");
            end
        end
        return true;
    end
    
    return false;
end

function DoTimer:UpdatePartyBuff(timer, guid, name, rank, texture, duration, endTime)
    local target = self:GetTarget("Party Buffs");
    if guid then
        local t = timer.affecting[guid];
        if t then
            t.name = name;
            t.rank = rank;
            t.duration = duration;
            t.time = endTime - duration;
            t.texture = texture;
        end
    end
    local mainBuff, remainingTime;
    local stack = 0;
    for guid, buffInfo in pairs(timer.affecting) do
        local remaining = buffInfo.duration - GetTime() + buffInfo.time;
        if remaining > 0 then
            if not mainBuff then
                mainBuff = buffInfo;
                remainingTime = remaining;
            else
                if remaining < remainingTime then
                    mainBuff = buffInfo;
                    remainingTime = remaining;
                end
            end
            stack = stack + 1;
        else
            if UnitExists(buffInfo.person) then
                timer.notAffecting[guid] = buffInfo;
            else
                releaseTable(buffInfo);
            end
            timer.affecting[guid] = nil;
            if unitName ~= UnitName("player") then
                self:UNIT_AURA("player");
            end
        end
    end
    
    if stack == 0 then
        target:RemoveTimer(timer);
    else
        timer:UpdateTimerData(mainBuff.name, mainBuff.texture, mainBuff.duration, mainBuff.time + mainBuff.duration, stack);
    end
end

local partyFrame = CreateFrame("Frame");
partyFrame:RegisterEvent("RAID_ROSTER_UPDATE");
partyFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
partyFrame:SetScript("OnEvent", function(self, event)
    local target = DoTimer:GetTarget("Party Buffs");
    if target then
        for timer in target:GetTimers() do
            local changed = false;
            for guid, data in pairs(timer.notAffecting) do
                if not UnitExists(data.person) then
                    timer.notAffecting[guid] = nil;
                    releaseTable(data);
                    changed = true;
                end
            end
            if DoTimer:Get("filterUngroupedBuffs") then
                for guid, data in pairs(timer.affecting) do
                    if not UnitExists(data.person) then
                        timer.affecting[guid] = nil;
                        releaseTable(data);
                        changed = true;
                    end
                end
            end
            if changed then 
                DoTimer:UpdatePartyBuff(timer);
            end
        end
    end
    
    if GetNumRaidMembers() > 0 then
        for i = 1, GetNumRaidMembers() do
            DoTimer:UNIT_AURA("raid" .. i);
        end
    else
        if GetNumPartyMembers() > 0 then
            for i = 1, GetNumPartyMembers() do
                DoTimer:UNIT_AURA("party" .. i);
            end
        end
        DoTimer:UNIT_AURA("player");
    end
end);

function DoTimer:GetTargetType(unit)
    if (UnitIsPlayer(unit) or UnitPlayerControlled(unit)) then return "player"; end
    --if UnitIsPlayer(unit) then return "player"; end
    return "mob";
end

function DoTimer:GetTarget(unit)
    if unit == "No Target" or unit == "Party Buffs" then
        for _, target in ipairs(targets) do
            if target.name == unit then return target end
        end
    elseif UnitPlayerControlled(unit) and not UnitIsPlayer(unit) then
        local name = UnitName(unit);
        for _, target in ipairs(targets) do
            if target.name == name and target.isPet then 
                target:UpdateGUID(UnitGUID(unit));
                return target 
            end
        end
    else
        local guid = UnitGUID(unit);
        for _, target in ipairs(targets) do
            if target.uniqueID == guid then return target end
        end
    end
end

function DoTimer:GetTargetByGUID(guid)
    for _, target in ipairs(targets) do
        if target.uniqueID == guid then return target end
    end
end

local getDuration;
local cachedDurations = {};
setmetatable(cachedDurations, {
    __index = function(t, k)
        local newMeta = {};
        setmetatable(newMeta, {
            __index = function(t2, k2)
                local dur = getDuration(k, k2);
                t2[k2] = dur;
                return dur;
            end
        })
        t[k] = newMeta;
        return newMeta;
    end
})
function DoTimer:ReturnDuration(spellName, spellRank, texture) --returns the duration of a spell
    if texture == "Interface\\Icons\\Spell_Frost_SummonWaterElemental_2" and select(5, GetTalentInfo(3, 26)) == 3 then return 60; end
    --[[if texture == "Interface\\Icons\\INV_Sword_07" then
        return (cachedMana * .2);
    end--]]
    return cachedDurations[spellName][spellRank];
end

function getDuration(spellName, spellRank)
    local texture = GetSpellTexture( spellName );
    for index, value in ipairs(spellbooktables) do 
        local i = 1;
        while GetSpellName(i,value) do
            local spellname, spellrank = GetSpellName(i,value);
            if spellname == spellName and ((spellrank == spellRank) or (spellRank == "") or (value == BOOKTYPE_PET)) then
                local text = SpellLib:GetSpellInfo(i, value, "left", "max");
                local basenumber = localeData[texture].duration;
                local rankNum = tonumber(match(spellRank, "(%d+)")) or 0;
                if texture == "Interface\\Icons\\Spell_Nature_ThunderClap" and rankNum < 3 then
                    basenumber = (rankNum == 1 and 10 or 14);
                end
                local multiplier = localeData[texture].multiplier;
                local truenumber;
                for value2 in gmatch(text, "(%d[%d%p]*)") do
                    value2 = tonumber(value2);
                    if type(value2) == "number" and ((not truenumber) or (abs(value2 - basenumber) < abs(truenumber - basenumber))) then truenumber = value2; end
                end
                truenumber = truenumber or basenumber;
                return truenumber * multiplier;
            end
            i = i + 1;
        end
    end
    return 0;
end

local f2 = CreateFrame("Frame")
f2.elapsed = 0;
f2.update = function(self, elapsed)
    if self.elapsed >= .1 then
        self.elapsed = 0;
        DoTimer:UNIT_AURA("mouseover");
    else
        self.elapsed = self.elapsed + elapsed;
    end
end
f2:SetScript("OnUpdate", f2.update);
f2.event = function(self,event, arg1) 
    local unit;
    if (event == "PLAYER_FOCUS_CHANGED") then
        unit = "focus";
    elseif (event == "PLAYER_TARGET_CHANGED") then
        unit = "target";
    elseif (event == "UNIT_PET" and arg1 == "player") then
        unit = "pet";
    elseif (event == "UPDATE_MOUSEOVER_UNIT") then
        unit = "mouseover";
    end
    
    if unit then DoTimer:UNIT_AURA(unit); end
end
f2:SetScript("OnEvent", f2.event);
DoTimer:AddSettingsUpdateScript(function(self)
    table.wipe(cachedPB);
    if self:Get("enabled") then
        f2:SetScript("OnUpdate", f2.update);
        f2:RegisterEvent("PLAYER_FOCUS_CHANGED")
        f2:RegisterEvent("PLAYER_TARGET_CHANGED")
        f2:RegisterEvent("UNIT_PET")
        f2:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
    else
        f2:SetScript("OnUpdate", nil);
        f2:UnregisterAllEvents();
    end
end);

local defaultSettings = {
    enabled = true,
    usePartyBuffs = true,
    useNoTarget = true,
    always = false,
    partyBuffs = {},
    filterUngroupedBuffs = false,
    filterNonPlayerBuffs = false,
    filterSelf = true,
    maxBuffDuration = 0,
    otherTimers = {},
}
DoTimer:AddDefaultSettings(defaultSettings);
