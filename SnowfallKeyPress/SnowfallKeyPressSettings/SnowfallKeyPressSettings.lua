-- This is the configuration settings file for SnowfallKeyPress. 
--
-- You can also configure the addon in game through the usual
-- Options->Interface->Addons menu.
--
-- In order to create your own configuration settings, copy the whole
--   Interface\Addons\SnowfallKeyPress\SnowfallKeyPressSettings
-- folder and paste it at the
--   Interface\Addons
-- level. Then edit the settings in
--   Interface\Addons\SnowfallKeyPressSettings\SnowfallKeyPressSettings.lua
-- to your liking.
--
-- When you see two adjacent hyphens on a line, the remainder of the line is a
-- comment for you to read. These comments have no effect on the addon
-- configuration, and they are there purely for your information.


-- Do not modify the following two lines.
if (SnowfallKeyPress) then return end
SnowfallKeyPress = {settings = {


  -- This is a full list of keys that SnowfallKeyPress will accelerate.
  -- Feel free to add or delete keys to suit your language and preferences.
  -- By default, all modifier (ALT, CTRL, and SHIFT) combinations for each key
  -- specified below will be accelerated.
  --
  -- If you want to accelerate only certain modifier combinations for a
  -- particular key, then add those modifers (in order of ALT, CTRL, SHIFT) in
  -- front of the key, separated by hyphens (-). For example, if you wanted to
  -- only accelerate ALT-CTRL-SHIFT-A and not any other modified or unmodified
  -- presses of A, then you'd add this line:
  --   "ALT-CTRL-SHIFT-A",
  --
  -- If you want to accelerate only the unmodified version of a key, then
  -- precede the key by a hyphen (-). For example, if you only wanted to
  -- accelerate an unmodified press of A and not any modified presses of A, then
  -- you'd add this line:
  --   "-A",
  --
  -- You can add as many specific modifer combinations for each key as you like.
  --
  -- If you don't know what the name of a particular special key on your
  -- keyboard is, then bind that key to a global binding in
  -- Options->Keybindings, exit the game, and look in your
  --   WTF\Account\<account name>\bindings-cache.wtf
  -- file for that binding to determine the key name.
  keys = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "`",
    "-",
    "=",
    "[",
    "]",
    "\\",
    ";",
    "'",
    ".",
    ",",
    "/",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "F10",
    "F11",
    "F12",
--  "F13",
--  "F14",
--  "F15",
    "BACKSPACE",
    "DELETE",
    "DOWN",
    "END",
    "ENTER",
    "ESCAPE",
    "HOME",
    "INSERT",
    "LEFT",
    "NUMLOCK",
    "NUMPAD0",
    "NUMPAD1",
    "NUMPAD2",
    "NUMPAD3",
    "NUMPAD4",
    "NUMPAD5",
    "NUMPAD6",
    "NUMPAD7",
    "NUMPAD8",
    "NUMPAD9",
    "NUMPADDECIMAL",
    "NUMPADDIVIDE",
    "NUMPADMINUS",
    "NUMPADMULTIPLY",
    "NUMPADPLUS",
    "PAGEDOWN",
    "PAGEUP",
    "PAUSE",
--  "PRINTSCREEN",
    "RIGHT",
    "SCROLLLOCK",
    "SPACE",
    "TAB",
    "UP",
--  "BUTTON1",
--  "BUTTON2",
    "BUTTON3",
    "BUTTON4",
    "BUTTON5",
--  "BUTTON6",
--  "BUTTON7",
--  "BUTTON8",
--  "BUTTON9",
--  "BUTTON10",
--  "BUTTON11",
--  "BUTTON12",
--  "BUTTON13",
--  "BUTTON14",
--  "BUTTON15",
--  "BUTTON16",
--  "BUTTON17",
--  "BUTTON18",
--  "BUTTON19",
--  "BUTTON20",
--  "BUTTON21",
--  "BUTTON22",
--  "BUTTON23",
--  "BUTTON24",
--  "BUTTON25",
--  "BUTTON26",
--  "BUTTON27",
--  "BUTTON28",
--  "BUTTON29",
--  "BUTTON30",
--  "BUTTON31",
  };


  -- This is a full list of modifier keys that SnowfallKeyPress supports.
  -- By default, all keys above will be accelerated for all combinations of
  -- these modifiers.
  modifiers = {
    "ALT",
    "CTRL",
    "SHIFT",
  };


-- Do not modify the following line.
}}
