--[[
Name: LibRockEvent-1.0
Revision: $Rev: 236 $
Developed by: ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: Library to allow for event handling and inter-addon communication.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockEvent-1.0"
local MINOR_VERSION = tonumber(("$Revision: 236 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockEvent, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockEvent then
	return
end
local _G = _G
local Rock = _G.Rock
local error = _G.error
local type = _G.type
local geterrorhandler = _G.geterrorhandler
local pcall = _G.pcall
local tostring = _G.tostring
local pairs = _G.pairs
local next = _G.next
local ipairs = _G.ipairs
local select = _G.select
local setmetatable = _G.setmetatable

local weakKey = {__mode = 'k'}

-- the frame to receive Blizzard events from
RockEvent.frame = oldLib and oldLib.frame or _G.CreateFrame("Frame")
local frame = RockEvent.frame
-- events[namespace][eventName][object] = { callback = methodOrFunction, bucketDelay = nil/bucketNumber, n = numArgs, [1] = arg1, [n] = argn }
RockEvent.events = oldLib and oldLib.events or {}
local events = RockEvent.events
-- multiEvents[namespace][{eventName = true, otherEventName = true}][object] = { callback = methodOrFunction, bucketDelay = nil/bucketNumber, n = numArgs, [1] = arg1, [n] = argn }
RockEvent.multiEvents = oldLib and oldLib.multiEvents or {}
local multiEvents = RockEvent.multiEvents

frame:UnregisterAllEvents()
frame:RegisterAllEvents()
frame:RegisterEvent("ADDON_LOADED") -- HACK! WHAT THE FUCK! I DONT KNOW HOW THE FUCK THIS WORKS BUT I FUCKING SWEAR IT FIXES A BUG FOR ME! I'M SERIOUSLY WHAT THE FUCKING OVER THIS! WHAT THE FUCK!
for namespace,v in pairs(events) do
	setmetatable(v, nil)
	for eventName,u in pairs(v) do
		setmetatable(u, weakKey)
	end
end

local newList, del = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "del")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local LibRockTimer
function RockEvent:OnLibraryLoad(major, instance)
	if major == "LibRockTimer-1.0" then
		LibRockTimer = instance
		LibRockTimer:Embed(self)
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* adds a listener for an event specified by the "namespace"/"eventName" pair.
	* to register for a Blizzard event, specify namespace as "Blizzard"
	* Along with the normal arguments passed into the callback, the "namespace" and "eventName" are passed in.
	* Bucketed events can be handled by setting the bucketDelay argument to a number, which is the amount of time to bucket events by. Bucket events will take the first argument passed in and store it in a set. If the set is non-empty by the time the specified delay is up, the callback will be called, passing along the set.
	* It is recommended to only use the multiple event system when using buckets.
	* If you wish to listen to events triggered by AceEvent-2.0, specify the namespace "AceEvent-2.0". e.g. "AceEvent-2.0", "SharedMedia_Registered". 
Arguments:
	string - the namespace, could be "Blizzard" or the name of a library or addon. Optional, default: "Blizzard"
	string or table - the name of the event or a table containing a set of events.
	[optional] string or function - the callback (method name or function) to call. Default: "eventName",
	[optional] number - if a number is provided, the bucketing delay. Default: nil
	tuple - a list of arguments to pass into the start of the callback.
Example:
	MyAddon.PLAYER_LOGIN = function(self, namespace, event)
		-- do something here.
	end
	MyAddon:AddEventListener("PLAYER_LOGIN") -- same as :AddEventListener("Blizzard", "PLAYER_LOGIN")
	MyAddon.ADDON_LOADED = function(self, value, namespace, event)
		assert(value == 50)
	end
	MyAddon:AddEventListener("ADDON_LOADED", nil, nil, 50)
	-- buckets:
	MyAddon.SomeEvent = function(self, namespace, event, data)
	end
	MyAddon:AddEventListener("MyAddon", "SomeEvent", nil, 1) -- bucketing by every second.
	MyAddon:DispatchEvent("SomeEvent", "alpha")
	-- half second later
	MyAddon:DispatchEvent("SomeEvent", "bravo")
	-- once the second has passed, MyAddon:SomeEvent("MyAddon", "SomeEvent", { ["alpha"] = true, ["bravo"] = true }) will be called.
	-- multiple events:
	MyAddon.Handler = function(self, namespace, event)
		-- will receive SomeEvent and SomeOtherEvent
	end
	MyAddon:AddEventListener("SomeNamespace", { SomeEvent = true, SomeOtherEvent = true}, "Handler")
-----------------------------------------------------------------------------]]
function RockEvent:AddEventListener(namespace, eventName, callback, bucketDelay, ...)
	if not eventName or type(namespace) == "table" or (type(namespace) == "string" and namespace:match("^[A-Z_]+$")) then
		if bucketDelay == nil and select('#', ...) == 0 then
			return RockEvent.AddEventListener(self, "Blizzard", namespace, eventName, callback)
		else
			return RockEvent.AddEventListener(self, "Blizzard", namespace, eventName, callback, bucketDelay, ...)
		end
	end
	local isMulti = type(eventName) == "table"
	if not callback then
		callback = eventName
	end
	local isBucket = type(bucketDelay) == "number"
	if isBucket and not LibRockTimer then
		-- logistics issue
		error(("Cannot use a bucketed event with `AddEventListener' unless library %q is available."):format("LibRockTimer-1.0"), 2)
	end
	local events_namespace
	if isMulti then
		events_namespace = multiEvents[namespace]
		if not events_namespace then
			events_namespace = newList()
			multiEvents[namespace] = events_namespace
		end
	else
		events_namespace = events[namespace]
		if not events_namespace then
			events_namespace = newList()
			events[namespace] = events_namespace
		end
	end
	
	local events_namespace_eventName = events_namespace[eventName]
	if not events_namespace_eventName then
		events_namespace_eventName = setmetatable(newList(), weakKey)
		events_namespace[eventName] = events_namespace_eventName
	end
	
	local events_namespace_eventName_self = events_namespace_eventName[self]
	if events_namespace_eventName_self then
		del(events_namespace_eventName_self)
	end
	events_namespace_eventName_self = newList()
	events_namespace_eventName[self] = events_namespace_eventName_self
	events_namespace_eventName_self.object = self
	events_namespace_eventName_self.namespace = namespace
	events_namespace_eventName_self.eventName = eventName
	events_namespace_eventName_self.callback = callback
	if isBucket then
		events_namespace_eventName_self.bucketDelay = bucketDelay
	end
	
	local n = select('#', ...)
	if n >= 1 then
		for i = 1, n do
			events_namespace_eventName_self[i] = select(i, ...)
		end
		events_namespace_eventName_self.n = n
	end
	
	if isBucket then
		events_namespace_eventName_self.bucketID = Rock:GetUID()
	end
end
precondition(RockEvent, 'AddEventListener', function(self, namespace, eventName, callback, bucketDelay, ...)
	if not eventName or type(namespace) == "table" or (type(namespace) == "string" and namespace:match("^[A-Z_]+$")) then
		-- cause it returns right away
		return
	end
	argCheck(namespace, 2, "string")
	argCheck(eventName, 3, "string", "table")
	if type(eventName) == "table" then
		for k,v in pairs(eventName) do
			if type(k) ~= "string" then
				error(("Bad argument #3 to `AddEventListener'. All keys must be %q, got %q"):format("string", type(k)), 3)
			elseif v ~= true then
				error(("Bad argument #3 to `AddEventListener'. All values must be true, got %q"):format(type(v)), 3)
			end
		end
		argCheck(callback, 4, "string", "function")
	else
		argCheck(callback, 4, "string", "function", "nil")
	end
	if not callback then
		callback = eventName
	end
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #4 to `AddEventListener'. %q is not a %q, got %q."):format(callback, "function", type(self[callback])), 3)
	end
	argCheck(bucketDelay, 5, "number", "nil")
end)
postcondition(RockEvent, 'AddEventListener', function(ret, self, namespace, eventName, callback, bucketDelay, ...)
	if not eventName or type(namespace) == "table" or (type(namespace) == "string" and namespace:match("^[A-Z_]+$")) then
		-- cause it returns right away
		return
	end
	
	assert(self:HasEventListener(namespace, eventName))
end)

--[[---------------------------------------------------------------------------
Notes:
	* remove the event listener for the specified "namespace"/"eventName" pair.
Arguments:
	string - the namespace, could be "Blizzard" or the name of a library or addon. Optional, default: "Blizzard"
	string - the name of the event.
Returns:
	boolean - whether the event actually was removed.
Example:
	MyAddon:RemoveEventListener("PLAYER_LOGIN") -- same as :RemoveEventListener("Blizzard", "PLAYER_LOGIN")
-----------------------------------------------------------------------------]]
function RockEvent:RemoveEventListener(namespace, eventName)
	if not eventName then
		return RockEvent.RemoveEventListener(self, "Blizzard", namespace)
	end
	if type(namespace) ~= "string" then
		error(("Bad argument #2 to `RemoveEventListener'. Expected %q, got %q."):format("string", type(namespace)), 2)
	end
	local isMulti = type(eventName) == "table"
	
	local ret = false
	
	local ev = isMulti and multiEvents or events
	
	local ev_namespace = ev[namespace]
	if ev_namespace then
		local ev_namespace_eventName = ev_namespace[eventName]
		if ev_namespace_eventName then
			ret = ev_namespace_eventName[self]
			if ret then
				local bucketID = ret.bucketID
				if bucketID then
					RockEvent:RemoveTimer(bucketID)
				end
				local bucket = ret.bucket
				if bucket then
					del(bucket)
				end
				ev_namespace_eventName[self] = del(ret)
			end
			if not next(ev_namespace_eventName) then
				ev_namespace[eventName] = del(ev_namespace_eventName)
			end
		end
		if not next(ev_namespace) then
			ev[namespace] = del(ev_namespace)
		end
	end
	
	return not not ret
end
precondition(RockEvent, 'RemoveEventListener', function(self, namespace, eventName)
	if not eventName then
		-- cause it returns right away
		return
	end
	argCheck(namespace, 2, "string")
	argCheck(eventName, 3, "table", "string")
end)
postcondition(RockEvent, 'RemoveEventListener', function(ret, self, namespace, eventName)
	assert(not self:HasEventListener(namespace, eventName))
end)

--[[---------------------------------------------------------------------------
Notes:
	* remove all event listener for the specified namespace or for all namespaces.
Arguments:
	[optional] string - the namespace, could be "Blizzard" or the name of a library or addon. Default: all namespaces
Example:
	MyAddon:RemoveAllEventListeners()
-----------------------------------------------------------------------------]]
function RockEvent:RemoveAllEventListeners(namespace)
	if namespace and type(namespace) ~= "string" then
		error(("Bad argument #2 to `RemoveAllEventListeners'. Expected %q or %q, got %q."):format("string", "nil", type(namespace)), 2)
	end
	
	local t = newList(events, multiEvents)
	for _,ev in ipairs(t) do
		if namespace then
			local ev_namespace = ev[namespace]
			if ev_namespace then
				local tmp = newList()
				for eventName in pairs(ev_namespace) do
					tmp[eventName] = true
				end
				for eventName in pairs(tmp) do
					RockEvent.RemoveEventListener(self, namespace, eventName)
				end
				tmp = del(tmp)
			end
		else
			local tmp = newList()
			for namespace, ev_namespace in pairs(ev) do
				tmp[namespace] = ev_namespace
			end
			for namespace, ev_namespace in pairs(tmp) do
				local tmp2 = newList()
				for eventName in pairs(ev_namespace) do
					tmp2[eventName] = true
				end
				for eventName in pairs(tmp2) do
					RockEvent.RemoveEventListener(self, namespace, eventName)
				end
				tmp2 = del(tmp2)
			end
			tmp = del(tmp)
		end
	end
	t = del(t)
end

--[[---------------------------------------------------------------------------
Arguments:
	string - the namespace. Optional, default: "Blizzard"
	string - the name of the event.
Returns:
	boolean or function or string - false if not registered, otherwise the callback that the event is registered to. ''Note: if this is called on LibRockEvent-1.0 itself, it will only return true/false.
Example:
	local has = MyAddon:HasEventListener("PLAYER_LOGIN") -- same as :HasEventListener("Blizzard", "PLAYER_LOGIN")
	local has = MyAddon:HasEventListener("MyAddon", "Kersplosion")
-----------------------------------------------------------------------------]]
function RockEvent:HasEventListener(namespace, eventName)
	if not eventName then
		return RockEvent.HasEventListener(self, "Blizzard", namespace)
	end
	local isMulti = type(eventName) == "table"
	
	local ev = isMulti and multiEvents or events
	
	local ev_namespace = ev[namespace]
	if not ev_namespace then
		return false
	end
	
	local ev_namespace_event = ev_namespace[eventName]
	if not ev_namespace_event then
		return false
	elseif self == RockEvent then
		return true
	end
	
	return ev_namespace_event[self] or false
end
precondition(RockEvent, 'HasEventListener', function(self, namespace, eventName)
	if not eventName then
		-- cause it returns right away
		return
	end
	argCheck(namespace, 2, "string")
	argCheck(eventName, 3, "table", "string")
end)

local function unpackWithExtras(t, start, finish, ...)
	if start <= finish then
		return t[start], unpackWithExtras(t, start+1, finish, ...)
	else
		return ...
	end
end

local function bucketHandler(data)
	local bucket = data.bucket
	if not bucket then
		return
	end
	
	RockEvent.currentUID = Rock:GetUID()
	local namespace = data.namespace
	local eventName = data.eventName
	local callback = data.callback
	local args_num = data.n
	local shouldRemove = false
	if type(callback) == "string" then -- method
		local object = data.object
		local object_method = object[callback]
		if not object_method then -- did a typecheck before, just double-check existence
			local success, ret = pcall(error, ("Error calling method %q on object %q. Method does not exist."):format(callback, tostring(object)))
			geterrorhandler()(ret)
			shouldRemove = true
		else
			local success, ret
			if not args_num then
				success, ret = pcall(object_method, object, namespace, eventName, bucket)
			else	
				success, ret = pcall(object_method, object, unpackWithExtras(data, 1, args_num, namespace, eventName, bucket))
			end
			if not success then
				geterrorhandler()(ret)
				shouldRemove = true
			end
		end
	else -- function	
		local success, ret
		if not args_num then
			success, ret = pcall(callback, namespace, eventName, bucket)
		else
			success, ret = pcall(callback, unpackWithExtras(data, 1, args_num, namespace, eventName, bucket))
		end
		if not success then
			geterrorhandler()(ret)
			shouldRemove = true
		end
	end
	RockEvent:RemoveTimer(data.bucketID)
	data.bucket = del(bucket)
	if shouldRemove then
		RockEvent.RemoveEventListener(data.object, namespace, eventName)
	end
	RockEvent.currentUID = nil
end

local function dispatch(namespace, event, ...)
	local events_namespace = events[namespace]
	local multiEvents_namespace = multiEvents[namespace]
	if events_namespace or multiEvents_namespace then
		local events_namespace_event = events_namespace and events_namespace[event]
		local multiEvents_namespace_withEvent = newList()
		if multiEvents_namespace then
			for eventSet, v in pairs(multiEvents_namespace) do
				if eventSet[event] then
					multiEvents_namespace_withEvent[eventSet] = v
				end
			end
		end
		if events_namespace_event or next(multiEvents_namespace_withEvent) then
			-- events are stored in the temporary tables in case some bright spark decides to remove the events upon calling.
			local tmp1 = newList()
			local tmp2 = newList()
			if events_namespace_event then
				for object, data in pairs(events_namespace_event) do
					tmp1[#tmp1+1] = object
					tmp2[#tmp2+1] = data
				end
			end
			for eventSet, v in pairs(multiEvents_namespace_withEvent) do
				for object, data in pairs(v) do
					tmp1[#tmp1+1] = object
					tmp2[#tmp2+1] = data
				end
			end
			
			local lastUID = RockEvent.currentUID
			RockEvent.currentUID = Rock:GetUID()
			for i = 1, #tmp1 do
				local object, data = tmp1[i], tmp2[i]
				if data.bucketID then
					local bucket = data.bucket
					if not bucket then
						bucket = newList()
						data.bucket = bucket
						RockEvent:AddTimer(data.bucketID, data.bucketDelay, bucketHandler, data)
					end
					bucket[(...) or false] = true
				else
					local args_num = data.n
					local callback = data.callback
					if type(callback) == "string" then
						local object_method = object[callback]
						if not object_method then -- did a typecheck before, just double-check existence
							local success, ret = pcall(error, ("Error calling method %q on object %q. Method does not exist."):format(callback, tostring(object)))
							geterrorhandler()(ret)
							shouldRemove = true
						else
							local success, ret
							if not args_num then
								success, ret = pcall(object_method, object, namespace, event, ...)
							else	
								success, ret = pcall(object_method, object, unpackWithExtras(data, 1, args_num, namespace, event, ...))
							end
							if not success then
								geterrorhandler()(ret)
							end
						end
					else -- function	
						local success, ret
						if not args_num then
							success, ret = pcall(callback, namespace, event, ...)
						else
							success, ret = pcall(callback, unpackWithExtras(data, 1, args_num, namespace, event, ...))
						end
						if not success then
							geterrorhandler()(ret)
						end
					end
				end
			end
			RockEvent.currentUID = lastUID
			tmp1 = del(tmp1)
			tmp2 = del(tmp2)
		end
		multiEvents_namespace_withEvent = del(multiEvents_namespace_withEvent)
	end
end
--[[---------------------------------------------------------------------------
Notes:
	* dispatch an event, causing all addons which have registered for the event to have their callbacks called.
	* events should be in the form of PascalCase. Only Blizzard's events should be in CONSTANT_CASE
	* events are passed with the namespace as specified by <tt>object.name</tt>
Arguments:
	string - the name of the event.
	tuple - list of arguments to pass.
Example:
	MyAddon:DispatchEvent("Kersplosion") -- dispatches "MyAddon","Kersplosion"
-----------------------------------------------------------------------------]]
function RockEvent:DispatchEvent(eventName, ...)
	return dispatch(self.name, eventName, ...)
end
precondition(RockEvent, 'DispatchEvent', function(self, eventName, ...)
	argCheck(eventName, 2, "string")
	local namespace = self.name
	if type(namespace) ~= "string" then
		error(("Cannot call `DispatchEvent' without .name being a %q, got %q"):format("string", type(namespace)), 3)
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* dispatches an event with the specified namespace, causing all addons which have registered for the event to have their callbacks called.
	* events should be in the form of PascalCase. Only Blizzard's events should be in CONSTANT_CASE
	* events are passed with the namespace as specified by <tt>object.name</tt>
	* this is for special cases only, e.g. debugging. It is highly recommended that ''':DispatchEvent''' is used instead.
Arguments:
	string - the namespace.
	string - the name of the event.
	tuple - list of arguments to pass.
Example:
	Rock("LibRockEvent-1.0"):DispatchNamespaceEvent("MyAddon", "Kersplosion") -- dispatches "MyAddon","Kersplosion"
-----------------------------------------------------------------------------]]
function RockEvent:DispatchNamespaceEvent(namespace, eventName, ...)
	return dispatch(namespace, eventName, ...)
end
precondition(RockEvent, 'DispatchNamespaceEvent', function(self, namespace, eventName, ...)
	argCheck(namespace, 2, "string")
	argCheck(eventName, 3, "string")
end)

local AceEvent20

local function SetupAceEvents()
	if not AceEvent20 then
		local AceLibrary = _G.AceLibrary
		if AceLibrary and AceLibrary:HasInstance("AceEvent-2.0", false) then
			AceEvent20 = AceLibrary("AceEvent-2.0")
			function RockEvent:OnAceEvent(...)
				local event = AceEvent20.currentEvent
				if event:match("^[A-Z_]+$") then
					return
				end
				dispatch("AceEvent-2.0", event, ...)
			end
			AceEvent20.RegisterAllEvents(RockEvent, "OnAceEvent")
		end
	end
end

frame:SetScript("OnEvent", function(this, event, ...)
	if event == "ADDON_LOADED" then
		SetupAceEvents()
	end
	return dispatch("Blizzard", event, ...)
end)

function RockEvent:OnUnembed(object)
	self.RemoveAllEventListeners(object)
end

function RockEvent:OnEmbedDisable(object)
	self.RemoveAllEventListeners(object)
end

--[[---------------------------------------------------------------------------
Notes:
	* The event "LibEvent-1.0","FullyInitialized" will be dispatched when the UI has fully initialized.
	* Fully initialized means that it is post-PLAYER_LOGIN and all chat channels have been properly joined, which has no corresponding Blizzard event.
Returns:
	boolean - whether the UI has fully initialized
Example:
	local init = Rock("LibRockEvent-1.0"):IsFullyInitialized()
-----------------------------------------------------------------------------]]
function RockEvent:IsFullyInitialized()
	return self.postInit
end

RockEvent.postInit = oldLib and oldLib.postInit or false
if not RockEvent.postInit then
	local frame = CreateFrame("Frame")
	local function PLAYER_LOGIN()
		PLAYER_LOGIN = nil
		
		local nextTime = GetTime() + 10
		frame:SetScript("OnUpdate", function(this, elapsed)
			if GetTime() >= nextTime then
				local major, minor = RockEvent:GetLibraryVersion()
				if minor == MINOR_VERSION or minor == -MINOR_VERSION then -- HACK, remove the negative thing
					-- make sure we've not upgraded
					SetupAceEvents() -- Workaround for broken OptionalDeps
					RockEvent.postInit = true
					dispatch(MAJOR_VERSION, "FullyInitialized")
				end
				frame:UnregisterAllEvents()
				frame:SetScript("OnEvent", nil)
				frame:SetScript("OnUpdate", nil)
				frame:Hide()
			end
		end)
		local hasMeetingStone = true
		frame:SetScript("OnEvent", function(this, event)
			if event == "MEETINGSTONE_CHANGED" then
				nextTime = GetTime() + 1
				hasMeetingStone = false
				this:UnregisterEvent("MEETINGSTONE_CHANGED")
			elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
				nextTime = GetTime() + 0.15
			elseif event == "LANGUAGE_LIST_CHANGED" then
				if hasMeetingStone then
					hasMeetingStone = false
					this:UnregisterEvent("MEETINGSTONE_CHANGED")
					this:RegisterEvent("MINIMAP_ZONE_CHANGED")
				end
			elseif event == "MINIMAP_ZONE_CHANGED" then
				nextTime = GetTime() + 1
				this:UnregisterEvent("MINIMAP_ZONE_CHANGED")
			end
		end)
		frame:RegisterEvent("MEETINGSTONE_CHANGED")
		frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
		frame:RegisterEvent("LANGUAGE_LIST_CHANGED")
	end

	if IsLoggedIn() then
		PLAYER_LOGIN()
	else
		frame:RegisterEvent("PLAYER_LOGIN")
		frame:SetScript("OnEvent", PLAYER_LOGIN)
	end
end

RockEvent:SetExportedMethods("AddEventListener", "RemoveEventListener", "RemoveAllEventListeners", "DispatchEvent", "HasEventListener")

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock("LibRockTimer-1.0", false, true) -- load if possible

Rock:AddUnitTest(MAJOR_VERSION, function()
	local t = {name = "RockEventUnitTest"}
	RockEvent:Embed(t)
	local triggered = false
	function t:Alpha(ns, event, ...)
		triggered = true
		assert(ns == "RockEventUnitTest")
		assert(event == "Alpha")
		assert((...) == "Blah")
	end
	t:AddEventListener("RockEventUnitTest", "Alpha")
	assert(t:HasEventListener("RockEventUnitTest", "Alpha"))
	t:DispatchEvent("Alpha", "Blah")
	assert(triggered)
	triggered = false
	RockEvent:DispatchNamespaceEvent("RockEventUnitTest", "Alpha", "Blah")
	assert(triggered)
	triggered = false
	t:RemoveEventListener("RockEventUnitTest", "Alpha")
	assert(not t:HasEventListener("RockEventUnitTest", "Alpha"))
	RockEvent:DispatchNamespaceEvent("RockEventUnitTest", "Alpha", "Blah")
	assert(not triggered)
	t:AddEventListener("RockEventUnitTest", "Alpha")
	assert(t:HasEventListener("RockEventUnitTest", "Alpha"))
	RockEvent:DispatchNamespaceEvent("RockEventUnitTest", "Alpha", "Blah")
	assert(triggered)
	triggered = false
	t:RemoveAllEventListeners()
	assert(not t:HasEventListener("RockEventUnitTest", "Alpha"))
	RockEvent:DispatchNamespaceEvent("RockEventUnitTest", "Alpha", "Blah")
	assert(not triggered)
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local t = {name = "RockEventUnitTest"}
	RockEvent:Embed(t)
	local triggered = false
	function t:FAKE_BLIZZARD_EVENT(ns, event, ...)
		triggered = true
		assert(ns == "Blizzard")
		assert(event == "FAKE_BLIZZARD_EVENT")
		assert((...) == "Blah")
	end
	t:AddEventListener("FAKE_BLIZZARD_EVENT")
	assert(t:HasEventListener("FAKE_BLIZZARD_EVENT"))
	RockEvent:DispatchNamespaceEvent("Blizzard", "FAKE_BLIZZARD_EVENT", "Blah")
	assert(triggered)
	triggered = false
	t:RemoveEventListener("FAKE_BLIZZARD_EVENT")
	assert(not t:HasEventListener("FAKE_BLIZZARD_EVENT"))
	RockEvent:DispatchNamespaceEvent("Blizzard", "FAKE_BLIZZARD_EVENT", "Blah")
	assert(not triggered)
	t:AddEventListener("FAKE_BLIZZARD_EVENT")
	assert(t:HasEventListener("FAKE_BLIZZARD_EVENT"))
	RockEvent:DispatchNamespaceEvent("Blizzard", "FAKE_BLIZZARD_EVENT", "Blah")
	assert(triggered)
	triggered = false
	t:RemoveAllEventListeners()
	assert(not t:HasEventListener("FAKE_BLIZZARD_EVENT"))
	RockEvent:DispatchNamespaceEvent("Blizzard", "FAKE_BLIZZARD_EVENT", "Blah")
	assert(not triggered)
end)
