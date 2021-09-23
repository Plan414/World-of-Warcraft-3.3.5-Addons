local L = LibStub("AceLocale-3.0"):NewLocale("Critline", "ruRU")
if not L then return end

L["%s added to %s."] = "%s добавлен в %s."
L["%s is already in %s."] = "%s уже в %s."
L["%s removed from %s."] = "%s удалено из %s."
L["Add target"] = "Добавить цель"
L["Amount color"] = "Цвет урона"
L["Announce"] = "Сообщение"
L["Are you sure you want to reset all %s records?"] = "Вы уверены что хотите сбросить все %s записи?"
--[[Translation missing --]]
--[[ L["Are you sure you want to revert all recent %s records?"] = ""--]] 
L["aura filter"] = "Фильтр Аур"
--[[Translation missing --]]
--[[ L["Auras"] = ""--]] 
--[[Translation missing --]]
--[[ L["Backdrop opacity"] = ""--]] 
--[[Translation missing --]]
--[[ L["Border opacity"] = ""--]] 
L["Cannot add players to mob filter."] = "Невозможно добавить игрока в фильтр монстров"
L["Chat output"] = "Вывод в чат"
L["Check to enable damage events to be recorded."] = "Включите, чтобы записывать урон."
L["Check to enable healing events to be recorded."] = "Включите, чтобы записывать лечение."
L["Check to enable pet damage events to be recorded."] = "Включите, чтобы записывать урон питомца"
--[[Translation missing --]]
--[[ L["Conflicting mapping."] = ""--]] 
L["Crit"] = "Крит"
L["Crit record"] = "записям критов"
L["critical "] = "кртитический(ое)"
L["Critical!"] = "Критический!"
L["Critline splash frame unlocked"] = "Всплывающее окно Critline разблокировано"
L["Damage"] = "Урон"
L["damage"] = "урон"
L["Detailed tooltip"] = "Подсказка с деталями"
L["Disable to ignore records where the target is a player."] = "Отключите, чтобы игнорировать записи, когда цель - игрок"
L["Disable to ignore records where the target is an NPC."] = "Отключите, чтобы игнорировать записи, когда цель - НПЦ"
L["Drag to move"] = "Зажмите, чтобы двигать"
L["Duration"] = "Длительность"
--[[Translation missing --]]
--[[ L["Enable to filter out new spell entries by default."] = ""--]] 
L["Enable to ignore additional damage due to vulnerability."] = "Включить что бы игнорировать дополнительный урон из-за уязвимости."
L["Enable to ignore integrated aura filter."] = "Включить, чтобы игнорировать встроенный фильтр аур"
L["Enable to ignore integrated mob filter."] = "Включить, чтобы игнорировать встроенный фильтр монстров"
L["Enable to ignore spells that are not in your (or your pet's) spell book."] = "Включить что бы игнорировать заклинания которых нет в вашей книге заклинания(а также питомца)."
L["Enable to show icon indicators instead of text."] = "Включить что бы отображать иконку индикаторов вместо текста."
L["Enable to use scrolling combat text for \"New record\" messages instead of the default splash frame."] = "Включить, чтобы использовать прокручивающийся комбат-текст для сообщений \"Новый рекорд\" взамен стандартному всплывающему окну"
L["Enabled"] = "Включено."
L["Enter mob name"] = "Введите имя монстра"
L["Enter spell ID"] = "Введите ИД заклинания:"
--[[Translation missing --]]
--[[ L["Enter spell name or ID"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enter whisper target"] = ""--]] 
--[[Translation missing --]]
--[[ L["Exclude"] = ""--]] 
--[[Translation missing --]]
--[[ L["excluded spells"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fade duration"] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter new spells"] = ""--]] 
L["Font"] = "Шрифт"
L["Font outline"] = "Контур шрифта"
L["Font size"] = "Размер шрифта"
L["Healing"] = "Лечение"
L["healing"] = "лечение"
--[[Translation missing --]]
--[[ L["Here you can review and manage all your registered spells. Click the button on the right hand side of a spell for options."] = ""--]] 
--[[Translation missing --]]
--[[ L["Icon overrides will cause the source spell to use the target texture in the spell list."] = ""--]] 
L["If level difference between you and the target is greater than this setting, records will not be registered."] = "Если разница в уровнях между вами и целью больше чем в настройках, рекорд не будет записан."
L["Ignore aura filter"] = "Игнорировать фильтр аур"
--[[Translation missing --]]
--[[ L["Ignore damage dealt to boss level creatures outside of raid instances."] = ""--]] 
L["Ignore mob filter"] = "Игнорировать фильтр монстров"
--[[Translation missing --]]
--[[ L["Ignore outdoor bosses"] = ""--]] 
L["Ignore vulnerability"] = "Игнорировать уязвимость"
--[[Translation missing --]]
--[[ L["Include"] = ""--]] 
--[[Translation missing --]]
--[[ L["Include (unfiltered) records in spell tooltips."] = ""--]] 
--[[Translation missing --]]
--[[ L["Include old record"] = ""--]] 
--[[Translation missing --]]
--[[ L["included spells"] = ""--]] 
--[[Translation missing --]]
--[[ L["Includes previous record along with \"New record\" messages."] = ""--]] 
L["Invalid channel. Please enter a valid channel name or ID."] = "Неверный канал. Пожалуйста введите верное имя канала или его ИД."
L["Invalid input. Please enter a spell ID."] = "Неверный ввод. Пожалуйста введите ИД заклинания."
L["Invalid spell ID."] = "Неверное ИД заклинания."
L["Left-click to toggle summary frame"] = "Левый клик для вкл/выкл окна статистики"
L["Level filter"] = "Фильтр уровня"
L["Lock minimap button."] = "Заблокировать кнопку миникарты."
L["Lock summary frame."] = "Заблокировать окно статистики."
L["Locked"] = "Заблокировано"
L["Minimap"] = "мини-карты"
L["mob filter"] = "Фильтр монстра"
L["Mobs"] = "монстра"
--[[Translation missing --]]
--[[ L["n/a"] = ""--]] 
--[[Translation missing --]]
--[[ L["Name overrides will cause the source spell to be listed as the target name in tree tooltips, new record messages and the spell list."] = ""--]] 
L["New %s record!"] = "Новый рекорд %s!"
--[[Translation missing --]]
--[[ L["New %s%s record - %s"] = ""--]] 
L["No records"] = "Нет записей."
L["No target selected."] = "Не выбрана цель."
L["None"] = "Нет"
L["Normal"] = "Нормальный"
L["Normal record"] = "записям хитов"
L["Only known spells"] = "Только известные заклинания"
--[[Translation missing --]]
--[[ L["Opacity"] = ""--]] 
L["pet"] = "питомец"
L["Pet"] = "Питомец"
--[[Translation missing --]]
--[[ L["Previous record:"] = ""--]] 
L["Prints new record notifications to the chat frame."] = "Показывать уведомление о новом рекорде в окно чата"
L["Record damage"] = "Запись урона"
L["Record healing"] = "Запись лечения"
L["Record pet damage"] = "Запись урона питомца"
L["Record PvE"] = "Запись PVE"
L["Record PvP"] = "Запись PVP"
--[[Translation missing --]]
--[[ L["Records in spell tooltips"] = ""--]] 
L["Reset"] = "Сбросить"
L["Reset %s (%s) records."] = "Сброшено %s (%s) записей."
L["Reset all"] = "Сбросить все"
L["Reset all %s records."] = "Сбросить все %s записи."
--[[Translation missing --]]
--[[ L["Revert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Revert all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reverted all recent %s records."] = ""--]] 
L["Right-click to lock"] = "Правый клик для разблокировки"
L["Right-click to open options"] = "Правый клик что бы открыть настройки"
L["Saves a screenshot on a new record."] = "Делать скриншот при каждом новом рекорде"
L["Scale"] = "Размер"
L["Screenshot"] = "Скриншот"
L["Sets the color for the amount text in the splash frame."] = "Устанавливает цвет для текста в окне вспышек."
L["Sets the color for the spell text in the splash frame."] = "Устанавливает цвет для текста заклинаний в окне вспышек."
L["Sets the font size of the splash frame."] = "Устанавливает размер текста для окна вспышек."
--[[Translation missing --]]
--[[ L["Sets the opacity of the display backdrop."] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets the opacity of the display border."] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets the opacity of the display."] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets the scale of the display."] = ""--]] 
L["Sets the scale of the splash frame."] = "Установить масштаб всплывающего окна"
L["Sets the time (in seconds) the splash frame is visible before fading out."] = "Устанавливает время вспышек (в секундах) пока окно видно до исчезновения."
--[[Translation missing --]]
--[[ L["Sets the time between the splash frame starting to fade and being fully faded out."] = ""--]] 
--[[Translation missing --]]
--[[ L["Shorten records"] = ""--]] 
L["Show"] = "Показать"
L["Show icons"] = "Показать иконки"
L["Show minimap button."] = "Показать кнопку миникарты"
L["Show summary frame."] = "Показать окно статистики"
L["Shows the new record on the middle of the screen."] = "Показывать новые рекорды в центре экрана"
--[[Translation missing --]]
--[[ L["Sort tooltips by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sound effect"] = ""--]] 
L["Spell color"] = "Цвет заклинания"
--[[Translation missing --]]
--[[ L["Spell icon overrides"] = ""--]] 
--[[Translation missing --]]
--[[ L["Spell mappings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Spell mappings causes the source spell to be registered as if it were the target spell. It will be stored with the ID, name and icon of the target spell. Useful for merging different spell IDs of the same spell into a single record. Spells will immediately be converted into their target ID after a mapping has been created."] = ""--]] 
--[[Translation missing --]]
--[[ L["Spell name"] = ""--]] 
--[[Translation missing --]]
--[[ L["Spell name overrides"] = ""--]] 
--[[Translation missing --]]
--[[ L["Spells cast on targets in this list will not be registered."] = ""--]] 
--[[Translation missing --]]
--[[ L["Spells in this list will be considered known spells for the purposes of the 'Only known spells' option."] = ""--]] 
--[[Translation missing --]]
--[[ L["Spells in this list will not be registered."] = ""--]] 
L["Splash frame"] = "Всплывающее окно"
L["Suppress all records while mind controlled."] = "Не записывать, когда вы под действием \"Контроль над разумом\""
L["Suppress mind control"] = "Скрывать МК"
L["Thick"] = "Тонкий"
--[[Translation missing --]]
--[[ L["This spell ID is already mapped."] = ""--]] 
--[[Translation missing --]]
--[[ L["tick"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tick"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tooltip mappings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tooltip mappings causes the tooltip of the source spell to display the records of the target spell. Useful for when several tooltips refer to the same spell, or you want to display some side effect of a spell. Any tooltip can only display the records of one database entry at a time."] = ""--]] 
L["Use combat text splash"] = "Использовать эффект текста боя"
L["Use detailed format in the summary tooltip."] = "Использовать детализированый формат статистики подсказки"
--[[Translation missing --]]
--[[ L["Use shorter format for record numbers."] = ""--]] 
--[[Translation missing --]]
--[[ L["When an aura in this list is gained, records will be disabled for the remainder of the combat duration."] = ""--]] 

