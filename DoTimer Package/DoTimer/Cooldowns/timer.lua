AsheylaLib:Package( "Cooldowns" );

CooldownsTimer = {};

local GetTime = GetTime;
local abs = math.abs;

local UPDATE_TIMERDATA = "COOLDOWNS_UPDATE_TIMERDATA";
local cachedTables;


local timerFuncs = {
    UpdateInfo = function(self, name, texture)
        local needsEvent = false;
        if (name ~= self.name) then
            self.name = name;
            self.nameChanged = true;
            needsEvent = true;
        end
        
        if (texture ~= self.texture) then
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
function CooldownsTimer:NewTimer(module, name, texture, start, duration, rank)
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
    timer.duration = duration;
    timer.time = start;
    timer.module = module;
    setmetatable(timer, stateMeta);
    
    return timer;
end
