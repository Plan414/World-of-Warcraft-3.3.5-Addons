-- this function should register our globals for this package, 
-- and allow access to the default package for stuff like Class
AsheylaLib:Package( "TimerLib" );
--[[
    Timer class 
--]]

-- the order in which the constructor expects the fields
local order = {
    "module", "data", "settings", "priority", "hidden"
};

local fields = {
    module = Class.READONLY,    -- table        the AsheylaLib module that owns the timer
    data = Class.READONLY,      -- table        the data for the timer; fields are listed below
    settings = Class.READWRITE, -- string       the settings to use (can be nil)
    priority = Class.READWRITE, -- number       timer's priority (lower numbers sorted before higher)
    hidden = Class.READWRITE,   -- boolean      if the timer is hidden from view (explicitly)
    visible = Class.READONLY,   -- boolean      if the timer is visible (depends on several factors)
    
    -- the below are not arguments externally, but are instead populated later
    
    group = Class.READWRITE,    -- table        the group the timer belongs to
    isGhost = Class.READONLY,   -- boolean      if the timer is a ghost timer
    frame = Class.READONLY,     -- table        the frame that the timer is rendered in
    id = Class.READONLY,        -- number       the id number of the timer (no two have the same)
    start = Class.READONLY,     -- number       when the timer started (existing or being a ghost)
    
    -- fields derived from the data table
    
    name = Class.READONLY,      -- string       the name of the timer
    duration = Class.READONLY,  -- number       the duration of the timer (nil means no duration)
    time = Class.READONLY,      -- number       when the timer started
    texture = Class.READONLY,   -- string       the texture path for the timer
    stack = Class.READONLY,     -- number       the timer's stack count (nil means 1)
};

local externalFuncs = {
    UpdateData = true,      -- <none>           when the data for the timer (name, duration, etc) changes
    Update = true,          -- currentTime      to make the timer update itself
    Remove = true,          -- <none>           to make the timer turn into a ghost
    UpdateSettings = true,  -- <none>           when the saved settings this timer is using have changed
    Get = true,             -- ...              to query the value this timer has for a setting
    UpdateVisibility = true,-- <none>           updates the visibility of the timer
    IsShown = true,         -- <none>           if the timer is visible on its own merits
    StartFadingOut = true,  -- <none>           to trigger a ghost timer to start fading out
    FormatTime = true,      -- number           transforms the number into a string representing time
    Destruct = true,        -- <none>           to trigger the timer's destruction (recycled for later use)
};

local persistent = {
    manager = true,
    cached = true,
    frame = true,
};

local checkedSettings = {};

-- grab local copies of globals
local min = math.min;
local huge = math.huge;
local wipe = table.wipe;
local GetTime = GetTime;
local select = select;
local print = print;

-- map from external objects to their internal data
local internal;

local oldDestruct;
local internalFuncs = {
    FieldUpdate = function( self, k, v )
        if k == "settings" then
            self:UpdateSettings();
        elseif k == "priority" or k == "hidden" then
            self:UpdateVisibility();
            self.manager:UpdateShown();
            self.group:TimerUpdated( internal[ self ], k );
        elseif k == "group" then
            self:UpdateSettings();
            self:UpdateVisibility();
            self.group:TimerUpdated( internal[ self ], "added" );
        end
    end,
    
    Destruct = function( self )
        local anchor = self.group.anchor;
        self.group:TimerUpdated( internal[ self ], "done" );
        self.manager:TimerDone( anchor );
        timerDone( internal[ self ] );
        wipe( self.cached );
        --print( "destructing timer " .. self.fields.id );
        oldDestruct( self );
    end,
    
    FormatTime = function( self, number )
        return self.manager:FormatTime( number );
    end,
    
    UpdateSettings = function( self )
        wipe( self.cached );
        self.manager:DrawFrame();
        self:Update();
    end,
    
    UpdateData = function( self )
        local oldName = self.fields.name;
        self.fields.name = self.data.name or "Timer";
        local oldTime = self.fields.time;
        self.fields.time = self.data.time or GetTime();
        local oldDur = self.fields.duration;
        self.fields.duration = self.data.duration; --can be nil
        self.fields.stack = self.data.stack; --can be nil
        self.fields.texture = self.data.texture or "Interface\\Icons\\Spell_Lightning_LightningBolt01";
        
        if self.group then
            if (oldDur and not self.duration) or (self.duration and not oldDur) then
                self.manager:DrawFrame();
            else
                self.manager:UpdateData();
            end
            
            if not self.hidden then
                if oldName ~= self.fields.name then
                    self.group:TimerUpdated( internal[ self ], "name" );
                elseif oldTime ~= self.fields.time or oldDur ~= self.fields.duration then
                    self.group:TimerUpdated( internal[ self ], "data" );
                end
            end
        end
    end,
    
    Remove = function( self )
        if not self.isGhost then
            self.fields.data = nil;
            self.fields.isGhost = true;
            self.fields.start = GetTime();
            self.playedSound = true;
            if self.visible then
                self.manager:UpdateToGhost();
            end
            self.group:TimerUpdated( internal[ self ], "ghost" );
        end
    end,
    
    Update = function( self, time )
        time = time or GetTime();
        --if self.duration - time + self.time <= 0 then self:Destruct(); end
        --do return end
        
        if not self.visible then
            if self.isGhost then
                return "destruct";
            end
            
            if self.duration then
                local remaining = self.duration - time + self.time;
                if ( remaining < 0 ) then
                    return "remove";
                end
            end
        else
            if self.isGhost then
                local isDone = self.manager:UpdateFadeOut(time);
                if ( isDone ) then
                    return "destruct";
                end
            else
                self.manager:UpdateFadeIn(time);
                
                if self.duration then
                    local remaining = self.duration - time + self.time;
                    
                    if ( remaining > 0 ) then
                        self.manager:Update( remaining );
                    else
                        return "remove";
                    end
                end
            end
        end
    end,
    
    Get = function( self, ... )
        if select("#", ...) == 1 and self.cached[...] then return self.cached[...]; end
        local val;
        wipe( checkedSettings );
        if self.settings then
            val = self:GetFrom( self.settings, ... );
        end
        if val == nil then
            val = self:GetFrom( self.group:Get("defaultTimerSetting"), ... );
            if val == nil then
                val = TimerLib:Get("timerSettings", "Default Timer", ...);
            end
        end
        if select("#", ...) == 1 then self.cached[...] = val; end
        return val;
    end,
    
    GetFrom = function( self, ref, ... )
        local val;
        wipe( checkedSettings );
        while ref and val == nil and not checkedSettings[ref] do
            val = TimerLib:Get("timerSettings", ref, ...);
            checkedSettings[ref] = true;
            ref = TimerLib:Get("timerSettings", ref, "reference");
        end
        
        return val;
    end,
    
    UpdateVisibility = function( self )
        self.fields.visible = self:IsShown() and self.group.visible;
        self:Update();
    end,
    
    IsShown = function( self )
        return not self.hidden;
    end,
    
    StartFadingOut = function( self )
        return self.manager:StartFadingOut();
    end,
};

local counter = 1;
Timer, internal, oldDestruct = Class( "Timer", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = Timer.new;
Timer.new = function( ... )
    local t, fresh = oldNew( ... );
    local int = internal[ t ];
    if ( fresh ) then
        int.manager = TimerFrameManager.new( t );
        int.cached = {};
        int.fields.frame = int.manager.frame;
    end
    int.fields.isGhost = false;
    int.fields.start = GetTime();
    int:UpdateData();
    int.manager:UpdateShown();
    
    int.fields.id = counter;
    counter = counter + 1;
    return t;
end

getfenv( 0 ).r_int = internalFuncs;

