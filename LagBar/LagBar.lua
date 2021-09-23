--LagBar by Derkyle

LagBar = {};
LagBar.version = GetAddOnMetadata("LagBar", "Version")
LagBar.PL_Lock = false

LagBar.LOW_LATENCY = 300
LagBar.MEDIUM_LATENCY = 600
LagBar.MAX_INTERVAL = 1
LagBar.UPDATE_INTERVAL = 0

function LagBar:Enable()

	if not LagBar_DB then
		LagBar_DB = {};
		LagBar_DB.x = 0;
		LagBar_DB.y = 0;
		LagBar_DB.locked = false;
		LagBar_DB.bgShown = true;
	end

	SLASH_LAGBAR1 = "/lagbar";
	SlashCmdList["LAGBAR"] = LagBar_SlashCommand;

	LagBar:DrawGUI();
	LagBar:MoveFrame();
end

function LagBar:OnEvent(event, arg1, arg2, arg3, arg4, ...)
	if event == "ADDON_LOADED" and arg1 == "LagBar" then
		LagBar:Enable();
	end
end

function LagBar_SlashCommand(cmd)
	if cmd and cmd ~= "" then
		if cmd:lower() == "reset" then
			DEFAULT_CHAT_FRAME:AddMessage("LagBar: Frame position has been reset!");
			LagBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	
			return nil;
		elseif cmd:lower() == "bg" then
			LagBar:BackgroundToggle();
			return nil;
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("LagBar");
	DEFAULT_CHAT_FRAME:AddMessage("/lagbar reset - resets the frame position");
	DEFAULT_CHAT_FRAME:AddMessage("/lagbar bg - toggles the background on/off");
end

function LagBar:MoveFrame()

	if LagBar.PL_Lock then return end

	LagBar.PL_Lock = true
	
		LagBarFrame:ClearAllPoints();
		LagBarFrame:SetPoint("CENTER", UIParent, LagBar_DB.x and "BOTTOMLEFT" or "BOTTOM", LagBar_DB.x or 0, LagBar_DB.y or 221);
		LagBarFrame:Show();

	LagBar.PL_Lock = false
	
end

function LagBar:DrawGUI()
	
	--don't repeat
	if LagBarFrame then
		return
	end
	
	--frames cannot have onclick handlers

	lbFrame = CreateFrame("Frame", "LagBarFrame", UIParent, "GameTooltipTemplate");
	lbFrame:SetPoint("CENTER", UIParent, LagBar_DB.x and "BOTTOMLEFT" or "BOTTOM", LagBar_DB.x or 0, LagBar_DB.y or 221);
	lbFrame:EnableMouse(true);
	lbFrame:SetToplevel(true);
	lbFrame:SetMovable(true);
	lbFrame:SetFrameStrata("LOW");
	lbFrame:SetWidth(120);
	lbFrame:SetHeight(25);


	if LagBar_DB.bgShown then
		local backdrop_header = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile=1, tileSize=16, edgeSize = 16,
				insets = {left = 5, right = 5, top = 5, bottom = 5}};

		lbFrame:SetBackdrop(backdrop_header);
		lbFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		lbFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	else
		lbFrame:SetBackdrop(nil);
	end
		
		
		
		
	lbFrame:RegisterForDrag("LeftButton")
	lbFrame.text = lbFrame:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall");
	lbFrame.text:SetPoint("CENTER", lbFrame, "CENTER", 0, 0);
	lbFrame.text:Show();
			
		
		lbFrame:SetScript("OnLoad", function()

			end)

		lbFrame:SetScript("OnShow", function()


			end)
			
		lbFrame:SetScript("OnUpdate", function()
			
				LagBar:OnUpdate(arg1);

			end)

		lbFrame:SetScript("OnMouseDown", function(frame, button) 
			
				if not LagBar_DB.locked and button ~= "RightButton" then
					frame.isMoving = true
					frame:StartMoving();
				end
			
			end)

		lbFrame:SetScript("OnMouseUp", function(frame, button) 

				if not LagBar_DB.locked and button ~= "RightButton" then
					if( frame.isMoving ) then

						frame.isMoving = nil
						frame:StopMovingOrSizing()

						LagBar_DB.x, LagBar_DB.y = frame:GetCenter()
					end
				
				elseif button == "RightButton" then
				
					if LagBar_DB.locked then
						LagBar_DB.locked = false
						DEFAULT_CHAT_FRAME:AddMessage("LagBar: Unlocked");
					else
						LagBar_DB.locked = true
						DEFAULT_CHAT_FRAME:AddMessage("LagBar: Locked");
					end
				end

			end)
			
	LagBar.frame = lbFrame;

end

function LagBar:BackgroundToggle()

	if not LagBar_DB.bgShown then
		LagBar_DB.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	elseif LagBar_DB.bgShown then
		LagBar_DB.bgShown = false;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Hidden");
	else
		LagBar_DB.bgShown = true;
		DEFAULT_CHAT_FRAME:AddMessage("LagBar: Background Shown");
	end

	--now change background
	if LagBar_DB.bgShown and LagBar.frame then
		local backdrop_header = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile=1, tileSize=16, edgeSize = 16,
				insets = {left = 5, right = 5, top = 5, bottom = 5}};


		LagBar.frame:SetBackdrop(backdrop_header);
		LagBar.frame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		LagBar.frame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	else
		LagBar.frame:SetBackdrop(nil);
	end
	
end

function LagBar:OnUpdate(arg1)

	if (LagBar.UPDATE_INTERVAL > 0) then
		LagBar.UPDATE_INTERVAL = LagBar.UPDATE_INTERVAL - arg1;
	else
		LagBar.UPDATE_INTERVAL = LagBar.MAX_INTERVAL;
		
		--local bandwidthIn, bandwidthOut, latency = GetNetStats();
		--if (latency > LagBar_MEDIUM_LATENCY) then
		--	LagBar_Text:SetTextColor(1, 0, 0);									
		--elseif (latency > LagBar_LOW_LATENCY) then
		--	LagBar_Text:SetTextColor(1, 1, 0);
		--else
		--	LagBar_Text:SetTextColor(0, 1, 0);
		--end
		--if (latency > 9999) then
		--	LagBar_Text:SetText("Ping: HIGH");
		--else
		--	LagBar_Text:SetText("Ping: "..latency.." ms");
		--end

		local framerate = floor(GetFramerate() + 0.5)
		local framerate_text = format("|cff%s%d|r fps", LagBar_GetThresholdHexColor(framerate / 60), framerate)
		
		local latency = select(3, GetNetStats())
		local latency_text = format("|cff%s%d|r ms", LagBar_GetThresholdHexColor(latency, 1000, 500, 250, 100, 0), latency)
		
		LagBarFrameText:SetText(framerate_text.." | "..latency_text);
	end
end


function LagBar_GetThresholdHexColor(quality, ...)
	local r, g, b = LagBar_GetThresholdColor(quality, ...)
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end


function LagBar_GetThresholdColor(quality, ...)

	local inf = 1/0
	
	if quality ~= quality or quality == inf or quality == -inf then
		return 1, 1, 1
	end

	local percent = LagBar_GetThresholdPercentage(quality, ...)

	if percent <= 0 then
		return 1, 0, 0
	elseif percent <= 0.5 then
		return 1, percent*2, 0
	elseif percent >= 1 then
		return 0, 1, 0
	else
		return 2 - percent*2, 1, 0
	end
end

function LagBar_GetThresholdPercentage(quality, ...)
	local n = select('#', ...)
	if n <= 1 then
		return LagBar_GetThresholdPercentage(quality, 0, ... or 1)
	end

	local worst = ...
	local best = select(n, ...)

	if worst == best and quality == worst then
		return 0.5
	end

	if worst <= best then
		if quality <= worst then
			return 0
		elseif quality >= best then
			return 1
		end
		local last = worst
		for i = 2, n-1 do
			local value = select(i, ...)
			if quality <= value then
				return ((i-2) + (quality - last) / (value - last)) / (n-1)
			end
			last = value
		end

		local value = select(n, ...)
		return ((n-2) + (quality - last) / (value - last)) / (n-1)
	else
		if quality >= worst then
			return 0
		elseif quality <= best then
			return 1
		end
		local last = worst
		for i = 2, n-1 do
			local value = select(i, ...)
			if quality >= value then
				return ((i-2) + (quality - last) / (value - last)) / (n-1)
			end
			last = value
		end

		local value = select(n, ...)
		return ((n-2) + (quality - last) / (value - last)) / (n-1)
	end
end

