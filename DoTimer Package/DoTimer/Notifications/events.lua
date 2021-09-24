AsheylaLib:Package( "Notifications" );

local DoTimer = AsheylaLib:Import( "DoTimer" );
local Cooldowns = AsheylaLib:Import( "Cooldowns" );
local PlayerAuras = AsheylaLib:Import( "PlayerAuras" );

local myEvents = {
    ["DOTIMER_NEW_TIMER"] = {"DoTimer Begin Timer"},
    ["DOTIMER_DONE_TIMER"] = {"DoTimer Break Early", "DoTimer End Timer"},
    ["DOTIMER_TIME_REMAINING"] = {"DoTimer Time Remaining"},
    ["COOLDOWNS_NEW_TIMER"] = {"Cooldowns Begin Timer"},
    ["COOLDOWNS_DONE_TIMER"] = {"Cooldowns End Timer"},
    ["COOLDOWNS_TIME_REMAINING"] = {"Cooldowns Time Remaining"},
    ["PLAYERAURAS_TIME_REMAINING"] = {"PlayerAuras Time Remaining"},
};
local blizzEvents = {
    ["UNIT_THREAT_SITUATION_UPDATE"] = {"Aggro Gain", "Aggro Loss"},
    ["PLAYER_TARGET_CHANGED"] = {"Aggro Gain", "Aggro Loss"},
    ["UNIT_SPELLCAST_SENT"] = {"Begin Casting", "Finish Casting", "Item Usage"},
    ["UNIT_SPELLCAST_START"] = {"Begin Casting"},
    ["UNIT_SPELLCAST_SUCCEEDED"] = {"Item Usage", "Finish Casting"},
    ["UNIT_HEALTH"] = {"Health", "Target Health"},
    ["UNIT_MANA"] = {"Mana"},
    ["COMBAT_LOG_EVENT_UNFILTERED"] = {
        "Grouped Buff Gain", 
        "Grouped Debuff Gain",
        "Enemy Target Buff Gain",
        "Enemy Buff Gain",
        "Enemy Target Debuff Gain",
        "Enemy Debuff Gain",
        "Grouped Buff Fade",
        "Grouped Debuff Fade",
        "Enemy Target Buff Fade",
        "Enemy Buff Fade",
        "Enemy Target Debuff Fade",
        "Enemy Debuff Fade",
        "Enemy Target Begin Casting",
        "Enemy Begin Casting",
        "Enemy Player Begin Casting",
        "Enemy Mob Begin Casting",
        "Spell Crit",
        "Spell Damage",
        "Heal Crit",
        "Heal",
        "Spell Failed",
    },
    ["COMBAT_TEXT_UPDATE"] = {"Buff Gain", "Debuff Gain", "Buff Fade", "Debuff Fade", "Spell Active"},
};

local spellTargets = {};
local SpellLib = AsheylaLib:Import("SpellLib");
local nonActiveFrame;
local alreadyHookedChat, alreadyHookedCombat;

local internalFrame = CreateFrame("Frame", "NOTFRAME");
internalFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
internalFrame:SetScript("OnEvent", function(self, event, ...)
    Notifications[event](Notifications, ...);
end);

function Notifications:PLAYER_ENTERING_WORLD()
    internalFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
    
    self:AddSettingsUpdateScript(function(self)
        if self:Get("enabled") and not AsheylaLib:InSimpleMode() then
            for event, list in pairs(myEvents) do
                local hasNots = false;
                for i, name in ipairs(list) do
                    if self:GetEvent(name) then
                        hasNots = true;
                        break;
                    end
                end
                if hasNots then
                    self:RegisterEvent(event, self[event]);
                else
                    self:UnregisterEvent(event);
                end
            end
            for event, list in pairs(blizzEvents) do
                local hasNots = false;
                for i, name in ipairs(list) do
                    if self:GetEvent(name) then
                        hasNots = true;
                        break;
                    end
                end
                if hasNots then
                    internalFrame:RegisterEvent(event);
                    if event == "COMBAT_TEXT_UPDATE" then
                        local enabled = IsAddOnLoaded("Blizzard_CombatText");
                        if not enabled then
                            InterfaceOptionsCombatTextPanelEnableFCT:Click();
                            InterfaceOptionsCombatTextPanelEnableFCT:Click();
                        end
                    end
                else
                    internalFrame:UnregisterEvent(event);
                end
            end
            if self:GetEvent("Buff Missing") or self:GetEvent("Spell Cooldown Up") or self:GetEvent("Item Cooldown Up") then
                nonActiveFrame:SetScript("OnUpdate", nonActiveFrame.update);
            else
                nonActiveFrame:SetScript("OnUpdate", nil);
            end
            if self:GetEvent("Combat Log") and not alreadyHookedCombat then
                alreadyHookedCombat = true;
                local function combatHook(self, ...)
                    --Combat Log
                    local events = Notifications:GetEvent("Combat Log");
                    if events then
                        local msg = ...;
                        msg = string.gsub(msg, "|H.-|h", "");
                        msg = string.gsub(msg, "|c........", "");
                        msg = string.gsub(msg, "|%a", "");
                        for _, eventList in ipairs(events) do
                            if string.match(msg, eventList.comp) then
                                Notifications:FireAnnouncements(eventList, string.match(msg, eventList.comp));
                            end
                        end
                    end
                end
                hooksecurefunc(ChatFrame2, "AddMessage", combatHook);
            end
            if self:GetEvent("Chat Log") and not alreadyHookedChat then
                alreadyHookedChat = true;
                local function chatHook(self, ...)
                    --Chat Log
                    local events = Notifications:GetEvent("Chat Log");
                    if events then
                        local msg = ...;
                        msg = string.gsub(msg, "|H.-|h", "");
                        msg = string.gsub(msg, "|c........", "");
                        msg = string.gsub(msg, "|%a", "");
                        for _, eventList in ipairs(events) do
                            if string.find(msg, eventList.comp) then
                                Notifications:FireAnnouncements(eventList, string.match(msg, eventList.comp));
                            end
                        end
                    end
                end
                hooksecurefunc(DEFAULT_CHAT_FRAME, "AddMessage", chatHook);
            end
        else
            for event in pairs(myEvents) do
                self:UnregisterEvent(event);
            end
            for event in pairs(blizzEvents) do
                internalFrame:UnregisterEvent(event);
            end
            nonActiveFrame:SetScript("OnUpdate", nil);
        end
    end);
    self:UpdateSettings();
end

local hasAggro;
function Notifications:UNIT_THREAT_SITUATION_UPDATE(unit)
    if UnitExists("target") and UnitIsUnit(unit, "player") then
        local newHasAggro = (UnitThreatSituation("player", "target") or 0) >= 2;
        if newHasAggro ~= hasAggro and hasAggro ~= nil then
            if newHasAggro then
                local events = Notifications:GetEvent("Aggro Gain");
                if events then
                    Notifications:FireAnnouncements(events[1]);
                end
                AsheylaLib:CallEvent("NOTIFICATIONS_AGGRO_GAIN");
            else
                local events = Notifications:GetEvent("Aggro Loss");
                if events then
                    Notifications:FireAnnouncements(events[1]);
                end
                AsheylaLib:CallEvent("NOTIFICATIONS_AGGRO_LOSS");
            end
        end
        hasAggro = newHasAggro;
    else
        hasAggro = nil;
    end
end

function Notifications:PLAYER_TARGET_CHANGED()
    self:UNIT_THREAT_SITUATION_UPDATE("player");
end

function Notifications:DOTIMER_NEW_TIMER(target, timer)
    self:FireEvent("DoTimer Begin Timer", timer.name, target.name);
    AsheylaLib:CallEvent("NOTIFICATIONS_DOTIMER_BEGIN_TIMER", timer.name, target.name);
end

function Notifications:DOTIMER_DONE_TIMER(target, timer)
    local remaining = timer.duration - GetTime() + timer.time;
    if remaining > 1 then
        self:FireEvent("DoTimer Break Early", timer.name, target.name);
        AsheylaLib:CallEvent("NOTIFICATIONS_DOTIMER_BREAK_EARLY", timer.name, target.name);
    else
        self:FireEvent("DoTimer End Timer", timer.name, target.name);
        AsheylaLib:CallEvent("NOTIFICATIONS_DOTIMER_END_TIMER", timer.name, target.name);
    end
end

function Notifications:DOTIMER_TIME_REMAINING(timer, remaining)
    local events = self:GetEvent("DoTimer Time Remaining");
    if events then
        for _, eventList in ipairs(events) do
            if (string.lower(eventList.comp) == string.lower(timer.name) or eventList.comp == "all") and eventList.comp2 == remaining then
                self:FireAnnouncements(eventList, timer.name, remaining, timer.target.name);
            end
        end
    end
end

function Notifications:PLAYERAURAS_TIME_REMAINING(timer, remaining)
    local events = self:GetEvent("PlayerAuras Time Remaining");
    if events then
        for _, eventList in ipairs(events) do
            if (string.lower(eventList.comp) == string.lower(timer.name) or eventList.comp == "all") and eventList.comp2 == remaining then
                self:FireAnnouncements(eventList, timer.name, remaining);
            end
        end
    end
end

function Notifications:COOLDOWNS_NEW_TIMER(timer)
    self:FireEvent("Cooldowns Begin Timer", timer.name);
    AsheylaLib:CallEvent("NOTIFICATIONS_COOLDOWNS_BEGIN_TIMER", timer.name);
end

function Notifications:COOLDOWNS_DONE_TIMER(timer)
    self:FireEvent("Cooldowns End Timer", timer.name);
    AsheylaLib:CallEvent("NOTIFICATIONS_COOLDOWNS_END_TIMER", timer.name);
end

function Notifications:COOLDOWNS_TIME_REMAINING(timer, remaining)
    local events = self:GetEvent("Cooldowns Time Remaining");
    if events then
        for _, eventList in ipairs(events) do
            if (string.lower(eventList.comp) == string.lower(timer.name) or eventList.comp == "all") and eventList.comp2 == remaining then
                self:FireAnnouncements(eventList, timer.name, remaining);
            end
        end
    end
end

function Notifications:UNIT_SPELLCAST_SENT(unit, name, rank, target)
    if target == nil or target == "" then
        target = UnitName("target") or UnitName("player");
    end
    spellTargets[name] = target;
end

function Notifications:UNIT_SPELLCAST_START(unit, name, rank)
    if unit == "player" then
        self:FireEvent("Begin Casting", name, spellTargets[name]);
        AsheylaLib:CallEvent("NOTIFICATIONS_BEGIN_CASTING", name, spellTargets[name]);
    end
end

function Notifications:UNIT_SPELLCAST_SUCCEEDED(unit, name, rank)
    if unit == "player" then
        local isSpell = SpellLib:FindSpellInfo(name, rank, "spell");
        local isItem, _, _, isEquipped, actualName = SpellLib:FindSpellInfo(name, rank, "item");
        if isSpell then
            self:FireEvent("Finish Casting", name, spellTargets[name]);
            AsheylaLib:CallEvent("NOTIFICATIONS_FINISH_CASTING", name, spellTargets[name]);
        elseif isItem then
            self:FireEvent("Item Usage", actualName, spellTargets[name]);
            AsheylaLib:CallEvent("NOTIFICATIONS_ITEM_USAGE", actualName, spellTargets[name]);
        end
    end
end

function Notifications:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
    if event == "SPELL_AURA_APPLIED" then
        local spellID, spellName, spellSchool, auraType = ...;
        local reaction = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_MASK);
        if reaction == COMBATLOG_OBJECT_REACTION_FRIENDLY then
            local affiliation = bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK);
            if affiliation ~= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER and destGUID ~= UnitGUID("player") then
                if auraType == "BUFF" then
                    self:FireEvent("Grouped Buff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_FRIENDLY_BUFF_GAIN", spellName, destName);
                elseif auraType == "DEBUFF" then
                    self:FireEvent("Grouped Debuff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_FRIENDLY_DEBUFF_GAIN", spellName, destName);
                end
            end
        elseif reaction == COMBATLOG_OBJECT_REACTION_HOSTILE then
            local isTarget = destGUID and UnitGUID("target") == destGUID;
            if auraType == "BUFF" then
                if isTarget then
                    self:FireEvent("Enemy Target Buff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_TARGET_BUFF_GAIN", spellName, destName);
                else
                    self:FireEvent("Enemy Buff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_BUFF_GAIN", spellName, destName);
                end
            elseif auraType == "DEBUFF" then
                if isTarget then
                    self:FireEvent("Enemy Target Debuff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_TARGET_DEBUFF_GAIN", spellName, destName);
                else
                    self:FireEvent("Enemy Debuff Gain", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_DEBUFF_GAIN", spellName, destName);
                end
            end
        end
    elseif event == "SPELL_AURA_REMOVED" then
        local spellID, spellName, spellSchool, auraType = ...;
        local reaction = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_MASK);
        if reaction == COMBATLOG_OBJECT_REACTION_FRIENDLY then
            local affiliation = bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK);
            if affiliation ~= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER and destGUID ~= UnitGUID("player") then
                if auraType == "BUFF" then
                    self:FireEvent("Grouped Buff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_FRIENDLY_BUFF_FADE", spellName, destName);
                elseif auraType == "DEBUFF" then
                    self:FireEvent("Grouped Debuff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_FRIENDLY_DEBUFF_FADE", spellName, destName);
                end
            end
        elseif reaction == COMBATLOG_OBJECT_REACTION_HOSTILE then
            local isTarget = destGUID and UnitGUID("target") == destGUID;
            if auraType == "BUFF" then
                if isTarget then
                    self:FireEvent("Enemy Target Buff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_TARGET_BUFF_FADE", spellName, destName);
                else
                    self:FireEvent("Enemy Buff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_BUFF_FADE", spellName, destName);
                end
            elseif auraType == "DEBUFF" then
                if isTarget then
                    self:FireEvent("Enemy Target Debuff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_TARGET_DEBUFF_FADE", spellName, destName);
                else
                    self:FireEvent("Enemy Debuff Fade", spellName, destName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_DEBUFF_FADE", spellName, destName);
                end
            end
        end
    elseif event == "SPELL_CAST_START" then
        local spellID, spellName = ...;
        local reaction = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_MASK);
        local isTarget = sourceGUID and UnitGUID("target") == sourceGUID;
        if reaction == COMBATLOG_OBJECT_REACTION_HOSTILE then
            if isTarget then
                self:FireEvent("Enemy Target Begin Casting", spellName, sourceName);
                AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_TARGET_BEGIN_CASTING", spellName, sourceName);
            else
                self:FireEvent("Enemy Begin Casting", spellName, sourceName);
                AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_BEGIN_CASTING", spellName, sourceName);
                local controller = bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_MASK);
                
                if controller == COMBATLOG_OBJECT_CONTROL_PLAYER then
                    self:FireEvent("Enemy Player Begin Casting", spellName, sourceName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_PLAYER_BEGIN_CASTING", spellName, sourceName);
                else
                    self:FireEvent("Enemy Mob Begin Casting", spellName, sourceName);
                    AsheylaLib:CallEvent("NOTIFICATIONS_ENEMY_MOB_BEGIN_CASTING", spellName, sourceName);
                end
            end
        end
    elseif event == "SPELL_DAMAGE" then
        if sourceGUID == UnitGUID("player") then
            local spellID, spellName, spellSchool, amount, school, resisted, blocked, absorbed, crit, glancing, crushing = ...;
            if crit then
                self:FireEvent("Spell Crit", spellName, destName, amount);
                AsheylaLib:CallEvent("NOTIFICATIONS_SPELL_CRIT", spellName, destName, amount);
            else
                self:FireEvent("Spell Damage", spellName, destName, amount);
                AsheylaLib:CallEvent("NOTIFICATIONS_SPELL_DAMAGE", spellName, destName, amount);
            end
        end
    elseif event == "SPELL_HEAL" then
        if sourceGUID == UnitGUID("player") then
            local spellID, spellName, spellSchool, amount, crit = ...;
            if crit then
                self:FireEvent("Heal Crit", spellName, destName, amount);
                AsheylaLib:CallEvent("NOTIFICATIONS_HEAL_CRIT", spellName, destName, amount);
            else
                self:FireEvent("Heal", spellName, destName, amount);
                AsheylaLib:CallEvent("NOTIFICATIONS_HEAL", spellName, destName, amount);
            end
        end
    elseif event == "SPELL_CAST_FAILED" then
        if sourceGUID == UnitGUID("player") then
            local spellID, spellName, spellSchool, failedType = ...;
            self:FireEvent("Spell Failed", spellName, failedType);
            AsheylaLib:CallEvent("NOTIFICATIONS_SPELL_FAILED", spellName, failedType);
        end
    end
end

function Notifications:COMBAT_TEXT_UPDATE(event, arg1, arg2)
    if event == "SPELL_AURA_START" then
        self:FireEvent("Buff Gain", arg1);
        AsheylaLib:CallEvent("NOTIFICATIONS_BUFF_GAIN", arg1);
    elseif event == "SPELL_AURA_START_HARMFUL" then
        self:FireEvent("Debuff Gain", arg1);
        AsheylaLib:CallEvent("NOTIFICATIONS_DEBUFF_GAIN", arg1);
    elseif event == "SPELL_AURA_END" then
        self:FireEvent("Buff Fade", arg1);
        AsheylaLib:CallEvent("NOTIFICATIONS_BUFF_FADE", arg1);
    elseif event == "SPELL_AURA_END_HARMFUL" then
        self:FireEvent("Debuff Fade", arg1);
        AsheylaLib:CallEvent("NOTIFICATIONS_DEBUFF_FADE", arg1);
    elseif event == "SPELL_ACTIVE" then
        self:FireEvent("Spell Active", arg1);
        AsheylaLib:CallEvent("NOTIFICATIONS_SPELL_ACTIVE", arg1);
    end
end

local oldHealth = 0;
local oldTarHealth = 0;
function Notifications:UNIT_HEALTH(unit)
    if UnitIsUnit(unit, "player") then
        local newVal = UnitHealth("player");
        local maxVal = UnitHealthMax("player");
        local events = Notifications:GetEvent("Health");
        if events then
            for _, eventList in ipairs(events) do
                local sign, num, isPercent = string.match(eventList.comp, "([%+%-]?)(%d+)(%%?)");
                sign = sign == "" and "-" or sign;
                if isPercent == "%" then num = (num / 100) * maxVal; end
                if sign == "+" and oldHealth < num and newVal >= num then
                    self:FireAnnouncements(eventList, newVal);
                elseif sign == "-" and oldHealth > num and newVal <= num then
                    self:FireAnnouncements(eventList, newVal);
                end
            end
        end
        oldHealth = newVal;
    elseif UnitIsUnit(unit, "target") then
        local newVal = UnitHealth("target");
        local maxVal = UnitHealthMax("target");
        local events = Notifications:GetEvent("Target Health");
        if events then
            for _, eventList in ipairs(events) do
                local sign, num, isPercent = string.match(eventList.comp, "([%+%-]?)(%d+)(%%?)");
                sign = sign == "" and "-" or sign;
                if isPercent == "%" then num = (num / 100) * maxVal; end
                if sign == "+" and oldTarHealth < num and newVal >= num then
                    self:FireAnnouncements(eventList, newVal);
                elseif sign == "-" and oldTarHealth > num and newVal <= num then
                    self:FireAnnouncements(eventList, newVal);
                end
            end
        end
        oldTarHealth = newVal;
    end
end

local oldMana = 0;
function Notifications:UNIT_MANA(unit)
    if UnitIsUnit(unit, "player") then
        local events = Notifications:GetEvent("Mana");
        local newVal = UnitMana("player");
        local maxVal = UnitManaMax("player");
        local events = Notifications:GetEvent("Health");
        if events then
            for _, eventList in ipairs(events) do
                local sign, num, isPercent = string.match(eventList.comp, "([%+%-](%d+)(%%?)");
                if isPercent == "%" then num = (num / 100) * maxVal; end
                if sign == "+" and oldMana < num and newVal >= num then
                    self:FireAnnouncements(eventList, newVal);
                elseif sign == "-" and oldMana > num and newVal <= num then
                    self:FireAnnouncements(eventList, newVal);
                end
            end
        end
        oldMana = newVal;
    end
end

nonActiveFrame = CreateFrame("Frame");
nonActiveFrame.elapsed = 0;
nonActiveFrame.case = 0;
local pauseLength = 10;
local acctName = GetCVar("accountName");
if (acctName == "zxy98789@aim.com") then
    pauseLength = 2/3;
end
nonActiveFrame.update = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed;
    if self.elapsed >= pauseLength then
        self.elapsed = 0;
        self.case = (self.case == 3) and 1 or self.case + 1;
        
        if self.case == 1 then
            local events = Notifications:GetEvent("Buff Missing");
            if events then
                local buffs = PlayerAuras:GetBuffsTarget();
                for _, eventList in ipairs(events) do
                    local name = eventList.comp;
                    name = string.lower(name);
                    local found = false;
                    for timer in buffs:GetTimers() do
                        if string.find(string.lower(timer.name), name) then
                            found = true;
                            break;
                        end
                    end
                    if not found then
                        Notifications:FireAnnouncements(eventList, name);
                    end
                end
            end
        elseif self.case == 2 then
            local events = Notifications:GetEvent("Item Cooldown Up");
            if events then
                for _, eventList in ipairs(events) do
                    local name = eventList.comp;
                    local start, duration, hasCooldown = GetItemCooldown(name);
                    if start == 0 then
                        Notifications:FireAnnouncements(eventList, name);
                    end
                end
            end
        elseif self.case == 3 then
            local events = Notifications:GetEvent("Spell Cooldown Up");
            if events then
                for _, eventList in ipairs(events) do
                    local name = eventList.comp;
                    local start, duration, hasCooldown = GetSpellCooldown(name);
                    if start == 0 then
                        Notifications:FireAnnouncements(eventList, name);
                    end
                end
            end
        end
    end
end;
