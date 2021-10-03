--Mage Nuggets 1.86 by B-Buck (Bbuck of Eredar)

local L = LibStub("AceLocale-3.0"):GetLocale("MageNuggets")

MageNugz = {
  spMonitorToggle = true;
  ssMonitorToggle = true;
  mageProcToggle = true;
  camZoomTogg = true;
  absorbToggle = true;
  mirrorImageToggle = true;
  waterEleToggle = true;
  evocationToggle = true;
  livingBombToggle = true;
  smallLBToggle =  false;
  ScorchToggle = true;
  procMonitorToggle = true;
  arcaneBlastToggle = true;
  abCastTimeToggle = true;
  minimapToggle = true;
  buffmonToggle = false;
  polyToggle = true;
  spMonitorSize = 3;
  ssMonitorSize = 3;
  procMonitorSize = 3;
  livingBCounterSize = 3;
  lockFrames = false;
  borderStyle = 0;
  transColor = 0;
  consoleTextEnabled = true;
  slowfallMsg = L["Slowfall Cast On You"];
  slowfallMsg2 = L["Slowfall Cast On You"];
  slowfallMsg3 = L["Slowfall Cast On You"];
  focusMagicNotify = L["Focus Magic Cast On You"];
  focusMagicNotify2 = L["Focus Magic Cast On You"];
  focusMagicNotify3 = L["Focus Magic Cast On You"];
  focusMagicThanks = L["Thanks For Focus Magic"];
  focusMagicThanks2 = L["Thanks For Focus Magic"];
  innervatThanks = L["Thanks For The Innervate"];
  innervatThanks2 = L["Thanks For The Innervate"];
  powerinfThanks = L["Thanks For Power Infusion"];
  backdropR = 0.0;
  backdropG = 0.0;
  backdropB = 0.0;
  backdropA = 0.0;
  MinimapPos = 45;
  miSound = "mirror.mp3";
  miSoundToggle = false;
  procSound = "proc.mp3";
  procSoundToggle = false;
  toolTips = true;
  clearcastToggle = true;
  clickthru = false;
  polyFrameSize = 3;
}

local livingBombCount = 0;
local mirrorImageTime = 0;
local livingbombTime = 0;
local waterEleTime = 0;
local spellStealTog = 0;
local misslebTog = 0;
local mageProcHSTime = 0;
local mageProcMBTime = 0;
local mageProcBFTime = 0
local fofProgMonTime = 0;
local mageImpProgMonTime = 0;
local combatTextCvar = GetCVar("enableCombatText");
local impactId = " ";
local hotStreakId = " ";
local missileBarId = " ";
local brainFreezeId =  " ";
local fingersFrostId = " ";
local ablastId = " ";
local abProgMonTime = 0;
local ttwFlag = false;
local abCastTime = 2.5;
local polyTimer = 0;
local scorchTime = 0;
local icyTimer = 0;
local apTimer = 0;
local lustTimer = 0;
local clearcastTime = 0;


function MN_Start(self)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("CVAR_UPDATE")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_UPDATE_RESTING")
    MageNuggetsOptions()
    SlashCmdList['MAGENUGGETS_SLASHCMD'] = MageNuggets_SlashCommandHandler
    SLASH_MAGENUGGETS_SLASHCMD1 = L["/magenuggets"]
end

function RoundCrit(critNum) --rounds the crit rating to two decimals
    return math.floor(critNum*math.pow(10,2)+0.5) / math.pow(10,2) 
end

function RoundThree(critNum) --rounds three places
    return math.floor(critNum*math.pow(10,3)+0.5) / math.pow(10,3) 
end

function RoundOne(inputNum) --rounds three places
    return math.floor(inputNum*math.pow(10,1)+0.5) / math.pow(10,1) 
end

function MageNuggets_SlashCommandHandler(msg) --Handles the slash commands
    if (msg == "options") then
	    InterfaceOptionsFrame_OpenToCategory("Mage Nuggets");
    elseif (msg == "ports") then
        MageNuggets_Minimap_OnClick(); 
    else
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff------------|cff00BFFF"..L["Mage"].." |cff00FF00"..L["Nuggets"].."|cffffffff 1.86--------------")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff"..L["/magenuggets"].." "..L["options (Shows Option Menu)"])
    DEFAULT_CHAT_FRAME:AddMessage("|cffffffff"..L["/magenuggets"].." "..L["ports (Shows Portal Menu)"])
    end
end
--
local MN_UpdateInterval = 1.0;
function MageNuggets_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
 if (self.TimeSinceLastUpdate > MN_UpdateInterval) then
    if (spellStealTog >= 1) then 
        spellStealTog = spellStealTog - 1;
    else
        if (MageNugz.ssMonitorToggle == true) then
            local stealableBuffs, i = { }, 1;
            local buffName, _, _, _, _, _, _, _, isStealable = UnitAura("target", i, "HELPFUL");
            while buffName do
                if(isStealable == 1) then
                    stealableBuffs[#stealableBuffs + 1] = buffName;
                end
                i = i + 1;
                buffName, _, _, _, _, _, _, _, isStealable = UnitAura("target", i, "HELPFUL");
            end
            if (#stealableBuffs < 1) then
                MNSpellSteal_Frame:Hide(); 
            else
                MNSpellSteal_Frame:Show(); 
                stealableBuffs = table.concat(stealableBuffs, "\n");
                MNSpellSteal_FrameBuffText:SetText("|cffFFFFFF"..stealableBuffs);
            end
        end
    end
    if(misslebTog >= 1) then
        misslebTog = misslebTog - 1;
    else
        if(UnitClass("Player") == 'Mage') then
            local p = 1; 
            local isMB = false
            local buffNamez, _, _, _, _, _, _, _, _, _, spellIdz = UnitAura("player", p, "HELPFUL");
            while buffNamez do
                if(spellIdz == 44401) then
                    isMB = true;
                end
                p = p + 1;
                buffNamez, _, _, _, _, _, _, _, _, _, spellIdz = UnitAura("player", p, "HELPFUL");
            end
            if (isMB == false) then
                mageProcMBTime = 0;
            end
        end
    end
  self.TimeSinceLastUpdate = 0;
  end
end     
--
local MNhs_UpdateInterval = 0.1;   
function MageNuggetsHS_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNhs_UpdateInterval) then   
        if (mageProcHSTime >= 0) then
            mageProcHSTime = RoundOne(mageProcHSTime - 0.1);
            MageNugProcFrame_ProcBar:SetValue(mageProcHSTime)
            MageNugProcFrameText2:SetText(mageProcHSTime)
            local position = (MageNugProcFrame_ProcBar:GetValue() / 9 * 120);
            MageNugProcFrame_ProcBarSpark:SetPoint("BOTTOMLEFT",MageNugProcFrame_ProcBar,"BOTTOMLEFT",position - 10,-6);
            if (mageProcHSTime <= 0) then
                MageNugProcFrame:Hide()
                MageNugProcFrame_ProcBar:SetValue(15)
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNmb_UpdateInterval = 0.1;   
function MageNuggetsMB_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNmb_UpdateInterval) then   
        if (mageProcMBTime >= 0) then
            mageProcMBTime = RoundOne(mageProcMBTime - 0.1);
            MageNugMBProcFrame_ProcBar:SetValue(mageProcMBTime)
            MageNugMBProcFrameText2:SetText(mageProcMBTime)
            local position = (MageNugMBProcFrame_ProcBar:GetValue() / 14 * 120);
            MageNugMBProcFrame_ProcBarSpark:SetPoint("BOTTOMLEFT",MageNugMBProcFrame_ProcBar,"BOTTOMLEFT",position - 10,-6);
            if (mageProcMBTime <= 0.1) then
                MageNugMBProcFrame:Hide()
                MageNugMBProcFrame_ProcBar:SetValue(14)
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNbf_UpdateInterval = 0.1;   
function MageNuggetsBF_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNbf_UpdateInterval) then   
        if (mageProcBFTime >= 0) then
            mageProcBFTime = RoundOne(mageProcBFTime - 0.1);
            MageNugBFProcFrame_ProcBar:SetValue(mageProcBFTime)
            MageNugBFProcFrameText2:SetText(mageProcBFTime)
            local position = (MageNugBFProcFrame_ProcBar:GetValue() / 14 * 120);
            MageNugBFProcFrame_ProcBarSpark:SetPoint("BOTTOMLEFT",MageNugBFProcFrame_ProcBar,"BOTTOMLEFT",position - 10, -6);
            if (mageProcBFTime <= 0) then
                MageNugBFProcFrame:Hide()
                MageNugBFProcFrame_ProcBar:SetValue(15)
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--    
local MNab_UpdateInterval = 0.1;   
function MageNuggetsAB_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNab_UpdateInterval) then   
        if (abProgMonTime >= 0) then
            abProgMonTime = RoundOne(abProgMonTime - 0.1);
            MageNugAB_Frame_ABBar:SetValue(abProgMonTime)
            MageNugAB_FrameText2:SetText("|cffFFFFFF"..abProgMonTime)
            if (abProgMonTime <= 0) then
                MageNugAB_Frame:Hide()
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--   
local MNslb_UpdateInterval = 0.1;
function MageNuggetsSmallLB_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNslb_UpdateInterval) then   
        if (livingbombTime >= 0) then
            livingbombTime = RoundOne(livingbombTime - 0.1);
            MageNugSmallLB_Frame_LBBar:SetValue(livingbombTime)
            MageNugSmallLB_FrameText2:SetText(livingbombTime)
            if (livingbombTime <= 0) then
                livingBombCount = 0;
                MageNugSmallLB_Frame:Hide();
            end
        end    
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNcc_UpdateInterval = 0.1;
function MageNuggetsClearCast_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNcc_UpdateInterval) then   
        if (clearcastTime >= 0) then
            clearcastTime = RoundOne(clearcastTime - 0.1);
            MageNugClearcast_Frame_Bar:SetValue(clearcastTime)
            MageNugClearcast_FrameText2:SetText(clearcastTime)
            if (clearcastTime <= 0) then
                MageNugClearcast_Frame:Hide();
            end
        end    
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNscorch_UpdateInterval = 1.0;
function MageNuggetsScorch_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNscorch_UpdateInterval) then   
        if(scorchTime >= 0) then
            scorchTime = scorchTime - 1;
            MageNugScorch_FrameText:SetText(scorchTime)
            MageNugScorch_Frame_Bar:SetValue(scorchTime)
            if(scorchTime <= 0) then
                MageNugScorch_Frame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNmi_UpdateInterval = 1.0;
function MageNuggetsMI_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNmi_UpdateInterval) then   
        if (mirrorImageTime >= 0) then
            mirrorImageTime = mirrorImageTime - 1.0;
            MageNugMI_Frame_MIText1:SetText(" "..mirrorImageTime)
            MageNugMI_Frame_MiBar:SetValue(mirrorImageTime)
            if (mirrorImageTime <= 0) then
                MageNugMI_Frame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--
local MNwe_UpdateInterval = 1.0;   
function MageNuggetsWE_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNwe_UpdateInterval) then   
        if (waterEleTime >=0) then
            waterEleTime = waterEleTime - 1.0;
            MageNugWE_Frame_WEText1:SetText(" "..waterEleTime)
            MageNugWE_Frame_WeBar:SetValue(waterEleTime)
            if(waterEleTime <= 0) then
                MageNugWE_Frame:Hide();
            end
        end 
    self.TimeSinceLastUpdate = 0;
    end   
end
--   
local MNpoly_UpdateInterval = 1.0;   
function MageNuggetsPoly_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNpoly_UpdateInterval) then   
        if (polyTimer >= 0) then
            polyTimer = polyTimer - 1.0;
            MageNugPolyFrameTimerText:SetText(polyTimer);
            if(polyTimer <= 0) then
                MageNugPolyFrame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--  
local MNicy_UpdateInterval = 1.0;   
function MageNuggetsIcy_OnUpdate(self, elapsed) 
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNicy_UpdateInterval) then   
        if (icyTimer >= 0) then
            icyTimer = icyTimer - 1.0;
            MNicyveins_FrameText:SetText(icyTimer);
            if(icyTimer <= 0) then
                MNicyveins_Frame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--
local MNlust_UpdateInterval = 1.0;   
function MageNuggetsLust_OnUpdate(self, elapsed) 
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNicy_UpdateInterval) then   
        if (lustTimer >= 0) then
            lustTimer = lustTimer - 1.0;
            MNlust_FrameText:SetText(lustTimer);
            if(lustTimer <= 0) then
                MNlust_Frame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--
local MNap_UpdateInterval = 1.0;   
function MageNuggetsArcaneP_OnUpdate(self, elapsed) 
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNap_UpdateInterval) then   
        if (apTimer >= 0) then
            apTimer = apTimer - 1.0;
            MNarcanepower_FrameText:SetText(apTimer);
            if(apTimer <= 0) then
                MNarcanepower_Frame:Hide();
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--
local MNfof_UpdateInterval = 0.1;   
function MageNuggetsFoF_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNfof_UpdateInterval) then   
        if (fofProgMonTime >= 0) then
            fofProgMonTime = RoundOne(fofProgMonTime - 0.1);
            MageNugFoFProcFrame_ProcBar:SetValue(fofProgMonTime)
            MageNugFoFProcFrameText2:SetText(fofProgMonTime)
            local position = (MageNugFoFProcFrame_ProcBar:GetValue() / 13 * 120);
            MageNugFoFProcFrame_ProcBarSpark:SetPoint("BOTTOMLEFT",MageNugFoFProcFrame_ProcBar,"BOTTOMLEFT",position - 10,-6);
            if (fofProgMonTime <= 0) then
                MageNugFoFProcFrame:Hide()
                MageNugFoFProcFrame_ProcBar:SetValue(14)
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--
local MNimp_UpdateInterval = 0.1;   
function MageNuggetsImpact_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNimp_UpdateInterval) then   
        if (mageImpProgMonTime >= 0) then
            mageImpProgMonTime = RoundOne(mageImpProgMonTime - 0.1);
            MageNugImpactProcFrame_ProcBar:SetValue(mageImpProgMonTime)
            MageNugImpactProcFrameText2:SetText(mageImpProgMonTime)
            local position = (MageNugImpactProcFrame_ProcBar:GetValue() / 9 * 120);
            MageNugImpactProcFrame_ProcBarSpark:SetPoint("BOTTOMLEFT",MageNugImpactProcFrame_ProcBar,"BOTTOMLEFT",position - 10,-6);
            if (mageImpProgMonTime <= 0) then
                MageNugImpactProcFrame:Hide()
                MageNugImpactProcFrame_ProcBar:SetValue(9)        
            end
        end
    self.TimeSinceLastUpdate = 0;
    end   
end  
--
local MNsp_UpdateInterval = 1.0
function MageNuggetsSP_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
 if (self.TimeSinceLastUpdate > MNsp_UpdateInterval) then   
        if (ttwFlag == false) then
            MNTorment_Frame:Hide();
        end
        local _, _, _, _, currRank11, _ = GetTalentInfo(1,14); --torment the weak
        local spellHit = RoundCrit(GetCombatRatingBonus(8));
        local critRating = RoundCrit(GetSpellCritChance(3));
        local hasteRating = ((GetCombatRatingBonus(20)/100) + 1);
        local misFlag = false;
        local faerieFlag = false;
        local j = 1;
        local jj = 1;
        ttwFlag = false;
        local buffName3, rank3, _, count3, _, _, _, _, _, _, spellId3 = UnitAura("target", j, "HARMFUL");
        while buffName3 do
            if (MageNugz.buffmonToggle == true) then
                if (currRank11 == 3) or (currRank11 == 2) or (currRank11 == 1) then
                    if(spellId3 == 31589) or (spellId3 == 55095) or (spellId3 == 45524) or (spellId3 == 12323) or (spellId3 == 18223) then
                        ttwFlag = true;
                        MNTorment_Frame:Show();
                    elseif (spellId3 == 3600) or (spellId3 == 13809) or (spellId3 == 2974) or (spellId3 == 25809) or (spellId3 == 1715) then
                        ttwFlag = true;
                        MNTorment_Frame:Show();
                    elseif (buffName3 == frostboltId) or (buffName3 == conecoldId) or (buffName3 == blastwaveId) or (buffName3 == frostfireId) or (buffName3 == chilledId) then
                        ttwFlag = true;
                        MNTorment_Frame:Show();
                    elseif (buffName3 == judgementjustId) or (buffName3 == infectedwoundsIdthen) or (buffName3 == thunderclapId) or (buffName3 == deadlythrowId) or (buffName3 == frostshockId) or (buffName3 == mindflayId) then
                        ttwFlag = true;
                        MNTorment_Frame:Show();
                    end
                end
            end
            if(spellId3 == 33198) then --misery
                spellHit = spellHit + 3.0;
                misFlag = true;
            elseif (spellId3 == 33197) then
                spellHit = spellHit + 2.0;
                misFlag = true;
            elseif (spellId3 == 33196) then
                spellHit = spellHit + 1.0;
                misFlag = true;
            end
            if(spellId3 == 770) then --Faerie Fire
                faerieFlag = true;
            end
            if(spellId3 == 12579) then --winter's chill
                if(count3 == 1) then
                    critRating = critRating + 1.0;
                elseif(count3 == 2) then
                    critRating = critRating + 2.0;
                elseif(count3 == 3) then
                    critRating = critRating + 3.0;
                elseif(count3 == 4) then
                    critRating = critRating + 4.0;
                elseif(count3 == 5) then
                    critRating = critRating + 5.0;
                end
            end
            if(spellId3 == 22959) then --scorch
                critRating = critRating + 5.0;
            end
            if(spellId3 == 17800) then --shadow mastery
                critRating = critRating + 5.0;
            end
            j = j + 1;
            buffName3, rank3, _, count3, _, _, _, _, _, _, spellId3 = UnitAura("target", j, "HARMFUL");
        end     
        local buffName2, rank2, _, count2, _, _, _, _, _, _, spellId2 = UnitAura("player", jj, "HELPFUL");
        while buffName2 do
            if(spellId2 == 28878) then
                spellHit = spellHit + 1;
            end
            if(spellId2 == 6562) then
                spellHit = spellHit + 1;
            end
            if(spellId2 == 10060) then --pushing the limit
                hasteRating = (hasteRating*1.20);
            end
            if(spellId2 == 70753) then --pushing the limit
                hasteRating = (hasteRating*1.12);
            end
            if(spellId2 == 2895) then --wrath of air tot
                hasteRating = (hasteRating*1.05);
            end
            if(spellId2 == 24907) then --Moonkin Aura
                hasteRating = (hasteRating*1.03);
            end
            if(spellId2 == 26297) then --berserking
                hasteRating = (hasteRating*1.20);
            end
            if(spellId2 == 12472) then --icy veins
                hasteRating = (hasteRating*1.20);
            end
            if(spellId2 == 2825) then --bloodlust
                hasteRating = (hasteRating*1.30);
            end
            if(spellId2 == 65980) then --bloodlust argent turny
                hasteRating = (hasteRating*1.30);
            end
            if(spellId2 == 32182) then --heroism
                hasteRating = (hasteRating*1.30);
            end
            if(spellId2 == 65983) then --heroism argent turny
                hasteRating = (hasteRating*1.30);
            end
            if(spellId2 == 16886) then --cfocus
                hasteRating = (hasteRating*1.20);
            end
            jj = jj + 1;
            buffName2, rank2, _, count2, _, _, _, _, _, _, spellId2 = UnitAura("player", jj, "HELPFUL");
        end 
        if(misFlag == false) then
            if (faerieFlag == true) then
                spellHit = spellHit + 3;
                if(UnitClass("Player") == 'Druid') then
                    critRating = critRating + 3.0;
                end
            end
        end
        if(UnitClass("Player") == 'Druid') then
            local nameD, _, _, _, currRankD, _ = GetTalentInfo(1,11) --cfocus 
            if(currRankD == 3) then
                hasteRating = (hasteRating*1.03)
            end
            if(currRankD == 2) then
                hasteRating = (hasteRating*1.02)
            end
            if(currRankD == 1) then
                hasteRating = (hasteRating*1.01)
            end
            local namebop, _, _, _, currRankbop, _ = GetTalentInfo(1,17) --Balance of Power
            if(currRankbop == 2) then
                spellHit = spellHit + 4;
            end
            if(currRankbop == 1) then
                spellHit = spellHit + 2;
            end
        end
        if(UnitClass("Player") == 'Mage') then
            local _, _, _, _, currRank7, _ = GetTalentInfo(3,6); --precision
            local _, _, _, _, currRank8, _ = GetTalentInfo(1,2); --arcane focus  
            local _, _, _, _, currRank9, _ = GetTalentInfo(1,22); --arcane power
            local _, _, _, _, currRank10, _ = GetTalentInfo(1,28); --netherwind presence
            if(currRank7 == 1) then
                spellHit = spellHit + 1.0;
            end
            if(currRank7 == 2) then
                spellHit = spellHit + 2.0;
            end
            if(currRank7 == 3) then
                spellHit = spellHit + 3.0;
            end
            if(currRank9 == 1) then
                if(currRank8 == 1) then
                    spellHit = spellHit + 1.0;
                end
                if(currRank8 == 2) then
                spellHit = spellHit + 2.0;
                end
                if(currRank8 == 3) then
                spellHit = spellHit + 3.0;
                end
            end
            if(currRank10 == 1) then
                hasteRating = (hasteRating*1.02);
            end
            if(currRank10 == 2) then
                hasteRating = (hasteRating*1.04);
            end
            if(currRank10 == 3) then
                hasteRating = (hasteRating*1.06);
            end
        end
        if(spellHit >= 17.0) then
            spellHit = "capped";
        else
            spellHit = spellHit.."%";
        end
        hasteRating = RoundCrit((hasteRating - 1)*100)
        abCastTime = RoundThree((2.5)/(1+(hasteRating/100)))
        if(MageNugz.abCastTimeToggle == true) then
            if(abCastTime < 1) then
                MNabCast_FrameText:SetText("|cffFF0000Capped")
            else
                MNabCast_FrameText:SetText("|cffFFFFFF"..abCastTime)
            end
        end
        MageNugSP_FrameText:SetText("|cffFF0000SP:|cffFFFFFF"..GetSpellBonusDamage(3).."\n|cffFF6600Crit:|cffFFFFFF"..critRating.."%".."\n|cffCC33FFHaste:|cffFFFFFF"..hasteRating.."%".."\n|cffFFFF33 Hit:|cffFFFFFF"..spellHit);
    self.TimeSinceLastUpdate = 0;
  end
end   

function MageNuggets_OnEvent(self, event, ...)
    if (event == "ADDON_LOADED") and (arg1 == "MageNuggets") then
        MNVariablesLoaded_OnEvent()
    end  
    if (event == "VARIABLES_LOADED") then
        MNVariablesLoaded_OnEvent()
    end
    if (event == "PLAYER_REGEN_DISABLED") then       
        if(UnitClass("Player") == 'Mage') then
        local i1 = 1; 
        local isMageArmorOn = false;
        local buffNamei1, _, _, _, _, _, _, _, _, _, spellIdi1 = UnitAura("player", i1, "HELPFUL");
        while buffNamei1 do
            if(spellIdi1 == 43046) or (spellIdi1 == 43045) or (spellIdi1 == 30482) or (spellIdi1 == 43024) or (spellIdi1 == 43023) or (spellIdi1 == 27125) or (spellIdi1 == 22783) or (spellIdi1 == 22782) or (spellIdi1 == 6117)then
                isMageArmorOn = true;
            end
            if(spellIdi1 == 43008) or (spellIdi1 == 27124) or (spellIdi1 == 10220) or (spellIdi1 == 10219) or (spellIdi1 == 7320) or (spellIdi1 == 7302) or (spellIdi1 == 7301) or (spellIdi1 == 7300) or (spellIdi1 == 168)then
                isMageArmorOn = true;
            end
            i1 = i1 + 1;
            buffNamei1, _, _, _, _, _, _, _, _, _, spellIdi1 = UnitAura("player", i1, "HELPFUL");
        end
        if (isMageArmorOn == false) then
            if(combatTextCvar == '1') then
                if (MageNugz.mageProcToggle == true) then
                    CombatText_AddMessage(L["BUFF MISSING: Mage Armor!"], CombatText_StandardScroll, 1.0, 0, 0, "crit", isStaggered, nil);
			    end
            end
            if (MageNugz.consoleTextEnabled == true) then
                DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["BUFF MISSING: Mage Armor!"])
            end
        end
        end
    end  
    if (event == "CVAR_UPDATE") then
        combatTextCvar = GetCVar("enableCombatText")
    end
    if (event == "PLAYER_ENTERING_WORLD") then
        MageNugHordeFrame:Hide();
        MageNugAlliFrame:Hide();
    end
    if (event == "PLAYER_UPDATE_RESTING") then
        MageNugHordeFrame:Hide();
        MageNugAlliFrame:Hide();
    end
    if (event == "UNIT_AURA") and (arg1 == "player") then
        _, _, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player",impactId)
        if (spellId == 64343) then
            local imptime = RoundOne(expirationTime - GetTime());
            if(MageNugz.procMonitorToggle == true) then
                mageImpProgMonTime = imptime;
                MageNugImpactProcFrameText:SetText("|cffFF0000"..L["IMPACT!"])
                MageNugImpactProcFrame_ProcBar:SetValue(mageImpProgMonTime)
                MageNugImpactProcFrame:Show();
            end
            if(imptime >= 9.9)then
                if(combatTextCvar == '1') then
                    if (MageNugz.mageProcToggle == true) then
                        CombatText_AddMessage(L["IMPACT!"], CombatText_StandardScroll, 1.0, 0, 0, "crit", isStaggered, nil);
			        end
                end
                if (MageNugz.procSoundToggle == true) then
                    PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.procSound)
                end
            end
        end
        _, _, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", missileBarId) 
        if (spellId ==  44401) then
            local mbtime = RoundOne(expirationTime - GetTime());
            if(MageNugz.procMonitorToggle == true) then
                mageProcMBTime = mbtime;
                MageNugMBProcFrameText:SetText("|cffFF33FF"..L["MISSILE BARRAGE!"])
                MageNugMBProcFrame_ProcBar:SetValue(mageProcMBTime)
                MageNugMBProcFrame:Show()
            end
            if(mbtime >= 14.9)then
                if(combatTextCvar == '1') then
                    if (MageNugz.mageProcToggle == true) then
                        CombatText_AddMessage(L["MISSILE BARRAGE!"], CombatText_StandardScroll, 0.60, 0, 0.60, "crit", isStaggered, nil);
			        end
                end
                if (MageNugz.procSoundToggle == true) then
                    PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.procSound)
                end
            end  
        end
        _, _, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", hotStreakId) 
        if(spellId == 48108) then
            local hstime = RoundOne(expirationTime - GetTime());
            if(MageNugz.procMonitorToggle == true) then
                mageProcHSTime = hstime;
                MageNugProcFrameText:SetText("|cffFF0000"..L["HOT STREAK!"])
                MageNugProcFrame_ProcBar:SetValue(mageProcHSTime)
                MageNugProcFrame:Show()
            end
            if(hstime >= 9.9)then
                if(combatTextCvar == '1') then
                    if (MageNugz.mageProcToggle == true) then
                        CombatText_AddMessage(L["HOT STREAK!"], CombatText_StandardScroll, 1, 0.10, 0, "crit", isStaggered,nil);
			        end
                end
                if (MageNugz.procSoundToggle == true) then
                    PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.procSound)
                end
            end  
        end
        _, _, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", brainFreezeId) 
        if(spellId == 57761) then
            local bftime = RoundOne(expirationTime - GetTime());
            if(MageNugz.procMonitorToggle == true) then
                mageProcBFTime = bftime;     
                MageNugBFProcFrameText:SetText("|cffFF3300"..L["BRAIN FREEZE!"])
                MageNugBFProcFrame_ProcBar:SetValue(mageProcBFTime)
                MageNugBFProcFrame:Show()
            end
            if(bftime >= 14.9)then
                if(combatTextCvar == '1') then
                    if (MageNugz.mageProcToggle == true) then
                        CombatText_AddMessage(L["BRAIN FREEZE!"], CombatText_StandardScroll, 1, 0.20, 0, "crit", isStaggered);
			        end
                end
                if (MageNugz.procSoundToggle == true) then
                   PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.procSound)
                end
            end  
        end       
        _, _, _, _, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", fingersFrostId) 
        if(spellId == 74396) then
            local foftime = RoundOne(expirationTime - GetTime());
            if(MageNugz.procMonitorToggle == true) then
                fofProgMonTime = foftime;
                MageNugFoFProcFrameText:SetText("|cffFFFFFF"..L["Fingers Of Frost"])
                MageNugFoFProcFrame_ProcBar:SetValue(fofProgMonTime)
                MageNugFoFProcFrame:Show()
            end
            if(foftime >= 14.9)then
                if(combatTextCvar == '1') then
                    if (MageNugz.mageProcToggle == true) then
                       CombatText_AddMessage(L["Fingers Of Frost"], CombatText_StandardScroll, 1, 1, 1, "crit", 1);
			        end
                end
                if (MageNugz.procSoundToggle == true) then
                   PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.procSound)
                end
            end  
        end    
        _, _, _, count, _, _, expirationTime, _, _, _, spellId = UnitDebuff("player", ablastId) 
        if (spellId == 36032) then
            if (MageNugz.arcaneBlastToggle == true) then
                local ABtime = expirationTime - GetTime()
                abProgMonTime = ABtime;
                MageNugAB_FrameText:SetText("|cffFF00FF"..count)
                MageNugAB_Frame_ABBar:SetValue(abProgMonTime)
                MageNugAB_Frame:Show()
            end
        end
    end
    if (event == "COMBAT_LOG_EVENT_UNFILTERED")then   
        local _, event1, _, sourceName, _, destGUID, destName, _ = select(1, ...) 
        local arg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = select(9, ...) 
		local spellId1 = select(12, ...)     
        if event1 == "SPELL_CAST_START" then
            if sourceName == UnitName("player") then
                if ((arg == 42832) or (arg == 42833) or (arg == 38692) or (arg == 27070) or (arg == 25306) or (arg == 10149) or (arg == 10150) or (arg == 10151)) then
                    MageNugBFProcFrame:Hide() 
                end
                if ((arg == 44614) or (arg == 47610)) then
                    MageNugBFProcFrame:Hide() 
                end
                if ((arg == 42891) or (arg == 42890) or (arg == 33938) or (arg == 27132) or (arg == 18809) or (arg == 12526) or (arg == 12525)) then
                    MageNugProcFrame:Hide() 
                end
            end
        end
        if event1 == "SPELL_AURA_REFRESH" then
            if (MageNugz.polyToggle == true) then
                    local dest = tonumber(destGUID:sub(5,5), 16);
                    local maskdest = dest % 8;
                    if (arg == 61305) or (arg == 61721) or (arg == 28271) or (arg == 12826) or (arg == 28272) then
                        if (maskdest == 0) then
                            polyTimer = 8;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 12825)  then
                        if (maskdest == 0) then
                            polyTimer = 8;
                        else
                            polyTimer = 39;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 12824)  then
                        if (maskdest == 0) then
                            polyTimer = 8;
                        else
                            polyTimer = 29;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 118)  then
                        if (maskdest == 0) then
                            polyTimer = 8;
                        else
                            polyTimer = 19;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrame:Show();
                    end
            end            
            if(MageNugz.absorbToggle == true) then   
                if sourceName == UnitName("player") then
                    if (MageNugz.consoleTextEnabled == true) then
                        if (arg == 43039) then
                            local iceBarrTotal = ((GetSpellBonusDamage(3) * 0.8067) + 3300);
                            local iceBarrRounded = math.floor(iceBarrTotal*math.pow(10,0)+0.5) / math.pow(10,0)
                            for i = 1, 6 do
                                local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i);
                                if (enabled == 1) then
                                    if (glyphSpellID ~= nil) then
                                        if (glyphSpellID == 63095) then
                                        iceBarrRounded = iceBarrRounded * 1.3;
                                        end
                                    end
                                end
                            end    
                            DEFAULT_CHAT_FRAME:AddMessage("|cff00BFFF"..L["Ice Barrier Absorbing"]..":|cffFFFFFF "..iceBarrRounded.."|cff00BFFF "..L["Damage"]);
                        end                
                        if (arg == 43020) then
                            local manaShieldTotal = ((GetSpellBonusDamage(3) * 0.8067) + 1330);
                            local manaShieldRounded = math.floor(manaShieldTotal*math.pow(10,0)+0.5) / math.pow(10,0)              
                            DEFAULT_CHAT_FRAME:AddMessage("|cff00688B"..L["Mana Shield Absorbing"]..":|cffFFFFFF "..manaShieldRounded.."|cff00688B "..L["Damage"]);
                        end
                    end
                end    
            end
            if(arg == 22959) then
                if sourceName == UnitName("player") then
                    if(MageNugz.ScorchToggle == true) then
                        scorchTime = 29;
                        MageNugScorch_FrameText:SetText(scorchTime)
                        MageNugScorch_Frame_Bar:SetValue(scorchTime)
                        MageNugScorch_Frame:Show();
                    end
                end
            end
        end
        --
        if event1 == "SPELL_CAST_SUCCESS" then 
            if sourceName == UnitName("player") then
                if ((arg == 42845) or (arg == 42844) or (arg == 38703) or (arg == 38700) or (arg == 27076) or (arg == 25346))then
                    MageNugMBProcFrame:Hide()
                end    
                if (arg == 42873) or (arg == 42872) or (arg == 27079) or (arg == 27078) or (arg == 10199) or (arg == 10197) or (arg == 8413) then
                    MageNugImpactProcFrame:Hide();
                end
                if (arg == 33831) then
                    if (MageNugz.miSoundToggle == true) then
                        PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.miSound)
                    end
                end
                if (arg == 31687) then
                    if (MageNugz.waterEleToggle == true) then
                        local waterGlyphed = 0;
                        local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(3,26);
                        for k = 1, 6 do
                            local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(k);
                            if (enabled == 1) then
                                if (glyphSpellID ~= nil) then
                                    if (glyphSpellID == 70937) then
                                        waterGlyphed = 1;
                                    end
                                end
                            end
                        end    
                        if(waterGlyphed == 0) then
                            if (currRank == 0) then 
                                MageNugWE_Frame_WeBar:SetMinMaxValues(0,45)           
                                waterEleTime = 45;
                                MageNugWE_Frame_WEText1:SetText(" "..waterEleTime)
                                MageNugWE_Frame_WeBar:SetValue(waterEleTime)
                                MageNugWE_Frame:Show()
                            end
                            if (currRank == 1) then 
                                MageNugWE_Frame_WeBar:SetMinMaxValues(0,50)           
                                waterEleTime = 50;
                                MageNugWE_Frame_WEText1:SetText(" "..waterEleTime)
                                MageNugWE_Frame_WeBar:SetValue(waterEleTime)
                                MageNugWE_Frame:Show()
                            end
                            if (currRank == 2) then 
                                MageNugWE_Frame_WeBar:SetMinMaxValues(0,55)           
                                waterEleTime = 55;
                                MageNugWE_Frame_WEText1:SetText(" "..waterEleTime)
                                MageNugWE_Frame_WeBar:SetValue(waterEleTime)
                                MageNugWE_Frame:Show()
                            end
                            if (currRank == 3) then 
                                MageNugWE_Frame_WeBar:SetMinMaxValues(0,60)           
                                waterEleTime = 60;
                                MageNugWE_Frame_WEText1:SetText(" "..waterEleTime)
                                MageNugWE_Frame_WeBar:SetValue(waterEleTime)
                                MageNugWE_Frame:Show()
                            end
                        end
                    end
                end
            end
        end
        --
        if event1 == "SPELL_AURA_REMOVED" then 
            if sourceName == UnitName("player") then
                if(arg == 22959) then
                    MageNugScorch_Frame:Hide();
                end
                if (arg == 36032) then
                    MageNugAB_Frame:Hide()
                end
                if (arg == 74396) then
			        MageNugFoFProcFrame:Hide()
                end
                if (arg == 12536) then
                    if (MageNugz.clearcastToggle == true) then
                        MageNugClearcast_Frame:Hide();
                    end
                end
                if (arg == 55360) then
                    livingBombCount = livingBombCount - 1;
                    if (livingBombCount <= 0) then
                        livingBombCount = 0;
                        MageNugSmallLB_Frame:Hide();
                    end
                    if (MageNugz.smallLBToggle == true) then
                        MageNugSmallLB_FrameText:SetText("|cffFFFFFF"..livingBombCount)
                    else
                        MageNugLBTemplate_AnchorText2:SetText("|cffFFFFFF"..livingBombCount)
                    end
                end
                if (MageNugz.polyToggle == true) then
                    if (arg == 28272) then
                        MageNugPolyFrame:Hide();
                        polyTimer = 0;
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage("Polymorph Broken", CombatText_StandardScroll, 1, 0.20, 1, "sticky", nil);
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Polymorph(Pig) Broken On"]..":|cffFFFFFF "..destName);
                        end
                    end
                    if (arg == 12826) or (arg == 12825) or (arg == 12824) or (arg == 118) then
                        MageNugPolyFrame:Hide();
                        polyTimer = 0;
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage("Polymorph Broken", CombatText_StandardScroll, 1, 0.20, 1, "sticky", nil);
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Polymorph(Sheep) Broken On"]..":|cffFFFFFF "..destName);
                        end
                    end
                    if (arg == 28271) then
                        MageNugPolyFrame:Hide();
                        polyTimer = 0;
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage("Polymorph Broken", CombatText_StandardScroll, 1, 0.20, 1, "sticky", nil);
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Polymorph(Turtle) Broken On"]..":|cffFFFFFF "..destName);
                        end
                    end
                    if (arg == 61721) then
                        MageNugPolyFrame:Hide();
                        polyTimer = 0;
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage("Polymorph Broken", CombatText_StandardScroll, 1, 0.20, 1, "sticky", nil);
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Polymorph(Rabbit) Broken On"]..":|cffFFFFFF "..destName);
                        end
                    end
                    if (arg == 61305) then
                        MageNugPolyFrame:Hide();
                        polyTimer = 0;
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage("Polymorph Broken", CombatText_StandardScroll, 1, 0.20, 1, "sticky", nil);
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Polymorph(Black Cat) Broken On"]..":|cffFFFFFF "..destName);
                        end
                    end 
                end
            end
        end
        --
        if event1 == "SPELL_AURA_APPLIED" then
            if sourceName == UnitName("player") then
                if (arg == 12042) then
                    if (MageNugz.buffmonToggle == true) then
                        apTimer = 14
                        MNarcanepower_FrameText:SetText(apTimer);
                        MNarcanepower_Frame:Show();
                    end
                end
                if (arg == 12472) then
                    if (MageNugz.buffmonToggle == true) then
                        icyTimer = 19;
                        MNicyveins_FrameText:SetText(icyTimer);
                        MNicyveins_Frame:Show();
                    end
                end
                if (MageNugz.polyToggle == true) then
                    local destpoly = tonumber(destGUID:sub(5,5), 16);
                    local maskdest = destpoly % 8;
                    if  (arg == 12826) then -- sheep
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_nature_polymorph");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 28272) then -- pig
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_magic_polymorphpig");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 61305) then -- cat
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Achievement_halloween_cat_01");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 61721) then -- rabbit
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_magic_polymorphrabbit");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 28271) then -- turtle
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 49;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Ability_hunter_pet_turtle");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 12825)  then
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 39;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_nature_polymorph");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 12824)  then
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 29;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_nature_polymorph");
                        MageNugPolyFrame:Show();
                    end
                    if (arg == 118)  then
                        if (maskdest == 0) then
                            polyTimer = 9;
                        else
                            polyTimer = 19;
                        end
                        MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"]..":\n|cffFFFFFF "..destName);
                        MageNugPolyFrameTimerText:SetText(polyTimer);
                        MageNugPolyFrameTexture:SetTexture("Interface\\Icons\\Spell_nature_polymorph");
                        MageNugPolyFrame:Show();
                    end
                end            
                if(MageNugz.absorbToggle == true) and (MageNugz.consoleTextEnabled == true) then
                    if (arg == 43039) then
                        local iceBarrTotal = ((GetSpellBonusDamage(3) * 0.8067) + 3300);
                        local iceBarrRounded = math.floor(iceBarrTotal*math.pow(10,0)+0.5) / math.pow(10,0)
                        for i = 1, 6 do
                            local enabled, glyphType, glyphSpellID, icon = GetGlyphSocketInfo(i);
                            if (enabled == 1) then
                                if (glyphSpellID ~= nil) then
                                    if (glyphSpellID == 63095) then
                                        iceBarrRounded = iceBarrRounded * 1.3;
                                    end
                                end
                            end
                        end    
                        DEFAULT_CHAT_FRAME:AddMessage("|cff00BFFF"..L["Ice Barrier Absorbing"]..":|cffFFFFFF "..iceBarrRounded.."|cff00BFFF "..L["Damage"]);
                    end                
                    if (arg == 43012) then
                        local frostWardTotal = ((GetSpellBonusDamage(3) * 0.8067) + 1950);
                        local frostWardRounded = math.floor(frostWardTotal*math.pow(10,0)+0.5) / math.pow(10,0)              
                        DEFAULT_CHAT_FRAME:AddMessage("|cff00BFFF"..L["Frost Ward Absorbing"]..":|cffFFFFFF "..frostWardRounded.."|cff00BFFF "..L["Frost"].." "..L["Damage"]);
                    end
                    if (arg == 43010) then
                        local fireWardTotal = ((GetSpellBonusDamage(3) * 0.8067) + 1950);
                        local fireWardRounded = math.floor(fireWardTotal*math.pow(10,0)+0.5) / math.pow(10,0)              
                        DEFAULT_CHAT_FRAME:AddMessage("|cffFF030D "..L["Fire Ward Absorbing"]..":|cffFFFFFF "..fireWardRounded.."|cffFF030D "..L["Fire"].." "..L["Damage"]);
                    end
                    if (arg == 43020) then
                        local manaShieldTotal = ((GetSpellBonusDamage(3) * 0.8067) + 1330);
                        local manaShieldRounded = math.floor(manaShieldTotal*math.pow(10,0)+0.5) / math.pow(10,0)              
                        DEFAULT_CHAT_FRAME:AddMessage("|cff00688B"..L["Mana Shield Absorbing"]..":|cffFFFFFF "..manaShieldRounded.."|cff00688B "..L["Damage"]);
                    end
                end
                if ((arg == 55360) or (arg == 55359) or (arg == 44457)) then
                    if (MageNugz.livingBombToggle == true) then
                        livingBombCount = livingBombCount + 1;
                        if (MageNugz.smallLBToggle == true) then
                            livingbombTime = 12;
                            MageNugSmallLB_FrameText:SetText("|cffFFFFFF"..livingBombCount)
                            MageNugSmallLB_Frame_LBBar:SetValue(livingbombTime)
                            MageNugSmallLB_Frame:Show()
                        else
                            livingbombTime = 13;
                            LBmonitor(12, destName)
                            MageNugLBTemplate_AnchorText2:SetText("|cffFFFFFF"..livingBombCount)
                            MageNugLBTemplate_Anchor:Show()
                        end
                    end
                end
                if (arg == 55342) then
                    if (MageNugz.mirrorImageToggle == true) then
                        if (MageNugz.miSoundToggle == true) then
                            PlaySoundFile("Interface\\AddOns\\MageNuggets\\Sounds\\"..MageNugz.miSound)
                        end
                        mirrorImageTime = 30;
                        MageNugMI_Frame_MIText1:SetText(" "..mirrorImageTime)
                        MageNugMI_Frame_MiBar:SetValue(mirrorImageTime)
                        MageNugMI_Frame:Show();
                    end
                end
                if(arg == 22959) then
                    if(MageNugz.ScorchToggle == true) then
                        scorchTime = 29;
                        MageNugScorch_FrameText:SetText(scorchTime)
                        MageNugScorch_Frame_Bar:SetValue(scorchTime)
                        MageNugScorch_Frame:Show();
                    end
                end
                if (arg == 130) then
                    if (destName ~= UnitName("player")) then
                        local sfRandomNum = math.random(1,3)
                        if(sfRandomNum == 1) then 
                            SendChatMessage(MageNugz.slowfallMsg, "WHISPER", nil, destName);
                        end
                        if(sfRandomNum == 2) then
                            SendChatMessage(MageNugz.slowfallMsg2, "WHISPER", nil, destName);
                        end
                        if(sfRandomNum == 3) then
                            SendChatMessage(MageNugz.slowfallMsg3, "WHISPER", nil, destName);
                        end
                    end
                end
                if (arg == 54646) then
                    local fmRandomNum = math.random(1,3)
                    if(fmRandomNum == 1) then
                        SendChatMessage(MageNugz.focusMagicNotify, "WHISPER", nil, destName);
                    end
                    if(fmRandomNum == 2) then
                        SendChatMessage(MageNugz.focusMagicNotify2, "WHISPER", nil, destName);
                    end
                    if(fmRandomNum == 3) then
                        SendChatMessage(MageNugz.focusMagicNotify3, "WHISPER", nil, destName);
                    end
                end
            end
            if destName == UnitName("player") then
                if (arg == 12536) then
                    if (MageNugz.clearcastToggle == true) then
                        if(combatTextCvar == '1') then    
                            CombatText_AddMessage(L["Clearcast"], CombatText_StandardScroll, 1, 1, 1, nil, isStaggered, nil);
                        end    
                        clearcastTime = 15;
                        MageNugClearcast_Frame:Show();
                    end
                end
                if (arg == 64868) then
				    if(combatTextCvar == '1') then
                        if (MageNugz.mageProcToggle == true) then
                            CombatText_AddMessage(L["Praxis"], CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil, nil);
                            CombatText_AddMessage(L["+350 Spellpower"], CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil);
			            end
                    end
                end
		        if (arg == 10060) then
                    if (MageNugz.consoleTextEnabled == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("|cff0000FF"..L["Power Infusion By"]..":|cffFFFFFF "..sourceName);
                    end
                    if(combatTextCvar == '1') then
                        CombatText_AddMessage(sourceName, CombatText_StandardScroll, 0, 0.10, 1, "sticky", nil);
                        CombatText_AddMessage(L["POWER INFUSION!"], CombatText_StandardScroll, 0, 0.10, 1, "sticky", nil);  
                    end
                    SendChatMessage(MageNugz.powerinfThanks, "WHISPER", nil, sourceName);   
                end
                if (arg == 12051) then
                    if (MageNugz.evocationToggle == true) then
                        local manaPoolTotal = UnitManaMax("player");
                        local evoTotal = manaPoolTotal * 0.60
                        evoTotal = math.floor(evoTotal+0.5) 
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cff663399"..L["Evocating For"].." "..evoTotal.." "..L["Mana"]);
                        end
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage(L["Evocating For"].." "..evoTotal.." Mana", CombatText_StandardScroll, 0, 0.10, 1, nil, isStaggered, nil);  
                        end
                    end
                end
                if(combatTextCvar == '1') then
                    if (arg == 63711) then
                        CombatText_AddMessage(L["STORM POWER"].."!!", CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                        CombatText_AddMessage(L["(+135% Crit Damage)"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                    end
                    if (arg == 65134) then
                        CombatText_AddMessage(L["STORM POWER"].."!", CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                        CombatText_AddMessage(L["(+135% Crit Damage)"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                    end
                    if (arg == 62821) then
                        CombatText_AddMessage(L["TOASTY FIRE!"], CombatText_StandardScroll, 1, 0.20, 0, "sticky", nil);
                    end
                    if (arg == 29232) then
                        CombatText_AddMessage(L["Fungal Creep!"], CombatText_StandardScroll, 0, 1, 0.2, "sticky", nil);
                        CombatText_AddMessage(L["(+50% Crit Rating)"], CombatText_StandardScroll, 0, 1, 0,2, "sticky", nil);
                    end
                    if (arg == 62320) then
                        CombatText_AddMessage(L["Aura of Celerity!"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                        CombatText_AddMessage(L["(+20% Haste)"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                    end
                    if (arg == 62807) then
                        CombatText_AddMessage(L["Star Light!"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                        CombatText_AddMessage(L["(50% Haste)"], CombatText_StandardScroll, 1, 1, 1, "sticky", nil);
                    end
                end
                if (arg == 29166) then
                    if (sourceName ~= UnitName("player")) then
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cff0000FF"..L["Innervated By"]..":|cffFFFFFF "..sourceName);
                        end
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage(sourceName, CombatText_StandardScroll, 0, 0.10, 1, "sticky", nil);
                            CombatText_AddMessage(L["INNERVATED YOU!"], CombatText_StandardScroll, 0, 0.10, 1, "sticky", nil);  
                        end
                        local inRandomNum = math.random(1,2)
                        if(inRandomNum == 1) then 
                            SendChatMessage(MageNugz.innervatThanks, "WHISPER", nil, sourceName);   
                        end
                        if(inRandomNum == 2) then 
                            SendChatMessage(MageNugz.innervatThanks2, "WHISPER", nil, sourceName);
                        end
                    end
                end
                if (arg == 54646) then
                    if (MageNugz.consoleTextEnabled == true) then
                        DEFAULT_CHAT_FRAME:AddMessage("|cff0000FF"..L["Focused Magic By"]..":|cffFFFFFF "..sourceName);
                    end
                    if(combatTextCvar == '1') then
                        CombatText_AddMessage(sourceName, CombatText_StandardScroll, 0, 0.10, 1, nil, nil);
                        CombatText_AddMessage(L["Focused Magic you"], CombatText_StandardScroll, 0, 0.10, 1, nil, nil);  
                    end
                    local fmRandomNum = math.random(1,2)
                    if(fmRandomNum == 1) then 
                       SendChatMessage(MageNugz.focusMagicThanks, "WHISPER", nil, sourceName);   
                    end
                    if(fmRandomNum == 2) then
                       SendChatMessage(MageNugz.focusMagicThanks2, "WHISPER", nil, sourceName);
                    end
                end
                if (arg == 2825) then
                    if sourceName ~= UnitName("player") then
                        if (MageNugz.buffmonToggle == true) then
                            lustTimer = 40;
                            MNlust_Frame:Show()
                        end
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Blood Lust used by"]..":|cff0000FF "..sourceName);
                        end
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage(sourceName, CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil);
                            CombatText_AddMessage(L["BLOOD LUSTED!"], CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil);  
                        end
                    end
                end
                if (arg == 32182) then
                    if sourceName ~= UnitName("player") then
                        lustTimer = 40;
                        MNlust_Frame:Show()
                        if (MageNugz.consoleTextEnabled == true) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000"..L["Heroism used by"]..":|cff0000FF "..sourceName);
                        end
                        if(combatTextCvar == '1') then
                            CombatText_AddMessage(sourceName, CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil);
                            CombatText_AddMessage(L["HEROISM!"], CombatText_StandardScroll, 1, 0.10, 0, "sticky", nil);  
                        end
                    end
                end
  
            end
		end
        --
        if event1 == "SPELL_STOLEN" then
            if sourceName == UnitName("player") then
				if(combatTextCvar == '1') then
                    CombatText_AddMessage(L["Stole"]..":"..GetSpellLink(spellId1), CombatText_StandardScroll, 0.10, 0, 1, "sticky", nil);
                end
                if (MageNugz.consoleTextEnabled == true) then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffFFFFFF"..L["Spell Stolen"]..":"..GetSpellLink(spellId1))
	    	    end
            end
		end
    end
end

--------------------------------Options Functions----------------------------------

function MNVariablesLoaded_OnEvent() --Takes care of the options on load up
        if((UnitClass("Player") == 'Warrior') or (UnitClass("Player") == 'Rogue') or (UnitClass("Player") == 'Death Knight') or (UnitClass("Player") == 'Paladin') or (UnitClass("Player") == 'Hunter')) then
            MageNugz.spMonitorToggle = false;
            MageNugz.ssMonitorToggle = false;
            MageNugz.mageProcToggle = false;
            MageNugz.camZoomTogg = false;
            MageNugz.absorbToggle = false;
            MageNugz.mirrorImageToggle = false;
            MageNugz.waterEleToggle = false;
            MageNugz.evocationToggle = false;
            MageNugz.livingBombToggle = false;
            MageNugz.procMonitorToggle = false;
            MageNugz.consoleTextEnabled = false;
            MageNugz.arcaneBlastToggle = false;
            MageNugz.minimapToggle = false;
        end
        if((UnitClass("Player") == 'Druid') or (UnitClass("Player") == 'Shaman') or (UnitClass("Player") == 'Priest') or (UnitClass("Player") == 'Warlock')) then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00BFFF"..L["Mage"].."|cff00FF00"..L["Nuggets"].."|cffffffff 1.86 "..L["loaded! Some Options Disabled (Class:"]..UnitClass("Player")..")")
            MageNugz.ssMonitorToggle = false;
            MageNugz.mageProcToggle = false;
            MageNugz.absorbToggle = false;
            MageNugz.mirrorImageToggle = false;
            MageNugz.waterEleToggle = false;
            MageNugz.evocationToggle = false;
            MageNugz.livingBombToggle = false;
            MageNugz.procMonitorToggle = false;
            MageNugz.minimapToggle = false;
        end
        if(UnitClass("Player") == 'Mage') then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00BFFF"..L["Mage"].."|cff00FF00"..L["Nuggets"].."|cffffffff 1.86 "..L["loaded! (Use: /magenuggets options)"])
        end                
        -----Main Options----- 
        if (MageNugz.minimapToggle == nil) then
            MageNugz.minimapToggle = true;
        end
        if (MageNugz.minimapToggle == true) then
            MageNug_MinimapFrame:Show();
            MageNugOption2Frame_MinimapCheckButton:SetChecked(0);
        else
            MageNug_MinimapFrame:Hide();
            MageNugOption2Frame_MinimapCheckButton:SetChecked(1);
        end
        combatTextCvar = GetCVar("enableCombatText")
        MNspellstealFontString:SetText(L["Disable Spellsteal Monitor"])
        MNprocTextFontString:SetText(L["Disable Mage Proc Combat Text"])
        MNshieldFontString:SetText(L["Disable Precise Shield Absorb Notify"])
        MNmirrorImageFontString:SetText(L["Disable Mirror Image Timer"])
        MNwaterEleFontString:SetText(L["Disable Water Elemental Timer"])
        MNevoFontString:SetText(L["Disable Evocation Notify"])
        MNlbCounterFontString:SetText(L["Disable Living Bomb Counter"])
        MNprocMonsFontString:SetText(L["Disable Mage Proc Monitors"])
        MNabCounterFontString:SetText(L["Disable Arcane Blast Counter"])
        MNPolyFontString:SetText(L["Disable Poly Monitor"])
        MNcheckboxScorchFontString:SetText(L["Disable Scorch Monitor"])
        MNcheckboxclearcastString:SetText(L["Disable Clearcast Monitor"])
        MNcheckboxSmallLBFontString:SetText(L["Small LB Counter"])
        MNcheckboxABcastString:SetText(L["AB Cast Time"])
        MN_Slider2FontString:SetText(L["Spellsteal Monitor Size"])
        MN_Slider3FontString:SetText(L["LB,AB,Scorch Counter Size"])
        MN_Slider4FontString:SetText(L["Mage Proc Monitor Size"])
        MageNugOptionsFrameButton1:SetText(L["Preview Frames"])
        if (MageNugz.ssMonitorToggle == true) then
            MageNugOptionsFrame_CheckButton2:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton2:SetChecked(1);
        end
        if (MageNugz.mageProcToggle == true) then
            MageNugOptionsFrame_CheckButton3:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton3:SetChecked(1);
        end
        if (MageNugz.absorbToggle == true) then
            MageNugOptionsFrame_CheckButton5:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton5:SetChecked(1);
        end
        if (MageNugz.mirrorImageToggle == true) then
            MageNugOptionsFrame_CheckButton6:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton6:SetChecked(1);
        end
        if (MageNugz.waterEleToggle == true) then
            MageNugOptionsFrame_CheckButton7:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton7:SetChecked(1);
        end
        if (MageNugz.evocationToggle == true) then
            MageNugOptionsFrame_CheckButton8:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton8:SetChecked(1);
        end
        if (MageNugz.livingBombToggle == true) then
            MageNugOptionsFrame_CheckButton9:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton9:SetChecked(1);
        end
        if (MageNugz.ScorchToggle == true)then
            MageNugOptionsFrame_ScorchCheckButton:SetChecked(0);
        else
            MageNugOptionsFrame_ScorchCheckButton:SetChecked(1);
        end
        if (MageNugz.smallLBToggle == true) then
            MageNugOptionsFrame_SmallLBCheckButton:SetChecked(1);
        else
            MageNugOptionsFrame_SmallLBCheckButton:SetChecked(0);
        end
        if(MageNugz.abCastTimeToggle == nil) then
            MageNugz.abCastTimeToggle = true;
        end
        if(MageNugz.abCastTimeToggle == true) then
            MageNugOptionsFrame_ABcastCheckButton:SetChecked(1);
            MNabCast_Frame:Show();
        else
            MageNugOptionsFrame_ABcastCheckButton:SetChecked(0);
            MNabCast_Frame:Hide();
        end   
        if (MageNugz.arcaneBlastToggle == true) then
            MageNugOptionsFrame_CheckButton13:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton13:SetChecked(1);
        end
        if (MageNugz.polyToggle == true) then
            MageNugOptionsFrame_CheckButton14:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton14:SetChecked(1);
        end
        if (MageNugz.clearcastToggle == nil) then
            MageNugz.clearcastToggle = true;
        end
        if (MageNugz.clearcastToggle == true) then
            MageNugOptionsFrame_CheckButtonCC:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButtonCC:SetChecked(1);
        end   
        if (MageNugz.procMonitorToggle == nil) then
            MageNugz.procMonitorToggle = true;
        end
        if (MageNugz.procMonitorToggle == true) then
            MageNugOptionsFrame_CheckButton11:SetChecked(0);
        else
            MageNugOptionsFrame_CheckButton11:SetChecked(1);
        end
        if (MageNugz.ssMonitorSize == nil) then
            MageNugOptionsFrame_Slider2:SetValue(3)
        else
            MageNugOptionsFrame_Slider2:SetValue(MageNugz.ssMonitorSize)
        end
        if (MageNugz.livingBCounterSize == nil) then
            MageNugOptionsFrame_Slider3:SetValue(3)
        else
            MageNugOptionsFrame_Slider3:SetValue(MageNugz.livingBCounterSize)
        end
        if (MageNugz.procMonitorSize == nil) then
            MageNugOptionsFrame_Slider4:SetValue(3)
        else
            MageNugOptionsFrame_Slider4:SetValue(MageNugz.procMonitorSize)
        end  
        -----Messages Options----        
        MageNugMsgOptionFrame_Text1:SetText(L["Slowfall Notify Messages"])
        MageNugMsgOptionFrame_Text2:SetText(L["Focus Magic Notify Messages"])
        MageNugMsgOptionFrame_Text3:SetText(L["Focus Magic Thank You Messages"])
        MageNugMsgOptionFrame_Text4:SetText(L["Innervate Thank You Messages"])
        if (MageNugz.slowfallMsg == nil) then
            SlowFallMsgEditBox:SetText(L["Slowfall Cast On You"])
        else
            SlowFallMsgEditBox:SetText(MageNugz.slowfallMsg)
        end
        if (MageNugz.slowfallMsg2 == nil) then
            SlowFallMsgEditBox2:SetText(L["Slowfall Cast On You"])
        else
            SlowFallMsgEditBox2:SetText(MageNugz.slowfallMsg2)
        end
        if (MageNugz.slowfallMsg3 == nil) then
            SlowFallMsgEditBox3:SetText(L["Slowfall Cast On You"])
        else
            SlowFallMsgEditBox3:SetText(MageNugz.slowfallMsg3)
        end
        if (MageNugz.focusMagicNotify == nil) then
            FocMagNotifyEditBox:SetText(L["Focus Magic Cast On You"])
        else
          FocMagNotifyEditBox:SetText(MageNugz.focusMagicNotify)
        end
        if (MageNugz.focusMagicNotify2 == nil) then
            FocMagNotifyEditBox2:SetText(L["Focus Magic Cast On You"])
        else
           FocMagNotifyEditBox2:SetText(MageNugz.focusMagicNotify2)
        end
        if (MageNugz.focusMagicNotify3 == nil) then
            FocMagNotifyEditBox3:SetText(L["Focus Magic Cast On You"])
        else
           FocMagNotifyEditBox3:SetText(MageNugz.focusMagicNotify3)
        end
        if (MageNugz.focusMagicThanks == nil) then
            FocMagThankEditBox:SetText( L["Thanks For Focus Magic"])
        else
            FocMagThankEditBox:SetText(MageNugz.focusMagicThanks)
        end
        if (MageNugz.focusMagicThanks2 == nil) then
            FocMagThankEditBox2:SetText( L["Thanks For Focus Magic"])
        else
            FocMagThankEditBox2:SetText(MageNugz.focusMagicThanks2)
        end
        if (MageNugz.innervatThanks == nil) then
            InnervThankEditBox:SetText(L["Thanks For The Innervate"])
        else
            InnervThankEditBox:SetText(MageNugz.innervatThanks)
        end
        if (MageNugz.innervatThanks2 == nil) then
            InnervThankEditBox2:SetText(L["Thanks For The Innervate"])
        else
            InnervThankEditBox2:SetText(MageNugz.innervatThanks2)
        end
        ------Message 2 Options----
        MageNugMsg2OptionFrame_Text1:SetText(L["Power Infusion Thank You"])
        if (MageNugz.powerinfThanks == nil) then
            MageNugMsg2OptionFrame_PowerInfusionEditBox:SetText(L["Thanks For Power Infusion"])
        else
            MageNugMsg2OptionFrame_PowerInfusionEditBox:SetText(MageNugz.powerinfThanks)
        end
        ------Monitor Options------       
        MNcheckbox1FontString:SetText(L["Disable Stat Monitor"])
        MNcheckbox2FontString:SetText(L["Disable Buff Monitors"])
        MageNugStatMonOptionFrame_SPSliderFontString:SetText(L["SP and Crit % Monitor Size"])
        MageNugStatMonOptionFrame_BorderSliderFontString:SetText(L["Border Type"])
        MageNugStatMonOptionFrame_TransSliderFontString:SetText(L["Background Transparency"])
        MageNugStatMonOptionFrame_ColorSliderFontString:SetText(L["Backdrop Color"])
        if (MageNugz.spMonitorToggle == true) then
            MageNugSP_Frame:Show();
            MageNugStatMonOptionFrame_CheckButton1:SetChecked(0);
        else
           MageNugSP_Frame:Hide();
           MageNugStatMonOptionFrame_CheckButton1:SetChecked(1);
        end
        if (MageNugz.buffmonToggle == nil) then
            MageNugz.buffmonToggle = true;
        end
        if (MageNugz.buffmonToggle == true) then
            MageNugStatMonOptionFrame_CheckButton2:SetChecked(0);
        else
            MageNugStatMonOptionFrame_CheckButton2:SetChecked(1);
        end
        if (MageNugz.spMonitorSize == nil) then
            MageNugStatMonOptionFrame_SPSizeSlider:SetValue(3)
        else
            MageNugStatMonOptionFrame_SPSizeSlider:SetValue(MageNugz.spMonitorSize)
        end
        if(MageNugz.borderStyle == nil) then
            MageNugStatMonOptionFrame_BorderSlider:SetValue(0);
        else
            MageNugStatMonOptionFrame_BorderSlider:SetValue(MageNugz.borderStyle);
        end
        if(MageNugz.transColor == nil) then
            MageNugStatMonOptionFrame_TransparencySlider:SetValue(0);
        else
            MageNugStatMonOptionFrame_TransparencySlider:SetValue(MageNugz.transColor);
        end
        --------Options 2--------
        MNcheckboxMiniMapFontString:SetText(L["Disable Minimap Button"])
        MNcheckboxCameraFontString:SetText(L["Disable Maximum Camera Zoom Out"])
        MNcheckboxConsoleTextFontString:SetText(L["Disable Console Text"])
        MNcheckboxLockFramesFontString:SetText(L["Lock Frames"])
        MNcheckboxTTFontString:SetText(L["Tool Tips"])
        MNcheckboxClickThruFontString:SetText(L["Enable Frame Click Through"])
        MNpolyFrameSizeFontString:SetText(L["Polymorph Monitor Size"])
        if (MageNugz.MinimapPos == nil) then
            MageNugz.MinimapPos = 45;
        end
        if (MageNugz.camZoomTogg == true) then
            ConsoleExec("cameraDistanceMax 50");
            MageNugOption2Frame_CameraCheckButton:SetChecked(0);
        else
            MageNugOption2Frame_CameraCheckButton:SetChecked(1);
        end
        if (MageNugz.lockFrames == nil) then
            MageNugz.lockFrames = false;
        end
        if (MageNugz.lockFrames == true) then
            MageNugOption2Frame_LockFramesCheckButton:SetChecked(1);
        else
            MageNugOption2Frame_LockFramesCheckButton:SetChecked(0);
        end
        if (MageNugz.consoleTextEnabled == nil) then
            MageNugz.consoleTextEnabled = true;
        end
        if (MageNugz.consoleTextEnabled == true) then
            MageNugOption2Frame_ConsoleTextCheckButton:SetChecked(0);
        else
            MageNugOption2Frame_ConsoleTextCheckButton:SetChecked(1);
        end
        if (MageNugz.toolTips == nil) then
            MageNugz.toolTips = true;
        end
        if (MageNugz.toolTips == true) then
            MageNugOption2Frame_CheckButtonTT:SetChecked(1);
        else
            MageNugOption2Frame_CheckButtonTT:SetChecked(0);
        end
        if (MageNugz.clickthru == true) then
            MageNugOption2Frame_ClickThruCheckButton:SetChecked(1);
        else
            MageNugOption2Frame_ClickThruCheckButton:SetChecked(0);
        end
        if (MageNugz.polyFrameSize == nil) then
            MageNugOption2Frame_Slider1:SetValue(3)
        else
            MageNugOption2Frame_Slider1:SetValue(MageNugz.polyFrameSize)
        end
        -------Sounds Options-------
        if (MageNugz.miSound == nil) then
            MageNugSoundOptionFrame_MISoundEditBox:SetText("mirror.mp3")
        else
            MageNugSoundOptionFrame_MISoundEditBox:SetText(MageNugz.miSound)
        end
        if (MageNugz.procSound == nil) then
            MageNugSoundOptionFrame_ProcSoundEditBox:SetText("proc.mp3")
        else
            MageNugSoundOptionFrame_ProcSoundEditBox:SetText(MageNugz.procSound)
        end
        if (MageNugz.miSoundToggle == true) then
            MageNugSoundOptionFrame_MICheckButton:SetChecked(1);
        else
            MageNugSoundOptionFrame_MICheckButton:SetChecked(0);
        end
        if (MageNugz.procSoundToggle == true) then
            MageNugSoundOptionFrame_ProcCheckButton:SetChecked(1);
        else
            MageNugSoundOptionFrame_ProcCheckButton:SetChecked(0);
        end
        MageNugPolyFrame:Hide();
        MageNugImpactProcFrame:Hide();
        MageNugBFProcFrame:Hide();
        MageNugProcFrame:Hide();
        MageNugMBProcFrame:Hide();
        MageNugFoFProcFrame:Hide(); 
        MageNugAB_Frame:Hide();
        MageNugScorch_Frame:Hide();
        missileBarId, _, _, _, _, _, _, _, _ = GetSpellInfo(44401);
        hotStreakId, _, _, _, _, _, _, _, _ = GetSpellInfo(48108);
        brainFreezeId, _, _, _, _, _, _, _, _ = GetSpellInfo(57761);
        fingersFrostId, _, _, _, _, _, _, _, _ = GetSpellInfo(44544);
        ablastId, _, _, _, _, _, _, _, _ = GetSpellInfo(36032);
        frostboltId, _, _, _, _, _, _, _, _ = GetSpellInfo(42842);
        frostfireId, _, _, _, _, _, _, _, _ = GetSpellInfo(47610);
        conecoldId, _, _, _, _, _, _, _, _ = GetSpellInfo(42931);
        blastwaveId, _, _, _, _, _, _, _, _ = GetSpellInfo(42945);
        judgementjustId, _, _, _, _, _, _, _, _ = GetSpellInfo(53696);
        infectedwoundsId, _, _, _, _, _, _, _, _ = GetSpellInfo(48485);
        thunderclapId, _, _, _, _, _, _, _, _ = GetSpellInfo(47502);
        deadlythrowId, _, _, _, _, _, _, _, _ = GetSpellInfo(48674);
        frostshockId, _, _, _, _, _, _, _, _ = GetSpellInfo(49236);
        chilledId, _, _, _, _, _, _, _, _ = GetSpellInfo(7321); 
        mindflayId, _, _, _, _, _, _, _, _ = GetSpellInfo(48156);
        impactId, _, _, _, _, _, _, _, _ = GetSpellInfo(64343);
        MageNugz_MinimapButton_Move()
end

function MageNuggetsOptions() --Options Frame
    local MageNugOptions = CreateFrame("FRAME", "MageNugOptions", InterfaceOptionsFrame)
    MageNugOptions.name = "Mage Nuggets"
    InterfaceOptions_AddCategory(MageNugOptions)
    MageNugOptions:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)
    
    local statmonOptions = CreateFrame("FRAME", "statmonOptions");
    statmonOptions.name = "Stat Monitor";
    statmonOptions.parent = "Mage Nuggets";
    InterfaceOptions_AddCategory(statmonOptions); 
    statmonOptions:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)

    local msgOptions = CreateFrame("FRAME", "msgOptions");
    msgOptions.name = "Messages";
    msgOptions.parent = "Mage Nuggets";
    InterfaceOptions_AddCategory(msgOptions); 
    msgOptions:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)

    local msg2Options = CreateFrame("FRAME", "msg2Options");
    msg2Options.name = "Messages 2";
    msg2Options.parent = "Mage Nuggets";
    InterfaceOptions_AddCategory(msg2Options); 
    msg2Options:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)
    
    local soundOptions = CreateFrame("FRAME", "soundOptions");
    soundOptions.name = "Sounds";
    soundOptions.parent = "Mage Nuggets";
    InterfaceOptions_AddCategory(soundOptions); 
    soundOptions:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)
    
    local mnOptions = CreateFrame("FRAME", "mnOptions");
    mnOptions.name = "Options";
    mnOptions.parent = "Mage Nuggets";
    InterfaceOptions_AddCategory(mnOptions); 
    mnOptions:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)

end

function hideMonitorToggle() --Sp and Crit Monitor Toggle
    local monitorChecked = MageNugStatMonOptionFrame_CheckButton1:GetChecked();
    if (monitorChecked == 1) then
	    MageNugSP_Frame:Hide();
        MageNugz.spMonitorToggle = false;
    else
        MageNugSP_Frame:Show();
        MageNugz.spMonitorToggle = true;
    end
end

function MNMinimapButtonToggle()
    local mini = MageNugOption2Frame_MinimapCheckButton:GetChecked();
    if (mini == 1) then
        MageNugz.minimapToggle = false; 
        MageNug_MinimapFrame:Hide();
    else
        MageNugz.minimapToggle = true; 
        MageNug_MinimapFrame:Show();
    end
end

function HideSSMonitorToggle() -- Spellsteal Monitor Toggle
    local stealMonitorChecked = MageNugOptionsFrame_CheckButton2:GetChecked();
    if (stealMonitorChecked == 1) then
	    MageNugz.ssMonitorToggle = false; 
    else
        MageNugz.ssMonitorToggle = true;
    end
end

function MageProcNoteToggle() -- Mage Proc Notification Toggle
    local cNotifyChecked = MageNugOptionsFrame_CheckButton3:GetChecked();
    if (cNotifyChecked == 1) then
	    MageNugz.mageProcToggle = false;
    else
        MageNugz.mageProcToggle = true;
    end
end

function cameraZoomToggle() -- Camera Zoom Out Toggle
    local camZoomChecked = MageNugOption2Frame_CameraCheckButton:GetChecked();
    if (camZoomChecked == 1) then
        ConsoleExec("cameraDistanceMax 15");
        MageNugz.camZoomTogg = false;
    else  
        ConsoleExec("cameraDistanceMax 50");
        MageNugz.camZoomTogg = true;
    end
end

function absorbNotifyToggle() -- Actual Shield Damage Notify Toggle
    local absorbChecked = MageNugOptionsFrame_CheckButton5:GetChecked();
    if (absorbChecked == 1) then
        MageNugz.absorbToggle = false;
    else  
        MageNugz.absorbToggle = true;
    end
end

function MirrorImageSoundToggle() -- Mirror Image Sound Toggle
    local miChecked = MageNugSoundOptionFrame_MICheckButton:GetChecked();
    if (miChecked == 1) then
        MageNugz.miSoundToggle = true;
    else  
        MageNugz.miSoundToggle = false;
    end
end

function ProcSoundToggle() -- Proc Sound Toggle
    local procChecked = MageNugSoundOptionFrame_ProcCheckButton:GetChecked();
    if (procChecked == 1) then
        MageNugz.procSoundToggle = true;
    else  
        MageNugz.procSoundToggle = false;
    end
end

function MirrorImagToggle() -- Mirror Image Timer Toggle
    local mirrorChecked = MageNugOptionsFrame_CheckButton6:GetChecked();
    if (mirrorChecked == 1) then
        MageNugz.mirrorImageToggle = false;
    else  
        MageNugz.mirrorImageToggle = true;
    end
end

function WaterEleToggle() -- Water Elemental Timer Toggle
    local waterChecked = MageNugOptionsFrame_CheckButton7:GetChecked();
    if (waterChecked == 1) then
        MageNugz.waterEleToggle = false;
    else  
        MageNugz.waterEleToggle = true;
    end
end

function EvoToggle() -- Evocation Toggle
    local evoChecked = MageNugOptionsFrame_CheckButton8:GetChecked();
    if (evoChecked == 1) then
        MageNugz.evocationToggle = false;
    else  
        MageNugz.evocationToggle = true;
    end
end

function LivingBToggle() -- Living Bomb Toggle
    local lbChecked = MageNugOptionsFrame_CheckButton9:GetChecked();
    if (lbChecked == 1) then
        MageNugz.livingBombToggle = false;
    else  
        MageNugz.livingBombToggle = true;
    end
end

function MNSmallLBToggle()
    local slbChecked = MageNugOptionsFrame_SmallLBCheckButton:GetChecked();
    if (slbChecked == 1) then
        MageNugz.smallLBToggle = true;
    else  
        MageNugz.smallLBToggle = false;
    end
end
function ScorchToggle() -- Scorch Toggle
    local sChecked = MageNugOptionsFrame_ScorchCheckButton:GetChecked();
    if (sChecked == 1) then
        MageNugz.ScorchToggle = false;
    else  
        MageNugz.ScorchToggle = true;
    end
end

function MNabCastTimeToggle() -- AB Cast Time Toggle
    local abcChecked = MageNugOptionsFrame_ABcastCheckButton:GetChecked();
    if (abcChecked == 1) then
        MageNugz.abCastTimeToggle = true;
        MNabCast_Frame:Show();
    else  
        MageNugz.abCastTimeToggle = false;
        MNabCast_Frame:Hide();
    end
end

function MageProcMonitorToggle()
    local mpChecked = MageNugOptionsFrame_CheckButton11:GetChecked();
    if (mpChecked == 1) then
        MageNugz.procMonitorToggle = false;
    else  
        MageNugz.procMonitorToggle = true;
    end
end

function MNArcaneBlastToggle()
    local abChecked = MageNugOptionsFrame_CheckButton13:GetChecked();
    if (abChecked == 1) then
        MageNugz.arcaneBlastToggle = false;
    else  
        MageNugz.arcaneBlastToggle = true;
    end
end

function MNpolyToggle()
    local polyChecked = MageNugOptionsFrame_CheckButton14:GetChecked();
    if (polyChecked == 1) then
        MageNugz.polyToggle = false;
    else  
        MageNugz.polyToggle = true;
    end
end

function BuffMonitorsToggle()
    local buffsChecked = MageNugStatMonOptionFrame_CheckButton2:GetChecked();
    if (buffsChecked == 1) then
	    MageNugz.buffmonToggle = false;
    else
        MageNugz.buffmonToggle = true;
    end
end

function MNclickThrough()
    local clickChecked = MageNugOption2Frame_ClickThruCheckButton:GetChecked();
    if (clickChecked == 1) then
        MageNugz.clickthru = true;
        MageNugSP_Frame:EnableMouse(false)
        MNTorment_Frame:EnableMouse(false)
        MNicyveins_Frame:EnableMouse(false)
        MNarcanepower_Frame:EnableMouse(false)
        MNlust_Frame:EnableMouse(false)
        MageNugClearcast_Frame:EnableMouse(false)
        MageNugSmallLB_Frame:EnableMouse(false)
        MageNugScorch_Frame:EnableMouse(false)
        MageNugAB_Frame:EnableMouse(false)
        MNabCast_Frame:EnableMouse(false)
        MageNugProcFrame:EnableMouse(false)
        MageNugPolyFrame:EnableMouse(false)
        MageNugImpactProcFrame:EnableMouse(false)
        MageNugBFProcFrame:EnableMouse(false)
        MageNugMBProcFrame:EnableMouse(false)
        MageNugFoFProcFrame:EnableMouse(false)
        MNSpellSteal_Frame:EnableMouse(false)
        MageNugMI_Frame:EnableMouse(false)
        MageNugWE_Frame:EnableMouse(false)
    else
        MageNugz.clickthru = false;
        MageNugSP_Frame:EnableMouse(true)
        MNTorment_Frame:EnableMouse(true)
        MNicyveins_Frame:EnableMouse(true)
        MNarcanepower_Frame:EnableMouse(true)
        MNlust_Frame:EnableMouse(true)
        MageNugClearcast_Frame:EnableMouse(true)
        MageNugSmallLB_Frame:EnableMouse(true)
        MageNugScorch_Frame:EnableMouse(true)
        MageNugAB_Frame:EnableMouse(true)
        MNabCast_Frame:EnableMouse(true)
        MageNugProcFrame:EnableMouse(true)
        MageNugPolyFrame:EnableMouse(true)
        MageNugImpactProcFrame:EnableMouse(true)
        MageNugBFProcFrame:EnableMouse(true)
        MageNugMBProcFrame:EnableMouse(true)
        MageNugFoFProcFrame:EnableMouse(true)
        MNSpellSteal_Frame:EnableMouse(true)
        MageNugMI_Frame:EnableMouse(true)
        MageNugWE_Frame:EnableMouse(true)
    end
end

function ShowConfigFrames() --Shows frames for 20 seconds
    if (MageNugz.ssMonitorToggle == true) then
        spellStealTog = 20;
        MNSpellSteal_Frame:Show();
    end
    mirrorImageTime = 20;
    MageNugMI_Frame:Show();
    livingbombTime = 20;
    if (MageNugz.smallLBToggle == true) then
        MageNugSmallLB_Frame:Show();
    else
        MageNugLBTemplate_Anchor:Show();
    end
    waterEleTime = 20;
    MageNugWE_Frame:Show();
    polyTimer = 20
    MageNugPolyFrameText:SetText("|cffFFFFFF"..L["Polymorph"])
    MageNugPolyFrame:Show();
    mageImpProgMonTime = 20;
    MageNugImpactProcFrameText:SetText("|cffFF0000"..L["IMPACT!"])
    MageNugImpactProcFrame:Show()
    mageProcBFTime = 20;
    MageNugBFProcFrameText:SetText("|cffFF3300"..L["BRAIN FREEZE!"])
    MageNugBFProcFrame:Show();
    mageProcHSTime = 20;
    MageNugProcFrameText:SetText("|cffFF0000"..L["HOT STREAK!"]);
    MageNugProcFrame:Show();
    mageProcMBTime = 20;
    misslebTog = 20;
    MageNugMBProcFrameText:SetText("|cffFF33FF"..L["MISSILE BARRAGE!"])
    MageNugMBProcFrame:Show();
    fofProgMonTime = 20;
    MageNugFoFProcFrameText:SetText("|cffFFFFFF"..L["Fingers Of Frost"])
    MageNugFoFProcFrame:Show(); 
    abProgMonTime = 20;
    MageNugAB_Frame:Show();
    scorchTime = 20;
    MageNugScorch_Frame:Show();
    clearcastTime = 20;
    MageNugClearcast_Frame:Show();
end

function LockFramesToggle()
    local flChecked = MageNugOption2Frame_LockFramesCheckButton:GetChecked();
    if (flChecked == 1) then
        MageNugz.lockFrames = true;
    else  
        MageNugz.lockFrames = false;
    end
end

function ConsoleTextToggle()
    local ctChecked = MageNugOption2Frame_ConsoleTextCheckButton:GetChecked();
    if (ctChecked == 1) then
        MageNugz.consoleTextEnabled = false;
    else
        MageNugz.consoleTextEnabled = true;
    end
end

function MNtoolTipToggle()
    local ttChecked = MageNugOption2Frame_CheckButtonTT:GetChecked();
    if (ttChecked == 1) then
        MageNugz.toolTips = true;
    else
        MageNugz.toolTips = false;
    end
end

function MNclearcastToggle()
    local ccChecked = MageNugOptionsFrame_CheckButtonCC:GetChecked();
    if (ccChecked == 1) then
        MageNugz.clearcastToggle = false;
    else
        MageNugz.clearcastToggle = true;
    end
end

function  MageNugSpMonitorSize() --Function for the SP Slider
    local tempInt = MageNugStatMonOptionFrame_SPSizeSlider:GetValue()
    if (tempInt == 0) then
        MageNugSP_Frame:SetScale(0.7);
        MageNugz.spMonitorSize = 0;
    end
    if (tempInt == 1) then
        MageNugSP_Frame:SetScale(0.8);
        MageNugz.spMonitorSize = 1;
    end
    if (tempInt == 2) then
        MageNugSP_Frame:SetScale(0.9);
        MageNugz.spMonitorSize = 2;
    end
    if (tempInt == 3) then
        MageNugSP_Frame:SetScale(1.0);
        MageNugz.spMonitorSize = 3;
    end
    if (tempInt == 4) then
        MageNugSP_Frame:SetScale(1.1);
        MageNugz.spMonitorSize = 4;
    end
    if (tempInt == 5) then
        MageNugSP_Frame:SetScale(1.2);
        MageNugz.spMonitorSize = 5;
    end
    if (tempInt == 6) then
        MageNugSP_Frame:SetScale(1.3);
        MageNugz.spMonitorSize = 6;
    end
end

function  MageNugSSMonitorSize() --Function for the SS Slider
    local tempInt = MageNugOptionsFrame_Slider2:GetValue()
    if (tempInt == 0) then
        MNSpellSteal_Frame:SetScale(0.7);
        MageNugz.ssMonitorSize = 0;
    end
    if (tempInt == 1) then
        MNSpellSteal_Frame:SetScale(0.8);
        MageNugz.ssMonitorSize = 1;
    end
    if (tempInt == 2) then
        MNSpellSteal_Frame:SetScale(0.9);
        MageNugz.ssMonitorSize = 2;
    end
    if (tempInt == 3) then
        MNSpellSteal_Frame:SetScale(1.0);
        MageNugz.ssMonitorSize = 3;
    end
    if (tempInt == 4) then
        MNSpellSteal_Frame:SetScale(1.1);
        MageNugz.ssMonitorSize = 4;
    end
    if (tempInt == 5) then
        MNSpellSteal_Frame:SetScale(1.2);
        MageNugz.ssMonitorSize = 5;
    end
    if (tempInt == 6) then
        MNSpellSteal_Frame:SetScale(1.3);
        MageNugz.ssMonitorSize = 6;
    end
end

function  MageNugProcMonitorSize() --Function for the SS Slider
    local tempInt = MageNugOptionsFrame_Slider4:GetValue()
    if (tempInt == 0) then
        MageNugProcFrame:SetScale(0.7);
        MageNugMBProcFrame:SetScale(0.7);
        MageNugFoFProcFrame:SetScale(0.7);
        MageNugBFProcFrame:SetScale(0.7);
        MageNugImpactProcFrame:SetScale(0.7);
        MageNugz.procMonitorSize = 0;
    end
    if (tempInt == 1) then
        MageNugProcFrame:SetScale(0.8);
        MageNugMBProcFrame:SetScale(0.8);
        MageNugFoFProcFrame:SetScale(0.8);
        MageNugBFProcFrame:SetScale(0.8);
        MageNugImpactProcFrame:SetScale(0.8);
        MageNugz.procMonitorSize = 1;
    end
    if (tempInt == 2) then
        MageNugProcFrame:SetScale(0.9);
        MageNugMBProcFrame:SetScale(0.9);
        MageNugFoFProcFrame:SetScale(0.9);
        MageNugBFProcFrame:SetScale(0.9);
        MageNugImpactProcFrame:SetScale(0.9);
        MageNugz.procMonitorSize = 2;
    end
    if (tempInt == 3) then
        MageNugProcFrame:SetScale(1.0);
        MageNugMBProcFrame:SetScale(1.0);
        MageNugFoFProcFrame:SetScale(1.0);
        MageNugBFProcFrame:SetScale(1.0);
        MageNugImpactProcFrame:SetScale(1.0);
        MageNugz.procMonitorSize = 3;
    end
    if (tempInt == 4) then
        MageNugProcFrame:SetScale(1.1);
        MageNugMBProcFrame:SetScale(1.1);
        MageNugFoFProcFrame:SetScale(1.1);
        MageNugBFProcFrame:SetScale(1.1);
        MageNugImpactProcFrame:SetScale(1.1);
        MageNugz.procMonitorSize = 4;
    end
    if (tempInt == 5) then
        MageNugProcFrame:SetScale(1.2);
        MageNugMBProcFrame:SetScale(1.2);
        MageNugFoFProcFrame:SetScale(1.2);
        MageNugBFProcFrame:SetScale(1.2);
        MageNugImpactProcFrame:SetScale(1.2);
        MageNugz.procMonitorSize = 5;
    end
    if (tempInt == 6) then
        MageNugProcFrame:SetScale(1.3);
        MageNugMBProcFrame:SetScale(1.3);
        MageNugFoFProcFrame:SetScale(1.3);
        MageNugBFProcFrame:SetScale(1.3);
        MageNugImpactProcFrame:SetScale(1.3);
        MageNugz.procMonitorSize = 6;
    end
end

function MageNugPolyFrameSize()
     local tempInt = MageNugOption2Frame_Slider1:GetValue()
    if (tempInt == 0) then
        MageNugPolyFrame:SetScale(0.7);
        MageNugz.polyFrameSize = 0;
    end
    if (tempInt == 1) then
        MageNugPolyFrame:SetScale(0.8);
        MageNugz.polyFrameSize = 1;
    end
    if (tempInt == 2) then
        MageNugPolyFrame:SetScale(0.9);
        MageNugz.polyFrameSize = 2;
    end
    if (tempInt == 3) then
        MageNugPolyFrame:SetScale(1.0);
        MageNugz.polyFrameSize = 3;
    end
    if (tempInt == 4) then
        MageNugPolyFrame:SetScale(1.2);
        MageNugz.polyFrameSize = 4;
    end
    if (tempInt == 5) then
        MageNugPolyFrame:SetScale(1.4);
        MageNugz.polyFrameSize = 5;
    end
    if (tempInt == 6) then
        MageNugPolyFrame:SetScale(1.6);
        MageNugz.polyFrameSize = 6;
    end
end

function MageNugLivingBombSize() 
 local tempInt = MageNugOptionsFrame_Slider3:GetValue()
    if (tempInt == 0) then
        MageNugLBTemplate_Anchor:SetScale(0.7);
        MageNugAB_Frame:SetScale(0.7);
        MageNugScorch_Frame:SetScale(0.7);
        MageNugSmallLB_Frame:SetScale(0.7);
        MageNugClearcast_Frame:SetScale(0.7);
        MageNugz.livingBCounterSize = 0;
    end
    if (tempInt == 1) then
        MageNugLBTemplate_Anchor:SetScale(0.8);
        MageNugAB_Frame:SetScale(0.8);
        MageNugScorch_Frame:SetScale(0.8);
        MageNugSmallLB_Frame:SetScale(0.8);
        MageNugClearcast_Frame:SetScale(0.8);
        MageNugz.livingBCounterSize = 1;
    end
    if (tempInt == 2) then
        MageNugLBTemplate_Anchor:SetScale(0.9);
        MageNugAB_Frame:SetScale(0.9);
        MageNugScorch_Frame:SetScale(0.9);
        MageNugSmallLB_Frame:SetScale(0.9);
        MageNugClearcast_Frame:SetScale(0.9);
        MageNugz.livingBCounterSize = 2;
    end
    if (tempInt == 3) then
        MageNugLBTemplate_Anchor:SetScale(1.0);
        MageNugAB_Frame:SetScale(1.0);
        MageNugScorch_Frame:SetScale(1.0);
        MageNugSmallLB_Frame:SetScale(1.0);
        MageNugClearcast_Frame:SetScale(1.0);
        MageNugz.livingBCounterSize = 3;
    end
    if (tempInt == 4) then
        MageNugLBTemplate_Anchor:SetScale(1.1);
        MageNugAB_Frame:SetScale(1.1);
        MageNugScorch_Frame:SetScale(1.1);
        MageNugSmallLB_Frame:SetScale(1.1);
        MageNugClearcast_Frame:SetScale(1.1);
        MageNugz.livingBCounterSize = 4;
    end
    if (tempInt == 5) then
        MageNugLBTemplate_Anchor:SetScale(1.2);
        MageNugAB_Frame:SetScale(1.2);
        MageNugScorch_Frame:SetScale(1.2);
        MageNugSmallLB_Frame:SetScale(1.2);
        MageNugClearcast_Frame:SetScale(1.2);
        MageNugz.livingBCounterSize = 5;
    end
    if (tempInt == 6) then
        MageNugLBTemplate_Anchor:SetScale(1.3);
        MageNugAB_Frame:SetScale(1.3);
        MageNugScorch_Frame:SetScale(1.3);
        MageNugSmallLB_Frame:SetScale(1.3);
        MageNugClearcast_Frame:SetScale(1.3);
        MageNugz.livingBCounterSize = 6;
    end
end

function Tab2_OnEnter()
  GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
  GameTooltip:SetText("|cff00BFFF"..L["Mage"].." |cff00CD00"..L["Nuggets"]..":|cffFFFFFF"..L["Messages are picked at random."].." \n"..L["To disable a message leave all of its boxes blank."])
  GameTooltip:Show()
end

function Monitors_OnEnter()
  if (MageNugz.toolTips == true) then
    GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
    GameTooltip:SetText("|cff00BFFF"..L["Mage"].." |cff00CD00"..L["Nuggets"]..":|cffFFFFFF "..L["You can disable or resize this"].." \n"..L["monitor in options."])
    GameTooltip:Show()
    end
end

function SPMonitor_OnEnter()
    if (MageNugz.toolTips == true) then
        GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
        GameTooltip:SetText("|cff00BFFF"..L["Mage"].." |cff00CD00"..L["Nuggets"]..":|cffFFFFFF "..L["You can customize or disable this"].." \n"..L["monitor in options."])
        GameTooltip:Show()
    end
end

function CombatText_OnEnter()
  GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
  GameTooltip:SetText("|cff00BFFF"..L["Mage"].." |cff00CD00"..L["Nuggets"]..":|cffFFFFFF "..L["Checking this will disable all notifications sent to"].." \n"..L["the chat console. This includes shield absorb, polymorph, evocation,"].." \n"..L["spellsteal notifications and all other chat console notifications."])
  GameTooltip:Show()
end

function MageProc_OnEnter()
    GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
    GameTooltip:SetText("|cff00BFFF"..L["Mage"].." |cff00CD00"..L["Nuggets"]..":|cffFFFFFF "..L["The in game combat text must be turned on"].." \n"..L["for mage proc combat text to function."])
    GameTooltip:Show()
end

function MNLockFrames()
    if (MageNugz.lockFrames == false)then
       this:StartMoving(); this.isMoving = true;
    end
end

function BorderTypeSlider()
    local tempInt = MageNugStatMonOptionFrame_BorderSlider:GetValue()
    if (tempInt == 0) then
         MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                    tile = true, tileSize = 16, edgeSize = 16, 
                                    insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 0;
    end
    if (tempInt == 1) then
         MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                    tile = true, tileSize = 16, edgeSize = 8, 
                                    insets = { left = 1, right = 1, top = 1, bottom = 1 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 1;
    end
    if (tempInt == 2) then
        MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                                    tile = true, tileSize = 16, edgeSize = 16, 
                                    insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 2;
    end
    if (tempInt == 3) then
        MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                                    tile = true, tileSize = 16, edgeSize = 8, 
                                    insets = { left = 1, right = 1, top = 1, bottom = 1 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 3;
    end
    if (tempInt == 4) then
        MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                    edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",
                                    tile = true, tileSize = 16, edgeSize = 16, 
                                    insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 4;
    end
    if (tempInt == 5) then
        MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                    edgeFile = "Interface/DialogFrame/UI-DialogBox-Gold-Border",
                                    tile = true, tileSize = 16, edgeSize = 8, 
                                    insets = { left = 1, right = 1, top = 1, bottom = 1 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 5;
    end
    if (tempInt == 6) then
        MageNugSP_Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                    tile = true, tileSize = 16, edgeSize = 16, 
                                    insets = { left = 4, right = 4, top = 4, bottom = 4 }});
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.borderStyle = 6;
    end
end

function BackdropTransparencySlider()
    local tempInt = MageNugStatMonOptionFrame_TransparencySlider:GetValue()
    if (tempInt == 0) then
        MageNugz.backdropA = 1.0;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 0;
    end
    if (tempInt == 1) then
        MageNugz.backdropA = 0.85;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 1;
    end
    if (tempInt == 2) then
        MageNugz.backdropA = 0.7;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 2;
    end
    if (tempInt == 3) then
        MageNugz.backdropA = 0.55;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 3;
    end
    if (tempInt == 4) then
        MageNugz.backdropA = 0.4;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 4;
    end
    if (tempInt == 5) then
        MageNugz.backdropA = 0.25;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 5;
    end
    if (tempInt == 6) then
        MageNugz.backdropA = 0.0;
        MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
        MageNugz.transColor = 6;
    end
end

function MNSetBackdropBlack()
    MageNugz.backdropR = 0.0;
    MageNugz.backdropG = 0.0;
    MageNugz.backdropB = 0.0;
    MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA)
end

function MNColorSelector()
    MageNugz.backdropR, MageNugz.backdropG, MageNugz.backdropB = MageNugStatMonOptionFrameColorSelect:GetColorRGB();
    MageNugSP_Frame:SetBackdropColor(MageNugz.backdropR,MageNugz.backdropG,MageNugz.backdropB,MageNugz.backdropA);
end

function MageNugz_MinimapButton_Move()
	MageNug_MinimapFrame:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(MageNugz.MinimapPos)),(80*sin(MageNugz.MinimapPos))-52)
end

function MageNugz_MinimapButton_DraggingFrame_OnUpdate()
	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()
	xpos = xmin-xpos/UIParent:GetScale()+70 
    ypos = ypos/UIParent:GetScale()-ymin-70
	MageNugz.MinimapPos = math.deg(math.atan2(ypos,xpos))
    MageNugz_MinimapButton_Move()
end

function MageNuggets_Minimap_OnClick() 
    local englishFaction, localizedFaction = UnitFactionGroup("player")
    if (englishFaction == "Horde")then
        MageNugHordeFrame:Show();
    end
    if (englishFaction == "Alliance") then
        MageNugAlliFrame:Show();
    end   
end

-----------------------------------------------------------------
local firstLBtimer, lastLBtimer
local LBtimer = {}
local popOrCreateFrame, pushFrame
    do
	local id = 1
	local frameStack
	function popOrCreateFrame()
		local frame
		if frameStack then 
			frame = frameStack
			frameStack = frameStack.next
			frame:Show()
		else
			frame = CreateFrame("StatusBar", "LivingBombBars"..id, MageNugLBTemplate_Anchor, "MageNugLBTemplate")
            id = id + 1
		end
		return frame
	end
	function pushFrame(frame)
		frame.obj = nil
		frame.next = frameStack
		frameStack = frame
	end
end
local mt = {__index = LBtimer}
--
function LBmonitor(LBtimer, target)
	local frame = popOrCreateFrame()
	_G[frame:GetName().."Text"]:SetText(target)
	local obj = setmetatable({
		frame = frame,
		totalTime = LBtimer,
		LBtimer = LBtimer
	}, mt)
	frame.obj = obj
	if firstLBtimer == nil then
		firstLBtimer = obj
		lastLBtimer = obj
	else
		obj.prev = lastLBtimer
		lastLBtimer.next = obj
		lastLBtimer = obj
	end
	obj:SetPosition()
	obj:Update(0)
	return obj 
end
--
function LBtimer:SetPosition()
	self.frame:ClearAllPoints()
	if self == firstLBtimer then
		self.frame:SetPoint("CENTER", MageNugLBTemplate_Anchor, "CENTER")
	else
		self.frame:SetPoint("TOP", self.prev.frame, "BOTTOM", 0, -3)
	end
end
--
function LBtimer:Update(elapsed)
	self.LBtimer = self.LBtimer - elapsed;
    if (self.LBtimer <= 0) then
	    self:Cancel()
    else
	    local currentBarPos = self.LBtimer / self.totalTime
	    self.frame:SetValue(currentBarPos)
	    _G[self.frame:GetName().."Timer"]:SetText(RoundOne(self.LBtimer))
	    _G[self.frame:GetName().."Spark"]:SetPoint("CENTER", self.frame, "LEFT", self.frame:GetWidth() * currentBarPos, -1)
	end
end
--
local MNlb_UpdateInterval = 0.1;
function MageNuggetsLB_OnUpdate(self, elapsed) 
 self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate > MNlb_UpdateInterval) then   
        livingbombTime = RoundOne(livingbombTime - 0.1);
        if (livingbombTime <= 0) then
            livingBombCount = 0;
            MageNugLBTemplate_Anchor:Hide();
        end
    self.TimeSinceLastUpdate = 0;
    end   
end
--
function LBtimer:Cancel()
	if (self == firstLBtimer) then
		firstLBtimer = self.next
	else
		self.prev.next = self.next
	end
	if (self == lastLBtimer) then
		lastLBtimer = self.prev
	else
		self.next.prev = self.prev
	end
	if (self.next) then
		self.next:SetPosition()
	end
	self.frame:Hide()
	pushFrame(self.frame)
end