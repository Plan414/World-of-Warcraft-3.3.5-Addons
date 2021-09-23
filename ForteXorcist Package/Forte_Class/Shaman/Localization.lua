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
if FW.CLASS == "SHAMAN" then
--[[>> still needs translating]]
	local FWL = FW.L;

	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL
	
	-- French
	if GetLocale() == "frFR" then
		--[[>>]]FWL.TOTEM_FIRE = "Fire Totem";
		--[[>>]]FWL.TOTEM_EARTH = "Earth Totem";
		--[[>>]]FWL.TOTEM_WATER = "Water Totem";
		--[[>>]]FWL.TOTEM_AIR = "Air Totem";	

	-- Russian
	elseif GetLocale() == "ruRU" then
		--[[>>]]FWL.TOTEM_FIRE = "Fire Totem";
		--[[>>]]FWL.TOTEM_EARTH = "Earth Totem";
		--[[>>]]FWL.TOTEM_WATER = "Water Totem";
		--[[>>]]FWL.TOTEM_AIR = "Air Totem";	

	-- SPANISH
	elseif GetLocale() == "esES" then
		--[[>>]]FWL.TOTEM_FIRE = "Fire Totem";
		--[[>>]]FWL.TOTEM_EARTH = "Earth Totem";
		--[[>>]]FWL.TOTEM_WATER = "Water Totem";
		--[[>>]]FWL.TOTEM_AIR = "Air Totem";	

	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
		--[[>>]]FWL.TOTEM_FIRE = "Fire Totem";
		--[[>>]]FWL.TOTEM_EARTH = "Earth Totem";
		--[[>>]]FWL.TOTEM_WATER = "Water Totem";
		--[[>>]]FWL.TOTEM_AIR = "Air Totem";	

	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
		--[[>>]]FWL.TOTEM_FIRE = "Fire Totem";
		--[[>>]]FWL.TOTEM_EARTH = "Earth Totem";
		--[[>>]]FWL.TOTEM_WATER = "Water Totem";
		--[[>>]]FWL.TOTEM_AIR = "Air Totem";	

	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
		FWL.TOTEM_FIRE = "Feuertotem";
		FWL.TOTEM_EARTH = "Erdtotem";
		FWL.TOTEM_WATER = "Wassertotem";
		FWL.TOTEM_AIR = "Lufttotem";	
		
	--Korean
	elseif GetLocale() == "koKR" then
		FWL.TOTEM_FIRE = "불 토템";
		FWL.TOTEM_EARTH = "땅 토템";
		FWL.TOTEM_WATER = "물 토템";
		FWL.TOTEM_AIR = "바람 토템";		
	
	-- ENGLISH
	else
		FWL.TOTEM_FIRE = "Fire Totem";
		FWL.TOTEM_EARTH = "Earth Totem";
		FWL.TOTEM_WATER = "Water Totem";
		FWL.TOTEM_AIR = "Air Totem";	
	end

end