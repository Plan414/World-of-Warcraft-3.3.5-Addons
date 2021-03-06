if not(GetLocale() == "ruRU") then
    return;
end

local L = WeakAuras.L

-- Options translation
L["1 Match"] = "1 Совпадение"
L["Actions"] = "Действия"
L["Activate when the given aura(s) |cFFFF0000can't|r be found"] = "Активировать когда заданная аура(ы) |cFFFF0000не|r найдена"
L["Add a new display"] = "Добавить новую индикацию"
L["Add Dynamic Text"] = "Добавить Динамический Текст"
L["Addon"] = "Аддон"
L["Addons"] = "Аддоны"
L["Add to group %s"] = "Добавить в группу %s"
L["Add to new Dynamic Group"] = "Добавить в новую динамическую группу"
L["Add to new Group"] = "Добавить в новую группу"
L["Add Trigger"] = "Добавить Триггер"
L["A group that dynamically controls the positioning of its children"] = "Группа, позволяющая динамично изменять позиции своих элементов"
L["Align"] = "Выровнять"
L["Allow Full Rotation"] = "Разрешить полное вращение"
L["Alpha"] = "Прозрачность"
L["Anchor"] = "Крепление"
L["Anchor Point"] = "Точка Крепления"
L["Angle"] = "Угол"
L["Animate"] = "Анимация"
L["Animated Expand and Collapse"] = "Анимированное Сворачивание и Разворачивание"
L["Animation relative duration description"] = [=[Длительность анимации по отношению к индикации, выраженная в виде дроби (1/2), процентах (50%), или десятично (0.5).
|cFFFF0000Примечание:|r Если индикация не имеет таймера (например аура без длительности и т.д.), то анимация не проигрывается.
|cFF4444FFДля Примера:|r
Если длительность анимации установлена в |cFF00CC0010%|r и триггер индикации это бафф длительностью 20 секунд, стартовая анимация проиграется за 2 секунды.
Если длительность анимации установлена в |cFF00CC0010%|r и триггер индикации это бесконечная аура, стартовая анимация не будет проигрываться (но проигралась бы, если установить длительность в секундах) .]=]
L["Animations"] = "Анимация"
L["Animation Sequence"] = "Цепочка Анимации"
L["Aquatic"] = "Водная форма"
L["Aura (Paladin)"] = "Аура (паладин)"
L["Aura(s)"] = "Эффекты"
L["Auto"] = "Авто"
L["Auto-cloning enabled"] = "Авто-клонирование включено"
L["Automatic Icon"] = "Автоматическая Иконка"
-- L["Backdrop Color"] = ""
-- L["Backdrop Style"] = ""
L["Background"] = "Подложка"
L["Background Color"] = "Цвет Подложки"
L["Background Inset"] = "Вложенная подложка"
L["Background Offset"] = "Смещение Подложки"
L["Background Texture"] = "Текстура Подложки"
L["Bar Alpha"] = "Прозрачность Полосы"
L["Bar Color"] = "Цвет Полосы"
-- L["Bar Color Settings"] = ""
-- L["Bar in Front"] = ""
L["Bar Texture"] = "Текстура Полосы"
L["Battle"] = "Сражение"
L["Bear"] = "Медведь"
L["Berserker"] = "Берсерк"
L["Blend Mode"] = "Режим Наложения"
L["Blood"] = "Кровь"
L["Border"] = "Граница"
L["Border Color"] = "Цвет Границы"
-- L["Border Inset"] = ""
L["Border Offset"] = "Смещение Границы"
L["Border Settings"] = "Настройки Границы"
L["Border Size"] = "Размер Границы"
L["Border Style"] = "Стиль Границы"
L["Bottom Text"] = "Нижний текст"
L["Button Glow"] = "Подсветка кнопки"
L["Can be a name or a UID (e.g., party1). Only works on friendly players in your group."] = "Может быть именем или UID (н.п. party1). Работает только с дружественными целями в вашей группе."
L["Cancel"] = "Отмена"
L["Cat"] = "Кошка"
L["Change the name of this display"] = "Изменить имя индикации"
L["Channel Number"] = "Номер Канала"
L["Check On..."] = "Проверять..."
L["Choose"] = "Выбрать"
L["Choose Trigger"] = "Выбор Триггера"
L["Choose whether the displayed icon is automatic or defined manually"] = "Выберите, будет ли значок определен автоматически или вручную"
L["Clone option enabled dialog"] = [=[Вы активировали опцию |cFFFF0000Авто-клонирования|r.

|cFFFF0000Авто-клонирование|r заставляет индикацию автоматически дубироватся для отображения нескольких источников информации.
Если вы поместите эту индикацию в |cFF22AA22Динамическую Группу|r, все клоны будут смещаться вверх этой большой кучи.

Вы хотите поместить эту индикацию в новую |cFF22AA22Динамическую Группу|r?]=]
L["Close"] = "Закрыть"
L["Collapse"] = "Свернуть"
L["Collapse all loaded displays"] = "Свернуть все активные индикации"
L["Collapse all non-loaded displays"] = "Свернуть все неактивные индикации"
L["Color"] = "Цвет"
L["Compress"] = "Сжать"
L["Concentration"] = "Концентрация"
L["Constant Factor"] = "Постоянный множитель"
L["Control-click to select multiple displays"] = "Ctrl+клик для выбора нескольких индикаций"
L["Controls the positioning and configuration of multiple displays at the same time"] = "Управление позиционированием и настройка нескольких индикаций одновременно"
L["Convert to..."] = "Преобразовать в..."
L["Cooldown"] = "Кулдаун"
L["Copy"] = "Копировать"
L["Copy settings from..."] = "Копировать настройки из..."
L["Copy settings from another display"] = "Копировать настройки из другой индикации"
L["Copy settings from %s"] = "Копировать настройки из %s"
L["Count"] = "Кол-во"
L["Creating buttons: "] = "Создание кнопок:"
L["Creating options: "] = "Создание настроек:"
L["Crop X"] = "Обрезать по X"
L["Crop Y"] = "Обрезать по Y"
L["Crusader"] = "Рыцарь"
L["Custom Code"] = "Свой Код"
L["Custom Trigger"] = "Свой Триггер"
L["Custom trigger event tooltip"] = [=[Напишите какие события должны проверятся для активации триггера.
Несколько событий должны разделятся запятыми или пробелами.

|cFF4444FFДля Примера:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
L["Custom trigger status tooltip"] = [=[Напишите какие события должны проверятся для активации триггера.
Поскольку это триггер состояния, указанные события могут быть вызваны WeakAuras без ожидаемых аргументов.
Несколько событий должны разделятся запятыми или пробелами.

|cFF4444FFДля Примера:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
L["Custom Untrigger"] = "Свой Детриггер"
L["Custom untrigger event tooltip"] = [=[Напишите какие события должны проверятся для деакивации триггера.
Эти события могут быть отличны от описанных для срабатывания триггера.
Несколько событий должны разделятся запятыми или пробелами.

|cFF4444FFДля Примера:|r
UNIT_POWER, UNIT_AURA PLAYER_TARGET_CHANGED
]=]
L["Death"] = "Смерть"
L["Death Rune"] = "Руна Смерти"
L["Debuff Type"] = "Тип Дебафа"
L["Defensive"] = "Защита"
L["Delete"] = "Удалить"
L["Delete all"] = "Удалить всё"
L["Delete children and group"] = "Удалить группу и ее элементы"
L["Deletes this display - |cFF8080FFShift|r must be held down while clicking"] = "Удаляя эту индикацию - зажмите |cFF8080FFShift|r и кликните мышью."
L["Delete Trigger"] = "Удалить Триггер"
-- L["Desaturate"] = ""
L["Devotion"] = "Благочестие"
L["Disabled"] = "Выключено"
L["Discrete Rotation"] = "Вращать Дискретно"
L["Display"] = "Индикация"
L["Display Icon"] = "Отображать Значек"
L["Display Text"] = "Отобразить Текст"
L["Distribute Horizontally"] = "Распределить по Горизонтали"
L["Distribute Vertically"] = "Распределить по Вертикали"
L["Do not copy any settings"] = "Не копировать какие-либо настройки"
L["Do not group this display"] = "Не группировать эту индикацию"
L["Duplicate"] = "Дублировать"
L["Duration Info"] = "Информация о продолжительности"
L["Duration (s)"] = "Длительность"
L["Dynamic Group"] = "Динамическая Группа"
L["Dynamic text tooltip"] = [=[Несколько специальных кодов для отображения динамического текста:

|cFFFF0000%p|r - Прогресс - Оставшееся время таймера или без таймерная величина
|cFFFF0000%t|r - Всего - Максимальная длительность таймера или максимальная без таймерная величина
|cFFFF0000%n|r - Название - Название индикации (обычно название задействованной ауры) или ID индикатора
|cFFFF0000%i|r - Иконка - Иконка связанная с индикацией
|cFFFF0000%s|r - Стаки - Кол-во стаков (обычно для ауры)
|cFFFF0000%c|r - В ручную - Позволяет написать функцию на Lua, возвращаемое значение которой и будет отображено ]=]
L["Enabled"] = "Включено"
L["Enter an aura name, partial aura name, or spell id"] = "Введите полное название эффекта, часть его названия или ID заклинания."
L["Event Type"] = "Тип События"
L["Expand"] = "Развернуть"
L["Expand all loaded displays"] = "Развернуть все загруженные индикации"
L["Expand all non-loaded displays"] = "Развернуть все не загруженные индикации"
L["Expand Text Editor"] = "Расширенный редактор текста"
L["Expansion is disabled because this group has no children"] = "Развертывание не возможно, потому что группа не имеет элементов"
L["Export"] = "Экспортировать"
L["Export to Lua table..."] = "Экспортировать в таблицу Lua"
L["Export to string..."] = "Экспортировать в строку..."
L["Fade"] = "Скрыть"
L["Finish"] = "Завершение"
L["Fire Resistance"] = "Сопротивление Огню"
L["Flight(Non-Feral)"] = "Полет(не ферал)"
L["Font"] = "Шрифт"
-- L["Font Flags"] = ""
L["Font Size"] = "Размер Шрифта"
L["Font Type"] = "Тип Шрифта"
L["Foreground Color"] = "Основной Цвет"
L["Foreground Texture"] = "Основная Текстура"
L["Form (Druid)"] = "Форма (друид)"
L["Form (Priest)"] = "Форма (жрец)"
L["Form (Shaman)"] = "Форма (шаман)"
L["Form (Warlock)"] = "Форма (чернокнижник)"
L["Frame"] = "Кадр"
L["Frame Strata"] = "Слой Кадра"
L["Frost"] = "Лед"
L["Frost Resistance"] = "Сопротивление Льду"
L["Full Scan"] = "Полное Сканирование"
L["Ghost Wolf"] = "Призрачный волк"
L["Glow Action"] = "Действия для подсвечивания"
L["Group aura count description"] = [=[Кол-во из %s человек, к которым должен быть применен один или более данных эффектов, чтобы индикатор сработал.
Если введено целое число (напр. 5), то число людей с этим эффектом, будет сравниваться с введеным значением.
Если введено не целое (напр. 0.5), дробь (напр. 1/2) или процент (напр. 50%%), то эта часть из %s человек и будет в расчетах.

|cFF4444FFДля Примера:|r
|cFF00CC00> 0|r сработает когда любой из %s попал под воздействие
|cFF00CC00= 100%%|r сработает когда любой из %s попал под воздействие
|cFF00CC00!= 2|r будет срабатывать когда %s человек под воздействием и их кол-во не равно 2
|cFF00CC00<= 0.8|r сработает когда менее 80%% из %s, под воздействием (4 из 5 сопартийцев, 8 из 10 или 20 из 25 членов рейда)
|cFF00CC00> 1/2|r сработает если затронуто больше половины из %s человек
|cFF00CC00>= 0|r всегда срабатывает, несмотря ни на что]=]
L["Group Member Count"] = "Кол-во Элементов Группы"
L["Group (verb)"] = "Группировать"
L["Height"] = "Высота"
L["Hide this group's children"] = "Скрыть элементы этой группы"
L["Hide When Not In Group"] = "Скрыть Когда Не в Группе"
L["Horizontal Align"] = "Выравнивание по Горизонтали"
L["Icon Info"] = "Информация о значке"
L["Ignored"] = "Игнорируется"
L["Ignore GCD"] = "Игнорировать ГКД"
L["%i Matches"] = "%i Совпадений"
L["Import"] = "Импорт"
L["Import a display from an encoded string"] = "Импортировать индикацию из закодированной строки"
L["Justify"] = "Выравнивание"
L["Left Text"] = "Текст Слева"
L["Load"] = "Загрузить"
L["Loaded"] = "Загружено"
L["Main"] = "Главный"
L["Main Trigger"] = "Главный Триггер"
L["Mana (%)"] = "Мана (%)"
L["Manage displays defined by Addons"] = "Управление индикациями, определенными Аддонами"
L["Message Prefix"] = "Префикс Сообщения"
L["Message Suffix"] = "Суффикс Сообщения"
L["Metamorphosis"] = "Метаморфоза"
L["Mirror"] = "Отразить"
L["Model"] = "Модель"
L["Moonkin/Tree/Flight(Feral)"] = "Сова/Дерево/Полет(Ферал)"
L["Move Down"] = "Опустить"
L["Move this display down in its group's order"] = "Переместить индикацию вниз в групповом порядке"
L["Move this display up in its group's order"] = "Переместить индикацию вверх, в групповом порядке"
L["Move Up"] = "Поднять"
L["Multiple Displays"] = "Множество Индикаций"
L["Multiple Triggers"] = "Множественные Триггеры"
L["Multiselect ignored tooltip"] = [=[
|cFFFF0000Игнор|r - |cFF777777Одиночная|r - |cFF777777Множественная|r
Эта опция не определяет, когда индикация должна быть загружена]=]
L["Multiselect multiple tooltip"] = [=[
|cFFFF0000Игнор|r - |cFF777777Одиночная|r - |cFF777777Множественная|r
Любое количество совпадающих значений могут быть получены]=]
L["Multiselect single tooltip"] = [=[
|cFFFF0000Игнор|r - |cFF777777Одиночная|r - |cFF777777Множественная|r
Только одно совпадение может быть получено]=]
L["Must be spelled correctly!"] = "Должно быть написано правильно!"
L["Name Info"] = "Название Инфо"
L["Negator"] = "Не"
L["New"] = "Новая Индикация"
L["Next"] = "Следующий"
L["No"] = "Нет"
L["No Children"] = "Нет Элементов"
L["Not all children have the same value for this option"] = "Не все элементы имеют схожее значение для этой опции"
L["Not Loaded"] = "Не Загружено"
L["No tooltip text"] = "Без подсказки"
L["% of Progress"] = "% Прогресса"
L["Okay"] = "Ок"
L["On Hide"] = "При Скрытии"
L["Only match auras cast by people other than the player"] = "Совпадение для эффектов других людей, но не игрока"
L["Only match auras cast by the player"] = "Совпадение только для эффектов игрока"
L["On Show"] = "При Появлении"
L["Operator"] = "Оператор"
L["or"] = "или"
L["Orientation"] = "Ориентация"
L["Other"] = "Другой(ие)"
L["Outline"] = "Обводка"
L["Own Only"] = "Только своё"
L["Player Character"] = "Игровой Персонаж"
L["Play Sound"] = "Проиграть Звук"
L["Presence (DK)"] = "Власть"
L["Presence (Rogue)"] = "Дух"
L["Prevents duration information from decreasing when an aura refreshes. May cause problems if used with multiple auras with different durations."] = "Не позволяет снижать информацию о длительности эффекта, при его обновлении. Может вызвать проблемы при использовании с несколькими эффектами разной длительности."
L["Primary"] = "Основной"
L["Progress Bar"] = "Полоса Прогресса"
L["Progress Texture"] = "Текстура Прогресса"
L["Put this display in a group"] = "Поместить эту индикацию в группу"
L["Ready For Use"] = "Готово Для Использования"
L["Re-center X"] = "Рецентровать X"
L["Re-center Y"] = "Рецентровать Y"
L["Remaining Time Precision"] = "Точность оставшегося времени"
L["Remove this display from its group"] = "Удалить эту индикацию из её группы"
L["Rename"] = "Переименовать"
L["Requesting display information"] = "Запрос информации о индикации из %s..."
L["Required For Activation"] = "Необходимо для Активации"
L["Retribution"] = "Воздаяние"
L["Right-click for more options"] = "Правый клик для дополнительных опций"
L["Right Text"] = "Текст Справа"
L["Rotate"] = "Вращать"
L["Rotate In"] = "Вращение В"
L["Rotate Out"] = "Вращение Из"
L["Rotate Text"] = "Вращать Текст"
L["Rotation"] = "Поворот"
L["Same"] = "Похожие"
L["Search"] = "Поиск"
L["Secondary"] = "Вторичная"
L["Send To"] = "Отправить"
L["Set tooltip description"] = "Установить всплывающую подсказку"
L["Shadow Dance"] = "Танец Теней"
L["Shadowform"] = "Облик Тьмы"
L["Shadow Resistance"] = "Сопротивление Темной Магии"
L["Shift-click to create chat link"] = "Shift+Клик чтобы создать |cFF8800FF[Ссылку в чат]"
L["Show all matches (Auto-clone)"] = "Показать все совпадения (Авто-клонирование)"
L["Show players that are |cFFFF0000not affected"] = "Показать |cFFFF0000не затронутых игроков"
L["Shows a 3D model from the game files"] = "Показать 3D модель из файлов игры"
L["Shows a custom texture"] = "Показывает свою текстуру"
L["Shows a progress bar with name, timer, and icon"] = "Показать полосу прогресса с названием, таймером и иконкой"
L["Shows a spell icon with an optional a cooldown overlay"] = "Показать значек заклинания с наложением обратного отсчета"
L["Shows a texture that changes based on duration"] = "Показать текстуру, меняющуюся в зависимости от длительности"
L["Shows one or more lines of text, which can include dynamic information such as progress or stacks"] = "Показать одну или несколько строк текста, которые могут включать в себя информацию о длительности или стаках"
L["Shows the remaining or expended time for an aura or timed event"] = "Показывает оставшееся или потраченное время эффекта или приуроченного события"
L["Show this group's children"] = "Показать индикации этой группы"
L["Size"] = "Размер"
L["Slide"] = "Скольжение"
L["Slide In"] = "Задвинуть"
L["Slide Out"] = "Выдвинуть"
L["Sort"] = "Сортировка"
L["Sound"] = "Звук"
L["Sound Channel"] = "Звуковой канал"
L["Sound File Path"] = "Путь к Звуковому Файлу"
L["Space"] = "Отступ"
L["Space Horizontally"] = "Отступ по Горизонтали"
L["Space Vertically"] = "Отступ по Вертикали"
L["Spell ID"] = "ID Заклинания"
L["Spell ID dialog"] = [=[По умолчанию |cFF8800FFWeakAuras|r не может различать ауры с тем же названием, но с разными |cFFFF0000ИД заклинаний|r.
Однако, если использовать Полное Сканирование, |cFF8800FFWeakAuras|r сможет обнаружить специфические |cFFFF0000ИД заклинаний|r.
Вы желаете задействовать Полное Сканирование, что бы онаружить эти |cFFFF0000ИД заклинаний|r.]=]
L["Stack Count"] = "Кол-во Стаков"
L["Stack Count Position"] = "Позиция Кол-ва Стаков"
L["Stack Info"] = "Информация о стаках"
L["Stacks Settings"] = "Настройки Стаков"
L["Stagger"] = "Шатание"
L["Stance (Warrior)"] = "Стойка"
L["Start"] = "Начало"
L["Stealable"] = "Возможно Украсть"
L["Stealthed"] = "Невидимость"
L["Sticky Duration"] = "Липкая Длительность"
L["Temporary Group"] = "Временная Группа"
L["Text"] = "Текст"
L["Text Color"] = "Цвет Текста"
L["Text Position"] = "Позиция Текста"
L["Text Settings"] = "Настройки Текста"
L["Texture"] = "Текстура"
L["The children of this group have different display types, so their display options cannot be set as a group."] = "Элементы этой группы содержат разные типы индикаций, по этому их настройки не могут быть групповыми"
L["The duration of the animation in seconds."] = "Длительность анимации в секугдах"
L["The type of trigger"] = "Тип Триггера"
L["This condition will not be tested"] = "Это условие не может быть протестировано"
L["This display is currently loaded"] = "Эта индикация уже загружена"
L["This display is not currently loaded"] = "Эта индикация еще не загружена"
L["This display will only show when |cFF00FF00%s"] = "Эта индикация будет отображена когда |cFF00FF00%s"
L["This display will only show when |cFFFF0000 Not %s"] = "Эта индикация будет отображена когда |cFFFF0000 Не %s"
L["This region of type \"%s\" has no configuration options."] = "Эта зона типа \"%s\" не имеет настроек."
L["Time in"] = "Время В"
L["Timer"] = "Таймер"
L["Timer Settings"] = "Настройки Таймера"
L["Toggle the visibility of all loaded displays"] = "Переключить видимость всех загруженных индикаций"
L["Toggle the visibility of all non-loaded displays"] = "Переключить видимость всех не загруженных индикаций"
L["Toggle the visibility of this display"] = "Переключить видимость этой индикации"
L["to group's"] = "в группы"
L["Tooltip"] = "Подсказка"
L["Tooltip on Mouseover"] = "Подсказка при наведении мыши"
L["Top Text"] = "Текст Вверху"
L["to screen's"] = "к экранам"
L["Total Time Precision"] = "Точность Общего Времени"
L["Tracking"] = "Отслеживание"
L["Travel"] = "Походная"
L["Trigger"] = "Триггер"
L["Trigger %d"] = "Триггер %d"
L["Triggers"] = "Триггеры"
L["Type"] = "Тип"
L["Ungroup"] = "Разгруппировать"
L["Unholy"] = "Нечистивость"
L["Unit Exists"] = "Объект существует"
L["Unlike the start or finish animations, the main animation will loop over and over until the display is hidden."] = "В отличие от начальной или конечной анимации, главная анимация зациклена и будет повторятся пока индикация не пропадет."
L["Unstealthed"] = "Не скрытный"
L["Update Custom Text On..."] = "Обновить Свой Текст На..."
L["Use Full Scan (High CPU)"] = "Использовать Полное Сканирование (Загрузка ЦП)"
L["Use tooltip \"size\" instead of stacks"] = "Использовать подсказку размер вместо стаков"
L["Vertical Align"] = "Выравнивание по Вертикали"
L["View"] = "Вид"
L["Width"] = "Ширина"
L["X Offset"] = "Смещение по X"
L["X Scale"] = "Масштаб по X"
L["Yes"] = "Да"
L["Y Offset"] = "Смещение по Y"
L["Y Scale"] = "Масштаб по Y"
L["Z Offset"] = "Смещение по Z"
L["Zoom"] = "Увеличение"
L["Zoom In"] = "Увеличить"
L["Zoom Out"] = "Уменьшить"



