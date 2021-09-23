CooldownCount = LibStub("AceAddon-3.0"):NewAddon("CooldownCount", "AceConsole-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("CooldownCount")
local SM = LibStub("LibSharedMedia-3.0")
local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local blacklist = { "TargetFrame", "PetAction", "TotemFrame", "PartyFrame", "TargetofTargetFrame", "FocusFrame", "RaidFrame", "CompactRaidGroup", "LAB10ChargeCooldown" }

local defaults = {
	profile = {
		shine = false,
		shineScale = 2,
		ShowDecimal = true,
		UseBlizCounter = false,
		WarnSpeed = 0.25,
		minimumDuration = 3,
		hideAnimation = false,
		font = SM:GetDefault("font"),
		color_common = {r=1, g=1, b=0.2, a=1},
		color_warn = {r=1, g=0, b=0, a=1},
		size1 = 18,
		size2 = 24,
		size3 = 28,
		size4 = 34,
		blacklist = {},
	}
}
local function get(info)
    local k = info[#info]
    return CooldownCount.db.profile[k]
end
local function set(info,value)
    local k = info[#info]
    CooldownCount.db.profile[k] = value
	if k == "font" then
		CooldownCount:initFontStyle()
	end
end

function CooldownCount:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CooldownCountDB", defaults, "Default")
	local options = {
		type = "group",
		name = "CooldownCount",
		args = {
			FontSettings = {
				type = "group",
				name = L["Font Settings"],
				get = get,
				set = set,
				args = {
					font = {
						type = "select",
						name = L["Font Style"],
						desc = L["Set cooldown value display font."],
						order =10,
						values = function()
							local fonts, newFonts = SM:List("font"), {}
							for k, v in pairs(fonts) do
								newFonts[v] = v
							end
							return newFonts
						end,
					},
					header_font_color = {
						type = "header",
						name = L["Font Color"],
						order = 20,
					},
					color_common = {
						type = "color",
						name = L["Common color"],
						desc = L["Setup the common color for value display."],
						order = 21,
						hasAlpha = true,
						get = function(info)
							local k=info[#info]
							return self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a
						end,
						set = function(info, r, g, b, a)
							local k=info[#info]
							self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a = r, g, b, a
						end,
					},
					color_warn = {
						type = "color",
						name = L["warning color"],
						desc = L["Setup the warning color for value display."],
						order = 22,
						hasAlpha = true,
						get = function(info)
							local k=info[#info]
							return self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a
						end,
						set = function(info, r, g, b, a)
							local k=info[#info]
							self.db.profile[k].r, self.db.profile[k].g, self.db.profile[k].b, self.db.profile[k].a = r, g, b, a
						end,
					},
					header_font_size = {
						type = "header",
						name = L["Font Size"],
						order = 30,
					},
					size1 = {
						type = "range",
						name = L["Small Size"],
						desc = L["Small font size for cooldown is longer than 10 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 31,
					},
					size2 = {
						type = "range",
						name = L["Medium Size"],
						desc = L["Medium font size for cooldown is longer than 1 minute and less than 10 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 32,
					},
					size3 = {
						type = "range",
						name = L["Large Size"],
						desc = L["Large font size for cooldown is longer than 10 seconds and less than 1 minutes."],
						min = 10,
						max = 45,
						step = 1,
						order = 33,
					},
					size4 = {
						type = "range",
						name = L["Warning Size"],
						desc = L["Warning font size for cooldown is less than 10 seconds."],
						min = 10,
						max = 45,
						step = 1,
						order = 34,
					},
				},
			},
			Misc = {
				type = "group",
				order = 3,
				name = L["Misc"],
				get = get,
				set = set,
				args = {
					shine = {
						type = "toggle",
						name = L["Shine at finish cooldown"],
						desc = L["Toggle icon shine display at finish cooldown."],
						order = 10,
					},
					shineScale = {
						type = "range",
						name = L["Shine Scale"],
						desc = L["Adjust icon shine scale."],
						min = 0,
						max = 50,
						step = 1,
						order = 11,
					},
					header_hideAnimation = {
						type = "header",
						name = L["Hide Blizzard Origin Animation"],
						order = 20,
					},
					hideAnimation = {
						type = "toggle",
						name = L["Hide Blizzard Origin Animation"],
						desc = L["Hide Blizzard origin cooldown animation."],
						width = "full",
						order = 21,
					},
					header_minimumDuration = {
						type = "header",
						name = L["Minimum Duration"],
						order = 50,
					},
					minimumDuration = {
						type = "range",
						name = L["Minimum Duration"],
						desc = L["Minimum duration for display cooldown count."],
						min = 0.5,
						max = 30,
						step = 0.5,
						order = 51,
					},
					header_WarnSpeed = {
						type = "header",
						name = L["Warning speed"],
						order = 60,
					},
					WarnSpeed = {
						type = "range",
						name = L["Warning blink speed"],
						desc = L["Speed at which the warning blinking occurs."],
						min = 0.1,
						max = 0.5,
						step = 0.05,
						order = 61,
					},
					header_decimal = {
						type = "header",
						name = L["Show decimal"],
						order = 70,
					},
					ShowDecimal = {
						type = "toggle",
						name = L["Show decimal below 1 sec"],
						desc = L["Show decimal below 1 sec."],
						width = "full",
						order = 71,
					},
					header_blizCounter = {
						type = "header",
						name = L["Blizzard time display"],
						order = 80,
					},
					UseBlizCounter = {
						type = "toggle",
						name = L["Use Blizzard time display"],
						desc = L["Blizzard display 0 between 0 and 0.999 remaining seconds. Disabling this option will show 1 instead."],
						width = "full",
						order = 81,
					},
					header_resetdb = {
						type = "header",
						name = L["Reset"],
						order = 100,
					},
					resetdb = {
						type = "execute",
						confirm = true,
						confirmText = L["ResetDB_Confirm"],
						func = function()
							self.db:ResetDB()
							self:initFontStyle()
							self:Print(L["All settings are reset to default value."])
						end,
						name = L["Reset"],
						order = 101,
					},
				},
			},
		}
	}

	config:RegisterOptionsTable("CooldownCount", {
		name = "CooldownCount",
		type = "group",
		args = {
			description = {
				type = "description",
				name = L["WhatIsCooldownCount"],
			},
		},
	})
	dialog:SetDefaultSize("CooldownCount", 600, 400)
	dialog:AddToBlizOptions("CooldownCount", "CooldownCount")

	config:RegisterOptionsTable("CooldownCount-Misc", options.args.Misc)
	dialog:AddToBlizOptions("CooldownCount-Misc", options.args.Misc.name, "CooldownCount")

	config:RegisterOptionsTable("CooldownCount-FontSettings", options.args.FontSettings)
	dialog:AddToBlizOptions("CooldownCount-FontSettings", options.args.FontSettings.name, "CooldownCount")
end

local actions = {}
local function action_OnShow(self)
  actions[self] = true
end

local function action_OnHide(self)
  actions[self] = nil
end

local function action_Add(button, action, cooldown)
  if not cooldown.cooldownCountAction then
    cooldown:HookScript('OnShow', action_OnShow);
    cooldown:HookScript('OnHide', action_OnHide);
  end
  cooldown.cooldownCountAction = action;
end

local function actions_Update()
  for cooldown in pairs(actions) do
    local start, duration = GetActionCooldown(cooldown.cooldownCountAction);
    --CooldownCount.SetCooldown(cooldown, start, duration, 1);
  end
end

function CooldownCount:OnEnable()
	self:initFontStyle()
	hooksecurefunc("CooldownFrame_Set",CooldownCount.SetCooldown);
    hooksecurefunc('SetActionUIButton', action_Add);

    for i, button in pairs(ActionBarButtonEventsFrame.frames) do
      action_Add(button, button.action, button.cooldown);
    end

end

function CooldownCount:initFontStyle()
	self.font = SM:Fetch('font', self.db.profile.font)
end

function CooldownCount.SetCooldown(frame, start, duration, enable, forceShowDrawEdge, modRate)
	local fname = frame:GetName();

	--black list handle
	if CooldownCount:CheckBlacklist(fname) then
		return
	end
	
	-- hide blz origin cooldown animation
	frame:SetAlpha(CooldownCount.db.profile.hideAnimation and 0 or 1)

	if enable and enable ~= 0 and start > 0 and duration > CooldownCount.db.profile.minimumDuration
	then
		local CC = frame.cooldownCounFrame or CooldownCount:CreateCooldownCount(frame, start, duration)
		CC.start = start
		CC.duration = duration
		CC.timeToNextUpdate = 0
		if not CC:IsShown() then
			CC:Show()
		end
	else
		local CC = frame.cooldownCounFrame
		if CC and CC:IsShown() then
			CC:Hide()
		end
	end
end

function CooldownCount:CreateCooldownCount(frame, start, duration)
	local fname = frame:GetName();
	frame.cooldownCounFrame = CreateFrame("Frame", nil, frame:GetParent())
	local textFrame = frame.cooldownCounFrame

	textFrame:SetAllPoints(frame:GetParent())
	textFrame:SetFrameLevel(textFrame:GetFrameLevel() + 5)
	textFrame:SetToplevel(true)
	textFrame.timeToNextUpdate = 0

	textFrame.text = textFrame:CreateFontString(nil, "OVERLAY")
	textFrame.text:SetPoint("CENTER", textFrame, "CENTER", 0, -1)

	textFrame.icon =
		--standard action button icon, $parentIcon
		_G[frame:GetParent():GetName() .. "Icon"] or
		--standard item button icon,  $parentIconTexture
		_G[frame:GetParent():GetName() .. "IconTexture"]

	if textFrame.icon then        
		textFrame:SetScript("OnUpdate", function(self, elapsed)
			if textFrame.timeToNextUpdate <= 0 or not textFrame.icon:IsVisible() then
				--[[
					If you have a long cooldown spell/item, after reboot your computer, cooldown value will be wrong.
					I still havn't any idea for it.
				]]
				local current_time = GetTime()
				if current_time < textFrame.start then return end

				local remain = textFrame.duration - (current_time - textFrame.start)

				if floor(remain + 1) > 0 and textFrame.icon:IsVisible() then
					local text, toNextUpdate, size, isWarn = CooldownCount:GetFormattedTime(remain)
					textFrame.text:SetFont(CooldownCount.font, size, "OUTLINE")
					color = CooldownCount.db.profile.color_common
					if isWarn then -- Switch to Warning blink mode
						-- Check if entering blink mode for this casted spell
						if textFrame.isWarn == nil then
							textFrame.isWarn = 2 -- Warn color
							textFrame.nextWarnSwitch = current_time + CooldownCount.db.profile.WarnSpeed
						end
						-- Check for color switch (blink)
						if current_time >= textFrame.nextWarnSwitch then
							if textFrame.isWarn == 2 then -- Was warn color, go to normal color
								textFrame.isWarn = 1
							else -- Was normal color, go to warn color
								textFrame.isWarn = 2
							end
							textFrame.nextWarnSwitch = current_time + CooldownCount.db.profile.WarnSpeed
						end
						-- Check if we must alter rendering color (warn color)
						if textFrame.isWarn == 2 then
							color = CooldownCount.db.profile.color_warn
						end
					end
					textFrame.text:SetTextColor(color.r, color.g, color.b)
					if type(text) == "number" then
						if text < 1 and CooldownCount.db.profile.ShowDecimal then
							textFrame.text:SetText( format("%.1f",text) )
						else
							textFrame.text:SetText( format("%.0f",text) )
						end
					else
						textFrame.text:SetText( text )
					end
					textFrame.timeToNextUpdate = toNextUpdate
				else
					if CooldownCount.db.profile.shine and textFrame.icon:IsVisible() then
						CooldownCount:StartToShine(textFrame.icon)
					end
					textFrame.isWarn = nil
					textFrame.nextWarnSwitch = 0
					textFrame:Hide()
				end
			else
				textFrame.timeToNextUpdate = textFrame.timeToNextUpdate - elapsed
			end
		end)
	end

	textFrame:Hide()

	return textFrame
end

function CooldownCount:Child_OnShow(self, event, ...)
	local textFrame = self:GetParent().textFrame
	if textFrame and not textFrame:IsShown() then
		textFrame:Show()
	end
end

function CooldownCount:Child_OnHide(self, event, ...)
	local textFrame = self:GetParent().textFrame
	if textFrame and textFrame:IsShown() then
		textFrame:Hide()
	end
end

function CooldownCount:GetFormattedTime(secs)
	local addSec = (CooldownCount.db.profile.UseBlizCounter and 0) or 1;
	-- return cc now value, next update value, font size, toggle two color
	if secs >= 86400 then
		return ceil(secs / 86400) .. L["d"], mod(secs, 86400), CooldownCount.db.profile.size1
	elseif secs >= 3600 then
		return ceil(secs / 3600) .. L["h"], mod(secs, 3600), CooldownCount.db.profile.size1
	elseif secs >= 600 then
		return ceil(secs / 60) .. L["m"], mod(secs, 60), CooldownCount.db.profile.size1
	elseif secs >= 60 then
		return ceil(secs / 60) .. L["m"], mod(secs, 60), CooldownCount.db.profile.size2
	elseif secs >= 10 then
		return floor(secs+addSec), 0.100, CooldownCount.db.profile.size3
	elseif secs >= 2 then
		return floor(secs+addSec), 0.050, CooldownCount.db.profile.size4, true
	elseif secs >= 1 then
		return floor(secs+addSec), 0.025, CooldownCount.db.profile.size4, true
	end
	if(CooldownCount.db.profile.ShowDecimal)
	then
		return secs, 0.010, CooldownCount.db.profile.size2, true
	end
	return floor(secs+addSec), 0.010, CooldownCount.db.profile.size4, true
end


--[[ Shine Codes ]]--
function CooldownCount:StartToShine(textFrame)
	local shineFrame = textFrame.shine or CooldownCount:CreateShineFrame(textFrame:GetParent())

	shineFrame.shine:SetAlpha(shineFrame:GetParent():GetAlpha())
	shineFrame.shine:SetHeight(shineFrame:GetHeight() * CooldownCount.db.profile.shineScale)
	shineFrame.shine:SetWidth(shineFrame:GetWidth() * CooldownCount.db.profile.shineScale)

	shineFrame:Show()
end

function CooldownCount:CreateShineFrame(parent)
	local shineFrame = CreateFrame("Frame", nil, parent)
	shineFrame:SetAllPoints(parent)

	local shine = shineFrame:CreateTexture(nil, "OVERLAY")
	shine:SetTexture("Interface\\Cooldown\\star4")
	shine:SetPoint("CENTER", shineFrame, "CENTER")
	shine:SetBlendMode("ADD")
	shineFrame.shine = shine

	shineFrame:Hide()
	shineFrame:SetScript("OnUpdate", CooldownCount.Shine_Update)
	shineFrame:SetAlpha(parent:GetAlpha())

	return shineFrame
end

function CooldownCount:Shine_Update()
	local shine = self.shine
	local alpha = shine:GetAlpha()
	shine:SetAlpha(alpha * 0.95)

	if alpha < 0.1 then
		self:Hide()
	else
		shine:SetHeight(alpha * self:GetHeight() * CooldownCount.db.profile.shineScale)
		shine:SetWidth(alpha * self:GetWidth() * CooldownCount.db.profile.shineScale)
	end
end

function CooldownCount:CheckBlacklist(frameName)
	if not frameName or _G[frameName].noCooldownCount then
		return true
	end
	-- Global blacklist
	for _, v in ipairs(blacklist) do
		if strfind(frameName, v) then
			_G[frameName].noCooldownCount=1
			return true
		end
	end
	-- User blacklist
	if(CooldownCount.db.profile.blacklist) then
		for _, v in ipairs(CooldownCount.db.profile.blacklist) do
			if strfind(frameName, v) then
				_G[frameName].noCooldownCount=1
				return true
			end
		end
	end
	return false
end

local function CooldownCount_ChatPrint(str,r,g,b)
  if(DEFAULT_CHAT_FRAME)
  then
    DEFAULT_CHAT_FRAME:AddMessage("CooldownCount: "..str, r or 1.0, g or 0.7, b or 0.15);
  end
end

local function CooldownCount_ShowHelp()
  CooldownCount_ChatPrint("Usage:");
  CooldownCount_ChatPrint("  |cffffffff/cc options|r - "..L["Opens options panel"]);
  CooldownCount_ChatPrint("  |cffffffff/cc bl add <FrameName>|r - "..L["Adds a frame to the user blacklist"]);
  CooldownCount_ChatPrint("  |cffffffff/cc bl del <FrameName>|r - "..L["Removes a frame from the user blacklist"]);
  CooldownCount_ChatPrint("  |cffffffff/cc bl list|r - "..L["List user blacklisted frames"]);
end

local function CooldownCount_Commands(command)
  local _,_,cmd,param = strfind(command,"^([^ ]+) (.+)$");
  if(not cmd) then cmd = command; end
  if(not cmd) then cmd = ""; end
  if(not param) then param = ""; end

  if((cmd == "") or (cmd == "help"))
  then
    CooldownCount_ShowHelp();
  elseif(cmd == "options")
  then
    InterfaceOptionsFrame_OpenToCategory("CooldownCount");
  elseif(cmd == "bl")
  then
    local _,_,cmd2,param2 = strfind(param,"^([^ ]+) (.+)$");
    if(not cmd2) then cmd2 = param; end
    if(not cmd2) then cmd2 = ""; end
    if(not param2) then param2 = ""; end
    if(cmd2 == "add")
    then
      if(param2 == "")
      then
        CooldownCount_ChatPrint(L["Missing parameter for 'blacklist add' command"]);
        CooldownCount_ShowHelp();
      else
        if(_G[param2] == nil)
        then
          CooldownCount_ChatPrint(string.format(L["Frame '%s' is not known. Cannot add it to user blacklist."],param2));
        else
          if(CooldownCount.db.profile.blacklist == nil)
          then
            CooldownCount.db.profile.blacklist = {};
          end
          tinsert(CooldownCount.db.profile.blacklist,param2);
          CooldownCount_ChatPrint(string.format(L["Frame '%s' added to user blacklist."],param2));
        end
      end
    elseif(cmd2 == "del")
    then
      if(param2 == "")
      then
        CooldownCount_ChatPrint(L["Missing parameter for 'blacklist del' command"]);
        CooldownCount_ShowHelp();
      else
        if(CooldownCount.db.profile.blacklist == nil)
        then
          CooldownCount.db.profile.blacklist = {};
        end
        for i,v in ipairs(CooldownCount.db.profile.blacklist)
        do
          if(param2 == v)
          then
            tremove(CooldownCount.db.profile.blacklist,i);
            CooldownCount_ChatPrint(string.format(L["Frame '%s' removed from user blacklist."],param2));
            return;
          end
        end
        CooldownCount_ChatPrint(string.format(L["Frame '%s' is not in user blacklist."],param2));
      end
    elseif(cmd2 == "list")
    then
      CooldownCount_ChatPrint(L["User blacklist:"]);
      if(CooldownCount.db.profile.blacklist)
      then
        for _, v in ipairs(CooldownCount.db.profile.blacklist)
        do
          CooldownCount_ChatPrint(" - "..v);
        end
      end
      CooldownCount_ChatPrint(L["End of list"]);
    else
      CooldownCount_ChatPrint(string.format(L["Unknown or missing parameter for 'blacklist' command: %s"],param));
      CooldownCount_ShowHelp();
    end
  else
    CooldownCount_ChatPrint(string.format(L["Unknown command: %s"],cmd));
    CooldownCount_ShowHelp();
  end
end

SLASH_COOLDOWNCOUNT1 = "/cooldowncount";
SlashCmdList["COOLDOWNCOUNT"] = function(msg)
  CooldownCount_Commands(msg);
end

SLASH_CC1 = "/cc";
SlashCmdList["CC"] = function(msg)
  CooldownCount_Commands(msg);
end

local f = CreateFrame('Frame'); f:Hide()
f:SetScript('OnEvent', function(self, event, ...)
	-- update action cooldowns
	if event == 'ACTIONBAR_UPDATE_COOLDOWN' then
		actions_Update()
	end
end)

f:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')

CooldownCount_ChatPrint(string.format(L["CooldownCount v%s loaded!\nType /cooldowncount (or /cc) for help"],GetAddOnMetadata("CooldownCount", "Version")));
