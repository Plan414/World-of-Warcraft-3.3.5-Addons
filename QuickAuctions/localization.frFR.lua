if( GetLocale() ~= "frFR" ) then
	return
end

local QuickAuctions = select(2, ...)
QuickAuctions.L = setmetatable({
	["%d (max %d) posted by yourself (%s)"] = "%d (max %d) post\195\169s par vous-m\195\170me (%s)",
	["%d log messages waiting"] = "%d messages de log cach\195\169s",
	["%s lowest buyout %s (threshold %s), total posted |cfffed000%d|r (%d by you)"] = "%s prix le plus bas %s (seuil %s), |cfffed000%d|r post\195\169s au total (%d par vous)",
	["/qa cancelall <group/12/2> - Cancels all active auctions, or cancels auctions in a group if you pass one, or cancels auctions with less than 12 or 2 hours left."] = "/qa cancelall <group/12/2> -Annule toutes les ventes, ou annule les ventes d'un groupe si pr\195\169cis\195\169, ou annule les ventes avec moins de 12 ou 2 heures de temps restant.",
	["/qa config - Toggles the configuration"] = "/qa config - Affiche l'\195\169cran de configuration",
	["/qa summary - Shows the auction summary"] = "/qa summary - Affiche le r\195\169sum\195\169 des ventes",
	["/qa tradeskill - Toggles showing the craft queue window for tradeskills"] = "/qa tradeskill - Affiche la file d'attente d'artisanat",
	["12 hours"] = "12 heures",
	["24 hours"] = "24 heures",
	["48 hours"] = "48 heures",
	["ALTER_PERFECT"] = "ALTER_PERFECT",
	["Add items"] = "Ajouter",
	["Add items matching filter"] = "Filtre d'ajout d'objet",
	["Add new group"] = "Ajouter un nouveau groupe",
	["Add new player"] = "Ajouter un nouveau joueur",
	["Adds a new player to the whitelist so they will not be undercut."] = "Ajoute un joueur \195\160 la liste blanche pour ne pas le concurrencer.",
	["Allows you to override the default auto fallback settings."] = "Vous permet de passer outre les param\195\168tres de rabat automatique par d\195\169faut.",
	["Allows you to override the default auto mailer settings."] = "Vous permet de passer outre les param\195\168tres de courrier automatique par d\195\169faut.",
	["Allows you to override the default bid percent settings."] = "Vous permet de passer outre les param\195\168tres de prix de d\195\169part par d\195\169faut.",
	["Allows you to override the default fallback after settings."] = "Vous permet de passer outre les param\195\168tres de prise en compte du rabat par d\195\169faut.",
	["Allows you to override the default fallback settings."] = "Vous permet de passer outre les param\195\168tres de rabat par d\195\169faut.",
	["Allows you to override the default items per auction."] = "Vous permet de passer outre les param\195\168tres de taille de la pile d'objets par ench\195\168re par d\195\169faut.",
	["Allows you to override the default post cap settings."] = "Vous permet de passer outre les param\195\168tres de plafond par d\195\169faut.",
	["Allows you to override the default post time settings."] = "Vous permet de passer outre les param\195\168tres de dur\195\169e des ench\195\168res par d\195\169faut.",
	["Allows you to override the default threshold settings."] = "Vous permet de passer outre les param\195\168tres de seuil par d\195\169faut.",
	["Allows you to override the default undercut settings."] = "Vous permet de passer outre les param\195\168tres de concurrence par d\195\169faut.",
	["Are you sure you want to delete this group?"] = "Etes-vous s?r de vouloir supprimer ce groupe ?",
	["Auction House must be visible for you to use this."] = "L'H\195\180tel des Ventes doit vous \195\170tre visible pour utiliser cela.",
	["Auto mail"] = "Courrier automatique",
	["Automatically mails items to your banker if you set a bank name.\n\n[WARNING!] There is no confirmation once it starts mailing, if you enter the wrong banker name it's your own fault."] = "Envoie automatiquement les objets par courrier \195\160 votre banquier si vous en avez d\195\169fini un.\n\n[ATTENTION !] Il n'y a pas de confirmation demand\195\169e, si vous entrez un mauvais nom pour le banquier c'est votre responsabilit\195\169.",
	["Automatically posts auctions at the fallback price if the lowest item in the auction house is below the threshold price."] = "Cr\195\169\195\169 automatiquement les ench\195\168res au prix de rabat si le prix le moins cher \195\160 l'h\195\180tel des ventes est en-dessous du seuil de prix.",
	["Banker name"] = "Nom du banquier",
	["Bid percent"] = "Pourcentage du prix de d\195\169part",
	["Bracer"] = "brassards",
	["Bracers"] = "brassards",
	["Cancel"] = "Annuler",
	["Cancel auctions with bids"] = "Annuler en cas d'ench\195\168res",
	["Cancelled %s"] = "%s annul\195\169s",
	["Cancelling |cfffed000%d|r of |cfffed000%d|r"] = "Annulation de |cfffed000%d|r sur |cfffed000%d|r",
	["Cancels any posted auctions that you were undercut on."] = "Annule toutes les ench\195\168res sur lesquelles vous vous \195\170tes fait concurrencer.",
	["Cannot cancel auctions without the Auction House window open."] = "Impossible d'annuler les ench\195\168res sans avoir la fen\195\170tre de l'H\195\180tel des Ventes ouverte.",
	["Cannot find class index. QA still needs to be localized into %s for this feature to work."] = "Impossible de trouver l'index de type. QA doit \195\170tre localis\195\169 en %s pour faire fonctionner cela.",
	["Cannot find data for %s."] = "Impossible de trouver des donn\195\169es pour %s.",
	["Click an item to add it to this group, you cannot add an item that is already in another group.\n\nYou can enter a search and it will automatically add any item from your inventory that matches the filter."] = "Cliquez sur un objet pour l'ajouter \195\160 ce groupe, vous ne pouvez pas ajouter un objet qui est d\195\169j\195\160 dans un autre grouper.\n\nVous pouvez saisir une recherche; cela ajoutera automatiquement tous les objets dans votre inventaire qui correspondent au filtre.",
	["Click an item to remove it from this group."] = "Cliquez sur un objet pour le supprimer de ce groupe.",
	["Consumable"] = "Consommable",
	["Could not post all auctions, ran out of space."] = "Impossible de mettre en vente toutes les ench\195\168res, l'inventaire est plein.",
	["Craft queue help"] = "Aide",
	["Creates a new group in Quick Auctions."] = "Cr\195\169\195\169 un nouveau groupe dans Quick Auctions.",
	["Default auction settings"] = "Param\195\168tres par d\195\169faut",
	["Delete"] = "Supprimer",
	["Disable cancelling"] = "D\195\169sactiver l'annulation",
	["Disables automatically cancelling items if they are undercut and in this group."] = "D\195\169sactive l'annulation automatique des objets de ce groupe si ils sont concurrenc\195\169s.",
	["Disables cancelling of auctions with a market price below the threshold, also will cancel auctions if you are the only one with that item up and you can relist it for more."] = "D\195\169sactive l'annulation des ench\195\168res avec un prix du march\195\169 en dessous du seuil, et annule les ench\195\168res si vous \195\170tes le seul sur le march\195\169 et que vous pouvez le vendre plus cher.",
	["Displays the Quick Auctions log describing what it's currently scanning, posting or cancelling."] = "Affiche le log de Quick Auctions qui d\195\169crit les recherches, les mises en vente ou les annulations.",
	["Does a status scan that helps to identify auctions you can buyout to raise the price of a group your managing.\n\nThis will NOT automatically buy items for you, all it tells you is the lowest price and how many are posted."] = "Effectue une analyse qui vous aide \195\160 identifier les ench\195\168res que vous pouvez racheter pour augmenter le prix d'objets que vous g\195\169rez.\n\nCela n'ach\195\168teras PAS les objets pour vous, vous verrez uniquement le prix le moins cher et combien il y en a.",
	["Either your inventory is empty, or all of the items inside it are already listed in other groups."] = "Soit votre inventaire est vide, soit tous les objets sont d\195\169j\195\160 ajout\195\169s dans d'autres groupes.",
	["Elemental"] = "\195\137l\195\169mentaire",
	["Elixir"] = "\195\137lixir",
	["Elixirs"] = "\195\137lixirs",
	["Enable auto fallback"] = "Activer le rabat automatique",
	["Enable auto mail"] = "Activer le courrier automatique",
	["Enables Quick Auctions auto mailer, the last patch of mails will take ~10 seconds to send.\n\n[WARNING!] You will not get any confirmation before it starts to send mails, it is your own fault if you mistype your bankers name."] = "Active le courrier automatique, qui prendra ~10 secondes \195\160 envoyer.\n\n[ATTENTION !] Il n'y a pas de confirmation demand\195\169e, si vous entrez un mauvais nom pour le banquier c'est votre responsabilit\195\169.",
	["Enchant materials"] = "Composants d'enchant.",
	["Enchant scrolls"] = "Parchemins d'enchant.",
	["Enchanting"] = "Enchantement",
	["Fallback after"] = "Rabat au del\195\160 de",
	["Fallback price"] = "Prix de rabat",
	["Finished cancelling |cfffed000%d|r auctions"] = "Annulation de |cfffed000%d|r ench\195\168res termin\195\169e",
	["Finished posting |cfffed000%d|r items"] = "Cr\195\169ation de |cfffed000%d|r ench\195\168res termin\195\169e",
	["Finished status report"] = "Analyse termin\195\169e",
	["Flask"] = "Flacon",
	["Flasks"] = "Flacons",
	["Food"] = "Nourriture",
	["Food & Drink"] = "Nourriture & boissons",
	["Gem"] = "Gemme",
	["Gems"] = "Gemmes",
	["General"] = "G\195\169n\195\169ral",
	["Get Data"] = "Rechercher",
	["Glyph"] = "Glyphe",
	["Glyphs"] = "Glyphes",
	["Group name"] = "Nom du groupe",
	["Groups are both how you list items to be managed by Quick Auctions as well as giving you finer control for auction configuration.\n\nYou cannot have the same item in multiple groups at the same time."] = "Les groupes sont un regroupement d'objets \195\160 faire g\195\169rer par Quick Auctions et permettent \195\169galement un contr\195\180le plus fin de la configuration des ench\195\168res.\n\nVous ne pouvez pas avoir le m\195\170me objet dans plusieurs groupes en m\195\170me temps.",
	["Help"] = "Aide",
	["Herb"] = "Herbes",
	["Herbs"] = "Herbes",
	["Hide uncraftables"] = "Masquer les infaisables",
	["How long auctions should be posted for."] = "Dur\195\169e des ench\195\168res.",
	["How many auctions of the same item should be up at any one time.\n\nNote that post cap only applies if you weren't undercut, if you were undercut you can post more until you hit the post cap."] = "D\195\169finit combien d'ench\195\168res d'un m\195\170me objet doivent \195\170tre cr\195\169\195\169es en m\195\170me temps.\n\nNotez que ce plafond ne peut s'appliquer que si vous n'\195\170tes pas concurrenc\195\169, sinon vous pouvez en cr\195\169er plus jusqu'\195\160 atteindre le plafond.",
	["How many items each auction should contain, if the item cannot stack it will always post at least one item."] = "D\195\169finit combien d'objets chaque ench\195\168re doit contenir, si l'objet est empilable.",
	["How much auctions should be undercut."] = "D\195\169finit de combien les ench\195\168res doivent \195\170tre baiss\195\169es pour la concurrence.",
	["If someone posts an item at a percentage higher than the fallback, it will automatically use the fallback price instead.\n\nFor example, fallback is 100g, fallback after is set to 50% if someone posts an item at 160g it will fallback to 100g."] = "Si quelqu'un cr\195\169\195\169 une ench\195\168re \195\160 un pourcentage sup\195\169rieur \195\160 celui-ci, utilise automatiquement le prix de rabat.\n\nPar exemple, si le rabat est de 100 PO et le pourcentage de 50%, si quelqu'un cr\195\169\195\169 une ench\195\168re \195\160 160 PO, le prix sera rabattu \195\160 100 PO.",
	["Invalid money format entered for \"%s\""] = "Mauvais format de monnaie pour \"%s\"",
	["Invalid time entered, should either be 12 or 2 you entered \"%s\""] = "Mauvaise dur\195\169e saisie, doit \195\170tre 12 ou 2, vous avez saisi \"%s\"",
	["Item Enhancement"] = "Am\195\169lioration d'objet",
	["Item data not found, you will need to see this item before the name is shown."] = "Les donn\195\169es de l'objet ne peuvent pas \195\170tre trouv\195\169es, vous devez voir cet objet avant que son nom ne s'affiche.",
	["Item groups"] = "Groupes d'objets",
	["Items"] = "Objets",
	["Items in your inventory (and only your inventory) that match the filter will be added to this group."] = "Les objets dans votre inventaire (et uniquement votre inventaire) qui correspondent au filtre seront ajout\195\169s \195\160 ce groupe.",
	["Items per auction"] = "Taille de la pile",
	["List"] = "Liste",
	["Log"] = "Log",
	["Log (%d)"] = "Log (%d)",
	["Mass cancelling posted items"] = "Annulation en masse des ench\195\168res",
	["Mass cancelling posted items in the group |cfffed000%s|r"] = "Annulation en masse des ench\195\168res du groupe |cfffed000%s|r",
	["Mass cancelling posted items with less than %d hours left"] = "Annulation en masse des ench\195\168res d'une dur\195\169e inf\195\169rieure \195\160 %d heures",
	["Materials required"] = "Composants requis",
	["Name of your banker on this realm/faction, this is where items will be mailed if you have any items to auto mail."] = "Le nom de votre banquier sur ce royaume/cette faction, \195\160 qui les objets seront envoy\195\169s si vous avez configur\195\169 le courrier automatique.",
	["No"] = "Non",
	["No auctions or inventory items found that are managed by Quick Auctions that can be scanned."] = "Aucune ench\195\168res ou objets g\195\169r\195\169s par Quick Auctions ne peuvent \195\170tre analys\195\169s.",
	["No group named %s exists."] = "Il n'y a pas de groupe %s.",
	["No player name entered."] = "Pas de nom de joueur saisi.",
	["None posted by yourself"] = "Aucune cr\195\169\195\169e par vous",
	["Not all your auctions were posted, ran out of space to split items even after waiting 10 seconds."] = "Toutes vos ench\195\168res n'ont pas pu \195\170tre cr\195\169\195\169es, l'inventaire est trop plein pour s\195\169parer les objets, m\195\170me apr\195\168s avoir attendu 10 secondes.",
	["Nothing to cancel"] = "Rien \195\160 annuler",
	["Nothing to cancel, you have no unsold auctions up."] = "Rien \195\160 annuler, vous n'avez actuellement pas d'ench\195\168res non vendues.",
	["Nothing to post"] = "Aucune ench\195\168re \195\160 cr\195\169er",
	["Override auto fallback"] = "Passer outre le rabat automatique",
	["Override auto mail"] = "Passer outre le courrier automatique",
	["Override bid percent"] = "Passer outre le prix de d\195\169part",
	["Override fallback"] = "Passer outre le rabat",
	["Override fallback after"] = "Passer outre le pourcentage de rabat",
	["Override per auction"] = "Passer outre la taille de la pile",
	["Override post cap"] = "Passer outre le plafond",
	["Override post time"] = "Passer outre la dur\195\169e",
	["Override threshold"] = "Passer outre le seuil",
	["Override undercut"] = "Passer outre le prix de concurrence",
	["Percentage of the buyout the bid will be set at, if the buyout is 100g and set you set this to 90%, then the bid will be 90g."] = "Pourcentage du prix d'achat auquel le prix de d\195\169part sera d\195\169fini, si le prix d'achat est 100 PO et que c'est d\195\169fini \195\160 90%, le prix de d\195\169part sera de 90 PO.",
	["Perfect (.+)"] = "(.+) parfait",
	["Player name"] = "Nom du joueur",
	["Post"] = "Cr\195\169er",
	["Post cap"] = "Plafond",
	["Post items from your inventory into the auction house."] = "Cr\195\169er les ench\195\168res des objets dans votre inventaire.",
	["Post time"] = "Dur\195\169e des ench\195\168res",
	["Posting %s%s (%d/%d) bid %s, buyout %s"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s",
	["Posting %s%s (%d/%d) bid %s, buyout %s (Buyout went below zero, undercut by 1 copper instead)"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s (Prix d'achat en dessous de 0, concurrencer de 1 PC)",
	["Posting %s%s (%d/%d) bid %s, buyout %s (Forced to fallback price, lowest price was too high)"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s (Ramen\195\169 au prix de rabat, le prix le moins cher \195\169tait trop \195\169lev\195\169)",
	["Posting %s%s (%d/%d) bid %s, buyout %s (Forced to fallback price, market below threshold)"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s (Ramen\195\169 au prix de rabat, le prix du march\195\169 est inf\195\169rieur au seuil)",
	["Posting %s%s (%d/%d) bid %s, buyout %s (Increased bid price due to going below thresold)"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s (Augmentation du prix de d\195\169part pour ne pas passer sous le seuil)",
	["Posting %s%s (%d/%d) bid %s, buyout %s (No other auctions up)"] = "Ench\195\168re pour %s%s (%d/%d) prix de d\195\169part %s, prix d'achat %s (Pas d'autres ench\195\168res)",
	["Posting interrupted due to Auction House being closed"] = "Interruption de la cr\195\169ation d'ench\195\168res \195\160 cause de la fermeture de l'H\195\180tel des Ventes",
	["Posting was interrupted due to the Auction House was closed."] = "Interruption de la cr\195\169ation d'ench\195\168res \195\160 cause de la fermeture de l'H\195\180tel des Ventes.",
	["Price items should be posted at if there are no others of it's kind on the auction house."] = "Le prix auquel les ench\195\168res doivent \195\170tre cr\195\169\195\169es si il n'y a pas de concurrence.",
	["Prices will be rounded to the nearest gold piece when undercutting, meaning instead of posting an auction for 1 gold and 50 silver, it would be posted for 1 gold."] = "Les prix seront tronqu\195\169s \195\160 la pi\195\168ce d'or pr\195\168s, ce qui veut dire qu'\195\160 la place de cr\195\169er une ench\195\168re pour 1 or et 50 argent, elle sera cr\195\169\195\169 pour 1 or.",
	["Queued %s to be posted"] = "Mise en file de %s",
	["Queued %s to be posted (Cap is |cffff2020%d|r, only can post |cffff2020%d|r need to restock)"] = "Mise en file de %s (le plafond est de |cffff2020%d|r, |cffff2020%d|r peuvent \195\170tre cr\195\169\195\169es, besoin de refaire le stock)",
	["Quick Auctions"] = "Quick Auctions",
	["Remove"] = "Supprimer",
	["Remove items"] = "Supprimer",
	["Reset craft queue"] = "R\195\169initialiser",
	["Reset the craft queue list for every item."] = "R\195\169initialiser la file d'attente d'artisanat pour tous les objets.",
	["Retry |cfffed000%d|r of |cfffed000%d|r for %s"] = "Nouvelle tentative |cfffed000%d|r sur |cfffed000%d|r pour %s",
	["Scan finished!"] = "Analyse termin\195\169e !",
	["Scan interrupted before it could finish"] = "Analyse interrompue avant qu'elle n'ait pu aboutir",
	["Scan interrupted due to Auction House being closed."] = "Analyse interrompue \195\160 cause de la fermeture de l'H\195\180tel des Ventes.",
	["Scanned page |cfffed000%d|r of |cfffed000%d|r for %s"] = "Page |cfffed000%d|r sur |cfffed000%d|r analys\195\169e pour %s",
	["Scanning %s"] = "Analyse de %s",
	["Scanning page |cfffed000%d|r of |cfffed000%d|r for %s"] = "Analyse de la page |cfffed000%d|r sur |cfffed000%d|r pour %s",
	["Scanning |cfffed000%d|r items..."] = "Analyse de |cfffed000%d|r objets...",
	["Scroll of (.+)"] = "Parchemin d'?e? ?(.+)",
	["Scroll of Enchant (.+)"] = "Parchemin d'enchantement d'?e? ?(.+)",
	["Scroll of Enchant (.+) %- .+"] = "Parchemin d'enchantement d'?e? ?(.+) %(.+%)",
	["Show craft queue"] = "Afficher file",
	["Show uncraftables"] = "Afficher les infaisables",
	["Shows information on how to use the craft queue"] = "Affiche les informations sur l'utilisation de la file d'attente d'artisanat",
	["Simple"] = "simple",
	["Skipped %s lowest buyout is %s threshold is %s"] = "%s ignor\195\169, le prix d'achat le moins cher est %s, le seuil est %s",
	["Skipped %s need |cff20ff20%d|r for a single post, have |cffff2020%d|r"] = "%s ignor\195\169, une ench\195\168re doit compter |cff20ff20%d|r, dispose de |cffff2020%d|r",
	["Skipped %s posted |cff20ff20%d|r of |cff20ff20%d|r already"] = "%s ignor\195\169, |cff20ff20%d|r sur |cff20ff20%d|r ench\195\168res d\195\169j\195\160 cr\195\169\195\169es",
	["Skipped cancelling %s flagged to not be canelled."] = "Annulation ignor\195\169e pour %s, marqu\195\169 pour ne pas l'\195\170tre.",
	["Skipped cancelling %s flagged to post at fallback when market is below threshold."] = "Annulation ignor\195\169e pour %s, marqu\195\169 pour \195\170tre cr\195\169\195\169e au prix de rabat quand le prix du march\195\169 est inf\195\169rieur au seuil.",
	["Slash commands"] = "Commandes Slash",
	["Smart cancelling"] = "Annulation maline",
	["Smart undercutting"] = "Concurrence maline",
	["Starting to cancel..."] = "D\195\169marrage de l'annulation...",
	["Starting to split and post items..."] = "D\195\169marrage de la s\195\169paration des piles et de la cr\195\169ation d'ench\195\168res...",
	["Status"] = "Statut",
	["Stop"] = "Stop",
	["Stopped splitting due to Auction House frame being closed."] = "S\195\169partion des piles arr\195\170t\195\169e \195\160 cause de la fermeture de l'H\195\180tel des Ventes.",
	["Summary"] = "R\195\169sum\195\169",
	["The %s group does not have any items in it yet."] = "Le groupe %s n'a encore aucun objet.",
	["The craft queue in Quick Auctions is a way of letting you queue up a list of items that can then be seen in that professions Tradeskill window, or through /qa tradeskill with a tradeskill open.\n\n|cffff2020**NOTE**|r This does not work with the enchant scroll category.\nQueues are setup through the summary window by holding SHIFT + double clicking an item in the summary.\n\nFor example: If you want to cut 20 |cff0070dd[Insightful Earthsiege Diamond]|r you SHIFT + double click the |cff0070dd[Insightful Earthsiege Diamond]|r text in the summary window, it will then show\n\n|cfffed0000 x|r Insightful Earthsiege Diamond|r\n\nThis tells you that it is ready and you can input how many you want, once you are done setting how many you want to make hit ENTER. If you were to enter 20 it will now look like\n\n0 x |cff20ff202Insightful Earthsiege Diamond|r\nAnd you're done! Once you open the Jewelcrafting Tradeskill window you will see a frame pop up with\n\n|cff0070dd[Insightful Earthsiege Diamond]|r [20]\n\nIf you click that text you will create 20 |cff0070dd[Insightful Earthsiege Diamond]|r providing you have the materials"] = "La file d'attente d'artisanat de Quick Auctions est un moyen de conserver une liste d'objets qui peut \195\170tre vue depuis la fen\195\170tre de profession, ou gr\195\162ce \195\160 la commande /qa tradeskill.\n\n|cffff2020**NOTE**|r Cela ne marche pas pour les parchemins d'enchantement.\nLa file est d\195\169finie depuis la fen\195\170tre de r\195\169sum\195\169 en maintenant SHIFT + double clic sur un objet.\n\nPar exemple : si vous voulez faire 20 |cff0070dd[Diamant si\195\168geterre flambant]|r vous faites SHIFT + double clic sur le texte |cff0070dd[Diamant si\195\168geterre flambant]|r dans la fen\195\170tre de r\195\169sum\195\169, cela affichera alors\n\n|cfffed0000 x|r Diamant si\195\168geterre flambant|r\n\nCela vous indique que vous pouvez saisir le nombre que vous d\195\169sirez, puis tapez sur la touche ENTER. Si vous avez saisi 20, le texte sera alors\n\n20 x |cff20ff20Diamant si\195\168geterre flambant|r\nEt voil\195\160 ! Quand vous ouvrirez la fen\195\170tre de joiallerie, vous verrez une fen\195\170tre avec \n\n|cff0070dd[Diamant si\195\168geterre flambant]|r [20]\n\nSi vous cliquez sur ce texte, cela cr\195\169era 20 |cff0070dd[Diamant si\195\168geterre flambant]|r si vous avez les composants n\195\169cessaires",
	["The group \"%s\" already exists."] = "Le groupe \"%s\" existe d\195\169j\195\160.",
	["The price at which an auction won't be posted, meaning if you set this to 10g then no auctions posted through Quick Auctions will go below 10g."] = "Le prix auquel une ench\195\168re ne sera pas cr\195\169\195\169, ce qui signifie que si vous d\195\169finissez ce prix \195\160 10 PO, alors aucune ench\195\168re cr\195\169\195\169e avec Quick Auctions n'aura de prix inf\195\169rieur \195\160 10 PO.",
	["Threshold price"] = "Prix de seuil",
	["Toggles hiding items you cannot craft in the summary window."] = "Masque / affiche les objets que vous ne pouvez pas cr\195\169er dans la fen\195\170tre de r\195\169sum\195\169.",
	["Toggles the craft queue window"] = "Masque / afficher la file d'attente d'artisanat",
	["Trade Goods"] = "Artisanat",
	["Undercut by"] = "Concurrenc\195\169 par",
	["Undercut on %s by |cfffed000%s|r, but %s placed a bid of %s so not cancelling"] = "Concurrenc\195\169 sur %s par |cfffed000%s|r, mais %s a ench\195\169ri pour %s donc pas d'annulation",
	["Undercut on %s by |cfffed000%s|r, buyout %s, yours %s (per item)"] = "Concurrenc\195\169 sur %s par |cfffed000%s|r, prix d'achat \195\160 %s, le votre \195\160 %s (par objet)",
	["Undercut on %s by |cfffed000%s|r, their buyout %s, yours %s (per item), threshold is %s not cancelling"] = "Concurrenc\195\169 sur %s par |cfffed000%s|r, prix d'achat \195\160 %s, le votre \195\160 %s (par objet), le seuil est \195\160 %s pas d'annulation",
	["View a summary of what the highest selling of certain items is."] = "Affiche un r\195\169sum\195\169 des ventes de certains objets.",
	["Whistlists give you a way of setting others users who Quick Auctions should not undercut; however, if they match your buyout and undercut your bid they will still be considered undercutting.\n\nWhile your alts are not shown in this list, your alts will be considered yourself automatically."] = "La liste blanche vous donne un moyen de d\195\169finir d'autres joueurs que Quick Auctions ne doit pas concurrencer; cependant, si ils ont le m\195\170me prix d'achat que vous et concurrencent votre prix de d\195\169part, ils seront toujours consid\195\169r\195\169s comme des concurrents.\n\nVos autres personnages sont automatiquement consid\195\169r\195\169s comme vous-m\195\170me tant qu'ils ne figurent pas dans cette liste.",
	["Whitelist"] = "Liste blanche",
	["Will cancel your auctions even if they have a bid on them."] = "Annulera vos ench\195\168res m\195\170me si quelqu'un \195\160 d\195\169j\195\160 ench\195\169ri.",
	["Yes"] = "Oui",
	["You are the only one posting %s, the fallback is %s (per item), cancelling so you can relist it for more gold"] = "Vous \195\170tes le seul \195\160 cr\195\169er une ench\195\168re pour %s, le rabat est de %s (par objet), annulation pour que vous puissiez le vendre plus cher",
	["You can set the fallback settings to use for items that do not have one set specifically for their group, or per item.\n\nMoney values should be entered as \"#g#s#c\". For example, \"50g20s\" is entered as 50 gold, 20 silver."] = "Vous pouvez d\195\169finir le rabat pour les objets qui n'en ont pas un sp\195\169cifique dans leurs groupes, ou par objet.\n\nLes valeurs en monnaies doivent \195\170tre saisies de cette mani\195\168re : \"#g#s#c\". Par exemple, \"50g20s\" est saisi pour 50 pi\195\168ces d'or, 20 pi\195\168ces d'argent.",
	["You cannot use auto mailer on your banker as you cannot mail items to yourself."] = "Vous ne pouvez pas utiliser le courrier automatique car vous ne pouvez pas vous envoyer de courrier \195\160 vous-m\195\170me.",
	["You do not have any items to post"] = "Vous n'avez aucun objet \195\160 mettre en vente",
	["You have nobody on your whitelist yet."] = "Vous n'avez encore personne dans votre liste blanche.",
	["You have to set a banker before you can use the auto mailer."] = "Vous devez d\195\169finir un banquier avant d'utiliser le courrier automatique.",
	["\n\n%d in inventory\n%d on the Auction House"] = "\n\n%d dans l'inventaire\n%d \195\160 l'H\195\180tel des Ventes",
	["lowest price"] = "prix le plus bas",
	["undercut"] = "concurrenc\195\169",
}, {__index = QuickAuctions.L})