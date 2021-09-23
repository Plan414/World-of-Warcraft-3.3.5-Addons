--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

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

if FW.CLASS == "DEATHKNIGHT" then
	local FWL = FW.L;
	
	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL
	
	-- French
	if GetLocale() == "frFR" then
		FWL.RUNE_BLOOD = "Blood Rune";
		FWL.RUNE_UNHOLY = "Unholy Rune";
		FWL.RUNE_FROST = "Frost Rune";
		FWL.RUNE_ALL = "Death Rune";
	
	-- Russian
	elseif GetLocale() == "ruRU" then
--[[>>]]FWL.RUNE_BLOOD = "Blood Rune";
--[[>>]]FWL.RUNE_UNHOLY = "Unholy Rune";
--[[>>]]FWL.RUNE_FROST = "Frost Rune";
--[[>>]]FWL.RUNE_ALL = "Death Rune";
	
	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
		FWL.RUNE_BLOOD = "鲜血符文 ";
		FWL.RUNE_UNHOLY = "邪恶符文";
		FWL.RUNE_FROST = "冰霜符文";
		FWL.RUNE_ALL = "死亡符文";	
		
	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
		FWL.RUNE_BLOOD = "血魄符文";
		FWL.RUNE_UNHOLY = "穢邪符文";
		FWL.RUNE_FROST = "冰霜符文";
		FWL.RUNE_ALL = "死亡符文";
		
	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
		FWL.RUNE_BLOOD = "Blutrune";
		FWL.RUNE_UNHOLY = "Unheiligrune";
		FWL.RUNE_FROST = "Frostrune";
		FWL.RUNE_ALL = "Todesrune";	
		
	--Korea
	elseif GetLocale() == "koKR" then
		FWL.RUNE_BLOOD = "혈기의 룬";
		FWL.RUNE_UNHOLY = "부정의 룬";
		FWL.RUNE_FROST = "냉기의 룬";
		FWL.RUNE_ALL = "죽음의 룬";

	-- ENGLISH
	else
		FWL.RUNE_BLOOD = "Blood Rune";
		FWL.RUNE_UNHOLY = "Unholy Rune";
		FWL.RUNE_FROST = "Frost Rune";
		FWL.RUNE_ALL = "Death Rune";		
	end
end
