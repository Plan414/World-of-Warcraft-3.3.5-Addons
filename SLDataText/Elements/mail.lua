--[[ 		     SLDataText Module: Mail 				]]
--[[ Author: Taffu  RevDate: 05/19/2012  Version: 5.0.0 ]]

local SLDT, MODNAME = SLDataText, "Mail"
if ( SLDT ) then SLDT.Mail = CreateFrame("Frame") end
local L = SLDT.Locale
local db, frame, text, tool

local handler = {
	NOMAILICON  = "Interface\\CURSOR\\UnableMail",
	NEWMAILICON = "Interface\\Icons\\INV_Letter_09",
	AHICON = "Interface\\Icons\\Ability_Paladin_JudgementofthePure",
	MAILSOUND = "Interface\\AddOns\\SLDataText\\Media\\mail.mp3",
	new = 0,
	total = 0,
	lastClose = 0,
	ignoreNext = false,
	mailChecked = false,
	iconString = "|TInterface\\CURSOR\\UnableMail:0|t",
	textString = L["No Mail"],
}

local function SetupToolTip()
	tool:SetScript("OnEnter", function(this)
		if ( not HasNewMail() ) then return end
		GameTooltip:SetOwner(this, db.aF)
		MinimapMailFrameUpdate()
		GameTooltip:Show()
	end)
	tool:SetScript("OnLeave", function(this) if ( GameTooltip:IsVisible() ) then GameTooltip:Hide() end end)
end

local function UpdateDisplay()
	if ( MiniMapMailFrame:IsVisible() ) then MiniMapMailFrame:Hide() end
	
	if ( db["ahAlert"] ) then
		-- Change icon to AHAlert icon
		handler.iconString = string.format("|T%s:0|t", handler.AHICON)
		handler.textString = L["AH Alert!"]
	elseif ( db["total"] and db["total"] > 0 ) or ( HasNewMail() and not handler.mailChecked ) then
		-- Change icon to Mail icon
		handler.iconString = string.format("|T%s:0|t", handler.NEWMAILICON)
		handler.textString = L["Mail!"]
	else
		-- Change icon to No Mail icon
		handler.iconString = string.format("|T%s:0|t", handler.NOMAILICON)
		handler.textString = L["No Mail"]
	end
end

local function IncomingMail()		
	if ( handler.ignoreNext ) then
		handler.ignoreNext = false
	else
		handler.new = 0
		if ( db["new"] ~= nil ) then
			handler.new = db["new"] + (1 * .5)
		end
		
		handler.total = 0
		if ( db["total"] ~= nil ) then
			handler.total = db["total"] + .5
		end
		
		if ( handler.mailChecked ) then
			handler.total = GetInboxNumItems() + handler.new
		end
			
		db["new"] = handler.new
		db["total"] = handler.total
		
		if ( db.playSounds ) then PlaySoundFile(handler.MAILSOUND) end
	end
end

local function ReadMsg(msg)
	local ahEvents = {
		[ERR_AUCTION_WON_S] = false,
		[ERR_AUCTION_SOLD_S] = false,
		[ERR_AUCTION_OUTBID_S] = true,
		[ERR_AUCTION_EXPIRED_S] = false,
		[ERR_AUCTION_REMOVED_S] = false,
	}
	
	for k, _ in pairs(ahEvents) do
		local search = string.gsub(k, "%%[^%s]+", "(.+)")
		local _, _, item = string.find(msg, search)
		
		if ( item ) then
			db["ahAlert"] = true
			
			if ( ahEvents[k[1]] ) then
				IncomingMail()
			end
			
			PlaySound("AuctionWindowOpen")
		end
	end
end

function SLDT.Mail:Enable()
	if ( db.enabled ) then
		SLDT:UpdateBaseText(self, db)
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("UPDATE_PENDING_MAIL")
		self:RegisterEvent("MAIL_INBOX_UPDATE")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("MAIL_SHOW")
		self:RegisterEvent("MAIL_CLOSED")
		self:SetScript("OnEvent", function(self, event, ...)
			if ( event == "PLAYER_ENTERING_WORLD" ) then
				handler.ignoreNext = true
			elseif ( event == "CHAT_MSG_SYSTEM" ) then
				local arg = ...
				ReadMsg(arg)
			elseif ( event == "UPDATE_PENDING_MAIL" ) then
				if ( (handler.lastClose + 5) > time() ) then 
					handler.ignoreNext = true
				end
				IncomingMail()
				UpdateDisplay()
			elseif ( event == "MAIL_INBOX_UPDATE" ) then
				db["new"], db["total"] = 0, GetInboxNumItems()
				UpdateDisplay()
			elseif ( event == "MAIL_SHOW" ) then
				handler.mailChecked = true
				db["ahAlert"] = false
				UpdateDisplay()
			elseif ( event == "MAIL_CLOSED" ) then
				handler.lastClose = time()
			end
			self:Refresh()
		end)
	end
	handler.ignoreNext = true
	self:Refresh()
end

function SLDT.Mail:Disable()
	if ( not db.enabled ) then
		self:UnregisterEvent("UPDATE_PENDING_MAIL")
		self:UnregisterEvent("MAIL_INBOX_UPDATE")
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:UnregisterEvent("MAIL_SHOW")
		self:UnregisterEvent("MAIL_CLOSED")
		self:SetScript("OnEvent", nil)
	end
	self:Refresh()
end

function SLDT.Mail:Refresh()
	if ( db.enabled or SLDataText.db.profile.configMode ) then
		if ( not self.firstRun ) then self.firstRun = true; SLDT:UpdateBaseText(self, db) end
		
		local count = ""
		if ( db["total"] and db["total"] > 0 ) then
			count = string.format("%u/%u", db["new"], db["total"])
		elseif ( HasNewMail() and not handler.mailChecked ) then
			count = L["Mail!"]
		end
		
		text:SetFormattedText("%s%s%s", db.showIcon and handler.iconString.." " or "", db.showText and handler.textString.." " or "", count)
		SLDT:UpdateBaseFrame(self, db)
	else
		if ( frame:IsVisible() and not SLDataText.db.profile.configMode ) then frame:Hide() end
	end
end

SLDT.Mail.optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Enabled"], [3] = "enabled" },
	[2] = { [1] = "toggle", [2] = L["Global Font"], [3] = "gfont" },
	[3] = { [1] = "toggle", [2] = L["Outline"], [3] = "outline" },
	[4] = { [1] = "toggle", [2] = L["Force Shown"], [3] = "forceShow" },
	[5] = { [1] = "toggle", [2] = L["Tooltip On"], [3] = "tooltipOn" },
	[6] = { [1] = "toggle", [2] = L["Show Icon"], [3] = "showIcon" },
	[7] = { [1] = "toggle", [2] = L["Show Text"], [3] = "showText" },
	[8] = { [1] = "toggle", [2] = L["Play Sounds"], [3] = "playSounds" },
	[9] = { [1] = "range", [2] = L["Font Size"], [3] = "fontSize", [4] = 6, [5] = 40, [6] = 1 },
	[10] = { [1] = "select", [2] = L["Font"], [3] = "font", [4] = SLDT.fontTbl },
	[11] = { [1] = "select", [2] = L["Justify"], [3] = "aP", [4] = SLDT.justTbl },
	[12] = { [1] = "text", [2] = L["Parent"], [3] = "anch" },
	[13] = { [1] = "select", [2] = L["Anchor"], [3] = "aF", [4] = SLDT.anchTbl },
	[14] = { [1] = "text", [2] = L["X Offset"], [3] = "xOff" },
	[15] = { [1] = "text", [2] = L["Y Offset"], [3] = "yOff" },
	[16] = { [1] = "select", [2] = L["Frame Strata"], [3] = "strata", [4] = SLDT.stratTbl },
}

local function OnInit()
	SLDT.Mail.db = SLDT.db:RegisterNamespace(MODNAME)
    SLDT.Mail.db:RegisterDefaults({
        profile = {
			name = "Mail",
			enabled = true,
			gfont = false,
			outline = false,
			forceShow = true,
			tooltipOn = true,
			showIcon = true,
			showText = true,
			playSounds = true,
			fontSize = 12,
			font = "Arial Narrow",
			aP = "CENTER",
			anch = "UIParent",
			aF = "CENTER",
			xOff = -100,
			yOff = 48,
			strata = "LOW",
			new = 0,
			total = 0,
			ahAlert = false,
        },
    })
	db = SLDT.Mail.db.profile
	
	SLDT.Modules = SLDT.Modules or {}
	if ( not SLDT.Modules[MODNAME] ) then table.insert(SLDT.Modules, { MODNAME, db }) end
	frame, text, tool = SLDT:SetupBaseFrame(SLDT.Mail)
	SetupToolTip()
	
	SLDT.Mail:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SLDT.Mail:Enable()
end

SLDT.Mail:RegisterEvent("PLAYER_ENTERING_WORLD")
SLDT.Mail:SetScript("OnEvent", OnInit)