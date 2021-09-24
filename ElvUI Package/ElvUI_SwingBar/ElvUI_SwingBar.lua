local E, L, V, P, G = unpack(ElvUI)
local SB = E:NewModule("SwingBar")
local UF = E:GetModule("UnitFrames")
local EP = E.Libs.EP

local addonName = ...

local pairs = pairs

function UF:Construct_Swingbar(frame)
	local frameName = frame:GetName()
	local swingbar = CreateFrame("Frame", frameName.."SwingBar", frame)
	swingbar:SetFrameLevel(frame.RaisedElementParent:GetFrameLevel() + 30)
	swingbar:SetClampedToScreen(true)

	swingbar.Holder = CreateFrame("Frame", nil, swingbar)
	swingbar.Holder:Point("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -36)
	swingbar:Point("BOTTOMRIGHT", swingbar.Holder, "BOTTOMRIGHT", -E.Border, E.Border)

	E:CreateMover(swingbar.Holder, frameName.."SwingBarMover", L["Player SwingBar"], nil, -6, nil, "ALL,SOLO", nil, "elvuiPlugins,swing")

	swingbar.Twohand = CreateFrame("StatusBar", frameName.."SwingBar_Twohand", swingbar)
	swingbar.Twohand:Point("TOPLEFT", swingbar, "TOPLEFT", 0, 0)
	swingbar.Twohand:Point("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT", 0, 0)

	swingbar.Mainhand = CreateFrame("StatusBar", frameName.."SwingBar_Mainhand", swingbar)
	swingbar.Offhand = CreateFrame("StatusBar", frameName.."SwingBar_Offhand", swingbar)

	for _, Bar in pairs({swingbar.Twohand, swingbar.Mainhand, swingbar.Offhand}) do
		UF.statusbars[Bar] = true
		Bar:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
		Bar:Hide()

		Bar.bg = Bar:CreateTexture(nil, "BORDER")
		Bar.bg:SetAllPoints(Bar)
		Bar.bg:SetTexture(E.media.blankTex)

		Bar.Spark = Bar:CreateTexture(nil, "OVERLAY")
		Bar.Spark:SetBlendMode("ADD")
		Bar.Spark:SetVertexColor(1, 1, 1)
		Bar.Spark:Size(20, 40)

		Bar.Text = swingbar:CreateFontString(nil, "OVERLAY")
	end

	return swingbar
end

function UF:Configure_Swingbar(frame)
	local swingbar = frame.Swing
	local db = frame.db.swingbar

	if db.enable then
		if not frame:IsElementEnabled("Swing") then
			frame:EnableElement("Swing")
		end

		swingbar:Show()
		swingbar:Size(db.width - (E.Border * 2), db.height)

		swingbar.Holder:Size(db.width, db.height + E.Border * 2)

		if swingbar.Holder:GetScript("OnSizeChanged") then
			swingbar.Holder:GetScript("OnSizeChanged")(swingbar.Holder)
		end

		swingbar.Mainhand:ClearAllPoints()
		swingbar.Offhand:ClearAllPoints()

		if db.verticalOrientation then
			swingbar.Mainhand:Point("TOPLEFT", swingbar, "TOPLEFT")
			swingbar.Mainhand:Point("BOTTOMRIGHT", swingbar, "BOTTOM", -db.spacing, 0)

			swingbar.Offhand:Point("TOPLEFT", swingbar, "TOP", db.spacing + E.Border, 0)
			swingbar.Offhand:Point("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT")
		else
			swingbar.Mainhand:Point("TOPLEFT", swingbar, "TOPLEFT")
			swingbar.Mainhand:Point("BOTTOMRIGHT", swingbar, "RIGHT", 0, db.spacing)

			swingbar.Offhand:Point("TOPLEFT", swingbar, "LEFT", 0, -db.spacing - E.Border)
			swingbar.Offhand:Point("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT")
		end

		for _, Bar in pairs({swingbar.Twohand, swingbar.Mainhand, swingbar.Offhand}) do
			local color = db.color
			Bar:SetStatusBarColor(color.r, color.g, color.b)

			color = db.backdropColor
			Bar.bg:SetVertexColor(color.r * 0.35, color.g * 0.35, color.b * 0.35)

			Bar:SetOrientation(db.verticalOrientation and "VERTICAL" or "HORIZONTAL")

			if db.spark then
				if db.verticalOrientation then
					if Bar == swingbar.Twohand then
						Bar.Spark:Width(db.width * 1.8)
					else
						Bar.Spark:Width(db.width)
					end
					Bar.Spark:Height(10)
				else
					if Bar == swingbar.Twohand then
						Bar.Spark:Height(db.height * 1.8)
					else
						Bar.Spark:Height(db.height / 1.2)
					end
					Bar.Spark:Width(20)
				end

				Bar.Spark:ClearAllPoints()
				if db.verticalOrientation then
					Bar.Spark:Point("CENTER", Bar:GetStatusBarTexture(), "TOP")
				else
					Bar.Spark:Point("CENTER", Bar:GetStatusBarTexture(), "RIGHT")
				end
				Bar.Spark:Show()
			else
				Bar.Spark:Hide()
			end

			local x, y = self:GetPositionOffset(db.text.position)
			color = db.text.color

			Bar.Text:ClearAllPoints()
			Bar.Text:Point(db.text.position, Bar, db.text.position, x + db.text.xOffset, y + db.text.yOffset)
			Bar.Text:FontTemplate(UF.LSM:Fetch("font", db.text.font), db.text.fontSize, db.text.fontOutline)
			Bar.Text:SetTextColor(color.r, color.g, color.b)

			if db.text.enable then
				Bar.Text:Show()
			else
				Bar.Text:Hide()
			end
		end

		E:EnableMover(frame:GetName().."SwingBarMover")
	elseif frame:IsElementEnabled("Swing") then
		frame:DisableElement("Swing")

		swingbar:Hide()
		E:DisableMover(frame:GetName().."SwingBarMover")
	end
end

function SB:Initialize()
	EP:RegisterPlugin(addonName, self.InsertOptions)

	ElvUF_Player.Swing = UF:Construct_Swingbar(ElvUF_Player)
	hooksecurefunc(UF, "Update_PlayerFrame", function(_, frame)
		UF:Configure_Swingbar(frame)
	end)
end

local function InitializeCallback()
	SB:Initialize()
end

E:RegisterModule(SB:GetName(), InitializeCallback)