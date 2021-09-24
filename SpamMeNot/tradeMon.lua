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

--[[ 
	Trade is often a special place for special people and needs special treatment.  The idea
	of this object is that it maintains a running total of weights.  The total is decremented
	by the a timed pulse.  If there's a surge is spammy messages like "ANAL [Reckoning]" or
	whatever or lots of [Dirge] links or stupid skill links then it should trigger SpamMeNot
	to start kicking some ass.
]]

local max_history = 50
local pulse_weight = 2

local TradeMon = {}

function TradeMon:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.history = {}
	self.currentWeight = 0
	return o
end

function TradeMon:AddHistory(sender, id, text)
	local isSpam = false
	if not self:AlreadyAdded(sender, id, text) then
		SpamMeNot:DebugMsg(string.format("TradeMon:AddHistory(%s, %d, \"%s\")", sender, id, text))
		local e = SpamMeNot.TradeHistory:New(sender, id, text)
		table.insert(self.history, e)
						
		self:AddWeight(e:GetWeight())
			
		-- If we have more than max_history
		if #self.history > max_history then
			-- remove the first one in FIFO fashion
			table.remove(self.history, 1)
		end
		
		if self:GetCurrentWeight() >= SpamMeNot:GetBlockScore() and e:GetWeight() > 0 then
			isSpam = true
		end		
	end
	return isSpam
end

function TradeMon:AlreadyAdded(sender, id, text)
	local res = false
	for i=1,#self.history do
		if (self.history[i].sender == sender) and (self.history[i].id == id) and (self.history[i].text == text) then
			res = true
		end
	end
	return res
end

function TradeMon:Pulse()
	if (self:GetCurrentWeight() >= SpamMeNot:GetBlockScore()) then
		-- Lets start ignoring some trade spammers
		for i=1,#self.history do
			if self.history[i]:GetWeight() > 0 then
				self.history[i]:FlagAsSpam()
			end
		end
	end

	if (self:GetCurrentWeight() >= SpamMeNot:GetReportScore()) and SpamMeNot:IsAutoReporting() then
		SpamMeNot:DebugMsg("Time for the trade monitor to kick some ass.")
		-- We'll start from the top of our history and report anyone with a TRADE rating > 0
		while #self.history > 0 do
			if self.history[1]:GetWeight() > 0 then
				self.history[1]:Report()
			end
			table.remove(self.history, 1)
		end
	end
	self:SubtractWeight(pulse_weight)
	
	-- If enough time has passed that the trade rating has dropped right to 0
	-- then remove the history because it's no longer current.
	if self:GetCurrentWeight() == 0 then
		self.history = {}
	end
end

function TradeMon:AddWeight(weight)
	local oldWeight = self.currentWeight

	self.currentWeight = self.currentWeight + weight
	-- Make sure it doesn't rocket too high or it'll take hours to come back down
	if self.currentWeight > (SpamMeNot:GetReportScore() + 30) then
		self.currentWeight = SpamMeNot:GetReportScore() + 30
	end
	
	if oldWeight ~= self.currentWeight then
		SpamMeNot:DebugMsg("TradeMon weight: " .. self.currentWeight)
	end
end

function TradeMon:SubtractWeight(weight)
	local oldWeight = self.currentWeight

	self.currentWeight = self.currentWeight - weight
	if self.currentWeight < 0 then
		self.currentWeight = 0
	end

	if oldWeight ~= self.currentWeight then
		SpamMeNot:DebugMsg("TradeMon weight: " .. self.currentWeight)
	end

end

function TradeMon:GetCurrentWeight()
	return self.currentWeight
end

SpamMeNot.TradeMon = TradeMon