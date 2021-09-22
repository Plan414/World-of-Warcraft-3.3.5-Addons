﻿--
-- To translate, go to http://wow.curseforge.com/addons/rankwatch/localization/esMX/
--
local L = LibStub("AceLocale-3.0"):NewLocale("RankWatch", "esMX", false);
if not L then return end

L["About"] = "Acerca de"
L["ADD_BOILERPLATE"] = "RankWatch enviará una breve explicación la primera vez que un jugador es susurrado."
L["ALREADY_NOTIFIED"] = "No se susurrará %s sobre %s porque %s ya lo hizo"
L["ANY_LEVEL"] = "jugadores de cualquier nivel"
L["DATE_FORMAT"] = "%d/%m/%y %H:%M:%S"
L["IGNORED_PLAYERS"] = "RankWatch ignorará los hechizos lanzados por los siguientes jugadores:"
L["INVALID_COMMAND"] = "Comando no válido - usa \"/rankwatch help\" si necesitas ayuda"
L["LEVEL_80_ONLY"] = "solo jugadores de nivel 80"
L["LOCAL_SPELL_LOW"] = "RankWatch vio a %s usar %s Rango %d (rango máx al nivel %d es %d) el %s."
L["LOCAL_SPELL_REPLACED"] = "RankWatch vió a %s usar %s Rango %d (reemplazado al nivel %d por %s Rango %d) el %s."
L["NO_BOILERPLATE"] = "RankWatch no enviará una corta explicación la primera vez que un jugador sea susurrado."
L["NOONE_IGNORED"] = "RankWatch no está ignorando a nadie."
L["NOREPORT_DOWNRANKED"] = "RankWatch ya no reportará hechizos de rango bajo"
L["NOT_REPORT_INTERVAL"] = "RankWatch no reportará a ningun jugador sobre el mismo hechizo más de una vez cada %s segundos."
L["ON_IGNORE_LIST"] = "No se susurrará a %s sobre %s porque %s lo tiene en su lista de ignorados."
L["PLAYER_ALREADY_IGNORED"] = "RankWatch ya está ignorando hechizos lanzados por %s."
L["PLAYER_ALREADY_WATCHED"] = "RankWatch ya está vigilando hechizos lanzados por %s."
L["PLAYER_NOW_IGNORED"] = "RankWatch ignorará hechizos lanzados por %s."
L["PLAYER_NOW_WATCHED"] = "RankWatch vigilará hechizos lanzados por %s."
L["RANKWATCH_CHANNEL_NOWHISPERS"] = "RankWatch no susurrará a ningún jugador automáticamente."
L["RANKWATCH_CHANNEL_PARTY"] = "RankWatch reportará %s que usan hechizos de bajo rango en el chat de grupo/raid/bg"
L["RANKWATCH_CHANNEL_SAY"] = "RankWatch reportará %s que usen hechizos de bajo rango con /decir."
L["RANKWATCH_CHANNEL_WHISPER"] = "RankWatch susurrará %s que usen hechizos de bajo rango."
L["RANKWATCH_CHANNEL_WHISPER_EXPLAIN"] = "RankWatch susurrará una corta explicación la primera vez que un jugador es visto usando un hechizo de bajo rango."
L["RANKWATCH_CHANNEL_WHISPER_NOEXPLAIN"] = "RankWatch no susurrará una corta explicación la primera vez que un jugador es visto usando un hechizo de bajo rango."
L["RANKWATCH_DISABLED"] = "RankWatch está desactivado."
L["RANKWATCH_ENABLED"] = "RankWatch está activado."
L["RANKWATCH_REPORT_LINE_LOW"] = "%s rango %d (rango máx al nivel %d es %d) el %s"
L["RANKWATCH_REPORT_LINE_REPLACED"] = "%s rango %d (reemplazado al nivel %d por %s rango %d) el %s"
L["RANKWATCH_REPORT_NONE_SEEN"] = "RankWatch no ha visto ningún hechizo de rango bajo."
L["RANKWATCH_SELF_ONLY"] = "RankWatch will report only spells cast by you." -- Requires localization
L["RANKWATCH_WELCOME_DISABLED"] = "RankWatch %s desactivado. Escribe '/rankwatch enable' para activarlo."
L["RANKWATCH_WELCOME_ENABLED"] = "RankWatch %s activo. Escribe /rankwatch para más información."
L["REPORT_ALL_LEVELS"] = "RankWatch informará a jugadores de todos los niveles que usen hechizos de rango bajo."
L["REPORT_DOWNRANKED"] = "RankWatch ahora informará de hechizos de rango bajo"
L["REPORT_GROUP_CHAT"] = "RankWatch informará de jugadores que usen hechizos de rango bajo en el chat de grupo/raid/bg."
L["REPORT_ONLY_80"] = "RankWatch solo informará de jugadores nivel 80 que usen hechizos de rango bajo."
L["REPORT_ONLY_SELF"] = "RankWatch informará de hechizos de rango bajo sólo en tu ventana de chat."
L["REPORT_SAY"] = "RankWatch informará de jugadores que usen hechizos de rango bajo con /decir."
L["REPORT_SEEN"] = "RankWatch ha visto los siguientes hechizos de rango bajo:"
L["REPORT_WHISPER"] = "RankWatch susurrará jugadores que usen hechizos de rango bajo."
L["SEEN_LIST_CLEARED"] = "La lista de RankWatch de hechizos de bajo rango recientemente vistos ha sido vaciada."
L["__URL__"] = "http://wow.curse.com/downloads/wow-addons/details/rankwatch.aspx"
L["USAGE_01"] = "Ayuda de RankWatch %s:"
L["USAGE_02"] = "    /rankwatch enable          - activa RankWatch"
L["USAGE_03"] = "    /rankwatch disable         - desactiva RankWatch"
L["USAGE_04"] = "    /rankwatch report          - reporta hechizos de rango bajo recientemente vistos"
L["USAGE_05"] = "   /rankwatch clear           - limpia la lista de hechizos de rango bajo recientemente vistos"
L["USAGE_06"] = "    /rankwatch 80              - informa solo a los jugadores de nivel 80 que usan hechizos de rango bajo"
L["USAGE_07"] = "   /rankwatch all             - informa a todos los jugadores que usan hechizos de rango bajo"
L["USAGE_08"] = "   /rankwatch whisper         - susurra jugadores que usan hechizos de rango bajo (no funciona en mazmorras entre reinos)"
L["USAGE_09"] = "   /rankwatch party           - informa de los jugadores que usan hechizos de rango bajo en el chat de grupo/raid/bg"
L["USAGE_10"] = "   /rankwatch say             - informa de jugadores que usan hechizos de rango bajo con /decir"
L["USAGE_11"] = "   /rankwatch none            - informa de hechizos de bajo rango sólo en tu ventana de chat"
L["USAGE_11a"] = "   /rankwatch self            - report only your own downranked spells" -- Requires localization
L["USAGE_12"] = "   /rankwatch explain enable  - la primera vez que se susurra se incluye una corta explicación"
L["USAGE_13"] = "   /rankwatch explain disable  - la primera vez que se susurra no se incluirá una corta explicacion"
L["USAGE_14"] = "    /rankwatch interval <segundos> - mínimo tiempo entre susurros a la misma persona sobre el mismo hechizo"
L["USAGE_15"] = "   /rankwatch ignore          - lista a los jugadores en la lista de ignorados"
L["USAGE_16"] = "   /rankwatch ignore <nombre>   - nunca informa de hechizos usados por ese jugador"
L["USAGE_17"] = "   /rankwatch watch <nombre>    - ya no se ignorarán hechizos lanzados por ese jugador"
L["Version"] = "Versión"
L["WHISPER_BOILERPLATE_PART1"] = "Si has entrenado %s rango %d, asegúrate de que está en tus barras - hay un bug si entrenas teniendo la doble spec, no se actualizan las barras de tu otra especialización."
L["WHISPER_BOILERPLATE_PART2"] = "Si de verdad querías usar un hechizo de rango bajo, mis disculpas - dimelo, y haré que RankWatch nunca te envíe otro mensaje."
L["WHISPER_SPELL_LOW_WARNING"] = "[RankWatch] %s usó %s Rango %d. El máximo rango al nivel %d es %d."
L["WHISPER_SPELL_REPLACED_WARNING"] = "[RankWatch] %s usó %s Rango %d, el cual es reemplazado al nivel %d por %s Rango %d."

