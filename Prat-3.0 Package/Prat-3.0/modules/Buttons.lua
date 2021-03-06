--if Prat.BN_CHAT then return end -- Removed in 3.3.5 

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
Name: module
Revision: $Revision: r24999 $
Author(s): Fin (fin@instinct.org)
Website: http://files.wowace.com/Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#Clear
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Description: Adds /clear (or /cls) and /clearall (or /clsall) commands for clearing chat frames (default=off).
Dependencies: Prat
Credits: Code taken almost entirely from Chatter by Antiarc
]]

Prat:AddModuleToLoad(function() 

local PRAT_MODULE = Prat:RequestModuleName("Buttons")

if PRAT_MODULE == nil then 
    return 
end


local L = Prat:GetLocalizer({})

--[===[@debug@
L:AddLocale("enUS", {
    ["Buttons"] = true,
    ["Chat window button options."] = true,
    ["chatmenu_name"] = "Show Chat Menu",
    ["chatmenu_desc"] = "Toggles chat menu on and off.",
    ["Show Arrows"] = true,
    ["Toggle showing chat arrows for each chat window."] = true, 
    ["Show Chat%d Arrows"] = true,
    ["Toggles navigation arrows on and off."] = true,
    ["scrollReminder_name"] = "Show ScrollDown Reminder",
    ["scrollReminder_desc"] = "Show reminder button when not at the bottom of a chat window.",
    ["Set Position"] = true,
    ["Sets position of chat menu and arrows for all chat windows."] = true,
    ["Default"] = true,
    ["Right, Inside Frame"] = true,
    ["Right, Outside Frame"] = true,
    ["alpha_name"] = "Set Alpha",
    ["alpha_desc"] = "Sets alpha of chat menu and arrows for all chat windows.",
    ["showmenu_name"] = "Show Menu",
    ["showmenu_desc"] = "Show Chat Menu",
    ["showbnet_name"] = "Show Social Menu",
    ["showbnet_desc"] = "Show Social Menu",
    ["showminimize_name"] = "Show Minimize Button",
    ["showminimize_desc"] = "Show Minimize Button",
})
--@end-debug@]===]

-- These Localizations are auto-generated. To help with localization
-- please go to http://www.wowace.com/projects/prat-3-0/localization/


--@non-debug@
L:AddLocale("enUS", 
{
	Buttons = true,
	["Chat window button options."] = true,
	Default = true,
	["Right, Inside Frame"] = true,
	["Right, Outside Frame"] = true,
	["Set Position"] = true,
	["Sets position of chat menu and arrows for all chat windows."] = true,
	["Show Arrows"] = true,
	["Show Chat%d Arrows"] = true,
	["Toggle showing chat arrows for each chat window."] = true,
	["Toggles navigation arrows on and off."] = true,
	alpha_desc = "Sets alpha of chat menu and arrows for all chat windows.",
	alpha_name = "Set Alpha",
	chatmenu_desc = "Toggles chat menu on and off.",
	chatmenu_name = "Show Chat Menu",
	scrollReminder_desc = "Show reminder button when not at the bottom of a chat window.",
	scrollReminder_name = "Show ScrollDown Reminder",
	showbnet_desc = "Show Social Menu",
	showbnet_name = "Show Social Menu",
	showmenu_desc = "Show Chat Menu",
	showmenu_name = "Show Menu",
	showminimize_desc = "Show Minimize Button",
	showminimize_name = "Show Minimize Button",
}

)
L:AddLocale("frFR",  
{
	Buttons = "Boutons",
	["Chat window button options."] = "Options des boutons de la fen??tre de discussion.",
	Default = "D??faut",
	["Right, Inside Frame"] = "Droite, dans le cadre",
	["Right, Outside Frame"] = "Droite, en dehors du cadre",
	["Set Position"] = "D??finir la position",
	["Sets position of chat menu and arrows for all chat windows."] = "D??finir la position du menu et des fl??ches de toutes les fen??tres de discussion.",
	["Show Arrows"] = "Montrer les fl??ches",
	-- ["Show Chat%d Arrows"] = "",
	["Toggle showing chat arrows for each chat window."] = "Activer l'affichage des fl??ches pour chaque fen??tre de discussion.",
	["Toggles navigation arrows on and off."] = "Activer et d??sactiver les fl??ches de navigations",
	alpha_desc = "D??finit la transparence du menu du chat et des fl??ches pour toutes les fen??tres de discussion.",
	alpha_name = "D??finir la transparence",
	chatmenu_desc = "Activer et d??sactiver le menu du tchat",
	chatmenu_name = "Montrer le menu du chat",
	scrollReminder_desc = "Montrer le bouton de rappel lorsque vous n'??tes pas ?? la fin de la fen??tre de discussion.",
	scrollReminder_name = "Montrer le rappel",
	showbnet_desc = "Montrer le menu Social.",
	showbnet_name = "Montrer le menu Social",
	showmenu_desc = "Montrer le menu de la fen??tre de discussion.",
	showmenu_name = "Montrer le menu",
	showminimize_desc = "Montrer le bouton pour minimiser la discussion.",
	showminimize_name = "Montrer Minimiser",
}

)
L:AddLocale("deDE", 
{
	Buttons = "Schaltfl??chen",
	["Chat window button options."] = "Optionen f??r die die Schaltfl??chen der Chat-Fenster",
	Default = "Standard",
	["Right, Inside Frame"] = "Rechts, innerhalb des Rahmens",
	["Right, Outside Frame"] = "Rechts, au??erhalb des Rahmens",
	["Set Position"] = "Position einstellen",
	["Sets position of chat menu and arrows for all chat windows."] = "Stellt die Position des Chat-Men??s und der Navigationspfeile f??r alle Chat-Fenster ein.",
	["Show Arrows"] = "Zeige die Navigationspfeile",
	["Show Chat%d Arrows"] = "Navigationspfeile im Chat%d anzeigen",
	["Toggle showing chat arrows for each chat window."] = "Anzeige der Navigationspfeile f??r jedes Chat-Fenster ein- und ausschalten.",
	["Toggles navigation arrows on and off."] = "Schaltet die Anzeige der Navigationspfeile an und aus",
	alpha_desc = "Transparenz der Chat-Men??s und Navigationspfeile f??r alle Chat-Fenster einstellen.",
	alpha_name = "Transparenz einstellen",
	chatmenu_desc = "Chat-Men?? ein- und ausschalten.",
	chatmenu_name = "Chat-Men?? anzeigen",
	scrollReminder_desc = "Erinnerungsschaltfl??che anzeigen, wenn nicht am unteren Ende des Chat-Fensters.",
	scrollReminder_name = "ScrollDown-Erinnerung anzeigen",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	showmenu_desc = "Chat-Men?? anzeigen",
	showmenu_name = "Men?? anzeigen",
	showminimize_desc = "Zeigt den Schalter zum Minimieren an",
	showminimize_name = "Zeige Minimieren Knopf",
}

)
L:AddLocale("koKR",  
{
	Buttons = "??????",
	["Chat window button options."] = "????????? ?????? ??????",
	Default = "?????????",
	["Right, Inside Frame"] = "??????, ????????? ??????",
	["Right, Outside Frame"] = "??????, ????????? ?????????",
	["Set Position"] = "?????? ??????",
	["Sets position of chat menu and arrows for all chat windows."] = "???????????? ????????? ???????????? ????????? ???????????????.",
	["Show Arrows"] = "????????? ?????????",
	["Show Chat%d Arrows"] = "?????????%d??? ????????? ?????????",
	["Toggle showing chat arrows for each chat window."] = "??? ???????????? ?????? ????????? ???????????? ?????? ?????????.",
	["Toggles navigation arrows on and off."] = "?????? ???????????? ???????????????.",
	alpha_desc = "?????? ???????????? ????????? ????????? ???????????? ???????????? ???????????????.",
	alpha_name = "????????? ??????",
	chatmenu_desc = "????????? ????????? ?????? ?????????.",
	chatmenu_name = "????????? ?????? ?????????",
	scrollReminder_desc = "???????????? ?????? ????????? ???, ???????????? ????????? ?????????.",
	scrollReminder_name = "?????????????????? ?????????",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	showmenu_desc = "?????? ?????? ?????????",
	showmenu_name = "?????? ?????????",
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
L:AddLocale("esMX",  
{
	-- Buttons = "",
	-- ["Chat window button options."] = "",
	-- Default = "",
	-- ["Right, Inside Frame"] = "",
	-- ["Right, Outside Frame"] = "",
	-- ["Set Position"] = "",
	-- ["Sets position of chat menu and arrows for all chat windows."] = "",
	-- ["Show Arrows"] = "",
	-- ["Show Chat%d Arrows"] = "",
	-- ["Toggle showing chat arrows for each chat window."] = "",
	-- ["Toggles navigation arrows on and off."] = "",
	-- alpha_desc = "",
	-- alpha_name = "",
	-- chatmenu_desc = "",
	-- chatmenu_name = "",
	-- scrollReminder_desc = "",
	-- scrollReminder_name = "",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	-- showmenu_desc = "",
	-- showmenu_name = "",
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
L:AddLocale("ruRU",  
{
	Buttons = true,
	["Chat window button options."] = "?????????????????? ???????????? ???????? ????????.",
	Default = "???? ??????????????????",
	["Right, Inside Frame"] = "????????????, ???????????? ????????",
	["Right, Outside Frame"] = "????????????, ?????? ????????",
	["Set Position"] = "??????????????????",
	["Sets position of chat menu and arrows for all chat windows."] = "???????????????????? ?????????????????? ?????????????? ?? ???????????? ???????? ?????? ???????? ????????.",
	["Show Arrows"] = "???????????????????? ??????????????",
	["Show Chat%d Arrows"] = "???????????????????? ?????????????? %d ????????",
	["Toggle showing chat arrows for each chat window."] = "???????????????????? ?????????????? ?????? ?????????????? ???????? ????????.",
	["Toggles navigation arrows on and off."] = "??????/???????? ?????????????????????????? ??????????????.",
	alpha_desc = "?????????????????? ???????????????????????? ???????????? ???????? ?? ???????? ??????????????.",
	alpha_name = "????????????????????????",
	chatmenu_desc = "??????/???????? ???????????? ????????.",
	chatmenu_name = "???????????????? ???????????? ????????",
	scrollReminder_desc = "??????/???????? ??????????????????, ???????????????????????????????? ?? ??????, ?????? ???????? ???????? ?????????? ???????????????????????? ????????.",
	scrollReminder_name = "?????????????????? ?????????????????? ????????",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	showmenu_desc = "???????????????????? ???????? ????????????",
	showmenu_name = "???????????????????? ????????", -- Needs review
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
L:AddLocale("zhCN",  
{
	Buttons = "??????",
	["Chat window button options."] = "????????????????????????",
	Default = "??????",
	["Right, Inside Frame"] = "???????????????",
	["Right, Outside Frame"] = "???????????????",
	["Set Position"] = "????????????",
	["Sets position of chat menu and arrows for all chat windows."] = "??????????????????????????????????????????????????????",
	["Show Arrows"] = "????????????",
	["Show Chat%d Arrows"] = "????????????%d??????",
	["Toggle showing chat arrows for each chat window."] = "?????????????????????????????????????????????",
	["Toggles navigation arrows on and off."] = "???????????????????????????",
	alpha_desc = "?????????????????????????????????????????????????????????",
	alpha_name = "???????????????",
	chatmenu_desc = "?????????????????????",
	chatmenu_name = "????????????_??????",
	scrollReminder_desc = "????????????????????????????????????????????????",
	scrollReminder_name = "????????????????????????",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	-- showmenu_desc = "",
	-- showmenu_name = "",
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
L:AddLocale("esES",  
{
	Buttons = "Botones",
	["Chat window button options."] = "Opciones de los botones de la ventana del chat",
	Default = "Predeterminado",
	["Right, Inside Frame"] = "Derecha, Dentro del Marco",
	["Right, Outside Frame"] = "Derecha, Fuera del Marco",
	["Set Position"] = "Establecer Posici??n",
	["Sets position of chat menu and arrows for all chat windows."] = "Establece la posici??n del men?? y de las flechas de todas las ventanas de chat.",
	["Show Arrows"] = "Mostar Flechas",
	["Show Chat%d Arrows"] = "Mostar Flechas del Chat %d",
	["Toggle showing chat arrows for each chat window."] = "Alterna el mostrar las flechas para cada ventana de chat.",
	["Toggles navigation arrows on and off."] = "Alterna la activaci??n de las flechas de navegaci??n.",
	alpha_desc = "Establece la transparencia del menu del chat y de las flechas para todas las ventanas.",
	alpha_name = "Establecer Transparencia",
	chatmenu_desc = "Alterna la activaci??n del men?? del chat.",
	chatmenu_name = "Mostrar Men?? del Chat",
	scrollReminder_desc = "Muestra el bot??n recordatorio cuando no se est?? en la parte inferior de la ventana de chat.",
	scrollReminder_name = "Mostrar Recordatorio de Desplazamiento Abajo",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	-- showmenu_desc = "",
	-- showmenu_name = "",
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
L:AddLocale("zhTW",  
{
	Buttons = "??????",
	["Chat window button options."] = "???????????????????????????",
	Default = "?????????",
	["Right, Inside Frame"] = "?????????????????????",
	["Right, Outside Frame"] = "?????????????????????",
	["Set Position"] = "????????????",
	-- ["Sets position of chat menu and arrows for all chat windows."] = "",
	["Show Arrows"] = "????????????",
	["Show Chat%d Arrows"] = "???????????? %d ?????????",
	-- ["Toggle showing chat arrows for each chat window."] = "",
	-- ["Toggles navigation arrows on and off."] = "",
	alpha_desc = "??????????????????????????????????????????????????????",
	alpha_name = "???????????????",
	chatmenu_desc = "?????????????????????????????????",
	chatmenu_name = "??????????????????",
	-- scrollReminder_desc = "",
	-- scrollReminder_name = "",
	-- showbnet_desc = "",
	-- showbnet_name = "",
	-- showmenu_desc = "",
	-- showmenu_name = "",
	-- showminimize_desc = "",
	-- showminimize_name = "",
}

)
--@end-non-debug@


local module = Prat:NewModule(PRAT_MODULE, "AceHook-3.0")

Prat:SetModuleDefaults(module.name, {
	profile = {
	    on = true,
		scrollReminder = true,
		showButtons = true,
		showBnet = true,
		showMenu = true,
		showminimize = true,
	}
} )

Prat:SetModuleOptions(module.name, {
        name = L["Buttons"],
        desc = L["Chat window button options."],
        type = "group",
        args = {
		    showButtons = { 
				name = L["Show Arrows"],
				desc = L["Toggle showing chat arrows for each chat window."],
				type = "toggle",
				order = 100
			},
		    scrollReminder = { 
				name = L["scrollReminder_name"],
				desc = L["scrollReminder_desc"],
				type = "toggle",
				order = 110 
			},
		    showBnet = { 
				name = L["showbnet_name"],
				desc = L["showbnet_desc"],
				type = "toggle",
				order = 120 
			},
		    showMenu = { 
				name = L["showmenu_name"],
				desc = L["showmenu_desc"],
				type = "toggle",
				order = 130 
			},	
		    showminimize = { 
				name = L["showminimize_name"],
				desc = L["showminimize_desc"],
				type = "toggle",
				order = 140 
			},									
        }
    }
)

--[[------------------------------------------------
	Module Event Functions
------------------------------------------------]]--
local fmt = _G.string.format


local function hide(self)
	if not self.override then
		self:Hide()
	end
	self.override = nil
end

function module:OnModuleEnable()
    local buttons3 = Prat.Addon:GetModule("OriginalButtons", true)
    if buttons3 and buttons3:IsEnabled() then
        self.disabledB3 = true
        buttons3.db.profile.on = false
        buttons3:Disable()
        LibStub("AceConfigRegistry-3.0"):NotifyChange("Prat")
    end

    self:ApplyAllSettings()
	
	Prat.RegisterChatEvent(self, Prat.Events.POST_ADDMESSAGE)

	--self:SecureHook("FCF_SetButtonSide")

end

function module:ApplyAllSettings()
	if not self.db.profile.showButtons then
		self:HideButtons()
	else
	    self:ShowButtons()
	end

	self:UpdateMenuButtons()
	
	self:AdjustMinimizeButtons()
	
	self:AdjustButtonFrames(self.db.profile.showButtons)
	
    self:UpdateReminder()
end

function module:OnModuleDisable()
	self:DisableBottomButton()
	self:ShowButtons()
	
	Prat.UnregisterAllChatEvents(self)
end

function module:UpdateReminder()
	local v = self.db.profile.scrollReminder
	if v then
		module:EnableBottomButton()
	elseif self.buttonsEnabled then
		module:DisableBottomButton()
	end
end

function module:OnValueChanged(info, b)
    self:ApplyAllSettings()
end

function module:UpdateMenuButtons()
    if self.db.profile.showBnet then
        FriendsMicroButton:Show()
    else
        FriendsMicroButton:Hide()
    end

    if self.db.profile.showMenu then
    	ChatFrameMenuButton:SetScript("OnShow", nil)
	    ChatFrameMenuButton:Show()
	else
    	ChatFrameMenuButton:SetScript("OnShow", hide)
        ChatFrameMenuButton:Hide()	
    end
end
function module:HideButtons()
    self:UpdateMenuButtons()
    
	local upButton, downButton, bottomButton, min

	for name, frame in pairs(Prat.Frames) do
		upButton = _G[name.."ButtonFrameUpButton"]
		upButton:SetScript("OnShow", hide)
		upButton:Hide()
		downButton = _G[name.."ButtonFrameDownButton"]
		downButton:SetScript("OnShow", hide)
		downButton:Hide()
		bottomButton = _G[name.."ButtonFrameBottomButton"]
		bottomButton:SetScript("OnShow", hide)
		bottomButton:Hide()
		bottomButton:SetParent(frame)
		
		bottomButton:SetScript("OnClick", function() frame:ScrollToBottom() end)

		self:FCF_SetButtonSide(frame)
	end
	
	self:AdjustMinimizeButtons()
end

function module:AdjustButtonFrames(visible)
    for name, frame in pairs(Prat.Frames) do
        local f = _G[name.."ButtonFrame"]
        
        if visible then
            f:SetScript("OnShow", nil)
            f:Show()
            f:SetWidth(29)
        else
            f:SetScript("OnShow", hide)    
            f:Hide()    
            f:SetWidth(0.1)
        end
    end
end

function module:AdjustMinimizeButtons()
    for name, frame in pairs(Prat.Frames) do
		local min = _G[name.."ButtonFrameMinimizeButton"]
		
		if min then 
		
		    if self.db.profile.showminimize then
    		    min:ClearAllPoints()
    		    
    		    min:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 2, 2)
    		    --min:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -32, -4);
    		    
        		min:SetParent(_G[frame:GetName().."Tab"])
        
                min:SetScript("OnShow", 
                                    function(self)
                                        if frame.isDocked then
                                            self:Hide()
                                        end
                                    end )
                                    
                min:SetScript("OnClick", 
                                    function(self) 
        								FCF_MinimizeFrame(frame, strupper(frame.buttonSide))
        							end )
        							
        		min:Show()
        	else
        	    min:SetScript("OnShow", hide)
        	    min:Hide()
        	end
    	end
	end    
end

function module:ShowButtons()
	self:Unhook("FCF_SetButtonSide")
    self:UpdateMenuButtons()
	local upButton, downButton, bottomButton

	for name, frame in pairs(Prat.Frames) do
		upButton = _G[name.."ButtonFrameUpButton"]
		upButton:SetScript("OnShow", nil)
		upButton:Show()
		downButton = _G[name.."ButtonFrameDownButton"]
		downButton:SetScript("OnShow", nil)
		downButton:Show()
		bottomButton = _G[name.."ButtonFrameBottomButton"]
		bottomButton:SetScript("OnShow", nil)
		bottomButton:Show()
		bottomButton:SetParent(_G[name.."ButtonFrame"])
		
--		frame.buttonSide = nil
--		bottomButton:ClearAllPoints()
--		bottomButton:SetPoint("BOTTOMRIGHT", _G[name.."ButtonFrame"], "BOTTOMLEFT", 2, 2)
--		bottomButton:SetPoint("BOTTOMLEFT", _G[name.."ButtonFrame"], "BOTTOMLEFT", -32, -4);
		--FCF_UpdateButtonSide(frame)
		
		--bottomButton:SetScript("OnClick", function() frame:ScrollToBottom() end)
		
		self:FCF_SetButtonSide(frame)
	end
	
	self:AdjustMinimizeButtons()	
end

--[[ - - ------------------------------------------------
	Core Functions
--------------------------------------------- - ]]--

function module:FCF_SetButtonSide(chatFrame, buttonSide)
	local f = _G[chatFrame:GetName().."ButtonFrameBottomButton"]
	local bf = _G[chatFrame:GetName().."ButtonFrame"]
	
	if self.db.profile.showButtons then
    	f:ClearAllPoints()
        f:SetPoint("BOTTOM", bf, "BOTTOM", 0, 0)
	else
    	f:ClearAllPoints()
        f:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", 2, 2)
    end
end


function module:EnableBottomButton()
	if self.buttonsEnabled then return end
	self.buttonsEnabled = true
	for name, f in pairs(Prat.Frames) do
		self:SecureHook(f, "ScrollUp")
		self:SecureHook(f, "ScrollToTop", "ScrollUp")
		self:SecureHook(f, "PageUp", "ScrollUp")
					
		self:SecureHook(f, "ScrollDown")
		self:SecureHook(f, "ScrollToBottom", "ScrollDownForce")
		self:SecureHook(f, "PageDown", "ScrollDown")

		local button = _G[name .. "ButtonFrameBottomButton"]
		
		if button then
    		if f:GetCurrentScroll() ~= 0 then
    			button.override = true
    			button:Show()	
    		else
    			button:Hide()
    		end
        end
	end
end

function module:DisableBottomButton()
	if not self.buttonsEnabled then return end
	self.buttonsEnabled = false
	for name, f in pairs(Prat.Frames) do
		if f then
			self:Unhook(f, "ScrollUp")
			self:Unhook(f, "ScrollToTop")
			self:Unhook(f, "PageUp")					
			self:Unhook(f, "ScrollDown")
			self:Unhook(f, "ScrollToBottom")
			self:Unhook(f, "PageDown")
			local button = _G[name.. "ButtonFrameBottomButton"]
			button:Hide()
		end
	end
end

function module:ScrollUp(frame)
	local button = _G[frame:GetName() .. "ButtonFrameBottomButton"]
	button.override = true
	button:Show()
end

function module:ScrollDown(frame)
	if frame:GetCurrentScroll() == 0 then
		local button = _G[frame:GetName() .. "ButtonFrameBottomButton"]
		button:Hide()	
	end
end

function module:ScrollDownForce(frame)
	local button = _G[frame:GetName() .. "ButtonFrameBottomButton"]
	button:Hide()	
end

--function module:AddMessage(frame, text, ...)
function module:Prat_PostAddMessage(info, message, frame, event, text, r, g, b, id)
	local button = _G[frame:GetName() .. "ButtonFrameBottomButton"]

	if not button then return end
	if frame:GetCurrentScroll() > 0 then
		button.override = true
		button:Show()
	else
		button:Hide()	
	end
end


  return
end ) -- Prat:AddModuleToLoad