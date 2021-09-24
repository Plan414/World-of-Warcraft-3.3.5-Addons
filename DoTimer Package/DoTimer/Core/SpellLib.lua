AsheylaLib:Package( "SpellLib" );
SpellLib = {}
local module = AsheylaLib:NewModule("SpellLibInternal")
local SpellSystemScanningFrame = CreateFrame("GameTooltip", "SpellSystemScanningFrame", nil, "GameTooltipTemplate");
local GetSpellName, GetSpellTexture, BOOKTYPE_SPELL, BOOKTYPE_PET, GetContainerNumSlots, GetItemInfo, GetContainerItemInfo, 
    GetItemSpell, GetContainerItemLink, GetInventoryItemLink, GetInventoryItemTexture, GetActionTexture, GetActionInfo = 
    GetSpellName, GetSpellTexture, BOOKTYPE_SPELL, BOOKTYPE_PET, GetContainerNumSlots, GetItemInfo, GetContainerItemInfo, 
    GetItemSpell, GetContainerItemLink, GetInventoryItemLink, GetInventoryItemTexture, GetActionTexture, GetActionInfo;

function SpellLib:GetSpellInfo(i,book,side,index)
    SpellSystemScanningFrame:SetOwner(UIParent,"ANCHOR_NONE")
    SpellSystemScanningFrame:SetSpell(i,book)
    if side == "max" then return SpellSystemScanningFrame:NumLines() end
    side = (string.lower(side) == "left" and "Left") or (string.lower(side) == "right" and "Right") or nil
    if not side then return end
    index = (type(index) == "number" and index or SpellSystemScanningFrame:NumLines())
    local frame = getglobal("SpellSystemScanningFrameText"..side..index)
    if frame then
        return getglobal("SpellSystemScanningFrameText"..side..index):GetText() or ""
    else
        return ""
    end
end

function SpellLib:ReturnPetID(query)
    local i = 1
    local name = GetSpellName(i,BOOKTYPE_PET)
    while name do
        if name == query then 
            return i
        end
        i = i + 1
        name = GetSpellName(i,BOOKTYPE_PET)
    end
    return 1
end

function SpellLib:GetItemID(link)
    return string.match(link,"item:(%d+)")
end

function SpellLib:FindSpellInfo(query,queryrank,type)
    if type then
        if type == "spell" then
            local i = 1
            local name,rank = GetSpellName(i,BOOKTYPE_SPELL)
            while name do
                if name == query and (not queryrank or queryrank == "" or queryrank == rank) then 
                    local texture = GetSpellTexture(i,BOOKTYPE_SPELL)
                    return texture,BOOKTYPE_SPELL,i
                end
                i = i + 1
                name,rank = GetSpellName(i,BOOKTYPE_SPELL)
            end
            i = 1
            name,rank = GetSpellName(i,BOOKTYPE_PET)
            while name do
                if name == query then 
                    local texture = GetSpellTexture(i,BOOKTYPE_PET)
                    return texture,BOOKTYPE_PET,i
                end
                i = i + 1
                name,rank = GetSpellName(i,BOOKTYPE_PET)
            end
        elseif type == "item" then
            for b = 0,4 do
                for s = 1,GetContainerNumSlots(b) do
                    local name = GetItemInfo(GetContainerItemLink(b,s) or "") or ""
                    if name == query then
                        local texture = GetContainerItemInfo(b,s)
                        local itemid = SpellLib.GetItemID(module,GetContainerItemLink(b,s))
                        return texture,"item",itemid, false, name;
                    end
                    local spellName = GetItemSpell(GetContainerItemLink(b,s) or "") or ""
                    if spellName == query then
                        local texture = GetContainerItemInfo(b,s)
                        local itemid = SpellLib.GetItemID(module,GetContainerItemLink(b,s))
                        return texture,"item",itemid, false, name;
                    end
                end
            end
            for i = 1,19 do
                local name = GetItemInfo(GetInventoryItemLink("player",i) or "") or ""
                if name == query then
                    local texture = GetInventoryItemTexture("player",i)
                    local itemid = SpellLib.GetItemID(module,GetInventoryItemLink("player",i))
                    return texture,"item",itemid, true, name;
                end
                local spellName = GetItemSpell(GetInventoryItemLink("player",i) or "") or ""
                if spellName == query then
                    local texture = GetInventoryItemTexture("player",i)
                    local itemid = SpellLib.GetItemID(module,GetInventoryItemLink("player",i))
                    return texture,"item",itemid, true, name;
                end
            end
        elseif string.sub(type,1,6) == "action" then
            local action = string.sub(type,7)
            local texture = GetActionTexture(action)
            local stype,id = GetActionInfo(action)
            if stype == "item" then castingspell.spell.item = GetItemInfo(id) end
            return texture,stype,id
        end
    end
end

function SpellLib:ReturnItemLink(itemid)
    local _,itemlink = GetItemInfo(itemid)
    return itemlink
end

function SpellLib:ReturnRank(spell) --called if the spell did not have a rank from CastSpellByName, returns highest rank
    local highrank
    local i = 1
    while GetSpellName(i,BOOKTYPE_SPELL) do
        local spellname,spellrank = GetSpellName(i,BOOKTYPE_SPELL)
        if spellname == spell then highrank = spellrank end
        i = i + 1
    end
    if highrank == nil then highrank = "" end
    return highrank
end

