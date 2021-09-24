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

local L = LibStub("AceLocale-3.0"):GetLocale("SpamMeNot")

local UpdateMonitor = {}

function UpdateMonitor:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function UpdateMonitor:New()
	local o = self:new()
	o.isEnabled = false
	o.commPrefix = "SMN"
	o.newVersionDetected = false
	LibStub("AceComm-3.0"):Embed(o)
	LibStub("AceSerializer-3.0"):Embed(o)	
	return o
end

function UpdateMonitor:IsActive()
	return self.isEnabled
end

function UpdateMonitor:Enable()
	if not self.isEnabled then
		self:RegisterComm(self.commPrefix, "CommMsgHandler")
		SpamMeNot:DebugMsg("Comms registered.")
		self:BroadcastVersion()
		self.isEnabled = true
	end
end

function UpdateMonitor:Disable()
	if self.isEnabled then
		self.isEnabled = false
		self:UnregisterAllComm()
	end
end

function UpdateMonitor:BroadcastVersion()
	local msg = {}
	msg.type = "Version"
	msg.major, msg.minor, msg.build = SpamMeNot:GetVersion()
	
	local serialized = self:Serialize(msg)
	
	SpamMeNot:DebugMsg("Serialized to " .. serialized)
	self:SendCommMessage(self.commPrefix, serialized, "PARTY")
	self:SendCommMessage(self.commPrefix, serialized, "RAID")
	if (IsInGuild()) then
		self:SendCommMessage(self.commPrefix, serialized, "GUILD")
	end	
	SpamMeNot:DebugMsg("Version broadcasted.")
end

function UpdateMonitor:CommMsgHandler(prefix, serialized, distrib, sender)	
	if prefix == self.commPrefix then
		local success, msg = self:Deserialize(serialized)
		if success then
			if msg then
				if type(msg.type) == "string" then
					local member = string.format("On%sReceived", msg.type)
					if self[member] then
						self[member](self, msg, sender)
					end				
				end
			end			
		end
	end	
end

function UpdateMonitor:OnVersionReceived(msg, sender)
	if sender ~= UnitName("player") then
		sender = sender or "unknown"
		SpamMeNot:DebugMsg(string.format("Version received from %s: %d.%d.%d", sender, msg.major, msg.minor, msg.build))
		local myVersion = {}
		myVersion.major, myVersion.minor, myVersion.build = SpamMeNot:GetVersion()
				
		if msg.major > myVersion.major
			or (msg.major == myVersion.major) and (msg.minor > myVersion.minor)
			or (msg.major == myVersion.major) and (msg.minor == myVersion.minor) and (msg.build > myVersion.build)
			and not self.newVersionDetected then
				-- The sender has a newer version of SpamMeNot
				SpamMeNot:Print(string.format(L["%s has a newer version - %d.%d (r %d)"], sender, msg.major, msg.minor, msg.build))		
				self.newVersionDetected = true
		end		
	end
end


SpamMeNot.UpdateMonitor = UpdateMonitor