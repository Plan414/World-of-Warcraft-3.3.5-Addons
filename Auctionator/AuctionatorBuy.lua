
local addonName, addonTable = ...; 
local zc = addonTable.zc;


local ATR_BUY_NULL						= 0;
local ATR_BUY_QUERY_SENT				= 1;
local ATR_BUY_JUST_BOUGHT				= 2;
local ATR_BUY_PROCESSING_QUERY_RESULTS	= 3;
local ATR_BUY_WAITING_FOR_AH_CAN_SEND	= 4;

local gBuyState = ATR_BUY_NULL;

-----------------------------------------

local gAtr_Buy_BuyoutPrice;
local gAtr_Buy_ItemName;
local gAtr_Buy_StackSize;
local gAtr_Buy_NumBought;
local gAtr_Buy_NumUserWants;
local gAtr_Buy_MaxCanBuy;
local gAtr_Buy_CurPage;
local gAtr_Buy_Waiting_Start;
local gAtr_Buy_Query;
local gAtr_Buy_Pass;

-----------------------------------------

function Atr_Buy_Debug1 (yellow)

	if (gBuyState == ATR_BUY_NULL)										then asstr = "ATR_BUY_NULL"; end;
	if (gBuyState == ATR_BUY_QUERY_SENT)								then asstr = "ATR_BUY_QUERY_SENT"; end;
	if (gBuyState == ATR_BUY_PROCESSING_QUERY_RESULTS)					then asstr = "ATR_BUY_PROCESSING_QUERY_RESULTS"; end;
	if (gBuyState == ATR_BUY_JUST_BOUGHT)								then asstr = "ATR_BUY_JUST_BOUGHT"; end;
	if (gBuyState == ATR_BUY_WAITING_FOR_AH_CAN_SEND)					then asstr = "ATR_BUY_WAITING_FOR_AH_CAN_SEND"; end;

	if (gBuyState ~= ATR_BUY_NULL) then
		if (yellow) then
			zc.msg (asstr, "curpage: ", gAtr_Buy_CurPage, "   gAtr_Buy_NumBought: ", gAtr_Buy_NumBought);
		else
			zc.msg_pink (asstr, "curpage: ", gAtr_Buy_CurPage, "   gAtr_Buy_NumBought: ", gAtr_Buy_NumBought);
		end
	end
	
end

-----------------------------------------

function Atr_ClearBuyState()

	gBuyState = ATR_BUY_NULL;

end


-----------------------------------------

function Atr_Buy1_Onclick ()

	if (not Atr_ShowingCurrentAuctions()) then
		return;
	end
	
	gAtr_Buy_Query			= Atr_NewQuery();
	gAtr_Buy_NumUserWants	= -1;
	gAtr_Buy_NumBought		= 0;
	
	local currentPane = Atr_GetCurrentPane();
	
	local scan = currentPane.activeScan;
	
	local data = scan.sortedData[currentPane.currIndex];

	gAtr_Buy_BuyoutPrice	= data.buyoutPrice;
	gAtr_Buy_ItemName		= scan.itemName;
	gAtr_Buy_StackSize		= data.stackSize;
	gAtr_Buy_MaxCanBuy		= data.count;
	gAtr_Buy_Pass			= 1;		-- - first pass
	
	Atr_Buy_Confirm_ItemName:SetText (gAtr_Buy_ItemName.." x"..gAtr_Buy_StackSize);
	Atr_Buy_Confirm_Numstacks:SetNumber (1);
	Atr_Buy_Confirm_Max_Text:SetText (ZT("max")..": "..gAtr_Buy_MaxCanBuy);
	
	Atr_Buy_Part1:Show();
	Atr_Buy_Part2:Hide();
	
	Atr_Buy_Confirm_OKBut:SetText (ZT("Buy"))
	Atr_Buy_Confirm_OKBut:Disable();
	Atr_Buy_Confirm_Frame:Show();

	if (scan.searchWasExact and data.minpage ~= nil) then
		Atr_Buy_QueueQuery(data.minpage);
	else
		Atr_Buy_QueueQuery(0);
	end


end

-----------------------------------------

function Atr_Buy_QueueQuery (page)

	gAtr_Buy_CurPage = page;

--zc.msg_pink ("Queuing query for page ", page);

	gBuyState = ATR_BUY_WAITING_FOR_AH_CAN_SEND;
	gAtr_Buy_Waiting_Start = time();
	
	Atr_Buy_SendQuery();		-- give it a shot
end

-----------------------------------------

function Atr_Buy_SendQuery ()

	if (CanSendAuctionQuery()) then

		gBuyState = ATR_BUY_QUERY_SENT;

		local queryString = zc.UTF8_Truncate (gAtr_Buy_ItemName,63);	-- attempting to reduce number of disconnects

		QueryAuctionItems (queryString, "", "", nil, 0, 0, gAtr_Buy_CurPage, nil, nil);
	end
		
end

-----------------------------------------
local prevBuyState;

-----------------------------------------

function Atr_Buy_Idle ()

	if (gBuyState ~= prevBuyState) then
		prevBuyState = gBuyState;
--		Atr_Buy_Debug1 (true);
	end
	
	if (gBuyState == ATR_BUY_WAITING_FOR_AH_CAN_SEND) then
	
--		zc.md ("WAITING_FOR_AH_CAN_SEND: ", time() - gAtr_Buy_Waiting_Start);
		
		if (GetMoney() < gAtr_Buy_BuyoutPrice) then
			Atr_Buy_Cancel (ZT("You do not have enough gold\n\nto make any more purchases."));
		elseif (time() - gAtr_Buy_Waiting_Start > 10) then
			Atr_Buy_Cancel (ZT("Auction House timed out"));
		else	
			Atr_Buy_SendQuery ();
		end
		
	elseif (gBuyState == ATR_BUY_JUST_BOUGHT) then

--		zc.msg_pink ("ATR_BUY_JUST_BOUGHT: ",  time() - gAtr_Buy_Waiting_Start);

		local queueIf = (time() - gAtr_Buy_Waiting_Start > 2);		-- wait a few seconds for Auction List to Update after buys
		
		Atr_Buy_NextPage_Or_Cancel (queueIf);
		
	end

end

-----------------------------------------

function Atr_Buy_OnAuctionUpdate()

--	Atr_Buy_Debug1();

	if (gBuyState == ATR_BUY_QUERY_SENT) then
		Atr_Buy_CheckForMatches ();
	end

	return (gBuyState ~= ATR_BUY_NULL);
end

-----------------------------------------

function Atr_Buy_CheckForMatches ()

	gBuyState = ATR_BUY_PROCESSING_QUERY_RESULTS;
	
	if (gAtr_Buy_Query:CheckForDuplicatePage(gAtr_Buy_CurPage)) then
		Atr_Buy_QueueQuery (gAtr_Buy_CurPage);
		return;
	end

	local isLastPage = gAtr_Buy_Query:IsLastPage(gAtr_Buy_CurPage);
	
	local numMatches = Atr_Buy_CountMatches();
	
	if (numMatches > 0) then		-- update the confirmation screen
	
		Atr_Buy_Confirm_OKBut:Enable();

		if (gAtr_Buy_NumUserWants ~= -1) then		
			Atr_Buy_Continue_Text:SetText (string.format (ZT("%d of %d bought so far"), gAtr_Buy_NumBought, gAtr_Buy_NumUserWants));
			Atr_Buy_Part1:Hide();
			Atr_Buy_Part2:Show();
			Atr_Buy_Confirm_OKBut:SetText (ZT("Continue"))
		end

	else
		Atr_Buy_NextPage_Or_Cancel();
	end

end


-----------------------------------------

function Atr_Buy_BuyMatches ()
	return Atr_Buy_CountMatches (true);
end

-----------------------------------------

function Atr_Buy_CountMatches (andBuy)

	local numMatches		= 0;
	local numBoughtThisPage	= 0;
	local i = 1;

	while (true) do
	
		local name, _, count, _, _, _, _, _, buyoutPrice, _ = GetAuctionItemInfo ("list", i);

		if (name == nil) then
			break;
		end

		if (zc.StringSame (name, gAtr_Buy_ItemName) and buyoutPrice == gAtr_Buy_BuyoutPrice and count == gAtr_Buy_StackSize) then
			
			numMatches = numMatches + 1;
			
			if (andBuy and gAtr_Buy_NumUserWants > gAtr_Buy_NumBought) then
				PlaceAuctionBid("list", i, gAtr_Buy_BuyoutPrice);
				
				numBoughtThisPage  = numBoughtThisPage + 1;
				gAtr_Buy_NumBought = gAtr_Buy_NumBought + 1;
			end
		end

		i = i + 1;
	end

	return numMatches, numBoughtThisPage;
end




-----------------------------------------

function Atr_Buy_Confirm_Update ()

	local num = Atr_Buy_Confirm_Numstacks:GetNumber();

	if (num == 1) then
		Atr_Buy_Confirm_Text2:SetText (ZT("stack for"));
	else
		Atr_Buy_Confirm_Text2:SetText (ZT("stacks for"));
	end

	MoneyFrame_Update ("Atr_Buy_Confirm_TotalPrice",  gAtr_Buy_BuyoutPrice * num);

end

-----------------------------------------

function Atr_Buy_NextPage_Or_Cancel ( queueIf )

	if (Atr_Buy_IsComplete()) then
	
		Atr_Buy_Cancel();
		
	elseif (queueIf == nil or queueIf == true) then
	
		if (Atr_Buy_IsFirstPassComplete()) then
			gAtr_Buy_Pass = 2;
			Atr_Buy_QueueQuery(0);
		else
			Atr_Buy_QueueQuery(gAtr_Buy_CurPage + 1);
		end
	end
end

-----------------------------------------

function Atr_Buy_IsComplete ()

	if (gAtr_Buy_NumUserWants ~= -1 and gAtr_Buy_NumUserWants <= gAtr_Buy_NumBought) then
		return true;
	end

	if (gAtr_Buy_Query:IsLastPage(gAtr_Buy_CurPage) and gAtr_Buy_Pass == 2) then
		return true;
	end

	return false;

end

-----------------------------------------

function Atr_Buy_IsFirstPassComplete ()

	if (gAtr_Buy_Query:IsLastPage(gAtr_Buy_CurPage) and gAtr_Buy_Pass == 1) then
		return true;
	end

	return false;

end

-----------------------------------------

function Atr_Buy_Confirm_OK ()

	if (gAtr_Buy_NumUserWants == -1) then
		local numToBuy = Atr_Buy_Confirm_Numstacks:GetNumber();

		if (numToBuy > gAtr_Buy_MaxCanBuy) then
			Atr_Error_Text:SetText (string.format (ZT("You can buy at most %d auctions"), gAtr_Buy_MaxCanBuy));
			Atr_Error_Frame:Show ();
			return;
		end
		
		gAtr_Buy_NumUserWants = numToBuy;
	end
	
	local _, numJustBought = Atr_Buy_BuyMatches ();

	if (numJustBought > 0) then

--zc.msg (numJustBought, " from page ", gAtr_Buy_CurPage);
	
		AuctionatorSubtractFromScan (gAtr_Buy_ItemName, gAtr_Buy_StackSize, gAtr_Buy_BuyoutPrice, gAtr_Buy_NumBought);
		gBuyState = ATR_BUY_JUST_BOUGHT;
		gAtr_Buy_Waiting_Start = time();
		Atr_Buy_Confirm_OKBut:Disable();
	else
		Atr_Buy_NextPage_Or_Cancel();
	end
	
end

-----------------------------------------

function Atr_Buy_Wait_For_Bought_To_Clear ()

	zc.md ("Atr_Buy_Wait_For_Bought_To_Clear: ", time() - gAtr_Buy_Waiting_Start);
	
end

-----------------------------------------

function Atr_Buy_Cancel (msg)
	
	gBuyState = ATR_BUY_NULL;

	Atr_Buy_Confirm_Frame:Hide();
	
	Atr_Error_Display(msg);
end


