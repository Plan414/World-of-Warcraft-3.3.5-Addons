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

local FWL = FW.L;

-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

-- French
if GetLocale() == "frFR" then 
	FWL.TS = "Talent Spy";
	FWL.TS_USE = "You can use the new spy dropdown menu from your Talent frame.";
	FWL.TS_HINT = "For now you have to inspect people that aren't using the addon to store their talents.";
	FWL.TALENT_OFFSETX = "X-offset dropdown";
	FWL.TALENT_OFFSETY = "Y-offset dropdown";
	FWL.TALENT_OFFSET_TT = "Use this in case you're using a customized Talent Frame and need to change the position of the dropdown and buttons.";
	
	FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED";

-- Russian
elseif GetLocale() == "ruRU" then 

	FWL.TS = "Монитор Талантов";
	FWL.TS_USE = "Вы можете использовать новое выпадающий список монитора в окне Талантов.";
	FWL.TS_HINT = "В настоящий момент, вы должны осмотреть людей без этого аддона, для запоминания их талантов.";
	FWL.TALENT_OFFSETX = "Отступ по горизонтали";
	FWL.TALENT_OFFSETY = "Отступ по вертикали";
	FWL.TALENT_OFFSET_TT = "Используйте это, если вы используете измененное окно талантов и требуется изменить позицию выпадающего списка и кнопок.";

--[[>>]]FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED";

-- simple chinese
elseif GetLocale() == "zhCN" then

	FWL.TS = "天赋助手";
	FWL.TS_USE = "在你的天赋窗口有新的下拉菜单使用.";
	FWL.TS_HINT = "你必须要观察那些没有装此插件的人,以保存其天赋.";
	FWL.TALENT_OFFSETX = "菜单水平偏移";
	FWL.TALENT_OFFSETY = "菜单垂直偏移";
	FWL.TALENT_OFFSET_TT = "此选项是为了你使用自定义天赋窗口,需要移动下拉菜单和按钮准备的";

--[[>>]]FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED";

-- tradition chinese
elseif GetLocale() == "zhTW" then

	FWL.TS = "天賦助手";
	FWL.TS_USE = "在你的天賦視窗有新的下拉功能表使用.";
	FWL.TS_HINT = "你必須要觀察那些沒有裝此插件的人,以保存其天賦.";
	FWL.TALENT_OFFSETX = "菜單水準偏移";
	FWL.TALENT_OFFSETY = "菜單垂直偏移";
	FWL.TALENT_OFFSET_TT = "此選項是為了你使用自定義天賦視窗,需要移動下拉功能表和按鈕準備的";

	--[[>>]]FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED"

-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
elseif GetLocale() == "deDE" then
	FWL.TS = "Talent Spion";
	FWL.TS_USE = "Du kannst das neue Spionage Dropdown Menu in deinem Talentfenster benutzen.";
	FWL.TS_HINT = "Nun kannst du Spieler betrachten, die dieses Addon nicht nutzen um ihre Talente zu speichern.";
	FWL.TALENT_OFFSETX = "Dropdown X-Offset";
	FWL.TALENT_OFFSETY = "Dropdown Y-Offset";
	FWL.TALENT_OFFSET_TT = "Verwende dies wenn du nicht das originale Talentfenster verwendest und ein Ändern der Position der Dropdown Menus und Buttons erforderlich ist.";
	FWL.TS_DISABLED = "DER TALENT SPION IST DERZEIT DEAKTIVIERT";

-- Korean
elseif GetLocale() == "koKR" then

	FWL.TS = "특성 엿보기";
	FWL.TS_USE = "특성을 목록으로 저장 활성화";
	FWL.TS_HINT = "이 애드온을 사용하지 않는 사람들은 살펴보기를 통해서 특성정보를 저장할 수 있습니다.";
	FWL.TALENT_OFFSETX = "X-축 위치";
	FWL.TALENT_OFFSETY = "Y-축 위치";
	FWL.TALENT_OFFSET_TT = "임의로 제작된 특성 프레임을 사용할 때 목록이나 버튼이 제대로 안나올 경우 위치를 조정할 수 있습니다..";
	
--[[>>]]FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED";
-- ENGLISH
else

	FWL.TS = "Talent Spy";
	FWL.TS_USE = "You can use the new spy dropdown menu from your Talent frame.";
	FWL.TS_HINT = "For now you have to inspect people that aren't using the addon to store their talents.";
	FWL.TALENT_OFFSETX = "X-offset dropdown";
	FWL.TALENT_OFFSETY = "Y-offset dropdown";
	FWL.TALENT_OFFSET_TT = "Use this in case you're using a customized Talent Frame and need to change the position of the dropdown and buttons.";
	
	FWL.TS_DISABLED = "THE TALENT SPY IS CURRENTLY DISABLED";
end