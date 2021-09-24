local E, L, V, P, G = unpack(ElvUI)
if not E.private["general"]["minimap"].enable or not E.private["CustomTweaks"] or not E.private["CustomTweaks"]["MinimapSizeLimits"] then return end;

local CT = E:GetModule("CustomTweaks")

local function ConfigTable()
	E.Options.args.maps.args.minimap.args.generalGroup.args.size.min = 40
end
CT.Configs["MinimapSizeLimits"] = ConfigTable