local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["AuraIconSpacing"] and true or false

--Cache global variables
local _G = _G
local pairs = pairs

local UpdateAuraSettings

P["CustomTweaks"]["AuraIconSpacing"] = {
	["spacing"] = 1,
	["units"] = {
		["player"] = true,
		["target"] = true,
		["targettarget"] = true,
		["targettargettarget"] = true,
		["focus"] = true,
		["focustarget"] = true,
		["pet"] = true,
		["pettarget"] = true,
		["arena"] = true,
		["boss"] = true,
		["party"] = true,
		["raid"] = true,
		["raid40"] = true,
		["raidpet"] = true,
		["tank"] = true,
		["assist"] = true,
	},
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing = {
		type = "group",
		name = "AuraIconSpacing",
		args = {
			spacing = {
				type = 'range',
				order = 1,
				name = L["Aura Spacing"],
				desc = L["Sets space between individual aura icons."],
				get = function(info) return E.db.CustomTweaks.AuraIconSpacing.spacing end,
				set = function(info, value) E.db.CustomTweaks.AuraIconSpacing.spacing = value; UpdateAuraSettings(); end,
				disabled = function() return not isEnabled end,
				min = 0, max = 10, step = 1,
			},
			units = {
				type = "multiselect",
				order = 2,
				name = L["Set Aura Spacing On Following Units"],
				get = function(info, key) return E.db.CustomTweaks.AuraIconSpacing.units[key] end,
				set = function(info, key, value) E.db.CustomTweaks.AuraIconSpacing.units[key] = value; UpdateAuraSettings(); end,
				disabled = function() return not isEnabled end,
				values = {
					['player'] = L["Player"],
					['target'] = L["Target"],
					['targettarget'] = L["TargetTarget"],
					['targettargettarget'] = L["TargetTargetTarget"],
					['focus'] = L["Focus"],
					['focustarget'] = L["FocusTarget"],
					['pet'] = L["Pet"],
					['pettarget'] = L["PetTarget"],
					['arena'] = L["Arena"],
					['boss'] = L["Boss"],
					['party'] = L["Party"],
					['raid'] = L["Raid"],
					['raid40'] = L["Raid40"],
					['raidpet'] = L["RaidPet"],
					["tank"] = L["Tank"],
					["assist"] = L["Assist"],
				},
			},
		},
	}
end
CT.Configs["AuraIconSpacing"] = ConfigTable
if not isEnabled then return; end

--Set spacing between individual aura icons and update PostUpdateIcon
local function SetAuraSpacingAndUpdate(unitframe, unitName, auraSpacing)
	if not unitframe.Buffs and not unitframe.Debuffs then return; end

	if unitframe.Buffs then
		unitframe.Buffs.spacing = auraSpacing
		--Update internal aura settings
		if unitframe.db then
			UF:Configure_Auras(unitframe, "Buffs")
		end
	end
	if unitframe.Debuffs then
		unitframe.Debuffs.spacing = auraSpacing
		if unitframe.db then
			UF:Configure_Auras(unitframe, "Debuffs")
		end
	end

	--Refresh aura display
	if unitframe.IsElementEnabled and unitframe:IsElementEnabled("Aura") then
		unitframe:UpdateElement("Aura")
	end
end

function UpdateAuraSettings()
	local auraSpacing = E.db.CustomTweaks.AuraIconSpacing.spacing or 1

	for unit, unitName in pairs(UF.units) do
		local spacing = E.db.CustomTweaks.AuraIconSpacing.units[unitName] and auraSpacing or E.Spacing
		local frameNameUnit = E:StringTitle(unitName)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe then
			SetAuraSpacingAndUpdate(unitframe, unitName, spacing)
		end
	end

	for unit, unitgroup in pairs(UF.groupunits) do
		local spacing = E.db.CustomTweaks.AuraIconSpacing.units[unitgroup] and auraSpacing or E.Spacing
		local frameNameUnit = E:StringTitle(unit)
		frameNameUnit = frameNameUnit:gsub("t(arget)", "T%1")
		
		local unitframe = _G["ElvUF_"..frameNameUnit]
		if unitframe then
			SetAuraSpacingAndUpdate(unitframe, unitgroup, spacing)
		end
	end
	
	for _, header in pairs(UF.headers) do
		local name = header.groupName
		local spacing = E.db.CustomTweaks.AuraIconSpacing.units[name] and auraSpacing or E.Spacing

		for i = 1, header:GetNumChildren() do
			local group = select(i, header:GetChildren())
			--group is Tank/Assist Frames, but for Party/Raid we need to go deeper
			SetAuraSpacingAndUpdate(group, name, spacing)

			for j = 1, group:GetNumChildren() do
				--Party/Raid unitbutton
				local unitbutton = select(j, group:GetChildren())
				SetAuraSpacingAndUpdate(unitbutton, name, spacing)
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	UpdateAuraSettings()
end)

local function SetAuraWidth(self, frame, auraType)
	local db = frame.db

	local auras = frame[auraType]
	auraType = auraType:lower()
	
	if db[auraType].sizeOverride and db[auraType].sizeOverride > 0 then
		auras:SetWidth(db[auraType].perrow * db[auraType].sizeOverride + ((db[auraType].perrow - 1) * auras.spacing))
	end
end
hooksecurefunc(UF, 'Configure_Auras', SetAuraWidth)