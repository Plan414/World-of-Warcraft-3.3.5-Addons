local MAJOR_VERSION = "3.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 30 $"):match("%d+"))

if FUBAR_REVISION and FUBAR_REVISION > MINOR_VERSION then
	MINOR_VERSION = FUBAR_REVISION
end
FUBAR_REVISION = nil

local Jostle = Rock("LibJostle-3.0", false, true)

local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar")

FuBar = Rock:NewAddon("FuBar", "LibRockDB-1.0", "LibRockEvent-1.0", "LibRockTimer-1.0", "LibRockHook-1.0", "LibRockConfig-1.0")
local FuBar = FuBar
FuBar.title = "FuBar"
FuBar.version = MAJOR_VERSION .. "." .. MINOR_VERSION
FuBar.date = string.gsub("$Date: 2009-12-10 10:01:58 +0000 (Thu, 10 Dec 2009) $", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1")

FuBar:SetDatabase("FuBar2DB")

local _G = getfenv(0)
local plugins = {}

local FuBar_Panel = FuBar_Panel
_G.FuBar_Panel = nil

if not FUBAR_DEFAULTS then
	FUBAR_DEFAULTS = function()
		return {
			fontSize = 12,
			adjust = true,
			panels = {
				[1] = {
					attachPoint = "TOP",
					plugins = {
						left = {
							"LocationFu",
							"ExperienceFu",
							"PerformanceFu",
						},
						center = {},
						right = {
							"ClockFu",
							"VolumeFu",
						}
					}
				}, 
				[2] = {
					attachPoint = "BOTTOM"
				}
			}
		}
	end
end

local localizedCategory = setmetatable({["All categories"] = L["All categories"]}, { __index = function(self, category)
	if type(category) ~= "string" then
		return L["Others"]
	end
	local ret = Rock:GetLocalizedCategory(category)
	if ret == UNKNOWN or ret == "Unknown" then
		ret = L["Others"]
	end
	self[category] = ret
	return ret
end } )

local basePluginFrame

local alreadyEnabled = false

local backgrounds = {
	["Interface\\AddOns\\FuBar\\background"] = L["Default"],
	[true] = NONE or "None"
}

local function safecall(func, ...)
	local success, ret = pcall(func, ...)
	if not success then
		geterrorhandler()(ret)
	end
end

function FuBar:RegisterSkin(name, bgFile)
	if type(name) ~= "string" then
		error("You must provide a name for your skin")
	elseif type(bgFile) ~= "string" then
		error("You must provide a file for your skin")
	end
	if not backgrounds[bgFile] then
		backgrounds[bgFile] = name
	end
end

local function SetBackground(bgFile)
	if backgrounds[bgFile] then
		FuBar.db.profile.skin = bgFile
		if bgFile == true then
			FuBar_Panel:SetBackgroundColor(FuBar.db.profile.skinR, FuBar.db.profile.skinG, FuBar.db.profile.skinB)
		else
			FuBar_Panel:SetBackground(bgFile)
		end
	end
end

local function GetBackground()
	return backgrounds[FuBar.db.profile.skin] and FuBar.db.profile.skin or "Interface\\AddOns\\FuBar\\background"
end

local function GetBackgroundColor()
	return FuBar.db.profile.skinR, FuBar.db.profile.skinG, FuBar.db.profile.skinB
end
local function SetBackgroundColor(r,g,b)
	FuBar.db.profile.skinR, FuBar.db.profile.skinG, FuBar.db.profile.skinB = r,g,b
	if FuBar.db.profile.skin == true then
		FuBar_Panel:SetBackgroundColor(r, g, b)
	end
end

local newList, del, unpackDictAndDel = Rock:GetRecyclingFunctions("FuBar", "newList", "del", "unpackDictAndDel")

local toBeLoaded

local optionsTable_args = {
	overflow = {
		type = 'boolean',
		name = L["Overflow plugins"],
		desc = L["Let plugins overflow onto another panel"],
		get = "IsOverflowing",
		set = "ToggleOverflowing",
	},
	create = {
		type = 'execute',
		name = L["Create new panel"],
		desc = L["Create new panel"],
		buttonText = L["Create"],
		func = "new",
		handler = FuBar_Panel
	},
	adjust = {
		type = 'boolean',
		name = L["Auto-adjust frames"],
		desc = L["Toggle auto-adjustment of blizzard's frames"],
		get = "IsAdjust",
		set = "ToggleAdjust",
	},
	autohideTop = {
		type = 'boolean',
		name = L["Auto-hide top panels"],
		desc = L["Toggle auto-hiding of the top panels"],
		get = "IsAutoHidingTop",
		set = "ToggleAutoHidingTop",
	},
	autohideBottom = {
		type = 'boolean',
		name = L["Auto-hide bottom panels"],
		desc = L["Toggle auto-hiding of the bottom panels"],
		get = "IsAutoHidingBottom",
		set = "ToggleAutoHidingBottom",
	},
	background = {
		type = 'group',
		name = L["Background"],
		desc = L["Background of the panels"],
		args = {
			texture = {
				type = 'choice',
				name = L["Texture"],
				desc = L["Change the texture of the panels"],
				get = GetBackground,
				set = SetBackground,
				choices = backgrounds,
			},
			color = {
				type = 'color',
				name = type(COLOR) == "string" and COLOR or "Color",
				desc = L["Change the color of the panels, if texture is set to None"],
				get = GetBackgroundColor,
				set = SetBackgroundColor,
			}
		}
	},
	spacing = {
		type = 'group',
		name = L["Spacing"],
		desc = L["Spacing between plugins"],
		args = {
			left = {
				type = 'number',
				name = L["Left-aligned spacing"],
				desc = L["Set spacing between left-aligned plugins"],
				max = 40,
				min = 0,
				step = 1,
				get = "GetLeftSpacing",
				set = "SetLeftSpacing",
			},
			center = {
				type = 'number',
				name = L["Center-aligned spacing"],
				desc = L["Set spacing between center-aligned plugins"],
				max = 40,
				min = 0,
				step = 1,
				get = "GetCenterSpacing",
				set = "SetCenterSpacing",
			},
			right = {
				type = 'number',
				name = L["Right-aligned spacing"],
				desc = L["Set spacing between right-aligned plugins"],
				max = 40,
				min = 0,
				step = 1,
				get = "GetRightSpacing",
				set = "SetRightSpacing",
			},
		}
	},
	fontsize = {
		type = 'number',
		name = L["Font size"],
		desc = L["Set font size for the plugins on the panel"],
		max = 24,
		min = 7,
		step = 1,
		get = "GetFontSize",
		set = "SetFontSize",
	},
	transparency = {
		type = 'number',
		name = L["Transparency"],
		desc = L["Set transparency of the panels"],
		max = 1,
		min = 0,
		step = 0.01,
		bigStep = 0.05,
		isPercent = true,
		get = "GetTransparency",
		set = "SetTransparency",
	},
	thickness = {
		type = 'number',
		name = L["Thickness"],
		desc = L["Set thickness between the panels"],
		max = 20,
		min = 0,
		step = 1,
		get = "GetThickness",
		set = "SetThickness",
	},
	tooltip = {
		type = 'group',
		name = L["Tooltip"],
		desc = L["Tooltip settings"],
		args = {
			transparency = {
				type = 'number',
				name = L["Transparency"],
				desc = L["Set transparency of the tooltip"],
				max = 1,
				min = 0,
				step = 0.01,
				bigStep = 0.05,
				isPercent = true,
				get = function()
					return Rock("Tablet-2.0"):GetTransparency(FuBar.db.profile.tooltip)
				end,
				set = function(value)
					return Rock("Tablet-2.0"):SetTransparency(FuBar.db.profile.tooltip, value)
				end,
			},
			fontSize = {
				type = 'number',
				name = L["Font size"],
				desc = L["Set font size for the tooltip"],
				max = 2,
				min = 0.5,
				step = 0.01,
				bigStep = 0.05,
				isPercent = true,
				get = function()
					return Rock("Tablet-2.0"):GetFontSizePercent(FuBar.db.profile.tooltip)
				end,
				set = function(value)
					return Rock("Tablet-2.0"):SetFontSizePercent(FuBar.db.profile.tooltip, value)
				end,
			},
			hideInCombat = {
				type = 'boolean',
				name = L["Hide in combat"],
				desc = L["Prevent tooltips from showing in combat"],
				get = "IsHidingTooltipsInCombat",
				set = "ToggleHidingTooltipsInCombat",
			}
		},
		hidden = function()
			return not Rock:HasLibrary("Tablet-2.0", true)
		end
	}
}

local barOpts
do
	local attachChoices = {
		TOP = L["Attach to top"],
		BOTTOM = L["Attach to bottom"],
		NONE = L["Detach panel"],
	}
	
	local args_attach = {
		type = 'choice',
		name = L["Attach"],
		desc = "Attachment point.",
		choices = attachChoices,
		get = function(key)
			return FuBar:GetPanel(key):GetAttachPoint()
		end,
		set = function(key, ...)
			return FuBar:GetPanel(key):SetAttachPoint(...)
		end,
	}
	local args_lock = {
		type = 'boolean',
		name = L["Lock panel"],
		desc = L["Lock panel"],
		get = function(key)
			return FuBar:GetPanel(key):IsLocked()
		end,
		set = function(key, ...)
			return FuBar:GetPanel(key):ToggleLocked(...)
		end,
	}
	local args_remove = {
		type = 'execute',
		name = L["Remove panel"],
		desc = L["Remove panel"],
		buttonText = L["Remove"],
		confirmText = L["Are you sure?"],
		func = function(key)
			return FuBar:GetPanel(key):del()
		end,
		disabled = function(key)
			return FuBar:GetNumPanels() <= 1
		end,
	}
	
	local category_choiceDescs = function(panelID, cat)
		local choiceDescs = newList()
		
		for _,plugin in ipairs(plugins) do
			local category = localizedCategory[plugin:GetCategory()]
			if category == cat or cat == L["All categories"] then
				choiceDescs[plugin] = plugin.notes
			end
		end
		for _,plugin in ipairs(toBeLoaded) do
			local lod = FuBar.db.profile.loadOnDemand[plugin[1]]

			local category = localizedCategory[lod.category]
			if category == cat or cat == L["All categories"] then
				choiceDescs[plugin] = plugin[2]
			end
		end
		return "@dict", unpackDictAndDel(choiceDescs)
	end
	
	local category_choices = function(panelID, cat)
		local choices = newList()
		
		for _,plugin in ipairs(plugins) do
			local category = localizedCategory[plugin:GetCategory()]
			if category == cat or cat == L["All categories"] then
				choices[plugin] = plugin:GetTitle()
			end
		end
		for _, plugin in ipairs(toBeLoaded) do
			local lod = FuBar.db.profile.loadOnDemand[plugin[1]]

			local category = localizedCategory[lod.category]
			if category == cat or cat == L["All categories"] then
				choices[plugin[1]] = lod.title
			end
		end
		return "@dict", unpackDictAndDel(choices)
	end
	
	local function category_get(panelID, category, key)
		if type(key) == "string" then
			-- to be loaded
			return false
		else
			if key:GetPanel() == FuBar:GetPanel(panelID) then
				return true
			elseif key:GetPanel() then
				return "HALF"
			else
				return false
			end
		end
	end
	local function category_set(panelID, category, key, value)
		if type(key) == "string" then
			-- to be loaded
			FuBar_Panel.selectedPanel = FuBar:GetPanel(panelID)
			FuBar:LoadPlugin(key)
		else
			if value then
				if key:GetPanel() then
					key:Hide()
				end
				key:Show(panelID or 1)
			else
				key:Hide(panelID or 1)
			end
		end
	end
	
	local categoryOpts = setmetatable({}, {__index=function(self, category)
		self[category] = {
			type = 'multichoice',
			name = category,
			desc = category == L["All categories"] and L["Available plugins in the all categories."] or L["Available plugins in the %q category."]:format(category),
			choices = category_choices,
			choiceDescs = category_choiceDescs,
			get = category_get,
			set = category_set,
			passValue2 = category,
			order = category == L["All categories"] and 50 or 100,
		}
		return self[category]
	end})
	
	local args_plugins = {
		type = 'group',
		groupType = 'inline',
		name = L["Plugins"],
		desc = L["Plugins that can be shown on the bar."],
		args = function(key)
			local args = newList()

			local menuTitles = newList()
			for _,plugin in ipairs(plugins) do
				local alreadyExists = false
				local category = localizedCategory[plugin:GetCategory()]
				menuTitles[category] = true
			end
			for _,name in ipairs(toBeLoaded) do
				local category = localizedCategory[FuBar.db.profile.loadOnDemand[name[1]].category]
				menuTitles[category] = true
			end
			for name in pairs(menuTitles) do
				args[name] = categoryOpts[name]
			end
			if next(menuTitles, next(menuTitles, nil)) ~= nil then
				-- don't do it if we only have one category
				args[L["All categories"]] = categoryOpts[L["All categories"]]
			end
			menuTitles = del(menuTitles)

			return "@dict", unpackDictAndDel(args)
		end,
		order = 200,
	}
	
	barOpts = setmetatable({}, {__index=function(self, key)
		self[key] = {
			name = (L["Bar #%d"]):format(key),
			desc = (L["Bar #%d"]):format(key),
			type = 'group',
			child_child_passValue = key,
			child_passValue = key,
			passValue = key,
			args = {
				attach = args_attach,
				lock = args_lock,
				remove = args_remove,
				plugins = args_plugins,
			},
		}
		return self[key]
	end})
end
local optionsTable = {
	name = "FuBar",
	desc = L["A panel that modules can plug into."],
	handler = FuBar,
	type = 'group',
	icon = [[Interface\Icons\INV_Gizmo_SuperSapperCharge]],
	args = function()
		local t = newList()
		for k,v in pairs(optionsTable_args) do
			t[k] = v
		end
		for i = 1, FuBar:GetNumPanels() do
			t["bar" .. i] = barOpts[i]
		end
		return "@dict", unpackDictAndDel(t)
	end
}

--FuBar:RegisterChatCommand(L["ChatCommands"], optionsTable, "FUBAR")

function FuBar:GetScaledCursorPosition()
	local x, y = GetCursorPosition()
	local scale = GetScreenHeight() / 768
	return x * scale, y * scale
end

function FuBar:Reset()
	self:RemoveEventListener("PLAYER_LOGOUT")
	FuBar2DB = {}
	ReloadUI()
end

function FuBar:GetPanel(panelId)
	return FuBar_Panel.instances[panelId]
end

function FuBar:GetNumPanels()
	return #FuBar_Panel.instances
end

function FuBar:GetBottommostTopPanel()
	local bottom = GetScreenHeight()
	local best
	for i = 1, self:GetNumPanels() do
		local panel = self:GetPanel(i)
		if panel:GetAttachPoint() == "TOP" and panel.frame:GetBottom() < bottom then
			bottom = panel.frame:GetBottom()
			best = panel
		end
	end
	return best
end

function FuBar:GetTopmostBottomPanel()
	local top = 0
	local best
	for i = 1, self:GetNumPanels() do
		local panel = self:GetPanel(i)
		if panel:GetAttachPoint() == "BOTTOM" and panel.frame:GetTop() > top then
			top = panel.frame:GetTop()
			best = panel
		end
	end
	return best
end

local isChangingProfile, previousProfile

function FuBar:IsChangingProfile()
	return isChangingProfile
end

function FuBar:IsAdjust()
	return self.db.profile.adjust
end

function FuBar:ToggleAdjust()
	self.db.profile.adjust = not self.db.profile.adjust
	self:UpdateJostleAdjustments()
	return self.db.profile.adjust
end

function FuBar:IsOverflowing()
	do return false end
	return not self.db.profile.overflow
end

function FuBar:ToggleOverflowing()
	self.db.profile.overflow = not self.db.profile.overflow
	for i = 1, self:GetNumPanels() do
		self:GetPanel(i):CheckForOverlap()
	end
	return not self.db.profile.overflow
end

function FuBar:UpdateJostleAdjustments()
	if not Jostle then
		return
	end
	if not self.db.profile.adjust then
		Jostle:DisableTopAdjusting()
		Jostle:DisableBottomAdjusting()
	else
		if self:IsAutoHidingTop() then
			Jostle:DisableTopAdjusting()
		else
			Jostle:EnableTopAdjusting()
		end
		if self:IsAutoHidingBottom() then
			Jostle:DisableBottomAdjusting()
		else
			Jostle:EnableBottomAdjusting()
		end
	end
end

function FuBar:IsAutoHidingTop()
	return self.db.profile.autohideTop
end

local autohideTopTime, autohideBottomTime

function FuBar:ToggleAutoHidingTop()
	self.db.profile.autohideTop = not self.db.profile.autohideTop
	self:UpdateJostleAdjustments()
	if not self.db.profile.autohideTop then
		for i = 1, self:GetNumPanels() do
			if self:GetPanel(i):GetAttachPoint() == "TOP" then
				local frame = _G["FuBarFrame" .. i]
				frame:SetAlpha(1)
				frame:SetFrameStrata("HIGH")
			end
		end
	else
		self:AddTimer("FuBar_AutoHideTop", 1, "OnUpdate_AutoHideTop")
	end
	autohideTopTime = GetTime()
	return self.db.profile.autohideTop
end

function FuBar:IsAutoHidingBottom()
	return self.db.profile.autohideBottom
end

function FuBar:ToggleAutoHidingBottom()
	self.db.profile.autohideBottom = not self.db.profile.autohideBottom
	self:UpdateJostleAdjustments()
	if not self.db.profile.autohideBottom then
		for i = 1, self:GetNumPanels() do
			if self:GetPanel(i):GetAttachPoint() == "BOTTOM" then
				local frame = _G["FuBarFrame" .. i]
				frame:SetAlpha(1)
				frame:SetFrameStrata("HIGH")
			end
		end
	else
		self:AddTimer("FuBar_AutoHideBottom", 1, "OnUpdate_AutoHideBottom")
	end
	autohideBottomTime = GetTime()
	return self.db.profile.autohideBottom
end

function FuBar:GetFontSize()
	if not self.db.profile then
		return 12
	end
	return self.db.profile.fontSize or 12
end

function FuBar:SetFontSize(size)
	size = size or 12
	self.db.profile.fontSize = size
	for i,plugin in ipairs(plugins) do
		if type(plugin.SetFontSize) ~= "function" then
			table.remove(plugins, i)
			i = i - 1
		else
			plugin:SetFontSize(size)
		end
	end
	for i = 1, self:GetNumPanels() do
		self:GetPanel(i):UpdateTexture()
	end
	self:Update()
	if Jostle then
		Jostle:Refresh()
	end
end

function FuBar:GetLeftSpacing()
	if not self.db.profile then
		return 20
	end
	return self.db.profile.leftSpacing or 20
end

function FuBar:SetLeftSpacing(size)
	self.db.profile.leftSpacing = size
	self:Update()
end

function FuBar:GetCenterSpacing()
	if not self.db.profile then
		return 20
	end
	return self.db.profile.centerSpacing or 20
end

function FuBar:SetCenterSpacing(size)
	self.db.profile.centerSpacing = size
	self:Update()
end

function FuBar:GetRightSpacing()
	if not self.db.profile then
		return 20
	end
	return self.db.profile.rightSpacing or 20
end

function FuBar:SetRightSpacing(size)
	self.db.profile.rightSpacing = size
	self:Update()
end

function FuBar:SetThickness(size)
	self.db.profile.thickness = size
	for i = 1, self:GetNumPanels() do
		self:GetPanel(i):UpdateTexture()
	end
	self:Update()
	if Jostle then
		Jostle:Refresh()
	end
end

function FuBar:GetThickness(size)
	if not self.db.profile then
		return 5
	end
	return self.db.profile.thickness or 5
end

function FuBar:GetTransparency()
	return self.db.profile.transparency or 0.8
end

function FuBar:SetTransparency(value)
	self.db.profile.transparency = value
	for i = 1, self:GetNumPanels() do
		self:GetPanel(i):UpdateTexture()
	end
end

local function CheckLoadCondition(loadCondition)
	return RunScript("(function()"..loadCondition.." end)()")
end

local function _IsCorrectPlugin(plugin)
	if type(plugin) ~= "table" then
		return false
	elseif type(plugin.GetName) ~= "function" then
		return false
	elseif type(plugin.GetTitle) ~= "function" then
		return false
	elseif type(plugin.GetCategory) ~= "function" then
		return false
	elseif type(plugin.SetFontSize) ~= "function" then
		return false
	elseif type(plugin.GetFrame) ~= "function" then
		return false
	elseif type(plugin.Show) ~= "function" then
		return false
	elseif type(plugin.Hide) ~= "function" then
		return false
	elseif type(plugin.GetPanel) ~= "function" then
		return false
	elseif type(plugin:GetName()) ~= "string" then
		return false
	elseif type(plugin:GetTitle()) ~= "string" then
		return false
	elseif type(plugin:GetCategory()) ~= "string" then
		return false
	end
	local frame = plugin:GetFrame()
	if type(frame) ~= "table" then
		return false
	elseif type(frame[0]) ~= "userdata" then
		return false
	elseif type(frame.GetObjectType) ~= "function" then
		return false
	elseif type(frame:GetObjectType()) ~= "string" then
		return false
	end
	return true
end

local function IsCorrectPlugin(plugin)
	local ret, msg = pcall(_IsCorrectPlugin, plugin)
	if ret then
		return msg
	end
end

local function _IsCorrectPanel(panel)
	if type(panel) ~= "table" then
		return false
	elseif type(panel.AddPlugin) ~= "function" then
		return false
	elseif type(panel.RemovePlugin) ~= "function" then
		return false
	elseif type(panel.GetNumPlugins) ~= "function" then
		return false
	elseif type(panel:GetNumPlugins()) ~= "number" then
		return false
	elseif type(panel.GetPlugin) ~= "function" then
		return false
	elseif type(panel.HasPlugin) ~= "function" then
		return false
	elseif type(panel.GetPluginSide) ~= "function" then
		return false
	end
	return true
end

local function IsCorrectPanel(panel)
	local ret, msg = pcall(_IsCorrectPanel, panel)
	if ret then
		return msg
	end
end

local n
local mt = {
	__newindex = function(self, k, v)
		rawset(self, k, v)
		n[k] = v
	end,
}

local function LoadAddOnWrapper(addon)
	local o = getfenv(0)
	n = {}
	local oldmt = getmetatable(o)
	setmetatable(o, mt)
	local success, ret = pcall(LoadAddOn, addon)
	setmetatable(o, oldmt)
	if not success then
		geterrorhandler()(ret)
		return
	elseif not ret then
		DEFAULT_CHAT_FRAME:AddMessage("Error loading LoadOnDemand plugin " .. addon)
		return
	end

	local dependencies
	local plugin
	for k,v in pairs(n) do
		if IsCorrectPlugin(v) then
			if plugin then
				if not dependencies then
					dependencies = {}
				end
				table.insert(dependencies, plugin)
			end
			plugin = v
		end
	end
	if not plugin then
		DEFAULT_CHAT_FRAME:AddMessage("Error loading LoadOnDemand plugin " .. addon)
		return
	end
	return ret, plugin, dependencies
end

local t = {}
local function CleanDB()
	local self = FuBar
	if not self.db.profile.panels then
		self.db.profile.panels = { { plugins = {}, attachPoint = "TOP" } }
	end
	for _,panel in ipairs(self.db.profile.panels) do
		if panel and panel.plugins then
			for _,part in pairs(panel.plugins) do
				if part then
					for i,plugin in ipairs(part) do
						if t[plugin] then
							i = i - 1
							table.remove(part, i)
						else
							t[plugin] = true
						end
					end
				end
			end
		end
	end
	for k in pairs(t) do
		t[k] = nil
	end
end

local function copyTable(t)
	if type(t) == "table" then
		local ret = {}
		for k, v in pairs(t) do
			ret[copyTable(k)] = copyTable(v)
		end
		return ret
	else
		return t
	end
end

function FuBar:OnInitialize()
	if not self.db.account.firstTimeWoW21 then
		self.db.account.firstTimeWoW21 = true
		SetCVar("scriptErrors", "1")
	end
	toBeLoaded = {}
	self:SetConfigTable(optionsTable)
	self:SetConfigSlashCommand("/FuBar", "/Fu")
	optionsTable.extraArgs.active = nil

	if not next(FuBar.db.profile) then
		local def
		local profile = self:GetProfile()
		if profile:find("^char/") or profile:find("^class/") then
			local class = select(2, UnitClass("player"))
			def = _G["FUBAR_DEFAULTS_" .. class] or FUBAR_DEFAULTS
		else
			def = FUBAR_DEFAULTS
		end
		if type(def) == "function" then
			def = def()
		end
		def = copyTable(def)
		for k,v in pairs(def) do
			FuBar.db.profile[k] = v
		end
	end

	if type(self.db.profile.loadOnDemand) ~= "table" then
		self.db.profile.loadOnDemand = {}
	end

	if type(self.db.profile.tooltip) ~= "table" then
		self.db.profile.tooltip = {}
	end
	self.db.profile.tooltip.r = nil -- in case some evil person made it non-black
	self.db.profile.tooltip.g = nil
	self.db.profile.tooltip.b = nil
	if type(self.db.profile.skinR) ~= "number" then
		self.db.profile.skinR = 0
	end
	if type(self.db.profile.skinG) ~= "number" then
		self.db.profile.skinG = 0
	end
	if type(self.db.profile.skinB) ~= "number" then
		self.db.profile.skinB = 0
	end

	self:SetFontSize(self:GetFontSize())

	local menuTitles = {}
	local titles = {}

	self:AddTimer(0, "LoadLoadOnDemandPlugins")

	CleanDB()

	self:AddEventListener("ADDON_LOADED", "OnLibraryLoad")
end

function FuBar:LoadPlugin(name)
	local loaded, plugin, dependencies = LoadAddOnWrapper(name)
	if loaded then
		if type(plugin.SetLoadOnDemand) == "function" then
			plugin:SetLoadOnDemand(true)
		end
		self.db.profile.loadOnDemand[name] = {
			title = plugin:GetTitle(),
			category = plugin:GetCategory(),
			disabled = nil,
			condition = type(plugin.GetLoadCondition) == "function" and plugin:GetLoadCondition() or nil,
		}
		plugin:Show(FuBar_Panel.selectedPanel or false)
		if dependencies then
			for _,v in ipairs(dependencies) do
				if type(v.SetLoadOnDemand) == "function" then
					v:SetLoadOnDemand(true)
				end
				self.db.profile.loadOnDemand[name].disabled = nil
				for j,u in ipairs(toBeLoaded) do
					if u[1] == v:GetTitle() then
						table.remove(toBeLoaded, j)
						break
					end
				end
				if v.hideWithoutStandby then
					v:EnableApp()
				else
					v:Show(panelId or false)
				end
			end
		end
		self:SetFontSize(self:GetFontSize())
		for i,n in ipairs(toBeLoaded) do
			if n[1] == name then
				table.remove(toBeLoaded, i)
				break
			end
		end
		self.db.profile.loadOnDemand[name].disabled = nil
	end
end

function FuBar:OnEnable()
	if alreadyEnabled then
		ReloadUI()
		return
	end
	alreadyEnabled = true

	if type(self.db.profile.panels) ~= "table" then
		self.db.profile.panels = {}
	end

	if type(self.db.profile.minimap) ~= "table" then
		self.db.profile.minimap = {}
	end

	for i = #self.db.profile.panels, 1, -1 do
		if self.db.profile.panels[i] then
			FuBar_Panel:new()
		end
	end

	self:CheckResolution()

	if self:GetNumPanels() == 0 then
		FuBar_Panel:new()
	end
	
	if FuBar.db.profile.skin ~= nil then
		SetBackground(FuBar.db.profile.skin)
	end
	
	self:AddEventListener("CVAR_UPDATE", "OnCVarUpdate")
	
	DisableAddOn("FuBar-compat-1.2")
	
	self:AddSecureHook("RestartGx")
	
	local function func()
		if FuBar.db.profile.skin ~= nil then
			SetBackground(FuBar.db.profile.skin)
		end
		
		if not self:SetupPlugins() then
			self:AddTimer(0, func)
			return
		end
		self:Update()

		self:AddTimer("FuBar_AutoHideTop", 1, "OnUpdate_AutoHideTop")
		self:AddTimer("FuBar_AutoHideBottom", 1, "OnUpdate_AutoHideBottom")
	end
	self:AddTimer(1, func)
	
	self:UpdateJostleAdjustments()
	
	if self.db.profile.skin and backgrounds[self.db.profile.skin] then
		FuBar_Panel:SetBackground(self.db.profile.skin)
	end
end

function FuBar:OnLibraryLoad()
	if not Jostle and Rock("LibJostle-3.0", false, true) then
		Jostle = Rock("LibJostle-3.0", false, true)
		FuBar_Panel:OnJostleLoad(Jostle)
	end
end

local function findFuBarDep(...)
	for i = 1, select("#", ...) do
		local dep = select(i, ...)
		if dep == "FuBar" then
			return true
		end
	end
end

local function isFuBarDependent(name)
	local data = GetAddOnMetadata(name, "X-FuBar-Dependent")
	data = tonumber(data) or data
	if data and data ~= 0 then
		return true
	end
	return findFuBarDep(GetAddOnDependencies(name))
end

function FuBar:LoadLoadOnDemandPlugins()
	for i = 1, GetNumAddOns() do
		local name, _, notes, enabled, loadable = GetAddOnInfo(i)
		if IsAddOnLoadOnDemand(i) and enabled and loadable and not IsAddOnLoaded(i) then
			if isFuBarDependent(name) then
				if not self.db.profile.loadOnDemand[name] then
					self:LoadPlugin(name)
				elseif not self.db.profile.loadOnDemand[name].disabled and (not self.db.profile.loadOnDemand[name].condition or CheckLoadCondition(self.db.profile.loadOnDemand[name].condition)) then
					self:LoadPlugin(name)
				else
					table.insert(toBeLoaded, {name, notes})
				end
			end
		end
	end
end

function FuBar:RestartGx()
	self:AddTimer(0, "Update")
end

function FuBar:OnCVarUpdate()
	if arg1 == "USE_UISCALE" then
		self:AddTimer(0, "CheckResolution")
	end
end

local lastScreenWidth = GetScreenWidth()
function FuBar:CheckResolution()
	local screenWidth = GetScreenWidth()
	if lastScreenWidth ~= screenWidth then
		for i = 1, self:GetNumPanels() do
			self:GetPanel(i):Update()
		end
		lastScreenWidth = screenWidth
		if Jostle then
			Jostle:Refresh()
		end
	end
end

local inTopPanel, inBottomPanel

function FuBar:OnUpdate_AutoHideTop()
	if not inTopPanel and self:IsAutoHidingTop() then
--		for i = 1, self:GetNumPanels() do
--			if Dewdrop:IsOpen(self:GetPanel(i).frame) then
--				self:AddTimer("FuBar_AutoHideTop", 1, "OnUpdate_AutoHideTop")
--				return
--			end
--		end
		for i = 1, self:GetNumPanels() do
			if self:GetPanel(i):GetAttachPoint() == "TOP" then
				local frame = _G["FuBarFrame" .. i]
				frame:SetAlpha(0)
				frame:SetFrameStrata("BACKGROUND")
			end
		end
	end
end

function FuBar:OnUpdate_AutoHideBottom()
	if not inBottomPanel and self:IsAutoHidingBottom() then
--		for i = 1, self:GetNumPanels() do
--			if Dewdrop:IsOpen(self:GetPanel(i).frame) then
--				self:AddTimer("FuBar_AutoHideBottom", 1, "OnUpdate_AutoHideBottom")
--				return
--			end
--		end
		for i = 1, self:GetNumPanels() do
			if self:GetPanel(i):GetAttachPoint() == "BOTTOM" then
				local frame = _G["FuBarFrame" .. i]
				frame:SetAlpha(0)
				frame:SetFrameStrata("BACKGROUND")
			end
		end
	end
end

function FuBar:IsHidingTooltipsInCombat()
	return self.db.profile.hidingTooltipsInCombat
end

function FuBar:ToggleHidingTooltipsInCombat()
	self.db.profile.hidingTooltipsInCombat = not self.db.profile.hidingTooltipsInCombat
end

local doneSetupPlugins, pluginsToSetup

function FuBar:OnDisable()
	for i = 1, self:GetNumPanels() do
		self:GetPanel(i).frame:Hide()
	end
end

function FuBar:GetNumPlugins()
	return #plugins
end

function FuBar:GetPlugin(i)
	return plugins[i]
end

function FuBar:RegisterPlugin(plugin)
	if not IsCorrectPlugin(plugin) then
		return
	end
	table.insert(plugins, plugin)

	local frame = plugin:GetFrame()
	local downTime
	if frame:HasScript("OnClick") then
		local OnClick = frame:GetScript("OnClick")
		frame:SetScript("OnClick", function(...)
			if OnClick and (not downTime or GetTime() < downTime + 0.5) and (not this.stopClick or GetTime() > this.stopClick) then
				OnClick(...)
			end
			downTime = nil
		end)
	end
	local OnMouseDown = frame:GetScript("OnMouseDown")
	frame:SetScript("OnMouseDown", function(...)
		if arg1 == "LeftButton" and not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
			downTime = GetTime()
			FuBar:Plugin_StartDrag(plugin)
		end
		if OnMouseDown then
			OnMouseDown(...)
		end
	end)
	local OnMouseUp = frame:GetScript("OnMouseUp")
	frame:SetScript("OnMouseUp", function(...)
		if arg1 == "LeftButton" then
			if not FuBar:Plugin_StopDrag(plugin) then
				if OnMouseUp then
					OnMouseUp(...)
				end
			else
				this.stopClick = GetTime() + 0.05
			end
		elseif OnMouseUp then
			OnMouseUp(...)
		end
	end)
	local OnEnter = frame:GetScript("OnEnter")
	frame:SetScript("OnEnter", function(...)
		FuBar:Panel_OnEnter(plugin)
		if OnEnter then
			OnEnter(...)
		end
	end)
	local OnLeave = frame:GetScript("OnLeave")
	frame:SetScript("OnLeave", function(...)
		FuBar:Panel_OnLeave(plugin)
		if OnLeave then
			OnLeave(...)
		end
	end)
end

function FuBar:Update()
	for panelId = 1, self:GetNumPanels() do
		self:GetPanel(panelId):Update()
	end
end

function FuBar:SetupPlugins()
	doneSetupPlugins = true
	if pluginsToSetup then
		for i = 1, self:GetNumPanels() do
			local panel = self:GetPanel(i)
			for h = 1, 3 do
				local side
				if h == 1 then
					side = "LEFT"
				elseif h == 2 then
					side = "CENTER"
				else
					side = "RIGHT"
				end
				local order = panel:GetSavedOrder(side)
				for _,name in ipairs(order) do
					for plugin in pairs(pluginsToSetup) do
						if not plugin:IsDisabled() and plugin:GetTitle() == name then
							if not panel:AddPlugin(plugin, nil, side) then
								doneSetupPlugins = false
								return
							end
							pluginsToSetup[plugin] = nil
							break
						end
					end
				end
			end
		end

		local order = self.db.profile.detached
		if order then
			for name in pairs(order) do
				for plugin in pairs(pluginsToSetup) do
					if not plugin:IsDisabled() and plugin:GetTitle() == name then
						pluginsToSetup[plugin] = nil
						plugin:Show(0)
						break
					end
				end
			end
		else
			self.db.profile.detached = {}
		end

		for plugin in pairs(pluginsToSetup) do
			if type(plugin.GetDefaultPosition) == "function" and plugin:GetDefaultPosition() == "MINIMAP" then
				plugin:Show(0)
			else
				self.lastPanelId = (self.lastPanelId or 0) + 1
				if self.lastPanelId > self:GetNumPanels() then
					self.lastPanelId = 1
				end
				self:GetPanel(self.lastPanelId):AddPlugin(plugin, nil, type(plugin.GetDefaultPosition) == "function" and plugin:GetDefaultPosition() or "LEFT", true)
			end
		end

		pluginsToSetup = nil
	end
	return true
end

function FuBar:ShowPlugin(plugin, panelId)
	if type(plugin) ~= "table" then
		error(("Bad argument #2 to `ShowPlugin'. Expected %q, got %q."):format("table", type(plugin)), 2)
	end
	if panelID and type(panelId) ~= "number" then
		error(("Bad argument #3 to `ShowPlugin'. Expected %q or %q, got %q."):format("number", "nil", type(panelId)), 2)
	end	
	if doneSetupPlugins then
		if not panelId then
			doneSetupPlugins = false
			pluginsToSetup = {}
			pluginsToSetup[plugin] = true
			local function func()
				if not self:SetupPlugins() then
					self:AddTimer(0, func)
					return
				end
				self:Update()
			end
			func()
		else
			local pos = type(plugin.GetDefaultPosition) == "function" and plugin:GetDefaultPosition() or "LEFT"
			if not self:GetPanel(panelId) then
				panelId = nil
				for i, panel in ipairs(self.db.profile.panels) do
					if panel.plugins then
						for _,part in pairs(panel.plugins) do
							for _, plug in ipairs(part) do
								if plug == plugin:GetTitle() then
									panelId = i
									break
								end
							end
							if panelId then
								break
							end
						end
					end
					if panelId then
						break
					end
				end
				if not panelId then
					panelId = 1
				end
			end
			self:GetPanel(panelId):AddPlugin(plugin, nil, pos, true)
		end
	else
		if not pluginsToSetup then
			pluginsToSetup = {}
		end
		pluginsToSetup[plugin] = true
	end
end

local previousPosition_panel, previousPosition_index, previousPosition_side, previousPosition_x, previousPosition_y

function FuBar:Plugin_StartDrag(plugin)
	local panel = plugin:GetPanel()
	if not panel then error(plugin:GetTitle() .. ": You must be attached to a panel.") end

	self:Panel_OnLeave()
	local index, side = panel:IndexOfPlugin(plugin)
	
	if index then
		if not panel:IsLocked() then
			if index < panel:GetNumPlugins(side) then
				local frame = panel:GetPlugin(index + 1, side):GetFrame()
				local x, y = frame:GetLeft(), frame:GetBottom()
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
			end

			previousPosition_panel = panel
			previousPosition_index = index
			previousPosition_side = side
			previousPosition_x, previousPosition_y = self:GetScaledCursorPosition()

			FuBar_Panel:PreventUpdate()
			panel:RemovePlugin(index, side)
			plugin:GetFrame():StartMoving()
		end
	end
end

function FuBar:Plugin_StopDrag(plugin)
	plugin:GetFrame():StopMovingOrSizing()
	if previousPosition_panel and not previousPosition_panel:IsLocked() then
		local insertAt
		local panel = previousPosition_panel
		local side = previousPosition_side
		local x, y = self:GetScaledCursorPosition()
		local px, py = previousPosition_x, previousPosition_y

		for panelId = 1, self:GetNumPanels() do
			local p = self:GetPanel(panelId)
			local frame = p.frame
			local x1, x2, y1, y2 = frame:GetLeft(), frame:GetRight(), frame:GetBottom(), frame:GetTop()
			if x1 <= x and x <= x2 and y1 <= y and y <= y2 then
				panel = p
				break
			end
		end

		if panel:GetNumPlugins(side) == 0 then
			insertAt = 1
		else
			for i = 1, panel:GetNumPlugins(side) + 1 do
				local left, right
				local leftPlugin
				local rightPlugin

				leftPlugin = panel:GetPlugin(i - 1, side)
				rightPlugin = panel:GetPlugin(i, side)

				if side == "RIGHT" then
					leftPlugin, rightPlugin = rightPlugin, leftPlugin
				end
				left = leftPlugin and leftPlugin:GetFrame():GetCenter() or 0
				right = rightPlugin and rightPlugin:GetFrame():GetCenter() or GetScreenWidth()
				if left <= x and x <= right then
					insertAt = i
					break
				end
			end
		end
		if not insertAt then
			insertAt = panel:GetNumPlugins(side) + 1
		end

		panel:AddPlugin(plugin, insertAt, side)
		FuBar_Panel:StopPreventUpdate()
		previousPosition_panel:Update()
		panel:Update()
		previousPosition_panel = nil
		previousPosition_index = nil
		previousPosition_side = nil
		previousPosition_x = nil
		previousPosition_y = nil
		if math.abs(px - x) <= 5 and math.abs(py - y) <= 5 then
			return false
		else
			return true
		end
	end
end

function FuBar:Panel_OnEnter(plugin)
	local point = plugin
	if type(plugin) == "table" then
		point = plugin:GetPanel():GetAttachPoint()
	end
	if point == "TOP" then
		inTopPanel = true
		self:RemoveTimer("FuBar_AutoHideTop")
	elseif point == "BOTTOM" then
		inBottomPanel = true
		self:RemoveTimer("FuBar_AutoHideBottom")
	else
		return
	end
	for i = 1, self:GetNumPanels() do
		local panel = self:GetPanel(i)
		if panel:GetAttachPoint() == point then
			panel.frame:SetAlpha(1)
			panel.frame:SetFrameStrata("HIGH")
		end
	end
end

function FuBar:Panel_OnLeave(plugin)
	local point = plugin
	if type(plugin) == "table" then
		if not plugin:GetPanel() then
			return
		end
		point = plugin:GetPanel():GetAttachPoint()
	end
	if point == "TOP" then
		inTopPanel = false
		self:AddTimer("FuBar_AutoHideTop", 1, "OnUpdate_AutoHideTop")
	elseif point == "BOTTOM" then
		inBottomPanel = false
		self:AddTimer("FuBar_AutoHideBottom", 1, "OnUpdate_AutoHideBottom")
	end
end

function FuBar:OnProfileEnable(oldName, _, copyFrom)
	isChangingProfile = true
	if not next(FuBar.db.profile) then
		local def
		local profile = self:GetProfile()
		if profile:find("^char/") or profile:find("^class/") then
			local class = select(2, UnitClass("player"))
			def = _G["FUBAR_DEFAULTS_" .. class] or FUBAR_DEFAULTS
		else
			def = FUBAR_DEFAULTS
		end
		if type(def) == "function" then
			def = def()
		end
		def = copyTable(def)
		for k,v in pairs(def) do
			FuBar.db.profile[k] = v
		end
	end

	if type(self.db.profile.loadOnDemand) ~= "table" then
		self.db.profile.loadOnDemand = {}
	end

	if type(self.db.profile.tooltip) ~= "table" then
		self.db.profile.tooltip = {}
	end

	if type(self.db.profile.panels) ~= "table" then
		self.db.profile.panels = {}
	end

	CleanDB()

	doneSetupPlugins = false
	pluginsToSetup = {}
	for i,plugin in ipairs(plugins) do
		pluginsToSetup[plugin] = true
		local frame = plugin:GetFrame()
		frame:Hide()
		frame:ClearAllPoints()
		plugin:SetPanel(nil)
	end

	for i = self:GetNumPanels(), 1, -1 do
		self:GetPanel(i):del(true)
	end

	for i = #self.db.profile.panels, 1, -1 do
		if self.db.profile.panels[i] then
			FuBar_Panel:new()
		end
	end

	if self:GetNumPanels() == 0 then
		FuBar_Panel:new()
	end

	self:CheckResolution()

	for i = 1, GetNumAddOns() do
		local name, _, notes, enabled, loadable = GetAddOnInfo(i)
		if IsAddOnLoadOnDemand(i) and enabled and loadable and not IsAddOnLoaded(i) then
			if findFuBarDep(GetAddOnDependencies(name)) then
				if not self.db.profile.loadOnDemand[name] then
					self:LoadPlugin(name)
				elseif not self.db.profile.loadOnDemand[name].disabled and (not self.db.profile.loadOnDemand[name].condition or CheckLoadCondition(self.db.profile.loadOnDemand[name].condition)) then
					self:LoadPlugin(name)
				else
					local exists = false
					for _,n in ipairs(toBeLoaded) do
						if n[1] == name then
							exists = true
							break
						end
					end
					if not exists then
						table.insert(toBeLoaded, {name, notes})
					end
				end
			end
		end
	end

	for i,plugin in ipairs(plugins) do
		if plugin.IsDisabled and plugin:IsDisabled() and plugin:GetPanel() then
			plugin:GetPanel():RemovePlugin(plugin)
		end
	end

	local name = self:GetProfile()
	for _,plugin in ipairs(plugins) do
		if not plugin.independentProfile then
			if type(plugin.CopyProfileFrom) ~= "function" then
				if type(plugin.SetProfile) == "function" then
					safecall(plugin.SetProfile, plugin, name, copyFrom)
				end
			elseif type(plugin.SetProfile) == "function" then
				if copyFrom then
					safecall(plugin.CopyProfileFrom, plugin, copyFrom)
				else
					safecall(plugin.SetProfile, plugin, name)
				end
			end
		end
	end

	self:SetFontSize(self:GetFontSize())

	local function func()
		if not self:SetupPlugins() then
			self:AddTimer(0, func)
			return
		end
		self:Update()
	end
	self:AddTimer(0, func)

	isChangingProfile = false
end
