-- Options
local showItemLevelAndId = false;
local showSpellIdAndRank = true;

-- Tables
local TipTypeFuncs = {};
local criteriaList = {};

-- Returns colored text string
local function BoolCol(bool)
	return (bool and "|cff80ff80" or "|cffff8080");
end

--------------------------------------------------------------------------------------------------------
--                                            Create Extras                                           --
--------------------------------------------------------------------------------------------------------

local tipIcon = ItemRefTooltip:CreateTexture(nil,"BACKGROUND");
tipIcon:SetPoint("TOPRIGHT",ItemRefTooltip,"TOPLEFT",0,-2.5);
tipIcon:SetWidth(42);
tipIcon:SetHeight(42);
tipIcon:Hide();

local tipCount = ItemRefTooltip:CreateFontString(nil,"ARTWORK","NumberFontNormal");
tipCount:SetPoint("BOTTOMRIGHT",tipIcon,"BOTTOMRIGHT",-3,3);
tipCount:SetJustifyH("RIGHT");

--------------------------------------------------------------------------------------------------------
--                                         Tip Type Functions                                         --
--------------------------------------------------------------------------------------------------------

-- item
function TipTypeFuncs.item(tip,refString,id)
	local itemLevel, _, _, _, itemStackCount, _, itemTexture = select(4,GetItemInfo(id));
	tipCount:SetText(itemStackCount and itemStackCount > 1 and (itemStackCount == 0x7FFFFFFF and "#" or itemStackCount) or "");
	tipIcon:SetTexture(itemTexture);
	tipIcon:Show();
	if (showItemLevelAndId) then
		tip:AddLine("Item Level: "..itemLevel..", Item ID: "..id,0.2,0.6,1);
		tip:Show();
	end
end

-- spell
function TipTypeFuncs.spell(tip,refString,id)
	local name, rank, icon = GetSpellInfo(id);
	tipCount:SetText("");
	tipIcon:SetTexture(icon);
	tipIcon:Show();
	if (showSpellIdAndRank) then
		tip:AddLine("Spell ID: "..id..(rank and rank ~= "" and ", "..rank or ""),0.2,0.6,1);
		tip:Show();
	end
end

-- achievement
function TipTypeFuncs.achievement(tip,refString,id)
	local guid = refString:match("achievement:[^:]+:([^:]+)");
	local isPlayer = (UnitGUID("player"):sub(3) == guid);
	-- Get category
	local catId = GetAchievementCategory(id);
	local category, catParent = GetCategoryInfo(catId);
	local catName;
	while (catParent > 0) do
		catName, catParent = GetCategoryInfo(catParent);
		category = catName.." - "..category;
	end
	-- Get Criteria
	wipe(criteriaList);
	local criteriaComplete = 0;
	local left, right, leftText, rightText;
	for i = 6, tip:NumLines() do
		left = _G[tip:GetName().."TextLeft"..i];
		right = _G[tip:GetName().."TextRight"..i];
		leftText = left:GetText();
		rightText = right:GetText();
		if (leftText and leftText ~= " ") then
			criteriaList[#criteriaList + 1] = { label = leftText, done = left:GetTextColor() < 0.5 };
			if (criteriaList[#criteriaList].done) then
				criteriaComplete = (criteriaComplete + 1);
			end
		end
		if (rightText and rightText ~= " ") then
			criteriaList[#criteriaList + 1] = { label = rightText, done = right:GetTextColor() < 0.5 };
			if (criteriaList[#criteriaList].done) then
				criteriaComplete = (criteriaComplete + 1);
			end
		end
	end
	-- Cache Info
	local complete = _G[tip:GetName().."TextLeft3"]:GetText();
	local title, points, _, _, _, _, description, _, icon, reward = select(2,GetAchievementInfo(id));
	-- Icon
	if (tip == ItemRefTooltip) then
		tipCount:SetText(points);
		tipIcon:SetTexture(icon);
		tipIcon:Show();
	end
	-- Rebuild Tip
	tip:ClearLines();
	local stat = isPlayer and GetStatistic(id);
	tip:AddDoubleLine(title,(stat ~= "0" and stat ~= "--" and stat),nil,nil,nil,1,1,1);
	tip:AddLine("<"..category..">");
	if (reward) then
		tip:AddLine(reward,0.2,0.6,1);
	end
	tip:AddLine(description,1,1,1,1);
	tip:AddLine(BoolCol(complete:match("earned"))..complete);
	if (#criteriaList > 0) then
		tip:AddLine(" ");
		tip:AddLine("Achievement Criteria |cffffffff"..criteriaComplete.."|r of |cffffffff"..#criteriaList);
		local r1, g1, b1, r2, g2, b2;
		local myDone1, myDone2;
		for i = 1, #criteriaList, 2 do
			r1, g1, b1 = (criteriaList[i].done and 0.25 or 0.5), (criteriaList[i].done and 0.75 or 0.5), (criteriaList[i].done and 0.25 or 0.5);
			if (criteriaList[i + 1]) then
				r2, g2, b2 = (criteriaList[i + 1].done and 0.25 or 0.5), (criteriaList[i + 1].done and 0.75 or 0.5), (criteriaList[i + 1].done and 0.25 or 0.5);
			end
			if (not isPlayer) then
				myDone1 = select(3,GetAchievementCriteriaInfo(id,i));
				myDone2 = select(3,GetAchievementCriteriaInfo(id,i + 1));
			end
			tip:AddDoubleLine((isPlayer and "" or BoolCol(myDone1).."*|r")..criteriaList[i].label,criteriaList[i + 1] and criteriaList[i + 1].label..(isPlayer and "" or BoolCol(myDone2).."*"),r1,g1,b1,r2,g2,b2);
		end
	end
	tip:Show();
end

--------------------------------------------------------------------------------------------------------
--                                         HOOK: SetHyperlink                                         --
--------------------------------------------------------------------------------------------------------

-- HOOK: ItemRefTooltip + GameTooltip: SetHyperlink
local function SetHyperlink_Hook(self,refString)
	local type, id = refString:match("|?H?(%a+):([^:]+)");
	-- Check ID
	if (not id) or (type ~= "achievement" and self ~= ItemRefTooltip) then
		if (self == ItemRefTooltip) then
			tipIcon:Hide();
			tipCount:SetText("");
		end
	-- Call Tip Type Func
	elseif (TipTypeFuncs[type]) and (self:NumLines() > 0) then
		TipTypeFuncs[type](self,refString,id);
	-- Other types not supported, hide icon
	elseif (self == ItemRefTooltip) then
		tipIcon:Hide();
		tipCount:SetText("");
	end
end

hooksecurefunc(GameTooltip,"SetHyperlink",SetHyperlink_Hook);
hooksecurefunc(ItemRefTooltip,"SetHyperlink",SetHyperlink_Hook);