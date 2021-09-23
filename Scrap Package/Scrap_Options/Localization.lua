local L = Scrap_Locals
local Language = GetLocale()

-- Simplified Chinese --
if Language == 'zhCN' then
	L["AutoSell"] = "自动出售"
	L["AutoSellDesc"] = "开启此功能，Scrap会在你访问商人时自动出售所有垃圾。"
	L["ShowTutorials"] = "显示教学"
	L["Tutorial"] = "你正在使用Scrap，本插件可以让你在商人处一键出售所有你不需要的物品。|n|n|cffffd200左键单击|rScrap按钮出售所有垃圾。|cffffd200右键单击|rScrap按钮弹出选项。"
	L["Tutorial2"] = "你可以自行决定Scrap帮你出售哪些物品: 如要对|cffffd200垃圾列表|r进行添加或删除，只需将物品从你的背包拖拽到Scrap按钮。"

-- Traditional Chinese --
elseif Language == 'zhTW' then
	L["AutoSell"] = "自動出售"
	L["AutoSellDesc"] = "開啟次功能，Scrap會在你訪問商人時自動出售所有垃圾。"
	L["ShowTutorials"] = "顯示教學"
	L["Tutorial"] = "你正在使用Scrap，本組件可讓你在商人處單擊出售所有你不需要的物品。|n|n|cffffd200左鍵點擊|rScrap按鈕出售所有垃圾。|cffffd200右鍵點擊|rScrap按鈕顯示選單。"
	L["Tutorial2"] = "你可以自行決定Scrap幫助你出售哪些物品: 如要對|cffffd200垃圾清單|r進行添加或移除，只需將物品從你的背包拖拽到Scrap按鈕。"
	
-- Russian --
elseif Language == 'ruRU' then
	L["AutoSell"] = "Авто продажа"
	L["AutoSellDesc"] = "Если включено, Scrap автоматически будет продавать хлам когда вы посещаете торговца."
	L["ShowTutorials"] = "Показать учебник"
	L["Tutorial"] = "Вы сейчас используете Scrap - дополнение, которое позволяет вам продавать весь ваш имеющийся хлам нажатием одной кнопки!|n|n|cffffd200Левая кнопка мыши|r на кнопке Scrap продаст ваш хлам. |cffffd200Правая кнопка мыши|r откроет вам дополнительные опции."
	L["Tutorial2"] = "Вы можете указать, какие предметы вы хотите, чтобы Scrap продавал или нет: для добавления или удаления предмета с вашего |cffffd200Списка хлама|r, перетащите предмет на кнопку Scrap."
	
-- German --
elseif Language == 'deDE' then
	L["AutoSell"] = "Automatisch verkaufen"
	L["AutoSellDesc"] = "Wenn aktiviert, wird Scrap deinen Müll automaitsch beim Händler verkaufen."
	L["ShowTutorials"] = "Zeige Anleitungen"
	L["Tutorial"] = "Du benutzt nun Scrap, ein Addon zum Verkaufen all der Gegenstände, die du nicht brauchst, mit nur einem Klick.|n|n|cffffd200Linksklick|r auf den Scrap-Button verkauft deinen gesamten Müll. |cffffd200Rechtsklick|r öffnet weitere Optionen."
	L["Tutorial2"] = "Du kannst einstellen, welche Gegenstände von Scrap verkauft oder auch nicht verkauft werden sollen: Um einen Gegenstand zur |cffffd200Junkliste|r hinzuzufügen oder zu entfernen, zieh es aus deinen Taschen auf den Scrap-Button."
	
-- Spanish --
elseif Language == 'esES' or Language == 'esMX' then
	L["AutoSell"] = "Auto Vender"
	L["AutoSellDesc"] = "Si está habilitado, Scrap venderá automáticamente toda tu basura cuando visites a un mercader."
	L["ShowTutorials"] = "Mostrar Tutoriales"
	L["Tutorial"] = "Estás usando Scrap, un addon que te permite vender la basura que no necesitas con un simple click cada vez que visitas a un mercader.|n|n|cffffd200Click Izquierdo|r en el Botón Scrap venderá toda tu basura. |cffffd200Click Derecho|r en el botón mostrará opciones extra."
	L["Tutorial2"] = "Puedes especificar que objetos quieres vender o no: para añadir o eliminar un objeto de tu |cffffd200Lista de Basura|r, arrástralo desde tus bolsas al Botón Scrap."
	
-- French --
elseif Language == 'frFR' then
	L["AutoSell"] = "Vente automatique"
	L["AutoSellDesc"] = "Si actif, Scrap vendra automatiquement tous vos objets gris lors d'une visite chez un marchand."
	L["ShowTutorials"] = "Afficher les didacticiels"
	L["Tutorial"] = "Vous utilisez maintenant Scrap, un add-on qui vous permet de vendre tous les objets que vous ne voulez plus en un clic au marchand.|n|n|cffffd200Cliquez gauche|r sur le bouton Scrap vendra tous vos déchets. |cffffd200Cliquez droit|r sur le bouton vous affichera les options supplémentaires."
	L["Tutorial2"] = "Vous pouvez spécifier quels objets vous voulez que Scrap vende ou non : pour ajouter ou enlever un objet de votre |cffffd200liste de déchets|r, déplacer l'objet de votre sac vers le bouton Scrap."
	
-- English --
else
	L["AutoSell"] = 'Auto Sell'
	L["AutoSellDesc"] = 'If enabled, Scrap will automatically sell all your junk when you visit a merchant.'
	L["ShowTutorials"] = 'Show Tutorials'
	L["Tutorial"] = 'You are now using Scrap, an addon which allows you to sell every item you do not need with a single click at the merchant.|n|n|cffffd200Left Clicking|r on the Scrap Button will sell all your junk. |cffffd200Right Clicking|r on the button will bring up extra options.'
	L["Tutorial2"] = 'You can specify which items you want Scrap to sell or not: to add or remove an item from your |cffffd200Junk List|r, drag it from your bags into the Scrap button.'
end