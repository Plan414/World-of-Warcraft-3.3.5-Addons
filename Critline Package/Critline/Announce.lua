local addonName, addon = ...
local L = addon.L

assert(addon.spellList, "Announce module requires spellList module.")

local lastTarget = ""

local announceFormat = format("%%s - %s: %%s %s: %%s", L["Normal"], L["Crit"])

local function announce(data, channel, target)
	local normal = data.normal and addon:ShortenNumber(data.normal.amount)
	local crit = data.crit and addon:ShortenNumber(data.crit.amount)
	local text = format(announceFormat, addon:GetFullSpellName(data.name, data.periodic, true), (normal or "-"), (crit or "-"))
	SendChatMessage(text, channel, nil, target)
end

local targetChannels = {
	WHISPER = "CRITLINE_ANNOUNCE_WHISPER",
	CHANNEL = "CRITLINE_ANNOUNCE_CHANNEL",
}

local function onClick(self, tree, channel)
	local popup = targetChannels[channel]
	if popup then
		StaticPopup_Show(popup, nil, nil, self.value)
	else
		announce(self.value, channel)
	end
	CloseDropDownMenus()
end

local channels = {
	"SAY",
	"GUILD",
	"PARTY",
	"RAID",
	"WHISPER",
	"CHANNEL",
}

for i, v in ipairs(channels) do
	channels[i] = {
		text = _G[v],
		func = onClick,
		notCheckable = true,
		arg2 = v,
	}
end

addon.spellList:AddSpellOption({
	text = L["Announce"],
	hasArrow = true,
	notCheckable = true,
	menuList = channels,
})

local function onShow(self)
	self.button1:Disable()
	self.editBox:SetText(lastTarget)
	self.editBox:HighlightText()
end

addon:CreatePopup("CRITLINE_ANNOUNCE_WHISPER", {
	text = L["Enter whisper target"],
	OnAccept = function(self, data)
		lastTarget = self.editBox:GetText()
		announce(data, "WHISPER", lastTarget:trim())
	end,
	OnShow = onShow,
}, true)

addon:CreatePopup("CRITLINE_ANNOUNCE_CHANNEL", {
	text = ADD_CHANNEL,
	OnAccept = function(self, data)
		lastTarget = self.editBox:GetText()
		local target = GetChannelName(lastTarget:trim())
		if target == 0 then
			addon:Message(L["Invalid channel. Please enter a valid channel name or ID."])
			return
		else
			announce(data, "CHANNEL", target)
		end
	end,
	OnShow = onShow,
}, true)
