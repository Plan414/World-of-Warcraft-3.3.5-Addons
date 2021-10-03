local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("frFR", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },

	["Auto Loot"] = "Ramassage automatique",
	["AutoLootMsg"] = "Active le ramassage automatique lorsque vous p\195\170chez.",

	["Auto Lures"] = "App\195\162t automatique",
	["AutoLureMsg"] = "Applique automatiquement un app\195\162t lors c'est n\195\169cessaire.",

	["Enhance Sounds"] = "R\195\169glages sonores optimis\195\169s",
	["EnhanceSoundsMsg"] = "Modifie les r\195\169glages sonores pour faciliter la p\195\170che.",

	["Use Action"] = "Use Action",  -- Needs localization
	["UseActionMsg"] = "If set, Fishing Ace! will find an action button to cast with.",

	["LureSkill"] = "Utiliser: Attach\195\169 \195\160 votre canne \195\160 p\195\170che, il augmente votre comp\195\169tence de p\195\170che de (%d) points pendant %d minutes.",
	
} end)
