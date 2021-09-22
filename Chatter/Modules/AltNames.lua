local mod = Chatter:NewModule("Alt Linking", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Alt Linking"]

local NAMES
local GUILDNOTES
local pairs = _G.pairs
local select = _G.select
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local tremove = _G.tremove
local type = _G.type
local unpack = _G.unpack
local strlower= _G.string.lower
local gmatch = _G.string.gmatch

local leftBracket, rightBracket

local defaults = { 
	realm = {}, 
	profile = {
		guildNotes=true,
		altNotesFallback=true,
		colorMode = "COLOR_MOD", 
		color = {0.6, 0.6, 0.6},
		leftBracket = "[",
		rightBracket = "]",
	} 
}
local colorModes = {
	COLOR_MOD = L["Use PlayerNames coloring"],
	CUSTOM = L["Use custom color"],
	CHANNEL = L["Use channel color"]
}

local customColorNames = setmetatable({}, {
	__index = function(t, v)
		local r, g, b = unpack(mod.db.profile.color)
		t[v] = ("|cff%02x%02x%02x%s|r"):format(r * 255, g  * 255, b * 255, v)
		return t[v]
	end
})


local options
function mod:GetOptions()
	options = options or {
		guildNotes = {
			order=100,
			type = "toggle",
			name = L["Use guildnotes"],
			desc = L["Look in guildnotes for character names, unless a note is set manually"],
			get = function()
				return mod.db.profile.guildNotes
			end,
			set = function(info, v)
				mod.db.profile.guildNotes = v
				mod:EnableGuildNotes(v)
			end,
		},
		altNotesFallback = {
			order=101,
			type = "toggle",
			name = L["Alt note fallback"],
			desc = L["If no name can be found for an 'alt' rank character, use entire note"],
			disabled = function()
				return not mod.db.profile.guildNotes
			end,
			get = function()
				return mod.db.profile.altNotesFallback
			end,
			set = function(info, v)
				mod.db.profile.altNotesFallback = v
				mod:ScanGuildNotes()
			end,
		},	
		colorMode = {
			order=110,
			type = "select",
			name = L["Name color"],
			desc = L["Set the coloring mode for alt names"],
			values = colorModes,
			get = function()
				return mod.db.profile.colorMode
			end,
			set = function(info, v)
				mod.db.profile.colorMode = v
			end
		},
		color = {
			order=111,
			type = "color",
			name = L["Custom color"],
			desc = L["Select the custom color to use for alt names"],
			get = function()
				return unpack(mod.db.profile.color)
			end,
			set = function(info, r, g, b)
				mod.db.profile.color[1] = r
				mod.db.profile.color[2] = g
				mod.db.profile.color[3] = b
				for k, v in pairs(customColorNames) do
					customColorNames[k] = nil
				end
			end,
			disabled = function() return mod.db.profile.colorMode ~= "CUSTOM" end
		},
		leftbracket = {
			type = "input",
			name = L["Left Bracket"],
			desc = L["Character to use for the left bracket"],
			get = function() return mod.db.profile.leftBracket end,
			set = function(i, v)
				mod.db.profile.leftBracket = v
				leftBracket = v
			end
		},
		rightbracket = {
			type = "input",
			name = L["Right Bracket"],
			desc = L["Character to use for the right bracket"],
			get = function() return mod.db.profile.rightBracket end,
			set = function(i, v)
				mod.db.profile.rightBracket = v
				rightBracket = v
			end
		},
	}
	return options
end



local accept = function(self, char)
	local editBox = _G[this:GetParent():GetName().."EditBox"]
	local main = editBox:GetText()
	mod:AddAlt(char, main)
	this:GetParent():Hide()
end

StaticPopupDialogs['MENUITEM_SET_MAIN'] = {
	text		= L["Who is %s's main?"],
	button1		= TEXT(ACCEPT),
	button2		= TEXT(CANCEL),
	hasEditBox	= 1,
	maxLetters	= 128,
	exclusive	= 0,
	OnShow = function()
		_G[this:GetName().."EditBox"]:SetFocus()
	end,
	OnHide = function()
		if ( _G[this:GetName().."EditBox"]:IsShown() ) then
			_G[this:GetName().."EditBox"]:SetFocus();
		end
		_G[this:GetName().."EditBox"]:SetText("");
	end,
	OnAccept = accept,
	EditBoxOnEnterPressed = accept,
	EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}	

UnitPopupButtons["SET_MAIN"] = {
	text = L["Set Main"],
	dist = 0,
	func = mod.GetMainName
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("AltLinks", defaults)
end

function mod:Decorate(frame)
	if not self:IsHooked(frame,"AddMessage") then
		self:RawHook(frame, "AddMessage", true)
	end
end

function mod:OnEnable()
	NAMES = self.db.realm
	UnitPopupButtons["SET_MAIN"].func = self.GetMainName
	tinsert(UnitPopupMenus["SELF"], 	#UnitPopupMenus["SELF"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["PLAYER"], 	#UnitPopupMenus["PLAYER"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["FRIEND"],	#UnitPopupMenus["FRIEND"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["PARTY"], 	#UnitPopupMenus["PARTY"] - 1,	"SET_MAIN")
	self:SecureHook("UnitPopup_ShowMenu")

	leftBracket, rightBracket = self.db.profile.leftBracket, self.db.profile.rightBracket
	
	mod:EnableGuildNotes(mod.db.profile.guildNotes)
	
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	self.colorMod = Chatter:GetModule("Player Class Colors")
end

local types = {"SELF", "PLAYER", "FRIEND", "PARTY"}
function mod:OnDisable()
	for j = 1, #types do
		local t = types[j]
		for i = 1, #UnitPopupMenus[t] do
			if UnitPopupMenus[t][i] == "SET_MAIN" then
				tremove(UnitPopupMenus[t], i)
				break
			end
		end
	end
	mod:EnableGuildNotes(false)
end


function mod.GetMainName()
	local alt = UIDROPDOWNMENU_INIT_MENU.name
	local popup = StaticPopup_Show("MENUITEM_SET_MAIN", alt)
	if popup then 
		popup.data = alt 
		local editbox = getglobal(popup:GetName().."EditBox")
		editbox:SetText(NAMES[alt] or GUILDNOTES[alt] or "")
		editbox:HighlightText()
	end
end

function mod:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		if button.value == "SET_MAIN" then
		    button.func = UnitPopupButtons["SET_MAIN"].func
		end
	end
end

function mod:AddAlt(alt, main)
	if #main == 0 then 
		if GUILDNOTES[alt] then
			-- let the user store an empty note, meaning "dont show me this main"
		else
			main = nil 
		end
	end
	NAMES[alt] = main	
end

local function pName(msg, name)
	if name and #name > 0 then
		local alt = NAMES[name] or GUILDNOTES[name]
		if alt and alt ~= "" then		-- empty notes can be stored to override guildnote data
			local mode = mod.db.profile.colorMode
			if mode == "CUSTOM" then				
				alt = customColorNames[alt]
			elseif mode == "COLOR_MOD" and mod.colorMod and mod.colorMod:IsEnabled() then
				alt = mod.colorMod:ColorName(alt)
			end
			return ("%s%s%s%s"):format( msg, leftBracket, alt, rightBracket )
		end
	end
	return msg
end

function mod:AddMessage(frame, text, ...)
	if text and type(text) == "string" then 
		--text = text:gsub("(|Hplayer:([^:]+)[:%d+]*|h.-|h)", pName)
		text = text:gsub("(|Hplayer:([^:]+).-|h.-|h)", pName)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:Info()
	return L["Enables you to right-click a person's name in chat and set a note on them to be displayed in chat, such as their main character's name. Can also scan guild notes for character names to display, if no note has been manually set."]
end

function mod:EnableGuildNotes(enable)
	GUILDNOTES={}
	if enable then
		mod:RegisterEvent("GUILD_ROSTER_UPDATE")
		if IsInGuild() then
			GuildRoster()
		end
		mod:ScanGuildNotes()	-- Unfortunately we can't count on GuildRoster() triggering the event if someone else triggered it recently. So we try once at first straight off the bat.
	else
		mod:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

local doscan=true	-- always the first time we start up
function mod:GUILD_ROSTER_UPDATE(event,arg1)
	-- arg1 gets set for SOME changes to the guild, but notably not for player notes.. doh  (unless you're the one editing them yourself)
	-- we force a scan when the guild frame is actually visible (i.e. when we know the player is actually interested in seeing changes)
	-- i'd like to be able to not have the guildframe check there, but there's plenty of stupid-ass addons that spam GuildRoster() every 10/15/20 seconds, so ... no.
	if arg1 or GuildFrame:IsVisible() or doscan then
		doscan=false
		mod:ScanGuildNotes()
	end
	
	if arg1 then
		-- but it appears that when arg1 is set, the player note change isn't available yet; that happens on the next arg1=nil update (about 0.1s later), so catch that one too. ghod this is messy.
		doscan=true	
	end
end

function mod:ScanGuildNotes()
	if not IsInGuild() then
		return
	end
	--DBG print("Scanning guildnotes!")
	--DBG local n,nFallback=0,0
	local names = {}  -- ["playername"]="Playername"   (note lowercase = uppercase) (yes, this works for 'foreign' letters too in WoW, even though it does not in standard Lua)
	GUILDNOTES = {} -- Yes, we do want to zap it, otherwise we end up storing notes for people being promoted/demoted through alt ranks and stuff
	
	-- #1: find all names
	for i=1,GetNumGuildMembers(true) do
		local name = GetGuildRosterInfo(i)
		names[strlower(name or "?")] = name
	end
	
	-- #2: scan all words in all guild notes, see if a name is mentioned
--	for i=1,GetNumGuildMembers(true) do
--		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
--		local success
--		for word in gmatch(strlower(note), "[%a\128-\255]+") do
--			if names[word] then
--				GUILDNOTES[name] = names[word]
--				success = true
--				--DBG n=n+1
--				break
--			end
--		end
--		if not success and mod.db.profile.altNotesFallback and note~="" then
--			-- #3:  no joy? then if this is an 'alt' rank, use the entire note
--			rank=strlower(rank)
--			if strfind(rank, "alt") or
--				strfind(rank, L["alt2"]) or
--				strfind(rank, L["alt3"]) then
--				GUILDNOTES[name] = note
--				--DBG print("Fallback: ",note)
--				--DBG nFallback=nFallback+1
--			end
--		end
--	end
	--DBG print("Mapped",n,"names and",nFallback,"fallbacks!")
end
