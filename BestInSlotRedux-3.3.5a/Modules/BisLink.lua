--lua
local unpack, select, tonumber
=     unpack, select, tonumber
local Ambiguate, strsplit, strjoin, UnitFullName, GetSpecializationInfoByID
=     Ambiguate, strsplit, strjoin, UnitFullName, GetSpecializationInfoByID
local BestInSlot, L = unpack(select(2, ...))
local BiSLink = BestInSlot:NewModule("BiSLink", "AceHook-3.0")
BiSLink.format = "%[%[BestInSlot:(%d):(%w+):(%d+):(%d+)%]%]" --Format BestInSlot:TYPE:TYPE_ID:DIFFICULTY:SPEC
BiSLink.linkformat = BiSLink.colorNormal.."\124HBiSLink:%s\124h[%s]\124r\124h"
BiSLink.chatfilter = {}

local function chatFilter(...)
  return BiSLink:ApplyChatFilter(...)
end

function BiSLink:OnInitialize()
  self:Print("Initialized")
end

function BiSLink:OnEnable()
  --self:SecureHook("ChatFrame_OnHyperlinkShow", "OnHyperlinkShow")
  self:RawHook(ItemRefTooltip, "SetHyperlink", "OnSetHyperlink", true)
  self:RegisterChats()
end

function BiSLink:OnDisable()
  --self:Unhook("ChatFrame_OnHyperlinkShow")
  self:Unhook(ItemRefTooltip, "SetHyperlink")
  self:RegisterChats(true)
end

function BiSLink:GetShareLink(source, type, typeinfo, difficulty, spec)
  return ("[[BestInSlot:%d:%s:%d:%d]]"):format(type, typeinfo, difficulty, spec)
end

--[[function BiSLink:OnHyperlinkShow(self, ...)
  BestInSlot.console:Add("OnHyperlinkShow params", ...)
end]]

function BiSLink:OnSetHyperlink(tooltip, link, ...)
  if link:sub(1,7) == "BiSLink" then
    local linkid, sender, type, typeinfo, difficulty, spec = strsplit(":",link)
    if sender == "invalid" then return end
    type = tonumber(type)
    difficulty = tonumber(difficulty)
    spec = tonumber(spec)
    local raidtier = type == self.RAIDTIER and tonumber(typeinfo) or self:GetRaidTiers(type, typeinfo)
    if not type then return end
    if sender == strjoin("-", UnitFullName("player")) then
      local bislist, slots = self:GetBestInSlotItems(raidtier, difficulty, spec)
      local pi = self:GetPlayerInfo()
      pi.spec = self:GetSelected(BestInSlot.SPECIALIZATION)
      BestInSlot.Preview:Show(bislist,difficulty, pi, slots)
    else
      local charinfo = nil
      local bisinfo = nil
      local raidtiereventid = self:RegisterEvent("AddonMessage_requestRaidTierReply", function(_, bislist, channel, source)
        if (sender):find(source) then
          if bislist[spec] then
            bisinfo = bislist[spec]
          end
        end
      end)
      local charinfoeventid = self:RegisterEvent("AddonMessage_charinforeply", function(_, info, channel, source)
        if (sender):find(source) then
          charinfo = info
        end
      end)
      local function onTimerEnd(success)
        self:UnregisterEvent("AddonMessage_requestRaidTierReply",raidtiereventid)
        self:UnregisterEvent("AddonMessage_charinforeply",charinfoeventid)
        if success then
          charinfo.spec = spec
          BestInSlot.Preview:Show(bisinfo, difficulty, charinfo)
        else
          BiSLink:Print(L["Failed to get info from %s"]:format(sender))
        end
      end
      local function verifySuccess()
        return charinfo and bisinfo and true
      end
      self.Timer:NewTimer(0.1, onTimerEnd, verifySuccess, 2)
      self:SendAddonMessage("requestRaidTier", {selection = raidtier, difficulty = difficulty}, "WHISPER", sender)
      self:SendAddonMessage("requestcharinfo", nil, "WHISPER", sender)
    end
  else
    self.hooks[ItemRefTooltip].SetHyperlink(tooltip, link, ...)
  end
end

function BiSLink:Validate(type, typeinfo, difficulty, spec, sender)
  if not type or not typeinfo or not difficulty or not spec or not sender then return false, "Invalid BiS link - Arguments missing" end
  difficulty = tonumber(difficulty)
  local raidtier 
  if type == self.RAIDTIER then
    raidtier = tonumber(typeinfo)
  else
    raidtier = self:GetRaidTiers(type, typeinfo)
  end
  if not raidtier or not tContains(self:GetRaidTiers(), raidtier) then return false, "Invalid BiS link - Not supported" end
  local typeDescr = self:GetDescription(self.RAIDTIER, raidtier)
  local difficulties = self:GetDifficulties(self.RAIDTIER, raidtier)
  if not difficulties or not difficulties[difficulty] then return false, "Invalid BiS link - Difficulty not supported" end
  local difficDescr = self:GetDescription(self.DIFFICULTY, raidtier, difficulty)
  if not GetSpecializationInfoByID(spec) then return false, "Invalid BiS link - Unknown specialization" end
  return true, L["%1$s's %2$s list for %3$s %4$s"]:format(Ambiguate(sender, "all"), self.colorHighlight.."BestInSlot"..self.colorNormal, typeDescr, difficDescr)
end

function BiSLink:MakeLink(text, first, last, type, typeinfo, difficulty, spec, sender)
  type = tonumber(type)
  local prependText = text:sub(1, first - 1)
  local appendText = text:sub(last + 1)
  local formattedSender = Ambiguate(sender, "mail")
  local valid, str = self:Validate(type, typeinfo, difficulty, spec, sender)
  if valid then
    return prependText..self.linkformat:format(formattedSender..":"..type..":"..typeinfo..":"..difficulty..":"..spec, str)..appendText, valid
  else
    return prependText..self.linkformat:format("invalid", str)..appendText, valid
  end
end

function BiSLink:ApplyChatFilter(chatframe, event, text, sender, lang, channel, ...)
  local first, last, type, typeinfo, difficulty, spec = text:find(self.format)
  if first then
    local valid
    text, valid = self:MakeLink(text, first, last, type, typeinfo, difficulty, spec, sender)
    if valid then 
      self.chatfilter[sender] = time()
      C_Timer.After(0.01, function()
        BiSLink.chatfilter[sender] = false
      end)
    end
  elseif self.chatfilter[sender] then
    if (time() - 1) > self.chatfilter[sender] then --prevents the filtering to be on for longer then 1 second
      self.chatfilter[sender] = false
    elseif text:find("item:") then --only filter itemlinks
      return true
    end 
  end
  return false, text, sender, lang, channel, ...
end

function BiSLink:RegisterChats(disable)
  local func = disable and ChatFrame_RemoveMessageEventFilter or ChatFrame_AddMessageEventFilter
  func("CHAT_MSG_CHANNEL", chatFilter)
  func("CHAT_MSG_YELL", chatFilter)
  func("CHAT_MSG_GUILD", chatFilter)
  func("CHAT_MSG_OFFICER", chatFilter)
  func("CHAT_MSG_PARTY", chatFilter)
  func("CHAT_MSG_PARTY_LEADER", chatFilter)
  func("CHAT_MSG_RAID", chatFilter)
  func("CHAT_MSG_RAID_LEADER", chatFilter)
  func("CHAT_MSG_SAY", chatFilter)
  func("CHAT_MSG_WHISPER", chatFilter)
  func("CHAT_MSG_WHISPER_INFORM", chatFilter)
  func("CHAT_MSG_BN_WHISPER", chatFilter)
  func("CHAT_MSG_BN_WHISPER_INFORM", chatFilter)
  func("CHAT_MSG_BN_CONVERSATION", chatFilter)
  func("CHAT_MSG_INSTANCE_CHAT", chatFilter)
  func("CHAT_MSG_INSTANCE_CHAT_LEADER", chatFilter)
end