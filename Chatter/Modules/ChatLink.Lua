local mod = Chatter:NewModule("ChatLink", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Chat Link"]

local gsub = _G.string.gsub
local find = _G.string.find
local GetChannelName = _G.GetChannelName
local EnumerateServerChannels = _G.EnumerateServerChannels
local select = _G.select

local serverChannels = {}
local function excludeChannels(...)
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		serverChannels[name] = true
	end
end

function mod:Decorate(frame)
	if not self:IsHooked(frame,"AddMessage") then
		self:RawHook(frame, "AddMessage", true)
	end
end

function mod:OnEnable()
	excludeChannels(EnumerateServerChannels())
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:RawHook(cf, "AddMessage", true)
		end
	end
end

function mod:OnDisable()
end

function mod:ParseLinks(text)
	if not text then return nil end
	text = gsub(text, "{CLINK:item:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:talent:(%x+):([%d-]-:[%d-]-):([^}]-)}", "|c%1|Htalent:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:glyph:(%x+):([%d-]-:[%d-]-):([^}]-)}", "|c%1|Hglyph:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:enchant:(%x+):([%d-]-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:spell:(%x+):([%d-]-):([^}]-)}", "|c%1|Hspell:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:quest:(%x+):([%d-]-):([%d-]-):([^}]-)}", "|c%1|Hquest:%2:%3|h[%4]|h|r")
	text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
	text = gsub(text, "{CLINK:trade:(%x+):(%-?%d-:%-?%d-:.*:.*):([^}]-)}", "|c%1|Htrade:%2|h[%3]|h|r")
	--	{CLINK:achievement:ffffff00:780:00000000001ED5C3:1:12:16:8:4294967295:4294967295:4294967295:4294967295:Explore Redridge Mountains}
	text = gsub(text, "{CLINK:achievement:(%x+):(%-?%d-:%-?%x-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-:%-?%d-):([^}]-)}", "|c%1|Hachievement:%2|h[%3]|h|r")
	return text
end

function mod:AddMessage(frame, text, ...)
	return self.hooks[frame].AddMessage(frame, mod:ParseLinks(text), ...)
end

function mod:Info()
	return L["Lets you link items, enchants, spells, talents, achievements and quests in custom channels."]
end
