--lua
local unpack, select
=     unpack, select
--wow api
local ConvertRGBtoColorString
=     ConvertRGBtoColorString

local BestInSlot, L, AceGUI = unpack(select(2, ...))
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BestInSlotRedux")
local Credits = BestInSlot:GetMenuPrototype(L["Credits"])
local hordeColor, allianceColor
Credits.Width = 600
Credits.Height = 600

-- Name variables for locales since some were weirdly missing
local sDEDE, sESES, sESMX, sFRFR, sITIT, sKOKR, sPTBR, sRURU, sZHCN, sZHTW
=     "German", "Spanish", "Spanish (Latin America)", "French", "Italian", "Korean", "Brazilian Portuguese", "Russian", "Simplified Chinese", "Traditional Chinese"

function Credits:CreateTranslatorLabel(language, name)
  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText(("%s: %s"):format(language, name))
  return label
end

function Credits:CreateTesterLabel(name, realm, class, faction)
  local label = AceGUI:Create("Label")
  local txt = name
  if class then
    txt = "|c"..RAID_CLASS_COLORS[class].colorStr..txt.."|r"
  end
  if realm then
   txt = txt.." - "
    if faction then
      local factionStr = ""
      if faction == "A" then
        if not allianceColor then allianceColor = ConvertRGBtoColorString(PLAYER_FACTION_COLORS[1]) end
        factionStr = allianceColor
      elseif faction == "H" then
        if not hordeColor then hordeColor = ConvertRGBtoColorString(PLAYER_FACTION_COLORS[0]) end
        factionStr = hordeColor 
      end
      txt = txt..factionStr
    end
    txt = txt..realm.."|r"
  end
  label:SetFullWidth(true)
  label:SetText(txt)
  return label
end

function Credits:Draw(container)
  container:SetLayout("Fill")
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  container:AddChild(scroll)
  
  local header = AceGUI:Create("Heading")
  header:SetText("Foreword")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  -- foreword
  local label = AceGUI:Create("Label")
  label:SetText(
    "I have developped this AddOn. But the credit doesn't go solely to me.\n"..
    "There have been a lot of people making awesome recommendations and I'd like to include them in here as a way of thanking them.\n"..
    "This page is intentionally untranslated in other languages because it is my personal message to those that helped me.\n"..
    "\n"..
    "Thanks for taking the time to read these credits.\n"..
    "\n"..
    "With kind regards "..self.Author1..
    "\n\n----------\n\n"..
    "I want to thank Baleria for letting me take over this project.\n"..
    "The work you have put down into this AddOn is really amazing and it has been a pleasure figuring out how it works.\n"..
    "-"..self.Author2
  )
  label:SetFullWidth(true)
  scroll:AddChild(label)
  
  local header = AceGUI:Create("Heading")
  header:SetText("Authors")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  
  label = AceGUI:Create("Label")
  label:SetText(self.Author)
  label:SetFullWidth(true)
  -- authors
  scroll:AddChild(self:CreateTesterLabel("Beleria",   "Argent Dawn-EU", "DEMONHUNTER",  "A"))
  scroll:AddChild(self:CreateTesterLabel("Anhility",  "Ravencrest-EU",  "PALADIN",      "A"))
  scroll:AddChild(self:CreateTesterLabel("Sar\195\173th",  "Tarren Mill-EU",  "ROGUE",      "A"))
  
  local header = AceGUI:Create("Heading")
  header:SetText("Contributors")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  -- contributors
  scroll:AddChild(self:CreateTesterLabel("Sannath", "Elune-EU", "DRUID", "A"))
  
  local header = AceGUI:Create("Heading")
  header:SetText("Official Websites")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  -- urls
  scroll:AddChild(self:CreateUneditableTextbox("https://www.curseforge.com/wow/addons/bestinslotredux", "BestInSlotRedux on Curse.com"))
  scroll:AddChild(self:CreateUneditableTextbox("https://github.com/anhility/BestInSlotRedux", "BestInSlotRedux on Github.com"))
  
  local header = AceGUI:Create("Heading")
  header:SetText("Translators")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  -- Translators
  scroll:AddChild(self:CreateTranslatorLabel(sDEDE, "Rushgarroth1337 & SpeedsharkX"))
  --scroll:AddChild(self:CreateTranslatorLabel(sESES, "to be added"))
  scroll:AddChild(self:CreateTranslatorLabel(sESMX, "xylons"))
  scroll:AddChild(self:CreateTranslatorLabel(sFRFR, "Meivyn & nitrodroki"))
  --scroll:AddChild(self:CreateTranslatorLabel(sITIT, "to be added"))
  --scroll:AddChild(self:CreateTranslatorLabel(sKOKR, "to be added"))
  scroll:AddChild(self:CreateTranslatorLabel(sPTBR, "Carlinha"))
  scroll:AddChild(self:CreateTranslatorLabel(sRURU, "Hubbotu & SintlKun"))
  --scroll:AddChild(self:CreateTranslatorLabel(sZHCN, "to be added"))
  scroll:AddChild(self:CreateTranslatorLabel(sZHTW, "gaspy10"))
  
  -- Old translators
  local label=AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText(
    "\n\n"..
    "I want to acknowledge the following people who did the previous translations that unfortunately were lost:\n"..
    sDEDE..": Simcat & neo0608\n"..
    sESES..": Luskaner\n"..
    sKOKR..": yuk6196 & cyberyahoo\n"..
    sRURU..": KAPMA & Je\195\177ka\n"..
    sZHCN..": nrg3331"
  )
  scroll:AddChild(label)
  
  -- Translation help
  scroll:AddChild(self:CreateUneditableTextbox("https://wow.curseforge.com/projects/bestinslotredux/localization", "Want to help translate BestInSlotRedux?"))
  
  local header = AceGUI:Create("Heading")
  header:SetText("Testers")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  
  scroll:AddChild(self:CreateTesterLabel("Yulrich",       "Argent Dawn-EU",         "PRIEST", "A"))
  scroll:AddChild(self:CreateTesterLabel("Mard",          "Steamwheedle Cartel-EU", "DRUID",  "H"))
  scroll:AddChild(self:CreateTesterLabel("Minta",         "Defias Brotherhood-EU",  "PRIEST", "H"))
  scroll:AddChild(self:CreateTesterLabel("Peanut",        "Defias Brotherhood-EU",  "HUNTER", "A"))
  scroll:AddChild(self:CreateTesterLabel("Nema\195\175r", "Defias Brotherhood-EU",  "MAGE",   "A"))
  
  local header = AceGUI:Create("Heading")
  header:SetText("Special Thanks")
  header:SetFullWidth(true)
  scroll:AddChild(header)
  
  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText(
    "Special thanks to the guild <Shadowsongs Bane>.\n"..
    "When the AddOn was in early development they allowed me to extensively test it.\n"..
    "So for everyone I haven't mentioned in person from Shadowsongs Bane, thanks!\n-"..self.Author1
  )
  scroll:AddChild(label)
end