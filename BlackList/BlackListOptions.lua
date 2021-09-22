----------------------------------------------------------------------------------------------------
-- Rogue Focus: Options
----------------------------------------------------------------------------------------------------
BlackListOptions = { };

local _G = getfenv(0);

----------------------------------------------------------------------------------------------------
-- Widgets Handlers
----------------------------------------------------------------------------------------------------
function BlackListOptions:Handler()
	if(BlackListOptionsFrame:IsVisible()) then
		HideUIPanel(BlackListOptionsFrame);
	else
		ShowUIPanel(BlackListOptionsFrame);
	end
end

function BlackListOptions:SoundCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Sound);
end

function BlackListOptions:CenterCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Center);
end

function BlackListOptions:ChatCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Chat);
end

function BlackListOptions:IgnoreCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Ignore);
end

function BlackListOptions:BanCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Ban);
end

function BlackListOptions:KickCheckButton_OnShow()
	this:SetChecked(BlackListConfig.Kick);
end

function BlackListOptions:BL_RankBox_OnShow()
	this:SetText(BlackListConfig.Rank);
end


function BlackListOptions:SoundCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Sound = true;
	else
		BlackListConfig.Sound = false;
	end
end

function BlackListOptions:CenterCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Center = true;
	else
		BlackListConfig.Center = false;
	end
end

function BlackListOptions:ChatCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Chat = true;
	else
		BlackListConfig.Chat = false;
	end
end

function BlackListOptions:IgnoreCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Ignore = true;
	else
		BlackListConfig.Ignore = false;
	end
end

function BlackListOptions:BanCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Ban = true;
	else
		BlackListConfig.Ban = false;
	end
end

function BlackListOptions:KickCheckButton_OnClick()
	if(1 == this:GetChecked()) then
		BlackListConfig.Kick = true;
	else
		BlackListConfig.Kick = false;
	end
end

function BlackListOptions:BL_RankBox_OnTextChanged()
	local Rank = tonumber(BL_RankBox:GetText());
	if not Rank then Rank = 5; end
	BlackListConfig.Rank = Rank;
end