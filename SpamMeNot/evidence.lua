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
	Evidence is a single line of evidence.
]]

local Evidence = {}

function Evidence:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

function Evidence:New(id, text)
	local obj = Evidence:new()
	obj.id = id
	obj.text = text
	obj.time = date("*t")	
	obj.time.serverHour, obj.time.serverMin = GetGameTime();
	obj.timestamp = time()
				
	obj.reported = false
	return obj
end

-- Reports the evidence as spam.  Returns true on success.
function Evidence:Report()
	local res = false
	SpamMeNot:DebugMsg("Reporting evidence id " .. self.id)
	if CanComplainChat(self.id) then
		ComplainChat(self.id)
		res = true
	end
	return res
end

SpamMeNot.Evidence = Evidence