--[[    
    SpamMeNot: Detects and blocks commercial spam
    Copyright (C) 2008 Robert Stiles (robs@codexsoftware.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local L = LibStub("AceLocale-3.0"):NewLocale("SpamMeNot", "frFR", true)

if L then
	-- L["Version %s (r %s)"] = true

end

-- These words should all be lowercase.  They are lua string matching patterns.  Do not set
-- the weight of any word too highly or you will get a lot of false positives.

-- This is used for specific annoying trade spam
-- if an excessive amount of these are spotted then SpamMeNot will start laying down the law
-- It will also look for excessive non-trade skill links.
SpamMeNot.tradeWords["frFR"] = {
	["anal"] = 30,
	["oral"] = 30,
	["dirge"] = 30,
}

-- This is used for the generic gold spam detection
SpamMeNot.words["frFR"] = {	
	["5uneed"] = 50,
	["gold4guild"] = 50,
	["peons"] = 50,
	["peonz"] = 50,
	["fcwow"] = 50,
	["4hire"] = 30,
	["p4hire"] = 50,
	["happy"] = 40,
	["worker"] = 25,
	["wow%-europe%.cn"] = 80,	
	["epicinn"] = 50,
	["working"] = 20,		
	["delivery"] = 30,
	["deliveries"] = 30,
	["power"] = 20,		
	["level"] = 20,
	["lvl"] = 20,
	["mmo"] = 15,
	["pwr"] = 20,
	["store"] = 20,							
	["gold"] = 30,
	["get%s*gold"] = 10,
	["currency"] = 30,
	["account"] = 30,
	["%d+g"] = 10,
	["profession"] = 30,
	["buy"] = 20,
	["purchase"] = 20,
	["sell"] = 20,
	["payment"] = 20,
	["dollar"] = 30,		
	["pound"] = 30,
	["euro"] = 30,	
	["€"] = 30,
	["%d+%s*eur"] = 30,
	["%d+%s*pound"] = 30,
	["%d+%s*usd"] = 30,
	["%d+%s*gbp"] = 30,
	["$$"] = 30,
	["$%d+"] = 30,
	["£"] = 30,
	["offer"] = 15,
	["free"] = 15,
	["order"] = 15,		
	["fast"] = 15,	
	["cheap"] = 15,				
	["price"] = 10,
	["low"] = 10,
	["courtious"] = 15,				
	["safe"] = 15,
	["special"] = 15,
	["service"] = 30,
	["p&l"] = 50,
	["days"] = 10,
	["discount"] = 20,
	["code"] = 10,
	["www"] = 25,
	["%.com"] = 25,
	["%,com"] = 25,
	[" com"] = 10,
	["dot%s*com"] = 25,
	["dot%s*cn"] = 75,
	["%.cn"] = 75,
	["%,cn"] = 75,	
	["banned"] = 15,
	["hi"] = 5,
	["web"] = 20,
	["site"] = 20,
	["welcome%s*to"] = 30,	
	["wellcome%s*to"] = 15,
	["wellcome"] = 15,
	["we"] = 5,
	["best"] = 15,
	["choice"] = 15,
	["mount"] = 15,
	["promotion"] = 15,
	["wow%-toolbox"] = 50,
	["hack"] = 40,
	["undetectable"] = 20,
	["download"] = 30,
	["health"] = 10,
	["mana"] = 10,
	["solo"] = 10,
	["instance"] = 10,
	["elite"] = 10,
	["mob"] = 5,
	["%?"] = 5,
	["guarantee"] = 15,
	[">>>"] = 12,
	["<<<"] = 12,
	["==="] = 10,	
	["server"] = 10,
	["65%s*%-%s*70"] = 15,
	["60%s*%-%s*70"] = 15,
	["1%s*%-%s*60"] = 15,
	["24%s*/*%s*7"] = 15,
	["level%s*%d+%s*account"] = 40,
	["stat%s*changer"] = 50,
	["live%s*chat"] = 30,
	["dude,%syou%ssuck,%sstop%sbeing%sa%sn00b."] = 100,
	["sell.*account"] = 50,	
	["%d%s*customers"] = 15,
	["bonus"] = 10,
	["with%s*in%s*%d"] = 10,
	["e%-shop"] = 50,
	["c{circle}m"] = 25,
	["c@m"] = 25,
	["buyeugold"] = 50,
	["byeugold"] = 50,
	["goldcat"] = 50,
	["m%s*4"] = 15,
	["pvpbank"] = 50,		
}
