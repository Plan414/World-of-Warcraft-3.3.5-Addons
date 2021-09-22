local mod = Chatter:NewModule("Chat Autolog")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Chat Autolog"]

function mod:OnEnable()
	self.isLogging = LoggingChat()
	LoggingChat(true)
end

function mod:OnDisable()
	LoggingChat(self.isLogging)
end

function mod:Info()
	return L["Automatically turns on chat logging."]
end
