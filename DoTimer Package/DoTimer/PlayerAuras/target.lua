AsheylaLib:Package( "PlayerAuras" );

PlayerAurasTarget = {};

local NEW_TIMER = "PLAYERAURAS_NEW_TIMER";
local DONE_TIMER = "PLAYERAURAS_DONE_TIMER";

local targetFuncs = {
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
                AsheylaLib:CallEvent(DONE_TIMER, self, t);
                table.remove(self.timers, i);
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
}

function PlayerAurasTarget:MakeBuffsTable(module, unit)
    local target = acquireTable();
    target.name = "Buffs";
    target.unit = unit;
    target.module = module;
    target.timers = acquireTable();
    for i, v in pairs(targetFuncs) do
        target[i] = v;
    end
    return target;
end

function PlayerAurasTarget:MakeDebuffsTable(module, unit)
    local target = acquireTable();
    target.name = "Debuffs";
    target.unit = unit;
    target.module = module;
    target.timers = acquireTable();
    for i, v in pairs(targetFuncs) do
        target[i] = v;
    end
    return target;
end
