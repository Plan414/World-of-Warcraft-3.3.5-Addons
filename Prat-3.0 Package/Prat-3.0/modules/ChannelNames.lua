---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc., 
-- 51 Franklin Street, Fifth Floor, 
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------



--[[
Name: PratChannelNames
Revision: $Revision: 80975 $
Author(s): Curney (asml8ed@gmail.com)
           Krtek (krtek4@gmail.com)
           Sylvanaar (sylvanaar@mindspring.com)
Inspired by: idChat2_ChannelNames by Industrial
Website: http://www.wowace.com/files/index.php?path=Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#ChannelNames
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Description: Module for Prat that options for replacing channel names with abbreviations.
Dependencies: Prat
]]

Prat:AddModuleToLoad(function() 

local PRAT_MODULE = Prat:RequestModuleName("ChannelNames")

if PRAT_MODULE == nil then 
    return 
end

-- define localized strings
local L = Prat:GetLocalizer({})

--[===[@debug@
L:AddLocale("enUS", {
    ["ChannelNames"] = true,
    ["Channel name abbreviation options."] = true,
    ["Replace"] = true,
    ["Toggle replacing this channel."] = true,
    ["Blank"] = true,
    ["Dont display the channel/chat type name"] = true,
    ["Set"] = true,
    ["Channel %d"] = true,
    ["%s settings."] = true,
    ["Use a custom replacement for the chat %s text."] = true,
    
	["channelnick_name"] = "Channel Abbreviations",
	["channelnick_desc"] = "Channel Abbreviations",

    ["Add Channel Abbreviation"] = true,
    ["addnick_desc"] = "Adds an abbreviated channel name. Prefix the name with '#' to include the channel number. (e.g. '#Trade').",
    ["Remove Channel Abbreviation"] = true,
    ["Removes an an abbreviated channel name."] = true,    
    ["Clear Channel Abbreviation"] = true,
    ["Clears an abbreviated channel name."] = true,

	["otheropts_name"] = "Other Options",
	["otheropts_desc"] = "Additional channel formating options, and channel link controls.",

    ["space_name"] = "Show Space",
    ["space_desc"] = "Toggle adding space after channel replacement.",
    ["colon_name"] = "Show Colon",
    ["colon_desc"] = "Toggle adding colon after channel replacement.",

    ["chanlink_name"] = "Create Channel Link",
    ["chanlink_desc"] = "Make the channel a clickable link which opens chat to that channel.",
	
    ["<string>"] = true,
})
--@end-debug@]===]

-- These Localizations are auto-generated. To help with localization
-- please go to http://www.wowace.com/projects/prat-3-0/localization/


--@non-debug@
L:AddLocale("enUS", 
{
	["%s settings."] = true,
	["<string>"] = true,
	["Add Channel Abbreviation"] = true,
	Blank = true,
	["Channel %d"] = true,
	["Channel name abbreviation options."] = true,
	ChannelNames = true,
	["Clear Channel Abbreviation"] = true,
	["Clears an abbreviated channel name."] = true,
	["Dont display the channel/chat type name"] = true,
	["Remove Channel Abbreviation"] = true,
	["Removes an an abbreviated channel name."] = true,
	Replace = true,
	Set = true,
	["Toggle replacing this channel."] = true,
	["Use a custom replacement for the chat %s text."] = true,
	addnick_desc = "Adds an abbreviated channel name. Prefix the name with '#' to include the channel number. (e.g. '#Trade').",
	chanlink_desc = "Make the channel a clickable link which opens chat to that channel.",
	chanlink_name = "Create Channel Link",
	channelnick_desc = "Channel Abbreviations",
	channelnick_name = "Channel Abbreviations",
	colon_desc = "Toggle adding colon after channel replacement.",
	colon_name = "Show Colon",
	otheropts_desc = "Additional channel formating options, and channel link controls.",
	otheropts_name = "Other Options",
	space_desc = "Toggle adding space after channel replacement.",
	space_name = "Show Space",
}

)
L:AddLocale("frFR",  
{
	["%s settings."] = "Options pour %s .",
	["<string>"] = "<cha??ne>",
	["Add Channel Abbreviation"] = "Ajouter une abr??viation",
	-- Blank = "",
	["Channel %d"] = "Canal %d",
	["Channel name abbreviation options."] = "Options d'abr??viations des noms de canaux.",
	ChannelNames = "Noms des canaux",
	-- ["Clear Channel Abbreviation"] = "",
	-- ["Clears an abbreviated channel name."] = "",
	-- ["Dont display the channel/chat type name"] = "",
	-- ["Remove Channel Abbreviation"] = "",
	-- ["Removes an an abbreviated channel name."] = "",
	Replace = "Remplacer",
	-- Set = "",
	["Toggle replacing this channel."] = "Active/D??sactive le texte de remplacement pour ce canal.",
	["Use a custom replacement for the chat %s text."] = "Utiliser un texte de remplacement pour le canal %s.",
	addnick_desc = "Ajoute une abr??viation pour le nom de ce canal. Pr??fixer le nom avec '#' permet d'inclure le num??ro du canal. (Exemple : '#Commerce')",
	-- chanlink_desc = "",
	-- chanlink_name = "",
	channelnick_desc = "Abr??viations des noms des canaux.",
	channelnick_name = "Abr??viations",
	-- colon_desc = "",
	-- colon_name = "",
	otheropts_desc = "Options suppl??mentaires du formatage des noms de canaux.",
	otheropts_name = "Autres options",
	-- space_desc = "",
	-- space_name = "",
}

)
L:AddLocale("deDE", 
{
	["%s settings."] = "%s -Einstellungen.",
	["<string>"] = true,
	["Add Channel Abbreviation"] = "Hinzuf??gen einer Kanal-Abk??rzung",
	Blank = "Leer",
	["Channel %d"] = "Kanal %d",
	["Channel name abbreviation options."] = "Optionen zu Kanalnamen-Abk??rzungen.",
	ChannelNames = "Channel-Namen",
	["Clear Channel Abbreviation"] = "Channel-Abk??rzung l??schen",
	["Clears an abbreviated channel name."] = "L??scht die Abk??rzung eines Kanals",
	["Dont display the channel/chat type name"] = "Name des Kanal-/Chat-Typs nicht anzeigen",
	["Remove Channel Abbreviation"] = "Kanal-Abk??rzung entfernen",
	["Removes an an abbreviated channel name."] = "Entfernt einen abgek??rzten Kanalnamen.",
	Replace = "Ersetzen",
	Set = "Setzen",
	["Toggle replacing this channel."] = "Ersetzen f??r diesen Kanal ein-/ausschalten.",
	["Use a custom replacement for the chat %s text."] = "Benutze einen allgemein ??blichen Ersatz f??r den Text des Chats %s.",
	addnick_desc = "F??gt einen abgek??rzten Kanalnamen hinzu. F??ge den Vorsatz '#' dem Namen hinzu, um die Nummer des Kanals mit anzuzeigen (z.B. '#Handel')",
	chanlink_desc = "Den Kanal zu einem anklickbaren Link machen, der den Chat zu diesem Kanal ??ffnet.",
	chanlink_name = "Kanal-Link erstellen",
	channelnick_desc = "Kanalabk??rzungen",
	channelnick_name = "Kanalabk??rzungen",
	colon_desc = "Hinzuf??gen eines Doppelpunkts nach dem Ersetzen des Kanals ein-/ausschalten.",
	colon_name = "Doppelpunkt anzeigen",
	otheropts_desc = "Weitere Formatierungsoptionen f??r die Kan??le, sowie Steuerung der Kanal-Links.",
	otheropts_name = "Weitere Optionen",
	space_desc = [=[Hinzuf??gen eines Leerzeichens nach dem Ersetzen des Kanals ein-/ausschalten.
]=],
	space_name = "Leerzeichen anzeigen",
}

)
L:AddLocale("koKR",  
{
	["%s settings."] = "%s ??????.",
	["<string>"] = "<??????>",
	["Add Channel Abbreviation"] = "?????? ?????? ?????? ??????",
	Blank = "??????",
	["Channel %d"] = "?????? %d",
	["Channel name abbreviation options."] = "?????? ?????? ????????? ??????.",
	ChannelNames = "?????? ??????",
	-- ["Clear Channel Abbreviation"] = "",
	-- ["Clears an abbreviated channel name."] = "",
	-- ["Dont display the channel/chat type name"] = "",
	-- ["Remove Channel Abbreviation"] = "",
	-- ["Removes an an abbreviated channel name."] = "",
	Replace = "??????",
	-- Set = "",
	["Toggle replacing this channel."] = "??? ?????? ?????? ????????????",
	-- ["Use a custom replacement for the chat %s text."] = "",
	addnick_desc = "?????? ?????? ????????? ??????. ?????? ????????? #??? ????????? ?????? ????????? ???????????????. (???. '#??????').",
	-- chanlink_desc = "",
	chanlink_name = "?????? ?????? ?????????",
	channelnick_desc = "?????? ?????? ????????????",
	channelnick_name = "?????? ?????? ????????????",
	colon_desc = "?????? ?????? ?????? ?????? ?????? ??????",
	colon_name = "?????? ?????????",
	-- otheropts_desc = "",
	otheropts_name = "?????? ??????",
	-- space_desc = "",
	space_name = "?????? ?????????",
}

)
L:AddLocale("esMX",  
{
	-- ["%s settings."] = "",
	-- ["<string>"] = "",
	-- ["Add Channel Abbreviation"] = "",
	-- Blank = "",
	-- ["Channel %d"] = "",
	-- ["Channel name abbreviation options."] = "",
	-- ChannelNames = "",
	-- ["Clear Channel Abbreviation"] = "",
	-- ["Clears an abbreviated channel name."] = "",
	-- ["Dont display the channel/chat type name"] = "",
	-- ["Remove Channel Abbreviation"] = "",
	-- ["Removes an an abbreviated channel name."] = "",
	-- Replace = "",
	-- Set = "",
	-- ["Toggle replacing this channel."] = "",
	-- ["Use a custom replacement for the chat %s text."] = "",
	-- addnick_desc = "",
	-- chanlink_desc = "",
	-- chanlink_name = "",
	-- channelnick_desc = "",
	-- channelnick_name = "",
	-- colon_desc = "",
	-- colon_name = "",
	-- otheropts_desc = "",
	-- otheropts_name = "",
	-- space_desc = "",
	-- space_name = "",
}

)
L:AddLocale("ruRU",  
{
	["%s settings."] = "?????????????????? %s.",
	["<string>"] = true,
	["Add Channel Abbreviation"] = "???????????????? ???????????????????? ????????????",
	Blank = "????????????",
	["Channel %d"] = "?????????? %d",
	["Channel name abbreviation options."] = "?????????????????? ???????????????????? ???????????????? ??????????????.",
	ChannelNames = "???????????????? ????????????",
	["Clear Channel Abbreviation"] = "???????????????? ???????????????????? ????????????",
	["Clears an abbreviated channel name."] = "?????????????? ???????????????????? ???????????????? ??????????????.",
	["Dont display the channel/chat type name"] = "???? ???????????????????? ???????????????? ????????????/?????? ????????",
	["Remove Channel Abbreviation"] = "?????????????? ???????????????????? ????????????",
	["Removes an an abbreviated channel name."] = "?????????????? ???????????????????? ???????????????? ??????????????.",
	Replace = "????????????????",
	Set = "????????????",
	["Toggle replacing this channel."] = "???????????????? ???????????? ?????????????? ????????????.",
	["Use a custom replacement for the chat %s text."] = "???????????????????????? ???????????????? ???????????? ???????????? %s ????????????.",
	addnick_desc = "?????????????????? ???????????????????? ???????????????? ??????????????. ?????????????? ???????????????? ?? '#' ???????????????? ?????????? ????????????. (???????????????? '#????????????????').",
	chanlink_desc = "?????????????? ???????????????? ???????????? ??????????????, ???????????? ???? ?????????????? ?????????????????? ???????? ???????? ?????????? ????????????.",
	chanlink_name = "?????????????? ???????????? ???? ??????????",
	channelnick_desc = "???????????????????? ????????????",
	channelnick_name = "???????????????????? ????????????",
	colon_desc = "??????/???????? ???????????????????? ?????????????????? ?????????? ???????????? ????????????.",
	colon_name = "???????????????????? ??????????????????",
	otheropts_desc = "???????????????????????????? ?????????????????? ???????????????????????????? ????????????, ?? ???????????????????? ???????????????? ????????????.",
	otheropts_name = "???????????? ??????????????????",
	space_desc = "??????/???????? ???????????????????? ?????????????? ?????????? ???????????? ????????????.",
	space_name = "???????????????????? ????????????",
}

)
L:AddLocale("zhCN",  
{
	["%s settings."] = "%s ??????.",
	["<string>"] = "<?????????>",
	["Add Channel Abbreviation"] = "??????????????????",
	Blank = "??????",
	["Channel %d"] = "?????? %d",
	["Channel name abbreviation options."] = "????????????????????????",
	ChannelNames = "????????????",
	["Clear Channel Abbreviation"] = "??????????????????",
	["Clears an abbreviated channel name."] = "??????????????????????????????",
	["Dont display the channel/chat type name"] = "??????????????????/??????????????????",
	["Remove Channel Abbreviation"] = "??????????????????",
	["Removes an an abbreviated channel name."] = "??????????????????????????????",
	Replace = "??????",
	Set = "??????",
	["Toggle replacing this channel."] = "????????????",
	["Use a custom replacement for the chat %s text."] = "?????????????????????????????? %s ??????",
	addnick_desc = "?????????????????????????????????.??????????????? '#' ?????????????????????(??????'#??????')",
	chanlink_desc = "?????????????????????????????????????????????",
	chanlink_name = "??????????????????",
	channelnick_desc = "????????????",
	channelnick_name = "????????????",
	colon_desc = "?????????????????????",
	colon_name = "????????????",
	otheropts_desc = "??????????????????????????????????????????????????????",
	otheropts_name = "????????????",
	space_desc = "?????????????????????",
	space_name = "????????????",
}

)
L:AddLocale("esES",  
{
	["%s settings."] = "opciones %s.",
	["<string>"] = "<cadena>",
	["Add Channel Abbreviation"] = "A??adir Abreviatura del Canal",
	Blank = "Blanco",
	["Channel %d"] = "Canal %d",
	["Channel name abbreviation options."] = "Opciones de abreviatura del nombre del canal.",
	ChannelNames = "NombresCanales",
	["Clear Channel Abbreviation"] = "Limpiar Abreviatura de Canal",
	["Clears an abbreviated channel name."] = "Limpia un nombre de canal abreviado.",
	["Dont display the channel/chat type name"] = "No mostrar el nombre del tipo de canal/chat",
	["Remove Channel Abbreviation"] = "Eliminar Abreviatura de Canal",
	["Removes an an abbreviated channel name."] = "Elimina un nombre de canal abreviado.",
	Replace = "Sustituir",
	Set = "Establecer",
	["Toggle replacing this channel."] = "Alterna reemplazar este canal.",
	["Use a custom replacement for the chat %s text."] = "Utilizarr un reemplazo personalizado para el texto del chat %s.",
	addnick_desc = "Agrega un nombre abreviado del canal. El nombre con '#' para incluir el n??mero de canal. (por ejemplo, '#Comercio').",
	chanlink_desc = "Hacer del canal un v??nculo clickable que abre el chat para ese canal.",
	chanlink_name = "Crear Enlace del Canal",
	channelnick_desc = "Abreviaturas de Canal",
	channelnick_name = "Abreviaturas de Canal",
	colon_desc = "A??ade dos puntos despu??s del canal reemplazado.",
	colon_name = "Mostrar dos puntos",
	otheropts_desc = "Opciones de formato de canal adicionales y controles de enlace del canal.",
	otheropts_name = "Otras Opciones",
	space_desc = "Alternar a??adir un espacio despu??s del canal reemplazado.",
	space_name = "Mostrar Espacio",
}

)
L:AddLocale("zhTW",  
{
	-- ["%s settings."] = "",
	-- ["<string>"] = "",
	["Add Channel Abbreviation"] = "??????????????????",
	Blank = "??????",
	["Channel %d"] = "?????? %d",
	["Channel name abbreviation options."] = "????????????????????????",
	ChannelNames = "????????????",
	["Clear Channel Abbreviation"] = "????????????????????????",
	-- ["Clears an abbreviated channel name."] = "",
	-- ["Dont display the channel/chat type name"] = "",
	["Remove Channel Abbreviation"] = "??????????????????",
	-- ["Removes an an abbreviated channel name."] = "",
	Replace = "??????",
	-- Set = "",
	-- ["Toggle replacing this channel."] = "",
	-- ["Use a custom replacement for the chat %s text."] = "",
	-- addnick_desc = "",
	-- chanlink_desc = "",
	chanlink_name = "??????????????????",
	channelnick_desc = "????????????",
	channelnick_name = "????????????",
	-- colon_desc = "",
	-- colon_name = "",
	-- otheropts_desc = "",
	otheropts_name = "????????????",
	-- space_desc = "",
	-- space_name = "",
}

)
--@end-non-debug@

-- order to show channels
local orderMap = {
        "say",
        "whisper",
        "whisperincome",
        "yell",
        "party",
        "partyleader",
        "partyguide",
        "guild",
        "officer",
        "raid",
        "raidleader",
        "raidwarning",
        "battleground",
        "battlegroundleader",
        "bnwhisper",
        "bnwhisperincome",
        "bnconversation",
}

if not CHAT_MSG_BN_WHISPER_INFORM then 
    CHAT_MSG_BN_WHISPER_INFORM = "Outgoing Real ID Whisper";
end

-- Look Up Our Settings Key event..message.CHANNUM
local eventMap = {
    CHAT_MSG_CHANNEL1 = "channel1",
    CHAT_MSG_CHANNEL2 = "channel2",
    CHAT_MSG_CHANNEL3 = "channel3",
    CHAT_MSG_CHANNEL4 = "channel4",
    CHAT_MSG_CHANNEL5 = "channel5",
    CHAT_MSG_CHANNEL6 = "channel6",
    CHAT_MSG_CHANNEL7 = "channel7",
    CHAT_MSG_CHANNEL8 = "channel8",
    CHAT_MSG_CHANNEL9 = "channel9",
--    CHAT_MSG_CHANNEL10 = "channel10",
    CHAT_MSG_SAY = "say",
    CHAT_MSG_GUILD = "guild",
    CHAT_MSG_WHISPER = "whisperincome",
    CHAT_MSG_WHISPER_INFORM = "whisper",
    CHAT_MSG_BN_WHISPER = "bnwhisperincome",
    CHAT_MSG_BN_WHISPER_INFORM = "bnwhisper",
    CHAT_MSG_YELL = "yell",
    CHAT_MSG_PARTY = "party",
    CHAT_MSG_PARTY_LEADER = "partyleader",
    CHAT_MSG_PARTY_GUIDE = "partyguide",
    CHAT_MSG_OFFICER = "officer",
    CHAT_MSG_RAID = "raid",
    CHAT_MSG_RAID_LEADER = "raidleader",
    CHAT_MSG_RAID_WARNING = "raidwarning",
    CHAT_MSG_BATTLEGROUND = "battleground",
    CHAT_MSG_BATTLEGROUND_LEADER = "battlegroundleader",
    CHAT_MSG_BN_CONVERSATION = "bnconversation"
}

local module = Prat:NewModule(PRAT_MODULE, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

local CLR = Prat.CLR

Prat:SetModuleDefaults(module.name, {
	profile = {
    on = true,
    space = true,
    colon = true,
	chanlink = true,
    replace = {
        say = true,
        whisper = true,
        whisperincome = true,
        bnwhisper = true,
        bnwhisperincome = true,
        yell = true,
        party = true,
        partyleader = true,
        partyguide = true,
        guild = true,
        officer = true,
        raid = true,
        raidleader = true,
        raidwarning = true,
        battleground = true,
        battlegroundleader = true,
        channel1 = true,
        channel2 = true,
        channel3 = true,
        channel4 = true,
        channel5 = true,
        channel6 = true,
        channel7 = true,
        channel8 = true,
        channel9 = true,
        channel10 = true,
    },
    chanSave = {},
    shortnames = 
		-- zhCN
		PratCNlocal == "zhCN" and {
        say = "[???]",
        whisper = "[???]",
        whisperincome = "[???]",
        yell = "[???]",
        party = "[???]",
        guild = "[???]",
        officer = "[???]",
        raid = "[???]",
        raidleader = "[???]",
        raidwarning = "[???]",
        battleground = "[???]",
        battlegroundleader = "[???]",
        channel1 = "[1]",
        channel2 = "[2]",
        channel3 = "[3]",
        channel4 = "[4]",
        channel5 = "[5]",
        channel6 = "[6]",
        channel7 = "[7]",
        channel8 = "[8]",
        channel9 = "[9]",
        channel10 = "[10]",
    }
		--zhTW
		or PratCNlocal == "zhTW" and {
        say = "[???]",
        whisper = "[???]",
        whisperincome = "[???]",
        yell = "[???]",
        party = "[???]",
        guild = "[???]",
        officer = "[???]",
        raid = "[???]",
        raidleader = "[??????]",
        raidwarning = "[???]",
        battleground = "[???]",
        battlegroundleader = "[??????]",
        channel1 = "[1]",
        channel2 = "[2]",
        channel3 = "[3]",
        channel4 = "[4]",
        channel5 = "[5]",
        channel6 = "[6]",
        channel7 = "[7]",
        channel8 = "[8]",
        channel9 = "[9]",
        channel10 = "[10]",
    }
		--koKR
		or PratCNlocal == "koKR" and {
        say = "[??????]",
        whisper = "[??????]",
        whisperincome = "[????????????]",
        yell = "[??????]",
        party = "[??????]",
        guild = "[??????]",
        officer = "[?????????]",
        raid = "[??????]",
        raidleader = "[?????????]",
        raidwarning = "[????????????]",
        battleground = "[??????]",
        battlegroundleader = "[????????????]",
        channel1 = "[1]",
        channel2 = "[2]",
        channel3 = "[3]",
        channel4 = "[4]",
        channel5 = "[5]",
        channel6 = "[6]",
        channel7 = "[7]",
        channel8 = "[8]",
        channel9 = "[9]",
        channel10 = "[10]",
    	}
		--Other
		or {
        say = "[S]",
        whisper = "[W To]",
        whisperincome = "[W From]",
        bnwhisper = "[W To]",
        bnwhisperincome = "[W From]",
        yell = "[Y]",
        party = "[P]",
        partyleader = "[PL]",
        partyguide = "[DG]",
        guild = "[G]",
        officer = "[O]",
        raid = "[R]",
        raidleader = "[RL]",
        raidwarning = "[RW]",
        battleground = "[B]",
        battlegroundleader = "[BL]",
        channel1 = "[1]",
        channel2 = "[2]",
        channel3 = "[3]",
        channel4 = "[4]",
        channel5 = "[5]",
        channel6 = "[6]",
        channel7 = "[7]",
        channel8 = "[8]",
        channel9 = "[9]",
        channel10 = "[10]",
    },
    
    nickname = {}
	}
})



local eventPlugins = { types={}, channels={} }
local nickPlugins = { 	nicks={} }

---module.toggleOptions = { optsep227_sep = 227, optsep_sep = 229, space = 230, colon = 240, sep241_sep = 241, chanlink = 242 }
Prat:SetModuleOptions(module.name, {
    name = L["ChannelNames"],
    desc = L["Channel name abbreviation options."],
    type = "group",
	childGroups = "tab",
	args = {
		etypes = {
		    name = L["ChannelNames"],
		    desc = L["Channel name abbreviation options."],
		    type = "group",
--			inline = true,
		 	order = 1,
		    plugins= eventPlugins,
			args = {}
		},
		ntypes = {
		    name = L["channelnick_name"],
		    desc = L["channelnick_desc"],
		    order = 2,
--			inline = true,
		    type = "group",
			plugins = nickPlugins,
			args = {}
		},
		ctypes = {
		    name = L["otheropts_name"],
		    desc = L["otheropts_desc"],
		 	order = 3,
		    type = "group",
			args = {
--				chanlink = {
--					name = L["chanlink_name"],
--					desc = L["chanlink_desc"],
--					type = "toggle",				},
				space = {
					name = L["space_name"],
					desc = L["space_desc"],
					type = "toggle",				},
				colon = {
					name = L["colon_name"],
					desc = L["colon_desc"],
					type = "toggle",				},
			}
		},
	}
})

--[[------------------------------------------------
    Module Event Functions
------------------------------------------------]]--



function module:OnModuleEnable()
	self:BuildChannelOptions()
    self:RegisterEvent("UPDATE_CHAT_COLOR", "RefreshOptions")
	self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE") 

	Prat.RegisterChatEvent(self, "Prat_FrameMessage")

--  Possible fix for channel messages not getting formatted
	Prat.EnableProcessingForEvent("CHAT_MSG_CHANNEL_NOTICE")
	Prat.EnableProcessingForEvent("CHAT_MSG_CHANNEL_NOTICE_USER")
	Prat.EnableProcessingForEvent("CHAT_MSG_CHANNEL_LEAVE")
	Prat.EnableProcessingForEvent("CHAT_MSG_CHANNEL_JOIN")

    --self:AddOutboundWhisperColoring()

    --self:RawHook("ChatEdit_UpdateHeader", true)
end

function module:OnModuleDisable()
    self:UnregisterAllEvents()
	Prat.UnregisterAllChatEvents(self)
end



--function module:ChatEdit_UpdateHeader(editBox, ...)
--    self.hooks["ChatEdit_UpdateHeader"](...)
--	
--    local type = editBox:GetAttribute("chatType");
--	if ( not type ) then
--		return;
--	end
--
--	local info = ChatTypeInfo[type];
--	local header = _G[editBox:GetName().."Header"];
--	if ( not header ) then
--		return;
--	end    
--
--    if ( type == "CHANNEL" ) then
--		local channel, channelName, instanceID = GetChannelName(editBox:GetAttribute("channelTarget"));
--		if ( channelName ) then
--			if ( instanceID > 0 ) then
--				channelName = channelName.." "..instanceID;
--			end
--			info = ChatTypeInfo["CHANNEL"..channel];
--			editBox:SetAttribute("channelTarget", channel);
--			header:SetFormattedText(CHAT_CHANNEL_SEND, channel, channelName);
--		end
--    end
--end

--[[------------------------------------------------
    Core Functions
------------------------------------------------]]--

-- rebuild menu if chat colors change
function module:CHAT_MSG_CHANNEL_NOTICE()
	self:BuildChannelOptions()
	self:RefreshOptions()
end
function module:RefreshOptions()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("Prat")
end

--function module:AddOutboundWhisperColoring()
--    if not CHAT_CONFIG_CHAT_RIGHT then return end
--
--	CHAT_CONFIG_CHAT_RIGHT[7] = {
--		text = CHAT_MSG_WHISPER_INFORM,
--		type = "WHISPER_INFORM",
--		checked = function () return IsListeningForMessageType("WHISPER"); end;
--		func = function (checked) ToggleChatMessageGroup(checked, "WHISPER"); end;
--	}
--
--	CHAT_CONFIG_CHAT_LEFT[#CHAT_CONFIG_CHAT_LEFT].text = CHAT_MSG_WHISPER
--end

function module:AddNickname(info, name)
    self.db.profile.nickname[info[#info-1]] = name
end

function module:RemoveNickname(info, name)
    if self.db.profile.nickname[info[#info-1]] then
        self.db.profile.nickname[info[#info-1]] = nil
    end
end
function module:GetNickname(info)
	return self.db.profile.nickname[info[#info-1]]
end
function module:NotGetNickname(info)
	return (self:GetNickname(info) == nil) and true or false
end

-- replace text using prat event implementation
function module:Prat_FrameMessage(arg, message, frame, event)
--    if message.TYPEPREFIX:len()>0 and message.TYPEPOSTFIX:len()>0 then

        if event == "CHAT_MSG_CHANNEL_JOIN" or event == "CHAT_MSG_CHANNEL_LEAVE" then
            message.MESSAGE = message.ORG.TYPEPOSTFIX:trim()
            message.ORG.TYPEPOSTFIX = " "
        end

        if event == "CHAT_MSG_CHANNEL_NOTICE" or event == "CHAT_MSG_CHANNEL_NOTICE_USER" or event == "CHAT_MSG_CHANNEL_JOIN" or event == "CHAT_MSG_CHANNEL_LEAVE" then
            event = "CHAT_MSG_CHANNEL"
        end

        local cfg
        
        if event == "CHAT_MSG_BN_CONVERSATION" then
         cfg = eventMap[event]
        else
         cfg = eventMap[event..(message.CHANNELNUM or "")]
        end

        if self.db.profile.nickname[message.CHANNEL] then
            message.CHANNEL = self.db.profile.nickname[message.CHANNEL]
			if message.CHANNEL:sub(1,1) == "#" then
				message.CHANNEL=message.CHANNEL:sub(2)
			else
				message.CHANNELNUM, message.CC = "", ""
			end
        elseif self.db.profile.replace[cfg] then
            message.cC , message.CHANNELNUM, message.CC, message.CHANNEL, message.Cc = "","","","",""
            local space = self.db.profile.space and self.db.profile.shortnames[cfg] and self.db.profile.shortnames[cfg] ~= "" and " " or ""
            local colon = self.db.profile.colon and (message.PLAYERLINK:len() > 0 and message.MESSAGE:len() > 0) and ":" or ""
            message.TYPEPREFIX = self.db.profile.shortnames[cfg] or ""

			if message.TYPEPREFIX:len() == 0 then 
                message.nN, message.NN, message.Nn, message.CHANLINK = "", "", "", ""
			end

            message.TYPEPREFIX = message.TYPEPREFIX..space
            
            if (message.PLAYERLINK:len() > 0) or (message.TYPEPREFIX:len() > 0)  then 
                message.TYPEPOSTFIX = colon.."\32"
            else
                message.TYPEPOSTFIX = ""
            end	
        end
--    end
end

--[[------------------------------------------------
    Menu Builder Functions
------------------------------------------------]]--

function module:BuildChannelOptions()
    for _, v in ipairs(orderMap) do
        self:CreateTypeOption(eventPlugins["types"], v)
    end
    for i=1,9 do
        self:CreateChannelOption(eventPlugins["channels"], "channel"..i, i)
    end
    
    local t = Prat.GetChannelTable()
    for k, v in pairs(t) do
        if type(v) == "string" then
            self:CreateChanNickOption(nickPlugins["nicks"], v)
        end
    end    
end

function module:CreateChanNickOption(args, keyname)
    local text = keyname
    local name = keyname
    args[name] = args[name] or {
        name = text,
        desc = string.format(L["%s settings."], text),
        type = "group",
        order = 228,
        args = {
            addnick = {
                name = L["Add Channel Abbreviation"],
                desc = L["addnick_desc"],
                type = "input",
                order = 140,
                usage = "<string>",
                get = "GetNickname",
				set = "AddNickname",
            },
            removenick = {
                name = L["Remove Channel Abbreviation"],
                desc = L["Removes an an abbreviated channel name."],
                type = "execute",
                order = 150,
				func = "RemoveNickname",
                disabled = "NotGetNickname";
            },  
        }
    }        
end

function module:GetChanOptValue(info, ...)
	return self.db.profile[info[#info]][info[#info-1]]
end

function module:SetChanOptValue(info, val, ...)
	self.db.profile[info[#info]][info[#info-1]] = val
end

do 
	local function revLookup(keyname)
	    for k,v in pairs(eventMap) do
	        if keyname == v then
	            return k
	        end
	    end
	end

	local function GetChatCLR(name)
	    local type = strsub(name, 10);
	    local info = ChatTypeInfo[type];
	    if not info then
	        return CLR.COLOR_NONE
	    end
	    return CLR:GetHexColor(info)
	end
	
	local function ChatType(text, type) return CLR:Colorize(GetChatCLR(type), text) end


	 local optionGroup = {
		    type = "group",
			name = function(info) return ChatType(_G[revLookup(info[#info])], revLookup(info[#info])) end,
			desc = function(info) return (L["%s settings."]):format(_G[revLookup(info[#info])]) end,
			get = "GetChanOptValue",
			set = "SetChanOptValue",
		    args = {
		        shortnames = {
					name = function(info) return ChatType(_G[revLookup(info[#info-1])], revLookup(info[#info-1])) end,
					desc = function(info) return (L["Use a custom replacement for the chat %s text."]):format(ChatType(_G[revLookup(info[#info-1])], revLookup(info[#info-1]))) end, 
		            order = 1,
		            type = "input",
		            usage = L["<string>"],
		        },
		        replace = {
		            name = L["Replace"],
		            desc = L["Toggle replacing this channel."],
		            type = "toggle",
		            order = 3,
		        },
		    }
		}

	 local optionGroupChan = {
		    type = "group",
			name = function(info) return ChatType((L["Channel %d"]):format(info[#info]:sub(-1)), revLookup(info[#info])) end,
			desc = function(info) return (L["%s settings."]):format(ChatType((L["Channel %d"]):format(info[#info]:sub(-1)), revLookup(info[#info]))) end,
			get = "GetChanOptValue",
			set = "SetChanOptValue",
			order = function(info)  return 200+tonumber(info[#info]:sub(-1)) end,
		    args = {
		        shortnames = {
					name = function(info) return ChatType((L["Channel %d"]):format(info[#info-1]:sub(-1)), revLookup(info[#info-1])) end,
					desc = function(info) return (L["Use a custom replacement for the chat %s text."]):format(ChatType((L["Channel %d"]):format(info[#info-1]:sub(-1)), revLookup(info[#info-1]))) end, 
		            order = 1,
		            type = "input",
		            usage = L["<string>"],
		        },
		        replace = {
		            name = L["Replace"],
		            desc = L["Toggle replacing this channel."],
		            type = "toggle",
		            order = 3,
		        },
		    }
		}
		
	function module:CreateTypeOption(args, keyname)
		if not args[keyname] then
	    	args[keyname] = optionGroup
		end
	end
	
	function module:CreateChannelOption(args, keyname, keynum)
		if not args[keyname] then
	    	args[keyname] = optionGroupChan
		end
	end
end




  return
end ) -- Prat:AddModuleToLoad
