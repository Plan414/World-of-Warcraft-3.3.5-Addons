-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0-ElvUI");
local L = AceLocale:NewLocale("ElvUI", "enUS", true);
if not L then return; end

L["%s is a collection of various tweaks for ElvUI. New features or changes have been requested by regular users and then fulfilled by members of the Tukui community."] = true;
L["%s is the author of the following tweaks:"] = true;
L["%s version %s by Blazeflack of tukui.org"] = true;
L["Actionbar Tweaks"] = true;
L["Add 'Stack' Button"] = true;
L["AddOn Description / Download"] = true;
L["Allows you to change bag buttons to use the classic texture style and allows you to add a 'Stack' button."] = true;
L["Allows you to change template of the Raid Control button or hide it altogether."] = true;
L["Allows you to change the text and duration font for the castbar."] = true;
L["Allows you to choose the color of the actionbar button when it is pushed down."] = true;
L["Allows you to choose which text format the Bags datatext uses."] = true;
L["Allows you to make actionbars clickthrough."] = true;
L["Allows you to position and change color and alpha of castbar text."] = true;
L["Allows you to set a spacing between individual aura icons for the units you choose."] = true;
L["Allows you to use a separate texture for unitframe power bars."] = true;
L["Assist"] = true;
L["Attempts to remove borders on all ElvUI elements. This doesn't work on all statusbars, so some borders will be kept intact."] = true
L["Aura Spacing"] = true;
L["Bags Text Format"] = true;
L["Bags Tweaks"] = true;
L["Boss"] = true;
L["Button Color"] = true;
L["Button Style"] = true;
L["Chat Tweaks"] = true;
L["Credit"] = true;
L["Datatexts Tweaks"] = true;
L["Focus"] = true;
L["FocusTarget"] = true;
L["Free/Total"] = true;
L["Hide Raid Control"] = true;
L["Hide Text On Units"] = true;
L["Hold Shift:"] = true;
L["Icons"] = true;
L["Increases the amount of messages saved in a chat window, before they get replaced by new messages."] = true;
L["Increases the maximum allowed vertical and horizontal spacing for party and raid frames."] = true;
L["Information / Help"] = true;
L["Invalid name, check spelling."] = true;
L["Lowers the minimum allowed minimap size."] = true;
L["Makes the Consolidated Buffs frame movable and provides some configuration options."] = true;
L["Max Lines"] = true;
L["Minimap Tweaks"] = true;
L["Misc Tweaks"] = true;
L["NamePlate Tweaks"] = true;
L["Only Free Slots"] = true;
L["Only Used Slots"] = true;
L["Options"] = true;
L["Party"] = true;
L["Pet"] = true;
L["PetTarget"] = true;
L["Player"] = true;
L["Please use the following links if you need help or wish to know more about this AddOn."] = true;
L["Position of the stack count on the aura icon."] = true;
L["PowerBar Texture"] = true;
L["Raid"] = true;
L["Raid40"] = true;
L["RaidPet"] = true;
L["Report Bugs / Request Tweaks"] = true;
L["Set Aura Spacing On Following Units"] = true;
L["Sets space between individual aura icons."] = true;
L["Some tweaks may provide customizable options when enabled. If so then they will appear in the '%s' field below."] = true;
L["Stack Items In Bags"] = true;
L["Stack Items In Bank"] = true;
L["Stack Items To Bags"] = true;
L["Stack Items To Bank"] = true;
L["Tank"] = true;
L["Target"] = true;
L["TargetTarget"] = true;
L["TargetTargetTarget"] = true;
L["The max amount of messages kept in chat before they get replaced by new messages. Changing this setting will clear the chat in all windows."] = true;
L["Tweaks"] = true;
L["Unitframe Tweaks"] = true;
L["Use Transparent Template"] = true;
L["Used/Total"] = true;

--We don't need the rest if we're on enUS or enGB locale, so stop here.
if GetLocale() == "enUS" then return end

--German Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "deDE")
if L then
	--Add translations here
end

--Spanish (Spain) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "esES")
if L then
	--Add translations here
end

--Spanish (Mexico) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "esMX")
if L then
	--Add translations here
end

--French Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "frFR")
if L then
	--Add translations here
end

--Italian Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "itIT")
if L then
	--Add translations here
end

--Korean Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "koKR")
if L then
	--Add translations here
end

--Portuguese Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "ptBR")
if L then
	--Add translations here
end

--Russian Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "ruRU")
if L then
	L["%s is a collection of various tweaks for ElvUI. New features or changes have been requested by regular users and then fulfilled by members of the Tukui community."] = "%s представляет собой набор различных настроек для ElvUI. Новые возможности или изменения были запрошены обычными пользователями, а затем реализованы членами сообщества TukUI.";
	L["%s is the author of the following tweaks:"] = "%s является автором следующих твиков:";
	L["%s version %s by Blazeflack of tukui.org"] = "%s версия %s от Blazeflack с tukui.org";
	L["Actionbar Tweaks"] = "Твики панелей команд";
	L["Add 'Stack' Button"] = "Добавить кнопку 'Собрать'";
	L["AddOn Description / Download"] = "Описание / Скачать:";
	L["Allows you to change bag buttons to use the classic texture style and allows you to add a 'Stack' button."] = "Позволяет изменять кнопки сумок на текстурные полосы, а так же добавляет кнопку 'Собрать'.";
	L["Allows you to change template of the Raid Control button or hide it altogether."] = "Позволяет изменять вид кнопки управления рейдом или полностью скрыть её.";
	L["Allows you to change the text and duration font for the castbar."] = "Позволяет изменять шрифт текста и длительности для полосы заклинания";
	L["Allows you to choose the color of the actionbar button when it is pushed down."] = "Позволяет изменять цвет кнопок панелей команд во время нажатия.";
	L["Allows you to choose which text format the Bags datatext uses."] = "Позволяет выбрать формат текста сумок.";
	L["Allows you to make actionbars clickthrough."] = "Позволяет совершать нажатия мыши сквозь панели команд.";
	L["Allows you to position and change color and alpha of castbar text."] = "Позволяет перемещать и изменять цвет и прозрачность текста полос заклинаний.";
	L["Allows you to set a spacing between individual aura icons for the units you choose."] = "Позволяет устанавливать отступ между аурами на выбранных рамках юнитов.";
	L["Allows you to use a separate texture for unitframe power bars."] = "Позволяет использовать отдельную текстуру ресурса для рамок юнитов";
	L["Assist"] = "Помощник";
	L["Attempts to remove borders on all ElvUI elements. This doesn't work on all statusbars, so some borders will be kept intact."] = "Удаляет границы на всех элементах ElvUI. Это работает не на всех статусбарах, поэтому некоторые границы останутся.";
	L["Aura Spacing"] = "Отступ аур";
	L["Bags Text Format"] = "Формат текста сумок";
	L["Bags Tweaks"] = "Твики сумок";
	L["Boss"] = "Боссы";
	L["Button Color"] = "Цвет кнопок";
	L["Button Style"] = "Стиль кнопок";
	L["Chat Tweaks"] = "Твики чата";
	L["Credit"] = "Благодарность";
	L["Datatexts Tweaks"] = "Твики инфо-текстов";
	L["Focus"] = "Фокус";
	L["FocusTarget"] = "Цель фокуса";
	L["Free/Total"] = "Свободно/Всего";
	L["Hide Raid Control"] = "Скрыть управление рейдом";
	L["Hide Text On Units"] = "Скрыть текст на юнитах";
	L["Hold Shift:"] = "Зажмите Shift";
	L["Icons"] = "Иконки";
	L["Increases the amount of messages saved in a chat window, before they get replaced by new messages."] = "Увеличивает количество сообщений, сохраненных в окне чата, прежде чем они будут заменены новыми сообщениями.";
	L["Increases the maximum allowed vertical and horizontal spacing for party and raid frames."] = "Увеличивает максимально допустимое значение отступа по горизонтали и вертикали для рамок группы и рейда.";
	L["Information / Help"] = "Информация / Помощь";
	L["Invalid name, check spelling."] = "Неверное имя, проверьте орфографию";
	L["Lowers the minimum allowed minimap size."] = "Снижает минимально допустимый размер миникарты.";
	L["Makes the Consolidated Buffs frame movable and provides some configuration options."] = true;
	L["Max Lines"] = "Максимальное колличество строк";
	L["Minimap Tweaks"] = "Твики мини-карты";
	L["Misc Tweaks"] = "Разные твики";
	L["NamePlate Tweaks"] = "Твики индикаторов здоровья";
	L["Only Free Slots"] = "Только свободные слоты";
	L["Only Used Slots"] = "Только занятые слоты";
	L["Options"] = "Настройки";
	L["Party"] = "Группа";
	L["Pet"] = "Петомец";
	L["PetTarget"] = "Цель петомца";
	L["Player"] = "Игрок";
	L["Please use the following links if you need help or wish to know more about this AddOn."] = "Пожалуйста, используйте следующие ссылки, если вам необходима помощь, или вы хотите узнать больше об этом аддоне.";
	L["Position of the stack count on the aura icon."] = "Позиция текста стаков на иконках аур.";
	L["PowerBar Texture"] = "Текстура ресурса";
	L["Raid"] = "Рейд";
	L["Raid40"] = "Рейд 40";
	L["RaidPet"] = "Петомцы рейда";
	L["Report Bugs / Request Tweaks"] = "Отчеты об ошибках / Запрос твиков";
	L["Set Aura Spacing On Following Units"] = "Установить отступ аур для следующих юнитов:";
	L["Sets space between individual aura icons."] = "Устанавливает отступ между отдельными иконками аур.";
	L["Some tweaks may provide customizable options when enabled. If so then they will appear in the '%s' field below."] = "У некоторых твиков, при включении, могут быть дополнительные опции, найти которые можно в поле '%s'.";
	L["Stack Items In Bags"] = "Собрать вещи в сумках";
	L["Stack Items In Bank"] = "Собрать вещи в банке";
	L["Stack Items To Bags"] = "Собрать вещи в сумки";
	L["Stack Items To Bank"] = "Собрать вещи в банк";
	L["Tank"] = "Танки";
	L["Target"] = "Цель";
	L["TargetTarget"] = "Цель цели";
	L["TargetTargetTarget"] = "Цель цели цели";
	L["The max amount of messages kept in chat before they get replaced by new messages. Changing this setting will clear the chat in all windows."] = "Максимальное количество сообщений сохраняемых в чате, прежде чем они заменятся новыми сообщениями. Изменение этого параметра очистит чат во всех окнах.";
	L["Tweaks"] = "Твики";
	L["Unitframe Tweaks"] = "Твики рамок юнитов";
	L["Use Transparent Template"] = "Сделать фон прозрачным";
	L["Used/Total"] = "Занято/Всего";
end

--Chinese (China, simplified) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "zhCN")
if L then
	--Add translations here
end

--Chinese (Taiwan, traditional) Localizations
local L = LibStub("AceLocale-3.0-ElvUI"):NewLocale("ElvUI", "zhTW")
if L then
	--Add translations here
end
