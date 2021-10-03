if ( GetLocale() ~= "ruRU" ) then return end

local addon, ns = ...
ns.L = {
	-- Core Globals
	["Combat Fade"] = "Скрыть в бою",
	["Class Colored"] = "Окраска классов",
	["Global Font Size"] = "Глобальный размер шрифта",
	["ProfDesc"] = "Создание нового или копию существующих профилей. По умолчанию профили набор к персонаж.",
	["ProfResDesc"] = "Reset Profile",
	["ProfNew"] = "новый",
	["ProfReset"] = "Reset",
	["ProfCurrent"] = "текущий",
	["ProfCopy"] = "копия",
	["ProfDel"] = "Delete",
	["/sldt"] = "/sldt",
	["Command List"] = "Список команд",
	["config"] = "конфиг",
	["Toggle Configuration Mode"] = "Переключить режим конфигурации",
	["Configuration Mode"] = "Режим конфигурации",
	["active"] = "активный",
	["inactive"] = "неактивный",
	["global"] = "глобальный",
	["Open SLDataText global menu"] = "Открытое SLDataText глобальное меню",
	["<module>"] = "<модуль>",
	["Open Module Option Menu"] = "Открыть меню Дополнительный модуль",
	["Loaded Modules"] = "Загруженные модули",
	["TTScale"] = "SLToolTip Scale",
	
	-- Common
	["Enabled"] = "Включен",
	["Global Font"] = "Основной шрифт",
	["Outline"] = "Контур основного шрифта",
	["Force Shown"] = "Показать в бою",
	["Tooltip On"] = "Шоу подсказку",
	["Font Size"] = "Размер шрифта",
	["Font"] = "Шрифт",
	["Justify"] = "Выравнивание текста",
	["Parent"] = "Родительский",
	["Anchor"] = "Привязать к",
	["X Offset"] = "Смещение по X",
	["Y Offset"] = "Смещение по Y",
	["Frame Strata"] = "кадр Слои",
	["Update Interval"] = "Интервал обновления",
	["On"] = "на",
	["Off"] = "от",
	["Prefix"] = "префикс",
	["Prefix Text"] = "Префикс текст",
	["Suffix"] = "суффикс",
	["Suffix Text"] = "суффикс текст",
	["Left-Click"] = "Левый клик",
	["Right-Click"] = "право клик",
	["Show Icon"] = "Показать значок",
	["Show Text"] = "Показать текст",
	["Text Display"] = "текст дисплей",
	
	-- Armor Module
	["Armor"] = "Доспехи",
	["All Items"] = "все пункт",
	["Auto Repair"] = "Авто-починка",
	["Use Guild Bank"] = "Исп. средства гильдии",
	["AutoRepairLine"] = "Cтоимость ремонта",
	["GFAutoRepairLine"] = "Cтоимость ремонта (Guild Funds)",
	["ArmorTextDesc"] = "Tags for Text Display: [Dur] = Current Durability",
	
	-- Bag Module
	["Bag Info"] = "Сумки информация",
	["Space Used"] = "Пространство Зането",
	["Space Avail"] = "Пространство доступный",
	["Space Left"] = "Пространство бесплатно",
	["AutoSell Junk"] = "Авто продать барахло",
	["JunkSoldLine"] = "Нежелательная продал заработал",
	["Toggle Bags"] = "Переключить Сумки",
	["BagTextDesc"] = "Tags for текст дисплей: [T] = Total, [R] = Remaining, [U] = Used",
	
	-- Clock Module
	["Toggle Calendar"] = "переключатель календарь",
	["Toggle Time Manager"] = "переключатель время менеджер",
	["Queued for:"] = "В очереди на:",
	["Realm Time"] = "Показать серверное время",
	["24 Hour"] = "24ч",
	["PvP Info"] = "PvP информации",
	["Time String"] = "Time String",
	["ClockDesc"] = "Visit http://www.lua.org/pil/22.1.html for a full list of clock tags. Turn 'Correct Hour' option off if hour tag is not first in the time string.",
	["CorrHour"] = "Correct Hour",
	
	-- Coords Module
	["Precision"] = "Точность",
	
	-- Currency Module
	["Currency"] = "Bалюта",
	["No Currency"] = "Нет Bалюта",
	["Click to set display currency."] = "Нажмите, чтобы установить дисплей валюты.",
	["Display Currency"] = "дисплей Bалюта",
	
	-- Exp Module
	["Max Level Hide"] = "Скрыть уровне макс",
	["Exp"] = "Exp",
	["ExpTextDesc"] = "Tags for Text Display: [Cur] = Current XP, [Max] = Max XP, [Rem] = Remaining XP, [Per] = XP Percent, [PerR] = XP Remaining Percent, [R] = Rest XP, [RP] = Rest XP Percent",
	
	-- FPS Module
	["fps"] = "fps",
	["FPSTextDesc"] = "Tags for Text Display: [F] = Current FPS",
	
	-- Gold Module
	["Wallet"] = "бумажник",
	["Current"] = "текущий",
	["Session Start"] = "сессия начало",
	["Session Earned"] = "сессия заработанный",
	["Server Gold"] = "cервер золото",
	["Horde"] = "Орда",
	["Alliance"] = "Альянс",
	["Total Gold"] = "Всего золота",
	["Display Style"] = "стиль отображения",
	["Alt Money"] = "Alt Деньги",
	["ResetData"] = "Reset Data",
	
	-- Latency Module
	["Latency"] = "Задержка",
	["Bandwidth In"] = "трафик в",
	["Bandwidth Out"] = "трафик из",
	["Latency (Home)"] = "Задержка (домой)",
	["Latency (World)"] = "Задержка (мир)",
	["ms"] = "мс",
	["LagTextDesc"] = "Tags for Text Display: [L] = Current Latency",
	
	-- Mail Module
	["No Mail"] = "Нет Почта",
	["Mail!"] = "Почта!",
	["AH Alert!"] = "AH оповещения!",
	["Play Sounds"] = "Звук Бдительные",
	
	-- Memory Module
	["AddOn Memory"] = "Аддон Память",
	["Showing Top 15 AddOns"] = "отображения хигхест 15 Аддон",
	["Total AddOn Memory"] = "Всего Аддон Память",
	["Total UI Memory Usage"] = "Всего UI Память пользование",
	["Hover"] = "зависать",
	["Show only top AddOns"] = "Показать только верхний Аддон",
	["Alt+Hover"] = "Alt+зависать",
	["Show all AddOns"] = "Показать все Аддон",
	["Collect Garbage"] = "Сбор мусора",
	["mb"] = "mb",
	["MemTextDesc"] = "Tags for Text Display: [MA] = Addon Memory, [MT] = Total Memory",
	
	-- Reputation Module
	["Reputation"] = "Reputation",
	["No Reputation"] = "No Reputation",
	["Click to set display reputation."] = "Click to set display reputation.",
	["Display Reputation"] = "Display Reputation",
	["Hated"] = "Hated",
	["Hostile"] = "Hostile",
	["Unfriendly"] = "Unfriendly",
	["Neutral"] = "Neutral",
	["Friendly"] = "Friendly",
	["Honored"] = "Honored",
	["Revered"] = "Revered",
	["Exalted"] = "Exalted",
}