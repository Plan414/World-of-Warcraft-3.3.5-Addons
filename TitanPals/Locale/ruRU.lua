local L = LibStub("AceLocale-3.0"):NewLocale("TitanPals", "ruRU");
if not L then return end
L["TITAN_PALS_BUTTON_LABEL"] = "Друзья: "
L["TITAN_PALS_BUTTON_TEXT"] = "%s/%s/%s"
L["TITAN_PALS_BUTTON_TEXT_NOREALID"] = "%s/%s"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_F"] = "Рыцарь смерти"
L["TITAN_PALS_CLASSES_DEATHKNIGHT_M"] = "Рыцарь смерти"
L["TITAN_PALS_CLASSES_DRUID_F"] = "Друид"
L["TITAN_PALS_CLASSES_DRUID_M"] = "Друид"
L["TITAN_PALS_CLASSES_HUNTER_F"] = "Охотница"
L["TITAN_PALS_CLASSES_HUNTER_M"] = "Охотник"
L["TITAN_PALS_CLASSES_MAGE_F"] = "Маг"
L["TITAN_PALS_CLASSES_MAGE_M"] = "Маг"
L["TITAN_PALS_CLASSES_PALADIN_F"] = "Паладин"
L["TITAN_PALS_CLASSES_PALADIN_M"] = "Паладин"
L["TITAN_PALS_CLASSES_PRIEST_F"] = "Жрица"
L["TITAN_PALS_CLASSES_PRIEST_M"] = "Жрец"
L["TITAN_PALS_CLASSES_ROGUE_F"] = "Разбойница"
L["TITAN_PALS_CLASSES_ROGUE_M"] = "Разбойник"
L["TITAN_PALS_CLASSES_SHAMAN_F"] = "Шаманка"
L["TITAN_PALS_CLASSES_SHAMAN_M"] = "Шаман"
L["TITAN_PALS_CLASSES_WARLOCK_F"] = "Чернокнижница"
L["TITAN_PALS_CLASSES_WARLOCK_M"] = "Чернокнижник"
L["TITAN_PALS_CLASSES_WARRIOR_F"] = "Воин"
L["TITAN_PALS_CLASSES_WARRIOR_M"] = "Воин"
L["TITAN_PALS_COLORS_BLUE"] = "|cff00ffff"
L["TITAN_PALS_COLORS_CTAG"] = "|r"
L["TITAN_PALS_COLORS_GRAY"] = "|cff808080"
L["TITAN_PALS_COLORS_GREEN"] = "|cff20ff20"
L["TITAN_PALS_COLORS_HLIGHT"] = "|cffffffff"
L["TITAN_PALS_COLORS_NORMAL"] = "|cffffd200"
L["TITAN_PALS_COLORS_ORANGE"] = "|cffff9900"
L["TITAN_PALS_COLORS_RED"] = "|cffff2020"
L["TITAN_PALS_CONFIG"] = "Titan [|cffeda55fPals|r]"
L["TITAN_PALS_CONFIG_ABOUT"] = "Об аддоне"
L["TITAN_PALS_CONFIG_BANNOR"] = "Показывать информацию при загрузке аддона"
L["TITAN_PALS_CONFIG_BANNOR_DESC"] = "Это покажет текстовую информацию при загрузке аддона (и используемой им памяти) в чат."
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP"] = "Add a |cff00ffffRealID|r Tooltip Format :" -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_DESC"] = "Here you can add custom formats for the tooltip display" -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_INST"] = [=[
|cff20ff20You can use :|r
     |cff20ff20!cn|r for Character Name
     |cff20ff20!fn|r for Full Name
     |cff20ff20!sn|r for Sir Name
     |cff20ff20!ln|r for Last Name
     |cff20ff20!rn|r for Realm Name
     |cff20ff20!gn|r for Game Client|r]=] -- Requires localization
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP"] = "Добавить формат подсказки :"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_DESC"] = "Здесь вы можете задать свой формат отображения подсказки"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_INST"] = [=[
|cff20ff20Вы можете использовать :|r
     |cff20ff20!s|r для Статуса
     |cff20ff20!l|r для Уровня
     |cff20ff20!p|r для Игрока
     |cff20ff20!z|r для Зоны
     |cff20ff20!n|r для Заметки
     |cff20ff20!c|r для Класса
     |cff20ff20!uc|r для Цветных Имён Игроков

|cffff9900Правая сторона должна быть отделена от левой через ~(тильду).|r]=]
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID"] = "|cff00ffffRealID|r Формат подсказки :"
L["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID_DESC"] = "Несколько |cff00ffffRealID|r предустановок для изменения имён |cff00ffffRealID|r друзей"
L["TITAN_PALS_CONFIG_HEADER_ADD"] = "Новые форматы"
L["TITAN_PALS_CONFIG_HEADER_REALID"] = "|cff00ffffRealID Формат|r"
L["TITAN_PALS_CONFIG_HEADER_REALID_ADD"] = "New |cff00ffffRealID|r Formats" -- Requires localization
L["TITAN_PALS_CONFIG_HEADER_REALID_REMOVE"] = "Remove |cff00ffffRealID|r Formats" -- Requires localization
L["TITAN_PALS_CONFIG_HEADER_REMOVE"] = "Удалить формат подсказки"
L["TITAN_PALS_CONFIG_LABEL"] = "Аддон для ТитанПанели, Этот аддон отображает ваших друзей, отсортированных по способу подключения на ТитанПанели"
L["TITAN_PALS_CONFIG_NOALTS"] = "Подсказки без альтов"
L["TITAN_PALS_CONFIG_NOALTS_DESC"] = "Это предотвратит отображение альтов на подсказке."
L["TITAN_PALS_CONFIG_PRESETS"] = "Предустановки подсказок :"
L["TITAN_PALS_CONFIG_PRESETS_DESC"] = "Несколько различных форматов отображения подсказок"
L["TITAN_PALS_CONFIG_PRESETS_PREVIEW"] = "Для просмотра наведите мышкой на [|cffeda55fPals|r] кнопку."
L["TITAN_PALS_CONFIG_REALID_NOTE1_OFF"] = "|cffff2020Отключить|r Это отключит отображение |cff00ffffRealID Друзей|r на всплывающей подсказке."
L["TITAN_PALS_CONFIG_REALID_NOTE1_ON"] = "|cff20ff20Включить|r Это включит отображение |cff00ffffRealID Друзей|r на всплывающей подсказке."
L["TITAN_PALS_CONFIG_REALID_ONOFF"] = "Показать |cff00ffffRealID|r в подсказке"
L["TITAN_PALS_CONFIG_REALID_ONOFF_DESC"] = "Эта опция покажет друзей |cff00ffffRealID|r в подсказке."
L["TITAN_PALS_CONFIG_REALID_PRESETS"] = "|cff00ffffRealID|r Tooltip Presets :" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_PRESETS_DESC"] = "A few diffrent preset format for the |cff00ffffRealID|r part of the tooltip" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE"] = "Remove |cff00ffffRealID|r" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE_DESC"] = "This will remove the selected |cff00ffffRealID|r format from the presets tooltip table" -- Requires localization
L["TITAN_PALS_CONFIG_REALID_REMOVE_PRESETS_DESC"] = "Please select a |cff00ffffRealID|r format to remove!" -- Requires localization
L["TITAN_PALS_CONFIG_REMOVE"] = "Удалить"
L["TITAN_PALS_CONFIG_REMOVE_DESC"] = "Это опция предназначена для удаления формата из списков форматов"
L["TITAN_PALS_CONFIG_REMOVE_PRESETS_DESC"] = "Выберите формат для удаления!"
L["TITAN_PALS_CONFIG_SET_HEADER"] = "Формат подсказки"
L["TITAN_PALS_CONFIG_SET_HEADER_2"] = "Настройки"
L["TITAN_PALS_CONFIG_SET_HEADER_STATUS"] = "Status Types" -- Requires localization
L["TITAN_PALS_CONFIG_SHOWIGNORED"] = "Показывать игнорируемых"
L["TITAN_PALS_CONFIG_SHOWIGNORED_DESC"] = "Это будет отображать всех кого вы игнорировали в подсказке."
L["TITAN_PALS_CONFIG_SHOWMEM"] = "Показывать использование памяти"
L["TITAN_PALS_CONFIG_SHOWMEM_DESC"] = "Это покажет сколько памяти использует аддон."
L["TITAN_PALS_CONFIG_SHOWOFFLINE"] = "Показывать друзей оффлайн"
L["TITAN_PALS_CONFIG_SHOWOFFLINE_DESC"] = "Это позволит отобразить некоторую детализированную информацию в подсказке."
L["TITAN_PALS_CONFIG_STATUS_TYPES"] = "Status Display Style" -- Requires localization
L["TITAN_PALS_CONFIG_STATUS_TYPES_DESC"] = "The style that you would like Pals that are away to show up as." -- Requires localization
L["TITAN_PALS_CONFIG_STATUS_TYPES_INST"] = [=[

|cff20ff20This allow you to change the default text of <Away> in the tooltip, you choices are :|r
     |cffff8c00<Away>|r
     |cffff8c00<AFK>|r
     |cffff8c00<A>|r
     |cffff8c00(Away)|r
     |cffff8c00(AFK)|r
     |cffff8c00(A)|r
     |cffff8c00[Away]|r
     |cffff8c00[AFK]|r
     |cffff8c00[A]|r]=] -- Requires localization
L["TITAN_PALS_DEBUG_DEBUG1"] = "Отладка настроек"
L["TITAN_PALS_DEBUG_DEV"] = "Режим отладки"
L["TITAN_PALS_DEBUG_DEVEVENT"] = "Режим отладки событий"
L["TITAN_PALS_DEBUG_DEVLOGEVENT"] = "Режим отладки лога"
L["TITAN_PALS_DEBUG_MDEBUG"] = "Отладка меню"
L["TITAN_PALS_DEBUG_PLAY"] = "Отобразить массив данных в чат"
L["TITAN_PALS_DEBUG_PLAYALTS"] = "Отобразить список альтов в чате"
L["TITAN_PALS_DEBUG_PLAYFRIENDS"] = "Отобразить список друзей в чате"
L["TITAN_PALS_MENU_CUSTOM_NOTE"] = "Персональная заметка"
L["TITAN_PALS_MENU_INVITE"] = "Пригласить"
L["TITAN_PALS_MENU_NORMAL"] = "Друзья"
L["TITAN_PALS_MENU_NOTE"] = "Заметка"
L["TITAN_PALS_MENU_REALID"] = "|cff00ffffRealID Друзья|r"
L["TITAN_PALS_MENU_REMOVE"] = "Удалить"
L["TITAN_PALS_MENU_REMOVEDATA"] = "Утилиты базы данных"
L["TITAN_PALS_MENU_REMOVE_ALT"] = "Удалить альта"
L["TITAN_PALS_MENU_REMOVE_ALTDATA"] = "Удалить альта из базы данных"
L["TITAN_PALS_MENU_REMOVE_FRIEND"] = "Удалить друга"
L["TITAN_PALS_MENU_REMOVE_FRIENDDATA"] = "Удалить друга из базы данных"
L["TITAN_PALS_MENU_SETTINGS"] = "Настройки"
L["TITAN_PALS_MENU_SUB_REMOVE"] = "Удалить "
L["TITAN_PALS_MENU_SYNC"] = "Синхронизация"
L["TITAN_PALS_MENU_SYNCALTS"] = "Синхронизовать альтов в список друзей"
L["TITAN_PALS_MENU_SYNCALTSFRIENDS"] = "Синхронизовать альтов друзей в список друзей"
L["TITAN_PALS_MENU_TEXT"] = "Titan Pals"
L["TITAN_PALS_MENU_WHISPER"] = "Шепнуть"
L["TITAN_PALS_NOTES_DEATH KNIGHT_1"] = "Кровь"
L["TITAN_PALS_NOTES_DEATH KNIGHT_2"] = "Лед"
L["TITAN_PALS_NOTES_DEATH KNIGHT_3"] = "Нечестивость"
L["TITAN_PALS_NOTES_DRUID_1"] = "Баланс"
L["TITAN_PALS_NOTES_DRUID_2"] = "Сила зверя"
L["TITAN_PALS_NOTES_DRUID_3"] = "Исцеление"
L["TITAN_PALS_NOTES_HUNTER_1"] = "Стрельба"
L["TITAN_PALS_NOTES_HUNTER_2"] = "Повелитель зверей"
L["TITAN_PALS_NOTES_HUNTER_3"] = "Выживание"
L["TITAN_PALS_NOTES_MAGE_1"] = "Огонь"
L["TITAN_PALS_NOTES_MAGE_2"] = "Лед"
L["TITAN_PALS_NOTES_MAGE_3"] = "Тайная магия"
L["TITAN_PALS_NOTES_PALADIN_1"] = "Защита"
L["TITAN_PALS_NOTES_PALADIN_2"] = "Свет"
L["TITAN_PALS_NOTES_PALADIN_3"] = "Воздаяние"
L["TITAN_PALS_NOTES_PRIEST_1"] = "Тьма"
L["TITAN_PALS_NOTES_PRIEST_2"] = "Свет"
L["TITAN_PALS_NOTES_PRIEST_3"] = "Послушание"
L["TITAN_PALS_NOTES_ROGUE_1"] = "Ликвидация"
L["TITAN_PALS_NOTES_ROGUE_2"] = "Бой"
L["TITAN_PALS_NOTES_ROGUE_3"] = "Скрытность"
L["TITAN_PALS_NOTES_SHAMAN_1"] = "Стихии"
L["TITAN_PALS_NOTES_SHAMAN_2"] = "Совершенствование"
L["TITAN_PALS_NOTES_SHAMAN_3"] = "Исцеление"
L["TITAN_PALS_NOTES_WARLOCK_1"] = "Колдовство"
L["TITAN_PALS_NOTES_WARLOCK_2"] = "Демонология"
L["TITAN_PALS_NOTES_WARLOCK_3"] = "Разрушение"
L["TITAN_PALS_NOTES_WARRIOR_1"] = "Защита"
L["TITAN_PALS_NOTES_WARRIOR_2"] = "Оружие"
L["TITAN_PALS_NOTES_WARRIOR_3"] = "Неистовство"
L["TITAN_PALS_REALM_ERROR"] = "Извините, %s не на вашем сервере, вы можете приглашать только людей с вашего сервера "
L["TITAN_PALS_REAL_TOOLTIP"] = "|cff00ffffRealID|r друзья"
L["TITAN_PALS_TOOLTIP"] = "Друзья онлайн"
L["TITAN_PALS_TOOLTIP_EMPTY"] = "Ваш список друзей пуст!"
L["TITAN_PALS_TOOLTIP_IGNORE"] = "Игнорируемые игроки"
L["TITAN_PALS_TOOLTIP_IGNORED"] = "Игнорируемые"
L["TITAN_PALS_TOOLTIP_IGNORE_EMPTY"] = "Ваш список игнорируемых пуст!"
L["TITAN_PALS_TOOLTIP_MEM"] = "Использование памяти"
L["TITAN_PALS_TOOLTIP_NOPALS"] = "  Нет друзей онлайн"
L["TITAN_PALS_TOOLTIP_NOREALID_FRIENDS"] = "У вас нет |cff00ffffДрузей RealID|r!!!"
L["TITAN_PALS_TOOLTIP_NOREALPALS"] = "  Нет друзей RealID онлайн"
L["TITAN_PALS_TOOLTIP_NO_OFF"] = "  No Offline Pals" -- Requires localization
L["TITAN_PALS_TOOLTIP_OFF"] = "Друзья оффлайн"
L["TITAN_PALS_TOOLTIP_OFFLINE"] = "Оффлайн"
L["TITAN_PALS_TOOLTIP_OFFLINE_IGNORED"] = "Игнорируется"
L["TITAN_PALS_TOOLTIP_ONLINE"] = "Онлайн"