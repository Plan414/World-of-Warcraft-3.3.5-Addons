--[[          	  Simple Light Data Text				]]
--[[ Author: Taffu	RevDate: 09/02/12	Version: 5.0.2	]]

-- Rev: Added free_nme's fix for string.lower and config line comparison @ slash commands


local addon, ns = ...
SLDataText = CreateFrame("Frame")
local SML, SLC, L = LibStub("LibSharedMedia-3.0"), LibStub("LibSL-1.0"), ns.L
local profileList, db = {}

function SLDataText:SetupBaseFrame(module)
	module.Frame = module.Frame or CreateFrame("Frame", "SLDT_" .. tostring(module.db.profile.name), UIParent)
	module.Tool = module.Tool or CreateFrame("Frame", nil, module.Frame)
	module.Text = module.Text or module.Frame:CreateFontString(nil, "OVERLAY")
	local frame, text, tool = module.Frame, module.Text, module.Tool
	
	frame:SetBackdrop({ 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true, tileSize = 16, edgeSize = 4,
		insets = { left = 0, top = 0, right = 0, bottom = 0 }
	})
	frame:SetBackdropColor(0,0,0,0)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(false)
	tool:EnableMouse(true)
	
	return frame, text, tool
end

function SLDataText:SetupPulseFrame(module)
	module.Pulse = module.Pulse or CreateFrame("Frame", nil, module.Frame)
	local pulse = module.Pulse
	pulse:SetBackdrop({ 
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\AddOns\\SLDataText\\Media\\glowTex",
		tile = true, tileSize = 16, edgeSize = 4,
		insets = { left = 3, top = 3, right = 3, bottom = 3 }
	})
	pulse:EnableMouse(false)
	pulse:SetBackdropColor(1,1,0,1)
	pulse:SetBackdropBorderColor(1,1,0,1)
	pulse:Hide()
	
	pulse:ClearAllPoints()
	pulse:SetPoint("CENTER", module.Frame, "CENTER", 0, 0)
	
	return pulse
end

function SLDataText:Pulse(module, start)
	module.Pulse = module.Pulse or self:SetupPulseFrame(module)
	if ( not module.Pulse.down ) then module.Pulse.down = false end
    
    if ( not start ) then
        if ( module.Pulse:IsShown() ) then module.Pulse:Hide() end
        module.Pulse:SetScript("OnUpdate", nil)
    else
        if ( not module.Pulse:IsShown() ) then module.Pulse:Show() end
        module.Pulse:SetFrameLevel(0)
        module.Pulse:SetScript("OnUpdate", function(self, elapsed)
            local step = abs(1/30)
            if ( self:GetAlpha() == 1 ) then
                module.Pulse.down = true; self:SetAlpha(self:GetAlpha()-step)
            elseif ( self:GetAlpha() == 0 ) then
                module.Pulse.down = false; self:SetAlpha(self:GetAlpha()+step)
            else
                if ( module.Pulse.down ) then
                    self:SetAlpha(self:GetAlpha()-step)
                else
                    self:SetAlpha(self:GetAlpha()+step)
                end
            end
        end)
    end
end

function SLDataText:UpdateBaseText(module, mdb)
	local font, gfont, gfontSize, text = SML:Fetch("font", mdb.font), SML:Fetch("font", db.gFont), db.gFontSize, module.Text
	text:SetFont(mdb.gfont and gfont or font, mdb.gfont and gfontSize or mdb.fontSize, mdb.outline and "THINOUTLINE" or nil)	
	if ( not mdb.outline ) then text:SetShadowColor(0,0,0,1); text:SetShadowOffset(1, -1) else text:SetShadowColor(0,0,0,0) end
	text:ClearAllPoints()
	text:SetPoint("CENTER", module.Frame, "CENTER", 0, 0)
end

local function SLDTAnchorFix(module, mdb)
	local reset, timer = CreateFrame("Frame"), 10
	reset:SetScript("OnUpdate", function(this, elapsed)
		if ( (GetTime() - elapsed) >= timer ) then
			reset:SetScript("OnUpdate", nil)
			SLDataText:UpdateBaseFrame(module, mdb)
		end
	end)
end

function SLDataText:UpdateBaseFrame(module, mdb)
	module.Frame:SetWidth(module.Text:GetWidth()); module.Frame:SetHeight(module.Text:GetHeight())
	module.Frame:ClearAllPoints()
	
	if ( string.sub(mdb.anch, 0, 5) == "SLDT_" ) then
		local found = false
		for k, v in pairs(SLDataText.Modules) do
			local frame = SLDataText[v[1]].Frame
			if ( frame:GetName() == mdb.anch ) then found = true end
		end
		if ( not found ) then
			SLDTAnchorFix(module, mdb)
		else
			module.Frame:SetParent(mdb.anch)
			module.Frame:SetPoint(mdb.aP, mdb.anch, mdb.aF, mdb.xOff, mdb.yOff)
		end
	else
		module.Frame:SetParent(mdb.anch)
		module.Frame:SetPoint(mdb.aP, mdb.anch, mdb.aF, mdb.xOff, mdb.yOff)	
	end
	
	module.Frame:SetFrameStrata(mdb.strata)
	module.Tool:SetAllPoints(module.Frame)
	if ( module.Pulse ) then
		module.Pulse:SetWidth(module.Frame:GetWidth()+8); module.Pulse:SetHeight(module.Frame:GetHeight()+8)
	end
	if ( not mdb.tooltipOn or db.configMode ) then module.Tool:EnableMouse(false) else module.Tool:EnableMouse(true) end
	if ( db.configMode ) then module.Frame:EnableMouse(true) else module.Frame:EnableMouse(false) end
	if ( not module.Frame:IsShown() ) then module.Frame:Show() end
end

function SLDataText:AddModule(modname, db)
	if ( not modname or modname == nil ) then error("SLDataText:AddModule(modname, db) - 'modname': string expected, cannot create module entry", 2) end
	if ( not db or db == nil ) then error("SLDataText:AddModule(modname, db) - 'db': table expected, cannot create module entry", 2) end
	
	self.Modules = self.Modules or {}
	if ( not self.Modules[modname] ) then
		table.insert(self.Modules, { modname, db })
	end
end

local function FadeOut(module)
	local step, f = 0.1, CreateFrame("Frame")
	if ( db.cFade ) then
		f:SetScript("OnUpdate", function()
			local mAlpha = module.Frame:GetAlpha()
			if ( mAlpha > 0 ) then module.Frame:SetAlpha(mAlpha-step)
			elseif ( mAlpha == 0 ) then f:SetScript("OnUpdate", nil); f = nil end
		end)
	end
end

local function FadeIn(module)
	local step, f = 0.1, CreateFrame("Frame")
	if ( db.cFade ) then
		f:SetScript("OnUpdate", function()
			local mAlpha = module.Frame:GetAlpha()
			if ( mAlpha < 1 ) then module.Frame:SetAlpha(mAlpha+step)
			elseif ( mAlpha == 1 ) then f:SetScript("OnUpdate", nil); f = nil end
		end)
	end
end

local function SLDT_ChangeMode(module, mdb)
	if ( db.configMode ) then
		module.Frame:Show()
		module.Frame:EnableMouse(true)
		module.Frame:SetBackdropColor(0,0,0,0.75)
		module.Tool:EnableMouse(false)
				
		module.Frame:SetMovable(true)
		module.Frame:SetScript("OnMouseDown", function(_, button) 
			if ( button == "LeftButton" ) then SLC:MoveSLFrame(module.Frame, mdb); module.Moving = true end
			if ( button == "RightButton" ) then SLC:OpenOptBox(module) end
		end)
		module.Frame:SetScript("OnMouseUp", function(_, button) 
			if ( button == "LeftButton" ) then SLC:StopSLFrame(module.Frame, mdb, module.Opt, mdb.name); module.Moving = false end
		end)
		module.Frame:SetScript("OnEnter", function(this)
			GameTooltip:SetOwner(this, "ANCHOR_TOP", 0, 6)
			GameTooltip:AddLine("|cffffffffConfig Mode|r")
			GameTooltip:AddDoubleLine("Left-Click", "Drag & Move", 1,1,0,1,1,1)
			GameTooltip:AddDoubleLine("Right-Click", "Open Menu", 1,1,0,1,1,1)
			GameTooltip:Show()
		end)
		module.Frame:SetScript("OnLeave", function(this) if ( GameTooltip:IsVisible() ) then GameTooltip:Hide() end end)
	else
		if ( not mdb.enabled ) then module.Frame:Hide() end
		module.Frame:EnableMouse(false)
		module.Frame:SetBackdropColor(0,0,0,0)
		module.Tool:EnableMouse(true)
		
		module.Frame:SetMovable(false)
		module.Frame:SetScript("OnMouseDown", nil)
		module.Frame:SetScript("OnMouseUp", nil)
	end
end

local function SLDT_Refresh()
	for k, v in pairs(SLDataText.Modules) do
		SLDataText:UpdateBaseText(SLDataText[v[1]], SLDataText[v[1]].db.profile)
		SLDataText[v[1]]:Refresh()
	end
end

function SLDataText:Refresh()
	for k, v in pairs(SLDataText.Modules) do
		self:UpdateBaseText(SLDataText[v[1]], SLDataText[v[1]].db.profile)
		SLDataText[v[1]]:Refresh()
	end
end

local optsTbl = {
	[1] = { [1] = "toggle", [2] = L["Combat Fade"], [3] = "cFade" },
	[2] = { [1] = "toggle", [2] = L["Class Colored"], [3] = "cCol" },
	[3] = { [1] = "range", [2] = L["Global Font Size"], [3] = "gFontSize", [4] = 6, [5] = 40, [6] = 1 },
	[4] = { [1] = "select", [2] = L["Global Font"], [3] = "gFont", [4] = SML:List("font") },
	[5] = { [1] = "range", [2] = L["TTScale"], [3] = "ttScale", [4] = 0.1, [5] = 2.0, [6] = 0.1 },
	[6] = { [1] = "desc", [2] = "ProfDesc", [3] = L["ProfDesc"] },
	[7] = { [1] = "profile", [2] = L["ProfNew"], [3] = "New", },
	[8] = { [1] = "profile", [2] = L["ProfCurrent"], [3] = "Current", },
	[9] = { [1] = "profile", [2] = L["ProfCopy"], [3] = "Copy", },
	[10] = { [1] = "profile", [2] = L["ProfDel"], [3] = "Delete", },
	[11] = { [1] = "profile", [2] = L["ProfReset"], [3] = "Reset", [4] = L["ProfResDesc"], },
}

SLASH_SLDT1 = L["/sldt"]
function SlashCmdList.SLDT(msg, _)
	if ( type(msg) == "string" and string.len(msg) > 1 ) then
		if ( string.lower(msg) == string.lower(L["config"]) ) then
			db.configMode = not db.configMode
			print(string.format("|cff6698FFSLDataText|r Configuration Mode |cffffff00%s|r.", db.configMode and "active" or "inactive"))
			for k, v in pairs(SLDataText.Modules) do
				SLDT_ChangeMode(SLDataText[v[1]], v[2])
				SLDataText[v[1]]:Refresh()
			end
		elseif ( string.lower(msg) == L["global"] ) then
			if ( not SLDataText.Opt ) then SLC:CreateMenu("SLDataText", SLDataText, optsTbl) end
			SLC:OpenOptBox(SLDataText)
		elseif ( SLDataText[msg] ) then
			SLC:OpenOptBox(SLDataText[msg])
		end
	else
		-- Help printout
		print("|cff6698FFSLDataText|r")
		print("|cffffff00/sldt|r - "..L["Command List"])
		print("|cffffff00/sldt "..L["config"].."|r - "..L["Toggle Configuration Mode"])
		print("|cffffff00/sldt "..L["global"].."|r - "..L["Open SLDataText Global Menu"])
		print("|cffffff00/sldt "..L["<module>"].."|r - "..L["Open Module Option Menu"])
		local modString = ""
		for k, v in pairs(SLDataText.Modules) do modString = string.format("%s %s", modString, v[1]) end
		print(L["Loaded Modules"]..":"..modString)
	end
end

local function OnInit()
	SLDataText.db = LibStub("AceDB-3.0"):New("SLDTDB")
	SLDataText.db:RegisterDefaults({
		profile = {
			cFade = true,
			cCol = true,
			gFont = "Arial Narrow",
			gFontSize = 12,
			configMode = false,
			ttScale = 1.0,
            modules = {
                ['*'] = true,
            },
		},
	})
	SLDataText.db.RegisterCallback("SLDataText", "OnProfileChanged", SLDT_Refresh)
	SLDataText.db.RegisterCallback("SLDataText", "OnProfileCopied", SLDT_Refresh)
	SLDataText.db.RegisterCallback("SLDataText", "OnProfileReset", SLDT_Refresh)
	db = SLDataText.db.profile
	
	-- Force configMode off OnLoad
	db["configMode"] = false
	-- Do this to ensure proper scaling of global menu to UIParent
	if ( not SLDataText.Frame ) then SLDataText.Frame = CreateFrame("Frame", nil, UIParent) end
	-- Kill OnInit
	SLDataText:UnregisterEvent("PLAYER_LOGIN")
	-- Get class color hex
	local class = select(2, UnitClass("player"))
	SLDataText.classColor = string.format("%02X%02X%02X", RAID_CLASS_COLORS[class].r*255, RAID_CLASS_COLORS[class].g*255, RAID_CLASS_COLORS[class].b*255)
	-- Setup Fade Functionality
	SLDataText:RegisterEvent("PLAYER_REGEN_ENABLED")
	SLDataText:RegisterEvent("PLAYER_REGEN_DISABLED")
	SLDataText:SetScript("OnEvent", function(_, event)
		if ( event == "PLAYER_REGEN_DISABLED" ) then
			-- In combat / fade out
			for _, v in pairs(SLDataText.Modules) do
				local module, mdb = SLDataText[v[1]], v[2]
				if ( not mdb.forceShow ) then
					FadeOut(module)
				end
			end
		elseif ( event == "PLAYER_REGEN_ENABLED" ) then
			-- Out of combat / fade in
			for _, v in pairs(SLDataText.Modules) do
				local module, mdb = SLDataText[v[1]], v[2]
				if ( not mdb.forceShow ) then
					FadeIn(module)
				end
			end
		end
	end)
end

SLDataText.Locale = L
SLDataText.fontTbl = SML:List("font")
SLDataText.justTbl = {
	[1] = "LEFT",
	[2] = "CENTER",
	[3] = "RIGHT",
}
SLDataText.anchTbl = {
	[1] = "TOPLEFT",
	[2] = "TOP",
	[3] = "TOPRIGHT",
	[4] = "LEFT",
	[5] = "CENTER",
	[6] = "RIGHT",
	[7] = "BOTTOMLEFT",
	[8] = "BOTTOM",
	[9] = "BOTTOMRIGHT",
}
SLDataText.stratTbl = {
	[1] = "BACKGROUND",
	[2] = "LOW",
	[3] = "MEDIUM",
	[4] = "HIGH",
	[5] = "DIALOG",
}

SLDataText:RegisterEvent("PLAYER_LOGIN")
SLDataText:SetScript("OnEvent", OnInit)
SLDataText.GlobalErr = "SLDataText Global is nil, %s module not created."