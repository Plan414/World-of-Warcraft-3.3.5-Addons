-- this function should register our globals for this package, 
-- and allow access to the default package for stuff like Class
AsheylaLib:Package( "TimerLib" );
--[[
    Anchor class
--]]

-- the order in which the constructor expects the fields
local order = {
    "settings"
};

local fields = {
    settings = Class.READONLY,  -- string       which settings to use
    visible = Class.READONLY,   -- boolean      if the timer is visible (depends on several factors)
    
    -- the below are not arguments externally, but are instead populated later
    
    frame = Class.READONLY,     -- table        the frame that the anchor is rendered in
};

local externalFuncs = {
    Get = true,             -- ...              to query the value this anchor has for a setting
    Set = true,             -- ...              to set a value for one of this anchor's settings
    UpdateVisibility = true,-- <none>           updates the visibility of the timer
    IsShown = true,         -- <none>           if the group is visible on its own merits
    GroupUpdated = true,    -- group, why       called by groups to let their anchor know they've changed
    FindGroup = true,       -- data,new,hid,pri returns the group with that data, will make it if specified
    UpdateSettings = true,  -- <none>           when the saved settings this anchor is using have changed
    UpdateToCursor = true,  -- <none>           moves the anchor to the mouse cursor
    CallScript = true,      -- name             invokes a script on the anchor
    UpdateAllGroups = true, -- <none>           makes all groups update their timers
    DeleteAllTimers = true, -- module           deletes all timers for specified module (or all timers)
    
    Destruct = function( self ) -- <none>       this object should never be destroyed
        error( "Attempt to destroy an Anchor" );
    end,
};

local persistent = {};

local updateTimersFunc, groupSortFunc;

-- grab local copies of globals
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local tsort = table.sort;
local huge = math.huge;
local match = string.match;
local GetTime = GetTime;
local type = type;

-- map from external objects to their internal data
local internal;

local internalFuncs = {
    DeleteAllTimers = function( self, module )
        local n = #self.groups;
        for i = n, 1, -1 do
            local group = self.groups[ i ];
            group:DeleteAllTimers( module );
        end
    end,
    
    CallScript = function( self, name )
        if name == "UpdateAlpha" then
            self:UpdateAlpha();
        elseif name == "StartMoving" then
            self.manager:StartMoving();
        elseif name == "StopMoving" then
            self.manager:StopMoving();
        end
        --[[
        local f = self[ name ];
        if f then f( self ); end
        -- qualms: relies on knowledge of implementation (sort of)
        --]]
    end,
    
    Get = function( self, ... )
        local val = TimerLib:Get("anchorSettings", self.settings, ...);
        if val == nil then
            val = TimerLib:Get("anchorSettings", "Default Anchor", ...);
        end
        return val;
    end,
    
    UpdateToCursor = function( self )
        self.manager:UpdateToCursor();
    end,
    
    Set = function( self, ... )
        TimerLib:Set("anchorSettings", self.settings, ...);
    end,
    
    UpdateVisibility = function( self )
        self.fields.visible = self.alpha ~= 0 and self:IsShown();
        for i, group in ipairs( self.groups ) do
            group:UpdateVisibility();
        end
    end,
    
    IsShown = function( self )
        return not (self:Get("hideAll") or self.allGroupsHidden);
    end,
    
    GroupUpdated = function( self, group, reason )
        if reason == "size" then
            self.manager:Resize( self.groups );
        elseif reason == "priority" or reason == "hidden" or reason == "update" then
            self:UpdateAnchor();
        elseif reason == "done" then
            self:GroupDestructed( group );
        end
    end,
    
    GroupDestructed = function( self, group )
        for i, g in ipairs( self.groups ) do
            if g == group then
                tremove( self.groups, i );
                break;
            end
        end
        
        self:UpdateAnchor( true );
        if #self.groups == 0 then
            self.frame:SetScript("OnUpdate", nil);
        end
    end,
    
    FindGroup = function( self, data, priority, hidden )
        for _, g in ipairs( self.groups ) do
            if g.data == data or (type(data) == "table" and g.uniqueID and g.uniqueID == data.uniqueID) then
                return g;
            end
        end
        
        local group = Group.new( data, priority, hidden );
        group.anchor = internal[ self ];
        tinsert( self.groups, group );
        self.manager:AddChild( group );
        self.frame:SetScript( "OnUpdate", updateTimersFunc );
        return group;
    end,
    
    UpdateAnchor = function( self, dontSort )
        self:CheckGroups();
        self.manager:UpdateShown();
        if not dontSort then
            self:SortGroups();
        end
        self.manager:Resize( self.groups, true );
    end,
    
    CheckGroups = function( self )
        local oldAGH = self.allGroupsHidden;
        self.allGroupsHidden = false;
        if #self.groups > 0 then
            for _, group in ipairs( self.groups ) do
                if group:IsShown() then
                    if self.allGroupsHidden ~= oldAGH then
                        self:UpdateVisibility();
                    end
                    return; 
                end
            end
            self.allGroupsHidden = true;
        end
        if self.allGroupsHidden ~= oldAGH then
            self:UpdateVisibility();
        end
    end,
    
    SortGroups = function( self )
        tsort( self.groups, groupSortFunc );
    end,
    
    UpdateSettings = function( self )
        local method, direction = match(self:Get("groupSortMethod"), "(.*) %((%a)%)");
        self.groupSortMethod = method;
        self.groupSortDirection = direction;
        
        self.manager:DrawFrame();
        self:UpdateAlpha();
        -- don't need to explicitly update visibility since updatealpha() will do it for us
        self:UpdateAnchor();
        local n = #self.groups;
        for i = n, 1, -1 do
            local group = self.groups[ i ];
            group:UpdateSettings();
        end
    end,
    
    UpdateAlpha = function(self)
        self.alpha = self.manager:UpdateAlpha();
        self:UpdateVisibility();
        self:UpdateAllGroups();
    end,
    
    UpdateAllGroups = function( self )
        local time = GetTime();
        local n = #self.groups;
        for i = n, 1, -1 do
            local group = self.groups[ i ];
            group:UpdateAllTimers( time );
        end
    end,
};

function updateTimersFunc(self, elapsed)
    ---[[
    self.elapsed = self.elapsed + elapsed;
    if self.elapsed < .033 then return; end
    --if self.elapsed < .033 then return; end
    self.elapsed = self.elapsed - .033;--]]
    --self.elapsed = self.elapsed - .033;--]]
    
    self.anchor:UpdateAllGroups();
end

groupSortFunc = function(a, b)
    if a:IsShown() ~= b:IsShown() then
        return b:IsShown();
    end
    if a.priority ~= b.priority then
        return (a.priority or huge) < (b.priority or huge);
    end
    local method, direction = internal[a.anchor].groupSortMethod, internal[a.anchor].groupSortDirection;
    local aComp, bComp;
    if method == "Time Added" then
        aComp, bComp = a.time, b.time;
    elseif method == "Alphabetical" then
        aComp, bComp = a.name, b.name;
        if aComp == bComp then
            aComp, bComp = a.time, b.time;
        end
    end
    
    if direction == "D" then
        return (bComp < aComp);
    else
        return (aComp < bComp);
    end
end

Anchor, internal = Class( "Anchor", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = Anchor.new;
Anchor.new = function( ... )
    local t, fresh = oldNew( ... );
    local int = internal[ t ];
    if ( fresh ) then
        int.manager = AnchorFrameManager.new( t );
        int.groups = {};
        int.fields.frame = int.manager.frame;
    end
    
    int:UpdateSettings();
    return t;
end

getfenv( 0 ).r_aint = internalFuncs;

