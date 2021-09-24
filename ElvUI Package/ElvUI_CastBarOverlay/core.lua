local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CBO = E:GetModule("CastBarOverlay")
local UF = E:GetModule("UnitFrames");
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

--Cache global variables
local _G = _G

-- Warn about trying to overlay on disabled power bar
E.PopupDialogs["CBO_PowerDisabled"] = {
	text = L["CBO_POWER_DISABLED"],
	button1 = L["I understand"],
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}

--Set size of castbar and position on chosen frame
local function SetCastbarSizeAndPosition(unit, unitframe, overlayFrame)
	local db = E.db.CBO[unit];
	local cdb = E.db.unitframe.units[unit].castbar;
	local castbar = unitframe.Castbar

	local frameStrata = db.overlayOnFrame == "HEALTH" and unitframe.RaisedElementParent:GetFrameStrata() or overlayFrame:GetFrameStrata()
	local frameLevel = (db.overlayOnFrame == "HEALTH" and unitframe.RaisedElementParent:GetFrameLevel() or overlayFrame:GetFrameLevel()) + 2

	--Store original frame strata and level
	castbar.origFrameStrata = castbar.origFrameStrata or castbar:GetFrameStrata()
	castbar.origFrameLevel = castbar.origFrameLevel or castbar:GetFrameLevel()

	local overlayWidth = overlayFrame:GetWidth()
	local overlayHeight = overlayFrame:GetHeight()

	-- Set castbar height and width according to chosen overlay panel
	cdb.width, cdb.height = overlayWidth, overlayHeight

	-- Update internal settings
	UF:Configure_Castbar(unitframe, true) --2nd argument is to prevent loop

	-- Raise FrameStrata and FrameLevel so castbar stays on top of power bar
	-- If offset is used, the castbar will still stay on top of power bar while staying below health bar.
	castbar:SetFrameStrata(frameStrata)
	castbar:SetFrameLevel(frameLevel)

	-- Position the castbar on overLayFrame
	if (not cdb.iconAttached) then
		castbar:SetInside(overlayFrame, 0, 0)
	else
		--Adjust size of castbar icon
		castbar.ButtonIcon.bg:Size(overlayHeight + unitframe.BORDER*2)

		local iconWidth = cdb.icon and (castbar.ButtonIcon.bg:GetWidth() - unitframe.BORDER) or 0
		castbar:ClearAllPoints()
		if(unitframe.ORIENTATION == "RIGHT") then
			castbar:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT")
			castbar:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT", -iconWidth - unitframe.SPACING*3, 0)
		else
			castbar:SetPoint("TOPLEFT", overlayFrame, "TOPLEFT",  iconWidth + unitframe.SPACING*3, 0)
			castbar:SetPoint("BOTTOMRIGHT", overlayFrame, "BOTTOMRIGHT")
		end
	end

	if(castbar.Holder.mover) then
		E:DisableMover(castbar.Holder.mover:GetName())
	end

	castbar.isOverlayed = true
end

--Reset castbar size and position
local function ResetCastbarSizeAndPosition(unit, unitframe)
	local cdb = E.db.unitframe.units[unit].castbar;
	local castbar = unitframe.Castbar
	local mover = castbar.Holder.mover

	--Reset size back to default
	cdb.width, cdb.height = E.db.unitframe.units[unit].width, P.unitframe.units[unit].castbar.height

	-- Reset frame strata and level
	castbar:SetFrameStrata(castbar.origFrameStrata)
	castbar:SetFrameLevel(castbar.origFrameLevel)

	-- Update internal settings
	UF:Configure_Castbar(unitframe, true) --2nd argument is to prevent loop

	-- Revert castbar position to default
	if mover then
		local moverName = mover and mover.textString
		if moverName ~= "" and moverName ~= nil then
			E:ResetMovers(moverName)
		end
		E:EnableMover(mover:GetName())
	else
		--Boss/Arena frame castbars don't have movers
		castbar.Holder:ClearAllPoints()
		castbar.Holder:Point("TOPLEFT", unitframe, "BOTTOMLEFT", 0, -(E.Border * 3))
	end

	castbar.isOverlayed = false
end

--Configure castbar text position and alpha
local function ConfigureText(unit, castbar)
	local db = E.db.CBO[unit]

	if db.hidetext then -- Hide
		castbar.Text:SetAlpha(0)
		castbar.Time:SetAlpha(0)
	else -- Show
		castbar.Text:SetAlpha(1)
		castbar.Time:SetAlpha(1)
	end

	-- Set position of castbar text according to chosen offsets
	castbar.Text:ClearAllPoints()
	castbar.Text:SetPoint("LEFT", castbar, "LEFT", db.xOffsetText, db.yOffsetText)
	castbar.Time:ClearAllPoints()
	castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", db.xOffsetTime, db.yOffsetTime)
end

--Reset castbar text position and alpha
local function ResetText(castbar)
	castbar.Text:ClearAllPoints()
	castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
	castbar.Time:ClearAllPoints()
	castbar.Time:SetPoint("RIGHT", castbar, "RIGHT", -4, 0)
	castbar.Text:SetAlpha(1)
	castbar.Time:SetAlpha(1)
end

--Initiate update/reset of castbar
local function ConfigureCastbar(unit, unitframe)
	local db = E.db.CBO[unit];
	local cdb = E.db.unitframe.units[unit].castbar;
	local castbar = unitframe.Castbar

	if db.overlay then
		local OverlayFrame = db.overlayOnFrame == "HEALTH" and unitframe.Health or unitframe.Power
		E:Delay(0.01, function() SetCastbarSizeAndPosition(unit, unitframe, OverlayFrame) end) --Delay it a bit, so size of overlayFrame is updated before we grab it.
		ConfigureText(unit, castbar)
	elseif castbar.isOverlayed then
		ResetCastbarSizeAndPosition(unit, unitframe)
		ResetText(castbar)
	end
end

--Initiate update of unit
function CBO:UpdateSettings(unit)
	local db = E.db.CBO[unit];
	local cdb = E.db.unitframe.units[unit].castbar;

	--Check if power is disabled and overlay is set to POWER
	if not E.db.unitframe.units[unit].power.enable and (E.db.CBO[unit].overlay and E.db.CBO[unit].overlayOnFrame == "POWER") then
		E:StaticPopup_Show("CBO_PowerDisabled", unit)
		E.db.CBO[unit].overlayOnFrame = "HEALTH"
	end

	if unit == "player" or unit == "target" or unit == "focus" or unit == "pet" then
		local unitFrameName = "ElvUF_"..E:StringTitle(unit)
		local unitframe = _G[unitFrameName]
		ConfigureCastbar(unit, unitframe)
	elseif unit == "arena" then
		for i = 1, 5 do
			local unitframe = _G["ElvUF_Arena"..i]
			ConfigureCastbar(unit, unitframe)
		end
	elseif unit == "boss" then
		for i = 1, 4 do
			local unitframe = _G["ElvUF_Boss"..i]
			ConfigureCastbar(unit, unitframe)
		end
	end
end

-- Function to be called when registered events fire
function CBO:UpdateAllCastbars()
	CBO:UpdateSettings("player")
	CBO:UpdateSettings("target")
	CBO:UpdateSettings("focus")
	CBO:UpdateSettings("pet")
	CBO:UpdateSettings("arena")
	CBO:UpdateSettings("boss")
end

function CBO:Initialize()
	-- Register callback with LibElvUIPlugin
	EP:RegisterPlugin(addon, CBO.InsertOptions)

	--ElvUI UnitFrames are not enabled, stop right here!
	if E.private.unitframe.enable ~= true then return end

	--Profile changed, update castbar overlay settings
	hooksecurefunc(E, "UpdateAll", function()
		CBO:UpdateAllCastbars()
	end)

	--Castbar was modified, re-apply settings
	hooksecurefunc(UF, "Configure_Castbar", function(self, frame, preventLoop)
		if preventLoop then return; end --I call Configure_Castbar with "true" as 2nd argument
		local unit = frame.unitframeType
		if unit and E.db.CBO[unit] and E.db.CBO[unit].overlay then
			CBO:UpdateSettings(unit)
		end
	end)

	--Health may have changed size, update castbar overlay settings
	hooksecurefunc(UF,"Configure_HealthBar", function(self, frame)
		local unit = frame.unitframeType
		if unit and E.db.CBO[unit] and E.db.CBO[unit].overlay and E.db.CBO[unit].overlayOnFrame == "HEALTH" then
			CBO:UpdateSettings(unit)
		end
	end)

	--Power may have changed size, update castbar overlay settings
	hooksecurefunc(UF,"Configure_Power",function(self, frame)
		local unit = frame.unitframeType
		if unit and E.db.CBO[unit] and E.db.CBO[unit].overlay and E.db.CBO[unit].overlayOnFrame == "POWER" then
			CBO:UpdateSettings(unit)
		end
	end)
end