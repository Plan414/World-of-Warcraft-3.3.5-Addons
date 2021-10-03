--[[
Name: LibRockHook-1.0
Revision: $Rev: 228 $
Developed by: ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: Library to allow for safe hooking of functions, methods, and scripts.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockHook-1.0"
local MINOR_VERSION = tonumber(("$Revision: 228 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockHook, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockHook then
	return
end
-- #AUTODOC_NAMESPACE RockHook

local _G = _G
local Rock = _G.Rock
local error = _G.error
local type = _G.type
local hooksecurefunc = _G.hooksecurefunc
local pairs = _G.pairs
local next = _G.next

RockHook.registry = oldLib and oldLib.registry or {}
local registry = RockHook.registry
RockHook.actives = oldLib and oldLib.actives or {}
local actives = RockHook.actives
RockHook.handlers = oldLib and oldLib.handlers or {}
local handlers = RockHook.handlers
RockHook.scripts = oldLib and oldLib.scripts or {}
local scripts = RockHook.scripts

local newList, del = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "del")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local function createFunctionHook(self, func, handler, orig, secure)
	if not secure then
		if type(handler) == "string" then
			-- The handler is a method, need to self it
			local uid
			uid = function(...)
				if actives[uid] and self[handler] then
					return self[handler](self, ...)
				else
					return orig(...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				else
					return orig(...)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			-- The handler is a method, need to self it
			local uid
			uid = function(...)
				if actives[uid] and self[handler] then
					return self[handler](self, ...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				end
			end
			return uid
		end
	end
end

local function hookFunction(self, func, handler, secure)
	local orig = _G[func]
	
	if not handler then
		handler = func
	end

	local registry_self = registry[self]
	local uid = registry_self[func]
	if uid then
		if actives[uid] then
			-- We have an active hook from this source.  Don't multi-hook
			error(("%q already has an active hook from this source."):format(func), 4)
		end
		
		if handlers[uid] == handler then
			-- The hook is inactive, so reactivate it
			actives[uid] = true
			return
		else
			self.hooks[func] = nil
			registry_self[func] = nil
			handlers[uid] = nil
			uid = nil
		end
	end
	
	uid = createFunctionHook(self, func, handler, orig, secure)
	registry_self[func] = uid
	actives[uid] = true
	handlers[uid] = handler
	
	if not secure then
		_G[func] = uid
		self.hooks[func] = orig
	else
		hooksecurefunc(func, uid)
	end
end

local function createMethodHook(self, object, method, handler, orig, secure)
	if not secure then
		if type(handler) == "string" then
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				else
					return orig(...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				else
					return orig(...)
				end
			end
			return uid
		end
	else
		-- secure hooks don't call the original method
		if type(handler) == "string" then
			local uid
			uid = function(...)
				if actives[uid] then
					return self[handler](self, ...)
				end
			end
			return uid
		else
			-- The handler is a function, just call it
			local uid
			uid = function(...)
				if actives[uid] then
					return handler(...)
				end
			end
			return uid
		end
	end
end

local function unhookFunction(self, func)
	local registry_self = registry[self]
	local uid = registry_self[func]
	if not uid then
		error(("Tried to unhook %q which is not currently hooked."):format(func), 3)
	end
	
	if actives[uid] then
		-- See if we own the global function
		if self.hooks[func] and _G[func] == uid then
			_G[func] = self.hooks[func]
			self.hooks[func] = nil
			registry_self[func] = nil
			handlers[uid] = nil
			actives[uid] = nil
			-- Magically all-done
		else
			actives[uid] = nil
		end
	end
end

local noop = function() end

local function hookMethod(self, obj, method, handler, script, secure)
	if not handler then
		handler = method
	end
	
	local registry_self = registry[self]
	local registry_self_obj = registry_self[obj]
	local uid = registry_self_obj and registry_self_obj[method]
	local self_hooks = self.hooks
	if uid then
		if actives[uid] then
			-- We have an active hook from this source.  Don't multi-hook
			error(("%q already has an active hook from this source."):format(method), 4)
		end
		
		if handlers[uid] == handler then
			-- The hook is inactive, reactivate it.
			actives[uid] = true
			return
		else
			if self_hooks[obj] then
				self_hooks[obj][method] = nil
			end
			registry_self_obj[method] = nil
			handlers[uid] = nil
			actives[uid] = nil
			scripts[uid] = nil
			uid = nil
		end
	end
	
	local orig
	if script then
		orig = obj:GetScript(method)
		if type(orig) ~= "function" then
			-- Sometimes there is not a original function for a script.
			orig = noop
		end
	else
		orig = obj[method]
	end
	
	local self_hooks_obj = self_hooks[obj]
	if not self_hooks_obj then
		self_hooks_obj = newList()
		self_hooks[obj] = self_hooks_obj
	end
	local registry_self_obj = registry_self[obj]
	if not registry_self_obj then
		registry_self_obj = newList()
		registry_self[obj] = registry_self_obj
	end
	
	local uid = createMethodHook(self, obj, method, handler, orig, secure)
	registry_self_obj[method] = uid
	actives[uid] = true
	handlers[uid] = handler
	scripts[uid] = script or nil
	
	if script then
		if not secure then
			obj:SetScript(method, uid)
			self_hooks_obj[method] = orig
		else
			obj:HookScript(method, uid)
		end
	else
		if not secure then
			obj[method] = uid
			self_hooks_obj[method] = orig
		else
			hooksecurefunc(obj, method, uid)
		end
	end
end

local function unhookMethod(self, obj, method)
	local registry_self = registry[self]
	local registry_self_obj = registry_self and registry_self[obj]
	local uid = registry_self_obj and registry_self_obj[method]
	if not uid then
		error(("Attempt to unhook a method %q that is not currently hooked."):format(method), 3)
	end
	
	local self_hooks = self.hooks
	
	if actives[uid] then
		if scripts[uid] then -- If this is a script
			if obj:GetScript(method) == uid then
				-- We own the script.  Revert to normal.
				if self_hooks[obj][method] == noop then
					obj:SetScript(method, nil)
				else
					obj:SetScript(method, self_hooks[obj][method])
				end
				self_hooks[obj][method] = nil
				registry_self_obj[method] = nil
				handlers[uid] = nil
				scripts[uid] = nil
				actives[uid] = nil
			else
				actives[uid] = nil
			end
		else
			if self_hooks[obj] and self_hooks[obj][method] and obj[method] == uid then
				-- We own the method.  Revert to normal.
				obj[method] = self_hooks[obj][method]
				self_hooks[obj][method] = nil
				registry_self_obj[method] = nil
				handlers[uid] = nil
				actives[uid] = nil
			else
				actives[uid] = nil
			end
		end
	end
	if self_hooks[obj] and not next(self_hooks[obj]) then
		self_hooks[obj] = del(self_hooks[obj])
	end
	if not next(registry_self_obj) then
		registry_self[obj] = del(registry_self_obj)
	end
end

local function hook(self, object, method, handler, secure, script)
	if not script and type(object) == "string" then
		method, handler = object, method
		hookFunction(self, method, handler, secure)
	else
		hookMethod(self, object, method, handler, script, secure)
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* hooks a function or method, replacing it with your own function.
	* this adds the original function to self.hooks[func] or self.hooks[object][method], which should be called in most cases.
Arguments:
	table - object the method lives on. Optional, default: _G
	string - the name of the method/function.
	[optional] string or function - the callback to call when the function is normally called.
Example:
	function Blah()
		return "Alpha"
	end
	assert(Blah() == "Alpha")
	MyAddon:AddHook("Blah", function(...)
		return MyAddon.hooks.Blah(...) .. "Bravo"
	end)
	assert(Blah() == "AlphaBravo")
	-- for methods:
	MyAddon:AddHook(ChatFrame1, "AddMessage", function(object, text, ...)
		-- add the date to all messages of the first ChatFrame.
		return MyAddon.hooks[object].AddMessage(object, date("%Y-%m-%d") .. " " .. text, ...)
	end)
-----------------------------------------------------------------------------]]
function RockHook:AddHook(object, method, callback)
	return hook(self, object, method, callback, false, false)
end
precondition(RockHook, 'AddHook', function(self, object, method, callback)
	argCheck(object, 2, "table", "string")
	if type(object) == "table" then
		argCheck(method, 3, "string")
		if type(object[method]) ~= "function" then
			error(("Bad argument #3 to `AddHook'. %q is not a %q, got %q."):format(method, "function", type(object[method])), 3)
		end
		argCheck(callback, 4, "string", "function", "nil")
		if not callback then
			callback = method
		end
	else
		if type(_G[object]) ~= "function" then
			error(("Bad argument #2 to `AddHook'. %q is not a %q, got %q."):format(object, "function", type(_G[object])), 3)
		end
		argCheck(method, 3, "string", "function", "nil")
		callback = method
		if not callback then
			callback = object
		end
	end
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #%d to `AddHook'. %q is not a %q, got %q."):format(type(object) == "table" and 4 or 3, callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockHook, 'AddHook', function(ret, self, object, method, callback)
	if type(object) == "table" then
		assert(self:HasHook(object, method))
	else
		assert(self:HasHook(object))
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* hooks a function or method, having your callback called after the original function
	* This is primarily used for hooking secure functions and maintaining the secure state.
Arguments:
	table - object the method lives on. Optional, default: _G
	string - the name of the method/function.
	[optional] string or function - the callback to call when the function is normally called.
Example:
	function Blah()
		return "Alpha"
	end
	assert(Blah() == "Alpha")
	MyAddon:AddSecureHook("Blah", function()
		-- do something here
	end)
	assert(Blah() == "Alpha") -- still returns the old value, but your hook was called.
-----------------------------------------------------------------------------]]
function RockHook:AddSecureHook(object, method, callback)
	return hook(self, object, method, callback, true, false)
end
precondition(RockHook, 'AddSecureHook', function(self, object, method, callback)
	argCheck(object, 2, "table", "string")
	if type(object) == "table" then
		argCheck(method, 3, "string")
		if type(object[method]) ~= "function" then
			error(("Bad argument #3 to `AddSecureHook'. %q is not a %q, got %q."):format(method, "function", type(object[method])), 3)
		end
		argCheck(callback, 4, "string", "function", "nil")
		if not callback then
			callback = method
		end
	else
		if type(_G[object]) ~= "function" then
			error(("Bad argument #2 to `AddSecureHook'. %q is not a %q, got %q."):format(object, "function", type(_G[object])), 3)
		end
		argCheck(method, 3, "string", "function", "nil")
		callback = method
		if not callback then
			callback = object
		end
	end
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #%d to `AddSecureHook'. %q is not a %q, got %q."):format(type(object) == "table" and 4 or 3, callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockHook, 'AddSecureHook', function(ret, self, object, method, callback)
	if type(object) == "table" then
		assert(self:HasHook(object, method))
	else
		assert(self:HasHook(object))
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* hooks a frame's script, replacing it with your own function.
	* this adds the original function to self.hooks[frame][script], which should be called in most cases.
Arguments:
	Frame - frame the script lives on.
	string - the name of the script.
	[optional] string or function - the callback to call when the function is normally called.
Example:
	MyAddon:AddScriptHook(frame, "OnMouseDown", function(object, ...)
		-- do something
		return RockTest.hooks[object].OnMouseDown(...)
	end)
-----------------------------------------------------------------------------]]
function RockHook:AddScriptHook(frame, script, callback)
	return hook(self, frame, script, callback, false, true)
end
precondition(RockHook, 'AddScriptHook', function(self, frame, script, callback)
	argCheck(frame, 2, "table")
	if type(rawget(frame, 0)) ~= "userdata" then
		error("Bad argument #2 to `AddScriptHook'. Expected Frame.", 3)
	end
	argCheck(script, 3, "string")
	if not frame:HasScript(script) then
		error(("Bad argument #3 to `AddScriptHook'. %q is not a script."):format(script), 3)
	end
	argCheck(callback, 4, "string", "function", "nil")
	if not callback then
		callback = script
	end
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #%d to `AddScriptHook'. %q is not a %q, got %q."):format(4, callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockHook, 'AddScriptHook', function(ret, self, frame, script, callback)
	assert(self:HasHook(frame, script))
end)

--[[---------------------------------------------------------------------------
Notes:
	* hooks a frame's script, having your callback called after the original function
	* This is primarily used for hooking secure scripts and maintaining the secure state.
Arguments:
	Frame - frame the script lives on.
	string - the name of the script.
	[optional] string or function - the callback to call when the function is normally called.
Example:
	MyAddon:AddSecureScriptHook(frame, "OnMouseDown", function(object, ...)
		-- do something
	end)
-----------------------------------------------------------------------------]]
function RockHook:AddSecureScriptHook(frame, script, callback)
	return hook(self, frame, script, callback, true, true)
end
precondition(RockHook, 'AddSecureScriptHook', function(self, frame, script, callback)
	argCheck(frame, 2, "table")
	if type(rawget(frame, 0)) ~= "userdata" then
		error("Bad argument #2 to `AddSecureScriptHook'. Expected Frame.", 3)
	end
	argCheck(script, 3, "string")
	if not frame:HasScript(script) then
		error(("Bad argument #3 to `AddSecureScriptHook'. %q is not a script."):format(script), 3)
	end
	argCheck(callback, 4, "string", "function", "nil")
	if not callback then
		callback = script
	end
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #%d to `AddSecureScriptHook'. %q is not a %q, got %q."):format(4, callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockHook, 'AddSecureScriptHook', function(ret, self, frame, script, callback)
	assert(self:HasHook(frame, script))
end)

--[[---------------------------------------------------------------------------
Arguments:
	table or Frame - table the method lives on or frame the script lives on. Optional, default: _G.
	string - the name of the function, script, or method.
Returns:
	false or function or string - false if not hooked, or function/string for the callback.
Example:
	local hook = MyAddon:HasHook(frame, "OnMouseDown")
-----------------------------------------------------------------------------]]
function RockHook:HasHook(object, method)
	if type(object) == "string" then
		if registry[self][object] and actives[registry[self][object]] then
			return handlers[registry[self][object]]
		end
	else
		if registry[self][object] and registry[self][object][method] and actives[registry[self][object][method]] then
			return handlers[registry[self][object][method]]
		end
	end
	
	return false
end
precondition(RockHook, 'HasHook', function(self, object, method)
	argCheck(object, 2, "string", "table")
	if type(object) == "table" then
		argCheck(method, 3, "string")
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* Unhooks a hooked function, script, or method
Arguments:
	table or Frame - table the method lives on or frame the script lives on. Optional, default: _G.
	string - the name of the function, script, or method.
Example:
	MyAddon:RemoveHook("SomeGlobalFunction")
	MyAddon:RemoveHook(frame, "OnMouseDown")
-----------------------------------------------------------------------------]]
function RockHook:RemoveHook(object, method)
	if type(object) == "string" then
		unhookFunction(self, object)
	else
		unhookMethod(self, object, method)
	end
end
precondition(RockHook, 'RemoveHook', function(self, object, method)
	argCheck(object, 2, "string", "table")
	if type(object) == "table" then
		argCheck(method, 3, "string")
	end
end)
postcondition(RockHook, 'RemoveHook', function(ret, self, object, method)
	if type(object) == "string" then
		assert(not self:HasHook(object))
	else
		assert(not self:HasHook(object, method))
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* Unhooks all hooked functions, scripts, and methods.
Example:
	MyAddon:RemoveAllHooks()
-----------------------------------------------------------------------------]]
function RockHook:RemoveAllHooks()
	local registry_self = registry[self]
	if type(registry_self) ~= "table" then
		return
	end
	local tmp = newList()
	for key, value in pairs(registry_self) do
		tmp[key] = value
	end
	for key, value in pairs(tmp) do
		if type(value) == "table" then
			local tmp2 = newList()
			for method in pairs(value) do
				tmp2[method] = true
			end
			for method in pairs(tmp2) do
				RockHook.RemoveHook(self, key, method)
			end
			tmp2 = del(tmp2)
		else
			RockHook.RemoveHook(self, key)
		end
	end
	tmp = del(tmp)
end

function RockHook:OnEmbed(object)
	object.hooks = newList()
	registry[object] = newList()
end

function RockHook:OnUnembed(object)
	self.RemoveAllHooks(object)
	object.hooks = del(object.hooks)
	registry[object] = del(registry[object])
end

function RockHook:OnEmbedDisable(object)
	self.RemoveAllHooks(object)
end

RockHook:SetExportedMethods("AddHook", "AddSecureHook", "AddScriptHook", "AddSecureScriptHook", "HasHook", "RemoveHook", "RemoveAllHooks")

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- chat commands
	local t = { name = "RockHookUnitTest" }
	
	RockHook:Embed(t)
	
	function t:SomeMethod(obj, ...)
		return ...
	end
	local triggered = false
	function t:SomeOtherMethod(obj)
		triggered = true
	end
	
	local object = {}
	function object:SomeMethod()
		return "Alpha"
	end
	function object:SomeOtherMethod()
		return "Charlie"
	end
	
	assert(not t:HasHook(object, "SomeMethod"))
	assert(object:SomeMethod() == "Alpha")
	
	t:AddHook(object, "SomeMethod")
	assert(t:HasHook(object, "SomeMethod"))
	assert(object:SomeMethod("Bravo") == "Bravo")
	t:RemoveHook(object, "SomeMethod")
	assert(not t:HasHook(object, "SomeMethod"))
	assert(object:SomeMethod() == "Alpha")
	
	t:AddHook(object, "SomeMethod")
	assert(t:HasHook(object, "SomeMethod"))
	assert(object:SomeMethod("Bravo") == "Bravo")
	t:RemoveAllHooks()
	assert(not t:HasHook(object, "SomeMethod"))
	assert(object:SomeMethod() == "Alpha")
	
	assert(not t:HasHook(object, "SomeOtherMethod"))
	assert(object:SomeOtherMethod() == "Charlie")
	
	t:AddSecureHook(object, "SomeOtherMethod")
	assert(t:HasHook(object, "SomeOtherMethod"))
	assert(not triggered)
	assert(object:SomeOtherMethod() == "Charlie")
	assert(triggered)
	triggered = false
	t:RemoveHook(object, "SomeOtherMethod")
	assert(not t:HasHook(object, "SomeOtherMethod"))
	assert(object:SomeOtherMethod() == "Charlie")
	assert(not triggered)
	
	t:AddSecureHook(object, "SomeOtherMethod")
	assert(t:HasHook(object, "SomeOtherMethod"))
	assert(not triggered)
	assert(object:SomeOtherMethod() == "Charlie")
	assert(triggered)
	triggered = false
	t:RemoveAllHooks()
	assert(not t:HasHook(object, "SomeOtherMethod"))
	assert(object:SomeOtherMethod() == "Charlie")
	assert(not triggered)
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- chat commands
	local t = { name = "RockHookUnitTest" }
	
	RockHook:Embed(t)
	
	local triggered = false
	function t:OnShow(obj)
		triggered = true
	end
	
	local frame = CreateFrame("Frame")
	frame:Hide()
	local normalTriggered = false
	frame:SetScript("OnShow", function(this)
		normalTriggered = true
	end)

	assert(not t:HasHook(frame, "OnShow"))
	frame:Show()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
	frame:Hide()
	
	t:AddScriptHook(frame, "OnShow")
	assert(t:HasHook(frame, "OnShow"))
	frame:Show()
	assert(not normalTriggered)
	assert(triggered)
	triggered = false
	frame:Hide()
	t:RemoveHook(frame, "OnShow")
	assert(not t:HasHook(frame, "OnShow"))
	frame:Show()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
	frame:Hide()
	
	t:AddScriptHook(frame, "OnShow")
	assert(t:HasHook(frame, "OnShow"))
	frame:Show()
	assert(not normalTriggered)
	assert(triggered)
	triggered = false
	frame:Hide()
	t:RemoveAllHooks()
	assert(not t:HasHook(frame, "OnShow"))
	frame:Show()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
	frame:Hide()
	frame:Show()
	local triggered = false
	function t:OnHide(obj)
		triggered = true
	end
	
	local normalTriggered = false
	frame:SetScript("OnHide", function()
		normalTriggered = true
	end)
	
	assert(not t:HasHook(frame, "OnHide"))
	frame:Hide()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
	frame:Show()
	
	t:AddSecureScriptHook(frame, "OnHide")
	assert(t:HasHook(frame, "OnHide"))
	frame:Hide()
	assert(normalTriggered)
	normalTriggered = false
	assert(triggered)
	triggered = false
	frame:Show()
	t:RemoveHook(frame, "OnHide")
	assert(not t:HasHook(frame, "OnHide"))
	frame:Hide()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
	frame:Show()
	
	t:AddSecureScriptHook(frame, "OnHide")
	assert(t:HasHook(frame, "OnHide"))
	frame:Hide()
	assert(normalTriggered)
	normalTriggered = false
	assert(triggered)
	triggered = false
	frame:Show()
	t:RemoveAllHooks()
	assert(not t:HasHook(frame, "OnHide"))
	frame:Hide()
	assert(normalTriggered)
	normalTriggered = false
	assert(not triggered)
end)

