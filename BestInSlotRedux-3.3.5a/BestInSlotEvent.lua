local BestInSlot, L, AceGUI = unpack(select(2, ...))
local eventId = 0
local eventHandlers = {}
local callbacks = {}
---
--List of events that the add-on makes
-- InitializeLootTable: Fired when a loot table is initialized
--    arg1 : eventName
--    arg2 : ID of the raid Tier that's initialized
-- 
-- DebugOptionsChanged: Fired when the debug options have changed
--    arg1 :  True/false wether the options are now true or false 
-- 
-- Any AddonEvent Message received will automatically fire an event in the format
-- AddonMessage_Identifier (for example: AddonMessage_version when a version message is received)
-- 
-- Any AddonEvent Message sent will automatically fire an event in the format
-- MessageSent_Identifier (for example: MessageSent_versioncheck when a version message is received)
---

--- Register an event 
-- @param #string name The event to register, * to register to all events
-- @param #function callback The function to call when an event hits
-- @return #number the unique id of this event
function BestInSlot:RegisterEvent(name, callback, ...)
  eventId = eventId + 1
  local callbackType = type(callback)
  if not (callbackType == "function" or (callbackType == "string" and BestInSlot[callback])) then error("Callback should be a function or a string representing a function in BestInSlot!") end
  if not eventHandlers[name] then
    eventHandlers[name] = {}
  end
  local eventIdStr = tostring(eventId)
  local callbackinfo = {func = callback, event = name, eventid = eventId}
  if ... then
    callbackinfo.args = {...}
  end
  callbacks[eventIdStr] = callbackinfo
  if callbacks[callback] then
    if type(callbacks[callback]) ~= "table" then
      callbacks[callback] = {[tostring(callbacks[callback].eventid)] = callbacks[callback]}
    end
    callbacks[callback][eventId] = callbackinfo
  else
    callbacks[callback] = callbackinfo
  end
  eventHandlers[name][eventIdStr] = callbackinfo
  return eventId
end

local function formatArgumentOrder(callbackArgs, ...)
   if not callbackArgs or #callbackArgs == 0 then return ... end
   local args = {...}
   for i=1,#callbackArgs do
      args[#args + 1] = callbackArgs[i]
   end
   return unpack(args)
end

--- Send an event
-- @param #string name The name of the event to send
-- @param #multiple ... Any extra parameters will be forwarded to the eventhandler
-- 
function BestInSlot:SendEvent(name, ...)
  local eventArgs = {...}
  if eventHandlers[name] then
    for _,eventInfo in pairs(eventHandlers[name]) do
      local func = eventInfo.func
      local args = eventInfo.args
      if type(func) == "function" then
        func(name, formatArgumentOrder(eventInfo.args, ...))
      else
        self[func](self, name, formatArgumentOrder(eventInfo.args, ...))
      end
    end
  end
  if eventHandlers["*"] then
    for eventid,eventInfo in pairs(eventHandlers["*"]) do
      local func = eventInfo.func
      local args = eventInfo.args
      if type(func) == "function" then
        func(name, formatArgumentOrder(eventInfo.args, ...))
      else
        self[func](self, name, formatArgumentOrder(eventInfo.args, ...))
      end
    end
  end
end

--- Unregister an eventhandler
-- @param #string name The name of the event to unregister
-- @param #function callback The function to unregister
-- @param #number callback The number to unregister
-- @return #boolean True if successfully removed, false if not
function BestInSlot:UnregisterEvent(name, callback)
  local result = false
  local callbackType = type(callback)
  if callbackType == "number" then callback = tostring(callback) end
  local eventInfo = callbacks[callback]
  if not eventInfo then return false end
  local eventId = tostring(eventInfo.eventid)
  if type(callbacks[eventInfo.func]) == "table" then
    callbacks[eventInfo.func][eventId] = nil
  else
    callbacks[eventInfo.func] = nil
  end
  callbacks[eventId] = nil
  eventHandlers[eventInfo.event][eventId] = nil
  return true
end

function BestInSlot:DumpEventsInConsole()
  self.console:Add("Event handler table", eventHandlers)
  local i = 1
  local prev
  while i < eventId do
    i = tostring(i)
    if callbacks[i] then
      if prev then
        self.console:Add("Events " .. prev .. " to " .. (i - 1) .. " have unregistered")
        prev = nil
      end
      self.console:Add("Event "..i, callbacks[i])
    elseif not prev then
      prev = i
    end
    i = i + 1
  end
    if prev then
      self.console:Add("Events " .. prev .. " to " .. (i) .. " have unregistered")
      prev = nil
    end
end