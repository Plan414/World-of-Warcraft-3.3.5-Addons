AsheylaLib:Package( "PlayerAuras" );
PlayerAuras = AsheylaLib:NewModule("PlayerAuras");

local targetModule = PlayerAurasTarget;
local timerModule = PlayerAurasTimer;

local buffsTarget = targetModule:MakeBuffsTable(PlayerAuras, "player");
local debuffsTarget = targetModule:MakeDebuffsTable(PlayerAuras, "player");

PlayerAuras.units = {
    ["player"] = {
        ["HELPFUL"] = buffsTarget,
        ["HARMFUL"] = debuffsTarget,
    },
    ["pet"] = {
        ["HELPFUL"] = targetModule:MakeBuffsTable(PlayerAuras, "pet"),
        ["HARMFUL"] = targetModule:MakeDebuffsTable(PlayerAuras, "pet"),
    },--]]
    ["target"] = {
        ["HELPFUL"] = targetModule:MakeBuffsTable(PlayerAuras, "target"),
        ["HARMFUL"] = targetModule:MakeDebuffsTable(PlayerAuras, "target"),
    },--]]
    ["focus"] = {
        ["HELPFUL"] = targetModule:MakeBuffsTable(PlayerAuras, "focus"),
        ["HARMFUL"] = targetModule:MakeDebuffsTable(PlayerAuras, "focus"),
    },--]]
};

local units = PlayerAuras.units;

local defaultSettings = {
    enabled = true,
    blizzBuffs = false,
    noDuration = {},
};
for unit in pairs(units) do
    local suffix = unit == "player" and "" or "-" .. unit;
    defaultSettings["showUnit" .. suffix] = unit == "player" and true or false;
end
PlayerAuras:AddDefaultSettings(defaultSettings);

function PlayerAuras:GetBuffsTarget()
    return buffsTarget;
end

function PlayerAuras:GetDebuffsTarget()
    return debuffsTarget;
end

local TIME_REMAINING = "PLAYERAURAS_TIME_REMAINING";

local internalFrame = CreateFrame("Frame");
internalFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
internalFrame:SetScript("OnEvent", function(self, event, ...)
    PlayerAuras[event](PlayerAuras, ...);
end);

local updateFunc = function(self, elapsed)
    local time = GetTime();
    local numTimers = 0;
    for unit, filters in pairs(units) do
        for filter, target in pairs(filters) do
            for timer in target:GetTimers() do
                if timer.duration then
                    if time >= timer.time + timer.duration then
                        if timer.type == "standard" then
                            target:RemoveTimer(timer);
                        elseif timer.type == "tempEnchant" then
                            target:RemoveTimer(timer);
                            PlayerAuras:ClearTempEnchantTimer(timer);
                        end
                    else
                        timer.announced = timer.announced or timer.duration;
                        local remaining = timer.duration - time + timer.time;
                        if remaining <= timer.announced - 1  or remaining > timer.announced then
                            timer.announced = floor(remaining + .5);
                            AsheylaLib:CallEvent(TIME_REMAINING, timer, timer.announced);
                        end
                    end
                end
            end
            numTimers = numTimers + #target.timers;
        end
    end
    
    if numTimers == 0 then
        self:SetScript("OnUpdate", nil);
    end
end;

function PlayerAuras:UNIT_PET(unit)
    if unit == "player" then self:UNIT_AURA("pet") end
end

function PlayerAuras:PLAYER_TARGET_CHANGED()
    self:UNIT_AURA("target");
end

function PlayerAuras:PLAYER_FOCUS_CHANGED()
    self:UNIT_AURA("focus");
end

function PlayerAuras:UNIT_AURA(unit)
    local suffix = unit == "player" and "" or "-" .. unit;
    if not (units[unit] and self:Get("showUnit" .. suffix)) then return; end
    
    for filter, target in pairs(units[unit]) do
        for timer in target:GetTimers() do
            if timer.type == "standard" then 
                timer.validated = false;
            end
        end
        
        local i = 1;
        local name, rank, texture, count, debuffType, duration, endTime, isMine = UnitAura(unit, i, filter);
        while name do
            if duration == 0 or self:Get("noDuration", string.lower(name)) then duration = nil; end
            local adding = true;
            for _i = #target.timers, 1, -1 do
                local timer = target.timers[_i];
                if timer.name == name and timer.type == "standard" and (timer.duration ~= 0) == (duration ~= 0) and not timer.validated then
                    timer.validated = true;
                    timer.rank = rank;
                    timer.buffID = i;
                    adding = false;
                    timer:UpdateTimerData(duration, endTime, count, _i, i);
                    break;
                end
            end
            
            if adding then
                -- performance increase: even though the "hidden" setting technically should be in the listener, 
                -- to parallel the code of DoTimer and Cooldowns (which have timers that generally persist much longer), 
                -- it is too CPU intensive to make ALL the timers for e.g. your target's debuffs (which, in a 25man raid, 
                -- can be a LOT.  thus, we will avoid doing so, here, in this code
                local isHidden;
                if self:Get("whiteList-" .. target.name .. suffix) then
                    isHidden = not self:Get("visible-" .. target.name .. suffix, string.lower(name));
                else
                    isHidden = self:Get("blocked-" .. target.name .. suffix, string.lower(name));
                end
                if ( not isHidden ) then
                    local timer = timerModule:NewTimer(self, name, rank, texture, count, duration, endTime, filter, filter == "HARMFUL" and (debuffType or "Physical"), "standard");
                    timer.buffID = i;
                    target:AddTimer(timer);
                    internalFrame:SetScript("OnUpdate", updateFunc);
                end
            end
            
            i = i + 1;
            name, rank, texture, count, debuffType, duration, endTime, isMine = UnitAura(unit, i, filter);
        end
        
        for timer in target:GetTimers() do
            if timer.type == "standard" and not timer.validated then
                target:RemoveTimer(timer);
            end
        end
    end
end

local trackingTimer;
function PlayerAuras:MINIMAP_UPDATE_TRACKING()
    local name, texture, active, id;
    local newTexture = GetTrackingTexture();
    for i = 1, GetNumTrackingTypes() do
        name, texture = GetTrackingInfo(i);
        if texture == newTexture then
            active = true;
            id = i;
            break;
        end
    end
    
    if active then
        if trackingTimer then
            --update
            trackingTimer:UpdateTimerData(nil, nil, 1, nil, nil, name, texture);
            trackingTimer.trackID = id;
        else
            --create
            trackingTimer = timerModule:NewTimer(PlayerAuras, name, nil, texture, 1, nil, nil, "HELPFUL", nil, "tracking");
            trackingTimer.trackID = id;
            buffsTarget:AddTimer(trackingTimer);
        end
    elseif trackingTimer then
        --remove
        buffsTarget:RemoveTimer(trackingTimer);
        trackingTimer = false;
    end
end

local stanceTimer;
function PlayerAuras:UPDATE_SHAPESHIFT_FORM()
    local texture, name, active, id;
    for i = 1, GetNumShapeshiftForms() do
        texture, name, active = GetShapeshiftFormInfo(i);
        if active then
            id = i;
            break;
        end
    end
    
    if active then
        if stanceTimer then
            --update
            stanceTimer:UpdateTimerData(nil, nil, 1, nil, nil, name, texture);
            stanceTimer.stanceID = id;
        else
            --create
            stanceTimer = timerModule:NewTimer(PlayerAuras, name, nil, texture, 1, nil, nil, "HELPFUL", nil, "stance");
            stanceTimer.stanceID = id;
            buffsTarget:AddTimer(stanceTimer);
        end
    elseif stanceTimer then
        --remove, i don't believe this ever happens... don't you always have to be in a stance?
        buffsTarget:RemoveTimer(stanceTimer);
        stanceTimer = false;
    end
end
function PlayerAuras:UPDATE_INVENTORY_ALERTS() self:UPDATE_SHAPESHIFT_FORM() end;
function PlayerAuras:UPDATE_SHAPESHIFT_USABLE() self:UPDATE_SHAPESHIFT_FORM() end;
function PlayerAuras:UPDATE_SHAPESHIFT_COOLDOWN() self:UPDATE_SHAPESHIFT_FORM() end;

local scanningFrame = CreateFrame("GameTooltip", "PlayerAurasScanningFrame", nil, "GameTooltipTemplate");
local function getEnchantName(id)
    scanningFrame:SetOwner(UIParent,"ANCHOR_NONE")
    scanningFrame:SetInventoryItem("player", id);
    for i = 1, scanningFrame:NumLines() do
        local text = getglobal("PlayerAurasScanningFrameTextLeft"..i):GetText();
        local name = string.match(text, "(.+) %(.*%d+.*%)$");
        if name then return name; end
    end
end

local function checkWeapEnchant(has, expir, charges, timer, num, time)
    if has and expir > 1000 then
        local itemName = getEnchantName(num) or GetItemInfo(GetInventoryItemLink("player", num));
        if itemName then
            local timeLeft = expir / 1000;
            if timer then
                if timeLeft > timer.duration then
                    timer.duration = timeLeft;
                end
                timer:UpdateTimerData(timer.duration, time + timeLeft, charges, nil, nil, itemName, nil, true);
            else
                local duration = not PlayerAuras:Get("noDuration", string.lower(itemName)) and timeLeft or nil;
                local texture = GetInventoryItemTexture("player", num);
                timer = timerModule:NewTimer(PlayerAuras, itemName, nil, texture, charges, duration, time + timeLeft, "HELPFUL", nil, "tempEnchant");
                timer.weapID = num;
                buffsTarget:AddTimer(timer);
            end
        end
    elseif timer then
        buffsTarget:RemoveTimer(timer);
        timer = false;
    end
    
    return timer;
end

local tempEnchantFrame = CreateFrame("Frame");
tempEnchantFrame.elapsed = 0;
local mainHandRunning, offHandRunning = false, false;
local function tempEnchantUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed;
    if self.elapsed >= .25 then
        self.elapsed = 0;
        local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
        local time = GetTime();
        mainHandRunning = checkWeapEnchant(hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandRunning, 16, time);
        offHandRunning = checkWeapEnchant(hasOffHandEnchant, offHandExpiration, offHandCharges, offHandRunning, 17, time);
    end
end

local isJordan = false;
local acctName = GetCVar("accountName");
if (acctName == "zxy98789@aim.com") then
    isJordan = true;
end
function PlayerAuras:ClearTempEnchantTimer(timer)
    if timer == mainHandRunning then
        mainHandRunning = false;
    elseif timer == offHandRunning then
        offHandRunning = false;
    end
end

function PlayerAuras:Commands()
    local loaded = LoadAddOn("DoTimer_Options");
    if loaded and not AsheylaLib:InSimpleMode() then
        AsheylaLib:Import( "GUILib" ):ShowPanel("DoTimer", "PlayerAuras");
    end
end
PlayerAuras:MakeSlashCmd("/playerauras", "/pa");

local blizzFrames = {
    BuffFrame,
    TemporaryEnchantFrame,
    ConsolidatedBuffs,
};

local blizzHidden = false;
local hasBeenEnabled = false;
function PlayerAuras:PLAYER_ENTERING_WORLD()
    internalFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
    
    self:AddSettingsUpdateScript(function(self)
        if AsheylaLib:InSimpleMode() then
            if not BuffFrame:IsShown() and not hasBeenEnabled then
                blizzHidden = true;
            end
            if blizzHidden then
                for _, f in ipairs( blizzFrames ) do if f then f:Hide(); end end
            else
                for _, f in ipairs( blizzFrames ) do if f then f:Show(); end end
            end
        else
            if self:Get("blizzBuffs") then
                for _, f in ipairs( blizzFrames ) do if f then f:Show(); end end
            else
                for _, f in ipairs( blizzFrames ) do if f then f:Hide(); end end
            end
        end
        
        if self:Get("enabled") and not AsheylaLib:InSimpleMode() then
            hasBeenEnabled = true;
            internalFrame:RegisterEvent("UNIT_AURA");
            internalFrame:RegisterEvent("UNIT_PET");
            internalFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
            internalFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
            for unit, filters in pairs(units) do
                local suffix = unit == "player" and "" or "-" .. unit;
                for filter, target in pairs(filters) do
                    for timer in target:GetTimers() do
                        local isHidden = false;
                        if timer.type == "standard" then
                            if self:Get("whiteList-" .. target.name .. suffix) then
                                isHidden = not self:Get("visible-" .. target.name .. suffix, string.lower(timer.name));
                            else
                                isHidden = self:Get("blocked-" .. target.name .. suffix, string.lower(timer.name));
                            end
                        end
                        
                        if ( isHidden ) then
                            target:RemoveTimer( timer );
                        else
                            if self:Get("noDuration", string.lower(timer.name)) then
                                timer:UpdateTimerData(nil, nil, timer.stack);
                            else
                                if timer.type == "tempEnchant" then
                                    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
                                    if timer.weapID == 16 then
                                        timer:UpdateTimerData(mainHandExpiration / 1000, GetTime() + (mainHandExpiration / 1000), mainHandCharges);
                                    else
                                        timer:UpdateTimerData(offHandExpiration / 1000, GetTime() + (offHandExpiration / 1000), offHandCharges);
                                    end
                                elseif timer.type == "standard" then
                                    local name, _, _, _, _, duration, endTime = UnitAura(unit, timer.name, timer.rank, filter);
                                    --if not duration then print(name) end
                                    timer:UpdateTimerData( (duration or 0) > 0 and duration or nil, endTime, timer.stack);
                                end
                            end
                        end
                    end
                end
            end
            for unit, filters in pairs(units) do
                local suffix = unit == "player" and "" or "-" .. unit;
                if self:Get("showUnit" .. suffix) then
                    self:UNIT_AURA(unit);
                else
                    for filter, target in pairs(filters) do
                        target:RemoveAllTimers();
                    end
                end
            end
            if self:Get("showUnit") then
                internalFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING");
                self:MINIMAP_UPDATE_TRACKING();
                tempEnchantFrame:SetScript("OnUpdate", tempEnchantUpdate);
                tempEnchantUpdate(tempEnchantFrame, 1);
            else
                internalFrame:UnregisterEvent("MINIMAP_UPDATE_TRACKING");
                tempEnchantFrame:SetScript("OnUpdate", nil);
                trackingTimer = nil;
                mainHandRunning = nil;
                offHandRunning = nil;
            end
            local _, class = UnitClass("player");
            if class == "WARRIOR" then
                if self:Get("showUnit") then
                    internalFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
                    internalFrame:RegisterEvent("UPDATE_INVENTORY_ALERTS");
                    internalFrame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
                    internalFrame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
                    self:UPDATE_SHAPESHIFT_FORM();
                else
                    internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
                    internalFrame:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
                    internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_USABLE");
                    internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
                    stanceTimer = nil;
                end
            end
        else
            internalFrame:UnregisterEvent("UNIT_AURA");
            internalFrame:UnregisterEvent("UNIT_PET");
            internalFrame:UnregisterEvent("MINIMAP_UPDATE_TRACKING");
            internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
            internalFrame:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
            internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_USABLE");
            internalFrame:UnregisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
            internalFrame:UnregisterEvent("PLAYER_FOCUS_CHANGED");
            internalFrame:UnregisterEvent("PLAYER_TARGET_CHANGED");
            tempEnchantFrame:SetScript("OnUpdate", nil);
            stanceTimer = nil;
            trackingTimer = nil;
            mainHandRunning = nil;
            offHandRunning = nil;
            for unit, filters in pairs(units) do
                for filter, target in pairs(filters) do
                    target:RemoveAllTimers();
                end
            end
        end
    end);
    self:UpdateSettings();
end
