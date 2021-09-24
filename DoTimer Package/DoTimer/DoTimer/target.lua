AsheylaLib:Package( "DoTimer" );

DoTimerTarget = {};

local GetTime = GetTime;
local max = math.max;
local UnitName, UnitLevel, GetRaidTargetIndex, UnitGUID = UnitName, UnitLevel, GetRaidTargetIndex, UnitGUID;

local NEW_TIMER = "DOTIMER_NEW_TIMER";
local DONE_TIMER = "DOTIMER_DONE_TIMER";
local UPDATE_TARGETDATA = "DOTIMER_UPDATE_TARGETDATA";
local cachedTables;

local targetFuncs = {
    UpdateIcon = function(self, icon)
        local currI = self.icon;
        if (currI ~= icon) then
            self.icon = icon;
            AsheylaLib:CallEvent(UPDATE_TARGETDATA, self);
        end
    end,
    
    UpdateName = function(self, name)
        local currN = self.name;
        if (currN ~= name) then
            self.name = name;
            AsheylaLib:CallEvent(UPDATE_TARGETDATA, self);
        end
    end,
    
    UpdateGUID = function(self, guid)
        local currG = self.uniqueID;
        if (currG ~= guid) then
            self.uniqueID = guid;
            AsheylaLib:CallEvent(UPDATE_TARGETDATA, self);
        end
    end,
    
    iteratorState = 0,
    iteratorFunc = function(self, timer)
        self.iteratorState = self.iteratorState - 1;
        if self.iteratorState > 0 then
            return self.timers[self.iteratorState];
        end
    end,
    
    GetTimers = function(self)
        self.iteratorState = #self.timers + 1;
        return self.iteratorFunc, self;
    end,
    
    AddTimer = function(self, timer)
        table.insert(self.timers, timer);
        timer.target = self;
        AsheylaLib:CallEvent(NEW_TIMER, self, timer);
    end,
    
    RemoveTimer = function(self, timer)
        for i, t in ipairs(self.timers) do
            if (t == timer) then 
                AsheylaLib:CallEvent(DONE_TIMER, self, t, max(0, t.duration - t.time + GetTime()), t.duration);
                table.remove(self.timers, i);
                if (#self.timers == 0) then
                    self:Destruct();
                end
                t:Destruct();
                break;
            end
        end
    end,
    
    RemoveAllTimers = function(self)
        for timer in self:GetTimers() do
            self:RemoveTimer(timer);
        end
    end,
    
    Destruct = function(self)
        table.insert(cachedTables, self);
        self.module:RemoveTarget(self);
    end,
}

cachedTables = {};
function DoTimerTarget:NewTarget(module, unit)
    local target = table.remove(cachedTables, 1);
    if target then
        table.wipe(target.timers);
        table.wipe(target.state);
    else
        target = acquireTable();
        target.state = acquireTable();
        for i, v in pairs(targetFuncs) do
            target[i] = v;
        end
    end
    
    target.name = UnitName(unit);
    target.level = UnitLevel(unit);
    target.type = module:GetTargetType(unit);
    target.icon = GetRaidTargetIndex(unit) or 0;
    target.module = module;
    target.timers = acquireTable();
    target.uniqueID = UnitGUID(unit);
    target.isPet = UnitPlayerControlled(unit) and not UnitIsPlayer(unit);
    setmetatable(target, stateMeta);
    
    return target;
end

function DoTimerTarget:NewTargetByData(module, name, level, type, icon, guid)
    local target = table.remove(cachedTables, 1);
    if target then
        table.wipe(target.timers);
        table.wipe(target.state);
    else
        target = acquireTable();
        target.state = acquireTable();
        for i, v in pairs(targetFuncs) do
            target[i] = v;
        end
    end
    
    target.name = name;
    target.level = level;
    target.type = type;
    target.icon = icon or 0;
    target.module = module;
    target.timers = acquireTable();
    target.uniqueID = guid;
    setmetatable(target, stateMeta);
    
    return target;
end

function DoTimerTarget:NewAOETarget(module)
    local target = table.remove(cachedTables, 1);
    if target then
        table.wipe(target.timers);
        table.wipe(target.state);
    else
        target = acquireTable();
        target.state = acquireTable();
        for i, v in pairs(targetFuncs) do
            target[i] = v;
        end
    end
    target.name = "No Target";
    target.level = nil;
    target.type = "player";
    target.icon = nil;
    target.module = module;
    target.timers = acquireTable();
    target.uniqueID = "0x0000000000000000";
    setmetatable(target, stateMeta);
    
    return target;
end

function DoTimerTarget:NewPartyBuffsTarget(module)
    local target = table.remove(cachedTables, 1);
    if target then
        table.wipe(target.timers);
        table.wipe(target.state);
    else
        target = acquireTable();
        target.state = acquireTable();
        for i, v in pairs(targetFuncs) do
            target[i] = v;
        end
    end
    target.name = "Party Buffs";
    target.level = nil;
    target.type = "player";
    target.icon = nil;
    target.module = module;
    target.timers = acquireTable();
    target.uniqueID = "0x0000000000000001";
    setmetatable(target, stateMeta);
    
    return target;
end
