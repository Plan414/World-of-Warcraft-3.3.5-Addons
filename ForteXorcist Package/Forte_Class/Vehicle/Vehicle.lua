--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local FW = FW;
local ST = FW:Module("Timer");
local CA = FW:Module("Casting");
local CD = FW:Module("Cooldown");
	
if ST then
	local F = ST.F;
	-- doesnt use the casting code, but who cares!!
	ST:SetDefaultHasted(0)
	
	-- Wyrmrest Skytalon
	:AddSpell(57090, 000,"Heal",	F.HOT):SetTickSpeed(1):SetStacks(5) -- revivify
	:AddSpell(56092, 000,"Default",	F.TICKS):SetStacks(5) -- engulf
	:AddSpell(57143, 000,"Buff",	F.BUFF) -- life burst
	:AddSpell(57108, 000,"Buff",	F.BUFF) -- flame shield
	:AddSpell(57092, 000,"Pet") -- blazing speed
	
	-- Ulduar
	:AddSpell(62489, 000,"Default"):SetTickSpeed(1):SetStacks(5) -- Blue Pyrite

	-- Amber Drake (The Oculus)
	:AddSpell(49836, 000,"Default") -- Shock Charge

	-- Emerald Drake (The Oculus)
	:AddSpell(50341, 000,"Default") -- Touch the Nightmare
	--:AddSpell(50328, 000,"Default",	F.TICKS):SetTickSpeed(2) -- Leeching Poison ROGUE HAS THIS ABILITY TOO
end
