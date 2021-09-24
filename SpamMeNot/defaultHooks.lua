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

local DefaultHooks = {}

function DefaultHooks:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self	
	return o
end

function DefaultHooks:Install()
	self:WIM(true)
	self:ChatSounds(true)	
end

function DefaultHooks:Uninstall()
	self:WIM(false)
	self:ChatSounds(false)
end

function DefaultHooks:ChatSounds(hook)
	if ChatSounds then
		if hook then			
			SpamMeNot:RegisterEventHandler(ChatSounds, "GroupChat")
			SpamMeNot:RegisterEventHandler(ChatSounds, "CHAT_MSG_WHISPER", true)
			SpamMeNot:RegisterEventHandler(ChatSounds, "CHAT_MSG_WHISPER_INFORM")			
		else
			SpamMeNot:UnregisterEventHandler(ChatSounds, "GroupChat")
			SpamMeNot:UnregisterEventHandler(ChatSounds, "CHAT_MSG_WHISPER")
			SpamMeNot:UnregisterEventHandler(ChatSounds, "CHAT_MSG_WHISPER_INFORM")
		end
	end
end

-- In some cases WIM detects messages from it's own message handler, and in some cases
-- from ChatFrame_MessageEventHandler.
function DefaultHooks:WIM(hook)
	-- Hook WIM 3
	if WIM then
		if WIM.CoreEventHandler then
			if hook then
				SpamMeNot:RegisterEventHandler(WIM, "CoreEventHandler", true)				
				SpamMeNot:DisableChatFrameInjection()
			else
				SpamMeNot:UnregisterEventHandler(WIM, "CoreEventHandler")				
				SpamMeNot:EnableChatFrameInjection()
			end
		end
	end
end

SpamMeNot.DefaultHooks = DefaultHooks