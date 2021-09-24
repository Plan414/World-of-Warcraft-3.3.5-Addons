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

local EventHandler = {}

--[[
	This detours, trampolines and injects events in to our registered event
	handlers.  This includes AceEvent-3.0 which SpamMeNot itself uses - because
	of this we need to check to see if we're acting on a SpamMeNot hook and
	not do anything other than call the trampoline if that's the case.
]]

function EventHandler:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	local AceHooks = LibStub("AceHook-3.0")
	AceHooks:Embed(o)
	return o
end

function EventHandler:New(obj, func, handlesWhispers)
	local o = self:new()
	o.obj = obj
	o.func = func
	o.handlesWhispers = handlesWhispers	
	return o
end

function EventHandler:InjectEvent(...)
	SpamMeNot:DebugMsg("InjectEvent() called.")
	
	if self.obj == SpamMeNot then
		SpamMeNot:DebugMsg("InjectEvent() detected SpamMeNot - exiting.")
		return nil
	end

	if self.obj then
		self.hooks[self.obj][self.func](obj, ...)
	else
		self.hooks[self.func](...)
	end
end

function EventHandler:HandlesWhispers()
	return self.handlesWhispers
end

function EventHandler:Handler(o, ...)	
					
	--if type(o) == "table" then			
	if self.obj then
		-- Object call
		if not SpamMeNot.filter:FilterEvent(...) then			
			SpamMeNot:DebugMsg("Msg passed filter.  Calling trampoline...")
			if self.hooks[self.obj] then				
				if self.hooks[self.obj][self.func] then
					self.hooks[self.obj][self.func](o, ...)
				end			
			else
				SpamMeNot:DebugMsg("This object doesn't have any hooks??")				
				SpamMeNot:DebugMsg(o)				
				SpamMeNot:DebugMsg(self.obj)
				SpamMeNot:DebugMsg("---")								
			end
		else
			SpamMeNot:DebugMsg("Message filtered.  Not calling trampoline.")			
		end		
	else
		if not SpamMeNot.filter:FilterEvent(o, ...) then
			--self.hooks[self.obj][self.func](o, ...)
			
			SpamMeNot:DebugMsg("Msg passed filter.  Calling trampoline " .. self.func .. "...")
			if self.hooks[self.func] then
				self.hooks[self.func](o, ...)	
			else
				SpamMeNot:DebugMsg("Erm... where's the trampoline for " .. self.func)
			end
			
			
		end
	end
end


function EventHandler:Install()
	SpamMeNot:DebugMsg("Calling RawHook()")
	self:RawHook(self.obj, self.func, "Handler")	
end


function EventHandler:Remove()
	self:Unhook(self.obj, self.func)
end

SpamMeNot.EventHandler = EventHandler