local E, L, V, P, G =  unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars");
local EP = LibStub("LibElvUIPlugin-1.0");
local S = E:GetModule("Skins");
local addon = ...

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local COLOR = COLOR

P.actionbar.microbar.symbolic = false
P.actionbar.microbar.backdrop = false
P.actionbar.microbar.backdropSpacing = 2
P.actionbar.microbar.transparentBackdrop = false
P.actionbar.microbar.classColor = false
P.actionbar.microbar.colorS = {r = 1, g = 1, b = 1}

function AB:GetOptions()
	E.Options.args.actionbar.args.microbar.args.microbarEnhanced = {
		order = 10,
		type = "group",
		name = "Microbar Enhancement",
		guiInline = true,
		get = function(info) return E.db.actionbar.microbar[ info[#info] ] end,
		set = function(info, value) E.db.actionbar.microbar[ info[#info] ] = value AB:UpdateMicroPositionDimensions() end,
		args = {
			backdrop = {
				order = 1,
				type = "toggle",
				name = L["Backdrop"],
				disabled = function() return not AB.db.microbar.enabled end,
			},
			backdropSpacing = {
				order = 2,
				type = "range",
				name = L["Backdrop Spacing"],
				min = 0, max = 10, step = 1,
				disabled = function() return not AB.db.microbar.enabled or not AB.db.microbar.backdrop end,
			},
			transparentBackdrop = {
				order = 3,
				type = "toggle",
				name = L["Transparent Backdrop"],
				disabled = function() return not AB.db.microbar.enabled or not AB.db.microbar.backdrop end,
			},
			symbolic = {
				order = 4,
				type = "toggle",
				name = L["As Letters"],
				desc = L["Replace icons with just letters"],
				disabled = function() return not AB.db.microbar.enabled end,
			},
			classColor = {
				order = 5,
				type = "toggle",
				name = L["Use Class Color"],
				get = function(info) return AB.db.microbar.classColor end,
				set = function(info, value) AB.db.microbar.classColor = value AB:SetSymbloColor() end,
				disabled = function() return not AB.db.microbar.enabled or not AB.db.microbar.symbolic end
			},
			color = {
				order = 6,
				type = "color",
				name = COLOR,
				get = function(info)
					local t = AB.db.microbar.colorS
					local d = P.actionbar.microbar.colorS
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = AB.db.microbar.colorS
					t.r, t.g, t.b = r, g, b
					AB:SetSymbloColor()
				end,
				disabled = function() return not AB.db.microbar.enabled or AB.db.microbar.classColor or not AB.db.microbar.symbolic end
			}
		}
	}
end

local MICRO_BUTTONS = {
	["CharacterMicroButton"] = L["CHARACTER_SYMBOL"],
	["SpellbookMicroButton"] = L["SPELLBOOK_SYMBOL"],
	["TalentMicroButton"] = L["TALENTS_SYMBOL"],
	["AchievementMicroButton"] = L["ACHIEVEMENT_SYMBOL"],
	["QuestLogMicroButton"] = L["QUEST_SYMBOL"],
	["SocialsMicroButton"] = L["SOCIAL_SYMBOL"],
	["PVPMicroButton"] = L["PVP_SYMBOL"],
	["LFDMicroButton"] = L["LFD_SYMBOL"],
	["MainMenuMicroButton"] = L["MENU_SYMBOL"],
	["HelpMicroButton"] = L["HELP_SYMBOL"]
}

function AB:SetSymbloColor()
	local color = AB.db.microbar.classColor and (E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])) or AB.db.microbar.colorS

	for button in pairs(MICRO_BUTTONS) do
		_G[button].text:SetTextColor(color.r, color.g, color.b)
	end
end

local function onEnter(self)
	if AB.db.microbar.symbolic then
		S.SetModifiedBackdrop(self)
	end
end

local function onLeave(self)
	if AB.db.microbar.symbolic then
		S.SetOriginalBackdrop(self)
	end
end

local oldHandleMicroButton = AB.HandleMicroButton
function AB:HandleMicroButton(button)
	oldHandleMicroButton(self, button)

	button:HookScript("OnEnter", onEnter)
	button:HookScript("OnLeave", onLeave)

	local text = MICRO_BUTTONS[button:GetName()]
	button.text = button:CreateFontString(nil, "BORDER")
	button.text:FontTemplate()
	button.text:SetPoint("CENTER", button, "CENTER", 0, -1)
	button.text:SetJustifyH("CENTER")
	button.text:SetText(text)
end

local oldUpdateMicroPositionDimensions = AB.UpdateMicroPositionDimensions
function AB:UpdateMicroPositionDimensions()
	oldUpdateMicroPositionDimensions(self)

	if not ElvUI_MicroBar.backdrop then
		ElvUI_MicroBar:CreateBackdrop("Transparent")
	end

	ElvUI_MicroBar.backdrop:SetTemplate(AB.db.microbar.transparentBackdrop and "Transparent" or "Default")
	ElvUI_MicroBar.backdrop:SetOutside(ElvUI_MicroBar, AB.db.microbar.backdropSpacing, AB.db.microbar.backdropSpacing)

	if AB.db.microbar.backdrop then
		ElvUI_MicroBar.backdrop:Show()
	else
		ElvUI_MicroBar.backdrop:Hide()
	end

	for button in pairs(MICRO_BUTTONS) do
		local b = _G[button]

		if AB.db.microbar.symbolic then
			b:DisableDrawLayer("ARTWORK")
			b:DisableDrawLayer("OVERLAY")
			b:EnableDrawLayer("BORDER")
		else
			b:EnableDrawLayer("ARTWORK")
			b:EnableDrawLayer("OVERLAY")
			b:DisableDrawLayer("BORDER")
		end
	end

	AB:SetSymbloColor()
end

function AB:EnhancementInit()
	EP:RegisterPlugin(addon, AB.GetOptions)
end

hooksecurefunc(AB, "SetupMicroBar", AB.EnhancementInit)