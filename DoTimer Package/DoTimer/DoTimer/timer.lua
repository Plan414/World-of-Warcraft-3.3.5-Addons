AsheylaLib:Package( "DoTimer" );

DoTimerTimer = {};

local GetTime = GetTime;
local abs = math.abs;

local UPDATE_TIMERDATA = "DOTIMER_UPDATE_TIMERDATA";
local cachedTables, activeTimers;


local timerFuncs = {
    UpdateTimerData = function(self, name, texture, duration, endTime, stack, oldIndex, newIndex)
        local currDur = self.duration;
        local currTime = self.time;
        local currStack = self.stack;
        local currName = self.name;
        local currTexture = self.texture;
        local needsEvent = false;
        
        if (currName ~= name) then
            self.name = name;
            self.nameChanged = true;
            needsEvent = true;
        end
        
        if (currTexture ~= texture) then
            self.texture = texture;
            needsEvent = true;
        end

        if (abs(currDur - duration) > .1) then
            self.duration = duration;
            needsEvent = true;
        end
        
        local realTime = endTime - duration;
        if (abs(currTime - realTime) > .1) then
            self.time = realTime;
            needsEvent = true;
        end
        
        if (currStack ~= stack) then
            self.stack = stack;
            needsEvent = true;
        end
        
        if (oldIndex and newIndex) then
            local timers = self.target.timers;
            table.insert(timers, math.min(#timers, newIndex), table.remove(timers, oldIndex));
        end
         
        if (needsEvent) then
            AsheylaLib:CallEvent(UPDATE_TIMERDATA, self);
        end
    end,
    
    Destruct = function(self)
        if self.affecting then
            for t in pairs(self.affecting) do
                releaseTable(t);
            end
            releaseTable(self.affecting);
        end
        if self.notAffecting then
            for t in pairs(self.notAffecting) do
                releaseTable(t);
            end
            releaseTable(self.notAffecting);
        end
        activeTimers[self] = nil;
        table.insert(cachedTables, self);
    end,
}

activeTimers = {};
function DoTimerTimer:IsActiveTimer(timer)
    return activeTimers[timer];
end

cachedTables = {};
function DoTimerTimer:NewTimer(module, name, rank, texture, count, duration, endTime, filter, isMine)
    local timer = table.remove(cachedTables, 1);
    if timer then
        table.wipe(timer.state);
    else
        timer = acquireTable();
        timer.state = acquireTable();
        for i, v in pairs(timerFuncs) do
            timer[i] = v;
        end
    end
    
    timer.name = name;
    timer.rank = rank;
    timer.texture = texture;
    timer.stack = count;
    timer.duration = duration;
    timer.time = endTime - duration;
    timer.module = module;
    timer.type = filter;
    timer.isMine = isMine;
    timer.validated = true;
    setmetatable(timer, stateMeta);
    activeTimers[timer] = true;
    
    return timer;
end

function DoTimerTimer:NewPartyBuffsTimer(module, buffType, name, rank, texture, count, duration, endTime, filter)
    local timer = table.remove(cachedTables, 1);
    if timer then
        table.wipe(timer.state);
    else
        timer = acquireTable();
        timer.state = acquireTable();
        for i, v in pairs(timerFuncs) do
            timer[i] = v;
        end
    end
    
    timer.name = name;
    timer.rank = rank;
    timer.texture = texture;
    timer.stack = count;
    timer.duration = duration;
    timer.time = endTime - duration;
    timer.module = module;
    timer.type = filter;
    timer.isMine = true;
    setmetatable(timer, stateMeta);
    timer.partyBuffType = buffType;
    timer.affecting = acquireTable();
    timer.notAffecting = acquireTable();
    activeTimers[timer] = true;
    
    return timer;
end
