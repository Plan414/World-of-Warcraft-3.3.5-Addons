--[[
Name: LibRockConfig-1.0
Revision: $Rev: 401 $
Developed by: ckknight (ckknight@gmail.com)
Credits: Nargiddley, inspiration and some code taken from Waterfall-1.0
Website: http://www.wowace.com/
Description: Library to allow for easy configuration.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockConfig-1.0"
local MINOR_VERSION = tonumber(("$Revision: 401 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockConfig, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockConfig then
	return
end

local WotLK = not not ToggleAchievementFrame

local SET_NORMAL_FONT_OBJECT = WotLK and "SetNormalFontObject" or "SetTextFontObject"

local KEY_BUTTON1 = "Left Mouse"
local KEY_BUTTON2 = "Right Mouse"
local KEYBINDING_COLON = "Keybinding: "
local ADDON_PREFERENCES = "Addon Preferences"
local FUBAR_OPTIONS = "FuBar options"
local USAGE_COLON = "Usage: "
local SHOW_MINIMAP_ICON = "Show minimap icon"
local SHOW_MINIMAP_ICON_DESC = "Whether to show the minimap icon or not."
local SCALE = "Scale"
local SCALE_DESC = "Set the scale of the preferences window."
local COPY = "Copy"
local PASTE = "Paste"
local SAVE = "Save"
local FADEOUT_TRANSPARENCY = "Fadeout transparency"
local FADEOUT_TRANSPARENCY_DESC = "The transparency for when your mouse is not over the preferences window."
local FADEIN_TRANSPARENCY = "Fadein transparency"
local FADEIN_TRANSPARENCY_DESC = "The transparency for when your mouse is over the preferences window."
local HIDE_IN_COMBAT = "Hide in combat"
local HIDE_IN_COMBAT_DESC = "Hide preferences window in combat and prevent misclicks in "
if GetLocale() == "deDE" then
	KEY_BUTTON1 = "Linke Maustaste"
	KEY_BUTTON2 = "Rechte Maustaste"
elseif GetLocale() == "koKR" then
	KEY_BUTTON1 = "왼쪽 마우스"
	KEY_BUTTON2 = "오른쪽 마우스"
	KEYBINDING_COLON = "단축키: "
	ADDON_PREFERENCES = "애드온 선택"
	FUBAR_OPTIONS = "FuBar 옵션"
	USAGE_COLON = "명령어: "
	SHOW_MINIMAP_ICON = "미니맵 아이콘 표시"
	SHOW_MINIMAP_ICON_DESC = "미니맵 아이콘을 표시하거나 숨김니다."
	SCALE = "크기"
	SCALE_DESC = "선택 창의 크기를 설정합니다."
	COPY = "복사"
	PASTE = "붙여넣기"
	FADEOUT_TRANSPARENCY = "사라짐 투명도"
	FADEOUT_TRANSPARENCY_DESC = "당신의 마우스가 선택 창 위에 있지 않을때의 투명도를 설정합니다."
	FADEIN_TRANSPARENCY = "밝아짐 투명도"
	FADEIN_TRANSPARENCY_DESC = "당신의 마우스가 선택 창 위에 있을때의 투명도를 설정합니다."
	HIDE_IN_COMBAT = "전투중 숨김"
	HIDE_IN_COMBAT_DESC = "전투중 선택 창을 숨겨 클릭실수를 방지합니다."
elseif GetLocale() == "frFR" then
	KEY_BUTTON1 = "Clic gauche"
	KEY_BUTTON2 = "Clic droit"
	KEYBINDING_COLON = "Raccourci : "
	ADDON_PREFERENCES = "Préférences"
	FUBAR_OPTIONS = "Options FuBar"
	USAGE_COLON = "Utilisation : "
	SHOW_MINIMAP_ICON = "Afficher l'icône sur la minicarte"
	SHOW_MINIMAP_ICON_DESC = "Affiche ou cache l'icône sur la minicarte."
	SCALE = "Échelle"
	SCALE_DESC = "Modifie l'échelle de la fenêtre de configuration."
	COPY = "Copier"
	PASTE = "Coller"
	FADEOUT_TRANSPARENCY = "Transparence de fenêtre inactive"
	FADEOUT_TRANSPARENCY_DESC = "La transparence de la fenêtre lorsque votre souris ne la survole pas."
	FADEIN_TRANSPARENCY = "Transparence de fenêtre active"
	FADEIN_TRANSPARENCY_DESC = "La transparence de la fenêtre lorsque votre souris la survole."
	HIDE_IN_COMBAT = "Masquer en combat"
	HIDE_IN_COMBAT_DESC = "Masque la fenêtre des préférences en combat afin d'éviter les fausses manœuvres."
elseif GetLocale() == "esES" then
	KEY_BUTTON1 = "Clic Izquierdo"
	KEY_BUTTON2 = "Clic Derecho"
elseif GetLocale() == "zhTW" then
	--*******************************
	-- zhTW Chinses Traditional localiation
	-- 2007/Oct/8 addded huge zhTW updates
	-- by 蕾艾莎塔@奧妮克希亞
	--*******************************

    KEY_BUTTON1 = "滑鼠左鍵"
	KEY_BUTTON2 = "滑鼠右鍵"
	KEYBINDING_COLON = "快捷鍵設定: "
	ADDON_PREFERENCES = "插件設定"
	FUBAR_OPTIONS = "FuBar 選項"
	USAGE_COLON = "用法: "
	SHOW_MINIMAP_ICON = "顯示小地圖圖示"
	SHOW_MINIMAP_ICON_DESC = "是否顯示小地圖邊的圖示。"
	SCALE = "縮放"
	SCALE_DESC = "調整設定視窗的縮放比例。"
	COPY = "複製"
	PASTE = "貼上"
	SAVE = "儲存"
	FADEOUT_TRANSPARENCY = "移出時透明度"
	FADEOUT_TRANSPARENCY_DESC = "當你的游標不在設定視窗上時的透明度。"
	FADEIN_TRANSPARENCY = "移入時透明度"
	FADEIN_TRANSPARENCY_DESC = "當你的游標在設定視窗上時的透明度。"
	HIDE_IN_COMBAT = "戰鬥中隱藏"
	HIDE_IN_COMBAT_DESC = "進入戰鬥時隱藏設定視窗，避免誤按。"
elseif GetLocale() == "zhCN" then
	KEY_BUTTON1 = "鼠标左键"
	KEY_BUTTON2 = "鼠标右键"

	KEYBINDING_COLON = "按键绑定: "
	ADDON_PREFERENCES = "插件参数"
	FUBAR_OPTIONS = "FuBar 选项"
	USAGE_COLON = "用法: "
	SHOW_MINIMAP_ICON = "显示小地图图标"
	SHOW_MINIMAP_ICON_DESC = "选择是否显示小地图按钮。"
	SCALE = "缩放"
	SCALE_DESC = "设置参数窗口的缩放。"
	COPY = "复制"
	PASTE = "粘贴"
	FADEOUT_TRANSPARENCY = "移出时透明度"
	FADEOUT_TRANSPARENCY_DESC = "当你的鼠标移出参数窗口时的透明度。"
	FADEIN_TRANSPARENCY = "移入时透明度"
	FADEIN_TRANSPARENCY_DESC = "当你的鼠标移入参数窗口时的透明度。"
	HIDE_IN_COMBAT = "战斗中隐藏"
	HIDE_IN_COMBAT_DESC = "进入战斗时隐藏设置窗口以避免错误点击"
end

--[[---------------------------------------------------------------------------
== LibRockConfig-1.0 table documentation ==

=== Miscellaneous notes ===
* Ordering
** -1 is the very last value, -2 comes before that, -10000 comes before that, and 10000 comes before that.
** 1 is the very first value, 2 comes after that, 10000 comes after that, and -10000 comes after that.
** An order of 0 is an error.
** If two orders are equal, then they should be sorted alphabetically.
* If you provide method names, you can use "~IsGood" instead of function() return not self:IsGood() end.
* If any function or method returns "@dict", "@list", or "@set", followed by a tuple, it will automatically turn the tuple into the proper table type (a dict, list, or set), which will later be automatically recycled.
==== Fields for all types ====
; name ''Note: this should be a few words describing the option in "Sentence case", not in "Title Case".''
: string - name of the option
: function - function which returns the name
; desc ''Note: this should be a full sentence in "Sentence case".''
: string - description of the option
: function - function which returns the description
; [handler]
: nil - inherit from the parent option's handler if possible, otherwise inherit from the object which registered it.
: table - object on which to call methods
; [disabled]
: nil or false - enabled (default)
: true - the option is disabled.
: function - function which returns a boolean, stating whether the option is disabled.
: string - method name which returns a boolean, stating whether the option is disabled.
; [hidden]
: nil or false - shown (default)
: true - the option is hidden.
: function - function which returns a boolean, stating whether the option is hidden.
: string - method name which returns a boolean, stating whether the option is hidden.
; [order]
: nil - order of 100. (default)
: number - the order of the option
: function - function which returns a number.
: string - method name which returns a number.
; [icon]
: nil - no icon. (default)
: string - path to the icon.
: function - function which returns the path to the icon.
; [iconSize]
: nil - 100%. (default)
: number - size of the icon as a percentage, e.g. 0.5 is 50%, 2 is 200%.
: string - method name which returns the size of the icon.
: function - function which returns the size of the icon.
; [passValue]
: nil - don't pass any values
: value - pass the given value to any functions/methods belonging to the current option.
; [passValue2]
: nil - don't pass any more values (only pass the passValue field)
: value - pass the given value to any functions/methods belonging to the current option.
; [passValueN] ''Note: Where N is a number from 2-inf.''
: nil - don't pass any more values (only pass the previous passValue fields)
: value - pass the given value to any functions/methods belonging to the current option.

=== execute ===
The execute type acts as a button, there is no state, but merely an action that will occur when it is triggered.
==== Fields ====
; func
: function - function that will be called.
: string - method name that will be called.
; buttonText ''Note: this should only be one word or so, e.g. "Click", "Okay", or "Remove". If more than one word, it should be in "Sentence case", not "Title Case".''
: string - name of the text on the button
: function - function which returns the text on the button
; [confirmText] ''Note: this should be a small phrase, specific if possible.
: nil - no confirmation.
: string - Add a confirmation message with a checkbox, showing one's desire.
: function - function that should return the confirmation message.
==== Example ====
 {
 	type = 'execute',
 	name = "My button",
 	desc = "Click the button to get a pony!",
 	buttonText = "Pony",
 	func = function()
 		message("You got a pony!")
 	end,
 	confirm = "Are you sure you want a pony?",
 }

=== number ===
The number type allows you to select a number between a specific range.
==== Fields ====
; get
: number - the number the value will always be. (not recommended, use a function)
: function - function that will return a number.
: string - method name that will return a number.
; set
: function - function that will set the value of a number. ''This works in tandem with get, which should return said number.''
: string - method name that will set the value of a number.
; [isPercent]
: nil or false - not a percentage (default)
: true - the value is a percentage. ''If a value is a percentage, it will show to the user as 100x larger with a percent sign.''
: function - function that will return whether the value is a percentage.
: string - method name that will return whether the value is a percentage.
; [min]
: nil - 0 (default)
: number - the minimum value.
: function - function which returns the minimum value.
: string - method name which returns the minimum value.
; [max]
: nil - 1 (default)
: number - the maximum value.
: function - function which returns the maximum value.
: string - method name which returns the maximum value.
; [step]
: nil - (max - min)/100 (default)
: number - the smallest stepsize between values. ''e.g. from [0, 1] with a step of 0.01 cannot ever have a value of 0.005, it would round up to 0.01.''
: function - function which returns the step size.
: string - method name which returns the step size.
; [bigStep]
: nil - same as step (default)
: number - the stepsize when dragging the slider, for a less specific measurement.
: function - function which returns the larger step size.
: string - method name which returns the larger step size.
; [stepBasis]
: nil - same as min (default)
: number - the basis for the step movement, so that the base number does not have to be dependent on the minimum value (which may be an odd number).
: function - function which returns the step basis.
: string - method name which returns the step basis.
==== Example ====
 local num = 0
 {
 	type = 'number',
 	name = "It's a number!",
 	desc = "A very special number.",
 	get = function()
 		return num
 	end,
 	set = function(value)
 		num = value
 	end,
 	isPercent = true,
 	step = 0.01,
 	bigStep = 0.05,
 	min = 0.01, -- minimum of 1%
 	max = 1, -- maximum of 100%
 	stepBasis = 0.05, -- so that steps go 0.01, 0.05, 0.10, 0.15 instead of 0.01, 0.06, 0.11, 0.16.
 }
=== boolean ===
The boolean type allows you to switch a toggle on and off.
==== Fields ====
; get
: boolean - the boolean the value will always be. (not recommended, use a function)
: string - can only be "HALF", anything else is an error. Means to show that it is only partially true.
: function - function that will return a boolean (or "HALF")
: string - method name that will return a boolean.
; set
: function - function that will set the value of a boolean. ''This works in tandem with get, which should return said boolean.''
: string - method name that will set the value of a boolean.

=== color ===
The color type allows you to select a color, possibly with alpha.
==== Fields ====
; get
: function - function that will return the value for a color (in format specified by colorType).
: string - method name that will return the value for a color (in format specified by colorType).
; set
: function - function that will set the value of a color (in format specified by colorType). ''This works in tandem with get, which should return said color.''
: string - method name that will set the value of a color (in format specified by colorType).
; [hasAlpha]
: nil or false - only use red, green, and blue, without alpha level.
: true - only use red, green, blue, and alpha.
: function - function which returns whether alpha is used.
: string - method name which returns whether alpha is used.
; [colorType]
: nil - use the default (either "tuple" or "tuple:rgba", based on hasAlpha)
: string - use a specific color type. (see below for the list)
: function - function which returns a specific color type.
==== Color types ====
* Without alpha
** 'tuple' - values work as an r, g, b tuple, e.g. 1, 0, 0 is red. (default)
** 'hex' - values work as an "rrggbb" hex string, e.g. "ff0000" is red.
** 'number' - values work as a serialized number, e.g. 16711680 is red and ("%06x"):format(16711680) == "ff0000".
* With alpha
** 'tuple:rgba' - values work as an r, g, b, a tuple, e.g. 1, 0, 0, 1 is red. (default)
** 'tuple:argb' - values work as an a, r, g, b tuple, e.g. 1, 1, 0, 0 is red.
** 'hex:rgba' - values work as an "rrggbbaa" hex string, e.g. "ff0000ff" is red.
** 'hex:argb' - values work as an "aarrggbb" hex string, e.g. "ffff0000" is red.
** ''Note: numbers cannot be serialized properly with alpha, as there are not enough bits to represent by an IEEE-754 double.''
==== Example ====
 local r, g, b
 {
 	type = 'color',
 	name = "The colors",
 	desc = "Some description of color.",
 	hasAlpha = false
 	colorType = 'tuple'
 	get = function()
 		return r, g, b
 	end,
 	set = function(r_, g_, b_)
 		r, g, b = r_, g_, b_
 	end,
 }
Or
 local color = "ff0000ff"
 {
 	type = 'color',
 	name = "The colors",
 	desc = "Some description of color.",
 	hasAlpha = true
 	colorType = 'hex:rgba'
 	get = function()
 		return color
 	end,
 	set = function(value)
 		color = value
 	end,
 }

=== choice ===
The choice type allows you to select a value from a list of values.
==== Fields ====
; get
: value - the current value.
: function - function that will return the current value.
: string - method name that will return the current value.
; set
: function - function that will set the current value. ''This works in tandem with get, which should return said value.''
: string - method name that will set the  current value.
; choices
: table - dictionary in backendValue = "value to show the user" format.
: function - function which returns a choices dictionary.
: string - method name which returns a choices dictionary.
; [choiceType]
: nil - guess either "list" or "dict" based on what choices is.
: "list" - the choices is a list, do not sort automatically and treat all the values as the backend values.
: "dict" - the choices is a dictionary, sort alphabetically and treat the keys as the backend values.
; [choiceDescs]
: nil - no description for each choice.
: table - dictionary in backendValue = "Description for choice" format.
: function - function which returns choiceDescs dictionary.
: string - method name which returns choiceDescs dictionary.
; [choiceIcons]
: nil - no icons for choices.
: table - dictionary in backendValue = "Icon\\path" format.
: function - function which returns choiceIcons dictionary.
: string - method name which returns choiceIcons dictionary.
; [choiceFonts]
: nil - default font. (default)
: table - dictionary in backendValue = "Font\\path" format.
: function - function which returns choiceFonts dictionary.
: string - method name which returns choiceFonts dictionary.
; [choiceTextures]
: nil - no textures for choices.
: table - dictionary in backendValue = "Texture\\path" format.
: function - function which returns choiceTextures dictionary.
: string - method name which returns choiceTextures dictionary.
; [choiceOrder]
: nil - no predefined order
: table - list of backendValues, specifying the order of the choices.
: function - function which returns choiceOrder list.
: string - method name which returns choiceOrder list.
==== Example ====
 local choice = "alpha"
 {
 	name = "Choices, choices",
 	desc = "Here's a description for the choices",
 	type = 'choice',
 	get = function()
 		return choice
 	end,
 	set = function(value)
 		choice = value
 	end,
 	choices = {
 		alpha = "Alpha",
 		bravo = "Bravo",
 		charlie = "Charlie",
 	},
	choiceOrder = { "alpha", "bravo", "charlie" },
 }

=== multichoice ===
The multichoice type allows you to select multiple values from a list of values.
==== Fields ====
; get
: function - function that will return a boolean (or "HALF"), stating whether a given key is enabled.
: string - method name that will return a boolean (or "HALF"), stating whether a given key is enabled.
; set
: function - function that will set a boolean for the given key. ''This works in tandem with get, which should return said boolean for the given key.''
: string - method name that will set a boolean for the given key.
; choices
: table - dictionary inbackendValue = "value to show the user" format.
: function - function which returns a choices dictionary.
: string - method name which returns a choices dictionary.
; [choiceType]
: nil - guess either "list" or "dict" based on what choices is.
: "list" - the choices is a list, do not sort automatically and treat all the values as the backend values.
: "dict" - the choices is a dictionary, sort alphabetically and treat the keys as the backend values.
; [choiceDescs]
: nil - no description for each choice.
: table - dictionary inbackendValue = "Description for choice" format.
: function - function which returns choiceDescs dictionary.
: string - method name which returns choiceDescs dictionary.
; [choiceIcons]
: nil - no icons for choices.
: table - dictionary inbackendValue = "Icon\\path" format.
: function - function which returns choiceIcons dictionary.
: string - method name which returns choiceIcons dictionary.
; [choiceFonts]
: nil - default font. (default)
: table - dictionary inbackendValue = "Font\\path" format.
: function - function which returns choiceFonts dictionary.
: string - method name which returns choiceFonts dictionary.
; [choiceTextures]
: nil - no textures for choices.
: table - dictionary inbackendValue = "Texture\\path" format.
: function - function which returns choiceTextures dictionary.
: string - method name which returns choiceTextures dictionary.
; [choiceOrder]
: nil - no predefined order
: table - list of backendValues, specifying the order of the choices.
: function - function which returns choiceOrder list.
: string - method name which returns choiceOrder list.
==== Example ====
 local choices = {}
 {
 	name = "Choices, choices",
 	desc = "Here's a description for the choices",
 	type = 'multichoice',
 	get = function(key)
 		return choices[key]
 	end,
 	set = function(key, value)
 		choices[key] = value
 	end,
 	choices = {
 		alpha = "Alpha",
 		bravo = "Bravo",
 		charlie = "Charlie",
 	},
	choiceOrder = { "alpha", "bravo", "charlie" },
 }

=== string ===
The string type allows you to enter arbitrary text.
==== Fields ====
; get
: false - do not show a default value. ''Note: this causes the set to act like a one-way execute with input.''
: function - function that will return the current string.
: string - method name that will return the current string.
; set
: function - function that will set the current string. ''This works in tandem with get, which should return said string.''
: string - method name that will set the  current string.
; [onChange]
: nil - do not call a function when the text changes.
: function - function that is called when the text changes.
: string - method name that is called when the text changes.
; [multiline]
: nil or false - just a single line. (default)
: true - use multiple lines.
: function - function that will return whether multiple lines are used.
: string - method name that will return whether multiple lines are used.
; [validate]
: nil - no validation (default)
: function - function that will be passed the string and should return true for a proper string and false, "message" for an improper string.
: string - method name that will be passed the string and should return true for a proper string and false, "message" for an improper string.
; usage
: string - usage text to be displayed.
: function - function to return usage text.
; [syntaxHighlighter]
: nil - no highlighting (default)
: function - function that will be passed the string and should return a new string with colors embedded.
: string - method name that will be passed the string and should return a new string with colors embedded.
==== Example ====
 local text = "Hello"
 {
 	name = "Teckst Bocks",
 	desc = "Here's the desc",
 	type = 'string',
 	get = function()
 		return text
 	end,
 	set = function(value)
 		text = value
 	end,
	onChange = function(value)
		-- do something here
	end,
	usage = "Some text",
 }
or
 local text = "Alpha"
 {
 	name = "Teckst Bocks",
 	desc = "Here's the desc",
 	type = 'string',
 	get = function()
 		return text
 	end,
 	set = function(value)
 		text = value
 	end,
 	validate = function(value)
 		if #value <= 4 then
 			return false, "Must be at least 5 characters long."
 		else
 			return true,
 		end
 	end,
	usage = "Some text at least 5 characters long.",
 }

=== keybinding ===
The keybinding type allows you to enter a keybinding.
==== Fields ====
; get
: false - do not show a default value.
: function - function that will return the current key binding.
: string - method name that will return the current key binding.
; set ''Note: this can receive either false or a string, where false is no binding.''
: function - function that will set the current key binding. ''This works in tandem with get, which should return said string.''
: string - method name that will set the current key binding.
; [keybindingExcept]
: nil - accept everything (or pass on to keybindingOnly).
: table - a set of keybindings which will not be accepted.
: function - function which returns a set of keybindings.
: string - method name which returns a set of keybindings.
; [keybindingOnly]
: nil - accept everything (or pass on to keybindingExcept).
: table - a set of keybindings which are the only ones to be accepted.
: function - function which returns a set of keybindings.
: string - method name which returns a set of keybindings.

=== group ===
The group type provides a tree-like structure to your options, allowing options to be suboptions of said group.
==== Fields ====
; args
: table - dictionary of sub-options in someName = { suboption } format. Keys can be anything unique.
; [child_<SomeKey>]
: value - this will essentially implant <SomeKey> = value onto the child table.
; [child_child_<SomeKey>]
: value - this will essentially implant <SomeKey> = value onto the child's child table, ad nauseum.
; [groupType]
: nil or "normal" : to show in a normal tree fashion.
: "tab" : show in tab format. -- TODO- actually implement this
: "inline" : show inline in the other options, in a collapseable group.
==== Example ====
 values = {}
 {
 	type = 'group',
 	name = "My subgroup",
 	desc = "Description for the subgroup",
 	child_get = function(key)
 		return values[key]
 	end,
 	child_set = function(key, value)
 		values[key] = value
 	end,
 	args = {
 		{
 			type = 'boolean',
 			name = "Some value",
 			desc = "Some description",
 			passValue = "blah",
 		},
 		{
 			type = 'string',
 			name = "Some other value",
 			desc = "Some other description",
			usage = "Some text",
 			passValue = "blarg",
 		},
 	}
 }
-----------------------------------------------------------------------------]]

-- #AUTODOC_NAMESPACE RockConfig

RockConfig.data = setmetatable(oldLib and oldLib.data or {}, {__mode='k'})
local data = RockConfig.data

local _G = _G
local Rock = _G.Rock
local assert = _G.assert
local error = _G.error
local pcall = _G.pcall
local select = _G.select
local ipairs = _G.ipairs
local pairs = _G.pairs
local unpack = _G.unpack
local tostring = _G.tostring
local next = _G.next
local type = _G.type
local setmetatable = _G.setmetatable
local math_min = _G.math.min
local math_max = _G.math.max
local math_floor = _G.math.floor
local math_abs = _G.math.abs
local table_sort = _G.table.sort
local table_concat = _G.table.concat
local table_insert = _G.table.insert
local geterrorhandler = _G.geterrorhandler
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local ChatFontNormal = _G.ChatFontNormal
local GameFontNormal = _G.GameFontNormal
local GameFontDisableSmall = _G.GameFontDisableSmall
local GameFontDisable = _G.GameFontDisable
local GameFontHighlightSmall = _G.GameFontHighlightSmall
local GameFontHighlight = _G.GameFontHighlight
local GameTooltip = _G.GameTooltip
local GRAY_FONT_COLOR = _G.GRAY_FONT_COLOR
local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR
local NORMAL_FONT_COLOR = _G.NORMAL_FONT_COLOR
local SetDesaturation = _G.SetDesaturation
local GetMouseFocus = _G.GetMouseFocus

local newList, newDict, newSet, del, unpackListAndDel = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "newDict", "newSet", "del", "unpackListAndDel")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local function toliteral(v)
	if type(v) == "string" then
		return ("%q"):format(v)
	else
		return tostring(v)
	end
end

-- small value that's used.
local epsilon = 1e-5

local validateConfigTable

--[[---------------------------------------------------------------------------
Notes:
	* Sets the configuration table for the current object
	* This will call Rock:GetRockConfigOptions(addon) expecting an unpacked dict as the return. The values of said dict will be placed into the extraArgs section of the configTable.
	* This will also call mixin:GetEmbedRockConfigOptions(addon), in the same mechansim as the above process.
Arguments:
	table - a configuration table.
Example:
	MyAddon:SetConfigTable({
		...
	})
-----------------------------------------------------------------------------]]
function RockConfig:SetConfigTable(configTable)
	data[self] = configTable

	if Rock:HasAddon(self) and Rock.GetRockConfigOptions then
		local opts = newDict(Rock:GetRockConfigOptions(self))
		if next(opts) ~= nil then
			local configTable_extraArgs = configTable.extraArgs
			if not configTable_extraArgs then
				configTable_extraArgs = newList()
				configTable.extraArgs = configTable_extraArgs
			end
			for k,v in pairs(opts) do
				configTable_extraArgs[k] = v
			end
		end
		opts = del(opts)
	end
	for mixin in Rock:IterateObjectMixins(self) do
		if mixin.GetEmbedRockConfigOptions then
			local opts = newDict(mixin:GetEmbedRockConfigOptions(self))
			if next(opts) ~= nil then
				local configTable_extraArgs = configTable.extraArgs
				if not configTable_extraArgs then
					configTable_extraArgs = newList()
					configTable.extraArgs = configTable_extraArgs
				end
				for k,v in pairs(opts) do
					configTable_extraArgs[k] = v
				end
			end
			opts = del(opts)
		end
	end
end
precondition(RockConfig, 'SetConfigTable', function(self, configTable)
	if data[self] then
		error("Cannot call `SetConfigTable' more than once.", 3)
	end
	local result, path = validateConfigTable(self, configTable)
	if result then
		error(("Config error: %s for path `%s'"):format(result, path), 3)
	end
end)

local createBase
local base

-- hook the escape button so it closes the config window
local orig_CloseSpecialWindows = _G.CloseSpecialWindows
function _G.CloseSpecialWindows()
	local found = orig_CloseSpecialWindows()
	if base and base:IsShown() then
		base:Hide()
		return true
	end
	return found
end

local getTreeLine, releaseTreeLine, sortTreeLineSections

local saveState, restoreState

--[[---------------------------------------------------------------------------
Arguments:
	tuple - the path to open to.
Notes:
	* Opens the configuration menu to the current object's configuration
	* This must be called after `SetConfigTable'.
Example:
	MyAddon:OpenConfigMenu()
-----------------------------------------------------------------------------]]
function RockConfig:OpenConfigMenu(...)
	if not base then
		createBase()
	elseif base:IsShown() then
		base:Hide()
	end
	
	if RockConfig.hideInCombat and InCombatLockdown() then
		base:Hide()
		return
	end

	if UIParent:IsShown() then
		base:SetParent(UIParent)
		base:SetScale(RockConfig.scale or 1)
		base:SetFrameLevel(1)
		base:SetFrameStrata("FULLSCREEN_DIALOG")
	else
		base:SetParent(nil)
		base:SetScale((RockConfig.scale or 1) * UIParent:GetScale())
		base:SetFrameLevel(1)
		base:SetFrameStrata("FULLSCREEN_DIALOG")
	end

	base.titleText:SetText('-----')

	local found
	if data[self] then
		if self == RockConfig and restoreState() then
			-- pass
		else
			base.addonChooser:Select(self)
			local line = base.treeView.sections[1]
			for i = 1, select('#', ...) do
				local breadcrumb = select(i, ...)
				local good = false
				local sections = line.sections
				if sections then
					for k,v in pairs(sections) do
						if v[i+1] == breadcrumb then
							v:Click()
							if v.expand:IsShown() then
								line = v
								good = true
							end
							break
						end
					end
				end
				if not good then
					break
				end
			end
		end
	end

	base.treeView:Reposition()

	base:Show()
end
precondition(RockConfig, 'OpenConfigMenu', function(self)
	if RockConfig ~= self and not data[self] then
		error("Cannot call `OpenConfigMenu' before calling `AddConfigTable'.", 3)
	end
end)

local currentlyMovingSlider = false

local refreshConfigMenu
local refreshConfigMenu_frame
local refreshConfigMenu_object
--[[---------------------------------------------------------------------------
Notes:
	* Refreshes the config menu if it is open to the current object.
	* This will do nothing if the menu is closed or if it is open on a different object.
	* This is very useful to call if a setting has changed not in response to someone setting an option.
Example:
	Rock("LibRockConfig-1.0"):RefreshConfigMenu(MyAddon)
-----------------------------------------------------------------------------]]
function RockConfig:RefreshConfigMenu(object)
	if not data[object] and object ~= false then
		return
	end
	if not base or not base:IsShown() then
		return
	end
	if base.addonChooser.value ~= object then
		return
	end

	if not refreshConfigMenu_frame then
		refreshConfigMenu_frame = CreateFrame("Frame")
		refreshConfigMenu_frame:SetScript("OnUpdate", function(this)
			if not currentlyMovingSlider then
				refreshConfigMenu(refreshConfigMenu_object)
				this:Hide()
			end
		end)
	end
	refreshConfigMenu_object = object or nil
	refreshConfigMenu_frame:Show()
end
precondition(RockConfig, 'RefreshConfigMenu', function(self, object)
	if object ~= false then
		argCheck(object, 2, "table")
	end
end)

--[[---------------------------------------------------------------------------
Arguments:
	[optional] table - addon which the config menu could be open to
Returns:
	boolean - whether the config menu is open to the given addon
Example:
	local isOpen = Rock("LibRockConfig-1.0"):IsConfigMenuOpen(MyAddon)
-----------------------------------------------------------------------------]]
function RockConfig:IsConfigMenuOpen(object)
	if not data[object] and object then
		return false
	end
	if not base or not base:IsShown() then
		return false
	end
	return base.addonChooser.value == object or not object
end
precondition(RockConfig, 'IsConfigMenuOpen', function(self, object)
	argCheck(object, 2, "table", "nil")
end)

--[[---------------------------------------------------------------------------
Notes:
	* Creates slash commands that link to the addon's configuration menu.
Example:
	MyAddon:SetConfigSlashCommand("/MyAddon")
-----------------------------------------------------------------------------]]
function RockConfig:SetConfigSlashCommand(...)
	local function handler()
		RockConfig.OpenConfigMenu(self)
	end

	local name = self.name
	if type(name) == "string" then
		name = name:upper()
	else
		name = tostring(self):upper()
	end

	local i = 0
	for j = 1, select('#', ...) do
		local command = select(j, ...)
		if command then
			i = i + 1
			_G["SLASH_"..name..i] = command
			local command_lower = command:lower()
			if command_lower ~= command then
				i = i + 1
				_G["SLASH_"..name..i] = command_lower
			end
		end
	end
	_G.hash_SlashCmdList[name] = nil
	_G.SlashCmdList[name] = handler

	if self.slashCommand == nil then
		self.slashCommand = (...)
	end
end
precondition(RockConfig, 'SetConfigSlashCommand', function(self, ...)
	argCheck(self, 1, "table")
	if self == RockConfig then
		error(("Bad argument #1 to `SetConfigSlashCommand'. Cannot be %s."):format(MAJOR_VERSION), 3)
	end
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		argCheck(v, i+1, "string")
		if not v:match("^/[A-Za-z0-9]") then
			error(("Bad argument #%d to `SetConfigSlashCommand'. Must be in the form of %q, got %q."):format(i+1, "/word", v), 3)
		end
	end
end)


local caches = {}
local cacheFuncs = {}
local function getCachedPath(path)
	for k,v in pairs(caches) do
		if #k == #path then
			local good = true
			for i = 1, #path do
				if path[i] ~= k[i] then
					good = false
					break
				end
			end
			if good then
				return newList(true, unpack(v))
			end
		end
	end
end

local cacheTimes = setmetatable({}, {__mode = 'k'})
local function setCachedPath(path, ...)
	for k,v in pairs(caches) do
		if #k == #path then
			local good = true
			for i = 1, #path do
				if path[i] ~= k[i] then
					good = false
					break
				end
			end
			if good then
				caches[k] = del(v)
				del(k)
			end
		end
	end
	local k = newList(unpack(path))
	caches[k] = newList(...)
	if not cacheTimes[path[1]] then
		cacheTimes[path[1]] = GetTime()
	end
	if #path == 2 and select('#', ...) == 1 and type(...) == "table" and type(data[path[1]][path[2]]) == "function" then
		cacheFuncs[k] = data[path[1]][path[2]]
		data[path[1]][path[2]] = (...)
	end
end

local cacheFrame = CreateFrame("Frame")
local nextTime = 0
cacheFrame:SetScript("OnUpdate", function(this, elapsed)
	local currentTime = GetTime()
	if currentTime < nextTime then
		return
	end
	nextTime = currentTime + 1
	for k, v in pairs(caches) do
		local addon = k[1]
		if RockConfig:IsConfigMenuOpen(addon) then
			cacheTimes[addon] = currentTime
		else
			if cacheTimes[addon] + 180 < currentTime and not InCombatLockdown() then
				if cacheFuncs[k] then
					data[k[1]][k[2]] = cacheFuncs[k]
					cacheFuncs[k] = nil
				end
				caches[k] = del(v)
				del(k)
			end
		end
	end
end)

local transformReturnTable
do
	local temporaryPool = setmetatable({}, {__mode='k'})

	function transformReturnTable(path, tmp)
		if tmp[2] == "@cache" then
--			Rock("LibRockConsole-1.0"):Print("Add cache", unpack(path))
--			Rock("LibRockConsole-1.0"):Print(unpack(tmp))
			table.remove(tmp, 2)
			transformReturnTable(path, tmp)
			setCachedPath(path, tmp[2])
		elseif tmp[2] == "@dict" then
			local t = newDict(unpack(tmp, 3, #tmp))
			tmp[2] = t
			temporaryPool[t] = true
			for i = 3, #tmp do
				tmp[i] = nil
			end
		elseif tmp[2] == "@list" then
			local t = newList(unpack(tmp, 3, #tmp))
			tmp[2] = t
			temporaryPool[t] = true
			for i = 3, #tmp do
				tmp[i] = nil
			end
		elseif tmp[2] == "@set" then
			local t = newSet(unpack(tmp, 3, #tmp))
			tmp[2] = t
			temporaryPool[t] = true
			for i = 3, #tmp do
				tmp[i] = nil
			end
		end
	end

	local f = CreateFrame("Frame", nil, UIParent)
	f:SetScript("OnUpdate", function()
		for k in pairs(temporaryPool) do
			temporaryPool[k] = del(k)
		end
		temporaryPool[true] = true
		temporaryPool[true] = nil
	end)
end

local function __getPassValues(configTables, rest, current, tableKey)
	local key
	if not current then
		key = "passValue"
		current = 1
	else
		key = "passValue" .. current
	end
	for i,v in ipairs(configTables) do
		local passValue = v[("child_"):rep(i-1) .. key]
		if passValue ~= nil then
			return passValue, __getPassValues(configTables, rest, current + 1)
		end
	end
	if current == 1 then
		if configTables[2] and configTables[2].pass then
			if rest then
				return tableKey, unpack(rest)
			else
				return tableKey
			end
		end
	end
	if rest then
		return unpack(rest)
	else
		return
	end
end

local getConfigTable
--[[---------------------------------------------------------------------------
Arguments:
	table - the current configTable
	table - a list of the rest of the values to be returned.
Returns:
	tuple - a tuple of values
Example:
	local configTable = { passValue = "hello", passValue2 = "there", passValue3 = "dolly" }
	getPassValues(configTable, nil) => "hello", "there", "dolly"
	getPassValues(configTable, { "alpha" }) => "alpha", "hello", "there", "dolly"
	getPassValues(configTable, { "alpha", "bravo" }) => "alpha", "bravo", "hello", "there", "dolly"
-----------------------------------------------------------------------------]]
local function getPassValues(path, rest)
	local configTables = newList(getConfigTable(path))
	local results = newList(__getPassValues(configTables, rest, nil, path[#path]))
	del(configTables)
	return unpackListAndDel(results)
end

--[[---------------------------------------------------------------------------
Arguments:
	table - a list of the current path.
Notes:
	Paths are in the form of [1] = object, [2] = firstArg, [3] = secondArg, ad nauseum.
Returns:
	A configTable or nil
Example:
	local configTable = getConfigTable({ MyAddon, 'stuff' })
-----------------------------------------------------------------------------]]
function getConfigTable(path)
	local configTable = data[path[1]]
	if not configTable then
		if type(path[1].type) == "string" then
			configTable = path[1]
		else
			return nil
		end
	end
	if type(configTable) == "function" then
		local tmpPath = newList(path[1])
		local tmp = getCachedPath(tmpPath)
		if not tmp then
			tmp = newList(pcall(configTable))
			if not tmp[1] then
				geterrorhandler()(tmp[2])
				tmp = del(tmp)
				tmpPath = del(tmpPath)
				return nil
			end
			
			transformReturnTable(tmpPath, tmp)
		end
		tmpPath = del(tmpPath)
		configTable = tmp[2]
		tmp = del(tmp)
	end
	local t = newList(configTable)
	for i = 2, #path do
		if configTable.type ~= "group" then
			local good = false
			if not configTable.type then
				for j = 2, #t do
					local ct = t[j]
					local ct_type = ct[("child_"):rep(j-1) .. "type"]
					if ct_type == "group" then
						good = true
						break
					elseif ct_type then
						break
					end
				end
			end
			if not good then
				t = del(t)
				break
			end
		end
		local configTable_args = configTable.args
		if not configTable_args then
			for j = 2, #t do
				local ct = t[j]
				configTable_args = ct[("child_"):rep(j-1) .. "args"]
				if configTable_args then
					break
				end
			end
			if not configTable_args then
				t = del(t)
				break
			end
		end
		if type(configTable_args) == "function" then
			local tmpPath = newList()
			for j = 1, i-1 do
				tmpPath[j*2-1] = path[j]
				tmpPath[j*2] = 'args'
			end
			local tmp = getCachedPath(tmpPath)
			if not tmp then
				tmp = newList(pcall(configTable_args, __getPassValues(t)))
				if not tmp[1] then
					geterrorhandler()(tmp[2])
					tmp = del(tmp)
					tmpPath = del(tmpPath)
					return nil
				end
				
				transformReturnTable(tmpPath, tmp)
			end
			configTable_args = tmp[2]
			tmp = del(tmp)
			tmpPath = del(tmpPath)
		end
		local v = path[i]
		configTable = configTable_args[v]
		
		if type(configTable) == "function" then
			local tmpPath = newList()
			for j = 1, i-1 do
				tmpPath[i*2 - 1] = path[j]
				tmpPath[i*2] = 'args'
			end
			tmpPath[#tmpPath+1] = path[i]
			local tmp = getCachedPath(tmpPath)
			if not tmp then
				tmp = newList(pcall(configTable))
				if not tmp[1] then
					geterrorhandler()(tmp[2])
					tmp = del(tmp)
					tmpPath = del(tmpPath)
					return nil
				end

				transformReturnTable(tmpPath, tmp)
			end
			tmpPath = del(tmpPath)
			configTable = tmp[2]
			tmp = del(tmp)
		end
		
		table_insert(t, 1, configTable)
		if not configTable then
			t = del(t)
			break
		end
	end
	if t then
		return unpackListAndDel(t)
	end

	configTable = data[path[1]] or path[1]
	t = newList(configTable)
	for i = 2, #path do
		if configTable.type ~= "group" then
			local good = false
			if not configTable.type then
				for j = 2, #t do
					local ct = t[j]
					local ct_type = ct[("child_"):rep(j-1) .. "type"]
					if ct_type == "group" then
						good = true
						break
					elseif ct_type then
						break
					end
				end
			end
			if not good then
				t = del(t)
				return nil
			end
		end
		local configTable_args
		if i == 2 then
			configTable_args = configTable.extraArgs
		else
			configTable_args = configTable.args
		end
		if not configTable_args then
			for j = 2, #t do
				local ct = t[j]
				configTable_args = ct[("child_"):rep(j-1) .. "args"]
				if configTable_args then
					break
				end
			end
			if not configTable_args then
				t = del(t)
				return nil
			end
		end
		local v = path[i]
		configTable = configTable_args[v]
		
		if type(configTable) == "function" then
			local tmpPath = newList()
			for j = 1, i-1 do
				tmpPath[i*2 - 1] = path[j]
				tmpPath[i*2] = 'args'
			end
			tmpPath[#tmpPath+1] = path[i]
			local tmp = getCachedPath(tmpPath)
			if not tmp then
				tmp = newList(pcall(configTable))
				if not tmp[1] then
					geterrorhandler()(tmp[2])
					tmp = del(tmp)
					tmpPath = del(tmpPath)
					return nil
				end

				transformReturnTable(tmpPath, tmp)
			end
			tmpPath = del(tmpPath)
			configTable = tmp[2]
			tmp = del(tmp)
		end
		
		table_insert(t, 1, configTable)
		if not configTable then
			t = del(t)
			return nil
		end
	end
	return unpackListAndDel(t)
end

--[[---------------------------------------------------------------------------
Arguments:
	table - a list of the current path.
Returns:
	boolean - whether the path leads to a configTable
Example:
	local has = hasConfigTable({ MyAddon, 'stuff' })
-----------------------------------------------------------------------------]]
local function hasConfigTable(path)
	return not not getConfigTable(path)
end

--[[---------------------------------------------------------------------------
Arguments:
	table - a list of the current path
Notes:
	If possible, the names from the configTables are used instead of the keys themselves.
Returns:
	string - a string representation of the path, in a way that is most humanly-readable.
Example:
	assert(getPathString({ MyAddon, 'settings', 'color' }) == "My Addon->General settings->Color")
-----------------------------------------------------------------------------]]
local function getPathString(path)
	local t = newList()
	for i = 1, #path do
		local v = path[i]

		local tmp = newList(unpack(path, 1, i))
		local configTable = getConfigTable(tmp)
		tmp = del(tmp)

		local name = configTable and configTable.name

		if type(name) ~= "string" then
			if type(v) == "table" then
				name = v.name
			end
			if type(name) ~= "string" then
				name = tostring(v)
			end
		end
		t[i] = name
	end
	local s = table_concat(t, "->")
	t = del(t)
	return s
end

do
	local function myPathString(configTable, currentPath)
		if not currentPath then
			local path = newList(configTable)
			local s = getPathString(path)
			path = del(path)
			return s
		else
			return getPathString(currentPath)
		end
	end
	local function check(object, configTable, currentPath, field, canBeString, optional, typecheck)
		local guiField = "gui" .. field:sub(1, 1):upper() .. field:sub(2)
		local configTable_field = configTable[guiField]
		if configTable_field == nil then
			configTable_field = configTable[field]
		end
		if configTable_field == nil and currentPath then
			local tables = newList(getConfigTable(currentPath))
			for i = 2, #tables do
				local v = tables[i]
				local ct = v[("child_"):rep(i-1) .. guiField]
				if ct == nil then
					ct = v[("child_"):rep(i-1) .. field]
				end
				if ct ~= nil then
					configTable_field = ct
					break
				end
			end
			if configTable_field == nil and #tables >= 2 and tables[2].pass then
				configTable_field = tables[2][guiField]
				if configTable_field == nil then
					configTable_field = tables[2][field]
				end
			end
			tables = del(tables)
		end
		local type_configTable_field = type(configTable_field)
		if type_configTable_field == "function" then
			return
		end
		if not canBeString and type_configTable_field == "string" then
			local tables = newList(getConfigTable(currentPath))
			local handler = object
			for i,v in ipairs(tables) do
				local h = v.handler
				if type(h) == "table" then
					handler = h
					break
				end
			end
			tables = del(tables)
			local methodName = configTable_field:match("^~(.*)$") or configTable_field
			local handler_methodName = handler[methodName]
			if type(handler_methodName) ~= "function" then
				return ('Method %q not found, got %q.'):format(methodName, type(handler_methodName)), myPathString(configTable, currentPath)
			end
			return
		end
		if optional and type_configTable_field == "nil" then
			return
		end
		if not typecheck then
			if type_configTable_field == "nil" then
				return ('%s must be non-nil.'):format(field), myPathString(configTable, currentPath)
			else
				return
			end
		end
		local types = newSet((";"):split(typecheck))
		if types then
			local good = false
			if types["boolean"] and (type_configTable_field == "nil" or configTable_field == 1) then
				good = true
			elseif (types["dict"] or types["set"] or types["list"]) and type_configTable_field == "table" then
				good = true
			elseif types[type_configTable_field] then
				good = true
			end
			types = del(types)
			if good then
				return
			end
		end
		return ('%s must be a %q, got %q.'):format(field, typecheck, type_configTable_field), myPathString(configTable, currentPath)
	end
	function validateConfigTable(object, configTable, currentPath)
		local configTable_type = configTable.type
		if configTable_type == nil and currentPath then
			local tables = newList(getConfigTable(currentPath))
			for i = 2, #tables do
				local v = tables[i]
				local ct = v[("child_"):rep(i-1) .. "type"]
				if ct ~= nil then
					configTable_type = ct
					break
				end
			end
			tables = del(tables)
		end
		if type(configTable_type) == "function" then
			-- pass
		elseif type(configTable_type) ~= "string" then
			return ('type must be a "string", got %q'):format(type(configTable_type)), myPathString(configTable, currentPath)
		else
			if not currentPath then
				if configTable_type ~= "group" then
					return 'type must be "group"', myPathString(configTable, currentPath)
				end
			else
				if configTable_type ~= "execute" and configTable_type ~= "boolean" and configTable_type ~= "number" and configTable_type ~= "color" and configTable_type ~= "choice" and configTable_type ~= "multichoice" and configTable_type ~= "string" and configTable_type ~= "keybinding" and configTable_type ~= "group" and configTable_type ~= "toggle" and configTable_type ~= "range" and configTable_type ~= "text" and configTable_type ~= "header" then
					return ('type %q is not valid'):format(configTable_type), myPathString(configTable, currentPath)
				end
			end
		end

		local checks = newList()
		checks[#checks+1] = newList('handler', false, true, "table")
		if configTable_type ~= "header" then
			checks[#checks+1] = newList('name', true, false, "string")
			checks[#checks+1] = newList('desc', true, false, "string")
		end
		checks[#checks+1] = newList('disabled', false, true)
		checks[#checks+1] = newList('hidden', false, true)
		checks[#checks+1] = newList('order', false, true, "number")
		checks[#checks+1] = newList('icon', true, true, "string")
		checks[#checks+1] = newList('iconSize', false, true, "number")
		checks[#checks+1] = newList('iconTexCoord', false, true, "table")

		if configTable_type == "execute" then
			checks[#checks+1] = newList('func', false, false, "function")
			checks[#checks+1] = newList('buttonText', true, true, "string")
			checks[#checks+1] = newList('confirmText', true, true, "string")
		elseif configTable_type == "number" then
			checks[#checks+1] = newList('get', false, false, "number")
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('isPercent', false, true, "boolean")
			checks[#checks+1] = newList('min', false, true, "number")
			checks[#checks+1] = newList('max', false, true, "number")
			checks[#checks+1] = newList('step', false, true, "number")
			checks[#checks+1] = newList('bigStep', false, true, "number")
			checks[#checks+1] = newList('stepBasis', false, true, "number")
		elseif configTable_type == "boolean" then
			checks[#checks+1] = newList('get', false, false, "boolean;string")
			checks[#checks+1] = newList('set', false, false, "function")
		elseif configTable_type == "color" then
			checks[#checks+1] = newList('get', false, false, "function")
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('hasAlpha', false, true, "boolean")
			checks[#checks+1] = newList('colorType', true, true, "string")
		elseif configTable_type == "choice" then
			checks[#checks+1] = newList('get', false, false)
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('choices', false, false, "table")
			checks[#checks+1] = newList('choiceType', true, true, "string")
			checks[#checks+1] = newList('choiceDescs', false, true, "table")
			checks[#checks+1] = newList('choiceIcons', false, true, "table")
			checks[#checks+1] = newList('choiceIconTexCoords', false, true, "table")
			checks[#checks+1] = newList('choiceFonts', false, true, "table")
			checks[#checks+1] = newList('choiceTextures', false, true, "table")
			checks[#checks+1] = newList('choiceOrder', false, true, "table")
		elseif configTable_type == "multichoice" then
			checks[#checks+1] = newList('get', false, false, "function")
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('choices', false, false, "table")
			checks[#checks+1] = newList('choiceType', true, true, "string")
			checks[#checks+1] = newList('choiceDescs', false, true, "table")
			checks[#checks+1] = newList('choiceIcons', false, true, "table")
			checks[#checks+1] = newList('choiceIconTexCoords', false, true, "table")
			checks[#checks+1] = newList('choiceFonts', false, true, "table")
			checks[#checks+1] = newList('choiceTextures', false, true, "table")
			checks[#checks+1] = newList('choiceOrder', false, true, "table")
		elseif configTable_type == "string" then
			checks[#checks+1] = newList('get', false, false, "string;boolean;number")
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('multiline', false, true, "boolean")
			checks[#checks+1] = newList('validate', false, true, "function")
			checks[#checks+1] = newList('syntaxHighlighter', false, true, "function")
			checks[#checks+1] = newList('usage', true, false, "string")
		elseif configTable_type == "keybinding" then
			checks[#checks+1] = newList('get', false, false, "string;boolean")
			checks[#checks+1] = newList('set', false, false, "function")
			checks[#checks+1] = newList('keybindingOnly', false, true, "table")
			checks[#checks+1] = newList('keybindingExcept', false, true, "table")
		elseif configTable_type == "group" then
			checks[#checks+1] = newList('args', false, false, "table")
			checks[#checks+1] = newList('extraArgs', false, true, "table")
			checks[#checks+1] = newList('groupType', true, true, "string")
		end

		local ret, path
		for i,v in ipairs(checks) do
			ret, path = check(object, configTable, currentPath, unpack(v))
			if ret then
				break
			end
		end
		for i,v in ipairs(checks) do
			del(v)
		end
		checks = del(checks)
		if ret then
			return ret, path
		end

		if configTable_type == "group" then
			local args = configTable.args
			if type(args) == "table" then
				for k,v in pairs(args) do
					local p
					if currentPath then
					 	p = newList(unpack(currentPath))
					else
						p = newList(configTable)
					end
					p[#p+1] = k
					ret, path = validateConfigTable(object, v, p)
					p = del(p)
					if ret then
						return ret, path
					end
				end
			end
		end
	end
end

local getConfigField

local function transformConfigField(path, field, canBeString, optional, typecheck, t)
	if field == 'type' then
		if t[2] == 'toggle' then
			t[2] = 'boolean'
			return
		elseif t[2] == 'range' then
			t[2] = 'number'
			return
		elseif t[2] == 'text' then
			local validate_type = getConfigField(path, 'validate', false, true, nil, true, true)
			if validate_type == "table" then
				local multiToggle = getConfigField(path, 'multiToggle', false, true, nil, true)
				if multiToggle then
					t[2] = 'multichoice'
				else
					t[2] = 'choice'
				end
			elseif validate_type == "string" then
				local validate = getConfigField(path, 'validate', true, true, nil, true)
				if validate == "keybinding" then
					t[2] = 'keybinding'
				else
					t[2] = 'string'
				end
			else
				t[2] = 'string'
			end
			return
		end
	elseif field == 'buttonText' then
		if t[2] == nil then
			t[2] = _G.OKAY
		end
	elseif field == 'choices' then
		if t[2] == nil then
			local type = getConfigField(path, 'type', true, true, nil, true)
			if type == 'text' then
				t[2] = getConfigField(path, 'validate', false, true, nil, true)
			end
			return
		end
	elseif field == 'choiceDescs' then
		if t[2] == nil then
			local type = getConfigField(path, 'type', true, true, nil, true)
			if type == 'text' then
				t[2] = getConfigField(path, 'validateDesc', false, true, nil, true)
			end
			return
		end
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* This takes a value off of a configTable, and if a function should be executed, then that should happen, though literal values are quite acceptable.
	* This makes general situations such as name = "Hello" as well as name = function() return "Hello" end both work equally.
Arguments:
	table - a list of the current path
	string - the name of the field we're looking at
	[optional] boolean - whether the field can be a literal string instead of a reference to a method name.
	[optional] boolean or value - whether the field is optional, if a non-boolean is provided, then that will be the value returned if the field returns nil.
	[optional] string - the type (or types separated by semicolon) that the resultant field must be.
Returns:
	value or tuple - if executing a function, this will return the tuple that is returned, otherwise return the literal value.
Example:
	local value = getConfigField(path, 'get', false, false, "string") -- get the value off the path that must be a string and cannot be optional.
	local r, g, b, a = getConfigField(path, 'get', false, false) -- get the value off the path that you expect to be an r, g, b, a sequence. Note: this must be typechecked manually.
	local name = getConfigField(path, 'name', true, false) -- get the name off the path, the name can be a literal string, cannot be a method.
	local hasAlpha = getConfigField(path, 'hasAlpha', false, true, "boolean") -- get hasAlpha off the path, can be nil/true/false.
	local order = getConfigField(path, 'order', false, 100, "number") -- get order off the path, if nil is provided, it will return 100.
-----------------------------------------------------------------------------]]
function getConfigField(path, field, canBeString, optional, typecheck, dontTransform, getType)
	local guiField = "gui" .. field:sub(1, 1):upper() .. field:sub(2)
	local t = newList(getConfigTable(path))

	if #t == 0 then
		t = del(t)
		local _, ret = pcall(error, ("%s: Cannot find path `%s'."):format(MAJOR_VERSION, getPathString(path)))
		geterrorhandler()(ret)
		return nil
	end

	local func
	local handler = path[1]
	for i = #t, 1, -1 do
		local configTable = t[i]
		local f = configTable[("child_"):rep(i-1) .. guiField]
		if f == nil then
			f = configTable[("child_"):rep(i-1) .. field]
		end
		if f ~= nil then
			func = f
		end
		local h = configTable.handler
		if h ~= nil then
			handler = h
		end
	end

	local configTable = t[1]

	if func == nil and field ~= 'pass' and #path > 1 then
		local superpath = newList(unpack(path, 1, #path-1))
		local pass = getConfigField(superpath, 'pass', false, true)
		if pass then
			func = t[2][guiField]
			if func == nil then
				func = t[2][field]
			end
		end
		superpath = del(superpath)
	end
	t = del(t)

	if type(func) == "string" and not canBeString then
		if getType then
			return "string", "method"
		end
		if type(handler) ~= "table" then
			local _, ret = pcall(error, ("%s: Handler not given for method %q for `%s'."):format(MAJOR_VERSION, func, getPathString(path)))
			geterrorhandler()(ret)
			return nil
		end
		local negate = false
		local handler_func = handler[func]
		if type(handler_func) ~= "function" then
			local realFunc = func:match("^~(.*)$")
			if not realFunc then
				local _, ret = pcall(error, ("%s: Unknown method %q for `%s'."):format(MAJOR_VERSION, func, getPathString(path)))
				geterrorhandler()(ret)
				return nil
			end
			negate = true
			handler_func = handler[realFunc]
			if type(handler_func) ~= "function" then
				local _, ret = pcall(error, ("%s: Unknown method %q for `%s'."):format(MAJOR_VERSION, realFunc, getPathString(path)))
				geterrorhandler()(ret)
				return nil
			end
		end
		
		local tmpPath = newList()
		for i = 1, #path-1 do
			tmpPath[i*2 - 1] = path[i]
			tmpPath[i*2] = 'args'
		end
		tmpPath[#tmpPath+1] = path[#path]
		tmpPath[#tmpPath+1] = field
		local tmp = getCachedPath(tmpPath)
		if not tmp then
			tmp = newList(pcall(handler_func, handler, getPassValues(path)))
			if not tmp[1] then
				geterrorhandler()(tmp[2])
				tmp = del(tmp)
				tmpPath = del(tmpPath)
				return nil
			end
		
			transformReturnTable(tmpPath, tmp)
		end
		tmpPath = del(tmpPath)
		if not dontTransform then
			transformConfigField(path, field, canBeString, optional, typecheck, tmp)
		end

		if negate then
			tmp[2] = not tmp[2]
			for i = 3, #tmp do
				tmp[i] = nil
			end
		end

		local value = tmp[2]
		if optional and value == nil then
			if optional ~= true then
				tmp = del(tmp)
				return optional
			end
		elseif typecheck then
			local types = newSet((";"):split(typecheck))
			local type_value = type(value)
			if not types[type_value] then
				if types["boolean"] and (type_value == "nil" or value == 1) then
					-- pass
				elseif (types["dict"] or types["set"] or types["list"]) and type_value == "table" then
					-- pass
				else
					local t = newList()
					for k in pairs(types) do
						t[#t+1] = ("%q"):format(k)
					end
					local s = table_concat(t, ", ")
					t = del(t)
					local _, ret = pcall(error, ("%s: Bad return from method %q for `%s'. Expected %s, got %q (%s)."):format(MAJOR_VERSION, func, getPathString(path), s, type_value, toliteral(value)))
					geterrorhandler()(ret)
				end
			end
			types = del(types)
		end
		return unpackListAndDel(tmp, 2, #tmp)
	elseif type(func) == "function" then
		if getType then
			return "function"
		end
		
		local tmpPath = newList()
		for i = 1, #path-1 do
			tmpPath[i*2 - 1] = path[i]
			tmpPath[i*2] = 'args'
		end
		tmpPath[#tmpPath+1] = path[#path]
		tmpPath[#tmpPath+1] = field
		local tmp = getCachedPath(tmpPath)
		if not tmp then
			tmp = newList(pcall(func, getPassValues(path)))
			if not tmp[1] then
				geterrorhandler()(tmp[2])
				tmp = del(tmp)
				tmpPath = del(tmpPath)
				return nil
			end

			transformReturnTable(tmpPath, tmp)
		end
		tmpPath = del(tmpPath)
		if not dontTransform then
			transformConfigField(path, field, canBeString, optional, typecheck, tmp)
		end

		local value = tmp[2]
		if optional and value == nil then
			if optional ~= true then
				tmp = del(tmp)
				return optional
			end
		elseif typecheck then
			local types = newSet((";"):split(typecheck))
			local type_value = type(value)
			if not types[type_value] then
				if types["boolean"] and (type_value == "nil" or value == 1) then
					-- pass
				elseif (types["dict"] or types["set"] or types["list"]) and type_value == "table" then
					-- pass
				else
					local t = newList()
					for k in pairs(types) do
						t[#t+1] = ("%q"):format(tostring(k))
					end
					local s = table_concat(t, ", ")
					t = del(t)
					local _, ret = pcall(error, ("%s: Bad return from function %q for `%s'. Expected %s, got %q (%s)."):format(MAJOR_VERSION, field, getPathString(path), s, type_value, toliteral(value)))
					geterrorhandler()(ret)
				end
			end
			types = del(types)
		end
		return unpackListAndDel(tmp, 2, #tmp)
	else
		if getType then
			return type(func)
		end
		if not dontTransform then
			local tmp = newList(true, func)
			transformConfigField(path, field, canBeString, optional, typecheck, tmp)
			func = tmp[2]
			tmp = del(tmp)
		end
		if func == nil then
			if not optional then
				local _, ret = pcall(error, ("%s: Field %q not found for `%s'."):format(MAJOR_VERSION, field, getPathString(path)))
				geterrorhandler()(ret)
				return nil
			elseif optional ~= true then
				return optional
			else
				return func
			end
		end
		if typecheck then
			local types = newSet((";"):split(typecheck))
			local type_func = type(func)
			if not types[type_func] then
				if types["boolean"] and (type_func == "nil" or value == 1) then
					-- pass
				elseif (types["dict"] or types["set"] or types["list"]) and type_func == "table" then
					-- pass
				else
					local t = newList()
					for k in pairs(types) do
						t[#t+1] = ("%q"):format(tostring(k))
					end
					local s = table_concat(t, ", ")
					t = del(t)
					local _, ret = pcall(error, ("%s: Bad value for field %q for `%s'. Expected %s, got %q (%s)."):format(MAJOR_VERSION, field, getPathString(path), s, type_func, toliteral(func)))
					geterrorhandler()(ret)
				end
			end
			types = del(types)
		end
		return func
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* This calls a function or method on the configTable of the given path.
Arguments:
	table - a list of the current path
	string - the name of the field we're looking at
	[optional] table - A list of values that are to be passed in.
	[optional] boolean - if set to true, if the function does not exist, no error is raised.
Returns:
	success, ret
	boolean - whether the function executed properly, without errors.
	tuple - results from the function call.
Example:
	callConfigField(path, 'set', { 1, 1, 0, 1 }) -- passes four values along, not just 1
	callConfigField(path, 'set', { "text" }) -- passes along text.
	local success, ret = callConfigField(path, 'get', { key }) -- used in multichoice
-----------------------------------------------------------------------------]]
local function callConfigField(path, field, values, optional)
	local guiField = "gui" .. field:sub(1, 1):upper() .. field:sub(2)
	local t = newList(getConfigTable(path))

	if #t == 0 then
		t = del(t)
		local _, ret = pcall(error, ("%s: Cannot find path `%s'."):format(MAJOR_VERSION, getPathString(path)))
		geterrorhandler()(ret)
		return nil
	end

	local func
	local handler = path[1]
	for i = #t, 1, -1 do
		local configTable = t[i]
		local f = configTable[("child_"):rep(i-1) .. guiField]
		if f == nil then
			f = configTable[("child_"):rep(i-1) .. field]
		end
		if f ~= nil then
			func = f
		end
		local h = configTable.handler
		if h ~= nil then
			handler = h
		end
	end

	local configTable = t[1]

	if func == nil and field ~= 'pass' and #path > 1 then
		local superpath = newList(unpack(path, 1, #path-1))
		local pass = getConfigField(superpath, 'pass', false, true)
		if pass then
			func = t[2][guiField]
			if func == nil then
				func = t[2][field]
			end
		end
		superpath = del(superpath)
	end

	t = del(t)

	if type(func) == "string" then
		if type(handler) ~= "table" then
			local _, ret = pcall(error, ("%s: Handler not given for method %q for `%s'."):format(MAJOR_VERSION, func, getPathString(path)))
			geterrorhandler()(ret)
			return nil
		end

		local negate = false
		local handler_func = handler[func]
		if type(handler_func) ~= "function" then
			local realFunc = func:match("^~(.*)$")
			if not realFunc then
				local _, ret = pcall(error, ("%s: Unknown method %q for `%s'."):format(MAJOR_VERSION, func, getPathString(path)))
				geterrorhandler()(ret)
				return nil
			end
			negate = true
			handler_func = handler[realFunc]
			if type(handler_func) ~= "function" then
				local _, ret = pcall(error, ("%s: Unknown method %q for `%s'."):format(MAJOR_VERSION, realFunc, getPathString(path)))
				geterrorhandler()(ret)
				return nil
			end
		end
		
		local tmpPath = newList()
		for i = 1, #path-1 do
			tmpPath[i*2 - 1] = path[i]
			tmpPath[i*2] = 'args'
		end
		tmpPath[#tmpPath+1] = path[#path]
		tmpPath[#tmpPath+1] = field
		local tmp = getCachedPath(tmpPath)
		if not tmp then
			tmp = newList(pcall(handler_func, handler, getPassValues(path, values)))
			if not tmp[1] then
				geterrorhandler()(tmp[2])
				tmp = del(tmp)
				tmpPath = del(tmpPath)
				return nil
			end

			transformReturnTable(tmpPath, tmp)
		end
		tmpPath = del(tmpPath)

		if negate then
			tmp[2] = not tmp[2]
			for i = 3, #tmp do
				tmp[i] = nil
			end
		end

		return true, unpackListAndDel(tmp, 2, #tmp)
	elseif type(func) == "function" then	
		local tmpPath = newList()
		for i = 1, #path-1 do
			tmpPath[i*2 - 1] = path[i]
			tmpPath[i*2] = 'args'
		end
		tmpPath[#tmpPath+1] = path[#path]
		tmpPath[#tmpPath+1] = field
		local tmp = getCachedPath(tmpPath)
		if not tmp then
			tmp = newList(pcall(func, getPassValues(path, values)))
			if not tmp[1] then
				geterrorhandler()(tmp[2])
				tmp = del(tmp)
				tmpPath = del(tmpPath)
				return nil
			end

			transformReturnTable(tmpPath, tmp)
		end
		tmpPath = del(tmpPath)

		return true, unpackListAndDel(tmp, 2, #tmp)
	else
		if not optional then
			local _, ret = pcall(error, ("%s: Field %q not found for `%s'."):format(MAJOR_VERSION, field, getPathString(path)))
			geterrorhandler()(ret)
			return nil
		end
		return nil, true
	end
end

local removeSections

local mainPane_Reposition

if oldLib and oldLib.base then
	oldLib.base:Hide()
	oldLib.base:UnregisterAllEvents()
end

local function recheckThirdPartyOptions()
	local list = newList()
	local AceConsole = Rock("AceConsole-2.0", true, true)
	if AceConsole then
		for k,v in pairs(AceConsole.registry) do
			list[v] = true
		end
	end
	local FuBarPlugin20 = Rock("FuBarPlugin-2.0", true, true)
	if FuBarPlugin20 and FuBarPlugin20.registry then
		for k in pairs(FuBarPlugin20.registry) do
			if type(k) == "table" and k.OnMenuRequest then
				list[k.OnMenuRequest] = true
			end
		end
	end
	for k in pairs(list) do
		if type(k) == "table" and k.type == 'group' and type(k.args) == "table" and k.handler and not data[k.handler] then
			local addonName = k.handler.name
			if not k.name or k.name == "" then
				k.name = addonName
			end
			if k.name ~= "Niagara" and k.name ~= "DeuceCommander" then
				if not k.desc or k.desc == "" then
					if not k.handler.notes or k.handler.notes == "" then
						k.desc = addonName
					else
						k.desc = k.handler.notes
					end
				end
				if not k.icon and (k.handler.hasIcon or k.handler.icon) then
					if type(k.handler.hasIcon) == "string" then
						k.icon = k.handler.hasIcon
					elseif type(k.handler.icon) == "string" then
						k.icon = k.handler.icon
					end
				end
			end
		else
			list[k] = nil
		end
	end
	for k in pairs(list) do
		local good = true
		for l in pairs(list) do
			if k ~= l then
				for m,n in pairs(l.args) do
					if n == k then
						good = false
						break
					end
				end
				if not good then
					break
				end
			end
		end
		if good then
			for _,l in pairs(data) do
				if type(l.args) == "table" then
					for m,n in pairs(l.args) do
						if n == k then
							good = false
							break
						end
					end
					if not good then
						break
					end
				end
			end
		end
		if good and not data[k.handler] then
			RockConfig.SetConfigTable(k.handler, k)
		end
		list[k] = nil
	end
	list = del(list)

	if base.treeView then
		RockConfig:RefreshConfigMenu(false)
	end
end

local function base_OnEvent(base, event)
	if event == "ADDON_LOADED" then
		recheckThirdPartyOptions()
	elseif event == "PLAYER_REGEN_DISABLED" then
		if RockConfig.hideInCombat then
			base:Hide()
		end
	end
end

local function recalculateSavedPosition()
	if not base then
		return
	end
	local x, y = base:GetCenter()
	x = x - GetScreenWidth()/2/base:GetScale()
	y = y - GetScreenHeight()/2/base:GetScale()
	base:ClearAllPoints()
	base:SetPoint("CENTER", UIParent, "CENTER", x, y)
	local width, height = base:GetWidth(), base:GetHeight()
	RockConfig.x = x
	RockConfig.y = y
	RockConfig.width = width
	RockConfig.height = height
end

local pullout -- choice pullout

local strataList = {}
local function makeBackground(frame)
	if not frame then
		frame = base
	end
	strataList[frame] = true
	frame:SetFrameStrata("BACKGROUND")
	local t = newList(frame:GetChildren())
	for i,v in ipairs(t) do
		makeBackground(v)
	end
	t = del(t)
end
local function makeForeground()
	for k in pairs(strataList) do
		k:SetFrameStrata("FULLSCREEN_DIALOG")
		strataList[k] = nil
	end
end

-- bubble up OnEnter
local function SubControl_OnEnter(this, ...)
	local parent = this:GetParent()
	if not parent or parent == base then
		return
	end
	local OnEnter = parent:GetScript("OnEnter")
	if OnEnter then
		return OnEnter(parent, ...)
	end
	return SubControl_OnEnter(this, ...)
end

-- bubble up OnLeave
local function SubControl_OnLeave(this, ...)
	local parent = this:GetParent()
	if not parent or parent == base then
		return
	end
	local OnLeave = parent:GetScript("OnLeave")
	if OnLeave then
		return OnLeave(parent, ...)
	end
	return SubControl_OnLeave(this, ...)
end

-- create the pullout frame, only called once.
local function makePullout()
	makePullout = nil
	local mainPane = base.mainPane
	pullout = CreateFrame("Frame", mainPane:GetName() .. "_ChoicePullout", mainPane)
	pullout:SetFrameLevel(20)
	local bg = newList()
	bg.bgFile = [[Interface\Buttons\WHITE8X8]]
	bg.edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]]
	bg.tile = true
	bg.edgeSize = 16
	bg.tileSize = 16
	bg.insets = newList()
	bg.insets.left = 3
	bg.insets.right = 3
	bg.insets.top = 3
	bg.insets.bottom = 3
	pullout:SetBackdrop(bg)
	bg.insets = del(bg.insets)
	bg = del(bg)
	pullout:SetBackdropColor(0, 0, 0)
	pullout:SetFrameStrata("FULLSCREEN_DIALOG")
	pullout:SetFrameLevel(20)
	pullout:EnableMouseWheel(true)
	pullout:SetScript("OnMouseWheel", function(this, up)
		if up < 0 then
			local bottom = this:GetBottom()
			if bottom < 0 then
				for i = 1, this:GetNumPoints() do
					local point, frame, relpoint, xdiff, ydiff = this:GetPoint(i)
					if point == "TOP" then
						local y = math.min(17, -bottom)
						this:SetPoint(point, frame, relpoint, xdiff, ydiff + y)
					end
				end
			end
		else
			local top = this:GetTop()
			local screenHeight = GetScreenHeight()
			if top > screenHeight then
				for i = 1, this:GetNumPoints() do
					local point, frame, relpoint, xdiff, ydiff = this:GetPoint(i)
					if point == "TOP" then
						local y = math.min(17, top - screenHeight)
						this:SetPoint(point, frame, relpoint, xdiff, ydiff - y)
					end
				end
			end
		end
	end)
	pullout:Hide()
end

local buildPullout

-- when a line is clicked, set the value, update
local function Dropdown_LineClicked(this)
	local parent = this:GetParent().parent
	if parent == base.addonChooser then
		if parent.value == this.value then
			return
		end
		this:GetParent():Hide()
		parent:Select(this.value)
		return
	elseif parent.isMulti then
		local value = not this.check:IsShown() or this.check.half
		local t = newList(this.value, not not value)
		callConfigField(parent, 'set', t)
		t = del(t)
	else
		if parent.value == this.value then
			return
		end
		local t = newList(this.value)
		callConfigField(parent, 'set', t)
		t = del(t)
	end

	refreshConfigMenu(parent[1])
end

-- if using radio buttons, show the highlight
local function Dropdown_LineEnter(this)
	local pullout = this:GetParent()
	if not pullout.parent.isMulti then
		this.checkHighlight:Show()
	end
	_G.GameTooltip_SetDefaultAnchor(GameTooltip, this)

	local name, desc
	if pullout.parent ~= base.addonChooser then
		local choiceDescs = getConfigField(pullout.parent, 'choiceDescs', false, true, "table")
		if not choiceDescs then
			desc = this.text:GetText()
			name = this:GetParent().parent.label.text:GetText()
		else
			name = this.text:GetText()
			desc = choiceDescs[this.value]
		end
	else
		name = this.text:GetText()
		local t = newList(this.value)
		desc = getConfigField(t, 'desc', true, false, "string")
		t = del(t)
	end
	GameTooltip:SetText(name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	if name ~= desc and desc then
		GameTooltip:AddLine(desc, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
	end
	GameTooltip:Show()
end

-- if using radio buttons, hide the highlight
local function Dropdown_LineLeave(this)
	if not this:GetParent().parent.isMulti then
		this.checkHighlight:Hide()
	end

	GameTooltip:Hide()
end

-- fetch or create a button on the pullout
local function getPulloutButton(num)
	local button = pullout[num]
	if button then
		button:Show()

		return button
	end
	button = CreateFrame("Button", pullout:GetName() .. "_Button" .. num, pullout)
	pullout[num] = button
	button:SetHeight(17)
	button:SetPoint("LEFT", pullout, "LEFT", 6, 0)
	button:SetPoint("RIGHT", pullout, "RIGHT", -6, 0)

	local text = button:CreateFontString(button:GetName() .. "_Text", "OVERLAY", "GameFontHighlightSmall")
	button.text = text
	text:SetJustifyH("LEFT")
	button:SetFontString(text)

	local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY")
	button.highlight = highlight
	highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	highlight:SetVertexColor(1, 1, 1, 0.5)
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(button)
	button:SetHighlightTexture(highlight)

	local check = button:CreateTexture("OVERLAY")
	button.check = check
	check:SetWidth(16)
	check:SetHeight(16)
	check:SetPoint("LEFT", button, "LEFT", 0, 0)
	check:SetTexture([[Interface\Buttons\UI-RadioButton]])
	check:SetTexCoord(0, 0.25, 0, 1)

	-- highlight for radio buttons only
	local checkHighlight = button:CreateTexture("OVERLAY")
	button.checkHighlight = checkHighlight
	checkHighlight:SetAllPoints(check)
	checkHighlight:SetTexture([[Interface\Buttons\UI-RadioButton]])
	checkHighlight:SetBlendMode("ADD")
	checkHighlight:SetTexCoord(0.5, 0.75, 0, 1)
	checkHighlight:Hide()

	local icon = button:CreateTexture(button:GetName() .. "_Icon", "ARTWORK")
	button.icon = icon
	icon:SetWidth(epsilon)
	icon:SetHeight(16)
	icon:SetPoint("LEFT", check, "RIGHT", 0, 0)

	text:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	text:SetPoint("TOP", button, "TOP", 0, 0)
	text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

	local texture = button:CreateTexture(button:GetName() .. "_Texture", "ARTWORK")
	button.texture = texture
	texture:SetVertexColor(1, 1, 1, 0.5)
	texture:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	texture:SetPoint("RIGHT", button, "RIGHT", -1, 0)
	texture:SetPoint("TOP", button, "TOP", 0, -1)
	texture:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)

	button:SetScript("OnClick", Dropdown_LineClicked)
	button:SetScript("OnEnter", Dropdown_LineEnter)
	button:SetScript("OnLeave", Dropdown_LineLeave)

	return button
end

local choiceSort__choices
-- sort choices alphabetically
local function choiceSort(alpha, bravo)
	local alpha_v, bravo_v = choiceSort__choices[alpha], choiceSort__choices[bravo]
	local type_alpha_v = type(alpha_v)
	local type_bravo_v = type(bravo_v)
	if type_alpha_v ~= type_bravo_v then
		return type_alpha_v < type_bravo_v
	end
	if type_alpha_v == "string" then
		return alpha_v:lower() < bravo_v:lower()
	elseif type_alpha_v == "number" then
		return alpha_v < bravo_v
	elseif type_alpha_v == "boolean" then
		return not alpha_v
	else
		return tostring(alpha_v) < tostring(bravo_v)
	end
end

local function isList(choices)
	local n = #choices
	if n == 0 then
		return false
	end
	for k,v in pairs(choices) do
		if type(k) ~= "number" or k <= 0 or k > n then
			return false
		end
	end
	return true
end

-- build the pullout's buttons based on the control
function buildPullout(this)
	for i,v in ipairs(pullout) do
		pullout[i]:Hide()
	end

	local isAddonChooser = this == base.addonChooser

	local choices, choiceType, choiceOrder
	if not isAddonChooser then
		choices = getConfigField(this, 'choices', false, false, "table")
		choiceType = getConfigField(this, 'choiceType', true, isList(choices) and "list" or "dict", "string")
		if choiceType == "dict" then
			choiceOrder = getConfigField(this, 'choiceOrder', false, true, "table")
		end
	end

	local choiceIcons, choiceIconTexCoords, choiceFonts, choiceTextures

	local keys = newList()
	if isAddonChooser then
		choices = newList()
		choiceIcons = newList()
		for k,v in pairs(data) do
			keys[#keys + 1] = k
			local t = newList(k)
			choices[k] = getConfigField(t, 'name', true, false, "string")
			choiceIcons[k] = getConfigField(t, 'icon', true, true, "string")
			t = del(t)
		end
		
		choiceSort__choices = choices
		table_sort(keys, choiceSort)
		choiceSort__choices = nil
		choiceType = "dict"
	else
		if choiceType == "dict" then
			if choiceOrder then
				for i,k in ipairs(choiceOrder) do
					keys[#keys+1] = k
				end
			else
				for k,v in pairs(choices) do
					keys[#keys+1] = k
				end
				choiceSort__choices = choices
				table_sort(keys, choiceSort)
				choiceSort__choices = nil
			end
		else
			for i,v in ipairs(choices) do
				keys[#keys+1] = v
			end
		end

		choiceIcons = getConfigField(this, 'choiceIcons', false, true, "table")
		choiceIconTexCoords = getConfigField(this, 'choiceIconTexCoords', false, true, "table")
		choiceFonts = getConfigField(this, 'choiceFonts', false, true, "table")
		choiceTextures = getConfigField(this, 'choiceTextures', false, true, "table")
	end

	local totalHeight = 10 -- 5 on the top and bottom
	local isMulti = not isAddonChooser and this.isMulti
	local value = isMulti and this.values or this.value
	local last = pullout
	for i,k in ipairs(keys) do
		local button = getPulloutButton(i)
		if choiceType == "dict" then
			button.text:SetText(choices[k])
		else
			button.text:SetText(k)
		end
		if choiceIcons then
			button.icon:SetWidth(16)
			local icon = choiceIcons[k]
			button.icon:SetTexture(icon)
			local texCoord = choiceIconTexCoords and choiceIconTexCoords[k]
			if texCoord then
				button.icon:SetTexCoord(unpack(texCoord))
			else
				if icon and icon:find([[^Interface\Icons\]]) then
					button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				else
					button.icon:SetTexCoord(0, 1, 0, 1)
				end
			end
		else
			button.icon:SetWidth(epsilon)
			button.icon:SetTexture(nil)
		end
		if choiceTextures then
			button.texture:SetTexture(choiceTextures[k])
		else
			button.texture:SetTexture(nil)
		end
		if choiceFonts and choiceFonts[k] then
			local _, size, flags = GameFontHighlightSmall:GetFont()
			button.text:SetFont(choiceFonts[k], size, flags)
		else
			button.text:SetFont(GameFontHighlightSmall:GetFont())
		end
		if last == pullout then
			button:SetPoint("TOP", pullout, "TOP", 0, -5)
		else
			button:SetPoint("TOP", last, "BOTTOM", 0, 0)
		end

		SetDesaturation(button.check, false)
		button.check.half = nil
		if isMulti then
			button.check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
			button.check:SetTexCoord(0, 1, 0, 1)
			if value[k] then
				button.check:Show()
				if value[k] == "HALF" then
					button.check.half = true
					SetDesaturation(button.check, true)
				end
			else
				button.check:Hide()
			end
		else
			button.check:SetTexture([[Interface\Buttons\UI-RadioButton]])
			button.check:Show()
			if value == k then
				-- shows full radio
				button.check:SetTexCoord(0.25, 0.5, 0, 1)
			else
				-- shows empty radio
				button.check:SetTexCoord(0, 0.25, 0, 1)
			end
		end
		button.value = k
		totalHeight = totalHeight + button:GetHeight()
		last = button
	end
	if isAddonChooser then
		choices = del(choices)
		choiceIcons = del(choiceIcons)
	end
	pullout:SetHeight(totalHeight)
end

local nextFreeScroll = 0

--[[---------------------------------------------------------------------------
Notes:
	* Creates the config menu frame
	* This is called only once.
-----------------------------------------------------------------------------]]
function createBase()
	createBase = nil
	base = CreateFrame("Frame", MAJOR_VERSION .. "_Frame", UIParent)
	RockConfig.base = base
	base:RegisterEvent("ADDON_LOADED")
	base:RegisterEvent("PLAYER_REGEN_DISABLED")
	base:SetScript("OnEvent", base_OnEvent)
	local currentAlpha = 1
	local hasEntered = false
	local isDragging = false
	local function inFocus()
		local frame = GetMouseFocus()
		if frame == WorldFrame or frame == UIParent or not frame or frame == base then
			return true
		end
		while true do
			frame = frame:GetParent()
			if frame == base then
				return true
			elseif frame == UIParent or not frame then
				return false
			end
		end
	end
	base:SetScript("OnUpdate", function(this, elapsed)
		local maxAlpha = RockConfig.maxAlpha
		local minAlpha = RockConfig.minAlpha
		if not maxAlpha then
			maxAlpha = 1
			RockConfig.maxAlpha = maxAlpha
		end
		if not minAlpha then
			minAlpha = 0.25
			RockConfig.minAlpha = minAlpha
		end
		if ((MouseIsOver(this) or pullout and pullout:IsShown() and MouseIsOver(pullout)) and inFocus()) or isDragging then
			hasEntered = true
			if currentAlpha < maxAlpha then
				currentAlpha = currentAlpha + elapsed/((maxAlpha - minAlpha)/5)
			end
			if currentAlpha >= maxAlpha then
				currentAlpha = maxAlpha
			end
			if next(strataList) then
				makeForeground()
			end
		elseif hasEntered then
			if currentAlpha > minAlpha then
				currentAlpha = currentAlpha - elapsed/((maxAlpha - minAlpha)/5)
			end
			if currentAlpha <= minAlpha then
				currentAlpha = minAlpha
				if not next(strataList) then
					makeBackground()
				end
			end
		end
		this:SetAlpha(currentAlpha)
	end)
	recheckThirdPartyOptions()
	do
		base:Hide()
		local x = RockConfig.x or 0
		local y = RockConfig.y or 0
		local width = RockConfig.width or GetScreenWidth()*3/5
		local height = RockConfig.height or GetScreenHeight()*3/5
		base:SetWidth(width)
		base:SetHeight(height)
		base:SetPoint("CENTER", UIParent, "CENTER", x, y)
		base:SetScale(RockConfig.scale or 1)
		base:EnableMouse(true)
		base:SetMovable(true)
		base:SetResizable(true)
		base:SetMinResize(600, 300)
		base:SetFrameLevel(1)
		base:SetFrameStrata("FULLSCREEN_DIALOG")

		local bg = newDict(
			'bgFile', [[Interface\DialogFrame\UI-DialogBox-Background]],
			'edgeFile', [[Interface\DialogFrame\UI-DialogBox-Border]],
			'tile', true,
			'tileSize', 32,
			'edgeSize', 32,
			'insets', newDict(
				'left', 5,
				'right', 6,
				'top', 5,
				'bottom', 6
			)
		)
		base:SetBackdrop(bg)
		bg.insets = del(bg.insets)
		bg = del(bg)
		base:SetBackdropColor(0, 0, 0)
		base:SetClampedToScreen(true)

		local header = CreateFrame("Frame", base:GetName() .. "_Header", base)
		base.header = header
		header:SetHeight(34.56)
		header:SetClampedToScreen(true)
		local left = header:CreateTexture(header:GetName() .. "_TextureLeft", "ARTWORK")
		header.left = left
		left:SetPoint("TOPLEFT")
		left:SetPoint("BOTTOMLEFT")
		left:SetWidth(11.54)
		left:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
		left:SetTexCoord(0.235, 0.28, 0.04, 0.58)
		local right = header:CreateTexture(header:GetName() .. "_TextureRight", "ARTWORK")
		header.right = right
		right:SetPoint("TOPRIGHT")
		right:SetPoint("BOTTOMRIGHT")
		right:SetWidth(11.54)
		right:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
		right:SetTexCoord(0.715, 0.76, 0.04, 0.58)
		local center = header:CreateTexture(header:GetName() .. "_TextureCenter", "ARTWORK")
		header.center = center
		center:SetPoint("TOPLEFT", left, "TOPRIGHT")
		center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
		center:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
		center:SetTexCoord(0.28, 0.715, 0.04, 0.58)

		local closeButton = CreateFrame("Button", base:GetName() .. "_CloseButton", base, "UIPanelCloseButton")
		base.closeButton = closeButton
		closeButton:SetFrameLevel(5)
		closeButton:SetScript("OnClick", function(this)
			this:GetParent():Hide()
		end)
		closeButton:SetPoint("TOPRIGHT", base, "TOPRIGHT", -5, -5)

		base:SetScript("OnHide", function(this)
			makeForeground()
			saveState()
			removeSections(base.treeView)
			currentAlpha = 1
			hasEntered = false
		end)

		header:EnableMouse(true)
		header:RegisterForDrag("LeftButton")
		header:SetScript("OnDragStart", function(this)
			isDragging = true
			this:GetParent():StartMoving()
		end)
		header:SetScript("OnDragStop", function(this)
			isDragging = false
			this:GetParent():StopMovingOrSizing()
			recalculateSavedPosition()
		end)

		local titleText = header:CreateFontString(header:GetName() .. "_FontString", "OVERLAY", "GameFontNormal")
		base.titleText = titleText
		titleText:SetText('-----')
		titleText:SetPoint("CENTER", base, "TOP", 0, -8)
		titleText:SetHeight(26)
		titleText:SetShadowColor(0, 0, 0)
		titleText:SetShadowOffset(1, -1)

		header:SetPoint("LEFT", titleText, "LEFT", -32, 0)
		header:SetPoint("RIGHT", titleText, "RIGHT", 32, 0)

		local sizer_se = CreateFrame("Frame", base:GetName() .. "_SizerSoutheast", base)
		base.sizer_se = sizer_se
		sizer_se:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", 0, 0)
		sizer_se:SetWidth(25)
		sizer_se:SetHeight(25)
		sizer_se:EnableMouse(true)
		sizer_se:RegisterForDrag("LeftButton")
		sizer_se:SetScript("OnDragStart", function(this)
			isDragging = true
			this:GetParent():StartSizing("BOTTOMRIGHT")
		end)
		sizer_se:SetScript("OnDragStop", function(this)
			isDragging = false
			this:GetParent():StopMovingOrSizing()
			recalculateSavedPosition()
		end)
		local line1 = sizer_se:CreateTexture(sizer_se:GetName() .. "_Line1", "BACKGROUND")
		line1:SetWidth(14)
		line1:SetHeight(14)
		line1:SetPoint("BOTTOMRIGHT", -10, 10)
		line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		local x = 0.1 * 14/17
		line1:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

		local line2 = sizer_se:CreateTexture(sizer_se:GetName() .. "_Line2", "BACKGROUND")
		line2:SetWidth(11)
		line2:SetHeight(11)
		line2:SetPoint("BOTTOMRIGHT", -10, 10)
		line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		local x = 0.1 * 11/17
		line2:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

		local line3 = sizer_se:CreateTexture(sizer_se:GetName() .. "_Line3", "BACKGROUND")
		line3:SetWidth(8)
		line3:SetHeight(8)
		line3:SetPoint("BOTTOMRIGHT", -10, 10)
		line3:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		local x = 0.1 * 8/17
		line3:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

		local sizer_s = CreateFrame("Frame", base:GetName() .. "_SizerSouth", base)
		base.sizer_s = sizer_s
		sizer_s:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", -25, 0)
		sizer_s:SetPoint("BOTTOMLEFT", base, "BOTTOMLEFT", 0, 0)
		sizer_s:SetHeight(25)
		sizer_s:EnableMouse(true)
		sizer_s:RegisterForDrag("LeftButton")
		sizer_s:SetScript("OnDragStart", function(this)
			isDragging = true
			this:GetParent():StartSizing("BOTTOM")
		end)
		sizer_s:SetScript("OnDragStop", function(this)
			isDragging = false
			this:GetParent():StopMovingOrSizing()
			recalculateSavedPosition()
		end)

		local sizer_e = CreateFrame("Frame", base:GetName() .. "_SizerEast", base)
		base.sizer_e = sizer_e
		sizer_e:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", 0, 25)
		sizer_e:SetPoint("TOPRIGHT", base, "TOPRIGHT", 0, 0)
		sizer_e:SetWidth(25)
		sizer_e:EnableMouse(true)
		sizer_e:RegisterForDrag("LeftButton")
		sizer_e:SetScript("OnDragStart", function(this)
			isDragging = true
			this:GetParent():StartSizing("RIGHT")
		end)
		sizer_e:SetScript("OnDragStop", function(this)
			isDragging = false
			this:GetParent():StopMovingOrSizing()
			recalculateSavedPosition()
		end)
	end

	-- tree view
	local treeView = CreateFrame("Frame", base:GetName() .. "_TreeView", base)
	do
		base.treeView = treeView
		treeView:SetPoint("LEFT", base, "LEFT", 14, 0)
		treeView:SetPoint("TOP", base, "TOP", 0, -33)
		treeView:SetPoint("BOTTOMLEFT", base, "BOTTOMLEFT", 14, 14)
		treeView:SetWidth(200)
		treeView:SetMinResize(120, 0)
		treeView:SetMaxResize(300, 10000)

		local scrollFrame = CreateFrame("ScrollFrame", treeView:GetName() .. "_ScrollFrame", treeView)
		local scrollChild = CreateFrame("Frame", scrollFrame:GetName() .. "_Frame", scrollFrame)
		local scrollBar = CreateFrame("Slider", scrollFrame:GetName() .. "_ScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
		local bg = newDict(
			'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
			'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
			'tile', true,
			'tileSize', 16,
			'edgeSize', 16,
			'insets', newDict(
				'left', 3,
				'right', 3,
				'top', 3,
				'bottom', 3
			)
		)
		treeView:SetBackdrop(bg)
		bg.insets = del(bg.insets)
		bg = del(bg)
		treeView:SetBackdropBorderColor(0.6, 0.6, 0.6)
		treeView:SetBackdropColor(0.1, 0.1, 0.1)
		treeView:SetScript("OnSizeChanged", function(this)
			this:Reposition()
		end)
		treeView:SetFrameLevel(2)
		treeView:SetFrameStrata("FULLSCREEN_DIALOG")
		treeView:SetResizable(true)

		treeView.scrollFrame = scrollFrame
		treeView.scrollChild = scrollChild
		treeView.scrollBar = scrollBar

		scrollFrame:SetScrollChild(scrollChild)
		scrollFrame:SetPoint("TOPLEFT", treeView, "TOPLEFT", 8, -12)
		scrollFrame:SetPoint("BOTTOMRIGHT", treeView, "BOTTOMRIGHT", -28, 12)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript("OnMouseWheel", function(this, change)
			local childHeight = scrollChild:CalculateHeight()
			local frameHeight = scrollFrame:GetHeight()
			if childHeight <= frameHeight then
				return
			end

			local diff = frameHeight - childHeight

			local delta = 1
			if change < 0 then
				delta = -1
			end

			local value = scrollBar:GetValue() + delta*(24/diff)
			if value < 0 then
				value = 0
			elseif value > 1 then
				value = 1
			end
			scrollBar:SetValue(value) -- will trigger OnValueChanged
		end)

		scrollChild:SetHeight(1)
		scrollChild:SetWidth(1)

		function scrollChild:CalculateHeight()
			local top = self:GetTop()
			if not top then
				return 0
			end

			local current = treeView

			local bottom = top

			local sections = current.sections
			while sections do
				local section
				for i,v in ipairs(sections) do
					local b = v:GetBottom()
					if b and b < bottom then
						bottom = b
						section = v
					end
				end
				if not section then
					break
				end
				current = section
				sections = current.sections
			end

			return top - bottom
		end

		scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -16)
		scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 16)
		scrollBar:SetMinMaxValues(0, 1)
		scrollBar:SetValueStep(epsilon)
		scrollBar:SetValue(0)
		scrollBar:SetWidth(16)
		scrollBar:SetScript("OnValueChanged", function(this)
			local max = scrollChild:CalculateHeight() - scrollFrame:GetHeight()

			local val = scrollBar:GetValue() * max

			if math_abs(scrollFrame:GetVerticalScroll() - val) < 1 then
				return
			end

			scrollFrame:SetVerticalScroll(val)
		end)
		scrollBar:EnableMouseWheel(true)
		scrollBar:SetScript("OnMouseWheel", function(this, ...)
			scrollFrame:GetScript("OnMouseWheel")(scrollFrame, ...)
		end)

		local function reposition(sections, last, depth)
			if not sections then
				return last
			end
			for i,v in ipairs(sections) do
				v:ClearAllPoints()
				v:SetPoint("LEFT", scrollFrame, "LEFT", depth*16, 0)
				v:SetPoint("RIGHT", scrollFrame, "RIGHT")
				if not last then
					v:SetPoint("TOP", scrollChild, "TOP")
				else
					v:SetPoint("TOP", last, "BOTTOM")
				end
				last = v
				if v.sections then
					last = reposition(v.sections, last, depth+1)
				end
			end
			return last
		end

		local function treeView_OnUpdate(this)
			this:SetScript("OnUpdate", nil)
			this:Reposition()
		end
		treeView:SetScript("OnUpdate", treeView_OnUpdate)

		local switch = false
		function treeView:Reposition()
			if not switch then
				treeView:SetScript("OnUpdate", treeView_OnUpdate)
			end
			switch = not switch
			reposition(self.sections, nil, 0)

			local height = scrollChild:CalculateHeight()

			if height == 0 then
				treeView:SetScript("OnUpdate", treeView_OnUpdate)
				return
			end
			if height < scrollFrame:GetHeight() then
				scrollBar:Hide()
				scrollFrame:SetPoint("BOTTOMRIGHT", treeView, "BOTTOMRIGHT", -8, 12)
				scrollBar:SetValue(0)
				scrollFrame:SetVerticalScroll(0)
			else
				scrollBar:Show()
				scrollFrame:SetPoint("BOTTOMRIGHT", treeView, "BOTTOMRIGHT", -28, 12)
			end
		end
	end

	local addonChooser = CreateFrame("Frame", base:GetName() .. "_AddonChooser", base)
	do
		base.addonChooser = addonChooser
		addonChooser:SetPoint("LEFT", base, "LEFT", 14, 0)
		addonChooser:SetPoint("TOP", base, "TOP", 0, -16)
		addonChooser:SetPoint("BOTTOM", treeView, "TOP", 0, 0)
		addonChooser:SetPoint("RIGHT", treeView, "RIGHT", 0, 0)

		addonChooser:SetScript("OnEnter", function(this)
			-- show tooltip about choosing addons
		end)
		addonChooser:SetScript("OnLeave", function(this)
			GameTooltip:Hide()
		end)

		local text = CreateFrame("Button", addonChooser:GetName() .. "_Text", addonChooser)
		addonChooser.text = text
		local fs = text:CreateFontString(text:GetName() .. "_FontString", "OVERLAY", "ChatFontNormal")
		text.fs = fs
		fs:SetJustifyH("LEFT")
		text:SetHeight(24)
		text:SetScript("OnEnter", SubControl_OnEnter)
		text:SetScript("OnLeave", SubControl_OnLeave)
		local bg = newDict(
			'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
			'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
			'tile', true,
			'tileSize', 16,
			'edgeSize', 16,
			'insets', newDict(
				'left', 3,
				'right', 3,
				'top', 3,
				'bottom', 3
			)
		)
		text:SetBackdrop(bg)
		bg.insets = del(bg.insets)
		bg = del(bg)
		text:SetBackdropBorderColor(0.6, 0.6, 0.6)
		text:SetBackdropColor(0.1, 0.1, 0.1)

		local icon = text:CreateTexture(text:GetName() .. "_Icon", "ARTWORK")
		text.icon = icon
		icon:SetWidth(16)
		icon:SetHeight(16)
		icon:SetPoint("LEFT", 5, 0)
		fs:SetPoint("LEFT", icon, "RIGHT", 0, 0)
		fs:SetPoint("RIGHT", -5, 0)

		text:SetPoint("LEFT")

		local button = CreateFrame("Button", addonChooser:GetName() .. "_Button", addonChooser)
		addonChooser.button = button
		text:SetPoint("RIGHT", button, "LEFT")
		button:SetWidth(24)
		button:SetHeight(24)
		button:SetScript("OnEnter", SubControl_OnEnter)
		button:SetScript("OnLeave", SubControl_OnLeave)
		button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
		button:GetNormalTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
		button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
		button:GetPushedTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
		button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
		button:GetDisabledTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
		button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		button:GetHighlightTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
		button:SetPoint("RIGHT")
		button:SetScript("OnClick", function(this, arg1)
			SetButtonPulse(this, 0, 1)
			if makePullout then
				makePullout()
			end
			local shown = pullout:IsShown()
			pullout:Hide()
			local parent = this:GetParent()
			if pullout.parent == parent and shown then
				-- click to hide after it's been opened
				return
			end
			pullout.parent = parent
			pullout:SetFrameStrata("FULLSCREEN_DIALOG")
			pullout:SetPoint("TOP", parent.text, "BOTTOM")
			pullout:SetPoint("LEFT", parent.text, "LEFT")
			pullout:SetPoint("RIGHT", parent.text, "RIGHT")
			pullout:Show()
			pullout:SetHeight(50)

			buildPullout(parent)
		end)

		text:EnableMouse(true)
		text:SetScript("OnClick", function(this, arg1)
			button:Click()
		end)

		local pulsed = false
		function addonChooser:Select(addon)
			if not data[addon] then
				return
			end
			if not pulsed and addon == RockConfig then
				SetButtonPulse(button, 60, 1)
			else
				SetButtonPulse(button, 0, 1)
			end
			pulsed = true

			self.value = addon

			local treeView = base.treeView
			removeSections(treeView)
			local addonPath = newList(addon)
			local name = getConfigField(addonPath, 'name', true, false, "string")
			self.text.fs:SetText(name)
			local icon = getConfigField(addonPath, 'icon', true, true, "string")
			self.text.icon:SetTexture(icon)
			if icon and icon:find([[^Interface\Icons]]) then
				self.text.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			else
				self.text.icon:SetTexCoord(0, 1, 0, 1)
			end
			getTreeLine(addonPath)
			addonPath = del(addonPath)

			local treeView_firstSection = treeView.sections[1]
			if treeView_firstSection then
				treeView_firstSection:Click()
			end

			treeView:Reposition()
		end
	end

	-- main pane
	local mainPane = CreateFrame("Frame", base:GetName() .. "_MainPane", base)
	do
		base.mainPane = mainPane

		local inFunc = nil
		local function paneOnSizeChanged(this)
			if inFunc then
				return
			end
			inFunc = true
			mainPane:Reposition()
			inFunc = nil
		end

		local bg = newDict(
			'bgFile', [[Interface\Tooltips\UI-Tooltip-Background]],
			'edgeFile', [[Interface\Tooltips\UI-Tooltip-Border]],
			'tile', true,
			'tileSize', 16,
			'edgeSize', 16,
			'insets', newDict(
				'left', 3,
				'right', 3,
				'top', 3,
				'bottom', 3
			)
		)
		mainPane:SetBackdrop(bg)
		bg.insets = del(bg.insets)
		bg = del(bg)
		mainPane:SetBackdropBorderColor(0.6, 0.6, 0.6)
		mainPane:SetBackdropColor(0.1, 0.1, 0.1)
		mainPane:SetFrameLevel(2)
		mainPane:SetFrameStrata("FULLSCREEN_DIALOG")
		mainPane:SetScript("OnSizeChanged", paneOnSizeChanged)

		local scrollFrame = CreateFrame("ScrollFrame", mainPane:GetName() .. "_ScrollFrame", mainPane)
		local scrollChild = CreateFrame("Frame", mainPane:GetName() .. "_ScrollChild", scrollFrame)
		local scrollBar = CreateFrame("Slider", mainPane:GetName() .. "_ScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
		mainPane.scrollFrame = scrollFrame
		mainPane.scrollChild = scrollChild
		mainPane.scrollBar = scrollBar

		scrollFrame:SetScrollChild(scrollChild)
		scrollFrame:SetPoint("TOPLEFT", mainPane, "TOPLEFT", 9, -9)
		scrollFrame:SetPoint("BOTTOMRIGHT", mainPane, "BOTTOMRIGHT", -28, 12)
		scrollFrame:EnableMouseWheel(true)
		scrollFrame:SetScript("OnMouseWheel", function(this, change)
			local childHeight = scrollChild:CalculateHeight()
			local frameHeight = scrollFrame:GetHeight()
			if childHeight <= frameHeight then
				return
			end

			nextFreeScroll = GetTime() + 1

			local diff = childHeight - frameHeight

			local delta = 1
			if change > 0 then
				delta = -1
			end

			local value = scrollBar:GetValue() + delta*24/diff
			if value < 0 then
				value = 0
			elseif value > 1 then
				value = 1
			end
			scrollBar:SetValue(value) -- will trigger OnValueChanged
		end)
		scrollFrame:SetScript("OnSizeChanged", paneOnSizeChanged)

		scrollChild:SetHeight(1)
		scrollChild:SetWidth(1)

		local first = true
		function scrollChild:CalculateHeight()
			local controls = mainPane.controls
			if #controls == 0 then
				return 0
			else
				local top = self:GetTop()
				if not top then
					return 0
				end
				local bottom = top
				for i,v in ipairs(controls) do
					local val = v:GetBottom()
					if val and val < bottom then
						bottom = val
					end
				end
				return top - bottom
			end
		end
		_G.scrollChild = scrollChild

		scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -16)
		scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 16)
		scrollBar:SetMinMaxValues(0, 1)
		scrollBar:SetValueStep(epsilon)
		scrollBar:SetValue(0)
		scrollBar:SetWidth(16)
		scrollBar:SetScript("OnValueChanged", function(this)
			local max = scrollChild:CalculateHeight() - scrollFrame:GetHeight()

			local val = scrollBar:GetValue() * max

			if math_abs(scrollFrame:GetVerticalScroll() - val) < 1 then
				return
			end

			scrollFrame:SetVerticalScroll(val)

			scrollFrame:UpdateScrollChildRect()
		end)
		scrollBar:EnableMouseWheel(true)
		scrollBar:SetScript("OnMouseWheel", function(this, ...)
			scrollFrame:GetScript("OnMouseWheel")(scrollFrame, ...)
		end)

		mainPane.controls = {}

		mainPane:SetPoint("LEFT", treeView, "RIGHT", -3, 0)
		mainPane:SetPoint("TOP", base, "TOP", 0, -33)
		mainPane:SetPoint("BOTTOMRIGHT", base, "BOTTOMRIGHT", -14, 14)
		local function mainPane_OnUpdate(this)
			this:SetScript("OnUpdate", nil)
			this:Reposition()
		end
		mainPane:SetScript("OnUpdate", mainPane_OnUpdate)

		local switch = false
		function mainPane:Reposition()
			mainPane_Reposition(self)
			local height = scrollChild:CalculateHeight()
			if height == 0 then
				mainPane:SetScript("OnUpdate", mainPane_OnUpdate)
				return
			end
			if not switch then
				mainPane:SetScript("OnUpdate", mainPane_OnUpdate)
			end
			switch = not switch
			if height < scrollFrame:GetHeight() then
				scrollBar:Hide()
				scrollFrame:SetPoint("BOTTOMRIGHT", mainPane, "BOTTOMRIGHT", -9, 12)
				scrollBar:SetValue(0)
				scrollFrame:SetVerticalScroll(0)
			else
				scrollBar:Show()
				scrollFrame:SetPoint("BOTTOMRIGHT", mainPane, "BOTTOMRIGHT", -28, 12)
			end

			local label = self.controls[1] and self.controls[1].label
			if not label then
				return
			end
			local labelWidth = label:GetWidth()
			local paneWidth = scrollFrame:GetWidth() - labelWidth - 8
			for i,v in ipairs(self.controls) do
				if v.SizeChanged then
					v:SizeChanged(paneWidth)
				end
			end

			scrollBar:GetScript("OnValueChanged")(scrollBar)
		end
	end

	do
		local sizer = CreateFrame("Frame", treeView:GetName() .. "_Sizer", treeView)
		treeView.sizer = sizer
		sizer:SetPoint("TOPLEFT", treeView, "TOPRIGHT", -5, 0)
		sizer:SetPoint("BOTTOMRIGHT", mainPane, "BOTTOMLEFT", 5, 0)
		sizer:EnableMouse(true)
		sizer:RegisterForDrag("LeftButton")
		sizer:SetScript("OnDragStart", function(this)
			this:GetParent():StartSizing("RIGHT")
		end)
		sizer:SetScript("OnDragStop", function(this)
			this:GetParent():StopMovingOrSizing()

			treeView:ClearAllPoints()
			treeView:SetPoint("LEFT", base, "LEFT", 14, 0)
			treeView:SetPoint("TOP", base, "TOP", 0, -33)
			treeView:SetPoint("BOTTOMLEFT", base, "BOTTOMLEFT", 14, 14)
		end)
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* Shows a tooltip, with the given information.
Arguments:
	Frame - the frame to be the owner
	string - the name of the item being hovered over, act as title.
	string - the descripiton of the item being hovered over, acts as the text.
Example:
	showTooltip(control, "Alpha", "Description of alpha")
-----------------------------------------------------------------------------]]
local function showTooltip(frame, name, desc, isDisabled)
	_G.GameTooltip_SetDefaultAnchor(GameTooltip, frame)

	if isDisabled then
		GameTooltip:SetText(name, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
	else
		GameTooltip:SetText(name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	end
	if name ~= desc then
		if isDisabled then
			GameTooltip:AddLine(desc, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1)
		else
			GameTooltip:AddLine(desc, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		end
	end
	GameTooltip:Show()
end

local clearMainPane, populateMainPane

do
	-- tree stuff
	local selectedTreeLine

	local TreeLine_Unselect, TreeLine_OnClick, TreeLine_OnExpandClick

	-- fill a list with a tree holding the expanded trees
	local function fillExpandedList(currentLine, expanded, num)
		if not num then
			num = 1
		end
		if not currentLine.sections then
			return
		end
		for i,v in ipairs(currentLine.sections) do
			if v.expand:IsShown() and v.expand:GetNormalTexture():GetTexture() ~= [[Interface\Buttons\UI-PlusButton-Up]] then
				local t = newList()
				expanded[v[num]] = t
				fillExpandedList(v, t, num+1)
			end
		end
	end

	-- expand the lines based on a table created by fillExpandedList
	local function expandTreeLines(currentLine, expanded, num)
		if not num then
			num = 1
		end
		if not currentLine.sections then
			return
		end
		for i,v in ipairs(currentLine.sections) do
			local v_num = v[num]
			local var = expanded[v_num]
			if var then
				if v:IsEnabled() == 1 and v.expand:IsShown() then
					local tex = v.expand:GetNormalTexture():GetTexture()
					TreeLine_OnExpandClick(v.expand, true)
					expandTreeLines(v, var, num+1)
				end
				expanded[v_num] = del(var)
			end
		end
	end

	local pulloutPath, pulloutYDiff, treeView_scroll, treeView_scrollval, mainPane_scroll, mainPane_scrollval, selectedPath, expandedList, currentAddon
	function saveState()
		if pulloutPath then
			pulloutPath = del(pulloutPath)
		end
		pulloutPath = nil
		pulloutYDiff = nil
		if pullout and pullout:IsShown() then
			pulloutPath = newList(unpack(pullout.parent))
			for i = 1, pullout:GetNumPoints() do
				local point, frame, relpoint, xdiff, ydiff = pullout:GetPoint(i)
				if point == "TOP" then
					pulloutYDiff = ydiff
					break
				end
			end
		end

		treeView_scroll = base.treeView.scrollBar:GetValue()
		treeView_scrollval = base.treeView.scrollFrame:GetVerticalScroll()
		mainPane_scroll = base.mainPane.scrollBar:GetValue()
		mainPane_scrollval = base.mainPane.scrollFrame:GetVerticalScroll()

		if selectedPath then
			selectedPath = del(selectedPath)
		end
		if selectedTreeLine then
			selectedPath = newList(unpack(selectedTreeLine))
		end

		local treeView = base.treeView
		if expandedList then
			expandedList = del(expandedList)
		end
		expandedList = newList()
		fillExpandedList(treeView, expandedList)

		currentAddon = base.addonChooser.value
	end

	function restoreState()
		local treeView = base.treeView
		removeSections(treeView)

		if not currentAddon then
			return false
		end
		base.addonChooser:Select(currentAddon)
		local ret = false
		if expandedList then
			expandTreeLines(treeView, expandedList)
			expandedList = del(expandedList)
			ret = true
		end
		if not treeView.sections then
			return false
		end

		if selectedPath then
			local current = treeView
			local last
			for i,v in ipairs(selectedPath) do
				local sections = current.sections
				last = current
				current = nil
				if not sections then
					break
				end
				for j, u in ipairs(sections) do
					if u[i] == v then
						current = u
						break
					end
				end
				if not current then
					break
				end
			end
			if current == treeView then
				current = nil
			end
			if last == treeView then
				last = nil
			end
			if current or last then
				TreeLine_OnClick(current or last, true)
			end
			selectedPath = del(selectedPath)
		end

		if treeView_scroll and treeView.scrollBar:IsShown() then
			treeView.scrollBar:SetValue(treeView_scroll)
			treeView.scrollFrame:SetVerticalScroll(treeView_scrollval)
		end

		local mainPane = base.mainPane

		if mainPane_scroll and mainPane.scrollBar:IsShown() then
			mainPane.scrollBar:SetValue(mainPane_scroll)
			mainPane.scrollFrame:SetVerticalScroll(mainPane_scrollval)
		end

		if pulloutPath then
			for _, control in ipairs(base.mainPane.controls) do
				for i,v in ipairs(pulloutPath) do
					if v ~= control[i] then
						if control[i] == nil then
							if control.type == 'group' and control.groupType == 'inline' then
								local control_controls = control.controls
								control = nil
								for _, subControl in ipairs(control_controls) do
									if subControl[i] == v then
										control = subControl
										break
									end
								end
							end
							if not control then
								break
							end
						else
							control = nil
							break
						end
					end
				end
				if control then
					if control.button and control.type == 'choice' then
						control.button:Click()
						for i = 1, pullout:GetNumPoints() do
							local point, frame, relpoint, xdiff, ydiff = pullout:GetPoint(i)
							if point == "TOP" then
								pullout:SetPoint(point, frame, relpoint, xdiff, pulloutYDiff)
								break
							end
						end
					end
					break
				end
			end
			pulloutPath = del(pulloutPath)
			pulloutYDiff = nil
		end
		return ret
	end

	--[[---------------------------------------------------------------------------
	Notes:
		* Refreshes the controls inside the main pane, rechecking existence and the current values of all of them.
	Example:
		refreshConfigMenu()
	-----------------------------------------------------------------------------]]
	function refreshConfigMenu(object)
		if object and not data[object] then
			return
		end
		if base.addonChooser.value ~= object then
			return
		end

		local fixStrata = false
		if next(strataList) then
			fixStrata = true
			makeForeground()
		end

		saveState()

		if selectedTreeLine then
			TreeLine_Unselect(selectedTreeLine)
		end

		restoreState()

		if fixStrata then
			makeBackground()
		end
	end

	-- show the highlight and tooltip
	local function TreeLine_OnEnter(this)
		if this:IsEnabled() == 1 then
			this.highlight:SetAlpha(1)
			this.highlight:Show()
		end

		local name = this.text:GetText()
		local desc = this.desc
		if not desc then
			desc = getConfigField(this, 'desc', true, false, "string")
			this.desc = desc
		end
		showTooltip(this, name, desc, this:IsEnabled() ~= 1)
	end

	-- hide the highlight (unless selected) and tooltip
	local function TreeLine_OnLeave(this)
		if this ~= selectedTreeLine then
			this.highlight:Hide()
		else
			this.highlight:SetAlpha(0.7)
		end
		GameTooltip:Hide()
	end

	-- unselect the line, thus clearing any results from it
	function TreeLine_Unselect(this)
		this.highlight:Hide()
		selectedTreeLine = nil
		base.titleText:SetText('-----')

		clearMainPane(base.mainPane)
	end

	-- select the line
	function TreeLine_OnClick(this, dontExpand)
		if this:IsEnabled() ~= 1 then
			return
		end
		local last_selectedTreeLine = selectedTreeLine
		if selectedTreeLine then
			TreeLine_Unselect(selectedTreeLine)
		end

		selectedTreeLine = this
		if GetMouseFocus() == this then
			this.highlight:SetAlpha(1)
		else
			this.highlight:SetAlpha(0.7)
		end
		this.highlight:Show()

		local t = newList()
		for i = 1, #this do
			-- double-check existence of config tables, just in case
			-- also track breadcrumbs so the title is nice
			local path = newList(unpack(this, 1, i))
			if not hasConfigTable(path) then
				TreeLine_Unselect(this)
				t = del(t)
				path = del(path)
				return
			end
			t[i] = getConfigField(path, 'name', true, false, "string")
			path = del(path)
		end
		base.titleText:SetText(table_concat(t, " -> "))
		t = del(t)

		if this.expand:IsShown() and dontExpand ~= true then
			if this == last_selectedTreeLine then
				this.expand:Click()
			else
				TreeLine_OnExpandClick(this.expand, true)
			end
		end

		populateMainPane(this)
	end

	-- clear a tree
	function removeSections(treeLine, object)
		local sections = treeLine.sections
		if sections then
			for i,v in ipairs(sections) do
				if not object or v[1] == object then
					removeSections(v)
					releaseTreeLine(v)
					if object then
						table.remove(sections, i)
						return
					end
				end
			end
			treeLine.sections = del(sections)
		end
	end

	-- expand a tree, create the sub-sections
	function TreeLine_OnExpandClick(this, openOnly)
		if not this:IsShown() then
			return
		end
		local treeLine = this:GetParent()
		local tex = this:GetNormalTexture():GetTexture()
		local expand = (tex == [[Interface\Buttons\UI-PlusButton-Up]])
		if openOnly == true or openOnly == false then
			if openOnly then
				if not expand then
					return
				end
			else
				if expand then
					return
				end
			end
		end
		if expand then
			this:SetNormalTexture([[Interface\Buttons\UI-MinusButton-UP]])
			this:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Down]])
			this:SetDisabledTexture([[Interface\Buttons\UI-MinusButton-Disabled]])
			this:SetHighlightTexture([[Interface\Buttons\UI-MinusButton-Hilight]])
			local args = getConfigField(treeLine, 'args', false, false, "table")
			for k,v in pairs(args) do
				local t = newList(unpack(treeLine))
				t[#t+1] = k
				local v_type = getConfigField(t, 'type', true, false, "string")
				if v_type == 'group' then
					local v_groupType = getConfigField(t, 'groupType', true, "normal", "string")
					if v_groupType ~= "inline" then
						getTreeLine(t)
					end
				end
				t = del(t)
			end
			if #treeLine == 1 then
				local extraArgs = getConfigField(treeLine, 'extraArgs', false, true, "table")
				if extraArgs then
					for k,v in pairs(extraArgs) do
						if args[k] == nil then
							local t = newList(unpack(treeLine))
							t[#t+1] = k
							local v_type = getConfigField(t, 'type', true, false, "string")
						 	if v_type == 'group' then
								local v_groupType = getConfigField(t, 'groupType', true, "normal", "string")
								if v_groupType ~= "inline" then
									getTreeLine(t)
								end
							end
							t = del(t)
						end
					end
				end
			end
			sortTreeLineSections(treeLine)
		else
			this:SetNormalTexture([[Interface\Buttons\UI-PlusButton-Up]])
			this:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
			this:SetDisabledTexture([[Interface\Buttons\UI-PlusButton-Disabled]])
			this:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
			removeSections(treeLine)
		end
		base.treeView:Reposition()

		local scrollValue = base.treeView.scrollFrame:GetVerticalScroll()

		local max = base.treeView.scrollChild:CalculateHeight() - base.treeView.scrollFrame:GetHeight()

		base.treeView.scrollBar:SetValue(scrollValue/max)
	end

	local treeLinesDisabled = {}
	local function frame_IsEnabled(this)
		return treeLinesDisabled[this] and 0 or 1
	end
	local function frame_Disable(this)
		if treeLinesDisabled[this] then
			return
		end
		treeLinesDisabled[this] = true
		local tex = this.expand:GetNormalTexture():GetTexture()
		TreeLine_OnExpandClick(this.expand, false)
		this.expand:Disable()
		this.expand:EnableMouse(false)
		this.text:SetFontObject(GameFontDisable)
		this:SetPushedTextOffset(0, 0)
		this.highlight:Hide()
		if selectedTreeLine == this then
			TreeLine_Unselect(this)
		end
	end
	local function frame_Enable(this)
		if not treeLinesDisabled[this] then
			return
		end
		treeLinesDisabled[this] = nil
		this.expand:Enable()
		this.expand:EnableMouse(true)
		this.text:SetFontObject(GameFontHighlight)
		this:SetPushedTextOffset(1.45, -1.45)
	end

	local pool = {}
	-- remove a tree line, put it in the pool
	function releaseTreeLine(frame)
		if selectedTreeLine == frame then
			TreeLine_Unselect(frame)
		end
		frame:Hide()
		frame:Enable()
		frame:ClearAllPoints()
		frame.highlight:Hide()
		frame.expand:Show()
		frame.expand:SetNormalTexture([[Interface\Buttons\UI-PlusButton-Up]])
		frame.expand:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
		frame.expand:SetDisabledTexture([[Interface\Buttons\UI-PlusButton-Disabled]])
		frame.expand:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
		frame.icon:SetTexture(nil)
		frame.icon:SetWidth(16)
		frame.icon:SetHeight(16)
		frame.desc = nil
		for i = 1, #frame do
			frame[i] = nil
		end
		pool[frame] = true
		return nil
	end

	local treeLineNum = 0
	-- create a preliminary tree line
	local function _getTreeLine()
		local frame = next(pool)
		if frame then
			pool[frame] = nil
			frame:Show()
			return frame
		end
		treeLineNum = treeLineNum + 1
		frame = CreateFrame("Button", base.treeView:GetName() .. "_TreeLine" .. treeLineNum, base.treeView.scrollChild)
		local text = frame:CreateFontString(frame:GetName() .. "_Text", "OVERLAY", "GameFontHighlight")
		frame.text = text
		text:SetJustifyH("LEFT")
		frame:SetFontString(text)
		frame:SetHeight(16)
		frame:EnableMouse(true)
		frame:SetScript("OnEnter", TreeLine_OnEnter)
		frame:SetScript("OnLeave", TreeLine_OnLeave)
		frame:SetScript("OnClick", TreeLine_OnClick)
		frame:SetFrameLevel(10)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")

		frame.Enable = frame_Enable
		frame.Disable = frame_Disable
		frame.IsEnabled = frame_IsEnabled

		local highlight = frame:CreateTexture(frame:GetName() .. "_Highlight", "BACKGROUND")
		frame.highlight = highlight
		highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints(frame)
		highlight:Hide()

		local expand = CreateFrame("Button", frame:GetName() .. "_Expand", frame)
		frame.expand = expand
		expand:SetNormalTexture([[Interface\Buttons\UI-PlusButton-Up]])
		expand:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
		expand:SetDisabledTexture([[Interface\Buttons\UI-PlusButton-Disabled]])
		expand:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
		expand:SetScript("OnClick", TreeLine_OnExpandClick)
		expand:SetFrameLevel(21)
		expand:SetWidth(16)
		expand:SetHeight(16)

		local icon = frame:CreateTexture(frame:GetName() .. "_Icon", "OVERLAY")
		frame.icon = icon
		icon:SetWidth(16)
		icon:SetHeight(16)
		icon:SetPoint("LEFT", expand, "RIGHT", 1, 0)

		expand:SetPoint("LEFT", frame, "LEFT", 0, 0)
		text:SetPoint("LEFT", icon, "RIGHT", 0, 0)
		text:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

		return frame
	end

	-- fetch a preliminary tree line and set it up
	function getTreeLine(path)
		if not hasConfigTable(path) then
			return nil
		end
		local hidden = getConfigField(path, 'hidden', false, true)
		if hidden then
			return
		end
		local parent = base.treeView
		for i = 1, #path-1 do
			local u = path[i]
			local good = false
			if not parent.sections then
				return nil
			end
			for k,v in pairs(parent.sections) do
				if v[i] == u then
					parent = v
					good = true
					break
				end
			end
			if not good then
				return nil
			end
		end
		local line = _getTreeLine()
		local sections = parent.sections
		if not sections then
			sections = newList()
			parent.sections = sections
		end
		sections[#sections+1] = line
		for i,v in ipairs(path) do
			line[i] = v
		end
		local hasChild = false
		local args = getConfigField(path, 'args', false, false, "table")
		if not args then
			-- error occurred
			sections[#sections] = releaseTreeLine(line)
			return
		end
		for k,v in pairs(args) do
			local t = newList(unpack(path))
			t[#t+1] = k
			local v_type = getConfigField(t, 'type', true, false, "string")
			if v_type == "group" then
				local v_groupType = getConfigField(t, 'groupType', true, "normal", "string")
				if v_groupType ~= "inline" then
					local v_hidden = getConfigField(t, 'hidden', false, true)
					if not v_hidden then
						hasChild = true
					end
				end
			end
			t = del(t)
			if hasChild then
				break
			end
		end
		if not hasChild and #path == 1 then
			local extraArgs = getConfigField(path, 'extraArgs', false, true, "table")
			if extraArgs then
				for k,v in pairs(extraArgs) do
					if args[k] == nil then
						local t = newList(unpack(path))
						t[#t+1] = k
						local v_type = getConfigField(t, 'type', true, false, "string")
						if v_type == "group" then
							local v_groupType = getConfigField(t, 'groupType', true, "normal", "string")
							if v_groupType ~= "inline" then
								hasChild = true
							end
						end
						t = del(t)
						if hasChild then
							break
						end
					end
				end
			end
		end
		if not hasChild then
			line.expand:Hide()
		end
		line.text:SetText(getConfigField(path, 'name', true, false, "string"))
		local icon = #path >= 2 and getConfigField(path, 'icon', true, true, "string")
		if icon then
			line.icon:SetTexture(icon)
			if icon:find([[^Interface\Icons\]]) then
				line.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			else
				line.icon:SetTexCoord(0, 1, 0, 1)
			end
			local size = getConfigField(path, 'iconSize', false, 1, "number")
			line.icon:SetWidth(size*16)
			line.icon:SetHeight(size*16)
			
			local texCoord = getConfigField(path, 'iconTexCoord', false, true, "table")
			if texCoord then
				line.icon:SetTexCoord(unpack(texCoord))
			else
				line.icon:SetTexCoord(0, 1, 0, 1)
			end
		else
			line.icon:SetWidth(epsilon)
		end
		local disabled = getConfigField(path, 'disabled', false, true)
		if disabled then
			line:Disable()
		end
		return line
	end

	do
		-- helping sorting function for the groups.
		local function treeLineSort(alpha, bravo)
			local alpha_order = getConfigField(alpha, 'order', false, 100, "number")
			local bravo_order = getConfigField(bravo, 'order', false, 100, "number")
			if alpha_order == bravo_order then
				return alpha.text:GetText():lower() < bravo.text:GetText():lower()
			else
				if alpha_order < 0 then
					if bravo_order < 0 then
						return alpha_order < bravo_order
					else
						return false
					end
				else
					if bravo_order < 0 then
						return true
					else
						return alpha_order < bravo_order
					end
				end
			end
		end
		-- sort the sub-trees of the given tree line
		function sortTreeLineSections(treeLine)
			local sections = treeLine.sections
			if not sections then
				return
			end

			table_sort(sections, treeLineSort)
		end
	end
end

do
	local releaseLabel, getLabel
	do
		local labelPool = {}
		-- remove a label, put it in the pool
		function releaseLabel(frame)
			frame:Enable()
			frame:Hide()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			labelPool[frame] = true
			frame.text:SetText(nil)
			frame.icon:SetTexture(nil)
			return nil
		end

		-- show tooltip
		local function Label_OnEnter(this)
			local control = this.control
			local name = this.text:GetText()
			local desc = control.desc
			if not desc then
				desc = getConfigField(control, 'desc', true, false, "string")
				control.desc = desc
			end
			showTooltip(control, name, desc, this:IsEnabled() ~= 1)
		end

		-- hide tooltip
		local function Label_OnLeave(this)
			GameTooltip:Hide()
		end

		local labelsDisabled = {}
		-- fake enable function, turn non-gray
		local function Label_Enable(this)
			if not labelsDisabled[this] then
				return
			end
			labelsDisabled[this] = nil
			this.text:SetFontObject(GameFontNormal)
		end
		-- fake disable function, turn gray
		local function Label_Disable(this)
			if labelsDisabled[this] then
				return
			end
			labelsDisabled[this] = true
			this.text:SetFontObject(GameFontDisable)
		end
		-- fake check enable function. Note: this returns 0 and 1 because Blizzard does this.
		local function Label_IsEnabled(this)
			return labelsDisabled[this] and 0 or 1
		end
		local labelNum = 0
		-- create a preliminary label
		local function _getLabel()
			local frame = next(labelPool)
			if frame then
				labelPool[frame] = nil
				frame:Show()
				return frame
			end
			local mainPane = base.mainPane
			labelNum = labelNum + 1
			frame = CreateFrame("Frame", mainPane:GetName() .. "_Label" .. labelNum, mainPane.scrollChild)
			local text = frame:CreateFontString(frame:GetName() .. "_FontString", "OVERLAY", "GameFontNormal")
			frame.text = text
			text:SetPoint("LEFT")
			text:SetJustifyH("LEFT")
			local icon = frame:CreateTexture(frame:GetName() .. "_Icon", "ARTWORK")
			frame.icon = icon
			icon:SetPoint("RIGHT", text, "LEFT", -1, 0)

			frame:SetScript("OnEnter", Label_OnEnter)
			frame:SetScript("OnLeave", Label_OnLeave)
			frame:EnableMouse(true)
			frame.IsEnabled = Label_IsEnabled
			frame.Enable = Label_Enable
			frame.Disable = Label_Disable

			return frame
		end
		-- fetch and set up a label
		function getLabel(path, control)
			local frame = _getLabel()

			local mainPane = base.mainPane
			control.label = frame
			frame.control = control
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local name = getConfigField(frame, 'name', true, false, "string")
			frame.text:SetText(name)
			local icon = getConfigField(frame, 'icon', true, true, "string")
			if icon then
				frame.icon:Show()
				frame.icon:SetTexture(icon)
				if icon:find([[^Interface\Icons\]]) then
					frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				else
					frame.icon:SetTexCoord(0, 1, 0, 1)
				end
				local size = getConfigField(frame, 'iconSize', false, 1, "number")
				frame.icon:SetWidth(16*size)
				frame.icon:SetHeight(16*size)
				
				local texCoord = getConfigField(frame, 'iconTexCoord', false, true, "table")
				if texCoord then
					frame.icon:SetTexCoord(unpack(texCoord))
				else
					frame.icon:SetTexCoord(0, 1, 0, 1)
				end
			else
				frame.icon:Hide()
			end
			return frame
		end
	end

	-- show a tooltip on hover
	local function Control_OnEnter(this)
		local name = this.label.text:GetText()
		local desc = this.desc
		if not desc then
			desc = getConfigField(this, 'desc', true, false, "string")
			this.desc = desc
		end
		showTooltip(this, name, desc, this:IsEnabled() ~= 1)
	end

	-- hide tooltip on unhover
	local function Control_OnLeave(this)
		GameTooltip:Hide()
	end

	local function recolorEditBoxStyle(editBox, r, g, b, a)
		editBox.line1:SetVertexColor(r*3/4, g*3/4, b*3/4, a or 1)
		editBox.line2:SetVertexColor(r*3/4, g*3/4, b*3/4, a or 1)
		editBox.line3:SetVertexColor(r*3/8, g*3/8, b*3/8, a or 1)
		editBox.line4:SetVertexColor(r*3/8, g*3/8, b*3/8, a or 1)
	end

	local function styleEditBox(editBox)
		local isMultiLine = editBox:IsMultiLine()
		local line1 = editBox.line1 or editBox:CreateTexture(editBox:GetName() .. "_Line1", "BACKGROUND")
		editBox.line1 = line1
		line1:SetTexture([[Interface\Buttons\WHITE8X8]])
		line1:SetHeight(1)
		line1:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, 1)
		line1:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", 0, 1)

		local line2 = editBox.line2 or editBox:CreateTexture(editBox:GetName() .. "_Line2", "BACKGROUND")
		editBox.line2 = line2
		line2:SetTexture([[Interface\Buttons\WHITE8X8]])
		line2:SetWidth(1)
		line2:SetPoint("TOPLEFT", editBox, "TOPRIGHT", 0, isMultiLine and 3 or 0)
		line2:SetPoint("BOTTOMLEFT", editBox, "BOTTOMRIGHT", 0, 0)

		local line3 = editBox.line3 or editBox:CreateTexture(editBox:GetName() .. "_Line3", "BACKGROUND")
		editBox.line3 = line3
		line3:SetTexture([[Interface\Buttons\WHITE8X8]])
		line3:SetHeight(1)
		line3:SetPoint("BOTTOMLEFT", editBox, "TOPLEFT", 0, isMultiLine and 2 or -1)
		line3:SetPoint("BOTTOMRIGHT", editBox, "TOPRIGHT", 0, isMultiLine and 2 or -1)

		local line4 = editBox.line4 or editBox:CreateTexture(editBox:GetName() .. "_Line4", "BACKGROUND")
		editBox.line4 = line4
		line4:SetTexture([[Interface\Buttons\WHITE8X8]])
		line4:SetWidth(1)
		line4:SetPoint("TOPRIGHT", editBox, "TOPLEFT", 0, isMultiLine and 3 or 0)
		line4:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMLEFT", 0, 0)

		recolorEditBoxStyle(editBox, 1, 1, 1, 1)
	end

	local releaseExecuteControl, getExecuteControl
	do
		-- button
		local pool = {}
		-- remove a button and put it in the pool
		function releaseExecuteControl(frame)
			frame:Hide()
			frame:Enable()
			frame.button:Enable()
			frame.confirmButton:Hide()
			frame.confirmButton:SetChecked(false)
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			pool[frame] = true
			return nil
		end
		-- when pressed, the button should look pressed
		local function button_OnMouseDown(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			end
		end
		-- when depressed, return to normal
		local function button_OnMouseUp(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			end
		end
		local executeControlsDisabled = {}
		-- fake enable check
		local function frame_IsEnabled(this)
			return executeControlsDisabled[this] and 0 or 1
		end
		-- when disabled, turn gray
		local function frame_Disable(this)
			if executeControlsDisabled[this] then
				return
			end
			executeControlsDisabled[this] = true
			this.label:Disable()
			this.button:Disable()
			this.confirmButton:Disable()
			this.confirmButton:EnableMouse(false)
			this.confirmButton.text:SetFontObject(GameFontDisableSmall)
		end
		-- when enabled, return to normal
		local function frame_Enable(this)
			if not executeControlsDisabled[this] then
				return
			end
			executeControlsDisabled[this] = nil
			this.label:Enable()
			this.button:Enable()
			this.confirmButton:Enable()
			if this.confirmButton:IsShown() and not this.confirmButton:GetChecked() then
				this.button:Disable()
			end
			this.confirmButton:EnableMouse(true)
			this.confirmButton.text:SetFontObject(GameFontNormalSmall)
		end

		local function confirmButton_OnClick(this)
			if this:GetChecked() then
				this:GetParent().button:Enable()
			else
				this:GetParent().button:Disable()
			end
		end

		local function button_Disable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this:__Disable()
			this:EnableMouse(false)
		end

		local function button_Enable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this:__Enable()
			this:EnableMouse(true)
		end

		-- call the actual function
		local function button_OnClick(this)
			callConfigField(this:GetParent(), 'func')
			refreshConfigMenu(this:GetParent()[1])
		end
		local executeControlNum = 0
		-- create a preliminary button
		local function _getExecuteControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			executeControlNum = executeControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_ExecuteControl" .. executeControlNum, mainPane.scrollChild)

			local button = CreateFrame("Button", frame:GetName() .. "_Button", frame)
			frame.button = button
			local left = button:CreateTexture(button:GetName() .. "_LeftTexture", "BACKGROUND")
			button.left = left
			local middle = button:CreateTexture(button:GetName() .. "_MiddleTexture", "BACKGROUND")
			button.middle = middle
			local right = button:CreateTexture(button:GetName() .. "_RightTexture", "BACKGROUND")
			button.right = right
			left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

			left:SetPoint("TOPLEFT")
			left:SetPoint("BOTTOMLEFT")
			left:SetWidth(12)
			left:SetTexCoord(0, 0.09375, 0, 0.6875)

			right:SetPoint("TOPRIGHT")
			right:SetPoint("BOTTOMRIGHT")
			right:SetWidth(12)
			right:SetTexCoord(0.53125, 0.625, 0, 0.6875)

			middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
			middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
			middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)

			button:SetScript("OnMouseDown", button_OnMouseDown)
			button:SetScript("OnMouseUp", button_OnMouseUp)

			button.__Enable = button.Enable
			button.__Disable = button.Disable
			button.Enable = button_Enable
			button.Disable = button_Disable

			frame.IsEnabled = frame_IsEnabled
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable

			local text = button:CreateFontString(button:GetName() .. "_FontString", "ARTWORK")
			button:SetFontString(text)
			button.text = text
			text:SetPoint("LEFT", button, "LEFT", 7, 0)
			text:SetPoint("RIGHT", button, "RIGHT", -7, 0)

			button[SET_NORMAL_FONT_OBJECT](button, GameFontNormal)
			button:SetHighlightFontObject(GameFontHighlight)
			button:SetDisabledFontObject(GameFontDisable)
			local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY", "UIPanelButtonHighlightTexture")
			button:SetHighlightTexture(highlight)

			button:SetScript("OnClick", button_OnClick)
			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			button:SetScript("OnEnter", SubControl_OnEnter)
			button:SetScript("OnLeave", SubControl_OnLeave)

			frame:EnableMouse(true)
			button:EnableMouse(true)

			frame:SetHeight(24)
			button:SetAllPoints()

			local confirmButton = CreateFrame("CheckButton", frame:GetName() .. "_ConfirmButton", frame, "UICheckButtonTemplate")
			frame.confirmButton = confirmButton
			confirmButton:SetPoint("LEFT")
			confirmButton.text = _G[confirmButton:GetName() .. "Text"]
			confirmButton.text:SetText("Pants")
			confirmButton:Hide()
			confirmButton:SetScript("OnEnter", SubControl_OnEnter)
			confirmButton:SetScript("OnLeave", SubControl_OnLeave)
			confirmButton:SetScript("OnClick", confirmButton_OnClick)

			frame.type = 'execute'

			return frame
		end
		-- fetch and set up a button
		function getExecuteControl(path, parent)
			local frame = _getExecuteControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local buttonText = getConfigField(frame, 'buttonText', true, false, "string")
			frame.button.text:SetText(buttonText)
			local confirmText = getConfigField(frame, 'confirmText', true, true, "string")
			frame.button:ClearAllPoints()
			if confirmText then
				frame.confirmButton.text:SetText(confirmText)
				frame.confirmButton:Show()
				frame.button:SetPoint("LEFT", frame.confirmButton.text, "RIGHT", 3, 0)
				frame.button:SetPoint("TOP")
				frame.button:SetPoint("BOTTOM")
				frame.button:SetPoint("RIGHT")
				frame.button:Disable()
			else
				frame.button:SetAllPoints()
			end
			return frame
		end
	end

	local getBooleanControl, releaseBooleanControl
	do
		local pool = {}
		-- remove a checkbox, put in the pool
		function releaseBooleanControl(frame)
			frame:Hide()
			frame:Enable()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			SetDesaturation(frame.button.check, false)
			frame.button.check.half = nil
			pool[frame] = true
			return nil
		end

		-- when clicked, change the state
		local function button_OnClick(this)
			local newValue = not this.check:IsShown() or this.check.half

			local t = newList(not not newValue)
			callConfigField(this:GetParent(), 'set', t)
			t = del(t)

			refreshConfigMenu(this:GetParent()[1])
		end
		-- show a depression
		local function button_OnMouseDown(this)
			this.checkbox:SetTexture([[Interface\Buttons\UI-CheckBox-Down]])
		end
		-- show undepression
		local function button_OnMouseUp(this)
			this.checkbox:SetTexture([[Interface\Buttons\UI-CheckBox-Up]])
		end
		-- fake enable check
		local booleanControlsDisabled = {}
		local function frame_IsEnabled(this)
			return booleanControlsDisabled[this] and 0 or 1
		end
		-- turn gray, including the checkbox.
		local function frame_Disable(this)
			if booleanControlsDisabled[this] then
				return
			end
			booleanControlsDisabled[this] = true
			this.button.checkbox:SetTexture([[Interface\Buttons\UI-CheckBox-Disabled]])
			SetDesaturation(this.button.check, true)
			this.label:Disable()
			this.button:Disable()
			this.button:EnableMouse(false)
		end
		-- turn normal colors
		local function frame_Enable(this)
			if not booleanControlsDisabled[this] then
				return
			end
			booleanControlsDisabled[this] = nil
			this.button.checkbox:SetTexture([[Interface\Buttons\UI-CheckBox-Up]])
			SetDesaturation(this.button.check, false)
			this.label:Enable()
			this.button:Enable()
			this.button:EnableMouse(true)
		end
		local booleanControlNum = 0
		-- create a preliminary checkbox
		local function _getBooleanControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			booleanControlNum = booleanControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_BooleanControl" .. booleanControlNum, mainPane.scrollChild)
			frame:EnableMouse(true)
			frame:SetHeight(24)
			local button = CreateFrame("Button", frame:GetName() .. "_Button", frame)
			frame.button = button
			button:SetAllPoints()
			local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY")
			highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			highlight:SetVertexColor(1, 1, 1, 0.5)
			highlight:SetBlendMode("ADD")
			highlight:SetAllPoints(frame)
			button:SetHighlightTexture(highlight)

			local checkbox = button:CreateTexture(button:GetName() .. "_Texture", "BACKGROUND")
			button.checkbox = checkbox
			checkbox:SetHeight(24)
			checkbox:SetWidth(24)
			checkbox:SetTexture([[Interface\Buttons\UI-CheckBox-Up]])
			checkbox:SetPoint("CENTER")
			checkbox:SetTexCoord(0.12, 0.88, 0.12, 0.88)

			local check = button:CreateTexture(button:GetName() .. "_Check", "ARTWORK")
			button.check = check
			check:SetHeight(24)
			check:SetWidth(24)
			check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
			check:SetPoint("CENTER")
			check:Hide()
			check:SetTexCoord(0.12, 0.88, 0.12, 0.88)

			button:SetScript("OnClick", button_OnClick)
			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			button:SetScript("OnEnter", SubControl_OnEnter)
			button:SetScript("OnLeave", SubControl_OnLeave)

			button:SetScript("OnMouseDown", button_OnMouseDown)
			button:SetScript("OnMouseUp", button_OnMouseUp)
			frame.IsEnabled = frame_IsEnabled
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable

			frame.type = 'boolean'

			return frame
		end

		-- fetch and set up a checkbox
		function getBooleanControl(path, parent)
			local frame = _getBooleanControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local ret = getConfigField(frame, 'get', false, false, "boolean;string")
			if ret then
				frame.button.check:Show()
				if ret == "HALF" then
					frame.button.check.half = true
					SetDesaturation(frame.button.check, true)
				end
			else
				frame.button.check:Hide()
			end
			return frame
		end
	end

	local getNumberControl, releaseNumberControl
	do
		local pool = {}
		-- remove a slider and put in the pool
		function releaseNumberControl(frame)
			frame:Hide()
			frame:Enable()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			pool[frame] = true
			frame.desc = nil
			return nil
		end

		-- make sure the slider's value and the edit box are the proper value, with step and everything properly checked.
		local function fixSliderValue(this)
			if this.changing then
				return
			end
			local min = this.min
			local max = this.max
			local step = this.step
			local stepBasis = this.stepBasis
			local value = getConfigField(this, 'get', false, (min+max)/2, "number")

			value = math_floor((value - stepBasis) / step + 0.5) * step + stepBasis

			local fakeValue = (value - min) / (max - min)
			this.changing = true
			this.slider:SetValue(fakeValue)

			this.editBox:ClearFocus()
			if this.isPercent then
				this.editBox:SetText(tostring(value*100) .. "%")
			else
				this.editBox:SetText(value)
			end
			this.changing = nil
		end

		local numberControlsDisabled = {}
		-- fake enable check.
		local function frame_IsEnabled(this)
			return numberControlsDisabled[this] and 0 or 1
		end
		-- fake enable function, turns things normal from gray
		local function frame_Enable(this)
			if not numberControlsDisabled[this] then
				return
			end
			numberControlsDisabled[this] = nil
			this.slider:EnableMouse(true)
			this.editBox:EnableMouse(true)
			this.slider.lowText:SetFontObject(GameFontHighlightSmall)
			this.slider.highText:SetFontObject(GameFontHighlightSmall)
			this.editBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			recolorEditBoxStyle(this.editBox, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

			if this:IsShown() then
				fixSliderValue(this)
			end

			this.label:Enable()
		end
		-- fake disable function, turns things gray
		local function frame_Disable(this)
			if numberControlsDisabled[this] then
				return
			end
			numberControlsDisabled[this] = true
			this.slider:EnableMouse(false)
			this.editBox:EnableMouse(false)
			this.slider.lowText:SetFontObject(GameFontDisableSmall)
			this.slider.highText:SetFontObject(GameFontDisableSmall)
			this.editBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			recolorEditBoxStyle(this.editBox, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)

			this.editBox:ClearFocus()

			this.label:Disable()
		end

		local changedValue = false
		-- when the value's changed, make sure everything's up to date.
		local function slider_OnValueChanged(this, fakeValue)
			local parent = this:GetParent()
			if parent.changing then
				return
			end
			local min = parent.min
			local max = parent.max
			local bigStep = parent.bigStep
			local value = fakeValue*(max - min) + min
			local stepBasis = parent.stepBasis

			value = math_floor((value - stepBasis) / bigStep + 0.5) * bigStep + stepBasis

			if value == parent.lastValue then
				return
			end

			parent.lastValue = value
			local t = newList(value)
			callConfigField(parent, 'set', t)
			t = del(t)

			fixSliderValue(parent)
			changedValue = true
		end

		local function slider_OnMouseDown(this)
			currentlyMovingSlider = true
		end

		-- refix things
		local function slider_OnMouseUp(this)
			currentlyMovingSlider = false
			if changedValue then
				changedValue = false
				refreshConfigMenu(this:GetParent()[1])
			else
				fixSliderValue(this:GetParent())
			end
		end

		-- mousewheel changes the slider by one step
		local function frame_OnMouseWheel(this, change)
			if nextFreeScroll > GetTime() or this:IsEnabled() ~= 1 then
				base.mainPane.scrollFrame:GetScript("OnMouseWheel")(base.mainPane.scrollFrame, change)
				return
			end
			local min = this.min
			local max = this.max
			local step = this.step
			local value = this.slider:GetValue()*(max - min) + min
			local stepBasis = this.stepBasis

			local delta = step
			if change < 0 then
				delta = -delta
			end
			value = value + delta

			value = math_floor((value - stepBasis) / step + 0.5) * step + stepBasis

			if value < min then
				value = min
			elseif value > max then
				value = max
			end

			if value == this.lastValue then
				fixSliderValue(this)
				return
			end

			this.lastValue = value
			local t = newList(value)
			callConfigField(this, 'set', t)
			t = del(t)

			refreshConfigMenu(this[1])
		end

		-- if escape is pressed, the text should go back to the previous
		local function editBox_OnEscapePressed(this)
			this:ClearFocus()
		end
		-- if enter is pressed, it should update
		local function editBox_OnEnterPressed(this)
			local value = this:GetNumber()
			this:ClearFocus()
			local parent = this:GetParent()
			if parent.isPercent then
				value = value / 100
			end

			local min, max, step, stepBasis = parent.min, parent.max, parent.step, parent.stepBasis

			value = math_floor((value - stepBasis) / step + 0.5) * step + stepBasis

			if value < min then
				value = min
			elseif value > max then
				value = max
			end

			if value ~= parent.lastValue then
				parent.lastValue = value

				local t = newList(value)
				callConfigField(parent, 'set', t)
				t = del(t)

				refreshConfigMenu(parent[1])
			else
				fixSliderValue(parent)
			end
		end
		-- if the edit box gains focus and is a percentage, strip the percent sign.
		local function editBox_OnEditFocusGained(this)
			if this:GetParent():IsEnabled() ~= 1 then
				this:ClearFocus()
				return
			end
			local text = this:GetText()
			if text:find("%%$") then
				this:SetText(text:sub(1, -2))
			end
		end
		-- if focus is lost, fix the value to go back to normal
		local function editBox_OnEditFocusLost(this)
			fixSliderValue(this:GetParent())
		end

		local numberControlNum = 0
		-- create a preliminary slider
		local function _getNumberControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			numberControlNum = numberControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_NumberControl" .. numberControlNum, mainPane.scrollChild)
			frame:SetHeight(20)
			frame:EnableMouse(true)
			frame:EnableMouseWheel(true)

			local slider = CreateFrame("Slider", frame:GetName() .. "_Slider", frame)
			frame.slider = slider
			slider:SetOrientation("HORIZONTAL")
			slider:EnableMouse(true)
			slider:SetHeight(17)
			slider:SetPoint("TOPLEFT")
			slider:SetHitRectInsets(0, 0, 0, 0)
			local bg = newList()
			bg.bgFile = [[Interface\Buttons\UI-SliderBar-Background]]
			bg.edgeFile = [[Interface\Buttons\UI-SliderBar-Border]]
			bg.tile = true
			bg.edgeSize = 8
			bg.tileSize = 8
			bg.insets = newList()
			bg.insets.left = 3
			bg.insets.right = 3
			bg.insets.top = 6
			bg.insets.bottom = 6
			slider:SetBackdrop(bg)
			bg.insets = del(bg.insets)
			bg = del(bg)
			slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])

			local text = slider:CreateFontString(slider:GetName() .. "_LowText", "ARTWORK", "GameFontHighlightSmall")
			slider.lowText = text
			text:SetText("0%")
			text:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
			local text = slider:CreateFontString(slider:GetName() .. "_HighText", "ARTWORK", "GameFontHighlightSmall")
			slider.highText = text
			text:SetText("100%")
			text:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)

			-- edit box is made so that someone can type in easily
			local editBox = CreateFrame("EditBox", frame:GetName() .. "_EditBox", frame)
			frame.editBox = editBox
			editBox:SetFontObject(ChatFontNormal)
			editBox:SetHeight(17)
			editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, 0)
			editBox:SetText("50%")
			editBox:SetJustifyH("CENTER")
			editBox:SetWidth(48)

			slider:SetPoint("RIGHT", editBox, "LEFT", -1, 0)

			styleEditBox(editBox)

			editBox:SetAutoFocus(false)
			editBox:SetScript("OnEscapePressed", editBox_OnEscapePressed)
			editBox:SetScript("OnEnterPressed", editBox_OnEnterPressed)

			editBox:SetScript("OnEditFocusGained", editBox_OnEditFocusGained)
			editBox:SetScript("OnEditFocusLost", editBox_OnEditFocusLost)

			frame.type = 'number'
			slider:SetValueStep(epsilon)
			slider:SetScript("OnValueChanged", slider_OnValueChanged)
			slider:SetScript("OnMouseDown", slider_OnMouseDown)
			slider:SetScript("OnMouseUp", slider_OnMouseUp)
			frame:SetScript("OnMouseWheel", frame_OnMouseWheel)

			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			slider:SetScript("OnEnter", SubControl_OnEnter)
			slider:SetScript("OnLeave", SubControl_OnLeave)
			editBox:SetScript("OnEnter", SubControl_OnEnter)
			editBox:SetScript("OnLeave", SubControl_OnLeave)
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable
			frame.IsEnabled = frame_IsEnabled

			return frame
		end

		-- fetch and set up a slider
		function getNumberControl(path, parent)
			local frame = _getNumberControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local min = getConfigField(frame, 'min', false, 0, "number")
			local max = getConfigField(frame, 'max', false, 1, "number")
			local value = getConfigField(frame, 'get', false, (min + max)/2, "number")
			local step = getConfigField(frame, 'step', false, (max - min)/100, "number")
			local bigStep = getConfigField(frame, 'bigStep', false, step, "number")
			local stepBasis = getConfigField(frame, 'stepBasis', false, min, "number")
			local isPercent = getConfigField(frame, 'isPercent', false, true, "boolean")
			frame.slider:SetMinMaxValues(0, 1)
			frame.min = min
			frame.max = max
			frame.step = step
			frame.bigStep = bigStep
			frame.stepBasis = stepBasis
			frame.lastValue = value
			frame.isPercent = isPercent

			frame.changing = true

			if isPercent then
				frame.slider.lowText:SetText(min*100 .. "%")
				frame.slider.highText:SetText(max*100 .. "%")
			else
				frame.slider.lowText:SetText(min)
				frame.slider.highText:SetText(max)
			end

			frame.changing = nil
			fixSliderValue(frame)

			return frame
		end
	end

	local getColorControl, releaseColorControl
	do
		local pool = {}
		-- remove a color picker and put it in the pool
		function releaseColorControl(frame)
			frame:Hide()
			frame:Enable()
			if _G.CurrentlyCopiedColor then
				frame.pasteButton:Enable()
			end
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			pool[frame] = true
			return nil
		end

		-- seeing as it is multiple different frames, the width is computed dynamically to stretch across properly and smoothly.
		local function frame_SizeChanged(this, width)
			local extra = 3 --[[ space between hsl + rgb]] + 3 --[[ space on right]]
			local hasAlpha = this.hasAlpha
			local sliderWidth
			extra = extra + 3 -- space between rgb + alpha
			extra = extra + this.hueSlider.label:GetWidth()*3
			extra = extra + this.hueSlider.editBox:GetWidth()*3
			sliderWidth = (width - extra)/3 - 7

			this.hueSlider:SetWidth(sliderWidth + 7)
			for i = 1, 6 do
				this.hueSlider["gradient" .. i]:SetWidth(sliderWidth/6)
			end
			this.hueSlider.checkers:SetWidth(sliderWidth)
			this.lumSlider:SetWidth(sliderWidth + 7)
			for i = 1, 2 do
				this.lumSlider["gradient" .. i]:SetWidth(sliderWidth/2)
			end
			this.lumSlider.checkers:SetWidth(sliderWidth)
			local tmp = newList('satSlider', 'redSlider', 'greenSlider', 'blueSlider')
			if hasAlpha then
				tmp[#tmp+1] = 'alphaSlider'
			end
			for i,v in ipairs(tmp) do
				local slider = this[v]
				slider:SetWidth(sliderWidth + 7)
				slider.gradient:SetWidth(sliderWidth)
				slider.checkers:SetWidth(sliderWidth)
			end
			tmp = del(tmp)
		end

		local colorControlsDisabled = {}
		-- fake enable check
		local function frame_IsEnabled(this)
			return colorControlsDisabled[this] and 0 or 1
		end
		-- fake disable function, turn things gray, turn off the mouse
		local function frame_Disable(this)
			if colorControlsDisabled[this] then
				return
			end
			colorControlsDisabled[this] = true
			local tmp = newList("hue", "sat", "lum", "red", "green", "blue", "alpha")
			for i,v in ipairs(tmp) do
				local slider = this[v .. "Slider"]
				slider.label:SetFontObject(GameFontDisable)
				slider.editBox:SetTextColor(0.5, 0.5, 0.5)
				recolorEditBoxStyle(slider.editBox, 0.5, 0.5, 0.5, 1)
				slider:EnableMouse(false)
				slider.editBox:EnableMouse(false)
			end
			tmp = del(tmp)
			this.copyButton:Disable()
			this.pasteButton:Disable()
			this.label:Disable()
		end
		-- fake enable function, turn things normal color, turn on the mouse
		local function frame_Enable(this)
			if not colorControlsDisabled[this] then
				return
			end
			colorControlsDisabled[this] = nil
			local tmp = newList("hue", "sat", "lum", "red", "green", "blue", "alpha")
			for i,v in ipairs(tmp) do
				local slider = this[v .. "Slider"]
				slider.label:SetFontObject(GameFontNormal)
				slider.editBox:SetTextColor(1, 1, 1)
				recolorEditBoxStyle(slider.editBox, 1, 1, 1, 1)
				slider:EnableMouse(true)
				slider.editBox:EnableMouse(true)
			end
			tmp = del(tmp)
			this.copyButton:Enable()
			if _G.CurrentlyCopiedColor then
				this.pasteButton:Enable()
			end
			this.label:Enable()
		end

		-- helper function for hsl2rgb
		local function func(v1, v2, h)
			if h < 0 then
				h = h + 1
			elseif h > 1 then
				h = h - 1
			end
			if h < 1/6 then
				return v1 + (v2 - v1) * 6 * h
			elseif h < 1/2 then
				return v2
			elseif h < 2/3 then
				return v1 + (v2 - v1) * (2/3 - h) * 6
			else
				return v1
			end
		end

		-- convert HSL to RGB
		-- h is [0, 360], rest is [0, 1]
		local function hsl2rgb(h, s, l)
			if s == 0 then
				return l, l, l
			end

			h = h / 360

			local v2
			if l < 0.5 then
				v2 = l * (1+s)
			else
				v2 = (l + s) - (s * l)
			end
			local v1 = 2*l - v2

			local r = func(v1, v2, h + 1/3)
			local g = func(v1, v2, h)
			local b = func(v1, v2, h - 1/3)
			return r, g, b
		end

		-- convert RGB to HSL
		-- inputs are [0, 1]
		local function rgb2hsl(r, g, b)
			local min = math_min(r, g, b)
			local max = math_max(r, g, b)
			local delta = max - min

			local l = (max + min)/2

			if delta == 0 then
				return 0, 0, l
			end

			local s
			if l < 0.5 then
				s = delta / (max + min)
			else
				s = delta / (2 - max - min)
			end

			local deltaR = (max - r)/(6*delta) + 1/2
			local deltaG = (max - g)/(6*delta) + 1/2
			local deltaB = (max - b)/(6*delta) + 1/2

			local h
			if r == max then
				h = deltaB - deltaG
			elseif g == max then
				h = 1/3 + deltaR - deltaB
			elseif b == max then
				h = 2/3 + deltaG - deltaR
			end
			if h < 0 then
				h = h + 1
			elseif h > 1 then
				h = h - 1
			end

			return h*360, s, l
		end

		-- fix the colors of the sliders to reflect changes
		local function refixColors(frame, useRGB)
			local h, s, l, r, g, b
			if not useRGB then
				h = frame.hueSlider:GetValue()
				s = frame.satSlider:GetValue()
				l = frame.lumSlider:GetValue()
				r, g, b = hsl2rgb(h, s, l)
			else
				r = frame.redSlider:GetValue()/255
				g = frame.greenSlider:GetValue()/255
				b = frame.blueSlider:GetValue()/255
				h, s, l = rgb2hsl(r, g, b)
			end

			local hasAlpha = frame.hasAlpha
			local a = hasAlpha and frame.alphaSlider:GetValue() or 1

			frame.swatch:SetVertexColor(r, g, b, a)

			local r1, g1, b1 = hsl2rgb(0, s, l)
			local r2, g2, b2 = hsl2rgb(60, s, l)
			frame.hueSlider.gradient1:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(120, s, l)
			frame.hueSlider.gradient2:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(180, s, l)
			frame.hueSlider.gradient3:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(240, s, l)
			frame.hueSlider.gradient4:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(300, s, l)
			frame.hueSlider.gradient5:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(0, s, l)
			frame.hueSlider.gradient6:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			frame.hueSlider.editBox:SetText(math_floor(h + 0.5) .. "º")

			local r1, g1, b1 = hsl2rgb(h, 0, l)
			local r2, g2, b2 = hsl2rgb(h, 1, l)
			frame.satSlider.gradient:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			frame.satSlider.editBox:SetText(math_floor(s*100 + 0.5) .. "%")

			local r1, g1, b1 = hsl2rgb(h, s, 0)
			local r2, g2, b2 = hsl2rgb(h, s, 0.5)
			frame.lumSlider.gradient1:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			local r1, g1, b1 = r2, g2, b2
			local r2, g2, b2 = hsl2rgb(h, s, 1)
			frame.lumSlider.gradient2:SetGradientAlpha("HORIZONTAL", r1, g1, b1, a, r2, g2, b2, a)
			frame.lumSlider.editBox:SetText(math_floor(l*100 + 0.5) .. "%")

			frame.redSlider.gradient:SetGradientAlpha("HORIZONTAL", 0, g, b, a, 1, g, b, a)
			frame.redSlider.editBox:SetText(math_floor(r*255 + 0.5))
			frame.greenSlider.gradient:SetGradientAlpha("HORIZONTAL", r, 0, b, a, r, 1, b, a)
			frame.greenSlider.editBox:SetText(math_floor(g*255 + 0.5))
			frame.blueSlider.gradient:SetGradientAlpha("HORIZONTAL", r, g, 0, a, r, g, 1, a)
			frame.blueSlider.editBox:SetText(math_floor(b*255 + 0.5))
			if hasAlpha then
				frame.alphaSlider.gradient:SetGradientAlpha("HORIZONTAL", r, g, b, 0, r, g, b, 1)
				frame.alphaSlider.editBox:SetText(math_floor(a*100 + 0.5) .. "%")
			end
		end

		local changed = false
		-- save results, refresh
		local function save(frame)
			if not changed then
				return
			end
			changed = false
			local r, g, b, a = frame.redSlider:GetValue()/255, frame.greenSlider:GetValue()/255, frame.blueSlider:GetValue()/255, frame.alphaSlider:GetValue()

			local colorType = frame.colorType
			local t
			if colorType == "tuple" then
				t = newList(r, g, b)
			elseif colorType == "tuple:rgba" then
				t = newList(r, g, b, a)
			elseif colorType == "tuple:argb" then
				t = newList(r, g, b, a)
			elseif colorType == "hex:rgba" or colorType == "hex:argb" or colorType == "hex" then
				if colorType == "hex" then
					t = newList(("%02x%02x%02x"):format(r*255, g*255, b*255))
				elseif colorType == "hex:rgba" then
					t = newList(("%02x%02x%02x%02x"):format(r*255, g*255, b*255, a*255))
				else
					t = newList(("%02x%02x%02x%02x"):format(a*255, r*255, g*255, b*255))
				end
			elseif colorType == "number" then
				t = newList(math_floor(r*255 * 256^2 + 0.5) + math_floor(g*255 * 256 + 0.5) + math_floor(b * 256 + 0.5))
			else
				-- should never occur
				error(("Unknown colorType: %q"):format(tostring(colorType)))
			end
			callConfigField(frame, 'set', t)
			t = del(t)

			refreshConfigMenu(frame[1])
		end

		local changing = false
		-- change colors, set a flag so that the data will be saved when the mouse is let go.
		local function slider_OnValueChanged(this, value)
			if changing then
				return
			end
			changing = true
			local frame = this:GetParent()
			local kind = this.kind
			if kind == "red" or kind == "green" or kind == "blue" then
				local r, g, b = frame.redSlider:GetValue()/255, frame.greenSlider:GetValue()/255, frame.blueSlider:GetValue()/255
				local h, s, l = rgb2hsl(r, g, b)
				frame.hueSlider:SetValue(h)
				frame.satSlider:SetValue(s)
				frame.lumSlider:SetValue(l)
			elseif kind == "hue" or kind == "sat" or kind == "lum" then
				local h, s, l = frame.hueSlider:GetValue(), frame.satSlider:GetValue(), frame.lumSlider:GetValue()
				local r, g, b = hsl2rgb(h, s, l)
				frame.redSlider:SetValue(r*255)
				frame.greenSlider:SetValue(g*255)
				frame.blueSlider:SetValue(b*255)
			end
			refixColors(frame)
			changing = false

			changed = value
		end
		-- if the data has changed, save
		local function slider_OnMouseUp(this)
			save(this:GetParent())
		end

		-- mousewheel changes a slider by one step
		local function slider_OnMouseWheel(this, change)
			if nextFreeScroll > GetTime() then
				base.mainPane.scrollFrame:GetScript("OnMouseWheel")(base.mainPane.scrollFrame, change)
				return
			end
			local value = this:GetValue()
			local step = this:GetValueStep()
			local min, max = this:GetMinMaxValues()
			if change > 0 then
				value = value + step
				if value > max then
					value = max
				end
			else
				value = value - step
				if value < min then
					value = min
				end
			end
			if value ~= this:GetValue() then
				this:SetValue(value)
			end
			save(this:GetParent())
		end

		-- if escape is presed, change the text to the original
		local function editBox_OnEscapePressed(this)
			this:ClearFocus()
		end
		-- if enter is pressed, update the slider, save
		local function editBox_OnEnterPressed(this)
			local value = this:GetNumber()
			this:ClearFocus()
			local min, max = this:GetParent():GetMinMaxValues()
			local step = this:GetParent():GetValueStep()
			if min == 0 and max == 1 then
				-- percentage
				value = value / 100
			end

			if value < min then
				value = min
			elseif value > max then
				value = max
			end

			this:GetParent():SetValue(value)

			save(this:GetParent():GetParent())
		end

		-- on focus, if the text ends in percent or degree, remove those
		local function editBox_OnEditFocusGained(this)
			if this:GetParent():GetParent():IsEnabled() ~= 1 then
				this:ClearFocus()
				return
			end
			local text = this:GetText()
			if text:find("%%$") then
				this:SetText(text:sub(1, -2))
			elseif text:find("\194\186$") then -- degree
				this:SetText(text:sub(1, -3))
			end
		end
		-- fix the colors as well as the text if focus is lost
		local function editBox_OnEditFocusLost(this)
			refixColors(this:GetParent():GetParent())
		end

		-- when pressed, the button should look pressed
		local function button_OnMouseDown(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			end
		end
		-- when depressed, return to normal
		local function button_OnMouseUp(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			end
		end

		local function copyButton_OnClick(this)
			local CurrentlyCopiedColor = _G.CurrentlyCopiedColor
			if not CurrentlyCopiedColor then
				CurrentlyCopiedColor = {}
				_G.CurrentlyCopiedColor = CurrentlyCopiedColor
			end
			for k in pairs(CurrentlyCopiedColor) do
				CurrentlyCopiedColor[k] = nil
			end
			local parent = this:GetParent()
			CurrentlyCopiedColor.r = (parent.redSlider:GetValue() or 255)/255
			CurrentlyCopiedColor.g = (parent.greenSlider:GetValue() or 255)/255
			CurrentlyCopiedColor.b = (parent.blueSlider:GetValue() or 255)/255
			CurrentlyCopiedColor.a = parent.alphaSlider:IsShown() and parent.alphaSlider:GetValue() or 1

			refreshConfigMenu(parent[1])
		end

		local function pasteButton_OnClick(this)
			changing = true
			local frame = this:GetParent()
			local CurrentlyCopiedColor = _G.CurrentlyCopiedColor
			frame.redSlider:SetValue(CurrentlyCopiedColor.r*255)
			frame.greenSlider:SetValue(CurrentlyCopiedColor.g*255)
			frame.blueSlider:SetValue(CurrentlyCopiedColor.b*255)
			if frame.alphaSlider:IsShown() then
				frame.alphaSlider:SetValue(CurrentlyCopiedColor.a)
			end
			changing = false

			changed = true
			save(frame)
		end

		local function button_Disable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this:__Disable()
			this:EnableMouse(false)
		end

		local function button_Enable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this:__Enable()
			this:EnableMouse(true)
		end

		local colorControlNum = 0
		-- create a color picker
		local function _getColorControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			colorControlNum = colorControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_ColorControl" .. colorControlNum, mainPane.scrollChild)

			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			frame:EnableMouse(true)
			frame.SizeChanged = frame_SizeChanged

			local tmp = newList("hue", "sat", "lum", "red", "green", "blue", "alpha")
			local tmp_max = newList(359, 1, 1, 255, 255, 255, 1)
			local tmp_step = newList(1, 0.01, 0.01, 1, 1, 1, 0.01)
			local tmp_label = newList("H", "S", "L", "R", "G", "B", "A")
			local maxLabelWidth = 0
			for i, v in ipairs(tmp) do
				-- make a slider for each value
				local slider = CreateFrame("Slider", frame:GetName() .. "_" .. v .. "Slider", frame)
				frame[v .. "Slider"] = slider
				slider.kind = v
				slider:SetMinMaxValues(0, tmp_max[i])
				slider:SetValue(tmp_max[i])
				slider:SetValueStep(tmp_step[i])
				slider:SetOrientation("HORIZONTAL")
				slider:SetHeight(16)
				slider:SetWidth(71)
				slider:SetScript("OnValueChanged", slider_OnValueChanged)
				slider:SetScript("OnMouseUp", slider_OnMouseUp)
				slider:EnableMouseWheel(true)
				slider:SetScript("OnMouseWheel", slider_OnMouseWheel)

				slider:SetScript("OnEnter", SubControl_OnEnter)
				slider:SetScript("OnLeave", SubControl_OnLeave)

				local label = slider:CreateFontString(slider:GetName() .. "_Label", "ARTWORK", "GameFontNormal")
				slider.label = label
				label:SetText(tmp_label[i])
				local label_width = label:GetWidth()
				if label_width > maxLabelWidth then
					maxLabelWidth = label_width
				end
				label:SetHeight(16)
				label:SetJustifyH("RIGHT")
				slider:SetPoint("LEFT", label, "RIGHT")

				if v ~= "hue" and v ~= "lum" then
					-- hue requires 6 gradients, lum requires 2
					local gradient = slider:CreateTexture(slider:GetName() .. "_Gradient", "ARTWORK")
					slider.gradient = gradient
					gradient:SetHeight(16)
					gradient:SetWidth(64)
					gradient:SetPoint("CENTER", slider, "CENTER")
					gradient:SetTexture([[Interface\Buttons\WHITE8X8]])
					gradient:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 1, 1, 1, 1)
				end

				-- the checkers are shown behind, so that alpha colors can show.
				local checkers = slider:CreateTexture(slider:GetName() .. "_Checkers", "BACKGROUND")
				slider.checkers = checkers
				checkers:SetHeight(16)
				checkers:SetWidth(64)
				checkers:SetPoint("CENTER")
				checkers:SetTexture([[Tileset\Generic\Checkers]])
				checkers:SetDesaturated(true)
				checkers:SetTexCoord(0, 1, 0, 0.25)
				checkers:SetVertexColor(1, 1, 1, 0.75)

				local thumb = slider:CreateTexture(slider:GetName() .. "_Thumb")
				slider.thumb = thumb
				thumb:SetWidth(7)
				thumb:SetHeight(24)
				thumb:SetTexture([[Interface\Buttons\UI-ColorPicker-Buttons]])
				thumb:SetTexCoord(0.25, 0.875, 1, 0.875, 0.25, 0, 1, 0)
				slider:SetThumbTexture(thumb)

				-- edit box is available so people can type in the value they want
				local editBox = CreateFrame("EditBox", slider:GetName() .. "_EditBox", slider)
				slider.editBox = editBox
				editBox:SetFontObject(ChatFontNormal)
				editBox:SetHeight(17)
				editBox:SetPoint("LEFT", slider, "RIGHT", 0, 0)
				editBox:SetText("100%")
				editBox:SetJustifyH("CENTER")
				editBox:SetWidth(36)
				editBox:SetTextInsets(-5, -5, 0, 0)

				editBox:SetScript("OnEnter", SubControl_OnEnter)
				editBox:SetScript("OnLeave", SubControl_OnLeave)

				styleEditBox(editBox)

				editBox:SetAutoFocus(false)
				editBox:SetScript("OnEscapePressed", editBox_OnEscapePressed)
				editBox:SetScript("OnEnterPressed", editBox_OnEnterPressed)

				editBox:SetScript("OnEditFocusGained", editBox_OnEditFocusGained)
				editBox:SetScript("OnEditFocusLost", editBox_OnEditFocusLost)
			end
			for i,v in ipairs(tmp) do
				local slider = frame[v .. "Slider"]
				local label = slider.label
				label:SetWidth(maxLabelWidth)
			end
			tmp = del(tmp)
			tmp_max = del(tmp_max)
			tmp_step = del(tmp_step)
			tmp_label = del(tmp_label)
			local hueSlider = frame.hueSlider
			for i = 1, 6 do
				-- hue requires 6 gradients because the progression isn't linear on an RGB scale.
				local gradient = hueSlider:CreateTexture(hueSlider:GetName() .. "_Gradient" .. i, "ARTWORK")
				hueSlider["gradient" .. i] = gradient
				gradient:SetHeight(16)
				gradient:SetWidth(64 / 6)
				if i == 1 then
					gradient:SetPoint("LEFT", hueSlider, "LEFT", 3.5, 0)
				else
					gradient:SetPoint("LEFT", hueSlider["gradient" .. (i-1)], "RIGHT")
				end
				gradient:SetTexture([[Interface\Buttons\WHITE8X8]])
				gradient:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 1, 1, 1, 1)
			end
			local lumSlider = frame.lumSlider
			for i = 1, 2 do
				-- lum requires 2 gradients because the progression isn't linear on an RGB scale.
				local gradient = lumSlider:CreateTexture(lumSlider:GetName() .. "_Gradient" .. i, "ARTWORK")
				lumSlider["gradient" .. i] = gradient
				gradient:SetHeight(16)
				gradient:SetWidth(64 / 2)
				if i == 1 then
					gradient:SetPoint("LEFT", lumSlider, "LEFT", 3.5, 0)
				else
					gradient:SetPoint("LEFT", lumSlider["gradient" .. (i-1)], "RIGHT")
				end
				gradient:SetTexture([[Interface\Buttons\WHITE8X8]])
				gradient:SetGradientAlpha("HORIZONTAL", 0, 0, 0, 0, 1, 1, 1, 1)
			end

			local swatch = frame:CreateTexture(frame:GetName() .. "_Swatch", "ARTWORK")
			frame.swatch = swatch
			swatch:SetWidth(32)
			swatch:SetHeight(32)
			swatch:SetTexture([[Interface\Buttons\WHITE8X8]])
			swatch:SetVertexColor(1, 1, 1, 1)

			local swatchUnder = frame:CreateTexture(frame:GetName() .. "_SwatchUnder", "BACKGROUND")
			frame.swatchUnder = swatchUnder
			swatchUnder:SetWidth(32)
			swatchUnder:SetHeight(32)
			swatchUnder:SetPoint("CENTER", swatch, swatch)
			swatchUnder:SetTexture([[Tileset\Generic\Checkers]])
			swatchUnder:SetDesaturated(true)
			swatchUnder:SetTexCoord(0, 0.5, 0, 0.5)
			swatchUnder:SetVertexColor(1, 1, 1, 0.75)

			for i = 1, 2 do
				local button = CreateFrame("Button", frame:GetName() .. (i == 1 and "_button" or "_PasteButton"), frame)
				if i == 1 then
					frame.copyButton = button
				else
					frame.pasteButton = button
				end
				local left = button:CreateTexture(button:GetName() .. "_LeftTexture", "BACKGROUND")
				button.left = left
				local middle = button:CreateTexture(button:GetName() .. "_MiddleTexture", "BACKGROUND")
				button.middle = middle
				local right = button:CreateTexture(button:GetName() .. "_RightTexture", "BACKGROUND")
				button.right = right
				left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

				left:SetPoint("TOPLEFT")
				left:SetPoint("BOTTOMLEFT")
				left:SetWidth(12)
				left:SetTexCoord(0, 0.09375, 0, 0.6875)

				right:SetPoint("TOPRIGHT")
				right:SetPoint("BOTTOMRIGHT")
				right:SetWidth(12)
				right:SetTexCoord(0.53125, 0.625, 0, 0.6875)

				middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
				middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
				middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)

				button:SetScript("OnMouseDown", button_OnMouseDown)
				button:SetScript("OnMouseUp", button_OnMouseUp)

				local text = button:CreateFontString(button:GetName() .. "_FontString", "ARTWORK")
				button:SetFontString(text)
				button.text = text
				text:SetPoint("LEFT", button, "LEFT", 7, 0)
				text:SetPoint("RIGHT", button, "RIGHT", -7, 0)

				button[SET_NORMAL_FONT_OBJECT](button, GameFontNormal)
				button:SetHighlightFontObject(GameFontHighlight)
				button:SetDisabledFontObject(GameFontDisable)

				if i == 1 then
					text:SetText(COPY)
				else
					text:SetText(PASTE)
				end

				local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY", "UIPanelButtonHighlightTexture")
				button:SetHighlightTexture(highlight)

				button:SetScript("OnClick", i == 1 and copyButton_OnClick or pasteButton_OnClick)
				button:SetScript("OnEnter", SubControl_OnEnter)
				button:SetScript("OnLeave", SubControl_OnLeave)

				button.__Disable = button.Disable
				button.__Enable = button.Enable
				button.Disable = button_Disable
				button.Enable = button_Enable

				if i == 1 then
					button:SetPoint("TOPLEFT", swatch, "TOPRIGHT", 3, 2)
				else
					button:SetPoint("BOTTOMLEFT", swatch, "BOTTOMRIGHT", 3, -2)
				end
				button:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
				button:SetHeight(18)
			end

			hueSlider.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
			frame.satSlider.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -19)
			lumSlider.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -38)
			frame.redSlider.label:SetPoint("LEFT", hueSlider.editBox, "RIGHT", 3, 0)
			frame.greenSlider.label:SetPoint("LEFT", frame.satSlider.editBox, "RIGHT", 3, 0)
			frame.blueSlider.label:SetPoint("LEFT", lumSlider.editBox, "RIGHT", 3, 0)
			frame.alphaSlider.label:SetPoint("LEFT", frame.redSlider.editBox, "RIGHT", 3, 0)

			frame.IsEnabled = frame_IsEnabled
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable

			frame.type = 'color'
			frame:SetHeight(64)

			refixColors(frame)
			return frame
		end

		local t = {}
		for i = 0, 9 do
			t[tostring(i):byte()] = i
		end
		do
			local a_byte = ('a'):byte()
			local A_byte = ('A'):byte()
			for i = 10, 15 do
				t[a_byte+i-10] = i
				t[A_byte+i-10] = i
			end
		end
		-- turn hexadecimal (0-9, A-F) bytes into a number [0, 255]
		local function hexBytesToNumber(alpha, bravo)
			local alpha_num = t[alpha] or 15
			local bravo_num = t[bravo] or 15

			return alpha_num*16 + bravo_num
		end
		-- make sure that a value is within the given range
		local function fixRange(num, min, max)
			if not num or not min or not max then
				return num
			end
			if num < min then
				return min
			elseif num > max then
				return max
			else
				return num
			end
		end

		-- fetch and set up a color picker
		function getColorControl(path, parent)
			local frame = _getColorControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local hasAlpha = not not getConfigField(frame, 'hasAlpha', false, true, "boolean")
			frame.hasAlpha = hasAlpha
			local colorType = getConfigField(frame, 'colorType', false, hasAlpha and "tuple:rgba" or "tuple", "string")
			frame.colorType = colorType
			if hasAlpha then
				if colorType ~= "tuple:rgba" and colorType ~= "hex:rgba" and colorType ~= "tuple:argb" and colorType ~= "hex:argb" then
					error(("%s: Bad result from field %q for `%s'. Expected %q, %q, %q, or %q, got %q."):format(MAJOR_VERSION, 'colorType', getPathString(frame), "tuple:rgba", "hex:rgba", "tuple:argb", "hex:argb", colorType))
				end
			else
				if colorType ~= "tuple" and colorType ~= "hex" and colorType ~= "number" then
					error(("%s: Bad result from field %q for `%s'. Expected %q, %q, or %q, got %q."):format(MAJOR_VERSION, 'colorType', getPathString(frame), "tuple", "hex", "number", colorType))
				end
			end
			local c1, c2, c3, c4 = getConfigField(frame, 'get', false, false)
			local r, g, b, a
			if colorType == "tuple" then
				r, g, b = c1, c2, c3
			elseif colorType == "tuple:rgba" then
				r, g, b, a = c1, c2, c3, c4
			elseif colorType == "tuple:argb" then
				a, r, g, b = c1, c2, c3, c4
			elseif colorType == "hex:rgba" or "hex:argb" or colorType == "hex" then
				if type(c1) ~= "string" then
					error(("%s: Bad result from field %q for `%s'. Expected %q, got %q."):format(MAJOR_VERSION, 'get', getPathString(path), "string", type(c1)))
				end
				local n = hasAlpha and 8 or 6
				if #c1 ~= n then
					error(("%s: Bad result from field %q for `%s'. Expected %d-byte string, got %d-byte string."):format(MAJOR_VERSION, 'get', getPathString(path), n, #c1))
				end
				local r1, r2, g1, g2, b1, b2, a1, a2
				if colorType == "hex" then
					r1, r2, g1, g2, b1, b2 = c1:byte(1, 6)
				elseif colorType == "hex:rgba" then
				 	r1, r2, g1, g2, b1, b2, a1, a2 = c1:byte(1, 8)
				else -- hex:argb
					a1, a2, r1, r2, g1, g2, b1, b2 = c1:byte(1, 8)
				end
				r, g, b, a = hexBytesToNumber(r1, r2), hexBytesToNumber(g1, g2), hexBytesToNumber(b1, b2), hasAlpha and hexBytesToNumber(a1, a2)

				r, g, b, a = r/255, g/255, b/255, hasAlpha and a/255
			else -- number
				if type(c1) ~= "number" then
					error(("%s: Bad result from field %q for `%s'. Expected %q, got %q."):format(MAJOR_VERSION, 'get', getPathString(path), "number", type(c1)))
				end
				r = math_floor(c1/256^2)
				g = math_floor(c1/256) % 256
				b = math_floor(c1) % 256
			end
			r, g, b, a = fixRange(r, 0, 1) or 1, fixRange(g, 0, 1) or 1, fixRange(b, 0, 1) or 1, hasAlpha and fixRange(a, 0, 1) or 1

			changing = true
			local h, s, l = rgb2hsl(r, g, b)
			frame.hueSlider:SetValue(h)
			frame.satSlider:SetValue(s)
			frame.lumSlider:SetValue(l)
			frame.redSlider:SetValue(r*255)
			frame.greenSlider:SetValue(g*255)
			frame.blueSlider:SetValue(b*255)
			frame.swatch:ClearAllPoints()
			if hasAlpha then
				frame.alphaSlider:Show()
				frame.alphaSlider:SetValue(a)
				frame.swatch:SetPoint("TOPLEFT", frame.alphaSlider, "BOTTOMLEFT", 4, -6)
			else
				frame.alphaSlider:Hide()
				frame.swatch:SetPoint("LEFT", frame.greenSlider.editBox, "RIGHT", 3, 0)
			end

			if not _G.CurrentlyCopiedColor then
				frame.pasteButton:Disable()
			else
				local CurrentlyCopiedColor = _G.CurrentlyCopiedColor
				frame.pasteButton.text:SetTextColor(CurrentlyCopiedColor.r, CurrentlyCopiedColor.g, CurrentlyCopiedColor.b, hasAlpha and CurrentlyCopiedColor.a or 1)
			end
			changing = false

			refixColors(frame, true)

			return frame
		end
	end

	local getChoiceControl, releaseChoiceControl
	do
		local pool = {}
		-- remove a choice dropdown and put it in the pool
		function releaseChoiceControl(frame)
			frame:Hide()
			frame:Enable()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			frame.value = nil
			if frame.values then
				frame.values = del(frame.values)
			end
			frame.text.icon:SetTexture(nil)
			frame.text.icon:SetWidth(epsilon)
			frame.text.icon:SetHeight(16)
			pool[frame] = true
			return nil
		end

		local choiceControlsDisabled = {}
		-- fake check enable function
		local function frame_IsEnabled(this)
			return choiceControlsDisabled[this] and 0 or 1
		end
		-- fake enable function, enable the mouse, turn normal color
		local function frame_Enable(this)
			if not choiceControlsDisabled[this] then
				return
			end
			choiceControlsDisabled[this] = nil

			this.text.fs:SetTextColor(1, 1, 1)
			this.button:Enable()
			this.button:EnableMouse(true)
			this.label:Enable()
		end
		-- fake disable function, disable the mouse, turn gray
		local function frame_Disable(this)
			if choiceControlsDisabled[this] then
				return
			end
			choiceControlsDisabled[this] = true

			this.text.fs:SetTextColor(0.5, 0.5, 0.5)
			this.button:Disable()
			this.button:EnableMouse(false)
			this.label:Disable()
		end

		-- toggle the pullout menu
		local function button_OnClick(this)
			if makePullout then
				makePullout()
			end
			local shown = pullout:IsShown()
			pullout:Hide()
			local parent = this:GetParent()
			if pullout.parent == parent and shown then
				-- click to hide after it's been opened
				return
			end
			pullout.parent = parent
			pullout:SetFrameStrata("FULLSCREEN_DIALOG")
			pullout:SetPoint("TOP", parent.text, "BOTTOM")
			pullout:SetPoint("LEFT", parent.text, "LEFT")
			pullout:SetPoint("RIGHT", parent.text, "RIGHT")
			pullout:Show()
			pullout:SetHeight(50)

			buildPullout(parent)
		end

		local function text_OnClick(this)
			this:GetParent().button:Click()
		end

		-- if the control is hidden and the pullout is set to it, remove that relationship
		local function frame_OnHide(this)
			if pullout and pullout.parent == this then
				pullout:Hide()
				pullout.parent = nil
			end
		end

		local choiceControlNum = 0
		-- create a preliminary choice dropdown
		local function _getChoiceControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			choiceControlNum = choiceControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_ChoiceControl" .. choiceControlNum, mainPane.scrollChild)
			frame.IsEnabled = frame_IsEnabled
			frame.Enable = frame_Enable
			frame.Disable = frame_Disable
			frame:EnableMouse(true)
			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			frame:SetScript("OnHide", frame_OnHide)

			local text = CreateFrame("Button", frame:GetName() .. "_Text", frame)
			frame.text = text
			local fs = text:CreateFontString(text:GetName() .. "_FontString", "OVERLAY", "ChatFontNormal")
			text.fs = fs
			fs:SetJustifyH("LEFT")
			text:SetHeight(24)
			text:SetScript("OnEnter", SubControl_OnEnter)
			text:SetScript("OnLeave", SubControl_OnLeave)
			local bg = newList()
			bg.bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]
			bg.edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]]
			bg.tile = true
			bg.edgeSize = 16
			bg.tileSize = 16
			bg.insets = newList()
			bg.insets.left = 3
			bg.insets.right = 3
			bg.insets.top = 3
			bg.insets.bottom = 3
			text:SetBackdrop(bg)
			bg.insets = del(bg.insets)
			bg = del(bg)
			text:SetBackdropColor(0, 0, 0)

			local icon = text:CreateTexture(text:GetName() .. "_Icon", "ARTWORK")
			text.icon = icon
			icon:SetWidth(epsilon)
			icon:SetHeight(16)
			icon:SetPoint("LEFT", 5, 0)
			fs:SetPoint("LEFT", icon, "RIGHT", 0, 0)
			fs:SetPoint("RIGHT", -5, 0)

			local texture = text:CreateTexture(text:GetName() .. "_Texture", "ARTWORK")
			text.texture = texture
			texture:SetVertexColor(1, 1, 1, 0.5)
			texture:SetPoint("LEFT", icon, "RIGHT", 0, 0)
			texture:SetPoint("RIGHT", -5, 0)
			texture:SetPoint("TOP", 0, -4)
			texture:SetPoint("BOTTOM", 0, 4)

			text:SetPoint("LEFT")

			local button = CreateFrame("Button", frame:GetName() .. "_Button", frame)
			frame.button = button
			text:SetPoint("RIGHT", button, "LEFT")
			button:SetWidth(24)
			button:SetHeight(24)
			button:SetScript("OnEnter", SubControl_OnEnter)
			button:SetScript("OnLeave", SubControl_OnLeave)
			button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			button:GetNormalTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
			button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			button:GetPushedTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
			button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
			button:GetDisabledTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
			button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
			button:GetHighlightTexture():SetTexCoord(0.09, 0.91, 0.09, 0.91)
			button:SetPoint("RIGHT")
			button:SetScript("OnClick", button_OnClick)
			text:SetScript("OnClick", text_OnClick)
			frame.type = 'choice'
			frame:SetHeight(24)

			return frame
		end

		-- fetch and set up a choice dropdown
		function getChoiceControl(path, isMulti, parent)
			local frame = _getChoiceControl()
			frame.text.texture:SetTexture(nil)

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end

			frame.isMulti = isMulti or nil
			local choices = getConfigField(frame, 'choices', false, false, "table")
			local choiceType = getConfigField(frame, 'choiceType', true, isList(choices) and "list" or "dict", "string")
			if not isMulti then
				-- set the text based on the single result
				local ret = getConfigField(frame, 'get', false, false)
				frame.value = ret
				if choiceType == "dict" then
					frame.text.fs:SetText(choices[ret])
				else
					frame.text.fs:SetText(ret)
				end

				if ret then
					local choiceIcons = getConfigField(frame, 'choiceIcons', false, true, "table")
					if choiceIcons and choiceIcons[ret] then
						frame.text.icon:SetWidth(16)
						local icon = choiceIcons[ret]
						frame.text.icon:SetTexture(icon)
						if icon and icon:find([[^Interface\Icons\]]) then
							frame.text.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
						else
							frame.text.icon:SetTexCoord(0, 1, 0, 1)
						end
					end

					local choiceFonts = getConfigField(frame, 'choiceFonts', false, true, "table")
					if choiceFonts and choiceFonts[ret] then
						local _, size, flags = ChatFontNormal:GetFont()
						frame.text.fs:SetFont(choiceFonts[ret], size, flags)
					else
						frame.text.fs:SetFont(ChatFontNormal:GetFont())
					end

					local choiceTextures = getConfigField(frame, 'choiceTextures', false, true, "table")
					if choiceTextures and choiceTextures[ret] then
						frame.text.texture:SetTexture(choiceTextures[ret])
					end
				end
			else
				-- set the text based on a concatenation of all the true values (or show None)
				local keys = newList()
				if choiceType == "dict" then
					for k,v in pairs(choices) do
						keys[#keys+1] = k
					end
					choiceSort__choices = choices
					table_sort(keys, choiceSort)
					choiceSort__choices = nil
				else
					for i,v in ipairs(choices) do
						keys[i] = v
					end
				end

				local values = newList()
				frame.values = values

				local t = newList()
				for _,k in ipairs(keys) do
					local tmp = newList(k)
					local success, ret = callConfigField(frame, 'get', tmp)
					if success and ret then
						if ret ~= "HALF" then
							values[k] = true
							if choiceType == "dict" then
								t[#t+1] = choices[k]
							else
								t[#t+1] = k
							end
						else
							values[k] = "HALF"
						end
					end
					tmp = del(tmp)
				end

				local s
				if #t == 0 then
					s = _G.NONE
				else
			 		s = table_concat(t, ", ")
				end
				frame.text.icon:SetWidth(epsilon)
				frame.text.fs:SetFont(ChatFontNormal:GetFont())
				frame.text.fs:SetText(s)
			end
			return frame
		end
	end

	local getStringControl, releaseStringControl
	do
		local pool = {}
		-- remove an edit box, put in the pool
		function releaseStringControl(frame)
			frame:Hide()
			frame:Enable()
			frame:ClearAllPoints()
			local editBox = frame.editBox
			if editBox:IsMultiLine() then
				editBox:SetMultiLine(false)
				editBox:SetScript("OnTextChanged", editBox_OnTextChanged)
				editBox:SetScript("OnEnterPressed", editBox_OnEnterPressed)
				editBox:ClearAllPoints()
				editBox:SetPoint("LEFT")
				editBox:SetPoint("TOP")
				editBox:SetPoint("BOTTOM")
				editBox:SetPoint("RIGHT")
				frame.saveButton:Hide()
				frame:SetHeight(24)
				frame.warning:Hide()
			end
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			frame.value = nil
			frame.validationIssue = nil
			pool[frame] = true
			return nil
		end

		-- show a tooltip on hover
		local function frame_OnEnter(this)
			local name = this.label.text:GetText()
			local desc = this.desc
			if not desc then
				desc = getConfigField(this, 'desc', true, false, "string")
				local usage = getConfigField(this, 'usage', true, false, "string")
				desc = desc .. "\n\n" .. USAGE_COLON .. usage
				this.desc = desc
			end
			if this.validationIssue then
				desc = desc .. "\n\n|cffff7f7f" .. this.validationIssue
			end
			showTooltip(this, name, desc, this:IsEnabled() ~= 1)
		end

		local stringControlsDisabled = {}
		-- fake enable check
		local function frame_IsEnabled(this)
			return stringControlsDisabled[this] and 0 or 1
		end
		-- fake disable method, turn gray and disable focus
		local function frame_Disable(this)
			if stringControlsDisabled[this] then
				return
			end
			stringControlsDisabled[this] = true
			this.editBox:SetTextColor(0.5, 0.5, 0.5, 1)
			recolorEditBoxStyle(this.editBox, 0.5, 0.5, 0.5, 1)
			this.editBox:EnableMouse(false)
			this.label:Disable()
		end
		-- fake disable method, turn white and enable focus ability
		local function frame_Enable(this)
			if not stringControlsDisabled[this] then
				return
			end
			stringControlsDisabled[this] = nil
			this.editBox:SetTextColor(1, 1, 1, 1)
			recolorEditBoxStyle(this.editBox, 1, 1, 1, 1)
			this.editBox:EnableMouse(true)
			this.label:Enable()
		end
		
		local hasFocus, lastText
		-- set the text back to default if focus is lost
		local function editBox_OnEditFocusLost(this)
			if hasFocus == this then
				hasFocus = nil
				lastText = nil
			end
			this:SetText(tostring(this:GetParent().value or ''))
		end
		local function editBox_OnEditFocusGained(this)
			hasFocus = this
			lastText = this:GetText()
		end
		-- clear focus on escape, reset to default
		local function editBox_OnEscapePressed(this)
			this:ClearFocus()
		end
		local dontCall = false
		
		local function stripColors__handler(x, y)
			if #x%2 == 0 then
				return x
			else
				return x .. y
			end
		end
		local function stripColors(text)
			return text:gsub("(|*)(|c%x%x%x%x%x%x%x%x)", stripColors__handler):gsub("(|*)(|r)", stripColors__handler)
		end
		
		local function highlight(this, text)
			if hasFocus == this and lastText ~= this:GetText() then
				dontCall = true
				local tmp = newList(text)
				local success, ret, problem = callConfigField(this:GetParent(), 'syntaxHighlighter', tmp, true)
				tmp = del(tmp)
				if success and ret then
					lastText = ret:gsub("(|*)|r", stripColors__handler)
					local position = this:GetCursorPosition()
					local skip = 0
					local colorText = this:GetText()
					for i = 1, position do
						if colorText:byte(i) == ("|"):byte() then
							if colorText:byte(i+1) == ("c"):byte() then
								skip = skip + 10
							elseif colorText:byte(i+1) == ("r"):byte() then
								skip = skip + 2
							end
						end
					end
					position = position - skip
					this:SetText(lastText)
					
					local betterPosition = 0
					for i = 1, position do
						betterPosition = betterPosition + 1
						while lastText:byte(betterPosition) == ("|"):byte() do
							if lastText:byte(betterPosition+1) == ("c"):byte() then
								betterPosition = betterPosition + 10
							elseif lastText:byte(betterPosition+1) == ("r"):byte() then
								betterPosition = betterPosition + 2
							else
								break
							end
						end
					end
					
					this:SetCursorPosition(betterPosition)
				end
				dontCall = false
			end
		end
		local function editBox_OnTextChanged(this, ...)
			if dontCall then
				return
			end
			local parent = this:GetParent()
			local text = stripColors(this:GetText() or '')
			local tmp = newList(text)
			local success, ret, problem = callConfigField(parent, 'validate', tmp, true)
			tmp = del(tmp)
			if success then
				if ret then
					parent.validationIssue = nil
					this:SetPoint("RIGHT", parent, "RIGHT")
					parent.warning:Hide()
				else
					parent.validationIssue = problem
					this:SetPoint("RIGHT", parent.warning, "LEFT")
					parent.warning:Show()
				end
				if GameTooltip:IsOwned(parent) then
					parent:GetScript("OnEnter")(parent)
				end
			end
			local tmp = newList(text)
			callConfigField(parent, 'onChange', tmp, true)
			tmp = del(tmp)
			
			highlight(this, text)
		end
		local fs = UIParent:CreateFontString(nil, "ARTWORK")
		local function editBox_OnMultilineTextChanged(this, ...)
			if dontCall then
				return
			end
			local parent = this:GetParent()
			local text = stripColors(this:GetText() or '')
			fs:SetFontObject(this:GetFontObject())
			fs:SetWidth(parent:GetWidth())
			fs:SetText(text)
			local height = fs:GetHeight() + 6
			if height < 42 then
				height = 42
			end
			parent:SetHeight(height + 18)
			local tmp = newList(text)
			local success, ret, problem = callConfigField(parent, 'validate', tmp, true)
			tmp = del(tmp)
			if success then
				if ret then
					parent.validationIssue = nil
					this:SetPoint("RIGHT", parent, "RIGHT")
					parent.warning:Hide()
				else
					parent.validationIssue = problem
					this:SetPoint("RIGHT", parent.warning, "LEFT")
					parent.warning:Show()
				end
				if GameTooltip:IsOwned(parent) then
					parent:GetScript("OnEnter")(parent)
				end
			end
			if parent.validationIssue then
				return
			end
			local tmp = newList(text)
			callConfigField(parent, 'onChange', tmp, true)
			tmp = del(tmp)
			
			highlight(this, text)
			if this.inlineGroup and this.inlineGroup.label then
				this.inlineGroup:Reposition()
			end
		end
		-- on enter, save the data, clear focus
		local function editBox_OnEnterPressed(this)
			local parent = this:GetParent()
			local text = this:GetText()
			if parent.value == text then
				this:ClearFocus()
				return
			end
			if parent.validationIssue then
				return
			end
			text = stripColors(text)
			local tmp = newList(text)
			callConfigField(parent, 'set', tmp)
			tmp = del(tmp)

			refreshConfigMenu(parent[1])
		end

		local function editBox_OnReceiveDrag(this)
			local type, alpha, bravo = GetCursorInfo()
			local text
			if type == "spell" then
				text = GetSpellName(alpha, bravo)
			elseif type == "item" then
				text = bravo
			end
			if not text then
				return
			end
			ClearCursor()
			this:SetText(text)
		end

		local function editBox_OnMouseDown(this, arg1)
			if arg1 == "LeftButton" then
				if GetCursorInfo() and (CursorHasItem() or CursorHasSpell()) then
					return editBox_OnReceiveDrag(this)
				end
			end
		end

		local function button_Disable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this:__Disable()
			this:EnableMouse(false)
		end

		local function button_Enable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this:__Enable()
			this:EnableMouse(true)
		end

		-- when pressed, the button should look pressed
		local function button_OnMouseDown(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			end
		end
		-- when depressed, return to normal
		local function button_OnMouseUp(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			end
		end

		local function saveButton_OnClick(this)
			local parent = this:GetParent()
			local editBox = parent.editBox
			local text = editBox:GetText()
			if parent.value == text then
				editBox:ClearFocus()
				return
			end
			if parent.validationIssue then
				return
			end
			text = stripColors(text)
			local tmp = newList(text)
			callConfigField(parent, 'set', tmp)
			tmp = del(tmp)

			refreshConfigMenu(parent[1])
		end

		local stringControlNum = 0
		-- create a preliminary edit box
		-- TODO: support multi-line
		local function _getStringControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			stringControlNum = stringControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_StringControl" .. stringControlNum, mainPane.scrollChild)

			frame.Disable = frame_Disable
			frame.Enable = frame_Enable
			frame.IsEnabled = frame_IsEnabled

			frame.type = 'string'
			frame:SetHeight(24)
			frame:EnableMouse(true)

			local editBox = CreateFrame("EditBox", frame:GetName() .. "_EditBox", frame)
			frame.editBox = editBox
			editBox:SetAutoFocus(false)
			editBox:SetFontObject(ChatFontNormal)

			editBox:SetScript("OnEscapePressed", editBox_OnEscapePressed)
			editBox:SetScript("OnTextChanged", editBox_OnTextChanged)
			editBox:SetScript("OnEnterPressed", editBox_OnEnterPressed)
			editBox:SetScript("OnEditFocusLost", editBox_OnEditFocusLost)
			editBox:SetScript("OnEditFocusGained", editBox_OnEditFocusGained)
			editBox:SetScript("OnReceiveDrag", editBox_OnReceiveDrag)
			editBox:SetScript("OnMouseDown", editBox_OnMouseDown)
			frame:SetScript("OnEnter", frame_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			editBox:SetScript("OnEnter", SubControl_OnEnter)
			editBox:SetScript("OnLeave", SubControl_OnLeave)

			local warning = frame:CreateTexture(frame:GetName() .. "_Warning", "ARTWORK")
			frame.warning = warning
			warning:Hide()
			warning:SetTexture([[Interface\DialogFrame\DialogAlertIcon]])
			warning:SetWidth(24)
			warning:SetHeight(24)
			warning:SetPoint("RIGHT")

			return frame
		end

		-- fetch and set up an edit box
		function getStringControl(path, parent)
			local frame = _getStringControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local editBox = frame.editBox
			if getConfigField(frame, 'multiline', false, true, "boolean") then
				editBox:SetMultiLine(true)
				editBox:ClearAllPoints()
				editBox:SetPoint("LEFT", frame, "LEFT", 1, 0)
				editBox:SetPoint("TOP", frame, "TOP", 0, -3)
				editBox:SetPoint("BOTTOM", frame, "BOTTOM", 0, 18)
				editBox:SetPoint("RIGHT", frame, "RIGHT", -1, 0)
				frame:SetHeight(42)
				editBox:SetScript("OnTextChanged", editBox_OnMultilineTextChanged)
				editBox:SetScript("OnEnterPressed", nil)
				if parent:GetName():match("Inline") then
					editBox.inlineGroup = parent
				end

				if not frame.saveButton then
					local button = CreateFrame("Button", frame:GetName() .. (i == 1 and "_button" or "_PasteButton"), frame)
					frame.saveButton = button
					local left = button:CreateTexture(button:GetName() .. "_LeftTexture", "BACKGROUND")
					button.left = left
					local middle = button:CreateTexture(button:GetName() .. "_MiddleTexture", "BACKGROUND")
					button.middle = middle
					local right = button:CreateTexture(button:GetName() .. "_RightTexture", "BACKGROUND")
					button.right = right
					left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
					middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
					right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

					left:SetPoint("TOPLEFT")
					left:SetPoint("BOTTOMLEFT")
					left:SetWidth(12)
					left:SetTexCoord(0, 0.09375, 0, 0.6875)

					right:SetPoint("TOPRIGHT")
					right:SetPoint("BOTTOMRIGHT")
					right:SetWidth(12)
					right:SetTexCoord(0.53125, 0.625, 0, 0.6875)

					middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
					middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
					middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)

					button:SetScript("OnMouseDown", button_OnMouseDown)
					button:SetScript("OnMouseUp", button_OnMouseUp)

					local text = button:CreateFontString(button:GetName() .. "_FontString", "ARTWORK")
					button:SetFontString(text)
					button.text = text
					text:SetPoint("LEFT", button, "LEFT", 7, 0)
					text:SetPoint("RIGHT", button, "RIGHT", -7, 0)

					button[SET_NORMAL_FONT_OBJECT](button, GameFontNormal)
					button:SetHighlightFontObject(GameFontHighlight)
					button:SetDisabledFontObject(GameFontDisable)

					text:SetText(SAVE)

					local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY", "UIPanelButtonHighlightTexture")
					button:SetHighlightTexture(highlight)

					button:SetScript("OnClick", saveButton_OnClick)
					button:SetScript("OnEnter", SubControl_OnEnter)
					button:SetScript("OnLeave", SubControl_OnLeave)

					button.__Disable = button.Disable
					button.__Enable = button.Enable
					button.Disable = button_Disable
					button.Enable = button_Enable

					button:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", 0, 0)
					button:SetWidth(100)
					button:SetHeight(18)
				else
					local button = frame.saveButton
					button:Show()
				end
			else
				editBox:SetScript("OnTextChanged", editBox_OnTextChanged)
				editBox:SetScript("OnEnterPressed", editBox_OnEnterPressed)
				editBox:SetPoint("LEFT", frame, "LEFT", 1, 0)
				editBox:SetPoint("TOP", frame, "TOP", 0, 0)
				editBox:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
				editBox:SetPoint("RIGHT", frame, "RIGHT", -1, 0)
			end

			styleEditBox(editBox)
			
			local ret = getConfigField(frame, 'get', false, false, "string;boolean;number") or ''
			local tmp = newList(ret)
			local success, r = callConfigField(frame, 'syntaxHighlighter', tmp, true)
			if success then
				ret = r
			end
			ret = tostring(ret or '')
			frame.editBox:SetText(ret)
			frame.value = ret

			return frame
		end
	end

	local releaseKeybindingControl, getKeybindingControl
	do
		local currentLock = nil
		local button_Unclick
		-- button
		local pool = {}
		-- remove a button and put it in the pool
		function releaseKeybindingControl(frame)
			if currentLock == frame then
				button_Unclick(frame)
			end
			frame:Hide()
			frame:Enable()
			frame.button:Enable()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			frame.previousText = nil
			pool[frame] = true
			return nil
		end
		-- when pressed, the button should look pressed
		local function button_OnMouseDown(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Down]])
			end
		end
		-- when depressed, return to normal
		local function button_OnMouseUp(this)
			if this:IsEnabled() == 1 then
				this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
				this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			end
		end
		local keybindingControlsDisabled = {}
		-- fake enable check
		local function frame_IsEnabled(this)
			return keybindingControlsDisabled[this] and 0 or 1
		end
		-- when disabled, turn gray
		local function frame_Disable(this)
			if keybindingControlsDisabled[this] then
				return
			end
			keybindingControlsDisabled[this] = true
			this.label:Disable()
			this.button:Disable()
		end
		-- when enabled, return to normal
		local function frame_Enable(this)
			if not keybindingControlsDisabled[this] then
				return
			end
			keybindingControlsDisabled[this] = nil
			this.label:Enable()
			this.button:Enable()
		end

		local function button_Disable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Disabled]])
			this:__Disable()
			this:EnableMouse(false)
		end

		local function button_Enable(this)
			this.left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this.right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			this:__Enable()
			this:EnableMouse(true)
		end

		function button_Unclick(this)
			this:UnlockHighlight()
			this:EnableKeyboard(false)
			this:SetText(this.previousText)
			currentLock = nil
		end
		-- call the actual function
		local function button_OnClick(this)
			if currentLock then--and currentLock ~= this then
				button_Unclick(currentLock)
				return
			end
			this:LockHighlight()
			this:EnableKeyboard(true)
			currentLock = this
			this.previousText = this.text:GetText()
			this.text:SetText(BIND_KEY_TO_COMMAND:format(this:GetParent().label.text:GetText()))
		end

		local function button_OnKeyDown(this, key)
			if currentLock ~= this then
				return
			end
			
			if key == "SHIFT" or key == "ALT" or key == "CTRL" or key == "LSHIFT" or key == "RSHIFT" or key == "LALT" or key == "RALT" or key == "LCTRL" or key == "RCTRL" or key == "UNKNOWN" then
				return
			end

			local keybind = key
			if key == "ESCAPE" then
				key = false
				keybind = false
			else
				if IsShiftKeyDown() then
					key = "SHIFT-" .. key
				end
				if IsControlKeyDown() then
					key = "CTRL-" .. key
				end
				if IsAltKeyDown() then
					key = "ALT-" .. key
				end
			end

			local parent = this:GetParent()
			local keybindingOnly = getConfigField(parent, 'keybindingOnly', false, true, "table")
			if keybindingOnly then
				if not keybindingOnly[keybind] then
					return
				end
			else
				local keybindingExcept = getConfigField(parent, 'keybindingExcept', false, true, "table")
				if keybindingExcept and keybindingExcept[keybind] then
					return
				end
			end

			local t = newList(key)
			callConfigField(parent, 'set', t)
			t = del(t)
			button_Unclick(this)
			refreshConfigMenu(parent[1])
		end

		local function button_OnMouseDown(this, button)
			if currentLock ~= this then
				return
			end
			local key
			if button == "LeftButton" then
				key = "BUTTON1"
			elseif button == "RightButton" then
				key = "BUTTON2"
			elseif button == "MiddleButton" then
				key = "BUTTON3"
			elseif button == "MouseButton4" then
				key = "BUTTON4"
			elseif button == "MouseButton5" then
				key = "BUTTON5"
			else
				return
			end

			return button_OnKeyDown(this, key)
		end
		local keybindingControlNum = 0
		-- create a preliminary button
		local function _getKeybindingControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			keybindingControlNum = keybindingControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_KeybindingControl" .. keybindingControlNum, mainPane.scrollChild)

			local button = CreateFrame("Button", frame:GetName() .. "_Button", frame)
			frame.button = button
			local left = button:CreateTexture(button:GetName() .. "_LeftTexture", "BACKGROUND")
			button.left = left
			local middle = button:CreateTexture(button:GetName() .. "_MiddleTexture", "BACKGROUND")
			button.middle = middle
			local right = button:CreateTexture(button:GetName() .. "_RightTexture", "BACKGROUND")
			button.right = right
			left:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			middle:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])
			right:SetTexture([[Interface\Buttons\UI-Panel-Button-Up]])

			left:SetPoint("TOPLEFT")
			left:SetPoint("BOTTOMLEFT")
			left:SetWidth(12)
			left:SetTexCoord(0, 0.09375, 0, 0.6875)

			right:SetPoint("TOPRIGHT")
			right:SetPoint("BOTTOMRIGHT")
			right:SetWidth(12)
			right:SetTexCoord(0.53125, 0.625, 0, 0.6875)

			middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
			middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
			middle:SetTexCoord(0.09375, 0.53125, 0, 0.6875)

			button:SetScript("OnMouseDown", button_OnMouseDown)
			button:SetScript("OnMouseUp", button_OnMouseUp)

			button.__Enable = button.Enable
			button.__Disable = button.Disable
			button.Enable = button_Enable
			button.Disable = button_Disable

			frame.IsEnabled = frame_IsEnabled
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable

			local text = button:CreateFontString(button:GetName() .. "_FontString", "ARTWORK")
			button:SetFontString(text)
			button.text = text
			text:SetPoint("LEFT", button, "LEFT", 7, 0)
			text:SetPoint("RIGHT", button, "RIGHT", -7, 0)

			button[SET_NORMAL_FONT_OBJECT](button, GameFontNormal)
			button:SetHighlightFontObject(GameFontHighlight)
			button:SetDisabledFontObject(GameFontDisable)
			local highlight = button:CreateTexture(button:GetName() .. "_Highlight", "OVERLAY", "UIPanelButtonHighlightTexture")
			button:SetHighlightTexture(highlight)

			button:SetScript("OnClick", button_OnClick)
			frame:SetScript("OnEnter", Control_OnEnter)
			frame:SetScript("OnLeave", Control_OnLeave)
			button:SetScript("OnEnter", SubControl_OnEnter)
			button:SetScript("OnLeave", SubControl_OnLeave)
			button:SetScript("OnMouseDown", button_OnMouseDown)
			button:SetScript("OnKeyDown", button_OnKeyDown)

			frame:EnableMouse(true)
			button:EnableMouse(true)

			frame:SetHeight(24)
			button:SetAllPoints()

			frame.type = 'keybinding'

			return frame
		end
		-- fetch and set up a button
		function getKeybindingControl(path, parent)
			local frame = _getKeybindingControl()

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			local keybind = getConfigField(frame, 'get', false, true, "string;boolean")
			if not keybind then
				frame.button.text:SetText(KEYBINDING_COLON .. NOT_BOUND)
			else
				local alt, rest = keybind:match("^(ALT)%-(.*)$")
				if alt then
					keybind = rest
				end
				local ctrl, rest = keybind:match("^(CTRL)%-(.*)$")
				if ctrl then
					keybind = rest
				end
				local shift, rest = keybind:match("^(SHIFT)%-(.*)$")
				if shift then
					keybind = rest
				end
				local text
				if keybind == "BUTTON1" then
					text = KEY_BUTTON1
				elseif keybind == "BUTTON2" then
					text = KEY_BUTTON2
				else
					text = GetBindingText(keybind, "KEY_")
				end
				if shift then
					text = "Shift-" .. text
				end
				if ctrl then
					text = "Ctrl-" .. text
				end
				if alt then
					text = "Alt-" .. text
				end
				frame.button.text:SetText(KEYBINDING_COLON .. text)
			end
			frame.button:SetAllPoints()
			return frame
		end
	end

	local releaseInlineGroupControl, getInlineGroupControl
	do
		local pool = {}
		-- remove a control and put it in the pool
		function releaseInlineGroupControl(frame)
			frame:Hide()
			frame:Enable()
			frame:ClearAllPoints()
			for i = 1, #frame do
				frame[i] = nil
			end
			frame.desc = nil
			frame.parent = nil
			clearMainPane(frame)
			pool[frame] = true
			return nil
		end

		local inlineGroupControlsDisabled = {}
		-- fake enable check
		local function frame_IsEnabled(this)
			return inlineGroupControlsDisabled[this] and 0 or 1
		end
		-- when disabled, turn gray
		local function frame_Disable(this)
			if inlineGroupControlsDisabled[this] then
				return
			end
			inlineGroupControlsDisabled[this] = true

			this.label:Disable()
			this.vertLineLeft:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			this.vertLineRight:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			this.horizLineTop:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
			this.horizLineBottom:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)

			for i,v in ipairs(this.controls) do
				v:Disable()
			end
		end
		-- when enabled, return to normal
		local function frame_Enable(this)
			if not inlineGroupControlsDisabled[this] then
				return
			end
			inlineGroupControlsDisabled[this] = nil

			this.label:Enable()
			this.vertLineLeft:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			this.vertLineRight:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			this.horizLineTop:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			this.horizLineBottom:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)

			for i,v in ipairs(this.controls) do
				local disabled = getConfigField(v, 'disabled', false, true)
				if not disabled then
					v:Enable()
				end
			end
		end

		local function frame_Reposition(this)
			local parent = this.parent

			this.horizLineTop:SetPoint("LEFT", this.label.text, "RIGHT", 9, 0)

			local controls = this.controls
			local maxLabelWidth = 0
			for i, v in ipairs(controls) do
				local label = v.label
				label.text:SetWidth(0)
				label:ClearAllPoints()
				local label_width = label.text:GetWidth()
				if label.icon:IsShown() then
					label_width = label_width + label.icon:GetWidth() + 1
				end
				if label_width > maxLabelWidth then
					maxLabelWidth = label_width
				end
			end
			local last
			local height = 27
			local yOffset = -24
			for i,v in ipairs(controls) do
				local label = v.label
				label:SetWidth(maxLabelWidth)
				label:SetHeight(math_min(24, v:GetHeight()))
				height = height + 3 + v:GetHeight()
				label:SetPoint("LEFT", this.vertLineLeft, "LEFT", 6, 0)
				v:SetPoint("LEFT", label, "RIGHT", 8, 0)
				v:SetPoint("RIGHT", this.vertLineRight, "RIGHT", -6, 0)
				v:SetPoint("TOP", label, "TOP")

				if not last then
					label:SetPoint("TOP", this, "TOP", 0, yOffset)
				else
					label:SetPoint("TOP", last, "BOTTOM", 0, yOffset)
				end

				last = v
				yOffset = -3
			end
			this:SetHeight(height)
			if this.parent:GetName():match("Inline") then
				this.parent:Reposition()
			end
		end

		local function frame_SizeChanged(this, paneWidth)
			local label = this.controls[1] and this.controls[1].label
			if not label then
				return
			end
			local labelWidth = label:GetWidth()
			local paneWidth = base.mainPane.scrollFrame:GetWidth() - labelWidth - 22
			for i,v in ipairs(this.controls) do
				if v.SizeChanged then
					v:SizeChanged(paneWidth)
				end
			end
		end

		local inlineGroupControlNum = 0
		-- create a preliminary button
		local function _getInlineGroupControl()
			local frame = next(pool)
			if frame then
				pool[frame] = nil
				frame:Show()
				return frame
			end
			inlineGroupControlNum = inlineGroupControlNum + 1
			local mainPane = base.mainPane
			frame = CreateFrame("Frame", mainPane:GetName() .. "_InlineGroupControl" .. inlineGroupControlNum, mainPane.scrollChild)

			local horizLineTop = frame:CreateTexture(frame:GetName() .. "_HorizontalLineTop", "BACKGROUND")
			frame.horizLineTop = horizLineTop
			local horizLineBottom = frame:CreateTexture(frame:GetName() .. "_HorizontalLineBottom", "BACKGROUND")
			frame.horizLineBottom = horizLineBottom
			local vertLineLeft = frame:CreateTexture(frame:GetName() .. "_VerticalLineLeft", "BACKGROUND")
			frame.vertLineLeft = vertLineLeft
			local vertLineRight = frame:CreateTexture(frame:GetName() .. "_VerticalLineRight", "BACKGROUND")
			frame.vertLineRight = vertLineRight
			horizLineTop:SetTexture([[Interface\Buttons\WHITE8X8]])
			horizLineTop:SetHeight(1)
			horizLineBottom:SetTexture([[Interface\Buttons\WHITE8X8]])
			horizLineBottom:SetHeight(1)
			vertLineLeft:SetTexture([[Interface\Buttons\WHITE8X8]])
			vertLineLeft:SetWidth(1)
			vertLineRight:SetTexture([[Interface\Buttons\WHITE8X8]])
			vertLineRight:SetWidth(1)
			horizLineTop:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			horizLineBottom:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			vertLineLeft:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			vertLineRight:SetVertexColor(NORMAL_FONT_COLOR.r/2, NORMAL_FONT_COLOR.g/2, NORMAL_FONT_COLOR.b/2)
			horizLineTop:SetPoint("TOP", frame, "TOP", 0, -12)
			horizLineTop:SetPoint("RIGHT", vertLineRight, "RIGHT")
			vertLineLeft:SetPoint("BOTTOM", 0, 3)
			vertLineLeft:SetPoint("TOP", frame, "TOP", 0, -24)
			vertLineRight:SetPoint("BOTTOM", 0, 3)
			vertLineRight:SetPoint("TOP", frame, "TOP", 0, -12)
			horizLineBottom:SetPoint("BOTTOMLEFT", vertLineLeft, "BOTTOMLEFT")
			horizLineBottom:SetPoint("BOTTOMRIGHT", vertLineRight, "BOTTOMRIGHT")

			frame.IsEnabled = frame_IsEnabled
			frame.Disable = frame_Disable
			frame.Enable = frame_Enable

			frame.Reposition = frame_Reposition
			frame.SizeChanged = frame_SizeChanged

			frame:EnableMouse(true)

			frame.type = 'group'
			frame.groupType = 'inline'

			frame:SetHeight(24)

			frame.controls = {}

			return frame
		end
		-- fetch and set up a button
		function getInlineGroupControl(path, parent)
			local frame = _getInlineGroupControl()
			frame.parent = parent

			local controls = parent.controls
			controls[#controls+1] = frame
			for i,v in ipairs(path) do
				frame[i] = v
			end
			if parent == base.mainPane then
				frame.vertLineLeft:SetPoint("LEFT", parent.scrollFrame, "LEFT", 3, 0)
				frame.vertLineRight:SetPoint("RIGHT", parent.scrollFrame, "RIGHT", -3, 0)
			else
				frame.vertLineLeft:SetPoint("LEFT", parent.vertLineLeft, "LEFT", 6, 0)
				frame.vertLineRight:SetPoint("RIGHT", parent.vertLineRight, "RIGHT", -6, 0)
			end

			return frame
		end
	end

	-- clear the main pane of all controls
	function clearMainPane(parent)
		local controls = parent.controls

		for i,v in ipairs(controls) do
			local v_type = v.type
			if v_type == 'execute' then
				controls[i] = releaseExecuteControl(v)
			elseif v_type == 'boolean' then
				controls[i] = releaseBooleanControl(v)
			elseif v_type == 'number' then
				controls[i] = releaseNumberControl(v)
			elseif v_type == 'color' then
				controls[i] = releaseColorControl(v)
			elseif v_type == 'choice' then
				controls[i] = releaseChoiceControl(v, false)
			elseif v_type == 'multichoice' then
				controls[i] = releaseChoiceControl(v, true)
			elseif v_type == 'string' then
				controls[i] = releaseStringControl(v)
			elseif v_type == 'keybinding' then
				controls[i] = releaseKeybindingControl(v)
			elseif v_type == 'group' and v.groupType == 'inline' then
				controls[i] = releaseInlineGroupControl(v)
			else
				error(("Unknown control type: %q"):format(tostring(v_type)))
			end
			v.label = releaseLabel(v.label)
		end
	end

	-- sorting helper function
	local function myFunc(alpha, bravo)
		local alpha_order = getConfigField(alpha, 'order', false, 100, "number")
		local bravo_order = getConfigField(bravo, 'order', false, 100, "number")
		if alpha_order == bravo_order then
			return alpha.label.text:GetText():lower() < bravo.label.text:GetText():lower()
		else
			if alpha_order < 0 then
				if bravo_order < 0 then
					return alpha_order < bravo_order
				else
					return false
				end
			else
				if bravo_order < 0 then
					return true
				else
					return alpha_order < bravo_order
				end
			end
		end
	end
	-- sort the controls within the main pane
	local function sortMainPaneSections(parent)
		table_sort(parent.controls, myFunc)
	end

	-- populate the main pane with controls based on the path
	function populateMainPane(path, parent)
		if not parent then
			parent = base.mainPane
		end
		local args = getConfigField(path, 'args', false, false, "table")
		local extraArgs
		if #path == 1 then
			extraArgs = getConfigField(path, 'extraArgs', false, true, "table")
			if extraArgs then
				local realArgs = args
				args = newList()
				for k,v in pairs(extraArgs) do
					args[k] = v
				end
				for k,v in pairs(realArgs) do
					args[k] = v
				end
			end
		end

		for k,v in pairs(args) do
			local t = newList(unpack(path))
			t[#t+1] = k
			local v_type = getConfigField(t, 'type', true, false, "string")
			local hidden = getConfigField(t, 'hidden', false, true)
			if not hidden then
				local frame
				local inlineGroup = false
				if v_type == 'execute' then
					frame = getExecuteControl(t, parent)
				elseif v_type == 'boolean' then
					frame = getBooleanControl(t, parent)
				elseif v_type == 'number' then
					frame = getNumberControl(t, parent)
				elseif v_type == 'color' then
					frame = getColorControl(t, parent)
				elseif v_type == 'choice' then
					frame = getChoiceControl(t, false, parent)
				elseif v_type == 'multichoice' then
					frame = getChoiceControl(t, true, parent)
				elseif v_type == 'string' then
					frame = getStringControl(t, parent)
				elseif v_type == 'keybinding' then
					frame = getKeybindingControl(t, parent)
				elseif v_type == 'group' then
					local v_groupType = getConfigField(t, 'groupType', true, "normal", "string")
					if v_groupType == "inline" then
						frame = getInlineGroupControl(t, parent)
						inlineGroup = true
					end
				elseif v_type == 'header' then
					-- HACK
					-- pass
				else
					local _, ret = pcall(error, ("Config error: type %s is not valid for path `%s'"):format(toliteral(v_type), getPathString(t)))
					geterrorhandler()(ret)
				end
				if frame then
					getLabel(t, frame)
					if inlineGroup then
						populateMainPane(t, frame)
					end
					local disabled = getConfigField(t, 'disabled', false, true)
					if disabled then
						frame:Disable()
					end
				end
			end
			t = del(t)
		end

		if extraArgs then
			args = del(args)
		end

		sortMainPaneSections(parent)

		parent:Reposition()
	end

	-- reposition the controls in the main pane
	function mainPane_Reposition(mainPane)
		local scrollChild = mainPane.scrollChild
		local scrollFrame = mainPane.scrollFrame
		local controls = mainPane.controls
		local maxLabelWidth = 0
		for i, v in ipairs(controls) do
			local label = v.label
			label.text:SetWidth(0)
			label:ClearAllPoints()
			local label_width = label.text:GetWidth()
			if label.icon:IsShown() then
				label_width = label_width + label.icon:GetWidth() + 1
			end
			if label_width > maxLabelWidth then
				maxLabelWidth = label_width
			end
		end
		local last
		local yOffset = 0
		for i,v in ipairs(controls) do
			local label = v.label
			label:SetWidth(maxLabelWidth)
			label:SetHeight(math_min(24, v:GetHeight()))
			label:SetPoint("LEFT", scrollFrame, "LEFT")
			v:SetPoint("LEFT", label, "RIGHT", 8, 0)
			v:SetPoint("RIGHT", scrollFrame, "RIGHT")
			v:SetPoint("TOP", label, "TOP")

			if not last then
				label:SetPoint("TOP", scrollChild, "TOP", 0, yOffset)
			else
				label:SetPoint("TOP", last, "BOTTOM", 0, yOffset)
			end

			last = v
			yOffset = -3
		end
	end
end

function RockConfig:OnUnembed(object)
	data[object] = nil
end

local tmp

local usingFuBarPlugin = false

RockConfig.rockOptions = {
	type = 'group',
	name = ADDON_PREFERENCES,
	desc = ADDON_PREFERENCES,
	icon = [[Interface\Icons\INV_Misc_Gear_06]],
	args = {
		minimapButton = {
			type = 'boolean',
			name = SHOW_MINIMAP_ICON,
			desc = SHOW_MINIMAP_ICON_DESC,
			get = function()
				return RockConfig.minimapButton:IsShown()
			end,
			set = function(value)
				if value then
					RockConfig.minimapButton:Show()
				else
					RockConfig.minimapButton:Hide()
				end
			end,
			hidden = function()
				return usingFuBarPlugin
			end
		},
		scale = {
			type = 'number',
			name = SCALE,
			desc = SCALE_DESC,
			get = function()
				return RockConfig.scale
			end,
			set = function(value)
				RockConfig.scale = value
				if not tmp then
					tmp = CreateFrame("Frame")
					tmp:SetScript("OnUpdate", function(this)
						if base and base:IsShown() then
							if UIParent:IsShown() then
								base:SetScale(RockConfig.scale)
							else
								base:SetScale(RockConfig.scale * UIParent:GetEffectiveScale())
							end
						end
						this:Hide()
					end)
				end
				tmp:Show()
			end,
			min = 0.5,
			max = 2,
			isPercent = true,
			step = 0.01,
			bigStep = 0.05,
		},
		minAlpha = {
			type = 'number',
			name = FADEOUT_TRANSPARENCY,
			desc = FADEOUT_TRANSPARENCY_DESC,
			get = function()
				return RockConfig.minAlpha or 0.25
			end,
			set = function(value)
				RockConfig.minAlpha = value
			end,
			min = 0,
			max = function()
				return RockConfig.maxAlpha or 1
			end,
			isPercent = true,
			step = 0.01,
			bigStep = 0.05,
			stepBasis = 0,
		},
		maxAlpha = {
			type = 'number',
			name = FADEIN_TRANSPARENCY,
			desc = FADEIN_TRANSPARENCY_DESC,
			get = function()
				return RockConfig.maxAlpha or 1
			end,
			set = function(value)
				RockConfig.maxAlpha = value
			end,
			min = function()
				return math.max(RockConfig.minAlpha or 0.25, 0.25)
			end,
			max = 1,
			isPercent = true,
			step = 0.01,
			bigStep = 0.05,
			stepBasis = 0,
		},
		hideInCombat = {
			type = 'boolean',
			name = HIDE_IN_COMBAT,
			desc = HIDE_IN_COMBAT_DESC,
			get = function()
				return RockConfig.hideInCombat
			end,
			set = function(value)
				RockConfig.hideInCombat = value
				if InCombatLockdown() then
					base:Hide()
				end
			end,
		}
	},
}
if oldLib and oldLib.rockOptions then
	for k,v in pairs(oldLib.rockOptions) do
		if not RockConfig.rockOptions[k] then
			RockConfig.rockOptions[k] = v
		end
	end
end
RockConfig:SetConfigTable(RockConfig.rockOptions)

if oldLib then
	RockConfig.x = oldLib.x or 0
	RockConfig.y = oldLib.y or 0
	RockConfig.width = oldLib.width or GetScreenWidth()*3/5
	RockConfig.height = oldLib.height or GetScreenHeight()*3/5
	RockConfig.scale = oldLib.scale or 1
	RockConfig.minAlpha = oldLib.minAlpha or 0.25
	RockConfig.maxAlpha = oldLib.maxAlpha or 1
	for i = 1, 9 do
		RockConfig["sv" .. i] = oldLib["sv" .. i]
	end
end

_G.hash_SlashCmdList["ROCK"] = nil
_G.SlashCmdList["ROCK"] = function()
	RockConfig:OpenConfigMenu()
end
_G["SLASH_ROCK1"] = "/rock"
_G["SLASH_ROCK2"] = "/Rock"
_G["SLASH_ROCK3"] = "/rockconfig"
_G["SLASH_ROCK4"] = "/RockConfig"


local variablesLoaded = false
local function loadFuBarPlugin()
	if not variablesLoaded then
		return
	end
	loadFuBarPlugin = nil
	local FuBarPlugin = Rock("LibFuBarPlugin-3.0")
	FuBarPlugin:Embed(RockConfig)
	RockConfig:SetFuBarOption('iconPath', [[Interface\Icons\INV_Misc_Gear_06]])
	RockConfig:SetFuBarOption('hasNoText', true)
	RockConfig:SetFuBarOption('defaultPosition', "MINIMAP")
	RockConfig:SetFuBarOption('hideWithoutStandby', true)
	local minimapButton = RockConfig.minimapButton
	local shown = minimapButton:IsShown()
	minimapButton:Hide()
	if minimapButton.framePosition then
		RockConfig.minimapPosition = minimapButton.framePosition
	else
		RockConfig.minimapPosition = 157
		RockConfig.minimapPositionWild = true
		RockConfig.minimapPositionX = minimapButton.framePositionX
		RockConfig.minimapPositionY = minimapButton.framePositionY
	end
	usingFuBarPlugin = true
	RockConfig.title = ADDON_PREFERENCES
	RockConfig.rockOptions.args.fubar = {
		name = FUBAR_OPTIONS,
		desc = FUBAR_OPTIONS,
		type = 'group',
		groupType = 'inline',
		args = newDict(FuBarPlugin:GetEmbedRockConfigOptions(RockConfig)),
	}
	function RockConfig:OnUpdateFuBarTooltip()
		GameTooltip:SetText(ADDON_PREFERENCES)
	end
	function RockConfig:OnFuBarClick()
		self:OpenConfigMenu()
	end
	if FuBarPlugin.OnEmbedInitialize then
		FuBarPlugin:OnEmbedInitialize(RockConfig)
	end
	if FuBarPlugin.OnEmbedEnable then
		FuBarPlugin:OnEmbedEnable(RockConfig, true)
	end
	if shown then
		--RockConfig:Show()	-- HACK
	end
end

do
	-- minimap button
	local frame = CreateFrame("Button", MAJOR_VERSION .. "_MinimapButton", Minimap)
	RockConfig.minimapButton = frame
	if oldLib and oldLib.minimapButton then
		oldLib.minimapButton:UnregisterAllEvents()
		oldLib.minimapButton:Hide()
	end
	frame:Hide()	-- HACK
	frame:SetClampedToScreen(true)
	frame:SetWidth(31)
	frame:SetHeight(31)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameLevel(4)
	frame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	local icon = frame:CreateTexture(frame:GetName() .. "Icon", "BACKGROUND")
	frame.icon = icon
	icon:SetTexture([[Interface\Icons\INV_Misc_Gear_06]])
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -5)
	local overlay = frame:CreateTexture(frame:GetName() .. "Overlay","OVERLAY")
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetPoint("TOPLEFT", frame, "TOPLEFT")
	frame:EnableMouse(true)
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	frame:SetScript("OnEnter", function(this)
		local anchor
		if this:GetTop() > GetScreenHeight() / 2 then
			local x = this:GetCenter()
			if x < GetScreenWidth() / 2 then
				anchor = "ANCHOR_BOTTOMRIGHT"
			else
				anchor = "ANCHOR_BOTTOMLEFT"
			end
		else
			local x = this:GetCenter()
			if x < GetScreenWidth() / 2 then
				anchor = "ANCHOR_TOPLEFT"
			else
				anchor = "ANCHOR_TOPRIGHT"
			end
		end
		GameTooltip:SetOwner(this, anchor)
		GameTooltip:SetText(ADDON_PREFERENCES)
	end)
	frame:SetScript("OnLeave", function(this)
		GameTooltip:Hide()
	end)

	frame:SetScript("OnClick", function(this)
		if this.dragged then
			return
		end
		if base and base:IsShown() then
			base:Hide()
		else
			RockConfig:OpenConfigMenu()
		end
	end)

	frame:SetScript("OnMouseDown", function(this, button)
		if button ~= "LeftButton" then
			return
		end
		this.dragged = nil

		this.icon:SetTexCoord(0.14, 0.86, 0.14, 0.86)
	end)
	frame:SetScript("OnMouseUp", function(this, button)
		if button ~= "LeftButton" then
			return
		end
		this.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	end)
	frame:RegisterForDrag("LeftButton")
	local frame_OnUpdate
	frame:SetScript("OnDragStart", function(this)
		this.dragged = true
		if GameTooltip:IsOwned(this) then
			GameTooltip:Hide()
		end
		this:LockHighlight()
		this:SetScript("OnUpdate", frame_OnUpdate)
		this.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	end)
	frame:SetScript("OnDragStop", function(this)
		this:SetScript("OnUpdate", nil)
		this:UnlockHighlight()
	end)

	frame.framePosition = 157
	if oldLib and oldLib.minimapButton then
		if oldLib.minimapButton:IsShown() then
			frame:Show()
		else
			frame:Hide()
		end
		frame.framePosition = oldLib.minimapButton.framePosition
		frame.framePositionX = oldLib.minimapButton.framePositionX
		frame.framePositionY = oldLib.minimapButton.framePositionY
	end
	local function Readjust(this)
		if this.framePosition then
			local angle = math.rad(this.framePosition)
			local x,y
			local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
			local cos = math.cos(angle)
			local sin = math.sin(angle)

			local round = true
			if minimapShape == "ROUND" then
				-- do nothing
			elseif minimapShape == "SQUARE" then
				round = false
			elseif minimapShape == "CORNER-TOPRIGHT" then
				if cos < 0 or sin < 0 then
					round = false
				end
			elseif minimapShape == "CORNER-TOPLEFT" then
				if cos > 0 or sin < 0 then
					round = false
				end
			elseif minimapShape == "CORNER-BOTTOMRIGHT" then
				if cos < 0 or sin > 0 then
					round = false
				end
			elseif minimapShape == "CORNER-BOTTOMLEFT" then
				if cos > 0 or sin > 0 then
					round = false
				end
			elseif minimapShape == "SIDE-LEFT" then
				if cos > 0 then
					round = false
				end
			elseif minimapShape == "SIDE-RIGHT" then
				if cos < 0 then
					round = false
				end
			elseif minimapShape == "SIDE-TOP" then
				if sin > 0 then
					round = false
				end
			elseif minimapShape == "SIDE-BOTTOM" then
				if sin < 0 then
					round = false
				end
			elseif minimapShape == "TRICORNER-TOPRIGHT" then
				if cos < 0 and sin > 0 then
					round = false
				end
			elseif minimapShape == "TRICORNER-TOPLEFT" then
				if cos > 0 and sin > 0 then
					round = false
				end
			elseif minimapShape == "TRICORNER-BOTTOMRIGHT" then
				if cos < 0 and sin < 0 then
					round = false
				end
			elseif minimapShape == "TRICORNER-BOTTOMLEFT" then
				if cos > 0 and sin < 0 then
					round = false
				end
			end

			if round then
				x = cos * 80
				y = sin * 80
			else
				x = 110 * cos
				y = 110 * sin
				x = math.max(-82, math.min(x, 84))
				y = math.max(-86, math.min(y, 82))
			end
			frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
		else
			frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", this.framePositionX, this.framePositionY)
		end
	end

	function frame_OnUpdate(this)
		if not IsAltKeyDown() then
			local mx, my = Minimap:GetCenter()
			local px, py = GetCursorPosition()
			local scale = this:GetEffectiveScale()
			px, py = px / scale, py / scale
			local position = math.floor(math.deg(math.atan2(py - my, px - mx)) + 0.5)
			if position <= 0 then
				position = position + 360
			elseif position > 360 then
				position = position - 360
			end
			this.framePosition = position
			this.framePositionX, this.framePositionY = nil, nil
		else
			local px, py = GetCursorPosition()
			local scale = this:GetEffectiveScale()
			px, py = math.floor(px/scale + 0.5), math.floor(py/scale + 0.5)
			this.framePosition = nil
			this.framePositionX, this.framePositionY = px, py
		end

		Readjust(this)
	end

	frame:RegisterEvent("PLAYER_LOGOUT")
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function(this, event, ...)
		if event == "VARIABLES_LOADED" then
			variablesLoaded = true
			local var = TALENT_FRAME_WAS_SHOWN
			if var then
				TALENT_FRAME_WAS_SHOWN = 1
			end
			if type(var) == "string" then
				local sv = newList()
				local hidden, framePositionX, framePositionY, x, y, width, height, scale, minAlpha, maxAlpha, hideInCombat
				hidden, framePositionX, framePositionY, x, y, width, height, scale, minAlpha, maxAlpha, hideInCombat, sv[1], sv[2], sv[3], sv[4], sv[5], sv[6], sv[7], sv[8], sv[9] = var:match("^1;(H?)(%-?%d+),(%-?%d+);(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+);(%d+),(%d+);([01]);(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)$")
				if not hidden then
					hidden, framePositionX, x, y, width, height, scale, minAlpha, maxAlpha, hideInCombat, sv[1], sv[2], sv[3], sv[4], sv[5], sv[6], sv[7], sv[8], sv[9] = var:match("^1;(H?)(%-?%d+);(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+);(%d+),(%d+);([01]);(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)$")
					if not hidden then
						hideInCombat = "0"
						hidden, framePositionX, framePositionY, x, y, width, height, scale, minAlpha, maxAlpha, sv[1], sv[2], sv[3], sv[4], sv[5], sv[6], sv[7], sv[8], sv[9] = var:match("^1;(H?)(%-?%d+),(%-?%d+);(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+);(%d+),(%d+);(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)$")
						if not hidden then
							hidden, framePositionX, x, y, width, height, scale, minAlpha, maxAlpha, sv[1], sv[2], sv[3], sv[4], sv[5], sv[6], sv[7], sv[8], sv[9] = var:match("^1;(H?)(%-?%d+);(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+);(%d+),(%d+);(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*)$")
						end
					end
				end
				hideInCombat = hideInCombat == "1"
				if framePositionX then
					framePositionX, framePositionY, x, y, width, height, scale, minAlpha, maxAlpha = tonumber(framePositionX), tonumber(framePositionY), tonumber(x), tonumber(y), tonumber(width), tonumber(height), tonumber(scale), tonumber(minAlpha), tonumber(maxAlpha)
					if scale then
						scale = scale / 100
						if scale < 0.5 or scale > 2 then
							scale = 1
						end
					end
					if minAlpha then
						minAlpha = minAlpha / 100
						if minAlpha < 0 or minAlpha > 1 then
							minAlpha = 0.25
						end
					end
					if maxAlpha then
						maxAlpha = maxAlpha / 100
						if maxAlpha < 0.25 or maxAlpha < minAlpha or maxAlpha > 1 then
							maxAlpha = 1
						end
					end
					if bravo then
						this.framePosition = nil
						this.framePositionX, this.framePositionY = framePositionX, framePositionY
					else
						this.framePosition = framePositionX
						this.framePositionX, this.framePositionY = nil
					end
					if hidden == "H" then
						this:Hide()
					end
					RockConfig.x = x
					RockConfig.y = y
					RockConfig.width = width
					RockConfig.height = height
					RockConfig.scale = scale
					RockConfig.minAlpha = minAlpha
					RockConfig.maxAlpha = maxAlpha
					RockConfig.hideInCombat = hideInCombat
				end
				for i,v in ipairs(sv) do
					if v == "" then
						v = nil
					elseif tonumber(v) then
						v = tonumber(v)
					end
					RockConfig["sv" .. i] = v
				end
				sv = del(sv)
			end

			if Rock:HasLibrary("LibFuBarPlugin-3.0") and loadFuBarPlugin then
				loadFuBarPlugin()
			else
				Readjust(this)
			end
		elseif event == "PLAYER_LOGOUT" then
			local x = RockConfig.x or 0
			local y = RockConfig.y or 0
			local width = RockConfig.width or GetScreenWidth()*3/5
			local height = RockConfig.height or GetScreenHeight()*3/5
			local scale = RockConfig.scale or 1
			local minAlpha = RockConfig.minAlpha or 0.25
			local maxAlpha = RockConfig.maxAlpha or 1
			local framePosition, framePositionX, framePositionY
			local hideInCombat = RockConfig.hideInCombat and "1" or "0"
			if usingFuBarPlugin then
				if not RockConfig.minimapPositionWild then
					framePosition = RockConfig.minimapPosition
				else
					framePositionX, framePositionY = RockConfig.minimapPositionX, RockConfig.minimapPositionY
				end
			else
				if this.framePosition then
					framePosition = this.framePosition
				else
					framePositionX, framePositionY = this.framePositionX, this.framePositionY
				end
			end
			local hidden
			if usingFuBarPlugin then
				local FuBarPlugin = Rock("LibFuBarPlugin-3.0")
				if FuBarPlugin.pluginToFrame and FuBarPlugin.pluginToFrame[RockConfig] and FuBarPlugin.pluginToMinimapFrame then
					hidden = not FuBarPlugin.pluginToFrame[RockConfig]:IsShown() and (not FuBarPlugin.pluginToMinimapFrame[RockConfig] or not FuBarPlugin.pluginToMinimapFrame[RockConfig]:IsShown())
				end
			else
				hidden = not this:IsShown()
			end
			if framePosition then
				TALENT_FRAME_WAS_SHOWN = ("1;%s%.0f;%.0f,%.0f,%.0f,%.0f,%.0f;%.0f,%.0f;%s;%s,%s,%s,%s,%s,%s,%s,%s,%s"):format(hidden and "H" or "", framePosition, x, y, width, height, scale*100, minAlpha*100, maxAlpha*100, hideInCombat, tostring(RockConfig.sv1 or ""), tostring(RockConfig.sv2 or ""), tostring(RockConfig.sv3 or ""), tostring(RockConfig.sv4 or ""), tostring(RockConfig.sv5 or ""), tostring(RockConfig.sv6 or ""), tostring(RockConfig.sv7 or ""), tostring(RockConfig.sv8 or ""), tostring(RockConfig.sv9 or ""))
			else
				TALENT_FRAME_WAS_SHOWN = ("1;%s%.0f,%.0f;%.0f,%.0f,%.0f,%.0f,%.0f;%.0f,%.0f;%s;%s,%s,%s,%s,%s,%s,%s,%s,%s"):format(hidden and "H" or "", framePositionX, framePositionY, x, y, width, height, scale*100, minAlpha*100, maxAlpha*100, hideInCombat, tostring(RockConfig.sv1 or ""), tostring(RockConfig.sv2 or ""), tostring(RockConfig.sv3 or ""), tostring(RockConfig.sv4 or ""), tostring(RockConfig.sv5 or ""), tostring(RockConfig.sv6 or ""), tostring(RockConfig.sv7 or ""), tostring(RockConfig.sv8 or ""), tostring(RockConfig.sv9 or ""))
			end
		end
	end)

	Readjust(frame)
end

if ScriptErrors then
	ScriptErrors:SetFrameStrata("FULLSCREEN_DIALOG")
	ScriptErrorsButton:SetFrameStrata("FULLSCREEN_DIALOG")
end

RockConfig:SetExportedMethods("SetConfigTable", "OpenConfigMenu", "SetConfigSlashCommand")

function RockConfig:OnLibraryLoad(major, instance)
	if major == "LibFuBarPlugin-3.0" then
		if loadFuBarPlugin then
			loadFuBarPlugin()
		end
	end
end

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- simple registration
	local t = { name = MAJOR_VERSION .. "_UnitTest" }
	RockConfig:Embed(t)
	assert(not getConfigTable({t}))
	assert(not hasConfigTable({t}))
	local value = false

	local val = true
	function t:OtherGet()
		assert(t == self)
		return val
	end
	function t:OtherSet(value)
		assert(t == self)
		val = value
	end
	function t:AntiSet(value)
		assert(t == self)
		val = not value
	end

	t:SetConfigTable {
		type = 'group',
		name = MAJOR_VERSION .. "_UnitTest",
		desc = MAJOR_VERSION .. "_UnitTest",
		args = {
			{
				type = 'boolean',
				name = "Name",
				desc = "Desc",
				get = function(alpha, bravo)
					assert(alpha == "Alpha")
					assert(bravo == "Bravo")
					return value
				end,
				set = function(alpha, bravo, val)
					assert(alpha == "Alpha")
					assert(bravo == "Bravo")
					value = val
				end,
				passValue = "Alpha",
				passValue2 = "Bravo",
				passValue4 = "Delta", -- should do nothing
			},
			{
				type = 'boolean',
				name = "Other Name",
				desc = "Other Desc",
				get = "OtherGet",
				set = "OtherSet",
			},
			{
				type = 'boolean',
				name = "Anti Name",
				desc = "Anti Desc",
				get = "~OtherGet",
				set = "AntiSet",
			},
		}
	}

	assert(getConfigTable({t}))
	assert(hasConfigTable({t}))
	assert(not getConfigTable({t, 'blah'}))
	assert(not hasConfigTable({t, 'blah'}))

	-- test passValues
	local configTable = getConfigTable({t, 1})
	local tmp = {getPassValues({t, 1})}
	assert(#tmp == 2)
	assert(tmp[1] == "Alpha")
	assert(tmp[2] == "Bravo")

	assert(getPathString({t, 1}) == MAJOR_VERSION .. "_UnitTest->Name")

	assert(getConfigField({t}, 'name', true, nil, "string") == MAJOR_VERSION .. "_UnitTest")
	assert(getConfigField({t}, 'desc', true, nil, "string") == MAJOR_VERSION .. "_UnitTest")
	assert(getConfigField({t, 1}, 'name', true, nil, "string") == "Name")
	assert(getConfigField({t, 1}, 'desc', true, nil, "string") == "Desc")

	-- test functions
	assert(getConfigField({t, 1}, 'get', false, nil, "boolean") == false)
	assert(select(2, callConfigField({t, 1}, 'get')) == false)
	callConfigField({t, 1}, 'set', {true})
	assert(getConfigField({t, 1}, 'get', false, nil, "boolean") == true)
	assert(select(2, callConfigField({t, 1}, 'get')) == true)
	callConfigField({t, 1}, 'set', {false})
	assert(getConfigField({t, 1}, 'get', false, nil, "boolean") == false)
	assert(select(2, callConfigField({t, 1}, 'get')) == false)

	-- test methods
	assert(getConfigField({t, 2}, 'get', false, nil, "boolean") == true)
	assert(select(2, callConfigField({t, 2}, 'get')) == true)
	callConfigField({t, 2}, 'set', {false})
	assert(getConfigField({t, 2}, 'get', false, nil, "boolean") == false)
	assert(select(2, callConfigField({t, 2}, 'get')) == false)
	callConfigField({t, 2}, 'set', {true})
	assert(getConfigField({t, 2}, 'get', false, nil, "boolean") == true)
	assert(select(2, callConfigField({t, 2}, 'get')) == true)

	-- test negated methods
	assert(getConfigField({t, 3}, 'get', false, nil, "boolean") == false)
	assert(select(2, callConfigField({t, 3}, 'get')) == false)
	callConfigField({t, 3}, 'set', {true})
	assert(getConfigField({t, 3}, 'get', false, nil, "boolean") == true)
	assert(select(2, callConfigField({t, 3}, 'get')) == true)
	callConfigField({t, 3}, 'set', {false})
	assert(getConfigField({t, 3}, 'get', false, nil, "boolean") == false)
	assert(select(2, callConfigField({t, 3}, 'get')) == false)
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local t = { name = MAJOR_VERSION .. "_UnitTest" }
	RockConfig:Embed(t)
	assert(not getConfigTable({t}))
	assert(not hasConfigTable({t}))
	local value = false
	t:SetConfigTable {
		type = 'group',
		name = MAJOR_VERSION .. "_UnitTest",
		desc = MAJOR_VERSION .. "_UnitTest",
		child_type = 'group',
		args = {
			alpha = { name = 'alpha', desc = 'alpha', args = { pants = { name = 'pants', desc = 'pants', type = 'boolean', get = function() end, set = function() end } }},
			bravo = { name = 'bravo', desc = 'bravo', type = 'boolean', args = { pants = {} }, get = function() end, set = function() end }
		}
	}
	assert(hasConfigTable({t}))
	assert(hasConfigTable({t, 'alpha'}))
	assert(hasConfigTable({t, 'bravo'}))
	assert(hasConfigTable({t, 'alpha', 'pants'}))
	assert(not hasConfigTable({t, 'bravo', 'pants'}))
end)
