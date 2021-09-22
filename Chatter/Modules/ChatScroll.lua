local mod = Chatter:NewModule("Mousewheel Scroll", "AceHook-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Mousewheel Scroll"]

local IsShiftKeyDown = _G.IsShiftKeyDown
local IsControlKeyDown = _G.IsControlKeyDown

local scrollFunc = function(self, arg1)
	-- prevent itemtooltips to be kept open when using LinkHover.
	HideUIPanel(GameTooltip)

	if arg1 > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:PageUp()
		else
			for i = 1, mod.db.profile.scrollLines do
				self:ScrollUp()
			end
		end
	elseif arg1 < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:PageDown()
		else
			for i = 1, mod.db.profile.scrollLines do
				self:ScrollDown()
			end
		end
	end
end

local defaults = { profile = { scrollLines = 1 } }
local options = {
	lines = {
		type = "range",
		name = L["Scroll lines"],
		desc = L["How many lines to scroll per mouse wheel click"],
		min = 1,
		max = 20,
		step = 1,
		bigStep = 1,
		get = function() return mod.db.profile.scrollLines end,
		set = function(info, v) mod.db.profile.scrollLines = v end
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace(self:GetName(), defaults)
	self:RegisterEvent("CVAR_UPDATE", "ChangedVars")
	self:RawHook("InterfaceOptionsSocialPanelChatMouseScroll_SetScrolling",true)
end

function mod:InterfaceOptionsSocialPanelChatMouseScroll_SetScrolling()
	-- We want to intercept this and handle it ourselves
end

function mod:ChangedVars(event,cvar,value)
	if cvar == "CHAT_MOUSE_WHEEL_SCROLL" then
		if value == "1" then
			for i = 1, NUM_CHAT_WINDOWS do
				local cf = _G[("%s%d"):format("ChatFrame", i)]
				cf:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
				cf:EnableMouseWheel(true)
			end
			for index,name in ipairs(self.TempChatFrames) do
				local cf = _G[name]
				if cf then
					cf:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
					cf:EnableMouseWheel(true)
				end
			end
		end
		if value == "0" and self:IsEnabled() then
			for i = 1, NUM_CHAT_WINDOWS do
				local cf = _G[("%s%d"):format("ChatFrame", i)]
				cf:SetScript("OnMouseWheel", scrollFunc)
				cf:EnableMouseWheel(true)
			end
			for index,name in ipairs(self.TempChatFrames) do
				local cf = _G[name]
				if cf then
					cf:SetScript("OnMouseWheel", scrollFunc)
					cf:EnableMouseWheel(true)
				end
			end
		end
	end
end

function mod:OnEnable()
	if GetCVar("chatMouseScroll") == "1" then
		return
	end
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[("%s%d"):format("ChatFrame", i)]
		cf:SetScript("OnMouseWheel", scrollFunc)
		if not cf:IsMouseWheelEnabled() then
			cf:EnableMouseWheel(true)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf:SetScript("OnMouseWheel", scrollFunc)
			if not cf:IsMouseWheelEnabled() then
				cf:EnableMouseWheel(true)
			end
		end
	end
end

function mod:Decorate(frame)
	if GetCVar("chatMouseScroll") == "1" then
		return
	end
	frame:SetScript("OnMouseWheel", scrollFunc)
	frame:EnableMouseWheel(true)
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G[("%s%d"):format("ChatFrame", i)]
		if GetCVarBool("chatMouseScroll") then
			cf:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
			if not cf:IsMouseWheelEnabled() then
				cf:EnableMouseWheel(true)
			end
		else
			cf:SetScript("OnMouseWheel", nil)
			if cf:IsMouseWheelEnabled() then
				cf:EnableMouseWheel(true)
			end
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if GetCVarBool("chatMouseScroll") then
			cf:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
			if not cf:IsMouseWheelEnabled() then
				cf:EnableMouseWheel(true)
			end
		else
			cf:SetScript("OnMouseWheel", nil)
			if cf:IsMouseWheelEnabled() then
				cf:EnableMouseWheel(true)
			end
		end
	end
end

function mod:Info()
	return L["Lets you use the mousewheel to page up and down chat."]
end

function mod:GetOptions()
	return options
end
