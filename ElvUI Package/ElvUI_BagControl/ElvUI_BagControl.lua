local E, L, V, P, G = unpack(ElvUI);
local BC = E:NewModule("BagControl", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
local B = E:GetModule("Bags")

local EP = LibStub("LibElvUIPlugin-1.0")
local addonName, addonTable = ...

local pairs = pairs

P["BagControl"] = {
	["Enabled"] = false,
	["Open"] = {
		["Mail"] = true,
		["Vendor"] = true,
		["Bank"] = true,
		["GB"] = true,
		["AH"] = true,
		["TS"] = true,
		["Trade"] = true
	},
	["Close"] = {
		["Mail"] = true,
		["Vendor"] = true,
		["Bank"] = true,
		["GB"] = true,
		["AH"] = true,
		["TS"] = true,
		["Trade"] = true
	}
}

function BC:InsertOptions()
	E.Options.args.plugins.args.BagControl = {
		type = "group",
		childGroups = "tab",
		name = L["Bag Control"],
		get = function(info) return E.db.BagControl[info[#info]] end,
		set = function(info, value) E.db.BagControl[info[#info]] = value end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Bag Control"]
			},
			Enabled = {
				order = 2,
				type = "toggle",
				name = L["Enable"],
				set = function(info, value) E.db.BagControl[info[#info]] = value; BC:Update() end,
				disabled = function() return not B.Initialized end
			},
			Open = {
				order = 3,
				type = "group",
				name = L["Open bags when the following windows open:"],
				guiInline = true,
				get = function(info) return E.db.BagControl.Open[info[#info]] end,
				set = function(info, value) E.db.BagControl.Open[info[#info]] = value end,
				disabled = function() return not B.Initialized or not E.db.BagControl.Enabled end,
				args = {
					Mail = {
						order = 1,
						type = "toggle",
						name = MINIMAP_TRACKING_MAILBOX
					},
					Vendor = {
						order = 2,
						type = "toggle",
						name = MERCHANT
					},
					Bank = {
						order = 3,
						type = "toggle",
						name = L["Bank"]
					},
					GB = {
						order = 4,
						type = "toggle",
						name = GUILD_BANK
					},
					AH = {
						order = 5,
						type = "toggle",
						name = BUTTON_LAG_AUCTIONHOUSE
					},
					TS = {
						order = 6,
						type = "toggle",
						name = TRADESKILLS
					},
					Trade = {
						order = 7,
						type = "toggle",
						name = TRADE
					}
				}
			},
			Close = {
				order = 4,
				type = "group",
				name = L["Close bags when the following windows close:"],
				guiInline = true,
				get = function(info) return E.db.BagControl.Close[info[#info]] end,
				set = function(info, value) E.db.BagControl.Close[info[#info]] = value end,
				disabled = function() return not B.Initialized or not E.db.BagControl.Enabled end,
				args = {
					Mail = {
						order = 1,
						type = "toggle",
						name = MINIMAP_TRACKING_MAILBOX
					},
					Vendor = {
						order = 2,
						type = "toggle",
						name = MERCHANT
					},
					Bank = {
						order = 3,
						type = "toggle",
						name = L["Bank"]
					},
					GB = {
						order = 4,
						type = "toggle",
						name = GUILD_BANK
					},
					AH = {
						order = 5,
						type = "toggle",
						name = BUTTON_LAG_AUCTIONHOUSE
					},
					TS = {
						order = 6,
						type = "toggle",
						name = TRADESKILLS
					},
					Trade = {
						order = 7,
						type = "toggle",
						name = TRADE
					}
				}
			}
		}
	}
end

local OpenEvents = {
	["MAIL_SHOW"] = "Mail",
	["MERCHANT_SHOW"] = "Vendor",
	["BANKFRAME_OPENED"] = "Bank",
	["GUILDBANKFRAME_OPENED"] = "GB",
	["AUCTION_HOUSE_SHOW"] = "AH",
	["TRADE_SKILL_SHOW"] = "TS",
	["TRADE_SHOW"] = "Trade"
}

local CloseEvents = {
	["MAIL_CLOSED"] = "Mail",
	["MERCHANT_CLOSED"] = "Vendor",
	["BANKFRAME_CLOSED"] = "Bank",
	["GUILDBANKFRAME_CLOSED"] = "GB",
	["AUCTION_HOUSE_CLOSED"] = "AH",
	["TRADE_SKILL_CLOSE"] = "TS",
	["TRADE_CLOSED"] = "Trade"
}

local function EventHandler(self, event, ...)
	if not B.Initialized then return end

	if OpenEvents[event]  then
		if event == "BANKFRAME_OPENED" then
			B:OpenBank()
			if not E.db.BagControl.Open[OpenEvents[event]] then
				B.BagFrame:Hide()
			end
			return
		elseif E.db.BagControl.Open[OpenEvents[event]] then
			B:OpenBags()
			return
		else
			B:CloseBags()
			return
		end
	elseif CloseEvents[event] then
		if E.db.BagControl.Close[CloseEvents[event]] then
			B:CloseBags()
			return
		else
			B:OpenBags()
			return
		end
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", EventHandler)

local eventsRegistered = false
local function RegisterMyEvents()
	for event in pairs(OpenEvents) do
		EventFrame:RegisterEvent(event)
	end

	for event in pairs(CloseEvents) do
		EventFrame:RegisterEvent(event)
	end

	eventsRegistered = true
end

local function UnregisterMyEvents()
	for event in pairs(OpenEvents) do
		EventFrame:UnregisterEvent(event)
	end

	for event in pairs(CloseEvents) do
		EventFrame:UnregisterEvent(event)
	end

	eventsRegistered = false
end

function BC:Update()
	if E.db.BagControl.Enabled and not eventsRegistered then
		RegisterMyEvents()
	elseif not E.db.BagControl.Enabled and eventsRegistered then
		UnregisterMyEvents()
	end
end

function BC:Initialize()
	EP:RegisterPlugin(addonName, BC.InsertOptions)
	BC:Update()
end

local function InitializeCallback()
	BC:Initialize()
end

E:RegisterModule(BC:GetName(), InitializeCallback)