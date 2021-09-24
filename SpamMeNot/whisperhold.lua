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

local WhisperHold = {}

local whisperTimeout = 30	-- seconds

function WhisperHold:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	self.whispers = {}		
	return o
end

function WhisperHold:Add(id, sender, text)
	local w = SpamMeNot.Whisper:New(id, sender, text)
	table.insert(self.whispers, w)
	SpamMeNot.players:GetPlayer(sender):WhoLookUp()
	SpamMeNot:DebugMsg(string.format("Added id %d from %s to hold.", id, sender))
end

function WhisperHold:ClearMsgsFromPlayer(playerName)
	for i=1,#self.whispers do
		if self.whispers[i].sender == playerName then			
			table.remove(self.whispers, i)
			i = i -1
		end
	end
end

function WhisperHold:PlayerHasQueuedMsg(playerName)
	local res = false
	for i=1,#self.whispers do
		if self.whispers[i].sender == playerName then
		res = true
		end
	end
	return res
end

function WhisperHold:Pulse()	
	--SpamMeNot:DebugMsg("WhisperHold:Pulse()")
	
	-- We only want to ask for the who information for the first message, and then
	-- pass on any other messages from the same player or we risk getting the who back
	-- in a later message, meaning the first may still
	-- be queued while the ones that arrived behind it are released first, in the wrong
	-- order.
	
	local whoRequested = {} 
	
	
	local i = 1
	--for x=1,#self.whispers do
	while (i <= #self.whispers) do
		SpamMeNot:DebugMsg(string.format("Top: %d / %d", i, #self.whispers))
		SpamMeNot:DebugMsg("(" .. self.whispers[i].text .. ")")
		SpamMeNot:DebugMsg(string.format("WhisperHold:Pulse() checking on id %d from %s", self.whispers[i].id, self.whispers[i].sender))
		
		local remove = false
		
		-- First check to see if the player has been allowed through
		local player = SpamMeNot.players:GetPlayer(self.whispers[i].sender)
		
		
		if player:IsWhiteListed() then
			self:AllowWhisper(i)
			remove = true			
		elseif player:IsWhoOK() and not whoRequested[player.name] then
			if player:GetLevel() > SpamMeNot:GetFilterLevel() then				
				self:AllowWhisper(i)
				remove = true
			else
				self:RejectWhisper(i)
				remove = true
			end					
		-- Otherwise check if we've timed out
		elseif self.whispers[i].time + whisperTimeout < GetTime() then
			self:TimeoutWhisper(i)			
			remove = true
		else
			-- Try a who	
			if not whoRequested[player.name] then		
				player:WhoLookUp()
				whoRequested[player.name] = true
			end
		end	
		
		if remove then
			SpamMeNot:DebugMsg("Deleted item " .. i)
			table.remove(self.whispers, i)									
		else
			i = i +1
		end
	end
end

function WhisperHold:AllowWhisper(index)	
	SpamMeNot:DebugMsg(string.format("WhisperHold allowing id %d from %s.", self.whispers[index].id, self.whispers[index].sender))
	SpamMeNot:FakeIncomingWhisper(self.whispers[index].sender, self.whispers[index].id, self.whispers[index].text)
end

function WhisperHold:RejectWhisper(index)
	SpamMeNot:DebugMsg(string.format("WhisperHold rejecting id %d from %s.", self.whispers[index].id, self.whispers[index].sender))
	local player = SpamMeNot.players:GetPlayer(self.whispers[index].sender)
	if player then
		player:InformLevelBlock()
	end
end

function WhisperHold:TimeoutWhisper(i)
	SpamMeNot:DebugMsg(string.format("WhisperHold timing out id %d from %s.", self.whispers[i].id, self.whispers[i].sender))
end

SpamMeNot.WhisperHold = WhisperHold