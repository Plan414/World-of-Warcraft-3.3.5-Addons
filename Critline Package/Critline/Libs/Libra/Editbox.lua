local Libra = LibStub("Libra")
local Type, Version = "Editbox", 3
if Libra:GetModuleVersion(Type) >= Version then return end

local function constructor(self, parent, isSearchBox)
	local editbox = CreateFrame("EditBox", nil, parent, isSearchBox and "SearchBoxTemplate" or "InputBoxTemplate")
	editbox:SetHeight(20)
	editbox:SetAutoFocus(false)
	return editbox
end

Libra:RegisterModule(Type, Version, constructor)