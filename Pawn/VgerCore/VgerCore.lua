-- VgerCore  by Vger-Azjol-Nerub
-- www.vgermods.com
-- © 2006-2008 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
-- 
-- Version 1.0.2: Conversion to RGB from hex and vice-versa
local VgerCoreThisVersion = 1.02;
-- 
-- VgerCore contains functionality that is shared by Vger's mods.
-- It can be used as a standalone add-on, or embedded within other mods.
--
------------------------------------------------------------

local InitializeOrUpgrade = not (VgerCore and VgerCore.Version and VgerCore.Version >= VgerCoreThisVersion);

-- If the currently loaded version of VgerCore isn't as good as this one, load the new one.
if InitializeOrUpgrade then

VgerCore = {}
VgerCore.Version = VgerCoreThisVersion

-- Common colors
VgerCore.Color = {}

VgerCore.Color.Reset = "|r"

VgerCore.Color.Blue = "|cff8ec3e6"
VgerCore.Color.BlueR = 142 / 255
VgerCore.Color.BlueG = 195 / 255
VgerCore.Color.BlueB = 230 / 255

VgerCore.Color.DarkBlue = "|cff6a92ac"
VgerCore.Color.DarkBlueR = 106 / 255
VgerCore.Color.DarkBlueG = 146 / 255
VgerCore.Color.DarkBlueB = 172 / 255

VgerCore.Color.Green = "|cffb4fe2c"
VgerCore.Color.GreenR = 180 / 255
VgerCore.Color.GreenG = 255 / 255
VgerCore.Color.GreenB = 44 / 255

VgerCore.Color.Orange = "|cfffecf38"
VgerCore.Color.OrangeR = 255 / 255
VgerCore.Color.OrangeG = 207 / 255
VgerCore.Color.OrangeB = 56 / 255

VgerCore.Color.Lemon = "|cfffffdd0"
VgerCore.Color.LemonR = 255 / 255
VgerCore.Color.LemonG = 253 / 255
VgerCore.Color.LemonB = 208 / 255

VgerCore.Color.Salmon = "|cfffe8460"
VgerCore.Color.SalmonR = 255 / 255
VgerCore.Color.SalmonG = 132 / 255
VgerCore.Color.SalmonB = 96 / 255

VgerCore.Color.Beige = "|cffe0dec8"
VgerCore.Color.BeigeR = 224 / 255
VgerCore.Color.BeigeG = 222 / 255
VgerCore.Color.BeigeB = 200 / 255

VgerCore.Color.White = "|cffffffff"
VgerCore.Color.WhiteR = 255 / 255
VgerCore.Color.WhiteG = 255 / 255
VgerCore.Color.WhiteB = 255 / 255

VgerCore.Color.Grey = "|cff909090"
VgerCore.Color.GreyR = 144 / 255
VgerCore.Color.GreyG = 144 / 255
VgerCore.Color.GreyB = 144 / 255

VgerCore.Color.Silver = "|cffc0c0c0"
VgerCore.Color.SilverR = 192 / 255
VgerCore.Color.SilverG = 192 / 255
VgerCore.Color.SilverB = 192 / 255

VgerCore.Color.Black= "|cff000000"
VgerCore.Color.BlackR = 0 / 255
VgerCore.Color.BlackG = 0 / 255
VgerCore.Color.BlackB = 0 / 255

VgerCore.MoneyColor = {}
VgerCore.MoneyColor.Gold = "|cffecda90"
VgerCore.MoneyColor.Silver = "|cffd7d5d8"
VgerCore.MoneyColor.Copper = "|cffe2ad8e"

-- Common sounds
VgerCore.Sound = {}
VgerCore.Sound.Bell = "Sound\\Interface\\RaidWarning.wav"
VgerCore.Sound.Fanfare = "Sound\\Spells\\NetherwindFocusImpact.wav"


-- Displays a standard VgerCore message.
function VgerCore.Message(Text)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(VgerCore.Color.Orange .. tostring(Text))
	else
		message(VgerCore.Color.Orange .. tostring(Text))
	end
end

-- Displays a bunch of messages from one string, separated by newlines.
-- Notes:
-- 	* Colors specified at the beginning of Text will not propagate to subsequent lines of Text.
-- 	Use the optional Color parameter instead.
-- 	* Empty lines will be skipped.  Add a space to the line if you want it to be printed.
function VgerCore.MultilineMessage(Text, Color)
	local Line
	local ColorString = Color
	if not ColorString then ColorString = "" end
	for Line in string.gmatch(Text, "[^\r\n]+") do
		VgerCore.Message(ColorString .. Line)
	end
end

-- Displays a large VgerCore message.
function VgerCore.BigMessage(Text)
	if UIErrorsFrame then
		UIErrorsFrame:AddMessage(tostring(Text), VgerCore.Color.GreenR, VgerCore.Color.GreenG, VgerCore.Color.GreenB, 1.0, 4.0)
	end
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(VgerCore.Color.Green .. tostring(Text))
	end
end

-- Displays a VgerCore error message if the condition is false.
function VgerCore.Assert(Condition, Message)
	-- Possibility: call the assert() function to get a callstack and integrate with mods such as Swatter.
	if not Condition then VgerCore.Fail(Message) end
end

-- Displays a VgerCore error message.
function VgerCore.Fail(Message)
	VgerCore.Message(VgerCore.Color.Salmon .. "ERROR:  " .. VgerCore.Color.White .. tostring(Message))
end

-- Hooks an insecure function.  Similar to the base WoW API's hooksecurefunc.  The hook function will be run
-- after the original function to be hooked.
-- Valid usage:
-- VgerCore.HookInsecureFunction(Object, FunctionName, Hook)
-- VgerCore.HookInsecureFunction(FunctionName, Hook)
function VgerCore.HookInsecureFunction(arg1, arg2, arg3)
	local TypeOfObject = type(arg1)
	local OldFunction
	if TypeOfObject == "table" then -- Object, FunctionName, Hook
		OldFunction = arg1[arg2]
		if OldFunction then
			arg1[arg2] = VgerCore.CreateHookFunction(OldFunction, arg3)
		else
			VgerCore.Fail("VgerCore.HookInsecureFunction: could not find member function '" .. arg2 .. "'.")
		end
	elseif TypeOfObject == "string" then -- FunctionName, Hook
		OldFunction = getglobal(arg1)
		if OldFunction then
			_G = getfenv()
			_G[arg1] = VgerCore.CreateHookFunction(OldFunction, arg2)
		else
			VgerCore.Fail("VgerCore.HookInsecureFunction: could not find function '" .. arg1 .. "'.")
		end
	else
		VgerCore.Fail("VgerCore.HookInsecureFunction argument 1 must be table or string, not " .. TypeOfObject .. ".")
	end
end

-- Hooks an insecure script handler.  Works just like HookInsecureFunction(Object, FunctionName, Hook), except that
-- instead of a function name, a script name is passed.
function VgerCore.HookInsecureScript(Object, ScriptName, Hook)
	local OldFunction = Object:GetScript(ScriptName)
	if OldFunction then
		Object:SetScript(ScriptName, VgerCore.CreateHookFunction(OldFunction, Hook))
	else
		Object:SetScript(ScriptName, Hook)
	end
end

-- Internal function used by HookInsecureFunction.
function VgerCore.CreateHookFunction(OldFunction, Hook)
	return function(...)
		local ReturnValue = OldFunction(...)
		Hook(...)
		return ReturnValue
	end
end

-- Executes a chat command just as if it were typed in the chat window.
-- Returns true if successful, or false if not (primarily if the command is a secure function, such as /cast).
function VgerCore.ExecuteChatCommand(Command)
	if not ChatFrameEditBox then return false end
	
	-- First, make sure that this command is okay.
	local _, _, SlashCommand = string.find(Command, "^(/%w+) ")
	if SlashCommand then
		if IsSecureCmd(SlashCommand) then
			VgerCore.Fail(SlashCommand .. " is a secure command and cannot be run automatically.")
			return false
		end
	end

	-- Now, execute the chat command.
	local PreviousText = ChatFrameEditBox:GetText()
	ChatFrameEditBox:SetText(Command)
	ChatEdit_SendText(ChatFrameEditBox)
	ChatFrameEditBox:SetText(PreviousText)
	return true
end

-- Runs a macro.
-- Returns true if successful, or false if not.
function VgerCore.RunMacro(MacroName)
	-- First, get the text of the macro.
	local _, _, Script, _ = GetMacroInfo(MacroName)
	if not Script then return false end

	-- Then, execute each line individually.  Ignore comments marked with # or -.
	local Line
	for Line in string.gmatch(Script, "[^\n]+") do
		local FirstChar = string.sub(Line, 1, 1)
		if FirstChar ~= "#" and FirstChar ~= "-" then
			VgerCore.ExecuteChatCommand(Line)
		end
	end
	return true
end

-- Returns true if the user is in a Battleground, or false if not.
function VgerCore.IsInBattleground()
	for Battleground = 1, MAX_BATTLEFIELD_QUEUES do
		local Status, _, _ = GetBattlefieldStatus(Battleground)
		if Status == "active" then return true end
	end
	return false
end

-- Comparer function for use in table.sort that sorts strings alphabetically, ignoring case.
function VgerCore.CaseInsensitiveComparer(a, b)
	return string.lower(a) < string.lower(b)
end

-- Returns a six-digit hex string for three RGB values 0-1.
function VgerCore.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Returns RGB values 0-1 for a six-digit hex string, or nil if unsuccessful.
function VgerCore.HexToRGB(hex)
	if not hex or string.len(hex) ~= 6 then return end
	local r, g, b = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	r, g, b = r or 0, g or 0, b or 0
	return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

end -- if InitializeOrUpgrade
