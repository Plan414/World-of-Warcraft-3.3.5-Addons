local L = AceLibrary("AceLocale-2.2"):new("Baggins")


L:RegisterTranslations("zhCN", function()
	return {
		--物品类型，必须和通过GetItemInfo命令获得的类型及子类型数据匹配才能使物品类型规则正确运行。
		["Armor"] = "护甲",
			["Cloth"] = "布甲",
			["Idols"] = "神像",
			["Leather"] = "皮甲",
			["Librams"] = "圣契",
			["Mail"] = "锁甲",
			["Miscellaneous"] = "其它",
			["Shields"] = "盾牌",
			["Totems"] = "图腾",
			["Plate"] = "板甲",
		["Consumable"] = "消耗品",
		["Container"] = "容器",
			["Bag"] = "容器",
			["Enchanting Bag"] = "附魔材料袋",
			["Engineering Bag"] = "工程学材料袋",
			["Herb Bag"] = "草药袋",
			["Soul Bag"] = "灵魂袋",
		["Key"] = "钥匙",
		["Miscellaneous"] = "其它",
			["Junk"] = "垃圾",
		["Reagent"] = "材料",
		["Recipe"] = "配方",
			["Alchemy"] = "炼金术",
			["Blacksmithing"] = "锻造",
			["Book"] = "书籍",
			["Cooking"] = "烹饪",
			["Enchanting"] = "附魔",
			["Engineering"] = "工程学",
			["First Aid"] = "急救",
			["Leatherworking"] = "制皮",
			["Tailoring"] = "剥皮",
		["Projectile"] = "弹药",
			["Arrow"] = "箭",
			["Bullet"] = "子弹",
		["Quest"] = "任务",
		["Quiver"] = "箭袋",
			["Ammo Pouch"] = "弹药袋",
			["Quiver"] = "箭袋",
		["Trade Goods"] = "商品",
			["Devices"] = "装置",
			["Explosives"] = "爆炸物",
			["Parts"] = "零件",
			["Gems"] = "珠宝",
		["Weapon"] = "武器",
			["Bows"] = "弓",
			["Crossbows"] = "弩",
			["Daggers"] = "匕首",
			["Guns"] = "枪械",
			["Fishing Pole"] = "鱼竿",
			["Fist Weapons"] = "拳套",
			["Miscellaneous"] = "其它",
			["One-Handed Axes"] = "单手斧",
			["One-Handed Maces"] = "单手锤",
			["One-Handed Swords"] = "单手剑",
			["Polearms"] = "长柄武器",
			["Staves"] = "法杖",
			["Thrown"] = "投掷武器",
			["Two-Handed Axes"] = "双手斧",
			["Two-Handed Maces"] = "双手锤",
			["Two-Handed Swords"] = "双手剑",
			["Wands"] = "魔杖",
		--规则正确运行所必需的本地化内容到此结束
		
	
		["Baggins"] = "Baggins",
		["Toggle All Bags"] = "开关所有背包",
		["Columns"] = "列数",
		["Number of Columns shown in the bag frames"] = "在背包框体中显示的物品列数",
		["Layout"] = "布局",
		["Layout of the bag frames."] = "背包框体的布局",
		["Automatic"] = "自动",
		["Automatically arrange the bag frames as the default ui does"] = "按系统默认样式排列背包",
		["Manual"] = "手动",
		["Each bag frame can be positioned manually."] = "可以任意更改背包框体的位置",
		["Show Section Title"] = "显示分类块标题",
		["Show a title on each section of the bags"] = "在每个分类块上显示标题",
		["Sort"] = "物品排列方式",
		["How items are sorted"] = "物品如何排列",
		["Quality"] = "品质",
		["Items are sorted by quality."] = "物品按品质排列",
		["Name"] = "名称",
		["Items are sorted by name."] = "物品按名称排列",
		["Hide Empty Sections"] = "隐藏空分类块",
		["Hide sections that have no items in them."] = "隐藏未包含物品的分类块",
		["Hide Default Bank"] = "隐藏系统银行",
		["Hide the default bank window."] = "隐藏系统默认银行的窗口",
		["FuBar Text"] = "Fubar文字",
		["Options for the text shown on fubar"] = "Fubar文字显示选项",
		["Show empty bag slots"] = "显示背包未用格",
		["Show used bag slots"] = "显示背包已用格",
		["Show Total bag slots"] = "显示背包总格数",
		["Combine Counts"] = "统一计数",
		["Show only one count with all the seclected types included"] = "将已选择类型之背包的计数统一显示",
		["Show Ammo Bags Count"] = "弹药袋计数",
		["Show Soul Bags Count"] = "灵魂袋计数",
		["Show Specialty Bags Count"] = "特殊背包计数",
		["Show Specialty (profession etc) Bags Count"] = "特殊（专业等）背包计数",
		["Set Layout Bounds"]= "设置布局范围",
		["Shows a frame you can drag and size to set where the bags will be placed when Layout is automatic"] = "显示一个可以移动缩放的框体，当布局设定为自动时背包将放置在此处",
		["Lock"] = "锁定",
		["Locks the bag frames making them unmovable"] = "锁定背包框体使之不能随意移动",
		["Shrink Width"] = "收缩宽度",
		["Shrink the bag's width to fit the items contained in them"] = "按背包内物品自动收缩背包宽度",
		["Compress"] = "压缩显示",
		["Compress Multiple stacks into one item button"] = "多组物品于一格中显示",
		["Compress All"] = "所有物品压缩显示",
		["Show all items as a single button with a count on it"] = "可压缩显示的所有物品及其计数于一格中显示",
		["Compress Empty Slots"] = "未用格压缩显示",
		["Show all empty slots as a single button with a count on it"] = "所有未用格及其计数于一格中显示",
		["Compress Soul Shards"] = "灵魂碎片压缩显示",
		["Show all soul shards as a single button with a count on it"] = "所有灵魂碎片及其计数于一格中显示",
		["Compress Ammo"] = "弹药压缩显示",
		["Show all ammo as a single button with a count on it"] = "所有弹药及其计数于一格中显示",
		["Quality Colors"]= "按品质着色",
		["Color item buttons based on the quality of the item"] = "按照物品的品质给边框着色",
		["Enable"] = "允许",
		["Enable quality coloring"] = "允许按品质着色",
		["Color Threshold"] = "着色等级",
		["Only color items of this quality or above"] = "仅着色这个品质及以上的物品",
		["Color Intensity"] = "着色亮度",
		["Intensity of the quality coloring"] = "品质着色亮度",
		["Edit Bags"] = "编辑背包",
		["Edit the Bag Definitions"] = "编辑背包",
		["Edit Categories"] = "编辑分类",
		["Edit the Category Definitions"] = "编辑分类",
		["Load Profile"] = "加载配置",
		["Load a built-in profile: NOTE: ALL Custom Bags will be lost and any edited built in categories will be lost."] = "加载内置样式：注：所有自定义的背包及分类将被删除。",
		["Default"] = "默认样式",
		["A default set of bags sorting your inventory into categories"] = "默认样式：按照物品分类将其显示在各自分类块中。",
		["All in one"] = "整合样式",
		["A single bag containing your whole inventory, sorted by quality"] = "整合样式：一个整合的无分类背包，物品按品质排序。",
		["Scale"] = "缩放",
		["Scale of the bag frames"] = "缩放背包框体",
		--bagtypes
		["Backpack"] = "行囊",
		["Bag1"] = "背包1",
		["Bag2"] = "背包2",
		["Bag3"] = "背包3",
		["Bag4"] = "背包4",
		["Bank Frame"] = "银行窗口",
		["Bank Bag1"] = "银行背包1",
		["Bank Bag2"] = "银行背包2",
		["Bank Bag3"] = "银行背包3",
		["Bank Bag4"] = "银行背包4",
		["Bank Bag5"] = "银行背包5",
		["Bank Bag6"] = "银行背包6",
		["Bank Bag7"] = "银行背包7",
		["KeyRing"] = "钥匙链",
		
		--qualoty names
		["Poor"] = "粗糙",
		["Common"] = "普通",
		["Uncommon"] = "优秀",
		["Rare"] = "精良",
		["Epic"] = "史诗",
		["Legendary"] = "传说",
		["Artifact"] = "神器",
		
		["None"] = "无",
		["All"] = "所有",
		
		["Item Type"] = "物品类型",
		["Filter by Item type and sub-type as returned by GetItemInfo"] = "按照通过GetItemInfo命令获得的物品类型和子类型过滤",
		["ItemType - "] = "物品类型 - ",
		["Item Type Options"] = "物品类型选项",
		["Item Subtype"] = "物品子类型",

		["Container Type"] = "容器类型",
		["Filter by the type of container the item is in."] = "按照其内物品类型过滤容器",
		["Container : "] = "容器：",
		["Container Type Options"] = "容器类型选项",

		["Item ID"] = "物品编号",
		["Filter by ItemID, this can be a space delimited list or ids to match."] = "按照物品编号过滤。",
		["ItemIDs "] = "物品编号",
		["ItemID Options"] = "物品编号选项",
		["Item IDs (space seperated list)"] = "物品编号（以空格间隔）",
		["New"] = "新",
		["Current IDs, click to remove"] = "当前编号，点击删除。",
		
		["Filter by the bag the item is in"] = "按照背包其内物品过滤",
		["Bag "] = "背包",
		["Bag Options"] = "背包选项",
		["Ignore Empty Slots"] = "忽略未用格",
		
		["Item Name"] = "物品名称",
		["Filter by Name or partial name"] = "按照名称或部分名称过滤",
		["Name: "] = "名称：",
		["Item Name Options"] = "物品名称选项",
		["String to Match"] = "匹配字符",
		
		["PeriodicTable Set"] = "PeriodicTable项",
		["Filter by PeriodicTable Set"] = "按照PeriodicTable项过滤",
		["Periodic Table Set Options"] = "PeriodicTable项属性",
		["Set"] = "项",
		
		["Empty Slots"] = "未用格",
		["Empty bag slots"] = "背包未用格",
		
		["Ammo Bag"] = "弹药袋",
		["Items in an ammo pouch or quiver"] = "箭袋或者弹药袋内的物品",
		["Ammo Bag Slots"] = "弹药袋",
		
		["Quality"] = "品质",
		["Filter by Item Quality"] = "按照物品品质过滤",
		["Quality Options"] = "品质选项",
		["Comparison"] = "比较",
		
		["Equip Location"] = "装备位置",
		["Filter by Equip Location as returned by GetItemInfo"] = "按照通过GetItemInfo得到的装备位置过滤",
		
		["Equip Location Options"] = "装备位置选项",
		["Location"] = "位置",
		
		["Unfiltered Items"] = "未过滤物品",
		["Matches all items that arent matched by any other bag, NOTE: this should be the only rule in a category, others will be ignored"] = "所有已匹配其余背包物品之外的物品，注：这将是分类中的唯一规则，忽略其余规则。",
		["Unfiltered"] = "未过滤",
		
		["Bind"] = "绑定",
		["Filter based on if the item binds, or if it is already bound"] = "按照物品绑定类型过滤",
		["Bind *unset*"] = "无需绑定",
		["Unbound"] = "未绑定",
		["Bind Options"] = "绑定选项",
		["Bind Type"] = "绑定类型",
		["Binds on pickup"] = "拾取后绑定",
		["Binds on equip"] = "装备后绑定",
		["Binds on use"] = "使用后绑定",
		["Soulbound"] = "灵魂绑定",

		["Tooltip"] = "物品提示",
		["Filter based on text contained in its tooltip"] = "按照物品提示过滤",
		["Tooltip Options"] = "物品提示选项",
		
		["ItemID: "] = "物品编号：",
		["Item Type: "] = "物品类型：",
		["Item Subtype: "] = "物品子类型：",
		
		["Click a bag to toggle it. Shift-click to move it up. Alt-click to move it down"] = "点击开关背包。Shift-点击向上移动。Alt-点击向下移动。",
		
		["Bags"] = "背包",
		["Options"] = "选项",
		["Open With All"] = "总是打开",
		["Bank"] = "银行",
		["Sections"] = "分类块",
		["Categories"] = "分类",
		["Add Category"] = "添加分类",
		["New Section"] = "新分类块",
		["New Bag"] = "新背包",
		["Close"] = "关闭",
		["Click on an entry to open. Shift-Click to move up. Alt-Click to move down. Ctrl-Click to delete."] = "点击打开条目。Shift-点击向上移动。Alt-点击向下移动。Ctrl-点击删除。",
		["Rules"] = "规则",
		["New Rule"] = "新规则",
		["Add Rule"] = "增加规则",
		["New Category"] = "新分类",
		["Apply"] = "应用",
		["Click on an entry to open. Ctrl-Click to delete."] = "点击打开一个条目。Ctrl-点击删除。",
		
		["Editing Rule"] = "编辑规则",
		["Type"] = "类型",
		["Select a rule type to create the rule"] = "选择一个规则类型以创建规则",
		["Operation"] = "运算法则",
		["AND"] = "和",
		["OR"] = "与",
		["NOT"] = "非",
		
		["Baggins - New Bag"] = "Baggins - 新背包",
		["Baggins - New Section"] = "Baggins - 新分类块",
		["Baggins - New Category"] = "Baggins - 新分类",
		["Accept"] = "接受",
		["Cancel"] = "取消",
		
		["Are you sure you want to delete this Bag? this cannot be undone"] = "你确认要删除这个背包？ 这是个不可恢复的操作",
		["Are you sure you want to delete this Section? this cannot be undone"] = "你确认要删除这个分类块？ 这是个不可恢复的操作",
		["Are you sure you want to remove this Category? this cannot be undone"] = "你确认要删除这个分类？ 这是个不可恢复的操作",
		["Are you sure you want to remove this Rule? this cannot be undone"] = "你确认要删除这个规则？ 这是个不可恢复的操作",
		["Delete"] = "删除",
		["Cancel"] = "取消",
		
		["That category is in use by one or more bags, you cannot delete it."] = "这个分类被一个或多个背包使用，不能被删除。",
		["A category with that name already exists."] = "同名分类已经存在。",
		
		["Drag to Move\nRight-Click to Close"] = "点击拖动\n右键关闭",
		["Drag to Size"] = "缩放拖动",
		
		["Previous "] = "向前",
		["Next "] = "向后",
		
		["All In One"] = "整合背包",
		["Bank All In One"] = "整合银行",
		["Bank Bags"] = "银行背包",
		
		["Equipment"] = "装备",
		["Weapons"] = "武器",
		["Quest Items"] = "任务物品",
		["Consumables"] = "消耗品",
		["Water"] = "饮料",
		["Food"] = "食物",
		["FirstAid"] = "急救",
		["Potions"] = "药水",
		["Scrolls"] = "卷轴",
		["Misc"] = "其它",
		["Misc Consumables"] = "其它消耗品",

		["Mats"] = "基础材料",
		["Tradeskill Mats"] = "[商]基础材料",
		["Gathered"] = "采集",
		["BankBags"] = "[银]背包",
		["Ammo"] = "弹药",
		["AmmoBag"] = "弹药袋",
		["SoulShards"] = "灵魂碎片",
		["SoulBag"] = "灵魂袋",
		["Other"] = "其它",
		["Trash"] = "垃圾",
		["TrashEquip"] = "垃圾装备",
		["Empty"] = "未用格",
		["Bank Equipment"] = "[银]装备",
		["Bank Quest"] = "[银]任务",
		["Bank Consumables"] = "[银]消耗品",
		["Bank Trade Goods"] = "[银]商品",
		["Bank Other"] = "[银]其它",
		
		["Add To Category"] = "添加到分类",
		["Exclude From Category"] = "从分类中删除",
		["Item Info"] = "物品信息",
		["Use"] = "使用",
			["Use/equip the item rather than bank/sell it"] = "使用/装备这件物品而不是放银行/出售",
		["Quality: "] = "品质：",
		["Level: "] = "等级：",
		["MinLevel: "] = "最小等级：",
		["Stack Size: "] = "堆叠数量：",
		["Equip Location: "] = "装备位置：",
		["Periodic Table Sets"] = "PeriodicTable项",
		
		["Highlight New Items"] = "高亮新物品",
		["Add *New* to new items, *+++* to items that you have gained more of."] = "在新物品上增加*新*，在获得了更多的物品上增加*+++*",
		["Reset New Items"] = "重置新物品",
		["Resets the new items highlights."] = "重置新物品高亮",
		["*New*"] = "*新*",
		
		["Hide Duplicate Items"] = "隐藏重复物品的范围",
		["Prevents items from appearing in more than one section/bag."] = "阻止物品出现在超过一个的分类块/背包中",
		
		["Optimize Section Layout"] = "优化分类块布局",
		["Change order and layout of sections in order to save display space."] = "调整分类块的布局和顺序使之更节省屏幕",
		
		["All In One Sorted"]= "整合-分类块样式",
		["A single bag containing your whole inventory, sorted into categories"]= "整合-分类块样式：一个整合的背包，按物品分类将其显示在各自分类块中。",
		
		["Compress Stackable Items"]= "可堆叠物品压缩显示",
		["Show stackable items as a single button with a count on it"]= "所有可堆叠物品及其计数于一格中显示",

		["Appearance and layout"]= "外观和布局",
		["Bags"]= "背包",
		["Bag display and layout settings"]= "背包显示和布局设置",
		["Layout Type"]= "布局类型",
		["Sets how all bags are laid out on screen."]= "设置如何在屏幕上排列背包",
		["Shrink bag title"]= "缩短背包标题",
		["Mangle bag title to fit to content width"]= "使背包标题适应内容宽度",
		["Sections"]= "分类块",
		["Bag sections display and layout settings."]= "分类块显示和布局设置",
		["Items"]= "物品",
		["Item display settings"]= "物品显示设置",
		["Bag Skin"]= "背包皮肤",
		["Select bag skin"]= "选择背包皮肤",
		
		["Compress bag contents"]= "压缩背包",
		["Split %d"]= "分离%d",
		["Split_tooltip"] = "点击按照设定分离物品\n并且在未用格中自动排列。\n\n按住shift仅拣取。",
		
		["PT3 LoD Modules"] = "PT3 模块",
		["Choose PT3 LoD Modules to load at startup, Will load immediately when checked"] = "选择开始时加载的PT3模块，选择后将立即加载",
		["Load %s at Startup"] = "开始时加载%s",
		
		["Disable Compression Temporarily"] = "临时禁用压缩",
		["Disabled Item Compression until the bags are closed."] = "在背包关闭前禁用物品压缩",
		
		["Always Resort"] = "总是重排",
		["Keeps Items sorted always, this will cause items to jump around when selling etc."] = "始终保持物品排列，在出售时物品将会跑来跑去",
		
		["Force Full Refresh"] = "全部刷新",
		["Forces a Full Refresh of item sorting"] = "刷新所有物品类别",
		
		["Override Default Bags"] = "取代默认背包",
		["Baggins will open instead of the default bags"] = "Baggins将会取代默认背包",
		["Sort New First"] = "新物品在前",
		["Sorts New Items to the beginning of sections"] = "在分类块的开始位置排列新物品",
		["New Items"] = "新物品",
		
		["Items that match another category"] = "用于匹配另一个分类",
		["Category Options"] = "分类选项",
		["Category"] = ">分类",

		["Layout Anchor"] = "布局锚点",
		["Sets which corner of the layout bounds the bags will be anchored to."] = "设定背包定位到布局框的角落。",
		["Top Right"] = "右上",
		["Top Left"] = "左上",
		["Bottom Right"] = "右下",
		["Bottom Left"] = "左下",

		["Show Money On Bag"] = "在背包显示金钱",
		["Which Bag to Show Money On"] = "选择显示金钱的背包",

		["User Defined"] = "自定义配置",
		["Load a User Defined Profile"] = "加载一个自定义配置",
		["Save Profile"] = "保存配置",
		["Save a User Defined Profile"] = "保存一个自定义配置",
		["New"] = "新",
		["Create a new Profile"] = "创建一个新配置",
		["Delete Profile"] = "删除配置",
		["Delete a User Defined Profile"] = "删除一个自定义配置",
		["Save"] = "保存",
		["Load"] = "加载",
		["Delete"] = "删除",

		["Config Window"] = "设置窗口",
		["Opens the Waterfall Config window"] = "打开使用Waterfall的图形设置窗口",
		["Bag/Category Config"] = "设置背包和分类",
		["Opens the Waterfall Config window"] = "打开使用Waterfall的图形设置窗口",
		["Rename / Reorder"] = "重命名/重排",
		["From Profile"] = "从配置",
		["User"] = "玩家",
		["Copy From"] = "复制自：",
		["Edit"] = "编辑",
		["Automatically open at auction house"] = "在拍卖行自动打开",
		["Create"] = "创建",
		["Bag Priority"] = "背包优先级",
		["Section Priority"] = "分类块优先级",
		["Allow Duplicates"] = "允许显示重复物品",
		["Import Sections From"] = "分类块导入自：",
	}
end)
