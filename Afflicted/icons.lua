if( not Afflicted ) then return end

local Icons = Afflicted:NewModule("Icons", "AceEvent-3.0")

local ICON_SIZE = 20
local POSITION_SIZE = ICON_SIZE + 2
local methods = {"CreateDisplay", "ClearTimers", "CreateTimer", "RemoveTimerByID", "UnitDied", "ReloadVisual"}
local savedGroups = {}
local inactiveIcons = {}

function Icons:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Reposition the passed groups timers
local function repositionTimers(group)
	local anchor = Afflicted.db.profile.anchors[group.type]
		
	-- Reposition everything
	for id, icon in pairs(group.active) do
		if( id > 1 ) then
			icon:ClearAllPoints()
			if( not anchor.growUp ) then
				icon:SetPoint("TOPLEFT", group.active[id - 1], "BOTTOMLEFT", 0, 0)
			else
				icon:SetPoint("BOTTOMLEFT", group.active[id - 1], "TOPLEFT", 0, 0)
			end
		
		elseif( anchor.growUp ) then
			icon:ClearAllPoints()
			icon:SetPoint("BOTTOMLEFT", group, "TOPLEFT", 0, 0)
		else
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", group, "BOTTOMLEFT", 0, 0)
		end
		
		if( id <= anchor.maxRows ) then
			icon:Show()
		else
			icon:Hide()
		end
	end
end

-- Handle grabbing/releasing icons for everything
local function releaseIcon(group, id)
	local icon = table.remove(group.active, id)
	icon:Hide()
	
	table.insert(inactiveIcons, icon)
end

-- Update icon timer
local function OnUpdate(self, elapsed)
	local time = GetTime()
	self.timeLeft = self.timeLeft - (time - self.lastUpdate)
	self.lastUpdate = time
	
	if( self.timeLeft <= 0 ) then
		-- Check if we should start the timer again
		if( self.repeating ) then
			self.timeLeft = self.startSeconds
			self.lastUpdate = time
			
			local anchor = Icons.groups[self.type]
			table.sort(anchor.active, sortTimers)
			repositionTimers(anchor)
			return
		end
		
		-- Tell Afflicted it ended
		Afflicted:AbilityEnded(self.sourceGUID, self.sourceName, Afflicted:GetSpell(self.spellID, self.spellName), self.spellID, self.spellName, self.isCooldown)

		-- Timer over, release and reposition
		local group = Icons.groups[self.type]
		for id, row in pairs(group.active) do
			if( row.id == self.id ) then
				releaseIcon(group, id)
				repositionTimers(group)
				break
			end
		end
		return
	end
	
	-- Otherwise, update!
	if( self.timeLeft > 60 ) then
		self.text:SetFormattedText("%dm", self.timeLeft / 60)
	elseif( self.timeLeft > 10 ) then
		self.text:SetFormattedText("%d", self.timeLeft)
	else
		self.text:SetFormattedText("%.1f", self.timeLeft)
	end
end

-- Create an icon
local function createIcon()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(50)
	frame:SetHeight(ICON_SIZE)
	frame:SetClampedToScreen(true)
	frame:SetScript("OnUpdate", OnUpdate)
	
	frame.icon = frame:CreateTexture(nil, "BACKGROUND")
	frame.icon:SetWidth(ICON_SIZE)
	frame.icon:SetHeight(ICON_SIZE)
	frame.icon:SetPoint("LEFT")
	
	frame.text = frame:CreateFontString(nil, "BACKGROUND")
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetPoint("LEFT", ICON_SIZE + 2, 0)
	
	return frame
end

local function getIcon(group)
	local icon = table.remove(inactiveIcons, 1)
	if( not icon ) then
		icon = createIcon()
	end
	
	table.insert(group.active, icon)
	return icon
end

-- Sort timers by time left
local function sortTimers(a, b)
	return a.endTime < b.endTime
end

-- Dragging functions
local function OnDragStart(self)
	self.isMoving = true
	self:StartMoving()
end

local function OnDragStop(self)
	if( self.isMoving ) then
		self.isMoving = nil
		self:StopMovingOrSizing()
		
		if( not Afflicted.db.profile.anchors[self.type].position ) then
			Afflicted.db.profile.anchors[self.type].position = {}
		end
		
		local scale = self:GetEffectiveScale()
		Afflicted.db.profile.anchors[self.type].position.x = self:GetLeft() * scale
		Afflicted.db.profile.anchors[self.type].position.y = self:GetTop() * scale
	end
end

local function OnShow(self)
	local position = Afflicted.db.profile.anchors[self.type].position
	if( position ) then
		local scale = self:GetEffectiveScale()
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position.x / scale, position.y / scale)
	else
		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent, "CENTER", 0, self.createID * 25)
	end
end

local function showTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:AddDoubleLine(self.name, AfflictedLocals["Drag to move the frame anchor."], nil, nil, nil, 0.90, 0.90, 0.90)
	GameTooltip:Show()
end

local function hideTooltip(self)
	GameTooltip:Hide()
end

-- PUBLIC METHODS
-- Create our main display frame
local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

local total = 0
function Icons:CreateDisplay(type)
	local anchorData = Afflicted.db.profile.anchors[type]
	total = total + 1
	
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(ICON_SIZE)
	frame:SetHeight(ICON_SIZE)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScale(anchorData.scale)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 1.0)
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 1.0)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)
	frame:SetScript("OnShow", OnShow)
	frame:SetScript("OnEnter", showTooltip)
	frame:SetScript("OnLeave", hideTooltip)
	frame.active = {}
	frame.type = type
	frame.name = anchorData.text
	frame.createID = total
		
	-- Display name
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetPoint("CENTER", frame)
	frame.text:SetFontObject(GameFontHighlight)
	frame.text:SetText(string.sub(anchorData.text, 0, 1))

	if( Afflicted.db.profile.showAnchors ) then
		frame:EnableMouse(true)
		frame:SetAlpha(1)
	else
		frame:EnableMouse(false)
		frame:SetAlpha(0)
	end
	
	return frame
end

-- Return an object to access our visual style
function Icons:LoadVisual()
	local obj = {}
	for _, func in pairs(methods) do
		obj[func] = Icons[func]
	end
	
	-- Create anchors
	Icons.groups = {}
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( data.enabled and data.display == "icons" ) then
			Icons.groups[name] = Icons:CreateDisplay(name)
		end
	end
	
	return obj
end

-- Clear all running timers for this anchor type
function Icons:ClearTimers(type)
	local group = Icons.groups[type]
	if( group ) then
		for i=#(group.active), 1, -1 do
			releaseIcon(group, i)
		end
	end
end

-- Unit died, remove their timers
function Icons:UnitDied(guid)
	-- Loop through all created anchors
	for name, group in pairs(Icons.groups) do
		if( group ) then
			local removed
			for i=#(group.active), 1, -1 do
				local row = group.active[i]

				if( row.sourceGUID == guid ) then
					releaseIcon(group, i)
					removed = true
				end
			end

			-- Reposition everything
			if( removed ) then
				repositionTimers(group)
			end
		end
	end
end

-- Create a new timer
function Icons:CreateTimer(sourceGUID, sourceName, anchor, repeating, isCooldown, duration, spellID, spellName, spellIcon)
	local group = Icons.groups[anchor]
	if( not group ) then
		return
	end	

	local id = sourceGUID .. spellID
	if( isCooldown ) then
		id = id .. "CD"
	end
			
	-- Grabby
	local frame = getIcon(group)
	
	-- Set it for when it fades
	frame.id = id
	frame.repeating = repeating
	frame.isCooldown = isCooldown
	
	frame.spellID = spellID
	frame.spellName = spellName

	frame.sourceGUID = sourceGUID
	frame.sourceName = sourceName

	frame.startSeconds = duration
	frame.timeLeft = duration
	frame.lastUpdate = GetTime()
	frame.endTime = frame.lastUpdate + duration

	frame.type = group.type
	frame.icon:SetTexture(spellIcon)
	frame:SetScale(Afflicted.db.profile.anchors[anchor].scale)
	
	-- Reposition
	repositionTimers(group)
end

-- Remove a specific anchors timer by ID
function Icons:RemoveTimerByID(anchor, id)
	local removedTimer
	for _, group in pairs(Icons.groups) do
		-- Remove the icon timer
		local removed
		for i=#(group.active), 1, -1 do
			if( group.active[i].id == id ) then
				removed = true
				releaseIcon(group, i)
			end
		end
		
		if( removed ) then
			-- Reposition everything
			repositionTimers(group)
			removedTimer = true
		end
	end
	
	return removedTimer
end

function Icons:ReloadVisual()
	for name, data in pairs(Afflicted.db.profile.anchors) do
		-- Had a bad anchor that was either enabled recently, or it used to be a bar anchor
		if( data.enabled and data.display == "icons" and not Icons.groups[name] ) then
			Icons.groups[name] = savedGroups[name] or Icons:CreateDisplay(name)
			savedGroups[name] = nil
		
		-- Had a bar anchor that was either disabled recently, or it's not an icon anchor anymore
		elseif( ( not data.enabled or data.display ~= "icons" ) and Icons.groups[name] ) then
			savedGroups[name] = Icons.groups[name]
			
			Icons:ClearTimers(name)
			Icons.groups[name]:SetAlpha(0)
			Icons.groups[name]:EnableMouse(false)
			Icons.groups[name] = nil
		end
	end

	-- Update anchors and icons inside
	for name, group in pairs(Icons.groups) do
		local data = Afflicted.db.profile.anchors[name]
		
		-- Update group scale
		group:SetScale(data.scale)
		
		for _, icon in pairs(group.active) do
			icon:SetScale(data.scale)
		end

		-- Annnd make sure it's shown or hidden
		if( Afflicted.db.profile.showAnchors ) then
			group:SetAlpha(1)
			group:EnableMouse(true)
		else
			group:SetAlpha(0)
			group:EnableMouse(false)
		end
		
		-- Reposition
		OnShow(group)
	end
end


-- We delay this until PEW to fix UIScale issues
function Icons:PLAYER_ENTERING_WORLD()
	if( Icons.groups ) then
		for _, group in pairs(Icons.groups) do
			OnShow(group)
		end
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
