--[[        LibSLTip-1.0 - Interactive Tooltip Handler   		]]
--[[ Use to create & manage interactive and functional tooltips ]]

-- Rev 9/01/12: Revised Tooltip Max Width

local MAJOR, MINOR = "LibSLTip-1.0", 12
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
local function err(msg) ChatFrame1:AddMessage(string.format("LibSLTip: %s", msg)) end

local diaBG = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
local solBG = {
	bgFile = "Interface\\BUTTONS\\WHITE8X8",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
local anchTbl = { 
	["TOPLEFT"] = "BOTTOMLEFT", ["TOP"] = "BOTTOM", ["TOPRIGHT"] = "BOTTOMRIGHT",
	["LEFT"] = "TOPLEFT", ["CENTER"] = "TOP", ["RIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT", ["BOTTOM"] = "TOP", ["BOTTOMRIGHT"] = "TOPRIGHT",
}
local anchFix = { ["LEFT"] = "BOTTOMLEFT", ["CENTER"] = "BOTTOM", ["RIGHT"] = "BOTTOMRIGHT" }

local toolTips, cushion, lspace, resX, resY = {}, 10, 4
do
	-- I'm not doing this every time I anchor...if they change their resolution, screw 'em...they can ReloadUI
	local res = ({GetScreenResolutions()})[GetCurrentResolution()]
	resX, resY = string.split("x", res)
end

local function SmartAnchor(name, anchor)
	local top, bottom, left, right = anchor:GetTop(), anchor:GetBottom(), anchor:GetLeft(), anchor:GetRight()
	local xVal, yVal, fix, xBuff, pos = nil, nil, false, floor((resX * 0.3) / 2)
	
	-- Vertical check
	if 		( top > resY / 2 and bottom > resY / 2 ) 	then 	yVal = "TOP"
	elseif 	( top >= resY / 2 and bottom <= resY / 2 ) 	then 	yVal = nil
	elseif 	( top < resY / 2 and bottom < resY / 2 ) 	then 	yVal = "BOTTOM" end
	-- Horizontal check
	if 		( right + xBuff > resX / 2 and left - xBuff > resX / 2 ) 	then 	xVal = "RIGHT"
	elseif 	( right + xBuff >= resX / 2 and left - xBuff <= resX / 2 ) 	then 	xVal = nil
	elseif 	( right + xBuff < resX / 2 and left - xBuff < resX / 2 ) 	then 	xVal = "LEFT" end
	
	-- Put it all together, and what do you get?
	if ( yVal and xVal ) then
		pos = string.format("%s%s", yVal, xVal)
	else
		if ( xVal and yVal == nil ) then
			pos = xVal; fix = true
		elseif ( xVal == nil and yVal ) then
			pos = yVal -- Don't fix cause we can compensate for TOP or BOTTOM alignment
		else 
			pos = "CENTER"; fix = true
		end
	end
	
	toolTips[name].frame:ClearAllPoints()
	toolTips[name].frame:SetPoint(fix and anchFix[pos] or pos, anchor, anchTbl[pos], 0, 0)
end

local underlineFrame = CreateFrame("Frame", nil)
underlineFrame.tx = underlineFrame:CreateTexture()
underlineFrame.tx:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
underlineFrame.tx:SetBlendMode("ADD")
underlineFrame:SetAlpha(0.75)
underlineFrame:SetScript("OnHide", function(this) this:Hide(); end)
underlineFrame:SetScript("OnShow", function(this)
    underlineFrame.tx:SetPoint("TOPLEFT", 0, 0)
    underlineFrame.tx:SetPoint("RIGHT", 0, 0)
end)

local function UpdateFrameSizes(name, width, height, widthDbl)
	if ( widthDbl ~= nil ) then
		local line = math.floor((width + widthDbl) + (cushion * 2))
		width = math.floor(line + (cushion * 2))
	else
		width = math.floor(width + (cushion * 2))
	end
	height = math.floor(height + lspace)
	
	-- Adjustments to cap width and ensure long subheaders wrap
	if ( width > 380 ) then width = 380 end
	
	toolTips[name].width = max(toolTips[name].width, width)
	toolTips[name].height = math.floor(toolTips[name].height + height)
	
	-- if ( toolTips[name].subheader ) then toolTips[name].subheader:SetWidth(toolTips[name].width) end
	
	if ( toolTips[name].spacers > 0 ) then
		for i = 1, toolTips[name].spacers do
			toolTips[name]["Spacer"..i]:SetWidth(math.floor(toolTips[name].width - (cushion * 2)))
		end
	end
end

function lib:GetTooltip(name, interactive)
	if ( type(name) ~= "string" ) then error("Usage: GetTooltip(name, guild, motto) - 'name': string expected.", 2) end
	
	toolTips[name] = toolTips[name] or {}
	toolTips[name].frame = CreateFrame("Frame", name.."Tooltip", UIParent)
	toolTips[name].frame:SetBackdrop(GameTooltip:GetBackdrop())
	toolTips[name].frame:SetBackdropColor(GameTooltip:GetBackdropColor())
	toolTips[name].frame:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
	toolTips[name].frame:EnableMouse(true)
	toolTips[name].frame:SetClampedToScreen(true)
	toolTips[name].frame:SetFrameStrata("FULLSCREEN_DIALOG")
	toolTips[name].frame:Hide()
	
	if ( interactive ) then
		toolTips[name].frame:SetHitRectInsets(1, 1, 1, 0)
		toolTips[name].frame:SetScript("OnEnter", function(this) this:Show() end)
		toolTips[name].frame:SetScript("OnLeave", function(this) self:ClearTooltip(name) end)
	end
	
	toolTips[name].width = 0
	toolTips[name].height = cushion 	
	toolTips[name].spacers = 0
	
	return toolTips[name].frame
end

function lib:AddHeader(name, header, subheader, subColor)
	if ( type(name) ~= "string" ) then error("Usage: AddHeader(name, header, subheader) - 'name': string expected.", 2) end
	if ( type(header) ~= "string" ) then error("Usage: AddHeader(name, header, subheader) - 'header': string expected.", 2) end
	if ( subheader and type(subheader) ~= "string" ) then error("Usage: AddHeader(name, header, subheader) - 'subheader': string expected.", 2) end
	if ( not toolTips[name] ) then error("Tooltip does not exist, cannot create header.", 2) end
	
	toolTips[name].header = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	toolTips[name].header:SetFont(toolTips[name].header:GetFont(), 14)
	toolTips[name].header:SetText(header)
	toolTips[name].header:ClearAllPoints()
	toolTips[name].header:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, toolTips[name].header:GetWidth(), toolTips[name].header:GetHeight())
	
	if ( subheader ) then
		toolTips[name].subheader = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		toolTips[name].subheader:SetFont(toolTips[name].subheader:GetFont(), 11)
		toolTips[name].subheader:SetWordWrap(true)
		toolTips[name].subheader:SetNonSpaceWrap(false)
		toolTips[name].subheader:SetJustifyH("LEFT")
		toolTips[name].subheader:SetText(subheader)
		if ( toolTips[name].subheader:GetWidth() > 300 - (cushion * 2) ) then
			toolTips[name].subheader:SetWidth(300 - (cushion * 2))
		end
		if ( subColor ) then toolTips[name].subheader:SetTextColor(unpack(subColor)) end
		toolTips[name].subheader:ClearAllPoints()
		toolTips[name].subheader:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
		toolTips[name].subheader:SetPoint("TOPRIGHT", toolTips[name].frame, "TOPRIGHT", math.floor(0 - cushion), math.floor(0 - toolTips[name].height))
		
		UpdateFrameSizes(name, toolTips[name].subheader:GetWidth(), toolTips[name].subheader:GetHeight())
	end
	
	toolTips[name].spacers = toolTips[name].spacers + 1
	toolTips[name]["Spacer"..toolTips[name].spacers] = toolTips[name].frame:CreateTexture()
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetTexture(1,1,0.5,0.75)
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetHeight(1)
	toolTips[name]["Spacer"..toolTips[name].spacers]:ClearAllPoints()
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, 0, toolTips[name]["Spacer"..toolTips[name].spacers]:GetHeight())
end

function lib:AddSpacer(name)
	if ( type(name) ~= "string" ) then error("Usage: AddSpacer(name) - 'name': string expected.", 2) end
	
	toolTips[name].spacers = toolTips[name].spacers + 1
	toolTips[name]["Spacer"..toolTips[name].spacers] = toolTips[name].frame:CreateTexture()
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetTexture(1,1,0.5,0.75)
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetHeight(1)
	toolTips[name]["Spacer"..toolTips[name].spacers]:ClearAllPoints()
	toolTips[name]["Spacer"..toolTips[name].spacers]:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, 0, toolTips[name]["Spacer"..toolTips[name].spacers]:GetHeight())
end

function lib:AddLine(name, line, lineColor, interactive, func)
	if ( type(name) ~= "string" ) then error("Usage: AddLine(name, line, lineColor) - 'name': string expected.", 2) end
	if ( type(line) ~= "string" ) then error("Usage: AddLine(name, line, lineColor) - 'line': string expected.", 2) end
	if ( lineColor and type(lineColor) ~= "table" ) then error("Usage: AddLine(name, line, lineColor) - 'lineColor': table expected.", 2) end
	
	local tline = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	tline:SetFont(tline:GetFont(), 11)
	tline:SetTextColor(1, 1, 1)
	tline:SetWordWrap(false)
	tline:SetText(line)
	if ( lineColor ) then tline:SetTextColor(unpack(lineColor)) end
	
	if ( interactive ) then
		local button = CreateFrame("Button")
		button:SetParent(toolTips[name].frame)
		button:ClearAllPoints(); button:SetPoint("TOPLEFT", tline, 0, 0); button:SetPoint("BOTTOMRIGHT", tline, 0, 0)
		
		button:SetScript("OnClick", func)
		button:SetScript("OnEnter", function(this)
			toolTips[name].frame:Show()
			
			underlineFrame:SetParent(this)
			underlineFrame:SetHeight(0.6 / this:GetEffectiveScale())
			underlineFrame:SetPoint("BOTTOMLEFT", this, 0, -2/this:GetEffectiveScale())
			underlineFrame:SetPoint("TOPRIGHT", this, 0, 1/this:GetEffectiveScale())
			underlineFrame:SetFrameLevel(1)
			underlineFrame:Show()
		end)
		button:SetScript("OnLeave", function(this)
			underlineFrame:Hide()
			toolTips[name].frame:Hide()
		end)
	end
	
	tline:ClearAllPoints()
	tline:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, tline:GetWidth(), tline:GetHeight())
end

function lib:AddDoubleLine(name, line1, line2, lineColor1, lineColor2, interactive, func)
	if ( type(name) ~= "string" ) then error("Usage: AddDoubleLine(name, line1, line2, [lineColor1, lineColor2, interactive, func]) - 'name': string expected.", 2) end
	if ( type(line1) ~= "string" ) then error("Usage: AddDoubleLine(name, line1, line2, [lineColor1, lineColor2, interactive, func]) - 'line1': string expected.", 2) end
	if ( type(line2) ~= "string" ) then error("Usage: AddDoubleLine(name, line1, line2, [lineColor1, lineColor2, interactive, func]) - 'line2': string expected.", 2) end
	if ( lineColor1 and type(lineColor1) ~= "table" ) then error("Usage: AddDoubleLine(name, line1, line2, [lineColor1, lineColor2, interactive, func]) - 'lineColor1': table expected.", 2) end
	if ( lineColor2 and type(lineColor2) ~= "table" ) then error("Usage: AddDoubleLine(name, line1, line2, [lineColor1, lineColor2, interactive, func]) - 'lineColor2': table expected.", 2) end
	
	local tline1 = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local tline2 = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	
	tline1:SetFont(tline1:GetFont(), 11); 	tline2:SetFont(tline2:GetFont(), 11)
	tline1:SetWordWrap(false); 				tline2:SetWordWrap(false)
	tline1:SetText(line1);					tline2:SetText(line2)
	
	if ( lineColor1 ) then tline1:SetTextColor(unpack(lineColor1)) else tline1:SetTextColor(1, 1, 1) end
	if ( lineColor2 ) then tline2:SetTextColor(unpack(lineColor2)) else tline2:SetTextColor(1, 1, 1) end
	
	if ( interactive ) then
		local button = CreateFrame("Button")
		button:SetParent(toolTips[name].frame)
		button:ClearAllPoints(); button:SetPoint("TOPLEFT", tline1, 0, 0); button:SetPoint("BOTTOMRIGHT", tline2, 0, 0)
		
		button:SetScript("OnClick", func)
		button:SetScript("OnEnter", function(this)
			toolTips[name].frame:Show()
			
			underlineFrame:SetParent(this)
			underlineFrame:SetHeight(0.6 / this:GetEffectiveScale())
			underlineFrame:SetPoint("BOTTOMLEFT", this, 0, -2/this:GetEffectiveScale())
			underlineFrame:SetPoint("TOPRIGHT", this, 0, 1/this:GetEffectiveScale())
			underlineFrame:SetFrameLevel(1)
			underlineFrame:Show()
		end)
		button:SetScript("OnLeave", function(this)
			underlineFrame:Hide(); toolTips[name].frame:Hide()
		end)
	end
	
	tline1:ClearAllPoints()
	tline1:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	tline2:ClearAllPoints()
	tline2:SetPoint("TOPRIGHT", toolTips[name].frame, "TOPRIGHT", math.floor(0 - cushion), math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, tline1:GetWidth(), tline1:GetHeight(), tline2:GetWidth())
end

local firstFoot = true
function lib:AddFooter(name, line, lineColor)
	if ( type(name) ~= "string" ) then error("Usage: AddFooter(name, line, lineColor) - 'name': string expected.", 2) end
	if ( type(line) ~= "string" ) then error("Usage: AddFooter(name, line, lineColor) - 'line': string expected.", 2) end
	if ( lineColor and type(lineColor) ~= "table" ) then error("Usage: AddFooter(name, line, lineColor) - 'lineColor': table expected.", 2) end
	
	if ( firstFoot ) then toolTips[name].height = toolTips[name].height + cushion; firstFoot = false end
	
	local foot = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	foot:SetFont(foot:GetFont(), 11)
	foot:SetTextColor(1, 1, 0)
	foot:SetWordWrap(false)
	foot:SetText(line)
	if ( lineColor ) then foot:SetTextColor(lineColor) end
	
	foot:ClearAllPoints()
	foot:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, foot:GetWidth(), foot:GetHeight())
end

function lib:AddStatusBar(name, line, minV, maxV, curV, barColor, texture, isTimer)
	if ( type(name) ~= "string" ) then error("Usage: AddStatusBar - 'name': string expected.", 2) end
	if ( type(line) ~= "string" ) then error("Usage: AddStatusBar - 'line': string expected.", 2) end
	if ( type(minV) ~= "number" ) then error("Usage: AddStatusBar - 'minV': number expected.", 2) end
	if ( type(maxV) ~= "number" ) then error("Usage: AddStatusBar - 'maxV': number expected.", 2) end
	if ( curV and type(curV) ~= "number" ) then error("Usage: AddStatusBar - 'curV': number expected.", 2) end
	if ( barColor and type(barColor) ~= "table" ) then error("Usage: AddStatusBar - 'barColor': table expected.", 2) end
	if ( texture and type(texture) ~= "string" ) then error("Usage: AddStatusBar - 'texture': table expected.", 2) end
	
	local tline = toolTips[name].frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	local sbar = CreateFrame("StatusBar")
	
	tline:SetFont(tline:GetFont(), 11)
	tline:SetWordWrap(false)
	tline:SetText(line)
	
	sbar:SetParent(toolTips[name].frame)
	sbar:SetWidth(100)
	sbar:SetHeight(tline:GetHeight()-2)
	sbar:SetStatusBarTexture(texture or "Interface\\TargetingFrame\\UI-StatusBar")
	sbar:SetStatusBarColor(barColor or 1, 0, 1)
	sbar:SetFrameLevel(2)
	
	sbar.border = CreateFrame("Frame")
	sbar.border:SetParent(sbar)
	sbar.border:SetWidth(sbar:GetWidth()+2)
	sbar.border:SetHeight(sbar:GetHeight()+2)
	sbar.border:SetPoint("CENTER", 0, 0)
	sbar.border:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		edgeFile = "Interface\\BUTTONS\\WHITE8X8",
		tile = false, edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	sbar.border:SetBackdropColor(0,0,0,1)
	sbar.border:SetBackdropBorderColor(.3,.3,.3,1)
	sbar.border:SetFrameLevel(1)
	
	if ( isTimer ) then
		-- minV becomes start time, maxV becomes end time, curV can becomes nil because we rely on GetTime()
		sbar:SetScript("OnUpdate", function(self)
			sbar:SetMinMaxValues(minV, maxV)
			if ( GetTime() < maxV ) then
				sbar:SetValue(GetTime())
			else
				sbar:SetScript("OnUpdate", nil)
			end
		end)
	else
		sbar:SetMinMaxValues(minV, maxV)
		sbar:SetValue(curV)
	end
	
	tline:ClearAllPoints()
	tline:SetPoint("TOPLEFT", toolTips[name].frame, "TOPLEFT", cushion, math.floor(0 - toolTips[name].height))
	sbar:ClearAllPoints()
	sbar:SetPoint("TOPRIGHT", toolTips[name].frame, "TOPRIGHT", math.floor(0 - cushion), math.floor(0 - toolTips[name].height))
	
	UpdateFrameSizes(name, tline:GetWidth(), tline:GetHeight(), sbar:GetWidth())
end

function lib:ShowTooltip(name, anchor)
	if ( type(name) ~= "string" ) then error("Usage: ClearTooltip(name) - 'name': string expected.", 2) end
	if ( not toolTips[name] ) then error("Tooltip does not exist, cannot show.", 2) end
	
	toolTips[name].frame:SetWidth(toolTips[name].width)
	-- Add cushion on Show() so we don't have to do running calculations for line spacing.
	toolTips[name].frame:SetHeight(math.floor(toolTips[name].height + cushion))
	toolTips[name].frame:SetScale(SLDataText.db.profile.ttScale)
	
	SmartAnchor(name, anchor)
	toolTips[name].frame:Show()
end

function lib:ClearTooltip(name)
	if ( type(name) ~= "string" ) then error("Usage: ClearTooltip(name) - 'name': string expected.", 2) end
	if ( not firstFoot ) then firstFoot = true end
	
	toolTips[name].frame:Hide()
end