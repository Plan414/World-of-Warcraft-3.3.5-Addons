--[[
RankWatch will monitor the spells cast by members of your party or raid and warn them
if they are using a downranked spell.

While downranked spells were formerly used to save mana, this use is no longer supported,
and while it is occasionally intended, the use of downranked spells is generally a mistake.

Sometimes this happens when people forget to train at level 80, sometimes it happens when
they spend talent points to obtain a spell which is not a base skill for the class (for
example, a Death Knight's Frost Strike our Scourge Strike) but fail to train the ranks
for the newly talented spell.

In my experience, the most common cause is training while dual specced.
For example, if you level up as a feral druid, you will train new ranks of Rejuvenation
etc, but the new ranks will not appear on your bars when you change to the Resto spec.

Copyright (C) 2009 by Gronzig of Rexxar/US.

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

local L = LibStub("AceLocale-3.0"):GetLocale("RankWatch")

local RankWatch_Version = "v1.11"

local RANKWATCH_PRIORITY_IS_ME = 9999
local RANKWATCH_PRIORITY_IGNORE = RANKWATCH_PRIORITY_IS_ME - 1
local RANKWATCH_PRIORITY_MAX = RANKWATCH_PRIORITY_IGNORE - 1

local RANKWATCH_CHANNEL_DISABLED = false
local RANKWATCH_CHANNEL_PARTY = 1
local RANKWATCH_CHANNEL_SAY = 2
local RANKWATCH_CHANNEL_WHISPER = 3
		
local RANKWATCH_WHISPER_80 = 1
local RANKWATCH_WHISPER_ALL = 2
local RANKWATCH_WHISPER_SELF = 3

-- Special-case a few spells for which reasonable uses for downranked spells exist

local RankWatch_Rank1_Allowed = {
	[(GetSpellInfo(116))] = true,	-- Mages commonly use rank 1 frostbolt to slow enemies due to its shorter cast time.
	[(GetSpellInfo(1949))] = true,	-- Warlocks commonly use rank 1 hellfire to proc trinkets etc.
	[(GetSpellInfo(1008))] = true,	-- Mages commonly use rank 1 amplify/dampen magic in arenas for purge fodder
	[(GetSpellInfo(604))] = true,
	[(GetSpellInfo(1120))] = true,	-- Drain Soul Rank 1 is used to obtain soul shards without killing a mob too quickly
}

local RankWatch_RankMaxMinusOne_Allowed = {
	[(GetSpellInfo(2120))] = true,	-- Mages use a downranked flamestrike for an optimal AOE rotation
}

local RankWatch_AnyRank_Allowed = {
	[(GetSpellInfo(1454))] = true,	-- Warlocks commonly use downranked life tap to proc the glyph
	[(GetSpellInfo(18220))] = true,	--    Dark Pact can proc the life tap glyph too
	[(GetSpellInfo(755))] = true,	-- and downranked Health Funnel still heals for quite a bit without costing so much health
	[(GetSpellInfo(118))] = true,	-- Mages commonly use downranked polymorph for shorter duration in some pve situations.
	[(GetSpellInfo(587))] = true,	-- Downranked Conjured Food is sometimes used to give to lower level players.
	[(GetSpellInfo(5504))] = true,	-- same with Conjured Water
	[(GetSpellInfo(42955))] = true,	-- and Conjured Refreshment
}

-- For buffs and HoTs, it's the target's level that matters, not the caster's
local RankWatch_Target_Level = {
	[(GetSpellInfo(  139))] = true, -- "Renew"
	[(GetSpellInfo(61295))] = true, -- "Riptide"
	[(GetSpellInfo(33763))] = true, -- "Lifebloom"
	[(GetSpellInfo(  774))] = true, -- "Rejuvenation"
	[(GetSpellInfo(48438))] = true, -- "Wild Growth"
	[(GetSpellInfo( 8936))] = true, -- "Regrowth"
	[(GetSpellInfo(  976))] = true, -- "Shadow Protection"
	[(GetSpellInfo(27683))] = true, -- "Prayer of Shadow Protection"
	[(GetSpellInfo( 1243))] = true, -- "Power Word: Fortitude"
	[(GetSpellInfo(21562))] = true, -- "Prayer of Fortitude"
	[(GetSpellInfo(14752))] = true, -- "Divine Spirit"
	[(GetSpellInfo(27681))] = true, -- "Prayer of Spirit"
	[(GetSpellInfo( 1126))] = true, -- "Mark of the Wild"
	[(GetSpellInfo(21849))] = true, -- "Gift of the Wild"
	[(GetSpellInfo(23028))] = true, -- "Arcane Brilliance"
	[(GetSpellInfo(61316))] = true, -- "Dalaran Brilliance"
	[(GetSpellInfo(  467))] = true, -- "Thorns"
	[(GetSpellInfo(19740))] = true, -- "Blessing of Might"
	[(GetSpellInfo(19742))] = true, -- "Blessing of Wisdom"
	[(GetSpellInfo(25782))] = true, -- "Greater Blessing of Might"
	[(GetSpellInfo(25894))] = true, -- "Greater Blessing of Wisdom"
	[(GetSpellInfo( 1459))] = true, -- "Arcane Intellect"
	[(GetSpellInfo( 1008))] = true, -- "Amplify Magic"
	[(GetSpellInfo(  604))] = true, -- "Dampen Magic"
	[(GetSpellInfo(   17))] = true, -- "Power Word: Shield"
}

local _G = getfenv(0)
local band = _G.bit.band

RankWatchSettings = {
	enabled = true,
	levels = RANKWATCH_WHISPER_ALL,
	channel = RANKWATCH_CHANNEL_WHISPER,
	checkAllLevels = true,
	delay = 3,
	explain = true,
	interval = 300,
	reports = {},
	ignore = {}
}

local queuedReports = { }

function RankWatch_ChatMsg(msg, player)
	if not player or player == "player" or player == UnitName("player") then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	else
		SendChatMessage(msg, "WHISPER", nil, player)
	end
end

local chat = RankWatch_ChatMsg

SLASH_RANKWATCH1 = '/rankwatch';
function SlashCmdList.RANKWATCH(msg, editbox)
	if (not msg or msg == "" or msg == "help") then
		chat(string.format(L["USAGE_01"],RankWatch_Version))
		chat(L["USAGE_02"])
		chat(L["USAGE_03"])
		chat(L["USAGE_04"])
		chat(L["USAGE_05"])
		chat(L["USAGE_06"])
		chat(L["USAGE_07"])
		chat(L["USAGE_08"])
		chat(L["USAGE_09"])
		chat(L["USAGE_10"])
		chat(L["USAGE_11"])
		chat(L["USAGE_11a"])
		chat(L["USAGE_12"])
		chat(L["USAGE_13"])
		chat(L["USAGE_14"])
		chat(L["USAGE_15"])
		chat(L["USAGE_16"])
		chat(L["USAGE_17"])
		
		if RankWatchSettings.enabled then
			chat(L["RANKWATCH_ENABLED"])
			if RankWatchSettings.levels == RANKWATCH_WHISPER_SELF then
				chat(L["RANKWATCH_SELF_ONLY"])
			else
				local whisperLevel = L["ANY_LEVEL"]
				if RankWatchSettings.levels == RANKWATCH_WHISPER_80 then
					whisperLevel = L["LEVEL_80_ONLY"]
				end

				if  RankWatchSettings.channel == RANKWATCH_CHANNEL_PARTY then
					chat(string.format(L["RANKWATCH_CHANNEL_PARTY"],whisperLevel))
				elseif  RankWatchSettings.channel == RANKWATCH_CHANNEL_SAY then
					chat(string.format(L["RANKWATCH_CHANNEL_SAY"],whisperLevel))
				elseif  RankWatchSettings.channel == RANKWATCH_CHANNEL_WHISPER then
					chat(string.format(L["RANKWATCH_CHANNEL_WHISPER"],whisperLevel))
				else
					chat(L["RANKWATCH_CHANNEL_NOWHISPERS"])
				end

				if RankWatchSettings.channel and RankWatchSettings.explain then
					chat(L["RANKWATCH_CHANNEL_WHISPER_EXPLAIN"])
				else
					chat(L["RANKWATCH_CHANNEL_WHISPER_NOEXPLAIN"])
				end
			end
						
			if RankWatchSettings.channel then
				chat(string.format(L["NOT_REPORT_INTERVAL"],RankWatchSettings.interval))
			end
		else
			chat(L["RANKWATCH_DISABLED"])
		end
	elseif (msg == "enable") then
		RankWatchSettings.enabled = true
		chat(L["REPORT_DOWNRANKED"])
	elseif (msg == "disable") then
		RankWatchSettings.enabled = false
		chat(L["NOREPORT_DOWNRANKED"])
	elseif (msg == "report") then
		RankWatch_Report()
	elseif (msg == "clear") then
		RankWatchSettings.reports = { }
		chat(L["SEEN_LIST_CLEARED"])
	elseif (msg == "self" or msg == "whisper self") then
		RankWatchSettings.levels = RANKWATCH_WHISPER_SELF
		chat(L["RANKWATCH_SELF_ONLY"])
	elseif (msg == "80" or msg == "whisper 80") then
		RankWatchSettings.levels = RANKWATCH_WHISPER_80
		chat(L["REPORT_ONLY_80"])
		if not RankWatchSettings.channel then
			RankWatchSettings.channel = RANKWATCH_CHANNEL_WHISPER
		end
	elseif (msg == "all" or msg == "whisper all") then
		RankWatchSettings.levels = RANKWATCH_WHISPER_ALL
		chat(L["REPORT_ALL_LEVELS"])
		if not RankWatchSettings.channel then
			RankWatchSettings.channel = RANKWATCH_CHANNEL_WHISPER
		end
	elseif (msg == "whisper disable" or msg == "whisper none" or msg == "none") then
		RankWatchSettings.channel = RANKWATCH_CHANNEL_DISABLED
		chat(L["REPORT_ONLY_SELF"])
	elseif (msg == "party") then
		RankWatchSettings.channel = RANKWATCH_CHANNEL_PARTY
		chat(L["REPORT_GROUP_CHAT"])
	elseif (msg == "say") then
		RankWatchSettings.channel = RANKWATCH_CHANNEL_SAY
		chat(L["REPORT_SAY"])
	elseif (msg == "whisper") then
		RankWatchSettings.channel = RANKWATCH_CHANNEL_WHISPER
		chat(L["REPORT_WHISPER"])
	elseif (msg == "explain enable") then
		RankWatchSettings.explain = true
		chat(L["ADD_BOILERPLATE"])
	elseif (msg == "explain disable") then
		RankWatchSettings.explain = false
		chat(L["NO_BOILERPLATE"])
	elseif (msg == "ignore") then
		RankWatch_ReportIgnoreList()
	elseif (msg:match("^interval *%d+$")) then
		RankWatchSettings.interval = tonumber(msg:match("^interval *(%d+)$"))
	elseif (msg:match("^ignore ")) then
		local player = msg:match("^ignore (.*)")
		RankWatch_Ignore(player)
	elseif (msg:match("^watch ")) then
		local player = msg:match("^watch (.*)")
		RankWatch_Watch(player)
	else
		chat(L["INVALID_COMMAND"])
	end
end

function RankWatch_GetPartyType()
	if UnitInBattleground("player") then
		return "BATTLEGROUND"
	elseif UnitInRaid("player") then
		return "RAID"
	elseif UnitInParty("player") then
		return "PARTY"
	else
		return nil
	end
end

function RankWatch_GetSpellInfo(spellId)
	-- GetSpellInfo returns a string like "Rank 5", we want to convert that to a number.
	local spellName, spellRank = GetSpellInfo(spellId)
	local spellRankNum = tonumber(spellRank:match("%d+")) or 1
	return spellName, spellRankNum
end

local reportNewLevelTime = nil

function RankWatch_OnUpdate()

	-- For each spell in queuedReports, if the delay time has elapsed since it was queued
	-- then report it and remove it from the queue.
	
	for sourceName, spells in pairs(queuedReports) do
		for spellName, spellData in pairs(spells) do
			if spellData.qtime + RankWatchSettings.delay < GetTime() then
				if spellData.isMine then
					RankWatch_Whisper(sourceName, spellData.lowId, spellData.maxId, spellData.time, spellData.isFirstTime)
				elseif spellData.priority == RANKWATCH_PRIORITY_IGNORE then
					chat(string.format(L["ON_IGNORE_LIST"],sourceName,spellName,spellData.sender))
				elseif spellData.priority <= RANKWATCH_PRIORITY_MAX then
					chat(string.format(L["ALREADY_NOTIFIED"],sourceName,spellName,spellData.sender ))
				end
				spells[spellName] = nil
			end
		end
	end
	
	if reportNewLevelTime and reportNewLevelTime + RankWatchSettings.delay < GetTime() then
		RankWatch_LevelUp("player", select(2,UnitClass("player")), UnitLevel("player"))
		reportNewLevelTime = nil
	end
end

function RankWatch_OnLoad() 
  this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
  this:RegisterEvent("ADDON_LOADED");
  this:RegisterEvent("CHAT_MSG_ADDON");
  this:RegisterEvent("PLAYER_LEVEL_UP");
end

function RankWatch_OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, _, sender = ...
		if prefix == "RankWatch" then
	
			-- We received a message from another RankWatch user saying they observed a downranked spell.

			local sourceName, spellName, nr, mr, t, isFirstTime, ns = message:match("([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")
			local timestamp = tonumber(t)
			local priority = tonumber(ns)
			if not queuedReports[sourceName] then
				queuedReports[sourceName] = { }
			end
			
			local qr = queuedReports[sourceName][spellName]
			if qr then

				-- There's already a queued report for this spell from this source waiting to be reported.

				if qr.priority < priority then
					-- They have a bigger "priority" so they will report it if it needs to be reported.
					queuedReports[sourceName][spellName].priority = priority
					queuedReports[sourceName][spellName].isMine = false
					queuedReports[sourceName][spellName].sender = sender
				elseif qr.isFirstTime and not isFirstTime then
					-- They have sent the "first time" whisper, so we shouldn't
					queuedReports[sourceName][spellName].isFirstTime = false
				end
			else
				-- They saw something that we didn't, or haven't yet.
				queuedReports[sourceName][spellName] = {
					priority = priority, time = timestamp,
					isFirstTime = isFirstTime, isMine = false, sender = sender, qtime = GetTime()
				}
			end
		end
	elseif event == "ADDON_LOADED" then
		local addonName = ...;
		if addonName:lower() == "rankwatch" then
			
			-- Save their old setting if they've modified it
			if RankWatchSettings.repeatInterval then
				if not RankWatchSettings.interval and RankWatchSettings.repeatInterval > 120 then
					RankWatchSettings.interval = RankWatchSettings.repeatInterval
				end
				RankWatchSettings["repeatInterval"] = nil
			end
			
			if not RankWatchSettings.interval then
				RankWatchSettings.interval = 300
			end
			
			if type(RankWatchSettings.channel) == "nil" then
				RankWatchSettings.channel = RANKWATCH_CHANNEL_WHISPER
			end
			
			if not RankWatchSettings.levels then
				RankWatchSettings.levels = RANKWATCH_WHISPER_ALL
			end
			
			if not RankWatchSettings.delay then
				RankWatchSettings.delay = 3
			end
			
			if type(RankWatchSettings.checkAllLevels) == "nil" then
				RankWatchSettings.checkAllLevels = true
			end

			if type(RankWatchSettings.whisperAllLevels) == "nil" then
				RankWatchSettings.whisperAllLevels = false
			end

			-- if the setting doesn't exist, then the default is true
			if type(RankWatchSettings.explain) == "nil" then
				RankWatchSettings.explain = true
			end
			
			-- Make sure the keys are all lowercase			
			local newIgnore = {}
			for k, v in pairs(RankWatchSettings.ignore) do
				if type(v) == "string" then
					newIgnore[k:lower()] = v
				elseif v then
					newIgnore[k:lower()] = k
				end
			end
			RankWatchSettings.ignore = newIgnore
				
			if RankWatchSettings.enabled then
				chat(string.format(L["RANKWATCH_WELCOME_ENABLED"], RankWatch_Version))
				RankWatch_ReportIgnoreList()
			else
				chat(string.format(L["RANKWATCH_WELCOME_DISABLED"], RankWatch_Version))
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, combatEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = 
		...; -- Those arguments appear for all combat event variants.

		-- We only want to look at players who are level 80
		-- and at RANGE and SPELL_??? events
		-- because those are the only ones that have a rank

		if (band(sourceFlags, COMBATLOG_OBJECT_TYPE_MASK) == COMBATLOG_OBJECT_TYPE_PLAYER)
			and combatEvent:match("^SPELL")
			and combatEvent ~= "SPELL_AURA_REMOVED"
			and (RankWatchSettings.checkAllLevels or UnitLevel(sourceName) == 80) then

			-- The first ninth and tenth arguments describe the spell or ability dealing damage.
			local spellId, spellName = select(9, ...); -- Everything from 9th argument in ... onward
			local sourceLevel = UnitLevel(sourceName)
			
			-- Don't complain about people still leveling who just dinged.
			if sourceLevel < 80 and sourceName ~= UnitName("player") then
				sourceLevel = sourceLevel - 1
			end
			
			-- If we're buffing or HoTting someone lower level than us, then the level of the target
			-- determines the level of the buff or HoT which is applied.
			if RankWatch_Target_Level[spellName] then
				if (UnitName("target")) == destName then
					-- this makes UnitLevel work when the target is not in our group but is our target
					destName = "target"
				end
				if destName and UnitLevel(destName) < sourceLevel then
					sourceLevel = UnitLevel(destName)
				end
			end
			
			-- RankWatch_RankData contains rank, level, and (if there is a higher rank) the spellID of the next higher rank.
			local spellData = RankWatch_RankData[spellId];

			if spellData and spellData.rank then
				local maxRankId = spellId
				local maxRankData = spellData
				while (maxRankData.next and RankWatch_RankData[maxRankData.next].level <= sourceLevel) do
					maxRankId = maxRankData.next
					maxRankData = RankWatch_RankData[maxRankData.next]
				end
				
				-- Some spells are downranked for legitimate reasons. Don't report these spells.
				if (spellData.rank == 1 and RankWatch_Rank1_Allowed[spellName])
						or (spellData.rank == maxRankData.rank - 1 and RankWatch_RankMaxMinusOne_Allowed[spellName])
						or RankWatch_AnyRank_Allowed[spellName] then
					maxRankId = spellId
				end
				
				if maxRankId ~= spellId then
					local isFirstTime = false
					if (not RankWatchSettings.reports[sourceName]) then
						RankWatchSettings.reports[sourceName] = {}
						isFirstTime = true
					end
					
					local lastReport = RankWatchSettings.reports[sourceName][spellName];
					local lastTime = 0;
					if lastReport then
						lastTime = lastReport.time;
					end
					
					RankWatchSettings.reports[sourceName][spellName] = { time = timestamp, lowId = spellId, maxId = maxRankId };

					if (timestamp - lastTime > RankWatchSettings.interval) then
						RankWatch_SendReport(sourceName, spellId, maxRankId, timestamp, isFirstTime)
					end
				end
			end
		end
	elseif event == "PLAYER_LEVEL_UP" then
		reportNewLevelTime = GetTime()
	end
end

function RankWatch_Report()
	local seenSpells = false
	local lastSeenName = ""
	
	for sourceName, spells in pairs(RankWatchSettings.reports) do
		for spellName, spellData in pairs(spells) do
			if spellData.lowId then
				if not seenSpells then
					chat(L["REPORT_SEEN"])
					seenSpells = true;
				end
				if lastSeenName ~= sourceName then
					chat(sourceName .. ":")
					lastSeenName = sourceName
				end

				local lowRankName, lowRank = RankWatch_GetSpellInfo(spellData.lowId)
				local maxRankName, maxRank = RankWatch_GetSpellInfo(spellData.maxId)
				local spellLevel = RankWatch_RankData[spellData.maxId].level
				chat("  " .. string.format(L["RANKWATCH_REPORT_LINE_REPLACED"],
				"\124cff71d5ff\124Hspell:" .. spellData.lowId .. "\124h[" .. lowRankName .. "]\124h\124r",
				lowRank,spellLevel,
				"\124cff71d5ff\124Hspell:" .. spellData.maxId .. "\124h[" .. maxRankName .. "]\124h\124r",
				maxRank,date(L["DATE_FORMAT"], spellData.time)));
			end
		end
	end
	if not seenSpells then
		chat(L["RANKWATCH_REPORT_NONE_SEEN"])
	end
end

function RankWatch_Ignore(player)
	local p = player:lower()
	if (not RankWatchSettings.ignore[p]) then
		RankWatchSettings.ignore[p] = player
		chat(string.format(L["PLAYER_NOW_IGNORED"],player))
	else
		chat(string.format(L["PLAYER_ALREADY_IGNORED"],player))
	end
end

function RankWatch_Watch(player)
	local p = player:lower()
	if (RankWatchSettings.ignore[p]) then
		RankWatchSettings.ignore[p] = false
		chat(string.format(L["PLAYER_NOW_WATCHED"],player))
	else
		chat(string.format(L["PLAYER_ALREADY_WATCHED"], player))
	end
end

function RankWatch_ReportIgnoreList()
	local seenAny = false
	local s = L["IGNORED_PLAYERS"]
	
	for player, isIgnored in pairs(RankWatchSettings.ignore) do
		if isIgnored then
			if seenAny then
				s = s .. ", "
			else
				seenAny = true
			end
			
			-- the value used to be a boolean, if it's a string, then that's the player's name as entered.
			if type(isIgnored) == "string" then
				s = s .. isIgnored
			else
				s = s .. player
			end
		end
	end
	if seenAny then
		chat(s)
	else
		chat(L["NOONE_IGNORED"])
	end
end

function RankWatch_SendReport(sourceName, lowRankSpellId, maxRankSpellId, timestamp, isFirstTime)
	if (RankWatchSettings.enabled) then
	
		if RankWatchSettings.levels == RANKWATCH_WHISPER_SELF
			and not UnitIsUnit(sourceName, "player") then
			return
		end
		
		local lowRankName, lowRank = RankWatch_GetSpellInfo(lowRankSpellId)
		local maxRankName, maxRank = RankWatch_GetSpellInfo(maxRankSpellId)
		local spellLevel = RankWatch_RankData[maxRankSpellId].level
		
		if not RankWatchSettings.ignore[sourceName:lower()] then
			chat(string.format(L["LOCAL_SPELL_REPLACED"],sourceName,
				"\124cff71d5ff\124Hspell:" .. lowRankSpellId .. "\124h[" .. lowRankName .. "]\124h\124r",
				lowRank,spellLevel,
				"\124cff71d5ff\124Hspell:" .. maxRankSpellId .. "\124h[" .. maxRankName .. "]\124h\124r",
				maxRank,date(L["DATE_FORMAT"], timestamp)));
		end

		-- if we're not in a party or raid, then it's just us, that's all we have to do.
		local channel = RankWatch_GetPartyType()
		if not channel then return end
		
	-- Send out a message to notify other rankwatch users that we have observed a downranked spell
	-- this is done to prevent multiple whispers
	-- Cases:
	--   priority RANKWATCH_PRIORITY_IS_ME: we noticed that I have downranked - no other user should whisper me
	--   priority RANKWATCH_PRIORITY_IGNORE: we noticed that a user I have on ignore has downranked - no one should whisper this user
	--   If the user is not me and not ignored, and channel is set, then we pick a random priority from 1 to RANKWATCH_PRIORITY_MAX
	--   If we receive a message from another user with a higher priority (or special cases RANKWATCH_PRIORITY_IS_ME or RANKWATCH_PRIORITY_IGNORE)
	--      then we will not whisper (making the assumption that the other user will).
	--   If we don't receive a message from another user with a higher priority within 3 seconds,
	--      then we will send the whisper ourselves.
	
		local priority = math.random(RANKWATCH_PRIORITY_MAX)
		if sourceName == UnitName("player") then
			priority = RANKWATCH_PRIORITY_IS_ME
		elseif RankWatchSettings.ignore[sourceName:lower()] then
			priority = RANKWATCH_PRIORITY_IGNORE
		end
		
		-- If it's me or an ignored user, we always want to tell other rankwatchers.
		-- Otherwise, if we're not going to send a whisper ourselves, we don't need to
		-- tell them
		if (priority > RANKWATCH_PRIORITY_MAX or RankWatchSettings.channel) then
			if (priority <= RANKWATCH_PRIORITY_MAX) then
				if not queuedReports[sourceName] then
					queuedReports[sourceName] = { }
				end
				
				-- if there's already a queued report for this spell and user, it's because some other user has
				-- noticed it and already sent out the message. Let them deal with it.
				if queuedReports[sourceName][lowRankName] then
					priority = -1
				else
					queuedReports[sourceName][lowRankName] = {
						priority = priority, time = timestamp, lowId = lowRankSpellId, maxId = maxRankSpellId,
						isFirstTime = isFirstTime, isMine = true, qtime = GetTime(), sender = "player"
					}
				end
			end

			if priority >= 0 then
				local s = sourceName .. "\t" .. lowRankName .. "\t" .. lowRank .. "\t" .. maxRank .. "\t" .. timestamp .. "\t" .. tostring(isFirstTime) .. "\t" .. priority
				SendAddonMessage("RankWatch", s, channel)
			end
		end
	end
end

function RankWatch_Whisper(sourceName, lowId, maxId, timestamp, isFirstTime)
	if (RankWatchSettings.levels ~= RANKWATCH_WHISPER_SELF
		and RankWatchSettings.channel
		and (UnitLevel(sourceName) == 80 or RankWatchSettings.levels == RANKWATCH_WHISPER_ALL)
		and sourceName ~= UnitName("player")) then

		local channel = "WHISPER"
		if RankWatchSettings.channel == RANKWATCH_CHANNEL_SAY then
			channel = "SAY"
		elseif RankWatchSettings.channel == RANKWATCH_CHANNEL_PARTY then
			channel = RankWatch_GetPartyType()
		end

		local lowRankName, lowRank = RankWatch_GetSpellInfo(lowId)
		local maxRankName, maxRank = RankWatch_GetSpellInfo(maxId)
		local spellLevel = RankWatch_RankData[maxId].level

		if channel then
			SendChatMessage(string.format(L["WHISPER_SPELL_REPLACED_WARNING"], sourceName,
					"\124cff71d5ff\124Hspell:" .. lowId .. "\124h[" .. lowRankName .. "]\124h\124r",
					lowRank, spellLevel,
					"\124cff71d5ff\124Hspell:" .. maxId .. "\124h[" .. maxRankName .. "]\124h\124r",
					maxRank),
				channel, nil, sourceName)
		end
		
		if (isFirstTime and RankWatchSettings.explain) then
			chat(string.format(L["WHISPER_BOILERPLATE_PART1"], maxRankName, maxRank), sourceName)
			chat(L["WHISPER_BOILERPLATE_PART2"], sourceName)
		end
	end
end

function RankWatch_LevelUp(playerName, inputClass, inputLevel)
	local seenNew = false
	local factionName = UnitFactionGroup(playerName)
	
	local playerClass = inputClass
	if not playerClass then playerClass = select(2,UnitClass(playerName)) end
	
	local playerLevel = inputLevel
	if not playerLevel then playerLevel = UnitLevel(playerName) end
	
	for spellId, spellData in pairs(RankWatch_RankData) do
		if playerClass == spellData.class
			and playerLevel == spellData.level
			and (not spellData.faction or spellData.faction == factionName)
		then
			if not seenNew then
				chat(string.format(L["NEW_SPELLS"], playerLevel), playerName)
			end
			local realSpellName, realSpellRank = GetSpellInfo(spellId)
			local msg = "  \124cff71d5ff\124Hspell:" .. spellId .. "\124h[" .. realSpellName .. "]\124h\124r".. " " .. realSpellRank
			chat(msg, playerName)
			seenNew = true
		end
	end
end
