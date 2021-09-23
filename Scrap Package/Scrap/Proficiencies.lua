local _, Class = UnitClass('player')
local Unusable

if Class == 'DEATHKNIGHT' then
	Unusable = {'Shields', 'Librams', 'Idols', 'Totems', 'Bows', 'Guns', 'Staves', 'Fist Weapons', 'Daggers', 'Thrown', 'Crossbows', 'Wands'}
elseif Class == 'DRUID' then
	Unusable = {'Mail', 'Plate', 'Shields', 'Librams', 'Totems', 'Sigils', 'One-Handed Axes','Two-Handed Axes',
	'Bows', 'Guns', 'One-Handed Swords', 'Two-Handed Swords', 'Thrown', 'Crossbows', 'Wands', 'Off Hand'}
elseif Class == 'HUNTER' then
	Unusable = {'Plate', 'Shields', 'Librams', 'Idols', 'Totems', 'Sigils', 'One-Handed Maces', 'Two-Handed Maces', 'Wands'}
elseif Class == 'MAGE' then
	Unusable = {'Leather', 'Mail', 'Plate', 'Shields', 'Librams', 'Idols', 'Totems', 'Sigils', 'One-Handed Axes', 'Two-Handed Axes', 'Bows',
	'Guns', 'One-Handed Maces', 'Two-Handed Maces', 'Polearms', 'Two-Handed Swords', 'Fist Weapons', 'Thrown', 'Crossbows', 'Off Hand'}	
elseif Class == 'PALADIN' then
	Unusable = {'Idols', 'Totems', 'Sigils', 'Bows', 'Guns', 'Staves', 'Fist Weapons', 'Daggers', 'Thrown', 'Crossbows', 'Wands', 'Off Hand'}
elseif Class == 'PRIEST' then
	Unusable = {'Leather', 'Mail', 'Plate', 'Shields', 'Librams', 'Idols', 'Totems', 'Sigils', 'One-Handed Axes', 'Two-Handed Axes', 'Bows',
	'Guns', 'Two-Handed Maces', 'Polearms', 'One-Handed Swords', 'Two-Handed Swords', 'Fist Weapons', 'Thrown', 'Crossbows', 'Off Hand'}
elseif Class == 'ROGUE' then
	Unusable = {'Mail', 'Plate', 'Shields', 'Librams', 'Idols', 'Totems', 'Sigils', 'Two-Handed Axes',
	'Two-Handed Maces', 'Polearms', 'Two-Handed Swords', 'Staves', 'Wands'}
elseif Class == 'SHAMAN' then
	Unusable = {'Plate', 'Librams', 'Idols', 'Sigils', 'Bows', 'Guns', 'Polearms', 'One-Handed Swords',
	'Two-Handed Swords', 'Thrown', 'Crossbows', 'Wands'}
elseif Class == 'WARLOCK' then
	Unusable = {'Leather', 'Mail', 'Plate', 'Shields', 'Librams', 'Idols', 'Totems', 'Sigils', 'One-Handed Axes', 'Two-Handed Axes', 'Bows',
	'Guns', 'One-Handed Maces', 'Two-Handed Maces', 'Polearms', 'Two-Handed Swords', 'Fist Weapons', 'Thrown', 'Crossbows', 'Off Hand'}
elseif Class == 'WARRIOR' then
	Unusable = {'Librams', 'Idols', 'Totems', 'Sigils', 'Wands'}
end

for i,k in ipairs(Unusable) do
	Unusable[k] = true
	Unusable[i] = nil
end

Scrap_Unusable = Unusable