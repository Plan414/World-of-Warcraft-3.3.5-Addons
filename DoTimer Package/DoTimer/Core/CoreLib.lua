local pairs = pairs;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local tremove = table.remove;
local tinsert = table.insert;
local type = type;
local tonumber = tonumber;
local gmatch = string.gmatch;
local ipairs = ipairs;
local floor = math.floor;
local tostring = tostring;

AsheylaLib:Package( "core" );

-- returns a copy of the table passed to it
function copyTable(oldtable, suppress, tabledata)
    tabledata = tabledata or {};
    local newtable = {};
    
    if (not tabledata[oldtable]) then
        tabledata[oldtable] = newtable;
    end
    
    for index,value in pairs(oldtable) do
        if (type(index) == "table") then
            if (tabledata[index]) then
                index = tabledata[index]
            else
                index = copyTable(index, suppress, tabledata);
            end
        end
        
        if (type(value) == "table") then
            if (tabledata[value]) then
                newtable[index] = tabledata[value]
            else
                newtable[index] = copyTable(value, suppress, tabledata);
            end
        else
            newtable[index] = value;
        end
    end
    
    if (not suppress) then
        local meta = getmetatable(oldtable);
        if (meta) then 
            setmetatable(newtable, meta);
        end
    end
    
    return newtable;
end

-- this next bit of code deals with creating temporary tables.  it recycles them!
local tablepool = {}
local currenttables = {}

-- acquire a table
function acquireTable(auto)
    local t = tremove(tablepool,1) or {}
    return t
end

-- release multiple tables at a time
function releaseTable(...)
    for i = 1,select("#",...) do
        local t = select(i, ...);
        if (type(t) == "table") then
            wipe(t);
            setmetatable(t, nil);
            tinsert(tablepool, t);
        end
    end
end

local ttnmatches = {
    ["s"] = 1,
    ["m"] = 60,
    ["h"] = 3600,
    ["d"] = 86400,
}
function textToNum(text)
    local total = tonumber(text) or 0;
    for num, letter in gmatch(text, "([%d%.]+)([smhd])") do
        total = total + (num * ttnmatches[letter]);
    end
    return total;
end

local nttmatches = {
    {len = 86400,letter = "d"},
    {len = 3600,letter = "h"},
    {len = 60,letter = "m"},
    {len = 1,letter = "s"},
}
function numToText(num)
    if num == 0 then return "0s"; end
    local text = "";
    for _, info in ipairs(nttmatches) do
        local n = info.len > 1 and floor(num / info.len) or num;
        if n > 0 then
            text = text .. n .. info.letter .. " ";
            num = num - (n * info.len);
        end
    end
    return text;
end


local alphabetizedFunc = function(t, last)
    last = tostring(last);
    local nextVal, val;
    for i, v in pairs(t) do
        i = tostring(i);
        if i:lower() > last:lower() then
            if nextVal then
                if i:lower() < nextVal:lower() then
                    nextVal = i;
                    val = v;
                end
            else
                nextVal = i;
                val = v;
            end
        end
    end
    return nextVal, val;
end

function alphabetize( t )
    return alphabetizedFunc, t, "";
end

local media = nil;
function sharedMedia()
    if media == nil then
        media = LibStub and LibStub("LibSharedMedia-3.0", true) or false;
    end
    return media;
end

StaticPopupDialogs["AsheylaLib"] = {
    text = "%s",
    button1 = "Ok",
    whileDead = 1,
    hideOnEscape = 1,
    timeout = 30,
}

function alertUser(text)
    StaticPopup_Show("AsheylaLib", text)
end

stateMeta = {
    __index = function(t, k)
        return t.state[k];
    end,
    
    __newindex = function(t, k, v)
        t.state[k] = v;
    end,
}

