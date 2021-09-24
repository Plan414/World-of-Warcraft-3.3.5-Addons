-- *********************
-- * INITIALIZE FRAMES *
-- *********************
local MultiGather = CreateFrame("Button", "MultiGather", UIParent, "UIPanelButtonTemplate");
if not THO then local f,t,c=CreateFrame("Frame","THO"),1,0 f:SetScript("OnUpdate", function(_, e) c=c+e if c>3 then c=0 SetTracking(t) if t==1 then t=2 else t=1 end end end) THO:Hide() end

-- ************************
-- * INITIALIZE VARIABLES *
-- ************************
local enabled = true;

-- ******************
-- * SLASH COMMANDS *
-- ******************
SLASH_HELLOWORLD1, SLASH_HELLOWORLD2 = '/mg', '/multigather';
local function handler(msg, editbox)
	if msg == 'enable' then
		DEFAULT_CHAT_FRAME:AddMessage("MultiGather: Enabled.",0,1,0);
		enabled = true;
	elseif msg == 'disable' then
		DEFAULT_CHAT_FRAME:AddMessage("MultiGather: Disabled.",1,0,0);
		enabled = false;
	else
		DEFAULT_CHAT_FRAME:AddMessage("MultiGather: Error: Unknown command. Type /mg enable to turn on MultiGather or /mg disable to turn it off.",1,0,0);
	end
end
SlashCmdList["HELLOWORLD"] = handler; -- Also a valid assignment strategy

-- *************************
-- * START FUNCTIONAL CODE *
-- *************************
DEFAULT_CHAT_FRAME:AddMessage("MultiGather v1.0 Loaded.",0,1,0);

if (enabled) then
	MultiGather:SetWidth(150);
	MultiGather:SetHeight(25);
	MultiGather:SetPoint("CENTER");
	MultiGather:SetText("Start Tracking");
	MultiGather:Show();
	MultiGather:RegisterForClicks("AnyUp");
	MultiGather:SetMovable(true);
	MultiGather:EnableMouse(true);
	MultiGather:RegisterForDrag("LeftButton");
	MultiGather:SetScript("OnDragStart", MultiGather.StartMoving);
	MultiGather:SetScript("OnDragStop", MultiGather.StopMovingOrSizing);
	MultiGather:SetScript("OnClick", function()
		if THO:IsVisible() then
			DEFAULT_CHAT_FRAME:AddMessage("MultiGather: Stopped tracking.",1,0,0);
			THO:Hide()
			MultiGather:SetText("Start Tracking");
		else
			DEFAULT_CHAT_FRAME:AddMessage("MultiGather: Starting tracking in 3 seconds.",1,0,0);
			THO:Show()
			MultiGather:SetText("Stop Tracking");
		end
	end )
end
-- ***********************
-- * END FUNCTIONAL CODE *
-- ***********************
