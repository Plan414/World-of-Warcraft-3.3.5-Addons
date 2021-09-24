local E, L, V, P, G = unpack(ElvUI)
if not E.private["unitframe"].enable or not E.private["CustomTweaks"] or not E.private["CustomTweaks"]["UnitFrameSpacingLimits"] then return end;

local CT = E:GetModule("CustomTweaks")

local function ConfigTable()
	E.Options.args.unitframe.args.party.args.generalGroup.args.positionsGroup.args.verticalSpacing.max = 200
	E.Options.args.unitframe.args.party.args.generalGroup.args.positionsGroup.args.horizontalSpacing.max = 200
	E.Options.args.unitframe.args.raid.args.generalGroup.args.positionsGroup.args.verticalSpacing.max = 200
	E.Options.args.unitframe.args.raid.args.generalGroup.args.positionsGroup.args.horizontalSpacing.max = 200
	E.Options.args.unitframe.args.raid40.args.generalGroup.args.positionsGroup.args.verticalSpacing.max = 200
	E.Options.args.unitframe.args.raid40.args.generalGroup.args.positionsGroup.args.horizontalSpacing.max = 200
end
CT.Configs["UnitFrameSpacingLimits"] = ConfigTable