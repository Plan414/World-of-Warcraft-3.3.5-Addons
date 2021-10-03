local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("deDE", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },

	["Auto Loot"] = "Automatisches Looten",
	["AutoLootMsg"] = "Wenn die Option eingeschatet ist, wird Fishing Ace! automatisch Looten w\195\164hrend du angelst.",

	["Auto Lures"] = "Automatischer K\195\182der",
	["AutoLureMsg"] = "Wenn die Option eingeschaltet ist, wendet Fishing Ace! einen K\195\182der an, falls Du einen ben\195\182tigst, anstatt die Angel auszuwerfen.",

	["Enhance Sounds"] = "Verst\195\164rke Kl\195\164nge",
	["EnhanceSoundsMsg"] = "Wenn die Option eingeschaltet ist, wird Fishing Ace! die Umgebungskl\195\164nge verst\195\164rken w\195\164hrend du angelst.",

	["Use Action"] = "Benutze Aktion",  -- Needs localization
	["UseActionMsg"] = "Wenn aktiviert, wird Fishing Ace! einen Actionstaste finden mit der gezaubert werden kann.",

	["LureSkill"] = "Benutzen: Bei Anwendung auf Eure Angelrute wird die F\195\164higkeit 'Angeln' %d Minuten lang um (%d) Punkte erh\195\182ht.",
	
} end)