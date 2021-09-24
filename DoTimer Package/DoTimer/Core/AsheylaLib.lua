--[[
    This code is responsible for managing all modules' and libraries' creations.  
    It is the glue for the rest of my addons.
--]]

-- global variables!
AsheylaLib = {};
AsheylaLib_Settings = {};

-- current active profile
local activeProfile = "Default";
-- set to true when DoTimer is loaded
local loaded = false;
-- contains references to all events that have been registered, and who registered them
local events = {};
-- holds all the modules created
local modules = {};
-- the class that modules are a created from
local Module;
-- the map of modules to their internal representations
local internal;

-- returns the version
function AsheylaLib:ReturnVersion()
    return GetAddOnMetadata("DoTimer", "Version");
end

-- returns the date uploaded
function AsheylaLib:ReturnDateUploaded()
    return GetAddOnMetadata("DoTimer", "X-Date");
end

-- called by modules to initiate themselves
local counter = 0;
function AsheylaLib:NewModule( name )
    counter = counter + 1;
    local module = Module.new( name or "AsheylaLibModule" .. counter );
    modules[ module ] = true;
    return module;
end

function AsheylaLib:GetActiveProfile()
    return activeProfile;
end

function AsheylaLib:SetActiveProfile(name)
    activeProfile = name;
    AsheylaLib_Settings[activeProfile] = AsheylaLib_Settings[activeProfile] or {};
    for module in pairs(modules) do
        table.wipe(internal[ module ].cached);
    end
    for module in pairs(modules) do
        module:UpdateSettings();
    end
    
    self:CallEvent("PROFILE_UPDATE");
end

function AsheylaLib:CopyFromProfile(name)
    if AsheylaLib_Settings[name] then
        AsheylaLib_Settings[activeProfile] = self:Import( "core" ).copyTable(AsheylaLib_Settings[name]);
        for module, workspace in pairs(modules) do
            table.wipe(workspace.cached);
        end
        for module in pairs(modules) do
            module:UpdateSettings();
        end
    end
    self:CallEvent("PROFILE_UPDATE");
end

function AsheylaLib:ClearAllSettings()
    AsheylaLib_Settings[activeProfile] = {};
    for module in pairs(modules) do
        module:UpdateSettings();
    end
    self:CallEvent("PROFILE_UPDATE");
end

function AsheylaLib:InSimpleMode()
    if AsheylaLib_Settings.simpleMode == nil then
        AsheylaLib_Settings.simpleMode = true;
        self:Import( "core" ).alertUser("DoTimer is currently in Simple Mode.  " ..
            "Many of its complex features have been disabled.  To disable Simple Mode, " .. 
            "go to DoTimer's main settings page and uncheck 'Simple Mode' at the top.");
        return true;
    else
        return AsheylaLib_Settings.simpleMode;
    end
end

function AsheylaLib:SetSimpleMode(bool)
    AsheylaLib_Settings.simpleMode = bool;
    for module in pairs(modules) do
        module:UpdateSettings();
    end
end

-- calls an event; all modules who have registered it and have an OnEvent Script will have the script called
function AsheylaLib:CallEvent(event, ...)
    local eventTable = events[event];
    if eventTable then
        for module, func in pairs(eventTable) do
            if (type(func) ~= "function") then
                func = module:GetScript("OnEvent");
                if (func and type(func) == "function") then 
                    --pcall(func, module, event, ...);
                    func( module, event, ... );
                end
            else
                --pcall( func, module, ... );
                func( module, ... );
            end
        end
    end
end

local f = CreateFrame("Frame");
f:RegisterEvent("ADDON_LOADED");
f:SetScript("OnEvent", function(self, event, addon)
    if addon == "DoTimer" then
        loaded = true;
        local id = UnitName("player") .. "-" .. GetRealmName();
        for name, settings in pairs(AsheylaLib_Settings) do
            if type(settings) == "table" and settings[id] then
                activeProfile = name;
                break;
            end
        end
        AsheylaLib_Settings[activeProfile] = AsheylaLib_Settings[activeProfile] or {};
        for module in pairs(modules) do
            module:UpdateSettings();
        end
    end
end)

local f = CreateFrame("Frame", nil, InterfaceOptionsFrame);
f:SetScript("OnShow", function() LoadAddOn("DoTimer_Options"); end);

local verbose = false;
local f = CreateFrame( "Frame" );
f:RegisterEvent( "PLAYER_ENTERING_WORLD" );
f:SetScript( "OnEvent", function( self, event )
    verbose = true;
    self:UnregisterEvent( event );
end);

local _G = _G;
local lookupFunc = function( t, k )
    if verbose and k ~= "TimerLib" and k ~= "AsheylaLib" then
        print( "global accessed!: ", k );
    end
    return _G[ k ];
end

local packages = {};
function AsheylaLib:Package( name )
    local t = packages[ name ];
    if not t then
        local lookup;
        if name == "core" then
            lookup = _G;
        else
            lookup = packages.core;
        end
        t = setmetatable( {}, { __index = lookup } );
        packages[ name ] = t;
    end
    setfenv( 2, t );
end

function AsheylaLib:Import( name )
    if packages[ name ] then
        if name == "core" then
            return packages[ name ];
        else
            return packages[ name ][ name ];
        end
    end
end

local externalFuncs = {
    Print = true,
    HeaderPrint = true,
    AddDefaultSettings = true,
    ClearSettings = true,
    Get = true,
    Set = true,
    GetUserSet = true,
    GetDefault = true,
    UpdateSettings = true,
    AddSettingsUpdateScript = true,
    SetScript = true,
    CallScript = true,
    GetScript = true,
    RegisterEvent = true,
    UnregisterEvent = true,
    IsRegisteredEvent = true,
    MakeSlashCmd = true,
    
    Destruct = function( self )
        error( "Modules cannot be destructed." );
    end,
};

AsheylaLib.Class = setmetatable( {}, {
    __index = {
        READONLY = 0,
        READWRITE = 1,
    },
    __newindex = function( t, k, v )
        error( "Attempt to write to the Class table" );
    end,
    __call = function( self, name, fields, order, internalFuncs, externalFuncs, persistent )
        local internal, external;
        local map = {};
        local pool = {};
        
        local internalDestruct = function( self )
            for k in pairs( self ) do
                if not ( k == "fields" or persistent[ k ] or internal.funcs[ k ] ) then
                    self[ k ] = nil;
                end
            end
            for k in pairs( self.fields ) do
                if not ( persistent[ k ] ) then
                    self.fields[ k ] = nil;
                end
            end
        end
        local destructFunc = function( self, dontRecycle )
            local external = map[ self ];
            for k in pairs( external ) do
                external[ k ] = nil;
            end
            internalDestruct( self );
            if not dontRecycle then
                tinsert( pool, external );
            end
        end
        
        internal = {
            __index = function( t, k )
                return t.fields[ k ];
            end,
            __newindex = function( t, k, v )
                local access = fields[ k ];
                if ( access == self.READONLY ) then
                    error( "Attempt to modify a read-only value: " .. k );
                elseif ( access == self.READWRITE ) then
                    if ( t.fields[ k ] ~= v ) then
                        t.fields[ k ] = v;
                        t:FieldUpdate( k, v );
                    end
                else
                    rawset( t, k, v );
                end
            end,
            funcs = {
                FieldUpdate = function( self, k, v )
                    -- should be modified by class creator,
                    -- should he desire the ability to see when
                    -- fields are updated
                    -- blank here to prevent errors when called
                end,
                
                Destruct = destructFunc,
            },
        };

        external = {
            __index = function( t, k )
                if ( fields[ k ] ) then
                    return map[ t ][ k ];
                else
                    return external.funcs[ k ];
                end
            end,
            
            __newindex = function( t, k, v )
                if ( fields[ k ] ) then
                    map[ t ][ k ] = v;
                elseif external.funcs[ k ] then
                    error( "Attempt to override Class function: " .. k );
                else
                    rawset( t, k, v );
                end
            end,
            funcs = {
                Destruct = function( self )
                    return map[ self ]:Destruct();
                end,
            },
        };
        
        for k, v in pairs( internalFuncs ) do
            internal.funcs[ k ] = v;
        end
        for k, v in pairs( externalFuncs ) do
            if ( type( v ) == "function" ) then
                external.funcs[ k ] = v;
            else
                external.funcs[ k ] = function( self, ... )
                    --if k ~= "Get" then print( name, k ) end
                    return map[ self ][ k ]( map[ self ], ... );
                end
            end
        end
        
        return {
            new = function( ... )
                if ( #pool > 0 ) then
                    local t = tremove( pool );
                    local int = map[ t ];
                    for i, f in ipairs( order ) do
                        int.fields[ f ] = select( i, ... );
                    end
                    return t, false;
                end
                
                local t = setmetatable( {}, external );
                
                local int = {
                    fields = {},
                };
                for i, f in ipairs( order ) do
                    int.fields[ f ] = select( i, ... );
                end
                for n, f in pairs( internal.funcs ) do
                    int[ n ] = f;
                end
                setmetatable( int, internal );
                map[ t ] = int;
                map[ int ] = t;
                
                return t, true;
            end,
        }, map, destructFunc;
    end
});

local order = {
    "name",
};

local fields = {
    name = AsheylaLib.Class.READONLY,
};

local persistent = {};

local stringify;

local strconcat = strconcat;
local pairs = pairs;
local ipairs = ipairs;
local tinsert = tinsert;
local wipe = table.wipe;
local select = select;
local strupper = string.upper;
local setglobal = setglobal;

local internalFuncs = {
    Print = function( self, ... )
        if (DEFAULT_CHAT_FRAME) then
            DEFAULT_CHAT_FRAME:AddMessage(strconcat(stringify(...))); 
        end
    end,
    
    HeaderPrint = function( self, ... )
        self:Print("|cff00ffff", self.name, "|r: ", ...);
    end,
    
    AddDefaultSettings = function( self, newSettings )
        local currSettings = self.defaultSettings;
        for i, v in pairs( newSettings ) do
            currSettings[i] = v;
        end
    end,
    
    ClearSettings = function( self )
        local settings = AsheylaLib_Settings[activeProfile][self.name];
        if settings then
            wipe(settings);
            wipe(self.cached);
            self:UpdateSettings();
        end
    end,
    
    Get = function( self, ... )
        if not loaded then return; end
        local num, cached = select("#", ...);
        if num == 1 then
            cached = self.cached;
            local cache = cached[...];
            if cache ~= nil then 
                return cache; 
            end
        end
        local setting = self:GetUserSet(...);
        if setting == nil then
            setting = self:GetDefault(...);
        end
        if num == 1 then
            cached[...] = setting;
        end
        return setting;
    end,
    
    Set = function( self, ... )
        if not loaded then return; end
        local setting = AsheylaLib_Settings[activeProfile][self.name];
        if (not setting) then
            setting = {};
            AsheylaLib_Settings[activeProfile][self.name] = setting;
        end
        
        local num = select("#", ...);
        
        if num == 2 then
            self.cached[...] = select(2, ...);
        else
            self.cached[...] = nil;
        end
        
        if type(select(1, ...)) == "table" and num == 3 then
            setting = select(1, ...);
        else
            for i = 1, num - 2 do
                local val = select(i, ...);
                setting[val] = setting[val] or {};
                setting = setting[val];
            end
        end
        
        local ind = select(num - 1, ...);
        local val = select(num, ...);
        
        setting[ind] = val;
        
        if not self.updatingSettings then
            self:UpdateSettings();
        end
    end,
    
    GetUserSet = function( self, ... )
        if not loaded then return; end
        local setting = AsheylaLib_Settings[activeProfile][self.name];
        if setting then
            for i = 1, select("#", ...) do
                setting = setting[select(i, ...)];
                if (setting == nil) then
                    break;
                end
            end
        end
        return setting;
    end,
    
    GetDefault = function( self, ... )
        if not loaded then return; end
        local setting = self.defaultSettings;
        for i = 1, select("#", ...) do
            setting = setting[select(i, ...)];
            if (setting == nil) then
                break;
            end
        end
        
        return setting;
    end,
    
    UpdateSettings = function( self )
        self.updatingSettings = true;
        if (self.updateScripts) then
            for index,value in ipairs(self.updateScripts) do 
                value( internal[ self ] );
            end
        end
        self.updatingSettings = false;
    end,
    
    AddSettingsUpdateScript = function( self, func )
        tinsert(self.updateScripts, func);
    end,
    
    SetScript = function( self, script, func )
        self.scripts[script] = func;
    end,
    
    CallScript = function( self, script, ... )
        local func = self:GetScript(script);
        if (func) then
            func(internal[ self ], ...)
        end
    end,
    
    GetScript = function( self, script )
        return self.scripts[script]
    end,
    
    RegisterEvent = function( self, event, func )
        events[event] = events[event] or {};
        events[event][internal[self]] = func or 1;
    end,
    
    UnregisterEvent = function( self, event )
        events[event] = events[event] or {};
        events[event][internal[self]] = nil;
    end,
    
    IsRegisteredEvent = function( self, event )
        return events[event] and events[event][internal[self]];
    end,
    
    MakeSlashCmd = function( self, ... )
        local global = strupper(self.name);
        
        SlashCmdList[global] = function(msg) 
            if (internal[self].Commands) then 
                internal[self]:Commands(msg);  
            end 
        end;
        
        for i = 1, select("#", ...) do
            local slash = select(i, ...);
            setglobal("SLASH_" .. global .. i, slash);
        end
    end,
};

function stringify( ... )
    local num = select( "#", ... );
    
    if ( num == 1 ) then
        return tostring( ... );
    else
        return tostring((select(1, ...))), stringify(select(2, ...));
    end 
end

Module, internal = AsheylaLib.Class( "Module", fields, order, internalFuncs, externalFuncs, persistent );
local oldNew = Module.new;
Module.new = function( ... )
    local t = oldNew( ... );
    local int = internal[ t ];
    
    int.updateScripts = {};
    int.cached = {};
    int.defaultSettings = {};
    int.scripts = {};
    
    return t;
end

AsheylaLib:Package( "core" );
Class = AsheylaLib.Class;

getfenv( 0 ).r_get = internalFuncs.Get;
