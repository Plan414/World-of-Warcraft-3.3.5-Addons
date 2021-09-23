local QuickAuctions = select(2, ...)
QuickAuctions = LibStub("AceAddon-3.0"):NewAddon(QuickAuctions, "QuickAuctions", "AceEvent-3.0")
QuickAuctions.status = {}

local L = QuickAuctions.L
local status = QuickAuctions.status
local statusLog, logIDs, lastSeenLogID = {}, {}

-- Addon loaded
function QuickAuctions:OnInitialize()
	self.defaults = {
		profile = {
			noCancel = {default = false},
			autoFallback = {default = false},
			undercut = {default = 0},
			postTime = {default = 12},
			bidPercent = {default = 1.0},
			fallback = {default = 0},
			fallbackCap = {default = 5},
			threshold = {default = 0},
			postCap = {default = 4},
			perAuction = {default = 1},
			leavingInBag = {default = 0},
			priceThreshold = {default = 10},
			ignoreStacks = {default = 1000},
			groupStatus = {},
			categories = {},
		},
		char = {
			autoMail = false,
		},
		global = {
			summaryItems = {},
			groups = {},
			infoID = -1,
			hideUncraft = false,
			playSound = true,
			cancelBinding = "",
			showStatus = false,
			smartUndercut = false,
			smartCancel = true,
			cancelWithBid = false,
			superScan = false,
			hideHelp = false,
			autoMail = false,
		},
		realm = {
			crafts = {},
			craftQueue = {},
		},
		factionrealm = {
			player = {},
			whitelist = {},
			mail = {},
		},
	}
	
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("QuickAuctionsDB", self.defaults, true)
	self.Scan = self.modules.Scan
	self.Manage = self.modules.Manage
	self.Split = self.modules.Split
	self.Post = self.modules.Post
	self.Summary = self.modules.Summary
	self.Tradeskill = self.modules.Tradeskill
	self.Status = self.modules.Status
	self.Mail = self.modules.Mail
		
	-- Add this character to the alt list so it's not undercut by the player
	self.db.factionrealm.player[UnitName("player")] = true
	
	-- Move to the global DB
	if( QuickAuctions.db.profile.groups ) then
		QuickAuctions.db.global.groups = CopyTable(QuickAuctions.db.profile.groups)
		QuickAuctions.db.profile.groups = nil
	end
	
	if( QuickAuctions.db.global.warned ) then
		QuickAuctions.db.global.infoID = 1
		QuickAuctions.db.global.warned = nil
	end
	
	-- Reset settings
	if( QuickAuctionsDB.revision ) then
		for key in pairs(QuickAuctionsDB) do
			if( key ~= "profileKeys" and key ~= "profiles" ) then
				QuickAuctionsDB[key] = nil
			end
		end
	end

	-- Move the craft list from factionrealm to realm
	if( self.db.factionrealm.crafts ) then
		self.db.factionrealm.craftQueue = nil
		self.db.realm.crafts = CopyTable(self.db.factionrealm.crafts)
		self.db.factionrealm.crafts = nil
	end
	
	-- Wait for auction house to be loaded
	self:RegisterMessage("QA_AH_LOADED", "AuctionHouseLoaded")
	self:RegisterMessage("QA_START_SCAN", "LockButtons")
	self:RegisterMessage("QA_STOP_SCAN", "UnlockButtons")
	self:RegisterMessage("QA_AH_CLOSED", "UnlockButtons")
	self:RegisterEvent("ADDON_LOADED", function(event, addon)
		if( addon == "Blizzard_AuctionUI" ) then
			QuickAuctions:UnregisterEvent("ADDON_LOADED")
			QuickAuctions:SendMessage("QA_AH_LOADED")
		end
	end)
	
	if( IsAddOnLoaded("Blizzard_AuctionUI") ) then
		self:UnregisterEvent("ADDON_LOADED")
		self:SendMessage("QA_AH_LOADED")
	end
	
	self:ShowInfoPanel()
end

function QuickAuctions:WipeLog()
	lastSeenLogID = 0
	
	-- This will force it to create new rows for any new logs without having to wipe all of them
	table.wipe(logIDs)
	
	if( #(statusLog) > 0 ) then
		self:Log("-------------------------------")
	else
		self:UpdateStatusLog()
	end
end

-- If you only pass message, it will assume the next line is going to be a new one
-- passing an ID will make it use that same line unless the ID changed, pretty much just an automated new line method
function QuickAuctions:Log(id, msg)
	if( not id ) then return end
	if( not msg and id ) then msg = id end
	
	if( not logIDs[id] ) then
		logIDs[id] = #(statusLog) + 1
	end
	
	statusLog[logIDs[id]] = msg or ""
	
	-- Force the scroll bar to the bottom while posting, assuming they haven't scrolled within 10 seconds
	local scrollBar = QALogScrollFrameScrollBar
	local maxValue = scrollBar and select(2, scrollBar:GetMinMaxValues())
	if( scrollBar and scrollBar:GetValue() < maxValue ) then
		scrollBar:SetValue(maxValue)
	else
		self:UpdateStatusLog()
	end
end

function QuickAuctions:UpdateStatusLog()
	local self = QuickAuctions
	local totalLogs = #(statusLog)
	if( not self.statusFrame or not self.statusFrame:IsVisible() ) then
		local waiting = totalLogs - (lastSeenLogID or 0)
		if( waiting > 0 ) then
			self.buttons.log:SetFormattedText(L["Log (%d)"], waiting)
			self.buttons.log.tooltip = string.format(L["%d log messages waiting"], waiting)
		else
			self.buttons.log:SetText(L["Log"])
			self.buttons.log.tooltip = self.buttons.log.startTooltip
		end
		return
	else
		self.buttons.log:SetText(L["Log"])
		self.buttons.log.tooltip = self.buttons.log.startTooltip

		lastSeenLogID = totalLogs
	end
	
	FauxScrollFrame_Update(self.statusFrame.scroll, totalLogs, #(self.statusFrame.rows) - 1, 16)
	
	local offset = FauxScrollFrame_GetOffset(self.statusFrame.scroll)
	for id, row in pairs(self.statusFrame.rows) do
		row.tooltip = statusLog[offset + id]
		row:SetText(row.tooltip)
		row:Show()
	end
	
	for i=totalLogs + 1, #(self.statusFrame.rows) do
		self.statusFrame.rows[i]:Hide()
	end
end

function QuickAuctions:AuctionHouseLoaded()
	-- This hides the <player>'s Auctions text
	AuctionsTitle:Hide()
	
	-- Hook auction OnHide to interrupt scans if we have to
	AuctionFrame:HookScript("OnHide", function(self)
		QuickAuctions:SendMessage("QA_AH_CLOSED")
	end)

	-- Block system messages for auctions being removed or posted
	local orig_ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler
	ChatFrame_SystemEventHandler = function(self, event, msg, ...)
		if( msg == ERR_AUCTION_REMOVED and status.isCancelling or msg == ERR_AUCTION_STARTED and status.isPosting ) then
			return true
		end
		
		return orig_ChatFrame_SystemEventHandler(self, event, msg, ...)
	end
	
	self.buttons = {}

	-- Tooltips!
	local function showTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end

	local function hideTooltip(self)
		GameTooltip:Hide()
	end
	
	-- Show log for posting
	local button = CreateFrame("Button", nil, AuctionFrameAuctions, "UIPanelButtonTemplate")
	button.tooltip = L["Displays the Quick Auctions log describing what it's currently scanning, posting or cancelling."]
	button.startTooltip = button.tooltip
	button:SetPoint("TOPRIGHT", AuctionFrameAuctions, "TOPRIGHT", 51, -15)
	button:SetWidth(90)
	button:SetHeight(18)
	button:SetText(L["Log"])
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip) 
	button:SetScript("OnShow", function(self)
		if( QuickAuctions.db.global.showStatus ) then
			self:LockHighlight()

			QuickAuctions:CreateStatus()
			QuickAuctions.statusFrame:Show()
		end
	end)
	button:SetScript("OnClick", function(self)
		QuickAuctions.db.global.showStatus = not QuickAuctions.db.global.showStatus

		if( QuickAuctions.db.global.showStatus ) then
			self:LockHighlight()

			QuickAuctions:CreateStatus()
			QuickAuctions.statusFrame:Show()
		else
			self:UnlockHighlight()
			
			if( QuickAuctions.statusFrame ) then
				QuickAuctions.statusFrame:Hide()
			end
		end
	end)
	
	self.buttons.log = button
	
	-- Scan our posted items
	local button = CreateFrame("Button", nil, AuctionFrameAuctions, "UIPanelButtonTemplate")
	button.tooltip = L["View a summary of what the highest selling of certain items is."]
	button:SetPoint("TOPRIGHT", self.buttons.log, "TOPLEFT", 0, 0)
	button:SetText(L["Summary"])
	button:SetWidth(90)
	button:SetHeight(18)
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip) 
	button:SetScript("OnClick", function(self)
		QuickAuctions.Summary:Toggle()
	end)
	
	self.buttons.summary = button
	
	-- Post inventory items
	local button = CreateFrame("Button", nil, AuctionFrameAuctions, "UIPanelButtonTemplate")
	button.tooltip = L["Post items from your inventory into the auction house."]
	button:SetPoint("TOPRIGHT", self.buttons.summary, "TOPLEFT", -25, 0)
	button:SetText(L["Post"])
	button:SetWidth(90)
	button:SetHeight(18)
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip)
	button:SetScript("OnClick", function(self)
		QuickAuctions.Manage:PostScan()
	end)
	button.originalText = button:GetText()
	
	self.buttons.post = button

	-- Scan our posted items
	local button = CreateFrame("Button", nil, AuctionFrameAuctions, "UIPanelButtonTemplate")
	button.tooltip = L["Cancels any posted auctions that you were undercut on."]
	button:SetPoint("TOPRIGHT", self.buttons.post, "TOPLEFT", -10, 0)
	button:SetText(L["Cancel"])
	button:SetWidth(90)
	button:SetHeight(18)
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip)
	button:SetScript("OnClick", function(self)
		QuickAuctions.Manage:CancelScan()
	end)
	button.originalText = button:GetText()
	
	self.buttons.cancel = button

	-- Status scans what items we have in our inventory/auction
	local button = CreateFrame("Button", nil, AuctionFrameAuctions, "UIPanelButtonTemplate")
	button.tooltip = L["Does a status scan that helps to identify auctions you can buyout to raise the price of a group your managing.\n\nThis will NOT automatically buy items for you, all it tells you is the lowest price and how many are posted."]
	button:SetPoint("TOPRIGHT", self.buttons.cancel, "TOPLEFT", -10, 0)
	button:SetText(L["Status"])
	button:SetWidth(80)
	button:SetHeight(18)
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip)
	button:SetScript("OnClick", function(self)
		QuickAuctions.Status:Scan()
	end)
	button.originalText = button:GetText()
	
	self.buttons.status = button
end

function QuickAuctions:GetSafeLink(link)
	link = link and string.match(link, "|H(.-):([-0-9]+):([0-9]+)|h")
	return link and string.gsub(link, ":0:0:0:0:0:0", "")
end

function QuickAuctions:GetEnchantLink(link)
	return link and tonumber(string.match(link, "enchant:(%d+)"))
end

function QuickAuctions:CreateStatus()
	if( self.statusFrame ) then return end
	
	-- Try and stop UIObjects from clipping the status frame
	local function fixFrame()
		local frame = QuickAuctions.statusFrame
		if( AuctionsScrollFrame:IsVisible() ) then
			frame:SetParent(AuctionsScrollFrame)
		else
			frame:SetParent(AuctionFrameAuctions)
		end
		
		frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 10)
		for _, row in pairs(frame.rows) do
			row:SetFrameLevel(frame:GetFrameLevel() + 1)
		end
		
		-- Force it to be visible still
		if( QuickAuctions.db.profile.showStatus ) then
			QuickAuctions.statusFrame:Show()
		end
	end
	
	AuctionsScrollFrame:HookScript("OnHide", fixFrame)
	AuctionsScrollFrame:HookScript("OnShow", fixFrame)

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

	local frame = CreateFrame("Frame", nil, AuctionsScrollFrame)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 0.95)
	frame:SetBackdropBorderColor(0.60, 0.60, 0.60, 1)
	frame:SetHeight(1)
	frame:SetWidth(1)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", AuctionsQualitySort, "BOTTOMLEFT", -2, -2)
	frame:SetPoint("BOTTOMRIGHT", AuctionsCloseButton, "TOPRIGHT", -5, 2)
	frame:SetScript("OnShow", function() QuickAuctions:UpdateStatusLog() end)
	frame:EnableMouse(true)
	frame:Hide()

	frame.scroll = CreateFrame("ScrollFrame", "QALogScrollFrame", frame, "FauxScrollFrameTemplate")
	frame.scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
	frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 1)
	frame.scroll:SetScript("OnVerticalScroll", function(self, value) FauxScrollFrame_OnVerticalScroll(self, value, 16, QuickAuctions.UpdateStatusLog) end)

	frame.rows = {}

	-- Tooltips!
	local function showTooltip(self)
		if( type(self.tooltip) == "string" and self.tooltip ~= "" ) then
			GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPLEFT")
			GameTooltip:SetText(self.tooltip, 1, 1, 1, nil, true)
			GameTooltip:Show()
		end
	end

	local function hideTooltip(self)
		GameTooltip:Hide()
	end

	for i=1, 21 do
		local button = CreateFrame("Button", nil, frame)
		button:SetWidth(1)
		button:SetHeight(16)
		button:SetPushedTextOffset(0, 0)
		button:SetScript("OnEnter", showTooltip)
		button:SetScript("OnLeave", hideTooltip)
		
		local text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text:SetFont(GameFontHighlight:GetFont(), 11)
		text:SetAllPoints(button)
		text:SetJustifyH("LEFT")
		text:SetTextColor(0.95, 0.95, 0.95, 1)
		button:SetFontString(text)
		
		if( i > 1 ) then
			button:SetPoint("TOPLEFT", frame.rows[i - 1], "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", frame.rows[i - 1], "BOTTOMRIGHT", 0, 0)
		else
			button:SetPoint("TOPLEFT", frame.scroll, "TOPLEFT", 2, 0)
			button:SetPoint("TOPRIGHT", frame.scroll, "TOPRIGHT", 0, 0)
		end

		frame.rows[i] = button
	end
	
	self.statusFrame = frame
	
	fixFrame()
end

function QuickAuctions:LockButtons()
	self.buttons.post:Disable()
	self.buttons.cancel:Disable()
	self.buttons.status:Disable()
end

function QuickAuctions:UnlockButtons()
	self.buttons.post:Enable()
	self.buttons.post:SetText(self.buttons.post.originalText)
	self.buttons.cancel:Enable()
	self.buttons.cancel:SetText(self.buttons.cancel.originalText)
	self.buttons.status:Enable()
	self.buttons.status:SetText(self.buttons.status.originalText)
end

function QuickAuctions:SetButtonProgress(type, current, total)
	self.buttons[type]:SetFormattedText("%d/%d", current, total)
end

-- Change log warning to the user
local infoMessages = {
	L["Read me, important information below!\n\nAs of 3.3 Blizzard requires that you use a hardware event (key press or mouse click) to cancel auctions, currently there is a loophole that allows you to get around this by letting you cancel as many auctions as you need for one hardware event."],
	L["This is a new info panel that will pop up when something changed in Quick Auctions that you should know, these messages will only show up once.\n\nSettings have been moved around to work better with profiles, groups and all misc smart cancel/etc settings are now global, while per-group settings are per profile.\nYou can change your profile depending on server or how aggressive you want to be without losing your general settings or your group through /quickauctions.\n\nBecause of the move in scope, general settings were reset, as well as auto mailing settings. Make sure you reconfigure them!"],
}

function QuickAuctions:ShowInfoPanel()
	local infoID = QuickAuctions.db.global.infoID
	QuickAuctions.db.global.infoID = #(infoMessages)
	if( infoID < 0 or infoID >= #(infoMessages) ) then return end
	
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:SetWidth(400)
	frame:SetHeight(285)
	frame:SetBackdrop({
		  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		  edgeSize = 26,
		  insets = {left = 9, right = 9, top = 9, bottom = 9},
	})
	frame:SetBackdropColor(0, 0, 0, 0.85)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

	frame.titleBar = frame:CreateTexture(nil, "ARTWORK")
	frame.titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	frame.titleBar:SetPoint("TOP", 0, 8)
	frame.titleBar:SetWidth(225)
	frame.titleBar:SetHeight(45)

	frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.title:SetPoint("TOP", 0, 0)
	frame.title:SetText("Quick Auctions")

	frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	frame.text:SetText(infoMessages[QuickAuctions.db.global.infoID])
	frame.text:SetPoint("TOPLEFT", 12, -22)
	frame.text:SetWidth(frame:GetWidth() - 20)
	frame.text:SetJustifyH("LEFT")
	frame:SetHeight(frame.text:GetHeight() + 70)

	frame.hide = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.hide:SetText(L["Ok"])
	frame.hide:SetHeight(20)
	frame.hide:SetWidth(100)
	frame.hide:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 8)
	frame.hide:SetScript("OnClick", function(self)
		self:GetParent():Hide()
	end)
end

-- Stolen from Tekkub!
local GOLD_TEXT = "|cffffd700g|r"
local SILVER_TEXT = "|cffc7c7cfs|r"
local COPPER_TEXT = "|cffeda55fc|r"

-- Truncate tries to save space, after 10g stop showing copper, after 100g stop showing silver
function QuickAuctions:FormatTextMoney(money, truncate)
	local gold = math.floor(money / COPPER_PER_GOLD)
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = math.floor(math.fmod(money, COPPER_PER_SILVER))
	local text = ""
	
	-- Add gold
	if( gold > 0 ) then
		text = string.format("%d%s ", gold, GOLD_TEXT)
	end
	
	-- Add silver
	if( silver > 0 and ( not truncate or gold < 100 ) ) then
		text = string.format("%s%d%s ", text, silver, SILVER_TEXT)
	end
	
	-- Add copper if we have no silver/gold found, or if we actually have copper
	if( text == "" or ( copper > 0 and ( not truncate or gold <= 10 ) ) ) then
		text = string.format("%s%d%s ", text, copper, COPPER_TEXT)
	end
	
	return string.trim(text)
end

-- Makes sure this bag is an actual bag and not an ammo, soul shard, etc bag
function QuickAuctions:IsValidBag(bag)
	if( bag == 0 or bag == -1 ) then return true end
	
	-- family 0 = bag with no type, family 1/2/4 are special bags that can only hold certain types of items
	local itemFamily = GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
	return itemFamily and ( itemFamily == 0 or itemFamily > 4 )
end

function QuickAuctions:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99Quick Auctions|r: %s", msg))
end

function QuickAuctions:Echo(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

if( IsAddOnLoaded("TestCode") ) then
	QuickAuctions.L = setmetatable(QuickAuctions.L, {
		__index = function(tbl, value)
			rawset(tbl, value, value)
			return value
		end,
	})
	
	_G["QuickAuctions"] = QuickAuctions
end

