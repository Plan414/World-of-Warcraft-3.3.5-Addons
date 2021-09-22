local mod = Chatter:NewModule("Group Say (/gr)", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Group Say (/gr)"]

local GetNumPartyMembers = _G.GetNumPartyMembers
local IsInInstance = _G.IsInInstance
local GetNumPartyMembers = _G.GetNumPartyMembers
local GetNumRaidMembers = _G.GetNumRaidMembers
local SendChatMessage = _G.SendChatMessage

function mod:Decorate(frame)
	self:HookScript(_G[frame:GetName().."EditBox"], "OnTextChanged")
end

function mod:OnEnable()
	for i = 1, 10 do
		self:HookScript(_G["ChatFrame" .. i .. "EditBox"], "OnTextChanged")
	end	
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name.."EditBox"]
		if cf then
			self:HookScript(cf, "OnTextChanged")
		end
	end
	
	if not self.slashCommandRegistered then
		self:RegisterChatCommand("gr", "SendChatMessage")
		self.slashCommandRegistered = true
	end
end

function mod:OnTextChanged(obj)
	local text = obj:GetText()
	if text:sub(1, 4) == "/gr " then
		obj:SetText(self:GetGroupDistribution(true) .. text:sub(5));
		ChatEdit_ParseText(obj, 0)
	end
	self.hooks[obj].OnTextChanged(obj)
end

function mod:SendChatMessage(input)
	SendChatMessage(input, self:GetGroupDistribution())
end

function mod:GetGroupDistribution(slash)
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp") then
		return slash and "/bg " or "BATTLEGROUND"
	end
	if GetNumRaidMembers() > 0 then
		return slash and "/ra " or "RAID"
	end
	if GetNumPartyMembers() > 0 then
		return slash and "/p " or "PARTY"
	end
	return slash and "/s " or "SAY"
end

function mod:Info()
	return L["Provides a /gr slash command to let you speak in your group (raid, party, or battleground) automatically."]
end
