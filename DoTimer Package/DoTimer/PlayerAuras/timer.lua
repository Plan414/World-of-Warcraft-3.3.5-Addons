AsheylaLib:Package( "PlayerAuras" );

PlayerAurasTimer = {};

local GetTime = GetTime;
local abs = math.abs;

local UPDATE_TIMERDATA = "PLAYERAURAS_UPDATE_TIMERDATA";
local cachedTables;


local timerFuncs = {
    UpdateTimerData = function(self, duration, endTime, stack, oldIndex, newIndex, name, texture, needsEvent)
        local currDur = self.duration;
        local currTime = self.time;
        local currStack = self.stack;
        local currName = self.name;
        local currTex = self.texture;

        if not (currDur and duration) or (abs(currDur - duration) > .1) then
            self.duration = duration;
            needsEvent = true;
        end
        
        local realTime = (endTime and duration) and endTime - duration or nil;
        if not (realTime and currTime) or (abs(currTime - realTime) > .1) then
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
        
        if (name and name ~= currName) then
            self.name = name;
            self.nameChanged = true;
            needsEvent = true;
        end
        
        if (texture and texture ~= currTex) then
            self.texture = texture;
            needsEvent = true;
        end
         
        if (needsEvent) then
            AsheylaLib:CallEvent(UPDATE_TIMERDATA, self);
        end
    end,
    
    Destruct = function(self)
        table.insert(cachedTables, self);
    end,
}

cachedTables = {};
function PlayerAurasTimer:NewTimer(module, name, rank, texture, count, duration, endTime, filter, debuffType, type)
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
    timer.time = duration and (endTime - duration) or nil;
    timer.module = module;
    timer.filter = filter;
    timer.debuffType = debuffType;
    timer.type = type;
    timer.validated = true;
    setmetatable(timer, stateMeta);
    
    return timer;
end
