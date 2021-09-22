﻿local mod = Chatter:NewModule("Channel Colors", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Channel Colors"]
local GetChannelList = _G.GetChannelList
local GetChannelName = _G.GetChannelName
local GetMessageTypeColor = _G.GetMessageTypeColor
local select = _G.select
local tonumber = _G.tonumber
local type = _G.type

function mod:Info()
	return L["Keeps your channel colors by name rather than by number."]
end

local defaults = {
	profile = { colors = {} }
}

local options = {
	splitter = {
		type = "header",
		name = L["Other Channels"],
		order = 49
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("ChannelColors", defaults)
end

function mod:OnEnable()
	self:RegisterEvent("UPDATE_CHAT_COLOR")
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
	self:AddChannels(GetChannelList())
	self:AddChannels(
		"SAY", L["Say"],
		"YELL", L["Yell"],
		"GUILD", L["Guild"], 
		"OFFICER", L["Officer"], 
		"PARTY", L["Party"], 
		"PARTY_LEADER", PARTY_LEADER,
		"RAID", L["Raid"], 
		"RAID_LEADER", L["Raid Leader"],
		"RAID_WARNING", L["Raid Warning"],
		"BATTLEGROUND", L["Battleground"],
		"BATTLEGROUND_LEADER", L["Battleground Leader"],
		"WHISPER", L["Whisper"],
		"BN_WHISPER", L["RealID Whisper"],
		"BN_CONVERSATION", L["RealID Conversation"]
	)
end

function mod:AddChannels(...)
	for i = 1, select("#", ...), 2 do
		local id, name = select(i, ...)
		self.db.profile.colors[name] = self.db.profile.colors[name] or {}
		if not self.db.profile.colors[name].r then
			local r, g, b = GetMessageTypeColor(type(id) == "number" and ("CHANNEL" .. id) or id)
			self.db.profile.colors[name].r = r
			self.db.profile.colors[name].g = g
			self.db.profile.colors[name].b = b
		end
		if not options[name:gsub(" ", "_")] then
			options[name:gsub(" ", "_")] = {
				type = "color",
				name = name,
				desc = L["Select a color for this channel"],
				order = type(id) == "number" and (50 + id) or 48,
				get = function()
					local c = self.db.profile.colors[name]
					if c then
						return c.r, c.g, c.b
					else
						return GetMessageTypeColor(type(id) == "number" and ("CHANNEL" .. id) or id)
					end
				end,
				set = function(info, r, g, b)
					self.db.profile.colors[name] = self.db.profile.colors[name] or {}
					self.db.profile.colors[name].r = r
					self.db.profile.colors[name].g = g
					self.db.profile.colors[name].b = b
					ChangeChatColor(type(id) == "number" and ("CHANNEL" .. id) or id, r, g, b);
				end
			}
		end
	end
end

function mod:CHAT_MSG_CHANNEL_NOTICE(evt, notice, _, _, fullname, _, _, channelType, channelNumber, channelName)	
	if notice == "YOU_JOINED" then
		self:AddChannels(GetChannelList())
		channelName = channelName:match("^(%w+)")
		local c = self.db.profile.colors[channelName] 
		if c then
			ChangeChatColor("CHANNEL" .. channelNumber, c.r, c.g, c.b);
		end
	end
end

function mod:UPDATE_CHAT_COLOR(evt, chan, r, g, b)
	if chan then
		local num = tonumber(chan:match("(%d+)$"))
		local channelNum = num and select(2, GetChannelName(num))
		local name = channelNum and channelNum:match("^(%w+)") or chan
		self.db.profile.colors[name] = self.db.profile.colors[name] or {}
		self.db.profile.colors[name].r = r
		self.db.profile.colors[name].g = g
		self.db.profile.colors[name].b = b
	end
end

function mod:GetOptions()
	return options
end
