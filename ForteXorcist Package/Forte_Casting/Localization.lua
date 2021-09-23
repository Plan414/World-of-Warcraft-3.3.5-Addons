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

-- RU by Papo
local FWL = FW.L;

-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

-- French
if GetLocale() == "frFR" then
	FWL.DELAY_MAX_FAIL = "Delay max resist/immune/evade";
	FWL.DELAY_MAX_FASTCAST = "Delay max fastcast fail-success";
	FWL.DISABLE_FOCUS = "I will never use focus-casting";
	FWL.DISABLE_MOUSEOVER = "I will never use mouseover-casting";
	
-- Russian
elseif GetLocale() == "ruRU" then
	FWL.DELAY_MAX_FAIL = "Максимальная задержка сопротивления/устойчивости/мимо";
	FWL.DELAY_MAX_FASTCAST = "Максимальная задержка неудачи-успеха быстрого чтения заклинания";
	FWL.DISABLE_FOCUS = "Я никогда не буду использовать чтение заклинаний с фокусом";
	FWL.DISABLE_MOUSEOVER = "Я никогда не буду использовать чтение заклинаний по наведению мыши";
	
-- tradition Chinese
elseif GetLocale() == "zhCN" then
	FWL.DELAY_MAX_FAIL = "抵抗/免疫/闪避最大延迟";
	FWL.DELAY_MAX_FASTCAST = "施法成功判断最大延迟";
	FWL.DISABLE_FOCUS = "我不想对焦点目标施法";
	FWL.DISABLE_MOUSEOVER = "我不想对鼠标指向目标施法";
	
-- tradition Chinese
elseif GetLocale() == "zhTW" then
	FWL.DELAY_MAX_FAIL = "抵抗/免疫/閃避最大延遲";
	FWL.DELAY_MAX_FASTCAST = "施法成功判斷最大延遲";
	FWL.DISABLE_FOCUS = "我不想對焦點目標施法";
	FWL.DISABLE_MOUSEOVER = "我不想對滑鼠指向目標施法";
	
-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
elseif GetLocale() == "deDE" then
--[[>>]]FWL.DELAY_MAX_FAIL = "Delay max resist/immune/evade";
--[[>>]]FWL.DELAY_MAX_FASTCAST = "Delay max fastcast fail-success";
	FWL.DISABLE_FOCUS = "Ich verwende nie Fokus-Casting";
	FWL.DISABLE_MOUSEOVER = "Ich verwende nie Mouseover-Casting";
	
-- Korean	
elseif GetLocale() == "koKR" then
	FWL.DELAY_MAX_FAIL = "저항/면역/회피 판단 최대 지연";
	FWL.DELAY_MAX_FASTCAST = "빠른시전 실패-성공 판단 최대 지연";
	FWL.DISABLE_FOCUS = "주시-시전 사용 중단";
	FWL.DISABLE_MOUSEOVER = "마우스오버-시전 사용 중단";
	
-- ENGLISH
else
	FWL.DELAY_MAX_FAIL = "Delay max resist/immune/evade";
	FWL.DELAY_MAX_FASTCAST = "Delay max fastcast fail-success";
	FWL.DISABLE_FOCUS = "I will never use focus-casting";
	FWL.DISABLE_MOUSEOVER = "I will never use mouseover-casting";
end
