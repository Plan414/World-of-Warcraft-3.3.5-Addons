local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule("DataTexts")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["CustomTweaks"] and E.private["CustomTweaks"]["BagsTextFormat"] and true or false

--Cache global variables
local unpack = unpack
local join = string.join
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local displayString = ""
local lastPanel

P["CustomTweaks"]["BagsTextFormat"] = {
	["textFormat"] = "USED_TOTAL",
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Datatexts.args.options.args.BagsTextFormat = {
		type = "group",
		name = "BagsTextFormat",
		get = function(info) return E.db.CustomTweaks.BagsTextFormat[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.BagsTextFormat[info[#info]] = value; CT:UpdateDatatext() end,
		args = {
			textFormat = {
				order = 1,
				type = "select",
				name = L["Bags Text Format"],
				disabled = function() return not isEnabled end,
				values = {
					["FREE"] = L["Only Free Slots"],
					["USED"] = L["Only Used Slots"],
					["FREE_TOTAL"] = L["Free/Total"],
					["USED_TOTAL"] = L["Used/Total"],
				},
			},
		},
	}
end
CT.Configs["BagsTextFormat"] = ConfigTable
if not isEnabled then return; end

local function OnEvent(self, event, ...)
	lastPanel = self
	local free, total,used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		free, total = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i)
	end
	used = total - free
	local textFormat = E.db.CustomTweaks.BagsTextFormat.textFormat
	if textFormat == "FREE" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", free)
	elseif textFormat == "USED" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", used)
	elseif textFormat == "FREE_TOTAL" then
		self.text:SetFormattedText(displayString, L["Bags"]..": ", free, total)
	else
		self.text:SetFormattedText(displayString, L["Bags"]..": ", used, total)
	end
end

local function ValueColorUpdate(hex, r, g, b)
	local textFormat = E.db.CustomTweaks.BagsTextFormat.textFormat
	if textFormat == "FREE" or textFormat == "USED" then
		displayString = join("", "%s", hex, "%d|r")
	else
		displayString = join("", "%s", hex, "%d/%d|r")
	end

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end

function CT:UpdateDatatext()
	ValueColorUpdate(E["media"].hexvaluecolor, unpack(E["media"].rgbvaluecolor))
	if DT.RegisteredDataTexts and DT.RegisteredDataTexts["Bags"] and DT.RegisteredDataTexts["Bags"].eventFunc then
		DT.RegisteredDataTexts["Bags"].eventFunc = OnEvent
	end
	DT:LoadDataTexts()
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	E["valueColorUpdateFuncs"][ValueColorUpdate] = true
	CT.UpdateDatatext()
end)