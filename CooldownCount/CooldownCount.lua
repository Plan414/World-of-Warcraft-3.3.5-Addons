CooldownCount = LibStub("AceAddon-3.0"):NewAddon("CooldownCount", "AceConsole-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("CooldownCount")
local SM = LibStub("LibSharedMedia-3.0")
local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local blacklist = { "TargetFrame", "PetAction", "TotemFrame" }

local defaults = {
	profile = {
		shine = false,
		shineScale = 2,
		minimumDuration = 3,
		hideAnimation = false,
		font = SM:GetDefault("font"),
		color_common = {r=1, g=1, b=0.2, a=1},
		color_warn = {r=1, g=0, b=0, a=1},
		size1 = 18,
		size2 = 24,
		size3 = 28,
		size4 = 34,
	}
}
local function get(info)
    local k = info[#info]
    return CooldownCount.db.profile[k]
end
local function set(info,value)
    local k = info[#info]
    CooldownCount.db.profile[k] = value
	if k == "font" then
		CooldownCount:initFontStyle()
	end
end

function CooldownCount:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CooldownCountDB", defaults, "Default")
	local options = {
		type = "group",
		name = "CooldownCount",
		args = {
			FontSettings = {
				type = "group",
				name = L["Font Settings"],
				get = get,
				set = set,
				args = {
					font = {
						type = "select",
						name = L["Font Style"],
						desc = L["Set cooldown value display font."],
						order =10,
						values = function()
							local fonts, newFonts = SM:List("font"), {}
							for k, v in pairs(fonts) do
								newFonts[v] = v
							end
							return newFonts
						end,
					},
					header_font_color = {
						type = "header",
						name = L["Font Color"],
						order = 20,
					},
					color_common = {
						type = "color",
						name = L["Common color"],
						desc = L["Setup the common color for value display."],
						order = 21,
						hasAlpha = true,
						get = function(info)
							local k=info[#info]
							return self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a
						end,
						set = function(info, r, g, b, a)
							local k=info[#info]
							self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a = r, g, b, a
						end,
					},
					color_warn = {
						type = "color",
						name = L["warning color"],
						desc = L["Setup the warning color for value display."],
						order = 22,
						hasAlpha = true,
						get = function(info)
							local k=info[#info]
							return self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a
						end,
						set = function(info, r, g, b, a)
							local k=info[#info]
							self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a = r, g, b, a
						end,
					},
					header_font_size = {
						type = "header",
						name = L["Font Size"],
						order = 30,
					},
					size1 = {
						type = "range",
						name = L["Small Size"],
						desc = L["Small font size for cooldown is longer than 10 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 31,
					},
					size2 = {
						type = "range",
						name = L["Medium Size"],
						desc = L["Medium font size for cooldown is longer than 1 minute and less than 10 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 32,
					},
					size3 = {
						type = "range",
						name = L["Large Size"],
						desc = L["Large font size for cooldown is longer than 10 seconds and less than 1 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 33,
					},
					size4 = {
						type = "range",
						name = L["Warning Size"],
						desc = L["Warning font size for cooldown is less than 10 seconds."],
						min = 10,
						max = 45,
						step = 1,
						order = 34,
					},
				},
			},
			Misc = {
				type = "group",
				order = 3,
				name = L["Misc"],
				get = get,
				set = set,
				args = {
					shine = {
						type = "toggle",
						name = L["Shine at finish cooldown"],
						desc = L["Toggle icon shine display at finish cooldown."],
						order = 10,
					},
					shineScale = {
						type = "range",
						name = L["Shine Scale"],
						desc = L["Adjust icon shine scale."],
						min = 0,
						max = 50,
						step = 1,
						order = 11,
					},
					header_hideAnimation = {
						type = "header",
						name = L["Hide Blizzard Origin Animation"],
						order = 20,
					},
					hideAnimation = {
						type = "toggle",
						name = L["Hide Blizzard Origin Animation"],
						desc = L["Hide Blizzard origin cooldown animation."],
						order = 21,
					},
					header_minimumDuration = {
						type = "header",
						name = L["Minimum Duration"],
						order = 50,
					},
					minimumDuration = {
						type = "range",
						name = L["Minimum Duration"],
						desc = L["Minimum duration for display cooldown count."],
						min = 0.5,
						max = 30,
						step = 0.5,
						order = 51,
					},
					header_resetdb = {
						type = "header",
						name = L["Reset"],
						order = 70,
					},
					resetdb = {
						type = "execute",
						confirm = true,
						confirmText = L["ResetDB_Confirm"],
						func = function()
							self.db:ResetDB()
							self:initFontStyle()
							self:Print(L["All settings are reset to default value."])
						end,
						name = L["Reset"],
						order = 71,
					},
				},
			},
		}
	}

	config:RegisterOptionsTable("CooldownCount", {
		name = "CooldownCount",
		type = "group",
		args = {
			description = {
				type = "description",
				name = L["WhatIsCooldownCount"],
			},
		},
	})
	dialog:SetDefaultSize("CooldownCount", 600, 400)
	dialog:AddToBlizOptions("CooldownCount", "CooldownCount")

	config:RegisterOptionsTable("CooldownCount-Misc", options.args.Misc)
	dialog:AddToBlizOptions("CooldownCount-Misc", options.args.Misc.name, "CooldownCount")

	config:RegisterOptionsTable("CooldownCount-FontSettings", options.args.FontSettings)
	dialog:AddToBlizOptions("CooldownCount-FontSettings", options.args.FontSettings.name, "CooldownCount")
end

function CooldownCount:OnEnable()
	self:initFontStyle()
	self:SecureHook(getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index, "SetCooldown")
end

function CooldownCount:initFontStyle()
	self.font = SM:Fetch('font', self.db.profile.font)
end

function CooldownCount:SetCooldown(frame, start, duration)
	--black list handle
	if CooldownCount:CheckBlacklist(frame:GetName()) then
		return
	end
	
	-- hide blz origin cooldown animation
	frame:SetAlpha(CooldownCount.db.profile.hideAnimation and 0 or 1)

	if start > 0 and duration > CooldownCount.db.profile.minimumDuration then
		local CC = frame.textFrame or CooldownCount:CreateCooldownCount(frame, start, duration)
		CC.start = start
		CC.duration = duration
		CC.timeToNextUpdate = 0
		if not CC:IsShown() then
			CC:Show()
		end
	else
		local CC = frame.textFrame
		if CC and CC:IsShown() then
			CC:Hide()
		end
	end
end

function CooldownCount:CreateCooldownCount(frame, start, duration)
	frame.textFrame = CreateFrame("Frame", nil, frame:GetParent())
	local textFrame = frame.textFrame

	-- switch action bar fix, but not perfect
	local ChildFrame = CreateFrame("Frame", nil, frame)
	ChildFrame:SetScript("OnShow", CooldownCount.Child_OnShow)
	ChildFrame:SetScript("OnHide", CooldownCount.Child_OnHide)

	textFrame:SetAllPoints(frame:GetParent())
	textFrame:SetFrameLevel(textFrame:GetFrameLevel() + 5)
	textFrame:SetToplevel(true)

	textFrame.text = textFrame:CreateFontString(nil, "OVERLAY")
	textFrame.text:SetPoint("CENTER", textFrame, "CENTER", 0, -1)

	textFrame.icon =
		--standard action button icon, $parentIcon
		getglobal(frame:GetParent():GetName() .. "Icon") or
		--standard item button icon,  $parentIconTexture
		getglobal(frame:GetParent():GetName() .. "IconTexture")

	if textFrame.icon then
		textFrame:SetScript("OnUpdate", CooldownCount.Text_OnUpdate)
	end

	textFrame:Hide()

	return textFrame
end

function CooldownCount:Child_OnShow()
	local textFrame = this:GetParent().textFrame
	if textFrame and not textFrame:IsShown() then
		textFrame:Show()
	end
end

function CooldownCount:Child_OnHide()
	local textFrame = this:GetParent().textFrame
	if textFrame and textFrame:IsShown() then
		textFrame:Hide()
	end
end

function CooldownCount:Text_OnUpdate()
	if this.timeToNextUpdate <= 0 or not this.icon:IsVisible() then
		--[[
		If you have a long cooldown spell/item, after reboot your computer, cooldown value will be wrong.
		I still havn't any idea for it.
		]]
		if GetTime() < this.start then return end

		local remain = this.duration - (GetTime() - this.start)

		if floor(remain + 0.5) > 0 and this.icon:IsVisible() then
			local text, toNextUpdate, size, color2 = CooldownCount:GetFormattedTime(remain)
			this.text:SetFont(CooldownCount.font, size, "OUTLINE")

			color = CooldownCount.db.profile.color_common
			if color2 then
				if this.color2 then
					color = CooldownCount.db.profile.color_warn
					this.color2 = nil
				else
					this.color2 = true
				end
			end
			this.text:SetTextColor(color.r, color.g, color.b)

			this.text:SetText( text )
			this.timeToNextUpdate = toNextUpdate
		else
			if CooldownCount.db.profile.shine and this.icon:IsVisible() then
				CooldownCount:StartToShine(this)
			end
			this.color2 = nil
			this:Hide()
		end
	else
		this.timeToNextUpdate = this.timeToNextUpdate - arg1
	end
end

function CooldownCount:GetFormattedTime(secs)
	-- return cc now value, next update value, font size, toggle two color
	if secs >= 86400 then
		return ceil(secs / 86400) .. L["d"], mod(secs, 86400), CooldownCount.db.profile.size1
	elseif secs >= 3600 then
		return ceil(secs / 3600) .. L["h"], mod(secs, 3600), CooldownCount.db.profile.size1
	elseif secs >= 600 then
		return ceil(secs / 60) .. L["m"], mod(secs, 60), CooldownCount.db.profile.size1
	elseif secs >= 60 then
		return ceil(secs / 60) .. L["m"], mod(secs, 60), CooldownCount.db.profile.size2
	elseif secs >= 10 then
		return floor(secs + 0.5), secs - floor(secs), CooldownCount.db.profile.size3
	end
	return floor(secs + 0.5), 0.5, CooldownCount.db.profile.size4, true
end


--[[ Shine Codes ]]--
function CooldownCount:StartToShine(textFrame)
	local shineFrame = textFrame.shine or CooldownCount:CreateShineFrame(textFrame:GetParent())

	shineFrame.shine:SetAlpha(shineFrame:GetParent():GetAlpha())
	shineFrame.shine:SetHeight(shineFrame:GetHeight() * CooldownCount.db.profile.shineScale)
	shineFrame.shine:SetWidth(shineFrame:GetWidth() * CooldownCount.db.profile.shineScale)

	shineFrame:Show()
end

function CooldownCount:CreateShineFrame(parent)
	local shineFrame = CreateFrame("Frame", nil, parent)
	shineFrame:SetAllPoints(parent)

	local shine = shineFrame:CreateTexture(nil, "OVERLAY")
	shine:SetTexture("Interface\\Cooldown\\star4")
	shine:SetPoint("CENTER", shineFrame, "CENTER")
	shine:SetBlendMode("ADD")
	shineFrame.shine = shine

	shineFrame:Hide()
	shineFrame:SetScript("OnUpdate", CooldownCount.Shine_Update)
	shineFrame:SetAlpha(parent:GetAlpha())

	return shineFrame
end

function CooldownCount:Shine_Update()
	local shine = this.shine
	local alpha = shine:GetAlpha()
	shine:SetAlpha(alpha * 0.95)

	if alpha < 0.1 then
		this:Hide()
	else
		shine:SetHeight(alpha * this:GetHeight() * CooldownCount.db.profile.shineScale)
		shine:SetWidth(alpha * this:GetWidth() * CooldownCount.db.profile.shineScale)
	end
end

function CooldownCount:CheckBlacklist(frameName)
	if not frameName or getglobal(frameName).noCooldownCount then
		return true
	end
	for _, v in ipairs(blacklist) do
		if strfind(frameName, v) then
			getglobal(frameName).noCooldownCount=1
			return true
		end
	end
end
