local tCLFix = 0
 
local function fCLFix(self,elapsed)
    tCLFix = tCLFix + elapsed
    if tCLFix >= 2 then --time (in seconds) it takes before it executes the command on line 6
		CombatLogClearEntries()
        tCLFix = 0 --resets the timer
    end
end

local f = CreateFrame("frame")
f:SetScript("OnUpdate", fCLFix)