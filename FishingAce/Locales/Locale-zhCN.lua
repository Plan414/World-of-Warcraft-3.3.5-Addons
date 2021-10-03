	--Chinese Local : CWDG Translation Team 昏睡墨鱼 (Thomas Mo)
	--$Rev: 683 $
	--$Date: 2007-06-16 19:27:28 +0800 (六, 16 六月 2007) $

local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("zhCN", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },

	["Auto Loot"] = "自动拾取",
	["AutoLootMsg"] = "设置后，Fishing Ace! 将在你钓鱼时打开自动拾取。",

	["Auto Lures"] = "自动上饵",
	["AutoLureMsg"] = "设置后，Fishing Ace! 将在钓鱼前尽可能上饵。",

	["Enhance Sounds"] = "声音增强",
	["EnhanceSoundsMsg"] = "设置后，Fishing Ace! 将增强钓鱼时鱼上钩的提示音。",

	["Use Action"] = "使用动作", 
	["UseActionMsg"] = "设置后，Fishing Ace! 将作出一个动作。",

	["LureSkill"] = "使用：应用于钓竿时，提升钓鱼技能(%d)点，持续%d分钟。",
	
} end)