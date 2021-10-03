--[[
Name: LibRockTimer-1.0
Revision: $Rev: 232 $
Developed by: ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: Library to allow for the creation of schedules.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockTimer-1.0"
local MINOR_VERSION = tonumber(("$Revision: 232 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockTimer, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockTimer then
	return
end

local FREQUENCY = 20+1 -- Timers will not be fired more often than FREQUENCY-1 times per second.
local NUM_BUCKETS = 131 -- Prime for good distribution

local _G = _G
local Rock = _G.Rock
local assert = _G.assert
local error = _G.error
local GetTime = _G.GetTime
local pairs = _G.pairs
local unpack = _G.unpack
local pcall = _G.pcall
local tostring = _G.tostring
local type = _G.type
local select = _G.select
local math_floor = _G.math.floor

-- the frame to receive OnUpdates from
RockTimer.frame = oldLib and oldLib.frame or _G.CreateFrame("Frame")
local frame = RockTimer.frame
-- timers[uid] = { object = objectThatCreatedIt, nextTime = nextTimeToRun, delay = delayTimeIfRepeating, callback = methodOrFunction, callback_type = type(callback), n = numberOfArguments, [1] = arg1, [n] = argn}
RockTimer.timers = oldLib and oldLib.timers or {}
local timers = RockTimer.timers

local newList, del = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "del")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local buckets = {}
for i = -1, NUM_BUCKETS-1 do
	buckets[i] = {}
end

for uid, timer in pairs(timers) do
	local num
	if timer.delay == 0 then
		num = -1
	else
		num = math_floor(timer.nextTime * FREQUENCY) % NUM_BUCKETS
	end
	timer.bucket = num
	buckets[num][uid] = true
end

local function toliteral(x)
	if type(x) == "string" then
		return ("%q"):format(x)
	else
		return tostring(x)
	end
end

local function addTimer(object, uid, delay, repeating, callback, type_callback, ...)
	local timer
	if not uid then
		timer = newList()
		timers[timer] = timer
	else
		timer = timers[uid]
		if not timer then
			timer = newList()
			timers[uid] = timer
		else
			for k in pairs(timer) do
				timer[k] = nil
			end
		end
	end
	local nextTime = GetTime() + delay
	timer.nextTime = nextTime
	if repeating then
		timer.delay = delay
	end
	local bucket
	if delay == 0 then
		bucket = -1
	else
		bucket = math_floor(nextTime * FREQUENCY) % NUM_BUCKETS
	end
	timer.bucket = bucket
	buckets[bucket][uid] = true
	timer.object = object
	timer.callback = callback
	timer.type_callback = type_callback
	local n = select('#', ...)
	timer.n = n
	for i = 1, n do
		timer[i] = select(i, ...)
	end
end

--[[----------------------------------------------------------------------------------
Notes:
	* Add a timer that will fire in the allotted time.
	* To fire on the next frame, specify a delay of 0.
Arguments:
	string or number - a unique identifier, to allow for easy removal later. Optional, default: nil.
	number - the amount of seconds until the callback is fired. Must be either 0 or >= 0.05.
	string or function - the method name or function to call.
	tuple - a list of arguments to pass along.
Example:
	MyAddon:AddTimer(5, "SomethingToFireInFiveSeconds")
	MyAddon:AddTimer(10, function(value) print("Kersplosion!x" .. value) end, 50)
	MyAddon:AddTimer("myUID", 0, "SomethingToFireNextFrame")
------------------------------------------------------------------------------------]]
function RockTimer:AddTimer(uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		if callback == nil and select('#', ...) == 0 then
			return RockTimer.AddTimer(self, nil, uid, delay)
		else
			return RockTimer.AddTimer(self, nil, uid, delay, callback, ...)
		end
	end
	
	if not uid then
		uid = Rock:GetUID()
	end
	
	return addTimer(self, uid, delay, false, callback, type(callback), ...)
end
precondition(RockTimer, "AddTimer", function(self, uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		-- because it returns anyway
		return
	end
	argCheck(delay, 3, "number")
	if delay < 0.05 and delay ~= 0 then
		error(("Bad argument #3 to `AddTimer'. Cannot be less than 0.05 and not 0, got %s."):format(delay), 3)
	end
	argCheck(callback, 4, "function", "string")
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #4 to `AddTimer'. %q is not a %q, got %q."):format(callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockTimer, "AddTimer", function(ret, self, uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		-- because it returns anyway
		return
	end
	if uid then
		assert(self:HasTimer(uid))
	end
end)

--[[----------------------------------------------------------------------------------
Notes:
	* Add a timer that will fire in the allotted time and repeatedly every so often after that point.
	* To fire on every frame, specify a delay of 0.
	* This will run every `delay` that you set. This keeps track of the original starting time and goes by that instead of running every `delay` after each run, which actually, due to the lack of infinite framerate, would cause it to run every `delay` + epsilon seconds. Without lag spikes, this will run 10 times in 10 seconds for a delay of 1, instead of possibly 9 or 8 times, never catching up.
	* If a lag spike occurs where multiple seconds are lost, all waiting timers will be run, but will not play a game of "catch-up", i.e. if you have a delay of 1, you lose 10 seconds, instead of running the timer 10x in the next 10 frames, it will run the next frame, somewhere between 0-1 seconds later (depending on the length of the lag spike, it stays in tune with the original time), and then every second after that.
Arguments:
	string or number - a unique identifier, to allow for easy removal later. Optional, default: nil.
	number - the amount of seconds until the callback is fired. Must be either 0 or >= 0.05.
	string or function - the method name or function to call.
	tuple - a list of arguments to pass along.
Example:
	MyAddon:AddTimer(5, "SomethingToFireInFiveSeconds")
	MyAddon:AddTimer(10, function(value) print("Kersplosion!x" .. value) end, 50)
	MyAddon:AddTimer("myUID", 0, "SomethingToFireNextFrame")
------------------------------------------------------------------------------------]]
function RockTimer:AddRepeatingTimer(uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		if callback == nil and select('#', ...) == 0 then
			return RockTimer.AddRepeatingTimer(self, nil, uid, delay)
		else
			return RockTimer.AddRepeatingTimer(self, nil, uid, delay, callback, ...)
		end
	end
	
	if not uid then
		uid = Rock:GetUID()
	end
	
	return addTimer(self, uid, delay, true, callback, type(callback), ...)
end
precondition(RockTimer, "AddRepeatingTimer", function(self, uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		-- because it returns anyway
		return
	end
	argCheck(delay, 3, "number")
	if delay < 0.05 and delay ~= 0 then
		error(("Bad argument #3 to `AddRepeatingTimer'. Cannot be less than 0.05 and not 0, got %s."):format(delay), 3)
	end
	argCheck(callback, 4, "function", "string")
	if type(callback) == "string" and type(self[callback]) ~= "function" then
		error(("Bad argument #4 to `AddRepeatingTimer'. %q is not a %q, got %q."):format(callback, "function", type(self[callback])), 3)
	end
end)
postcondition(RockTimer, "AddRepeatingTimer", function(ret, self, uid, delay, callback, ...)
	local type_delay = type(delay)
	if type_delay == "function" or type_delay == "string" then
		-- because it returns anyway
		return
	end
	if uid then
		assert(self:HasTimer(uid))
	end
end)

local tmp = {}
local currentBucket = math_floor(GetTime() * FREQUENCY)
local function OnUpdate(this, elapsed)
	local now = GetTime()
	local nowBucket = math_floor(now * FREQUENCY)
	local max = -1
	if nowBucket ~= currentBucket then
		-- if we're looking at a new bucket
		if currentBucket <= nowBucket - NUM_BUCKETS then -- occurs on lag spikes
			-- causes every timer to be iterated.
			currentBucket = currentBucket - NUM_BUCKETS + 1
		else
			currentBucket = currentBucket + 1
		end
		
		max = nowBucket - currentBucket
	end
	
	local soon = now + 1 -- +1 is safe as long as 1 < HZ < BUCKETS/2
	
	for i = -1, max do
		local bucketNum
		if i == -1 then
			-- check delay = 0
			bucketNum = -1
		else
			bucketNum = (i + currentBucket) % NUM_BUCKETS
		end
		local bucket = buckets[bucketNum]
		
		for uid in pairs(bucket) do
			tmp[uid] = true
		end
		for uid in pairs(tmp) do
			local timer = timers[uid]
			if timer then
				local nextTime = timer.nextTime
				if soon >= nextTime then
					local delay = timer.delay
					if delay and delay ~= 0 then
						local newNextTime = nextTime + delay
						while newNextTime < now do
							-- make sure to fire on the next correct time, skipping over any lagged times.
							-- this occurs if there is a bad lag spike
							newNextTime = newNextTime + delay
						end
						timer.nextTime = newNextTime
						
						-- update the bucket
						local newBucketNum = math_floor(newNextTime * FREQUENCY) % NUM_BUCKETS
						bucket[uid] = nil
						buckets[newBucketNum][uid] = true
					end
					RockTimer.currentUID = Rock:GetUID()
					local callback = timer.callback
					local type_callback = timer.type_callback
					if type_callback == "string" then
						local object = timer.object
						local object_method = object[callback]
						if not object_method then -- already did typecheck, just check existence
							local success, ret = pcall(error, ("Error calling method %q on object %q. Method does not exist."):format(callback, tostring(object)))
							geterrorhandler()(ret)
							delay = nil
						else
							object_method(object, unpack(timer, 1, timer.n))
--[[							local success, ret = pcall(object_method, object, unpack(timer, 1, timer.n))
							if not success then
								geterrorhandler()(ret)
								delay = nil
							end]]
						end
					else -- function
						local success, ret = pcall(callback, unpack(timer, 1, timer.n))
						if not success then
							geterrorhandler()(ret)
							delay = nil
						end
					end
					RockTimer.currentUID = nil
					if not delay then
						-- not repeating
						local newTimer = timers[uid]
						if newTimer and newTimer.nextTime == nextTime then -- otherwise it's be manually reset
							bucket[uid] = nil
							timers[uid] = del(timer)
						end
					end
				end
			end
			tmp[uid] = nil
		end
	end
	currentBucket = nowBucket
end
frame:SetScript("OnUpdate", OnUpdate)

--[[----------------------------------------------------------------------------------
Notes:
	* Remove a timer with the specified uid.
Arguments:
	string or number - a unique identifier.
Returns:
	boolean - whether the timer was actually removed.
Example:
	MyAddon:AddTimer("myUID", 0, "SomethingToFireNextFrame")
	MyAddon:RemoveTimer("myUID")
------------------------------------------------------------------------------------]]
function RockTimer:RemoveTimer(uid)
	local timer = timers[uid]
	if not timer then
		return false
	else
		local bucket = timer.bucket
		if bucket then
			buckets[bucket][timer] = nil
		end
		timers[uid] = del(timer)
		return true
	end
end
precondition(RockTimer, 'RemoveTimer', function(self, uid)
	if not uid then
		error(("Bad argument #2 to `RemoveTimer'. Expected non-false, got %s"):format(toliteral(uid)), 2)
	end
end)
postcondition(RockTimer, 'RemoveTimer', function(ret, self, uid)
	assert(not self:HasTimer(uid))
end)

--[[----------------------------------------------------------------------------------
Notes:
	* Remove all timers created by this object.
Example:
	MyAddon:RemoveAllTimers()
------------------------------------------------------------------------------------]]
function RockTimer:RemoveAllTimers()
	for uid, timer in pairs(timers) do
		if timer.object == self then
			timers[uid] = del(timer)
		end
	end
end

--[[----------------------------------------------------------------------------------
Notes:
	* Remove a timer with the specified uid.
Arguments:
	string or number - a unique identifier.
Returns:
	boolean or number - false if the timer does not exist, otherwise the amount of time until the timer goes off.
Example:
	MyAddon:AddTimer("myUID", 0, "SomethingToFireNextFrame")
	local hasTimer = MyAddon:HasTimer("myUID")
------------------------------------------------------------------------------------]]
function RockTimer:HasTimer(uid)
	local timer = timers[uid]
	if not timer then
		return false
	end
	local nextTime = timer.nextTime
	return nextTime - GetTime()
end
precondition(RockTimer, 'HasTimer', function(self, uid)
	if not uid then
		error(("Bad argument #2 to `HasTimer'. Expected non-false, got %s"):format(toliteral(uid)), 2)
	end
end)

function RockTimer:OnUnembed(object)
	self.RemoveAllTimers(object)
end

function RockTimer:OnEmbedDisable(object)
	self.RemoveAllTimers(object)
end

RockTimer:SetExportedMethods("AddTimer", "AddRepeatingTimer", "RemoveTimer", "RemoveAllTimers", "HasTimer")

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local t = {name = "RockTimerUnitTest"}
	RockTimer:Embed(t)
	
	local triggered = false
	function t:Alpha(...)
		triggered = true
		assert((...) == "Blah")
	end
	local uid = Rock:GetUID()
	assert(not t:HasTimer(uid))
	t:AddTimer(uid, 0, "Alpha", "Blah")
	assert(t:HasTimer(uid))
	OnUpdate(frame, 0)
	assert(triggered)
	triggered = false
	assert(not t:HasTimer(uid))
	
	t:AddRepeatingTimer(uid, 0, "Alpha", "Blah")
	assert(t:HasTimer(uid))
	OnUpdate(frame, 0)
	assert(triggered)
	triggered = false
	assert(t:HasTimer(uid))
	OnUpdate(frame, 0)
	assert(triggered)
	triggered = false
	assert(t:HasTimer(uid))
	t:RemoveTimer(uid)
	assert(not t:HasTimer(uid))
	
	t:AddRepeatingTimer(uid, 0, "Alpha", "Blah")
	assert(t:HasTimer(uid))
	OnUpdate(frame, 0)
	assert(triggered)
	triggered = false
	assert(t:HasTimer(uid))
	OnUpdate(frame, 0)
	assert(triggered)
	triggered = false
	assert(t:HasTimer(uid))
	t:RemoveAllTimers(uid)
	assert(not t:HasTimer(uid))
end)
