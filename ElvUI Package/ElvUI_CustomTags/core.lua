--Add access to ElvUI engine and unitframe framework
local E = unpack(ElvUI);
local ElvUF = ElvUI.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

local AddOnName = ...
LibStub("LibElvUIPlugin-1.0"):RegisterPlugin(AddOnName)

--Cache global variables
--Lua functions
local _G = _G
local unpack, pairs, assert = unpack, pairs, assert
local twipe = table.wipe
local ceil, sqrt, floor, abs = math.ceil, math.sqrt, math.floor, math.abs
local format, strupper, len, utf8sub = string.format, strupper, string.len, string.utf8sub
--WoW API
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

--GLOBALS: _TAGS, Hex, _COLORS

local textFormatStyles = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] =  "%s - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%s"
}

local textFormatStylesNoDecimal = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] =  "%s - %.0f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.0f%%",
	["PERCENT"] = "%.0f%%",
	["DEFICIT"] = "-%s"
}

local shortValueFormat
local function ShortValue(number, noDecimal)
	shortValueFormat = (noDecimal and "%.0f%s" or "%.1f%s")
	if E.db.general.numberPrefixStyle == "METRIC" then
		if abs(number) >= 1e9 then
			return format("%.1f%s", number / 1e9, "G")
		elseif abs(number) >= 1e6 then
			return format("%.1f%s", number / 1e6, "M")
		elseif abs(number) >= 1e3 then
			return format(shortValueFormat, number / 1e3, "k")
		else
			return format("%d", number)
		end
	elseif E.db.general.numberPrefixStyle == "CHINESE" then
		if abs(number) >= 1e8 then
			return format("%.1f%s", number / 1e8, "Y")
		elseif abs(number) >= 1e4 then
			return format("%.1f%s", number / 1e4, "W")
		else
			return format("%d", number)
		end
	else
		if abs(number) >= 1e9 then
			return format("%.1f%s", number / 1e9, "B")
		elseif abs(number) >= 1e6 then
			return format("%.1f%s", number / 1e6, "M")
		elseif abs(number) >= 1e3 then
			return format(shortValueFormat, number / 1e3, "K")
		else
			return format("%d", number)
		end
	end
end

local function GetFormattedText(min, max, style, noDecimal)
	assert(textFormatStyles[style] or textFormatStylesNoDecimal[style], "CustomTags Invalid format style: "..style)
	assert(min, "CustomTags - You need to provide a current value. Usage: GetFormattedText(min, max, style, noDecimal)")
	assert(max, "CustomTags - You need to provide a maximum value. Usage: GetFormattedText(min, max, style, noDecimal)")

	if max == 0 then max = 1 end

	local chosenFormat
	if noDecimal then
		chosenFormat = textFormatStylesNoDecimal[style]
	else
		chosenFormat = textFormatStyles[style]
	end

	if style == "DEFICIT" then
		local deficit = max - min
		if deficit <= 0 then
			return ""
		else
			return format(chosenFormat, ShortValue(deficit, noDecimal))
		end
	elseif style == "PERCENT" then
		return format(chosenFormat, min / max * 100)
	elseif style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max) then
		if noDecimal then
			return format(textFormatStylesNoDecimal["CURRENT"], ShortValue(min, noDecimal))
		else
			return format(textFormatStyles["CURRENT"], ShortValue(min, noDecimal))
		end
	elseif style == "CURRENT_MAX" then
		return format(chosenFormat, ShortValue(min, noDecimal), ShortValue(max, noDecimal))
	elseif style == "CURRENT_PERCENT" then
		return format(chosenFormat, ShortValue(min, noDecimal), min / max * 100)
	elseif style == "CURRENT_MAX_PERCENT" then
		return format(chosenFormat, ShortValue(min, noDecimal), ShortValue(max, noDecimal), min / max * 100)
	end
end

ElvUF.Tags.Events["num:targeting"] = "UNIT_TARGET PLAYER_TARGET_CHANGED RAID_ROSTER_UPDATE"
ElvUF.Tags.Methods["num:targeting"] = function(unit)
	if not IsInGroup() then return "" end
	local targetedByNum = 0

	--Count the amount of other people targeting the unit
	for i = 1, GetNumRaidMembers() do
		local groupUnit = (IsInRaid() and "raid"..i or "party"..i);
		if (UnitIsUnit(groupUnit.."target", unit) and not UnitIsUnit(groupUnit, "player")) then
			targetedByNum = targetedByNum + 1
		end
	end

	--Add 1 if we"re targeting the unit too
	if UnitIsUnit("playertarget", unit) then
		targetedByNum = targetedByNum + 1
	end

	return (targetedByNum > 0 and targetedByNum or "")
end

ElvUF.Tags.Events["health:percent:hidefull"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
ElvUF.Tags.Methods["health:percent:hidefull"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current:hidefull"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current:hidefull"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current-percent:hidefull"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current-percent:hidefull"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:percent:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
ElvUF.Tags.Methods["health:percent:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current-percent:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current-percent:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:percent:hidefull:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
ElvUF.Tags.Methods["health:percent:hidefull:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current:hidefull:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current:hidefull:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["health:current-percent:hidefull:hidedead"] = "UNIT_HEALTH UNIT_MAXHEALTH"
ElvUF.Tags.Methods["health:current-percent:hidefull:hidedead"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:percent:hidefull"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:percent:hidefull"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current:hidefull"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current:hidefull"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current-percent:hidefull"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current-percent:hidefull"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if deficit <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:percent:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:percent:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local String

	if min <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local String

	if min <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current-percent:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current-percent:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local String

	if min <= 0 then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:percent:hidefull:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:percent:hidefull:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0 or min <= 0) then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current:hidefull:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current:hidefull:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0 or min <= 0) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current-percent:hidefull:hidezero"] = "UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_MAXRUNIC_POWER UNIT_RUNIC_POWER"
ElvUF.Tags.Methods["power:current-percent:hidefull:hidezero"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0 or min <= 0) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:percent:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:percent:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:current:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current-percent:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:current-percent:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:percent:hidefull:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:percent:hidefull:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current:hidefull:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:current:hidefull:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT", true)
	end

	return String
end

ElvUF.Tags.Events["power:current-percent:hidefull:hidedead"] = "UNIT_DISPLAYPOWER UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_HEALTH"
ElvUF.Tags.Methods["power:current-percent:hidefull:hidedead"] = function(unit)
	local pType = UnitPowerType(unit)
	local min, max = UnitPower(unit, pType), UnitPowerMax(unit, pType)
	local deficit = max - min
	local String

	if (deficit <= 0) or (min == 0) or (UnitIsGhost(unit) or UnitIsDead(unit)) then
		String = ""
	else
		String = GetFormattedText(min, max, "CURRENT_PERCENT", true)
	end

	return String
end

ElvUF.Tags.Events["deficit:name:colors"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["deficit:name:colors"] = function(unit)
	local missinghp = _TAGS["missinghp"](unit)
	local String
	
	if missinghp then
		local healthcolor = _TAGS["healthcolor"](unit)
		String = format("%s-%s|r", healthcolor, missinghp)
	else
		local name = _TAGS["name"](unit)
		local namecolor = _TAGS["namecolor"](unit)
		String = format("%s%s|r", namecolor, name)
	end
	
	return String
end

ElvUF.Tags.Events["name:caps"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:caps"] = function(unit)
    local name = UnitName(unit)
    return name ~= nil and strupper(name) or ""
end

ElvUF.Tags.Events["name:abbreviate"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:abbreviate"] = function(unit)
	local name = UnitName(unit)

	if name then
		name = name:gsub("(%S+) ", function(t) return utf8sub(t,1,1)..". " end)
	end

	return name
end

ElvUF.Tags.Events["name:veryshort:abbreviate"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:veryshort:abbreviate"] = function(unit)
	local name = UnitName(unit)

	if name and len(name) > 5 then
		name = name:gsub("(%S+) ", function(t) return utf8sub(t,1,1)..". " end)
	end

	return name
end

ElvUF.Tags.Events["name:short:abbreviate"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:short:abbreviate"] = function(unit)
	local name = UnitName(unit)

	if name and len(name) > 10 then
		name = name:gsub("(%S+) ", function(t) return utf8sub(t,1,1)..". " end)
	end

	return name
end

ElvUF.Tags.Events["name:medium:abbreviate"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:medium:abbreviate"] = function(unit)
	local name = UnitName(unit)

	if name and len(name) > 15 then
		name = name:gsub("(%S+) ", function(t) return utf8sub(t,1,1)..". " end)
	end

	return name
end

ElvUF.Tags.Events["name:long:abbreviate"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["name:long:abbreviate"] = function(unit)
	local name = UnitName(unit)

	if name and len(name) > 20 then
		name = name:gsub("(%S+) ", function(t) return utf8sub(t,1,1)..". " end)
	end

	return name
end

ElvUF.Tags.Events["faction:icon"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["faction:icon"] = function(unit)
	local faction = UnitFactionGroup(unit)
	local str = ""
	
	if faction == "Alliance" then
		str = "|TInterface\\AddOns\\ElvUI_CustomTags\\Media\\Alliance:0:0:0:-1|t"
	elseif faction == "Horde" then
		str = "|TInterface\\AddOns\\ElvUI_CustomTags\\Media\\Horde:0:0:0:-1|t"
	end
	
	return str
end

ElvUF.Tags.Methods["classcolor:player"] = function()
	local _, unitClass = UnitClass("player")
	local String

	if unitClass then
		String = Hex(_COLORS.class[unitClass])
	else
		String = "|cFFC2C2C2"
	end
	
	return String
end

ElvUF.Tags.Methods["classcolor:hunter"] = function()
	return Hex(_COLORS.class["HUNTER"])
end

ElvUF.Tags.Methods["classcolor:warrior"] = function()
	return Hex(_COLORS.class["WARRIOR"])
end

ElvUF.Tags.Methods["classcolor:paladin"] = function()
	return Hex(_COLORS.class["PALADIN"])
end

ElvUF.Tags.Methods["classcolor:mage"] = function()
	return Hex(_COLORS.class["MAGE"])
end

ElvUF.Tags.Methods["classcolor:priest"] = function()
	return Hex(_COLORS.class["PRIEST"])
end

ElvUF.Tags.Methods["classcolor:warlock"] = function()
	return Hex(_COLORS.class["WARLOCK"])
end

ElvUF.Tags.Methods["classcolor:shaman"] = function()
	return Hex(_COLORS.class["SHAMAN"])
end

ElvUF.Tags.Methods["classcolor:deathknight"] = function()
	return Hex(_COLORS.class["DEATHKNIGHT"])
end

ElvUF.Tags.Methods["classcolor:druid"] = function()
	return Hex(_COLORS.class["DRUID"])
end

ElvUF.Tags.Methods["classcolor:rogue"] = function()
	return Hex(_COLORS.class["ROGUE"])
end