-- English localization file for enUS and enGB.
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "enUS", true);

if not L then return end
L["CBO_CBPOWARNING"] = "You still have the outdated addon 'CastBarPowerOverlay' enabled. It will now be disabled. You should uninstall it when possible."
L["CBO_CONFLICT_WARNING"] = "It would appear you have ElvUI_CastBarSnap loaded. CastBarPowerOverlay has been disabled for the Player CastBar."
L["CBO_POWER_DISABLED"] = "The %s power frame is disabled. Setting castbar overlay to health instead."
L["I understand"] = true
L["Arena"] = true
L["Boss"] = true
L["Choose which panel to overlay the castbar on."] = true;
L["Enable Overlay"] = true;
L["Focus"] = true
L["Hide Castbar text. Useful if your power height is very low or if you use power offset."] = true
L["Hide Text"] = true
L["Move castbar text to the left or to the right. Default is 4"] = true
L["Move castbar text up or down. Default is 0"] = true
L["Move castbar time to the left or to the right. Default is -4"] = true
L["Move castbar time up or down. Default is 0"] = true
L["Overlay Panel"] = true;
L["Overlay the castbar on the chosen panel."] = true;
L["Player"] = true
L["Target"] = true
L["Text xOffset"] = true
L["Text yOffset"] = true
L["Time xOffset"] = true
L["Time yOffset"] = true

--We don't need the rest if we're on enUS or enGB locale, so stop here.
if GetLocale() == "enUS" then return end

--German Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "deDE")
if L then
	--Add translations here
end

--Spanish (Spain) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "esES")
if L then
	--Add translations here
end

--Spanish (Mexico) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "esMX")
if L then
	--Add translations here
end

--French Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "frFR")
if L then
	--Add translations here
end

--Italian Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "itIT")
if L then
	--Add translations here
end

--Korean Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "koKR")
if L then
	--Add translations here
end

--Portuguese Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "ptBR")
if L then
	--Add translations here
end

--Russian Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "ruRU")
if L then
	--Add translations here
end

--Chinese (China, simplified) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "zhCN")
if L then
	--Add translations here
end

--Chinese (Taiwan, traditional) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "zhTW")
if L then
	--Add translations here
end