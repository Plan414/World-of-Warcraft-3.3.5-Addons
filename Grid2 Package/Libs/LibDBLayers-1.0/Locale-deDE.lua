--[[
	LibKeyBound-1.0 localization file
		Deutch by Gamefaq
--]]

if (GetLocale() ~= "deDE") then
	return
end

local REVISION = 90000 + tonumber(("$Revision: 2 $"):match("%d+"))
if (LibKeyBoundLocale10 and REVISION <= LibKeyBoundLocale10.REVISION) then
	return
end

LibKeyBoundLocale10 = {
	REVISION = REVISION;
	Enabled = "Tastenzuweisung Modus aktiviert";
	Disabled = "Tastenzuweisung Modus deaktiviert";
	ClearTip = format("Drücke %s um alle Tastenzuweisungen zu löschen", GetBindingText("ESCAPE", "KEY_"));
	NoKeysBoundTip = "Keine Tasten zugewiesen";
	ClearedBindings = "Entferne alle Zuweisungen von %s";
	BoundKey = "Setze %s zu %s";
	UnboundKey = "Entferne %s von %s";
	CannotBindInCombat = "Kann Tasten nicht im Kampf zuweisen";
	CombatBindingsEnabled = "Verlasse Kampf, Tastenzuweisung Modus aktiviert";
	CombatBindingsDisabled = "Beginne Kampf, Tastenzuweisung Modus deaktiviert";
	BindingsHelp = "Schwebe mit der Maus über einem Schalter. Drück dann eine Taste um sie zuzuweisen. Um die Belegung der Taste wieder zu löschen drück %s.";

	-- This is the short display version you see on the Button
	["Alt"] = "A",
	["Ctrl"] = "S",
	["Shift"] = "U",
	["NumPad"] = "N",

	["Backspace"] = "BS",
	["Button1"] = "B1",
	["Button2"] = "B2",
	["Button3"] = "B3",
	["Button4"] = "B4",
	["Button5"] = "B5",
	["Button6"] = "B6",
	["Button7"] = "B7",
	["Button8"] = "B8",
	["Button9"] = "B9",
	["Button10"] = "B10",
	["Button11"] = "B11",
	["Button12"] = "B12",
	["Button13"] = "B13",
	["Button14"] = "B14",
	["Button15"] = "B15",
	["Capslock"] = "Cp",
	["Clear"] = "Cl",
	["Delete"] = "Del",
	["End"] = "En",
	["Home"] = "HM",
	["Insert"] = "Ins",
	["Mouse Wheel Down"] = "WD",
	["Mouse Wheel Up"] = "WU",
	["Num Lock"] = "NL",
	["Page Down"] = "PD",
	["Page Up"] = "PU",
	["Scroll Lock"] = "SL",
	["Spacebar"] = "Sp",
	["Tab"] = "Tb",

	["Down Arrow"] = "DA",
	["Left Arrow"] = "LA",
	["Right Arrow"] = "RA",
	["Up Arrow"] = "UA",
}
setmetatable(LibKeyBoundLocale10, {__index = LibKeyBoundBaseLocale10})
