-- Russian localization file for ruRU.
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "ruRU")
if not L then return; end

L["DTBars2_DESC"] = "Этот плагин позволяет создавать и изменять дополнительные панели для инфо-текстов"
L["Show additional options."] = "Показать дополнительные опции."
L["Set the name for the new datatext panel."] = "Задате имя для новой панели инфо-текстов."
L['Slots'] = "Слоты"
L["Sets number of datatext slots for the panel"] = "Устанавливает кол-во слотов под инфо-тексты на панели."
L['Hide panel background'] = "Скрыть фон панели"
L["Don't show this panel, only datatexts assinged to it"] = "Не показывать саму панель, а только назначенные на нее инфо-тексты"
L["Anchor"] = "Фиксатор"
L["Panel anchors itself on the parent frame with this point."] = "Этой точкой панель крепится к родительскому фрейму."
L["Panel anchors itself to this point on the parent frame."] = "К этой точке родительского фрейма крепится панель."
L["Strata"] = "Слой"
L["Defines on what layer of the UI your panel will be: higher layer/number allows the panel to overlap more other frames. If you are not sure, leave this option at \"2. Low\""] = "Определяет на каком слое интерфейса будет находиться панель: чем выше слой/число, тем больше потенциальное количество фреймов, которые будет перекрывать панель. Если сомневаетесь, оставьте опцию на \"2. Low\""
L["DT_Slot_Change_Text"] = "Вы собираетесь изменить число слотов с |cff1784d1%s|r на |cff1784d1%s|r. Это изменение сбросит все инфо-тексты данной панели на значения по умолчанию. Продолжить?"
L["Deleting the panel will erase all it's setting and you'll not be able to restore them. Continue?"] = "Удаление это панели приведет к стиранию всех ее настроек, Вы не сможете их восстановить. Продолжить?"
L["Are you sure you want to create a panel with those parameters?\nThis action will require a reload."] = "Вы уверены, что хотите создать панель с данными параметрами?\nЭто действие потребует перезагрузки."
L['farleft'] = "Слева скраю"
L['farright'] = "Справа скраю"
L["Sets width of the panel"] = "Устанавливает ширину панели"
L["Sets height of the panel (height of each individual datatext)"] = "Устанавливает высоту панели (высоту каждого индивидуального инфо-текста)"
L["Panel with the name %s already exist. Please choose another one."] = "Панель с именем %s уже существует. Пожалуйста, выберите другое."