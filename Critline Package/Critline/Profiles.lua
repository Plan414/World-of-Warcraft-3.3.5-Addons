local CRITLINE, Critline = ...

local profiles = Critline.config:AddSubCategory("Profiles")
profiles:SetDescription("This profile controls all settings that are not related to individual trees or their records.")

local spellProfiles = Critline.config:AddSubCategory("Spell profiles")
spellProfiles:SetDescription("This profile stores individual tree settings, including which trees will be registered, and spell records.")

local profileUI = Critline:NewModule("Profiles")

function profileUI:OnInitialize()
	Critline:CreateAceDBControls(Critline.db, profiles):SetPoint("CENTER")
	Critline:CreateAceDBControls(Critline.percharDB, spellProfiles):SetPoint("CENTER")
end
