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

local max_history = 3
local max_spammerEvidence = 8 

local L = LibStub("AceLocale-3.0"):GetLocale("SpamMeNot")

local Player = {}

-- Standard Constructor
function Player:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

-- More useful constructor
function Player:New(playerName)
	local o = self:new()
	
	o.name = playerName
	o.evidence = {}
	o.isSpammer = false
	o.reported = false
	o.rating = 0
	o.isWhoOK = false
	o.level = 0
	o.isInformedSpamBlock = false
	o.isInformedLevelBlock = false	
	return o
end

function Player:GetLink()
	return string.format("|cffff5555|HSpamMeNot:%s|h[%s]|h|r", self:GetName(), self:GetName())
end

function Player:IsCrossServerPlayer()
	if (string.find(self.name, "-") ~= nil) then		
		return true
	else
		return false
	end	
end

function Player:IsWhiteListed()
	local res = false;
	
	res = res or self:IsSelf()
	res = res or self:IsFriend()
	res = res or self:IsGroupMember()
	res = res or self:IsRaidMember()
	res = res or self:IsGuildMember()
	res = res or self:IsCrossServerPlayer()
		
	return res
end

function Player:IsSelf()
	local res = false
	
	if self.name == UnitName("player") then
		res = true
	end
	return res
end

function Player:IsGroupMember()
	for i=1,GetNumPartyMembers() do
		local unitName = UnitName("party"..i, true)  
		if (self.name == unitName) then
			return true			
		end
	end
	return false
end

function Player:IsRaidMember()
	for i=1,GetNumRaidMembers() do
		local raidName = GetRaidRosterInfo(i);
		if (raidName == self.name) then
			return true
		end
	end	
	return false
end

function Player:IsFriend()
	local friend = false
	for i=1,GetNumFriends() do
		local lookup = GetFriendInfo(i);
		if (lookup == self.name) then
			friend = true			
			break
		end
	end
	return friend
end

function Player:IsGuildMember()	
	local guildie = false
	if (IsInGuild()) then	
		for i=1,GetNumGuildMembers(true) do
			lookup = GetGuildRosterInfo(i);
			if (lookup == self.name) then
				guildie = true
			end		
		end	
	end
	return guildie	
end

function Player:IsSpammer()
	return self.isSpammer
end

function Player:WhoLookUp()	
	local data = SpamMeNot.who:Lookup(self.name)
	if data then
		self.class = data.class
		self.level = data.level or 0
		self.race = data.race
		self.guild = data.guild
		self.zone = data.zone		
		self.isWhoOK = true
	end
end

function Player:IsWhoOK()
	return self.isWhoOK
end

function Player:IsLevelAllowed()
	return self:GetLevel() > SpamMeNot:GetFilterLevel()
end

function Player:HasMsgInHold()
	return SpamMeNot.whisperHold:PlayerHasQueuedMsg(self.name)
end

function Player:GetLevel()
	return self.level
end

function Player:FlagAsSpammer()
	local alreadyFlagged = self.isSpammer
	self.isSpammer = true	
	-- Clear whisper hold for this spammer
	SpamMeNot.whisperHold:ClearMsgsFromPlayer(self.name)
	
	if not SpamMeNot:IsSilent() and not alreadyFlagged then
		SpamMeNot:Print(string.format(L["%s blocked with a rating of %d."], self:GetLink(), self:GetRating()))
	end
end

function Player:UnflagAsSpammer()
	self.isSpammer = false
	self.evidence = {}
end

function Player:GetName()
	return self.name
end

function Player:GetRating()
	return self.rating
end

function Player:AddEvidence(id, text)	
	SpamMeNot:DebugMsg(string.format("Player:AddEvidence(%d, \"%s\")", id, text))
	local e = SpamMeNot.Evidence:New(id, text)
	table.insert(self.evidence, e)
	
	local max_evidence = max_history
	if self:IsSpammer() then
		-- Let them dig their own grave so they're more likely to get auto-reported
		max_evidence = max_spammerEvidence
	end
	
	-- If we have more than max_history
	if #self.evidence > max_evidence then
		-- remove the first one in FIFO fashion
		table.remove(self.evidence, 1)
	end	
	self.rating = SpamMeNot.analyzer:RateMessage(self:GetEvidenceAsString())
end

function Player:HasEvidence(id, text)
	local res = false
	for i=1,#self.evidence do
		if (id == self.evidence[i].id) and (text == self.evidence[i].text) then
			res = true
			break
		end
	end
	return res
end

function Player:GetEvidenceAsString()
	local s = ""	
	for i=1,#self.evidence do
		if i > 1 then
			s = s .. " "
		end
		s = s .. self.evidence[i].text
	end
	return s
end

function Player:IsRepeatingText(text)
	local result = false;
	
	if SpamMeNot:IsBlockingRepeatedText() then
	
		for i=1,#self.evidence do
			if text == self.evidence[i].text then
				if time() -  self.evidence[i].timestamp < 10 then
					result = true
					SpamMeNot:DebugMsg("Stopped repeating text: " .. text .. " from " .. self.name)
					break
				end
			end
		end
	end
	return result
end

function Player:Report()
	if not self.reported then
		if not SpamMeNot:IsSilent() then
			SpamMeNot:Print(string.format(L["Reporting %s."], self:GetLink()))
		end				
	
		for i=1,#self.evidence do
			self.evidence[i]:Report()
		end		
		self.reported = true		
	end		
end

function Player:InformSpamBlock()
	if not self:IsInformedSpamBlock() then
		SendChatMessage(SpamMeNot.db.profile.msgSpamBlocked, "WHISPER", nil, self:GetName())
		self.isInformedSpamBlock = true
	end
end

function Player:InformLevelBlock()
	if not self:IsInformedLevelBlock() then		
		SendChatMessage(SpamMeNot.db.profile.msgLevelBlocked, "WHISPER", nil, self:GetName())
		self.isInformedLevelBlock = true
	end
end

function Player:IsInformedSpamBlock()
	return self.isInformedSpamBlock
end

function Player:IsInformedLevelBlock()
	return self.isInformedLevelBlock
end
	
function Player:IsReported()
	return self.reported
end

SpamMeNot.Player = Player