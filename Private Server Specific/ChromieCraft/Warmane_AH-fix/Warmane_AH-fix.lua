local version = "1.5";

local frame = CreateFrame("FRAME");
frame:RegisterEvent("AUCTION_HOUSE_SHOW");
frame:RegisterEvent("MAIL_SHOW");

local eventHandler = function()
	if (event == "AUCTION_HOUSE_SHOW" or event == "MAIL_SHOW") then
		DEFAULT_CHAT_FRAME:AddMessage("Warmane AH-fix v"..version.." loaded.", 0.5, 0.5, 1);
		frame:UnregisterEvent("AUCTION_HOUSE_SHOW");
		frame:UnregisterEvent("MAIL_SHOW");
	end
end
frame:SetScript("OnEvent", eventHandler);

local origStartAuction = StartAuction;
StartAuction = function(minBid, buyoutPrice, runTime, stackSize, numStacks)
	numStacks = numStacks or 1;
	stackSize = stackSize or AuctionsStackSizeEntry:GetText();
	return origStartAuction(minBid, buyoutPrice, runTime, stackSize, numStacks);
end


local AllianceMails = {
	"Stormwind Auction House",
	"Ironforge Auction House",
	"Darnassus Auction House",
	"Exodar Auction House" }

local HordeMails = {
	"Undercity Auction House",
	"Thunder Bluff  Auction House",
	"Thunder Bluff Auction House", -- Currently with 2 spaces, listing with 1 space also in case it gets changed.
	"Orgrimmar Auction House",
	"Silvermoon Auction House" }

local origGetInboxHeaderInfo = GetInboxHeaderInfo;
GetInboxHeaderInfo = function(index)
	packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM = origGetInboxHeaderInfo(index);
	
	for _,v in pairs(AllianceMails) do
		if v == sender then
			sender = "Alliance Auction House"
			break
		end
	end
	
	for _,v in pairs(HordeMails) do
		if v == sender then
			sender = "Horde Auction House"
			break
		end
	end
	
	return packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM;
end