local mod = Chatter:NewModule("Highlights", "AceHook-3.0", "AceEvent-3.0", "LibSink-2.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Highlights"]

local Media = LibStub("LibSharedMedia-3.0")
local PlaySoundFile = _G.PlaySoundFile
local UnitName = _G.UnitName
local pairs = _G.pairs
local select = _G.select
local type = _G.type
local gsub = _G.string.gsub
local ChatFrame_GetMessageEventFilters = _G.ChatFrame_GetMessageEventFilters
local defSound = {["None"] = [[Interface\Quiet.mp3]]}
Media:Register("sound", "Loot Chime", [[Sound\interface\igLootCreature.wav]])
Media:Register("sound", "Whisper Ping", [[Sound\interface\iTellMessage.wav]])
Media:Register("sound", "Magic Click", [[Sound\interface\MagicClick.wav]])

local player = UnitName("player")
local defaults = {
	profile = {
		words = {
			[player:lower()] = player
		},
		sound = true,
		soundFile = "None",
		useSink = true,
		rerouteMessage = true,
		customChannels = {},
		sinkOptions = {}
	}
}

local options = {
	defaultOptions = {
		type = "group",
		name = L["Options"],
		order = 1,
		args = {
			sound = {
				type = "toggle",
				name = L["Use sound"],
				desc = L["Play a soundfile when one of your keywords is said."],
				get = function()
					return mod.db.profile.sound
				end,
				set = function(info, v)
					mod.db.profile.sound = v
				end
			},
			sink = {
				type = "toggle",
				name = L["Show SCT message"],
				desc = L["Show highlights in your SCT mod"],
				order = 21,
				get = function()
					return mod.db.profile.useSink
				end,
				set = function(info, v)
					mod.db.profile.useSink = v
				end
			},
			rerouteMessage = {
				type = "toggle",
				name = L["Reroute whole message to SCT"],
				desc = L["Reroute whole message to SCT instead of just displaying 'who said keyword in channel'"],
				order = 22,
				get = function()
					return mod.db.profile.rerouteMessage
				end,
				set = function(info, v)
					mod.db.profile.rerouteMessage = v
				end,
				disabled = function() return not mod.db.profile.useSink end
			},
			soundFile = {
				type = "select",
				name = L["Sound File"],
				desc = L["Sound file to play"],
				get = function()
					return mod.db.profile.soundFile
				end,
				set = function(info, v)
					mod.db.profile.soundFile = v
					PlaySoundFile(Media:Fetch("sound", v))
				end,
				dialogControl = "LSM30_Sound",
				values = function () if Media:HashTable("sound") then return Media:HashTable("sound") else return defSound end end,
				disabled = function() return not mod.db.profile.sound end
			},
			addWord = {
				type = "input",
				name = L["Add Word"],
				desc = L["Add word to your highlight list"],
				get = function() end,
				set = function(info, v)
					-- no whitespace only stuff
					if v:match("^%s*$") then return end
					mod.db.profile.words[v:lower()] = v
				end
			},
			removeWord = {
				type = "select",
				name = L["Remove Word"],
				desc = L["Remove a word from your highlight list"],
				get = function() end,
				set = function(info, v)
					mod.db.profile.words[v:lower()] = nil
				end,
				values = function() return mod.db.profile.words end,
				confirm = function(info, v) return (L["Remove this word from your highlights?"]) end
			}
		}
	},
	config = {
		type = "group",
		name = L["Custom Channel Sounds"],
		args = {}
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Highlight", defaults)
	self:AddCustomChannels(GetChannelList())
	self:SetSinkStorage(self.db.profile.sinkOptions)
	options.output = self:GetSinkAce3OptionsDataTable()
end

local words
function mod:OnEnable()
	words = self.db.profile.words
	self:RegisterEvent("CHAT_MSG_SAY", "ParseChat")
	self:RegisterEvent("CHAT_MSG_GUILD", "ParseChat")
	self:RegisterEvent("CHAT_MSG_BATTLEGROUND", "ParseChat")
	self:RegisterEvent("CHAT_MSG_BATTLEGROUND_LEADER", "ParseChat")
	self:RegisterEvent("CHAT_MSG_OFFICER", "ParseChat")
	self:RegisterEvent("CHAT_MSG_PARTY", "ParseChat")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "ParseChat")
	self:RegisterEvent("CHAT_MSG_RAID", "ParseChat")
	self:RegisterEvent("CHAT_MSG_RAID_WARNING", "ParseChat")
	self:RegisterEvent("CHAT_MSG_SAY", "ParseChat")
	self:RegisterEvent("CHAT_MSG_WHISPER", "ParseChat")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER", "ParseChat")
	self:RegisterEvent("CHAT_MSG_BN_CONVERSATION", "ParseChat")
	self:RegisterEvent("CHAT_MSG_CHANNEL", "ParseChat")
	self:RegisterEvent("CHAT_MSG_YELL", "ParseChat")
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
	self:AddCustomChannels(GetChannelList())
	self:AddCustomChannels(
		"YELL", L["Yell"],
		"GUILD", L["Guild"], 
		"OFFICER", L["Officer"],
		"RAID", L["Raid"],
		"PARTY", L["Party"],
		"RAID_WARNING", L["Raid Warning"],
		"SAY", L["Say"],
		"BATTLEGROUND", L["Battleground"],
		"BATTLEGROUND_LEADER", L["Battleground"],
		"WHISPER", L["Whisper"],
		"BN_WHISPER", L["RealID Whisper"],
		"BN_CONVERSATION", L["RealID Conversation"]
	)
end

function mod:CHAT_MSG_CHANNEL_NOTICE(evt, notice)
	self:AddCustomChannels(GetChannelList())
end

function mod:AddCustomChannels(...)
	-- excludeChannels(EnumerateServerChannels())
	for i = 1, select("#", ...), 2 do
		local id, name = select(i, ...)
		if not options[name:gsub(" ", "_")] then
			options.config.args[name:gsub(" ", "_")] = {
				type = "select",
				name = name,
				values = Media:HashTable("sound") or {},
				desc = L["Play a sound when a message is received in this channel"],
				order = type(id) == "number" and 103 or 102,
				get = function() return self.db.profile.customChannels[id] or "None" end,
				set = function(info, v)
					self.db.profile.customChannels[id] = v
					PlaySoundFile(Media:Fetch("sound", v))
				end
			}
		end
	end
end

function mod:ParseChat(evt, msg, sender, ...)
	if sender == player then return end

	local filters = ChatFrame_GetMessageEventFilters(evt)
	if filters then
		for i, filterFunc in ipairs(filters) do
			local filtered, new_message = filterFunc(DEFAULT_CHAT_FRAME, evt, msg, sender, ...)
			if filtered then
				return
			end
			msg = new_message or msg
		end
	end

	local msg = msg:lower()
	for k, v in pairs(words) do
		if msg:find(k) then
			self:Highlight(msg, sender, k, select(7, ...), evt)
			return
		end
	end

	if evt == "CHAT_MSG_CHANNEL" then
		local num = select(6, ...)
		local snd = self.db.profile.customChannels[num]
		if snd then
			PlaySoundFile(Media:Fetch("sound", snd))
			return
		end
	else
		local e = evt:gsub("^CHAT_MSG_", "")
		local snd = self.db.profile.customChannels[e]
		if snd then
			PlaySoundFile(Media:Fetch("sound", snd))
			return
		end
	end
end

function mod:Highlight(msg, who, what, where, event)
	if not where or #where == 0 then
		where = _G[event] or event:gsub("CHAT_MSG_", "")
	end
	if self.db.profile.sound then
		PlaySoundFile(Media:Fetch("sound", self.db.profile.soundFile))
	end
	if self.db.profile.useSink then
		if mod.db.profile.rerouteMessage then
			msg = gsub( msg, "|h[^|]+|h(.-)|h", "%1" )
			self:Pour((L["[%s] %s: %s"]):format(where, who, msg), 1, 1, 0, nil, 24, "OUTLINE", false)
		else
			self:Pour((L["%s said '%s' in %s"]):format(who, what, where), 1, 1, 0, nil, 24, "OUTLINE", false)
		end
	end
end

function mod:Info()
	return L["Alerts you when someone says a keyword or speaks in a specified channel."]
end

function mod:GetOptions()
	return options
end

-- vim: ts=4 noexpandtab
