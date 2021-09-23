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



if FW.CLASS == "MAGE" then
	local FWL = FW.L;

	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

	-- French
	if GetLocale() == "frFR" then
		FWL.POLYMORPH_BREAK = "Polymorph Break";
		FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	-- Russian
	elseif GetLocale() == "ruRU" then
	--[[>>]]FWL.POLYMORPH_BREAK = "Polymorph Break";
	--[[>>]]FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	-- simplified chinese
	elseif GetLocale() == "zhCN" then
		FWL.POLYMORPH_BREAK = "变形术打断";
		FWL.POLYMORPH_FADE = "变形术消退";

	-- traditional chinese
	elseif GetLocale() == "zhTW" then
		FWL.POLYMORPH_BREAK = "變形術打斷";
		FWL.POLYMORPH_FADE = "變形術消退";
		
	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
	--[[>>]]FWL.POLYMORPH_BREAK = "Polymorph Break";
	--[[>>]]FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	--Korean
	elseif GetLocale() == "koKR" then
		FWL.POLYMORPH_BREAK = "변이 깨짐";
		FWL.POLYMORPH_FADE = "변이 풀림";
		
	-- ENGLISH
	else	-- standard english version
		FWL.POLYMORPH_BREAK = "Polymorph Break";
		FWL.POLYMORPH_FADE = "Polymorph Fade";

	end
end
	