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

if FW.CLASS == "HUNTER" then
	local FWL = FW.L;
	if GetLocale() == "ruRU" then
		FWL.SNAKE1 = "Viper";
	-- FR
	elseif GetLocale() == "frFR" then
		FWL.SNAKE1 = "Viper";
	-- DE 
	elseif GetLocale() == "deDE" then
		FWL.SNAKE1 = "Viper";
	-- SPANISH
	elseif GetLocale() == "esES" then
		FWL.SNAKE1 = "Viper";
	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
		FWL.SNAKE1 = "Viper";
	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
		FWL.SNAKE1 = "Viper";
	-- KOREAN
	elseif GetLocale() == "koKR" then
		FWL.SNAKE1 = "Viper";
	-- ENGLISH
	else
		FWL.SNAKE1 = "Viper";
	end
end
