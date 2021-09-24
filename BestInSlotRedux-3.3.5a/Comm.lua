--lua function
local unpack, select, pcall, error, type
=     unpack, select, pcall, error, type
--WoW API
local GetUnitName, GetAddOnMetadata, IsInGuild, IsInGroup
=     GetUnitName, GetAddOnMetadata, IsInGuild, IsInGroup
local BestInSlot, L = unpack(select(2, ...))
local communication = {}
local playerName
local versionNumber
local printUpdateReminder = true

local function OnCommReceived(prefix, msg, channel, source)
  playerName = playerName or GetUnitName("player")
  if prefix == BestInSlot.MSGPREFIX and source ~= playerName then
    local success, msg = BestInSlot:Deserialize(msg)
    if success then
      local version = msg.version
      local data = msg.data
      local identifier = msg.id
      local target = msg.target
      if target and target ~= playerName then
        return
      end
      if printUpdateReminder and BestInSlot.version < version and not msg.Alpha and version > 136 then
        BestInSlot:Print((L["Your version of BestInSlot is outdated! You can download the newest version at %s%s"]):format(BestInSlot.colorHighlight, "https://www.curseforge.com/wow/addons/bestinslotredux"), true)
        BestInSlot:Print(source..":"..version)
        printUpdateReminder = false
      end
      if not identifier then BestInSlot:Print(("Invalid AddOn message received from %s"):format(source)) return end
      if communication[identifier] then
        BestInSlot:SendEvent(("AddonMessage_%s"):format(identifier), data, channel, source)
        communication[identifier](data, channel, source, version)
      end
    else
      BestInSlot.console:AddError("Error at unserializing the package", msg)
    end
  end

end

--- This function is called on receiving addon-messages
-- @see AceComm-3.0 documentation
function BestInSlot:OnCommReceived(prefix, msg, channel, source)
  local result, error = pcall(OnCommReceived, prefix, msg, channel, source)
  if not result then
    --Unserialize the msg
    local result, success, msg = BestInSlot:Deserialize(msg)
    BestInSlot.console:AddError("Unkonwn error in communication system", error, prefix, msg, channel, source)
  end
end

--- This function is called on receiving addon-messages
-- @see AceComm-3.0 documentation
function BestInSlot:RegisterCommFunction(identifier, func)
  if identifier and communication[identifier] then error("The identifier "..identifier.." has allready been registered!") end
  if not func or type(func) ~= "function" then error("Function parameter for identifier "..identifier.." should be a function!") end
  communication[identifier] = func
end

--- BestInSlot function for sending add-on messages
-- @param string identifier The identifier of the message
-- @param multiple msg Any data to send
-- @param chattype The chattype to send it to, see WoW's API on available chattypes
-- @param target The target of the chattype (for "WHISPER")
function BestInSlot:SendAddonMessage(identifier, msg, chattype, target)
  --error handling
  if identifier and not communication[identifier] then error("The identifier "..identifier.." is not registered yet") end
  if not chattype then error("You must give a chattype for the SendAddonMessage to work") end
  if chattype == "WHISPER" and not target then error("The WHISPER chattype must supply a target") end
  
  --make a dataPackage
  local dataPackage = {version = self.version, data=msg, id = identifier, Alpha = BestInSlot.AlphaVersion}
  
  dataPackage = self:Serialize(dataPackage)
  self:SendCommMessage(BestInSlot.MSGPREFIX, dataPackage, chattype, target)
  self:SendEvent(("MessageSent_%s"):format(identifier), msg, chattype, target)
end

local versionReplyTimer
local function noVersionReplies()
  BestInSlot:Print("There were no responses on the version check.", true)
  versionReplyTimer = nil
end

--- Function for the /bis versioncheck command
local function versionCheck(data, channel, source)
  if not versionNumber then
    versionNumber = GetAddOnMetadata("BestInSlotRedux", "Version")
    if versionNumber:find("@project") and versionNumber:find("version@") then
      versionNumber = "Development Version"
    end
  end
  BestInSlot:SendAddonMessage("versionreply", versionNumber, "WHISPER", source)
end

--- Function to print out the reply of people
local function versionReply(data, channel, source, version)
  local str = source..": "..data
  if BestInSlot.options.DEBUG then
    str = str.." / "..version
  end
  BestInSlot:Print(str, true)
  BestInSlot:CancelTimer(versionReplyTimer)
  versionReplyTimer = nil
end
--- Function to receive automatic updates from other guild members
-- @param #table data The BiS list from the source
-- @param #string channel The channel where it got from, should be "GUILD"
-- @param #string source The player sending the update
local function automaticUpdate(data, channel, source, version)
  if channel == "GUILD" and BestInSlot.options.receiveAutomaticUpdates then
    local raidTier = data.raidTier
    local difficulty = data.difficulty
    local bis = data.bis
    local spec = data.spec
    if not raidTier or not difficulty then return end
    local guildName = GetGuildInfo("player")
    if version <= 275 then
      if #bis == 0 then
        BestInSlot.db.factionrealm[guildName][source][raidTier][difficulty] = nil
        BestInSlot:SendEvent("GuildCacheUpdated")
      else
        if not spec then
          BestInSlot.db.factionrealm[guildName][source][raidTier][difficulty] = bis
          BestInSlot:SendEvent("GuildCacheUpdated")
        else
          BestInSlot.db.factionrealm[guildName][source][raidTier][difficulty][spec] = bis
          BestInSlot.db.factionrealm[guildName][source].latestReceivedSpec = spec
          BestInSlot:SendEvent("GuildCacheUpdated")
        end
      end
    else
      BestInSlot:SaveGuildBestInSlotList(guildName, source, bis, raidTier, difficulty, spec, version)
    end
  end
end

--CHAT_MSG_PARTY
--CHAT_MSG_RAID
--CHAT_MSG_GUILD
--WHISPER

local function printSlashVersionCheckError()
  BestInSlot:Print(
    (L["Usage: %s"]):format(
      ("/bis versioncheck %1$s||%2$s||%3$s||%4$s [%4$s_%5$s]"):format(
        (CHAT_MSG_PARTY):lower(),
        (CHAT_MSG_RAID):lower(),
        (CHAT_MSG_GUILD):lower(),
        (WHISPER):lower(),
        (TARGET):lower()
      )
    )
  , true)
end

--- The /bis versioncheck command
-- @param #string channel The Channel to request the version off
-- @param #string target The optional target if the channel is "WHISPER"
local function SlashVersionCheck(channel, target)
  if not channel then 
    if IsInGuild() then
      channel = "GUILD"
    elseif IsInGroup() then
      channel = "RAID"
    else
      printSlashVersionCheckError()
      return
    end
  end
  channel = (channel):upper()
  if channel == CHAT_MSG_PARTY or channel == "PARTY" then
    BestInSlot:SendAddonMessage("version", nil, "PARTY")
  elseif channel == CHAT_MSG_RAID or channel == "RAID" then
    BestInSlot:SendAddonMessage("version", nil, "RAID")
  elseif channel == CHAT_MSG_GUILD or channel == "GUILD"  then
    BestInSlot:SendAddonMessage("version", nil, "GUILD")
  elseif channel == WHISPER or channel == "WHISPER" then
    if not target then
      BestInSlot:Print(
        L["This function requires a target."].." "..
        (L["Usage: %s"]):format(
          ("/bis versioncheck %s [%s]"):format(
            (WHISPER):lower(),
            (TARGET):lower()
          )
        )
      ,true)
      return
    end
    BestInSlot:SendAddonMessage("version", nil, "WHISPER", target)
  else
    printSlashVersionCheckError()
    return --to prevent the timer from starting
  end
  versionReplyTimer = BestInSlot:ScheduleTimer(noVersionReplies, 5)
end

BestInSlot:RegisterCommFunction("version", versionCheck)
BestInSlot:RegisterCommFunction("versionreply", versionReply)
BestInSlot:RegisterCommFunction("automaticUpdate", automaticUpdate)
BestInSlot:RegisterSlashCmd("versioncheck", "/bis versioncheck channel [target] - "..L["Queries the specified channels for versions."], SlashVersionCheck)

BestInSlot.comm = true