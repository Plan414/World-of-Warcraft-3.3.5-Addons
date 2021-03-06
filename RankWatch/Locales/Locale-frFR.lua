--
-- To translate, go to http://wow.curseforge.com/addons/rankwatch/localization/frFR/
--
local L = LibStub("AceLocale-3.0"):NewLocale("RankWatch", "frFR", false);
if not L then return end

L["About"] = "À propos de"
L["ADD_BOILERPLATE"] = "RankWatch enverra une brève explication la première fois qu'un joueur est chuchoté."
L["ALREADY_NOTIFIED"] = "Ne va pas chuchoter %s pour %s car %s l'a déjà fait."
L["ANY_LEVEL"] = "joueurs de tout niveau"
L["DATE_FORMAT"] = "%d/%m/%y %H:%M:%S"
L["IGNORED_PLAYERS"] = "RankWatch va ignorer les sorts lancés par les joueurs suivants:"
L["INVALID_COMMAND"] = "Commande invalide - Utilisez '/rankwatch help' si vous avez besoin d'aide"
L["LEVEL_80_ONLY"] = "joueurs de niveau 80 seulement"
L["LOCAL_SPELL_LOW"] = "Rankwatch a vu %s utiliser %s Rang %d (le rang maxi au %d est %d) à %s."
L["LOCAL_SPELL_REPLACED"] = "Rankwatch a vu %s utiliser %s Rang %d (remplacé au niveau %d par %s Rang %d) à %s."
L["NO_BOILERPLATE"] = "RankWatch n'enverra pas une brève explication la première fois qu'un joueur sera chuchoté."
L["NOONE_IGNORED"] = "RankWatch n'ignore actuellement personne."
L["NOREPORT_DOWNRANKED"] = "RankWatch ne signalera plus les sorts downrank."
L["NOT_REPORT_INTERVAL"] = "Rankwatch ne signalera plus un joueur pour le même sort utilisé à un intervalle de moins de %s secondes."
L["ON_IGNORE_LIST"] = "Ne chuchotera pas %s pour %s car %s l'a dans sa liste d'ignore."
L["PLAYER_ALREADY_IGNORED"] = "RankWatch ignore déja les sorts lancés par %s."
L["PLAYER_ALREADY_WATCHED"] = "RankWatch observe déja les sorts lancés par %s."
L["PLAYER_NOW_IGNORED"] = "RankWatch ignorera les sorts lancés par %s."
L["PLAYER_NOW_WATCHED"] = "RankWatch observera les sorts lancés par %s."
L["RANKWATCH_CHANNEL_NOWHISPERS"] = "RankWatch ne chuchotera pas un joueur automatiquement."
L["RANKWATCH_CHANNEL_PARTY"] = "RankWatch enverra son rapport sur les joueurs utilisant des sorts downrank sur le chat groupe/raid/cdb."
L["RANKWATCH_CHANNEL_SAY"] = "RankWatch enverra son rapport sur les joueurs utilisant des sorts downrank avec /dire."
L["RANKWATCH_CHANNEL_WHISPER"] = "RankWatch chuchotera aux joueurs utilisant des sorts downrank."
L["RANKWATCH_CHANNEL_WHISPER_EXPLAIN"] = "Rankwatch chuchotera une brève explication la première fois qu'un joueur est vu utiliser un sort downrank."
L["RANKWATCH_CHANNEL_WHISPER_NOEXPLAIN"] = "Rankwatch ne chuchotera pas une brève explication la première fois qu'un joueur est vu utiliser un sort downrank."
L["RANKWATCH_DISABLED"] = "RankWatch est désactivé."
L["RANKWATCH_ENABLED"] = "RankWatch est activé."
L["RANKWATCH_REPORT_LINE_LOW"] = "%s rang %d (le rang maxi au niveau %d est %d) à %s"
L["RANKWATCH_REPORT_LINE_REPLACED"] = "%s rang %d (remplacé au niveau %d par %s rang %d) à %s"
L["RANKWATCH_REPORT_NONE_SEEN"] = "RankWatch n'a vu aucun sort downrank."
L["RANKWATCH_SELF_ONLY"] = "RankWatch will report only spells cast by you." -- Requires localization
L["RANKWATCH_WELCOME_DISABLED"] = "RankWatch %s désactivé. Tapez '/rankwatch enable' pour l'activer."
L["RANKWATCH_WELCOME_ENABLED"] = "RankWatch %s activé. Tapez /rankwatch pour plus d'infiormations."
L["REPORT_ALL_LEVELS"] = "RankWatch rapportera les joueurs de tous niveaux utilisant des sorts downrank."
L["REPORT_DOWNRANKED"] = "RankWatch rapportera maintenant les sorts downrank."
L["REPORT_GROUP_CHAT"] = "RankWatch enverra son rapport sur les joueurs utilisant des sorts downrank sur le chat groupe/raid/cdb."
L["REPORT_ONLY_80"] = "RankWatch rapportera seulement les joueurs de niveau 80 utilisant des sorts downrank."
L["REPORT_ONLY_SELF"] = "RankWatch rapportera les sorts downrank dans votre fenêtre de discussion seulement."
L["REPORT_SAY"] = "RankWatch enverra son rapport sur les joueurs utilisant des sorts downrank avec /dire."
L["REPORT_SEEN"] = "RankWatch a vu les sorts downrank suivants :"
L["REPORT_WHISPER"] = "RankWatch chuchotera aux joueurs utilisant des sorts downrank."
L["SEEN_LIST_CLEARED"] = "La liste des sorts downrank récente de RankWatch a été vidée."
L["__URL__"] = " http://wow.curse.com/downloads/wow-addons/details/rankwatch.aspx"
L["USAGE_01"] = "Aide de RankWatch %s :"
L["USAGE_02"] = "    /rankwatch enable          - active RankWatch"
L["USAGE_03"] = "    /rankwatch disable          - désactive RankWatch"
L["USAGE_04"] = "    /rankwatch report          - rapporte les sorts récemment downrank"
L["USAGE_05"] = "    /rankwatch clear           - vide la liste des sorts récemment downrank"
L["USAGE_06"] = "    /rankwatch 80              - rapporte seulement les joueurs niveau 80 utilisant des sorts downrank"
L["USAGE_07"] = "   /rankwatch all             - rapporte les joueurs de tous niveaux utilisant des sorts downrank"
L["USAGE_08"] = "    /rankwatch whisper         - chuchote aux joueurs utilisant des sorts downrank (ne fonctionne pas en donjons inter-royaumes)"
L["USAGE_09"] = "    /rankwatch party           - rapporte les joueurs utilisant des sorts downrank sur le canal groupe/raid/cdb."
L["USAGE_10"] = "   /rankwatch say             - rapporte les joueurs utilisant des sorts downrank avec /dire"
L["USAGE_11"] = "   /rankwatch none             - rapporte les joueurs utilisant des sorts downrank sur votre fenêtre de discussion seulement"
L["USAGE_11a"] = "   /rankwatch self            - report only your own downranked spells" -- Requires localization
L["USAGE_12"] = "   /rankwatch explain enable  - le premier chuchoter inclut une courte explication"
L["USAGE_13"] = "    /rankwatch explain disable - le premier chuchoter n'incluera pas une courte explication"
L["USAGE_14"] = "    /rankwatch interval <secondes> - temps minimum entre chaque message pour la même personne et le même sort"
L["USAGE_15"] = "   /rankwatch ignore          - liste les joueurs sur la liste d'ignores"
L["USAGE_16"] = "    /rankwatch ignore <nom>   - ne signale jamais les sorts lancés par ce joueur"
L["USAGE_17"] = "   /rankwatch watch <nom>    - n'ignore plus les sorts lancés par ce joueur"
L["Version"] = "Version"
L["WHISPER_BOILERPLATE_PART1"] = "Si tu as entrainé %s rang %d, assure toi qu'il soit sur tes barres - il y a un bug lors de l'entrainement avec une double spé, qui ne met pas à jour les barres de ton autre spé."
L["WHISPER_BOILERPLATE_PART2"] = "Si ton intention était d'utiliser un sort downrank, toutes mes excuses - whisp moi, et je ferai en sorte que RankWatch ne t'envoie plus de messages."
L["WHISPER_SPELL_LOW_WARNING"] = " [RankWatch] %s a utilisé %s Rang %d.  Le rang maxi au niveau %d est %d."
L["WHISPER_SPELL_REPLACED_WARNING"] = " [RankWatch] %s a utilisé %s Rang %d, qui est remplacé au niveau %d par %s Rang %d."

