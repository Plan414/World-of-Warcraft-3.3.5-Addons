--[[
    This code is responsible for managing the overall layout of the timers for any specific module.  
    Basically, it deals with what happens when a timer is added or removed - the actual updates of 
    the timer are left for other code.
    
    Timer Scripts:
        OnTimerEnter(frame, timerdata)
        OnTimerClick(frame, timerdata, button)
        OnGroupEnter(frame, groupdata)
        OnGroupClick(frame, groupdata, button)
        OnDragEnter(frame)
        OnDragClick(frame, button)
--]]
AsheylaLib:Package( "TimerLib" );

TimerLib = AsheylaLib:NewModule("TimerLib");
TimerLib.timers = {};
TimerLib.anchors = {};

local anchors = TimerLib.anchors;
local timers = TimerLib.timers;

local GetTime = GetTime;
local huge = math.huge;
local lower = string.lower;
local pairs = pairs;
local select = select;
local type = type;
local LoadAddOn = LoadAddOn;
local max = math.max;
local fmod = math.fmod;

local defaultSettings, updateTimerSettings;

function updateTimerSettings(self)
    if not self:GetUserSet("timerSettings", "Default Timer") then
        self:Set("timerSettings", "Default Timer", {});
    end
    if not self:GetUserSet("anchorSettings", "Default Anchor") then
        self:Set("anchorSettings", "Default Anchor", {});
    end
    
    for name, anchor in pairs(anchors) do
        if not self:Get("anchorSettings", name) then
            anchors[name] = nil;
        end
    end
    
    for name, anchor in pairs(anchors) do
        anchor:UpdateSettings();
    end
end

function TimerLib:Commands(msg)
    local loaded = LoadAddOn("DoTimer_Options");
    if loaded then
        local panel = (msg == "a" or msg == "anchor") and "DoTimer Anchors" or "DoTimer Timers";
        AsheylaLib:Import( "GUILib" ):ShowPanel(panel);
    end
end
TimerLib:MakeSlashCmd("/TimerLib", "/tl");

-- called by external modules to create timers onscreen.  
-- TimerLib assumes that timerdata is a table consisting of the following elements:
--[[
    name: name of the timer
    time: (optional) when it began
    duration (optional): how long it's running
    texture (optional): texture of the timer
    stack (optional): stack of the timer
--]]
-- groupdata is as follows:
--[[
    name: group name
    icon (optional): raid icon
    level (optional): target level
    uniqueID (optional): a unique identifier for the group
--]]
-- groupdata can also be a string representing the name of the group, if you don't want to make a table for it

function TimerLib:NewTimer(timerdata, groupdata, module, timerSettings, timerPriority, timerHidden, anchorName, groupPriority, groupHidden)
    local time = GetTime();
    module = module or self;
    timerdata = timerdata or {duration = 10, time = time};
    groupdata = groupdata or "Default Group";
    anchorName = anchorName or "Default Anchor";
    
    local timer = Timer.new( module, timerdata, timerSettings, timerPriority, timerHidden );
    --print( "adding timer " .. timer.id );
    local anchor = TimerLib:GetAnchor( anchorName );
    local group = anchor:FindGroup( groupdata, groupPriority, groupHidden );
    group:AddTimer( timer );
    --print( "done adding timer " .. timer.id );
    timers[ timer.id ] = timer;
    return timer.id;
end

function TimerLib:GetAnchor(name)
    anchors[ name ] = anchors[ name ] or Anchor.new( name );
    return anchors[ name ];
end

-- flags the timer for updating on the screen (something about it has changed)
function TimerLib:UpdateTimer(id)
    local timer = timers[ id ];
    if timer and timer.id == id and timer.data then
        timer:UpdateData();
        return true;
    end
    return false;
end

-- flags the group for updating on the screen (something about it has changed)
function TimerLib:UpdateGroup(id)
    local timer = timers[ id ];
    if timer and timer.id == id and timer.group.data then
        timer.group:UpdateData();
    end
end

-- deletes the timer from the screen
function TimerLib:DeleteTimer(id, destroy)
    local timer = timers[ id ];
    if timer and timer.id == id then
        if destroy then
            timer:Destruct();
        else
            timer:Remove();
        end
    end
end

function TimerLib:DeleteGroup( id )
    local timer = timers[ id ];
    if timer and timer.id == id then
        local group = timer.group;
        group:DeleteAllTimers();
    end
end

function TimerLib:UpdateGroupInfo(id, priority, hidden)
    local timer = timers[ id ];
    if timer then
        timer.group.priority = priority;
        timer.group.hidden = hidden;
    end
end

function TimerLib:UpdateTimerInfo(id, priority, hidden, settings)
    local timer = timers[ id ];
    if timer and timer.id == id then
        timer.priority = priority;
        timer.hidden = hidden;
        timer.settings = settings;
    end
end

function TimerLib:MoveTimer(id, groupdata, anchorName, groupPriority, groupHidden)
    local timer = timers[ id ];
    if timer and timer.id == id then
        local newGroup = self:GetAnchor(anchorName):FindGroup(groupdata, groupPriority, groupHidden);
        timer.group:MoveTimer( timer, newGroup );
    end
end

function timerDone( timer )
    timers[ timer.id ] = nil;
end

function sanitize( f )
    f:ClearAllPoints();
    for _, v in pairs( f ) do
        if type( v ) == "table" and v[ 0 ] then
            sanitize( v );
        end
    end
end

drawingBackground = false;

function TimerLib:DeleteAllTimers(module)
    for _, timer in pairs( timers ) do
        if timer.module == module then
            timer:Destruct();
        end
    end
end

function TimerLib:UpdateAnchorToCursor(anchorName)
    for name, anchor in pairs(anchors) do
        if name == anchorName then
            anchor:UpdateToCursor();
        end
    end
end

function TimerLib:FormatTime( id, number )
    local timer = timers[ id ];
    if timer and timer.id == id then
        return timer:FormatTime( number );
    end
end

TimerLib:SetScript( "OnTimerClick", function( self, group, timer, id, button )
    if button == "RightButton" then
        self:DeleteTimer( id, 1 );
    end
end );

defaultSettings = {
    anchorSettings = {
        ["Default Anchor"] = {
            locked = false,
            displayNames = true,
            displayIcons = true,
            groupDirection = "down",
            groupSpacing = 10,
            timerDirection = "down", 
            timerSpacing = 5, 
            overflowDirection = "right",
            moveName = true,
            scale = 1,
            timerSortMethod = "Time Remaining (D)",
            groupSortMethod = "Time Added (D)",
            maxNumGroups = 0,
            overflowPoint = 0,
            defaultTimerSetting = "Default Timer",
            standardAlpha = 1,
            combatAlpha = 1,
            mouseoverAlpha = 1,
            hideAll = false,
            nameFontHeight = 12,
            nameScale = 1,
            nameSpacing = 5,
            timerJustification = "auto",
            centering = "none",
            font = "Friz Quadrata TT",
            interactable = true,
            anchorPoint = "TOPLEFT",
            relativePoint = "BOTTOMLEFT",
            relativeTo = "UIParent",
            positionX = 700,
            positionY = 500,
            nameFormat = "%l %s",
            nameLevelFormat = "[%s]",
            nameRaidIconFormat = "%s",
            anchorsToCursor = false, -- not customizable
            nameTextColor = {
                r = 1.0, g = .82, b = 0,
            },
        },
    },
    
    timerSettings = {
        ["Default Timer"] = {
            timerFormat = "bar",
            alpha = .75,
            scale = 1,
            ghostLength = 3;
            redPoint = 5,
            fadeInLength = 1,
            fadeOutLength = 1,
            timeFormat = "letters",
            tenths = true,
            clickable = true,
            soundAlert = false,
            ghosts = true,
            tooltips = true,
            font = "Friz Quadrata TT",
            
            iconDisplayFormat = "outside",
            iconShowCooldown = false,
            iconFlipText = false,
            iconReverseCooldown = true,
            iconFontHeight = 12,
            iconUseBG = false;
            
            barFlipIcon = false,
            barMajorLength = 150,
            barMinorLength = 16,
            barFontHeight = 12,
            barOrientation = "horizontal",
            barShowIcon = true,
            barTexture = "Aluminium",
            barLeftText = "Timer Name",
            barRightText = "Time Remaining",
            barReversed = false,
            barGrow = false,
            barScaling = "standard",
            barAbsScale = 0,
            barTextColor = {
                r = .95, g = .95, b = .95,
            },
            barBackgroundColor = { -- now also applied to icons, but keeping the name so the setting doesn't break
                r = .1, g = .6, b = .8,
            },
            
            startColor = {
                r = .2, g = .9, b = .2,
            },
            middleColor = {
                r = .9, g = .9, b = .2,
            },
            finalColor = {
                r = .9, g = .2, b = .2,
            },
            ghostColor = {
                r = .32, g = .56, b = 1.0,
            },
        },
    },
    
    LBF = {
        skinID = "Blizzard",
        gloss = 0,
        backdrop = false,
        colors = {},
    },
};

TimerLib:AddDefaultSettings(defaultSettings);
TimerLib:AddSettingsUpdateScript(updateTimerSettings);

hooksecurefunc("SetCVar", function(cvar, ...)
    if not (cvar == "uiscale" or cvar == "useUiScale") then return; end
    for name, anchor in pairs(anchors) do
        anchor:UpdateSettings();
    end
end);
