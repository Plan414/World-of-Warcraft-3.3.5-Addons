local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

-- default (EN)
TITAN_GUILD_MENU_TEXT = "Guild"
TITAN_GUILD_BUTTON_LABEL = "Guild: "
TITAN_GUILD_TOOLTIP = "Guild Info"
TITAN_GUILD_GUILD_CHAT = "Guild Chat";
TITAN_GUILD_GUILD_OFFICER_CHAT = "Guild Officer Chat";
TITAN_GUILD_SHOWOFFLINE = "Show Offline Members";
TITAN_GUILD_NOT_IN_GUILD = "Not a guild member";
TITAN_GUILD_MENU_SHOWADVANCED_TEXT = "Show Advanced Menus";
TITAN_GUILD_MENU_ADVANCED_INVITE_TEXT = "invite";
TITAN_GUILD_MENU_ADVANCED_WHISPER_TEXT = "whisper";
TITAN_GUILD_MENU_ADVANCED_WHO_TEXT = "who";
TITAN_GUILD_MENU_ADVANCED_FRIEND_TEXT = "friend";
TITAN_GUILD_MENU_CHAT_TEXT = "Chat";
TITAN_GUILD_MENU_SORT_TEXT = "Sort";
TITAN_GUILD_MENU_FILTER_TEXT = "Filter";
TITAN_GUILD_MENU_TOOLTIP_TEXT = "Tooltip";
TITAN_GUILD_TOOLTIP_HINT_TEXT = "Hint: Left-click to toggle guild window";
TITAN_GUILD_MENU_PLEASE_WAIT_TEXT = "Please wait...refreshing";
TITAN_GUILD_MENU_HIDE_OPTIONS_TEXT = "Hide options";
TITAN_GUILD_MENU_SHOW_OPTIONS_TEXT = "Show options";
TITAN_GUILD_MENU_HIDE = "|cff999999"..L["TITAN_PANEL_MENU_HIDE"].."|r";
TITAN_GUILD_MENU_FILTER_MYZONE = "within my zone";
TITAN_GUILD_MENU_FILTER_MYLEVEL = "within my level";
TITAN_GUILD_MENU_FILTER_CLASS = "Class";
TITAN_GUILD_MENU_FORWARD_TEXT = "Forward";
TITAN_GUILD_MENU_BACKWARD_TEXT = "Back";
TITAN_GUILD_TOOLTIP_WARNING = "Can not display all members. Use Filters!";
TITAN_GUILD_MENU_DISABLE_UPDATE_TEXT = "Disable auto-roster update";
TITAN_GUILD_MENU_CONFIGURE_UPDATE_TIME = "Update";
TITAN_GUILD_MENU_DISABLE_MOUSEOVER_UPDATE = "Disable mouse-over update";

-- format
TITAN_GUILD_BUTTON_TEXT = "%s"..TitanUtils_GetHighlightText("/").."%s";
TITAN_GUILD_BUTTON_TEXT_FILTERED = "%s"..TitanUtils_GetHighlightText("/").."%s"..TitanUtils_GetHighlightText("/").."%s";
TITAN_GUILD_BUTTON_TEXT_ONLINEONLY_FORMAT = "%s";

-- update time options
updateTimeOptions = {"60", "180", "300"};
updateTimeLabels = {};
-- init updateTimeLabels
if (GetLocale() == "deDE") then
	updateTimeLabels = {"1 min", "3 min", "5 min"};
elseif (GetLocale() == "frFR") then
	updateTimeLabels = {"1 min", "3 min", "5 min"};
elseif (GetLocale() == "esES") then
	updateTimeLabels = {"1 min", "3 min", "5 min"};	
elseif (GetLocale() == "ruRU") then
	updateTimeLabels = {"1 мин", "3 мин", "5 мин"};
else
	updateTimeLabels = {"1 min", "3 min", "5 min"};
end

-- sort options
sortChoicesValues = {"Name","Zone","Rank","Note","Level","Class"};
sortChoicesLabels = {};
-- init sortChoices
if (GetLocale() == "deDE") then
	sortChoicesLabels = {"Name","Zone","Rang","Hinweis","Stufe","Klasse"};
elseif (GetLocale() == "frFR") then
	sortChoicesLabels = {"Nom","Zone","Rang","Note","Niveau","Classe"};
elseif (GetLocale() == "esES") then
	sortChoicesLabels = {"Nombre","Zona","Rango","Nota","Nivel","Clase"};	
elseif (GetLocale() == "ruRU") then
	sortChoicesLabels = {"Имя","Зона","Звание","Заметка","Уровень","Класс"};
else
	sortChoicesLabels = {"Name","Zone","Rank","Note","Level","Class"};
end

-- class filter options
if (GetLocale() == "deDE") then
	classListLabels = {"Alle",
			   "Krieger",
			   "Kriegerin",
			   "Magier",
			   "Magierin",
			   "Schurke",
			   "Schurkin",
			   "Druide",
			   "Druidin",
			   "J\195\164ger",
			   "J\195\164gerin",
			   "Schamane",
			   "Schamanin",
			   "Priester",
			   "Priesterin",
			   "Hexenmeister",
			   "Hexenmeisterin",
			   "Paladin",
                           "Todesritter"};
	classListValues = {"All",
			   "Krieger",
			   "Kriegerin",
			   "Magier",
			   "Magierin",
			   "Schurke",
			   "Schurkin",
			   "Druide",
			   "Druidin",
			   "J\195\164ger",
			   "J\195\164gerin",
			   "Schamane",
			   "Schamanin",
			   "Priester",
			   "Priesterin",
			   "Hexenmeister",
			   "Hexenmeisterin",
			   "Paladin",
                           "Todesritter"};

elseif (GetLocale() == "frFR") then
	classListLabels = {"All",
			   "Druide",
			   "Druidesse",
			   "Chasseur",
			   "Chasseresse",
			   "Mage",
			   "Paladin",
			   "Pr\195\170tre",
			   "Pr\195\170tresse",
			   "Voleur",
			   "Voleuse",
			   "Chaman",
			   "Chamane",
			   "D\195\169moniste",
			   "Guerrier",
			   "Guerri\195\168re",
			   "Chevalier de la mort"}; 

	classListValues = {"All",
			   "Druide",
			   "Druidesse",
			   "Chasseur",
			   "Chasseresse",
			   "Mage",
			   "Paladin",
			   "Pr\195\170tre",
			   "Pr\195\170tresse",
			   "Voleur",
			   "Voleuse",
			   "Chaman",
			   "Chamane",
			   "D\195\169moniste",
			   "Guerrier",
			   "Guerri\195\168re",
			   "Chevalier de la mort"};
elseif (GetLocale() == "esES") then
	classListLabels = {"Todas",
			   "Druida",
			   "Cazador",
			   "Cazadora",
			   "Mago",
			   "Maga",
			   "Palad\195\173n",
			   "Sacerdote",
			   "Sacerdotisa",
			   "P\195\173caro",
			   "P\195\173cara",
			   "Cham\195\161n",
			   "Brujo",
			   "Bruja",
			   "Guerrero",
			   "Guerrera",
                           "Caballero de la Muerte"};
	classListValues = {"All",
			   "Druida",
			   "Cazador",
			   "Cazadora",
			   "Mago",
			   "Maga",
			   "Palad\195\173n",
			   "Sacerdote",
			   "Sacerdotisa",
			   "P\195\173caro",
			   "P\195\173cara",
			   "Cham\195\161n",
			   "Brujo",
			   "Bruja",
			   "Guerrero",
			   "Guerrera",
                           "Caballero de la Muerte"};
elseif (GetLocale() == "ruRU") then
	classListValues = {"All",
                           "Воин", 
                           "Маг", 
                           "Разбойник", 
                           "Разбойница", 
                           "Охотник", 
                           "Охотница", 
                           "Шаман", 
                           "Шаманка", 
                           "Жрец", 
                           "Жрица", 
                           "Чернокнижник", 
                           "Чернокнижница", 
                           "Паладин",
                           "Рыцарь смерти"};
	classListLabels = {"Все",
                           "Воин", 
                           "Маг", 
                           "Разбойник", 
                           "Разбойница", 
                           "Охотник", 
                           "Охотница", 
                           "Шаман", 
                           "Шаманка", 
                           "Жрец", 
                           "Жрица", 
                           "Чернокнижник", 
                           "Чернокнижница", 
                           "Паладин",
                           "Рыцарь смерти"};
else
	classListValues = {"All", "Warrior", "Mage", "Rogue", "Druid", "Hunter", "Shaman", "Priest", "Warlock", "Paladin", "Death Knight"};
	classListLabels = {"All", "Warrior", "Mage", "Rogue", "Druid", "Hunter", "Shaman", "Priest", "Warlock", "Paladin", "Death Knight"};
end

TITAN_GUILD_CLASSINDEX = {
	["Druid"]        = 1,
	["Hunter"]       = 2,
	["Mage"]         = 3,
	["Paladin"]      = 4,
	["Priest"]       = 5,
	["Rogue"]        = 6,
	["Shaman"]       = 7,
	["Warlock"]      = 8,
	["Warrior"]      = 9,
        ["Death Knight"] = 10,
-- de
	["Druide"] = 1,
	["Druidin"] = 1,
	["J\195\164ger"] = 2,
	["J\195\164gerin"] = 2,
	["Magier"] = 3,
	["Magierin"] = 3,
	["Paladin"] = 4,
        -- no female	["Paladin"] = 4,
	["Priester"] = 5,
	["Priesterin"] = 5,
	["Schurke"] = 6,
	["Schurkin"] = 6,
	["Schamane"] = 7,
	["Schamanin"] = 7,
	["Hexenmeister"] = 8,
	["Hexenmeisterin"] = 8,
	["Krieger"] = 9,
	["Kriegerin"] = 9,
        ["Todesritter"] = 10,
        -- possibly female unknown
-- fr
	["Druide"] = 1,
	["Druidesse"] = 1,
	["Chasseur"] = 2,
	["Chasseresse"] = 2,
	["Mage"] = 3,
        -- no female	["Mage"] = 3,
	["Paladin"] = 4,
        -- no female ["Paladin"] = 4,
	["Pr\195\170tre"] = 5,
	["Pr\195\170tresse"] = 5,
	["Voleur"] = 6,
	["Voleuse"] = 6,
	["Chaman"] = 7,
	["Chamane"] = 7,
	["D\195\169moniste"] = 8,
        -- no female	["D\195\169moniste"] = 8,
	["Guerrier"] = 9,
	["Guerri\195\168re"] = 9,
        ["Chevalier de la mort"] = 10,  -- Translation via Google
        -- possibly female unknown
-- es
	["Druida"]   = 1,
	["Cazador"]  = 2,
	["Cazadora"]  = 2,
	["Mago"]    = 3,
	["Maga"]    = 3,
	["Palad\195\173n"] = 4,
        -- no female	["Palad\195\173n"] = 4,
	["Sacerdote"]  = 5,
	["Sacerdotisa"]  = 5,
	["P\195\173caro"]   = 6,
	["P\195\173cara"]   = 6,
	["Cham\195\161n"]  = 7,
        -- no female	["Cham\195\161n"]  = 7,
	["Brujo"] = 8,
	["Bruja"] = 8,
	["Guerrero"] = 9,
	["Guerrera"] = 9,
        ["Caballero de la Muerte"] = 10,  -- Translation via Google
        -- possibly female unknown
-- ru	
	["Друид"]   = 1,
	["Охотник"]  = 2,
	["Охотница"]  = 2,
	["Маг"]    = 3,
	["Паладин"] = 4,
	["Жрец"]  = 5,
	["Жрица"]  = 5,
	["Разбойник"]   = 6,
	["Разбойница"]   = 6,
	["Шаман"]  = 7,
	["Шаманка"]  = 7,
	["Чернокнижник"] = 8,
	["Чернокнижница"] = 8,
	["Воин"] = 9,
        ["Рыцарь смерти"] = 10, -- Translation via Google
        -- possibly female unknown
};

-- German localization by Crowley and Scarabeus
if ( GetLocale() == "deDE" ) then
	TITAN_GUILD_MENU_TEXT = "Gilde"
	TITAN_GUILD_BUTTON_LABEL = "Gilde: "
	TITAN_GUILD_TOOLTIP = "Liste"
	TITAN_GUILD_GUILD_CHAT = "Chat";
	TITAN_GUILD_GUILD_OFFICER_CHAT = "Offiziers-Chat";
	TITAN_GUILD_SHOWOFFLINE = "Zeige Offline";
	TITAN_GUILD_NOT_IN_GUILD = "Kein Gildenmitglied";
	TITAN_GUILD_MENU_SHOWADVANCED_TEXT = "Erweitertes Men\195\188anzeigen";
	TITAN_GUILD_MENU_ADVANCED_INVITE_TEXT = "Einladen";
	TITAN_GUILD_MENU_ADVANCED_WHISPER_TEXT = "Fl\195\188stern";
	TITAN_GUILD_MENU_ADVANCED_WHO_TEXT = "Wer";
	TITAN_GUILD_MENU_ADVANCED_FRIEND_TEXT = "Freund";	
	TITAN_GUILD_MENU_CHAT_TEXT = "Chat";
	TITAN_GUILD_MENU_SORT_TEXT = "Sortierung";
	TITAN_GUILD_MENU_FILTER_TEXT = "Filter";
	TITAN_GUILD_MENU_TOOLTIP_TEXT = "Tooltip";
	TITAN_GUILD_TOOLTIP_HINT_TEXT = "Hinweis: Links-Klick zum \195\150ffnen des Gilden-Men\195\188s";
	TITAN_GUILD_MENU_PLEASE_WAIT_TEXT = "Bitte warten...aktualisiere";
	TITAN_GUILD_MENU_HIDE_OPTIONS_TEXT = "Optionen ausblenden";
	TITAN_GUILD_MENU_SHOW_OPTIONS_TEXT = "Optionen anzeigen";
	TITAN_GUILD_MENU_FILTER_MYZONE = "innerhalb meiner Zone";
	TITAN_GUILD_MENU_FILTER_MYLEVEL = "in meinem Level";
	TITAN_GUILD_MENU_FILTER_CLASS = "Klasse";
	TITAN_GUILD_MENU_FORWARD_TEXT = "Vor\195\164rts";
	TITAN_GUILD_MENU_BACKWARD_TEXT = "R\195\188ckw\195\164rts";
	TITAN_GUILD_TOOLTIP_WARNING = "Kann nicht alle Mitglieder anzeigen. Nutze Filter!";
	TITAN_GUILD_MENU_DISABLE_UPDATE_TEXT = "Deaktiviere Auto-Update";
	TITAN_GUILD_MENU_CONFIGURE_UPDATE_TIME = "Update";
	TITAN_GUILD_MENU_DISABLE_MOUSEOVER_UPDATE = "Deaktiviere Maus-\195\188ber Update";				
end

-- French localization by Feu
if ( GetLocale() == "frFR" ) then
	TITAN_GUILD_MENU_TEXT = "Guilde"
	TITAN_GUILD_BUTTON_LABEL = "Guilde : "
	TITAN_GUILD_TOOLTIP = "Information de la guilde"
	TITAN_GUILD_GUILD_CHAT = "Canal de la guilde";
	TITAN_GUILD_GUILD_OFFICER_CHAT = "Canal des officiers de la guilde";
	TITAN_GUILD_SHOWOFFLINE = "Montrer les membres non connect\195\169s";
 	TITAN_GUILD_NOT_IN_GUILD = "Vous n'\195\170tes pas membre d'une guilde !";
	TITAN_GUILD_MENU_SHOWADVANCED_TEXT = "Montrer les menus avanc\195\169s";
	TITAN_GUILD_MENU_ADVANCED_INVITE_TEXT = "Inviter";
	TITAN_GUILD_MENU_ADVANCED_WHISPER_TEXT = "Chuchoter";
	TITAN_GUILD_MENU_ADVANCED_WHO_TEXT = "Qui";
	TITAN_GUILD_MENU_ADVANCED_FRIEND_TEXT = "Ami";
	TITAN_GUILD_MENU_CHAT_TEXT = "Chat";
	TITAN_GUILD_MENU_SORT_TEXT = "Trier";
	TITAN_GUILD_MENU_FILTER_TEXT = "Filtre";
	TITAN_GUILD_MENU_TOOLTIP_TEXT = "Tooltip";
	TITAN_GUILD_TOOLTIP_HINT_TEXT = "Conseil : clic-gauche pour afficher la fen\195\170tre Guilde";
	TITAN_GUILD_MENU_PLEASE_WAIT_TEXT = "Veuillez patienter...actualisation ";
	TITAN_GUILD_MENU_HIDE_OPTIONS_TEXT = "Cacher les options";
	TITAN_GUILD_MENU_SHOW_OPTIONS_TEXT = "Montrer les options";
	TITAN_GUILD_MENU_FILTER_MYZONE = "Dans ma zone";
	TITAN_GUILD_MENU_FILTER_MYLEVEL = "Dans mon niveau";
	TITAN_GUILD_MENU_FILTER_CLASS = "Classe";
	TITAN_GUILD_MENU_FORWARD_TEXT = "Vers l'avant";
	TITAN_GUILD_MENU_BACKWARD_TEXT = "Vers l\'arri\195\168re";
	TITAN_GUILD_TOOLTIP_WARNING = "Impossible d\'afficher tous les membres. Utilisez les filtres !";
	TITAN_GUILD_MENU_DISABLE_UPDATE_TEXT = "D\195\169sactiver la mise-\195\160-jour automatique";
	TITAN_GUILD_MENU_CONFIGURE_UPDATE_TIME = "Mise-\195\160-jour";
	TITAN_GUILD_MENU_DISABLE_MOUSEOVER_UPDATE = "Disable mouse-over update";						 
end

-- Spanish localization by NeKRoMaNT
if ( GetLocale() == "esES" ) then
TITAN_GUILD_MENU_TEXT = "Hermandad"
TITAN_GUILD_BUTTON_LABEL = "Hermandad: "
TITAN_GUILD_TOOLTIP = "Info Hermandad"
TITAN_GUILD_GUILD_CHAT = "Chat Hermandad";
TITAN_GUILD_GUILD_OFFICER_CHAT = "Chat Oficiales Hermandad";
TITAN_GUILD_SHOWOFFLINE = "Mostrar Miembros Desconectados";
TITAN_GUILD_NOT_IN_GUILD = "No eres miembro de una hermandad";
TITAN_GUILD_MENU_SHOWADVANCED_TEXT = "Mostrar Opciones Avanzadas";
TITAN_GUILD_MENU_ADVANCED_INVITE_TEXT = "invitar";
TITAN_GUILD_MENU_ADVANCED_WHISPER_TEXT = "susurrar";
TITAN_GUILD_MENU_ADVANCED_WHO_TEXT = "quien";
TITAN_GUILD_MENU_ADVANCED_FRIEND_TEXT = "amigo";
TITAN_GUILD_MENU_CHAT_TEXT = "Chat";
TITAN_GUILD_MENU_SORT_TEXT = "Ordenar";
TITAN_GUILD_MENU_FILTER_TEXT = "Filtrar";
TITAN_GUILD_MENU_TOOLTIP_TEXT = "Consejos Detallados";
TITAN_GUILD_TOOLTIP_HINT_TEXT = "Pista: bot\195\179n derecho para abrir ventana de hermandad";
TITAN_GUILD_MENU_PLEASE_WAIT_TEXT = "Por favor, espera...actualizando";
TITAN_GUILD_MENU_HIDE_OPTIONS_TEXT = "Ocultar Opciones";
TITAN_GUILD_MENU_SHOW_OPTIONS_TEXT = "Mostrar Opciones";
TITAN_GUILD_MENU_FILTER_MYZONE = "en mi zona";
TITAN_GUILD_MENU_FILTER_MYLEVEL = "de mi nivel";
TITAN_GUILD_MENU_FILTER_CLASS = "Clase";
TITAN_GUILD_MENU_FORWARD_TEXT = "Adelante";
TITAN_GUILD_MENU_BACKWARD_TEXT = "Atr\195\161s";
TITAN_GUILD_TOOLTIP_WARNING = "No puedo mostrar todos los miembros. Utiliza filtros";
TITAN_GUILD_MENU_DISABLE_UPDATE_TEXT = "Desactiva actualizaci\195\179n autom\195\161tica";
TITAN_GUILD_MENU_CONFIGURE_UPDATE_TIME = "Actualizar";
TITAN_GUILD_MENU_DISABLE_MOUSEOVER_UPDATE = "Desactiva actualizaci\195\179n al pasar el rat\195\179n";
end

-- Russian localization by StingerSoft (Eritnull aka Шептун)
if ( GetLocale() == "ruRU" ) then
	TITAN_GUILD_MENU_TEXT = "Гильдия"
	TITAN_GUILD_BUTTON_LABEL = "Гильдия: "
	TITAN_GUILD_TOOLTIP = "О Гильдии"
	TITAN_GUILD_GUILD_CHAT = "Чат Гильдии";
	TITAN_GUILD_GUILD_OFFICER_CHAT = "Офицерский чат Гильдии";
	TITAN_GUILD_SHOWOFFLINE = "Показ игроков в не сети";
	TITAN_GUILD_NOT_IN_GUILD = "Не член гильдии";
	TITAN_GUILD_MENU_SHOWADVANCED_TEXT = "Показать расширенное меню";
	TITAN_GUILD_MENU_ADVANCED_INVITE_TEXT = "пригласить";
	TITAN_GUILD_MENU_ADVANCED_WHISPER_TEXT = "шепнуть";
	TITAN_GUILD_MENU_ADVANCED_WHO_TEXT = "кто";
	TITAN_GUILD_MENU_ADVANCED_FRIEND_TEXT = "друзья";
	TITAN_GUILD_MENU_CHAT_TEXT = "Чат";
	TITAN_GUILD_MENU_SORT_TEXT = "Сортировать";
	TITAN_GUILD_MENU_FILTER_TEXT = "Фильтор";
	TITAN_GUILD_MENU_TOOLTIP_TEXT = "Подсказка";
	TITAN_GUILD_TOOLTIP_HINT_TEXT = "Совет: ЛКМ открывает/закрывает окно гильдии";
	TITAN_GUILD_MENU_PLEASE_WAIT_TEXT = "Пожалуйста подождите...обновляется";
	TITAN_GUILD_MENU_HIDE_OPTIONS_TEXT = "Скрыть опции";
	TITAN_GUILD_MENU_SHOW_OPTIONS_TEXT = "Показать опции";
	TITAN_GUILD_MENU_FILTER_MYZONE = "в пределах моей зоны";
	TITAN_GUILD_MENU_FILTER_MYLEVEL = "в пределах моего уровня";
	TITAN_GUILD_MENU_FILTER_CLASS = "Класс";
	TITAN_GUILD_MENU_FORWARD_TEXT = "Вперед";
	TITAN_GUILD_MENU_BACKWARD_TEXT = "Назад";
	TITAN_GUILD_TOOLTIP_WARNING = "невозможно отобразить всех членов гильдии. Воспользуйтесь Фильтрами!";
	TITAN_GUILD_MENU_DISABLE_UPDATE_TEXT = "Отключить авто-обновление списка";
	TITAN_GUILD_MENU_CONFIGURE_UPDATE_TIME = "Обновить";
	TITAN_GUILD_MENU_DISABLE_MOUSEOVER_UPDATE = "Отключить обновление при наводе курсора";
end
--Lua-Code für Umlaute:----à : \195\160 | ò : \195\178 | è : \195\168 | ì : \195\172 | ù : \195\185--á : \195\161 | ó : \195\179 | é : \195\169 | í : \195\173 | ú : \195\186--â : \195\162 | ô : \195\180 | ê : \195\170 | î : \195\174 | û : \195\187--ã : \195\163 | õ : \195\181 | ë : \195\171 | ï : \195\175 | ü : \195\188--ä : \195\164 | ö : \195\182--æ: \195\166 | ø : \195\184----ç : \195\167--ñ : \195\177----Ä : \195\132--Ö : \195\150--Ü : \195\156--ß : \195\159