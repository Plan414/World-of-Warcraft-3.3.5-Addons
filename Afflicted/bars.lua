if( not Afflicted ) then return end

local Bars = Afflicted:NewModule("Bars", "AceEvent-3.0")
local methods = {"CreateDisplay", "ClearTimers", "CreateTimer", "RemoveTimerByID", "ReloadVisual", "UnitDied"}
local SML = LibStub:GetLibrary("LibSharedMedia-3.0")
local GTBLib = LibStub:GetLibrary("GTB-1.0")
local barData, savedGroups = {}, {}

function Bars:OnInitialize()
	SML.RegisterCallback(Bars, "LibSharedMedia_Registered", "MediaRegistered")
	SML:Register(SML.MediaType.STATUSBAR, "BantoBar", "Interface\\Addons\\Afflicted\\images\\banto")
	SML:Register(SML.MediaType.STATUSBAR, "Smooth",   "Interface\\Addons\\Afflicted\\images\\smooth")
	SML:Register(SML.MediaType.STATUSBAR, "Perl",     "Interface\\Addons\\Afflicted\\images\\perl")
	SML:Register(SML.MediaType.STATUSBAR, "Glaze",    "Interface\\Addons\\Afflicted\\images\\glaze")
	SML:Register(SML.MediaType.STATUSBAR, "Charcoal", "Interface\\Addons\\Afflicted\\images\\Charcoal")
	SML:Register(SML.MediaType.STATUSBAR, "Otravi",   "Interface\\Addons\\Afflicted\\images\\otravi")
	SML:Register(SML.MediaType.STATUSBAR, "Striped",  "Interface\\Addons\\Afflicted\\images\\striped")
	SML:Register(SML.MediaType.STATUSBAR, "LiteStep", "Interface\\Addons\\Afflicted\\images\\LiteStep")
end

-- PUBLIC METHODS
local total = 0
function Bars:CreateDisplay(type)
	local anchorData = Afflicted.db.profile.anchors[type]
	local group = GTBLib:RegisterGroup(string.format("Afflicted (%s)", anchorData.text), SML:Fetch(SML.MediaType.STATUSBAR, Afflicted.db.profile.barName))
	group:SetGroupID(type)
	group:RegisterOnFade(Bars, "OnFade")
	group:RegisterOnMove(Bars, "OnMove")
	group:SetScale(anchorData.scale)
	group:SetWidth(Afflicted.db.profile.barWidth)
	group:SetAnchorVisible(Afflicted.db.profile.showAnchors)
	group:SetDisplayGroup(anchorData.redirect ~= "" and anchorData.redirect or nil)
	group:SetBarGrowth(anchorData.growUp and "UP" or "DOWN")
	group:SetMaxBars(anchorData.maxRows)
	group:SetFont(SML:Fetch(SML.MediaType.FONT, Afflicted.db.profile.fontName), Afflicted.db.profile.fontSize)
	group:SetFadeTime(anchorData.fadeTime)
	group:SetIconPosition(anchorData.icon or "LEFT")

	if( anchorData.position ) then
		group:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", anchorData.position.x, anchorData.position.y)
	else
		total = total + 1
		group:SetPoint("CENTER", UIParent, "CENTER", 0, total * 20)
	end

	return group
end

function Bars:OnMove(parent, x, y)
	if( not Afflicted.db.profile.anchors[parent.groupID].position ) then
		Afflicted.db.profile.anchors[parent.groupID].position = {}
	end

	Afflicted.db.profile.anchors[parent.groupID].position.x = x
	Afflicted.db.profile.anchors[parent.groupID].position.y = y
end

function Bars:MediaRegistered(event, mediaType, key)
	if( mediaType == SML.MediaType.STATUSBAR and Afflicted.db.profile.barName == key ) then
		for id, group in pairs(Bars.groups) do
			group:SetTexture(SML:Fetch(SML.MediaType.STATUSBAR, Afflicted.db.profile.barName))
		end
	elseif( mediaType == SML.MediaType.FONT and Afflicted.db.profile.fontName == key ) then
		for id, group in pairs(Bars.groups) do
			group:SetFont(SML:Fetch(SML.MediaType.FONT, Afflicted.db.profile.fontName), Afflicted.db.profile.fontSize)
		end
	end
end

-- Return an object to access our visual style
function Bars:LoadVisual()
	local obj = {}
	for _, func in pairs(methods) do
		obj[func] = self[func]
	end
	
	-- Create anchors
	Bars.groups = {}
	for name, data in pairs(Afflicted.db.profile.anchors) do
		if( data.enabled and data.display == "bars" ) then
			Bars.groups[name] = self:CreateDisplay(name)
		end
	end
	
	return obj
end

-- Clear all running timers for this anchor type
function Bars:ClearTimers(type)
	if( Bars.groups[type] ) then
		Bars.groups[type]:UnregisterAllBars()
	end
end

-- Unit died, removed their timers
function Bars:UnitDied(guid)
	local offset = string.len(guid)
	for id in pairs(barData) do
		if( string.sub(id, 0, offset) == guid ) then
			for _, group in pairs(Bars.groups) do
				group:UnregisterBar(id)
			end
		end
	end
end

-- Create a new timer
function Bars:CreateTimer(sourceGUID, sourceName, anchor, repeating, isCooldown, duration, spellID, spellName, spellIcon)
	local group = Bars.groups[anchor]
	if( not group ) then
		return
	end	
	
	local id = sourceGUID .. spellID .. (isCooldown and "CD" or "")
	barData[id] = string.format("%s,%s,%s,%s", sourceGUID, sourceName, spellID, spellName) .. (isCooldown and ",CD" or "")

	-- It's a cooldown, but it's not shown in the cooldown anchor so prefix [CD] to it
	local cd = ""
	if( isCooldown and ( anchor ~= "cooldowns" or Afflicted.db.profile.anchors[anchor].redirect ~= "" ) ) then
		cd = "[CD] "
	end

	local text
	if( sourceName == "" ) then
		text = string.format("%s%s", cd, spellName)
	elseif( Afflicted.db.profile.barNameOnly ) then
		text = string.format("%s%s", cd, Afflicted:StripServer(sourceName))
	else
		text = string.format("%s%s - %s", cd, spellName, Afflicted:StripServer(sourceName))
	end

	group:RegisterBar(id, text, duration, nil, spellIcon)
	group:SetRepeatingTimer(id, repeating or false)
end

-- Bar timer ran out
function Bars:OnFade(barID)
	if( not barData[barID] ) then return end
	local sourceGUID, sourceName, spellID, spellName, timerType = string.split(",", barData[barID])
	barData[barID] = nil
	
	spellID = tonumber(spellID)
	
	Afflicted:AbilityEnded(sourceGUID, sourceName, Afflicted:GetSpell(spellID, spellName), spellID, spellName, timerType == "CD")
end

-- Remove a timer by the ID, totems basically
function Bars:RemoveTimerByID(id)
	local removedTimer
	for _, group in pairs(Bars.groups) do
		local removed = group:UnregisterBar(id)
		if( removed ) then
			removedTimer = true
		end
	end
	
	return removedTimer
end

-- Reload visual data
function Bars:ReloadVisual()
	for name, data in pairs(Afflicted.db.profile.anchors) do
		-- Had a bad anchor that was either enabled recently, or it used to be an icon anchor
		if( not Bars.groups[name] and data.display == "bars" and ( data.enabled or data.redirect ~= "" ) ) then
			Bars.groups[name] = savedGroups[name] or Bars:CreateDisplay(name)
			savedGroups[name] = nil
		
		-- Had a bar anchor that was either disabled recently, or it's not a bar anchor anymore
		elseif( Bars.groups[name] and ( data.display ~= "bars" or ( not data.enabled and data.redirect == "" ) ) ) then
			savedGroups[name] = Bars.groups[name]
			
			Bars.groups[name]:SetAnchorVisible(false)
			Bars.groups[name]:UnregisterAllBars()
			Bars.groups[name] = nil
		end
	end

	-- Update!
	for key, group in pairs(Bars.groups) do
		local data = Afflicted.db.profile.anchors[group.groupID]
		if( data ) then
			group:SetScale(data.scale)
			group:SetDisplayGroup(data.redirect ~= "" and data.redirect or nil)
			group:SetBarGrowth(data.growUp and "UP" or "DOWN")
			group:SetAnchorVisible(Afflicted.db.profile.showAnchors)
			group:SetWidth(Afflicted.db.profile.barWidth)
			group:SetFont(SML:Fetch(SML.MediaType.FONT, Afflicted.db.profile.fontName), Afflicted.db.profile.fontSize)
			group:SetTexture(SML:Fetch(SML.MediaType.STATUSBAR, Afflicted.db.profile.barName))
			group:SetMaxBars(data.maxRows)
			group:SetFadeTime(data.fadeTime)
			group:SetIconPosition(data.icon)
		else
			savedGroups[key] = nil

			Bars.groups[key]:SetAnchorVisible(false)
			Bars.groups[key]:UnregisterAllBars()
			Bars.groups[key] = nil
		end
	end
end