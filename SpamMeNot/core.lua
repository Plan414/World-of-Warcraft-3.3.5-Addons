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

SpamMeNot.isBeta = false

local defaults = {
	profile = {
		showDebug = false,
		isSilent = false,
		monitorTrade = true,
		ignoreKnownAddOnChannels = true,
		blockRepeatedText = true,
		isLevelFiltering = true,
		filterLevel = 1,
		enabled = true,
		blockScore = 100,
		reportScore = 150,
		autoReport = true,
		updateMonitor = true,
		msgSpamBlocked = L["SpamMeNot has identified you as a possible spammer and has blocked your message."],
		msgLevelBlocked = L["Apologies, but I don't accept whispers from players of your level, in order to protect myself from spam."],
	},
	global = {
		totalSpamsBlocked = 0,
	}
}


function SpamMeNot:RegisterEventHandler(obj, func, handlesWhispers)
	self.eventHandlers:Register(obj, func, handlesWhispers)
end

function SpamMeNot:UnregisterEventHandler(obj, func)
	self.eventHandlers:Unregister(obj, func)
end

function SpamMeNot:RegisterCommonHandlers()

	-- see defaultHooks.lua	
	self.defaultHooks:Install()	
end

function SpamMeNot:DebugMsg(s)
	if self:IsShowDebug() then
		self:Print(s)
	end
end

function SpamMeNot:ChatCommand(input)
    if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(SpamMeNot, "smn", "SpamMeNot", input)
    end
end


function SpamMeNot:OnInitialize()	

	-- Get and santize some TOC values
	self.version = GetAddOnMetadata("SpamMeNot", "Version")
	self.versionMajor, self.versionMinor = self.version:match("(%d+).(%d+)")
	self.build = tonumber(GetAddOnMetadata("SpamMeNot", "X-Build"):match("%d+"))
	
	-- Init variables
	self.spamsBlocked = 0
	self.spamsReported = 0
	self.invitesBlocked = 0
	self.chatFrameInjectionCount = 0

	-- Ace3 stuff
	self.db = LibStub("AceDB-3.0"):New("SpamMeNotDB", defaults, "profile")	
	self:SetupOptions()
    self:RegisterChatCommand("smn", "ChatCommand")
    self:RegisterChatCommand("SpamMeNot", "ChatCommand")
    self.AceHook = LibStub("AceHook-3.0")
	
    -- Create some objects
    self.players = self.Players:new()
    self.analyzer = self.Analyzer:new()
    self.filter = self.Filter:new()
    self.whisperHold = self.WhisperHold:new()
    self.who = self.Who:new()
    self.eventHandlers = self.EventHandlers:new()
    self.spammers = self.Spammers:new()
    self.tradeMon = self.TradeMon:new()
    self.defaultHooks = self.DefaultHooks:new()
    self.gui = self.GUI:New()
    self.updateMonitor = self.UpdateMonitor:New()
    
    self:RegisterCommonHandlers()
                       
    self:SetEnabledState(self.db.profile.enabled)          
    self:DebugMsg("OnInitialize() done")
            
end

function SpamMeNot:GetVersion()
	return self.versionMajor, self.versionMinor, self.build
end

function SpamMeNot:OnPulse()
	self.whisperHold:Pulse()
	self.tradeMon:Pulse()
end

function SpamMeNot:OnEnable()
    -- Register for events
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_SAY")
	self:RegisterEvent("CHAT_MSG_YELL")
	self:RegisterEvent("CHAT_MSG_EMOTE")
	self:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
	self:RegisterEvent("CHAT_MSG_CHANNEL")	
	self:RegisterEvent("CHAT_MSG_DND")
	self:RegisterEvent("CHAT_MSG_AFK")
	--self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
	--self:RegisterEvent("CHAT_MSG_SYSTEM")	
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", SpamMeNot.ChatFrameFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", SpamMeNot.ChatFrameFilter)
	
	-- ChatFrame_OnHyperlinkShow
	self.AceHook:RawHook("SetItemRef", function(ref, link, button)
		if ref then
			local t,name = ref:match("(%a+):(%a+)")
			if t == "SpamMeNot" then
				SpamMeNot.gui:ShowSpam(name)
			else
				SpamMeNot.AceHook.hooks["SetItemRef"](ref, link, button)
			end
		end	
	end, true)
	
	self:ScheduleRepeatingTimer(SpamMeNot.OnPulse, 2, self)	
	if self:IsUpdateMonitorOn() then
		self.updateMonitor:Enable()		
	end
	
	self:DebugMsg("Enabled");
end

function SpamMeNot:OnDisable()
    -- Called when the addon is disabled	
    self.AceHook:UnhookAll()
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_EMOTE", SpamMeNot.ChatFrameFilter)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", SpamMeNot.ChatFrameFilter)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", SpamMeNot.ChatFrameFilter)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_DND", SpamMeNot.ChatFrameFilter)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_AFK", SpamMeNot.ChatFrameFilter)
    self.updateMonitor:Disable()
    self:DebugMsg("Disabled");
end

-- Unfortunately ChatFrameFilter doesn't pass the actual event type and
-- Blizz are trying to do away with the global args for events but they
-- don't seem to have implemented a way to pass those args to these filters
-- so for now I'll have to use the global ones, which seem to be available
-- anyway.
-- 3.1 Update:  I believe they now pass the event in param 2 and then the regular params after that.

function SpamMeNot.ChatFrameFilter(something, event, ...)
	--[[
	SpamMeNot:Print(event)
	SpamMeNot:Print(select(1, ...))
	SpamMeNot:Print(select(2, ...))
	]]
	--local msg = select(1, ...)	
	--return SpamMeNot.filter:FilterEvent(event, msg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	--return SpamMeNot.filter:FilterEvent(event, ...), ... 
	SpamMeNot:DebugMsg("SpamMeNot.ChatFrameFilter() called.")
	return SpamMeNot.filter:FilterEvent(event, ...)
end

function SpamMeNot:DisableChatFrameInjection()
	self.chatFrameInjectionCount = self.chatFrameInjectionCount +1
end

function SpamMeNot:EnableChatFrameInjection()
	self.chatFrameInjectionCount = self.chatFrameInjectionCount -1
	if self.chatFrameInjectionCount < 0 then
		self.chatFrameInjectionCount = 0
	end
end

function SpamMeNot:IsEventFilteredElsewhere(event, ...)
	local result = false
	local chatFilters = ChatFrame_GetMessageEventFilters(event)
	
	if chatFilters then
		-- Some AddOns still use global args :(
		arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...;
		for _, filterFunc in pairs(chatFilters) do
			if filterFunc then
				if filterFunc(...) then
					result = true
					break
				end
			end
		end
	end
	
	if result then
		SpamMeNot:DebugMsg("Event IS filtered elsewhere!")
	else
		SpamMeNot:DebugMsg("Event is NOT filtered elsewhere.")
	end
	
	return result
end

function SpamMeNot:FakeIncomingWhisper(sender, lineID, text)		
	if not lineID then
		lineID = 0
	end
	--local message = string.format("%s %s: %s", "|Hplayer:" .. sender .. ":" .. lineID .. "|h[" .. sender .. "]|h", L["whispers"], text)	

	local oldThis = this
	local oldSelf = self
	local oldEvent = event

	-- WoW 3 uses local args
	local arg1 = text
	local arg2 = sender
	local arg3 = ""
	local arg4 = ""
	local arg5 = ""
	local arg6 = ""
	local arg7 = 0
	local arg8 = ""
	local arg9 = ""
	local arg10 = ""
	local arg11 = lineID
	local arg12 = ""
	local event = "CHAT_MSG_WHISPER"
	
	self.filter:Disable()
	if not self:IsEventFilteredElsewhere(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12) then
		self.eventHandlers:FakeWhisper(sender, lineID, text)
	end
	self.filter:Enable()
	
	-- Standard chat box
	-- In some cases it can cause problems with other AddOns (WIM for example) if
	-- we inject a new whisper in to the chat frame. 	
	if self.chatFrameInjectionCount == 0 then		
		for i=1,NUM_CHAT_WINDOWS do			
			local chatWin = getglobal("ChatFrame"..i);
			if chatWin then			
				local channels = {GetChatWindowMessages(chatWin:GetID())}
				for x=1,#channels do
					if (channels[x] == "WHISPER") then
						
						self.filter:Disable()
						SpamMeNot:DebugMsg("Calling ChatFrame_OnEvent")
						-- Note that we are changing self and this here
						
						this = chatWin						
						self = chatWin	

						ChatFrame_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)					

						this = oldThis	
						self = oldSelf
						
						self.filter:Enable()										
						break
					end									
				end												
			end
		end
	end
	event = oldEvent			
end

function SpamMeNot:ShouldAutoReport(player)
	local res = false
	if (self:IsAutoReporting()) and (player:GetRating() >= self:GetReportScore()) then
		res = true
	end
	return res
end

function SpamMeNot:FlagSpammer(player)
	self.spammers:Add(player)
end

function SpamMeNot:UnflagSpammer(player)
	self.spammers:Remove(player)
end

function SpamMeNot:CHAT_MSG_SAY(...)
	--[[
		arg1:	chat message
		arg2:	author
		arg3:	language
		arg11:	lineID
		arg12:	SenderGUID?
	]]
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local language = select(4, ...)
	local lineID = select(12, ...)
	
	local spam = false
	local player = self.players:GetPlayer(author)
	if not player:IsWhiteListed() then
		if self.filter:FilterEvent(...) then
			spam = true
		end	
		player:AddEvidence(lineID, msg)
		
		if spam and player:GetRating() >= self:GetBlockScore() then
			self:FlagSpammer(player)
			player:IsSpammer()
			if self:ShouldAutoReport(player) then
				player:Report()
			end			
		end
		
	end	
end

function SpamMeNot:CHAT_MSG_YELL(...)
	--[[
		arg1:	chat message
		arg2:	author
		arg3:	language
		arg11:	lineID
	]]
	-- Same setup as CHAT_MSG_SAY
	self:CHAT_MSG_SAY(...)
end

function SpamMeNot:CHAT_MSG_EMOTE(...)
	--[[
		arg1:	chat message
		arg2:	author		
		arg11:	lineID
	]]
	-- The args are near enough the same so just call CHAT_MSG_SAY()
	self:CHAT_MSG_SAY(...)	
end

function SpamMeNot:CHAT_MSG_TEXT_EMOTE(...)

end

function SpamMeNot:CHAT_MSG_CHANNEL(...)
	--[[
		arg1:	chat message 
		arg2:	author 
		arg3:	language 
		arg4:	channel name with number ex: "1. General - Stormwind City" 
				zone is always current zone even if not the same as the 
				channel name 
		arg5:	target 
				second player name when two users are passed for a 
				CHANNEL_NOTICE_USER (E.G. x kicked y) 
		arg6:	AFK/DND/GM "CHAT_FLAG_"..arg6 flags 
		arg7:	zone ID used for generic system channels (1 for General, 
				2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 
				26 for LFG)	not used for custom channels or if you joined 
				an Out-Of-Zone channel ex: "General - Stormwind City" 
		arg8:	channel number 
		arg9:	channel name without number (this is _sometimes_ in lowercase) 
				zone is always current zone even if not the same as the 
				channel name 
		arg11:	spam id
	]]

	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local zoneID = select(8, ...)
	local lineID = select(12, ...)	
	local spam = false	
	local player = self.players:GetPlayer(author)
	
	if not player:IsWhiteListed() then
		if self.filter:FilterEvent(...) then
			spam = true
		end	
		player:AddEvidence(lineID, msg)
		
		if spam and player:GetRating() >= self:GetBlockScore() then
			self:FlagSpammer(player)
			self:IncSpamCount()
			if self:ShouldAutoReport(player) then
				player:Report()
			end
		end	
	end				
end

function SpamMeNot:CHAT_MSG_DND(...)
	self:DebugMsg("SpamMeNot:CHAT_MSG_DND()")
	
end

function SpamMeNot:CHAT_MSG_AFK(...)
	self:DebugMsg("SpamMeNot:CHAT_MSG_AFK()")
	
end

function SpamMeNot:CHAT_MSG_WHISPER(...)
	self:DebugMsg("SpamMeNot:CHAT_MSG_WHISPER()")
	--[[
		arg1:	Message received 
		arg2:	Author 
		arg3:	Language (or nil if universal, like messages from GM) 
				(always seems to be an empty string; argument may have been 
				kicked because whispering in non-standard language doesn't 
				seem to be possible [any more?]) 
		arg6:	status (like "DND" or "GM") 
		arg7:	(number) message id (for reporting spam purposes?) (default: 0) 
		arg8:	(number) unknown (default: 0) 	
		
		
		This definition is from WoW Wiki but to the best of my knowledge
		arg11 is the spam ID		
	]]
	local event = select(1, ...)
	local msg = select(2, ...)
	local author = select(3, ...)
	local status = select(7, ...)
	local lineID = select(12, ...)

	local filtered = false
	local player = self.players:GetPlayer(author)
	
	self:DebugMsg("msg = " .. msg)
	self:DebugMsg("author = " .. author)
	self:DebugMsg("status = " .. status)
	self:DebugMsg("lineID = " .. lineID)
	if player:IsWhiteListed() then
		self:DebugMsg("Player is whitelisted.")
	else
		self:DebugMsg("Player is not whitelisted.")
	end
	
	if not player:IsWhiteListed() and (status ~= "GM") then
		if self.filter:FilterEvent(...) then
			-- on a whisper it may just be filtered because the who hasn't
			-- come back yet.  It's not necessarily spam.
			filtered = true
		end	
		player:AddEvidence(lineID, msg)
		
		if player:GetRating() >= self:GetBlockScore() or player:IsSpammer() then
			self:FlagSpammer(player)
			player:InformSpamBlock()
			self:IncSpamCount()
			if self:ShouldAutoReport(player) then
				player:Report()
			end		
		elseif (self:IsLevelFiltering() and not player:IsWhoOK()) or player:HasMsgInHold() then			
			self.whisperHold:Add(lineID, author, msg)
		end

	end		
end

function SpamMeNot:GetSpamsBlocked()
	return self.spamsBlocked
end

function SpamMeNot:GetSpamsReported()
	return self.spamsReported
end

function SpamMeNot:GetInvitesBlocked()
	return self.invitesBlocked
end

function SpamMeNot:GetTotalSpamsBlocked()
	return self.db.account.totalSpamsBlocked
end

function SpamMeNot:IncSpamCount()
	self.spamsBlocked = self.spamsBlocked +1
	self.db.global.totalSpamsBlocked = self.db.global.totalSpamsBlocked +1
end

function SpamMeNot:IncInvitesBlocked()
	self.invitesBlocked = self.invitesBlocked +1
end

function SpamMeNot:SpamsReported()
	self.spamsReported = self.spamsReported +1	
end

function SpamMeNot:Show()
	self.gui:Show()
end

function SpamMeNot:IsBeta()
	return self.isBeta
end

function SpamMeNot:Test()
	local p1 = self.players:GetPlayer("Jaybe")
	local p2 = self.players:GetPlayer("Kebian")
	
	if p1 == p2 then
		self:Print("Both player references are the same.")
	else
		self:Print("Player references are different.")
	end
	
	p1:AddEvidence(1, "This is Jaybe's.")
	p2:AddEvidence(2, "This is Kebian's.")
	self:Print("Jaybe: " .. p1:GetEvidenceAsString())
	self:Print("Kebian: " .. p2:GetEvidenceAsString())

	self:Print("Jaybe's name is " .. p1.name)
	self:Print("Kebian's name is " .. p2.name)

	if p1.evidence == p2.evidence then
		self:Print("Both player evidence references are the same.")
	else
		self:Print("Player evidence references are different.")
	end		
end
