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

local Who = {}
Who.WhoLib =  LibStub:GetLibrary("LibWho-2.0")
Who.WhoLibResults = {}

--Who.WhoLib:SetWhoLibDebug(true)

function Who:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

function Who:Lookup(name)
	SpamMeNot:DebugMsg("Who:Lookup(" .. name .. ")");
	local options = {
		queue = Who.WhoLib.WHOLIB_QUEUE_QUIET,
		timeout = 5,
		callback = Who.WhoLibCallback,
		flags = Who.WhoLib.WHOLIB_FLAG_ALWAYS_CALLBACK,
	}
	-- WhoLib-2.0 is buggy atm and won't force a callback on cached who data.  Here
	-- we check to see if it returned immediately or not.
	local whoRes = Who.WhoLib:UserInfo(name, options)
	if (type(whoRes) == 'table') then
		SpamMeNot:DebugMsg("Manually calling callback...")
		Who.WhoLibCallback(whoRes)
	end
	
	return Who.WhoLibResults[name]	
end

function Who.WhoLibCallback(result)
	SpamMeNot:DebugMsg("WhoLibCallback() called with result for " .. result.Name)
	Who.WhoLibResults[result.Name] = {}
	Who.WhoLibResults[result.Name].class = result.Class
	Who.WhoLibResults[result.Name].level = result.Level
	Who.WhoLibResults[result.Name].race = result.Race
	Who.WhoLibResults[result.Name].guild = result.Guild
	Who.WhoLibResults[result.Name].zone = result.Zone							
end


SpamMeNot.Who = Who