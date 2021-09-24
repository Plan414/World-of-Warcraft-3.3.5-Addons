AsheylaLib:Package( "VersionCommunication" );
local Communication = AsheylaLib:NewModule("VersionCommunication");
VersionCommunication = Communication;
local find = string.find;
local match = string.match;

local printingVersions = false;

local f = CreateFrame("Frame");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("PARTY_MEMBERS_CHANGED");
f:RegisterEvent("RAID_ROSTER_UPDATE");

f:SetScript("OnEvent", function(self, event, ...)
    Communication[event](Communication, ...);
end);

function Communication:CHAT_MSG_ADDON(pre, msg, loc, sender)
    if pre == "DTMR" then
        local announced, current = self:Get("version"), AsheylaLib:ReturnVersion();
        local version = (announced == nil or announced < current ) and current or announced;
        if printingVersions and sender ~= UnitName("player") then
            AsheylaLib:Import( "DoTimer" ):HeaderPrint(sender .. " uses DoTimer " .. msg);
        end
        msg = msg:gsub( "^version:", "" );
        if not find(msg, "[^%d%.]") and (msg > version) then
            self:FlagAlert(msg);
        end
        if loc == "GUILD" or msg == "request" then
            self:Announce( "WHISPER", sender );
        end
    end
end

function Communication:PLAYER_ENTERING_WORLD()
    if IsInGuild() then self:Announce("GUILD"); end
    self:PARTY_MEMBERS_CHANGED();
    self:RAID_ROSTER_UPDATE();
    self:AlertUser(self:HasFlag());
    f:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

local oldPartyCount = 0;
function Communication:PARTY_MEMBERS_CHANGED()
    local newPartyCount = GetNumPartyMembers();
    if (newPartyCount > oldPartyCount) then self:Announce("PARTY"); end
    oldPartyCount = newPartyCount;
end

local oldRaidCount = 0;
function Communication:RAID_ROSTER_UPDATE()
    local newRaidCount = GetNumRaidMembers();
    if (newRaidCount > oldRaidCount) then self:Announce("RAID"); end
    oldRaidCount = newRaidCount;
end

function Communication:Announce(loc, user)
    SendAddonMessage("DTMR", "version:" .. AsheylaLib:ReturnVersion(), loc, user);
end

local stopPrinting = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed;
    if self.elapsed >= 1 then
        self.elapsed = 0;
        printingVersions = false;
        self:SetScript("OnUpdate", nil);
    end
end
function Communication:FindUsers()
    printingVersions = true;
    self:Announce("RAID");
    self:Announce( "GUILD" );
    f:SetScript("OnUpdate", stopPrinting);
end

function Communication:AlertUser(flag)
    if flag then alertUser(string.format("There is a new version of DoTimer available: |cff00ff00%s|r.  Please upgrade!", flag)); end
end

function Communication:FlagAlert(ver)
    self:Set("flag", ver);
    self:Set("version", ver);
end

function Communication:HasFlag()
    local flag = self:Get("flag");
    self:Set("flag", nil);
    return flag and flag > AsheylaLib:ReturnVersion() and flag;
end
