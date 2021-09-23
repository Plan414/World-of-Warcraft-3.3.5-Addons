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

if FW.CLASS == "ROGUE" then
	local FWL = FW.L;
	FWL.HEMORRHAGE = GetSpellInfo(89775);
	FWL.HEMORRHAGE_GLYPH = FWL.HEMORRHAGE..FWL._GLYPH;
	
	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL
	-- French
	if GetLocale() == "frFR" then
	--[[>>]]FWL.SAP_BREAK = "Sap Break";
	--[[>>]]FWL.SAP_FADE = "Sap Fade";
		
	-- Russian
	elseif GetLocale() == "ruRU" then
	--[[>>]]FWL.SAP_BREAK = "Sap Break";
	--[[>>]]FWL.SAP_FADE = "Sap Fade";
		
	-- simplified chinese
	elseif GetLocale() == "zhCN" then
	--[[>>]]FWL.SAP_BREAK = "Sap Break";
	--[[>>]]FWL.SAP_FADE = "Sap Fade";

	-- traditional chinese
	elseif GetLocale() == "zhTW" then
	--[[>>]]FWL.SAP_BREAK = "Sap Break";
	--[[>>]]FWL.SAP_FADE = "Sap Fade";
		
	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
	--[[>>]]FWL.SAP_BREAK = "Sap Break";
	--[[>>]]FWL.SAP_FADE = "Sap Fade";
		
	--Korean
	elseif GetLocale() == "koKR" then
		FWL.SAP_BREAK = "기절 효과 깨짐";
		FWL.SAP_FADE = "기절 효과 풀림";
		
	-- ENGLISH
	else	-- standard english version
		FWL.SAP_BREAK = "Sap Break";
		FWL.SAP_FADE = "Sap Fade";
	end
end
