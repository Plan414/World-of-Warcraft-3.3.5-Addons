-- **************************************************************************
-- **                              Roll Tracker                            **
-- **  http://wow.curse.com/downloads/wow-addons/details/roll-tracker.aspx **
-- **************************************************************************

RT_version = 3.22
RT_exversion = RT_version
RT_track = false
RT_reporttop = 5
RT_reportclosebutton = nil
RT_reportdropdown = nil
RT_reportframe = nil
RTBstarttracking = nil
RT_pagenumber = 1
RTpageid, RTnextpage, RTprevpage = nil,nil,nil,nil
RT_sortroll = "down" --(100-0)
RT_guildsort = "off"
RT_logged = false

RT_buttonfill={
["FrameHeader"]="Interface\\COMMON/Common-Input-Border.png",
["FrameBG"]="Interface\\DialogFrame/UI-DialogBox-Background.png",
["Settings"]="Interface\\GossipFrame/BinderGossipIcon.png",
["New Page"]="Interface\\BUTTONS\\UI-GuildButton-OfficerNote-Up.png",
["Del Page"]="Interface\\COMMON\\VOICECHAT-MUTED.png",
["Roll Start"]="Interface\\BUTTONS\\UI-GroupLoot-Dice-Up.png",
["Roll Pause"]="Interface\\BUTTONS\\UI-GroupLoot-Pass-Up.png",
["Report"]="Interface\\BUTTONS\\UI-GuildButton-MOTD-Up.png",
["Close"]="Interface\\BUTTONS\\UI-Panel-MinimizeButton-Up.png",
["Highlight"]="Interface\\BUTTONS\\BLUEGRAD64.png"
}

function RTresetrolls()
	return {
	["Name"]={},
	["Roll"]={},
	["Id"]={},
	["Won"]={}
	}
end

RT_rolls= RTresetrolls()
RT_reports = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}

function RTgetpartymembers()
	local partymembers;

	if(GetRealNumRaidMembers()>0) then
		partymembers = GetRealNumRaidMembers()
	elseif(GetNumPartyMembers()>0) then
		partymembers = GetNumPartyMembers()+1
	else
		partymembers = 1
	end
	
	return partymembers

end

function RTGetGuildRank(name)
	if(tostring(name)=="nil") then
		name=""
	end
	local guildName, guildRankName, guildRankIndex = GetGuildInfo(name)

	if(tostring(guildRankName)=="nil") then
		guildName="Noone"
		guildRankName="Noone"
		guildRankIndex=10
	end
	
	return guildName, guildRankName, guildRankIndex
end

StaticPopupDialogs["RT_REPORT"] = {
	text = "Report top:              ",
	button1 = "Raid/Party",
	button2 = "Close",
	button3 = "Print to chatframe",

	OnAccept = function()
		local RT_reporter = tonumber(UIDropDownMenu_GetText(RT_reportdropdown))
		if(RT_reporter>#RT_rolls["Name"]) then
			RT_reporttop = #RT_rolls["Name"]
		else
			RT_reporttop = RT_reporter
		end
		
		RT_reportclosebutton:Hide()
		RT_reportdropdown:Hide()
		if(#RT_rolls["Name"]==0) then
			print("You dont have anything to report")
		else
			if(GetRealNumRaidMembers()>0) then
				print("Reporting to raid: ")
				SendChatMessage("<Roll Tracker> reporting "..tostring(RT_reporttop).." of "..tostring(#RT_rolls["Name"]).." rolls:","RAID")
				RTReportRolls("RAID")
			elseif(GetNumPartyMembers()>0) then
				print("Reporting to party: ")
				SendChatMessage("<Roll Tracker> reporting "..tostring(RT_reporttop).." of "..tostring(#RT_rolls["Name"]).." rolls:","PARTY")
				RTReportRolls("PARTY")
			else
				print("You are not in raid/party!")
			end
		end
		
	end,
	OnCancel = function()
		RT_reportclosebutton:Hide() 
		RT_reportdropdown:Hide()
	end,
	OnAlt = function()
		local RT_reporter = tonumber(UIDropDownMenu_GetText(RT_reportdropdown))
		if(RT_reporter>#RT_rolls["Name"]) then
			RT_reporttop = #RT_rolls["Name"]
		else
			RT_reporttop = RT_reporter
		end
		
		RT_reportclosebutton:Hide()
		RT_reportdropdown:Hide()
		if(#RT_rolls["Name"]==0) then
			print("You dont have anything to report")
		else
			print("<Roll Tracker> reporting "..tostring(RT_reporttop).." of "..tostring(#RT_rolls["Name"]).." rolls:")
			RTReportRolls()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function RTFindName(rollname)
local a,igennem;
igennem = false
for a=1,#RT_rolls["Name"]+1 do 
	local name=RT_rolls["Name"][a]
	if(name==rollname) then
		igennem = true
	end
end

return igennem
end

function RTMaxMinRoll(text)
	--"(1-100")
	local a,b = strsplit("-",text,2)
	--"(1" "100)"
	local _,min = strsplit("(",a,2)
	--"1","100)"
	local max = strsplit(")",b,2)
	--"1","100"
	return tonumber(min),tonumber(max)
end

function RTRollSortRoll(typetype,sortguild)
	--up: 1=100-0,  2=0-100
if not(typetype=="off") then
	local newtable=RTresetrolls()						--creating a new table to save the rolls 
	local a,b,igennem;
	igennem = false
	
	for a=1,#RT_rolls["Name"] do						--new number to insert
		local newnumber = RT_rolls["Roll"][a]
		igennem=false
		
		for b=1,#newtable["Name"] do						--the place to the new number
			if(igennem==false) then
				local currentnumber = newtable["Roll"][b]

				if(typetype=="up") then
					if(tostring(currentnumber)=="nil") then
						currentnumber=99999999999999999999
					end
					if(newnumber<currentnumber) or (newnumber==currentnumber) then
						tinsert(newtable["Roll"],b,RT_rolls["Roll"][a])
						tinsert(newtable["Name"],b,RT_rolls["Name"][a])
						tinsert(newtable["Id"],b,RT_rolls["Id"][a])
						tinsert(newtable["Won"],b,RT_rolls["Won"][a])
						igennem=true
					elseif(b==#newtable["Name"]) then
						tinsert(newtable["Roll"],b+1,newnumber)
						tinsert(newtable["Name"],b+1,RT_rolls["Name"][a])
						tinsert(newtable["Id"],b+1,RT_rolls["Id"][a])
						tinsert(newtable["Won"],b+1,RT_rolls["Won"][a])
						igennem=true
					end
				elseif(typetype=="down") then
					if(tostring(currentnumber)=="nil") then
						currentnumber=-1
					end
					if(newnumber>currentnumber) or (newnumber==currentnumber) then
						tinsert(newtable["Roll"],b,newnumber)
						tinsert(newtable["Name"],b,RT_rolls["Name"][a])
						tinsert(newtable["Id"],b,RT_rolls["Id"][a])
						tinsert(newtable["Won"],b,RT_rolls["Won"][a])
						igennem=true
					elseif(b==#newtable["Name"]) then
						tinsert(newtable["Roll"],b+1,RT_rolls["Roll"][a])
						tinsert(newtable["Name"],b+1,RT_rolls["Name"][a])
						tinsert(newtable["Id"],b+1,RT_rolls["Id"][a])
						tinsert(newtable["Won"],b+1,RT_rolls["Won"][a])
						igennem=true
					end
				end
			end
		end
		if(#newtable["Roll"]==0) then
			local currentnumber = newtable["Roll"][b]
			tinsert(newtable["Roll"],a,newnumber)
			tinsert(newtable["Name"],a,RT_rolls["Name"][a])
			tinsert(newtable["Id"],a,RT_rolls["Id"][a])
			tinsert(newtable["Won"],a,RT_rolls["Won"][a])
		end
	end
	RT_rolls = newtable
	RTUpdateFont()
elseif not(guildsort=="off") then
	local newtable=RTresetrolls()						--creating a new table to save the rolls 
	local a,b,igennem;
	igennem = false
	igennemc = false
	
	for a=1,#RT_rolls["Roll"] do
		local newnumber = RT_rolls["Roll"][a]
		local gname,grank,gindex = RTGetGuildRank(RT_rolls["Name"][a])
		local newindex = gindex
		igennem,igennemc = false,false
	
		for b=1,#newtable["Roll"] do
			if(igennem==false) then
				local currentnumber = newtable["Roll"][b]
				local gname,grank,gindex = RTGetGuildRank(RT_rolls["Name"][b])
				local currentindex = gindex
					--print("New: "..newindex.." Cur: "..currentindex.." - "..RT_rolls["Name"][a])
					if(sortguild=="up") then
						if(newindex>currentindex) or (newindex==currentindex) then
							--print("placerer: "..RT_rolls["Name"][a].." --- "..b)
							for c=b,#newtable["Roll"] do
								if(igennemc==false) then
									local gname,grank,gindex = RTGetGuildRank(newtable["Name"][c])
									local futureindex = gindex
									--print("///"..newtable["Name"][c+1].." | "..newtable["Name"][a])
									if(newnumber>currentnumber) or (newnumber==currentnumber) or (newindex>futureindex) then
										tinsert(newtable["Roll"],c,RT_rolls["Roll"][a])
										tinsert(newtable["Name"],c,RT_rolls["Name"][a])
										tinsert(newtable["Id"],c,RT_rolls["Id"][a])
										tinsert(newtable["Won"],c,RT_rolls["Won"][a])
										igennem=true
										igennemc=true
									elseif(c==#newtable["Name"]) then
										tinsert(newtable["Roll"],c+1,RT_rolls["Roll"][a])
										tinsert(newtable["Name"],c+1,RT_rolls["Name"][a])
										tinsert(newtable["Won"],c+1,RT_rolls["Won"][a])
										igennem=true
										igennemc=true
									end
								end
							end
						elseif(b==#newtable["Name"]) then
							tinsert(newtable["Roll"],b+1,RT_rolls["Roll"][a])
							tinsert(newtable["Name"],b+1,RT_rolls["Name"][a])
							tinsert(newtable["Id"],b+1,RT_rolls["Id"][a])
							tinsert(newtable["Won"],b+1,RT_rolls["Won"][a])
							igennem=true
						end
					elseif(sortguild=="down") then
						if(newindex<currentindex) or (newindex==currentindex) then
							--print("placerer: "..RT_rolls["Name"][a].." --- "..b)
							for c=b,#newtable["Roll"] do
								if(igennemc==false) then
									local gname,grank,gindex = RTGetGuildRank(newtable["Name"][c])
									local futureindex = gindex
									--print("///"..newtable["Name"][c+1].." | "..newtable["Name"][a])
									if(newnumber>currentnumber) or (newnumber==currentnumber) or (newindex<futureindex) then
										tinsert(newtable["Roll"],c,RT_rolls["Roll"][a])
										tinsert(newtable["Name"],c,RT_rolls["Name"][a])
										tinsert(newtable["Id"],c,RT_rolls["Id"][a])
										tinsert(newtable["Won"],c,RT_rolls["Won"][a])
										igennem=true
										igennemc=true
									elseif(c==#newtable["Name"]) then
										tinsert(newtable["Roll"],c+1,RT_rolls["Roll"][a])
										tinsert(newtable["Name"],c+1,RT_rolls["Name"][a])
										tinsert(newtable["Id"],c+1,RT_rolls["Id"][a])
										tinsert(newtable["Won"],c+1,RT_rolls["Won"][a])
										igennem=true
										igennemc=true
									end
								end
							end
						elseif(b==#newtable["Name"]) then
							tinsert(newtable["Roll"],b+1,RT_rolls["Roll"][a])
							tinsert(newtable["Name"],b+1,RT_rolls["Name"][a])
							tinsert(newtable["Id"],b+1,RT_rolls["Id"][a])
							tinsert(newtable["Won"],b+1,RT_rolls["Won"][a])
							igennem=true
						end
					end
				end
			end
		
		if(#newtable["Roll"]==0) then
			tinsert(newtable["Roll"],a,RT_rolls["Roll"][a])
			tinsert(newtable["Name"],a,RT_rolls["Name"][a])
			tinsert(newtable["Id"],a,RT_rolls["Id"][a])
			tinsert(newtable["Won"],a,RT_rolls["Won"][a])
		end
		
	end

	RT_rolls = newtable
	RTUpdateFont()
	end
	
end

function RTRollSort(newnumber,rollname,rollid)
local TLenght = #RT_rolls["Roll"]

if(TLenght>0) then
	local a, RollNumber,stop
	for a=1, TLenght+1 do
		RollNumber = RT_rolls["Roll"][a]
		if(RollNumber) then
			if(newnumber>RollNumber) or (newnumber==RollNumber) then
				if(stop==nil) then
					if(RTFindName(rollname)==false) then
						tinsert(RT_rolls["Roll"],a,newnumber)
						tinsert(RT_rolls["Name"],a,rollname)
						tinsert(RT_rolls["Id"],a,rollid)
						tinsert(RT_rolls["Won"],a,"")
						stop = true
					end
				end
			end
		end
	end
	a = #RT_rolls["Roll"]
	if(stop==nil) then
		if(RTFindName(rollname)==false) then
			tinsert(RT_rolls["Roll"],a+1,newnumber)
			tinsert(RT_rolls["Name"],a+1,rollname)
			tinsert(RT_rolls["Id"],a+1,rollid)
			tinsert(RT_rolls["Won"],a+1,"")
		end
	end
else
	RT_rolls={
	["Name"]={rollname},
	["Roll"]={newnumber},
	["Id"]={rollid},
	["Won"]={""}}
end

RTRollSortRoll(RT_sortroll,RT_guildsort)
end

function RTReturnWinners()
	local a,tal,twowinners,firsttime,firsttimenumber;
	firsttime=true
	firsttimenumber=1
	
	for a=1,#RT_rolls["Name"] do
		if(firsttime==true) then
			if(tostring(RT_rolls["Roll"][a+1])==tostring(RT_rolls["Roll"][a])) or (tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then
				if not(tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then 
					tal = 1
					if(a>1) then
						firsttime=false
						firsttimenumber = a-1
					end
				elseif(tal==nil) then 
					tal = 1
				else 
					tal = tal+1
				end
			else
				if(a>1) then
					firsttime=false
					firsttimenumber = a-1
				end
			end
		end
	end

	return firsttimenumber
end

function RTReportRolls(type)
	local a,tal;
	if(type==nil) then
		for a=1,RT_reporttop do
			local extratext = ""
			if(tostring(RT_rolls["Roll"][a+1])==tostring(RT_rolls["Roll"][a])) or (tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then 
				if not(tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then
					tal = 1
				elseif(tal==nil) then
					tal = 1
				else
					tal = tal+1
				end
				extratext = "("..tostring(tal)..")"
			else
				tal = nil
				extratext=""
			end
			
			local RankText = ""
			if(RT_settings["GRankReport"]==true) then
				local guildName, guildRankName, guildRankIndex = RTGetGuildRank(tostring(RT_rolls["Name"][a]))
				if not(guildRankName=="Noone") then
					RankText = " ("..tostring(guildRankName)..")"
				elseif(guildRankName=="Noone") then
					RankText = " (No Rank)"
				end
			end
			
			local _,RTmax = RTMaxMinRoll(RT_rolls["Id"][a])
			RTAddRolledText("#"..tostring(a).." "..tostring(RT_rolls["Name"][a])..""..tostring(RankText)..": "..tostring(RT_rolls["Roll"][a]).." "..tostring(extratext),tonumber(RT_rolls["Roll"][a]),RTmax)
		end
		--Reporting winners
		--[[if(RTReturnWinners()==1) then
			RTAddRolledText("Winner: "..tostring(RT_rolls["Name"][1])..": "..tostring(RT_rolls["Roll"][1]).." "..tostring(RT_rolls["Id"][1]).."",100,100)
		else
			RTAddRolledText("Winners: ",100,100)
			for a=1, RTReturnWinners() do
				local _,RTmax = RTMaxMinRoll(RT_rolls["Id"][a])
				RTAddRolledText(""..tostring(RT_rolls["Name"][a])..": "..tostring(RT_rolls["Roll"][a]).." "..tostring(RT_rolls["Id"][a]).."",tonumber(RT_rolls["Roll"][a]),RTmax)
			end
		end]]
		--Reporting winners
	else
		for a=1,RT_reporttop do
			local extratext = ""
			if(tostring(RT_rolls["Roll"][a+1])==tostring(RT_rolls["Roll"][a])) or (tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then 
				if not(tostring(RT_rolls["Roll"][a-1])==tostring(RT_rolls["Roll"][a])) then
					tal = 1
				elseif(tal==nil) then
					tal = 1
				else
					tal = tal+1
				end
				extratext = "("..tostring(tal)..")"
			else
				tal = nil
				extratext=""
			end
			
			local RankText = ""
			if(RT_settings["GRankReport"]==true) then
				local guildName, guildRankName, guildRankIndex = RTGetGuildRank(tostring(RT_rolls["Name"][a]))
				if not(guildRankName=="Noone") then
					RankText = " ("..tostring(guildRankName)..")"
				elseif(guildRankName=="Noone") then
					RankText = " (No Rank)"
				end
			end
			
			local _,RTmax = RTMaxMinRoll(RT_rolls["Id"][a])
			RTAddRolledText("#"..tostring(a).." "..tostring(RT_rolls["Name"][a])..""..tostring(RankText)..": "..tostring(RT_rolls["Roll"][a]).." "..tostring(extratext),tonumber(RT_rolls["Roll"][a]),RTmax,tostring(type))
		end
		

		
		--Reporting winners
		--[[if(RTReturnWinners()==1) then
			RTAddRolledText("  Winner: "..tostring(RT_rolls["Name"][1])..": "..tostring(RT_rolls["Roll"][1]).." "..tostring(RT_rolls["Id"][1]).."",tonumber(RT_rolls["Roll"][1]),RTmax,tostring(type))
		else
			RTAddRolledText("  Winners: ",0,100,tostring(type))
			for a=1, RTReturnWinners() do
				local _,RTmax = RTMaxMinRoll(RT_rolls["Id"][a])
				RTAddRolledText("  #"..a.." "..tostring(RT_rolls["Name"][a])..": "..tostring(RT_rolls["Roll"][a]).." "..tostring(RT_rolls["Id"][a]).."",tonumber(RT_rolls["Roll"][a]),RTmax,tostring(type))
			end
		end]]
		--Reporting winners
	end
end

function RTDeleteTable(number)
	tremove(RT_rolls["Name"], number)
	tremove(RT_rolls["Roll"], number)
	tremove(RT_rolls["Id"], number)
	RTUpdateFont()
end

--if not(DPM_version) then
function RuneCreateFrame(name,x,y,parent,width,height,move,mouse,rto,rpoint)
	local Parent = parent

	if(parent==nil) then
		local Parent = UIParent
	end
	local FrameLevel = 4
	local RelativeTo="CENTER"
	local RelativePoint = "CENTER"
	if(rto) then
		local RelativeTo=rto
	end
	if not(rpoint==nil) then
		local RelativePoint = rpoint
	end

	local Fx = x
	local Fy = y
	local FName =  name
	local FWidth = width
	local FHeight = height
	local MoveAble = move
	local MouseAble = mouse  
	local FFrame = CreateFrame("FRAME",FName,Parent)
	FFrame:SetBackdrop(StaticPopup1:GetBackdrop())
	FFrame:SetWidth(FWidth)
	FFrame:SetHeight(FHeight)
	FFrame:SetPoint(RelativePoint,Parent,RelativeTo , Fx,Fy)

	if(MoveAble) then
		FFrame:SetMovable(true)
	end

	if(MouseAble) then
		FFrame:EnableMouse(true)
		FFrame:SetScript("OnMouseDown",function() FFrame:StartMoving() end)
		FFrame:SetScript("OnMouseUp",function() FFrame:StopMovingOrSizing() end)
	end

	FFrame:SetFrameLevel(4)

	return FFrame
end
function RuneCreateTexture(name,x,y,parent,width,height,move,mouse,rto,rpoint,texture,a,r,g,b)
	local Parent = parent

	if(parent==nil) then
		local Parent = UIParent
	end
	local FrameLevel = 4
	local RelativeTo="CENTER"
	local RelativePoint = "CENTER"
	if(rto) then
		local RelativeTo=rto
	end
	if not(rpoint==nil) then
		local RelativePoint = rpoint
	end

	local Fx = x
	local Fy = y
	local FName =  name
	local FWidth = width
	local FHeight = height
	local MoveAble = move
	local MouseAble = mouse  
	local FFrame = CreateFrame("FRAME",FName,Parent)
	local Texture = texture
	if(Texture == nil) then Texture = "" end
	if(a==nil) then a=1 end
	
	FFrame:SetWidth(FWidth)
	FFrame:SetHeight(FHeight)
	FFrame:SetPoint(RelativePoint,Parent,RelativeTo , Fx,Fy)

	if(MoveAble) then
		FFrame:SetMovable(true)
	end

	if(MouseAble) then
		FFrame:EnableMouse(true)
		FFrame:SetScript("OnMouseDown",function() FFrame:StartMoving() end)
		FFrame:SetScript("OnMouseUp",function() FFrame:StopMovingOrSizing() end)
	end

	FFrameTexture = FFrame:CreateTexture(FName.."texture")
	FFrameTexture:SetHeight(FHeight)
	FFrameTexture:SetHeight(FWidth)
	FFrameTexture:SetTexture(Texture)
	if(r) then
	FFrameTexture:SetVertexColor(r,g,b)
	end
	FFrameTexture:SetAllPoints(FFrame)
	FFrameTexture:SetAlpha(a)
	FFrame:SetFrameLevel(4)
	FFrameTexture:Show()
	return FFrame, FFrameTexture
end
function RuneCreateButton(name,text,x,y,parent,w,h,relativeto,relativepoint,OnClicking)
	if(parent==nil) then
		local Parent = UIParent
	else
		Parent = parent
	end
	local Name = name
	local BX = x
	local BY = y
	local RelativeTo = relativeto
	local RelativePoint = relativepoint
	local BWidth = w
	local BHeight = h
	local Text = text

	local FrameLevel = 5
	local ButtonFrame = CreateFrame("BUTTON",Name,Parent)
	ButtonFrame:ClearAllPoints()
	ButtonFrame:SetPoint(RelativeTo, Parent, RelativePoint, BX, BY)
	ButtonFrame:SetMovable(true)
	ButtonFrame:EnableMouse(true)
	ButtonFrame:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up.blp") 
	ButtonFrame:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")

	ButtonFrame:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight")

	ButtonFrame:SetWidth(BWidth)
	ButtonFrame:SetHeight(BHeight)

	function ButtonFrame.ButtonClick(self,button,down)
		OnClicking(self, button, down)
	end

	ButtonFrame:SetFrameLevel(FrameLevel)
	local ButtonFrameFont = ButtonFrame:CreateFontString("ButtonFrameString", FrameLevel+1, "GameFontNormal")
	ButtonFrameFont:SetPoint("BOTTOM",ButtonFrame,"CENTER",0,-1.5)
	ButtonFrameFont:SetText(text)
	ButtonFrame:SetScript("OnClick", function(self, button, down) OnClicking(self, button, down,ButtonFrameFont, Name) end)

	return ButtonFrame, ButtonFrameFont
end
function RuneCreateEditbox(name,x,y,parent,rt,rp)
	if(parent==nil) then
		local Parent = UIParent
	else
		Parent = parent
	end
	Name = name
	RelativeTo = rt
	RelativePoint = rp
	EditX = x
	EditY = y
	local FrameLevel = 5

	local EditBox = CreateFrame("EditBox", Name, Parent)
	EditBox:SetFrameLevel(FrameLevel)
	EditBox:ClearAllPoints()
	EditBox:SetPoint("TOPLEFT", Parent, "TOPLEFT",EditX+67,EditY)
 
	EditBox:SetPoint("BOTTOMRIGHT", Parent, "TOPRIGHT", EditX-17,EditY-25)
	EditBox:SetFontObject(GameFontHighlightSmall)
	EditBox:SetTextInsets(8,8,8,8)
	EditBox:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 }
	})
	EditBox:SetBackdropColor(.1,.1,.1,1)
	EditBox:SetMovable(true)
	EditBox:SetMultiLine(false)
	EditBox:SetAutoFocus(false)

	EditBox:SetScript("OnTextSet", function(self)
    if self:GetText() == "" then
		EditBox:SetPoint(RelativeTo,Parent,RelativePoint,EditX,EditY)
    else
		EditBox:SetPoint(RelativeTo,Parent,RelativePoint,EditX,EditY)
		EditBox:SetFocus()
		EditBox:HighlightText()
    end
	end)

	EditBox:SetScript("OnEscapePressed", EditBox.ClearFocus)
	EditBox:SetScript("OnEnterPressed", EditBox.ClearFocus)
	EditBox:SetScript("OnTabPressed", EditBox.ClearFocus)
	EditBox:ClearFocus()

	return EditBox
end
function RuneCreateText(name,text,x,y,parent,w,h,relativeto,relativepoint,white,tittle,justify,TextFunctionOnClick)
	if(parent==nil) then
		local Parent = UIParent
	else
		Parent = parent
	end

	local Name = name
	local TextX = x
	local TextY = y
	local RelativeTo = relativeto
	local RelativePoint = relativepoint
	local TextWidth = w
	local TextHeight = h
	local Text = text

	local FrameLevel = 4

	local TextFrame = CreateFrame("FRAME",Name,Parent)
	TextFrame:ClearAllPoints()
	TextFrame:SetWidth(TextWidth)
	TextFrame:SetHeight(TextHeight)
	local TextFrameFont = TextFrame:CreateFontString(nil, "OVERLAY","GameFontNormal")

	if(tittle) then
		--TextFrameFont:SetFont("Fonts\\skurri.ttf",20,"OUTLINE")
		TextFrameFont:SetFont("Fonts\\ARIALN.TTF",20,"OUTLINE")
	end

	if(white) then
		TextFrameFont:SetTextColor(1,1,1)
	end
   
	if(justify) then
		TextFrameFont:SetJustifyH(justify)
	end
  
	TextFrameFont:SetAllPoints()
	TextFrameFont:SetText(Text)
	TextFrame:SetPoint(RelativeTo,Parent,RelativePoint,TextX,TextY)
	TextFrame:SetMovable(true)
	TextFrame:SetFrameLevel(FrameLevel)

	function TextFrame.OnGlobalClick(a1,a2,a3,a4)
		TextFunctionOnClick(TextFrame,TextFrameFont,a1,a2,a3,a4)
	end

	function TextFrameFont.OnGlobalClick(a1,a2,a3,a4)
		TextFunctionOnClick(TextFrame,TextFrameFont,a1,a2,a3,a4)
	end

	return TextFrame,TextFrameFont
end
function RuneCreateDropdownMenu(name,x,y,parent,items,rto,rpoint,DDMFunctionOnClick,DDMFunctionOnInit,UseOnInit)
    
	if(parent==nil) then
		local Parent = UIParent
	else
		Parent = parent
	end

	local FrameWidth = 100
	local MenuWidth = 124
	local StartID = 1
	local TextAllign = "LEFT"
	local DDMItems = items
	local RelativeTo = rto
	local RelativePoint = rpoint
	local DDMx = x
	local DDMy = y
	local DDMName = name
	local DDMFrame = CreateFrame("FRAME",DDMName, Parent,"UIDropDownMenuTemplate")
	DDMFrame:ClearAllPoints()
	DDMFrame:SetPoint(RelativeTo, Parent, RelativePoint, DDMx, DDMy)
	DDMFrame:Show()

	function DDMFrame.OnClick(self)
		local idd = UIDropDownMenu_GetSelectedID(DDMFrame) --this:GetID()
		DDMFunctionOnClick(optionID,optionName,DDMFrame, idd)
	end

	function DDMFrame.DropDownMenuOnClick()
		local optionID = this:GetID();
		UIDropDownMenu_SetSelectedID(DDMFrame, optionID);
		local optionName =  UIDropDownMenu_GetText(DDMFrame);
		UIDropDownMenu_SetSelectedValue(DDMFrame, optionName);
		DDMFrame.OnClick()
	end

	function DDMFrame.DropDownMenuInit(ex,exex)
		if(tostring(UseOnInit)=="nil") then
			for index,value in pairs(DDMItems) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = value
				info.value = value
				info.tooltipTitle = tostring(value)
				--info.tooltipText = tostring(value)	
				info.func = DDMFrame.DropDownMenuOnClick
				UIDropDownMenu_AddButton(info, nil, DDMFrame)
			end
		else
			DDMFunctionOnInit(DDMFrame,DDMFrame.DropDownMenuOnClick,DDMItems,DDMFrame,ex,exex)
		end
		UIDropDownMenu_Refresh(DDMFrame)
	end
 
	UIDropDownMenu_Initialize(DDMFrame, 	DDMFrame.DropDownMenuInit)
	UIDropDownMenu_SetWidth(DDMFrame, 	FrameWidth);
	UIDropDownMenu_SetButtonWidth(DDMFrame,MenuWidth)
	UIDropDownMenu_SetSelectedID(DDMFrame, StartID)
	UIDropDownMenu_JustifyText(DDMFrame, 	TextAllign)
  
	return DDMFrame
end
function RuneCreateCheckbox(name,x,y,parent,rto,rpoint,w,h,down,CBoxClick)
	local DPMcheckbox = CreateFrame("CheckButton",name,parent)
	DPMcheckbox:SetWidth(w)
	DPMcheckbox:SetHeight(h)
	DPMcheckbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up") 
	DPMcheckbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down") 
	DPMcheckbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD") 
	DPMcheckbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check") 
	DPMcheckbox:SetPoint(rpoint,parent,rto,x,y)

	if(down==1) then 
		DPMcheckbox:SetChecked(true) 
	else 
		DPMcheckbox:SetChecked(false) 
	end

	DPMcheckbox:SetScript("OnClick", function(self, button, down)
		local enabled=DPMcheckbox:GetChecked()
		CBoxClick(self,button,enabled)
	end)

	DPMcheckbox:SetFrameLevel(5)

	DPMcheckbox:SetScript("OnShow", function(self)
	if(name=="DPMcheckbox0") then
		if(DPMdisable==1) then 
			DPMcheckbox:SetChecked(true) else DPMcheckbox:SetChecked(false) end
		end
	end)

	return DPMcheckbox
end
local function RuneCreateScrollframe(name,x,y,parent,rto,rpoint,w1,h1,w2,h2)

	if not(parent) then 
		parent=UIParent 
	end

	local SFrame = CreateFrame("ScrollFrame",name, parent, "UIPanelScrollFrameTemplate")
	local MSFrame = CreateFrame("Frame", name.."Child", SFrame)

	SFrame:SetScrollChild(MSFrame)
	SFrame:SetPoint(rpoint, parent, rto, x, y)

	MSFrame:SetPoint("TOPLEFT", name, "TOPLEFT", 0, 0)
  
	MSFrame:SetFrameLevel(4)
	SFrame:SetFrameLevel(4)
	SFrame:SetWidth(w1)  
	SFrame:SetHeight(h1) 

	MSFrame:SetWidth(w2)  
	MSFrame:SetHeight(h2) 

	SFrame:SetHorizontalScroll(0)
	SFrame:SetVerticalScroll(0)
	
	SFrame:EnableMouse(true)

  
	SFrame:Show()
	MSFrame:Show()

	return MSFrame,SFrame
end
local function RuneAddTooltip(frame,title,content)
	local function TooltipOnEnter(self,title,content)  
		GameTooltip:SetOwner(self, "ANCHOR_NAME")  
		GameTooltip:SetPoint("BOTTOMLEFT",GameTooltip:GetOwner(),"TOPRIGHT",0,10)
		GameTooltip:SetText(tostring(title))  -- This sets the top line of text, in gold.  
		GameTooltip:AddLine(tostring(content), 1, 1, 1)  
		GameTooltip:SetAnchorType("ANCHOR_TOPLEFT", GameTooltip:GetOwner():GetWidth(),0)  
		GameTooltip:Show() 
	end
	local function TooltipOnLeave(self)  
		GameTooltip:Hide() 
	end 
	frame:SetScript("OnEnter", function() TooltipOnEnter(frame,title,content) end)
	frame:SetScript("OnLeave", function() TooltipOnLeave(frame) end)
end
function RuneEBSetText(EB,text)
	EB:ClearFocus()
	EB:SetText(tostring(text))
	EB:ClearFocus()
	EB:SetText(tostring(text))
	EB:SetCursorPosition(0);
	EB:ClearFocus()
end

function RTAddRolledText(text,rolld,RTmax,type)
	if(tostring(type)=="nil") then
		ChatFrame1:AddMessage(tostring(text),0,1*(rolld/RTmax),0)
	else
		SendChatMessage(tostring(text),type)
	end
end

function RTStartTracking(force)
	if(RT_track==true) then
		ChatFrame1:AddMessage("Roll Tracker: stopped tracking",1,0.2,0.2)
		RT_track = false
	else
		ChatFrame1:AddMessage("Roll Tracker: started tracking",0.2,1,0.2)
		RT_track = true
	end
	if(force==true) then
		ChatFrame1:AddMessage("Roll Tracker: started tracking",0.2,1,0.2)
		RT_track = true
	elseif(force==false) then
		ChatFrame1:AddMessage("Roll Tracker: stopped tracking",1,0.2,0.2)
		RT_track = false
	end

	if(RT_track==true) then
		RuneAddTooltip(RTdice,"Stop Tracking","")
		RTdice:SetNormalTexture("Interface\\BUTTONS/UI-GroupLoot-Pass-Up.png")
		RTdice:SetPushedTexture("Interface\\BUTTONS/UI-GroupLoot-Pass-Up.png")
		RTdice:SetHighlightTexture("Interface\\BUTTONS/UI-GroupLoot-Pass-Up.png")
	else
		RuneAddTooltip(RTdice,"Start Tracking","")
		RTdice:SetNormalTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
		RTdice:SetPushedTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
		RTdice:SetHighlightTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
	end 
end

function RTCreateAndShowExtraButton()
	StaticPopup_EscapePressed()
	local RTFrame = StaticPopup_Show("RT_REPORT")
	RT_reportclosebutton = RuneCreateButton("RTpopupbutton","Guild",30,-15,RTFrame,115,27,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
		local RT_reporter = tonumber(UIDropDownMenu_GetText(RT_reportdropdown))
		if(RT_reporter>#RT_rolls["Name"]) then
			RT_reporttop = #RT_rolls["Name"]
		else
			RT_reporttop = RT_reporter
		end
		
		RT_reportclosebutton:Hide()
		RT_reportdropdown:Hide()
		if(#RT_rolls["Name"]==0) then
			print("You dont have anything to report")
		else
			if(UnitIsInMyGuild("player")) then
				print("Reporting to guild:")
				SendChatMessage("<Roll Tracker> reporting "..tostring(RT_reporttop).." of "..tostring(#RT_rolls["Name"]).." rolls:","GUILD")
				RTReportRolls("GUILD")
			end
		end
		StaticPopup_Hide("RT_REPORT") 
	end) 
	if(RT_reportframe==nil) then
		RT_reportframe = RuneCreateFrame("RT_reportframe",0,-113,RTFrame,210,300,false,false,"TOP","TOP")
		RT_reportframe:SetBackdrop({})
		RT_reportdropdown = RuneCreateDropdownMenu("RT_reportdropdown",75,-10,RT_reportframe ,RT_reports,"TOP","TOP", function(Id,Name,a1,number,a3,a4)  end)
	end
	RT_reportdropdown:Show()
end

RT_EFrame = RuneCreateFrame("RT_EFrame",0,0,nil,200,35,true,true)

--RT_CFrame = RuneCreateFrame("RT_CFrame",0,-100,RT_EFrame,200,200,false,false,"BOTTOMLEFT","BOTTOMLEFT")

RT_SFrame = RuneCreateFrame("RT_SFrame",0,-100,RT_EFrame,200,200,false,false,"BOTTOMLEFT","BOTTOMLEFT")
RT_CFrame,RT_CFrameBG = RuneCreateScrollframe("RTCFrame",0,0,RT_SFrame,"BOTTOMLEFT","BOTTOMLEFT",200-22,200-18,400,400)


RT_EFrame:SetBackdrop({
		bgFile = RT_buttonfill["FrameHeader"],
	})
RT_CFrame:SetBackdrop({
		bgFile = RT_buttonfill["FrameBG"],
	})
RT_SFrame:SetBackdrop({
		bgFile = RT_buttonfill["FrameBG"],
	})
RT_CFrameBG:SetBackdrop({
	bgFile = RT_buttonfill["FrameBG"],
})


local function RTButtonSetTexture(frame,bg1)
	frame:SetNormalTexture(bg1)
	frame:SetHighlightTexture(RT_buttonfill["Highlight"])
	frame:SetPushedTexture(bg3)
	
	return frame
end

function RTupdatecframe()
	for a=1,25 do
		if((14*a)>RT_CFrame:GetHeight()-14) then 
			_G["RTnamefont"..a]:Hide()
			_G["RTnumbfont"..a]:Hide()
		else
			_G["RTnamefont"..a]:Show()
			_G["RTnumbfont"..a]:Show()
		end
	end
end

function RTCreateEFrame()
do --Main Frame
	RT_MFrame = RuneCreateFrame("RT_MFrame",0,0,nil,210,300,false,false)
	RT_MFrame:SetBackdrop({})
end

do --Create Settings Buttons
   --_,RTheader = RuneCreateText("RTheader","Roll Tracker - version: "..RT_version,15,-12,RT_MFrame,500,25,"TOPLEFT","TOPLEFT",false,true,"LEFT") 
    --local rtx=300


  --[[RuneCreateButton("RTcversion","Version Check",rtx,-90,RT_MFrame,100,35,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
	SendAddonMessage("RTcheck", RT_version, "GUILD")
	SendAddonMessage("RTcheck", RT_version, "RAID")
    end)]]

	local button = RuneCreateButton("RTnewroll","",88,-4.3,RT_EFrame,14,14,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
		--if not(tostring(RT_rolls["Name"][1])=="nil") and not(RT_rolls["Name"][1]=="") then
		RTnewpage()
		RTStartTracking(true)
	 end)
	RTButtonSetTexture(button,RT_buttonfill["New Page"])
	RuneAddTooltip(button,"New Page","Starts the tracking on a new page")
 
	local button = RuneCreateButton("RTdeleteroll","",101,-4.3,RT_EFrame,14,14,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
		RTStartTracking(false)
		RTdeletepage()
	end)
	RTButtonSetTexture(button,RT_buttonfill["Del Page"])
	RuneAddTooltip(button,"Delete Page","")
 
 	RTdice = RuneCreateButton("RTstarttracking","",3.5,-4.3,RT_EFrame,15,15,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
		RTStartTracking()
	end)
	RTdice:SetNormalTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
	RTdice:SetPushedTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
	RTdice:SetHighlightTexture("Interface\\BUTTONS/UI-GroupLoot-Dice-Up.png")
	RuneAddTooltip(RTdice,"Start Tracking","")

	local button = RuneCreateButton("RTreport","",117,-3.5,RT_EFrame,15,15,"TOPLEFT","TOPLEFT",function(a1,a2,a3) RTCreateAndShowExtraButton() end)
	RTButtonSetTexture(button,RT_buttonfill["Report"])
	RuneAddTooltip(button,"Report","Report as you have listed the rolls in this frame")
	
	--[[local button = RuneCreateButton("RTsettings","",134,-4,RT_EFrame,14,14,"TOPLEFT","TOPLEFT",function(a1,a2,a3) end)
	RTButtonSetTexture(button,RT_buttonfill["Settings"])
	RuneAddTooltip(button,"Settings","")]]
	
	local button = RuneCreateButton("RTclose","",175,2,RT_EFrame,25,25,"TOPLEFT","TOPLEFT",function(a1,a2,a3) RT_EFrame:Hide() end)
	RTButtonSetTexture(button,RT_buttonfill["Close"])
	button:SetHighlightTexture("")
	RuneAddTooltip(button,"Hide","Type: '/rt' to show the window again")
	
	RTaccept100 = RuneCreateCheckbox("RTaccept100",134,-2.5,RT_EFrame,"TOPLEFT","TOPLEFT",17,17,1,function(self,button,down) 
		if(down) then
			RT_settings["100roll"]=true
		else
			RT_settings["100roll"]=false
		end
	end)
	RuneAddTooltip(RTaccept100,"(1-100)","Only accept (1-100) rolls")
	
	RTGRank = RuneCreateCheckbox("RTGRank",150,-2.5,RT_EFrame,"TOPLEFT","TOPLEFT",17,17,1,function(self,button,down) 
		if(down) then
			RT_settings["GRankReport"]=true
		else
			RT_settings["GRankReport"]=false
		end
	end)
	RuneAddTooltip(RTGRank,"Report guild ranks","Eg. Player1 (Officer) 84 ")
	
	RuneCreateText("RT#","#",4,2,RT_SFrame,500,25,"TOPLEFT","TOPLEFT",false,false,"LEFT") 
	for a=1,25 do 
		_,_G["RTnumbfont"..a] = RuneCreateText("RT#"..a,a,2.5,-14*(a-1),RT_CFrame,20,20,"TOPLEFT","TOPLEFT",true,false,"LEFT")
		_G["RTnumbfont"..a]:SetTextHeight(12)
	end
	
	RuneCreateText("RTPlayerName","Name",22,2,RT_SFrame,500,25,"TOPLEFT","TOPLEFT",false,false,"LEFT") 
	for a=1,25 do 
		_,_G["RTnamefont"..a] = RuneCreateText("RTname"..a,"",22,-14*(a-1),RT_CFrame,78,20,"TOPLEFT","TOPLEFT",true,false,"LEFT")
		_G["RTnamefont"..a]:SetTextHeight(12)
	end
	
	local button,buttonfont = RuneCreateButton("RTPlayerRank","GRank",100,-5,RT_SFrame,45,20,"TOPLEFT","TOPLEFT",function(a1,a2,a3)
		if(RT_guildsort=="up") then
			RT_guildsort="down"
		else
			RT_guildsort="up"
		end
		RT_sortroll="off"
		RTRollSortRoll(RT_sortroll,RT_guildsort)
	end)
	RuneAddTooltip(button,"Guild Rank","Sort Guildranks")
	RTButtonSetTexture(button,"")
	button:SetHighlightTexture("Interface\\BUTTONS/UI-DialogBox-Button-Highlight.png")
	for a=1,25 do 
		_,_G["RTrankfont"..a] = RuneCreateText("RTrank"..a,"",103,-14*(a-1),RT_CFrame,50,20,"TOPLEFT","TOPLEFT",true,false,"LEFT")
		_G["RTrankfont"..a]:SetTextHeight(12)
	end
	
	local button,buttonfont = RuneCreateButton("RTPlayerRoll","Roll",150,-4,RT_SFrame,30,22,"TOPLEFT","TOPLEFT",function(a1,a2,a3)
		if(RT_sortroll=="up") then
			RT_sortroll="down"
		else
			RT_sortroll="up"
		end
		RT_guildsort="off"
		RTRollSortRoll(RT_sortroll,RT_guildsort)
	end)
	RuneAddTooltip(button,"Roll","Sort Rolls")
	RTButtonSetTexture(button,"")
	button:SetHighlightTexture("Interface\\BUTTONS/UI-DialogBox-Button-Highlight.png")
	for a=1,25 do 
		_,_G["RTrollfont"..a] = RuneCreateText("RTroll"..a,"",153,-14*(a-1),RT_CFrame,25,20,"TOPLEFT","TOPLEFT",true,false,"LEFT")
		_G["RTrollfont"..a]:SetTextHeight(12)
	end

end

do --Page Scrolls
function RTpage(frame,page)
--page: 1=next avalible, 2=next unavalible, 3=prev avalible, 4=prev unavaliblve
	if(page==1) then
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up.png")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down.png")	
		frame:SetHighlightTexture(RT_buttonfill["Highlight"])
	end
	if(page==2) then
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Disabled.png")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Disabled.png")
		frame:SetHighlightTexture("")
	end
	if(page==3) then
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up.png")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down.png")
		frame:SetHighlightTexture(RT_buttonfill["Highlight"])
	end
	if(page==4) then
		frame:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Disabled.png")
		frame:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Disabled.png")
		frame:SetHighlightTexture("")
	end
end
	local RTpagetext
	RTpagetext,RTpageid = RuneCreateText("RTpageid",""..RT_pagenumber.."/"..tostring(#RT_savedrolls),-RT_EFrame:GetWidth()+3,-2.8,RT_EFrame,500,15,"TOPLEFT","TOPLEFT",true,false,"CENTER") 
	
RTnextpage = RuneCreateButton("RTnextpage","",73,-2.5,RT_EFrame,17,17,"TOPLEFT","TOPLEFT",function(a1,a2,a3) 
	if not(RT_pagenumber>#RT_savedrolls-1) then 	--if not page is the last, then scroll
		RT_pagenumber=RT_pagenumber+1
		RTpageid:SetText(""..RT_pagenumber.."/"..tostring(#RT_savedrolls)) 
		RTpage(RTprevpage,3)					--prev page icon can be pushed
		--\\\\\\\\\\\\\\\\\\\\\\\Save and refresh page////////////////////////
		RT_savedrolls[RT_pagenumber-1] = RT_rolls
		RT_rolls = RT_savedrolls[RT_pagenumber]	
		RTRollSortRoll(RT_sortroll,RT_guildsort)
		RTUpdateFont()	
		--////////////////////////Save and refresh page\\\\\\\\\\\\\\\\\\\\\\\\\
		if(RT_pagenumber==#RT_savedrolls) then	--if page is the last, then icon cannot be pushed
			RTpage(RTnextpage,2)
		end
	end
end)
		
RTprevpage = RuneCreateButton("RTprevpage","",19,-2.5,RT_EFrame,17,17,"TOPLEFT","TOPLEFT",function(a1,a2,a3)
	if not(RT_pagenumber<2) then 				--if not page is the first, then scroll
		RT_pagenumber=RT_pagenumber-1
		RTpageid:SetText(""..RT_pagenumber.."/"..tostring(#RT_savedrolls)) 
		RTpage(RTnextpage,1)					--next page can be pushed		
		--\\\\\\\\\\\\\\\\\\\\\\\Save and refresh page////////////////////////
		RT_savedrolls[RT_pagenumber+1] = RT_rolls
		RT_rolls = RT_savedrolls[RT_pagenumber]	
		RTRollSortRoll(RT_sortroll,RT_guildsort)
		RTUpdateFont()	
		--////////////////////////Save and refresh page\\\\\\\\\\\\\\\\\\\\\\\\\
		if(RT_pagenumber<2) then				--if page is the first, then icon cannot be pushed
			RTpage(RTprevpage,4)
		end
	end
end)

function RTupdatepagebuttons()
	if(RT_pagenumber<2) then				--if page is the first then set icon to cannot be pushed
		RTpage(RTprevpage,4)
	else									--else push
		RTpage(RTprevpage,3)
	end
	if(RT_pagenumber>#RT_savedrolls-1) then	--if page is the last then set icon to cannot be pushed
		RTpage(RTnextpage,2)
	else									--else push
		RTpage(RTnextpage,1)
	end
end

RTupdatepagebuttons()

end

end

function RTdeletepage()
	if not(#RT_savedrolls==1) then
		tremove(RT_savedrolls, RT_pagenumber)
		
		if(RT_pagenumber>#RT_savedrolls) then
			RT_pagenumber=#RT_savedrolls
		end
		
		RTupdatepagebuttons()

		RTpageid:SetText(""..RT_pagenumber.."/"..tostring(#RT_savedrolls)) 
		
		RT_rolls = RT_savedrolls[RT_pagenumber]
		if(RT_rolls==nil) then					--rolltracker dont like an empty table
			RT_rolls = RTresetrolls()
		end
		
		RTUpdateFont()
	else 										--ctr+c! ftw!
		RT_savedrolls[RT_pagenumber] = RTresetrolls()
		RT_rolls = RT_savedrolls[RT_pagenumber]
		if(RT_rolls==nil) then					--rolltracker dont like an empty table
			RT_rolls = RTresetrolls()
		end
		
		RTupdatepagebuttons()
		
		RTUpdateFont()
	end
end

function RTnewpage()
	RT_savedrolls[RT_pagenumber] = RT_rolls
	tinsert(RT_savedrolls,1,RTresetrolls())
	RT_pagenumber = 1
	
	RTupdatepagebuttons()

	RTpageid:SetText(""..RT_pagenumber.."/"..tostring(#RT_savedrolls)) 
	
	RT_rolls = RT_savedrolls[1]
	
	RTUpdateFont()
end

function RTReturnFont(number)
	return _G["RTnamefont"..number]
end

function RTreturnwinning(name) 
	local count,thispage=0,false
	for a=1,#RT_savedrolls do
		for b=1,#RT_savedrolls[a]["Name"] do
			local namecheck = RT_savedrolls[a]["Name"][b]
			if(name==namecheck) then
				local won = RT_savedrolls[a]["Won"][b]
				if not(won=="") then
					if(a==RT_pagenumber) then
						count = count +1
						thispage = true
					elseif(count==0) then
						count = count+1
					end
				end
			end
		end
	end
	return count,page,thispage
end

function RTUpdateFont()
	RT_savedrolls[RT_pagenumber] = RT_rolls
	local a;
	for a=1,26 do
		local namebuttonTF = _G["RTnamefont"..tostring(a)]
		local rankbuttonTF = _G["RTrankfont"..tostring(a)]
		local rollbuttonTF = _G["RTrollfont"..tostring(a)]
		local numbbuttonTF = _G["RTnumbfont"..tostring(a)]
		if(namebuttonTF) then
			namebuttonTF:SetText("Unknown")
			namebuttonTF:SetTextColor(1, 0.2, 0.2, 0.5)
			rankbuttonTF:SetText("Noone")
			rankbuttonTF:SetTextColor(1, 0.2, 0.2, 0.5)
			rollbuttonTF:SetText("0")
			rollbuttonTF:SetTextColor(1, 0.2, 0.2, 0.5)
			numbbuttonTF:SetTextColor(1,1,1,1)
		end
	end
	if(#RT_rolls["Name"]>0) then
		for a=1, #RT_rolls["Name"]+1 do
			local namebuttonTF = _G["RTnamefont"..tostring(a)]
			local rankbuttonTF = _G["RTrankfont"..tostring(a)]
			local rollbuttonTF = _G["RTrollfont"..tostring(a)]
			local numbbuttonTF = _G["RTnumbfont"..tostring(a)]
			if not(tostring(RT_rolls["Name"][a])=="nil") and not(namebuttonTF==nil) then
				local gname,grank,gindex = RTGetGuildRank(tostring(RT_rolls["Name"][a]))
				
				rankbuttonTF:SetText(grank)
				if not(grank=="Noone") then
					rankbuttonTF:SetTextColor(1-(gindex*500)/10000, 1-(gindex*2000)/10000, 0, 1)
				else
					rankbuttonTF:SetTextColor(1, 0.2, 0.2, 0.5)
				end
				
				rollbuttonTF:SetText(tostring(RT_rolls["Roll"][a]))
				rollbuttonTF:SetTextColor(0.2,RT_rolls["Roll"][a]/100, 0.7, 1)
				
				namebuttonTF:SetText(""..tostring(RT_rolls["Name"][a]).."")--: "..tostring(RT_rolls["Roll"][a]).." "..tostring(RT_rolls["Id"][a]).." "..tostring(extratext))
				namebuttonTF:SetTextColor(0.2, 1, 0.2, 1)
				
				local won,page,thispage = RTreturnwinning(tostring(RT_rolls["Name"][a]))
				if(won>0) then
					if(thispage==true) then
						numbbuttonTF:SetTextColor(0,1,0,1)
					elseif(page==RT_pagenumber) then
						numbbuttonTF:SetTextColor(1,1,1.2,1)
					else
						numbbuttonTF:SetTextColor(1,0.2,0.2,1)
					end
				end
			end
		end
	end
end

local RT_eventframe = CreateFrame("Frame")
RT_eventframe:RegisterEvent("ADDON_LOADED")
RT_eventframe:RegisterEvent("PARTY_MEMBERS_CHANGED")
RT_eventframe:RegisterEvent("CHAT_MSG_ADDON")
RT_eventframe:RegisterEvent("CHAT_MSG_SYSTEM")
RT_eventframe:SetScript("OnEvent", function(self,event,SystemMessage,a2,a3,a4,a5)
	if(event=="CHAT_MSG_SYSTEM") then
		if(RT_track==true) then
			local RollName, Roll,Rolled, RollID = strsplit(" ",SystemMessage,4) 
			if(Roll=="rolls") then
				if not(RT_settings["100roll"]==true) then
					RTRollSort(tonumber(Rolled),tostring(RollName),tostring(RollID))
				elseif(RollID=="(1-100)") and (RT_settings["100roll"]==true) then
					RTRollSort(tonumber(Rolled),tostring(RollName),tostring(RollID))
				end
			end
		end
	end
	if(event=="ADDON_LOADED") then
		if(RT_logged==false) then
			if(tostring(RT_settings)=="nil") then
				RT_settings = {
				["100roll"]=true,
				["GRankReport"]=true
				}
			end
			if(tostring(RT_savedrolls)=="nil") then
				RT_rolls = {
				["Name"]={},
				["Roll"]={},
				["Id"]={},
				["Won"]={}
				}
				RT_savedrolls = {RT_rolls}
			else
				RT_rolls = RT_savedrolls[1]
			end
			if(RT_firstlogin==nil) then
				print("\124cbc33cbc3This is first time you are using\124h\124r \124cFFC2C050Roll Tracker:\124h\124r \124cbc33cbc3\124h\124r")
				print("\124cbc33cbc3#1:\124h\124r\124cff192ff0Type \124cFFC2C050'/rt' or '/rolltracker' \124cbc33cbc3to show the main window\124h\124r")
				print("\124cbc33cbc3#2:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtwon name itemlink' \124cbc33cbc3to save the character as winner of the item\124h\124r")
				print("\124cbc33cbc3#3:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtlost name' \124cbc33cbc3to delete the character as winner of the roll\124h\124r")
				print("\124cbc33cbc3#4:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtcheck name' \124cbc33cbc3to see the items that character has won (checking all pages)\124h\124r")
				print("\124cbc33cbc3#5:\124h\124r\124cff192ff0Type \124cFFC2C050'/rthelp' \124cbc33cbc3to see the list of commands\124h\124r")
				print('\124caa55aa55Thanks for using Roll Tracker! \124h\124r')
				RT_firstlogin=true
			end
			if(UnitIsInMyGuild("player")) then
				SendAddonMessage("RTversion", RT_version, "GUILD")
			end
			RTCreateEFrame()
			RTRollSortRoll(RT_sortroll,RT_guildsort)
			RTUpdateFont()
			if(RT_settings["100roll"]) then RTaccept100:SetChecked(true) else RTaccept100:SetChecked(false) end
			if(RT_settings["GRankReport"]) then RTGRank:SetChecked(true) else RTGRank:SetChecked(false) end
			RT_logged = true
		end
	end
	if(event=="CHAT_MSG_ADDON") then
		local prefix = tostring(SystemMessage)
		local message = tostring(a2)
		local type = tostring(a3)
		local sender = tostring(a4)
		if(prefix=="RTversion") then
			local newversion=tonumber(message)

			if(newversion>RT_exversion) then
				print("The newest version of \124cffff6600Roll Tracker ("..newversion..")\124h\124r is out now! \124cffff6600["..sender.."]\124h\124r has it, why dont you get it?")
				RT_exversion=newversion
			end
		end
		if(prefix=="RTcheck") then
			SendAddonMessage("RTtrue", RT_version.." "..type, "WHISPER",sender)
		end
		if(prefix=="RTtrue") then
			local a,b = strsplit(" ", message)  
			if(b=="GUILD") then
				ChatFrame1:AddMessage("In Guild:\124Hplayer:"..sender.."\124h \124cffff6600"..sender.."\124h\124r has Roll Tracker - Version: \124cffff6600"..a.."\124h\124r",0,255,0)
			elseif(b=="RAID") then
				ChatFrame1:AddMessage("In Raid:\124Hplayer:"..sender.."\124h \124cffff6600"..sender.."\124h\124r has Roll Tracker - Version: \124cffff6600"..a.."\124h\124r",255,0,0)
			end
		end
	end
	if (event=="PARTY_MEMBERS_CHANGED") then
		SendAddonMessage("RTversion", RT_version, "RAID")
	end
end)


function RTreturnhighest(name)
	local highest = 0
	local index
	name=strlower(name)
	
	for a=1,#RT_rolls["Name"] do
		current = RT_rolls["Name"][a]
		if(name==strlower(current)) then
			index = a
		end
	end
	
	return index
end

function RTcheckwonitems(name)
	local items
	items = ""
	
	for a=1,#RT_savedrolls do
		for b=1,#RT_savedrolls[a]["Name"] do
			local namecheck = RT_savedrolls[a]["Name"][b]
			local itemcheck = RT_savedrolls[a]["Won"][b]
		
			if(strlower(namecheck)==strlower(name)) then
				if not(itemcheck=="") then
					if(items=="") then
						items = itemcheck
					else
						items = ""..items..", "..itemcheck
					end
				end
			end
		end
	end

	return items
end

SLASH_RT1, SLASH_RT2 = '/rolltracker', '/rt'; 
function SlashCmdList.RT(msg) 
	RT_EFrame:Show()
end

SLASH_RTWON1, SLASH_RTWON2,SLASH_RTWON3, SLASH_RTWON4 = '/rtwon', '/rtwinner','/rolltrackerwon','/rolltrackerwinner'; 
function SlashCmdList.RTWON(name) 

	local name,item = strsplit(" ",name,2)
	local index =  RTreturnhighest(name)
	if not(tostring(index)=="nil") then
		if(tostring(item)=="nil") then
			item="Noone"
		end
		RT_rolls["Won"][index]=tostring(item)
		print(""..name.."".." won: "..tostring(item))
		RTUpdateFont()
	end
end

SLASH_RTLOST1, SLASH_RTLOST2,SLASH_RTLOST3, SLASH_RTLOST4 = '/rtloss', '/rtlost','/rolltrackerlost','/rolltrackerloss'; 
function SlashCmdList.RTLOST(name) 

	local name,item = strsplit(" ",name,2)
	local index = RTreturnhighest(name)
	if not(tostring(index)=="nil") then
		RT_rolls["Won"][index]=""
		print(""..name.."".." didnt won")
		RTUpdateFont()
	end
end

SLASH_RTCHECK1, SLASH_RTCHECK2,SLASH_RTCHECK3, SLASH_RTCHECK4 = '/rtcheck', '/rtcheck','/rolltrackercheck','/rolltrackercheck'; 
function SlashCmdList.RTCHECK(name) 

	local name,item = strsplit(" ",name,2)	
	items = RTcheckwonitems(tostring(name))

	print(""..name.." has won: "..items)
end

SLASH_RTHELP1, SLASH_RTHELP2,SLASH_RTHELP3, SLASH_RTHELP4 = '/rthelp', '/rthelp','/rolltrackerhelp','/rolltrackerhelp'; 
function SlashCmdList.RTHELP(name) 
	print("\124cbc33cbc3#1:\124h\124r\124cff192ff0Type \124cFFC2C050'/rt' or '/rolltracker' \124cbc33cbc3to show the main window\124h\124r")
	print("\124cbc33cbc3#2:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtwon name itemlink' \124cbc33cbc3to save the character as winner of the item\124h\124r")
	print("\124cbc33cbc3#3:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtlost name' \124cbc33cbc3to delete the character as winner of the roll\124h\124r")
	print("\124cbc33cbc3#4:\124h\124r\124cff192ff0Type \124cFFC2C050'/rtcheck name' \124cbc33cbc3to see the items that character has won (checking all pages)\124h\124r")
	print("\124cbc33cbc3#5:\124h\124r\124cff192ff0Type \124cFFC2C050'/rthelp' \124cbc33cbc3to see the list of commands\124h\124r")
end


