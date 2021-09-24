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

local EventHandlers = {}

function EventHandlers:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	self.eventHandlers = {}
	return o
end

function EventHandlers:FakeWhisper(sender, lineID, text)
	SpamMeNot:DebugMsg("EventHandlers:FakeWhisper(\"" .. sender .. "\", " .. lineID .. ", \"" .. text .. "\")")
	for i=1,#self.eventHandlers do
		if self.eventHandlers[i]:HandlesWhispers() then
			self.eventHandlers[i]:InjectEvent("CHAT_MSG_WHISPER",text,sender,nil,nil,nil,"",nil,nil,nil,nil,lineID)
		end
	end
end

function EventHandlers:Register(obj, func, handlesWhispers)
	
	if type(obj) == "string" then
		handlesWhispers = func
		func = obj
		obj = nil
	end
	
	if type(func) ~= "string" then
		error("The function you want to hook must be specificed as a string.")
	end
	
	if obj then
		SpamMeNot:DebugMsg("Registering member event: " .. func)
	else
		SpamMeNot:DebugMsg("Registering simple event: " .. func)
	end
		
	self:Unregister(obj, func)
	
	local handler = SpamMeNot.EventHandler:New(obj, func, handlesWhispers)
	handler:Install()
	table.insert(self.eventHandlers, handler)
	
end


function EventHandlers:Unregister(obj, func)
	if type(obj) == "string" then
		func = obj
		obj = nil		
	end

	if type(func) ~= "string" then
		error("The function you want to unhook must be specificed as a string.")
	end

	if self.eventHandlers then
		for i=1,#self.eventHandlers do
			if (self.eventHandlers[i].obj == obj) and (self.eventHandlers[i].func == func) then
				self.eventHandlers[i]:Remove()
				table.remove(self.eventHandlers, i)
				break
			end
		end		
	end	
end

SpamMeNot.EventHandlers = EventHandlers