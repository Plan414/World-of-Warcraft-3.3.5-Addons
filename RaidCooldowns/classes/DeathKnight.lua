assert(RaidCooldowns, "RaidCooldowns not found!")
if (select(2, UnitClass("player"))) ~= "DEATHKNIGHT" then return end

local mod = RaidCooldowns:NewModule("DeathKnight", RaidCooldowns.ModuleBase, "AceConsole-3.0", "AceEvent-3.0")
mod.cooldowns = RaidCooldowns.cooldowns["DEATHKNIGHT"]