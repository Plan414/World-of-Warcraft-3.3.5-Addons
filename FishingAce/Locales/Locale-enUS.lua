local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("enUS", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },
     
	["Auto Loot"] = true,
	["AutoLootMsg"] = "If set, Fishing Ace! will turn Auto Loot on while you're fishing.",

	["Auto Lures"] = true,
	["AutoLureMsg"] = "If set, Fishing Ace! will add a lure when you need one, instead of casting.",

	["Enhance Sounds"] = true,
	["EnhanceSoundsMsg"] = "If set, Fishing Ace! will enhance the ambient sound while you're fishing.",

	["Use Action"] = true,
	["UseActionMsg"] = "If set, Fishing Ace! will find an action button to cast with.",

	["LureSkill"] = "Use: When applied to your fishing pole, increases Fishing by (%d) for %d minutes.",
	
} end)
