if ( GetLocale() ~= "zhTW" ) then return end

local addon, ns = ...
ns.L = {
	-- Core Globals
	["Combat Fade"] = "戰鬥中隱藏",
	["Class Colored"] = "職業顏色",
	["Global Font Size"] = "全域字型大小",
	["ProfDesc"] = "建立一個新的或是複製設定檔，設為角色預設設定",
	["ProfResDesc"] = "重置設定檔",
	["ProfNew"] = "New",
	["ProfReset"] = "Reset",
	["ProfCurrent"] = "Current",
	["ProfCopy"] = "Copy",
	["ProfDel"] = "Delete",
	["/sldt"] = "/sldt",
	["Command List"] = "命令列表",
	["config"] = "config",
	["Toggle Configuration Mode"] = "組態模式切換",
	["Configuration Mode"] = "組態模式",
	["active"] = "active",
	["inactive"] = "inactive",
	["global"] = "global",
	["Open SLDataText Global Menu"] = "開啟SLDataText全域選單",
	["<module>"] = "<module>",
	["Open Module Option Menu"] = "開啟模組設置選單",
	["Loaded Modules"] = "Loaded Modules",
	["TTScale"] = "SL提示訊息縮放",
	
	-- Common
	["Enabled"] = "啟用",
	["Global Font"] = "全域字型",
	["Outline"] = "外框線",
	["Force Shown"] = "總是顯示",
	["Tooltip On"] = "開啟提示資訊",
	["Font Size"] = "字型大小",
	["Font"] = "字型",
	["Justify"] = "對齊",
	["Parent"] = "依附",
	["Anchor"] = "錨點",
	["X Offset"] = "水平位移",
	["Y Offset"] = "垂直位移",
	["Frame Strata"] = "框架層級",
	["Update Interval"] = "更新頻率",
	["On"] = "開啟",
	["Off"] = "關閉",
	["Prefix"] = "Prefix",
	["Prefix Text"] = "Prefix Text",
	["Suffix"] = "Suffix",
	["Suffix Text"] = "Suffix Text",
	["Left-Click"] = "左鍵點擊",
	["Right-Click"] = "右鍵點擊",
	["Show Icon"] = "顯示小圖示",
	["Show Text"] = "顯示文字",
	["Text Display"] = "文字格式",
	
	-- Armor Module
	["Armor"] = "護甲",
	["All Items"] = "所有物品",
	["Auto Repair"] = "自動修理",
	["Use Guild Bank"] = "Use Guild Bank",
	["Armor"] = "護甲",
	["AutoRepairLine"] = "修理物品花費",
	["GFAutoRepairLine"] = "修理物品花費 (Guild Funds)",
	["ArmorTextDesc"] = "[Dur] = 目前的耐久值",
	
	-- Bag Module
	["Bag Info"] = "背包資訊",
	["Space Used"] = "已使用",
	["Space Avail"] = "總空間",
	["Space Left"] = "尚餘",
	["AutoSell Junk"] = "自動販賣垃圾",
	["JunkSoldLine"] = "垃圾販售所得",
	["Toggle Bags"] = "開啟背包",
	["BagTextDesc"] = "[T] = 總計, [R] = 尚餘, [U] = 已使用",
	
	-- Clock Module
	["Toggle Calendar"] = "行事曆",
	["Toggle Time Manager"] = "計時器",
	["Queued for:"] = "佇列：",
	["Realm Time"] = "伺服器時間",
	["24 Hour"] = "24小時制",
	["PvP Info"] = "PvP資訊",
	["Time String"] = "時間文字格式",
	["ClockDesc"] = "造訪 http://www.lua.org/pil/22.1.html 取得完整時間標籤，如果時間標籤不是起始字串請關閉時間校準",
	["CorrHour"] = "時間校準",
	
	-- Coords Module
	["Precision"] = "精準度",
	
	-- Currency Module
	["Currency"] = "兌換通貨",
	["No Currency"] = "無兌換通貨",
	["Click to set display currency."] = "點擊設定兌換通貨顯示",
	["Display Currency"] = "顯示兌換通貨",
	
	-- Exp Module
	["Max Level Hide"] = "封頂後隱藏",
	["Exp"] = "經驗值",
	["ExpTextDesc"] = "[Cur] = 目前經驗, [Max] = 總經驗, [Rem] = 尚餘經驗, [Per] = 目前經驗百分比, [PerR] = 尚餘經驗百分比, [R] = 充分休息經驗, [RP] = 充分休息經驗百分比",
	
	-- FPS Module
	["fps"] = "fps",
	["FPSTextDesc"] = "[F] = 目前FPS",
	
	-- Gold Module
	["'s"] = "的",
	["Wallet"] = "錢包",
	["Current"] = "目前",
	["Session Start"] = "初始",
	["Session Earned"] = "所得",
	["Server Gold"] = "伺服器金額",
	["Horde"] = "部落",
	["Alliance"] = "聯盟",
	["Total Gold"] = "總金額",
	["Display Style"] = "顯示細節",
	["Alt Money"] = "分身金錢",
	["ResetData"] = "Reset Data",
	
	-- Latency Module
	["Latency"] = "延遲",
	["Bandwidth In"] = "下載頻寬",
	["Bandwidth Out"] = "上傳頻寬",
	["Latency (Home)"] = "延遲 (住家)",
	["Latency (World)"] = "延遲 (世界)",
	["ms"] = "ms",
	["LagTextDesc"] = "標籤說明: [L] = 目前延遲",
	
	-- Mail Module
	["No Mail"] = "無新郵件",
	["Mail!"] = "新郵件!",
	["AH Alert!"] = "拍賣場通知!",
	["Play Sounds"] = "播放音效",
	
	-- Memory Module
	["AddOn Memory"] = "插件記憶體監視",
	["Showing Top 15 AddOns"] = "顯示消耗最多記憶體的前15名",
	["Total AddOn Memory"] = "插件消耗記憶體",
	["Total UI Memory Usage"] = "使用者介面消耗記憶體",
	["Hover"] = "滑鼠懸停",
	["Show only top AddOns"] = "只顯示消耗排名前15",
	["Alt+Hover"] = "Alt+滑鼠懸停",
	["Show all AddOns"] = "顯示所有插件",
	["Collect Garbage"] = "回收記憶體",
	["mb"] = "mb",
	["MemTextDesc"] = "[MA] = 插件消耗記憶體, [MT] = 總記憶體",
	
	-- Reputation Module
	["Reputation"] = "聲望",
	["No Reputation"] = "無聲望",
	["Click to set display reputation."] = "點擊設定聲望顯示",
	["Display Reputation"] = "顯示聲望",
	["Hated"] = "仇恨",
	["Hostile"] = "敵對",
	["Unfriendly"] = "不友好",
	["Neutral"] = "中立",
	["Friendly"] = "友好",
	["Honored"] = "尊敬",
	["Revered"] = "崇敬",
	["Exalted"] = "崇拜",
}