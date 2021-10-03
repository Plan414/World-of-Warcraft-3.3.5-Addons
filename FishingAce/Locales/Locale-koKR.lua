local L = AceLibrary("AceLocale-2.2"):new("FishingAce")

L:RegisterTranslations("koKR", function() return {
	["Slash-Commands"] = { "/fishingace", "/fa" },

	["Auto Loot"] = "자동 획득",
	["AutoLootMsg"] = "설정시, Fishing Ace!는 당신이 낚시를 하는 동안 자동으로 전리품을 획득하도록 합니다.",

	["Auto Lures"] = "자동 미끼",
	["AutoLureMsg"] = "설정시, Fishing Ace!는 당신이 낚시를 하는 동안 미끼가 필요할때 시전합니다.",

	["Enhance Sounds"] = "소리 조절",
	["EnhanceSoundsMsg"] = "설정시, Fishing Ace!는 낚시를 하는 동안 환경 소리 음량을 조절합니다.",

	["Use Action"] = "행동 사용",
	["UseActionMsg"] = "설정시, Fishing Ace!는 시전할 행동 단축키을 찾습니다.",

	["LureSkill"] = "사용 효과: 낚싯대에 사용하면 %d분 동안 낚시 숙련도가 (%d)만큼 증가합니다.",
	
} end)

