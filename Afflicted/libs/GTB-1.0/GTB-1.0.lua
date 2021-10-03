local major = "GTB-1.0"
local minor = 1501
assert(LibStub, string.format("%s requires LibStub.", major))

local GTB = LibStub:NewLibrary(major, minor)
if( not GTB ) then return end

local L = {
	["BAD_ARGUMENT"] = "bad argument #%d for '%s' (%s expected, got %s)",
	["MUST_CALL"] = "You must call '%s' from a registered GTB object.",
	["GROUP_EXISTS"] = "The group '%s' already exists.",
	["BAD_FUNC"] = "You must pass an actual handler and function to '%s'.",
}

-- Validation for passed arguments
local function assert(level, condition, message, ...)
	if( not condition ) then
		error(string.format(message, ...), level)
	end
end

local function argcheck(value, num, ...)
	if( type(num) ~= "number" ) then
		error(L["BAD_ARGUMENT"]:format(2, "argcheck", "number", type(num)), 1)
	end

	for i=1,select("#", ...) do
		if( type(value) == select(i, ...) ) then return end
	end

	local types = string.join(", ", ...)
	local name = string.match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(L["BAD_ARGUMENT"]:format(num, name, types, type(value)), 3)
end

-- GTB Library
GTB.framePool = GTB.framePool or {}
GTB.groups = GTB.groups or {}
GTB.defaultFontPath = GameFontHighlight:GetFont()

local framePool = GTB.framePool
local groups = GTB.groups
local methods = {"RegisterOnMove", "SetAnchorVisible", "SetGroupID", "SetMaxBars", "SetBaseColor", "EnableGradient", "SetFont", "SetPoint", "SetScale", "SetWidth", "SetTexture", "SetBarGrowth", "SetIconPosition",
"SetFadeTime", "SetBackgroundColor", "RegisterOnFade", "RegisterOnClick", "SetDisplayGroup", "GetDisplayGroup", "RegisterBar", "UnregisterBar", "SetRepeatingTimer", "UnregisterAllBars", "SetBarIcon"}

-- Internal functions for managing bars
local function getFrame()
	-- Check for an unused bar
	if( #(framePool) > 0 ) then
		return table.remove(framePool, 1)
	end
		
	-- Create the actual bar
	local frame = CreateFrame("StatusBar", nil, UIParent)
	frame:SetClampedToScreen(true)
	frame:SetMinMaxValues(0, 1)
	frame:SetValue(1)	
	
	frame.bg = CreateFrame("StatusBar", nil, frame)
	frame.bg:SetMinMaxValues(0, 1)
	frame.bg:SetValue(1)
	frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	frame.bg:SetFrameLevel(0)

	-- Create icon
	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	
	-- Timer text
	frame.timer = frame:CreateFontString(nil, "OVERLAY")
	frame.timer:SetFontObject(GameFontHighlight)
	frame.timer:SetJustifyH("RIGHT")
	
	-- Display Text
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetJustifyH("LEFT")
	
	return frame
end

-- Release it to be reused later
local function releaseFrame(frame)
	frame.removed = nil
	
	-- Stop updates
	frame:SetScript("OnUpdate", nil)
	frame:EnableMouse(false)
	frame:Hide()

	-- Reset alpha so everythings visible again
	frame:SetAlpha(1.0)

	-- And now readd to the frame pool
	table.insert(framePool, frame)	
end

local function safecall(func, ...)
	local success, result = pcall(func, ...)
	if( not success ) then
		geterrorhandler()(result)
	end
end

local function triggerFadeCallback(group, barID)
	if( type(group.onFadeHandler) == "table" and type(group.onFadeFunc) == "string" ) then
		safecall(group.onFadeHandler[group.onFadeFunc], group.onFadeHandler, barID)
	elseif( type(group.onFadeFunc) == "string" ) then
		safecall(getglobal(group.onFadeFunc), barID)
	elseif( type(group.onFadeFunc) == "function" ) then
		safecall(group.onFadeFunc, barID)
	end
end

-- Fadeout OnUpdate
local function fadeOnUpdate(self, elapsed)
	local time = GetTime()
	self.fadeTime = self.fadeTime - (time - self.lastUpdate)
	self.lastUpdate = time

	-- Done fading, hide
	if( self.fadeTime <= 0 ) then
		groups[self.owner]:UnregisterBar(self.barID, true)
		return
	end
		
	self:SetAlpha(self.fadeTime / self.timeToFade)
end

-- Starts to fade out the actual bar
local function fadeoutBar(self)
	local group = groups[self.owner]
	
	triggerFadeCallback(groups[self.originalOwner], self.barID)

	-- Don't fade at all, remove right now
	if( group.fadeTime <= 0 ) then
		group:UnregisterBar(self.barID, true)
		return
	end
	
	-- Start fading
	self.timeToFade = group.fadeTime
	self.fadeTime = group.fadeTime
	self:SetScript("OnUpdate", fadeOnUpdate)
end

-- OnUpdate for a bar
local function barOnUpdate(self)
	local time = GetTime()
	-- Check if times ran out and that we need to start fading it out
	self.secondsLeft = self.secondsLeft - (time - self.lastUpdate)
	self.lastUpdate = time
	if( self.secondsLeft <= 0 ) then
		-- Check if it's a repeating timer
		local bar = groups[self.groupName].bars[self.barID]
		if( bar and bar.repeating ) then
			self.secondsLeft = self.startSeconds
			self.lastUpdate = time
			return
		end
		
		self:SetValue(0)
		
		fadeoutBar(self)
		return
	end
	
	-- Timer text, need to see if this can be optimized a bit later
	local hour = floor(self.secondsLeft / 3600)
	local minutes = self.secondsLeft - (hour * 3600)
	minutes = floor(minutes / 60)
	
	local seconds = self.secondsLeft - ((hour * 3600) + (minutes * 60))
	
	if( hour > 0 ) then
		self.timer:SetFormattedText("%d:%02d", hour, minutes)
	elseif( minutes > 0 ) then
		self.timer:SetFormattedText("%d:%02d", minutes, floor(seconds))
	elseif( seconds < 10 ) then
		self.timer:SetFormattedText("%.1f", seconds)
	else
		self.timer:SetFormattedText("%.0f", floor(seconds))
	end
	
	local percent = self.secondsLeft / self.startSeconds

	-- Color gradient towards red
	if( self.gradients ) then
		-- finalColor + (currentColor - finalColor) * percentLeft		
		self:SetStatusBarColor(1.0 + (self.r - 1.0) * percent, self.g * percent, self.b * percent)
	end

	-- Now update the actual displayed bar
	self:SetValue(percent)
	self.text:SetWidth(self:GetWidth() - self.timer:GetWidth() - 5)
end

-- Reposition the group
local function sortBars(a, b)
	return a.endTime < b.endTime
end

local function repositionFrames(group)
	table.sort(group.usedBars, sortBars)

	local offset = 0
	if( group.iconPosition == "LEFT" ) then
		offset = group.height
	end
	
	for i, bar in pairs(group.usedBars) do
		bar:ClearAllPoints()
		
		if( i > 1 ) then
			if( group.barGrowth == "DOWN" ) then
				bar:SetPoint("TOPLEFT", group.usedBars[i - 1], "BOTTOMLEFT", 0, 0)
			else
				bar:SetPoint("BOTTOMLEFT", group.usedBars[i - 1], "TOPLEFT", 0, 0)
			end
		elseif( group.barGrowth == "UP" ) then
			bar:SetPoint("BOTTOMLEFT", group.frame, "TOPLEFT", offset, 0)
		else
			bar:SetPoint("TOPLEFT", group.frame, "BOTTOMLEFT", offset, 0)
		end
		
		-- Did we hit the bar limit yet?
		if( not group.maxBars or i <= group.maxBars ) then
			bar:Show()
		else
			bar:Hide()
		end
	end
end

------------------------
-- GTB PUBLIC METHODS --
------------------------

-- Register a new group
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 0.80,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

-- Dragging functions
local function OnDragStart(self)
	self.isMoving = true
	self:StartMoving()
end

local function OnDragStop(self)
	if( self.isMoving ) then
		self.isMoving = nil
		self:StopMovingOrSizing()

		local x, y = self:GetLeft(), self:GetTop()

		local group = groups[self.name]
		if( group.onMoveHandler and group.onMoveFunc ) then
			safecall(group.onMoveHandler[group.onMoveFunc], group.onMoveHandler, self, x, y)			
		elseif( type(group.onMoveFunc) == "string" ) then
			safecall(getglobal(group.onMoveFunc), self, x, y)
		elseif( type(group.onMoveFunc) == "function" ) then
			safecall(group.onMoveFunc, self, x, y)
		end
	end
end

function GTB:RegisterGroup(name, texture)
	argcheck(name, 1, "string")
	argcheck(texture, 2, "string")
	assert(3, not groups[name], L["GROUP_EXISTS"], name)

	local obj = {name = name, frame = CreateFrame("Frame", nil, UIParent), fontSize = 12, height = 16, obj = obj, bars = {}, usedBars = {}}
	
	-- Inject our methods
	for _, func in pairs(methods) do
		obj[func] = GTB[func]
	end

	-- Register
	groups[name] = obj

	-- Set defaults
	local frame = obj.frame
	frame:SetHeight(12)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 1.0)
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1.0)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame:SetScript("OnShow", OnShow)
	frame.name = name
	
	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlightSmall)
	frame.text:SetText(name)
	
	obj:SetScale(1.0)
	obj:SetWidth(200)
	obj:SetFadeTime(0.10)
	obj:SetMaxBars(nil)
	obj:EnableGradient(true)
	obj:SetAnchorVisible(true)
	obj:SetBarGrowth("DOWN")
	obj:SetIconPosition("LEFT")
	obj:SetTexture(texture)
	obj:SetBaseColor(0.0, 1.0, 0.0)
	obj:SetBackgroundColor(nil, nil, nil)
	obj:SetPoint("CENTER", UIParent, "CENTER")
	
	return obj	
end

-- Retrieve a group after it's been registered
function GTB:GetGroup(name)
	argcheck(name, 1, "string")
	return groups[name] and groups[name].obj
end

-- Returns every registered group and it's config obj
function GTB:GetGroups()
	return groups
end

-----------------
----- MISC ------
-----------------

-- Set a unique ID for this group
function GTB.SetGroupID(group, id)
	argcheck(id, 2, "string")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetGroupID")
	
	group.frame.groupID = id
	group.groupID = id
end

-- Toggle if the drag anchor should be shown
function GTB.SetAnchorVisible(group, flag)
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetAnchorVisible")
	
	group.anchorShown = flag
	
	if( flag ) then
		group.frame:EnableMouse(true)
		group.frame:SetAlpha(1.0)
	else
		group.frame:EnableMouse(false)
		group.frame:SetAlpha(0)
	end
end

function GTB.RegisterOnMove(group, handler, func)
	argcheck(handler, 2, "table", "function", "string")
	argcheck(func, 2, "string", "nil")
	
	if( func ) then
		if( not handler[func] ) then
			error(string.format(L["BAD_FUNC"], "RegisterOnMove"), 3)
		end
		
		group.onMoveHandler = handler
		group.onMoveFunc = func
	else
		if( type(handler) == "function" and not handler ) then
			error(string.format(L["BAD_FUNC"], "RegisterOnMove"), 3)
		end

		group.onMoveFunc = handler
	end
end

-- Associate a function to call when bars fade
function GTB.RegisterOnFade(group, handler, func)
	argcheck(handler, 2, "table", "function", "string")
	argcheck(func, 2, "string", "nil")
	
	if( func ) then
		if( not handler[func] ) then
			error(string.format(L["BAD_FUNC"], "RegisterOnFade"), 3)
		end
		
		group.onFadeHandler = handler
		group.onFadeFunc = func
	else
		if( type(handler) == "function" and not handler ) then
			error(string.format(L["BAD_FUNC"], "RegisterOnFade"), 3)
		end

		group.onFadeFunc = handler
	end
end

-----------------
-- BAR DISPLAY --
-----------------

-- Gradients from base color -> red depending on time left
function GTB.EnableGradient(group, flag)
	argcheck(flag, 2, "boolean")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "EnableGradient")
	
	group.gradients = flag
end

-- Sets the max number of bars that can show up in this group
function GTB.SetMaxBars(group, max)
	argcheck(max, 2, "number", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "EnableGradient")
	
	group.maxBars = max
	repositionFrames(group)
end

-- Group frame positioning, and all the timers inside it
function GTB.SetPoint(group, ...)
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetPoint")
			
	group.frame:ClearAllPoints()
	group.frame:SetPoint(...)
end

-- Bar scale
function GTB.SetScale(group, scale)
	argcheck(scale, 2, "number")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetScale")
	
	group.scale = scale
	group.frame:SetScale(scale)
	
	for _, bar in pairs(group.bars) do
		bar:SetScale(scale)
	end
end

-- Set font/font size
function GTB.SetFont(group, path, size, style)
	argcheck(path, 2, "string")
	argcheck(size, 3, "number")
	argcheck(style, 4, "string", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetFont")
	
	group.fontSize = size or 11
	group.fontPath = path or GTB.defaultFontPath
	group.fontStyle = style
	
	-- Update any existing ones
	for _, bar in pairs(group.bars) do
		bar.timer:SetFont(group.fontPath, group.fontSize, group.fontStyle)
		bar.text:SetFont(group.fontPath, group.fontSize, group.fontStyle)
	end
end

-- Width of all the bars
function GTB.SetWidth(group, width)
	argcheck(width, 2, "number")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetWidth")
	
	group.width = width
	group.frame:SetWidth(width + group.height)

	for _, bar in pairs(group.bars) do
		bar.text:SetWidth((group.width - ((group.fontSize or size) * 3.6)) * 0.90)
		bar.bg:SetWidth(group.width)
		bar:SetWidth(group.width)
	end
end

-- Bar texture
function GTB.SetTexture(group, texture)
	argcheck(texture, 2, "string")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetTexture")
	
	group.texture = texture
	
	for _, bar in pairs(group.bars) do
		bar.bg:SetStatusBarTexture(texture)
		bar:SetStatusBarTexture(texture)
	end
end

-- Bar growth mode (UP/DOWN)
function GTB.SetBarGrowth(group, type)
	assert(3, type == "UP" or type == "DOWN", L["BAD_ARGUMENT"], 2, "SetBarGrowth", "UP, DOWN", tostring(type))
	assert(3, group.name and groups[group.name], string.format(L["MUST_CALL"], "SetBarGrowth"))
	
	group.barGrowth = type
	
	repositionFrames(group)
end

-- Icon positioning (LEFT/RIGHT)
function GTB.SetIconPosition(group, position)
	assert(3, position == "LEFT" or position == "RIGHT", L["BAD_ARGUMENT"], 2, "SetIconPosition", "LEFT, RIGHT", tostring(position))
	assert(3, group.name and groups[group.name], string.format(L["MUST_CALL"], "SetIconPosition"))
	
	group.iconPosition = position
end

-- Group object
function GTB.SetBaseColor(group, r, g, b)
	argcheck(r, 2, "number", "nil")
	argcheck(g, 3, "number", "nil")
	argcheck(b, 4, "number", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetBaseColor")
	
	if( not group.baseColor ) then
		group.baseColor = {}
	end
	
	group.baseColor.r = r
	group.baseColor.g = g
	group.baseColor.b = b

	for _, bar in pairs(group.bars) do
		bar:SetStatusBarColor(frame.startR or group.baseColor.r, frame.startG or group.baseColor.g, frame.startB or group.baseColor.b)
	end
end

function GTB.SetBackgroundColor(group, r, g, b)
	argcheck(r, 2, "number", "nil")
	argcheck(g, 3, "number", "nil")
	argcheck(b, 4, "number", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetBackgroundColor")
	
	if( not group.bgColor ) then
		group.bgColor = {}
	end
	
	group.bgColor.r = r
	group.bgColor.g = g
	group.bgColor.b = b

	for _, bar in pairs(group.bars) do
		if( group.bgColor ) then
			bar.bg:SetStatusBarColor(group.bgColor.r or 0.0, group.bgColor.g or 0.5, group.bgColor.b or 0.5, 0.5)
		else
			bar.bg:SetStatusBarColor(0.0, 0.5, 0.5, 0.5)
		end
	end
end

-- How many seconds we should take to fade out
function GTB.SetFadeTime(group, seconds)
	argcheck(seconds, 2, "number")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetFadeTime")
	
	group.fadeTime = seconds
end

-- Redirect everything to the specified group
function GTB.SetDisplayGroup(group, name)
	argcheck(name, 2, "string", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetDisplayGroup")
	
	-- Don't allow setting the group to redirect to itself
	if( name == "" or name == group.name ) then
		name = nil
	end
	
	-- Reset the bars if the display group changed
	if( group.redirectTo ~= name ) then
		group:UnregisterAllBars()
	end
	
	group.redirectTo = name
end

-- Gets the current display group
function GTB.GetDisplayGroup(group)
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "GetDisplayGroup")
	
	return group.redirectTo
end

--------------------
-- BAR MANAGEMENT --
--------------------

-- Register
function GTB.RegisterBar(group, id, text, seconds, startSeconds, icon, r, g, b)
	argcheck(id, 2, "string", "number")
	argcheck(text, 3, "string")
	argcheck(seconds, 4, "number")
	argcheck(startSeconds, 5, "number", "nil")
	argcheck(icon, 6, "string", "nil")
	argcheck(r, 7, "number", "nil")
	argcheck(g, 8, "number", "nil")
	argcheck(b, 9, "number", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "RegisterBar")
		
	local originalOwner = group.name
	
	-- Check if we're supposed to redirect this to another group, and that the group exists
	if( group.redirectTo and groups[group.redirectTo] ) then
		group = groups[group.redirectTo]
	end
	
	-- Already exists, remove the old one quickly
	if( group.bars[id] ) then
		group:UnregisterBar(id, true)
	end

	-- Retrieve a frame thats either recycled, or a newly created one
	local frame = getFrame()
	
	-- Font path was not set, so use the default.
	group.fontPath = group.fontPath or GTB.defaultFontPath
	
	-- So we can do sorting and positioning
	table.insert(group.usedBars, frame)
	
	frame.timer:SetPoint("RIGHT", frame, "RIGHT", -1, 0)
	frame.timer:SetHeight(group.height)
	frame.timer:SetFont(group.fontPath, group.fontSize, group.fontStyle)
	frame.timer:SetText(seconds)
	
	frame.text:SetPoint("LEFT", frame, "LEFT", 1, 0)
	frame.text:SetHeight(group.height)
	frame.text:SetWidth(group.width - frame.timer:GetWidth() - 5)
	frame.text:SetFont(group.fontPath, group.fontSize, group.fontStyle)
	frame.text:SetText(text)
	
	-- Update icon
	if( icon ) then
		frame.icon:SetTexture(icon)
		
		if( frame.icon:GetTexture() ) then
			local offset = 0
			if( group.iconPosition == "LEFT" ) then
				offset = -group.height
			end
		
			frame.icon:SetWidth(group.height)
			frame.icon:SetHeight(group.height)
			frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			frame.icon:SetPoint("TOPLEFT", frame, "TOP" .. group.iconPosition, offset, 0)
			frame.icon:Show()
		else
			frame.icon:Hide()
		end
	else
		frame.icon:Hide()
	end
	
	-- Set info the bar needs to know
	frame.r = r or group.baseColor.r
	frame.g = g or group.baseColor.g
	frame.b = b or group.baseColor.b
	frame.startR = r
	frame.startG = g
	frame.startB = b
	frame.owner = group.name
	frame.originalOwner = originalOwner
	frame.lastUpdate = GetTime()
	frame.endTime = GetTime() + seconds
	frame.secondsLeft = seconds
	frame.startSeconds = startSeconds or seconds
	frame.gradients = group.gradients
	frame.groupName = group.name
	frame.iconPath = icon
	frame.barText = text
	frame.barID = id
		
	-- Setup background
	frame.bg:SetStatusBarTexture(group.texture)
	frame.bg:SetWidth(group.width)
	frame.bg:SetHeight(group.height)
	
	if( group.bgColor ) then
		frame.bg:SetStatusBarColor(group.bgColor.r or 0.0, group.bgColor.g or 0.5, group.bgColor.b or 0.5, 0.5)
	else
		frame.bg:SetStatusBarColor(0.0, 0.5, 0.5, 0.5)
	end

	-- Start it up
	frame:SetStatusBarTexture(group.texture)
	frame:SetStatusBarColor(frame.r, frame.g, frame.b)
	frame:SetWidth(group.width)
	frame:SetHeight(group.height)
	frame:SetScale(group.scale)
	frame:SetScript("OnUpdate", barOnUpdate)
	
	-- Reposition this group
	repositionFrames(group)

	-- Register it
	group.bars[id] = frame
end

-- Remove all bars
function GTB.UnregisterAllBars(group)
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "UnregisterAllBars")
	
	-- Check if we're supposed to redirect this to another group, and that the group exists
	if( group.redirectTo and groups[group.redirectTo] ) then
		group = groups[group.redirectTo]
	end

	-- Clear the used bars list
	local totalBars = #(group.usedBars)
	for i=totalBars, 1, -1 do
		table.remove(group.usedBars, i)
	end
	
	-- Release all the frames
	for id, bar in pairs(group.bars) do
		releaseFrame(bar)
		group.bars[id] = nil
	end
	
	return (totalBars > 0)
end

-- Unregistering
function GTB.UnregisterBar(group, id, noFade)
	argcheck(id, 2, "string", "number")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "UnregisterBar")
	
	-- Check if we're supposed to redirect this to another group, and that the group exists
	if( group.redirectTo and groups[group.redirectTo] ) then
		group = groups[group.redirectTo]
	end

	-- Remove the old entry, if it exists
	if( not group.bars[id] ) then
		return nil
	end

	-- Remove from list of used bars
	for i=#(group.usedBars), 1, -1 do
		if( group.usedBars[i].barID == id ) then
			if( noFade or group.fadeTime <= 0 ) then
				table.remove(group.usedBars, i)
			else
				group.usedBars[i].removed = true
				fadeoutBar(group.usedBars[i])
			end
			break
		end
	end

	if( noFade or group.fadeTime <= 0 ) then
		releaseFrame(group.bars[id])
		repositionFrames(group)
		
		group.bars[id] = nil
	end
	
	return true
end

-- Icon
function GTB.SetBarIcon(group, id, icon, left, right, top, bottom)
	argcheck(id, 2, "string", "number")
	argcheck(icon, 3, "string", "nil")
	argcheck(left, 4, "number", "nil")
	argcheck(right, 5, "number", "nil")
	argcheck(top, 6, "number", "nil")
	argcheck(bottom, 7, "number", "nil")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetBarIcon")
	
	-- Check if we're supposed to redirect this to another group, and that the group exists
	if( group.redirectTo and groups[group.redirectTo] ) then
		group = groups[group.redirectTo]
	end

	local bar = group.bars[id]
	if( not bar ) then
		return
	end
	
	-- Display icon
	if( icon ) then
		bar.bar.icon:SetTexture(icon)
		
		if( bar.bar.icon:GetTexture() ) then
			local mod = -1
			if( group.iconPosition == "RIGHT" ) then
				mod = 1
			end
		
			bar.icon:SetWidth(group.height)
			bar.icon:SetHeight(group.height)
			bar.icon:SetTexCoord(left or 0.07, right or 0.93, top or 0.07, bottom or 0.93)
			bar.icon:SetPoint("TOPLEFT", bar, "TOP" .. group.iconPosition, mod * group.height, 0)
			bar.icon:Show()
		else
			bar.bar.icon:Hide()
		end
	else
		bar.bar.icon:Hide()
	end
end

-- Change it to a repeating timer
function GTB.SetRepeatingTimer(group, id, flag)
	argcheck(id, 2, "string", "number")
	argcheck(flag, 3, "boolean")
	assert(3, group.name and groups[group.name], L["MUST_CALL"], "SetRepeatingTimer")

	-- Check if we're supposed to redirect this to another group, and that the group exists
	if( group.redirectTo and groups[group.redirectTo] ) then
		group = groups[group.redirectTo]
	end

	local bar = group.bars[id]
	if( bar ) then
		bar.repeating = flag
	end
end

-- Upgrade path
for name, obj in pairs(groups) do
	obj.frame:SetScript("OnEnter", nil)
	obj.frame:SetScript("OnLeave", nil)
	obj.frame:SetScript("OnDragStart", OnDragStart)
	obj.frame:SetScript("OnDragStop", OnDragStop)
	obj.frame:SetScript("OnShow", OnShow)

	for _, func in pairs(methods) do
		obj[func] = GTB[func]
	end
end
