-- CooldownCount localization information
-- French Locale
-- Translation by Sasmira
-- Date 06/11/2005

if ( GetLocale ) and ( GetLocale() == "frFR" ) then

BINDING_HEADER_COOLDOWNCOUNTHEADER	= "Cooldown Count";
BINDING_NAME_COOLDOWNCOUNT		= "ON/OFF Cooldown Count";

COOLDOWNCOUNT_CONFIG_HEADER		= "Cooldown Count";
COOLDOWNCOUNT_CONFIG_HEADER_INFO	= "Contient les options de Cooldown Count,\nun AddOn permettant d\'afficher le temps d\'attente avant de pouvoir relancer une action.";

COOLDOWNCOUNT_ENABLED			= "Activer Cooldown Count";
COOLDOWNCOUNT_ENABLED_INFO		= "En l\'activant, Cooldown Count montrera le temps restant avant la r\195\169utilisation d\'une action.";

COOLDOWNCOUNT_ROGUE_STEALTH		= "Activer le cooldown sur le camouflage des voleurs";
COOLDOWNCOUNT_ROGUE_STEALTH_INFO	= "Active le cooldown sur le camouflage des voleurs.";

COOLDOWNCOUNT_NOSPACES			= "Supprimer l\'espace entre le temps et l\'unit\195\169";
COOLDOWNCOUNT_NOSPACES_INFO		= "Supprime l\'espace entre le temps et l\'unit\195\169, exemple : \"19 m\" en \"19m\".";

COOLDOWNCOUNT_SIDECOUNT			= "Compteur Barre lat\195\169rale excentr\195\169e";
COOLDOWNCOUNT_SIDECOUNT_INFO		= "Le compteur fonctionnera sur la barre lat\195\169rale si elle est plac\195\169e plus loin au le milieu de l\'\195\169cran.";

COOLDOWNCOUNT_FLASHSPEED		= "Intervalle entre les Flash";
COOLDOWNCOUNT_FLASHSPEED_INFO		= "D\195\169termine l\'intervalle de temps entre chaque flash lorsque le chronometre de cooldown est sur le point d\'expirer.";

COOLDOWNCOUNT_FLASHSPEED_SLIDER_DESCRIPTION	= "Dur\195\169e";
COOLDOWNCOUNT_FLASHSPEED_SLIDER_APPEND		= " s ";

COOLDOWNCOUNT_HIDEUNTILTIMELEFT			= "Cachez jusqu\'\195\160...";
COOLDOWNCOUNT_HIDEUNTILTIMELEFT_INFO		= "Cachera les chronometres de CooldownCount jusqu\'\195\160 ce qu\'ils atteignent le temps indiqu\195\169 (0 = visible tout le temps).";

COOLDOWNCOUNT_HIDEUNTILTIMELEFT_SLIDER_DESCRIPTION	= "Dur\195\169e";
COOLDOWNCOUNT_HIDEUNTILTIMELEFT_SLIDER_APPEND		= " s ";

COOLDOWNCOUNT_HOURS_FORMAT				= "%s h";
COOLDOWNCOUNT_MINUTES_FORMAT				= "%s m";

COOLDOWNCOUNT_HOUR_MINUTES_FORMAT			= "%s:%s";
COOLDOWNCOUNT_MINUTES_SECONDS_FORMAT			= "%s:%s";
COOLDOWNCOUNT_SECONDS_FORMAT				= "%s";

COOLDOWNCOUNT_SECONDS_LONG_FORMAT			= "%s s";

COOLDOWNCOUNT_USERSCALE					= "Changer la Taille";
COOLDOWNCOUNT_USERSCALE_INFO				= "Changer manuellement la taille de l\'affichage des valeurs.La taille par d\195\169faut est de 1.";
COOLDOWNCOUNT_USERSCALE_SLIDER_DESCRIPTION		= "Taille";
COOLDOWNCOUNT_USERSCALE_SLIDER_APPEND			= " % ";

COOLDOWNCOUNT_USELONGTIMERS				= "Utiliser les longues descriptions du Chronometre ";
COOLDOWNCOUNT_USELONGTIMERS_INFO			= "Utilisera les longues descriptions, mais explicite, du Chronometre.";

COOLDOWNCOUNT_NORMALCOLOR_SET				= "Couleur du texte";
COOLDOWNCOUNT_NORMALCOLOR_SET_INFO			= "Permet de choisir la couleur de la valeur num\195\169rique.";

COOLDOWNCOUNT_FLASHCOLOR_SET				= "Couleur du Flash";
COOLDOWNCOUNT_FLASHCOLOR_SET_INFO			= "Permet de choisir la couleur du Flash de la valeur num\195\169rique.";
COOLDOWNCOUNT_SETTEXT					= "Choix";

COOLDOWNCOUNT_ALPHA					= "Transparence";
COOLDOWNCOUNT_ALPHA_INFO				= "Determines la transparence du texte.";

COOLDOWNCOUNT_ALPHA_SLIDER_DESCRIPTION			= "Transparence";
COOLDOWNCOUNT_ALPHA_SLIDER_APPEND			= " % ";


-- Slash Commands

COOLDOWNCOUNT_SLASH_ENABLE				= "enable";
COOLDOWNCOUNT_SLASH_DISABLE				= "disable";
COOLDOWNCOUNT_SLASH_SET					= "set";
COOLDOWNCOUNT_SLASH_FLASHSPEED				= "flash";
COOLDOWNCOUNT_SLASH_SCALE				= "scale";
COOLDOWNCOUNT_SLASH_ALPHA				= "alpha";
COOLDOWNCOUNT_SLASH_NOSPACES				= "space";
COOLDOWNCOUNT_SLASH_NORMALCOLOR				= "normalcolor";
COOLDOWNCOUNT_SLASH_FLASHCOLOR				= "flashcolor";
COOLDOWNCOUNT_SLASH_USELONGTIMERS			= "uselongtimers";
COOLDOWNCOUNT_SLASH_HIDEUNTILTIMELEFT			= "hideuntil";

COOLDOWNCOUNT_PARAM_ON					= "on";
COOLDOWNCOUNT_PARAM_OFF					= "off";
COOLDOWNCOUNT_PARAM_TOGGLE				= "toggle";


COOLDOWNCOUNT_SLASH_USAGE 							= {
	" Utilisation: /cooldowncount (ou /cc) <commande> [parametrage]",
	"",
	" Commandes:",
	COOLDOWNCOUNT_SLASH_ENABLE.." - Active CooldownCount",
	COOLDOWNCOUNT_SLASH_DISABLE.." - D\195\169sactive CooldownCount",
	COOLDOWNCOUNT_SLASH_SET.." - ON/OFF CooldownCount",
	COOLDOWNCOUNT_SLASH_FLASHSPEED.." - Contr\195\180le de la vitesse du flash",
	COOLDOWNCOUNT_SLASH_SCALE.." - Contr\195\180le de la taille",
	COOLDOWNCOUNT_SLASH_ALPHA.." - contr\195\180le de la transparence",
	COOLDOWNCOUNT_SLASH_NOSPACES.." - contr\195\180le de l\'espacement (Si vous mettez un espace entre la valeur num\195\169rique et l\'unit\195\169)",
	COOLDOWNCOUNT_SLASH_NORMALCOLOR.." - Choix de la Couleur",
	COOLDOWNCOUNT_SLASH_FLASHCOLOR.." - Choix de la Couleur du Flash",
	COOLDOWNCOUNT_SLASH_HIDEUNTILTIMELEFT.." - cachez jusqu\'au nombre indiqu\195\169 de secondes, 0 d\195\169sativ\195\169",
	--COOLDOWNCOUNT_SLASH_USELONGTIMERS.." - control long timer descriptions"
};

COOLDOWNCOUNT_CHAT_ALPHA_NOT_SPECIFIED				= "Cooldown Count - Transparence : Indiquer une valeur num\195\169rique.";

COOLDOWNCOUNT_CHAT_USERSCALE					= "Cooldown Count - Taille : %s.";
COOLDOWNCOUNT_CHAT_USERSCALE_NOT_SPECIFIED			= "Cooldown Count - Taille : : Indiquer une valeur num\195\169rique.";

COOLDOWNCOUNT_CHAT_USELONGTIMERS_ENABLED			= "Cooldown Count - Longues descriptions Activ\195\169es.";
COOLDOWNCOUNT_CHAT_USELONGTIMERS_DISABLED			= "Cooldown Count - Longues descriptions D\195\169sactiv\195\169es.";



COOLDOWNCOUNT_CHAT_ENABLED					= "Cooldown Count Activ\195\169es.";
COOLDOWNCOUNT_CHAT_DISABLED					= "Cooldown Count D\195\169sactiv\195\169es.";

COOLDOWNCOUNT_CHAT_ROGUE_STEALTH_ENABLED			= "Cooldown Count - Camouflage des Voleurs Activ\195\169s.";
COOLDOWNCOUNT_CHAT_ROGUE_STEALTH_DISABLED			= "Cooldown Count - Camouflage des Voleurs D\195\169sactiv\195\169s.";

COOLDOWNCOUNT_CHAT_NOSPACES_ENABLED				= "Cooldown Count - Sans Espace Activ\195\169.";
COOLDOWNCOUNT_CHAT_NOSPACES_DISABLED				= "Cooldown Count - Sans Espace D\195\169sactiv\195\169.";
COOLDOWNCOUNT_CHAT_FLASHSPEED					= "Cooldown Count - Vitesse du flash : %s.";

COOLDOWNCOUNT_CHAT_COMMAND_MAIN_INFO				= "contr\195\180le de Cooldown Count.";
COOLDOWNCOUNT_CHAT_COMMAND_ENABLE_INFO				= "ONF/OFF Cooldown Count.";
COOLDOWNCOUNT_CHAT_COMMAND_SIDECOUNT_ENABLE_INFO		= "ONF/OFF Cooldown Count - Barre lat\195\169rale excentr\195\169e.";
COOLDOWNCOUNT_CHAT_COMMAND_FLASHSPEED_INFO			= "D\195\169terminer l\'intervalle de temps ( en seconde ) entre chaque flash lorsque le chronometre de cooldown est sur le point d\'expirer.";
COOLDOWNCOUNT_CHAT_COMMAND_SCALE_INFO				= "D\195\169terminer la Taille pour la valeur num\195\169rique.";

COOLDOWNCOUNT_CHAT_ALPHA_FORMAT					= "Cooldown Count - Transparence : %2f";
COOLDOWNCOUNT_CHAT_NORMAL_COLOR_SET				= "Cooldown Count - Couleur du texte.";
COOLDOWNCOUNT_CHAT_FLASH_COLOR_SET				= "Cooldown Count - Couleur du flash.";

COOLDOWNCOUNT_CHAT_HIDEUNTILTIMELEFT				= "Cooldown Count - Cacher jusqu\'au temps restant : %d.";
COOLDOWNCOUNT_CHAT_HIDEUNTILTIMELEFT_NOT_SPECIFIED		= "Cooldown Count - Cacher jusqu\'au temps restant : Indiquer une valeur num\195\169rique.";

-- Classes
COOLDOWNCOUNT_CLASS_ROGUE					= "Voleur";

end
