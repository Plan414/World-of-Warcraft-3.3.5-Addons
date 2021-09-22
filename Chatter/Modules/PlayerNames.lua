local mod = Chatter:NewModule("Player Class Colors", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
local AceTab = LibStub("AceTab-3.0")

mod.modName = L["Player Names"]

local local_names = {}
local leftBracket, rightBracket, separator
local colorSelfInText, emphasizeSelfInText
local gsub = _G.string.gsub
local strmatch = _G.string.match
local find = _G.string.find
local pairs = _G.pairs
local wipe = _G.wipe
local string_format = _G.string.format
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetChannelName = _G.GetChannelName
local GetFriendInfo = _G.GetFriendInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetGuildRosterSelection = _G.GetGuildRosterSelection
local GetGuildRosterShowOffline = _G.GetGuildRosterShowOffline
local GetNumFriends = _G.GetNumFriends
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetNumPartyMembers = _G.GetNumPartyMembers
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumWhoResults = _G.GetNumWhoResults
local GetWhoInfo = _G.GetWhoInfo
local GuildRoster = _G.GuildRoster
local SetGuildRosterSelection = _G.SetGuildRosterSelection
local SetGuildRosterShowOffline = _G.SetGuildRosterShowOffline
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName

local floor = _G.math.floor
local select = _G.select
local setmetatable = _G.setmetatable
local sqrt = _G.sqrt
local tinsert = _G.tinsert
local type = _G.type

local player = UnitName("player")


local channels = {
	GUILD = {},
	PARTY = {},
	RAID = {}
}
local colorMethods = {
	CLASS = L["Class"],
	NAME = L["Name"],
	NONE = L["None"],
}

local defaults = {
	realm = {
		names = {},
		levels = {},
	},
	profile = {
		saveData = false, 
		nameColoring = "CLASS", 
		leftBracket = "[", 
		rightBracket = "]", 
		separator = ":",
		useTabComplete = true,
		colorSelfInText = true,
		emphasizeSelfInText = true,
	},
	global = {
		classes = {		-- yeah this should be localized by translators but ... they dont. so we also autodiscover on UnitClass() calls
			DRUID = L["Druid"],
			MAGE = L["Mage"],
			PALADIN = L["Paladin"],
			PRIEST = L["Priest"],
			ROGUE = L["Rogue"],
			HUNTER = L["Hunter"],
			SHAMAN = L["Shaman"],
			WARLOCK = L["Warlock"],
			WARRIOR = L["Warrior"],
			DEATHKNIGHT = L["Death Knight"],
		}
	}
}
local default_nick_color = { ["r"] = 0.627, ["g"] = 0.627, ["b"] = 0.627 }

local localizedToSystemClass = {} -- gets initialized in OnInit

local origUnitClass = UnitClass
local function UnitClass(unit)	-- Hook UnitClass for calls below so that we can autodiscover
	local loc,sys = origUnitClass(unit)
	if sys and mod.db.global.classes[sys] then
		mod.db.global.classes[sys] = loc
		localizedToSystemClass = sys
	end
	return loc,sys
end


local tabComplete
do
	function tabComplete(t, text, pos)
		local word = text:sub(pos)
		if #word == 0 then return end
		local cf = ChatEdit_GetActiveWindow()
		local channel = cf:GetAttribute("chatType")
		if channel == "CHANNEL" then
			channel = select(2, GetChannelName(cf:GetAttribute("channelTarget"))):lower()
		elseif channel == "OFFICER" then
			channel = "GUILD"
		elseif channel == "RAID_WARNING" or channel == "RAID_LEADER" or channel == "BATTLEGROUND" or channel == "BATTLEGROUND_LEADER" then
			channel = "RAID"
		end
		if channels[channel] then
			for k, v in pairs(channels[channel]) do
				if k:lower():match("^" .. word:lower()) then
					tinsert(t, k)
				end
			end
		end
		return t
	end
end

local getNameColor
do
	local sq2 = sqrt(2)
	local pi = _G.math.pi
	local cos = _G.math.cos
	local fmod = _G.math.fmod
	local strbyte = _G.strbyte
	local t = {}
	
	-- http://www.tecgraf.puc-rio.br/~mgattass/color/HSVtoRGB.htm


	local function HSVtoRGB(h, s, v)
	   if ( s == 0 ) then
		  --achromatic=fail
		  t.r = v
		  t.g = v
		  t.b = v
		  if not t.r then t.r = 0 end
		  if not t.g then t.g = 0 end
		  if not t.b then t.b = 0 end
		  return t.r,t.g,t.b
	   end
	   h = h/60
	   local i = floor(h)
	   local i1 = v * (1 - s)
	   local i2 = v * (1 - s * (h - i))
	   local i3 = v * (1 - s * (1 - (h - i)))
	   if i == 0 then
		  --	return v, i3, i1
		  t.r = v
		  t.g = i3
		  t.b = i1
	   elseif i == 1 then
		  --	return i2, v, i1
		  t.r = i2
		  t.g = v
		  t.b = i1
	   elseif i == 2 then
		  --	return i1, v, i3
		  t.r = i1
		  t.g = v
		  t.b = i3
	   elseif i == 3 then
		  --	return i3, i2, v
		  t.r = i3
		  t.g = i2
		  t.b = v
	   elseif i == 4 then
		  --	return i3, i1, v
		  t.r = i3
		  t.g = i1
		  t.b = v
	   elseif i == 5 then
		  --	return v, i1, i2
		  t.r = v
		  t.g = i1
		  t.b = i2
	   else
		  DEFAULT_CHAT_FRAME:AddMessage("Chatter HSVtoRGB failed")
	   end
	   if not t.r then t.r = 0 end
	   if not t.g then t.g = 0 end
	   if not t.b then t.b = 0 end
	   return t.r,t.g,t.b
	end
	
	function getNameColor(name)
		local seed = 5381 --old seed: 5124
		local h, s, v = 1, 1, 1
		local r, g, b
		for i = 1, #name do
			seed = 33 * seed + strbyte(name, i) --used to use 29 here
		end
		-- h = fmod(seed, 255) / 255
		h = fmod(seed, 360) --changed the HSVtoRGB to acompany this change
		if (h > 220) and (h < 270) then
		   h = h + 60
		end
		t.r, t.g, t.b = HSVtoRGB(h, s, v)
		
		return t
	end
end

local cache = {};

local function wipeCache()
	wipe(cache)
end

local function updateSaveData(v)
	if v then
		for k, v in pairs(local_names) do
			mod.db.realm.names[k] = v
		end
	end
end


function mod:OnInitialize()
	
	self.db = Chatter.db:RegisterNamespace("PlayerNames", defaults)
	for k, v in pairs(self.db.realm.names) do
		if type(v) == "string" then
			self.db.realm.names[k] = {class = v}
		end
	end
	
	if self.db.global and self.db.global.names then
		self.db.global.names = nil	-- get rid of old data
	end
	
	-- create reverse map of classes (localized -> system)
	for sys,loc in pairs(self.db.global.classes) do
		localizedToSystemClass[loc]=sys
	end
end

function mod:Decorate(frame)
	if not self:IsHooked(frame,"AddMessage") then
		self:RawHook(frame, "AddMessage", true)
	end
end


function mod:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("WHO_LIST_UPDATE")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("CHAT_MSG_SYSTEM", "WHO_LIST_UPDATE")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
	self:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
	self:RegisterEvent("CHAT_MSG_CHANNEL", "CHAT_MSG_CHANNEL_JOIN")
	
	leftBracket, rightBracket, separator = self.db.profile.leftBracket, self.db.profile.rightBracket, self.db.profile.separator
	colorSelfInText, emphasizeSelfInText = self.db.profile.colorSelfInText, self.db.profile.emphasizeSelfInText
	if IsInGuild() then
		GuildRoster()
	end
	self:RAID_ROSTER_UPDATE()
	self:PARTY_MEMBERS_CHANGED()

	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local cf = _G[frame]
		self:RawHook(cf, "AddMessage", true)
	end
	if self.db.profile.useTabComplete then
		AceTab:RegisterTabCompletion("Chatter", nil, tabComplete)
	end
	
	if CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS.RegisterCallback then
		CUSTOM_CLASS_COLORS:RegisterCallback(wipeCache)
	end
end

function mod:OnDisable()
	if AceTab:IsTabCompletionRegistered("Chatter") then
		AceTab:UnregisterTabCompletion("Chatter")
	end

	if CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS.UnregisterCallback then
		CUSTOM_CLASS_COLORS:UnregisterCallback(wipeCache)
	end
end

function mod:ClearCustomClassColorCache()
end

function mod:AddPlayer(name, class, level, save)
	if name and class and class ~= UNKNOWN then
		if save or self.db.realm.names[name] then	-- if we already have an entry saved from elsewhere, we update it regardless of the requested "save" type - nothing else makes sense
			self.db.realm.names[name] = self.db.realm.names[name] or {}
			self.db.realm.names[name].class = class
			if level and level ~= 0 then
				self.db.realm.names[name].level = level
			end
		else
			local_names[name] = local_names[name] or {}
			local_names[name].class = class
			if level and level ~= 0 then
				local_names[name].level = level
			end
		end
		cache[name] = nil
	end
end

function mod:FRIENDLIST_UPDATE(evt)
	for i = 1, GetNumFriends() do
		local name, level, class = GetFriendInfo(i)
		if class then
			self:AddPlayer(name, localizedToSystemClass[class], level, self.db.profile.saveFriends)
		end
	end
end

--[[
function mod:GUILD_ROSTER_UPDATE(evt)
	local n = GetNumGuildMembers()
	if not n or n == 0 then
		return
	end

	local offline = GetGuildRosterShowOffline()
	local selection = GetGuildRosterSelection()
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	
	SetGuildRosterShowOffline(true)
	SetGuildRosterSelection(0)
	GetGuildRosterInfo(0)
	n = GetNumGuildMembers()
	for k, v in pairs(channels.GUILD) do
		channels.GUILD[k] = nil
	end
	for i = 1, n do
		local name, _, _, level, _, _, _, _, online, _, class = GetGuildRosterInfo(i)
		if online then
			channels.GUILD[name] = name
		end
		self:AddPlayer(name, class, level, self.db.profile.saveGuild)
	end
	SetGuildRosterShowOffline(offline)
	SetGuildRosterSelection(selection)
	
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
end
]]

function mod:GUILD_ROSTER_UPDATE(evt)
	if not IsInGuild() then return end
	wipe( channels.GUILD )
	for i = 1, GetNumGuildMembers() do 
		local name, _, _, level, _, _, _, _, online, _, class = GetGuildRosterInfo(i) 
		if online then 
			channels.GUILD[name] = name 
		end 
		self:AddPlayer(name, class, level, self.db.profile.saveGuild) 
	end 
end 

function mod:RAID_ROSTER_UPDATE(evt)
	wipe(channels.RAID)

	for i = 1, GetNumRaidMembers() do
		local n, _, _, l, _, c = GetRaidRosterInfo(i)
		if n and c and l then
			channels.RAID[n] = true
			self:AddPlayer(n, c, l, self.db.profile.saveParty)
		end
	end
end

function mod:PARTY_MEMBERS_CHANGED(evt)
	wipe(channels.PARTY)
	
	for i = 1, GetNumPartyMembers() do
		local n = UnitName("party" .. i)
		local _, c = UnitClass("party" .. i)
		local l = UnitLevel("party" .. i)
		channels.PARTY[n] = true
		self:AddPlayer(n, c, l, self.db.profile.saveParty)
	end
end

function mod:PLAYER_TARGET_CHANGED(evt)
	if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then return end
	local _, c = UnitClass("target")
	local l = UnitLevel("target")
	self:AddPlayer(UnitName("target"), c, l, self.db.profile.saveTarget)
end

function mod:UPDATE_MOUSEOVER_UNIT(evt)
	if not UnitExists("mouseover") or not UnitIsPlayer("mouseover") or not UnitIsFriend("player", "mouseover") then return end
	local _, c = UnitClass("mouseover")
	local l = UnitLevel("mouseover")
	self:AddPlayer(UnitName("mouseover"), c, l, self.db.profile.saveTarget)
end

function mod:WHO_LIST_UPDATE(evt)
	if GetNumWhoResults() <= 3 or self.db.profile.saveAllWho then
		for i = 1, GetNumWhoResults() do
			local name, _, level, _, _, _, class = GetWhoInfo(i)
			if class then
				self:AddPlayer(name, class, level, self.db.profile.saveWho)
			end
		end
	end
end

function mod:CHAT_MSG_CHANNEL_JOIN(evt, _, name, _, _, _, _, _, _, chan)
	channels[chan:lower()] = channels[chan:lower()] or {}
	channels[chan:lower()][name] = true
end

function mod:CHAT_MSG_CHANNEL_LEAVE(evt, _, name, _, _, _, _, _, _, chan)
	if not channels[chan:lower()] then return end
	channels[chan:lower()][name] = nil
end

local function changeName(msgHeader, name, extra, msgCnt,displayName, msgBody)
	if name ~= player then
		if emphasizeSelfInText then
			msgBody = msgBody:gsub("("..player..")" , "|cffffff00>|r%1|cffffff00<|r"):gsub("("..player:lower()..")" , "|cffffff00>|r%1|cffffff00<|r")
		end
		if colorSelfInText then
			msgBody = msgBody:gsub("("..player..")" , "|cffff0000%1|r"):gsub("("..player:lower()..")" , "|cffff0000%1|r")
		end
	end

	if not strmatch( displayName, "|cff" ) then
		displayName = mod:ColorName( name )
	end

	cache[name] = displayName

	local level
	local tab = mod.db.realm.names[name] or local_names[name]
	if tab then
		level = mod.db.profile.includeLevel and tab.level or nil
	end

	if level and (level ~= 80 or not mod.db.profile.excludeMaxLevel) then
		if mod.db.profile.levelByDiff then
			local c = GetQuestDifficultyColor(level)
			level = ("|cff%02x%02x%02x%s|r"):format(c.r * 255, c.g * 255, c.b * 255, level)
			displayName = ("%s%s%s"):format( displayName, separator, level )
		else
			-- If we already have a color -- steal it and use it to color the level
			if strmatch( displayName, "|cff......" ) then
				-- This will seriously fuck up the string if there is already more than 1 color ... FIXME
				level = gsub(displayName, "((|cff......).-|r)", function (string, color)
					return ("%s%s|r"):format( color, level )
				end )
			end
			displayName = ("%s%s%s"):format( displayName, separator, level )
		end
	end

	return ("|Hplayer:%s%s%s|h%s%s%s|h%s"):format(name, extra, msgCnt, leftBracket, displayName, rightBracket, msgBody)
end

function mod:ColorName( name )
	local class
	local tab = mod.db.realm.names[name] or local_names[name]
	if tab then class = tab.class end

	-- already known?
	if cache[name] then
		name = cache[name]
	else
		local coloring = mod.db.profile.nameColoring

		-- not yet colored by blizzy
		if coloring ~= "NONE" then
			local c = default_nick_color
			if coloring == "CLASS" then
				c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or default_nick_color
			elseif coloring == "NAME" then
				c = getNameColor(name)
			end

			name = ("|cff%02x%02x%02x%s|r"):format(c.r * 255, c.g * 255, c.b * 255, name )
		end
	end

	return name
end

function mod:AddMessage(frame, text, ...)
	if text and type(text) == "string" then 
		text = text:gsub("(|Hplayer:([^|:]+)([:%d+]*)([^|]*)|h%[([^%]]+)%]|h)(.-)$", changeName)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:Info()
	return L["Provides options to color player names, add player levels, and add tab completion of player names."]
end

local options

function mod:GetOptions()
	if not options then	-- save RAM / load time
		options = {
			save = {
				type = "group",
				name = L["Save Data"],
				desc = L["Save data between sessions. Will increase memory usage"],
				args = {
					guild = {
						type = "toggle",
						name = L["Guild"],
						desc = L["Save class data from guild between sessions."],
						get = function()
							return mod.db.profile.saveGuild
						end,
						set = function(info, v)
							mod.db.profile.saveGuild = v
							updateSaveData(v)
						end
					},
					group = {
						type = "toggle",
						name = L["Group"],
						desc = L["Save class data from groups between sessions."],
						get = function()
							return mod.db.profile.saveGroup
						end,
						set = function(info, v)
							mod.db.profile.saveGroup = v
							updateSaveData(v)
						end
					},
					friend = {
						type = "toggle",
						name = L["Friends"],
						desc = L["Save class data from friends between sessions."],
						get = function()
							return mod.db.profile.saveFriends
						end,
						set = function(info, v)
							mod.db.profile.saveFriends = v
							updateSaveData(v)
						end
					},
					target = {
						type = "toggle",
						name = L["Target/Mouseover"],
						desc = L["Save class data from target/mouseover between sessions."],
						get = function()
							return mod.db.profile.saveTarget
						end,
						set = function(info, v)
							mod.db.profile.saveTarget = v
							updateSaveData(v)
						end
					},
					who = {
						type = "toggle",
						name = L["Who"],
						desc = L["Save class data from /who queries between sessions."],
						order = 104,
						get = function()
							return mod.db.profile.saveWho
						end,
						set = function(info, v)
							mod.db.profile.saveWho = v
							updateSaveData(v)
						end
					},
					saveAllWho = {
						type = "toggle",
						name = L["Save all /who data"],
						desc = L["Will save all data for large /who queries"],
						disabled = function() return not mod.db.profile.saveWho end,
						order = 105,
						get = function()
							return mod.db.profile.saveAllWho
						end,
						set = function(info, v)
							mod.db.profile.saveAllWho = v
						end
					},
					resetDB = {
						type = "execute",
						name = L["Reset Data"],
						desc = L["Destroys all your saved class/level data"],
						func = function() wipe( mod.db.realm.names ) end,
						order = 101,
						confirm = function() return L["Are you sure you want to delete all your saved class/level data?"] end
					}
				}
			},
			leftbracket = {
				type = "input",
				name = L["Left Bracket"],
				desc = L["Character to use for the left bracket"],
				get = function() return mod.db.profile.leftBracket end,
				set = function(i, v)
					mod.db.profile.leftBracket = v
					leftBracket = v
				end
			},
			rightbracket = {
				type = "input",
				name = L["Right Bracket"],
				desc = L["Character to use for the right bracket"],
				get = function() return mod.db.profile.rightBracket end,
				set = function(i, v)
					mod.db.profile.rightBracket = v
					rightBracket = v
				end
			},	
			separator = {
				type = "input",
				name = L["Separator"],
				desc = L["Character to use between the name and level"],
				get = function() return mod.db.profile.separator end,
				set = function(i, v)
					mod.db.profile.separator = v
					separator = v
				end
			},
			useTabComplete = {
				type = "toggle",
				name = L["Use Tab Complete"],
				desc = L["Use tab key to automatically complete character names."],
				get = function() return mod.db.profile.useTabComplete end,
				set = function(info, v)
					mod.db.profile.useTabComplete = v
					if v and not AceTab:IsTabCompletionRegistered("Chatter") then
						AceTab:RegisterTabCompletion("Chatter", nil, tabComplete)
					elseif not v and AceTab:IsTabCompletionRegistered("Chatter") then
						AceTab:UnregisterTabCompletion("Chatter")
					end
				end
			},
			colorSelfInText = {
				type = "toggle",
				name = L["Color self in messages"],
				desc = L["Color own charname in messages."],
				get = function() return mod.db.profile.colorSelfInText end,
				set = function(i, v)
					mod.db.profile.colorSelfInText = v
					colorSelfInText = v
				end
			},
			emphasizeSelfInText = {
				type = "toggle",
				name = L["Emphasize self in messages"],
				desc = L["Add surrounding brackets to own charname in messages."],
				width = "double",
				get = function() return mod.db.profile.emphasizeSelfInText end,
				set = function(i, v)
					mod.db.profile.emphasizeSelfInText = v
					emphasizeSelfInText = v
				end
			},
			levelHeader = {
				type = "header",
				name = L["Level Options"],
				order = 104
			},
			includeLevel = {
				type = "toggle",
				name = L["Include level"],
				desc = L["Include the player's level"],
				order = 105,
				get = function() return mod.db.profile.includeLevel end,
				set = function(info, val)
					mod.db.profile.includeLevel = val
					wipeCache()
				end
			},
			excludeMaxLevel = {
				type = "toggle",
				name = L["Exclude max levels"],
				desc = L["Exclude level display for max level characters"],
				order = 105,
				get = function() return mod.db.profile.excludeMaxLevel end,
				set = function(info, val)
					mod.db.profile.excludeMaxLevel = val
					wipeCache()
				end,
				hidden = function() return not mod.db.profile.includeLevel end
			},
			colorLevelByDifficulty = {
				type = "toggle",
				name = L["Color level by difficulty"],
				desc = L["Color level by difficulty"],
				order = 105,
				get = function()
					return mod.db.profile.levelByDiff
				end,
				set = function(info, v)
					mod.db.profile.levelByDiff = v
					wipeCache()
				end,
				hidden = function() return not mod.db.profile.includeLevel end
			},
			colorBy = {
				type = "select",
				name = L["Color Player Names By..."],
				desc = L["Select a method for coloring player names"],
				values = colorMethods,
				get = function() return mod.db.profile.nameColoring end,
				set = function(info, val)
					mod.db.profile.nameColoring = val
					wipeCache()
				end
			}
		}

	end
	return options
end
