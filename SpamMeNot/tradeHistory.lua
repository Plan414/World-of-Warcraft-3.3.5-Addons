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

local TradeHistory = {}

function TradeHistory:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

function TradeHistory:New(sender, id, text)
	local obj = TradeHistory:new()
	obj.sender = sender
	obj.id = id
	obj.text = text
	obj.reported = false
	obj.weight = SpamMeNot.analyzer:RateTradeMessage(obj.text)
	return obj
end

function TradeHistory:GetWeight()
	return self.weight
end

function TradeHistory:FlagAsSpam()
	SpamMeNot:DebugMsg(string.format("%s is a trade spammer.", self.sender))
	SpamMeNot.spammers:Add(self.sender)	
end

-- Reports the evidence as spam.  Returns true on success.
function TradeHistory:Report()
	if not self:IsReported() then
		SpamMeNot:DebugMsg(string.format("Reporting %s because of trade id %d.", self.sender, self.id))	
		local player = SpamMeNot.players:GetPlayer(self.sender)		
		SpamMeNot.spammers:Add(player)
		player:Report()
		self.reported = true
	end
end

function TradeHistory:IsReported()
	return self.reported
end

SpamMeNot.TradeHistory = TradeHistory