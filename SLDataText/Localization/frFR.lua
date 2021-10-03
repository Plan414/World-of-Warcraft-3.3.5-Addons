if ( GetLocale() ~= "frFR" ) then return end

local addon, ns = ...
ns.L = {
	-- Core Globals
	["Combat Fade"] = "Cachez-vous dans bataille",
	["Class Colored"] = "Classe de couleur",
	["Global Font Size"] = "Mondial Taille de la police",
	["ProfDesc"] = "Créer un nouveau ou copier les profils existants. Profils par défaut mis à caractère.",
	["ProfResDesc"] = "Reset Profile",
	["ProfNew"] = "Nouveau",
	["ProfReset"] = "Reset",
	["ProfCurrent"] = "Courant",
	["ProfCopy"] = "Copie",
	["ProfDel"] = "Delete",
	["/sldt"] = "/sldt",
	["Command List"] = "Liste des commandes",
	["config"] = "config",
	["Toggle Configuration Mode"] = "Basculer le mode de configuration",
	["Configuration Mode"] = "Mode de configuration",
	["active"] = "Actif",
	["inactive"] = "Inactives",
	["global"] = "mondial",
	["Open SLDataText global menu"] = "Ouvrez le menu SLDataText mondiale",
	["<module>"] = "<module>",
	["Open Module Option Menu"] = "Ouvrir le menu Option module",
	["Loaded Modules"] = "Modules chargés",
	["TTScale"] = "SLToolTip Scale",
	
	-- Common
	["Enabled"] = "Activé",
	["Global Font"] = "Font mondiale",
	["Outline"] = "Aperçu",
	["Force Shown"] = "Voir dans bataille",
	["Tooltip On"] = "Sur Tooltip",
	["Font Size"] = "Taille de la police",
	["Font"] = "Type de police",
	["Justify"] = "Alignement du texte",
	["Parent"] = "Cadre parent",
	["Anchor"] = "D'ancrage",
	["X Offset"] = "X Alignement",
	["Y Offset"] = "Y Alignement",
	["Frame Strata"] = "Cadre strates",
	["Update Interval"] = "Mise à jour Fréquence",
	["On"] = "Sur",
	["Off"] = "Off",
	["Prefix"] = "Préfixe",
	["Prefix Text"] = "Préfixe Texte",
	["Suffix"] = "Suffixe",
	["Suffix Text"] = "Suffixe Texte",
	["Left-Click"] = "Clic gauche",
	["Right-Click"] = "Faites un clic droit",
	["Show Icon"] = "Afficher l'icône",
	["Show Text"] = "Afficher le texte",
	["Text Display"] = "Texte Affichage",
	
	-- Armor Module
	["Armor"] = "Armures",
	["All Items"] = "Tous les Articles",
	["Auto Repair"] = "Automatique Réparation",
	["Use Guild Bank"] = "Use Guild Bank",
	["AutoRepairLine"] = "Articles réparé pour",
	["GFAutoRepairLine"] = "Articles réparé pour (Guild Funds)",
	["ArmorTextDesc"] = "Tags for Text Display: [Dur] = Current Durability",
	
	-- Bag Module
	["Bag Info"] = "Sac Information",
	["Space Used"] = "Espace Utilisé",
	["Space Avail"] = "Espace Disponibles",
	["Space Left"] = "Espace Restantes",
	["AutoSell Junk"] = "Jonque automatique Vendre",
	["JunkSoldLine"] = "Jonque vendu a généré",
	["Toggle Bags"] = "Sacs Ouverts",
	["BagTextDesc"] = "Tags for Texte Affichage: [T] = Total, [R] = Remaining, [U] = Used",
	
	-- Clock Module
	["Toggle Calendar"] = "Ouvrez Calendrier",
	["Toggle Time Manager"] = "Délai ouvert",
	["Queued for:"] = "En file d'attente pour:",
	["Realm Time"] = "Heure du Serveur",
	["24 Hour"] = "24 heures",
	["PvP Info"] = "PvP información",
	["Time String"] = "Time String",
	["ClockDesc"] = "Visit http://www.lua.org/pil/22.1.html for a full list of clock tags. Turn 'Correct Hour' option off if hour tag is not first in the time string.",
	["CorrHour"] = "Correct Hour",
	
	-- Coords Module
	["Precision"] = "Precisión",
	
	-- Currency Module
	["Currency"] = "Devises",
	["No Currency"] = "Pas de devise",
	["Click to set display currency."] = "Cliquez définir la monnaie d'affichage.",
	["Display Currency"] = "Affichage Devises",
	
	-- Exp Module
	["Max Level Hide"] = "Niveau max Cacher",
	["Exp"] = "Exp",
	["ExpTextDesc"] = "Tags for Text Display: [Cur] = Current XP, [Max] = Max XP, [Rem] = Remaining XP, [Per] = XP Percent, [PerR] = XP Remaining Percent, [R] = Rest XP, [RP] = Rest XP Percent",
	
	-- FPS Module
	["fps"] = "fps",
	["FPSTextDesc"] = "Tags for Text Display: [F] = Current FPS",
	
	-- Gold Module
	["Wallet"] = "Portefeuille",
	["Current"] = "Courant",
	["Session Start"] = "Début de session",
	["Session Earned"] = "Earned cette session",
	["Server Gold"] = "L'argent du serveur",
	["Horde"] = "Horde",
	["Alliance"] = "Alliance",
	["Total Gold"] = "L'argent total",
	["Display Style"] = "Style D'affichage",
	["Alt Money"] = "Alt Argent",
	["ResetData"] = "Reset Data",
	
	-- Latency Module
	["Latency"] = "Latency",
	["Bandwidth In"] = "Bandwidth In",
	["Bandwidth Out"] = "Bandwidth Out",
	["Latency (Home)"] = "Latency (Home)",
	["Latency (World)"] = "Latency (World)",
	["ms"] = "ms",
	["LagTextDesc"] = "Tags for Text Display: [L] = Current Latency",
	
	-- Mail Module
	["No Mail"] = "Pas de courrier",
	["Mail!"] = "Courrier!",
	["AH Alert!"] = "AH Alerte!",
	["Play Sounds"] = "Lire des sons",
	
	-- Memory Module
	["AddOn Memory"] = "mémoire AddOn",
	["Showing Top 15 AddOns"] = "Affichage Top 15 AddOns",
	["Total AddOn Memory"] = "Mémoire totale AddOn",
	["Total UI Memory Usage"] = "Utilisation de la mémoire totale UI",
	["Hover"] = "Hover",
	["Show only top AddOns"] = "Show only top AddOns",
	["Alt+Hover"] = "Alt+Hover",
	["Show all AddOns"] = "Voir tous les AddOns",
	["Collect Garbage"] = "Ramasser les Ordures",
	["mb"] = "mb",
	["MemTextDesc"] = "Tags for Text Display: [MA] = Addon Memory, [MT] = Total Memory",
	
	-- Reputation Module
	["Reputation"] = "Reputation",
	["No Reputation"] = "No Reputation",
	["Click to set display reputation."] = "Click to set display reputation.",
	["Display Reputation"] = "Display Reputation",
	["Hated"] = "Hated",
	["Hostile"] = "Hostile",
	["Unfriendly"] = "Unfriendly",
	["Neutral"] = "Neutral",
	["Friendly"] = "Friendly",
	["Honored"] = "Honored",
	["Revered"] = "Revered",
	["Exalted"] = "Exalted",
}