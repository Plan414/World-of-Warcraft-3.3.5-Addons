--[[ 		     SLDataText Module: Clock 				]]
--[[ Author: Taffu, Updated by Suicidal Katt  RevDate: 10/15/2012  Version: 5.0.3 ]]

-- Added additional toggle for "Custom Time Format", previously the custom string was only used if realmTime was not used.
-- Added additional toggle for "Military Time" and added support for the db value 'format24'.
-- Fix: Custom Time formatting will use class colors if used and will lowercase the am/pm for any instance of %p throughout the string.
-- Fix: 'hourCorrect' will now work on any instance of %H or %I throughout the string.
-- Fix: Realm Time will now toggle between local and realm time for both custom strings and default formatting.
-- Added 'getLocalTime()' function to allow formatted text for local time.
-- Alteration: Options ordering has changed, see table below as well as the default value for the 'timeString'.
-- Note: A lot of my code could probably be shrunken down but I feel like this change is a pretty large one. Some additional localizations are needed.


local SLDT, MODNAME = SLDataText, "Clock"
if ( SLDT ) then SLDT.Clock = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local rCol, gCol = RED_FONT_COLOR_CODE, GREEN_FONT_COLOR_CODE
local locTime, rlmTime
local function getGameTime()
    local serTime, serAMPM
    local hour, minu = GetGameTime()
	if ( minu < 10 ) then minu = string.format("0%i", minu) end 
    if ( db.format24 ) then
        serAMPM = ""; serTime = string.format("%s:%s", hour, minu)
    else
        if ( hour > 11 ) then serAMPM = "pm" else serAMPM = "am" end
        if ( hour == 0 ) then hour = hour + 12 elseif hour > 12 then hour = hour - 12 end
        serTime = string.format("%s:%s", hour, minu)
    end
    return serTime, serAMPM
end

local function getLocalTime()
    local serTime, serAMPM
    local hour, minu = tonumber(date("%H")),tonumber(date("%M"))
	if ( minu < 10 ) then minu = string.format("0%i", minu) end 
    if ( db.format24 ) then
        serAMPM = ""; serTime = string.format("%s:%s", hour, minu)
    else
        if ( hour > 11 ) then serAMPM = "pm" else serAMPM = "am" end
        if ( hour == 0 ) then hour = hour + 12 elseif hour > 12 then hour = hour - 12 end
        serTime = string.format("%s:%s", hour, minu)
    end
    return serTime, serAMPM
end

local function formatTimer(wait, long)
	local timestring
	local h, m, s = 0, 0, 0
	if ( wait >= 3600 ) then
		h = floor(wait / 3600); wait = wait - (h * 3600)
		m = floor(wait / 60); wait = wait - (m * 60)
		s = floor(wait)
		
		if ( m < 10 ) then m = string.format("%d%d", 0, m) end
		if ( s < 10 ) then s = string.format("%d%d", 0, s) end
		
		if ( long ) then
			timestring = string.format("%s hours", h)
		else
			timestring = string.format("%s:%s:%s", h, m, s)
		end
	elseif ( wait >= 60 and wait < 3600 ) then
		m = floor(wait / 60); wait = wait - (m * 60)
		s = floor(wait)
		
		if ( s < 10 ) then s = string.format("%d%d", 0, s) end
		
		if ( long ) then
			timestring = string.format("%s min %s sec", m, s)
		else
			timestring = string.format("%s:%s", m, s)
		end
	elseif ( wait < 60 ) then
		s = floor(wait)
		
		if ( long ) then
			timestring = string.format("%s sec", s)
		else
			timestring = string.format("%s", s)
		end
	end
	
	return timestring
end

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		GameTooltip:SetOwner(this, db.aF)
		GameTooltip:AddLine(string.format("|cffffffff%s %i, %i|r", date("%B"), date("%d"), date("%Y")))
		GameTooltip:AddDoubleLine("Realm Time", string.format("%s%s", select(1, getGameTime()), select(2, getGameTime())), 1,1,0,1,1,1)
		local hr, mi, mer = date("%I"), date("%M"), string.lower(date("%p"))
		GameTooltip:AddDoubleLine("Local Time", string.format("%i:%s%s", hr, mi, mer), 1,1,0,1,1,1)
		GameTooltip:AddLine(" ")
		
		if ( db.showPVP ) then
			local inQueue = nil
			for i = 1, 2 do
				local id, name, active, canQ, wait, _ = GetWorldPVPAreaInfo(i)
				if ( active ) then
					name = string.format("%s%s (A)|r", rCol, name)
				elseif ( canQ ) then
					name = string.format("%s%s (Q)|r", gCol, name)
				end
				GameTooltip:AddDoubleLine(name, formatTimer(wait))
			end
			
			for j = 1, MAX_WORLD_PVP_QUEUES do
				local status, map = GetWorldPVPQueueStatus(j)
				if ( status == "queued" ) then inQueue = {}; table.insert(inQueue, map) end
			end
			
			if ( inQueue ~= nil ) then
				local maps = ""
				for k, v in pairs(inQueue) do
					maps = string.format("%s %s", maps, v)
				end
				GameTooltip:AddLine(string.format("%s %s", L["Queued for:"], maps))
			end
			
			GameTooltip:AddLine(" ")
		end
		
		GameTooltip:AddDoubleLine(L["Left-Click"], L["Toggle Calendar"], 1,1,0,1,1,1)
		GameTooltip:AddDoubleLine(L["Right-Click"], L["Toggle Time Manager"], 1,1,0,1,1,1)
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this)
		if ( GameTooltip:IsShown() ) then GameTooltip:Hide() end
	end)
	tool:SetScript("OnMouseDown", function(self, button)
		if ( button == "LeftButton" ) then 
			ToggleCalendar()
		elseif ( button == "RightButton" ) then
			ToggleTimeManager()
		end
	end)
end

function SLDT.Clock:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		frame:SetScript("OnUpdate", function(_, elapsed)
			self:Refresh()
		end)
	end
end

function SLDT.Clock:Disable()
	if ( not db.enabled ) then
		frame:SetScript("OnUpdate", nil)
	end
	self:Refresh()
end

function SLDT.Clock:Refresh()
	if ( db.enabled or SLDT.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		if ( TimeManagerClockButton:IsShown() ) then TimeManagerClockButton:Hide() end
		
		if db.customString then
			local timeString = db.timeString
			local hr12String,hr24String,amString
			local hour,mns = GetGameTime()
			-- Coding for this was found in the UIParent.lua beginning with the function on line 3854 'BetterDate'.
			local function amFind()
				if db.realmTime then
					if ( hour > 11 ) then return "pm" else return "am" end
				else
					return strlower(tostring(date("%p")))
				end	
			end
			amString = string.format("|cff%s%s|r", SLDT.db.profile.cCol and SLDT.classColor or "ffffff", amFind())
			timeString = gsub(timeString, "^%%p", amString)
			timeString = gsub(timeString, "([^%%])%%p", "%1"..amString); -- Fix any other within the string.
			
			local hour12
			if ( hour == 0 ) then 
				hour12 = hour + 12 
			elseif hour > 12 then 
				hour12 = hour - 12 
			else
				hour12 = hour
			end
						
			if db.hourCorrect then
				if db.realmTime then
					if strfind(tostring(hour12),0) == 1 then -- If first character is a 0 then replace 0 with ""
						hr12String = gsub(tostring(hour12), 0, "", 1)
					else
						hr12String = hour12
					end
					if strfind(tostring(hour),0) == 1 then
						hr24String = gsub(tostring(hour), 0, "", 1)
					else
						hr24String = hour
					end
				else
					if strfind(tostring(date("%I")),0) == 1 then 
						hr12String = gsub(tostring(date("%I")), 0, "", 1)
					else
						hr12String = date("%I")
					end
					if strfind(tostring(date("%H")),0) == 1 then
						hr24String = gsub(tostring(date("%H")), 0, "", 1)
					else
						hr24String = date("%H")
					end
				end
			else
				if db.realmTime then
					hr12String = hour12
					hr24String = hour
				else
					hr12String = date("%I")
					hr24String = date("%H")
				end
			end
			timeString = gsub(timeString, "^%%I", hr12String)
			timeString = gsub(timeString, "([^%%])%%I", "%1"..hr12String);
			
			timeString = gsub(timeString, "^%%H", hr24String)
			timeString = gsub(timeString, "([^%%])%%H", "%1"..hr24String);
			
			text:SetText(date(timeString))
		else
			rlmTime = string.format("%s|cff%s%s|r", select(1, getGameTime()), SLDT.db.profile.cCol and SLDT.classColor or "ffffff", select(2, getGameTime()))
			locTime = string.format("%s|cff%s%s|r", select(1, getLocalTime()), SLDT.db.profile.cCol and SLDT.classColor or "ffffff", select(2, getLocalTime()))
			if db.realmTime and rlmTime then
				text:SetText(rlmTime)
			elseif not db.realmTime and locTime then
				text:SetText(locTime)
			end
		end
		
        local invites = CalendarGetNumPendingInvites()
		if ( invites > 0 ) then SLDT:Pulse(self, true) else SLDT:Pulse(self, false) end
		
		if ( not self.Moving) then SLDT:UpdateBaseFrame(self, db) end
	else
		if ( not TimeManagerClockButton:IsShown() ) then TimeManagerClockButton:Show() end
		if ( frame:IsShown() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Clock.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "toggle", [2] = L["PvP Info"], [3] = "showPVP" },
	[7] = { [1] = "toggle", [2] = L["CorrHour"], [3] = "hourCorrect" },	
	[8] = { [1] = "toggle", [2] = "Custom Time Format", [3] = "customString" }, -- Needs localization
	[9] = { [1] = "desc", [2] = L["ClockDesc"], [3] = L["ClockDesc"] },
	[10] = { [1] = "text", [2] = L["Time String"], [3] = "timeString" },	
	[11] = { [1] = "toggle", [2] = L["Realm Time"], [3] = "realmTime" },
	[12] = { [1] = "toggle", [2] = "Military Time", [3] = "format24" }, -- Needs localization
	[13] = { [1] = "toggle", [2] = L["PvP Info"], [3] = "showPVP" },	
	[14] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[15] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[16] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[17] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[18] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[19] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[20] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[21] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Clock.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Clock.db:RegisterDefaults({
        profile = {
			name = "Clock",
			enabled = true,
			forceShow = true,
			aP = "CENTER",
			anch = "Minimap",
			aF = "BOTTOM",
			xOff = 0,
			yOff = -10,
			strata = "MEDIUM",
			gfont = false,			
			fontSize = 12,
			font = "Arial Narrow",
			outline = false,
			tooltipOn = true,
			showPVP = true,
			hourCorrect = true,
			realmTime = false,
			customString = false,
			timeString = "%a, %b, %d %I:%M %p",			
        },
    })
	db = SLDT.Clock.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Clock)
	SetupToolTip()
	
	SLDT.Clock:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Clock:Enable()
end

SLDT.Clock:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Clock:SetScript("OnEvent", OnInit)

--[[ WORKING TIME ESCAPES
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
]]