local E, L, V, P, G = unpack(ElvUI);
local UF = E:GetModule('UnitFrames');
local ABM = E:GetModule('AuraMover')

function ABM:GetOptions()
E.Options.args.unitframe.args.player.args.aurabar.args.detach = {
	order = 25,
	type = "toggle",
	name = '|cff30ee30'..L['Detach From Frame']..'|r',
	get = function(info) return E.db.abm.player end,
	set = function(info, value) E.db.abm.player = value; UF:CreateAndUpdateUF('player'); ABM:MoverToggle() end,
}

E.Options.args.unitframe.args.player.args.aurabar.args.width = {
	order = 26,
	type = "range",
	name = '|cff30ee30'..L['Width']..'|r',
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.abm.playerw end,
	set = function(info, value) E.db.abm.playerw = value; UF:CreateAndUpdateUF('player') end,
}

E.Options.args.unitframe.args.player.args.aurabar.args.space = {
	order = 27,
	type = "range",
	name = '|cff30ee30'..L["Vertical Spacing"]..'|r',
	min = -10, max = 20, step = 1,
	get = function(info) return E.db.abm.playerSpace end,
	set = function(info, value) E.db.abm.playerSpace = value; UF:CreateAndUpdateUF('player') end,
}

E.Options.args.unitframe.args.target.args.aurabar.args.detach = {
	order = 25,
	type = "toggle",
	name = '|cff30ee30'..L['Detach From Frame']..'|r',
	get = function(info) return E.db.abm.target end,
	set = function(info, value) E.db.abm.target = value; UF:CreateAndUpdateUF('target'); ABM:MoverToggle() end,
}

E.Options.args.unitframe.args.target.args.aurabar.args.width = {
	order = 26,
	type = "range",
	name = '|cff30ee30'..L['Width']..'|r',
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.abm.targetw end,
	set = function(info, value) E.db.abm.targetw = value; UF:CreateAndUpdateUF('target') end,
}

E.Options.args.unitframe.args.target.args.aurabar.args.space = {
	order = 27,
	type = "range",
	name = '|cff30ee30'..L["Vertical Spacing"]..'|r',
	min = -10, max = 20, step = 1,
	get = function(info) return E.db.abm.targetSpace end,
	set = function(info, value) E.db.abm.targetSpace = value; UF:CreateAndUpdateUF('target') end,
}

E.Options.args.unitframe.args.focus.args.aurabar.args.detach = {
	order = 25,
	type = "toggle",
	name = '|cff30ee30'..L['Detach From Frame']..'|r',
	get = function(info) return E.db.abm.focus end,
	set = function(info, value) E.db.abm.focus = value; UF:CreateAndUpdateUF('focus'); ABM:MoverToggle() end,
}

E.Options.args.unitframe.args.focus.args.aurabar.args.width = {
	order = 26,
	type = "range",
	name = '|cff30ee30'..L['Width']..'|r',
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.abm.focusw end,
	set = function(info, value) E.db.abm.focusw = value; UF:CreateAndUpdateUF('focus') end,
}

E.Options.args.unitframe.args.focus.args.aurabar.args.space = {
	order = 27,
	type = "range",
	name = '|cff30ee30'..L["Vertical Spacing"]..'|r',
	min = -10, max = 20, step = 1,
	get = function(info) return E.db.abm.focusSpace end,
	set = function(info, value) E.db.abm.focusSpace = value; UF:CreateAndUpdateUF('focus') end,
}

E.Options.args.unitframe.args.pet.args.aurabar.args.detach = {
	order = 25,
	type = "toggle",
	name = '|cff30ee30'..L['Detach From Frame']..'|r',
	get = function(info) return E.db.abm.pet end,
	set = function(info, value) E.db.abm.pet = value; UF:CreateAndUpdateUF('pet'); ABM:MoverToggle() end,
}

E.Options.args.unitframe.args.pet.args.aurabar.args.width = {
	order = 26,
	type = "range",
	name = '|cff30ee30'..L['Width']..'|r',
	min = 50, max = 500, step = 1,
	get = function(info) return E.db.abm.petw end,
	set = function(info, value) E.db.abm.petw = value; UF:CreateAndUpdateUF('pet') end,
}

E.Options.args.unitframe.args.pet.args.aurabar.args.space = {
	order = 27,
	type = "range",
	name = '|cff30ee30'..L["Vertical Spacing"]..'|r',
	min = -10, max = 20, step = 1,
	get = function(info) return E.db.abm.petSpace end,
	set = function(info, value) E.db.abm.petSpace = value; UF:CreateAndUpdateUF('pet') end,
}
end
