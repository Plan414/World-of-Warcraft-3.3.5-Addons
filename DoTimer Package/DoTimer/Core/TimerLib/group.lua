-- this function should register our globals for this package, 
-- and allow access to the default package for stuff like Class
AsheylaLib:Package( "TimerLib" );
--[[
    Group class  
--]]

local order = {
    "data", "priority", "hidden"
};

local fields = {
    data = Class.READONLY,      -- table        the data for the timer; fields are listed below
    priority = Class.READWRITE, -- number       group's priority (lower numbers sorted before higher)
    hidden = Class.READWRITE,   -- boolean      if the group is hidden from view (explicitly)
    visible = Class.READONLY,   -- boolean      if the timer is visible (depends on several factors)
    
    -- the below are not arguments externally, but are instead populated later
    
    anchor = Class.READWRITE,   -- table        the anchor the group belongs to
    frame = Class.READONLY,     -- table        the frame that the group is rendered in
    time = Class.READONLY,      -- number       the time the group was created
    hiddenByAnchor = Class.READWRITE,-- boolean if the anchor has decided that this group needs hiding
    
    -- fields derived from the data table
    
    name = Class.READONLY,      -- string       the name of the group
    level = Class.READONLY,     -- number       the level of the group
    icon = Class.READONLY,      -- number       the raid icon of the group
    uniqueID = Class.READONLY,  -- anything!    a unique identifier for the group
};

local externalFuncs = {
    AddTimer = true,        -- timer            to add a timer to the group
    RemoveTimer = true,     -- timer, force     to make the timer turn into a ghost
    MoveTimer = true,       -- timer, group     moves the timer into a different group
    Get = true,             -- ...              to query the value this group has for a setting
    TimerUpdated = true,    -- timer, why       called by timers to let their group know they've changed
    UpdateVisibility = true,-- <none>           updates the visibility of the timer
    IsShown = true,         -- <none>           if the group is visible on its own merits
    Destruct = true,        -- <none>           to trigger the group's destruction (recycled for later use)
    UpdateSettings = true,  -- <none>           when the saved settings this group is using have changed
    UpdateData = true,      -- <none>           when the data for the group (name, icon, etc) changes
    UpdateAllTimers = true, -- time             calls Update() on all this group's timers
    DeleteAllTimers = true, -- module           deletes all timers for specified module (or all timers)
};

local persistent = {
    manager = true,
    frame = true,
    timers = true,
};

local timerSortFunc;

-- grab local copies of globals
local huge = math.huge;
local floor = math.floor;
local wipe = table.wipe;
local ipairs = ipairs;
local tremove = table.remove;
local tinsert = table.insert;
local tsort = table.sort;
local match = string.match;
local GetTime = GetTime;
local type = type;

-- map from external objects to their internal data
local internal;

local oldDestruct;
local internalFuncs = {
    DeleteAllTimers = function( self, module )
        local n = #self.timers;
        for i = n, 1, -1 do
            local timer = self.timers[ i ];
            if module == nil or module == timer.module then
                timer:Destruct();
            end
        end
    end,
    
    FieldUpdate = function( self, k, v )
        if k == "anchor" then
            self:UpdateSettings();
            self:UpdateVisibility();
        elseif k == "priority" or k == "hidden" then
            self:UpdateVisibility();
            self.manager:UpdateShown();
            self.anchor:GroupUpdated( internal[ self ], k );
        elseif k == "hiddenByAnchor" then
            self:UpdateVisibility();
            self.manager:UpdateShown();
        end
    end,
    
    UpdateAllTimers = function( self, time )
        local n = #self.timers;
        for i = n, 1, -1 do
            local timer = self.timers[ i ];
            -- sometimes this is nil (very rarely)
            -- haven't figured out why
            -- no visual manifestation of the error
            -- applying bandaid
            if timer then
                local done = timer:Update( time );
                if done == "destruct" then
                    timer:Destruct();
                elseif done == "remove" then
                    timer:Remove();
                end
            end
        end
    end,
    
    UpdateData = function( self )
        if type(self.data) == "table" then
            self.fields.name = self.data.name or "Group";
            self.fields.level = self.data.level;
            if self.fields.level == 0 then self.fields.level = nil; end
            self.fields.icon = self.data.icon or 0;
            if self.fields.icon == 0 then self.fields.icon = nil; end
            self.fields.uniqueID = self.data.uniqueID or GetTime();
        else
            self.fields.name = self.data;
            self.fields.level = nil;
            self.fields.icon = nil;
            self.fields.uniqueId = nil;
        end
        
        if self.anchor then
            self.manager:UpdateData();
        end
        
        local n = #self.timers;
        for i = n, 1, -1 do
            local timer = self.timers[ i ];
            if not timer.isGhost then
                timer:UpdateData();
            end
        end
    end,
    
    UpdateSettings = function( self )
        local method, direction = match(self:Get("timerSortMethod"), "(.*) %((%a)%)");
        self.timerSortMethod = method;
        self.timerSortDirection = direction;
        
        self.manager:DrawFrame();
        -- groups, unlike anchors, have 0 timers only briefly (when first created)
        -- therefore we can save time by not updating group until we have a timer
        if #self.timers > 0 then
            self:SortTimers();
            self:UpdateGroup();
            local n = #self.timers;
            for i = n, 1, -1 do
                local timer = self.timers[ i ];
                timer:UpdateSettings();
            end
        end
    end,
    
    AddTimer = function( self, timer )
        timer.group = internal[ self ];
    end,
    
    UpdateGroup = function( self, timer )
        if timer then
            self:InsertTimer( timer );
            local n = #self.timers;
            for i = n, 1, -1 do
                local t = self.timers[ i ];
                if t.module == timer.module and t.name == timer.name and t ~= timer and t.isGhost then
                    self:RemoveTimer( t, true );
                end
            end
        end
        self:CheckTimers();
        self.manager:UpdateShown();
        if not dontSort then
            self:SortTimers();
        end
        self.manager:Resize( self.timers, true );
        self.anchor:GroupUpdated( internal[ self ], "update" );
    end,
    
    RemoveTimer = function( self, timer, force )
        if force then
            timer:Destruct();
        else
            timer:Remove();
        end
    end,
    
    MoveTimer = function( self, timer, group )
        if group ~= internal[ self ] then
            self:TimerDestructed( timer );
            group:AddTimer( timer );
        end
    end,
    
    CheckTimers = function( self )
        local oldATH = self.allTimersHidden;
        self.allTimersHidden = false;
        if #self.timers > 0 then
            local hasData = false;
            local visibleHasData = false;
            local visibleTimerExists = false;
            for i, t in ipairs(self.timers) do
                local visible = t:IsShown();
                if visible then
                    visibleTimerExists = true;
                end
                if not t.isGhost then
                    hasData = true;
                    if visible then
                        visibleHasData = true;
                        break;
                    end
                end
            end
            self.allTimersHidden = not visibleTimerExists;
            
            if not visibleHasData then
                for i, t in ipairs( self.timers ) do
                    if t.isGhost then
                        t:StartFadingOut();
                    end
                end
            end
            
            hasData = hasData or type(self.data) == "string";
            if not hasData then
                self.fields.data = nil;
            end
        end
        if self.allTimersHidden ~= oldATH then
            self:UpdateVisibility();
        end
    end,
    
    UpdateVisibility = function( self )
        self.fields.visible = self:IsShown() and self.anchor.visible;
        for i, timer in ipairs( self.timers ) do
            timer:UpdateVisibility();
        end
    end,
    
    IsShown = function( self )
        return not (self.hidden or self.allTimersHidden or self.hiddenByAnchor);
    end,
    
    Destruct = function( self )
        local anchor = self.anchor;
        anchor:GroupUpdated( internal[ self ], "done" );
        self.manager:GroupDone( anchor );
        wipe( self.timers );
        oldDestruct( self );
    end,
    
    TimerUpdated = function( self, timer, reason )
        -- data: resize, delete any other timers with same name
        --      also, if any existing ghost timers have the new name, remove them
        -- done/ghost: check all timers for data
        -- size: resize
        -- data: resort
        -- priority/hidden: resize and resort
        if reason == "done" then
            self:TimerDestructed( timer );
        elseif reason == "added" then
            self:TimerAdded( timer );
        elseif reason == "ghost" then
            self:TimerRemoved( timer );
        elseif reason == "priority" or reason == "hidden" then
            self:UninsertTimer( timer );
            self:UpdateGroup( timer );
        elseif reason == "data" then
            self:TimerDataUpdated( timer );
        elseif reason == "size" then
            self.manager:Resize( self.timers );
        elseif reason == "name" then
            self:UninsertTimer( timer );
            self:UpdateGroup( timer );
        end
    end,
    
    TimerDataUpdated = function( self, timer )
        local old = self:UninsertTimer( timer );
        if self:InsertTimer( timer ) ~= old then
            self.manager:Resize( self.timers, true );
        end
    end,
    
    TimerAdded = function( self, timer )
        self.manager:AddChild( timer );
        self:UpdateGroup( timer );
    end,
    
    TimerDestructed = function( self, timer )
        for i, t in ipairs( self.timers ) do
            if t == timer then
                tremove( self.timers, i );
                break;
            end
        end
        if #self.timers == 0 then
            self:Destruct();
        else
            self:UpdateGroup();
        end
        self.manager:RemoveChild( timer );
    end,
    
    TimerRemoved = function( self, timer )
        local otherExists = false;
        for i, t in ipairs(self.timers) do
            if t ~= timer and t.module == timer.module and t.name == timer.name then
                otherExists = true;
                break;
            end
        end
        if otherExists then
            timer:Destruct();
        end
        self:CheckTimers();
    end,
    
    SortTimers = function( self )
        tsort( self.timers, timerSortFunc );
    end,
    
    InsertTimer = function( self, timer )
        local timers = self.timers;
        local first, last = 1, #timers;
        
        if last == 0 or timerSortFunc( timers[ last ], timer ) then
            tinsert( timers, timer );
            return last + 1;
        end
        
        while last > first do
            local mid = floor( (last + first) / 2 );
            if timerSortFunc( timers[ mid ], timer ) then
                first = mid + 1;
            else
                last = mid;
            end
        end
        
        tinsert( timers, first, timer );
        return first;
    end,
    
    UninsertTimer = function( self, timer )
        local timers = self.timers;
        local n = #timers;
        for i = 1, n do
            if timers[ i ] == timer then
                tremove( timers, i );
                return i;
            end
        end
    end,
    
    Get = function( self, ... )
        return self.anchor:Get( ... );
    end,
};

timerSortFunc = function(a, b)
    if a:IsShown() ~= b:IsShown() then
        return a:IsShown();
    end
    if a.priority ~= b.priority then
        return (a.priority or huge) < (b.priority or huge);
    end
    local method, direction = internal[a.group].timerSortMethod, internal[a.group].timerSortDirection;
    local time = GetTime();
    local aComp, bComp, flag;
    if method == "Time Remaining" then
        if  (a.duration or b.duration) then
            aComp = a.duration and (a.duration - time + a.time) or huge;
            bComp = b.duration and (b.duration - time + b.time) or huge;
        else
            flag = true;
            aComp, bComp = a.name, b.name;
        end
    elseif method == "Percent Remaining" then
        if  (a.duration or b.duration) then
            aComp = a.duration and ((a.duration - time + a.time) / a.duration) or huge;
            bComp = b.duration and ((b.duration - time + b.time) / b.duration) or huge;
        else
            flag = true;
            aComp, bComp = a.name, b.name;
        end
    elseif method == "Time Added" then
        if  (a.duration or b.duration) then
            aComp = a.duration and (a.time) or huge;
            bComp = b.duration and (b.time) or huge;
        else
            flag = true;
            aComp, bComp = a.name, b.name;
        end
    elseif method == "Alphabetical" then
        aComp, bComp = a.name, b.name;
    end
    
    if flag then
        return aComp < bComp;
    end
    if direction == "D" then
        if aComp ~= bComp then
            return (bComp < aComp);
        else
            return (b.name < a.name);
        end
    else 
        if aComp ~= bComp then
            return (aComp < bComp);
        else
            return (a.name < b.name);
        end
    end
end

Group, internal, oldDestruct = Class( "Group", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = Group.new;
Group.new = function( ... )
    local t, fresh = oldNew( ... );
    local int = internal[ t ];
    if ( fresh ) then
        int.manager = GroupFrameManager.new( t );
        int.timers = {};
        int.fields.frame = int.manager.frame;
    end
    
    int.fields.time = GetTime();
    int:UpdateData();
    int.manager:UpdateShown();
    
    return t;
end

getfenv( 0 ).r_gint = internalFuncs;
getfenv( 0 ).r_tsort = timerSortFunc;
