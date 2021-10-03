--[[
Name: LibRockLocale-1.0
Revision: $Rev: 237 $
Developed by: ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: Localization library for addons to use to handle proper
             localization and internationalization.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockLocale-1.0"
local MINOR_VERSION = tonumber(("$Revision: 237 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockLocale, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockLocale then
	return
end

-- #AUTODOC_NAMESPACE prototype

local _G = _G
local Rock = _G.Rock
local assert = _G.assert
local GetLocale = _G.GetLocale
local rawget = _G.rawget
local rawset = _G.rawset
local error = _G.error
local type = _G.type
local geterrorhandler = _G.geterrorhandler
local pcall = _G.pcall
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local GetTime = _G.GetTime
local next = _G.next

RockLocale.namespaces = oldLib and oldLib.namespaces or {}
local namespaces = RockLocale.namespaces
RockLocale.namespaceData = setmetatable(oldLib and oldLib.namespaceData or {}, {__mode='k'})
local namespaceData = RockLocale.namespaceData
RockLocale.prototype = oldLib and oldLib.prototype or {}
local prototype = RockLocale.prototype
local prototype_mt = {}

for k in pairs(prototype) do
	for name, ns in pairs(namespaces) do
		ns[k] = nil
	end
	prototype[k] = nil
end

local newList, del = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "del")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local GAME_LOCALE = GetLocale()

local namespacesToClear = setmetatable({}, {__mode='k'})
for _,ns in pairs(namespaces) do
	setmetatable(ns, nil)
	namespacesToClear[ns] = true
end
local timeToNextClear = 0
RockLocale.frame = oldLib and oldLib.frame or _G.CreateFrame("Frame")
local frame = RockLocale.frame
frame:Hide()
frame:UnregisterAllEvents()
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
local function scheduleClear(ns)
	if ns ~= frame then
		namespacesToClear[ns] = true
	end
	if next(namespacesToClear) then
		timeToNextClear = GetTime() + 5
		frame:Show()
	end
end
frame:SetScript("OnEvent", scheduleClear)
local function clearNamespace(ns)
	local namespaceData_ns = namespaceData[ns]
	local namespaceData_ns_currentTranslations = namespaceData_ns.currentTranslations
	local namespaceData_ns_baseTranslations = namespaceData_ns.baseTranslations
	for k, v in pairs(ns) do
		if namespaceData_ns_currentTranslations and namespaceData_ns_currentTranslations[k] then
			ns[k] = nil
		elseif namespaceData_ns_baseTranslations and namespaceData_ns_baseTranslations[k] then
			ns[k] = nil
		end
	end

	if rawget(ns, 'reverse') then
		ns.reverse = del(ns.reverse)
	end
	
	rawset(ns, true, true)
	ns[true] = nil
end
frame:SetScript("OnUpdate", function(this, elapsed)
	if GetTime() < timeToNextClear then
		return
	end
	for ns in pairs(namespacesToClear) do
		clearNamespace(ns)
		namespacesToClear[ns] = nil
	end
	frame:Hide()
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on the LibRockLocale-1.0 library.
Arguments:
	string - the namespace to check
Returns:
	boolean - whether the namespace has been created or not
Example:
	local has = Rock("LibRockLocale-1.0"):HasTranslationNamespace("MyAddon")
------------------------------------------------------------------------------------]]
function RockLocale:HasTranslationNamespace(name)
	return not not namespaces[name]
end
precondition(RockLocale, 'HasTranslationNamespace', function(self, name)
	argCheck(name, 2, "string")
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on the LibRockLocale-1.0 library.
	* This will create it if not existing already, or it will return what previously existed.
Arguments:
	string - the namespace to request
	[optional] table - the table to populate. This is only if you're declaring a library.
Returns:
	table - The translation namespace.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
------------------------------------------------------------------------------------]]
function RockLocale:GetTranslationNamespace(name, tab)
	local ns = namespaces[name]
	if not tab then
		if not ns then
			ns = newList()
		end
	else
		if ns and tab ~= namespaces[name] then
			error(("Bad argument #3 to `GetTranslationNamespace'. Cannot provide a %q different from the namespace already registered."):format("table"), 2)
		end
		ns = tab
	end
	namespaces[name] = ns
	local namespaceData_ns = namespaceData[ns]
	if namespaceData_ns then
		if not rawget(ns, 'AddTranslations') then
			clearNamespace(ns)
			namespaceData[ns] = del(namespaceData_ns)
			namespaceData_ns = nil
		else
			return ns
		end
	end
	
	namespaceData_ns = newList()
	namespaceData[ns] = namespaceData_ns
	namespaceData_ns.name = name
	
	setmetatable(ns, nil)
	
	for k, v in pairs(prototype) do
		ns[k] = v
	end
	setmetatable(ns, prototype_mt)
	
	scheduleClear(ns)

	return ns
end
precondition(RockLocale, 'GetTranslationNamespace', function(self, name, tab)
	argCheck(name, 2, "string")
	argCheck(tab, 3, "table", "nil")
end)
postcondition(RockLocale, 'GetTranslationNamespace', function(ret, self, name, tab)
	assert(self:HasTranslationNamespace(name))
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on a LibRockLocale-1.0 namespace.
	* For the first (base) locale set you specify, the values can be <tt>true</tt>, which means "same as the key".
Arguments:
	string - the locale to specify, e.g. "enUS", "deDE", "frFR", "esES", "zhCN", "zhTW", or "koKR".
	function - a function that will return a table. This will be called if the locale you specify is the proper one.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	-- assume we're deDE
	assert(L["Monkey"] == "Affe") -- as we specified
	assert(L["House"] == "House") -- fallback to the base locale (enUS)
------------------------------------------------------------------------------------]]
function prototype:AddTranslations(locale, func)
	local namespaceData_self = namespaceData[self]
	
	local namespaceData_self_baseLocale = namespaceData_self.baseLocale
	if not namespaceData_self_baseLocale then
		namespaceData_self_baseLocale = locale
		namespaceData_self.baseLocale = namespaceData_self_baseLocale
		
		local t = func()
		func = nil
		namespaceData_self.baseTranslations = t
		
		for k,v in pairs(t) do
			if v == true then
				t[k] = k
			end
		end
		
		if locale == GAME_LOCALE then
			namespaceData_self.currentLocale = locale
			namespaceData_self.currentTranslations = t
		end
	elseif locale == GAME_LOCALE then
		if namespaceData_self_baseLocale == locale or locale == namespaceData_self.currentLocale then
			error(("Bad argument #2 to `AddTranslations'. %q registered twice."):format(locale), 2)
		end
		
		namespaceData_self.currentLocale = locale
		
		local t = func()
		func = nil
		namespaceData_self.currentTranslations = t
	end
end
precondition(prototype, 'AddTranslations', function(self, locale, func)
	argCheck(locale, 2, "string")
	argCheck(func, 3, "function")
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on a LibRockLocale-1.0 namespace.
	* This is to be called after adding translations.
Arguments:
	boolean - whether to be strict or not. false by default.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	L:SetStrictness(true)
	-- assume we're deDE
	assert(L["Monkey"] == "Affe") -- as we specified
	local house = L["House"] -- pops an error, since we don't have the translation
------------------------------------------------------------------------------------]]
function prototype:SetStrictness(strict)
	local namespaceData_self = namespaceData[self]
	namespaceData_self.strict = strict
	
	clearNamespace(self)
end
precondition(prototype, 'SetStrictness', function(self, strict)
	argCheck(strict, 2, "boolean")
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on a LibRockLocale-1.0 namespace.
	* This is to be called after adding translations.
Arguments:
	boolean - whether to be in debug mode or not. false by default.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
	} end)
	L:SetDebug(true)
	-- assume we're enUS
	assert(L["Monkey"] == "Monkey") -- no errors
------------------------------------------------------------------------------------]]
function prototype:SetDebug(debug)
	local namespaceData_self = namespaceData[self]
	namespaceData_self.debug = debug
	
	clearNamespace(self)
end
precondition(prototype, 'SetDebug', function(self, debug)
	argCheck(debug, 2, "boolean")
end)

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on a LibRockLocale-1.0 namespace.
	* This is to be called after adding translations.
Arguments:
	boolean or string - false if the translation doesn't exist, otherwise it returns the translation.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	-- assume we're deDE
	assert(L:HasTranslation("Monkey") == "Affe") -- as we specified
	assert(L["House"] == "House")
	assert(not L:HasTranslation("House")) -- because not specified by the specific locale.
------------------------------------------------------------------------------------]]
function prototype:HasTranslation(key)
	local namespaceData_self = namespaceData[self]
	local namespaceData_self_currentTranslations = namespaceData_self.currentTranslations
	if not namespaceData_self_currentTranslations then
		return false
	end
	
	return namespaceData_self_currentTranslations[key]
end

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be called on a LibRockLocale-1.0 namespace.
	* This is to be called after adding translations.
Arguments:
	boolean - whether the translation exists on the base locale.
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	-- assume we're deDE
	assert(L:HasBaseTranslation("Monkey")) -- as we specified
	assert(L["House"] == "House")
	assert(L:HasBaseTranslation("House")) -- because it does exist, just not on the current locale.
------------------------------------------------------------------------------------]]
function prototype:HasBaseTranslation(key)
	local namespaceData_self = namespaceData[self]
	local namespaceData_self_baseTranslations = namespaceData_self.baseTranslations
	if not namespaceData_self_baseTranslations then
		return false
	end
	return not not namespaceData_self_baseTranslations[key]
end

local function initReverse(self)
	local reverse = newList()
	rawset(self, 'reverse', reverse)
	
	local namespaceData_self = namespaceData[self]
	local tmp = newList()
	local namespaceData_self_baseTranslations = namespaceData_self.baseTranslations
	if not namespaceData_self_baseTranslations then
		return
	end
	if not namespaceData_self.strict then
		for k,v in pairs(namespaceData_self_baseTranslations) do
			tmp[k] = v
		end
	end
	local namespaceData_self_currentTranslations = namespaceData_self.currentTranslations
	if namespaceData_self_currentTranslations then
		for k,v in pairs(namespaceData_self_currentTranslations) do
			tmp[k] = v
		end
	end
	for k,v in pairs(tmp) do
		reverse[v] = k
	end
	tmp = del(tmp)
end

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be accessed on a LibRockLocale-1.0 namespace.
	* This is to be accessed after adding translations.
	* This will error if the translation doesn't exist
Arguments:
	string - the translation key
Returns:
	string - the translated value
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	-- assume we're deDE
	assert(L["Monkey"] == "Affe") -- calling :__index("Monkey")
	assert(L["House"] == "House") -- calling :__index("House")
------------------------------------------------------------------------------------]]
function prototype_mt:__index(key)
	if key == "reverse" then
		initReverse(self)
		return self[key]
	end
	
	local namespaceData_self = namespaceData[self]
	local namespaceData_self_currentTranslations = namespaceData_self.currentTranslations
	if namespaceData_self_currentTranslations then
		local value = namespaceData_self_currentTranslations[key]
		if value then
			rawset(self, key, value)
			return value
		end
	end
	if not namespaceData_self.strict then
		local namespaceData_self_baseTranslations = namespaceData_self.baseTranslations
		if namespaceData_self_baseTranslations then
			local value = namespaceData_self_baseTranslations[key]
			if value then
				rawset(self, key, value)
				return value
			end
		else
			local _, ret = pcall(error, ("%s(%q): No translations registered"):format(MAJOR_VERSION, namespaceData_self.name), 3)
			geterrorhandler()(ret)
			rawset(self, key, key)
			return key
		end
	end
	if (type(key) == "string" and key:find("^On[A-Z]")) or key == 0 then
		return nil
	end
	if not namespaceData_self.debug then
		local _, ret
		if namespaceData_self.strict then
			_, ret = pcall(error, ("%s(%q): Translation %q does not exist for locale %s"):format(tostring(MAJOR_VERSION), tostring(namespaceData_self.name), tostring(key), tostring(namespaceData_self.currentLocale or namespaceData_self.baseLocale)), 3)
		else
			_, ret = pcall(error, ("%s(%q): Translation %q does not exist."):format(tostring(MAJOR_VERSION), tostring(namespaceData_self.name), tostring(key)), 3)
		end
		geterrorhandler()(ret)
	end
	rawset(self, key, key)
	return key
end

function prototype_mt:__newindex(key, value)
	if type(value) ~= "function" and (key ~= "name" or type(value) ~= "string") then
		error(("Cannot change the values of a %q instance"):format(MAJOR_VERSION), 2)
	end
end

--#FORCE_DOC
--[[----------------------------------------------------------------------------------
Notes:
	* This is to be accessed on a LibRockLocale-1.0 namespace.
	* This is to be accessed after adding translations.
	* Unlike normal indexing, this will not error if a translation does not exist.
	* This does follow the rules specified by :SetStrictness
Example:
	local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("MyAddon")
	L:AddTranslations("enUS", function() return {
		["Monkey"] = true, -- same as ["Monkey"] = "Monkey"
		["House"] = true, -- same as ["House"] = "House"
	} end)
	L:AddTranslations("deDE", function() return {
		["Monkey"] = "Affe",
		-- not specifying House
	} end)
	-- assume we're deDE
	assert(L.reverse["Affe"] == "Monkey") -- because L["Monkey"] == "Affe"
	assert(L.reverse["House"] == "House") -- because non-strict, L["House"] == "House", so the inverse is true
	-- more generally:
	assert(L.reverse[L[anything] ] == anything)
	assert(L[L.reverse[anything] ] == anything)
------------------------------------------------------------------------------------]]
local function reverse() end; reverse = nil -- only for autodoc

for name, ns in pairs(namespaces) do
	for k, v in pairs(prototype) do
		ns[k] = v
	end
	setmetatable(ns, prototype_mt)
end

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local base, other = GetLocale(), GetLocale() == "enUS" and "deDE" or "enUS"
	assert(not RockLocale:HasTranslationNamespace(MAJOR_VERSION .. "UnitTest"))
	local L = RockLocale:GetTranslationNamespace(MAJOR_VERSION .. "UnitTest")
	assert(RockLocale:HasTranslationNamespace(MAJOR_VERSION .. "UnitTest"))
	L:AddTranslations(base, function() return {
		Monkey = true,
		House = true,
	} end)

	L:AddTranslations(other, function() return {
		Monkey = "Affe"
	} end)

	L = RockLocale:GetTranslationNamespace(MAJOR_VERSION .. "UnitTest")
	assert(L:HasTranslation("Monkey") == "Monkey")
	assert(L:HasTranslation("House") == "House")
	assert(L:HasBaseTranslation("House"))
	assert(not L:HasBaseTranslation("Louse"))
	assert(L.Monkey == "Monkey")
	assert(L.House == "House")
	-- check for speed
	assert(rawget(L, 'Monkey') == "Monkey")
	assert(rawget(L, 'House') == "House")
	
	assert(L.reverse.Monkey == "Monkey")
	assert(L.reverse.House == "House")
	
	clearNamespace(L)
	
	assert(rawget(L, 'Monkey') == nil)
	assert(rawget(L, 'House') == nil)
	assert(L.Monkey == "Monkey")
	assert(L.House == "House")
	assert(rawget(L, 'Monkey') == "Monkey")
	assert(rawget(L, 'House') == "House")
	
	L = nil
	assert(RockLocale:HasTranslationNamespace(MAJOR_VERSION .. "UnitTest"))
	RockLocale.namespaces[MAJOR_VERSION .. "UnitTest"] = nil
	collectgarbage('collect')
	assert(not RockLocale:HasTranslationNamespace(MAJOR_VERSION .. "UnitTest"))
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local base, other = GetLocale() == "enUS" and "deDE" or "enUS", GetLocale()
	-- note, these tests only work properly if you're "enUS"
	local L = RockLocale:GetTranslationNamespace(MAJOR_VERSION .. "UnitTest2")
	L:AddTranslations(base, function() return {
		Affe = true,
		Haus = true,
	} end)

	L:AddTranslations(other, function() return {
		Affe = "Monkey"
	} end)

	L = RockLocale:GetTranslationNamespace(MAJOR_VERSION .. "UnitTest2")
	assert(L:HasTranslation("Affe") == "Monkey")
	assert(not L:HasTranslation("Haus"))
	assert(not L:HasTranslation("Maus"))
	
	assert(L.Affe == "Monkey")
	assert(L.Haus == "Haus")
	-- check for speed
	assert(rawget(L, 'Affe') == "Monkey")
	assert(rawget(L, 'Haus') == "Haus")
	
	assert(L.reverse.Monkey == "Affe")
	assert(L.reverse.Affe == nil)
	assert(L.reverse.Haus == "Haus")
	
	RockLocale.namespaces[MAJOR_VERSION .. "UnitTest2"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local fakeBabble = Rock:NewLibrary("LibFakeBabble-1.0", 1)
	local L = RockLocale:GetTranslationNamespace("LibFakeBabble-1.0", fakeBabble)
	L:AddTranslations(GetLocale(), function() return {
		Monkey = true,
		House = true,
	} end)
	
	Rock:FinalizeLibrary("LibFakeBabble-1.0")
	
	assert(L.Monkey == "Monkey")
	assert(L.House == "House")
	
	local fakeBabble = Rock:NewLibrary("LibFakeBabble-1.0", 2)
	local L = RockLocale:GetTranslationNamespace("LibFakeBabble-1.0", fakeBabble)
	L:AddTranslations(GetLocale(), function() return {
		Monkey = true,
		House = true,
		Cat = true,
	} end)
	
	Rock:FinalizeLibrary("LibFakeBabble-1.0")
	
	assert(L.Monkey == "Monkey")
	assert(L.House == "House")
	assert(L.Cat == "Cat")
	
	RockLocale.namespaces["LibFakeBabble-1.0"] = nil
end)
