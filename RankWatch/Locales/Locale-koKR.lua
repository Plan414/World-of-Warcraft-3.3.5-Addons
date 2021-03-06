--
-- To translate, go to http://wow.curseforge.com/addons/rankwatch/localization/koKR/
--
local L = LibStub("AceLocale-3.0"):NewLocale("RankWatch", "koKR", false);
if not L then return end

L["About"] = "정보"
L["ADD_BOILERPLATE"] = "RankWatch가 각 플레이어에게 첫 귓속말을 보낼 때 짧은 설명을 함께 보냅니다."
L["ALREADY_NOTIFIED"] = "%s님에게 %s의 하위 주문/스킬 알림 귓속말을 보내지 않습니다. (%s님이 먼저 귓속말을 보냈습니다.)"
L["ANY_LEVEL"] = "모든 레벨의 플레이어"
L["DATE_FORMAT"] = "%y/%m/%d %H:%M:%S"
L["IGNORED_PLAYERS"] = "RankWatch는 아래 목록의 플레이어가 시전하는 하위 주문/스킬을 무시합니다."
L["INVALID_COMMAND"] = "잘못된 명령어 - 도움이 필요하면 '/rankwatch help' 사용"
L["LEVEL_80_ONLY"] = "오직 레벨 80의 플레이어"
L["LOCAL_SPELL_LOW"] = "RankWatch:%s 가 %s 랭크 %d 를 사용했습니다. (%d 레벨에서 최고 랭크는 %d) - 시간 %s"
L["LOCAL_SPELL_REPLACED"] = "RankWatch:%s 가 %s 랭크 %d 를 사용했습니다. (replaced at level %d by %s Rank %d) at %s." -- Needs review
L["NO_BOILERPLATE"] = "RankWatch가 각 플레이어에게 첫 귓속말을 보낼 때 짧은 설명을 보내지 않습니다."
L["NOONE_IGNORED"] = "RankWatch에서 무시하도록 한 플레이어가 없습니다."
L["NOREPORT_DOWNRANKED"] = "RankWatch가 더 이상 하위 스킬/주문을 보고하지 않습니다."
L["NOT_REPORT_INTERVAL"] = "RankWatch는 어떤 플레이어 어떤 주문/스킬이든 %초 이상 보고 하지 않습니다."
L["ON_IGNORE_LIST"] = "%님에게 %에 대한 귓속말을 보내지 않습니다. (무시 목록에 있음: %s)"
L["PLAYER_ALREADY_IGNORED"] = "RankWatch는 이미 %s의 스킬/주문을 무시하고 있습니다."
L["PLAYER_ALREADY_WATCHED"] = "RankWatch는 이미 %s님의 주문/스킬을 지켜보고 있습니다."
L["PLAYER_NOW_IGNORED"] = "RankWatch가 %s 님의 주문/스킬을 무시하도록 합니다."
L["PLAYER_NOW_WATCHED"] = "RankWatch는 %s님의 주문/스킬을 지켜볼것입니다."
L["RANKWATCH_CHANNEL_NOWHISPERS"] = "RankWatch는 어떤 플레이어에게도 자동으로 귓속말을 보내지 않을것입니다."
L["RANKWATCH_CHANNEL_PARTY"] = "RankWatch가 파티/레이드/전장 채팅중 %s를 자동으로 적절한 곳으로 보고할 것입니다."
L["RANKWATCH_CHANNEL_SAY"] = "RankWatch가 일반 대화로 스킬 정보를 보고합니다."
L["RANKWATCH_CHANNEL_WHISPER"] = "RankWatch가 귓속말로 스킬 정보를 보고합니다."
L["RANKWATCH_CHANNEL_WHISPER_EXPLAIN"] = "RankWatch가 귓속말로 간단하게 스킬 정보를 보고합니다."
L["RANKWATCH_CHANNEL_WHISPER_NOEXPLAIN"] = "RankWatch는 첫번째로 발견한 스킬 정보를 귓속말하지 않을 것입니다."
L["RANKWATCH_DISABLED"] = "RankWatch 비활성"
L["RANKWATCH_ENABLED"] = "RankWatch 활성"
L["RANKWATCH_REPORT_LINE_LOW"] = "%s rank %d (max rank at level %d is %d) at %s" -- Requires localization
L["RANKWATCH_REPORT_LINE_REPLACED"] = "%s rank %d (replaced at level %d by %s rank %d) at %s" -- Requires localization
L["RANKWATCH_REPORT_NONE_SEEN"] = "RankWatch는 아직 저레벨 스펠을 못 찾았습니다."
L["RANKWATCH_SELF_ONLY"] = "RankWatch는 자신의 낮은 스킬만 보고 할 것입니다."
L["RANKWATCH_WELCOME_DISABLED"] = "RankWatch %s 사용 중단. 다시 사용하려면 '/rankwatch enable' 입력하세요."
L["RANKWATCH_WELCOME_ENABLED"] = "RankWatch %s 사용.  추가적인 정보가 필요하면 '/rankwatch' 입력하세요."
L["REPORT_ALL_LEVELS"] = "RankWatch가 모든 레벨에 대해서 보고합니다."
L["REPORT_DOWNRANKED"] = "RankWatch가 이제 하위 스킬/주문을 보고 할 것입니다."
L["REPORT_GROUP_CHAT"] = "RankWatch가 파티/레이드/전장 채팅중 자동으로 적절한 곳으로 보고할 것입니다."
L["REPORT_ONLY_80"] = "RankWatch가 하위 스킬/주문을 사용하는 80 레벨의 플레이어만 보고 할 것입니다."
L["REPORT_ONLY_SELF"] = "RankWatch는 하위 주문/스킬 사용에 관한 정보를 기본 창에만 출력할것입니다."
L["REPORT_SAY"] = "RankWatch는 하위 주문/스킬 사용에 관한 정보를 '일반' 대화창에 출력할것입니다."
L["REPORT_SEEN"] = "RankWatch가 발견한 하위 주문/스킬은 다음과 같습니다."
L["REPORT_WHISPER"] = "RankWatch는 하위 주문/스킬을 사용하는 플레이어에게 귓속말을 보낼것입니다."
L["SEEN_LIST_CLEARED"] = "RankWatch의 최근에 발견한 하위 주문/스킬 사용에 관한 목록이 삭제되었습니다."
L["__URL__"] = "http://wow.curse.com/downloads/wow-addons/details/rankwatch.aspx"
L["USAGE_01"] = "RankWatch %s 도움말:"
L["USAGE_02"] = "    /rankwatch enable          -RankWatch 켜기"
L["USAGE_03"] = "   /rankwatch disable         - RankWatch 끄기"
L["USAGE_04"] = "    /rankwatch report          - 하위 단계의 스킬/주문 사용 리포트"
L["USAGE_05"] = " \009/rankwatch clear           - 하위 단계 스킬/주문 사용 리스트 삭제"
L["USAGE_06"] = "    /rankwatch 80              - 80레벨 플레이어만 하위 스킬/주문에 대한 보고를 합니다."
L["USAGE_07"] = "   /rankwatch all             -모든 레벨 플레이어의 하위 스킬/주문에 대한 보고를 합니다."
L["USAGE_08"] = "    /rankwatch whisper         - 하위 스킬/주문을 사용하는 플레이어에게 귓속말을 보냅니다. (무작위 던전에선 사용되지 않습니다.)"
L["USAGE_09"] = "    /rankwatch party           - 파티/공격대/전장에서 하위 스킬/주문을 사용한 플레이어에 대한 보고를 합니다."
L["USAGE_10"] = "   /rankwatch say             - 하위 스킬/주문을 사용한 플레이어를 일반 채팅으로 보고합니다."
L["USAGE_11"] = "    /rankwatch none            -하위 스킬/주문을 사용한 플레이어를 오직 당신만 볼 수 있도록 합니다."
L["USAGE_11a"] = "   /rankwatch self            - 자신의 낮은 스킬만 보고합니다."
L["USAGE_12"] = "    /rankwatch explain enable  - 첫번째 귓속말에 짧은 설명을 포함합니다."
L["USAGE_13"] = "    /rankwatch explain disable - 첫번째 귓속말에 짧은 설명을 포함하지 않습니다."
L["USAGE_14"] = "    /rankwatch interval <seconds> - 같은 사람에게 같은 스킬에 대한 귓속말을 보내는 최소 시간"
L["USAGE_15"] = "    /rankwatch ignore          - 무시 리스트 플레이어 보기"
L["USAGE_16"] = "    /rankwatch ignore <name>   - 해당 플레이어에 의한 시전을 보고하지 않음"
L["USAGE_17"] = "    /rankwatch watch <name>   - 해당 플레이어에 의한 시전을 무시하지 않음"
L["Version"] = "버전"
L["WHISPER_BOILERPLATE_PART1"] = "당신께서 %s 스킬의 %d 등급을 배우셨다면 지금 액션바에 지정된 스킬이 낮은 등급의 스킬로 지정되어 있는것 같습니다. 듀얼특성의 버그로 이와 같은 현상이 발생할 수 있으니 확인하세요."
L["WHISPER_BOILERPLATE_PART2"] = "만약 당신께서 낮은 등급의 주문을 사용하려는 이유를 설명해주신 다면, 저는 RankWatch를 통해 절대 당신에게 메세지를 보내지 않도록 하겠습니다."
L["WHISPER_SPELL_LOW_WARNING"] = "[RankWatch] %s 님 께서 사용하신 %s스킬은 %d등급입니다. 이 스킬의 최고 등급은 %d레벨에 배우는 %d등급입니다."
L["WHISPER_SPELL_REPLACED_WARNING"] = "[RankWatch] %s used %s Rank %d, which is replaced at level %d by %s Rank %d." -- Requires localization

