local frame = CreateFrame("Frame")

LibStub("AceHook-3.0"):Embed(frame)

local strmatch = strmatch

-- GUILD_MOTD_TEMPLATE = "Guild Message of the Day: %s"; -- %s is the guild MOTD

local pattern = GUILD_MOTD_TEMPLATE:
	gsub("[-%%+*.()%[%]]", "%%%1"):
	gsub("%%%%s", "(.+)")

local gmotdData

function frame:AddMessage(frame, text, ...)
	local gmotd 
	if text then
		gmotd = strmatch(text, pattern)
	end
	if gmotd then
		gmotdData={text,...}
		self:UnhookAll()
	else
		return self.hooks[frame].AddMessage(frame, text, ...)
	end
end

frame:RawHook(ChatFrame1, "AddMessage", true)


local delay=2.5
frame:SetScript("OnUpdate", function(self, expired)
	delay=delay-expired
	if delay<0 then
		self:Hide()
		self:UnhookAll()
		if gmotdData then
			ChatFrame1:AddMessage(unpack(gmotdData))
			gmotdData=nil
		end
	end
end)
