local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("zhTW", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },

	["Auto Loot"] = "自動拾取",
	["AutoLootMsg"] = "如果設定，在釣魚時會將自動拾取物品的選項暫時打開，而不會出現拾取物品視窗。",

	["Auto Lures"] = "自動加上誘餌",
	["AutoLureMsg"] = "如果設定，在釣魚時會自動在需要時上釣餌。",

	["Enhance Sounds"] = "加強音效",
	["EnhanceSoundsMsg"] = "如果設定，在釣魚時會加強魚上鉤的音效。",

	["Use Action"] = "使用按鈕",
	["UseActionMsg"] = "如果設定，會在動作條上使用釣魚按鈕。",

	["LureSkill"] = "使用:裝備在魚竿上之後，可以使你的釣魚技能提高(%d)點，持續%d分鐘。",

} end)
