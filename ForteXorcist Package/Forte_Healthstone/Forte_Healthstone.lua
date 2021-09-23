--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local FW = FW;
local FWL = FW.L;
local HS = FW:Module("Healthstone");

local NUM_HS = 6;
local hs = FW:NEW2D();
local _G = _G;
local unpack = unpack;
local ipairs = ipairs;
local pairs = pairs;
local tonumber = tonumber;
local type = type;
local strformat = string.format;
local STATES = FW.STATES;

local HealthstoneShow = nil;
local function HS_HealthstoneShow(self,auto)
	FW:InitFrameVars(FWHSFrame);
	if not auto then HealthstoneShow = 1;end
	if FW.Settings.HealthstoneEnable and (not FW.Settings.HealthstoneAuto or STATES.GROUPED) then
	
		if HealthstoneShow or not FWHSFrame:IsShown() then
		
			FWHSBackground:ClearAllPoints();
			if not FW.STATES.INCOMBAT then
				HealthstoneShow = nil;
				FWHSFrame:Show();
				FWHSBackground:Show();

				FWHSFrame:SetWidth(FW.Settings.HealthstoneWidth+2*FW.BORDER);
				FWHSFrame:SetScale(FW.Settings.FWHSFrame.scale);
				
				FWHSBackground:SetWidth(FW.Settings.HealthstoneWidth+2*FW.BORDER);
				FWHSBackground:SetScale(FW.Settings.FWHSFrame.scale);
				
				FWHSFrame:SetFrameStrata(FW.Settings.HealthstoneStrata);
				FWHSBackground:SetFrameStrata(FW.Settings.HealthstoneStrata);
			
				FW:CorrectPosition(FWHSFrame);
			end
			FWHSFrame:SetAlpha(FW.Settings.FWHSFrame.alpha);
			FWHSBackground:SetAlpha(FW.Settings.FWHSFrame.alpha);
			

			FWHSBackground:SetBackdropColor(unpack(FW.Settings.HealthstoneBgColor));
			FWHSBackground:SetBackdropBorderColor(unpack(FW.Settings.HealthstoneBgColor));

			FWHSFrameAmount1:SetFont(unpack(FW.Settings.HealthstoneFont));
			FWHSFrameAmount2:SetFont(unpack(FW.Settings.HealthstoneFont));
			
			local r,g,b = unpack(FW.Settings.HealthstoneTextColor);
			for i=1,NUM_HS,1 do
				_G["FWHSBar"..i]:ClearAllPoints();
				
				_G["FWHSBar"..i.."Name"]:SetFont(unpack(FW.Settings.HealthstoneFont));
				_G["FWHSBar"..i.."Amount"]:SetFont(unpack(FW.Settings.HealthstoneFont));
				
				_G["FWHSBar"..i]:SetWidth(FW.Settings.HealthstoneWidth);
				_G["FWHSBar"..i]:SetHeight(FW.Settings.HealthstoneHeight);
				_G["FWHSBar"..i]:SetStatusBarTexture(FW.Settings.HealthstoneTexture);
				_G["FWHSBar"..i.."Back"]:SetTexture(FW.Settings.HealthstoneTexture);
				_G["FWHSBar"..i.."Name"]:SetTextColor(r,g,b);
				_G["FWHSBar"..i.."Amount"]:SetTextColor(r,g,b);

				_G["FWHSBar"..i.."Spark"]:SetWidth(FW.Settings.HealthstoneHeight);
				_G["FWHSBar"..i.."Spark"]:SetHeight(FW.Settings.HealthstoneHeight*2);
				
				if FW.Settings.GlobalSpark[0] then
					_G["FWHSBar"..i.."Spark"]:SetAlpha(FW.Settings.GlobalSpark[1]);
					_G["FWHSBar"..i.."Spark"]:Show();
				else
					_G["FWHSBar"..i.."Spark"]:Hide();
				end
			end
			
			if FW.Settings.HealthstoneExpand then
				FWHSBackground:SetPoint("BOTTOMRIGHT", FWHSFrame, "BOTTOMRIGHT", 0, 0);
				FWHSBar1:SetPoint("BOTTOMLEFT", FWHSBackground, "BOTTOMLEFT", FW.BORDER, 18);

				for i=2,NUM_HS,1 do
					_G["FWHSBar"..i]:SetPoint("BOTTOMLEFT", _G["FWHSBar"..(i-1)], "TOPLEFT", 0, FW.Settings.HealthstoneSpace);
				end
			else
				FWHSBackground:SetPoint("TOPLEFT", FWHSFrame, "TOPLEFT", 0, 0);
				FWHSBar1:SetPoint("TOPLEFT", FWHSBackground, "TOPLEFT", FW.BORDER, -18);

				for i=2,NUM_HS,1 do
					_G["FWHSBar"..i]:SetPoint("TOPLEFT", _G["FWHSBar"..(i-1)], "BOTTOMLEFT", 0, -FW.Settings.HealthstoneSpace);
				end
			end
		end
	else 
		if (HealthstoneShow or FWHSFrame:IsShown()) and not FW.STATES.INCOMBAT then
			HealthstoneShow = nil;
			FWHSFrame:Hide();
			FWHSBackground:Hide();
		end
	end
end

local function ColorVal(v,n)
	if n == 1 then
		return FW:MixColors(v,FW.Settings.HealthstoneMinColor,FW.Settings.HealthstoneMaxColor);
	else
		return FW:MixColors(v,FW.Settings.HealthstoneUnknownMinColor,FW.Settings.HealthstoneUnknownMaxColor);
	end
end

local function HS_DrawHealthstone()
	if not FWHSFrame:IsShown() then return; end
	local n=0;
	local Bar;
	for i=1, NUM_HS, 1 do
		Bar = _G["FWHSBar"..i];
		if FW.Settings.HealthstoneDetails and (not FW.Settings.HealthstoneDetailsAuto or STATES.GROUPED) and i <= hs.rows then
			local t1,t2,t3,t4 = unpack(hs[i]);
			if t2 == 0 then
				t2 = 1;
			end
			Bar.title = t3;
			Bar.tip = t4;
			local val = t1/t2;
			local r,g,b = ColorVal(val,i);
			Bar:SetStatusBarColor(r,g,b);
			_G["FWHSBar"..i.."Back"]:SetVertexColor(r,g,b,0.5);
			_G["FWHSBar"..i.."Name"]:SetText(t3);
			_G["FWHSBar"..i.."Amount"]:SetText(t1);
			Bar:SetValue(val);
			_G["FWHSBar"..i.."Spark"]:SetPoint("CENTER", Bar, "LEFT", val*Bar:GetWidth(), 0);
			
			if FW.Settings.GlobalSpark[0] then
				r,g,b = FW:FixIntensity(r,g,b);
				_G["FWHSBar"..i.."Spark"]:SetVertexColor(r,g,b);
			end
			
			n=n+1;
			Bar:Show();
		else
			Bar:Hide();
		end
	end
	if n>0 then
		FWHSBackground:SetHeight(21+(FW.Settings.HealthstoneHeight+FW.Settings.HealthstoneSpace)*n-FW.Settings.HealthstoneSpace);
	else
		FWHSBackground:SetHeight(20);
	end
end

local function HS_SetHSButton()
	local t1 = FW:BestHealthstone();
	local t2 = FW:GotHealthstone();

	FWHSFrameAmount1:SetText("x"..t2);	
	if not FW.STATES.INCOMBAT then -- update the use function in case it wasnt loaded properly due to combat or whatever
		FWHSButton:SetAttribute("*item2", t1 );
	end
	if t2 > 0 and FWHSButton:GetAttribute("*","item","2") then -- also check if the attribute is set already
		FWHSButton.title=strformat(FWL.USE_,t1);
		FWHSButton.tip=strformat(FWL.RIGHT_CLICK_TO_USE_,t1);
		FWHSButton:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\HS2");
	else
		FWHSButton.title=strformat(FWL.CREATE_,t1);
		FWHSButton.tip=strformat(FWL.LEFT_CLICK_TO_CREATE_,t1);
		FWHSButton:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\HS3");
	end

end

local erase = FW.ERASE;
local function HS_ProcessHealthstone()
	if FWHSFrame:IsShown() then
		hs:erase();
		
		local unknown = 0
		local active = 0;
		local stones = 0;
		local missing = 0;
		
		local str_missing = "";
		--local str_stones = "";
		local str_unknown = "";
		
		for name, data in pairs(FW.Saved.RaidStatus) do
			if data[1] >= FW.FLAG.NORMAL then 
				if data[4] and type(data[4])=="string" then -- only count people that are online and have fx
					active = active + 1;
					local hs = FW.Saved.Healthstone[name];
					if hs and hs > 0 then
						stones = stones + 1;
						--str_stones = str_stones.."\n"..name;
					else
						missing = missing + 1;
						str_missing = str_missing.."\n"..name;
					end
				else
					unknown = unknown + 1;
					str_unknown = str_unknown.."\n"..name;
				end
			end
		end
		if str_missing == "" then
			str_missing = "\n"..FWL.NOBODY;
		end
		hs:insert(stones,active,FWL.TOTAL,strformat(FWL.MISSING_,str_missing));
		if unknown > 0 and FW.Settings.HealthstoneUnknown then
			hs:insert(unknown,active+unknown,FWL.NO_INFO,strformat(FWL.UNKNOWN_,str_unknown));
		end
		FWHSFrameAmount2:SetText("x"..active-stones);
		HS_DrawHealthstone();
		HS_SetHSButton();
	end
end

local function HS_HealthstoneReceived(id,who)
	--FW:Show("hs "..id.." x"..n.." from "..who);
	FW.Saved.Healthstone[who] = id;
end

--globally accessable

function FW:HSFrame_OnClick(button)
	if FW:Moved() then return; end
	
	if button == "LeftButton" then
		if FW.Settings.HealthstoneDetails then
			if FW.Settings.HealthstoneUnknown then
				FW.Settings.HealthstoneDetails = false;
			else
				FW.Settings.HealthstoneUnknown = true;
			end
		
		else
			FW.Settings.HealthstoneDetails = true;
			FW.Settings.HealthstoneUnknown = false;
		end
		HS_DrawHealthstone();
		FW:RefreshOptionsNoStyle();
	else
		FW:ScrollTo(FWL.HEALTHSTONE_SPY);
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function FW:HealthstoneCheck() -- clicked from ui (and time-based)
	FW:SendData(FW.GET_HEALTHSTONE);
end

function FW:HealthstoneOnload()
	-- includes a quick 2.00 fix!
	FWHSFrame.Update = HS_HealthstoneShow;
	FW:RegisterFrame("FWHSFrame",FWHSFrame,1);

	FW:RegisterButtonPress("HS_CREATEHEALTHSTONE","FWHSButton","LeftButton");
	FW:RegisterButtonPress("HS_USEHEALTHSTONE","FWHSButton","RightButton");
	FW:RegisterButtonPress("HS_GETUPDATE","FWSWButton","LeftButton");
	FW:RegisterButtonPress("HS_CREATESOULWELL","FWSWButton","RightButton");
	FW:RegisterButtonPress("HS_OPTIONS","FWHSFrame","RightButton");
	
	FW:RegisterVariablesEvent(function()
		FW:RegisterTimedEvent("HealthstoneInterval",	HS_ProcessHealthstone);
		FW:RegisterTimedEvent("HealthstoneInterval",	function() FWHSFrame:Update(1); end);
	end);
	
	FW:RegisterOnEnterCombat(HS_SetHSButton); -- Hopefully set correct spell just before the buttons are locked if loading up in combat, if it failed during loading the button somehow

	FW:RegisterEnterPartyRaid( function(joined) if joined then FW:HealthstoneCheck();end end );
	
	FW:RegisterMessage(FW.SEND_HEALTHSTONE,
		function(m,f) 
			local _,_,t1 = string.find(m,"^(%d+)$");
			t1=tonumber(t1);
			if t1 then
				HS_HealthstoneReceived(t1,f);
				return 1;
			end
		end,
	nil);
end

FW:SetMainCategory(FWL.HEALTHSTONE_SPY,FW.ICON.HS,7,"HEALTHSTONE","FWHSFrame");
	FW:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1);
		FW:AddOption("INF",FWL.COMBAT_HINT);
		FW:AddOption("INF",FWL.ORA_HINT);
		
	FW:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND);
		FW:AddOption("CHK",FWL.ENABLE,		FWL.HS_ENABLE_TT,	"HealthstoneEnable"):SetFunc(HS_HealthstoneShow);
		FW:AddOption("CHK",FWL.AUTO_HIDE,	FWL.AUTO_HIDE_TT,	"HealthstoneAuto"):SetFunc(HS_HealthstoneShow);
		FW:AddOption("CHK",FWL.AUTO_MINIMIZE,	FWL.AUTO_MINIMIZE_TT,	"HealthstoneDetailsAuto");
		FW:AddOption("CHK",FWL.SHOW_BARS,	FWL.SHOW_BARS_TT,	"HealthstoneDetails");
		FW:AddOption("CHK",FWL.EXPAND_UP,	FWL.EXPAND_UP_TT,	"HealthstoneExpand"):SetFunc(HS_HealthstoneShow);
		
	FW:SetSubCategory(FWL.SPECIFIC,FW.ICON.SPECIFIC,3);	
		FW:AddOption("CHK","Show players with no info","","HealthstoneUnknown");

	FW:SetSubCategory(FWL.SIZING,FW.ICON.SIZE,4);	
		FW:AddOption("NUM",FWL.BAR_WIDTH,			"",	"HealthstoneWidth"):SetRange(0):SetFunc(HS_HealthstoneShow);
		FW:AddOption("NUM",FWL.BAR_HEIGHT,			"",	"HealthstoneHeight"):SetRange(0):SetFunc(HS_HealthstoneShow);
		FW:AddOption("NUM",FWL.BAR_SPACING,			"",	"HealthstoneSpace"):SetRange(0):SetFunc(HS_HealthstoneShow);
		
	FW:SetSubCategory(FWL.BAR_COLORING,FW.ICON.FILTER,5);	
		FW:AddOption("COL",FWL.LITTLE_HS,			"",	"HealthstoneMinColor");
		FW:AddOption("COL",FWL.MANY_HS,				"",	"HealthstoneMaxColor");
		FW:AddOption("COL",FWL.LITTLE_UNKNOWN,		"",	"HealthstoneUnknownMinColor");
		FW:AddOption("COL",FWL.MANY_UNKNOWN,		"",	"HealthstoneUnknownMaxColor");
		
	FW:SetSubCategory(FWL.APPEARANCE,FW.ICON.APPEARANCE,6);	
		FW:AddOption("COL",FWL.BAR_TEXT,			"",	"HealthstoneTextColor"):SetFunc(HS_HealthstoneShow);
		FW:AddOption("COL",FWL.FRAME_BACKGROUND,	"",	"HealthstoneBgColor"):SetFunc(HS_HealthstoneShow);
		FW:AddOption("FNT",FWL.BAR_FONT,			"",	"HealthstoneFont"):SetFunc(HS_HealthstoneShow);
		FW:AddOption("TXT",FWL.BAR_TEXTURE,			"",	"HealthstoneTexture"):SetFunc(HS_HealthstoneShow);

FW:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT");
	FW:SetSubCategory(FWL.HEALTHSTONE_SPY,FW.ICON.DEFAULT,7);
		FW:AddOption("STR",FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"HealthstoneStrata"):SetFunc(HS_HealthstoneShow);
		--FW:AddOption("NUM",FWL.HEALTHSTONE_CHECK_TIME,		"",	"HealthstoneCheckTime",nil,10);
		FW:AddOption("NUM",FWL.HEALTHSTONE_DRAW_INTERVAL,	"",	"HealthstoneInterval"):SetRange(0.5,5);

		
FW.Default.HealthstoneInterval = 2;
--FW.Default.HealthstoneCheckTime = 60;
FW.Default.HealthstoneStrata = FW.Default.Strata;

FW.Default.HealthstoneTextColor =	{1.00,1.00,1.00};
FW.Default.HealthstoneBgColor =		{0.31,0.00,0.62,0.75};
FW.Default.HealthstoneMinColor = 	{0.93,1.00,0.00};
FW.Default.HealthstoneMaxColor = 	{0.53,1.00,0.00};
FW.Default.HealthstoneUnknownMinColor = {0.53,1.00,0.00};
FW.Default.HealthstoneUnknownMaxColor = {1.00,0.00,0.00};

FW.Default.HealthstoneFont = FW.Default.Font;
FW.Default.HealthstoneTexture = FW.Default.Texture;
FW.Default.HealthstoneEnable = true;
FW.Default.HealthstoneDetails = true;
FW.Default.HealthstoneDetailsAuto = false;
FW.Default.HealthstoneAuto = false;
FW.Default.HealthstoneWidth = 100;
FW.Default.HealthstoneHeight = 12;
FW.Default.HealthstoneSpace = 1;
FW.Default.HealthstoneExpand = false;
FW.Default.HealthstoneUnknown = true;

BINDING_HEADER_HEALTHSTONE = FWL.HEALTHSTONE_SPY;
BINDING_NAME_HS_CREATEHEALTHSTONE = FW:SpellName(6201);
BINDING_NAME_HS_USEHEALTHSTONE = FWL.USE_HEALTHSTONE;
BINDING_NAME_HS_GETUPDATE = FWL.UPDATE_NOW;
BINDING_NAME_HS_CREATESOULWELL = FW:SpellName(29893); -- ritual of souls
BINDING_NAME_HS_OPTIONS = FWL.TOGGLE_OPTIONS;