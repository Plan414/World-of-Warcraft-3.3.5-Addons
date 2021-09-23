--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0
-- Module by Lurosara
-- Shamelessly cribbed from Xus' Forte Warrior module.

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": Korean

!! Make sure to keep this saved as UTF-8 format !!

]]

--[[>> still needs translating]]

if FW.CLASS == "DRUID" then
	local FWL = FW.L;
	FWL.BERSERK = GetSpellInfo(50334);
	FWL.FERAL_CHARGE = GetSpellInfo(16979);
	FWL.MANGLE = GetSpellInfo(33876);
	FWL.SKULL_BASH = GetSpellInfo(80964);
	FWL.SWIPE = GetSpellInfo(779);
	
	-- French
	if GetLocale() == "frFR" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
	
	-- Russian
	elseif GetLocale() == "ruRU" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";


	-- DE
	elseif GetLocale() == "deDE" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
	
	-- SPANISH
	elseif GetLocale() == "esES" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
	
	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
	
	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
	
	-- Korea
	elseif GetLocale() == "koKR" then
	--[[>>]]FWL._FERAL = " (Feral)";
	--[[>>]]FWL._BEAR = " (Bear)";
	--[[>>]]FWL._CAT = " (Cat)";
		
	-- ENGLISH
	else
		FWL._FERAL = " (Feral)";
		FWL._BEAR = " (Bear)";
		FWL._CAT = " (Cat)";
	end

	FWL.BERSERK_FERAL = FWL.BERSERK..FWL._FERAL;
	FWL.FERAL_CHARGE_BEAR = FWL.FERAL_CHARGE..FWL._BEAR;
	FWL.FERAL_CHARGE_CAT = FWL.FERAL_CHARGE..FWL._CAT;
	FWL.MANGLE_BEAR = FWL.MANGLE..FWL._BEAR;
	FWL.MANGLE_CAT = FWL.MANGLE..FWL._CAT;
	FWL.SKULL_BASH_BEAR = FWL.SKULL_BASH..FWL._BEAR;
	FWL.SKULL_BASH_CAT = FWL.SKULL_BASH..FWL._CAT;
	FWL.SWIPE_BEAR = FWL.SWIPE..FWL._BEAR;
	FWL.SWIPE_CAT = FWL.SWIPE..FWL._CAT;
	
	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

end
