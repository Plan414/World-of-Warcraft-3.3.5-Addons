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

local Spammers = {}

function Spammers:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	self.db = {}
	return o
end

function Spammers:Add(player)
	if type(player) == "string" then
		player = SpamMeNot.players:GetPlayer(player)
	end
	player:FlagAsSpammer()
	self.db[player:GetName()] = true
end

function Spammers:Remove(player)
	if type(player) == "string" then
		player = SpamMeNot.players:GetPlayer(player)
	end
	player:UnflagAsSpammer()
	self.db[player:GetName()] = nil
end

SpamMeNot.Spammers = Spammers