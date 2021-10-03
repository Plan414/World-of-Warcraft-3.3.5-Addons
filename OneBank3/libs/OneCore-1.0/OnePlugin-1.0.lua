--- '''OnePlugin-1.0''' provides a plugin framework built ontop of Ace3's Module system
-- @class file
-- @name OnePlugin-1.0.lua
local MAJOR, MINOR = "OnePlugin-1.0", tonumber("46") or 9999
local OnePlugin, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not OnePlugin then return end -- No Upgrade needed.

--[[
     OMFG I'm glad we already had this crazy code for Ace3.
	 xpcall safecall implementation
]]
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end
	
		local function dispatch(func, ...)
			 method = func
			 if not method then return end
			 ARGS = ...
			 return xpcall(call, eh)
		end
	
		return dispatch
	]]
	
	local args = {}
	for i = 1, argCount do args[i] = "arg"..i end
	code = code:gsub("ARGS", tconcat(args, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end

local function safecall(func, ...)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnInitialize OnEnable etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then
		return Dispatchers[select('#', ...)](func, ...)
	end
end

-- Yaye copy pasta from AceAddon /end

-- Upgrading Library Variables
OnePlugin.embeded = OnePlugin.embeded or {}

-- Usage sigs for the function error messages
local usages = {
    NewPluginType = "Usage: NewPluginType(name)",  
    SetActiveLimit = "Usage: SetActiveLimit(number)",
    NewPlugin = "Usage: NewPlugin(type, name[, ...])",
    GetPlugin = "Usage: GetPlugin(type, name)",
    SetBasePluginPrototype = "Usages: SetBasePluginPrototype(prototype)",
}

-- This metatable will be provided on the prototype objects when they are passed back for configuration
local Configuration = {}
local ConfigurationMetatable = { __index = Configuration }
         
-- This metatable will be provided at runtime.
local Runtime = {}
local RuntimeMetatable = { __index = Runtime }

--- Creates a new plugin and returns a table to be populated with functionality.  Provides for automatic embedding of libraries if NewModule is available.       
-- @param type a valid registered plugin type
-- @param name the name of this plugin, must be unique.                           
-- @param ... optional list of libraries to embed.  Has no affect if NewModule is not available.
-- @usage local MyPlugin = MyAddon:NewPlugin('plugin_type', 'MyPlugin')
function OnePlugin:NewPlugin(type, name, ...)

    if not name then
       error(usages.NewPlugin, 2)
    end
    
    if not self.__pluginTypes[type] then
        error(format("%s: 'type' - %s plugin type does not exist.", usages.NewPlugin, type), 2)
    end
    
    if self.__pluginsByTypes[type][name] or (self.GetModule and self:GetModule(name, true)) then
        error(format("%s: 'name' - plugin '%s' already exists.", usages.NewPlugin, name), 2)
    end           
                          
    -- This is probably unneeded most of the time, but I can't really think of a better place 
    -- to do this.  This strips the configurtion methods off the class, also adds the runtime meta.
    -- I thought about having a 'finalize' function as part of the config meta.  But haven't decided.
    
    setmetatable(self.__pluginTypes[type], self.__basePluginPrototypeMetatable or RuntimeMetatable)
    
    local plugin          
    
    if self.NewModule then
        plugin = self:NewModule(format("%s_%s", type, name), self.__pluginTypes[type], ...)
    else
        plugin = setmetatable({}, { __index = self.__pluginTypes[type] })
    end
                                                       
    plugin.pluginType = type
    plugin.pluginName = name   
    plugin.pluginFor = self

    safecall(self.OnPluginCreated, type, name, plugin) 
    self.__pluginsByTypes[type][name] = plugin
    
    return plugin
end                      

--- Returns an existing plugin                                                     
-- @param type a valid registered plugin type
-- @param name the name of this plugin, must be unique.
-- @param silent whether or not to error when called.
function OnePlugin:GetPlugin(type, name, silent)
    if not name then
       error(usages.NewPlugin, 2)
    end

    if not self.__pluginTypes[type] and not silent then
        error(format("%s: 'type' - %s plugin type does not exist.", usages.NewPlugin, type), 2)
    end

    if not self.__pluginsByTypes[type][name] and not silent then
        error(format("%s: 'name' - plugin '%s' does not exist.", usages.NewPlugin, name), 2)
    end                                           
    
    return self.__pluginsByTypes[type] and self.__pluginsByTypes[type][name] or nil
end

--- Creates a new plugin type.  
-- @note The plugin type information are stored on the table in which OnePlugin is embedded under __pluginTypes.
-- @param name Name of the plugin type                                                  
-- @return a fresh dictionary that can be used to build a prototype for the plugin type.
-- @usage local SortingPlugins = MyAddon:NewPluginType('plugin_type')
function OnePlugin:NewPluginType(name)
    
    if not name then
       error(usages.NewPluginType, 2)
    end
    
    if self.__pluginTypes[name] then
        error(format("%s: 'name' - %s plugin type already created.", usages.NewPluginType, name), 2)
    end
    
   self.__pluginTypes[name] = {
       __pluginSettings = {
       },
   }    
   
   self.__pluginsByTypes[name] = {}
                                                                    
   return setmetatable(self.__pluginTypes[name], ConfigurationMetatable)
end

--- Provides an iterator for scanning the available plugin types
-- @return a iterator over the name, prototype of the available types.
-- @usage
-- -- Print a list of all registered plugin types.
-- for typeName, _ in MyAddon:IteratePluginTypes() do
--     self:Print(typeName)
-- end
function OnePlugin:IteratePluginTypes()
    return pairs(self.__pluginTypes)
end

--- Allows for iteration over a given type of plugins.
-- @return an iterator over name, plugin of the available plugins.
-- @usage
-- -- Print a list of all registered plugins of a given type.
-- for pluginName, _ in MyAddon:IteratePluginByType('plugin_type')
--     self:Print(pluginName)
-- end
function OnePlugin:IteratePluginsByType(type)
    return pairs(self.__pluginsByTypes[type])
end 

local function enabledIterator(plugins, name)
	local name, plugin = next(plugins, name)
	if name and not plugin:IsEnabled() then
		-- skip disabled modules
		return enabledIterator(plugins, name)
	end
	return name, plugin
end

function OnePlugin:IterateActivePluginsByType(type)
    return enabledIterator, self.__pluginsByTypes[type], nil
end

--- Sets a table as being a base prototype for all of your plugins.  
-- @note At runtime your type specific prototypes will subclass from this table.
-- @param prototype A table to be used as the base prototype.
-- @usage
-- local PluginBase = {}
-- MyAddon:SetBasePluginPrototype(PluginBase)
function OnePlugin:SetBasePluginPrototype(prototype)
    if type(prototype) ~= 'table' then
        error(format("%s: 'prototype' - expected type 'table' got '%s.", usages.SetBasePluginPrototype, type(prototype)), 2)
    end
    
    self.__basePluginPrototypeMetatable = { __index = setmetatable(prototype, RuntimeMetatable) }   
end                                               
                         

--- Enables a plugin
function OnePlugin:EnablePlugin(plugin)
    plugin:SetEnabled(true)
    plugin:Enable()
end                 

function OnePlugin:DisablePlugin(plugin)
    plugin:SetEnabled(false)
    plugin:Disable()
end

-- Mixin System
local mixins = {
    "NewPlugin",    
    "GetPlugin",      
    "NewPluginType",
    "IteratePluginTypes", 
    "IteratePluginsByType",  
    "IterateActivePluginsByType",
    "SetBasePluginPrototype",
    "EnablePlugin",
    "DisablePlugin",
}

function OnePlugin:Embed( target )
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end                        
	
	self.embeded[target] = true
	
	--Creating data storage on the target, upgrade safe.
	target.__pluginTypes = target.__pluginTypes or {}   
	target.__pluginsByTypes = target.__pluginsByTypes or {}  
	target.__basePluginPrototypeMetatable = target.__basePluginPrototypeMetatable 
	
	return target
end

--- Upgrade our old embeded
for target, v in pairs( OnePlugin.embeded ) do
	OnePlugin:Embed( target )
end