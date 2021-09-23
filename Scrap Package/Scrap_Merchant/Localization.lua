Scrap_Locals = {}
local L = Scrap_Locals
local Language = GetLocale()

-- Simplified Chinese --
if Language == 'zhCN' then
	L["Add"] = "添加到垃圾列表"
	L["Added"] = "已添加到垃圾列表: %s"
	L["Remove"] = "从垃圾列表删除"
	L["Removed"] = "已从垃圾列表删除: %s"
	L["SellJunk"] = "出售垃圾"
	L["SoldJunk"] = "你出售垃圾共获得 %s"

-- Traditional Chinese --
elseif Language == 'zhTW' then
	L["Add"] = "添加到垃圾清單"
	L["Added"] = "已添加到垃圾清單: %s"
	L["Remove"] = "從垃圾清單移除"
	L["Removed"] = "已從垃圾清單移除: %s"
	L["SellJunk"] = "出售垃圾"
	L["SoldJunk"] = "你出售垃圾共獲得 %s"

-- Russian --
elseif Language == 'ruRU' then
	L["Add"] = "Добавить в список хлама"
	L["Added"] = "Добавлено в список хлама: %s"
	L["Remove"] = "Удалить из списка хлама"
	L["Removed"] = "Удалено из списка хлама: %s"
	L["SellJunk"] = "Продать хлам"
	L["SoldJunk"] = "Вы продали хлама на %s"
	
-- German --
elseif Language == 'deDE' then
	L["Add"] = "Zur Junkliste hinzufügen"
	L["Added"] = "Zur Junkliste hinzugefügt: %s"
	L["Remove"] = "Von der Junkliste entfernen"
	L["Removed"] = "Von der Junkliste entfernt: %s"
	L["SellJunk"] = "Müll verkaufen"
	L["SoldJunk"] = "Du hast deinen Müll für %s verkauft"
	
-- Spanish --
elseif Language == 'esES' or Language == 'esMX' then
	L["Add"] = "Añadir a la Lista de Basura"
	L["Added"] = "Añadido a la Lista de Basura: %s"
	L["Remove"] = "Eliminar de la Lista de Basura"
	L["Removed"] = "Eliminado de la Lista de Basura: %s"
	L["SellJunk"] = "Vender Basura"
	L["SoldJunk"] = "Has vendido tu basura por %s"
	
-- English --
else
	L["Add"] = 'Add to Junk List'
	L["Added"] = 'Added to junk list: %s'
	L["Remove"] = 'Remove from Junk List'
	L["Removed"] = 'Removed from junk list: %s'
	L["SellJunk"] = 'Sell Junk'
	L["SoldJunk"] = 'You sold your junk for %s'
end