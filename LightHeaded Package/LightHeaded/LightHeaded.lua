--[[-------------------------------------------------------------------------
  LightHeaded -  Copyright 2007-2011 by Jim Whitehead

  All Rights Reserved

  This is a very simple addon which compiles quest information and comments
  from http://www.wowhead.com and displays them in-game.  This addon was
  inspired by Wowhead_Quests by sid367, and I thank him for the idea

  IMPORTANT: Addon authors that wish to use this API and data should
  include the wowhead logo in the frame that displays this information.
  They are kind enough to let me continue parsing their database, and we
  owe them at least that much.  Thank you.
---------------------------------------------------------------------------]]

-- Properly handle loading on demand through AddonLoader
local genv = getfenv(0)
if genv.LightHeaded then
    setmetatable(LightHeaded, nil)
else
    LightHeaded = {}
end
LightHeaded.version = GetAddOnMetadata("LightHeaded", "Version")
if LightHeaded.version == "wowi:revision" then LightHeaded.version = "SVN" end

-- This stores all of the quest data
local stack = {}
local noop = function() return nil end
local previous_qid

function LightHeaded:Enable()
	-- Database defaults
	self.defaults = {
		profile = {
			attached = true,
			open = true,
			singlepage = false,
			positions = {
			},
			sound = true,
            descs = false,
			bgalpha = 1.0,
			debug = false,
            fixmodel = true,
            wp_tomtom = true,
            wp_cart2 = true,
            wp_cart3 = true,
            wp_mapnotes = true,
            fontsize = 12,
		},
	}

	self.db = self:InitializeDB("LightHeadedDB", self.defaults)
	self:CreateGUI()
	hooksecurefunc("SelectQuestLogEntry", function(index)
		self:SelectQuestLogEntry(index)
	end)
	hooksecurefunc("QuestLogTitleButton_OnClick", function()
		self.quest_clicked = true
		previous_qid = nil;
		self:SelectQuestLogEntry()
	end)
    hooksecurefunc("WatchFrameLinkButtonTemplate_OnClick", function(frame)
        if frame.type == "QUEST" then
            self.quest_clicked = true
            previous_qid = nil
            self:SelectQuestLogEntry()
            LightHeadedFrameSub.forceUpdate = true
        end
    end)


	-- Create hooks for QUEST_LOG_UPDATE
	self:RegisterEvent("QUEST_LOG_UPDATE")

    -- Clear any addonloader slash commands
    local slashes = {"lh", "lightheaded", "lighthead"}
    for idx,slash in ipairs(slashes) do
        _G["SLASH_" .. slash .. "1"] = nil
        SlashCmdList[slash:upper()] = nil
        hash_SlashCmdList["/" .. slash] = nil
    end

	-- Create slash command
	self.cmd = self:InitializeSlashCommand("LightHeaded config options", "LIGHTHEADED", "lh", "lightheaded", "lighthead")
	self.cmd:RegisterSlashHandler("attach - Re-Attaches LightHeaded to the Quest Log", "^attach$", "AttachFrame")
	self.cmd:RegisterSlashHandler("detach - Detach LightHeaded from the Quest Log", "^detach$", "DetachFrame")
	self.cmd:RegisterSlashHandler("sound - Toggles open/close sound on or off", "^sound$", "ToggleSound")
	self.cmd:RegisterSlashHandler("page - Toggle showing quest information on a single page, or multiple pages.", "^page$", "TogglePages")
	self.cmd:RegisterSlashHandler("bgalpha <0.0-1.0> - Changes the alpha transparency of the LightHeaded background", "^bgalpha (%d%.?%d?)$", "ChangeBGAlpha")
	self.cmd:RegisterSlashHandler("debug - Toggles debug mode on/off.", "^debug$", "ToggleDebug")
    self.cmd:RegisterSlashHandler("config - Opens the configuration GUI", "^config$", function()
        InterfaceOptionsFrame_OpenToCategory("LightHeaded")
    end)

	-- Set initial settings
	self:ChangeBGAlpha(self.db.profile.bgalpha)
	if self.db.profile.debug then
		self:EnableDebug(1)
	else
		self:EnableDebug()
	end

    self:CreateConfig()
end

function LightHeaded:QUEST_LOG_UPDATE(event, ...)
	self.bad_select = 0
end

function LightHeaded:GetCurrentQID()
	local index = GetQuestLogSelection()
	if not index then return end

	local link = GetQuestLink(index)
	if not link then return end

	return tonumber(link:match(":(%d+):"))
end

local qidNamesLower;
function LightHeaded:LoadNames(lower)
    if not LH_QIDNames then
        -- Try to load the addon
        local addon = "LightHeaded_Data_QIDNames"
        self:Debug(1, "Loading " .. addon)
        local succ,reason = LoadAddOn(addon)
        if succ ~= 1 then
            self:Debug(1, "Could not load " .. addon, reason)
            return
        end
        collectgarbage("collect")
    end

    if LH_QIDNames then
        if lower then
            if not qidNamesLower then
                qidNamesLower = LH_QIDNames:lower()
            end
            return qidNamesLower
        else
            return LH_QIDNames
        end
    end
end

function LightHeaded:GetQuestName(qid)
	local pattern = string.format("\031%s\031[^\030]*\030([^\030]*)\030", qid)
    local names = self:LoadNames()
    return names and names:match(pattern) or "Unknown quest"
end

-- This function will store the current page/scroll offsets for the selected qid
function LightHeaded:StoreQIDOffsets()
	local lhframe = LightHeadedFrameSub
	local qid = lhframe.current_qid

	if not qid then return end

	if not self.uihistory then self.uihistory = {} end

	local page = lhframe.current_page or "nil"
	local scroll = lhframe.scroll:GetVerticalScroll() or 0

	local data = string.format("%s::%s", page, scroll)
	self:DebugF(1, "Storing QID Offset for %s: %s", qid, data)
	self.uihistory[qid] = data
end

-- This function returns the previous page/scroll offsets for the selected qid
function LightHeaded:GetQIDOffsets(qid)
	if not self.uihistory then self.uihistory = {} end
	local data = self.uihistory[qid]

	if not data then
		if self.db.profile.singlepage then
			return nil, 0
		else
			return 1, 0
		end
	else
		local page, scroll = data:match("^([^:]+)::(.+)$")
		self:DebugF(1, "Retrieving QID Offset for %s: %s", qid, data)
		page = tonumber(page)
		scroll = tonumber(scroll)
		if self.db.profile.singlepage then
			return nil, scroll
		elseif page > 0 then
			return page, scroll
		else
			return 1, scroll
		end
	end
end

function LightHeaded:GetQIDDescription(qid)
    if not LH_QIDDesc then
        -- Try to load the addon
        local addon = "LightHeaded_Data_QIDDesc"
        self:Debug(1, "Loading " .. addon)
        local succ,reason = LoadAddOn(addon)
        if succ ~= 1 then
            self:Debug(1, "Could not load " .. addon, reason)
            return
        end
        collectgarbage("collect")
    end

    if qid then
        local pat = string.format("%d\031(.-)\031(.-)\030", qid)
        return LH_QIDDesc:match(pat)
    end
end

StaticPopupDialogs["LH_OFFENDING_ADDON"] = {
	text = "LightHeaded has detected an addon conflict.  The following addons may have a severe impact on the performance of your client in combination with LightHeaded; it is suggested that you disable these addons or contact the authors for a fix: |cffff1111%s|r",
	button1 = TEXT(OKAY),
	showAlert = true,
	OnAccept = function()
	end,
	timeout = 0,
}

StaticPopupDialogs["LH_OFFENDING_UNKNOWN"] = {
	text = "LightHeaded has detected an addon conflict, but was unable to determine the source of the conflict. One or more addons are calling the SelectQuestLogEntry() function unnecessarily.  This can severely impact the performance of your client, and it is suggested that you work to determine which addons are improperly using the API.",
	button1 = TEXT(OKAY),
	showAlert = true,
	OnAccept = function()
	end,
	timeout = 0,
}

function LightHeaded:WarnOffendingAddon(err)
	local postc = err:match("%[C%]: in function (.+)")
	if postc then
		local addons = {}
		for addon in postc:gmatch("Interface\\AddOns\\([^\\]+)\\") do
			addons[addon] = true
		end
		for k,v in pairs(addons) do
			table.insert(addons, k)
		end
		StaticPopup_Show("LH_OFFENDING_ADDON", table.concat(addons, ", "))
	else
		StaticPopup_Show("LH_OFFENDING_UNKNOWN")
	end
end

local times = {}
local UPPER_LIMIT = 10
function LightHeaded:SelectQuestLogEntry(index)
	--[[
	-- Error checking to try and catch "BAD" SelectQuestLogEntry behavior
	if LightHeadedFrame:IsVisible() then
		if not self.bad_select then self.bad_select = 0 end
		self.bad_select = self.bad_select + 1
		times[self.bad_select] = GetTime()

		if self.bad_select >= UPPER_LIMIT and not self.warned then
			local first = times[1]
			local last = times[UPPER_LIMIT]
			if (last - first) < 2.0 then
				self.warned = true
				self:WarnOffendingAddon(debugstack())
				self:Debug(1, debugstack())
				self:Debug(1, "Time between first and last call: " .. (last - first))
			end
		end
	end
	--]]

	local lhframe = LightHeadedFrameSub
	local qid = self:GetCurrentQID()

	if not qid then return end

	-- Kill the search flag
	lhframe.search = false

	-- Track the previous QID so we don't break pages
	-- if someone happens to call the API again

	if qid == previous_qid and qid == lhframe.current_qid then
		-- Do nothing
		return
	end

	-- Store the current offset information
	self:StoreQIDOffsets()

	-- Update the stored QID
	previous_qid = qid
	lhframe.current_qid = qid

	-- Clear the stack
	for k,v in pairs(stack) do stack[k] = nil end

	-- Now pull up the stored page/offset
	local page, scroll = self:GetQIDOffsets(qid)

	if self.quest_clicked then
		page = 1
		scroll = 0
		self.quest_clicked = nil
	end

	if self.db.profile.singlepage then
		self:UpdateFrame(qid, nil, scroll)
	else
		lhframe.current_page = page
		self:UpdateFrame(qid, page, scroll)
	end
end

local genv = getfenv(0)
function LightHeaded:GetQuestData(qid)
	if not qid then
		return nil
	end
	for i=#LH_QIDMap,1,-1 do
		local min = LH_QIDMap[i]
		if qid >= min then
			local varname = LH_QIDMap.vars[i]
			local addon = LH_QIDMap.addons[i]
			if not genv[varname] then
				-- Try to load the addon
				self:Debug(1, "Loading " .. addon)
				local succ,reason = LoadAddOn(addon)
				if succ ~= 1 then
					self:Debug(1, "Could not load " .. addon, reason)
					return
				end
				collectgarbage("collect")
			end

			-- Return the data
			return genv[varname][qid]
		end
	end
end

function LightHeaded:LoadNPCData(npc)
    if not LH_NPCData then
        local addon = "LightHeaded_Data_NPC"
        -- Try to load the stub
        self:Debug(1, "Loading " .. addon)
        local succ,reason = LoadAddOn(addon)
        if succ ~= 1 then
            self:Debug(1, "Could not load " .. addon, reason)
            return
        end
        collectgarbage("collect")
    end

	return LH_NPCData and LH_NPCData[npc]
end

--[[-------------------------------------------------------------------------
--  The following code can be used along with the output from
--  GetZoneTableCode.lua to get a mapping from WowHead zone numeric id to
--  MPQ filename.  This allows for local independent mapping of coordinates

local wzid = {
}

local ntoid = {}
for i = 0, 5000 do
   local name = GetMapNameByID(i)
   if name then
      ntoid[name] = i
   end
end

for k,v in pairs(wzid) do
   if not ntoid[v] then
      print("NO ZONE INFO FOR : " .. v)
      wzid[k] = nil
   else
      wzid[k] = ntoid[v]
   end
end

local out = "local zidmap = {"
local sort = {}
for k,v in pairs(wzid) do
   table.insert(sort, k)
end
table.sort(sort)
for idx,num in ipairs(sort) do
   out = string.format("%s\n   [%d] = %q,", out, num, wzid[num])
end
out = out .. "\n}\n"

local frame = CreateFrame("EditBox", nil, UIParent, "InputBoxTemplate")
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetText("Heyas")
frame:SetAutoFocus(false)
frame:Show()
frame:SetHeight(400)
frame:SetWidth(400)
frame:SetText(out)-------------------------------------------------------------------------]]--

-- A mapping from wowhead zone id (dbc) to in-game map id
local zidmap = {
   [1] = "27",
   [3] = "17",
   [4] = "19",
   [8] = "38",
   [10] = "34",
   [11] = "40",
   [12] = "30",
   [14] = "4",
   [15] = "141",
   [16] = "181",
   [17] = "11",
   [28] = "22",
   [33] = "37",
   [38] = "35",
   [40] = "39",
   [41] = "32",
   [44] = "36",
   [45] = "16",
   [46] = "29",
   [47] = "26",
   [51] = "28",
   [65] = "488",
   [66] = "496",
   [67] = "495",
   [85] = "20",
   [130] = "21",
   [139] = "23",
   [141] = "41",
   [148] = "42",
   [209] = "764",
   [210] = "492",
   [215] = "9",
   [267] = "24",
   [331] = "43",
   [357] = "121",
   [361] = "182",
   [394] = "490",
   [400] = "61",
   [405] = "101",
   [406] = "81",
   [440] = "161",
   [490] = "201",
   [491] = "761",
   [493] = "241",
   [495] = "491",
   [616] = "683",
   [618] = "281",
   [722] = "760",
   [796] = "762",
   [1176] = "686",
   [1377] = "261",
   [1497] = "382",
   [1519] = "301",
   [1537] = "341",
   [1637] = "321",
   [1638] = "362",
   [1657] = "381",
   [1977] = "793",
   [2017] = "765",
   [2057] = "763",
   [2100] = "750",
   [2366] = "733",
   [2367] = "734",
   [2597] = "401",
   [2817] = "510",
   [3430] = "462",
   [3433] = "463",
   [3483] = "465",
   [3487] = "480",
   [3518] = "477",
   [3519] = "478",
   [3520] = "473",
   [3521] = "467",
   [3522] = "475",
   [3523] = "479",
   [3524] = "464",
   [3525] = "476",
   [3537] = "486",
   [3557] = "471",
   [3703] = "481",
   [3711] = "493",
   [3805] = "781",
   [4080] = "499",
   [4197] = "501",
   [4228] = "528",
   [4265] = "803",
   [4298] = "502",
   [4395] = "504",
   [4706] = "684",
   [4709] = "607",
   [4714] = "679",
   [4720] = "682",
   [4737] = "605",
   [4755] = "611",
   [4812] = "604",
   [4813] = "602",
   [4815] = "610",
   [4820] = "603",
   [4922] = "770",
   [4987] = "609",
   [5034] = "748",
   [5042] = "640",
   [5095] = "708",
   [5144] = "615",
   [5145] = "614",
   [5146] = "613",
   [5287] = "673",
   [5389] = "709",
   [5396] = "747",
   [5416] = "751",
   [5695] = "772",
   [5733] = "795",
   [5788] = "816",
   [5789] = "820",
   [5844] = "819",
   [5861] = "823",
   [5892] = "824",
}

local czmap = {}
function LightHeaded:WZIDToCZ(zid)
	local mapid = zidmap[zid]
	if mapid then
		mapid = tonumber(mapid)

		-- Fill up the list
		if not next(czmap) then
			local c = {GetMapContinents()}
			for cid, cname in ipairs(c) do
				local z = {GetMapZones(cid)}
				for zid, zname in ipairs(z) do
					czmap[zname] = {cid, zid}
				end
			end
		end

		-- Spit it out
		local name = GetMapNameByID(mapid)
		return unpack(czmap[name])
	end
end

-- IMPORTANT: Addon authors that wish to use this API and data should
-- include the wowhead logo in the frame that displays this information.
-- They are kind enough to let me continue parsing their database, and we
-- owe them at least that much.  Thank you.

-- COMMENTINFO:
-- Comment format in the data files has changed:
--   user, userRating, rating, sticky, date, body (\031)
--
-- Replies use the same format and follow after a comment

function LightHeaded:GetNumQuestComments(qid)
	local data = self:GetQuestData(qid)
	return data and #data - 1 or 0
end

local comment_pattern = string.rep("([^\031]*)\031", 6) .. "$"

function LightHeaded:GetQuestComment(qid, idx)
	-- Adjust for offset
	idx = idx + 1
	local data = self:GetQuestData(qid)
	local cinfo = data and data[idx]
	if cinfo then
		local user, urating, rating, sticky, date, body = cinfo:match(comment_pattern)
		return qid, 0, rating, 0, 0, date, user, body
		--return qid,cid,rating,indent,parent,date,poster,comment
	end
end

local function iter_comments(tbl, idx)
	idx = idx + 1
	local val = tbl and tbl[idx]
	if val then
		local user, urating, rating, sticky, date, body = cinfo:match(comment_pattern)
		return qid, 0, rating, 0, 0, date, user, body
		--return idx,qid,cid,rating,indent,parent,date,poster,comment
	end
end

function LightHeaded:IterateQuestComments(qid)
	local data = self:GetQuestData(qid)
	return iter_comments, data, 1
end

local qinfopattern = "([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\030]-)\030"
function LightHeaded:GetQuestInfo(qid)
	local data = self:GetQuestData(qid)
	if not data or not data[1] then
		self:DebugF(1, "Could not find quest information for quest %s", qid)
		return
	end

	local qinfo = data[1]
	local qid,sharable,level,reqlev,stype,sname,sid,etype,ename,eid,exp,rep,series = qinfo:match(qinfopattern)
	return qid,sharable,level,reqlev,stype,sname,sid,etype,ename,eid,exp,rep,series
end

function LightHeaded:IterateQuestInfo(qid)
	local data = self:GetQuestData(qid)
	local qinfo = data and data[1]
	if not qinfo then
		self:DebugF(1, "Could not find quest information for quest %s", qid)
		return noop
	end

	return qinfo:gmatch(qinfopattern)
end

function LightHeaded:IterateNPCLocs(id)
	local data = self:LoadNPCData(id)
	if data then
		local iter,inv,state = data:gmatch("([^,]+),([^,]+),([^:]+):")
		return function(...)
			local zid,x,y = iter()
			if zid then zid = tonumber(zid) end
			if x then x = tonumber(x) end
			if y then y = tonumber(y) end
			local c,z = self:WZIDToCZ(zid)
			return c, z, x, y
		end
	end
	return noop
end

function LightHeaded:SetFrameTooltip(frame, text)
	frame:SetScript("OnEnter", function(frame, ...)
								   GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
								   GameTooltip:SetText(text)
								   GameTooltip:Show()
							   end)
	frame:SetScript("OnLeave", function(frame, ...)
								   GameTooltip:Hide()
							   end)
end

local function linkifyItemURLs(comment, pattern)
	while true do
		local front,back,id = 1
		front,back,id = comment:find(pattern,front)
		if not front then break end
		local link = ("item:%d:0:0:0:0:0:0:0"):format(id)
		local name,_,rarity = GetItemInfo(link)
		local color
		if name then
			color = ITEM_QUALITY_COLORS[rarity].hex
		else
			name = "Item: " .. id
			color = "|cffff1111"
		end
		comment = ("%s%s|Hlhref:%s|h[%s]|h|r%s"):format(comment:sub(1,front-1),color,link,name,comment:sub(back+1))
	end
	return comment
end

do
	local locale = GetLocale()
	local fmt = "%d%s%02d%s %d%s%02d"
	local dec, list = ".", ","

	if locale == "deDE" then
		dec, list = ",", ","
	else
		local fstring = CreateFrame("Frame"):CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		fstring:SetText("12.34")
		local sep = fstring:GetText():sub(3,3)
		if sep ~= dec then
			dec = sep
			list = ";"
		end
	end

	function LightHeaded:GetCoordText(x, y)
		local xi, xf = math.modf(x)
		local yi, yf = math.modf(y)
		return fmt:format(xi, dec, xf * 100, list, yi, dec, yf * 100)
	end
end

function LightHeaded:GetCommentText(qid, idx)
	local qid,cid,rating,indent,parent,date,poster,comment = self:GetQuestComment(qid, idx)
	local fmt = "|cffffd100Posted by |r%s |cffffd100on|r %s|cffffd100:|r\n\n%s"

	-- coordinates
	local formatcoords = function(text,x,y)
		return string.format("|cFF0066FF|Hlhref:coord:%s:%s:%s|h[%s]|h|r", x, y, qid, text)
	end
	comment = comment:gsub("((%d?%d%.?%d?%d?)%s*[, ]%s*(%d?%d%.?%d?%d?))", formatcoords)
	-- bold
	comment = comment:gsub("%[b%]", "|cFFFFFFFF")
	comment = comment:gsub("%[/b%]", "|r")
	-- italic
	comment = comment:gsub("%[i%]", "|cFFFFFF00")
	comment = comment:gsub("%[/i%]", "|r")
	-- underline
	comment = comment:gsub("%[u%]", "|cFF00FFFF")
	comment = comment:gsub("%[/u%]", "|r")
	-- small
	comment = comment:gsub("%[small%]", "")
	comment = comment:gsub("%[/small%]", "")
	-- ol/ul
	comment = comment:gsub("%[([ou])l%](.-)%[/%1l%]", function(listtype,content)
		local lis = "\n";
		local count = 1

		for li in content:gmatch("%[li%](.-)%[/li%]") do
			lis = lis .. "    |cFFFF0000"

			if(listtype == "o") then
				lis = lis .. count
				count = count + 1
			else
				lis = lis .. "*"
			end

			lis = lis .. "|r " .. li .. "\n"
		end

		return lis
	end)
	-- quote
	comment = comment:gsub("%[quote%](.-)%[/quote%]", "\n|cFFFFFF00 > |cFFCCCCCC%1|r\n\n")
	-- item
	comment = comment:gsub("%[url=[^%]]-wowhead.com/%?item=(%d+)](.-)%[/url%]", "|cFF0099AA|Hlhref:item:%1:0:0:0:0:0:0:0|h[%2]|h|r")
	-- spell
	comment = comment:gsub("%[url=[^%]]-wowhead.com/%?spell=(%d+)](.-)%[/url%]", "|cFF71D5FF|Hlhref:spell:%1|h[%2]|h|r")
	-- achievement
	comment = comment:gsub("%[url=[^%]]-wowhead.com/%?achievement=(%d+)](.-)%[/url%]", function(id,content)
		local link = GetAchievementLink(id)

		link = link:gsub("|Hachievement:", "|Hlhref:achievement:")
		link = link:gsub("%[.-%]", "[" .. content .. "]") -- replace achievement name with original link text

		return link
	end)
	-- quest
	comment = comment:gsub("%[url=[^%]]-wowhead.com/%?quest=(%d+)](.-)%[/url%]", "|cFF0099AA|Hlhref:quest:%1|h[%2]|h|r")
	-- other links
	comment = comment:gsub("%[url=(.-)%](.-)%[/url%]", "|cFF70B8FF|Hlhref:external:%1|h[%2]|h|r")

	return fmt:format(poster, date, comment)
end

-- This function is called with a quest id
-- In addition, a page can be specified.  If the page is specified
-- then we show that page (where page 1 is the qinfo).  If page
-- is nil, then we will display everything in one single string

function LightHeaded:GetPageText(qid, page)
	local text = ""

	-- Generate the qinfo page
	if not page or page == 1 then
		for qid,sharable,level,reqlev,stype,sname,sid,etype,ename,eid,exp,rep,series in self:IterateQuestInfo(qid) do

			if not qid then
				-- There was an error
				self:Print("Unable to parse " .. data[1] .. ", please report this error to cladhaire")
				return
			end

			-- Add a line feed if this is a second entry
			if text ~= "" then
				text = text .. "\n\n"
			end

			local title = self:GetQuestName(qid)
			-- Title will always exist
			text = text .. "|cffffd100Name:|r " .. title
			-- QID will always exist
			text = text .. "\n|cffffd100Quest ID:|r |Hlhref:external:http://www.wowhead.com/?quest="..qid.."|h" .. qid .. "|h"
			-- Sharable will always exist
			text = text .. "\n|cffffd100Sharable:|r " .. (sharable and "Yes" or "No")
			-- Level will always exist
			text = text .. "\n|cffffd100Level:|r " .. level

            if self.db.profile.descs then
                local intro, desc = self:GetQIDDescription(qid)
                if intro then
                    text = text .. "\n|cffffd100Intro:|r " .. intro
                end
                if desc then
                    text = text .. "\n|cffffd100Description:|r " .. desc
                end
            end

            -- All other params are optional
			if reqlev ~= "" then
				text = text .. "\n|cffffd100Required Level:|r " .. reqlev
			end

			if stype ~= "" and sname ~= "" then
				local link
				if stype == "npc" then
					link = "|cFF0066FF|Hlhref:npc:"..sid..":"..sname.."|h["..sname.."]|h|r"
				else
					link = "|cFFFFFFFF"..sname.."|r"
				end

				text = text .. "\n|cffffd100Starts:|r " .. link
			end

			if etype ~= "" and ename ~= "" then
				local link
				if etype == "npc" then
					link = "|cFF0066FF|Hlhref:npc:"..eid..":"..ename.."|h["..ename.."]|h|r"
				else
					link = "|cFFFFFFFF"..ename.."|r"
				end

				text = text .. "\n|cffffd100Ends:|r " .. link
			end

			if exp ~= "" then
				text = text .. "\n|cffffd100Experience:|r " .. exp

-- Quest XP awarded at level Begin
-- I've added the following section to calculate expected reward based on quest level
-- This is my fist time writing in lua, so I'm sure this could be better optimized.
-- I've also added the calculation for xp to money conversion if you're level 70
-- I'm aware that I need to further modify this to check if they have burning crusade installed
-- so that it calculates at level 60 if you don't have it installed, and at level 80 if you
-- have WOTLK. I'm also using UnitLevel("player") to determine the current level of the player
-- as I have read in the API reference this can lead to a wrong level being displayed at level
-- up or soon after. They suggest you register for event PLAYER_LEVEL_UP where arg1 provides
-- the current level, but since I'm new to this, registering for an event notification was beyond
-- my skill level.
--
-- I also used a color scheme that doesn't match the quest color code in the quest log.
-- since you get 100% xp for almost all colors in the quest log except for some greens
-- and grey's I colored 80% xp as orange, 60% as yellow, 40% and 20% as green, and 10% grey.

                exp = tonumber(exp) or 0
				local characterlevel = tonumber(UnitLevel("player"))
				local expaward = exp
				local mula,mulacopper,mulasilver,mulagold
                local levelcheck

				if level ~= "" then
					levelcheck = (tonumber(level) + 5)
					if (characterlevel <= levelcheck) then
						expaward = exp
					end
					levelcheck = (tonumber(level)+ 6)
					if characterlevel == levelcheck then
	 					expaward = math.floor(exp * 0.8 / 5) * 5
					end
					levelcheck =(tonumber(level)+7)
					if characterlevel == levelcheck then
	 					expaward = math.floor(exp * 0.6 / 5) * 5
					end
					levelcheck =(tonumber(level)+8)
					if characterlevel == levelcheck then
	 					expaward = math.floor(exp * 0.4 / 5) * 5
					end
					levelcheck =(tonumber(level)+9)
					if characterlevel == levelcheck then
	 					expaward = math.floor(exp * 0.2 / 5) * 5
					end
					levelcheck =(tonumber(level)+10)
					if characterlevel >= levelcheck and characterlevel < 70 then
	 					expaward = math.floor(exp * 0.1 / 5) * 5
					end
				end
				if characterlevel == 70 then
					expaward = ""
					mula=exp*6
					mulagold=math.floor(mula/10000)
					mulasilver=math.floor((mula-mulagold*10000)/100)
					mulacopper=mula-mulagold*10000-mulasilver*100
					if mulagold ~= 0 then
						expaward = "|cffffff00" .. mulagold .. "g|r"
					end
					if mulasilver ~= 0 then
						expaward = expaward .. "|cff9999cc" .. mulasilver .."s|r"
					end
					if mulacopper ~= 0 then
						expaward = expaward .. "|cffcc6633" .. mulacopper .."c|r"
					end
				end
				if exp ~= expaward then
					text = text .. "\n|cffffd100 At level "..characterlevel..":|r "
					if level ~= "" then
						levelcheck = (tonumber(level)+ 6)
						if characterlevel == levelcheck then
							text = text .. "|cffff9900" .. expaward .. "|r"
						end
						levelcheck =(tonumber(level)+7)
						if characterlevel == levelcheck then
							text = text .. "|cffffdd00" .. expaward .. "|r"
						end
						levelcheck =(tonumber(level)+8)
						if characterlevel == levelcheck then
							text = text .. "|cff339900" .. expaward .. "|r"
						end
						levelcheck =(tonumber(level)+9)
						if characterlevel == levelcheck then
							text = text .. "|cff339900" .. expaward .. "|r"
						end
						levelcheck =(tonumber(level)+10)
						if characterlevel >= levelcheck and characterlevel < 70 then
							text = text .. "|cff999999" .. expaward
						end
					end
					if characterlevel == 70 then
						text = text .. expaward
					end
				end
			end

			if rep ~= "" then
				text = text .. "\n|cffffd100Reputation Gains:|r"

				for name,value in rep:gmatch("([^\029]+)\029([^\029]+)") do
					text = text .. "\n|cffffd100 - " .. name .. "|r: " .. value
				end
			end

			if series ~= "" then
				text = text .. "\n|cffffd100Quest Series:|r"

				for step,id in series:gmatch("([^\029]+)\029([^\029]+)") do
					local name = self:GetQuestName(id)
					local link = "|cFF0066FF|Hlhref:quest:"..id.."|h["..name.."]|h|r"
					if qid == id then
						text = text .. "\n|cffffd100 - "..step..".|r " .. name
					else
						text = text .. "\n|cffffd100 - "..step..".|r " .. link
					end
				end
			end
		end
	end

    local title = self:GetQuestName(qid)

	if not page then
		text = text .. "\n\n"
	end

	-- Generate the comments pages
	if page and page > 1 then
		text = text .. string.format("|cffffd100Comments for |r%s\n", title)
		text = text .. self:GetCommentText(qid, page - 1)
	elseif not page then
		text = text .. string.format("|cffffd100Comments for |r%s\n", title)
		for i=1,self:GetNumQuestComments(qid) do
			text = text .. self:GetCommentText(qid, i) .. "\n\n"
		end
	end

	return text
end

-- This function can be called from a few different places
-- 1. In response to a quest being clicked in the quest log
-- 2. In response to a lhref:quest link
-- 3. In response to the "Next" button being pushed
-- 4. In response to the "Prev" button being pushed
-- In response to a lhref:back link
--
-- Each of these should be able to pass in their own page information,
-- or possibly no page information.  This function just calls
-- GetPageText() and enables/disables the buttons and sets the
-- page text.
--
-- Stack is a local table which allows us to store the stack of pages
-- So we can navigate back out.
--
-- Possible values for page:
--   1 - Show the Quest Information Page, and page the results
--  >1 - Show the given Comment Page, paging the results
-- nil - Show all quest information, in a single scrolling frame

function LightHeaded:UpdateFrame(qid, page, scrollOffset)
	-- If we're not visible, do nothing.
	local lhframe = LightHeadedFrameSub

    if lhframe.forceUpdate then
        lhframe.forceUpdate = false
    elseif not lhframe:IsVisible() then
		return
	end

	self:DebugF(1, "Updating the LightHeaded frame with qid %s", tostring(qid))
	if page and page < 0 then
		page = nil
	end

	local title = self:GetQuestName(qid)

	-- This is where we store our output as we build it
	local text = ""

	-- Check to see if we have something on the stack
	if #stack > 0 then
		-- Create a backlink to the last quest on the stack
		local link = "|cFF0066FF|Hlhref:back|h[Back]|h|r\n"
		text = text .. link
	end

	text = text .. self:GetPageText(qid, page)
	lhframe.text:MySetText(text)
	lhframe:MySetScroll(scrollOffset or 0)

	if page then
		local num = self:GetNumQuestComments(qid)
		if not num then return end

		local max = num + 1
		lhframe.page:SetText(("Page %s of %s"):format(page, max))

		lhframe.page:Show()
		lhframe.prev:Show()
		lhframe.next:Show()

		lhframe.prev:Enable()
		lhframe.next:Enable()

		if page == 1 then
			lhframe.prev:Disable()
		end

		if page == max then
			lhframe.next:Disable()
		end
	else
		lhframe.page:Hide()
		lhframe.prev:Hide()
		lhframe.next:Hide()
	end


	lhframe.qid = qid
	lhframe.current_page = page or -1
	lhframe.scroll:UpdateScrollChildRect()
end

-- From Chatter/UrlCopy
local currentLink
StaticPopupDialogs["LHUrlDialog"] = {
	text = "URL",
	button2 = CLOSE,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		local editBox = _G[self:GetName().."WideEditBox"]
		if editBox then
			editBox:SetText(currentLink)
			editBox:SetFocus()
			editBox:HighlightText(0)
		end
		local button = _G[self:GetName().."Button2"]
		if button then
			button:ClearAllPoints()
			button:SetWidth(200)
			button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
		end
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	maxLetters=1024, -- this otherwise gets cached from other dialogs which caps it at 10..20..30...
}

function LightHeaded:OnHyperlinkClick(frame, link, text, button)
	local lhframe = LightHeadedFrameSub

	if not link then return end

	if link:match("^lhref:npc") then
		-- Push the current quest onto the stack
		table.insert(stack, lhframe.current_page)
		table.insert(stack, lhframe.qid)

		local id,name = link:match("^lhref:npc:(.+):(.+)$")
		local text = "|cFF0066FF|Hlhref:back|h[Back]|h|r\n\n"

		id = tonumber(id)

		text = text .. "\nKnown locations for |cFFFFFFFF" .. name .. "|r:\n"

		if self:LoadNPCData(id) then
			for c,z,x,y in self:IterateNPCLocs(id) do
				local coordText = self:GetCoordText(x, y)
				text = text .. "\n|cFF0066FF|Hlhref:zcoord:"..c..":"..z..":"..x..":"..y..":"..name.."|h["..coordText.."]|h|r"
			end
		else
			text = text .. "\nLocation unknown"
		end

		lhframe.searching = false
		lhframe.text:MySetText(text)
		lhframe.scroll:UpdateScrollChildRect()
		lhframe.next:Disable()
		lhframe.prev:Disable()
	elseif link:match("^lhref:coord") then
		local xt,yt,qid = link:match("^lhref:coord:([^:]+):([^:]+):(.+)")
		local x = tonumber(xt)
		local y = tonumber(yt)

		if not x or not y then
			self:Print("The coordinate you clicked on was not valid: %s", link)
			return
		end

		local note
		if not tonumber(qid) then
			note = qid
		else
			note = string.format("[LH] %s", self:GetQuestName(qid))
		end

        if self.db.profile.wp_tomtom then
            -- Send the note to TomTom
            if TomTom then
                TomTom:AddWaypoint(x, y, note)
            end
        end

        if self.db.profile.wp_cart2 then
            -- Cartographer 2
            if  Cartographer_Waypoints and type(Cartographer_Waypoints.AddLHWaypoint) == "function" then
                self:Debug(1, "Sending waypoint to Cartographer", x, y, note or "No note")
                Cartographer_Waypoints:AddLHWaypoint(nil, nil, x, y, note)
            elseif Cartographer_Waypoints then
                self:Print("LightHeaded waypoints are not supported in this version of Cartographer_Waypoints.")
            end
        end

        if self.db.profile.wp_cart3 then
            -- Cartographer 3
            if Cartographer3_Waypoints then
                local c,z = GetCurrentMapContinent(), GetCurrentMapZone()
                if c and z then
                    self:Debug(1, "Sending waypoint to Cart3", x, y , note or "No note")
                    Cartographer3_Waypoints.SetWaypoint(c, z, x/100, y/100, note or "No note", "LightHeaded")
                end
            end
        end

        if self.db.profile.wp_mapnotes then
            -- MapNotes
            if MN_ThottInterface and type(MN_ThottInterface_Local) == "function" then
                MN_ThottInterface_Local(x, y, note)
            end
        end

	elseif link:match("^lhref:zcoord") then
		local c,z,x,y,qid = link:match("^lhref:zcoord:([^:]+):([^:]+):([^:]+):([^:]+):(.+)")
		c = tonumber(c)
		z = tonumber(z)
		x = tonumber(x)
		y = tonumber(y)

		local note
		if not tonumber(qid) then
			note = qid
		else
			note = string.format("[LH] %s", self:GetQuestName(qid))
		end

       if self.db.profile.wp_tomtom then
            -- Send the note to TomTom
            if TomTom then
                TomTom:AddZWaypoint(c, z, x, y, note)
            end
        end

        if self.db.profile.wp_cart2 then
            -- Cartographer 2
            if  Cartographer_Waypoints and type(Cartographer_Waypoints.AddLHWaypoint) == "function" then
                self:Debug(1, "Sending waypoint to Cartographer", x, y, note or "No note")
                Cartographer_Waypoints:AddLHWaypoint(c, z, x, y, note)
            elseif Cartographer_Waypoints then
                self:Print("LightHeaded waypoints are not supported in this version of Cartographer_Waypoints.")
            end
        end

        if self.db.profile.wp_cart3 then
            -- Cartographer 3
            if Cartographer3_Waypoints then
                if c and z then
                    self:Debug(1, "Sending waypoint to Cart3", x, y , note or "No note")
                    Cartographer3_Waypoints.SetWaypoint(c, z, x/100, y/100, note or "No note", "LightHeaded")
                end
            end
        end

        if self.db.profile.wp_mapnotes then
            -- MapNotes
            if MN_ThottInterface and type(MN_ThottInterface_Legacy) == "function" then
                MN_ThottInterface_Legacy(c, z, x, y, note)
            end
        end

	elseif link:match("^lhref:external") then
		local url = link:match("^lhref:external:(.+)$")
		currentLink = url
		StaticPopup_Show("LHUrlDialog")

	elseif link:match("^lhref:quest:") then
		-- This is only called from within LH, so push the stack
		if lhframe.searching then
			for k,v in pairs(stack) do
				stack[k] = nil
			end
			table.insert(stack, LightHeadedSearchBox:GetText())
			table.insert(stack, "SEARCH")
			lhframe.searching = false
		else
			table.insert(stack, lhframe.current_page)
			table.insert(stack, lhframe.qid)
		end


		local qid = link:match("^lhref:quest:(.+)$")
		qid = tonumber(qid)

		if self.db.profile.singlepage then
			self:UpdateFrame(qid, nil)
		else
			self:UpdateFrame(qid, 1)
		end
	elseif link:match("^lhref:back$") then
		-- Pop from the stack and display
		local qid = table.remove(stack)
		local page = table.remove(stack)

		if qid == "SEARCH" then
			self:SearchQuests(page)
		else
			self:UpdateFrame(qid, page)
		end
	elseif link:match("^lhref:item:") then
		link = link:sub(7)
		local name,chatLink = GetItemInfo(link)
		if name then
			if IsControlKeyDown() then
				DressUpItemLink(link)
			elseif IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
				ChatFrameEditBox:Insert(chatLink)
			else
				SetItemRef(link)
			end
		elseif IsAltKeyDown() then
			local tooltip = lhframe.tooltip
			tooltip.linkForced = link
			tooltip:SetOwner(lhframe.text,"ANCHOR_CURSOR")
			tooltip:SetHyperlink(link, text, button)
		end
	elseif link:match("^lhref:spell") then
		link = link:sub(7)
		SetItemRef(link)
	elseif link:match("^lhref:achievement") then
		link = link:sub(7)
		local id = link:match("achievement:(.-):")
		SetItemRef(link, GetAchievementLink(id), button) -- SetItemRef won't work at all with achievements without the correct text parameter, and since our link might have the wrong text we need to regenerate it
	else
		self:Print("Unmanaged lhref: " .. link)
	end
end


StaticPopupDialogs["LIGHTHEADED_NO_DATA"] = {
	template = "This quest data could not be found.  Please report this quest number to cladhaire@gmail.com.",
	button1 = TEXT(OKAY),
	OnAccept = function()
			   end,
	timeout = 0,
	hideOnEscape = 1
}

function LightHeaded:OnHyperlinkEnter(frame, link)
	local lhframe = LightHeadedFrameSub

	if not link then return end

	if link:match("^lhref:item") then
		link = link:sub(7)
		local tooltip = lhframe.tooltip
		local name = GetItemInfo(link)
		tooltip:SetOwner(frame,"ANCHOR_CURSOR")
		if name then
			tooltip:SetHyperlink(link)
		else
			tooltip:AddLine("WARNING",1,0,0)
			tooltip:AddLine("This item is not cached by your game client. You may request the item from the server by |cffffffffALT-CLICKing|r the item link.  However, if the server hasn't seen this item since the last server restart, you will be disconnected.",1,1,0,1)
		end
		tooltip:Show()
	elseif link:match("^lhref:quest") or link:match("^lhref:spell") or link:match("^lhref:achievement") then
		link = link:sub(7)
		local tooltip = lhframe.tooltip
		tooltip:SetOwner(frame,"ANCHOR_CURSOR")
		tooltip:SetHyperlink(link)
		tooltip:Show()
	elseif link:match("^lhref:external") then
		local url = link:match("^lhref:external:(.+)$")
		local tooltip = lhframe.tooltip
		tooltip:SetOwner(frame,"ANCHOR_CURSOR")
		tooltip:AddLine(url, 0x70/0xFF, 0xB8/0xFF, 0xFF/0xFF)
		tooltip:Show()

	elseif link:match("^lhref:coord") then
		local xt,yt,qid = link:match("^lhref:coord:([^:]+):([^:]+):(.+)")
		local x = tonumber(xt)
		local y = tonumber(yt)

		if not x or not y then
			self:Print("The coordinate you clicked on was not valid: %s", link)
			return
		end
		local tooltip = lhframe.tooltip
		tooltip:SetOwner(frame,"ANCHOR_CURSOR")
		tooltip:AddLine("Waypoint to " .. self:GetCoordText(x, y), 0x70/0xFF, 0xB8/0xFF, 0xFF/0xFF)
		tooltip:Show()
	end

end

local frame_offsets = {
	[QuestLogFrame] = {-15, 0},
	[QuestLogDetailFrame] = {-13, -4}
}

local npcelems = {
   "QuestNPCModelBg",
   "QuestNPCModelShadowOverlay",
   "QuestNPCModelTopBg",
   "QuestNPCModelBotLeftCorner",
   "QuestNPCModelBotRightCorner",
   "QuestNPCModelTopBorder",
   "QuestNPCModelBottomBorder",
   "QuestNPCModelLeftBorder",
   "QuestNPCModelRightBorder",
   "QuestNPCModelNameplate",
   "QuestNPCModelBlankNameplate",
   "QuestNPCModelNameText",
   "QuestNPCCornerTopLeft",
   "QuestNPCCornerTopRight",
   "QuestNPCCornerBottomLeft",
   "QuestNPCCornerBottomRight",
   "QuestNPCModelTextFrame",
}

local npcpoints

-- We don't bother re-anchoring, since that will happen automatically when the
-- portrait is updated.
function LightHeaded:ReleaseNPCModel()
    local npc = QuestNPCModel
    if npcpoints then
        for idx, name in ipairs(npcelems) do
            local elem = _G[name]
            if elem and elem.Show then
                elem:Show()
            end
        end
        npc:ClearAllPoints()
        for idx, point in ipairs(npcpoints) do
            pcall(npc.SetPoint, npc, unpack(point))
        end
        npc:SetAlpha(1.0)
        npcpoints = nil
    end
end

function LightHeaded:HijackQuestNPCModel()
    -- Check to see if the parent of the frame has been set manually
    -- to something other than QuestLogFrame or QuestLogDetailFrame.
    local current = LightHeadedFrame:GetParent()
    if not frame_offsets[current] then
        -- Some other addon is 'controlling' LightHeaded, so do nothing.
        return
    end

    -- Are we detached?
    if not self.db.profile.attached then
        return
    end

    -- Check and see if the QuestNPCModel has been shown or not
    local npc = QuestNPCModel

    if npc:IsShown() and npc:GetParent() == QuestLogFrame and current:IsVisible() and self.db.profile.fixmodel then
        -- hide all the elements of the model and move it into our frame
        for idx, name in ipairs(npcelems) do
            local elem = _G[name]
            if elem and elem.Hide then
                elem:Hide()
            end
        end

        npcpoints = {}
        npcpoints.n = npc:GetNumPoints()
        for idx = 1, npcpoints.n do
            npcpoints[idx] = {npc:GetPoint(idx)}
        end

        QuestNPCModel:ClearAllPoints()
        QuestNPCModel:SetPoint("BOTTOMLEFT", LightHeadedFrame, "BOTTOMLEFT", 40, 0)
        QuestNPCModel:SetAlpha(0.35)
		self.npcWasMouseEnabled = QuestNPCModel:IsMouseEnabled()
		QuestNPCModel:EnableMouse(false)
    else
        self:ReleaseNPCModel()
		QuestNPCModel:EnableMouse(self.npcWasMouseEnabled)
    end
end

function LightHeaded:AdjustGUIParent()
	if LightHeadedFrame then
        -- Check to see if the parent of the frame has been set manually
        -- to something other than QuestLogFrame or QuestLogDetailFrame.
        local current = LightHeadedFrame:GetParent()
        if not frame_offsets[current] then
            -- Some other addon is 'controlling' LightHeaded, so do nothing.
            return
        end

        -- Attack to the detail frame by default
		local parent = QuestLogDetailFrame

		if QuestLogFrame:IsVisible() then
			parent = QuestLogFrame
			LightHeaded_FrameWatchBug:SetParent(QuestLogDetailFrame)
		else
			LightHeaded_FrameWatchBug:SetParent(QuestLogFrame)
		end

		LightHeadedFrame:SetParent(parent)
		LightHeadedFrame:SetFrameLevel(0)

		if self.db.profile.attached then
			local x, y = unpack(frame_offsets[parent])

			if not self.db.profile.open then
				x = x - 313
			end

			LightHeadedFrame:SetPoint("LEFT", parent, "RIGHT", x, y)
		end
	end
end

function LightHeaded:CreateGUI()
	if LightHeadedFrame then
		return
	end

	local lhframe = CreateFrame("Frame", "LightHeadedFrame", QuestLogFrame)

	CreateFrame("Frame", "LightHeaded_FrameWatchBug", QuestLogDetailFrame):SetScript("OnShow", function() LightHeaded:AdjustGUIParent() end)
	lhframe:SetScript("OnShow", function() LightHeaded:AdjustGUIParent() end)

	local topleft = lhframe:CreateTexture(nil, "ARTWORK")
	topleft:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopLeft")
	topleft:SetWidth(128)
	topleft:SetHeight(256)
	topleft:SetPoint("TOPLEFT", 0, 0)

	local topright = lhframe:CreateTexture(nil, "ARTWORK")
	topright:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopRight")
	topright:SetWidth(140)
	topright:SetHeight(256)
	topright:SetPoint("TOPRIGHT", 0, 0)
	topright:SetTexCoord(0, (140 / 256), 0, 1)

	local top = lhframe:CreateTexture(nil, "ARTWORK")
	top:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-Top")
	top:SetHeight(256)
	top:SetPoint("TOPLEFT", topleft, "TOPRIGHT", 0, 0)
	top:SetPoint("TOPRIGHT", topright, "TOPLEFT", 0, 0)

	local botleft = lhframe:CreateTexture(nil, "ARTWORK")
	botleft:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-BotLeft")
	botleft:SetWidth(128)
	botleft:SetHeight(168)
	botleft:SetPoint("BOTTOMLEFT", 0, 0)
	botleft:SetTexCoord(0, 1, 0, (168 / 256))

	local botright = lhframe:CreateTexture(nil, "ARTWORK")
	botright:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-BotRIght")
	botright:SetWidth(140)
	botright:SetHeight(168)
	botright:SetPoint("BOTTOMRIGHT", 0, 0)
	botright:SetTexCoord(0, (140 / 256), 0, (168 / 256))

	local bot = lhframe:CreateTexture(nil, "ARTWORK")
	bot:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-Bot")
	bot:SetHeight(168)
	bot:SetPoint("TOPLEFT", botleft, "TOPRIGHT", 0, 0)
	bot:SetPoint("TOPRIGHT", botright, "TOPLEFT", 0, 0)
	bot:SetTexCoord(0, 1, 0, (168 / 256))

	local midleft = lhframe:CreateTexture(nil, "ARTWORK")
	midleft:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopLeft")
	midleft:SetWidth(128)
	midleft:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT", 0, 0)
	midleft:SetPoint("BOTTOMLEFT", botleft, "TOPLEFT", 0, 0)
	midleft:SetTexCoord(0, 1, (240 / 256), 1)

	local midright = lhframe:CreateTexture(nil, "ARTWORK")
	midright:SetTexture("Interface\\AddOns\\LightHeaded\\images\\MidRight")
	midright:SetWidth(140)
	midright:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT", 0, 0)
	midright:SetPoint("BOTTOMRIGHT", botright, "TOPRIGHT", 0, 0)
	midright:SetTexCoord(0, (140 / 256), 0, 1)

	local mid = lhframe:CreateTexture(nil, "ARTWORK")
	mid:SetTexture("Interface\\AddOns\\LightHeaded\\images\\Mid")
	mid:SetPoint("TOPLEFT", midleft, "TOPRIGHT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", midright, "BOTTOMLEFT", 0, 0)

	local bg1 = lhframe:CreateTexture(nil, "BACKGROUND")
	bg1:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopBackground")
	bg1:SetHeight(64)
	bg1:SetPoint("TOPLEFT", topleft, "TOPLEFT", 5, -4)
	bg1:SetWidth(256)

	local bg2 = lhframe:CreateTexture(nil, "BACKGROUND")
	bg2:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopBackground")
	bg2:SetHeight(64)
	bg2:SetPoint("TOPLEFT", bg1, "TOPRIGHT", 0, 0)
	bg2:SetWidth(256)

	local bg3 = lhframe:CreateTexture(nil, "BACKGROUND")
	bg3:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopBackground")
	bg3:SetHeight(64)
	bg3:SetPoint("TOPLEFT", bg2, "TOPRIGHT", 0, 0)
	bg3:SetWidth(256)

	local close = CreateFrame("Button", nil, lhframe, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 5, 4)
	self:SetFrameTooltip(close, "Click to close the QuestLog")

	local resize = CreateFrame("Button", nil, lhframe)
	resize:SetNormalTexture("Interface\\AddOns\\LightHeaded\\images\\Resize")
	resize:GetNormalTexture():SetTexCoord((12 / 32), 1, (12 / 32), 1)
	resize:SetHighlightTexture("Interface\\AddOns\\LightHeaded\\images\\Resize")
	resize:GetHighlightTexture():SetTexCoord((12 / 32), 1, (12 / 32), 1)
	resize:SetHeight(12)
	resize:SetWidth(12)
	resize:SetPoint("BOTTOMRIGHT", -3, 3)
	self:SetFrameTooltip(resize, "Click to resize LightHeaded")

	local titlereg = CreateFrame("Button", nil, lhframe)
	titlereg:SetPoint("TOPLEFT", 5, -5)
	titlereg:SetPoint("TOPRIGHT", 0, 0)
	titlereg:SetHeight(20)
	titlereg:SetScript("OnMouseDown", function(frame)
										  local parent = frame:GetParent()
										  if parent:IsMovable() then
											  parent:StartMoving()
										  end
									  end)
	titlereg:SetScript("OnMouseUp", function(frame)
										local parent = frame:GetParent()
										parent:StopMovingOrSizing()
										self:SavePosition("LightHeadedFrame")
									end)

	lhframe:EnableMouse()
	lhframe:SetMovable(1)
	lhframe:SetResizable(1)
	lhframe:SetMinResize(300, 300)
	lhframe:SetWidth(325)
	lhframe:SetHeight(450)

	lhframe.bg1 = bg1
	lhframe.bg2 = bg2
	lhframe.bg3 = bg3
	lhframe.top = top
	lhframe.bot = bot
	lhframe.topleft = topleft
	lhframe.topright = topright
	lhframe.botleft = botleft
	lhframe.botright = botright
	lhframe.close = close
	lhframe.resize = resize
	lhframe.mid = mid
	lhframe.midleft = midleft
	lhframe.midright = midright
	lhframe.titlereg = titlereg

	local lhframe = LightHeadedFrame

	local cos = math.cos
	local pi = math.pi

	-- internal functions
	local function cosineInterpolation(y1, y2, mu)
		return y1+(y2-y1)*(1 - cos(pi*mu))/2
	end

	local min,max,y
	local steps = 45
	local timeToFade = 1.5
	local mod = 1/timeToFade
	local modifier = 1/steps

	local count = 0
	local totalElapsed = 0
	local function onupdate(self, elapsed)
		count = count + 1
		totalElapsed = totalElapsed + elapsed

		if totalElapsed >= timeToFade then
			local temp = max
			max = min
			min = temp
			count = 0
			totalElapsed = 0
			self:SetScript("OnUpdate", nil)

			-- Do the frame fading
			if not LightHeaded.db.profile.open then
				if LightHeadedFrameSub.justclosed == true then
					LightHeadedFrameSub.justclosed = false
					LightHeadedFrameSub:Hide()
				else
					UIFrameFadeIn(LightHeadedFrameSub, 0.25, 0, 1)
					LightHeadedFrameSub:Show()
					LightHeaded.db.profile.open = true
					LightHeaded:SelectQuestLogEntry()
				end
			end
			return
		elseif count == 1 and LightHeaded.db.profile.open then
			UIFrameFadeOut(LightHeadedFrameSub, 0.25, 1, 0)
			LightHeaded.db.profile.open = false
			LightHeadedFrameSub.justclosed = true
		end

		local offset = cosineInterpolation(min, max, mod * totalElapsed)
		self:SetPoint("LEFT", self:GetParent(), "RIGHT", offset, y)
	end

	if not lhframe.handle then
		lhframe.handle = CreateFrame("Button", nil, lhframe)
	end

	lhframe.handle:SetWidth(8)
	lhframe.handle:SetHeight(128)
	lhframe.handle:SetPoint("LEFT", lhframe, "RIGHT", 0, 0)
	lhframe.handle:SetNormalTexture("Interface\\AddOns\\LightHeaded\\images\\tabhandle")

	lhframe.handle:RegisterForClicks("AnyUp")
	lhframe.handle:SetScript("OnClick", function(self, button)
        local offsets = frame_offsets[lhframe:GetParent()]
        if not offsets then
            lhframe:Hide()
        else
            max, y = unpack(offsets)
            min = max-313

            if LightHeaded.db.profile.open then
                min,max = max,min
            end

            lhframe:SetScript("OnUpdate", onupdate)
            if LightHeaded.db.profile.sound then
                PlaySoundFile("Sound\\Doodad\\Karazahn_WoodenDoors_Close_A.wav")
            end

            LightHeaded.db.profile.lhopen = not LightHeaded.db.profile.lhopen
        end
    end)

	lhframe.handle:SetScript("OnEnter", function(self)
											--SetCursor("Interface\\AddOns\\LightHeaded\\images\\cursor")
											SetCursor("INTERACT_CURSOR")
											GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
											GameTooltip:SetText("Click to open/close LightHeaded")
											GameTooltip:Show()
										end)

	lhframe.handle:SetScript("OnLeave",function(self)
										   SetCursor(nil)
										   GameTooltip:Hide()
									   end)

	lhframe.close:SetScript("OnClick", function()
		if QuestLogFrame:IsVisible() then
			HideUIPanel(QuestLogFrame)
		else
			lhframe.handle:Click()
		end
	end)

	local lhframe = CreateFrame("Frame", "LightHeadedFrameSub", LightHeadedFrame)
	lhframe:SetAllPoints(true)
	lhframe:SetAlpha(0)

	local timerFrame = CreateFrame("Frame")
	local editbox = CreateFrame("EditBox", "LightHeadedSearchBox", lhframe, "InputBoxTemplate")
	editbox:SetWidth(280)
	editbox:SetHeight(20)
	editbox:SetPoint("TOP", 5, -30)
	editbox:SetAutoFocus(false)
	editbox:SetText("Search for a quest...")
	editbox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	editbox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		LightHeaded:SearchQuests(text)
		timerFrame:Hide()
	end)

	local counter = 0
	local prev = ""
	editbox:SetScript("OnTextChanged", function(self)
		if self:HasFocus() then
			local text = self:GetText()
			if prev ~= text then
				counter = 0
				timerFrame:Show()
			else
				prev = text
			end
		end
	end)

	timerFrame:SetScript("OnUpdate", function(self, elapsed)
		counter = counter + elapsed
		if counter > 1.5 then
			LightHeaded:SearchQuests(editbox:GetText())
			timerFrame:Hide()
			counter = 0
		end
	end)
    timerFrame:Hide()

	-- Hook the SetItemRef so we can catch quest tooltips
	hooksecurefunc("SetItemRef", function(link, text, button)
		local qid = link:match("quest:(%d+)")
		if LightHeadedSearchBox and LightHeadedSearchBox:HasFocus() then
			LightHeadedSearchBox:SetText(qid)
			LightHeaded:SearchQuests(qid)
		end
	end)

    hooksecurefunc("QuestFrame_ShowQuestPortrait", function() LightHeaded:HijackQuestNPCModel() end)
    hooksecurefunc("QuestFrame_HideQuestPortrait", function() LightHeaded:HijackQuestNPCModel() end)

	lhframe.icon = CreateFrame("Button", nil, lhframe)
	lhframe.icon:SetHeight(64)
	lhframe.icon:SetHeight(64)
	lhframe.icon:SetWidth(64)
	lhframe.icon:SetNormalTexture("Interface\\AddOns\\LightHeaded\\images\\wh_icon")
	lhframe.icon:SetHighlightTexture("Interface\\AddOns\\LightHeaded\\images\\wh_icon_hover")
	lhframe.icon:GetHighlightTexture():SetBlendMode("BLEND")
	lhframe.icon:SetPoint("BOTTOMRIGHT", -10, -10)

	StaticPopupDialogs["LIGHTHEADED_ABOUT_DIALOG"] = {
		text = "LightHeaded (C) 2007-2008 by Jim Whitehead\n\nThis add-on only provides you with the comments and some basic information on quests. For the full information, be sure to visit http://www.wowhead.com",
		button1 = TEXT(OKAY),
		OnAccept = function()
				   end,
		timeout = 0,
		hideOnEscape = 1
	}

	lhframe.icon:SetScript("OnClick", function()
										  StaticPopup_Show("LIGHTHEADED_ABOUT_DIALOG")
									  end)

	lhframe.page = lhframe:CreateFontString(nil, "ARTWORK")
	lhframe.page:SetFontObject(GameFontNormalSmall)
	lhframe.page:SetPoint("BOTTOM", -32, 20)

	lhframe.prev = CreateFrame("Button", nil, lhframe)
	lhframe.prev:SetWidth(32)
	lhframe.prev:SetHeight(32)
	lhframe.prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	lhframe.prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	lhframe.prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	lhframe.prev:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	lhframe.prev:SetPoint("RIGHT", lhframe.page, "LEFT", -25, 0)

	self:SetFrameTooltip(lhframe.prev, "Previous page")
	lhframe.prev:SetScript("OnClick", function(frame)
										  if lhframe.current_page then
											  self:UpdateFrame(lhframe.qid, lhframe.current_page - 1)
										  end
									  end)

	lhframe.next = CreateFrame("Button", nil, lhframe)
	lhframe.next:SetWidth(32)
	lhframe.next:SetHeight(32)
	lhframe.next:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	lhframe.next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	lhframe.next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	lhframe.next:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	lhframe.next:SetPoint("LEFT", lhframe.page, "RIGHT", 25, 0)

	self:SetFrameTooltip(lhframe.next, "Next page")
	lhframe.next:SetScript("OnClick", function(frame)
										  if lhframe.current_page then
											  self:UpdateFrame(lhframe.qid, lhframe.current_page + 1)
										  end
									  end)

	lhframe.title = lhframe:CreateFontString(nil, "ARTWORK")
	lhframe.title:SetFontObject(GameFontHighlight)
	lhframe.title:SetPoint("TOP", 0, -4)
	lhframe.title:SetText("LightHeaded v." .. self.version)

	lhframe.scroll = CreateFrame("ScrollFrame", "LightHeadedScrollFrame", lhframe, "UIPanelScrollFrameTemplate")
	lhframe.scroll:SetPoint("TOPLEFT", 30, -75)
	lhframe.scroll:SetPoint("BOTTOMRIGHT", -35, 55)

	lhframe.scrollchild = CreateFrame("Frame", "LightHeadedScrollFrameChild", lhframe.scroll)
	lhframe.scrollchild:SetWidth(10)
	lhframe.scrollchild:SetHeight(10)

	lhframe.tooltip = CreateFrame("GameTooltip","LightHeadedTooltip",UIParent,"GameTooltipTemplate")
	lhframe.tooltip:SetScript("OnTooltipSetItem",function(frame)
		if frame.linkForced and GetItemInfo(frame.linkForced) then
			frame.linkForced = nil
			self:UpdateFrame(self:GetCurrentQID())
		end
	end)
	if IDCard and type(IDCard.RegisterTooltip) == "function" then
		IDCard:RegisterTooltip(lhframe.tooltip)
	end

	lhframe.text = CreateFrame("SimpleHTML", "LightHeadedHTML", lhframe.scrollchild)
	lhframe.text:SetPoint("TOPLEFT", 0, 0)
	lhframe.text:SetHeight(300)

    lhframe.font = CreateFont("LightHeadedFont")
    local gameFont = GameFontHighlight:GetFont()
    lhframe.font:SetFont(gameFont, self.db.profile.fontsize)
    lhframe.text:SetFontObject(lhframe.font)

	local function hlfix_OnUpdate(self, elapsed)
		self.text:SetText(self.updateText)
		if self.scrollOffset then
			LightHeaded:DebugF(1, "Setting Scroll: %s", tostring(self.scrollOffset))
			self.scroll:UpdateScrollChildRect()
			self.scroll:SetVerticalScroll(self.scrollOffset)
			self.scrollOffset = nil
		end
		self.updateText = nil
		self:SetScript("OnUpdate", nil)
	end

	function lhframe.text:MySetText(msg)
		self.text = msg
		lhframe.updateText = msg
		lhframe:SetScript("OnUpdate", hlfix_OnUpdate)
		--self:SetText(msg)
	end

	function lhframe:MySetScroll(offset)
		self.scrollOffset = offset
	end

	function lhframe.text:UpdateSize()
		local lhw = LightHeadedFrame:GetWidth()
		local width = lhw - 65
		self:SetWidth(width)
		self:MySetText(self.text)
		lhframe.scroll:UpdateScrollChildRect()
	end

	lhframe.text:SetScript("OnHyperlinkClick", function(...) self:OnHyperlinkClick(...) end)
	lhframe.text:SetScript("OnHyperlinkEnter", function(...) self:OnHyperlinkEnter(...) end)
	lhframe.text:SetScript("OnHyperlinkLeave", function() lhframe.tooltip:Hide() end)

	lhframe.scroll:SetScrollChild(lhframe.scrollchild)

	local text = "Please select a quest in your quest log, or type a name/id into the above search box"

	local function resizebg(frame)
		local width = frame:GetWidth() - 5
		-- bg1 will be okay due to minresize

		-- We'll resize bg2 up to 256
		local bg2w = width - 256
		local bg3w
		if bg2w > 256 then
			bg3w = bg2w - 256
			bg2w = 256
		end

		if bg2w > 0 then
			frame.bg2:SetWidth(bg2w)
			frame.bg2:SetTexCoord(0, (bg2w / 256), 0, 1)
			frame.bg2:Show()
		else
			frame.bg2:Hide()
		end


		if bg3w and bg3w > 0 then
			frame.bg3:SetWidth(bg3w)
			frame.bg3:SetTexCoord(0, (bg3w / 256), 0, 1)
			frame.bg3:Show()
		else
			frame.bg3:Hide()
		end
	end

	LightHeadedFrame.resizebg = resizebg

	resize:SetScript("OnMouseDown", function(frame)
										LightHeadedFrame:StartSizing()
										LightHeadedFrame:SetScript("OnUpdate", resizebg)
									end)
	resize:SetScript("OnMouseUp", function(frame)
									  LightHeadedFrame:StopMovingOrSizing()
									  LightHeadedFrame:SetScript("OnUpdate", nil)
									  self:SavePosition("LightHeadedFrame")
									  lhframe.text:UpdateSize()
									  lhframe.scroll:UpdateScrollChildRect()
									  LightHeadedFrame.resizebg(LightHeadedFrame)
								  end)

	lhframe.text:MySetText(text)
	lhframe:SetScript("OnShow", function(frame)
		LightHeaded.bad_select = 0;
		frame:SetScript("OnShow", nil);
		previous_qid = nil;
		self:SelectQuestLogEntry()
	end)

	resizebg(LightHeadedFrame)

	lhframe:SetAlpha(1)
	lhframe:Show()

	self:LockUnlockFrame()
end

function LightHeaded:LockUnlockFrame()
	local lhframe = LightHeadedFrameSub

	LightHeadedFrame:ClearAllPoints()

	if self.db.profile.attached then
		-- Lock the frame
		LightHeadedFrame.titlereg:Hide()
		LightHeadedFrame.resize:Hide()
		LightHeadedFrame.handle:Show()
		LightHeadedFrame:SetWidth(325)
		LightHeadedFrame:SetHeight(425)
		LightHeadedFrame.resizebg(LightHeadedFrame)
		LightHeadedFrame:SetFrameStrata("MEDIUM")
		LightHeadedFrame.close:Show()

		lhframe.text:UpdateSize()

		if self.db.profile.open then
			lhframe:Show()
			lhframe:SetAlpha(1)
			lhframe.open = true
		else
			lhframe:Hide()
			lhframe:SetAlpha(0)
		end

		LightHeaded:AdjustGUIParent()
        LightHeaded:HijackQuestNPCModel()
	else
		-- Unlock the frame
		LightHeadedFrame.titlereg:Show()
		LightHeadedFrame.resize:Show()
		LightHeadedFrame.handle:Hide()
		LightHeadedFrame:SetFrameStrata("HIGH")
		LightHeadedFrame.close:Hide()

		-- Make sure we can see the frame
		lhframe:Show()
		lhframe:SetAlpha(1)

		-- Update the size of the scroll child
		lhframe.text:UpdateSize()

		-- Restore the position
		self:RestorePosition("LightHeadedFrame")
        self:ReleaseNPCModel()
	end
end

function LightHeaded:SavePosition(name)
    local f = _G[name]
    local x,y = f:GetLeft(), f:GetTop()
    local s = f:GetEffectiveScale()

    x,y = x*s,y*s

	local opt = self.db.profile.positions[name]
	if not opt then
		self.db.profile.positions[name] = {}
		opt = self.db.profile.positions[name]
	end
    opt.PosX = x
    opt.PosY = y
	opt.Width = f:GetWidth()
	opt.Height = f:GetHeight()
end

function LightHeaded:RestorePosition(name)
	local f = _G[name]
	local opt = self.db.profile.positions[name]
	if not opt then
		self.db.profile.positions[name] = {}
		opt = self.db.profile.positions[name]
	end

	local x = opt.PosX
	local y = opt.PosY

    local s = f:GetEffectiveScale()

    if not x or not y then
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        return
    end

    x,y = x/s,y/s

    f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)

	-- restore height/width if stored
	if opt.Width then
		f:SetWidth(opt.Width)
	end

	if opt.Height then
		f:SetHeight(opt.Height)
	end

	-- Resize the background
	f.resizebg(f)
end

function LightHeaded:ToggleSound()
	if self.db.profile.sound then
		self:Print("Sound toggled off")
	else
		self:Print("Sound toggled on")
	end

	self.db.profile.sound = not self.db.profile.sound
end

function LightHeaded:AttachFrame()
	self:Print("Re-Attaching the LightHeaded Frame")

	self.db.profile.attached = true
	self:LockUnlockFrame()
end

function LightHeaded:DetachFrame()
	self:Print("Detaching the LightHeaded Frame")

	self.db.profile.attached = false
	self:LockUnlockFrame()
end

function LightHeaded:TogglePages()
	local lhframe = LightHeadedFrameSub

	if self.db.profile.singlepage then
		self:Print("Showing quest information in multiple pages")
	else
		self:Print("Showing quest information in a single page")
	end

	self.db.profile.singlepage = not self.db.profile.singlepage

	if self.db.profile.singlepage then
		self:UpdateFrame(lhframe.qid, nil, 0)
	else
		self:UpdateFrame(lhframe.qid, 1, 0)
	end
end

function LightHeaded:ChangeFontSize(value)
    local lhframe = LightHeadedFrameSub
    local gameFont = GameFontHighlight:GetFont()
    lhframe.font:SetFont(gameFont, value)
    lhframe.text:SetFontObject(lhframe.font)
end

function LightHeaded:ChangeBGAlpha(value)
	value = tonumber(value)

	self.db.profile.bgalpha = value

	local lhframe = LightHeadedFrame
	local textures = {
		"topleft",
		"top",
		"topright",
		"midleft",
		"mid",
		"midright",
		"botleft",
		"bot",
		"botright",
		"bg1",
		"bg2",
		"bg3",
		"resize",
		"titlereg",
		"handle",
		"close",
	}

	for k,v in pairs(textures) do
		lhframe[v]:SetAlpha(value)
	end
end

function LightHeaded:ToggleDebug()
	local level
	if self.db.profile.debug then
		self:Print("Debug messages have been disabled.")
	else
		self:Print("Debug messages have been enabled.")
		level = 1
	end

	self.db.profile.debug = not self.db.profile.debug
	self:EnableDebug(level)
end

function LightHeaded:SearchQuests(txt)
    local qidNamesLower = self:LoadNames(true) or ""

	local qid = tonumber(txt)
	local resultText = ""

	-- Search for the quest by QID
	if qid then
		local qname = self:GetQuestName(tonumber(txt))
		if qname then
			local link = "|cFF0066FF|Hlhref:quest:"..qid.."|h["..qname.."]|h|r"
			resultText = resultText .. link .. "\n"
		end
	end

	-- Convert the input to lowercase
	txt = txt:lower()

	-- Search for quests by name
	local numMatches = 0
	local pattern = string.format("(\031[^\030]+)\030([^\030]-%s[^\030]-)\030", txt)
	for qidlist, qname in qidNamesLower:gmatch(pattern) do
		if numMatches > 50 then
			resultText = resultText .. "\nToo many results, please refine your query..."
			break
		end

		local qname = nil
		for qid in qidlist:gmatch("\031(%d+)") do
			numMatches = numMatches + 1
			if not qname then
				qname = self:GetQuestName(tonumber(qid)) or "ERROR OCCURRED"
			end
			local link = "|cFF0066FF|Hlhref:quest:"..qid.."|h["..qname.."]|h|r"
			resultText = resultText .. link .. "\n"
		end
	end

	if resultText:match("%S") then
		resultText = "Found the following matches:\n\n" .. resultText
	else
		resultText = "No matching quests were found."
	end

	local lhframe = LightHeadedFrameSub

	-- Clear the page indicator and left/right buttons
	lhframe.next:Hide()
	lhframe.prev:Hide()
	lhframe.page:Hide()
	lhframe.searching = true
	lhframe.text:MySetText(resultText)
end

LightHeaded = DongleStub("Dongle-1.2"):New("LightHeaded", LightHeaded)
