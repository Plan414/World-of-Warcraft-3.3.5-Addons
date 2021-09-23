--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": Korean

!! Make sure to keep this saved as UTF-8 format !!
]]

--[[>> still needs translating]]

if FW.CLASS == "WARLOCK" then
	local FWL = FW.L;
	
	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

	-- French
	if GetLocale() == "frFR" then
		FWL.SUMMON_START = "Summoning Start";
		FWL.SUMMON_CANCEL = "Summoning Cancel";
		FWL.SUMMON_PORTAL = "Summoning Portal Open";
		FWL.SUMMON_FAILED = "Summoning Failed";
		FWL.SUMMON_SUCCESS = "Summoning Successfull";

		FWL.SUMMON_START_W = "Summoning Start whisper";	
		FWL.SUMMON_CANCEL_W = "Summoning Cancel whisper";	
		FWL.SUMMON_FAILED_W = "Summoning Failed whisper";

		FWL.SUMMONING = "Summoning";
		FWL.SOULTONE_START = "Soulstone cast Start";
		FWL.SOULTONE_CANCEL = "Soulstone cast Cancel";
		FWL.SOULTONE_SUCCESS = "Soulstone cast Success";

		FWL.SOULSTONE_NORMAL = "Soulstone";

		FWL.SOULTONE_START_W = "Soulstone cast Start whisper";
		FWL.SOULTONE_CANCEL_W = "Soulstone cast Cancel whisper";
		FWL.SOULTONE_SUCCESS_W = "Soulstone cast Success whisper";

		FWL.SEDUCE_START = "Seduce cast Start";
		FWL.SEDUCE_SUCCESS = "Seduce cast Success";
		FWL.SEDUCE_FAILED = "Seduce cast Failed";
		FWL.SEDUCE_BREAK = "Seduce Break";
		FWL.SEDUCE_FADE = "Seduce Fade";
		
		FWL.FEAR_BREAK = "Fear Break";
		FWL.FEAR_FADE = "Fear Fade";
		FWL.BANISH_BREAK = "Banish Break";
		FWL.BANISH_FADE = "Banish Fade";
		FWL.ENSLAVE_BREAK = "Enslave Break";
		FWL.ENSLAVE_FADE = "Enslave Fade";

		FWL.SPELL_LOCK_SUCCESS = "Spell Lock cast Success";
		FWL.SPELL_LOCK_FAILED = "Spell Lock cast Failed";
		FWL.SPELL_LOCK_READY = "Spell Lock Ready";
		
		FWL.DEVOUR_MAGIC_SUCCESS = "Devour Magic cast Success";
		FWL.DEVOUR_MAGIC_FAILED = "Devour Magic cast Failed";
		FWL.DEVOUR_MAGIC_READY = "Devour Magic Ready";
		
		FWL.BLOOD_PACT = "Blood Pact";
		FWL.BLOOD_PACT_ON = "Blood Pact on";
		FWL.BLOOD_PACT_GAIN = "Blood Pact gain";
		FWL.BLOOD_PACT_LOSS = "Blood Pact loss";
		FWL.BLOOD_PACT_TT = "Enable BLood Pact messages. You can set this to any classes, names and/or 'self' or 'all', so it will only show gains/losses for these players in your party.";

		FWL._GAINED_BLOOD_PACT = "%s gained Blood Pact.";
		FWL._LOST_BLOOD_PACT = "%s lost Blood Pact.";

		FWL.DELAY_PET_TARGET = "Delay pet target";
	
		FWL.RITUAL_OF_DOOM = "Ritual of Doom";
	
	-- Russian
	elseif GetLocale() == "ruRU" then

		FWL.SUMMON_START = "Призывание начато";
		FWL.SUMMON_CANCEL = "Призывание отменено";
		FWL.SUMMON_PORTAL = "Открыт портал Призывания";
		FWL.SUMMON_FAILED = "Призывание неудачно";
		FWL.SUMMON_SUCCESS = "Призывание успешно";

		FWL.SUMMON_START_W = "Шепот начала Призывания";	
		FWL.SUMMON_CANCEL_W = "Шепот отмены Призывания";	
		FWL.SUMMON_FAILED_W = "Шепот неудачи Призывания";

		FWL.SUMMONING = "Призывание";
		FWL.SOULTONE_START = "Чтение Камня души начато";
		FWL.SOULTONE_CANCEL = "Чтение Камня души отменено";
		FWL.SOULTONE_SUCCESS = "Чтение Камня души успешно";

		FWL.SOULSTONE_NORMAL = "Камень души";

		FWL.SOULTONE_START_W = "Шепот начала чтения Камня души";
		FWL.SOULTONE_CANCEL_W = "Шепот отмены чтения Камня души";
		FWL.SOULTONE_SUCCESS_W = "Шепот успеха чтения Камня души";

		FWL.SEDUCE_START = "Соблазнение начато";
		FWL.SEDUCE_SUCCESS = "Соблазнение успешно";
		FWL.SEDUCE_FAILED = "Соблазнение неудачно";
		FWL.SEDUCE_BREAK = "Соблазнение прервано";
		FWL.SEDUCE_FADE = "Соблазнение рассеивается";
		
		FWL.FEAR_BREAK = "Страх прерван";
		FWL.FEAR_FADE = "Страх рассеивается";
		FWL.BANISH_BREAK = "Изгнание прервано";
		FWL.BANISH_FADE = "Изгнание рассеивается";
		FWL.ENSLAVE_BREAK = "Порабощение прервано";
		FWL.ENSLAVE_FADE = "Порабощение рассеивается";

		FWL.SPELL_LOCK_SUCCESS = "Запрет Чар прочитан успешно";
		FWL.SPELL_LOCK_FAILED = "Запрет чар прочитан неудачно";
		FWL.SPELL_LOCK_READY = "Запрет чар готов";
		
		FWL.DEVOUR_MAGIC_SUCCESS = "Пожирание магии прочитано успешно";
		FWL.DEVOUR_MAGIC_FAILED = "Пожирание магии прочитано неудачно";
		FWL.DEVOUR_MAGIC_READY = "Пожиравние магии готово";
		
		FWL.BLOOD_PACT = "Кровавый союз";
		FWL.BLOOD_PACT_ON = "Кровавый союз включен";
		FWL.BLOOD_PACT_GAIN = "Кровавый союз получен";
		FWL.BLOOD_PACT_LOSS = "Кровавый союз потерян";
		FWL.BLOOD_PACT_TT = "Включить сообщения о Кровавом союзе. Вы можете задать это для любого класса, имен и/или для себя ('self') или всех ('all'), так что он будет показывать получение/потери только для указанных игроков в вашей группе.";

		FWL._GAINED_BLOOD_PACT = "%s получил Кровавый союз.";
		FWL._LOST_BLOOD_PACT = "%s потерял Кровавый союз.";

		FWL.DELAY_PET_TARGET = "Задержка цели прислужника";

--[[>>]]FWL.RITUAL_OF_DOOM = "Ritual of Doom";
		
	-- simple chinese
	elseif GetLocale() == "zhCN" then

		FWL.SUMMON_START = "召唤开始";
		FWL.SUMMON_CANCEL = "召唤取消";
		FWL.SUMMON_PORTAL = "时空门打开";
		FWL.SUMMON_FAILED = "召唤失败";
		FWL.SUMMON_SUCCESS = "召唤成功";

		FWL.SUMMON_START_W = "召唤开始M语";	
		FWL.SUMMON_CANCEL_W = "召唤取消M语";	
		FWL.SUMMON_FAILED_W = "召唤失败M语";

		FWL.SUMMONING = "召唤";
		FWL.SOULTONE_START = "灵魂石开始绑定";
		FWL.SOULTONE_CANCEL = "灵魂石取消绑定";
		FWL.SOULTONE_SUCCESS = "灵魂石成功绑定";

		FWL.SOULSTONE_NORMAL = "灵魂石";

		FWL.SOULTONE_START_W = "灵魂石开始绑定M语";
		FWL.SOULTONE_CANCEL_W = "灵魂石取消绑定M语";
		FWL.SOULTONE_SUCCESS_W = "灵魂石成功绑定M语";

		FWL.SEDUCE_START = "诱惑开始施放";
		FWL.SEDUCE_SUCCESS = "成功诱惑";
		FWL.SEDUCE_FAILED = "诱惑释放失败";
		FWL.SEDUCE_BREAK = "诱惑打断";
		FWL.SEDUCE_FADE = "诱惑消退";

		FWL.FEAR_BREAK = "恐惧打断";
		FWL.FEAR_FADE = "恐惧失效";
		FWL.BANISH_BREAK = "放逐打断";
		FWL.BANISH_FADE = "放逐失效";
		FWL.ENSLAVE_BREAK = "奴役打断";
		FWL.ENSLAVE_FADE = "奴役失效";

		FWL.SPELL_LOCK_SUCCESS = "法术封锁施放成功";
		FWL.SPELL_LOCK_FAILED = "法术封锁释放失败";
		FWL.SPELL_LOCK_READY = "法术封锁就绪";
		FWL.DEVOUR_MAGIC_SUCCESS = "吞噬魔法施放成功";
		FWL.DEVOUR_MAGIC_FAILED = "吞噬魔法释放失败";
		FWL.DEVOUR_MAGIC_READY = "吞噬魔法就绪";

		FWL.BLOOD_PACT = "血之契印";
		FWL.BLOOD_PACT_ON = "血之契印打开";
		FWL.BLOOD_PACT_GAIN = "获得血之契印";
		FWL.BLOOD_PACT_LOSS = "失去血之契印";
		FWL.BLOOD_PACT_TT = "开启血之契印信息. 你可以将这些信息显示给其他人, 输入 'self' 或者 'all', 这样你的队友也能看见这些信息.";

		FWL._GAINED_BLOOD_PACT = " 得到血之契印.";
		FWL._LOST_BLOOD_PACT = " 失去血之契印.";

		FWL.DELAY_PET_TARGET = "Pet目标延迟";
		
		FWL.RITUAL_OF_DOOM = "末日仪式";
	
	-- tradition chinese
	elseif GetLocale() == "zhTW" then

		FWL.SUMMON_START = "召喚開始";
		FWL.SUMMON_CANCEL = "召喚取消";
		FWL.SUMMON_PORTAL = "時空門打開";
		FWL.SUMMON_FAILED = "召喚失敗";
		FWL.SUMMON_SUCCESS = "召喚成功";

		FWL.SUMMON_START_W = "召喚開始M語";	
		FWL.SUMMON_CANCEL_W = "召喚取消M語";	
		FWL.SUMMON_FAILED_W = "召喚失敗M語";

		FWL.SUMMONING = "召喚";
		FWL.SOULTONE_START = "靈魂石開始綁定";
		FWL.SOULTONE_CANCEL = "靈魂石取消綁定";
		FWL.SOULTONE_SUCCESS = "靈魂石成功綁定";

		FWL.SOULSTONE_NORMAL = "靈魂石";

		FWL.SOULTONE_START_W = "靈魂石開始綁定M語";
		FWL.SOULTONE_CANCEL_W = "靈魂石取消綁定M語";
		FWL.SOULTONE_SUCCESS_W = "靈魂石成功綁定M語";

		FWL.SEDUCE_START = "誘惑開始施放";
		FWL.SEDUCE_SUCCESS = "成功誘惑";
		FWL.SEDUCE_FAILED = "誘惑釋放失敗";
		FWL.SEDUCE_BREAK = "誘惑打斷";
		FWL.SEDUCE_FADE = "誘惑消退";

		FWL.FEAR_BREAK = "恐懼打斷";
		FWL.FEAR_FADE = "恐懼失效";
		FWL.BANISH_BREAK = "放逐打斷";
		FWL.BANISH_FADE = "放逐失效";
		FWL.ENSLAVE_BREAK = "奴役打斷";
		FWL.ENSLAVE_FADE = "奴役失效";

		FWL.SPELL_LOCK_SUCCESS = "法術封鎖施放成功";
		FWL.SPELL_LOCK_FAILED = "法術封鎖釋放失敗";
		FWL.SPELL_LOCK_READY = "法術封鎖就緒";
		FWL.DEVOUR_MAGIC_SUCCESS = "吞噬魔法施放成功";
		FWL.DEVOUR_MAGIC_FAILED = "吞噬魔法釋放失敗";
		FWL.DEVOUR_MAGIC_READY = "吞噬魔法就緒";
		
		FWL.BLOOD_PACT = "血之契印";
		FWL.BLOOD_PACT_ON = "血之契印打開";
		FWL.BLOOD_PACT_GAIN = "獲得血之契印";
		FWL.BLOOD_PACT_LOSS = "失去血之契印";
		FWL.BLOOD_PACT_TT = "開啟血之契印資訊. 你可以將這些資訊顯示給其他人, 輸入 'self' 或者 'all', 這樣你的隊友也能看見這些資訊.";

		FWL._GAINED_BLOOD_PACT = " 得到血之契印.";
		FWL._LOST_BLOOD_PACT = " 失去血之契印.";

		FWL.DELAY_PET_TARGET = "Pet目標延遲";

		FWL.RITUAL_OF_DOOM = "末日儀式";
		
	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
		FWL.SUMMON_START = "Beschwörung Starten";
		FWL.SUMMON_CANCEL = "Beschwörung abbrechen";
		FWL.SUMMON_PORTAL = "Beschwörungsportal offen";
		FWL.SUMMON_FAILED = "Beschwörung fehlgeschlagen";
		FWL.SUMMON_SUCCESS = "Beschwörung erfolgreich";

		FWL.SUMMON_START_W = "Beschwörung Starten flüstern";	
		FWL.SUMMON_CANCEL_W = "Beschwörung Abbrechen flüstern";
		FWL.SUMMON_FAILED_W = "Beschwörung Fehlgeschlagen flüstern";

		FWL.SUMMONING = "Beschwörung";
		FWL.SOULTONE_START = "Seelenstein zaubern Start";
		FWL.SOULTONE_CANCEL = "Seelenstein zaubern Abbruch";
		FWL.SOULTONE_SUCCESS = "Seelenstein zaubern Erfolgreich";

		FWL.SOULSTONE_NORMAL = "Seelenstein";

		FWL.SOULTONE_START_W = "Seelenstein zaubern Start flüstern";
		FWL.SOULTONE_CANCEL_W = "Seelenstein zaubern Abbruch flüstern";
		FWL.SOULTONE_SUCCESS_W = "Seelenstein zaubern Erfolgreich flüstern";

		FWL.SEDUCE_START = "Verführung zaubern Start";
		FWL.SEDUCE_SUCCESS = "Verführung zaubern Erfolgreich";
		FWL.SEDUCE_FAILED = "Verführung zaubern Fehlgeschlagen";
		FWL.SEDUCE_BREAK = "Verführung Unterbrochen";
		FWL.SEDUCE_FADE = "Verführung Endet";
		
		FWL.FEAR_BREAK = "Furcht Unterbrochen";
		FWL.FEAR_FADE = "Furcht Endet";
		FWL.BANISH_BREAK = "Verbannung Unterbrochen";
		FWL.BANISH_FADE = "Verbannung Endet";
		FWL.ENSLAVE_BREAK = "Versklaven Unterbrochen";
		FWL.ENSLAVE_FADE = "Versklaven Endet";

		FWL.SPELL_LOCK_SUCCESS = "Zaubersperre zaubern Erfolgreich";
		FWL.SPELL_LOCK_FAILED = "Zaubersperre zaubern Fehlgeschlagen";
		FWL.SPELL_LOCK_READY = "Zaubersperre zaubern Bereit";
		
		FWL.DEVOUR_MAGIC_SUCCESS = "Magie Verschlingen zaubern Erfolgreich";
		FWL.DEVOUR_MAGIC_FAILED = "Magie Verschlingen zaubern Fehlgeschlagen";
		FWL.DEVOUR_MAGIC_READY = "Magie Verschlingen Bereit";
		
		FWL.BLOOD_PACT = "Blutpackt";
		FWL.BLOOD_PACT_ON = "Blutpackt an";
		FWL.BLOOD_PACT_GAIN = "Blutpackt erhalten";
		FWL.BLOOD_PACT_LOSS = "Blutpackt verloren";
		FWL.BLOOD_PACT_TT = "Aktiviere Blutpackt Nachrichten. Du kannst diese für eine Klasse, einen Namen und/oder 'self' oder 'all' setzen, so wird die Nachricht über Blutpackt erhalten/verloren für diese Spieler in deiner Gruppe angezeigt.";

		FWL._GAINED_BLOOD_PACT = "%s erhält Blutpackt.";
		FWL._LOST_BLOOD_PACT = "%s verlor Blutpackt.";

		FWL.DELAY_PET_TARGET = "Pet-Ziel-Verzögerung";
	
		FWL.RITUAL_OF_DOOM = "Ritual der Verdammnis";
		
	-- korean
	elseif GetLocale() == "koKR" then
		FWL.SUMMON_START = "소환 시작";
		FWL.SUMMON_CANCEL = "소환 취소";
		FWL.SUMMON_PORTAL = "소환의문 열림";
		FWL.SUMMON_FAILED = "소환 실패";
		FWL.SUMMON_SUCCESS = "소환 성공";

		FWL.SUMMON_START_W = "귓속말 : 소환 시작";	
		FWL.SUMMON_CANCEL_W = "귓속말 : 소환 취소";	
		FWL.SUMMON_FAILED_W = "귓속말 : 소환 실패";

		FWL.SUMMONING = "소환중";
		FWL.SOULTONE_START = "영혼석시전";
		FWL.SOULTONE_CANCEL = "영혼석시전 취소";
		FWL.SOULTONE_SUCCESS = "영혼석시전 성공";

		FWL.SOULSTONE_NORMAL = "영혼석";

		FWL.SOULTONE_START_W = "귓속말 : 영혼석시전 시작";
		FWL.SOULTONE_CANCEL_W = "귓속말 : 영혼석시전 취소";
		FWL.SOULTONE_SUCCESS_W = "귓속말 : 영혼석시전 성공";

		FWL.SEDUCE_START = "유혹 시전 시작";
		FWL.SEDUCE_SUCCESS = "유혹 성공";
		FWL.SEDUCE_FAILED = "유혹 실패";
		FWL.SEDUCE_BREAK = "유혹 풀림";
		FWL.SEDUCE_FADE = "유혹 사라짐";
		
		FWL.FEAR_BREAK = "공포 풀림";
		FWL.FEAR_FADE = "공포 사라짐";
		FWL.BANISH_BREAK = "추방 풀림";
		FWL.BANISH_FADE = "추방 사라짐";
		FWL.ENSLAVE_BREAK = "지배 풀림";
		FWL.ENSLAVE_FADE = "지배 사라짐";

		FWL.SPELL_LOCK_SUCCESS = "주문잠금 성공";
		FWL.SPELL_LOCK_FAILED = "주문잠금 실패";
		FWL.SPELL_LOCK_READY = "주문잠금 준비";
		
		FWL.DEVOUR_MAGIC_SUCCESS = "마법삼키기 시전 성공";
		FWL.DEVOUR_MAGIC_FAILED = "마법삼키기 시전 실패";
		FWL.DEVOUR_MAGIC_READY = "마법삼키기 준비";
		
		FWL.BLOOD_PACT = "피의서약";
		FWL.BLOOD_PACT_ON = "피의 서약 얻음";
		FWL.BLOOD_PACT_GAIN = "피의 서약효과 발동";
		FWL.BLOOD_PACT_LOSS = "피의서약 사라짐";
		FWL.BLOOD_PACT_TT = "피의 서약 메세지를 알립니다. 특정 직업군이나 다른 플레이어 그리고 본인에게 알려주며, 해당 버프를 받을 수 있는 사람들에게 상태를 알려줄 수 있습니다.";

		FWL._GAINED_BLOOD_PACT = "%s : 피의서약효과 얻음";
		FWL._LOST_BLOOD_PACT = "%s : 피의서약효과 사라짐";

		FWL.DELAY_PET_TARGET = "펫의 대상 지연";

        FWL.RITUAL_OF_DOOM = "파멸의 의식";
		
	-- ENGLISH
	else	-- standard english version
		FWL.SUMMON_START = "Summoning Start";
		FWL.SUMMON_CANCEL = "Summoning Cancel";
		FWL.SUMMON_PORTAL = "Summoning Portal Open";
		FWL.SUMMON_FAILED = "Summoning Failed";
		FWL.SUMMON_SUCCESS = "Summoning Successfull";

		FWL.SUMMON_START_W = "Summoning Start whisper";	
		FWL.SUMMON_CANCEL_W = "Summoning Cancel whisper";	
		FWL.SUMMON_FAILED_W = "Summoning Failed whisper";

		FWL.SUMMONING = "Summoning";
		FWL.SOULTONE_START = "Soulstone cast Start";
		FWL.SOULTONE_CANCEL = "Soulstone cast Cancel";
		FWL.SOULTONE_SUCCESS = "Soulstone cast Success";

		FWL.SOULSTONE_NORMAL = "Soulstone";

		FWL.SOULTONE_START_W = "Soulstone cast Start whisper";
		FWL.SOULTONE_CANCEL_W = "Soulstone cast Cancel whisper";
		FWL.SOULTONE_SUCCESS_W = "Soulstone cast Success whisper";

		FWL.SEDUCE_START = "Seduce cast Start";
		FWL.SEDUCE_SUCCESS = "Seduce cast Success";
		FWL.SEDUCE_FAILED = "Seduce cast Failed";
		FWL.SEDUCE_BREAK = "Seduce Break";
		FWL.SEDUCE_FADE = "Seduce Fade";
		
		FWL.FEAR_BREAK = "Fear Break";
		FWL.FEAR_FADE = "Fear Fade";
		FWL.BANISH_BREAK = "Banish Break";
		FWL.BANISH_FADE = "Banish Fade";
		FWL.ENSLAVE_BREAK = "Enslave Break";
		FWL.ENSLAVE_FADE = "Enslave Fade";

		FWL.SPELL_LOCK_SUCCESS = "Spell Lock cast Success";
		FWL.SPELL_LOCK_FAILED = "Spell Lock cast Failed";
		FWL.SPELL_LOCK_READY = "Spell Lock Ready";
		
		FWL.DEVOUR_MAGIC_SUCCESS = "Devour Magic cast Success";
		FWL.DEVOUR_MAGIC_FAILED = "Devour Magic cast Failed";
		FWL.DEVOUR_MAGIC_READY = "Devour Magic Ready";
		
		FWL.BLOOD_PACT = "Blood Pact";
		FWL.BLOOD_PACT_ON = "Blood Pact on";
		FWL.BLOOD_PACT_GAIN = "Blood Pact gain";
		FWL.BLOOD_PACT_LOSS = "Blood Pact loss";
		FWL.BLOOD_PACT_TT = "Enable BLood Pact messages. You can set this to any classes, names and/or 'self' or 'all', so it will only show gains/losses for these players in your party.";

		FWL._GAINED_BLOOD_PACT = "%s gained Blood Pact.";
		FWL._LOST_BLOOD_PACT = "%s lost Blood Pact.";

		FWL.DELAY_PET_TARGET = "Delay pet target";
	
		FWL.RITUAL_OF_DOOM = "Ritual of Doom";
	end
end
