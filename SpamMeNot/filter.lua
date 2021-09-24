--[[    
    SpamMeNot: Detects and blocks commercial spam
    Copyright (C) 2008 Robert Stiles (robs@codexsoftware.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local Filter = {}

function Filter:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.enabled = true
	return o
end

function Filter:Enable()
	self.enabled = true
end

function Filter:Disable()
	self.enabled = false
end

function Filter:IsEnabled()
	return self.enabled
end

function Filter:FilterEvent(e, ...)
	local eventString = e
		
	filtered = false
	
	if SpamMeNot:IsEnabled() and self:IsEnabled() then
		if e then
			if self[eventString] then
				filtered = self[eventString](self, e, ...)
			end	
		end
	end
		
	return filtered
end

function Filter:CHAT_MSG_SAY(...)
	--[[
		arg1:	chat message
		arg2:	author
		arg3:	language
		arg11:	lineID
	]]
	
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local lineID = select(12, ...)
		
	local filtered = false
	local player = SpamMeNot.players:GetPlayer(author)
	
	if not player:IsWhiteListed() then
		if player:IsSpammer() then
			filtered = true
		else
			-- Combine this new message with the gathered
			-- evidence and see how it rates.
			local s = player:GetEvidenceAsString()
			--SpamMeNot:DebugMsg("GetEvidenceAsString returned " .. s)
			if not player:HasEvidence(lineID, msg) then
				if string.len(s) > 0 then
					s = s .. " "
				end
				s = s .. msg
			end
			if SpamMeNot.analyzer:RateMessage(s) >= SpamMeNot:GetBlockScore() then
				filtered = true
			end
			
			if player:IsRepeatingText(msg) then
				filtered = true
			end
		end
	end
	
	return filtered
end

function Filter:CHAT_MSG_YELL(...)
	--[[
		arg1:	chat message
		arg2:	author
		arg3:	language
		arg11:	lineID
	]]
	-- Same set up as CHAT_MSG_SAY so let's just call that one
	return self:CHAT_MSG_SAY(...)	
end

function Filter:CHAT_MSG_EMOTE(...)
	--[[
		arg1:	chat message
		arg2:	author		
		arg11:	lineID
	]]
	-- Similar set up as CHAT_MSG_SAY so let's just call that one
	
	return self:CHAT_MSG_SAY(...)	
end

function Filter:CHAT_MSG_TEXT_EMOTE(...)
	--[[
		arg1:	chat message
		arg2:	author		
		arg11:	lineID
	]]

	-- Add fall asleep spam detection here
	return false
end

function Filter:CHAT_MSG_CHANNEL(...)
	--[[
		arg1:	chat message 
		arg2:	author 
		arg3:	language 
		arg4:	channel name with number ex: "1. General - Stormwind City" 
				zone is always current zone even if not the same as the 
				channel name 
		arg5:	target 
				second player name when two users are passed for a 
				CHANNEL_NOTICE_USER (E.G. x kicked y) 
		arg6:	AFK/DND/GM "CHAT_FLAG_"..arg6 flags 
		arg7:	zone ID used for generic system channels (1 for General, 
				2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 
				26 for LFG)	not used for custom channels or if you joined 
				an Out-Of-Zone channel ex: "General - Stormwind City" 
		arg8:	channel number 
		arg9:	channel name without number (this is _sometimes_ in lowercase) 
				zone is always current zone even if not the same as the 
				channel name 
		arg11:	spam id
	]]
	
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local status = select(7, ...)
	local zoneID = select(8, ...)
	local lineID = select(12, ...)
	
	local filtered = false
	local player = SpamMeNot.players:GetPlayer(author)
	local channelMonitored = true
	
	if (zoneID == 2) and (not SpamMeNot:IsMonitoringTrade()) then
		channelMonitored = false
	end
	
	if SpamMeNot:IsIgnoringKnownAddOnChannels() then
		local channelName = string.lower(arg9)
		-- Ignore Carbonite Channels
		if string.find(channelName, "crb") == 1 then
			--SpamMeNot:DebugMsg("Ignoring Carbonite channel " .. channelName)
			channelMonitored = false
		end
		-- Ignore FlagRSP Addons
		if channelName == "xtensionxtooltip2" then
			--SpamMeNot:DebugMsg("Ignoring FlagRSP channel " .. channelName)
			channelMonitored = false
		end
	end
	
	if not player:IsWhiteListed() and status ~= "GM" then
		if player:IsSpammer() then
			filtered = true
		elseif channelMonitored == true then
			-- Combine this new message with the gathered
			-- evidence and see how it rates.
			local s = player:GetEvidenceAsString()			
			if not player:HasEvidence(lineID, msg) then
				if string.len(s) > 0 then
					s = s .. " "
				end
				s = s .. msg
			end
			if SpamMeNot.analyzer:RateMessage(s) >= SpamMeNot:GetBlockScore() then
				filtered = true						
			elseif zoneID == 2 then
				if SpamMeNot.tradeMon:AddHistory(author, lineID, msg) then
					SpamMeNot:DebugMsg("Filtering trade message " .. s)
					filtered = true
				end			
			end	
 			if player:IsRepeatingText(msg) then
				filtered = true
			end										
		end
	end
	
	return filtered	
	
end

function Filter:CHAT_MSG_SYSTEM(...)
	--[[
		arg1:	The content of the chat message. 
		
		arg1 formats are found in Blizzard's GlobalStrings.lua. Some 
		possibilities: 

		ERR_LEARN_RECIPE_S (eg. "You have learned how to create a new item: Bristle Whisker Catfish.") 
		MARKED_AFK_MESSAGE (eg. "You are now AFK: Away from Keyboard") 	
	]]
	
	local event = select(1, ...)
	local msg = select(2, ...)
	local filtered = false

	-- If SpamMeNot is in silent mode and we're auto reporting then filter
	-- spam report confirmations
	
	if (string.find(msg, COMPLAINT_ADDED)) and (SpamMeNot:IsSilent()) and (SpamMeNot:IsAutoReporting()) then
		filtered = true
	end		
	return filtered	
end

function Filter:CHAT_MSG_AFK(...)
	return self:CHAT_MSG_DND(...)
end

function Filter:CHAT_MSG_DND(...)
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local filtered = false
	local player = SpamMeNot.players:GetPlayer(author)

	if not player:IsWhiteListed() then
		if player:IsSpammer() then
			filtered = true
		elseif player:HasMsgInHold() then
			filtered = true
		elseif not player:IsLevelAllowed() then
			filtered = true
		end
	end
	
	return filtered
	
end

function Filter:CHAT_MSG_WHISPER(...)
	--[[
		arg1:	Message received 
		arg2:	Author 
		arg3:	Language (or nil if universal, like messages from GM) 
				(always seems to be an empty string; argument may have been 
				kicked because whispering in non-standard language doesn't 
				seem to be possible [any more?]) 
		arg6:	status (like "DND" or "GM") 
		arg7:	(number) message id (for reporting spam purposes?) (default: 0) 
		arg8:	(number) unknown (default: 0) 	
		
		
		This definition is from WoW Wiki but to the best of my knowledge
		arg11 is the spam ID
	]]
	
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local status = select(7, ...)
	local lineID = select(12, ...) 
	
	local filtered = false
	local player = SpamMeNot.players:GetPlayer(author)
	
	if not player:IsWhiteListed() and status ~= "GM" then
		if player:IsSpammer() then
			filtered = true
		elseif player:HasMsgInHold() then
			filtered = true
		elseif (not player:IsLevelAllowed()) and (SpamMeNot:IsLevelFiltering()) then
			filtered = true		
		else
			-- Combine this new message with the gathered
			-- evidence and see how it rates.
			local s = player:GetEvidenceAsString()
			--SpamMeNot:DebugMsg("GetEvidenceAsString returned " .. s)
			if not player:HasEvidence(lineID, msg) then
				if string.len(s) > 0 then
					s = s .. " "
				end
				s = s .. msg
			end
			if SpamMeNot.analyzer:RateMessage(s) >= SpamMeNot:GetBlockScore() then				
				filtered = true
			end

			if player:IsRepeatingText(msg) then
				filtered = true
			end			
			
		end
	end	
	
	return filtered		
end

function Filter:CHAT_MSG_WHISPER_INFORM(...)
	--[[
		arg1:	Message sent 
		arg2:	Player who was sent the whisper 
		arg3:	Language  
	]]
	
	-- Filter out SpamMeNot's automated messages
	local filtered = false
	local event = select(1, ...)
	local msg = select(2, ...)
	
	if (msg == SpamMeNot.db.profile.msgSpamBlocked) or (msg == SpamMeNot.db.profile.msgLevelBlocked) then
		filtered = true
	end	
	return filtered
end

SpamMeNot.Filter = Filter