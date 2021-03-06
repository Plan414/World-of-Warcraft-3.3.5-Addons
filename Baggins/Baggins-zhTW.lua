local L = AceLibrary("AceLocale-2.2"):new("Baggins")


L:RegisterTranslations("zhTW", function()
	return {
		--itemtypes, these must match the Type and SubType returns from GetItemInfo for the ItemType rule to work
		["Armor"] = "護甲",
			["Cloth"] = "布甲",
			["Idols"] = "雕像",
			["Leather"] = "皮甲",
			["Librams"] = "聖契",
			["Mail"] = "鎖甲",
			["Miscellaneous"] = "其他",
			["Shields"] = "盾牌",
			["Totems"] = "圖騰",
			["Plate"] = "鎧甲",
		["Consumable"] = "消耗品",
		["Container"] = "容器",
			["Bag"] = "容器",
			["Enchanting Bag"] = "附魔包",
			["Engineering Bag"] = "工程包",
			["Herb Bag"] = "草藥包",
			["Soul Bag"] = "靈魂碎片背包",
		["Key"] = "鑰匙",
		["Miscellaneous"] = "其他",
			["Junk"] = "垃圾",
		["Reagent"] = "材料",
		["Recipe"] = "配方",
			["Alchemy"] = "煉金術",
			["Blacksmithing"] = "鍛造",
			["Book"] = "書籍",
			["Cooking"] = "烹飪",
			["Enchanting"] = "附魔",
			["Engineering"] = "工程學",
			["First Aid"] = "急救",
			["Leatherworking"] = "制皮",
			["Tailoring"] = "剝皮",
		["Projectile"] = "彈藥",
			["Arrow"] = "箭",
			["Bullet"] = "子彈",
		["Quest"] = "任務",
		["Quiver"] = "箭袋",
			["Ammo Pouch"] = "彈藥袋",
			["Quiver"] = "箭袋",
		["Trade Goods"] = "商品",
			["Devices"] = "裝置",
			["Explosives"] = "爆炸物",
			["Parts"] = "零件",
			["Gems"] = "寶石",
		["Weapon"] = "武器",
			["Bows"] = "弓",
			["Crossbows"] = "弩",
			["Daggers"] = "匕首",
			["Guns"] = "槍械",
			["Fishing Pole"] = "魚竿",
			["Fist Weapons"] = "拳套",
			["Miscellaneous"] = "其他",
			["One-Handed Axes"] = "單手斧",
			["One-Handed Maces"] = "單手錘",
			["One-Handed Swords"] = "單手劍",
			["Polearms"] = "長柄武器",
			["Staves"] = "法杖",
			["Thrown"] = "投擲武器",
			["Two-Handed Axes"] = "雙手斧",
			["Two-Handed Maces"] = "雙手錘",
			["Two-Handed Swords"] = "雙手劍",
			["Wands"] = "魔杖",
		--end of localizations needed for rules to work	
		
	
		["Baggins"] = "Baggins",
		["Toggle All Bags"] = "開關所有背包",
		["Columns"] = "列數",
		["Number of Columns shown in the bag frames"] = "在背包窗體中顯示的列數",
		["Layout"] = "佈局",
		["Layout of the bag frames."] = "背包窗體佈局",
		["Automatic"] = "自動",
		["Automatically arrange the bag frames as the default ui does"] = "背包按默認佈局自動排列",
		["Manual"] = "手動",
		["Each bag frame can be positioned manually."] = "可以自定義每個背包的位置",
		["Show Section Title"] = "顯示分類標題",
		["Show a title on each section of the bags"] = "在每個分類上顯示標題",
		["Sort"] = "物品排列方式",
		["How items are sorted"] = "物品如何排列",
		["Quality"] = "品質",
		["Items are sorted by quality."] = "物品按品質排列",
		["Name"] = "名稱",
		["Items are sorted by name."] = "物品按名稱排列",
		["Hide Empty Sections"] = "隱藏空分類背包",
		["Hide sections that have no items in them."] = "隱藏沒有物品的分類背包",
		["Hide Default Bank"] = "隱藏默認銀行",
		["Hide the default bank window."] = "隱藏默認銀行窗口",
		["FuBar Text"] = "Fubar 文字",
		["Options for the text shown on fubar"] = "Fubar 文字顯示選項",
		["Show empty bag slots"] = "顯示背包未使用狀態",
		["Show used bag slots"] = "顯示背包已使用狀態",
		["Show Total bag slots"] = "顯示背包總容量",
		["Combine Counts"] = "聯合計數",
		["Show only one count with all the seclected types included"] = "為所有選擇的類型顯示總數",
		["Show Ammo Bags Count"] = "彈藥袋狀態",
		["Show Soul Bags Count"] = "靈魂袋狀態",
		["Show Specialty Bags Count"] = "特殊背包狀態",
		["Show Specialty (profession etc) Bags Count"] = "特殊（專業等）背包狀態",
		["Set Layout Bounds"]= "設置佈局範圍",
		["Shows a frame you can drag and size to set where the bags will be placed when Layout is automatic"] = "顯示一個可以移動縮放的框體，當佈局設定為自動時背包將放置在此處",
		["Lock"] = "鎖定",
		["Locks the bag frames making them unmovable"] = "鎖定背包框體使之不能隨意移動",
		["Shrink Width"] = "收縮寬度",
		["Shrink the bag's width to fit the items contained in them"] = "按背包內物品收縮背包寬度",
		["Compress"] = "壓縮",
		["Compress Multiple stacks into one item button"] = "多組物品顯示在一個格子",
		["Compress All"] = "壓縮所有物品",
		["Show all items as a single button with a count on it"] = "所有物品及其數量顯示在一個格子",
		["Compress Empty Slots"] = "壓縮背包未用格",
		["Show all empty slots as a single button with a count on it"] = "所有背包未用格及其數量顯示在一個格子",
		["Compress Soul Shards"] = "壓縮靈魂碎片",
		["Show all soul shards as a single button with a count on it"] = "所有靈魂碎片及其數量顯示在一個格子",
		["Compress Ammo"] = "壓縮彈藥",
		["Show all ammo as a single button with a count on it"] = "所有彈藥及其數量顯示在一個格子",
		["Quality Colors"]= "按品質著色",
		["Color item buttons based on the quality of the item"] = "按照物品的品質給邊框著色",
		["Enable"] = "允許",
		["Enable quality coloring"] = "允許按品質著色",
		["Color Threshold"] = "著色等級",
		["Only color items of this quality or above"] = "僅著色這個品質及以上的物品",
		["Color Intensity"] = "著色亮度",
		["Intensity of the quality coloring"] = "品質著色亮度",
		["Edit Bags"] = "編輯背包",
		["Edit the Bag Definitions"] = "編輯背包的定義",
		["Edit Categories"] = "編輯分類",
		["Edit the Category Definitions"] = "編輯分類的定義",
		["Load Profile"] = "加載設置",
		["Load a built-in profile: NOTE: ALL Custom Bags will be lost and any edited built in categories will be lost."] = "加載內置設置：注：所有自定義背包和分類將會丟失。",
		["Default"] = "默認",
		["A default set of bags sorting your inventory into categories"] = "一個按分類排列背包的默認設置",
		["All in one"] = "整合背包",
		["A single bag containing your whole inventory, sorted by quality"] = "將所有背包整合成一個，按品質排序。",
		["Scale"] = "縮放",
		["Scale of the bag frames"] = "縮放所有窗體",
		--bagtypes
		["Backpack"] = "行囊",
		["Bag1"] = "1號背包",
		["Bag2"] = "2號背包",
		["Bag3"] = "3號背包",
		["Bag4"] = "4號背包",
		["Bank Frame"] = "銀行窗口",
		["Bank Bag1"] = "銀行1號背包",
		["Bank Bag2"] = "銀行2號背包",
		["Bank Bag3"] = "銀行3號背包",
		["Bank Bag4"] = "銀行4號背包",
		["Bank Bag5"] = "銀行5號背包",
		["Bank Bag6"] = "銀行6號背包",
		["Bank Bag7"] = "銀行7號背包",
		["KeyRing"] = "鑰匙圈",
		
		--qualoty names
		["Poor"] = "粗糙",
		["Common"] = "普通",
		["Uncommon"] = "優秀",
		["Rare"] = "精良",
		["Epic"] = "史詩",
		["Legendary"] = "傳說",
		["Artifact"] = "神器",
		
		["None"] = "無",
		["All"] = "所有",
		
		["Item Type"] = "物品類型",
		["Filter by Item type and sub-type as returned by GetItemInfo"] = "按照從GetItemInfo獲得的物品類型和子類型過濾",
		["ItemType - "] = "物品類型 - ",
		["Item Type Options"] = "物品類型選項",
		["Item Subtype"] = "物品子類型",

		["Container Type"] = "容器類型",
		["Filter by the type of container the item is in."] = "按照其內物品類型過濾容器",
		["Container : "] = "容器：",
		["Container Type Options"] = "容器類型選項",

		["Item ID"] = "物品ID",
		["Filter by ItemID, this can be a space delimited list or ids to match."] = "按照物品ID過濾。",
		["ItemIDs "] = "物品ID",
		["ItemID Options"] = "物品ID選項",
		["Item IDs (space seperated list)"] = "物品ID（以空格分割）",
		["New"] = "新物品",
		["Current IDs, click to remove"] = "當前ID，點擊刪除。",
		
		["Filter by the bag the item is in"] = "按照背包內物品過濾",
		["Bag "] = "背包",
		["Bag Options"] = "背包選項",
		["Ignore Empty Slots"] = "忽略背包未用格",
		
		["Item Name"] = "物品名稱",
		["Filter by Name or partial name"] = "按照名稱或部分名稱過濾",
		["Name: "] = "名稱：",
		["Item Name Options"] = "物品名稱選項",
		["String to Match"] = "匹配字元",
		
		["PeriodicTable Set"] = "PeriodicTable項",
		["Filter by PeriodicTable Set"] = "按照PeriodicTable項過濾",
		["Periodic Table Set Options"] = "PeriodicTable項屬性",
		["Set"] = "項",
		
		["Empty Slots"] = "未用格",
		["Empty bag slots"] = "背包未用格",
		
		["Ammo Bag"] = "彈藥袋",
		["Items in an ammo pouch or quiver"] = "箭袋或者彈藥袋內的物品",
		["Ammo Bag Slots"] = "彈藥袋",
		
		["Quality"] = "品質",
		["Filter by Item Quality"] = "按照物品品質過濾",
		["Quality Options"] = "品質選項",
		["Comparison"] = "比較",
		
		["Equip Location"] = "裝備位置",
		["Filter by Equip Location as returned by GetItemInfo"] = "按照通過GetItemInfo得到的裝備位置過濾",
		
		["Equip Location Options"] = "裝備位置選項",
		["Location"] = "位置",
		
		["Unfiltered Items"] = "未過濾物品",
		["Matches all items that arent matched by any other bag, NOTE: this should be the only rule in a category, others will be ignored"] = "除去所有已匹配其餘背包的物品，注：這將是分類中的唯一規則，忽略其餘規則。",
		["Unfiltered"] = "未過濾",
		
		["Bind"] = "綁定",
		["Filter based on if the item binds, or if it is already bound"] = "按照物品是否綁定過濾",
		["Bind *unset*"] = "無需綁定",
		["Unbound"] = "未綁定",
		["Bind Options"] = "綁定選項",
		["Bind Type"] = "綁定類型",
		["Binds on pickup"] = "拾取後綁定",
		["Binds on equip"] = "裝備後綁定",
		["Binds on use"] = "使用後綁定",
		["Soulbound"] = "靈魂綁定",

		["Tooltip"] = "物品提示",
		["Filter based on text contained in its tooltip"] = "按照物品提示過濾",
		["Tooltip Options"] = "提示選項",
		
		["ItemID: "] = "物品ID：",
		["Item Type: "] = "物品類型：",
		["Item Subtype: "] = "物品子類型：",
		
		["Click a bag to toggle it. Shift-click to move it up. Alt-click to move it down"] = "點擊開關背包。Shift-點擊向上移動。Alt-點擊向下移動。",
		
		["Bags"] = "背包",
		["Options"] = "選項",
		["Open With All"] = "總是打開",
		["Bank"] = "銀行",
		["Sections"] = "分類背包",
		["Categories"] = "分類",
		["Add Category"] = "增加分類",
		["New Section"] = "新分類背包",
		["New Bag"] = "新背包",
		["Close"] = "關閉",
		["Click on an entry to open. Shift-Click to move up. Alt-Click to move down. Ctrl-Click to delete."] = "點擊打開條目。Shift-點擊向上移動。Alt-點擊向下移動。Ctrl-點擊刪除。",
		["Rules"] = "規則",
		["New Rule"] = "新規則",
		["Add Rule"] = "增加規則",
		["New Category"] = "新分類",
		["Apply"] = "應用",
		["Click on an entry to open. Ctrl-Click to delete."] = "點擊打開一個條目。Ctrl-點擊刪除。",
		
		["Editing Rule"] = "編輯規則",
		["Type"] = "類型",
		["Select a rule type to create the rule"] = "選擇一個規則類型以創建規則",
		["Operation"] = "運算",
		["AND"] = "和",
		["OR"] = "與",
		["NOT"] = "非",
		
		["Baggins - New Bag"] = "Baggins - 新背包",
		["Baggins - New Section"] = "Baggins - 新分類背包",
		["Baggins - New Category"] = "Baggins - 新分類",
		["Accept"] = "接受",
		["Cancel"] = "取消",
		
		["Are you sure you want to delete this Bag? this cannot be undone"] = "你確認要刪除這個背包？ 這是個不可恢復的操作",
		["Are you sure you want to delete this Section? this cannot be undone"] = "你確認要刪除這個選項？ 這是個不可恢復的操作",
		["Are you sure you want to remove this Category? this cannot be undone"] = "你確認要刪除這個分類？ 這是個不可恢復的操作",
		["Are you sure you want to remove this Rule? this cannot be undone"] = "你確認要刪除這個規則？ 這是個不可恢復的操作",
		["Delete"] = "刪除",
		["Cancel"] = "取消",
		
		["That category is in use by one or more bags, you cannot delete it."] = "這個分類被一個或多個背包使用，不能被刪除。",
		["A category with that name already exists."] = "同名分類已經存在。",
		
		["Drag to Move\nRight-Click to Close"] = "點擊拖動\n右鍵關閉",
		["Drag to Size"] = "縮放拖動",
		
		["Previous "] = "向前",
		["Next "] = "向後",
		
		["All In One"] = "整合背包",
		["Bank All In One"] = "整合銀行",
		["Bank Bags"] = "銀行背包",
		
		["Equipment"] = "裝備",
		["Weapons"] = "武器",
		["Quest Items"] = "任務物品",
		["Consumables"] = "消耗品",
		["Water"] = "飲料",
		["Food"] = "食物",
		["FirstAid"] = "急救",
		["Potions"] = "藥劑",
		["Scrolls"] = "卷軸",
		["Misc"] = "其他",
		["Misc Consumables"] = "其他消耗品",

		["Mats"] = "基礎材料",
		["Tradeskill Mats"] = "[商]基礎材料",
		["Gathered"] = "採集",
		["BankBags"] = "銀行背包",
		["Ammo"] = "彈藥",
		["AmmoBag"] = "彈藥袋",
		["SoulShards"] = "靈魂碎片",
		["SoulBag"] = "靈魂袋",
		["Other"] = "其他",
		["Trash"] = "垃圾",
		["TrashEquip"] = "垃圾裝備",
		["Empty"] = "未用格",
		["Bank Equipment"] = "[銀]裝備",
		["Bank Quest"] = "[銀]任務",
		["Bank Consumables"] = "[銀]消耗品",
		["Bank Trade Goods"] = "[銀]商品",
		["Bank Other"] = "[銀]其他",
		
		["Add To Category"] = "添加到分類",
		["Exclude From Category"] = "從分類中刪除",
		["Item Info"] = "物品信息",
		["Use"] = "使用",
			["Use/equip the item rather than bank/sell it"] = "使用/裝備這件物品而不是放銀行/出售",
		["Quality: "] = "品質：",
		["Level: "] = "等級：",
		["MinLevel: "] = "最小等級：",
		["Stack Size: "] = "堆疊數量：",
		["Equip Location: "] = "裝備位置：",
		["Periodic Table Sets"] = "PeriodicTable項",
		
		["Highlight New Items"] = "高亮新物品",
		["Add *New* to new items, *+++* to items that you have gained more of."] = "在新物品上增加*新*，在獲得了更多的物品上增加*+++*",
		["Reset New Items"] = "重置新物品",
		["Resets the new items highlights."] = "重置新物品高亮",
		["*New*"] = "*新*",
		
		["Hide Duplicate Items"] = "隱藏相同物品的範圍",
		["Prevents items from appearing in more than one section/bag."] = "阻止物品出現在超過一個的分類背包/背包中",
		
		["Optimize Section Layout"] = "優化分類背包佈局",
		["Change order and layout of sections in order to save display space."] = "更改分類背包的佈局和順序使之更節省螢幕",
		
		["All In One Sorted"]= "分類的整合背包",
		["A single bag containing your whole inventory, sorted into categories"]= "將所有背包整合成一個，按照分類排序",
		
		["Compress Stackable Items"]= "壓縮可堆疊物品",
		["Show stackable items as a single button with a count on it"]= "將所有可堆疊物品及其數量顯示在一個格子",

		["Appearance and layout"]= "外觀和佈局",
		["Bags"]= "背包",
		["Bag display and layout settings"]= "背包顯示和佈局設置",
		["Layout Type"]= "佈局類型",
		["Sets how all bags are laid out on screen."]= "設置所有背包如何在螢幕上排列",
		["Shrink bag title"]= "收縮背包標題",
		["Mangle bag title to fit to content width"]= "使背包標題適應內容寬度",
		["Sections"]= "分類背包",
		["Bag sections display and layout settings."]= "分類背包顯示和佈局設置",
		["Items"]= "物品",
		["Item display settings"]= "物品顯示設置",
		["Bag Skin"]= "背包皮膚",
		["Select bag skin"]= "選擇背包皮膚",
		
		["Compress bag contents"]= "壓縮背包",
		["Split %d"]= "分離%d",
		["Split_tooltip"] = "點擊按照設定分離物品\n並且在未用格中自動排列。\n\n按住shift僅揀取。",
		
		["PT3 LoD Modules"] = "PT3 LoD模塊",
		["Choose PT3 LoD Modules to load at startup, Will load immediately when checked"] = "選擇開始時加載的PT3 LoD模塊，選擇後將立即加載",
		["Load %s at Startup"] = "開始時加載%s",
		
		["Disable Compression Temporarily"] = "臨時禁用壓縮",
		["Disabled Item Compression until the bags are closed."] = "在背包關閉前禁用物品壓縮",
		
		["Always Resort"] = "總是重排",
		["Keeps Items sorted always, this will cause items to jump around when selling etc."] = "始終保持物品排列，將會在出售時導致物品跑來跑去",
		
		["Force Full Refresh"] = "全部刷新",
		["Forces a Full Refresh of item sorting"] = "刷新所有物品類別",
		
		["Override Default Bags"] = "取代默認背包",
		["Baggins will open instead of the default bags"] = "Baggins將會取代默認背包",
		["Sort New First"] = "新物品在前",
		["Sorts New Items to the beginning of sections"] = "在分類背包的開始位置排列新物品",
		["New Items"] = "新物品",
		
		["Items that match another category"] = "匹配另一個分類的物品",
		["Category Options"] = "分類選項",
		["Category"] = "分類",

		["Layout Anchor"] = "佈局錨點",
		["Sets which corner of the layout bounds the bags will be anchored to."] = "設定背包定位到佈局框的哪個角落。",
		["Top Right"] = "右上",
		["Top Left"] = "左上",
		["Bottom Right"] = "右下",
		["Bottom Left"] = "左下",

		["Show Money On Bag"] = "在背包顯示金錢",
		["Which Bag to Show Money On"] = "選擇顯示金錢的背包",

		["User Defined"] = "自定義設置",
		["Load a User Defined Profile"] = "加載一個自定義設置",
		["Save Profile"] = "保存設置",
		["Save a User Defined Profile"] = "保存一個自定義設置",
		["New"] = "新建",
		["Create a new Profile"] = "創建一個新設置",
		["Delete Profile"] = "刪除設置",
		["Delete a User Defined Profile"] = "刪除一個自定義設置",
		["Save"] = "保存",
		["Load"] = "加載",
		["Delete"] = "刪除",

		["Config Window"] = "設置窗口",
		["Opens the Waterfall Config window"] = "打開使用Waterfall的圖形設置視窗",
		["Bag/Category Config"] = "設置背包和分類",
		["Opens the Waterfall Config window"] = "打開使用Waterfall的圖形設置視窗",
		["Rename / Reorder"] = "重命名/重排",
		["From Profile"] = "從配置",
		["User"] = "玩家",
		["Copy From"] = "復制自：",
		["Edit"] = "編輯",
		["Automatically open at auction house"] = "在拍賣行自動打開",
		["Create"] = "創建",
		["Bag Priority"] = "背包優先級",
		["Section Priority"] = "分類塊優先級",

		["Allow Duplicates"] = "允許顯示重復物品",
		["Import Sections From"] = "分類塊導入自：",
--[[------------------- modified by lalibre -------------------------------
	------ Baggins-Options.lua ------
$38		hideduplicates = 'global',
$330						validate = { 
							global = L["global"],
							bag = L["bag"],
							disabled = L["disabled"],
						}
$392						validate = { 
							auto = L["auto"],
							manual = L["manual"],
						 }
$536						validate = {
							quality = L["quality"],
							name = L["name"],
							type = L["type"],
							slot = L["slot"],
						}
$1424		return L["Select a Bag/Category"]
$1508				waterfall:AddControl("type","linklabel","text",L["Remove"],"noNewLine",true,"r",1,"g",0.82,"b",0,
$1530			if not category then return L["Invalid Category"] end
$1564								"execFunc",Baggins.RemoveRule,"confirm",L["Are You Sure?"],
$1581	waterfall:Register("BagginsEdit","tree",WaterfallTree,"children",WaterfallChildren,"treeType","SECTIONS","title",L["Baggins Bag/Category Editor"],"width",650)
$1452								"execArg1",Baggins,"execArg2",L["New"])
$1522								"execArg1",Baggins,"execArg2",bagid,"execArg3",L["New"])
--]]------------------- modified by lalibre -------------------------------
--[[------------------- modified by lalibre -------------------------------
		["global"] = "所有背包",
		["bag"] = "本背包",
		["disabled"] = "禁用",

		["auto"] = "自動",
		["manual"] = "手動",

		["quality"] = "品質",
		["name"] = "名稱",
		["type"] = "類型",
		["slot"] = "位置",

		["Select a Bag/Category"] = "選擇背包/分類",
		["Invalid Category"] = "未知分類",
		["Remove"] = "刪除",
		["Are You Sure?"] = "確認？",
		["Baggins Bag/Category Editor"] = "Baggins背包/分類編輯器",
--]]------------------- modified by lalibre -------------------------------
	}
end)
