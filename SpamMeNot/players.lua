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

local Players = {}

function Players:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	self.players = {}
	return o
end

function Players:GetPlayer(name)
	local res = nil
	local lwrName = string.lower(name)
	for n,o in pairs(self.players) do		
		if string.lower(n) == lwrName then
			res = o
			break		
		end
	end
	
	if not res then
		-- We don't have an existing object for this player in our
		-- database so let's make a new one.
		res = SpamMeNot.Player:New(name)
		self.players[name] = res
	end
	return res
end

SpamMeNot.Players = Players